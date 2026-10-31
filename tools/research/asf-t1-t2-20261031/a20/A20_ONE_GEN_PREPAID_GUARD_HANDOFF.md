# A20 PixelLab paid Tier-1 first low-cost source-locked T1 test (2026-10-31)

STATUS: **PREPARED, NOT RUN AGAINST LIVE PAID API; NO CREDITS SPENT BY A20**.
User has purchased PixelLab $12 Tier 1 and explicitly authorizes a conservative test. Official pricing page advertises 2,000 monthly generation units and unlocks skeleton animation. Official new animate-with-text supports 4 frames at 128x128 for 1 generation, exact service charge must be verified from before/after `GET /v2/balance`. This run is NOT the Tier-1 skeleton test; it establishes one low-cost comparison baseline.

A20 private ChatGPT downloadable ZIP: `A20_T1_PIXELLAB_SAFE_ONE_GEN_20261031.zip`; five files (~11.9 KB), CRC PASS, SHA256 `326ab8779536b0ddd73e055eaf1a4e094c00560f6e76c46d02a74154dc3e6c45`.
Contains source A15 T1 attack_02 exact PNG SHA256 `88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f`, Python one-shot runner, Windows CMD launcher, Chinese README and offline mock regression.
Only one POST to `/v2/animate-with-text-v3` may happen, and ONLY after local secure API token entry, successful paid balance with >10 remaining and explicit `RUN_ONE` confirmation. First frame supplied as **raw base64 bytes, no data URL prefix**, correcting likely prior payload format issue. Prompt is a short single sword slash, frames=4 at 96x112, transparent background, seed 16031, prompt enhance disabled. Input sourced from exact A15 bytes, no resizing.
Abort if GET balance fails, account remains trial, or quota missing. Prevent double-charging using immutable A20_JOB_LOCK.json created BEFORE POST. No automatic POST retry; any failure requires review. Supports sync images or asynchronous background ID, 4 or 5 outputs including echoed original. Saves raw PNG and 4x review image, computes pixel QA; G7 pending visual review, never auto-imports to FS.
All offline source, mock (balance / one POST / five frames / repeat blocked), ZIP CRC were verified in ChatGPT container; **no real user PixelLab API action completed**. User runs launcher once. Local token never stored, sent to ChatGPT, or committed to GitHub/Drive.

A19D2 Windows RX6700XT genuine ROCm GPU dispatch passed immediately prior, but local SD1.5 inpainting is an independent avenue. Freeze new local model downloads while testing paid PixelLab one image route, don't combine experiments.

References:
https://www.pixellab.ai/docs/tools/animate-with-text-new
https://www.pixellab.ai/docs/tools/animate-with-skeleton
https://api.pixellab.ai/v2/docs
