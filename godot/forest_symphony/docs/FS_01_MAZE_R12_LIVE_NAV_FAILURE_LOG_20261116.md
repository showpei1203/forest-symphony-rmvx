# Forest Symphony | FS_01_MAZE R10–R12 Road Navigation Failure Log | 2026-11-16

## Prior user-visible problem solved
R9 native footpoint AStar produced 5 physically connected routes but selected visually inappropriate straight axes across dense forest instead of following winding roads. FIX R10 reads ORIGINAL unmodified Ground-only RGB, derives warm-earth road score per 32×32 cell, and runs real Godot 13×9px foot collision-weighted AStar. All five routes raise painted-road alignment; 148 river cells remain blocked.

## Native QA and errors caught
1. Initial GDScript R10 used variable name "pass", reserved by parser. Source/test failed parse. Changed to candidate_ok and reran. No source art modification.
2. Initial R10 grid test compared JSON float array against literal integer array, Godot rejected despite correct dimensions. Corrected explicit int(dims[0]) / int(dims[1]), and reran to real native PASS.
3. Unauthenticated GitHub raw URL immediately after source update returned older script. Compared actual remote file, patched authoritative test source directly in connected Drive and kept correct GitHub canonical source.
4. R11 original Player CharacterBody2D.test_move inspected every 32px continuous segment, 231/231 zero collision; this reveals potential between-cell problems that cell-center grids miss.
5. Initial R12 native test used variable name "match", a GDScript keyword. Fixed to same_path and reran; original integrated live runtime PASS.
6. R12 original Godot full native GPU before/after compared 4,751,360 RGB pixels, 0 difference. Real Godot 326 whole PAR, original PNG Ground SHA and R8 scene SHA unchanged; no invisible overwrite of artwork or accidental additional shaders.
7. Current road-confidence classifier is trained on existing forest scene colors. For snow/sand/lava/marsh/crystal maps MUST derive proper biome-specific semantic materials, never reuse tan RGB threshold blindly. Likewise R10 smoothed confidence is routing preference, not formal art/road design or automatic drawn trail.
8. R10 candidate routes can become longer (center→east clearing 35→63; south→north 61→81), intentional path following. Future mission/path length target and user approved maze branch design may change cost. Do not mislabel algorithm success as final intended maze.
9. Runtime RoadNavigator recomputes 4,640 physical foot overlaps when loaded. No benchmark of latency under full actors/moving obstacles yet; optimize/cache only after profiling, not claim it free. Dynamic NPC changes and obstacle invalidation NOT IMPLEMENTED.
10. Full gameplay still needs chosen entrance/exit, route-to-door alignment, bridge crossings, in-game moving actor/input animation, NPC events/teleport integration and visually accepted HD-2D Ground3; ART HOLD / FINAL NAV HOLD.
11. Six biome x maze/village world goal remains 12. Only first village (art HOLD) and forest dungeon (engineering pass, art/nav HOLD) have native prototype work. Other 10 PLANNED. Never claim 12 maps finished from catalog text.
12. Origin and source protection: all work in independent Drive folder and separate original-Ground-immutable new scene; original A36B/A36C, R8 scenes, elf village and Godot combat branch untouched. GitHub code/tests/manifest/docs; full private source ZIP and original GPU frames owner-only Drive. Every new release must verify cloud size/SHA/CRC/private permission before linking.

**R10 5/5 native road preference PASS, R11 231/231 Player sweep PASS, R12 native live road API/GPU 0-pixel regression PASS. Art and formal navigation remain HOLD.**
