# A16 R4 diagnostic — 2026-10-31

## Observed real result
The user executed RUN_ONE_SHOT_SECURE.ps1 with token on Windows. Desktop Commander read:
- A16_R4_PIXELLAB_JOB.json and A16_R4_V2_STATUS.json report status=SUBMISSION_UNKNOWN_OR_FAILED, operation=submit, HTTPError HTTP 400.
- No accepted background_job_id and no generation PNG. The real endpoint rejected the request. Do not claim animation generated or G7 pass.
- The presence of the job JSON does NOT mean the generation was accepted.

## Next non-billable diagnostic
PixelLab OpenAPI currently exposes GET /v2/balance with HTTPBearer auth, returning 200 with account info or 401 invalid key.
Three private-local files were created in Windows working directory:
- DOUBLE_CLICK_CHECK_AUTH_ONLY.cmd (double-clickable Windows command)
- CHECK_PIXEL_LAB_AUTH_ONLY.ps1 (secure token entry)
- CHECK_PIXEL_LAB_AUTH_ONLY.py (GET /v2/balance only, no POST, no secrets logged or saved).
The Python script was bytecode compiled and tested with no token: exits MISSING_TOKEN with NO HTTP request.
User needs to run the new .cmd and report RESULT line. If AUTH_OK, investigate PixelLab backend request rejection without blind retry. If 401, correct token. Keep original failed job JSON intact for audit.

## Source facts
PixelLab v2 live openapi confirms first_frame, action, frame_count, no_background, seed, enhance_prompt properties for animate-with-text-v3, plus GET balance. 96x112 RGBA and 4 frames meet documented image size and frame budget; HTTP 400 exact server cause unknown because prior script suppressed error body. No billing claim can be made solely from HTTP status.

## Stop
NO further animation POST without diagnosing token and original HTTP 400 response. Original A15 and FS sealed assets unchanged.
