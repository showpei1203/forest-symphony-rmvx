# T-B R9 Failure Log | 2026-11-22

- `REAL_FSBATTLE_UI_SOURCE_TAG_NOT_VERIFIED`: **BLOCKING for production binding**. TB02 has no verified original VX Enemy ID/Troop mapping; do not match by enemy display name, use explicitly sourced profile only. Synthetic test sets the tag intentionally.
- `REAL_FS_BATTLESCAPE_CAMERA_NOT_PROVEN`: **ART HOLD**. Private 544x416 capture is a neutral staging backdrop, not original source BattleScape/45-degree scene. Preserve screenshot as preliminary native evidence only.
- `DAMAGE_AND_ANIMATION_F5_OFFSET`: **KNOWN ENGINE LIMIT**. Original FSActionQueue resolves damage when ACT completes, *before* visual F5 cue. Bridge is passive and leaves HP, MP, ATB untouched. Deferred gameplay hit timing needs source-gated T-A integration, not a duplicate call from VFX.
- `PUBLIC_CI_NO_PRIVATE_ART`: expected, not a fail. The CI tests the ACT bridge and real FSScreen with synthetic 384x192 idle/512x384 attack sheets. The separate private isolated Godot job tests authentic provider SHA and real pixels. Never claim one proved the other.
- `STAGE2_3_CONCEPT_NOT_RELEASED`: generative illustrations are unverified art references, not source-locked native sheet revisions. No rewrite of approved PMD0001 V6 / TB02 R8.
- `R9_PIXEL_LAB_COST`: 0 jobs, 0 subscription generations.
- `MAIN_TA_TC_UNTOUCHED`: T-B branch only.
