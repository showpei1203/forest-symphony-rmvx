# FS Map Asset Production Authority v3.0

Date: 2026-08-21
Project: Forest Symphony / RPG Maker VX
Status: CURRENT DEFAULT AUTHORITY FOR NEW MAP PRODUCTION
Related: SHO-39

## 1. Decision

Forest Symphony new-map production changes from a flattened-scene-first workflow to a modular asset-kit-first workflow.

Default new-map method:

`FS references -> Style DNA -> Asset Inventory -> modular asset generation -> QA -> Asset Kit -> user manual map assembly -> runtime derivatives -> RMVX acceptance`

The user is final layout/level-design authority.

AI is primarily an asset production system, prompt-engineering system and QA assistant.

## 2. Supersession scope

For NEW MAPS, this authority supersedes the production mechanics of:
- `FS_MAP_BENCHMARK_WORKFLOW_V1.md` Stage A-G flattened Master/decomposition path;
- `MAP_DUAL_OUTPUT_AUTHORITY_V2_9.md` and earlier v2.x as a mandatory default production path;
- old FS precheck wording that requires a Master + Ground + Complete PAR split for every new AI-authored map.

Those documents remain valid historical evidence and are retained for `Legacy Reconstruction Mode` when preserving an already-existing flattened Master.

No historical QA result is invalidated merely because the default future production workflow changed.

## 3. Rules explicitly preserved

The following remain authoritative:
- RMVX 32x32 world-scale basis for character/environment readability;
- high top-down / three-quarter RPG camera family;
- existing accepted FS tilesets/maps/scenes as style/scale/material evidence;
- do not copy existing scene geometry when designing a new map;
- pixel-crisp hard edges for normal pixel assets;
- no blur, soft smoothing or sub-pixel drift;
- Nearest Neighbor only for approved pixel-art resizing;
- map readability, walkable negative space, boundary readability and disciplined focal hierarchy;
- deterministic technical assembly when creating tilesheets/runtime derivative layers;
- Google Drive = binary/artifact authority;
- GitHub = text/source/manifest authority;
- Linear = work/status authority;
- Windows/RPG Maker VX = final runtime authority.

## 4. New source hierarchy

For new map production:

1. Existing FS tilesets and accepted scenes define visual/style/scale grammar.
2. Project Style DNA converts those observations into reusable rules.
3. Approved modular source assets become production art authority.
4. The user's assembled map becomes geometry/layout authority.
5. Runtime-specific Par/occlusion/light/shadow/collision are downstream derivatives.

A generated full-scene concept is optional reference material only unless the user explicitly promotes it into Legacy Reconstruction Mode.

## 5. Mandatory asset classes

New map inventories must distinguish:
- Base Terrain Source;
- Terrain / Structure Transitions;
- Vegetation;
- Architecture;
- Props;
- Hero / Landmark Assets;
- Runtime Derivatives.

The first six are source-production categories. Runtime Derivatives are produced after layout is stable.

## 6. Terrain authority

Base terrain should be authored as reusable seamless material sources.

AI should normally generate appearance/material, not RPG Maker VX autotile encoding.

Required principles:
- tileable source;
- no embedded buildings/props/characters;
- broad readable material zones;
- low enough micro-noise for a 32x32 actor to remain readable;
- edge repeat QA using 3x3 or larger preview;
- deterministic conversion/assembly into VX tiles/autotiles where required.

## 7. Transition / structure authority

Transition families must be planned as modular connector systems where appropriate.

Examples:
- terrain edges;
- road borders;
- shoreline;
- cliff top/face/corners;
- walls;
- fences;
- stairs;
- bridges;
- curbs/planter borders.

Connector geometry and thickness must remain consistent across the family.

## 8. Isolated asset authority

Ordinary objects are produced separately from the final map.

Preferred output order:
1. native transparent PNG;
2. pure `#FF00FF` chroma fallback;
3. pure `#00FF00` fallback when necessary;
4. white background only when unavoidable.

Ordinary assets must not contain accidental scene background, unrelated props, uncontrolled ground planes or cropped silhouettes.

Each accepted family must have a declared target footprint/scale range.

## 9. Hero asset authority

Landmarks are individually authored and QA'd.

They may be large but still inherit the same camera, pixel density, material language and world-scale relationships.

A landmark prompt must declare footprint, orientation/entrance and map role.

## 10. Reuse authority

Every asset must be classified as:
- `SHARED_BIOME`;
- `MAP_SPECIFIC`;
- `HERO`;
- `LEGACY_REUSE`.

