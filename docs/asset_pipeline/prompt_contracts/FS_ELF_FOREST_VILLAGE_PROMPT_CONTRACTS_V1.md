# FS Elf Forest Village — Prompt Contracts v1

Date: 2026-08-22  
Project: Forest Symphony / RPG Maker VX  
Workflow: FS Map Asset Prompt Workflow v1  
Stage: 7 — Prompt Contracts  
Status: LOCKED FOR STAGE 8 PILOT GENERATION

Reference Set: `FS_REFSET_ELF_FOREST_VILLAGE_V1`  
Style DNA: `FS_ELF_FOREST_VILLAGE_STYLE_DNA_V1`  
Pilot Selection: `FS_ELF_FOREST_VILLAGE_PILOT_SELECTION_V1`

## Shared rules
- RMVX world basis: 32x32 px.
- High top-down / three-quarter RPG camera.
- No strict isometric, cinematic low-angle, pure plan, blur, painterly AA or sub-pixel drift.
- Forest Symphony palette/material language remains authoritative.
- Modular source assets only; no complete final map baked into a generated image.

## Water Animation Authority
`TERRAIN-WATER-STREAM-A` is an animated family, not a single still texture.

- Each candidate family contains 3 coherent phases: A / B / C.
- Loop: A -> B -> C -> A.
- Phases are sequential motion states of one material, not unrelated variations.
- Every phase must be seamless on all four edges.
- Temporal change must read as gentle stream motion without flicker.
- AI produces source animation art; final RPG Maker VX A1-compatible quadrant/sheet packing is deterministic postprocess after QA.
- Existing A1 water is animation-pattern/packing reference only; new water uses restrained outdoor blue-green Elf Village Style DNA.

# PC-TERRAIN-WATER-STREAM-A

1. **ID:** `PC-TERRAIN-WATER-STREAM-A`
2. **Category:** Base Terrain / Animated Water Source
3. **Map/Biome:** Forest Elf Village / reusable forest-village stream
4. **References:** locked Reference Set + existing FS A1-style water animation-pattern evidence
5. **Use Case:** animated stream/river surface for manual mapping and deterministic VX A1 packing
6. **Footprint:** final world logic 32x32; pilot source normalization target = three equal 256x256 phase panels / 768x256 strip
7. **Perspective:** high top-down terrain surface; no horizon
8. **Silhouette:** no focal object; broad readable ripple clusters
9. **Palette:** restrained blue-green, muted teal/deep-blue accents, modest pale highlights; softer/warmer than dungeon water
10. **Variation Axis:** candidate families may vary ripple size, highlight density and flow rhythm only
11. **Background:** opaque terrain source
12. **Positive Prompt:**
`three-phase looping pixel-art forest stream water animation source for a fantasy RPG map, Forest Symphony visual language, high top-down terrain surface, designed for 32x32 world-scale readability, three equal sequential phases A B C of the same water material, subtle coherent ripple motion from phase to phase, restrained outdoor blue-green palette, broad readable ripple clusters, low micro-noise, each phase independently seamless on all four edges, temporal loop A to B to C to A, pixel-crisp hard edges, no focal object, no border, no scene context`
13. **Negative Prompt:**
`single static water image, three unrelated water styles, flickering unrelated frames, giant ocean waves, waterfall, shore, bank, rocks, plants, bridge, fish, lily pads, foam object clusters, reflections of buildings or sky, dungeon water, icy cyan water, lava, photorealism, painterly blur, anti-aliased soft edges, strict isometric perspective, vignette, frame, divider line, labels, text, UI, obvious repeating emblem, central stamp`
14. **Source Resolution:** preferred normalized strip 768x256; if model output differs, preserve equal phase geometry and use deterministic crop/split + nearest-neighbor integer normalization after visual acceptance
15. **Allowed Postprocess:** panel split, palette trim, NN integer scale, repeat test, loop/GIF witness, deterministic A1 packing
16. **Forbidden:** interpolation resize, repainting failed motion, mixing phases from different candidate families, warping one phase, embedding props/shore
17. **QA:** 3x3 repeat for every phase; A/B/C loop without flicker; no stamp/object; correct palette; 32px preview readable; A1 witness packable without repaint
18. **Status:** PILOT / LOCKED

Pilot: 3 animation-family candidates, each with 3 phases.

# PC-TRANS-GRASS-WATER-BANK-A

