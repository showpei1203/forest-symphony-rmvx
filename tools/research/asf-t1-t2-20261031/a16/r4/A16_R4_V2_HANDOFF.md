# FS / ASF A16 R4 V2 Official Async API Correction Handoff (2026-10-31)

## Status
PREPARED / BLOCKED_NO_API_TOKEN / API IMAGE GENERATION NOT RUN / ART G7 NOT TESTED.
No token or account session was available through the connected terminal. Chrome is running but exposes no existing remote-debugging interface, so a logged-in Creator page cannot currently be operated safely through these tools. Do not read browser cookies or extract account secrets.

## Important correction
The original R4 client assumed POST /v2/animate-with-text-v3 returns images synchronously. Official live OpenAPI disproves this:
POST returns background_job_id; GET /v2/background-jobs/{job_id} returns last_response.images when completed.
V2 client replaces the broken behavior and explicitly prevents duplicate POSTs by saving a job state file. Invalid or uncertain submit results require manual review before any new submit.

## Verified with official online schema and offline mock
- Request keys: first_frame, action, frame_count, no_background, seed, enhance_prompt.
- Reference is the exact 96x112 A15 T1 attack_02 RGBA PNG, SHA256 88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f.
- first_frame.base64 is data:image/png;base64,...; 4 frames; no_background=true; enhance_prompt=false, avoids extra enhancement charge.
- Live GET /v2/openapi.json HTTP 200; official AnimateWithTextV3Request properties/required fields match the payload.
- An end-to-end OFFLINE fake job test exercised submit/process/complete/decode/save four RGBA frames and tested duplicate submit suppression. Synthetic images were in TemporaryDirectory and deleted. They are NOT generated sprite assets.
- No real POST /v2/animate-with-text-v3 occurred, no credits spent, no images produced.
- Run a16_r4_pixellab_pilot_v2.py --submit once with PIXELLAB_API_KEY in process environment; then use --poll as often as needed, without resubmitting. RUN_ONE_SHOT_SECURE.ps1 is the local secure launcher. A new request is potentially billable when account is authorized.

## Stop gates
If real PixelLab returns four raw RGBA frames, validate sizes, transparency, first-frame identity and temporal differences. Mark G7 PENDING human judgement. Never promote to ASF / FS / Godot / VX before art approval.
Prior A16 R3 .ase source and sealed FS project unchanged.

## Storage
Private Windows local location:
E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF
