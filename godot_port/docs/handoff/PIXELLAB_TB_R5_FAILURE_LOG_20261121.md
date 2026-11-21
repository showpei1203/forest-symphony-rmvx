# Forest Symphony | T-B R5 Attack Failure Log | 2026-11-21

Stage: PMD0001 V5 source-locked cutout prototype. **Not an ART PASS.** Godot 4.7.2 real-PNG native render/script PASS; 13/13 machine geometry+identity tests PASS.

| Code | Severity | Observed | Treatment | State |
|---|---|---|---|---|
| V4_RBF_LIMB_STRETCH | BLOCKING ART | Previous V4 RBF displaced limb pixels, causing stretched orange forelegs and a jaw patch | V5 physically separates three source foot layers and uses solid source torso, no RBF and no whole-body scaling | Previous method retired |
| V5_JAW_V1_MASSIVE_PACMAN | BLOCKING ART | First local cutout trial drew mouth cavity across whole chin and neck, disconnected-looking black half-circle | Reduced mouth cavity to head-tip near original snout, revised jaw opening method. This counts as art correction round #1. | Fixed overlarge cavity; action still not satisfactory |
| V5_JAW_V2_INSUFFICIENT_BITE | BLOCKING ART | Refined F5 has only a small snout-mouth opening and weak jaw separation; may not read as a powerful bite at actual battle size | Do not repeatedly tweak polygons. Next: 3 distinct hand-drawn or PixelLab skeleton key poses with jaw and actual limb anatomy, then interpolate by semantic pose | HOLD; generation method change needed |
| V5_FRONT_LIMB_HARD_JOIN | BLOCKING ART | Forelegs are individually placed, but segment connectors remain simple strokes and have mechanical straightness | Need redraw knee/elbow segments and occlusion; do not run another rigid warp of entire subject | HOLD |
| FALSE_ALPHA_BINARY_TEST | QA BUG | Legacy 64px approved source contains 88 distinct alpha values; trial assertion requiring only 0/255 failed though alpha-preserving source was correct | Replace with source AA preservation check, native alpha border/crop checks | Fixed; QA 13/13 |
| NO_LOCAL_GODOT_472 | TECHNICAL BLOCKER | Previous runs couldn't verify private true PNG with Godot native runtime | Fetched official pinned Godot 4.7.2 via GitHub Actions artifact to isolated ChatGPT container; test with real private source, Xvfb llvmpipe OpenGL compatibility | RESOLVED |
| 45DEG_IDENTITY_REVIEW | BLOCKING ART | Right-facing 3/4 portrait remains unreviewed for exact 45-degree FS combat view | Manual combat camera approval required after next truly articulated attack sample | HOLD |
| PIXELLAB_TRUE_ANIMATION | BLOCKING PRODUCTION | V5 deterministic code is not PixelLab Skeleton v3 output. No new provider job occurred | Use existing signed-in PixelLab only with explicit job-cost recording, stable source+keys, and private outputs, then Godot native art review | NOT_RUN; 0 new generations |

## Production rule
- Approved original PMD0001 source and static evolution PMD0002/3 must not be overwritten.
- Non-blocking pixel polish capped at two consecutive repair passes; do not convert technical PASS into ART PASS.
- Do not generate the second independent species until PMD0001 physical Attack, Idle, and exact view are art-reviewed.
