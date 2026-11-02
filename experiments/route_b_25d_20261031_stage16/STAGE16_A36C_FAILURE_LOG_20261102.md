# Forest Symphony Stage16 A36C | Failure Log / Known Open Risks | 2026-11-02

| ID | Finding | Verification / action | State |
| --- | --- | --- | --- |
| A36C-R0-01 | Previous A36B looked like a grassy field with isolated trees: only 54 tree placements and 19.788% visual canopy alpha coverage | Built real independent forest PAR with 168 additional tree placements from SHA-verified A34 source variants, 70 new low shrubs; A36C visual canopy union reaches 51.290%. | ENGINE PASS; aesthetic acceptance PENDING |
| A36C-PASS-02 | Dense trees risk sealing the free-cell path network | Every candidate tree root rejected if it occupies a reserved path/door tile, violates local safety distances or disconnects walkable space. Final 914/914 free cells connected. | PASS |
| A36C-PASS-03 | Overlapping sprites can silently produce different Godot/PAR z-order | Stable (foot_y,id) order used by both canonical PAR composite and Godot inputs. Actual GPU has 0 pixels with RGB channel delta>1. | PASS |
| A36C-PASS-04 | Native VX engine with 358 assets might fail to load, crash or block legal path | Actual 11 cases, 22 screenshots, 358 loaded, no modal; attempted blocked tree root remains at (11,11), road step (11,8)->(12,8) succeeds. | PASS |
| A36C-PASS-05 | SHA claim for cloned VX could be mistaken for successful cold boot | Separately re-copied actual engine folder, checked all 3777 files SHA, then independently launched Game.exe and waited for 358-object and Map050 runtime log. | PASS |
| A36C-ART-06 | Two cottages are still visually identical; trees do not automatically make a credible elf village | Keep duplicates explicitly recorded, replace with 2 distinct source-derived building designs in next revision. | OPEN |
| A36C-ART-07 | More trees can lead to excessive visual occlusion around actors or important ground landmarks | Representative native nine-region panel exists, but human review of all walkable forest corridors and all house sides is still required. | OPEN |
| A36C-ART-08 | Forest floor remains partially open and understory material limited by existing source sprites; not yet reference-level polish | Compare actual source with Drive full-map references, add ecological clusters and path edges, do not claim formal art seal. | OPEN |
| A36C-TERRAIN-09 | Legacy terrain/cliff PAR/Paraxell relation unproven | Deferred per authority; do not introduce cliff top lips, stairs or height in flat forest A36C. | DEFERRED |

**Formal Seal = NO**. The engineering pipeline passes, user visual review remains pending. No original FS/A36B source has been overwritten.
