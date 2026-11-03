# Forest Symphony | A36G PixelLab House R2 + West Forest R3B | 2026-11-04

**CURRENT STATUS: ENGINE_SMOKE_PASS / ART_CANDIDATE_PENDING_USER_SIGNOFF / FORMAL_SEAL=NO.**

This is genuine RPG Maker VX and Godot engineering from independent Ground/PAR source assets, **not an illustration or concept render**. A36F R1 is the frozen last pre-A36G verified checkpoint; this candidate is an isolated follow-up, not an overwrite or formal completion.

## Real working directories
- A36F immutable reference: `E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103`
- A36F VX native immutable: `E:\FS_STAGE16_A36F_ELF_FOREST_VX_NATIVE_20261103`
- New A36G source: `E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104`
- New A36G R3B independent native VX: `E:\FS_STAGE16_A36G_PIXELLAB_R3B_VX_NATIVE_20261104`
- New A36G R3B Godot: `E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104\GODOT_A36G_PIXELLAB_R3B_40x29`

## What was actually created and integrated
1. **ONE COMPLETE ORIGINAL PIXELLAB HOUSE**: `SOURCE_INDEPENDENT_RGBA/A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png` (284×259, independently transparent RGBA, SHA256 `964fe9bf9fe4048bc4b96fab573285cc9a2042faeefe38f1fde9501a23ccb699`). Was generated in a single PixelLab source-first operation using authentic A36F RIGHT mossy stone house as style reference and the A36G earlier workshop rough as layout-only reference. Main roof and LEFT workshop now have one consistent architectural intersection, not pasted source sprites. Mounted at (353,209), foot (563,458) to align front step with real path. Transparent bbox (12,6,271,244), all 4 corners alpha zero. Ground/PAR proof `A36G_HOUSE_R1_VS_PIXELLAB_R2_NATIVE_BEFORE_AFTER.png`.
2. **ONE ACTUAL PIXELLAB FOREST-GROUP SOURCE**: `SOURCE_INDEPENDENT_RGBA/A36G_PIXELLAB_WEST_FOREST_CONTIGUOUS_FULL_R3B_RGBA.png` (464×576, SHA256 `0e697ccc2df1f6303089d412aa81369eed62c0ed44c609b32cd249c5a22350aa`), generated with actual A36F west tree forest style reference, independent genuine source with varied coherent tree crowns and tree trunks. Source world origin (-112,-110) so forest extends beyond LEFT/TOP map bounds. Provider source is preserved unmodified; computed transparent road-safe compilation `A36G_PIXELLAB_WEST_FOREST_R3B_ROAD_SAFE_RGBA.png` (SHA256 `78aa165b84effbcb9a5c6c3aa57fe7f428eab26b0f4f75308200fb03cb480946`), 21px clear corridor around actual A36F road mask, source divided into SIX actual depth bands to support actor y-sort.
3. **NO LOST ORIGINAL TREES WITHOUT RECORD**: 56 sprites of original A36F were replaced by the new region; 7 old original sprites restored because their root fell outside real provider-alpha coverage; 29 old collision-blocking tree anchors inside new region recorded. Native scene has 418 independent objects (193 original trees, 6 west continuous forest PAR depth bands, one original right cottage, one truly new integrated left cottage). The exact manifest `A36G_SCENE_MANIFEST.json` records every source filename/SHA, position, foot, per-tile collision, tree roots, and depth strips.
4. **REAL GROUND + PAR**: ground `A36G_GROUND_1280x928.png` retains original A36F verified road/grass/flowers unchanged (SHA256 `8c4acbfe3c7201de5f66c51f84af8b568972c5a09d97ebc0a76e3152d764e371`). True independent PAR `A36G_PAR50_RGBA_1280x928.png` (SHA256 `68b44987960c72804699487a3588ebd0579a15fb33e190a362b71cd31000bf12`). Actual alpha-composited scene `A36G_TRUE_GROUND_PLUS_PAR_1280x928.png` (SHA256 `0efe160e8aed36b92be1fe244b3afdf4c2c5c99123b452e7597e0fe8be702cbd`). NEVER treat the composite PNG as a substitute for Ground/PAR.
5. Genuine before/after full west at native pixel resolution: `A36F_VS_A36G_PIXELLAB_FOREST_R3B_NATIVE_BEFORE_AFTER.png`; new complete 640px preview `A36G_PREVIEW_640.png`.

