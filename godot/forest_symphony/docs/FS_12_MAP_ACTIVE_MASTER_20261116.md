# Forest Symphony | WORLD MAP ACTIVE MASTER v1.0 | 2026-11-16

## 0. NON-NEGOTIABLE GOAL (12 maps)
**SIX distinct biome families × (one DUNGEON / MAZE + one VILLAGE) = TWELVE core playable maps.**
This is the primary map-production goal, not endless polishing of a single sample village. All must eventually have distinct completed Ground, independently editable whole-object PAR, coherent environment, full 1:1 visual polish, actor collision and Godot runtime.

| Family | Biome ID | Dungeon | Village |
|---|---|---|---|
| 蒼翠精靈林 | VERDANT_ELF_FOREST | FOREST_DUNGEON | ELF_VILLAGE |
| 凜霜雪原 | FROST_SNOWFIELD | SNOW_DUNGEON | SNOW_VILLAGE |
| 風蝕金砂 | WIND_ERODED_GOLD_SANDS | DESERT_DUNGEON | DESERT_VILLAGE |
| 赤焰火山 | CRIMSON_VOLCANO | VOLCANO_DUNGEON | VOLCANO_VILLAGE |
| 幽霧水澤 | MISTY_MARSH | MARSH_DUNGEON | MARSH_VILLAGE |
| 星晶浮島 | STARRY_CRYSTAL_ISLES | CRYSTAL_ISLAND_DUNGEON | CRYSTAL_ISLAND_VILLAGE |

The 12-map authority is data/fs_12_map_catalog.json. Every map has a stable ID, biome, dungeon/village role, independent scene path, milestone, art gate, native QA gate and provenance; NONE may be called playable or finished before real native validation.

## 1. ENGINE AND PROVENANCE
- Engine: **Godot 4.7.2** only, never return to RPG Maker VX for active development.
- Current tested first-map candidate: ELF_VILLAGE / 1280×928, original R8 R3 scene, 40×29 logical grid @32px. Full native source and nav PASS; 4+6 original GPU frames PASS; **ART HOLD**, not production release.
- Forest Dungeon high-density potential base: parallel A36C R6 / 2560×1856, 80×58@32, 310 trees/326 independent PAR. **Only source QA PASS**; native R6 render/physics/river obstruction not yet verified, so status SOURCE_ONLY_HOLD. Do NOT merge into playable directory before real private A36B R2 baseline and authentic R6 runtime PNG/physics pass.
- Source verified A36B R2 private ZIP: https://drive.google.com/file/d/15t5Yn6zdTC8vG1dOYrLmMEHGVYqjEjwO/view, 54,150,993 bytes SHA256 7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b. Parallel source branch feat/fs-godot-first-a29-20261113 (A36C R6). Keep branches intact.
- Original ELF_VILLAGE R8 R3 runtime release: https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view, 199,988,204 bytes, owner-only; 398 files, SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830.
- Maintain independent map-art branch. Never silently overwrite A36C parallel forest, combat implementation, older A35 scenes or other collaborators' branches.
- Complete binaries/PNGs/ZIPs only in owner-only Drive; GitHub stores text code, scene manifest, scripts, QA summaries and Handoff. Zero permanent remote-PC files outside connected Drive except installations/necessary temporary cache.

## 2. MAP LAYER CONTRACT (applies to all twelve)
This is **Ground-first**, not "generate one beautiful composited picture, then cut sprites out of it".
- **GROUND**: one continuous, natural terrain (grass, paths, soil, stone, sand, snow, shore, floor, flowers and WATER SURFACE pixels), rich enough to stand alone; initial Ground generally WALKABLE except water/chasm/hazard definitions. Ground does not contain houses, trees, lantern posts, rails, bridges or canopy shadows.
- **PAR**: independently generated, complete transparent RGBA objects (entire trees, houses, shops, bridges, rocks, cliffs, railings, elevated cover). Place each at a stable root footpoint. Never ship clipped building or split trunks, never allow arbitrary hard image seams. PAR visual occlusion is logically separate from collision physics.
- **SHADOW**: shadows on a separate layer or Godot LightOccluder2D, derived from actual whole-object trunk/foliage geometry; do not bake permanent dark holes into Ground. Polygon shadows and fill lights may be stylized; do not claim physically correct alpha light transmission.
- **LIGHT / ATMOSPHERE**: independent, phase-dependent day/dusk/night, lamp pools, Godot real PointLight2D and occluders. Avoid unintentional brightening of houses, smoke/fog flattening detail, moving particles interfering with pixel QA.
- **WATER / HAZARDS**: semantic mask + separate animation or shader. Water surface may be in Ground, but traversal/collision is separate. Elevated bridges require on-bridge/water-under and front/back testing. Vertical cliffs require 1–2 tile top occlusion where character moves behind a wall; hold until physically tested.
- **NAV / COLLISION**: actor footpoint vs obstacle footprint, 32px logical grid; lock protected access roads and doors; no blocking an otherwise walkable house-front tile; order YSort by foot Y, PAR can cover actor when entering behind object. Top canopy and collision do not share the same rectangular mask.
- **PIXEL QUALITY**: target high-fidelity HD-2D stylized 2D pixel scene. 1:1 authentic Godot rendering; avoid blur, resampling/blocky over-enlargement, over-repeated foliage, nonmatching cottage/ground styles, simplistic procedural tiles. Generated concept/reference PNGs cannot satisfy runtime QA.

