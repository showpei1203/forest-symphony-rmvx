# Forest Symphony Map — Diorama Field Style DNA v2

Date: 2026-08-21
Project: Forest Symphony
Related: SHO-39
Status: CURRENT STYLE DNA FOR NEW MAP PRODUCTION

## 1. Purpose

This version preserves the visual/gameplay grammar proven in v1 while removing the requirement that a new map begin as a flattened Master Scene to be decomposed later.

Core rules:
- Learn the stage grammar. Do not copy the stage.
- Build the map from approved modular assets whenever practical.
- The user's final assembly is map geometry authority.

## 2. Evidence

Existing FS tilesets, accepted maps/scenes, Ground/Par references and accepted asset families remain valid evidence for:
- projection;
- world scale;
- palette;
- material language;
- object density;
- architecture/vegetation relationships;
- runtime occlusion behavior.

They are not geometry templates for new maps.

## 3. Core map identity

FS field/settlement maps should remain readable playable spaces rather than unrestricted concept paintings.

Common traits:
- clear playable footprint or navigable structure;
- high/top-down three-quarter RPG readability;
- visible front-facing wall/building/cliff faces where useful;
- readable movement space;
- denser decoration toward boundaries when appropriate;
- limited strong focal elements;
- exits/doors/bridges/stairs visually discoverable.

## 4. Visual hierarchy

Preferred order:
1. walkable Ground / route readability;
2. boundary / containment;
3. primary focal point or 1-3 moderate focal points;
4. large environment objects;
5. small props / vegetation accents;
6. lighting / shadow / atmosphere.

Decorative density must not destroy navigation readability.

## 5. Walkable negative space

Reserve coherent open movement areas before decoration.

Guidance:
- paths and walkable zones should remain continuous and obvious;
- repeated props should create rhythm, not accidental maze noise;
- ordinary filler should not compete with landmarks;
- visual clutter around characters should remain controlled at actual RMVX scale.

## 6. Perimeter / edge density

Boundary density may increase toward map edges using families such as:
- forest: trees, shrubs, rocks, cliff transitions;
- village: buildings, fences, stacked supplies, vegetation;
- castle/town: walls, towers, architecture, market props, gardens;
- dungeon: walls, machinery, crystals, channels, debris.

Perfect symmetry is not required.

## 7. Focal-point discipline

Preferred:
- one dominant landmark; or
- two to three moderate focal elements.

Hero assets are intentionally rare.

Ordinary architecture/vegetation/props should support rather than compete with the map's focal hierarchy.

## 8. Camera / projection DNA

Target:
- high top-down / three-quarter RPG view;
- floor layout clearly readable;
- enough visible vertical face for buildings, walls, cliffs and trunks;
- not strict side view;
- not pure flat bird's-eye plan;
- not cinematic perspective;
- not strict diamond-grid isometric unless separately approved.

All source asset families used together must share the same projection family.

## 9. World scale DNA

RMVX world-scale basis remains 32x32 px.

Use this as a relationship anchor rather than a hard maximum object size.

Prompt Contracts should express ordinary asset footprints in tile units, for example:
- small prop: fraction of a tile to roughly 1 tile;
- tree/bush family: several tiles as appropriate;
- building: multiple tiles;
- hero/landmark: unrestricted when map role justifies it.

Doors, stairs, path widths and walk-through openings must remain plausible relative to the player sprite.

## 10. Ground DNA

Ground is constructed from approved Base Terrain Sources and transition families.

Preferred:
- coherent material masses;
- readable contrast between route and surrounding terrain;
- subtle within-material variation;
- controlled irregular transitions;
- texture density that does not compete with characters.

Avoid:
- uniform high-frequency noise;
- embedded random hero objects in tileable terrain;
- obvious repeating central stamp patterns;
- terrain whose lighting implies a conflicting camera.

## 11. Modular object DNA

Normal map objects should exist as reusable families.

