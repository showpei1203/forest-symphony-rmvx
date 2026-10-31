# Forest Symphony Stage16 A17 Native Specialist Model — Handoff
2026-10-31 | Real original native16 pixel-model inference PASS | Ground3 ART FAIL | 544x416 NOT RUN | Godot NOT RUN | VX NOT RUN | Formal Seal NO.

## Input authority
Retained A16 no-native-pixel-art result, A10 legitimate original Ground3 grass crop b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407 (64x64). Neither A10/A16 nor formal FS Ground/PAR/Collision changed. Separate E:\FS_ROUTE_B_STAGE16_A17_NATIVE_SPECIALIST_20261031.

## Commercial model readiness
PixelLab official API https://api.pixellab.ai/v2/docs uses Bearer token; PixelLab v2 model canvas caps vary by generator (16–768 indicated in Pixen docs, some pricing listings 512). No API token in the authorized Windows Python execution environment; no paid call. PixelLab = NOT RUN AUTH.
Retro Diffusion API v2 https://github.com/Retro-Diffusion/api-examples/blob/main/llms.txt uses X-RD-Token; Scenario API supports RD Plus, RD Tile and references. No authenticated RetroDiffusion/Scenario key in execution environment; no paid call. Retro Diffusion = NOT RUN AUTH. No private token values exposed.

## Real runnable open-weights native experiment
Cloned https://github.com/tarulahsan/PXG-Tiny-AI commit c813f5b3d1a391ebef8695c77151abd17670a9d8. Ran pretrained INT8 generator (NumPy autoregressive, not high-res resize) directly using bundled model weights with Python 3.11 and Pillow. Native output is 16x16 RGBA indexed-palette.
T1 grass tile seed17001: gate accepted first attempt; native PNG SHA256 6028513331205cf34e914ca6558e5627b10af4d992ea9255e859209c712df40e, 3 RGB colors, fully opaque.
T2 stone tile seed17002: gate accepted first attempt; native PNG SHA256 2822fd45fab9527bb7d6a35cff7e347059aacedced7a358c44eabda0, 4 RGB colors, fully opaque.
T3 colorful patch of wildflowers on the meadow floor seed17003: model responds 'clarify: i don't know that object yet'; NO output PNG. This is a capability refusal, not a failed image.
Actual 16x16 Ground3 reference crop (from verified 64x64 original) has 256 unique RGB and adjacent channel L1 difference 13.03; model grass has 3 colors, L1 4.56; stone 4 colors, L1 15.54. Low complexity and repeated blocks visibly far below Ground3 detailed botanical art. No seamless tile proof. No full-map generation by this model; do not treat 16x16 success as 544x416 art.

## Reproduction and privacy
ZIP includes permitted third-party model source MIT, weights CC0, exact upstream license file, committed model SHA256, two original model PNGs, single source Ground3 64px private sample, user 16px comparison sheet, generator and offline verifier. Cold regeneration from bundled weights proves exact RGBA match on both generated outputs and same unsupported wildflower response. No complete private Ground3 source or proprietary model weights published in GitHub.

## Next finite trial
Authentic PixelLab or RetroDiffusion / Scenario account-backed single native pixel image 128x128 (or 192x144) with approved paid API access, then 1x and 32px human compare to Ground3. Confirm supported full canvas size before requesting 544x416. If no API connection, stop trial and record NOT RUN AUTH; no more generic SD1.5 or imagegen downsample.

Final: PXG native16 ENGINEERING PASS, Ground3 ART FAIL, PixelLab/Retro NOT RUN (AUTH), formal FS map unchanged, Formal Seal NO.
