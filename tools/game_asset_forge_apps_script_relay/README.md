# Game Asset Forge Apps Script PixelLab Finalizer v1

Related Linear: `SHO-43`

## Purpose

Large completed PixelLab background-job responses contain `last_response.image.base64`, which can exceed Custom GPT Action response limits.

This design keeps PixelLab generation direct and authenticated, but moves only the large-result finalization step into Google Apps Script:

```text
Game Asset Forge
  -> PixelLab queue action (Bearer auth)
  -> small background_job_id
  -> Apps Script finalizer (no generation capability)
  -> Apps Script polls PixelLab using token stored in Script Properties
  -> completed base64 decoded server-side
  -> PNG saved to Google Drive
  -> small JSON image_url returned to Game Asset Forge
```

Security advantage: the public Apps Script web app cannot start PixelLab generations or spend PixelLab credits. It can only finalize an already-existing PixelLab job ID.

## Files

- `Code.gs` — Apps Script web app
- `appsscript.json` — explicit runtime/scopes
- `openapi.pixellab-queue-only.yaml` — first GPT Action; Bearer-authenticated direct PixelLab queue/balance operations
- `openapi.apps-script-finalizer.yaml` — second GPT Action; Apps Script finalization only

## Current destination

Destination profile:

`fs_map_candidates`

Script Property:

`FS_MAP_CANDIDATE_FOLDER_ID`

Current Forest Symphony Drive target:

`01_Benchmarks/Maps/FS_Map_Forest_Clearing_01/01_Concept_Candidates`

Folder ID:

`1rFAwXI_1nZJGIovIbYa29mNubnUaC2VZ`

## Apps Script setup

1. Open `https://script.google.com/` and create a new standalone project.
2. Name it `Game Asset Forge PixelLab Finalizer`.
3. Replace the default `Code.gs` with this repository's `Code.gs`.
4. In Project Settings, enable showing the `appsscript.json` manifest file if needed, then replace it with this repository's manifest.
5. In Project Settings -> Script Properties, add:

```text
PIXELLAB_API_TOKEN = <your real PixelLab token>
FS_MAP_CANDIDATE_FOLDER_ID = 1rFAwXI_1nZJGIovIbYa29mNubnUaC2VZ
```

Do not place the PixelLab token in GitHub or either GPT Action schema.

6. Deploy -> New deployment -> Web app.
7. Execute as: Me.
8. Who has access: Anyone.
9. Authorize external requests and Drive access when Google prompts.
10. Copy the deployment URL ending in `/exec`.

Apps Script web apps require `doGet`/`doPost`; this project uses both. The web app executes as the owner so it can call PixelLab and write into the configured Drive folder.

## Why the Apps Script Action has no API-key auth

Google Apps Script Web App event objects expose query/body/path parameters but do not provide a supported arbitrary-request-header interface for `doGet`/`doPost`. Therefore the v1 Apps Script finalizer does not depend on the GPT Action Authorization header.

To keep the public surface safe, v1 deliberately has NO generation endpoint and accepts only a PixelLab job ID plus a constrained destination profile.

Keep Game Asset Forge private. Do not publish this configuration as a public GPT without adding a stronger authenticated gateway.

## Configure Game Asset Forge

Use two Actions.

### Action A — PixelLab Queue

Schema:

`openapi.pixellab-queue-only.yaml`

Authentication:

```text
API Key -> Bearer
value = your PixelLab API token
```

Available operations:

- `getPixelLabBalance`
- `queuePixelArtImage`

Do NOT expose `GET /background-jobs/{job_id}` directly to the GPT, because a completed job may return a large base64 image.

### Action B — Apps Script Finalizer

Schema:

`openapi.apps-script-finalizer.yaml`

Before pasting it into the GPT editor, replace:

```text
https://script.google.com/macros/s/REPLACE_DEPLOYMENT_ID/exec
```

with the real `/exec` deployment URL.

Authentication:

```text
None
```

Available operations:

- `getAssetFinalizerHealth`
- `finalizePixelLabImageJob`

## GPT instruction block

Add to Game Asset Forge instructions:

```text
# PIXELLAB LARGE IMAGE TRANSPORT

For normal PixelLab generation, call queuePixelArtImage.
Record the returned background_job_id.

Never call PixelLab background-job retrieval directly from ChatGPT.
Instead call finalizePixelLabImageJob with:
- job_id = background_job_id
- asset_id = current candidate ID
- destination = fs_map_candidates for the active FS map benchmark

If finalizer status=processing, do not claim completion. Retry finalization later.
If status=failed, report the returned failure code.
If status=completed, use image_url / drive_view_url as the candidate image and begin Visual Acceptance only after the PNG is visibly accessible.

A successful queue request is not a completed asset.
Do not transport or print image.base64 inside ChatGPT.
```

## First tests

### 1. Health

Open:

`<DEPLOYMENT_URL>/health`

Expected small JSON:

```json
{"ok":true,"service":"game-asset-forge-apps-script-finalizer","version":"1.0.0"}
```

### 2. 64x64 smoke test

Game Asset Forge:

1. call `queuePixelArtImage`
2. receive `background_job_id`
3. call `finalizePixelLabImageJob`
4. if processing, retry later
5. on completed, confirm PNG is in Drive and URL opens

### 3. Real gate

Asset:

`FS_Map_Forest_Clearing_01_A`

Size:

`272x208`

Acceptance:

- PixelLab job completes
- no `ResponseTooLargeError`
- Apps Script decodes PNG
- PNG saved into `01_Concept_Candidates`
- returned image URL opens without login
- Game Asset Forge can visually inspect the image

## Idempotency

The finalizer names files:

`<asset_id>__<job_id>.png`

If the same completed job is finalized again, the existing file is returned instead of writing another duplicate.

## Current limitations

- The destination list is intentionally restricted to `fs_map_candidates` in v1.
- Google Workspace administrators can disable `ANYONE_WITH_LINK`; if that happens, the Drive file is still saved but public image display may fail.
- Apps Script ContentService returns JSON but does not provide rich HTTP-status control; application status is carried in the JSON body.
- This is a private-production MVP. A public/multi-user Game Asset Forge should add a stronger authenticated gateway.
