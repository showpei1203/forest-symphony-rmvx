# FS A67 / PMD0001 ORIGINAL-PIXEL-FIRST MAGMA EDIT + 3-KEY ACTION SEMANTICS
Date: 2026-11-03

## Source and strategy
User rejected A65-V3C art and instructed: stop regenerating, edit ORIGINAL example sprites; start PMD sprite editing with semantic actions and `_1/_2/_3` three-frame naming.

- A65-V3B/V3C are **superseded as art candidates**, kept for traceability. No further generative body poses, lighting effects or reconstruction as an unapproved substitute for native source action.
- PMD0001 actual original: `SOURCE_0001` from `P3_R2_0001_STONEBACK_SOURCE_XML_20261026.zip`, original PMD 8-direction source animation atlases/AnimData.xml/Offsets/Shadow.
- Existing source-derived Stoneback geometry: `STONEBACK_0001` from same verifiable ZIP. This is a prior pixel edit of native original artwork, not an AI-created separate sprite.
- A67: deterministic source-native pixel recolor in magma-orange hues and restrained in-rock-pixel lava fissures; no image generation, no PixelLab tokens, no pose reconstruction. All 34 PMD action atlases edited with their native frame counts, frame sizes and full 8 facings.
- Original alpha masks (pixel exact) preserved in all 34 action atlases. Orig frame content preserved as three-key sample files for four semantic actions, original full atlases available in prior original ZIP. Original PMD XML, Offsets, Shadow **BYTE IDENTICAL** to source-derived Stoneback baseline.

## Semantic three-key filenames
In `3FRAME_ACTION_SEMANTICS/<FS_semantic>/`, `PMD0001_<FS_semantic>_1.png`, `_2.png`, `_3.png`, with original and Stoneback counterparts and 8x preview GIF. This is the **production/review keyframe scheme** only. The native atlas in `NATIVE_PMD0001_LAVA_CANDIDATE/` retains every native animation frame.

| FS semantics | PMD source | actual native positions, zero-based | native count |
| Waiting | Idle | 0,1,2 | 3 |
| Moving_to_Close_Attack | Walk | 0,3,5 | 6 |
| Close_Attack | Attack | 0,5,10 | 11 |
| Magic_Skill_Use | Charge | 0,5,9 | 10 |

- Preview sampled native direction ROW 7, 0-based, pending human approval of chosen orientation; don't label 45° formally without native-camera testing.
- This sampling is not a claim that each source action physically has only three frames; do not overwrite original durations or event timing.
- Attack source HitFrame 5 and Charge source HitFrame 5 are deliberately included as middle samples. PMD native original gameplay will continue using all 11/10 frames with its untouched XML.
- `NATIVE_PMD0001_LAVA_CANDIDATE` is complete source-shaped 34-action native candidate, but **art pending** and **native integration pending**.

## Deliverables, actual verified
- Private Drive ZIP: https://drive.google.com/file/d/19_es_liNTKmsiJj6HaLwaDW75ItgAbji/view
- Side-by-side native original / Stoneback / A67 preview: https://drive.google.com/file/d/1Uc3_JSRQL2jKazA6W18JCpXLSmPyKcgm/view
- Local ZIP path: `/mnt/data/FS_A67_PMD0001_SOURCE_PIXELS_3FRAME_SEMANTICS_20261103.zip`
- SHA256: `240bcbe7bf742ba2208917f77f40282908ce864707a7be95571a1c643a8e94cf`
- ZIP size: 418121 bytes; files: 152; ZIP CRC PASS, internal SHA256 manifest 151/151 PASS.
- Candidate action atlases: 34 with same source-geometry alpha; 34 XML-compatible animations, sprite file names unchanged.
- Sample four semantic actions plus original and Stoneback keyframes, each three PNGs, cropped and full 8x GIFs, one original-to-A67 4-column comparison sheet.
- Representative palette-modified pixel counts: Idle 4940, Walk 9880, Attack 18115, Charge 16540. Restrained in-rock crack edits Idle 52, Walk 104, Attack 196, Charge 80 (across all 8 facings and all frames). Pixel changes prove distinct edits, not human art quality.

## Current gate and next recommended work
- Technical source geometry QA PASS; 34 alpha masks unchanged, all source native support files retained; user art not approved.
- **Not game-integrated**: no native VX/Godot visual playback/occlusion test.
- Before expanding to PMD0002/0003, inspect native 1x for detached/crack artifact, rock/fissure structure and body silhouette. Compare approved A25 lava-monster direction and correct species shape only with original native pixels.
- Native FS action source `$actor01_1/_2/_3` should receive the same original-frame editing strategy separately; do not claim FS A65 character has been modified by A67 PMD edits. Original FS character/historical A62 approved state remains unchanged.
- When art approved, align PMD's true action names/8 directions to FS semantics and test in native game. Treat 3-key previews as QA, not engine timelines.

## Prevent recurrence
- No one-off concept images; no resampling/repainting from imagined 45-degree view.
- No unverified human-art PASS.
- Never quietly replace 6/11/10 source frames with 3.
- Carry all native XML/Offsets/Shadow byte for byte; human visual pass and actual native engine pass are separate gates.
