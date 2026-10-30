# Forest Symphony | Ground-only v2 Stage5 R16 | 2026-10-31

CURRENT STATE: R16_NATIVE_CURVED_LAYOUT_READY / GROUND_ART_FAIL / PAR_NOT_STARTED / FORMAL_SEAL_NO.

## Actual Stage5 build
- Built new non-symmetric cubic-spline village street geometry constrained by existing House A (144,208), House B (400,208), center (272,240), west (0,240), east (543,240), south (272,415) anchors.
- The south route bends west of sacred tree root and rejoins the southern exit. All six anchors belong to the same 4-neighbor road component. ROAD_MASK pixel area: R15 legacy 47483; R16 version 19287. ROOT_CONTACT overlap 0.
- Preserved prior eight masks untouched under masks/ and placed eight versioned R16 masks in new_masks/. Sealed K4/FS map, scripts, collision and passability were not modified.
- Used FS A2_VSCliff native 1x grass and dirt sources with exact 16-bit per-pixel OWNER_X/OWNER_Y and a side-by-side actual image comparison of R15 and R16.

## Verification
- Independent verify_r16.py: 21/21 PASS, including native source SHA, eight new mask dimensions, real geometry change, six connected anchors, root exclusion, each RGB output pixel equaling A2 original owner coordinate, terrain-only whitelist and 1px / +16px fault injection.
- Cold unzip and rerun build_r16.py + verify_r16.py: 26/26 original-source/output PNG/TIFF SHA identical, 21/21 QA PASS again.
- R16 Ground SHA256: 10a66146aaf1ae833e0f62aa8a4d0d6a838856d8c77eca11a4ed6fe3d1fb3df2.
- Full private ZIP 1937377 bytes, 36 entries, CRC PASS, SHA256 f45187eebc2809498655e1f224789c0171259cc417fce30c803fedfaf70a4c0f.
- Verified Google Drive upload, metadata and downloaded raw bytes: https://drive.google.com/file/d/1OFbxk0sYNo0plXKB29zqItoXrY7yP1Ze/view

## Artistic failure and stop-loss
Curved roads visibly improve on the rigid symmetric R15 crossroads. The grass lacks believable natural flower/leaf clusters and varied environmental rhythms compared with correct ground3 (1), and the source pixels still repeat. GROUND ART FAIL. NO PAR or VX/Godot native scene. Engineering PASS is not Art PASS.

NEXT_COMMAND: Keep R16 curved layout/owner system and create truly low ground-level floral/leaf clusters in varied non-grid distribution, verify against correct original FS ground3 at 1x and actual 32px actor. Re-run G0/G2/G3/Human Art G4/G5; only after art approval move to new separate House A/B and Sacred Tree PAR.