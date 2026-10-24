# Forest Symphony B1 | Level-1 Treehouse Platform v7 | 2026-10-24

**State:** isolated RPG Maker VX native technical PASS; visual benchmark NOT PASS; sealed FS runtime NOT TESTED; human Gate F NOT RUN.

## Scope and source authority

- Maintain the previously validated forest rich pilot with 48 PAR objects and 43 ground-flora instances. Only the central elevated treehouse source geometry changes.
- A single scene manifest identifies a new 192 x 192 treehouse composite, source hash ledger, and height-layer metadata.
- Level 0 ladder entrance is tile (15,10). Level 1 landing is tile (15,8), with only (15,8) and (16,8) walkable on the raised deck. Confirmation near the ladder moves the actor up or down. The upper platform cannot be exited off an edge.
- Actor level-1 visual elevation is 30 pixels, with its own depth. The adjacent tree's visible Pixel Owner ID provides a separate 610-pixel overhead occlusion mask without changing the static Ground or PAR visual master.

## Checks executed on Windows isolated Game.exe

- 8 real RGSS2 interaction gate results PASS: climb, platform step, edge blocked, cannot descend at far end, return to ladder, downwards edge blocked, level-0 descent, remote entry denied.
- 9 native screenshot probes from the previous tree, lodge, treehouse and upper-level cases. Background mismatches: 0; unlawful foreground occlusion differences: 0.
- 231 legal ground-depth positions checked; 461 ground-walkable tiles remain reachable from spawn; ladder reachable in 9 steps.
- Ground matches v6. v7 visual master changes 1,985 RGBA pixels; Ground/PAR-to-master and independent Tiled reference differences are 0.
- Negative injection: physically moving the treehouse one pixel changes 13,700 pixels; a tampered source SHA is rejected; a one-pixel occlusion-mask mutation is detected.
- Complete ZIP unpacked into an independent directory: 432 file hashes checked, 5 source/visual/height tests rerun and native VX 9 screenshot probes all PASS.

## Delivery and backup

Private Windows Game.exe, source image material, manifests, logs, screenshots, regression commands and hashes are archived in Google Drive:
https://drive.google.com/file/d/1r-xlmkTTk2snDWB9xJHgJu6oH-H95qeu/view

ZIP size: 15,765,890 bytes; 434 items; SHA256: `ee1959beb455bffa3a906c74391014843b2618f4b605548f5b38068771aa36e4`.

Google Docs current handoff: https://docs.google.com/document/d/1ULgzaZIDOzpfMe9moZogdgI56dvf-2Xic6GH1sbQKak/edit

## File cleanup

After cloud archive verification, local old v6 source directory, its local ZIP, and the v7 extracted regression duplicate were removed: 49.56 MiB freed. Total three cleanup stages: 176.98 MiB. Sealed FS runtime, accepted Forest FINAL, source libraries, tools and the active v7 playable build were retained.

## Restrictions and next work

This is only a two-tile level-1 platform on an isolated Project1 game. It lacks ladder climbing animation, bridge crossing with simultaneous underpass passage, complete elf village visual richness, formal sealed-FS compatibility, and human Gate F acceptance. Keep the production baseline sealed. Private asset provenance remains unapproved for public distribution.

Next: generalize height-level passage and overhead-owner masks to a bridge/river with independent above/below collisions; create the Sacred Tree and raise art detail toward benchmark examples. Do not declare FORMAL PASS prematurely.