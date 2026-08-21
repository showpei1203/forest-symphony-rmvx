# FS Elf Forest Village — Map Intent v1

Date: 2026-08-21
Project: Forest Symphony / RPG Maker VX
Workflow: FS Map Asset Prompt Workflow v1
Stage: 3 — Map Intent Brief
Status: LOCKED FOR STAGE 4 INVENTORY PLANNING
Reference Set: FS_REFSET_ELF_FOREST_VILLAGE_V1
Style DNA: FS_ELF_FOREST_VILLAGE_STYLE_DNA_V1

## Map Role

Medium-large primary exploration village inside a living forest. It must function as a real settlement, navigation hub, social/exploration space, and visual introduction to elf culture.

Planning envelope: approximately 4–6 RMVX viewport-equivalents of explorable visual space. This is not a fixed canvas size. Final dimensions and exact placement remain user manual-mapping authority.

## Core Experience

- forest gradually becomes settlement instead of a hard urban boundary;
- architecture integrates with trunks, roots, platforms and vegetation;
- one unmistakable sacred focal point;
- ground-level village life plus limited elevated/tree-integrated structures;
- stream/river and bridge act as spatial landmarks;
- perimeter can be dense while traversal remains readable.

## Required Functional Nodes

### Arrival / Commons
Readable first orientation point with open ground and a clear path toward the village core.

### Central Sacred Grove
Primary visual/cultural focal point containing the Central Sacred Tree Hero asset. Requires generous circulation and breathing room.

### Treehouse Residential Cluster
Elf-specific architecture family. Must preserve readable platform, entrance and support logic. The entire village must not become treehouses.

### Ground-House Residential Cluster
Ordinary timber housing using approved FS material language where possible. Provides everyday settlement body and contrast with treehouses.

### Commerce / Service Cluster
Required: Shop + Inn. Must be easy to revisit and visually distinguishable without leaving the shared village material family.

### Riverside / Bridge Node
The river must influence navigation and district separation. One main bridge is mandatory for identity. It must lead somewhere meaningful.

### Forest Perimeter / Utility Edge
Dense vegetation/rocks/logs/fences contain the map and merge settlement back into forest while exits remain readable.

## Connectivity Grammar

Arrival <-> Village Core / Sacred Grove
Village Core <-> Commerce
Village Core <-> Ground Residences
Village Core <-> Treehouse Cluster
Village Core <-> Riverside / Bridge
Commerce <-> at least one convenient secondary route
Bridge <-> meaningful destination/district

At least one small navigation loop is required. Dead ends are reserved for optional scenic/NPC/collectible/narrative use.

## River Intent

- moderate village-scale width;
- readable banks;
- obvious bridge crossing at RMVX scale;
- must not consume the center of the entire map;
- one main bridge mandatory;
- second minor crossing optional if manual mapping benefits;
- exact river shape remains user authority.

## Focal Hierarchy

Priority 1: Central Sacred Tree.

Priority 2: Inn, Shop, Main Bridge, strongest Treehouse composition.

Priority 3: ordinary houses, small platforms, wells/signs/benches/lamps, scenic vegetation moments.

Minor props must not compete with the Hero focal hierarchy.

## Density Grammar

Core traversal space: quieter, fewer large occluders, high route readability.

Residential/service edges: moderate lived-in prop density.

Forest perimeter: highest vegetation density and strongest containment.

Sacred Grove: visually important but uncluttered; Hero silhouette needs breathing room.

## Architecture Distribution Intent

The village should not consist entirely of treehouses.

- ground-level ordinary timber houses form the everyday settlement body;
- treehouses form the distinctive elf-specific secondary family;
- Shop and Inn are larger/readable variants of the same village material system;
- Central Sacred Tree is unique Hero architecture/nature fusion.

Exact building counts are deferred to Stage 4 Asset Inventory and final user mapping.

## Exploration Intent

The player should naturally encounter:
- clear arrival orientation;
- Sacred Tree as the main landmark;
- commerce/service route;
- bridge/riverside moment;
- treehouse-focused area;
- ordinary lived-in residential space;
- a few optional scenic or NPC corners.

Mandatory services should not require excessive detours after the map is learned.

## Boundaries / Runtime Policy

Boundaries should normally use forest density, rocks, roots, elevation, water or built barriers rather than arbitrary empty voids.

Stage 3 does not define Par, Collision, Light, Shadow or event coordinates. Those remain runtime derivatives after user manual mapping stabilizes the layout. No flattened Master Scene is required.

## Explicit Non-Goals

Do not:
- turn the village into a city-scale settlement;
- make every building a Hero asset;
- make the river the dominant map obstacle;
- fill every empty tile with vegetation/props;
- force all residences into trees;
- introduce castle/marble palace language;
- use isometric/cinematic perspective;
- define exact object coordinates before manual mapping.

## Stage 3 Acceptance

PASS when map role, functional nodes, connectivity, river/bridge role, Sacred Tree hierarchy, district purpose and density grammar are explicit enough to derive a complete Stage 4 Asset Inventory without stealing final geometry authority from the user.

Stage 3 result: PASS.

NEXT: Stage 4 — Asset Inventory. No image generation yet.
