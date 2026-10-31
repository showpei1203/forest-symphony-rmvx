# FS / ASF A16 R4 PixelLab single-sprite pilot — HANDOFF (2026-10-31)

## Exact status
**PREPARED / BLOCKED_NO_PIXEL_LAB_API_KEY / NO GENERATION PERFORMED.** G7 ART NOT RUN.
No repeated A15 mechanical art attempts. No image-generation infographic candidate is included.
The official PixelLab API v2 docs are reachable on Windows (HTTP 200 for /v2/llms.txt). No PIXELLAB_API_KEY or PIXELLAB_TOKEN was detected in the authenticated process's environment. No PixelLab-specific ChatGPT plugin was available.
Calling the runner with --run and no key stopped before any billable network request. Credits spent = 0.

## Technical preparation
Source: A15 T1 forest scout original attack_02, 96×112 RGBA, unchanged bytes.
Source SHA256: 88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f.
Target official endpoint: POST https://api.pixellab.ai/v2/animate-with-text-v3.
Parameters: source first_frame base64 PNG, action single sword slash, frame_count 4, no_background true, seed 16031.
Frame-pixel budget 96 × 112 × 4 = 43,008, within PixelLab limit 524,288.
Exact action and gate definitions in A16_R4_REQUEST_SPEC.json.
Visible preview of original only (6× nearest-neighbor), not generated art.

## Execution boundary
A single 'one-shot' Python runner exists but will not contact the endpoint unless explicitly invoked with --run and a credential in PIXELLAB_API_KEY or PIXELLAB_TOKEN.
Windows launcher RUN_ONE_SHOT_SECURE.ps1 uses hidden keyboard input in PowerShell session; no token is saved to file. Do not paste secrets into GitHub/Drive/chat.
No automatic retries. Even if 4 RGBA images come back, art gate G7 stays PENDING HUMAN VISUAL REVIEW.
If the app's free Creator UI is preferred over API access, use original T1_A15_attack_02_SOURCE.png and request settings from JSON; save original 96×112 transparent PNG frames directly. Do not send old generated presentation images to the sprite pipeline.

## Failure/stop rules
Reject if new identities, face/armor/cloak changes, multiple swords/arms, background, rescaling, wrong dimensions, blurry pixels, no visible arm bending, or unconvincing weight transfer.
Perform at most three *materially different* art-generation trials total. Only if G7 passes can an 8-frame sprite-sheet/Godot gate begin.
A15 archive / A16 R3 editable files remain untouched.

## Storage
Windows-only private source and executable test bundle:
E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF
