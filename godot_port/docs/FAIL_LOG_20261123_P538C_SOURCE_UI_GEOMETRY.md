# P538C Failure Log｜2026-11-23｜source original UI page geometry

## Recorded real art error: P538B generic page rectangle
- Original owner-only UI ZIP (202 PNG, SHA c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6) and real P538A native screenshot audit confirm different **original** baked source window layouts. P538B universal white content Panel at x144,y119 covered source-specific bottom panels and party reserve frame. This is a source artwork design/geometry regression, not a generic rendering bug.
- FIX `db311354cb53b94efa99e196f5cea187c2ee6a6d`: source-native geometry `SOURCE_ROW_RECTS`, StyleBoxEmpty, dedicated current/reserve slots, actor nav above source list. **Godot4.7.2 native synthetic geometry coverage PASS** later #45129180313. Real original Godot screenshot still HOLD.

## Recorded real functional UX error
- Previous original menu page hides developer `log_label`, while `FSScreen._show_log` populated only that developer label. A rejected item/equipment source action could appear to do nothing.
- FIX `1d2d8a00c248b3f6b1c8e990add688b7820819eb`: forward denial to `FSOriginalMenuPage.show_feedback` while original page visible. Existing business behavior and refusal to consume unverified item unchanged. Native P538C fixture tests visible feedback and conserved inventory, PASS #45129180313.

## CI R1 FAIL → native fixture correction
- **Official GitHub Godot4.7.2 CI FAIL #45128951564** at `test_fs_p538c_source_window_geometry.gd` (step P538C): `P538C SOURCE GEOMETRY/OPERATIONS native FAIL: status screen 1x/2x centered source window`. See https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45128951564 .
- Root cause observed: **SceneTree-native test fixture** changed `root.size`, then asserted on an `FSScreen` Control retaining old viewport dimensions; no Control.resize was propagated in this synthetic harness. This does NOT imply original source art pixel placement failed; private original source images were not staged into this CI.
- FIX `074c8e2209dda5f7b4d4f5fb97df04fc0d683762`: propagate new viewport size to `screen.size` and run existing `_layout_source_menu()` before 544/1088 assertions. **Final official complete CI SUCCESS 99/99 steps**: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45129180313 . No further native errors observed.

## Source offline QA / explicit HOLD
- 202 source PNG ZIP downloaded from owner-only Drive into isolated execution space (never user Windows PC); verified 8,371,041 bytes, SHA256 `c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6`; ZIP CRC PASS. Five source backgrounds each exactly 544x416, 10 source tabs each 60x20; authored rectangle outlines audited as **offline geometry only**.
- PRIVATE Drive P538C QA ZIP (actual upload+readback owner-only shared=false), 723,848 bytes, SHA256 `78a0313020038deeb90e5a7978753b7a37d40616f6d3a42f29d42486fa04216d`: https://drive.google.com/file/d/13EQhnMU8iYBDsjMEdO3A9Mp0iFjwb0SE/view .
- **NOT RUN / ART HOLD**: P538C Godot 4.7.2 screenshot with actual source 202 sprites (isolation lacks official engine); P538C P539F original VX same-state compare, original postApply DB 11 tables, complete 505 RGSS2 effective aliases, physical RX GPU, user visual acceptance. Offline 1088px is nearest-neighbor enlargement, not a real 1088x832 Godot viewport.
- No new engine, tool, API fees, PC Bridge task, Codex or Desktop Remote used. Original VX on E: remains untouched. Original assets preserved as private Drive only. Phase1 SEAL NO.
