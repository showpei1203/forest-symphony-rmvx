# FS Map Asset Prompt Workflow v1

Date: 2026-08-21
Project: Forest Symphony / RPG Maker VX
Status: CURRENT DEFAULT NEW-MAP PRODUCTION WORKFLOW
Related: SHO-39

## 1. Core production rule

For NEW Forest Symphony maps, AI does not author the final map by default.

AI manufactures reusable, style-consistent, scale-controlled map parts. The user performs final layout, placement, composition and editor integration.

Default flow:

`Reference Set -> Style DNA -> Map Intent Brief -> Asset Inventory -> Prompt Contracts -> Pilot Generation -> QA/Revision -> Production Batch -> Technical Normalization -> Asset Kit -> Manual Mapping -> Runtime Derivatives -> RMVX Acceptance`

A full flattened Master Scene is optional concept/reference material only. It is not required and is not the default asset source.

## 2. Authority preserved from existing FS rules

The following remain mandatory unless a later explicit FS authority changes them:
- RPG Maker VX world-scale basis: 32x32 px tile/player readability reference.
- High top-down / three-quarter RPG projection.
- Enough downward angle to read floor layout and enough visible vertical face to read buildings, walls, cliffs and trunks.
- Not strict side view, not pure bird's-eye plan, not cinematic perspective, not strict diamond-grid isometric unless specifically approved.
- Pixel-crisp output; no blur/soft smoothing/sub-pixel drift.
- Nearest Neighbor only when resizing accepted pixel-art assets.
- Existing FS tilesets and accepted village/scene references are style, scale, palette, material and stage-grammar evidence. They are not geometry templates to copy.
- Final playable map must preserve readable walkable space, clear boundaries, disciplined focal hierarchy and FS character/environment scale.

## 3. Reference Set stage

Before writing generation prompts, select a small explicit reference set from Drive.

Preferred reference roles:
1. existing FS tileset(s): tile density, palette, material language and pixel treatment;
2. 2-5 representative FS village/field/settlement scenes: camera, object scale, density and composition grammar;
3. already accepted asset-family examples when available;
4. optional map-specific concept image for mood only.

Do not use every available scene at once. Conflicting reference families must be separated before prompt construction.

Output of this stage:
- `Reference Set ID`
- file names / IDs
- role of each reference
- excluded references and why

No image generation is required in this stage.

## 4. Style DNA stage

Extract or update a Map Asset Style DNA before asset production.

Required fields:
- camera / projection;
- 32x32 world-scale interpretation;
- character-to-door / tree / building relationships;
- palette and saturation tendencies;
- material language;
- edge / outline treatment;
- lighting assumptions for source assets;
- texture density;
- silhouette preferences;
- allowed variation range;
- forbidden visual traits.

Style DNA describes visual grammar. It must not encode the exact geometry of an existing map.

## 5. Map Intent Brief

Before asset inventory, define the map role.

Required fields:
- map/biome name;
- gameplay role;
- settlement / field / dungeon / landmark type;
- expected player movement pattern;
- approximate map scale;
- dominant materials;
- architecture family;
- vegetation family;
- 0-3 focal landmarks;
- mood / lighting direction;
- exits / major route needs;
- reuse target: shared-biome assets vs map-specific assets.

The Map Intent Brief is planning metadata, not an image prompt.

## 6. Asset categories

### A. Base Terrain Source

Examples:
- grass / dark grass / moss;
- dirt / mud / sand;
- stone / plaza / road / floor;
- shallow/deep water source textures;
- snow / rock floor / cave floor.

Rules:
- Generate a clean seamless source texture first.
- `seamless`, `tileable on all edges`, and `no focal object` are mandatory prompt concepts.
- AI is not required to directly output a valid RPG Maker VX autotile sheet/quadrant layout.
- Approved source art may later be assembled deterministically into VX tiles/autotiles.
- Prefer broad readable texture clusters and low micro-noise.
- Validate with at least a 3x3 repeat preview.

### B. Terrain / Structure Transition Kit

Examples:
- grass-to-dirt edges;
- road edges;
- shore / bank transitions;
- cliff top / cliff face / corners;
- wall modules;
- fences;
- stairs;
- bridges;
- curb / planter / flowerbed borders.

For modular families, plan connector topology where appropriate:
- straight;
- inner corner;
- outer corner;
- end/cap;
- T/cross/junction if gameplay requires it.

