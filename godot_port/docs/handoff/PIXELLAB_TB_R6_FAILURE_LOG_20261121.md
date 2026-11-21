# Forest Symphony | T-B V6 Failure Log | 2026-11-21

Branch: `feat/fs-pixellab-tb-monster-20261121`. Godot **4.7.2** is the only target engine. PMD0001 forest symphony monster pipeline; keep all private art in Google Drive.

## Actual result and art gate
PixelLab Skeleton v3 **real generation**: completed `job_id=3fea688e-1c8c-451c-aa3f-84941166dca2`, `generation_id=67dd6734-d3a5-4dc7-a860-ebb797f20964`, **11 frames x 96x96**, actually charged **3.0 subscription generations**. Official provider returned 11 RGBA PNG frames. This is NOT a speculative prep step.

Godot 4.7.2 **real private provider sprite** native event test PASS; Xvfb OpenGL Mesa llvmpipe 11/11 native viewport screenshots captured. Seven technical QA checks PASS. **ART HOLD** remains mandatory because F5's bite does not read as a wide open jaw, and perfect source style/view is not proven.

## Blocking and nonblocking issues
| ID | Classification | Evidence | Action | Limit |
|---|---|---|---|---|
| V6_PIXEL_ART_JAW_WEAK | **BLOCKER ART** | F5 generated from pose with custom jaw joint pulled +7px nevertheless visually reads as forward arm extension, mouth appears closed/mostly a tan stripe | Next: shape-author a clearly open-jaw F4/F5/F6 trio; use frame-specific masked inpainting or hand-drawn upper/lower lip separated at hinge. Keep PixelLab skeleton full-body motion. Stop changing only skeleton jaw offset | Mandatory method change |
| V6_POSE_VIEW_NOT_APPROVED | **BLOCKER ART** | Character looks right-front 3/4; exact FS southeast 45° game combat camera not human approved | Native in-game composition + human view gate needed | Do not mark approved |
| V6_SOURCE_REDRAW_DRIFT | **BLOCKER for pixel-exact mother identity** | Even first and last PixelLab output frames are redraws, about 902 and 935 pixels different from source on 96px canvas, but silhouette and basalt family still recognizable | Preserve original source F0/F10 separately; source-lock pipeline normalization candidate later, ensure smooth transition across adjoining frames | Not simply recolor |
| V6_F6_STRAY_PIXEL | **NONBLOCKING (1st correction due)** | F6 alpha-connected components at threshold >24: one main 951px sprite + 2 isolated pixels | Separate surgical cleanup once full bite motion approved | Max 2 pixel-polish rounds |
| V6_MANUAL_KEYPOSE_JAW_HINGE | **BLOCKER ART** | Pre-provider manual V6 first render had detached-looking lower jaw after full translation; hinge-rotation alternative also visually unnatural | **Rejected preflight only**; not a final exported attack or PixelLab generation | Do not repeat same jaw patch strategy |
| V6_ENGINE_QA_SCOPE | QA boundary | Real provider image imported and rendered by Godot, but capture uses Mesa llvmpipe software OpenGL not owner's hardware GPU | Record renderer faithfully; don't claim user's GPU hardware proof | No fake GPU PASS |
| V6_LICENSE_GATE | PRIVATE | PMD original source rights/history must be retained; no public PNG upload | Keep raster and provider outputs in private Drive; only code/text GitHub | Hard policy |

## True costs / provenance
- Original source SHA256 (64px): `fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c`.
- Authenticated first frame SHA256 (96px): `e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72`.
- PixelLab **original provider saved atlas** SHA256: `6d9b6690c3097225bf8fbba5f14eb5fbd667e815577543298898e71ea8e56252`.
- The private exact RGBA equivalence after lossless-indexed transport is checked; transfer PNG bytes differ, but full RGBA pixels are preserved.
- Subscription billing: **3.0 generations**. Dollar equivalent not reported by API, so never claim a USD price. Generation ID above.

## Next complete milestone
**V7 verified bite keys**: keep all 11 V6 body poses, alter only F4/F5/F6 mouth and foreleg overlap with truly separate lip/keyframe masks or targeted provider inpainting, then run same Godot 4.7.2 full 11F native, exact-once Hit and actual-size 45° art review. Only after this complete chain passes do a second different species. Avoid another full-chain blind PixelLab call before identifying bite keyframes.
