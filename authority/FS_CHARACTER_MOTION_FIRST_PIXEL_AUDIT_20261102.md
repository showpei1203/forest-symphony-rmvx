# FS 角色動作範本庫：首批原始像素驗證（2026-11-02）

## Grounded source
- [00_Reference_Original](https://drive.google.com/drive/folders/1JZL1RLbWECyZP_ddn-TSFjpCaw5C8jtr)
- [人物戰鬥動作範本](https://drive.google.com/drive/folders/1vhcZhifp-9NWN2zwN3jPGOwzg9vPupTe)
- The folder has **364 unique PNG files**, Drive IDs indexed completely in [manifest](./FS_CHARACTER_MOTION_LIBRARY_MANIFEST_20261102.json) (4 provider pages). This is **filename/metadata** analysis; only the three listed files below have been visually and pixel-cell inspected so far.

## Three actual image reads (not deduced from filenames)

| File / Drive ID | PNG canvas | Grid | Per-cell verified facts | Candidate use |
|---|---|---|---|---|
| [Kaduki1.png](https://drive.google.com/file/d/1HrGPub5RudIoG1qIWzhyGXG_IbHKma7l/view) | 96×128 RGBA | 3 columns × 4 rows, 32×32 | All twelve cells non-empty; 4 row orientations visible. Source full alpha bbox (5,1,90,128) | Cardinal directional walk/character facing reference, **NOT automatic 45° SBS battle reference** |
| [Actor783_2.png](https://drive.google.com/file/d/1W2iUe1hp9d73gSA_lDUd0AxoEvjx1O-R/view) | 96×128 RGBA | 3×4 | Entire **row index 2** has zero nontransparent pixels; last row (index 3) contains three low/prone frames; upper two rows contain alternate body poses | Promising falling/death/critical posture reference, **check actual choreography and identity before retargeting** |
| [$Actor101_1.png](https://drive.google.com/file/d/1PQEK9WP_c09wXcDnrv9OAJGkbfC4k9Vg/view) | 96×128 RGBA | 3×4 | All twelve 32×32 cells non-empty, different limb/pose silhouettes in multiple rows | Candidate full-body battle-action and animation range reference, **action row meaning not yet proven** |

### Pixel-accurate cell evidence
- `Kaduki1.png`: all cells populated, including full bottom row; source alpha bbox (5,1,90,128).
- `Actor783_2.png`: cells at (row=2,col=0/1/2) have `None` alpha bounds. Bottom row local alpha bboxes: (1,11,32,31), (1,13,32,31), (0,13,32,31). Do **not** infer a twelve-frame full-motion animation from file dimensions alone.
- `$Actor101_1.png`: all grid cells populated; source overall alpha bounds (0,0,95,128).

## Permanent application in FS
1. Group by source family before selecting a different actor sprite and confirm matching face/costume.
2. Use actual PNG transparency and per-cell bounding boxes to discover empty frames, partial FX, foot anchor, camera/facing and pose, **not a generic inferred 4×3 layout**.
3. Distinguish 4-direction 2D sprites (Kaduki) and angled battle actions (some Actor series); if camera doesn't match FS approved 45° southeast SBS, it is a movement **reference**, not an immediately usable target frame.
4. Original FS actor01 remains the **action semantics** authority; A62 run is user PASS; A63 Waiting and A64 Critical are technical candidates only. For PixelLab provide same-family images AND the exact action-specific source pose references to reduce failed paid generations.
5. Continue pixel-grounded sampling/classification of the remaining 361 PNG images only as needed for upcoming actions; annotate each additional verified image with Drive ID, native frame size, source camera, leg/head motion, FX and acceptance status. Do not claim they are all reviewed.

**QA:** This report is a three-source verified first sample, not an exhaustive interpretation of 364 files.