Reusing an accepted ordinary asset is preferred to regenerating near-identical filler solely to create artificial uniqueness.

Map identity should primarily come from architecture combinations, landmark choices, layout, vegetation density, palette accents and deliberate map-specific assets.

## 11. Prompt Contract authority

Image generation for FS map assets must be driven by a Prompt Contract, not an untracked prose prompt.

Minimum Prompt Contract fields:
- asset/family ID;
- category;
- reference set;
- role;
- tile footprint / pixel envelope;
- perspective;
- silhouette rules;
- palette/material cues;
- variation axis;
- background/output mode;
- positive prompt;
- negative prompt;
- resolution;
- allowed postprocess;
- forbidden operations;
- QA checklist;
- status.

`FS_MAP_ASSET_PROMPT_WORKFLOW_V1.md` defines the standard contract and staged interaction.

## 12. Pilot-before-batch authority

Do not start a new family with a large blind batch.

First create a small pilot, visually accept/revise it, then scale production.

One accepted representative can become a style anchor for later family variants.

Rejected outliers do not redefine the family.

## 13. Technical asset gate

Before an asset enters the production kit:
- PNG format;
- explicit integer dimensions;
- scale/perspective pass;
- no accidental resampling;
- nearest-neighbor-only if resized;
- no unwanted crop;
- background/alpha cleanup pass;
- hard pixel-art structural assets normally use binary alpha;
- no chroma fringe;
- no contextual background contamination;
- naming/manifest stable.

## 14. Manual assembly authority

The user controls:
- final map geometry;
- placement;
- route design;
- density;
- focal hierarchy;
- object reuse;
- editor integration.

AI must not silently move, scale, redraw or reinterpret already accepted/placed assets.

Final assembly must still obey FS camera and world-scale rules.

## 15. Runtime layer authority

Source production and runtime rendering are separate concerns.

After the map is assembled:
- Par/actor-occlusion may be derived from actual placed objects;
- light/shadow overlays may be generated/painted;
- collision/passability/event/transfer metadata may be authored;
- deterministic masks or compiler operations are preferred when source art does not need to change.

Historical Ground/PAR rules remain available when a specific runtime profile or legacy map requires them, but they do not force new source assets to originate from a flattened Master.

## 16. Master Scene policy

`Master Scene` is redefined for new production as optional `Concept / Mood / Composition Reference`.

It may be used to explore:
- palette;
- density;
- architecture relationships;
- landmark mood;
- biome identity.

It is not automatically:
- pixel geometry authority;
- Ground authority;
- PAR authority;
- mandatory decomposition source;
- required for a map to proceed.

## 17. Legacy Reconstruction Mode

Use this only when the user explicitly wants to preserve/recover an already-existing flattened Master.

Then `MAP_DUAL_OUTPUT_AUTHORITY_V2_9.md` and its inherited v2.x rules remain applicable, including:
- Ground/PAR semantics;
- Master-exact owner extraction where required;
- deterministic coordinates;
- binary alpha;
- overlap/ownership QA;
- Ground remnant/restoration QA;
- recomposition to Master.

Current Castle Town extraction artifacts remain valid historical/recovery work. Continuing that extraction is no longer the default next step.

## 18. Existing Style DNA interaction

Existing Style DNA remains active unless directly contradicted by production mechanics.

In particular, preserve:
- high/top-down 3/4 readability;
- contained-stage grammar when relevant;
- clear traversable space;
- increased perimeter density where appropriate;
- controlled focal points;
- coherent broad Ground material masses;
- repeated asset families rather than every object being a unique hero.

A new Style DNA version may rewrite old decomposition wording without discarding these visual rules.

## 19. New-map PASS definition

A new-map production workflow passes when:
1. Reference Set and Style DNA are explicit.
2. Asset Inventory is complete enough for the intended map.
3. Required terrain/transition/prop/architecture/vegetation/hero families have accepted production assets.
4. Technical normalization and naming/manifest are stable.
5. The user can assemble the map without reverse-extracting missing core assets from a flattened concept scene.
6. Assembled map passes actual-scale visual QA.
7. Required runtime derivatives are produced from the stable assembly.
8. RPG Maker VX traversal/occlusion/runtime acceptance passes.

## 20. Authority priority

For FS new-map asset production after 2026-08-21:

1. Later explicit FS production authority, if any.
2. `FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_0.md`.
3. `FS_MAP_ASSET_PROMPT_WORKFLOW_V1.md`.
4. current FS Style DNA.
5. shared asset-generation authority for non-conflicting global rules.
6. historical map extraction / dual-output documents only when Legacy Reconstruction Mode is explicitly active.