1. **ID:** `PC-TRANS-GRASS-WATER-BANK-A`
2. **Category:** Terrain / Structure Transition
3. **Map/Biome:** Forest Elf Village / reusable forest stream bank
4. **References:** locked Reference Set + accepted animated-water family
5. **Use Case:** transition reused FS grass to moving stream water
6. **Footprint:** tile-compatible 1–2 tile local modules; straight, inner, outer, end/cap
7. **Perspective:** same high top-down three-quarter terrain edge
8. **Silhouette:** low-profile grassy soil bank; no cliff-scale wall
9. **Palette:** reused FS grass + warm soil/root + restrained warm-gray stone
10. **Variation Axis:** geometry role only; thickness/material stays fixed
11. **Background:** transparent PNG preferred
12. **Positive Prompt:**
`modular forest stream bank transition kit, high top-down three-quarter fantasy RPG pixel art, Forest Symphony visual language, compatible with 32x32 tile logic, designed to connect existing village grass to restrained animated blue-green stream water, low natural grassy soil bank with subtle root and warm stone accents, consistent bank thickness and height, pixel-crisp, isolated source artwork, transparent background, one coherent material family, connector geometry designed for straight edge inner corner outer corner and end cap modules`
13. **Negative Prompt:**
`complete river scene, full map, waterfall, tall cliff wall, bridge, dock, house, tree, character, giant rocks, cold dungeon masonry, snow, crystal, cinematic perspective, strict isometric diamond grid, inconsistent bank thickness, soft painterly edge, blur, glow halo, long cast shadow, text, UI`
14. **Source Resolution:** coherent transparent kit or controlled module outputs; connectors retain integer 32px logic
15. **Allowed Postprocess:** isolate/trim modules, binary-alpha/chroma cleanup, NN integer scale, deterministic connector alignment
16. **Forbidden:** warp/stretch, independent thickness repaint, embedded bridge/waterfall/props, whole-scene flattening
17. **QA:** straight/inner/outer/end valid; stable thickness; corners fit straight; works with reused grass and accepted moving water; 100% crisp
18. **Status:** PILOT / LOCKED

Pilot: minimum 4 modules. Finalize only after one water family is accepted.

# PC-ARCH-TREEHOUSE-SMALL-A

1. **ID:** `PC-ARCH-TREEHOUSE-SMALL-A`
2. **Category:** Architecture / Map-Specific Elf Residential
3. **Map/Biome:** Forest Elf Village
4. **References:** ordinary FS timber-house scale/material grammar + approved broadleaf trees
5. **Use Case:** small elf treehouse body combining with reusable trees, platform modules and existing access pieces
6. **Footprint:** approximately 3–5 tiles wide / 96–160px world envelope; entrance around one tile wide
7. **Perspective:** high top-down three-quarter; front/down-facing entrance readable
8. **Silhouette:** compact roof/body/door/platform logic; readable support/trunk interface; no palace mass
9. **Palette:** warm timber, dark supports, restrained moss/olive roof accents, limited warm-gray stone
10. **Variation Axis:** roof pitch/curve, windows, porch asymmetry, restrained moss; camera/interface fixed
11. **Background:** transparent PNG preferred; #FF00FF fallback
12. **Positive Prompt:**
`isolated small elf treehouse residence, high top-down three-quarter fantasy RPG pixel art, Forest Symphony visual language, designed for 32x32 tile world scale, target platform and body approximately 3 to 5 tiles wide, clear one-tile-scale entrance facing generally downward, compact warm timber architecture integrated with a readable tree-support or trunk anchor zone, restrained moss and leaf roof accents, carved organic wood details, visible platform contact logic, strong readable silhouette at RPG Maker VX scale, pixel-crisp, transparent background, no environment scene`
13. **Negative Prompt:**
`full forest scene, complete village, giant fantasy palace, oversized MMO treehouse, cinematic camera, low angle, strict isometric projection, white marble elf palace, sci-fi structure, photorealism, painterly concept art, blurry antialiasing, tiny unreadable filigree, huge neon magic glow, unrelated props, crowd, ground plane, long cast shadow, cropped doorway, text, UI`
14. **Source Resolution:** enough transparent margin around 3–5 tile architecture envelope; preserve integer world-scale relation
15. **Allowed Postprocess:** trim margin, binary-alpha/palette cleanup, pre-approved NN integer resize, isolated-pixel cleanup without redrawing geometry
16. **Forbidden:** perspective warp, arbitrary resize to fit witnesses, grafting candidate bodies before QA, background removal that eats edges, full tree/forest scene bake-in
17. **QA:** plausible beside ordinary house + tree witness; entrance/support/platform readable; correct 3–5 tile scale; same camera/material family; no Hero dominance; can attach to at least two platform arrangements
18. **Status:** PILOT / LOCKED

Pilot: 3 meaningful candidates.

# PC-ARCH-TREE-PLATFORM-A