## 3. REPEATABLE FACTORY, NOT TWELVE MANUAL REWRITES
1. Define map semantic blueprint: biome, purpose, traversal/door graph, paths/clearings/shore/hazard mask, intended camera extents, environmental palette, native 32px logic.
2. Produce **one coherent real Ground scene** with visually natural clustered grass/flower/rock variations, organic road edges, no visible tile repetition. Preserve standalone SHA.
3. Produce complete independently editable PAR for each object, 1x unified style, alpha bounds, provenance/license, anchor, logical footprint and semantic role.
4. Add landscape-specific SHADOW/LIGHT/WATER only after Ground/PAR composition; for snow, dune, lava, marsh and crystal islands, hazards/height differ, but layer contract does not.
5. Integrate in Godot 4.7.2 with Sprite2D/YSort/actor footpoint, independent 32px collision and full route graph. Include map-to-map exits and spawn positions later via gameplay/events workstream, without overwriting those systems.
6. QA **real source SHA/CRC, object count, α integrity, actual Godot 1x screenshots, real physical nav and actor behind/front, door/bridge/cliff rules, day/dusk/night performance, localized pixel ROI, art A/B**. Clear engine PASS vs ART HOLD separately.
7. Archive owner-only full source ZIP (not just derived images), SHA256 and size; GitHub code/manifest/Handoff/Failure Log; read back Google Drive exact ID and sharing. If Drive sync unconfirmed, mark PENDING, do not fabricate completion.
8. Only after **art pass and native QA** mark a map PRODUCTION_READY. Performance smoke tests measured from frame pacing must not be called isolated GPU throughput. Target sizes: validate 1280×928 prototype; then expand to full 2560×1856 80×58 via native high quality, NOT nonuniform nearest-neighbor enlargement.

## 4. ACTIVE PRODUCTION PRIORITIES / NO RESET
- **P0** Stabilize current ELF_VILLAGE R8 R3 (house light fixed in day/dusk/night; foliage R6 spikes and overall ART still HOLD). Clean and improve forest Ground3 grasses, paths and building/woods coherence in an additive scene only; preserve original R8 R3 Ground and avoid claiming final art prematurely.
- **P1** Bring separate A36C R6 large forest into true native Godot and full river/road/actor collision QA using verified private A36B R2 baseline; use as VERDANT_ELF_FOREST FOREST_DUNGEON only when it actually passes. Do not silently substitute old village Ground as forest dungeon.
- **P2** Once both first-biome maps meet real art/native contract, extract biome factory templates for paired town/dungeon building: snowfield→golden sands→volcano→mist marsh→star crystal islands. ALL 12 must remain in work queue; do not treat other biomes as vague stretch goals.
- **P3** Shared map traversal/world exits and sustainable content generation with real editor/test data. Story/NPC/combat systems remain their own engineering track.

## 5. FAILURE PREVENTION AND HANDOFF RULES
- No documents-only "progress"; require changed real files plus actual engine validation, or explicitly label source-only.
- Do not let a loop of 2-minute retouches replace advancing the next biome. ART HOLD is not a license for infinite texture touch-ups.
- Record for each build: baseline SHA, changed asset/masks/scene, Godot engine version, actual screenshot and test output, byte-identical preserved files, explicit failure list, next concrete blocking item, **12-map tracker** updated.
- If another branch may be newer, READ its current Handoff first and coordinate without overwriting.
- All six biome names and 12 map responsibilities fixed in catalog; do not forget the original goal when continuing chats.

**Definition of done: 12 playable, independently editable, cohesive HD-2D Godot maps, each ART PASS and native runtime PASS; not 12 filenames, not 12 pretty mockups, not 12 re-colored village clones.**
