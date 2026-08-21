# FS Elf Forest Village Style DNA v1

Date: 2026-08-21
Status: STAGE 2 LOCKED CANDIDATE
Reference Set: `FS_REFSET_ELF_FOREST_VILLAGE_V1`
Workflow: `FS Map Asset Prompt Workflow v1`

## Scope
This converts the locked FS reference set into production rules for a medium-large forest elf village. It is style/scale/material authority for asset generation, not final map layout authority.

## Evidence basis
Core scenes:
- `SCENE001.png`: village-scale wooden architecture, well/fence/sign/crate/barrel/log props, warm path/grass balance, readable central clearing.
- `SCENE21.png`: sacred woodland mood, vegetation-integrated architecture, moss/green roof language, mixed broadleaf/conifer planting, floral edge density.
- `SCENE03.png`: grass/water bank language, low elevation transitions, natural path and edge treatment.
- `SCENE06.png`: woodland containment, repeated tree family, dense perimeter vegetation and readable central negative space.

Core tilesets:
- `TileB.png`: exterior wooden architecture, doors/windows/roofs, wells, signs, common village structure language.
- `TileD.png`: primary vegetation, broadleaf/conifer trees, bushes, flowers, logs, rocks, rustic outdoor materials.
- `TileE.png`: exterior roofs, bridges, elevated wooden structures, stone/wood connector grammar.

## Camera / projection
- RMVX world-scale basis: 32x32 px.
- High top-down / three-quarter RPG camera.
- Ground plan remains readable while front/side vertical faces of buildings, trunks, cliffs and platforms remain visible.
- No strict diamond-grid isometric.
- No low-angle cinematic perspective.
- No pure bird's-eye plan.
- No strong vanishing-point convergence.
- Favor clear front/down-facing entrances compatible with ordinary RMVX traversal.

## Production scale envelopes
These are production envelopes inferred from the locked references, not collision boxes or exact historical source dimensions.
- Door/entrance: ~1 tile wide; visible treatment ~1.5-2 tiles high where architecture requires.
- Small ordinary house: ~3-5 tiles visual width, ~3-5 tiles visual height including roof.
- Medium house/shop/inn module: ~5-8 tiles visual width, ~4-7 tiles visual height including roof/signage.
- Common tree: ~2-3 tiles visual width, ~2.5-4 tiles visual height.
- Large accent tree: ~3-4 tiles width, ~4-6 tiles height.
- Sacred/Hero tree may exceed 4 tiles width and 6 tiles height but must retain the same camera/trunk/world scale.
- Bush/shrub: ~0.5-1.5 tiles wide.
- Small props: ~0.5-1.5 tiles per main dimension.
- Main walk path: ~2-4 tiles wide in frequent traversal zones.
- Minor path: ~1-2 tiles.
- Small bridge: ~2-4 tiles clear traversable width depending on role.
- Treehouse platform family: ~3-5 tiles wide before attached canopy/roof; entrance/access/support logic must remain readable.

## Silhouette
- Major objects need strong silhouettes at 100% game scale.
- Roof ridges, trunks, rails and doorway openings stay distinct.
- Do not replace readable form with dense 1-2 px noise.
- Ordinary props remain subordinate to architecture and Hero assets.
- Tree variants share family language while varying canopy contour/branch spread/asymmetry.
- Elf architecture may integrate foliage/roots but must still read as usable architecture.

## Materials
Primary family:
- warm weathered timber;
- medium/dark brown structural wood;
- mossy/olive/forest-green roof and plant integration;
- weathered gray-to-warm-gray stone;
- lush medium-to-bright green foliage;
- warm tan/ochre earth paths;
- restrained blue-green water.

Elf-specific variation may add carved timber, pale stone, leaf/moss roof accents and limited magical ornament while staying within the existing FS family.

## Palette
- Broad green foliage range from yellow-green highlights to deeper blue/forest greens.
- Warm tan/ochre paths separated clearly from grass without extreme contrast.
- Warm brown wood with darker structural outlines.
- Gray/brown-gray stone, not cold metallic gray.
- Flowers provide small high-saturation white/yellow/blue/pink/purple accents concentrated near edges and landmarks.
- Strongest magical saturation is reserved for Map-Specific/Hero assets.
- Avoid neon grass, cyan-heavy stone and uniformly oversaturated foliage.

## Pixel / edge
- Pixel-crisp mandatory.
- No blur, soft smoothing, feathered silhouette or sub-pixel shift.
- No broad semi-transparent fringe.
- Nearest Neighbor only for approved resize.
- Transparent PNG preferred.
- Chroma fallback: `#FF00FF` primary, `#00FF00` secondary; remove all fringe.
- Internal shading may remain detailed/pixel-dithered, but outer silhouette must stay clean.

