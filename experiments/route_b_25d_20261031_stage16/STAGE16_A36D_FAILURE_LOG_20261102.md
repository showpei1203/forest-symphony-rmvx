# Stage16 A36D R2 | Failure Log | 2026-11-02

| ID | Observed problem / risk | Action and evidence | Status |
|---|---|---|---|
| A36D-ART-01 | A36C used the same cottage twice, visually obvious clone | Imported original user Buildings/Hanzo-TownSet03VS.png (verified SHA256), assembled a 198×236 stone/thatch cottage with original door, replaced the second cottage in real PAR/VX/Godot. | FIXED as distinct architecture; visual approval PENDING |
| A36D-ART-02 | A36D R1's roof green was brighter than surrounding FS trees | R2 retained original source and R1 witness; adjusted 25,287 roof pixels with scoped palette mapping, preserving all alpha geometry; built new composite and real engine tests from R2. | R2 FIXED; human review PENDING |
| A36D-ART-03 | Road/forest-floor too empty around village | Added 45 forest-source independent plant alpha objects and 106 edge-localized ground flora/stones clusters; no extra blockers; both Ground/PAR SHA changed. | PARTIAL, further ecological art passes needed |
| A36D-QA-04 | Replacing a wide house with narrower house can leave invisible collision strip | Removed old second house footprint except cells shared with tree roots; recalculated new geometry, 239 blocked and all 921 nonblocked tiles connected. Real VX road 11,8->12,8 succeeds, root 11,11 downward stays blocked. | PASS |
| A36D-QA-05 | Large PAR can differ from Godot because of same-foot-Y order or alpha artifacts | Used stable (foot_y,id), alpha source-by-source PAR, GPU pixel comparison max channel RGB1 and 0 over1 differences; six full and six crop frames. | PASS |
| A36D-QA-06 | Native VX 403 sprite assets or cold boot may silently fail | Game.exe 11 positions/22 true frames, Map050 403 sprites, no modal. Separate cold clone SHA 3823/3823, actual fresh launch, Map050 403 sprites. | PASS |
| A36D-OPEN-07 | Second roof is heavily opaque; in rear test player fully disappears | Expected rear-of-house occlusion (case06 RGB actor diff 0) but player readability, entry and rear walking need review with more positions. | OPEN |
| A36D-TERRAIN-08 | User's old FS cliff PAR 1-2 tile lip rules not fully reverse engineered | Terrain height remains excluded from flat woodland visual branch, old original project triplets preserved for deferred authority audit. | DEFERRED |

Engineering all gated PASS. **Formal Seal NO / user art signoff PENDING.** No existing A36C or original FS production source files overwritten.
