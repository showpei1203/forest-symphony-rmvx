# Forest Symphony | FS_01_MAZE R8 Water Physics | Failure Log | 2026-11-16

1. **Original R7 river collision missing**: A36 terrain semantic file had 148 proposed blocked river cells only; native world previously rendered a blue stream but lacked actual approved water collision. Fixed with R8 new scene and independent StaticBody2D containing 148 exact 32px collision rectangles. Original Ground untouched.
2. **Collision vs visual artwork**: R8 deliberately adds collision only, **0 changed RGB pixels** in the complete 2560×1856 original Godot GPU R7→R8 screenshot. Do not falsely call the debug blue overlay part of Ground. Overlay is DERIVED from the true original Godot frame, stored owner-only.
3. **Native physics verification**: Godot 4.7.2 PhysicsDirectSpaceState2D intersect_point queries actually struck the water StaticBody2D at **148/148 tile centers**, scene source/physics Exit 0. 326 PAR source SHA/footpoint/other colliders unchanged. Distinct and in-bounds 148 entries verified.
4. **Navigation still not verified**: A collision at every water center does not prove that remaining intended paths, bridges and village front doors are walkable. Full start/exit route checks, player crossing and river edge precision remain NAV HOLD, not PASS.
5. **Water art not implemented**: River is a static old Ground image. No independent flowing animation, shoal layering, ripples, depth, foam, shoreline transition or biome-specific river ecosystem. Water art HOLD.
6. **Ground technical debt**: R7 Ground is a nonuniform nearest enlargement of 1478×1064 source to 2560×1856, not a newly hand-painted 32px-native high-fidelity HD-2D base. ART HOLD.
7. **Project safety**: R8 water scene is additive. Baseline R7 scene SHA 8bf0a897bc6525ec7cef29e4992c46aa36639ffbeb9b675bbc4cd88194128c36; original A36B Ground SHA ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911; original SHADOW SHA 752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa. All unchanged; 40 historical A36C source sprite regressions remain rejected.
8. **Six biome goal**: first village and first dungeon are technical candidates. The other ten original biomes/roles remain PLANNED. Never claim all 12 built because registry titles exist.
9. **Release integrity**: Publish code/docs only to GitHub, binary original PNG and full private Godot project only owner-only Drive; verify cloud metadata/permissions and CRC/SHA for R8 patch before linking.

**ENGINE PHYSICS PASS (148/148) · REAL GPU 2/2 PASS · PIXEL DIFF=0 PASS · ROUTE/WATER ART/OVERALL ART HOLD.**
