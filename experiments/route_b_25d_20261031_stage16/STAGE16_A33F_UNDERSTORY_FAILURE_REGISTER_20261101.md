# FS Stage16 A33F Understory | FAILURE REGISTER, 2026-11-01
A33F selected R2 based on actual 1× layered Ground + separate PAR and native engine tests. Visual user signoff PENDING. Formal Seal NO.

### F-01 A33E 1x understory too weak
A33E's 9 RGBA shrubs were isolated and technically loaded but visually almost disappeared in rich forest-floor grass. A33F R1 (scale1.26) and R2 (scale1.61, bounded edge clamping) tested; R2 selected. Three distinct pixel botanical constructions (broadleaf, fern and tiny flower/shrub) replace original nine IDs and preserve SAME foot/collision status. **Do not call nine existing shrubs new IDs**, and don't mistake number of leaves/strokes for ecological realism.

### F-02 A33F initial source path wrong
First real PAR compile script attempted to find A33D historical tree assets in the A33E work folder, failing FileNotFound for `A33D_TREE_left_copse.png`. The missing source was not a lost user asset: canonical existing source is `E:\FS_STAGE16_A33E_FOREST_DIVERSITY_VX_20261101\Overlays`. Fixed branch to use original verified A33E VX Overlays fallback, then complete compilation and 1x composite QA passed. NEVER flatten missing objects to fill gaps, never silently skip.

### F-03 scatter versus coherent habitat
A33E had only ~150 recent grass additions. A33F improves large ecological zones using nine broad growth areas, 285 clustered stems sources, 2133 small native leaf strokes and 74 petite wildflower markers, preserving original 1885 accepted flora pixels and entire A33E road RGB exact. Candidate still depends on pixel-level source textures; visually check full Ground3 reference rather than presume ground realism from count.

### F-04 Test-only RGSS map script must never contaminate production
Original A32B 12 RGBA sha and original 15 A33E trees preserved. In A33F independent native map clone, `Data/Map050.rvdata` and original E collision SHA identical to A33E (23 blocked, 198 walkable). RGSS Script 483 filenames updated for 9 new RGBA art; other 506 scripts byte-identical. Original production BattleRegression fix from prior stages is still unresolved and map test scripts contain bypass; isolated native VX PASS is NOT sealed FS release acceptance.

### F-05 Dynamic foliage can alter actor ROI by design
Original road actor and full tree cover tests still PASS. At one behind-tree/understory test case the enlarged shrub may partially cover a character which was fully exposed in A33E. Do not treat changes in actor ROI automatically as a missing sprite or failed alpha; validate which foot-sorted shrub now occupies that region. Visual signoff needed.

### F-06 Godot GPU tolerance not exact zero
20 actual Godot GPU outputs passed, actual frame vs independent layered source has 3765 positions with only max 1 channel RGB difference, 0 positions exceed1. Do not report an exact zero-difference GPU match.
Native VX 18 cases/36 actual screenshots, road and 5 original/new tree-root movement tests, zero modal; independent cold 3415/3415 file SHA + actual startup/32 objects. User art review PENDING; Formal Seal NO.
