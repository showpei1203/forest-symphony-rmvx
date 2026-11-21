# Forest Symphony | T-B R5 Private Native Attack + V5 Cutout Handoff

**Date**: 2026-11-21 Asia/Taipei  
**Branch**: `feat/fs-pixellab-tb-monster-20261121`  
**Issue**: SHO-37  
**Status**: **M1 three-stage + Idle retained; V5 ATTACK_CANDIDATE; Native Script/Render PASS; ART HOLD**. Godot 4.7.2 only, no VX migration or changes to formal FS combat damage.

## REAL WORK DELIVERED
1. Official Godot `4.7.2.stable.official.ed1daf0bf` Linux binary obtained through private working sandbox by GitHub Actions `44873427754` artifact `14694866553`. Official executable SHA256 `8d106cbe6144c2dc7e881d61d2429c1a8a76e6b22ef48bd5e48dcf934953f71e`. This executable is not committed and need not be deployed to owner's Windows machine.
2. Imported actual private PMD0001 **R4 V4 sprite atlas** into Godot 4.7.2, ran actual native validator `TB_TIMELINE_NATIVE_PASS` (R2/H5/T7/DONE; skip/cancel/normal). Unlike earlier synthetic CI, the PNG in this project is the private real source.
3. Created **V5 11×96×96 384×288 RGBA source-locked Attack**, 11 native output images. This is a new *deterministic separate cutout layer candidate* based on PMD0001 approved static source, NOT PixelLab generation, NOT final art. Three independent source-foot masks, source torso rigid translation, localized mouth tip, no RBF and no whole-character scaling; F0/F10 exactly match source. Normal Attack is leap/bite, no lava projectile.
4. Created standalone Godot V5-vs-V4 private review scene and a private-native validator. Real-PNG native test log `TB_V5_REAL_NATIVE_PASS 4.7.2 real atlas 384x288 11F R2/H5/T7 exact_once cancel`.
5. On `xvfb-run` native OpenGL compatibility renderer **Mesa llvmpipe CPU software rasterizer**, rendered **11/11 actual Godot viewport frames** from real V5 atlas: `TB_V5_11_NATIVE_RENDER_PASS`. Also exported F0/F3/F5 native comparative screenshot, 11-frame native contact and both realtime and slowed native GIF for manual art review. This is real Godot 4.7.2 image evidence, **not a claim of hardware GPU tests on the owner's PC**.
6. Offline source lock & render QA: **13/13 PASS**, including F0/F10 pixel-identical source, torso/eye pixels preserved on all 11 frames with body root translations, one large connected sprite component per frame, no crop, 11 distinct render positions except matching F0/F10, native screenshot PNGs saved and reproducible. 13/13 refers only to objective technical checks.

## SOURCE + CONTEXT
- Private 64px PMD0001 source SHA256 `fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c` from already verified 3-stage lava-frog source; head/body 3/4 right-facing but exact FS southeast 45° remains art HOLD.
- XML original native event contract F2 Rush, F5 Hit, F7 Return; eleven durations [4,2,4,2,2,2,2,2,2,2,4] ticks = 28 ticks (60 Hz base).
- V5 Atlas SHA256 `778282e1135c47d46a511e7da6a4a979636c5d67e7f259c13959e21795b584f4`.
- V5 is **not** 11 new PixelLab generations. This round **0 provider calls, 0 generations spent**, no new paid PixelLab job ID.

## GATES
| Gate | Status |
|---|---|
| Real PMD original PNG locked / derived cell sizes / no clipping | PASS |
| Attack F0/F10 preserve mother identity exactly | PASS |
| Source eye/shell unmodified in each pose | PASS |
| Native Godot 4.7.2 (actual PRIVATE art) script time and event test | PASS |
| Native Godot 4.7.2 actual viewport 11 frames rendered | PASS (software OpenGL) |
| Independent limb and jaw silhouette visually natural | **ART HOLD** |
| True PixelLab Skeleton v3 new attack | NOT_RUN |
| Verified exact 45° combat camera | HOLD |
| Second genuinely different sample/family | NOT_RUN |
| Whole production line volume efficiency | NOT_MEASURED |

## FAILURE LOG
See `PIXELLAB_TB_R5_FAILURE_LOG_20261121.md`. Key remaining blocker is **F5 jaw opens too subtly, foreleg connectors are straight / hard and need separately drawn shoulder/elbow and proper masking**, not software playback or palette. Do NOT repeat the RBF deformation. Two small local mouth-polygon iterations already attempted; next ART fix must change method (drawn key poses / provider skeleton), not endless pixel tweaking.

## DELIVERABLE LOCATION / CLOUD CONTRACT
- Private Drive folder from previous R4 handoff: `https://drive.google.com/drive/folders/10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`.
- GitHub branch (code, CI, reports ONLY): `https://github.com/showpei1203/forest-symphony-rmvx/tree/feat/fs-pixellab-tb-monster-20261121`.
- Full source, PNG, native screenshot, sprite sheet, Godot separate project and QA evidence stored only in private Drive. **No permanent results library or files placed on owner's PC.**
- New public `PIXELLAB_TB_CURRENT_HANDOFF.md` must point to this R5 report, not mark ART PASS.

## NEXT SINGLE COMPLETE TARGET
Use approved PMD0001 base + native 11-frame physics as pose anchors to draw three trustworthy separate key poses (crouch / leap / jaw-hit), maintain 3/4 identity and source license, then request one actual PixelLab Skeleton v3 set if eligible, record job id / quoted and actual credit cost and save provider outputs to private Drive. Run 11-frame native Godot screenshot and manual ART Gate; only after PASS, duplicate to next monster sample.

## R5 actual saved Drive evidence / shareable links
- Private final R5 project + source + all 11 raw Godot native screenshots ZIP: https://drive.google.com/file/d/1xNFP3fitA0PRQccc2t0oFCh2DsxyKrwM/view
- Real Godot 4.7.2 11-frame montage: https://drive.google.com/file/d/12WBZ2pKn4vXdq394ALAxFuXxDD3bEQ_B/view
- Slow replay of Godot native-rendered real PNG frames: https://drive.google.com/file/d/1GhyN5kYAP4yHhDaUyGPgJQF0aqcsRuUI/view
- Real-time Godot native GIF: https://drive.google.com/file/d/1ke0M3mWaRWwEcf6S6Koyf9kqWMU-kx0C/view
- V5 transparent sprite sheet: https://drive.google.com/file/d/17Py9VJhcumRttBCA4XYP9XHrZvWoRgPF/view
- Private R5 SHA manifest: https://drive.google.com/file/d/1cwYlne88kfuTNd39LC6mB2xPGTnpXzpv/view
- ZIP SHA256 `190bd45ad22629944746d54261ff966fade9661ed13c1576fca4adfd5f50fe6f`; 54 files CRC PASS.