Generate source appearance first; deterministic tile-sheet assembly is preferred over asking an image model to infer RPG Maker autotile encoding.

### C. Isolated Props

Examples:
- trees / bushes / rocks;
- houses / shops / minor buildings;
- crates / barrels / carts;
- lamps / benches / signs;
- wells / market stalls / furniture;
- fences and small structures.

Output priority:
1. native transparent PNG;
2. pure `#FF00FF` chroma-key background fallback;
3. pure `#00FF00` only when magenta conflicts;
4. white background only as last resort.

Rules:
- one isolated asset or clearly declared variation sheet;
- no contextual scene;
- no ground plane baked behind the prop;
- no unrelated props;
- no uncontrolled cast-shadow blob outside the intended asset footprint;
- transparent/chroma border margin around silhouette;
- batch by family, not by random mixed category.

### D. Hero / Landmark Assets

Examples:
- castle;
- gatehouse;
- windmill;
- chapel / shrine;
- sacred tree;
- monumental statue / fountain;
- unique dungeon entrance.

Rules:
- individually specified footprint and entrance/orientation;
- one-off QA rather than large blind batches;
- separate environment/background from the object;
- preserve readable doors, stairs and contact points at RMVX scale;
- landmarks may be larger than standard props but must use the same camera and material language.

### E. Runtime Derivatives

These are downstream of map composition:
- Par / actor-occlusion overlays;
- light overlay;
- shadow overlay;
- collision/passability metadata;
- event/transfer anchors.

Do not force source-asset generation to solve final runtime occlusion before the user has placed the asset in the map.

## 7. Shared Biome Library vs Map-Specific Kit

Every asset inventory must classify each item as one of:
- `SHARED_BIOME`: intended for reuse across maps of the same biome/family;
- `MAP_SPECIFIC`: created for the current map identity;
- `HERO`: intentionally unique;
- `LEGACY_REUSE`: existing approved FS asset reused without regeneration.

Reuse is preferred when visual and scale fit are already good. Do not regenerate ordinary trees, crates or lamps merely to make each map artificially unique.

## 8. Asset Inventory stage

Before generation, produce the complete inventory with at least:
- Asset ID;
- category;
- family;
- reuse class;
- priority;
- target footprint in 32x32 tile units;
- expected variations;
- source reference set;
- background/output mode;
- notes on modular connections.

Prioritize the smallest set needed to prove the map style before large batches.

Recommended pilot order:
1. 2-3 Base Terrain materials;
2. 1 Transition family;
3. 1 vegetation family;
4. 1 architecture family;
5. 1 small-prop family;
6. 1 Hero asset only if the map needs one.

## 9. Prompt Contract

Every generated asset/family must have a Prompt Contract. Required fields:

1. `Asset ID / Family ID`
2. `Category`
3. `Map / Biome`
4. `Reference Set`
5. `Use Case`
6. `Target Footprint` in tiles and approximate pixels
7. `Perspective Rule`
8. `Silhouette Rule`
9. `Palette / Material Cues`
10. `Variation Axis`
11. `Background / Alpha Mode`
12. `Positive Prompt`
13. `Negative Prompt`
14. `Output / Source Resolution`
15. `Allowed Postprocess`
16. `Forbidden Operations`
17. `QA Checklist`
18. `Status`: DRAFT / PILOT / ACCEPTED / REJECTED / SUPERSEDED

The user should normally request a task in these terms; ChatGPT translates it into the detailed generation prompt.

## 10. Base Terrain prompt skeleton

Positive skeleton:

`top-down / high three-quarter pixel-art seamless [MATERIAL] terrain texture for a fantasy RPG map, Forest Symphony visual language, compatible with 32x32 world-scale readability, broad readable texture clusters, controlled low micro-noise, restrained contrast, tileable on all four edges, no focal object, no border, no perspective drift, pixel-crisp`

Negative skeleton:

`character, building, tree, prop, isolated object, cast-shadow blob, vignette, frame, text, UI, photorealistic texture, strict isometric projection, blurry pixels, soft focus, anti-aliased painterly edge, obvious repeating emblem`

Required QA:
- 3x3 repeat has no visible seam;
- no obvious central stamp/repeating hero feature;
- texture remains readable behind a 32x32 character;
- palette fits reference tileset;
- no objects embedded in the terrain.

## 11. Isolated Prop prompt skeleton

Positive skeleton:

