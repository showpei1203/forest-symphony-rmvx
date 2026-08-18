# Forest Symphony Map — Diorama Field Style DNA v1

- Project: Forest Symphony
- Scope: contained field / clearing / camp / plateau / dungeon-room style maps
- Authority date: 2026-08-18
- Related Linear: `SHO-39 | FS Map Style DNA + Forest Clearing Benchmark I`

## 1. Purpose

This document defines the family-level visual and gameplay language for generating NEW Forest Symphony maps without copying any existing scene layout.

Legacy `SCENE##`, `ground##`, `par##`, `light##`, and `shadow##` files are analysis and acceptance references. They are not direct map templates.

Core rule:

> Learn the stage grammar. Do not copy the stage.

## 2. Evidence set

Current observations are derived from representative FS captures including `SCENE001`, `SCENE05`, `SCENE10`, `SCENE15`, `SCENE20`, `SCENE21`, plus legacy Ground / Par pairs.

The sampled scenes cover village clearing, dry field, camp, grass plateau, crystal-industrial dungeon, and woodland/church environments.

## 3. Core map identity

The sampled FS field maps behave like contained playable diorama stages rather than unrestricted full-screen terrain paintings.

Common traits:
- a clearly bounded playfield
- high/top-down three-quarter RPG readability
- visible front-facing cliff/wall/building faces where appropriate
- central or near-central negative space reserved for player movement
- higher decoration density around the perimeter
- a small number of strong focal elements
- map boundary communicates containment through cliffs, walls, trees, fences, structures, rocks, water, or vegetation
- environment theme changes strongly while layout grammar stays recognizable

## 4. Visual hierarchy

Preferred priority:

1. Walkable ground / route readability
2. Boundary and containment
3. One primary focal point or 1–3 secondary focal points
4. Large environment objects
5. Small props / foliage accents
6. Light / shadow / atmosphere overlays

The map must remain readable before decorative detail is added.

## 5. Walkable negative space

Central gameplay space is intentionally cleaner than the boundary.

Target behavior:
- reserve roughly half or more of the main playfield as visually readable traversable space
- avoid filling the center with equally dense decoration
- paths and open ground should form continuous readable movement zones
- props should create interest without producing accidental maze noise
- exits, stairs, doors, bridges, or passage openings should be visually discoverable

A beautiful map that hides where the player can walk is a visual failure.

## 6. Perimeter density

Environmental density should generally increase toward map edges.

Preferred boundary elements by family:
- forest: trees, shrubs, cliff edges, dense flowers, rocks
- village/camp: fences, buildings, stacked supplies, trees
- dry field: rock ledges, dead trees, barrels, scrub
- dungeon: walls, pipes, crystal formations, water channels, machinery

The perimeter is not required to be symmetrical.

## 7. Focal-point discipline

Standard field maps should not contain many equally important hero objects.

Preferred:
- 1 dominant focal element, or
- 2–3 moderate focal elements

Examples of valid focal roles:
- house / chapel
- well
- campfire
- raised plateau
- dungeon gate
- crystal pool

Ordinary trees and props should support the scene rather than compete with the focal point.

## 8. Silhouette / stage footprint

The playable field should read as one contained stage footprint.

Observed family tendencies:
- rounded / oval / irregular contained boundary
- front edge often visibly elevated or cut away
- rear edge often visually denser or taller
- the scene remains wider than tall in the RMVX viewport

Do not force a perfect oval. Natural irregularity is preferred.

## 9. Camera / projection DNA

Target view:
- high top-down / three-quarter RPG view
- enough downward angle to read floor layout
- enough visible vertical face to read cliffs, walls, buildings and tree trunks
- not strict side view
- not pure flat bird's-eye plan
- not cinematic perspective
- not strict diamond-grid isometric unless a specific family requires it

## 10. Ground DNA

Ground should have broad readable material zones before micro-detail.

Preferred:
- grass, dirt, stone, cracked soil, cave floor, shallow water, etc. form coherent large masses
- subtle texture variation inside each material
- path / clearing / route contrast visible at gameplay scale
- transition edges irregular but controlled

Avoid:
- uniformly noisy texture across every pixel
- extreme contrast that competes with characters
- decorative decals covering all walkable space

## 11. Object density / repetition

Normal map objects must tolerate repetition.

Use families rather than unique hero props:
- several related trees
- several related rocks
- repeated grasses / flowers
- barrels / crates / logs with mild variation

Special one-off objects should be rare and deliberate.

## 12. Occlusion DNA

FS legacy assets show Base + Occlusion Overlay behavior.

Map composition must therefore anticipate:
- complete environment objects in the visual base when required
- selected trunks / walls / canopy / high objects duplicated into Par as occlusion overlays
- walk-behind zones remain intentional and understandable

The concept scene itself is not the Ground/Par authority. It is a composition target to be decomposed after visual acceptance.

## 13. Lighting / atmosphere DNA

Lighting is a supporting layer, not the base composition.

Preferred:
- broad environment lighting
- localized light where biome/story requires it
- soft shadow organization
- atmosphere can differentiate village / cave / crystal dungeon / forest while preserving gameplay readability

Do not use lighting to hide weak layout structure.

## 14. Benchmark canvas strategy

RMVX viewport target: `544×416`.

Prototype generation canvas: `272×208`.

Reason:
- exact 1:2 scale relationship
- both dimensions are multiples of 16
- nearest-neighbor ×2 produces exact `544×416`
- avoids non-integer scaling damage to pixel clusters

The 272×208 image is a concept/master-scene benchmark, not automatically runtime-ready.

## 15. First benchmark family

Asset ID:

`FS_Map_Forest_Clearing_01`

Role:
- ordinary woodland transition / forest clearing
- reusable exploration map
- no sacred grove
- no boss arena
- no landmark shrine
- no giant hero tree

Target composition:
- contained irregular clearing
- readable central movement area
- perimeter tree / shrub / rock density
- 2 readable route openings or exits
- 0–1 modest focal prop
- no characters in generation image

## 16. Failure conditions

Blocking visual failures include:
- `FAIL_MAP_ROLE_MISMATCH`
- `FAIL_WALKABLE_SPACE_UNREADABLE`
- `FAIL_CENTER_OVERCLUTTERED`
- `FAIL_BOUNDARY_UNCLEAR`
- `FAIL_TOO_MANY_FOCAL_POINTS`
- `FAIL_CAMERA_FAMILY_MISMATCH`
- `FAIL_HERO_OBJECT_DOMINANCE`
- `FAIL_STYLE_FAMILY_MISMATCH`
- `FAIL_NOT_DECOMPOSABLE`

## 17. Success definition

A map candidate passes the concept benchmark only when:
1. It feels native to Forest Symphony.
2. It is clearly a normal playable field map, not concept art or a boss set piece.
3. Walkable negative space is obvious.
4. Perimeter density frames rather than overwhelms the playfield.
5. Focal hierarchy is disciplined.
6. The layout is materially new, not a redraw of a legacy scene.
7. Major components can be decomposed into Ground textures, reusable Master Objects, occlusion overlays, and metadata.
8. The scene can plausibly be rebuilt into the FS Ground/Par runtime profile.
