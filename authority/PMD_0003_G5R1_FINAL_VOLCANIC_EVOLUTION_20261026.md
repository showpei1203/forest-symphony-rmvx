# PMD 0003 G5R1 — authentic rock/fire final evolution candidate
Date: 2026-10-26 | Shared PMD Art Toolchain | Branch feature/ai-art-toolchain-pilot-20261025

## Scope and frozen baseline
- User explicitly ordered **F2 map production paused**. All Ground/PAR, actor-scale, native map sources, F1R1 A04 sealed baseline and other map conversations are untouched.
- PMD 0001 G3R1 orange/gray volcanic baby is **USER APPROVED DESIGN DIRECTION** only: warm orange body, small dark basalt shell with thin luminous magma cracks.
- PMD 0002 G4R1 candidate (user's prior "很不錯，繼續") has larger two-plate split basalt shell, brighter magma, 12 real actions and 682 cells original sprite/0002; TECH source/native Godot PASS, not independently USER VISUAL SEALED.
- PMD 0003 is FINAL ROCK+FIRE DESIGN target, more extensive fractures and fully exposed molten core.

## Actual original PMD0003 upstream
Directly fetched **PMDCollab/SpriteCollab/sprite/0003** from GitHub `master` into an isolated source directory. The upstream folder has 40 returned items, 37 relevant XML/PNG files. The ORIGINAL 0003 `AnimData.xml` has 14 action names, including 2 `CopyOf`; **12 actual animation sheets and 698 original individual action/direction/frame cells**. Crucial: original 0001 has 34/1123, original 0002 has 12/682; do NOT assume shared frame counts or use a generated faux sheet.

## G5R1 production result, source-derived, not image-gen
Every 698 original PMD 0003 cells preserved their original dimensions, canvas/atlas origin, frame counts, facing rows and unchanged original timing:
- Changed blue/green/flower body into an orange-ash-gray creature, with **substantially ruptured jagged charcoal basalt plates on either side of a large exposed molten orange/yellow core**, stronger than 0002's narrow hot split.
- Each cell gets real new alpha morphology, at least 20 measured molten core pixels, and source-derived local pose-anchored rock geometry, all 12 genuine motion sheets; no reordering frames.
- Original `AnimData.xml`, every `-Offsets.png`, every `-Shadow.png` remain byte-identical to upstream. Lower body/foot contact area alpha preserved beneath the generated rock shell.
- The first G5 candidate **FAILED** a `Swing` action row 1, frame 3 on the right atlas boundary (`NEW_EDGE_CROP`). The old failed candidate was archived, and G5R1 hard preserves all four original border lines before per-cell QA. The complete 698-frame border regression now PASS. Do not forget this negative test.
- Human aesthetic quality and actual original PMD game / RGSS2 Tankentai SBS import remain **PENDING**.

## Actual test result
- Original XML parses 14 names and authentic 12 sheet dimensions/698 frames.
- Native Godot 4.7.2 XMLParser + OpenGL GPU bridge loaded unchanged original XML against revised 0003 -Anim sources, actual three GPU-rendered frames differ, **zero ERROR/WARNING**, test PASS. This proves our native **Godot bridge**, not official PMD game or VX SBS player.
- Source QA reverified 698/698 alpha morphology, molten core, no added frame-border pixels, unmodified XML/Offsets/Shadows.
- Cold-unzipped release ZIP SHA tests, complete source QA and fresh native Godot GPU bridge re-execution all PASS.
- The included action GIFs use original XML duration ticks interpreted at assumed 60Hz for side-by-side preview, without claiming genuine original PMD game's timing.
- Fan derivative asset rights/attribution and commercial usage require separate review before publishing. Original source binaries are in private Drive ZIP only, not public GitHub.

## Actual delivery, private Drive
- [Full original PMD0003 + G5R1 transformed atlas + native Godot XML bridge + previews + source scripts + QA/CMD/LOG/Handoff ZIP](https://drive.google.com/file/d/1OfPgOeS_JYyOcjvNhxWQBnLo6OfwcNYV/view?usp=drivesdk).
- **858,861 bytes, 176 files**, SHA256 `eee94e4fb8e388c5f685db53f36ef470e0088959d9b0a9a3bef3cae712578e97`. ZIP CRC, cold file hashes, cold source QA and cold native GPU tests PASS.
- [Actual authentic 0001→0002→0003 evolution sprites comparison](https://drive.google.com/file/d/1ak78Ig-FIWhMESY1cE-Q4lVgu3xVtERA/view?usp=drivesdk).
- [Actual original PMD0003 vs G5R1 variant 8 facing directions](https://drive.google.com/file/d/124Oq8D6Z2ZSykAgQqZCVQE-Fu8xlG4K7/view?usp=drivesdk).
- [Idle XML-timed original vs derivative](https://drive.google.com/file/d/1f7w-7GZj8lMwG7672heNnITZqduulWfu/view?usp=drivesdk), [Walk](https://drive.google.com/file/d/1kVS6BA32_J1CT0uo9m_Pkcwr0IwaC2CM/view?usp=drivesdk), [Attack](https://drive.google.com/file/d/1GaJ2MuLU5XfKAO113El_ujE4aBB7f7qB/view?usp=drivesdk).

## Hard rules and next gates
1. **PAUSE MAP WORK** until user unpauses; do not touch F2/SEALED FS project.
2. **Use each PMD ID's actual upstream source**. 0001 34 actions/1123 cells, 0002 12/682, 0003 12/698. Never make all PMD sheets the same.
3. True source-derived silhouette/magma changes inside each original cell. Preserve XML, offsets, shadows, anchors, original sprite sheet dimensions/facing, and frame border. Negative G5 `Swing` edge-crop regression must remain in QA.
4. Verify technical Godot XML bridge separately from official PMD game and VX SBS; never label bridge as official loader tested.
5. User must review final 0002/0003 *human art gate* and action animations. User's approved 0001 style is a direction guide only. No art PROMOTION without explicit approval.
6. Next useful integration work: authentic PMD original loader or isolated native VX SBS offset/facing/pivot test, and full chain art comparison; no invented visual mockups.
7. Every new milestone requires ZIP/source, QUICK_RUN CMD, negative/repro QA, LOG, CURRENT_HANDOFF and Drive/GitHub/Linear sync.