Examples:
- trees;
- rocks;
- shrubs;
- flowers;
- houses;
- fences;
- lamps;
- crates/barrels;
- signs;
- benches;
- market props.

Family rules:
- common material/camera/scale language;
- several useful silhouette variations;
- avoid near-duplicate filler;
- ordinary objects should tolerate repetition;
- map-specific variations may be added without regenerating the whole family.

## 12. Shared vs map-specific identity

Use shared biome assets where possible.

Map identity is created through:
- layout;
- architecture combinations;
- selected landmark(s);
- local palette accents;
- density patterns;
- map-specific props/vegetation where necessary.

Do not require every map to own a completely separate tree/crate/lamp library.

## 13. Asset isolation DNA

Source props/architecture/vegetation/landmarks should normally be isolated from the final scene.

Preferred output:
- transparent PNG;
- pure magenta chroma fallback when native transparency is unavailable.

Avoid:
- baked environment background;
- unrelated neighboring objects;
- oversized cast-shadow blobs;
- cropped silhouettes;
- soft halos around hard pixel assets.

## 14. Transition DNA

Terrain and structure transition families must connect predictably.

Examples:
- road edges;
- shores;
- cliffs;
- walls;
- fences;
- bridge ends;
- curbs/planters.

When a family needs modular topology, explicitly plan straight/corner/end/junction pieces rather than relying on ad-hoc cropping from a scene.

## 15. Lighting / atmosphere DNA

Lighting remains a supporting layer.

Source assets should usually use a compatible neutral/default light direction without baking scene-wide atmospheric effects.

After map assembly, dedicated light/shadow overlays may provide map-specific mood.

Do not use lighting to hide weak routes, bad scale or incompatible asset families.

## 16. Occlusion DNA

FS runtime may require Par/actor-covering overlays.

Under v2 production:
- source assets are authored first;
- user places the final objects;
- occlusion masks/Par derivatives are created from actual placements afterward.

Occlusion does not require the source object to originate inside a full-scene Master.

## 17. Concept image policy

A concept image is optional.

It may help communicate:
- mood;
- palette;
- density;
- landmark relationships;
- architectural direction.

It is not automatically:
- Ground authority;
- object-placement authority;
- asset source;
- mandatory decomposition target.

## 18. Failure conditions

Blocking failures include:
- `FAIL_STYLE_FAMILY_MISMATCH`
- `FAIL_CAMERA_FAMILY_MISMATCH`
- `FAIL_WORLD_SCALE_MISMATCH`
- `FAIL_WALKABLE_SPACE_UNREADABLE`
- `FAIL_CENTER_OVERCLUTTERED`
- `FAIL_BOUNDARY_UNCLEAR`
- `FAIL_TOO_MANY_FOCAL_POINTS`
- `FAIL_HERO_OBJECT_DOMINANCE`
- `FAIL_ASSET_FAMILY_INCONSISTENT`
- `FAIL_PROP_BACKGROUND_CONTAMINATION`
- `FAIL_TERRAIN_NOT_SEAMLESS`
- `FAIL_TRANSITION_CONNECTOR_MISMATCH`
- `FAIL_REQUIRES_REVERSE_EXTRACTION_FOR_CORE_ASSETS`

## 19. Success definition

A new FS map family passes Style DNA when:
1. it feels native to FS without copying an existing layout;
2. camera and world scale are coherent across terrain and objects;
3. traversal remains readable;
4. focal hierarchy is disciplined;
5. ordinary objects belong to reusable families;
6. terrain and transitions can be assembled cleanly;
7. map-specific assets add identity without replacing every shared asset;
8. the final map can be manually composed from the Asset Kit;
9. runtime occlusion/lighting can be derived after composition.

## 20. Version relationship

`FS_MAP_DIARAMA_FIELD_STYLE_DNA_V1.md` remains historical evidence.

All v1 visual/gameplay observations not contradicted here remain inherited.

V2 supersedes v1 only where v1 assumed a mandatory full-scene concept/master decomposition pipeline.