## Native actual engine QA (R3B only, not inherited from A36F or first R1)
- A36G Map050 = 40×29, actual RGSS Player loaded **418** independent sprites, **11** test actor positions / **22** real 544×416 screenshots from process window. NO native error modal. Real obstructed walk `A36G_BLOCK before=11,11 after=11,11`; valid road step `A36G_ROAD before=11,8 after=12,8`. Actor completely hidden behind first cottage in rear case 04 (0 changed pixels); actor discernible at front case 05 (38). Full captures `R3B_VX_CAPTURES/A36G_VX_NATIVE_CASE_*.png`, QA `R3B_VX_CAPTURES/A36G_VX_NATIVE_11_CASES_SCREEN_QA.json`; contact sheet `A36G_PIXELLAB_R3B_VX_9_REGION_CONTACT.png`.
- Static collision recalculated from new full house physical footprint [379,389,618,454]: **241 blocked**, **919/919 reachable** from spawn. This is a PATH CONTINUITY and selected root/door movement smoke test, not exhaustive forest-root geometry proof.
- Godot 4.7.2 actual RX6700XT 6 full 1280×928 frames + 6 cropped 544×416: **RGB maximum absolute channel diff 1**, pixels with any channel diff >1 **0**, compared against actual generated Ground+PAR composite. QA file `A36G_PIXELLAB_R3B_NATIVE_ENGINE_QA.json`, `ENGINE_SMOKE_PASS:true`.
- A36F source manifest SHA256 remains `1c1742f8316a9fff62077df23504c9de444a1aa19b53afd3e716cfdd91f2aa52`.

## Failed attempts preserved / never falsify
- A36G first procedural `a36g_house_r1.py`: a geometrically connected house was built and composited but looked like a flat triangle. Art FAIL.
- `a36g_forest_region_r1.py`: single procedural canopy but flat moss carpet. Art FAIL.
- `a36g_forest_region_r2.py`: canopy volumes did not rescue readability. Art FAIL. The first 411-object native smoke PASS applies ONLY to that rejected R2 candidate.
- PixelLab forest original 510×630 request failed **HTTP 400**: aspect ratio provider limit 464×576; request was rejected and the dedup lock preserved. No accepted generation or quota consumed for this error. R3B was a distinct corrected 464×576 single accepted attempt.
- PixelLab actual accepted paid submissions: house cost **15** generations (1647.1→1632.1); forest R3B cost **25** generations (1632.1→1607.1). Neither request was re-sent after acceptance. Locks, prompts, remote source image proof and retained request scripts exist in this working directory.

## Open gates / next construction
- **Art still awaits user signoff**. R3B left cottage and WEST cluster visually much improved, but only the first WEST region was built as a new integrated forest source. North/East/South forest remain old 222-tree-derived assemblies and must each follow FIRST region-level source generation, THEN independent RGBA/depth, THEN live native validation. No random concept image.
- Root/canopy collision/occlusion is currently smoke tested, not fully verified for all 29 forest roots. Verify root anchors against compiled alpha with per-tile/actor geometry and avoid invisible blockers in newly clear spaces. Review door fronts/rears and tree depths at native 1×.
- Ground remains A36F old ground. Its road/material/flower naturalism must be re-evaluated visually without changing the approved walk topology.
- A36G R3B independent VX clone and Godot render completed; **full independent cold extract archival hash QA NOT YET RUN**. DO NOT mark final engine artifact seal before it.
- **Formal stage art seal remains NO** until full-art signoff & exhaustive scene QA; engineering smoke PASS does not override it.

## Exact code on remote to resume without regenerating/charging
- First integrated PixelLab house: `a36g_pixellab_house_source_first.py`, source `A36G_PIXELLAB_HOUSE_R2_SUBMISSION_LOCK.json`; never POST again with same lock.
- Forest first 510×630 rejected: `a36g_pixellab_forest_source_first.py`, lock `A36G_PIXELLAB_FOREST_R3_SUBMISSION_LOCK.json`.
- Corrected provider forest: `a36g_pixellab_forest_source_r3b.py`, lock `A36G_PIXELLAB_FOREST_R3B_SUBMISSION_LOCK.json`; never POST again.
- `a36g_integrate_pixellab_house_r2.py` and `a36g_integrate_pixellab_forest_r3b.py`: real PNG / manifest / alpha / road-safe depth.
- `a36g_build_native_engines_r3b.py`: isolated VX and Godot scene, no overwrite A36F.
- `a36g_capture_native_r3b.py`: real native RGSS Player cases.
- `a36g_validate_pixellab_native_r3b.py`: actual GPUs + native VX + source checks, 9-frame montage.
- Source QA JSONs and archived previous candidates under `HOUSE_R1_WEST_FOREST_R2_ARCHIVE`, `HOUSE_R2_WEST_FOREST_R2_ARCHIVE`.

**Next step must be advancing visually coherent EAST/NORTH/SOUTH original-sized RGBA groups, then exhaustive root and cold-clone tests. No more claims based on concept art.**