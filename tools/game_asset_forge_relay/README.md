# Game Asset Forge PixelLab Relay v1

Related Linear: `SHO-43 | Shared Asset Pipeline｜PixelLab Relay + R2 Transport I`

## Purpose

PixelLab returns generated Pixflux PNGs as `image.base64`. Large map candidates can exceed Custom GPT Action response limits. This relay keeps the large payload server-side:

```text
Game Asset Forge
  -> Worker /v1/pixflux/jobs
  -> PixelLab background job
  -> Worker polls PixelLab
  -> Worker decodes last_response.image.base64
  -> private R2 bucket
  -> small JSON containing image_url
  -> Game Asset Forge
```

The R2 bucket does not need public bucket access. PNGs are served by the Worker through `/assets/*`.

## Endpoints

- `GET /health` public health check
- `GET /v1/balance` authenticated PixelLab balance proxy
- `POST /v1/pixflux/jobs` authenticated image-job submission
- `GET /v1/pixflux/jobs/{job_id}` authenticated polling/finalization
- `GET /assets/{key}` public read-only asset delivery

## Security

Two secrets are required:

- `PIXELLAB_API_TOKEN`: real PixelLab API token. Never place this in GitHub or the GPT Action schema.
- `RELAY_API_KEY`: a separate random secret used by Game Asset Forge to authenticate to this Worker.

The R2 binding itself does not require an R2 secret inside Worker code.

## Cloudflare deployment

### 1. Create the R2 bucket

```bash
npx wrangler login
npx wrangler r2 bucket create game-asset-forge-assets
```

The checked-in `wrangler.jsonc` binds that bucket as `ASSETS`.

### 2. Install dependencies

```bash
cd tools/game_asset_forge_relay
npm install
```

### 3. Configure Worker secrets

```bash
npx wrangler secret put PIXELLAB_API_TOKEN
npx wrangler secret put RELAY_API_KEY
```

Enter each value interactively. Do not commit either secret.

### 4. Deploy

```bash
npm run deploy
```

Wrangler prints a Worker URL similar to:

```text
https://game-asset-forge-relay.<account-subdomain>.workers.dev
```

Test:

```text
GET https://...workers.dev/health
```

Expected:

```json
{"status":"ok","service":"game-asset-forge-relay","version":"1.0.0"}
```

## Configure Game Asset Forge Action

1. Open `openapi.game-asset-forge.yaml`.
2. Replace `https://REPLACE-WITH-YOUR-WORKER.workers.dev` with the deployed Worker URL.
3. In the GPT Action editor, replace the direct PixelLab schema with this relay schema.
4. Authentication: API Key -> Bearer.
5. The API key entered in the GPT editor must be `RELAY_API_KEY`, not the PixelLab token.

After this change the GPT only talks to the Worker. The Worker alone knows the PixelLab token.

## Required GPT instruction block

Add this to Game Asset Forge instructions:

```text
# PIXELLAB RELAY OUTPUT AUTHORITY

For PixelLab image generation, use startPixelLabImageJob and then poll getPixelLabImageJob.

Do not call PixelLab directly.

When status=processing, continue polling later and do not claim completion.
When status=failed, report GENERATION FAIL and the returned error.
When status=completed:
1. Use image_url as the authoritative generated PNG.
2. Display the image using the returned image_markdown or Markdown image syntax.
3. Keep asset_id, width, height, seed and job ID with the candidate.
4. Only after the image is visibly available may Visual Acceptance begin.

Do not request, print, transport or decode PixelLab image.base64 inside ChatGPT.
IMAGE_OUTPUT_TRANSPORT_FAIL is distinct from PIXELLAB_GENERATION_FAILED.
```

## First acceptance test

Submit a small smoke test first:

```json
{
  "asset_id": "GAF_RELAY_SMOKE_64",
  "description": "simple green grass pixel art tile with a few small stones",
  "image_size": {"width": 64, "height": 64},
  "no_background": false,
  "seed": 1234
}
```

Then test the real gate:

```text
FS_Map_Forest_Clearing_01_A
272 x 208
```

Acceptance requires:

- PixelLab job reaches `completed`
- Worker stores PNG in R2
- job response stays small and contains `image_url`
- `image_url` returns a valid PNG
- Game Asset Forge visibly displays the map
- no `ResponseTooLargeError`

## R2 object layout

```text
jobs/<pixellab_job_id>.json
jobs/<pixellab_job_id>.result.json
assets/<asset_id>/<pixellab_job_id>.png
```

A completed job is cached in `*.result.json`, so repeated polling does not repeatedly fetch/decode the large PixelLab base64 response.
