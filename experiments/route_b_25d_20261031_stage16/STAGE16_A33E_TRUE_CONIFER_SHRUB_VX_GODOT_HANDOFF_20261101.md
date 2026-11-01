# Forest Symphony Stage16 A33E | Actual conifer species + woodland shrub forest refinement
2026-11-01 Taiwan. **A33E REAL ENGINEERING PASS / USER ART PENDING / FORMAL SEAL NO.**

## Read first
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md`
3. `authority/FS_GROUND_BLACK_STREAKS_ECOLOGY_FAIL_CLOSED_V1_20261101.md`
4. `authority/FS_REMOTE_A33D_FOREST_LAYER_COLLISION_FAIL_CLOSED_V1_20261101.md`
5. NEW `authority/FS_FOREST_PAR_SPECIES_DIVERSITY_AND_SHRUB_VISUAL_GATES_V1_20261101.md`
6. This Handoff + `STAGE16_A33E_FOREST_SOURCE_DIVERSITY_FAILURE_REGISTER_20261101.md`; latest `CURRENT_HANDOFF_STAGE16_A33E_20261101.md` and A33D predecessor handoff.

## Inputs and new literal source files
Remote DESKTOP-90VT437 Desktop Commander connected and actually performed file copy/write and native Game.exe/Godot tests. User said 「不錯，可以繼續推進了」 after A33D, meaning continue good direction, not automatic A33E formal seal.
- Baseline A33D **Ground** 544×416 SHA256 `4af7f6bd86b8cdd171c7a13de59cd93a3a6a904c599b9be2640d8cae88f46c00`; retained untouched. A32B original 12 approved PAR assets and legacy full PAR50 SHA `24912a82622043c6c0b25b434a0a49585bb5cc470c4c83222a7db2d187de45fb` unchanged.
- NEW **A33E Ground** `A33E_FOREST_FLOOR_SPECIES_544x416.png` SHA `d129d229a1d5b75e3ab9ae061c9d42eea3a1014cbaa1b581c360b0b6b57c3fa5`; preserves A33D road pixels and source bright flora, adds 150 compact under-canopy fern/stem pixels. No light/shadow baked into Ground.
- NEW transparent **A33E_PAR50_32_OBJECTS_RGBA.png** SHA `0bb510b71ab5ad7c265b464d2aacfe228f3a4e98df2430bb8fc2a2e14c5b6b9c`, independently composed sorted by original (foot) from 32 individually loadable RGBA objects. Same old source12, A33D old9 slots, plus two new conifers and nine shrubs = **32 PAR objects, 15 trees, 9 shrubs**.
- User material sources `E:\FS_ROUTE_B_STAGE16_A29_SOURCE_DIVERSITY_VX_20261101\SOURCE_PRIVATE\tree01.png` and `Hanzo-VSTrees03.png`, actually inspected RGBA alpha crop and border. First source dark compact 64×96 fir, second source single conifer crop x206:338 y29:248 from 670×275 sheet, fully alpha bounded. FOUR small repeated A33D broadleaf instances replaced by needle fir source art with same foot positions; two additional needle conifers placed west road edge and outer east canopy; nine small NEW independent procedural leaf-bunch shrubs nonblocking. Only 2 additional original source species, NOT 6 completely new species; new source species cropped/resized NEAREST and RGB tone adjusted (alpha unchanged).
- Source manifest `A33E_SCENE_SOURCE_MANIFEST.json` has all 20 A33E-owned objects (9 older existing tree slots incl replacements, 2 extra conifers, 9 shrubs), filenames, source hashes, bounding boxes, feet, blocking roles, new Ground, PAR sha.
- Genuine user-facing preview `A33E_A33D_VS_A33E_REAL_LAYERED_COMPARE.png` (two 544×416 composites from independent Ground+PAR) plus actual native VX screenshot before/after `A33E_NATIVE_VX_BEFORE_AFTER_MOBILE_544W.png` and isolated sprite contact `A33E_NEW_2_SPECIES_9_SHRUBS_CONTACT.png`.

## Actual isolated RPG Maker VX
- A33E new clone from immutable A33D `E:\FS_STAGE16_A33E_FOREST_DIVERSITY_VX_20261101`.
- Exact old A32B 12 independently loaded PNGs untouched; A33D original immutable project also untouched. Replaced four old candidate small clones in A33E scene while retaining five unchanged A33D new tree instances. New 2 conifer PNG and 9 shrub PNG own separate Cache.overlay sources.
- `Data/Map050.rvdata` Ruby Marshal RGSS2 Table old blocked 21 retained and 2 NEW semantic conifer foot cells (7,5), (16,6) changed from E=769 to E=768, resulting **23 blocked, 198 passable, all 198 BFS reachable and original road intact**. New shrubs remain nonblocking.
- Only isolated native VX TEST Script 483 A30_MAP modified with 32 independent object coordinates, 2 new scene case positions, two real move_down attempts; other 506 source script payloads unchanged. This test-only source is NOT installable into sealed FS production, legacy BattleRegression test bypass.
- Actual Win32 `Game.exe` RGSS Player **18 placement scenarios, 36 real 544×416 screenshots**, no RGSS modal; 32 unique source objects logged and loaded. Real movement original tree blocker (2,4)->(2,4), new A33D two tree blocks (6,1)->(6,1) and (11,1)->(11,1), new A33E left pine (7,4)->(7,4), east pine (16,5)->(16,5); road legal (8,6)->(9,6). Original west behind partial 351/627, east partial 292/627 with A33E new conifer foreground, front 627/627; east upper behind fully covered 0/627.
- QA `A33E_NATIVE_18_CASES_AND_BA_QA.json`, screenshot log `A33E_VX_NATIVE_18_CASES_SCREEN_QA.json`.

## True GPU and cold rebuilding
- Separate project `E:\FS_STAGE16_A33E_FOREST_DIVERSITY_20261101\GODOT_A33E_FOREST_32_OBJECTS`; Godot 4.7.2 OpenGL compatibility on RX 6700 XT generated **16 native GPU PNG frames**, including new pine behind/front. Independent true 32-sprite Ground+PAR composite vs native no-actor: **3,908 changed pixel positions, max RGB single-channel delta1, zero >1**, `PASS_RGB_TOLERANCE_1`, NOT zero difference.
- Independent VX cold clone `E:\FS_STAGE16_A33E_FOREST_DIVERSITY_VX_COLD_20261101`, **3,415/3,415 SHA256 file match**; actual native cold Game.exe Map50 32 objects loaded, 0 modal, 544×416 screenshot. Not deterministic all 36 cold screenshots identical, do not falsely claim parity.
- Original approved A32B PAR, original A33D sources and previous Godot isolates unmodified.

## Acceptance and risks
Engineering layering, connectivity, 32 isolated source objects, real native VX, Godot GPU, cold full SHA PASS. User aesthetic **PENDING**, shrubs somewhat hard to distinguish at native 1×, evergreen source-species palette may still need a separate art iteration. Production BattleRegression startup untested due TEST-only harness. Original 1280×928 village/forest scale and final SHADOW/LIGHT game pipeline later. **Formal Seal NO**.
Private source sprites and files in user's Google Drive only (licenses unverified); GitHub documentation only. See current handoff for verified links added after sync.


## Verified A33E Private Google Drive source and 2026-11-01 QA
These exact links and ZIP byte count were read back from connected Drive after local Windows G:\ sync:
- **Actual RPG Maker VX native BEFORE/AFTER**, 544px wide + 4 terrain quadrants: https://drive.google.com/file/d/18z1Sf9PRKw3G-PmqZtvUSoN2zMwOgX1d/view
- **True Ground+PAR A33D vs A33E side-by-side**, 13 vs 15 trees, source-composited: https://drive.google.com/file/d/1I1rSNEwf6onKXFuwPRf4drm0UFkR5q5s/view
- **New A33E Ground** 544×416 opaque PNG SHA `d129d229a1d5b75e3ab9ae061c9d42eea3a1014cbaa1b581c360b0b6b57c3fa5`: https://drive.google.com/file/d/1Ufj6R1be3wgFCE8v-0L2w33OYUOLXhE-/view
- **New A33E Par50** 32-object transparent PNG SHA `0bb510b71ab5ad7c265b464d2aacfe228f3a4e98df2430bb8fc2a2e14c5b6b9c`: https://drive.google.com/file/d/1IWUoaPtfNFilv9W7t0hxK7FyMDrKCrbh/view
- Ground + 32 PNG PAR real composition: https://drive.google.com/file/d/1AUuwglBIRFXRmToLuy_7tSZxPOQIWwDI/view
- **New source-conifer vs 9 individual shrub RGBA contact**, inspected original alpha: https://drive.google.com/file/d/19j-PNfBfZOiM7DBn49k00gZP3Pj_r1fN/view
- **Actual new 15 standalone RGBA source PNGs + scripts + tests** in private ZIP: https://drive.google.com/file/d/1TbdBhZUqjCddpbQskZTNHjY_HfvNv5U0/view , 143 members, 35,053,988 bytes. Local ZIP CRC, ALL SHA256 and independently re-extracted SHA PASS; actual Drive name/byte metadata readback PASS, but no additional full remote ZIP download checksum claimed.
- A33E provenance/source manifesto: https://drive.google.com/file/d/1hP7uFX7xdUOg3ugtiy6mlQKTcxWj6vp6/view
- Native VX 18-case/36-frame QA: https://drive.google.com/file/d/1M4JhrqGSsGfeEnPqG7jUW8Uo1xnbDEtE/view
- Native GPU numerical RGB QA 16 frames: https://drive.google.com/file/d/18-nAyJvTU2TQFZO75MciQ8KmMEofyMlh/view
- Native independent 3415 SHA files cold verification: https://drive.google.com/file/d/1PUP0lgulkejYg1ZRA-sROGgtm0KzQzhl/view
- New permanently active species/shrub visual QA: https://drive.google.com/file/d/1E6rnVxRhsNHqmnkeOv_UoZ0L85DmOVJl/view
- A33E failure register: https://drive.google.com/file/d/1WWaDNDkw7IrT6Rz9_DTo7bXUchs3bGcn/view
- A33E detailed Handoff: https://drive.google.com/file/d/1hTsgMiOfsTAUmGJ6s_pQrRMApcYpHraI/view
- Latest CURRENT_HANDOFF: https://drive.google.com/file/d/10niiBdMJFxEZ3chUoyi2rxX5sMzjQVPM/view
- Stage 16 A33E folder: https://drive.google.com/drive/folders/1d2gz2oaPmedmhPrA33mpfmZ5pOmKGN1R

**Engineering PASS: 18 native VX cases/36 frames, Godot GPU 16 native frames RGB tolerance1, cold 3415 SHA files; A33E forest art user approval PENDING and Formal Seal NO.**
