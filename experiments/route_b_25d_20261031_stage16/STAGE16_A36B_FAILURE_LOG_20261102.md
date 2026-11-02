# Stage16 A36B Failure Log / Fail-closed register | 2026-11-02

| ID | Initial failure | Cause | Corrective action | Retest |
|---|---|---|---|---|
| VX-001 | RGSS dialog: Overlays/A36B_shrub_042_ORIGINAL_RGBA not found | Global string replacement changed reused A36 resource names but original filenames remained A36 | Rename 118 files in isolated VX, permanently correct generator to emit renamed files | PASS, 22 real frames, 0 modal |
| GD-001 | Godot static compositing RGB delta >1 for 202 pixels (max 170) | tree_005 and shrub_043 overlap at pixel x315-346/y783-809; same foot_y 812, different tie ordering | Sort Godot sprite inputs by (foot_y,id), same as PAR composite | PASS, maxRGB1, delta>1=0 |
| COLD-001 | Cold clone check initially missed 120 objects | Fixed 7-second wait ended before engine loaded Map050 | Poll for actual map-enter and object-count log, not fixed wall-clock time | PASS, actual log at 8.57s, SHA3538/3538 |
| ART-001 | Two cottages are duplicate roof/house design | Only one verified source cottage available within current scope | Retain as visible art limitation; A36C distinct building variants | OPEN, Formal Seal NO |
| ART-002 | Ground ecology remains below original FS ground3 reference | Source-derived grass and procedural paths alone insufficient | Add curated alpha sprites + coherent botanical clusters/props after visual reference review | OPEN, Formal Seal NO |
| TERRAIN-001 | Terrain/cliff PAR cannot be reliably derived | Original FS RGSS layering/ground/par triplet still under separate audit | Maintain freeze; do not generate guessed 1-2-tile lip mask | DEFERRED |

No unverified PASS claim. Native engine and GPU integration PASS; visual candidate still PENDING.
