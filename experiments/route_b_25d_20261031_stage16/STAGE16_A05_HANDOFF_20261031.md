# Forest Symphony Stage 16 A05 — Ground-first semantic mask and two-pass inpainting
Date: 2026-10-31. **A05 ENGINEERING PASS / GROUND3 ART FAIL / Godot NOT RUN / native VX NOT RUN / Formal Seal NO.**

## Source and baseline
Stage 15 engineering baseline preserved unchanged (cold 12/12 SHA; real Godot zero-pixel six-case geometry compositor; ART FAIL; VX not run). Stage16 A04 established that original ground3 style reference can condition SD1.5 via CLIP Vision and IPAdapter in CPU FP32. A05 does not modify sealed production map, scripts, tilesets, masks or A04 assets.
User-provided ground3 composite reference SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`, 1280x928 RGB. Selected private grass-and-sand-only 128x128 crop SHA256 `943c7c7aa16f12f15e0f298f5963b91283f4c8bb19fb234c2e48825059fb1928`. Reference sample remains private, is INPUT ONLY and must never count as newly generated artwork.

## Environment
ComfyUI v0.3.40 git 866f6cdab4bd5de95ee6296d1b418c455f67f929, IPAdapter Plus a0f451a5113cf9becb0847b92884cb10cbdec0ef, Python3.11 torch2.4.1 CPU FP32, original model checkpoint SD1.5 fp16 SHA256 `e9476a13728cd75d8279f6ec8bad753a66a1957ca375a1464dc63b37db6e3916`, CLIPVision ViT-H SHA256 `6ca9667da1ca9e0b0f75e46bb030f7e011f44f86cbfb8d5a36590fcd7507b030`, IPAdapter plus SD1.5 SHA256 `a1c250be40455cc61a43da1201ec3f1edaea71214865fb47f57927e06cbe4996`. Large model weights excluded from public GitHub/private transport ZIP, retained on user machine.

## True semantic mask geometry
New independent north-to-south curving road mask at 384x384; 28,818 of 147,456 road pixels, exactly **19.5435%** intended target occupancy. Continuous corridor (one segment per row) with road width 66–83 px. Complementary grass-only inpainting mask 118,638 pixels. Road PNG SHA256 `eed1ce659987b37ef074483fad3dd7fdfa17107e49b609ecce6afd83ca2b973e`. Input Ground image is original A04 independently generated B image, not the ground3 donor. Its exact local input PNG SHA256 `75f1fdcceab0ddd1bbfd79f2b48002a1928e236b42db0ff550f3c97d0c1c8fcc`.

## Three actual CPU model executions
R1 PASS: Ground3 ref + IPAdapter weight 0.5 + ComfyUI VAEEncodeForInpaint + KSampler 14 Euler/normal steps, seed160405, CFG6.5, denoise1.0, mask *outside road* white. Decoded image composited back with source road mask using ImageCompositeMasked. All 118,638/118,638 grass-area pixels change; **zero** of 28,818 road pixels change. Grass-green heuristic outside road from 40.1431% to 90.5047%. This merely measures appearance in RGB, not Ground3 art fidelity. New raw RGB PNG actually generated; artwork fails (smooth neon repeated circles).
R2 PASS as computation: Same R1 output, mask road white, use IPAdapter weight 0.65, 14 steps seed160406 CFG6.0. Composite with previous grass outside. All 28,818 road pixels changed, **zero** of 118,638 outside road pixels changed. Sand-like road proxy falls from 60.816% before to 30.113% after. Road drifts green and becomes irregular/not Ground3. ART FAIL.
R3 controlled test PASS as computation: same R1 input, mask, text, model checkpoint, seed160406, CFG6.0 and steps; *only* disconnect IPAdapter from KSampler to test a grass-reference style bias. All 28,818 road pixels changed, outside road zero. Road sand-like heuristic **19.307%**, green-like **77.465%**; broad flat green region. R3 is worse than R2; proposed simple explanation 'IPAdapter alone makes road too green' NOT SUPPORTED by this matched single A/B trial. ART FAIL.
Color heuristic is purely descriptive (sand: R>1.04G, G>1.12B; grass: G>1.08R and G>1.08B). No semantic classifier or visually accepted Ground3 similarity score.

## Pixel art style gate
Ground3 32x32 sample at nearest-neighbor 8x retains tight multicolor terrain texture. A05 grass exhibits blurred overbright repeated round splotches; R2 path is green/yellow irregular, R3 path is flat green. None is art approved. Masks control spatial changes, **not** target material semantics or source style fidelity. Native 544x416 map/village was intentionally not attempted before art pass.

## Authentic artifact integrity
Private A05 ZIP: `FS_STAGE16_A05_MASKED_INPAINT_PRIVATE_20261031.zip`, **4,525,104 bytes**, SHA256 `a6b74fa6694ea463fcb22985db777590646d49b3d32f72d3062d31699961a563`. 38 entries total including SHA manifest; 37/37 file hashes verified on fresh separate extraction, ZIP CRC PASS and actual cold-check Python run passed all pixel isolation assertions. Model and complete private Ground3 composite not in ZIP. All copied files on Google Drive mounted folder verified against source file SHA and then identified through live Google Drive connector.

Private Google Drive folder: https://drive.google.com/drive/folders/1q5qSlqHJN5ryCxKVCFkTRpJdEKC-vQ-0
Private A05 ZIP: https://drive.google.com/file/d/12dEXhn4CheaybwHuRtfi8mTqgpmXKyQS/view
Private A05 original 1x comparison: https://drive.google.com/file/d/18Ha8HaJfu0fBUpm6_cC-7Oii4z_38tOP/view
Private A05 32px pixel-lens: https://drive.google.com/file/d/1iH4EWQa5bGUXurRDOn5-1_1gCpYNliFp/view

## Next A06 research gate
No more identical SD1.5 + mixed-reference blind prompt loops. For material identity (sand vs grass), test dedicated source-domain material reference and spatial semantic model constraints (e.g. ControlNet segmentation or edge/line guidance / an inpaint checkpoint). Compare **only a fixed controlled hypothesis** before doing high-resolution Ground. Use exact native 32px style inspection. Explore stronger pixel/painterly JRPG-specific checkpoint or model adaptation only when source licensing/performance are verified. Never claim mask engineering PASS = art PASS. Do not compile PAR or test Godot/VX until real art candidate is visually accepted.

Gate summary: Mask geometry PASS; R1/R2 real masked model generation PASS; pixel-exact zone isolation PASS; IPAdapter-only-cause hypothesis rejected by R3; Ground3 ART FAIL; Godot/VX NOT RUN; **Formal Seal NO**.