# A41 Handoff | Normal Damage 3F real PixelLab skeleton and severity comparison

## User instruction
Continue FS action production after A40 real skeleton succeeded. Preserve A37 user-selected Dodging T4. A40 critical severe retains deeper slump; normal Damage should be a brief, milder flinch, not critical kneel. All are exactly three 40px sprites, 120x40 sheet and entirely unarmed.

## Two real PixelLab trials, verified
Use genuine A34 actor01_1 battle-view-derived teal/white-haired original as F0 source, and A40 real /estimate-skeleton 18 joints (do NOT charge another estimate). Both /animate-with-skeleton-v3 with south-east and low top-down camera, three target frames:
- R1 job d6c10beb-bf89-42b0-a01d-cff847ff9cf2, charged 2 generations; F1 raises and spreads arms horizontally, reads *attack* instead of damage -> ART SEMANTIC FAIL.
- R2 job dd62eb1a-85b3-49da-9f8d-b01bd4a0cb32, charged 2 generations. Guard wrists constrained inside shoulder span, limited neck/back shift, hips slightly lower, and source F2 identical F0. F1 now more like short defensive flinch, still subject to user art & exact camera 45 gate.
A41 total spent 4 generations; quota after R2 1695.7/2000. Both provider jobs API-readback completed; no retries or duplicate charges.

## True outputs
A41_R1_FAIL_R2_VS_A40_CRITICAL_COMPARISON.png: four lines A40 crit, failed A41 R1, raw successful A41 R2, exact source-anchored R2 candidate.
A41_R2_NORMAL_DAMAGE_NATIVE_SOURCE_ANCHORED_3F.png: exactly 120x40 original F0, PixelLab R2 F1, original F2, no raster repaint.
A41_R2_NORMAL_DAMAGE_3F_ONESHOT.gif: three-frame one-shot no infinite loop.
Both R1 and R2 provider raw frames preserved separately. R2 keypoint changes stored R2_HANDS_IN_GUARD/A41_R2_RESTRICTED_GUARD_18JOINT.json. Detailed QA A41_R2_COMPARE_QA.json and A41_FINAL_QA.json.

## Gates and next
Normal vs critical now distinct motion duration/severity: A41 normal returns to exact guard by F2; A40 severe remains collapsed F2. Technical frame counts/geometry/no cropping pass. No formal art camera/weapon overlay/VX SBS run yet; never claim final PASS without tests. Original FS sources, A37 Dodging T4 and other baselines untouched.
Next A42 tests Moving to Close Attack with same skeletal source but SBS engine handles actual forward displacement; sprite art is in-place three steps only.
