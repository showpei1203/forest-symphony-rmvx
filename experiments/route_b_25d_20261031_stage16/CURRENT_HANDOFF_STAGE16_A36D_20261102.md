**SUPERSEDED FOR ACTIVE MAP DEVELOPMENT: A36E R2**. Continue from [the A36E current Handoff](CURRENT_HANDOFF_STAGE16_A36E_20261102.md). This A36D R2 archive remains read-only, not the active visual candidate.

# Forest Symphony | Stage16 A36D R2 | 2026-11-02

**ACTIVE MAP VISUAL CANDIDATE A36D R2. Engine QA PASS; user art signoff PENDING; Formal Seal NO.** This is an actual native Ground / alpha PAR implementation, not an AI concept image. Never overwrite A36C, the original FS project, or the user-provided master asset folders.

## Immutable source authority
- Canonical original art root: https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr
- Map / PAR reference: https://drive.google.com/drive/folders/18PuuvYK1ClurHzLeKLG6yXZqKXDLa_tS
- User Buildings folder: https://drive.google.com/drive/folders/1_1fCD0jLwISt1SApxKwbNF3zIVMOyYlW
- **Actual second building source**: `Hanzo-TownSet03VS.png`, https://drive.google.com/file/d/1OmAF2slFsRwTsaXDjQn4QWgfz57CdHCo/view, original SHA256 `8a1da7ffe2db8361c68fb2a2874fa0868a313aca9861bba4a07f95d4c455063c`. The verified source sheet is archived in the private A36D package and at `CANONICAL_DRIVE_SOURCE/Hanzo-TownSet03VS.png`.
- Tree/reference guide: `authority/FS_CANONICAL_DRIVE_ART_REFERENCES_A36C_20261102.md`.
- Predecessor A36C: `experiments/route_b_25d_20261031_stage16/CURRENT_HANDOFF_STAGE16_A36C_20261102.md`.

## Concrete art changes from A36C
1. Replaced **only the second visually cloned cottage** with a genuinely different FS-style original-sheet stone-and-thatch structure. The new structure combines a cropped full green thatch/stone body (original atlas rectangle `[45,50:243,286]`), carefully masked independent alpha shape, and an original wooden door from the same source `[395,381:505,481]`, resized by nearest neighbor to 50×47 and placed at native 1× scale. **This is a composited new building sprite from user-supplied original building atlas, not only a recolor.**
2. Art R1 was overly neon-bright compared with existing forest. Kept R1 in `A36D_R1_RAW_GREEN_STONEHOUSE.png`; R2 conditionally reduced saturated green thatch (25,287 pixels toned) without altering its source geometry, and retained the entire original atlas unchanged. The final R2 independent asset is `SOURCE_INDEPENDENT_RGBA/A36D_HANZO_LIVING_STONE_THATCH_HOUSE_02_R2_RGBA.png` SHA256 `750061b6ead915376bfade3601c4895f57574f3a8eb2e1e266c88d35cdbe3d6b`.
3. Added **45 independent alpha understory shrubs** from previously SHA-verified A34 forest object sources. Restricted them to village margins/forest transition and away from doors and path footprints. Original forest 222 trees preserved; current 175 shrubs, 2 **different** houses, 4 pre-existing landmarks = **403 actual separate alpha objects**.
4. Added **106 small botanical/pebble clusters (453 touched pixel placements)** around actual road edges in Ground without altering or blocking the five paths. Terrain remains flat. These are deliberate localized ground decorations, not independent PAR blocking sources.
5. Narrower second house changes correctly recompiled the blocking footprint to **239 blocked + 921/921 reachable walkable tiles**, compared with A36C 246 blocked and 914 reachable. 32px tile collision rules remain.
6. Rebuilt full **1280×928** `A36D_GROUND_FLORA_PATH_1280x928.png`, source-sorted `A36D_PAR50_RGBA_1280x928.png`, and actual `A36D_TRUE_GROUND_PLUS_PAR_1280x928.png`, plus real before/after `A36C_VS_A36D_ACTUAL_GROUND_PAR_BEFORE_AFTER.png`.

