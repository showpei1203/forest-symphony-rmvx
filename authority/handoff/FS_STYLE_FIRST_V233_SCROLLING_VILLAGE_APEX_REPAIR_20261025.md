# Forest Symphony｜Style-first v2.3.3｜CURRENT HANDOFF｜2026-10-25

**State:** ISOLATED REAL RPG MAKER VX TECH PASS / NEW BUILD HUMAN VISUAL PENDING / FORMAL FS SEALED RUNTIME NOT TESTED. Existing V21 well USER PASS, V22 Sacred Grove USER OK and formally SEALED FS baseline remain unchanged. V232 house-clipping user failure preserved.

## Latest PRIVATE, runnable release

- [Verified private Drive ZIP](https://drive.google.com/file/d/1X9A7c_oZD-gHtqsUvp0hrnK8PxFcOlF-/view?usp=drivesdk).
- `FS_STYLE_FIRST_V233_FULL_ARCHITECTURE_SCROLLING_VILLAGE_20261025_PRIVATE_PLAYABLE.zip`.
- Size **26,048,056 bytes**, **293 ZIP entries**.
- SHA256 `4f0a4bf16548d0c1de788c12a30fbac2f9807fd96b4ba1820e040d6feda6f452`.
- Two Windows native manual entry points: `START_V233_BLUE_HOUSE.cmd` and `START_V233_GOLD_HOUSE.cmd`. No auto-test flag in either. Full seven-stage developer gate: `RUN_V233_ALL_CHECKS.cmd`.
- Per-file checksums, seven source/native verification scripts, all original and repaired private PNG assets, scene manifest, 17×18 masks, three Game.exe test builds, 16 true Windows native RMVX screenshots, logs and handoff are included in the private Drive ZIP.

[Drive V233 handoff document](https://docs.google.com/document/d/1wun-AhutJ02OsPZ4Kc1kxeodpYsRYTu-5mzt__lzbJE/edit?usp=drivesdk), filed within the FS production authority folder.

## Root causes of repeated 'houses still clipped' feedback

1. The 1434×1097 AI village *source master* was already a capture of a Windows RPG Maker VX game window with its titlebar. The blue roof apex was cut off **in the reference itself**, before segmentation. Merely widening source ROI or adding alpha padding cannot recover pixels absent from the screenshot.
2. The v232 544×416 17×13 world tried to fit a 229px blue and 183px ochre house, leaving no proper world margins. User repeatedly saw clipping despite source-to-render 0-pixel tests. Such tests prove the renderer maps supplied source, not that supplied art is complete.
3. Previous v23-v232 partial segmentation could discard legitimate walls, flowers, steps and misclassify walkable grass as PAR. Those results remain historical negative fixtures.

## Implemented in isolated v233

- Blue roof peak received **22px of explicitly SYNTHETIC pixel-wood reconstruction** sampled from roof-post color/material in original image; never describe the missing pixels as recovered authentic original. `input/V233_SOURCE_CAMERA_APEX_REPAIR_LEDGER.json` records provenance.
- World grows **17×13 → 17×18 tiles** (**544×576** source canvas), while VX viewport remains 544×416. Real native scrolling in camera_y 0…160. The first 384px of approved high-detail AI Ground remains pixel-identical; the added bottom 192px is deterministic AI-ground donor sampling with Bayer seam blending and no blur.
- Seven individually source-backed PAR objects. Blue roof first visible y=33 in world, gold house base y=526, **85px vertical space between their visible silhouettes**. Gold manual start at camera y=160 displays entire gold structure at viewport y=197…366.
- Single `scene_manifest.json` produces Ground, PAR, Collision, Occlusion and PixelOwner16. 40 blocked tiles and 266 spawn-reachable tiles. Existing V21 well and V22 sacred tree source hashes unchanged; formal FS SEALED runtime untouched.

## Real Windows RMVX technical evidence

- **16 authentic `Game.exe` screenshots**; 134 actual player directional moves to 8 standing positions per house; eight house-wall rejected moves plus V21 well and V22 sacred-tree regression denials (**10 blocking tests PASS**).
- 0 mismatch outside moving character for Background and illegal PAR/PixelOwner occlusion across all captured frames. On vertically scrolling levels the OS screenshot can occur a few pixels after game-loop camera coordinate logging: verification registers the observed frame to the shared Master over a bounded neighboring-camera search, then retains **zero tolerance** for background/illegal owner mismatch.
- Gold full-view actual Game.exe has camera=(0,160), full architecture visible between screen y=197…366, 0 background difference.
- Ground+PAR→Master and recompilation of Owner and physical Collision all RGBA/semantic exact. A deliberately shifted blue house by 1px gives 45,638 changed RGBA channels, showing the registration gate fails closed.
- **Independent, clean, offline ZIP cold-extract PASS:** 291 source files SHA verified, seven stages of original source reconstruction, layer compilation, routes, native Game.exe build, 16 real screenshots/134-step walk, gold manual full view and negative-source semantic audit all PASS. Latest audit: `logs/V233_COLD_EXTRACT_REBUILD_AUDIT.json`.

## Scope and next thread

Use the Drive handoff as the *authoritative resume prompt* and the verified private ZIP as test/asset source. USER HUMAN V233 visual QA **PENDING**. These native smoke gates do **not** establish complete richly detailed Elf Village, Castle Town, multilevel bridge/treehouse (V8 Level0/1/2) or formally sealed FS acceptance.

SHO-39's current default Modular Asset Kit flow and user's manual geometry approval **remain authoritative for NEW maps**. This work is an **explicit user-requested Legacy Reconstruction Mode repair of an existing flattened AI scene**, not a change to the default modular asset production rule. Continue only after visually accepting both houses; preserve original Source, partial failure samples, semantic masks, test logs and per-version ZIPs. Public GitHub stores written Authority and source-only code, **not** private AI mother images, commercial-unclear Sprite PNGs, Game.exe binaries, or private ZIP.
