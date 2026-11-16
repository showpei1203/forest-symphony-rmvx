# A40 FAILURE LOG | 2026-11-14

## A40-F01 | Foot mask bleed in generated keyframes
- Symptom: first generated candidate failed the immutable-foot check at F1 native pixel (37,47).
- Root cause: translated source arm overlay could overlap the y>=47 boot guard by one pixel.
- Fix: restore original source RGBA on all y>=47 rows at end of each newly composed attack frame; regenerate from A62.
- Retest: 8/8 GPU frames pass exact source face/boot RGBA gates, pixel-for-pixel matching their 64px atlas cell. **Resolved.**

## A40-F02 | AnimationPlayer hit track targets wrong Node
- Symptom: actual Godot runtime reported `Node2D(battle_animation_preview.gd)::_on_attack_contact: Method not found`; no hit at 0.52s.
- Root cause: method-track path was mistakenly `NodePath("..")`. Godot AnimationPlayer default root is the actor parent, so `..` referred to the battle preview, not actor.
- Fix: use `NodePath(".")` for `Animation.TYPE_METHOD` track inside the AttackClock; validate signal endpoint and exactly-one-per-attack.
- Retest: real GPU runtime pass in normal, 2x speed, early cancel, pause/resume. **Resolved.**

## A40-F03 | Art gate insufficient body weight
- Current 8-frame arm-based attack has visible anticipation/contact/recovery, but torso and feet remain pinned; brief impact slash is only a small white glint, not a full illustrated weapon strike.
- No claim that this is an approved cinematic battle action. **ART HOLD, next iterate from original-pixel/pose constraints.**

## A40-F04 | Official battle event wiring absent
- Real Godot `attack_hit(serial, second)` signal exists; no integration yet with migrated FS ATB, skills, target selection, damage, hitstop or enemy hurt.
- **NOT_RUN (explicit).** Do not report gameplay combat integrated.

Preservation: A39 source/Run byte-identical, E: RMVX main untouched, no paid PixelLab generation, private Drive artwork only.