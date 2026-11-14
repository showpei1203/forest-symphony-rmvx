# A43 R3 | Godot combat bridge candidate | 2026-11-14

## Delivered
- Private 103-member complete project ZIP (551122 bytes): https://drive.google.com/file/d/1Qn606HOaHKvrQUsmBvPxWrUBkLK8FWlq/view
- SHA256 `af69ee07c39409d92f1f5e8c86f5ea1474b98b7c1b9593d5bb85272728cbd3ca`
- Private actual 12-frame review PNG: https://drive.google.com/file/d/14P1yv6eVEGUFNooSt4HqXmUQSD5RuCqp/view
- New isolated Godot bridge scene: `scenes/a43_r3_combat_bridge.tscn`.
- Target HP/defense/death: `combat/fs_combat_target.gd`.
- Contact anchor to target damage: `combat/fs_attack_bridge.gd`, including serial dedup, pre-hit cancel, range rejection and dead-target rejection.
- Included in private ZIP: `qa/a43_r3_native_combat_qa.gd` for native Godot checks, `qa/a43_r3_package_audit.py`, `qa/A43_R3_STATIC_QA.json`, `A43_R3_ACTOR.gif`, `A43_R3_ACTOR_12FRAME_REVIEW.png`, updated `scenes/actor01.tscn` with A43 manifest.
- A42 original Body and Weapon atlas unchanged. A43 R2 FX F4-F8; hit at F6/0.55s and 70ms hitstop timeline retained.

## QA evidence
- Local Pillow exact 12/12 frame RGBA layer composition PASS.
- Manifest/scene contract and 12-frame dimensions PASS.
- A single nontransparent pixel touches the right edge in F6: visual clipping risk, ART HOLD.
- Native Godot 4.7.2 runtime **NOT RUN**, native test script is authored but not executed. FS ATB **NOT integrated**. No claim of actual runtime damage PASS.
- Original A42 source, E: VX, GitHub main, and map/migration branches not modified.

## Next required
Execute private candidate Godot headless QA in authorized environment; fix runtime errors; verify A42 regression; integrate the adapter into the actual FS migration battle module only after checking its current handoff; improve 45-degree arm/shoulder poses and obtain 1x ART PASS.
