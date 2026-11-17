# FS A57｜Body-only Godot 4.7.2 action pilot

## User direction 2026-11-18
The character animation contains only Body posing as if gripping a weapon. The actual weapon, shield, projectile, magic and effects MUST be provided by Godot sprites/logic. Do not bake any of them in Body. Do not generate a shield-bearing character to complete attack.

## Real payload
- The approved-for-technical-work A53 real PixelLab Body atlas 256×192 (12 × 64×64) and right-hand anchors; original pixels preserved.
- `A57BodyOnlyDemo.tscn` has a Body sprite and separate runtime-only Weapon/Shield/Effects nodes, all equipment initially textureless.
- `a57_body_action_player.gd` plays A53 attack at 0.09 seconds/frame, emits a SINGLE contact request at F7 t=0.63, 70ms Hitstop, can cancel and run 2×. The actual FS battle system owns damage, range, MP and ACT state. Shield mount deliberately has NO left-hand anchor since no verified source exists.
- All 16 original human animation classes in JSON; only actual A53 12F Body is wired to this private pilot. Existing A62 Run user-approved (48px), A63 Waiting, A64 Critical, A65 Magic retain independent identity/ART statuses. 11 other classes are not fabricated by reusing Attack frames.

## Test
Godot 4.7.2 native: `godot --headless --path <this project> --script res://scripts/a57_native_smoke.gd`. A57 native test STATUS is NOT_RUN unless a real console log is attached. Pixel/image QA uses `python qa/validate_a57.py --project <this project>`.

## Notes
No original VX artwork was modified. A53 Body ART HOLD and existing GPU timeout remain separate. Engine and art acceptance are independent.
