# Game Asset Forge Apps Script Redirect Proxy

Purpose: provide a redirect-safe HTTPS JSON endpoint for Custom GPT Actions while keeping Google Apps Script as the PixelLab finalizer and Google Drive writer.

Architecture:

```text
Game Asset Forge
  -> Cloudflare Worker Free proxy
  -> Google Apps Script Web App
  -> PixelLab background job status
  -> Apps Script decodes completed image.base64
  -> Google Drive PNG
  -> small JSON response
  -> Worker follows Google's ContentService redirect
  -> Game Asset Forge
```

This Worker does not use R2 and does not store images.

## Why this proxy exists

Google Apps Script ContentService redirects responses to a one-time `script.googleusercontent.com` URL. Some Custom GPT Action calls do not successfully consume that redirect chain and may return Google HTML or errors instead of the intended JSON.

The Worker explicitly fetches Apps Script with `redirect: 'follow'`, parses the final response as JSON, then returns clean JSON directly from the `workers.dev` domain.

## Configuration

Edit `wrangler.jsonc` and replace:

```text
REPLACE_WITH_APPS_SCRIPT_EXEC_URL
```

with the deployed Apps Script Web App URL ending in `/exec`.

Example:

```text
https://script.google.com/macros/s/AKfycb.../exec
```

Do not append `/health` or `/finalize` in the variable; the Worker adds the route.

## Deploy on Workers Free

```bash
npm install
npx wrangler login
npm run deploy
```

Expected URL:

```text
https://game-asset-forge-apps-script-proxy.<account>.workers.dev
```

Test:

```text
GET https://...workers.dev/health
```

Expected JSON:

```json
{"ok":true,"service":"game-asset-forge-apps-script-finalizer","version":"1.0.0"}
```

## Game Asset Forge Action

Use `openapi.proxy-finalizer.yaml` and replace its server URL with the Worker URL.

Authentication: None for this MVP.

Available operations:

- `getAssetFinalizerHealth`
- `finalizePixelLabImageJob`

## Security scope

The proxy exposes only `/health` and `/finalize`. It cannot start PixelLab generations and does not know the PixelLab token. Generation remains in the separate PixelLab queue-only Action.

The Apps Script finalizer itself only accepts existing PixelLab job IDs and stores completed results in the configured Drive folder.
