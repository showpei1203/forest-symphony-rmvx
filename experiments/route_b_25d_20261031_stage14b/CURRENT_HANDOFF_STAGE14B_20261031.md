# Forest Symphony Route B / Stage 14 B — Source-derived high-detail Ground
2026-10-31 | Experimental only | TECH POC PASS / ART NOT APPROVED / FORMAL SEAL NO

## Exactly what changed
- The Stage 13 deterministic new Ground was visually plain compared with Stage12's much higher detail.
- A separate **Stage14 B** experiment used a legitimate *independent* Style-first Stage12 ground asset as a texture donor, but authored a NEW 544x576 winding road with branch and independent semantic ROAD/WALKABLE masks. This changes source-layout geometry while retaining the old visual "texture DNA."
- Deterministic 64px donor sampling with 44px stride, only grass-rich and earth-rich donor crops, binary source-pixel blend with irregular joins. This is NOT image-model generation of novel painterly art; it is texture-source reassembly and selected private Style-first donor content, still showing repeated patches.
- Source provenance file STAGE14_SOURCE_LEDGER.json holds exact original donor SHA and derived SHA. No finished combined scene is reverse-cut. Ground remains independently authored, with objects original private Style-first transparent source sprites, positional scene manifest.

## Actual native 2D engine test
- Isolated project: E:\FS_ROUTE_B_STAGE14_TEXTURE_TRANSFER_20261031, forked from Stage12 2D source renderer.
- Godot 4.7.2 Compatibility on RX 6700 XT executes source atlas Ground, native tree split and separate PAR sprites; does NOT load precompiled Pillow Ground/PAR into GPU renderer.
- Both A_BLUE_COTTAGE and B_OCHRE_GROVE 544x416 captured independent GPU Ground, PAR and full. Each 0 different pixels vs separate Python source compiler, six totals all 0.
- PAR alpha border = 0, native 32x32 tree core base PASS both.
- 70 static 32px actor placements total, 20 front-labeled placements 0% PAR overlay. This is not VX Game.exe scrolling/movement, no VX Gate F.
- Legacy private source objects (houses, trees, well, hedge, sign) all reused, **not newly generated**.
- Open Canva generated media job was checked: status SUCCESS, but only media ID MAHZieTce7g and no accessible PNG bytes. Thus it was NOT tested/integrated, no Canva image PASS.
- ImageGen returned an irrelevant image with fake dates, scores, sample output. That infographic is REJECTED and not a Ground source.
- Stage14 Gate0 source-audit script from previous artifact remains valid; this pilot continues honoring technical gate without claiming visual gate.

## QA and visible limitations
- Private original donor SOURCE SHA256: 735fea2aa38cdb73c07cd3ffa7382662d256c8f6f3aec0d27b6343b22f5a2020.
- Derived E: drive output SHA256: a6d781d6ab1fd9c4a7fb4f9d9f1c9ba12fa93fdb2444316152879932c1130ec6 (Pillow encoder may vary on other OS).
- 544x576 Ground, 55,860 unique RGB colors, 15.93% newly authored dirt-path semantic mask.
- Tile-quilting artifacts: recurring bushes/flowers and seams; still **NOT equivalent to the user's ground3 reference**.
- User approval of art and legal commercial-rights clearance pending; private research ZIP only. Source assets must not be checked into public GitHub.
- Source Stage12 and all FS sealed VX maps, Scripts.rvdata, collision, player passability remain unchanged.

## Rebuild and deliverables
RUN_STAGE14_ALL_CHECKS.ps1 rebuilds source ground, source-semantic masks, separate PIl Ground/PAR, imports assets to Godot, captures 2 GPU scenes, runs exact pixel diff and 70 static actor positions, renders evidence comparison and asserts final QA.
Files: author_ground14.py, compile_stage12_source.py, render_2d_stage12.gd, audit_stage12.py, actor_sweep_stage12.py, compare_stage14.py, source/,parts/,build/,gpu/,evidence/ and original separate source donor.
Private canonical ZIP plus Drive backup; publish only authoring/verification source code and Handoff, never old private art to public GitHub.

## Gates
DERIVED_HIGH_DETAIL_GROUND_NEW_LAYOUT = PASS_SOURCE_ONLY
NEW_ORIGINAL_AI_PAINTED_GROUND = NOT_DONE
GROUND_PAR_PIXEL_EXACT_FROM_SOURCE=PASS_ALL_SIX
GODOT_4_7_2_GPU=PASS_2_SCENES
TREE_BASE_SINGLE_32PX=PASS_2/2
ACTOR_STATIC=PASS_70_WITH_20_FRONT_ZERO
ART_REFERENCE_GROUND3=FAIL_NOT_APPROVED
VX_EXECUTABLE=NOT_RUN
FORMAL_SEAL=NO

## Next recommended
1. Inspect original Canva generated image binary or use a genuine high-quality novel ground-generation workflow, no infographic/status signs.
2. Need source image strictly no raised trees/house, generate independently matched house and tree sprites, maintain donor provenance.
3. Once independently high-quality Ground + objects pass visual comparison at 100%, test larger village and native VX real walking, not beforehand.