# Forest Symphony · Godot-first migration status (A30)

Godot 4.7.2 stable is the primary game-development and map editor, replacing the RPG Maker VX mapping runtime for all **new** map work. Keep sealed VX as the comparison source for sprites, events, combat, graphics behavior. Private A11/A18/A62/A28 art remains owner-only Drive, publicly accessible code contains zero proprietary PNG pixels.

## Completed, evidenced
- A29: real original A11 Master + three A28 PAR and F0, Godot native 14 checks, 16-node PackedScene, camera and per-actor occlusion, four real engine framebuffers.
- A30: 180 manually annotated **collision candidate** 32px cells with actual TileSet/TileMapLayer physical collisions (Godot 4.7.2 native 221 checks); all 980 candidate-free cells form one connected candidate graph (not verified walkable); 3 original approved A62 Run frame images now animate during input, original F0 idle and dynamic PAR cache correct. Four original A27 occlusion baseline counts preserved; 4 native Godot scene screenshots and a Godot framebuffer-based loop proof.

## Still blocked
- Collision is not yet accepted for gameplay; 180 conservatively blocked candidates leave many shore/trees/house collision unknown, and might block some valid tiles. The editable red debug layer is a **review surface**, not a final authored map.
- Per-actor same-XY PAR's partially floating-head tree shadow visually fails; user needs an art pass, building roof original foreground is absent.
- A62 Run is a battle 45° actor, NOT real 4/8-way overworld walking. No false claim of new movement.
- Native Godot Windows export, door/transition events, inventory, saves, ATB/Tankentai 6-member battle, Break, Cover, Overdrive, summons are NOT_RUN.

## Next
1. Fix source tree/roof occlusion and area-by-area 32px collision with 1x native scenes; do not regen whole map.
2. Overworld sprites/scene transitions/event adapters with source-locked direction/facing/animation.
3. Batched map + battle runtime integration to avoid spending another month on pixel-perfect static tests.

`docs/A30_HANDOFF.md` is detailed source of truth for this iteration. `main` and sealed VX untouched.