## Texture density
- Local texture detail is allowed on bark/shingles/stone/foliage, but readability wins.
- Perimeter may be dense; central paths/plazas/traversal zones should be quieter.
- Avoid fixed-interval microtexture stamps.
- Terrain source must support 3x3 tiling without seam or central motif.

## Lighting / shadow
- Soft daylight with mild upper-left/top bias compatible with the reference family.
- Reusable props do not bake long directional cast shadows into surrounding empty space.
- Tight contact shadow only when inseparable from the object.
- Global light/shadow remains a downstream runtime derivative after manual mapping.

## Vegetation
- Mix broadleaf and conifer families.
- Layer forest edge as canopy/tree -> bush/shrub -> grass/flowers -> path/clearing.
- Common trees are `SHARED_BIOME`.
- Flowers/small plants cluster more strongly near edges, structures and focal points than in central walk zones.
- Logs/rocks/stumps break repetition but should not clog every path.

## Architecture
Ordinary village architecture:
- readable steep/triangular roof forms;
- warm timber frame;
- stone/timber base where appropriate;
- doors/windows separated from decoration;
- moderate asymmetry and plant integration permitted.

Elf-specific architecture:
- inherits FS wood/stone scale and camera;
- may use curved/carved timber, moss/leaf roof, roots/trunk support, elevated/suspended platforms and organic railings;
- avoid generic white-marble palace language;
- avoid MMO-scale oversized buildings;
- treehouses are `MAP_SPECIFIC` and need readable platform, entrance/access and support logic.

## Bridge / river
- River remains readable terrain; bank transitions remain separate from bridge structure.
- Bridge follows modular wood/stone connector language from TileE/TileD.
- Rails/supports must not overwhelm deck readability.
- Minimum bridge family: straight section + usable end connection; other connectors only when map intent requires.

## Sacred Tree / Hero
- Central Sacred Tree is `HERO`, not merely an ordinary tree enlarged with random glow.
- Identity comes from breadth, roots, canopy architecture, carved/natural focal details and restrained magical accents.
- It may dominate ordinary buildings but may not change camera/rendering style.
- Avoid photorealism, neon glow dominance, cinematic perspective and soft concept-art edges.

## Manual composition grammar
- Dense decorative containment near map edges.
- Clear negative space and traversable lanes through the village center.
- One dominant Hero focal point plus secondary functional nodes such as inn/shop/bridge/treehouse cluster.
- Paths visually connect functional buildings.
- Vegetation reinforces space instead of occupying every unused tile.

## Allowed variation axes
Trees: canopy width/shape, leaf hue within family, trunk lean/branch exposure, limited flower/moss attachment.
Houses: roof length/pitch, windows, porch/sign/planter attachment, restrained moss/ivy coverage.
Props: minor silhouette/wear/content/accessory variation.
Variation may not change camera, world scale or material family.

## Forbidden traits
- strict isometric diamond grid;
- low-angle side/cinematic perspective;
- photorealism or soft-focus painterly concept art;
- anti-aliased blurry silhouette;
- giant architecture inconsistent with 32px world scale;
- unreadable ultra-thin detail;
- neon magical palette dominating the entire map;
- modern/industrial/sci-fi props;
- full scene/ground baked into isolated props;
- long uncontrolled shadow blobs;
- unrelated architectural eras;
- copying exact geometry from an existing scene;
- `SCENE20` crystal-industrial dungeon language.

## Asset-family priority
`SHARED_BIOME`: common broadleaf, conifer, shrubs, flowers/grass clusters, rocks/logs/stumps, basic forest ground.

`LEGACY_REUSE` candidate: compatible rustic props and wooden village details that pass current scale/style QA.

`MAP_SPECIFIC`: elf treehouse family, elf shop/inn identifiers, elf bridge accents, carved signs/lamps/railings.

`HERO`: central Sacred Tree.

## Core negative language
`photorealistic, realistic 3D render, low-angle perspective, cinematic perspective, strict isometric diamond grid, blurry edges, anti-aliased silhouette, soft focus, painterly concept art, oversized architecture, tiny unreadable details, neon colors, modern objects, sci-fi objects, industrial machinery, full background scene, unrelated props, cropped silhouette, uncontrolled cast shadow, text, UI`

## Stage 2 gate
Stage 2 passes when future asset prompts can cite this DNA without reinterpreting camera, scale, palette, material, edge treatment and main silhouette rules per asset.

No image generation is authorized yet.

NEXT: Stage 3 — Map Intent Brief for the medium-large Forest Elf Village.