`isolated [ASSET], high top-down three-quarter fantasy RPG pixel art, Forest Symphony visual language, designed for 32x32 tile world scale, target footprint approximately [W x H] tiles, readable silhouette at RPG Maker VX scale, [MATERIAL / PALETTE CUES], consistent light direction, pixel-crisp, no environment context, transparent background`

Chroma fallback suffix:

`isolated on a perfectly flat pure #FF00FF background, no magenta inside the object, no background gradient, no shadow outside the intended object silhouette`

Negative skeleton:

`complete scene, landscape background, ground plane, character, extra unrelated props, cropped silhouette, strict isometric projection, cinematic perspective, photorealism, blur, painterly antialiasing, glow halo, soft feathered edge, text, UI`

Required QA:
- scale and perspective match reference set;
- silhouette is not clipped;
- no contextual background contamination;
- transparent/chroma cleanup is clean;
- family variation remains recognizably the same asset family.

## 12. Transition prompt skeleton

Positive skeleton:

`modular [TRANSITION / STRUCTURE] segment, high top-down three-quarter fantasy RPG pixel art, Forest Symphony visual language, compatible with 32x32 tile logic, designed to connect [A] to [B], [STRAIGHT / INNER CORNER / OUTER CORNER / END CAP], clear connector geometry, consistent thickness and material, pixel-crisp, isolated source artwork`

Negative skeleton:

`complete map, random building, character, unrelated prop, inconsistent wall thickness, perspective drift, diagonal isometric grid, photographic texture, blur, soft halo`

Required QA:
- connector thickness and height match family;
- neighboring pieces can be assembled without visible scale jumps;
- orientation is explicit;
- terrain/structure semantics are known before editor integration.

## 13. Hero Asset prompt skeleton

Positive skeleton:

`isolated [HERO ASSET], high top-down three-quarter fantasy RPG pixel art, Forest Symphony visual language, target footprint approximately [W x H] 32x32 tiles, [ENTRANCE / FACING] orientation, clear readable architecture, visible ground-contact logic, [MATERIAL / PALETTE], landmark silhouette without cinematic perspective, pixel-crisp, transparent background, no surrounding scene`

Negative skeleton:

`full town scene, surrounding houses, terrain background, character crowd, cinematic camera, strict isometric projection, photorealism, cropped entrance, soft blurred outline, text, UI`

## 14. Pilot Generation stage

Do not begin with a huge batch.

Default guidance:
- style calibration: 2-4 test outputs;
- family pilot: 3-6 meaningful variations;
- after acceptance, production batch: usually 6-12 per family when the category benefits from repetition.

Numbers are guidelines, not hard requirements. Hero assets normally use fewer candidates.

Only change one or two prompt variables per revision when diagnosing style drift.

## 15. Visual QA gate

Every pilot/production candidate is checked for:
- FS style-family match;
- camera/projection match;
- 32x32 world-scale plausibility;
- footprint plausibility;
- readable silhouette at 100% game scale;
- palette/material fit;
- texture-density fit;
- no accidental focal dominance for ordinary props;
- no unrelated scene/background content;
- no geometry copied from a legacy map.

Possible outcomes:
- `ACCEPT`;
- `ACCEPT_WITH_TECH_CLEANUP`;
- `REGENERATE_PROMPT_REVISION`;
- `REJECT_STYLE`;
- `REJECT_SCALE`;
- `REJECT_PERSPECTIVE`;
- `REJECT_CONTAMINATION`.

## 16. Technical QA / Normalization gate

Before entering the Asset Kit:
- file is PNG;
- dimensions are explicit integer pixels;
- no accidental resampling;
- Nearest Neighbor only for approved pixel-art resizing;
- transparent props have clean silhouette and adequate transparent margin;
- chroma-key removal has no magenta/green fringe;
- binary alpha `{0,255}` is preferred for hard pixel-art assets;
- partial alpha is allowed only for an explicitly approved effect class;
- no clipped edge unless the asset contract intentionally defines a tileable edge;
- no hidden background plane;
- naming and metadata match manifest.

## 17. Batch consistency QA

A family batch must be evaluated together.

Check:
- same species/material/architecture language;
- same camera;
- same pixel density;
- same scale family;
- variation is meaningful without becoming a different art style;
- reject near-duplicates that add no mapping value;
- reject outliers instead of warping the accepted family around them.

One accepted representative may become the style anchor for later family generations.

## 18. Asset Kit structure

Recommended logical structure:

