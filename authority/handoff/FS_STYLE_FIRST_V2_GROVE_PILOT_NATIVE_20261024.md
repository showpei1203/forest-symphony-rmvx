# Forest Symphony｜Style-first V2 Grove Pilot｜2026-10-24

**Status:** ISOLATED NATIVE VX TECH PASS; full Elf Village visual benchmark NOT PASS; human Gate F NOT RUN; sealed Forest Symphony runtime NOT TESTED.

## User visual direction
The user reviewed v1's actual VX output using newly generated Ground and matching PAR and wrote 「效果很棒」. It was recorded as STYLE_FIRST_V1_USER_VISUAL_POSITIVE_FEEDBACK in Google Drive Authority v4, previous Handoff, and Linear SHO-39. This is an accepted **art-direction anchor**, not full-map visual or formal F acceptance.

## This iteration is an actual new-art scene
- V1 544x416 AI Ground, original 3 generated trees, 2 stones and 1 sign remain as the art anchor; no old B1 v8 Ground/PAR reused.
- V2 rebuilds Ground by compositing three separate AI-generated modular patches from the same ground-component sheet: two grass modules and one dirt-corner. All placements and SHA256s are in the single Scene Manifest and source ledger.
- New PAR cropped from the same original AI-generated fantasy forest prop sheet: stone well, village noticeboard, and flowering hedge. 9 PAR objects total. The crop box, binary-alpha candidate normalization, source-sheet SHA, scale, actual source SHA, foot anchor, occlusion and collision rect are recorded. Preserve private source rights constraints.
- Opaque Ground, transparent PAR, Owner16, Occlusion, Collision and complete Master derive from the same manifest. Ground+PAR vs Master strict RGBA 0 mismatches. Source-ground patch reconstruction, PAR source reconstruction, and Pixel Owner reconstruction all 0 mismatches.
- 202 reachable ground tile cells from spawn, 19 blocked. A well-front screenshot position initially chosen at (6,8) was actually blocked. The v2 Gate corrected the probe to legal (5,8) and added a real VX game movement test that blocks entry into the well body.

## Real Windows Game.exe proof and independent ZIP verification
- Manual RPG Maker VX Game.exe boots, supports player movement and blocked movement and has no automatic teleport.
- 11 actually captured native 544x416 Game.exe screenshots: v1 tree behind/front (four), spawn (one), and well/board/flowering hedge behind/front (six). **Outside-actor background mismatch 0 and illegal Owner occlusion mismatch 0 in each of the 11**.
- Perturbation tests: moving a PAR object one pixel produces 2,685 changed image pixels; shifting an AI Ground module one pixel produces 4,421. Both are detected.
- Private 30,275,813-byte ZIP contains the full original AI source package, source-ledger crop coordinate info, source code, all layer outputs, semantic masks, two isolated native projects (manual/automated), real screenshots, README in Traditional Chinese, quick-test commands, complete Logs, checksum manifest and current Handoff.
- Complete ZIP extracted into a new Windows directory, **241 individual file SHA256 matches**. From that extraction, all four steps passed: regenerate source Ground/PAR, rebuild actual native VX Game.exe, re-run 11 native captures, and redo all Owner/collision/negative registration gates. The final repack adds this audit and was revalidated (243 ZIP entries; all SHA and CRC).

**Verified private Google Drive playable ZIP:** https://drive.google.com/file/d/1o25hjZU07aqa4mEpbGSKFAW6Xql22vHw/view

ZIP SHA256: `a0fb306d8abac7475b70d753ed4333a09b4220fbe4d3f5dafaf0d39e50c59a4c`.

**Google Docs current handoff:** https://docs.google.com/document/d/1HYU0H8A2qikq_ukQCyyDWrAUmm7xxaqkAr8IvbxiWYo/edit

**Default workflow Authority:** https://docs.google.com/document/d/1Hfs7v5tctPVrMDLB_a_0o-85_ou_jLKKx3sdtk0v5I4/edit

## Fail-closed status and next work
V2's bright-green Ground patch boundaries need visual art-direction QA, not marked human PASS. Full grand sacred tree, varied Elf Village architecture, river cliffs/bridges and ground3-like detail level remain to be produced. V8's pre-existing Level0/1/2 bridge and treehouse tech **has not** been integrated or retested on this v2 new-art map; do not inherit its 25 VX interaction PASS as proof here. The formal sealed FS runtime also has not been changed or tested. Next phases: ground-patch color/transition harmonization using original generated style, new larger source-backed architecture and sacred landmark, then integrate the v8 Height/Owner schema into actual new Ground and run native regression anew.

Public GitHub includes **source code and authority only**, never privately licensed artwork or complete Game.exe ZIP.

## Post-backup local cleanup (2026-10-24)
Only the redundant V2 cold-extracted smoke-test directory was removed **after** Drive cloud metadata verification, E:/G: ZIP SHA256+CRC validation, and real native VX cold-extraction rerun PASS. Removed 242 duplicate files, freed **29.74 MiB**. Local audit: `E:\GameAssetToolLab_20261023\logs\STYLE_FIRST_V2_SAFE_CLEANUP_20261024.json`. Current V2 playable Game.exe/source/ZIP, approved v1 Style DNA baseline, sealed FS runtime and prior Forest FINAL are preserved.


## USER-REPORTED V2 WELL REGRESSION | 2026-10-24 | FAIL
The user tested the real playable native VX V2 ZIP and provided a screenshot showing **well sprite cropped on the left and wrong passage/collision**. Previous static 0px Ground/PAR mismatch tests only proved that the engine drew the *already-invalid asset* faithfully; they did not validate the asset's semantic completeness or usable collision. **V2 WELL CROP/COLLISION = FAIL; superseded by v2.1 source-level correction.** Preserve original V2 zip for reproducibility. The corrected release must use a full well source crop, explicit stone-ring and barrel collision, native eight-direction reachability and four invalid entry tests, screenshot proof and independent zip reconstruction. Full elf village and formal FS runtime remain unverified.
