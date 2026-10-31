# Forest Symphony / Route B Stage12: 2D Style-first Source Revival
Date 2026-10-31. Research status = high-quality 2D visual candidate, TECH POC PASS, FORMAL SEAL NO.

## Purpose and source authority
Stages3-11 low-poly 3D leaves repeatedly passed basic source/occlusion checks yet failed high-fidelity ground3 art. Stage12 returns to the already-developed independent 2D Style-first sources, not to a completed master image. New layouts were constructed from *separate Ground and independent PAR sprites*. Assets are from user's private E:/GameAssetToolLab_20261023/V2,V22,V233 Style-first folders, ten assets with source SHA256 and exact original paths in SOURCE_LEDGER.json. They are NOT described as newly AI-generated images. The original ground3 flattened reference is not used as a runtime source.
Source uses existing independently generated 544x576 ground_long with two ROI crops [0,0,544,416] and [0,160,544,576], independent blue/ochre house, moss and sacred trees, wells, signs and flower hedges.

## Two new 544x416 scenes (actual Godot 4.7.2 GPU render)
A_BLUE_COTTAGE: Blue cottage at (34,94); moss tree (346,30); well (392,290); sign (268,344); hedge (8,333).
B_OCHRE_GROVE: Ochre cottage at (20,153); sacred tree (294,32); well (326,310); sign (241,321); hedge (14,333).
Manifest records source hash, original ROI, object position, alpha, and root contact. Ground is RGB and fully opaque. PAR is RGBA and genuinely transparent. All source coordinates are integer and filtering NEAREST.
Independent Python source composer uses original assets. Godot directly renders original sources as Sprite2D and AtlasTexture source Ground under the SAME scene manifest, NOT reading Python's prebuilt Ground/PAR during GPU rendering.
Confirmed strict GPU vs independent Python source compositor pixel differences for Ground, PAR and Full = 0,0,0 in A and B. GPU PAR alpha exact and border nonzero alpha=0. Both root 32x32 core contacts pass.

## A real regression caught and repaired
Initial source tree split only removed 32px central base from PAR, leaving peripheral lower roots that mistakenly overlaid front actors: 4/10 frontal placements per scene failed (max A 5.90%, B 9.09%). This is not a cosmetic issue.
Repaired at SOURCE level, not by masking finished Ground/PAR:
1. BASE_32.png holds central trunk/root within one 32x32 tile, recorded as a gameplay root-core anchor.
2. ROOT_DECAL_GROUND.png holds peripheral root ends in lower 32 source rows, as Ground decoration without collision or occlusion ownership.
3. PAR_UPPER.png holds actual upper object/canopy, no peripheral lower-root front overlap.
Strict source image recompose (BASE + DECAL + PAR) equals source RGBA at every pixel with no loss.
Post-fix 2 scenes x 5 X offsets x 7 Y offsets = 70 actor static samples; 20 front dy+16/+32 samples show 0% incorrect overlay. Central behind dy-16 actor overlap ~42.26%; central front dy+16 0.
This is static layered actor testing only, not true VX character movement, collision, or Y-sort.

## Strict technical results
Godot 4.7.2 Compatibility GPU, AMD Radeon RX 6700 XT.
A: SOURCE/PIL vs Godot independent Ground=0 diff, PAR=0 diff, Full=0 diff; border=0; alpha exact.
B: same results 0/0/0; border=0, alpha exact.
Negative source pixel shift PAR x+1 causes 61,519 different pixels; detector correctly rejects.
Two independent scene renders demonstrably far more detailed than the prior Stage11 3D test in foliage, roofs and dirt/grass boundaries. Their artwork is pre-existing Style-first source, so NOT a claim of new ground generation today and NOT a whole ground3-quality elf village.
No VX exe runtime test, no user human Gate F, no formally cleared commercial redistribution license. User-private R&D archive only; do not publish these source PNGs to public GitHub.
Sealed FS VX maps, scripts, passability and all previous Stage11 projects unchanged.

## Independent rebuild
RUN_STAGE12_ALL_CHECKS.ps1 starts from copied 10 Source files, regenerates source split, Ground and PAR, invokes Godot editor resource import, runs native 2D GPU capture for A and B, audits pixel parity, 70 static actor samples, visual panel and intentionally shifted source negative. No external reference folders needed for cold build. Preserve source ledger and SHA.
Files: compile_stage12_source.py, render_2d_stage12.gd, audit_stage12.py, actor_sweep_stage12.py, make_stage12_evidence.py, source/, parts/, build/, gpu/, evidence/, baseline_stage11/.
Key visual: evidence/STAGE11_3D_VS_STAGE12_2D.png. Other: evidence/STAGE12_GODOT_2_SCENES.png, A_BLUE_COTTAGE_4PANEL.png, B_OCHRE_GROVE_4PANEL.png.
No FS production map binary modified.

## Next
1. Human visual candidate acceptance against original ground3, at native game scale.
2. Produce genuinely NEW high-quality 2D Ground and object source sheets from accepted Style-first art DNA; do not simply crop/reuse old backgrounds forever.
3. Real separate VX Game.exe test, ground/par source import and actor full movement/occlusion + collision.
4. Style-gate visual quality, provenance and rights before village-scale expansion and formal seal.
5. If successful expand to rich 864x640+ elf village with distinct shop/inn/ordinary houses, sacred tree, river, bridge and height levels.

FINAL:
SOURCE_INPUTS=10; SCENES=2; GODOT_NATIVE_GROUND_PAR_EXACT=PASS_0_DIFF; ROOT_CORE=PASS_2; ACTOR_FRONT=PASS_20_ZERO_OF_70_STATIC; NEGATIVE_SHIFT=PASS_61519; VISUAL_GATE=CANDIDATE; VX=NOT_RUN; RIGHTS=PRIVATE_ONLY; FORMAL_SEAL=NO.