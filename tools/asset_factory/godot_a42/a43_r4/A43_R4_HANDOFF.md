# A43 R4 | 2026-11-14
- Private 106-member candidate ZIP SHA256 76adeb6e37366fb155dc9c69d8d22e7ece436f711f0857e0cf8dea114fffbd84.
- R3 bridge corrected to monotonic serial watermark instead of unbounded Dictionary. Cancellation, out-of-range, defeated target and duplicate delivery guarded.
- Original A42 Body/Weapon/FX byte-identical; 12-frame attack F6/0.55s and 70ms hitstop retained.
- Added native Godot extended QA in private ZIP qa/a43_r4_bridge_extended_qa.gd.
- 7/7 static source/atlas checks PASS, ZIP CRC PASS. Native Godot NOT RUN; formal FS ATB NOT INTEGRATED; ART HOLD.
- Do not promote to main or call TECH PASS before native run and integration.
