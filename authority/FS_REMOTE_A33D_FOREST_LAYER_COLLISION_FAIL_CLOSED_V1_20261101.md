# FS A33D Forest Layer + Remote Capability + Native Collision Rules v1
Date: 2026-11-01. ACTIVE, not formal product acceptance.

## Unacceptable previous failure
When a user requests continuing actual work and Desktop Commander was used earlier, **inspect the available connected tools and list_devices before claiming remote tools are unavailable**. User's DESKTOP-90VT437 was shown Online, and the Remote MCP actually connected in this turn. Previous assistant said it could not access any remote tools without checking. **That assertion was false** and led to repeated planning-only replies. In future, call `Remote_Desktop_Commander.list_devices` and check specific operations before falling back to handoff instructions.

## A33D constraints
- A33C R13 is baseline for forest rework; A32B upper two broadleaf trees and 12 original PAR sources are USER ART APPROVED and must remain byte-identical.
- A33D adds 9 NEW separate PAR tree PNGs, each traceable to one of four previously user-supplied and approved tree source sprites, with nearest-neighbor reduction, optional horizontal mirror, mild intrinsic-leaf green variation; no cropped source sprite, no artificial SHADOW/LIGHT material. Each has own foot, source SHA, exact alpha PNG, scene X/Y.
- Actual forest scene has 13 trees / 21 independent PAR objects, and a separately edited new opaque 544x416 Ground. `Par50.png` must be alpha-composited from all 21 independent objects ordered by footpoint. NEVER substitute a flattened image for actual Ground+PAR source.
- Maintain all 12 existing source object sprite bytes, existing collision cells and old actor sorting. New tree trunk foot collisions are added as separate blocked E-tile IDs (768), and nonobstacle tiles remain 769. If 9 new trees occupy 9 independent nonroad tile cells, blocking goes 12→21. Preserve original road connectivity. Check BFS 200/200 remaining walkable tiles and native road move / two new blocked-trunk movement attempts.
- Do not claim exact same collision state when adding trees. Distinguish **original collision preserved + new collisions added** from unchanged total blocking count.
- Ground should use macro habitat groves, not sprayed single-pixel grass. Forest-floor A33D retains original A33C road EXACT RGB and original 1885 floral pixels, adds 276 grass colonies, 2019 pointed leaf strokes and 15 micro fern groups, retains 0 A33B bad dark-line detector pixels. Numeric zero for that detector does not automatically mean all visually objectionable contours gone.

## QA gates
1. Always produce two comparison options or more (this time +6/+9 trees) before selection; label actual source composites.
2. Validate each new alpha canvas is uncut, feet on nonroad pixels, road tiles remain original shape, 12 approved source PNG SHA exact. Preserve originals and previous project directories.
3. Real RPG Maker VX Game.exe, source `Map050.rvdata` E blocking and test-only Script 483 dynamic sorted objects: 21 loaded, 16 scenarios 32 actual RGSS Player screenshot pairs, original and new blocker tests, road move, zero error modal.
4. Godot 4.7.2 actual GPU on RX6700XT: 12 native screenshots and independently calculate RGB difference from original Ground + 21 sprite layered composite. A33D maximum single-channel RGB delta 1, 3925 pixels at most delta1, 0 above1. Do NOT call exact zero pixel equality.
5. Isolated cold VX clone, 3404/3404 per-file SHA, original native cold Game.exe Map50 startup loads 21 sprites. Earlier test-only BattleRegression bypass remains unresolved for production, so Formal Seal NO regardless of engineering PASS.
6. User art signoff remains PENDING for A33D. Reuse/scaling is acceptable engineering technique, but repeated trees or insufficient forest diversity may still fail aesthetic acceptance. Do not falsely claim newly generated species or native PixelLab generations if the version is source-derived.
