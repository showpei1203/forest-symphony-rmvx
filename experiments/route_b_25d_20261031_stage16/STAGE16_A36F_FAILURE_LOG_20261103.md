# A36F R1 Failure Log | 2026-11-03

| ID | Found / failed initially | Fix | Retest |
|---|---|---|---|
| GROUND-01 | Previous grass and small flowers visually too scarce, roads looked drawn as pale uniform lines. | True source-ground changed via signed-distance spatial road-edge modification, native A34 1× shrub-derived grass tufts 1450 and native Hanzo flowers 175; 33859 road-mask pixels changed. | Generated, art review pending |
| ART-02 | First cottage had a different bright teal roof, unlike right-hand model requested by user. | Both houses are from the right-side Hanzo mother; left distinct 238×236 stone side annex, chimney, shutter and planters, right original mother preserved. | Generated, art review pending |
| PAR-03 | Forest visually repeated/understory insufficient. | 65 independent RGBA native shrub understory pieces, parent tree 222 preserved. Foot-y stable source ordering. | Godot pixel delta>RGB1 zero |
| TECH-04 | scipy missing in remote Python, initial Ground script import failed. | Installed scipy 1.17.1 on authorized device and reran actual Ground generation. | PASS |
| TECH-05 | PAR sprite duplicate names after stage prefix replacement caused SHA mismatch. | New additional shrubs renamed `A36F_EXTRA_LAYER_*`, only partial A36F unsealed source folder was cleared and regenerated. All 468 source SHA exact. | PASS |
| TECH-06 | A36F native builder initially read `cases` from wrong A36E QA file, KeyError. | Pull A36D validated 11 case array; rebuild isolated A36F clone only. | PASS 11 cases/22 actual frames |
| TECH-07 | More PAR/ground may cause scene, collision and compositor mismatch. | 927/927 free connected, native tree block and road moved verified, Godot 6+6 GPU pixel comparison max RGB1. | PASS |
| TECH-08 | Cold clone could pass SHA but fail runtime. | 3875/3875 independent copy SHA, separate Game.exe starts Map050 and loads 468 objects. | PASS |
| ART-09 | New cottage stone annex seam and road edge noise at pixel level require deeper visual QA; character behind house fully occluded in certain representative positions. | Pending improved native 1× visual inspection. Do not seal art. | OPEN |
| TERRAIN-10 | Original FS mountain PAR roof lip unresolved. | Retain separate legacy triplet audit, don't fake cliff obstruction. | DEFERRED |

**Engine PASS, user visual acceptance PENDING, Formal Seal NO.**