## Actual engine tests / screenshots (R2)
- Isolated native VX: `E:\FS_STAGE16_A36D_VISUAL_VX_NATIVE_20261102`.
- Actual Game.exe RGSS Player, Map050 (40×29): **403 native alpha sprites loaded, 11 test cases, 22 real 544×416 screenshots, no modal/RGSS error**.
- Tree-root blocked attempt `(11,11)->(11,12)`: still `(11,11)`.
- Dirt road rightward move `(11,8)->(12,8)`: successful.
- Front-of-new-building actual source screenshot case 07, roof occlusion behind case 06. The rear case has a fully obscured player silhouette (0 changed pixels). This is consistent with roof occlusion but should still receive targeted **human** visual review for actor readability and exit/entrance placement.
- True Godot 4.7.2 AMD RX6700XT: 6 native 1280×928 GPU frames and 6 native 544×416 region crops; comparison to expected alpha Ground+PAR: **max RGB single channel diff=1, 0 pixels with RGB delta>1**. Scene has 403 independent source sprites, 222 trees.
- **Independent native VX cold copy**, `E:\FS_STAGE16_A36D_VISUAL_VX_COLD_20261102`: **3823/3823 files SHA256 match**, launched Game.exe afresh, native 544×416 screenshot, Map050 entered, 403 objects loaded, 0 modal.
- Source-controlled proof files: `A36D_ART_BUILD_QA.json`, `A36D_ENGINE_BUILD_QA.json`, `A36D_VX_NATIVE_11_CASES_SCREEN_QA.json`, `A36D_GODOT_GPU_PIXEL_QA.json`, `A36D_NATIVE_VX_COLD_REBUILD_QA.json`, `A36D_ENGINE_STAGE_GATE_QA.json`.

## Worktree and reproducibility
- A36D: `E:\FS_STAGE16_A36D_VISUAL_REFINEMENT_20261102`
- A36C baseline read-only: `E:\FS_STAGE16_A36C_DENSE_FOREST_20261102`
- Source sheet read from user Drive into `CANONICAL_DRIVE_SOURCE`; recorded source SHA above.
- Source-first R1 art script: `a36d_build_visual.py` (only for a fresh empty stage, never run on current stage, to avoid reusing same file names).
- R2 art revision: `a36d_r2_roof_tone.py`.
- Native VX and Godot actual test projects generated by: `a36d_build_engines.py`.
- `a36d_prepare_capture.py`, then `a36d_capture_native_11_scenes.py` for actual screenshots.
- Godot console `--path GODOT_A36D_VISUAL_40x29 --script res://a36d_godot_native_render.gd`.
- `a36d_validate_godot.py`, `a36d_native_cold_verify.py`, `a36d_validate_all.py`, `a36d_package_private.py`.

## Art remaining & next A36E
- A36D R2 is not necessarily the best possible reference-level forest: the new thatch-roof stone cottage still needs detailed comparison to `ground3` pixel scale and natural village integration. Avoid pretending the 106 tiny ground clusters equal full forest-floor painterly detail.
- Inspect front/back actor visibility at both houses and extra narrow corridors; tighten/reposition trees or doors only with paired real RGSS screenshots.
- Replace/grow more original leaf varieties from the user's Trees atlas and add coherent village props/garden details from the supplied Props folder, avoiding cheap generic effects.
- The existing first cottage stays original; the second now uses true Hanzo sheet. Preserve these distinct designs as reference, not mandatory final models.
- Original source scripts Ground/PAR/Parallaxes mountainous/terrain lip audit **still deferred**, do not reintroduce cliffs in A36E flat-forest milestone.
- **Formal Seal NO / user art review PENDING**. Actual GPU/native engineering PASS is not art signoff.

## Verified Google Drive source, R2 proof and archive (read back 2026-11-02)
- Stage folder: https://drive.google.com/drive/folders/16GWArWzfn0G388FmvqdTIL2Z7fyPWzUO
- **Actual A36C vs A36D R2 Ground+PAR before/after:** https://drive.google.com/file/d/1HciDWl0a0MJbNvJ12ZrYrFoP_NxOEOTi/view
- **Actual A36D R2 full Ground+PAR 1280x928:** https://drive.google.com/file/d/1zYy4ksDhbbeTPtGupnXAsASeU61CX838/view
- **Actual native VX nine-region montage:** https://drive.google.com/file/d/1iydjkCptjM0TzVjduOAitT3wLkJd-vdU/view
- **Complete private ZIP (52,659,501 bytes, 477 entries):** https://drive.google.com/file/d/1BXwLn2xMAE1wlwEDJGXXfmgzFDqsIxEI/view
- A36D Ground: https://drive.google.com/file/d/1uggMSLNBZ05WshgeUezzcWRzfwH0wQ7n/view
- Transparent alpha PAR: https://drive.google.com/file/d/1s0O_UtoLlW4C_45AJjeImJl1cnOW35kV/view
- R1 neon roof witness: https://drive.google.com/file/d/1JstjYyOQJLQwLV7U3NQCpxdpl0Ng5GbW/view
- VX cold QA: https://drive.google.com/file/d/1uxyXMY-0JdRWl6CfHHcctmPHTSCNcpEK/view
- Engine all-gates QA: https://drive.google.com/file/d/1IxAn1fsVf0QcWuR9XdD_pog1u74xQ_dF/view
- Source package CRC / ZIP member SHA / independent unzip SHA: https://drive.google.com/file/d/1THscOz-gVuuzF-zhud-6DVf8RTTjujsx/view
- Google Drive uploaded ZIP byte length verified from actual Drive readback; private local archive ZIP SHA256: `b8a609d1860f2269f966156c5940b38d7b2e19b35edf473751de34f7e7d3be65`. The entire cloud ZIP was **not** re-downloaded to independently rehash.