1. **ID:** `PC-ARCH-TREE-PLATFORM-A`
2. **Category:** Architecture / Modular Platform + compatible `ARCH-RAILING-ORGANIC-A`
3. **Map/Biome:** Forest Elf Village
4. **References:** FS bridge/deck/wood vocabulary + accepted treehouse direction
5. **Use Case:** reusable elevated platform pieces
6. **Footprint:** approximately 2–5 tiles by role; integer 32px connector geometry
7. **Perspective:** same high top-down three-quarter camera
8. **Silhouette:** walkable deck plane dominates; railing/supports stay subordinate
9. **Palette:** weathered timber, dark supports, restrained moss/carved organic accent
10. **Variation Axis:** straight deck, small landing, supported edge, end treatment; railing shares one thickness language
11. **Background:** transparent PNG preferred
12. **Positive Prompt:**
`modular elevated elf treehouse platform kit, high top-down three-quarter fantasy RPG pixel art, Forest Symphony visual language, compatible with 32x32 world-grid logic, warm weathered timber deck with dark structural supports and restrained moss or organic carved accents, clear walkable deck plane, consistent deck thickness, integer-grid connector edges, compatible low organic railing that does not hide the deck, isolated transparent source artwork, designed as reusable straight deck small landing supported edge and end treatment modules, pixel-crisp`
13. **Negative Prompt:**
`complete treehouse scene, full forest, giant bridge, city boardwalk, modern lumber construction, strict isometric diamond grid, cinematic angle, inconsistent deck thickness, railing taller than architecture, dense decorative clutter covering the floor, photorealism, blur, painterly antialiasing, glow halo, ground plane, characters, text, UI`
14. **Source Resolution:** coherent module sheet or controlled individual outputs; transparent separation; preserve integer connectors
15. **Allowed Postprocess:** split modules, trim margin, binary-alpha cleanup, NN integer scale, deterministic connector alignment; rotate/flip only when proven perspective-safe
16. **Forbidden:** non-uniform stretch, perspective warp, per-piece deck-thickness changes, arbitrary repaint, permanent whole-scene merge
17. **QA:** four roles identifiable; same thickness/pixel density/camera; railing subordinate; modules connect; treehouse can attach; reused stair/ladder can meet one edge; second composition can be recombined
18. **Status:** PILOT / LOCKED

Pilot: minimum 4 modules + compatible railing treatment.

## Deterministic reuse witness instructions

### RW-TERRAIN-GRASS-A
- Source: current `Graphics/System/TILEA2.png`.
- Native pixel crop/selection only; no AI repaint/smoothing.
- Witness: `FS_TERRAIN_FOREST_GRASS_A_PILOT_V1.png`.

### RW-TERRAIN-DIRT-PATH-A
- Source: current `Graphics/System/TILEA2.png`.
- Native pixel crop/selection only; no AI repaint/smoothing.
- Witness: `FS_TERRAIN_FOREST_DIRT_PATH_A_PILOT_V1.png`.

### RW-VEG-BROADLEAF-COMMON-A
- Source: locked approved legacy/reference vegetation, especially TileD evidence.
- Extract 2 silhouettes; exact crop/background removal only when boundary is unambiguous; no AI inpainting.
- Witnesses: `FS_VEG_FOREST_BROADLEAF_A_01_PILOT_V1.png`, `FS_VEG_FOREST_BROADLEAF_A_02_PILOT_V1.png`.

### RW-ARCH-HOUSE-SMALL-A
- Source: locked TileB / existing FS timber architecture grammar.
- Clean legacy extraction or deterministic 32px-grid assembly allowed; no AI generation/inpainting.
- Witness: `FS_MAP_ELF_VILLAGE_ARCH_HOUSE_SMALL_A_WITNESS_V1.png`.

## Stage 8 order
1. Prepare reuse witnesses.
2. Generate animated water candidates.
3. QA spatial + temporal water; accept one direction.
4. Generate bank against accepted water.
5. Generate treehouse candidates against reused scale witnesses.
6. Generate platform + railing kit.
7. Build mixed diagnostic witness.
8. Run Terrain / Architecture / Reuse / Scalability gates.

Do not generate Sacred Tree Hero before these gates pass.

## Stage 7 Gate
PASS because all four contracts are complete; animated water is locked as 3-phase spatial+temporal seamless source; A1 packing is deterministic downstream; bank dependency is explicit; architecture interface rules are locked; reuse witnesses have deterministic instructions; no Hero or image generation has begun.

Stage 7 result: **PASS**.

NEXT: Stage 8 — Pilot Generation. Begin with reuse witness preparation, then animated water pilot.
