# FS A44 Formal Engineering Handoff | 2026-11-15

## Authority and unchanged foundations
- A43 private source archive SHA256 37d7bb4ffb2274de4ebdf4afaf4835bd670ff1bf42b521572958f7e17a4ba19c.
- Engine Godot 4.7.2; RPG Maker VX is no longer the development engine. E: historical sources intact.
- 45 degree 64x64 battle sprite, 4x3 atlas, 12 frames. Old A42/A43 and A39 breathing retained.
- GitHub branch feat/fs-asset-factory-v1-20261107. No main/map/migration overwrite.

## Implemented art and systems
1. A44 Body 12-frame edit: support leg, forward foot plant, hip tail, armor rotation highlights. FX grounding dust F5-7; weapon independent and A43 design retained.
2. A44 12-pose attack contact anchors in assets/actor01_a44_attack_anchors.json, consumed by a fifth synchronized AnimationPlayer track HitMarker:position. F6 tip local (29,9).
3. scenes/a44_contact_demo.tscn playable Godot project main scene: Actor01 strikes Area2D practice dummy, HP -25 within 29px radius, misses outside, flashes and recoils. A strike, R reset.
4. scripts/a44_practice_target.gd and a44_contact_demo.gd are isolated demo services, NOT formal FS combat migration.
5. Re-entrant callback cancellation guard: only emit attack_contact_anchor if attack remains active after attack_hit listener.

## Actual native GPU QA (AMD RX 6700 XT OpenGL)
- Godot 4.7.2 import EXIT0.
- A44 12/12 native 64x64 GPU screenshots match Body/Weapon/FX source (premultiplied alpha tolerant, 0 divergent pixels).
- 12/12 no border crop, 11 distinct poses, head y0..33 exact original A43 in all frames.
- A44_CONTACT_QA_RESULT PASS: exact 12 sword-tip marker keys, five-track animation, HP 100->75->50, 0 damage outside radius, no duplicate serial, cancel before contact, 2x speed, cancel INSIDE hit callback no ghost damage, returns idle.
- True 800x620 native Godot scene screenshot qa/output/a44/A44_NATIVE_DAMAGE_CONTACT_SCENE.png.
- Reconstructed Godot-native frame GIF A44_REAL_GODOT_GPU_ATTACK_12FRAMES_4X.gif (not PIL-only sprite compositing).

## Gates and failure log
ENGINE IMPORT PASS. 12-FRAME GPU PASS. ISOLATED HIT DAMAGE PASS.
ART HUMAN APPROVAL HOLD: motion still requires 1x and 3x human inspection.
FULL MIGRATED FS COMBAT/ATB/DAMAGE NOT RUN. Preserve source boundaries.
Detailed failures in qa/A44_FAILURE_LOG.md (unnamed CollisionShape2D, ghost damage reentrancy bug and fixes).

## Next
Review body anatomy of A44 vs A43 at 1x/3x. Once approved, integrate isolated contact semantics into main Godot port combat state machine in its OWN migration branch; do not claim main migration is done.
