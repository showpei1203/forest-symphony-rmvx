# A35 Forest Symphony native 45-degree Dodging interpolation / Handoff

## Source provenance
A34 real PixelLab battle-view teal unarmed F0/F2, built from original FS $actor01_1 r1/r2 c1 actual native pixel poses. F1 is A34 source-checked user Dodging pose reference controlled REAL PixelLab generated head-down/tumble. NO A33 wrong-facing F0 source used.
The original images are preserved; only new files under E:\GameAssetToolLab_20261023\A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101.

## API findings and actual work
PixelLab /interpolation-v2 accepts start_image + end_image + action (MAX 500 chars) and image_size.
A35 first overlong action HTTP422, not accepted, no credits. Short action accepted as true source F0→F1: job 4456a6dd-00a5-4351-9452-df69b50a414d, 14 genuine PixelLab 40x40 transparent PNGs, billed10 generations.
Second source F1→F0: job 790d9b6f-37ad-46be-8758-b261640e5f06, 14 more genuine PNGs, billed10 generations.
API endpoints redraw original keyframes, so do NOT automatically trust generated endpoints. Anchor originals exact, no manual painting.
Source F0 and F2 are byte identical. 40x40 geometry and border check PASS, meaning no right/bottom edge cropping.

## Visual analysis
A full 31-frame assembly is too long. Provider A8-A13 lingers prone AFTER inversion, B5-B6 temporarily return upside down AFTER standing. These are genuine generation FAIL artifacts, not animation creativity.
A curated semantic 18-frame demonstration selects provider indices A0..A7 and B0..B4,B7,B8 and inserts exact source F0/F1/F2. No painting/retouching, no invented animation frames; all provider raw 28 frames saved. Since interpolation still morphs head orientation/body, technical asset provenance PASS but art & camera angle still USER REVIEW PENDING, SBS engine NOT RUN.
- A35_SEMANTIC_SELECTED_DODGING_ONESHOT.gif (18-frame candidate, one-shot).
- A35_A34_3FRAME_VS_A35_18FRAME.gif (A34 crude pose vs A35 real inbetweens).
- A35_ALL_INTERPOLATED_REAL_FRAMES_QA_MONTAGE.png (30 frames incl exact source keys).
- A35_18FRAME_CURATED_REAL_PROVIDER_REVIEW.png (18 actual selected frames).
- A35_INTERPOLATION_FULL_QA.json and A35_FINAL_QA.json.
Last and first frame of 18 are an exact same 45 battle sprite from A34. The full action is ONE SHOT, no requirement to animate endlessly.

## Balance
From 1761.8 to 1741.8 / 2000, exactly 20 generations charged (10 per accepted interpolation job). Both job IDs and provider bills read back. Previous 422 rejected call not charged. No duplicate accepted jobs.

## Formal gates
Native source/SHA and real provider generation PASS. 40px sprite and no border crop PASS.
Dodge motion naturalness, exact per-frame southeast 45° view and visible character identity/weapon-free details still need art review. Full Tankentai SBS weapon paper-doll layer and VX engine not tested. No official FS/PMD/SBS file overwritten.
