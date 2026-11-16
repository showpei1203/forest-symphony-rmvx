# A42 Failure Log | 2026-11-14
Scope: Godot A41 source → true 3-layer body/weapon/FX, source-perfect GPU, reusable 45° pose manifest and hitstop.

## A42-F01 | QA sampled too close to contact time
- Actual first A42 real GPU test emitted F6 hit **after** the QA's hard-coded wait (0.43s+0.13s), due to native render frame granularity and callback scheduling. QA falsely flagged contact, freeze and finish as missing even though hit did occur.
- Root cause: sleep-based timing probe racing against scheduled AnimationPlayer callback, not a data/pose bug.
- Fix: await **actual `hitstop_started` and `hitstop_finished` signals**, then check frozen F6, single hit, reactivation. Re-test normal and x2 in real RX6700XT Godot.
- Result: **RESOLVED**, real Godot GPU QA exit0.

## A42-F02 | Potential post-contact state-cancellation hitstop
- Risk: when actual battle receiver reacts synchronously to `attack_hit` and cancels actor, unguarded `_begin_hitstop()` could freeze a no-longer-active attack.
- Fix: recheck `_active_motion == &"attack"` after emitting hit/anchor signals. Add real QA receiver that transitions to `idle_rig` **from inside the hit callback**.
- Result: hit F6 delivered, actor returns to idle, sword/FX hidden, no hitstop starts for cancelled state, no phantom/double hit. **RESOLVED**.

## A42-F03 | Independent graphics vs final art
- A42 decomposes the exact A41 art **without repaint**; it does not by itself create a stronger-looking 12-frame animation.
- Result: **ART HOLD**. Next stage needs independent weapon variation and human review of real 1x motion; do not claim finalized art.

## A42-F04 | True combat migration
- Normalized `attack_hit` and `attack_contact_anchor` remain ready for gameplay wiring, but there is **no formal FS Godot migrated ATB/damage/skill/target test**.
- Result: **NOT_RUN**. Do not confuse Godot preview dummy/QA with the game's damage pipeline.

## Reuse/QA rules
- Never paint over A62 face or adjust original A35 RUN sheet; use 64px original palette with RGBA 0/255, exact hit frame and same AnimationPlayer for pose, weapon, FX and hit method.
- Verify original A41 stacked A42 composite **12/12 RGBA 0 differences** in both source and real GPU before altering weapon/FX art.
- Maintain separate owner-only Drive ZIP and current feature branch Handoff per stage. No E: local artifacts, no PixelLab generation this stage.