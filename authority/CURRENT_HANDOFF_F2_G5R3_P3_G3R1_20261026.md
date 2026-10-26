# CURRENT_HANDOFF — F2_G5R3 player-scale fix + P3_G3R1 style approval
2026-10-26 | authoritative for isolated Shared AI Art Toolchain pilot

## User-approved artistic decision
User: "我非常喜歡橘灰岩火版本，方向正確。" Record P3_G3R1 PMD 0001 color/material direction as **USER STYLE DNA APPROVED**: warm orange frog, dark-grey juvenile volcanic rock shell, initial hairline fractures revealing faint magma. This establishes the family style for original 0002 (thicker cracked rock and stronger magma) and 0003 (fractured basalt with molten core, rock+fire). The complete 0001 34-action / 1123-frame animation artwork has **not** received independent human per-action acceptance, and only the isolated Godot XML bridge was native-tested. Official PMD runtime, VX SBS and commercial rights still pending. Do not regenerate a mockup when asked for the latest P3 art; always link/show actual existing `P3_G3R1` source or comparison.

Current finished P3 asset (do not modify this task): [G3R1 ZIP](https://drive.google.com/file/d/1iopQqJ7qtefob-57eJXgjRwhCPEOclGQ/view?usp=drivesdk), [actual original/rock/volcanic comparison](https://drive.google.com/file/d/1SXLaRwqbo-XjrM4vX8TUvlqdzA3SJpmQ/view?usp=drivesdk). Real source PMDCollab `sprite/0001`, 34 action atlases, original XML/Offsets/Shadow kept byte-identical and all 1,123 cells modified. Future production P3 G4: direct original PMD loader or VX SBS, preserve the approved orange-gray/magma style. 0002/0003 future goal only.

## F2 G5R2 NEW REGRESSION (user)
The user identified the lower-right flower clump in the 320x256 continuous Ground source as potentially **nearly the size of the in-game character**. This invalidates treating the sample as ready-to-use Ground, regardless of the 80-source-tile 0 RGB drift QA. It does not invalidate technical source continuity.
- Source continuity: 320x256 (10×8, 80 original source tiles) exact rebuild **TECH PASS**.
- Flora/player scale and semantics: **FAIL / HUMAN SCALE REVIEW REQUIRED** until actual VX playable actor is measured.
- Full-size art Ground (older donor patch version): **ART FAIL**.
- Original G4 VX collision (45×34, 1530 cells, 711 solid/819 reachable, closed door adjacent front open): **TECH PASS**, separate from this art gate.

## Mandatory F2_G5R3 next execution
1. Find the actual VX actor used in real FS map, measure visible bounding box **at game scale** and foot anchor. Avoid assuming a 32×32 cell is the character size.
2. Overlay the actual actor at 1× on original G5R2 320×256 Ground adjacent to the bottom-right flowers; inspect ratio; produce a real before/after + measured JSON. If actor cannot be located, set `BLOCKED_ACTOR_REFERENCE` and do not pretend to have passed.
3. Audit all 80 tiles and identify flowers, grass, shrubs and rocks. Flush grass/dirt/tiny petals remain Ground; taller flowers/bushes/rocks are source-owned separately in PAR, regardless of soft-prop collision. Threshold-based flags must have artist confirmation.
4. Remove oversized flowers from Ground using real cohesive ground source, **no blurry donor patch or invented texture clones**; PAR flora transparent PNG with bounding rect, anchor, optional collision only for solid contacts, y-depth testing with actor.
5. Only after actor-scale art/source and independent Ground/PAR masks meet QC attempt native VX check and user Human Gate. Preserve previous full-size F2 Ground FAIL and F1R1 A04 approved SEALED.

## New authority
`AI_ART_GROUND_ACTOR_SCALE_RULES_20261026.md` is the new hard-rule supplement. P3 approval scope and G5R2 regression are now persisted in latest dated handoff. Update Google Drive, GitHub and Linear SHO-39. This is a **rules/handoff update only**, not a newly revised Ground PNG or monster sprite edition.
