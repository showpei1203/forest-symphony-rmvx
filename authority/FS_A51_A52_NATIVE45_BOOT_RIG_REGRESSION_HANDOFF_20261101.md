# A51 / A52 FS 45° run sprite | 2026-11-01 | Source-anchored local limb reconstruction

## Mandatory authority and production safety
FS 16-action source-reference defines Moving to Close Attack three **poses**: left step, neutral, right step, not a blind 0→1→2. Our internal F0=neutral, F1=left step, F2=right step, rendered loop F0→F1→F0→F2. Only three 40×40 stored frames, one 120×40 sheet. All sprites unarmed; Tankentai owns world displacement.
Source F0 is the authentic A46/A45 PixelLab-rotated 45° candidate, which derives from FS material; it is NOT the untouched original FS native battle PNG, and the original remains the visual authority for camera acceptance.

## Stage A51
Implemented exact source-derived independent rectangular left/right leg-and-shoe cutouts instead of A50 whole-lower-body mirror. 6 pose experiments, real PNG and transparent GIF for every variant. With V1..V5 sprite alpha remains one connected object, F0 face/head preserved exactly and no right/bottom cropping. V6 splits a 15px component → automatic FAIL. Some A51 frame seams and foot gaps were obvious in enlarged contact sheet, therefore NO ART PASS.

## Stage A52
Implemented row-wise integer shear of each foot segment, progressively changing horizontal displacement toward the shoe. This avoids A51 vertical offset gaps and cuts. 6 real pixel-level variants with valid 120×40 strips, 0/1/0/2 gifs, head/face delta zero, one connected alpha object per frame, no bottom crop. V1/V3/V6 too subtle; V2 more visible but diagonal silhouette unnatural; V4 wide; V5 least intrusive. V5 is only an *engineering candidate*: the two legs still may not read clearly as a 45° in-place run on 40px canvas. Reject any claim that format PASS equals animation art PASS.

A52_SELECTED: A52_V5_short_asym_3FRAME.png and A52_V5_short_asym_LOOP.gif.
Comparison: A52_A47_A50_A51_A52_REGRESSION_COMPARE.png.
Verification: A52_FINAL_QA.json, A52_TECHNICAL_QA.json; SHA manifest and code.

## What actually changes
The A51/A52 scripts operate ONLY on copied 40×40 images with Pillow; all pixels are deterministic transforms of existing legitimate A46 source, no PixelLab API calls, no AI generation credits, no original FS file touched.

## Next action
Instead of guessing new PixelLab prompts: extract separately editable knee/leg/boot semantic layers by one approved pixel-mask source, review each exact leg and depth order; compare user reference three action poses at enlarged size; then perform isolated VX+Tankentai actual runtime test before any FORMAL PASS. A 45° camera requires human review, a `south-east` parameter does not certify it.

## Status
Engineering format / alpha continuity: PASS for A52 variants.
Natural running pose / camera artistic approval: PENDING, no formal release.
VX Tankentai SBS runtime: NOT RUN.