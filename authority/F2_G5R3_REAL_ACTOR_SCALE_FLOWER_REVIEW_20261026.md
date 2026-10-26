# F2 G5R3 — Actual RPG Maker VX Actor Size vs Oversized Ground Flowers

Date: 2026-10-26. Fail-closed source-first art pipeline.

## Actual progress
From real isolated `F2_R3_G4_VX_REAL_GAME_20261026/Data/Actors.rvdata`, actor1 uses `Actor1` `character_index=0`. F2 scene has no local `Graphics/Characters/Actor1.png`, therefore installed RPG Maker VX's native `C:/Program Files (x86)/Enterbrain/RPGVX/Graphics/Characters/Actor1.png` is the actual backing sprite. Verified 384x256 sheet / 12×8 character-frame arrangement, selected walking-down 32x32 frame (middle column, first row); actual nontransparent visible bbox (2,0,30,32) = **28×32 pixels**, foot anchor (16,32), native 1×.

G5R2 genuine 320×256 original ground crop has intact 80× 32px positional source cells, 0-pixel reconstruction drift, but a **large raised flower clump lies at the bottom-right** and is cropped by both bottom and right source image borders. Source continuity alone was previously misleadingly treated as a candidate for Ground.

Created two source-backed 1× character-on-ground visual screens, plus all-80 tile review grid, source-context beyond cropped G5R2 bounds, screening-mask image and JSON manifest. Flag 9 source cells (cols 7–9, rows 5–7; x224–319,y160–255) `NOT_GROUND_FLORA_REVIEW`. 71 others remain `SOURCE_CONTINUITY_ONLY_ART_PENDING`. **The 96x96 pixel ROI is mixed with grass and dirt and cannot be reported as actual flower height or a finished alpha object.** This is a clear semantic artwork FAIL/PENDING true source separation.

## Verified deliverables
Private [F2 G5R3 complete true actor 1x compare, 80 tile audit, uncropped flower context, source QA/CMD/LOG, handoff ZIP](https://drive.google.com/file/d/1dm6BaqbAlqB5tsgDCGju2xovu4sFNvtr/view?usp=drivesdk): 815,268 B; SHA256 `8006a7618a2f287257f53ce690c8592993d3a1357a54647d665bca07fe8346e7`, 80 tile source QA, ZIP CRC, cold SHA and cold source QA all PASS.
- [Actual original VX avatar vs Ground 1x](https://drive.google.com/file/d/1y1X4RPZY7XtxiKLC4dswVXwcYPRhE9J5/view?usp=drivesdk)
- [Actor 1x and flagged flora ROI](https://drive.google.com/file/d/1UqItjnFwqRgTMo9OKfmHU77XEAr7kc5J/view?usp=drivesdk)
- [80 tile per-grid screening](https://drive.google.com/file/d/1mjOzIbP9lX4FeXqOnlQki16xu2yXAJ-z/view?usp=drivesdk)
- [Uncropped larger original floral scene for genuine PAR isolation](https://drive.google.com/file/d/1_9fH9XsQ8sT6R5wwZGmEbHVYERCdQEZj/view?usp=drivesdk)

## Gate statuses
- Actual VX avatar and native visible pixels: **MEASURED PASS**.
- Source original Ground 80 tile pixel-contiguity: **TECH PASS ONLY**.
- 9 source cells with raised flowers: **NOT-GROUND; next actor-scale semantic gate FAIL/PENDING pixel alpha segmentation**.
- Original high-detail full F2 Ground patch donor seams: **ART FAIL**.
- New transparent flower PAR, underpaint, scene-native VX occlusion/human acceptance: **NOT DONE**.
- PMD0001 P3_G3R1 orange-gray volcanic species: USER APPROVED **VISUAL DIRECTION ONLY**, original sprite unchanged this milestone. See previously synced accepted color DNA rules.

## Updated authority
Use the real actor to determine Ground detail scale, not map tile dimensions. Complete vegetation must be independent owner with accurate alpha, source bounds, anchor and soft/hard collision. A rectangular ROI is only a diagnostic, not a sprite. Source-first cohesive reconstruction required, never crude clone donor or blurred ground.
 
## Next concrete gate
`F2_G5R4_COMPLETE_FLORA_SOURCE_ISOLATION`: get complete original floral clump from the bigger original high-detail reference; make a pixel-owned independent PNG and mask without cropped blossoms, unwanted rock, fence or surrounding ground. Then create corresponding truly cohesive Ground and real 1x actor composite, test PAR y-occlusion and VX collision if physically warranted. F1R1 A04 stays sealed and unchanged.
