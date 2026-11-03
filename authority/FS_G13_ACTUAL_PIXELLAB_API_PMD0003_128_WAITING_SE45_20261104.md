# FS G13 | Verified REAL PixelLab API animation (PMD0003 Waiting)

Date: 2026-11-04 Asia/Taipei. Stage: REAL API EXPERIMENT, visual art pending.

## Explicit correction
A preceding attempt created a beautiful three-stage concept and three 3×4 sprite sheets using **ChatGPT ImageGen, not PixelLab**. These were wrongly presented as though PixelLab had been used. Those sheets are concept/rough motion illustrations only; not production sprites. User correctly rejected the sprite sheets.

This new G13 test **actually called** the user's existing authorized PixelLab account using its secure pre-existing local credential on connected DESKTOP-90VT437, via PixelLab `POST /v2/animate-with-text-v3`. Token never exported or logged. This is NOT a claimed success based on ImageGen.

## Input and provider proof
- Input image: the user-liked ImageGen three-stage concept; cut out only PMD0003 largest lava rock frog and resized into a transparent 128×128 first-frame reference. Shared Drive source `PMD0003_PixelLab_Concept128.png`.
- Actual external API accepted the animation: HTTP 200, **Job ID `0b6aceb9-c121-4ac4-9da6-705cf9cfb209`**.
- Provider job status `completed`, polled by GET. No duplicate POST, no resubmission; exact original five images retrieved by **GET /background-jobs/{job}**.
- Prompt action: SE 45-degree crouched subtle idle-breathing loop, synchronized chest/shoulder/head motion, four feet stationary, original basalt and lava markings unchanged in meaning, no flowers/leaves/petals/plants/disconnected rocks/extra limbs.
- Request `frame_count=4`. Actual provider delivered **five** 128×128 RGBA frames, as the source image is returned in addition to animated frames. The first returned frame is **pixel-exact identical** to input.
- Balance before: 1607.099999999999 / 2000 generations. After: 1606.099999999999 / 2000. **Exactly 1 generation used**, from provider balance difference.
- Technical data: all five frames 128×128 RGBA; full original five-frame 640×128 PNG and GIF saved. For FS-style 3-key evaluation, images indexed **0,2,4** selected as `PMD0003_WAITING_1.png`, `_2.png`, `_3.png`, and a 4-phase 0-2-4-2 GIF constructed. The choice is editorial selection, NOT pretending PixelLab returns only three frames.
- Source bounding boxes by frame: (3,17,125,119), (10,16,125,119), (10,12,125,119), (10,11,125,119), (10,14,125,119). No opaque pixels on extreme top/bottom row. All 5 PNGs truly different other than first source exact match.

## Actual artifact delivery
- Google Drive folder: https://drive.google.com/drive/folders/10LhlfR7crNMX67ADLYLNqydwO6Ck2m-C
- ZIP: https://drive.google.com/file/d/1gl29kyFixWdDuz-82a6m9nvwzmnr8Uqk/view
- Full five-frame 2x contact: https://drive.google.com/file/d/19ZiIF29LWeE8mBIXbpzNfUyOXddM9Onm/view
- Selected 3-frame loop: https://drive.google.com/file/d/1xYuZWhmNA7Yt_yCUWYnSo-e9TIEMfMz2/view
- 3-key sheet: https://drive.google.com/file/d/1gUoVURV-lO_GVk-rfn-lE-cNi_M_X5zs/view
- File name: `FS_G13_PMD0003_REAL_PIXELLAB_WAITING_TEST_20261104.zip`, **393,396 bytes**, SHA256 `95fb4c974e8fb0ea3bb3ed563d94bc2d693cbac295839a082b84b2c6b81f2455`.
- Archive: 20 entries, ZIP CRC PASS, internal SHA256 manifest 19/19 PASS.
- Reconstruction scripts stored within ZIP: `g13_one_real_pixellab_job.py`, `g13_recover_completed_job.py`, `g13_qa_package.py`.
- `PROVIDER_JOB_LOCK.json` includes real provider ID, seed, before/after balance and source SHA.
- Local: `E:\GameAssetToolLab_20261023\PMD_G13_REAL_PIXELLAB_20261104` and G:\ Google Drive sync.

## Status and next use (fail-closed)
- **REAL PixelLab PROVIDER OUTPUT / frame geometry PASS**. Visual QA: PENDING USER. PMD XML and native RPG Maker VX/Tankentai: **NOT TESTED**, artwork 128×128 is not native legacy atlas cell size.
- User disliked earlier ImageGen sprite sheets. Do not claim this one sample proves all 4 actions or 0001-0003 family are production-ready. Assess quality of the 0003 Waiting 3-frame loop at 1x/2x. Evaluate orientation drift, unnatural foot movement, backplate consistency, extra debris and useable source scale before continuing paid requests.
- Original PMD source artwork G11/G12 and existing approved 0001 unchanged. A68 human actor project remains PAUSED.
- If Waiting passes, use 0003 master same reference for Move/Close Attack/Magic Skill Use via PixelLab with **one uniquely locked POST per action**, then repeat for 0001 and 0002 with their source sprites; never present the earlier ImageGen 12-sprite montage as PixelLab output.
- PixelLab currently requires even 4-16 generated frame count in the text model; 3-key output must be selected from real returned frames or use pose-controlled skeleton-v3 for exactly 3 frames.
