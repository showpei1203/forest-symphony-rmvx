# Forest Symphony｜Style-first V22 Sacred Grove｜2026-10-24

**Status: ISOLATED REAL WINDOWS RPG MAKER VX TECH PASS / New Sacred Grove Human Visual PENDING / Formal FS SEALED Runtime NOT TESTED / V8 Level0/1/2 NOT INTEGRATED.**

## Preserved baseline
The user approved the rich AI-generated v1 Ground style (“效果很棒”) and completed actual manual acceptance of v2.1 complete-well crop/collision (“成功！”). Both baselines and all sealed FS files are unchanged. Private [v2.1 user-accepted well build](https://drive.google.com/file/d/1iYUM7Ct3S6Ddee6ewUWc6C1oo_a2qIG_/view).

## Source-art decision and scene
Previous V9 sacred oak was evaluated and **rejected as inconsistent with v2.1's painterly forest art**. V22 uses a complete **85,143-pixel alpha-connected tree** from the same original AI forest-props source-sheet family. Native source bbox `[12,7,373,388]`; 3px padded ROI `[9,4,376,391]`; nearest-neighbor scaled to **213×224**. Base/trunk and canopy are separately editable source-backed derivatives, with exact source RGB/alpha recomposition, base split at y=156. The alpha=0 pixels initially had 2,478 latent RGB values; the source builder now clears them all and the audit fails closed on any recurrence.

The approved v2.1 **544×416 AI Ground is unchanged**. Nine PAR source-backed objects (new large tree replacing the former east blue tree, original well intact, noticeboard and northern rock moved to avoid overcrowding). Complete Scene Manifest owns source SHA, world XY, foot anchor, composite, Layer/Ground/PAR, PixelOwner, occlusion and collision. Tree's physical trunk/root contact local rectangle is `[81,186,137,224]`; canopy alpha is noncollidable. Built map has **25 blocked, 196 spawn-reachable** 32px tiles.

## Evidence for real native VX
- Manual Windows `Game.exe` boots, moves actor and has no auto-probe or teleport flag. Ground and nine PNGs verified against Source SHA.
- Exactly **15 screenshots from actual Game.exe**, including tree front/back, eight ring directions, spawn, intact original well: **0 outside-actor background mismatches** and **0 forbidden Owner occlusion mismatches** in every frame.
- The actor **actually walks 36 steps** around eight directions using native VX move calls. Four attempts to penetrate trunk/root contact are blocked. V2.1 well-body collision regression also PASS.
- Source-ground/PAR exact RGBA Master, source OwnerID rebuild, split base+canopy 0 mismatch; alpha0 RGB 0. Fail-closed negative tests: shifting tree 1px changes **28,973 pixels**, wrong canopy-as-collision and corrupted source SHA are detected.
- Full private release ZIP extracted into a new Windows directory: **251 source file SHA256 checks**, **five independent passes** (source compile, BFS planner, VX builder, native Game.exe 15 frames, semantic audit). The cold-extract audit is included in final release with verified ZIP CRC.

## Private playable release and records
[**V22 Complete playable private ZIP**](https://drive.google.com/file/d/1TFXFEMDQtem8hBxlypf1b6_JEBj9Fd2K/view)  
`FS_STYLE_FIRST_V22_SACRED_GROVE_20261024_PRIVATE_PLAYABLE.zip` | **20,372,042 bytes** | **253 ZIP items** | SHA256 `5a49706b85f607f537c761d34218849277d7079001a44dacede129c729875ac1`. Cloud Drive folder listing confirms actual file id and bytes. E:/G: SHA256 and ZIP CRC verified.

Unzip and launch `START_V22_GAME.cmd` on Windows. Developer `RUN_V22_ALL_CHECKS.cmd` repeats source/route/native/semantic tests (requires Python, Pillow, rubymarshal, and Windows graphical desktop). Package includes complete private source, original props sheet, derived sacred source/dual alpha layers, all masks, manifest, source hashes, native project, screenshots and logs.

[**Current Drive Handoff**](https://docs.google.com/document/d/1dkssj1SUIwijjht8WvTve80A3tTp7Txk1DpcfqIVMvI/edit) and [**Style-first Authority v4**](https://docs.google.com/document/d/1Hfs7v5tctPVrMDLB_a_0o-85_ou_jLKKx3sdtk0v5I4/edit).

Reproducible source-only tools: `tools/style_first/fs_v22_sacred_source_compiler.py`, `fs_v22_sacred_route_planner.py`, `fs_v22_sacred_native_builder.py`, `fs_v22_sacred_native_oracle.py`, `fs_v22_sacred_source_audit.py`. Private images and binaries must **not** be copied into public GitHub.

## Do not overclaim
New Sacred Grove still needs **user Human Visual acceptance**. Full complex Elf Village and Castle Town visual benchmark and V8 height-aware bridge Level0/2 / treehouse Level1 integration on this new Ground remain untested. Forest Symphony SEALED Runtime remains preserved and untested for this version. Next stage: enhance matching architecture/riverbank components, integrate V8 height schema into new source pipeline, re-run all real VX gates without inheriting unrelated old-scene PASS.


## Post-Cloud verified local cleanup
After official Google Drive listing identified the final private ZIP, local E:/G: SHA256+CRC matched, and five independent cold-extraction rebuild gates passed, deleted **only** redundant `FS_STYLE_FIRST_V22_COLD_EXTRACT_20261024` (252 duplicate files, **20.37 MiB** freed). Local audit `E:\GameAssetToolLab_20261023\logs\V22_SAFE_CLEANUP_20261024.json`. Current V22 source/real Game.exe/final ZIP, V21 user-accepted well project, V1 accepted art direction, and sealed FS runtime preserved. No final ZIP mutation after verification.
