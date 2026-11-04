# FS G20 / PMD0003 four SEMANTIC 3-key combat motions aligned 192px

Date: 2026-11-04 Asia/Taipei. ART PENDING, native PMD/XML and VX engine NOT TESTED.

## What was actually done
- Continued from G19 approved *technical* PixelLab Skeleton V3 padded attack, not from G16 failed attack.
- Reassembled exactly 12 pre-existing **real PixelLab** PNG frames from G13 (Waiting), G15 (Moving), G19 (Close Attack), G17 (Magic Skill Use).
- 3-column × 4-row RGBA sheet 576×768 with each cell **192×192** and fixed southeast 45° battle-facing reference. Retained original RGBA source pixel geometry without up/downscaling: G13/G15/G17 128×128 samples were embedded at offset x+22, y+26 into transparent 192×192; G19 source is already 192×192 and was copied unchanged.
- Removed exactly **33 disconnected alpha artifact pixels in Waiting F1**. No other pixel removal, no facial/costume/motion regeneration, no new paid API calls.
- Output per action: 3 named PNG `PMD0003_<ACTION>_1/_2/_3.png`, 3-key contact, individual action loop GIF and full transparent test sheet.
- Technical QA measured original-frame provenance, alpha bounding boxes, source allocation, native geometry untouched. G19 attack selected F1/F2/F3 centroid screen x 84.564 / 97.041 / 92.051, confirming visible forward movement in impact pose; centroid value is not substitute for human art approval.

## Actual verified output
- ZIP `FS_G20_PMD0003_45DEG_FOUR_ACTIONS_NATIVEPIXEL_QA_20261104.zip`
- Bytes **999700**, SHA256 `c9d82a3bcaeae47e5e90eff592353b6741a7044f6980c182755e71f6fe2d94d8`.
- 27 ZIP entries; 26 SHA256 references checked, CRC PASS.
- [Drive G20 folder](https://drive.google.com/drive/folders/1FvzR2qB5bLxJZ5jyIkpqE2bdLYAGEMfg)
- [Full G20 ZIP](https://drive.google.com/file/d/1eg4c28W3OdLak1_tKI6T2UFro8PXKrSg/view)
- [G20 human inspection four-action comparison](https://drive.google.com/file/d/1TsNAawNc2MjnCSavV2Yh2xAlUENsnVPM/view)
- [G20 transparent production-*test* 3x4 sheet](https://drive.google.com/file/d/1slmV8cevDpou_gXWRYm72frl4rZNmsqR/view)
- [Per-frame source and geometry QA JSON](https://drive.google.com/file/d/13QfWTQqAiOwvy4wK24ScO8HsSsEw50c6/view)

## Fail-closed gate
- This is NOT a verified native PMD sprite atlas. Source original PMD 0001–0003 raw animation, AnimData.xml, Shadow, Offsets have not been modified.
- The G13/G15/G17 master sources were 128; G19 original provider output 192. Resizing them to the PMD game's actual per-species cell size is a separate visual and integration task.
- All four are test candidates, not signed-off art. User's 0001/0002 concept and real PixelLab expansion begins after this stage as G21.
- A68 human actor development remains PAUSED.
