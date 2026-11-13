# Forest Symphony｜Godot-first CURRENT_HANDOFF
Latest: **A31 / 2026-11-14** | Repository: `showpei1203/forest-symphony-rmvx`
**Current development:** [Draft PR #16](https://github.com/showpei1203/forest-symphony-rmvx/pull/16) | branch `feat/fs-godot-first-a29-20261113`. **Do not merge main** without approval.
**Primary engine:** Godot 4.7.2 stable. Original RMVX/Tankentai scripts and FS v2.3.3 remain read-only function/art references. [Active Master v1.2](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-asset-factory-v1-20261107/authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md) + P0 cloud-only rules control rights, source SHA, QA, preservation.

## Actual latest build
- A30: original A11 1280×928 Ground byte/SHA unchanged, 3 individually editable PAR owners, true 32×32 Godot TileMapLayer physics with **180/1160 blocked CANDIDATES**, 980 remaining candidate-free cells connected but not USER-APPROVED traversable. Actual native Godot collisions and camera; original 48×48 Actor01 approved A62 battle RUN loop `0,1,0,2`. A62 is **not a full overworld four-direction animation**.
- A31: only opt-in `tree_canopy` foreground RGBA alpha changes over actor silhouette, **default OFF**. Key `H` toggles, exported `assisted_tree_alpha=0.35` candidate. Original complete Ground RGB/SHA, standalone source PAR assets and non-tree bridge are unchanged. A30 build_overlay default parity is byte-for-byte.
- Native framebuffer comparison at 544×416, tree behind A30→A31 changed 181 pixels; tree front **0**, bridge behind **0**. 100/65/35/20%-opacity comparisons under private QA. These are human ART review aids, **not ART PASS**.

## Actual tests and source evidence
- **Godot 4.7.2 isolated true private sources:** A30 real 221/221; A31 real 4627/4627; 8 native rendered screenshot captures. Master SHA `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530`. Audio not tested.
- **Godot source-only public:** A30 389/389, A31 133/133; [A31 exact HEAD CI 43518321348](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43518321348) completed/success. CI log confirms all new tests actually ran.
- **Private complete 79-file R3:** [Drive A31 ZIP](https://drive.google.com/file/d/1ENyWqKdqQkmENbQNXUdFOZxt8lHddiQK/view) 28,297,484 bytes, SHA256 `56696d0abe47e2176d2a1624fb4a4a914cb8ffe4b5aaf46cea1deb259dcdcde6`, upload/download SHA256/ZIP CRC PASS, not in GitHub.
- [Drive true native 4-way visual comparison](https://drive.google.com/file/d/1avAhO6gUJjcKHs_jgfI_n7rSbm29NHiX/view) (owner-only); [A31 QA/Failure Log/Handoff](docs/A31_HANDOFF.md); [Drive Handoff mirror](https://drive.google.com/file/d/1hPCDlIJ57MDryOyRdz2keLoEduVTjUyB/view).

## Gates / stopped assumptions
- USER_ART_RESULT **HOLD**, detached-head may remain due to small 48×48 battle F0 and source mask. A31 alpha assist is candidate, NOT approved new final art.
- COLLISION_ART **HOLD**: 180 blocked cells are manually judged candidates, not complete source semantic legal network.
- PMD/Actor01 overworld 4-direction, roof source independent mask, real events / skills / summons / ATB / Save / Windows build **NOT_RUN**.
- Native VX Game.exe no longer prerequisite for Godot map development. Formal seal **NO**; user PC writes **0**; PixelLab paid calls **0**. PR #15 and original VX sealed files untouched.

## Next concrete work
**Priority 1:** improve true tree-canopy/trunk source geometry and role-based cover, compare 1x **art** and record USER_ART/HOLD.
**Priority 2:** revise water/river/house/forest map collision boundaries using source-matched 32px semantic evidence, then native Godot walk/negative/camera tests.
**Priority 3:** obtain proper top-down overworld 4-direction actor actions; do not relabel A62 battle 45° animation as overworld walk.
Always write real test proof, Failure Log and cloud Handoff at end of the stage. Keep private PNGs/ZIP on owner-only Drive, only code/tests/docs in public GitHub PR.
