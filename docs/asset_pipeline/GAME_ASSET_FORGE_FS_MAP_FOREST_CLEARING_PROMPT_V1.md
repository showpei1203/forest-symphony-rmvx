# Game Asset Forge Prompt — FS Map Forest Clearing v1

Use this prompt for the first NEW-map benchmark.

## Recommended generation settings

- Model/action: PixelLab Pixflux whole-image generation (`createPixelArtImage` / `create-image-pixflux`)
- Canvas: `272×208`
- Background: opaque / no transparency
- View: high top-down / three-quarter RPG readability if the action exposes view control
- Isometric: false unless testing proves otherwise
- Detail: medium to detailed, but gameplay readability has priority
- Output count: generate multiple candidates with different seeds rather than repeatedly editing one bad composition

Do not attach a legacy FS map as the dominant init image for the first originality benchmark.

## Prompt

```text
Create one NEW original pixel-art RPG field map for Forest Symphony.

MAP FAMILY:
ordinary woodland transition / forest clearing.

ROLE:
normal exploration map used during regular gameplay.

This is NOT:
- a sacred grove
- a boss arena
- a cinematic set piece
- a landmark shrine
- a village center
- a giant ancient-tree scene
- a magical ritual location

The map should feel like one normal field in the Forest Symphony world and should be suitable for repeated exploration gameplay.

CAMERA AND STAGE LANGUAGE:
- high top-down / three-quarter classic RPG view
- readable floor layout
- visible vertical faces on raised edges, cliffs, trunks or structures when appropriate
- contained diorama-like playable field
- wider-than-tall composition
- one cohesive irregular stage footprint
- not strict geometric isometric diamond grid
- not flat schematic bird's-eye map
- not cinematic perspective

PLAYABLE SPACE:
- preserve a large clear central or near-central movement area
- roughly half or more of the main playfield should read as traversable open ground or path
- the player should immediately understand where movement is possible
- keep the center calmer than the perimeter
- do not scatter obstacles evenly across the entire map

ROUTE STRUCTURE:
- include two clearly readable route openings / exits on different sides of the field
- routes should connect through the clearing naturally
- paths can curve or widen organically
- exits must remain visually discoverable
- do not create confusing decorative dead-end maze noise

BOUNDARY:
Use natural woodland containment around the perimeter:
- standard broadleaf trees
- occasional conifers if visually compatible
- shrubs
- low flowers / grasses
- small rocks
- modest raised earth / stone edges where useful

Boundary density should be higher than central density.
The perimeter should frame the player space rather than dominate it.

TREES:
- use normal reusable forest trees
- no giant hero tree
- no sacred ancient tree
- no uniquely twisted fantasy tree
- trees should form environmental groups and edge framing
- do not make every tree a different showcase design
- vary size and placement subtly so the forest feels natural

GROUND:
- natural grass as the primary material
- worn dirt / earth route through the clearing
- broad readable material zones before tiny decorative texture
- subtle patches of darker/lighter grass
- controlled small flowers / weeds near edges
- keep main walking area readable
- no texture noise covering every pixel

FOCAL HIERARCHY:
This is a standard field map.
Use either no major focal object or one modest environmental focal element only.
Examples:
- a small weathered signpost
- a simple stump
- a small stone marker
- a tiny shallow puddle

Any focal prop must remain secondary to navigation.
Do not add a chapel, shrine, giant statue, magical crystal, monument, huge tree, elaborate ruin or story centerpiece.

OBJECT DENSITY:
- high around outer edges
- medium in transition zones
- low in core walkable area
- small props should occur in clusters, not uniform random scatter
- leave breathing room around exits and central routes

VISUAL STYLE:
- cohesive classic RPG pixel art
- natural Forest Symphony environment feeling
- crisp pixel clusters
- moderately detailed parallax-style environment
- readable value grouping
- restrained saturation
- no painterly blur
- no photorealism
- no modern concept-art rendering
- no glowing fantasy treatment

LIGHTING:
- soft natural daylight
- simple upper-side light direction
- enough shadow to separate trees, rocks and raised edges
- no cinematic spotlight
- no bloom
- no dramatic god rays

COMPOSITION ORIGINALITY:
Invent a new layout from scratch.
Do not recreate the geometry, object placement, paths, focal points or silhouette of any existing Forest Symphony scene.

The goal is to share the same MAP GRAMMAR, not the same MAP.

OUTPUT REQUIREMENTS:
- exactly one complete map image
- no characters
- no enemies
- no text labels
- no UI
- no title card
- no decorative border
- no separate asset sheet
- no transparency

ENGINEERING INTENT:
This image is a Concept / Master Scene candidate.
It must be visually decomposable later into:
- ground material zones
- reusable tree / rock / plant Master Objects
- route / exit metadata
- occlusion objects
- Ground / Par render outputs

Do not bake so many overlapping unique objects together that later decomposition becomes impossible.

FINAL TARGET:
A clean, original, restrained Forest Symphony woodland clearing that looks like a normal playable field from the same game world, with obvious walkable space, strong perimeter framing, two readable exits, disciplined decoration, and no landmark-level object.
```

## Negative block

```text
Avoid:
sacred grove, boss arena, ancient giant tree, hero tree, giant roots, shrine, church, temple, statue, magical crystal centerpiece, glowing plants, fantasy portal, elaborate ruins, village, crowded marketplace, many buildings, cinematic composition, dramatic spotlight, bloom, god rays, extreme saturation, random clutter everywhere, maze-like obstacle spam, blocked exits, tiny unreadable walking space, perfectly symmetrical layout, strict diamond isometric grid, flat schematic map, painterly blur, photorealistic textures, characters, monsters, text, UI.
```

## Acceptance before any decomposition

Do not proceed to Ground / Par authoring until the candidate passes:
- FS family fit
- normal field role fit
- walkability/readability
- boundary discipline
- focal discipline
- originality
- decomposability

A visually attractive image is not enough.
