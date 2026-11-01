# Forest Symphony | Terrain PAR TOP LEDGE 1-2 Tile Gate v2
2026-11-02. ACTIVE. Supersedes A35B interim zero-PAR conclusion while preserving rejection of A35 blanket 217 cliff masks.

## Rule
Terrain PAR is the front upper rim of a plateau which **covers an actor standing 1 or 2 walkable tile rows BEHIND that upper rim**, the exact number determined by plateau height and shape. For lower-ground actors in FRONT, the same lip must not occlude the actor. Dark cliff pixels, full cliff wall shape, and impassable collision alone are NOT evidence of PAR.

Each candidate has: source-backed RGBA, source SHA, height tier=1 or 2, edge tile row, legal behind-foot tile list, unique optional depth slice, permitted actor elevation/region and native front/behind screenshot pair. Draw conditional lip only when an actual actor foot is on allowed behind tiles. Never bake SHADOW/LIGHT into PAR. Main Ground SHA 478b3f40367cb449721a9216c28c3906557cbb292ffcc6702984ec0d90559f00 stays untouched.

## Actual A35C R2 proof
Four cliff ledges (west and middle tier2, east and south tier1), six independent RGBA depth sprites, 32 qualifying behind-foot predicates. One-to-two tile depth is not same as mask thickness: R1 used a 20px source lip that hid ~400 actor pixels, leaving only a head, and was rejected. R2 uses 9px original-source strips, preserving actor torso. Native Game.exe has two identical 11-case / 22-frame runs, enabled PAR and separate no-PAR. Cases2..10 after title fade: five actual behind actors lose 154-159 visible sprite pixel positions; four front/unrelated positions have zero changed pixels. All hidden Ground backgrounds pixel-identical.
Godot4.7.2 AMD RX6700XT 19 real full 1280x928 frames: behind effects 188-195 changed positions in five cases, four front effects0; no actor full Ground RGB exact0. VX cold 3635/3635 file SHA, real Map050 6 objects and no modal.

This is an actual representative prototype, not complete scene acceptance. Height graph, cave/stairs, all cliff segments and multi-character occlusion pending; test-only A30 RGSS BattleRegression bypass not for production. User art acceptance pending; Formal Seal NO.