`MapAssetKit/<BiomeOrMap>/`
- `00_References/`
- `01_BaseTerrain/`
- `02_Transitions/`
- `03_Vegetation/`
- `04_Architecture/`
- `05_Props/`
- `06_Landmarks/`
- `07_RuntimeDerivatives/`
- `08_Previews/`
- `09_Manifests/`

This is a logical standard. Do not destructively reorganize existing Drive assets only to match folder aesthetics.

## 19. Naming

Recommended:

`FS_MAP_<MAP>_<CATEGORY>_<FAMILY>_<NN>_V<version>.png`

Examples:
- `FS_MAP_ELF_VILLAGE_PROP_LAMP_01_V1.png`
- `FS_MAP_CASTLE_TOWN_ARCH_HOUSE_A_03_V1.png`

Shared terrain may use:
- `FS_TERRAIN_FOREST_GRASS_A_V1.png`
- `FS_TERRAIN_TOWN_STONE_ROAD_A_V1.png`

## 20. Manual Mapping stage

The user is the final level designer.

Rules:
- accepted asset pixels are not moved/rescaled/reinterpreted by AI after placement unless the user requests it;
- user controls final geometry, route design, spacing, object density and composition;
- editor placement should respect the 32x32 world scale and the accepted asset footprints;
- repeated props may be mirrored/varied only when visually and technically safe;
- tileset/base terrain, transparent props and manual edits may coexist;
- the map should be visually checked at actual RMVX scale, not only enlarged preview scale.

## 21. Runtime derivative stage

After layout is assembled:
- derive any required Par/occlusion overlay from actual placed objects;
- derive light/shadow overlays only after geometry is stable;
- derive collision/passability and transfer/event anchors from the assembled map;
- do not regenerate source art merely to fix runtime layer semantics if a deterministic mask/metadata operation is sufficient.

## 22. Runtime acceptance

Test with a real actor in RMVX.

Required checks:
- scale feels correct relative to the character;
- routes and exits are readable and traversable;
- doors/stairs/bridges align with movement logic;
- no invisible-wall or accidental-opening mismatch;
- occlusion occurs only where intended;
- no doubled props or Ground/Par ghosts;
- no visible terrain seams;
- repeated assets do not create obvious stamp patterns;
- lighting/shadow does not hide navigation.

## 23. Master Scene policy

A generated full-scene Master/Concept image is OPTIONAL.

If used:
- it is a mood/composition reference;
- it may guide palette, density, landmark relationship and architectural language;
- it is not mandatory geometry authority;
- it is not required to be decomposed;
- it must not force a new map into the old `Master -> Ground/PAR extraction` pipeline.

For already-existing flattened Masters that the user specifically chooses to salvage, use `Legacy Reconstruction Mode` under the historical MAP_DUAL_OUTPUT authority.

## 24. Legacy Reconstruction Mode

Use only when explicitly working from an already-existing flattened Master whose composition must be preserved.

Then historical rules such as:
- Master-exact extraction;
- binary alpha;
- deterministic placement;
- Ground/PAR semantic reconstruction;
- recomposition against Master;
remain applicable.

This mode is not the default production method for new maps.

## 25. User-to-ChatGPT working prompt template

The user may issue a concise task such as:

`Use the current FS Map Asset Workflow and the Drive reference set for <map>. Do not generate yet. First update the Style DNA, produce the complete Asset Inventory, classify SHARED_BIOME vs MAP_SPECIFIC vs HERO, and choose the first pilot batch.`

Then:

`Now process only <category/family>. Produce Prompt Contracts with target tile footprint, positive prompt, negative prompt, background mode, variation count and QA gate. Do not generate unrelated categories.`

Then after images exist:

`Audit this batch against the accepted FS reference set and Prompt Contract. Classify ACCEPT / CLEANUP / REGENERATE / REJECT and rewrite only the failed prompt variables.`

The user should not need to hand-author complex English generation prompts; ChatGPT owns prompt engineering and QA translation.

## 26. PASS definition for a production-ready map kit

A map kit is ready for manual mapping when:
1. its reference set and Style DNA are explicit;
2. required terrain sources and transition families pass their own QA;
3. required prop/architecture/vegetation families have accepted candidates;
4. hero assets, if any, pass individual scale/perspective QA;
5. technical normalization is complete;
6. names/manifests are stable;
7. user can assemble the intended map without needing to reverse-extract missing basic parts from a flattened scene.

That final condition is the key scalability gate.