# A30 FS actor01 Native Motion Rig / Real PixelLab Loop (2026-11-01)
 
## Core fix
User rejected A29 Idle floating and Walk unnatural. DO NOT repeat generic prompt or use external ImageGen illustration.
Real Forest Symphony source is E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters\$actor01.png and _1/_2/_3. Image geometry 96x128 (3 columns x 4 directions, 32x32 each). Source SHA verified against A23.
 
## Analysis
Right-facing r2, c0/c1/c2 native body and feet; foot bottom =32/32/32; hair top y=1/0/1; head is huge and torso/legs tiny. Native idle is center column c1, WALK is 3 poses. No actual rig joints are stored inside PNG; we infer regions from pixel silhouette, then compute genuine PixelLab 18-point estimated skeleton on A29 unarmed character.
A29 Idle bottom varied 38,37,36,38,38 (2px floating), Walk bottom 38,38,38,37,38 and unnatural free-form body sway.
 
## A30 PixelLab generation (genuine provider API)
- New A30 18-bone estimate based on the actual unarmed A29 diagonal candidate, charged 0.1 generation.
- Idle v3 bone poses: feet, hip, knees, neck, face and eye coordinates fixed; only tiny 1px shoulder/chest breathing. Job a87553bc-85b1-4386-9baa-7d923f711a8f; charged 3 generation; six authentic 40x40 transparent PNGs.
- Walk v3 poses: neutral, near-leg step, neutral, far-leg step, neutral, neutral. Root, neck/head and planted foot Y stable; knee/foot move only 1-2px and arms counter-swing 1px. Job 0e04939c-0c2e-4b1e-9032-a4c6ebea31e1; charged 3 generation; six real 40x40 transparent PNGs.
- No post-drawing or image-generation substitutions. Real frame0 is identical to approved A29 unarmed 40px source.
 
## Objective Loop QA
A30 RAW Idle bbox top y4 for all 6, bottom y38 for all 6; A30 RAW Walk same. No vertical bob. All source PNG originals and failed A29 output intact.
Final candidate cuts only duplicate idle and walk terminal poses: Idle provider indices [0,1,2,3] durations [240,150,150,240] ms; Walk indices [0,1,2,3,4], each 150ms. Last-to-first pixel diff =1 for both, substantially below internal step diffs. Complete six source frames preserved.
- Source rig raw review: A30_TRUE_SKELETON_PIXELLAB_12FRAMES.png
- Final GIFs: A30_IDLE_SOURCE_RIG_FINAL_LOOP.gif; A30_WALK_SOURCE_RIG_FINAL_LOOP.gif; A30_FINAL_IDLE_WALK_COMBINED_LOOP.gif.
- Before/After GIF: A30_A29_VS_A30_RAW_LOOP_COMPARE.gif (old and new both RAW).
- Native image reference: A30_REAL_ACTOR01_ORIGINAL_WALK_IDLE_REFERENCE.png
- QA: A30_RAW_LOOP_QA.json and A30_FINAL_SOURCE_GUIDED_QA.json
 
## Gate and next
- Engineering source/geometry/loop anchoring PASS, human animation naturalness/art angle PENDING.
- A29 diagonal view is visually selected, NOT formally accepted 45-degree southeast view. Preserve direction caveat.
- Weapon-free actor, weapon layer intended as Tankentai SBS paper-doll; NOT tested with overlay.
- Original FS $actor01.png, $actor01_1/_2/_3.png and ALL engine scripts unmodified. No formal engine PASS claim.
- PixelLab quota after A30: 1832.8/2000, A30 spent 6.1 (0.1 + 3 + 3).
- Use this stage as source-guided animation proof and do not revert to A29 hopping.
