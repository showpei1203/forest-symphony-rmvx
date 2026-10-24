# Forest Symphony｜Style-first V231 Full Cottage Source/Scale Fix｜2026-10-25

**Status:** isolated Windows RPG Maker VX TECH PASS. User V231 human visual acceptance PENDING. Formal Forest Symphony SEALED Runtime NOT TESTED. Full rich Elf Village benchmark NOT PASS.

## User-reported V23 failure and root cause
The user tested the actual V23 native executable and reported BOTH house sprites clipped and under-sized. The original 1434x1097 AI Elf Village master still contained complete roofs, facades, side walls, front steps and accessories. V23 extraction/segmentation omitted legitimate image content, and later transparent padding did NOT restore it. V23 house crop/scale therefore remains USER REPORTED FAIL, even though its source-to-engine pixel alignment was 0 mismatch. Preserve V23 as negative QA history.

## V231 real source repair
Both house images were newly extracted from the ORIGINAL mother image via documented manually traced full-resolution polygons, image provenance SHA, nearest-neighbor resize and 7px transparent padding. This is NOT a resize of the damaged old sprites. Exact source polygons, original-image crop and output hashes are in the private Source Ledger and six portable replay scripts.

- Blue house: OLD 153x130 to COMPLETE 228x206; 69,173 source-object pixels.
- Ochre house: OLD 149x105 to COMPLETE 219x168; 59,450 source-object pixels.
- The approved 544x416 painterly AI Ground is unchanged. Seven source-backed PAR sprites include both complete houses, user-accepted V21 well and V22 sacred tree. Placement changes exist only in isolated V231. All sealed baselines preserved.
- Architecture semantic Alpha/Occlusion/Wall-contact Collision are separate. Roofs do not physically block walking. 42 blocked tiles and 179 spawn-reachable tiles.

## Real native source/collision/visual QA
- Windows RPG Maker VX Game.exe manual playable boots and moves without auto-test flag.
- 16 actual Game.exe screenshots (8 positions per house) have ZERO outside-actor background drift and ZERO illegal PixelOwner foreground occlusion drift.
- Native actor actually walked 132 direction steps through reachable routes; 8 house wall intrusion tests blocked; 2 accepted well/sacred-tree collision regression tests blocked.
- Strict source and semantic compiler: Ground+PAR Master RGBA mismatch ZERO; source Owner16 and Collision recompile mismatch ZERO. Crops have true transparency, no hidden RGB and 7px source padding.
- Negative: deliberately shift blue house one pixel and get 34,093 changed RGBA pixels. The old clipped source and roof-as-solid-body regressions are rejected.
- A 15-pixel test delta at x12..19,y328..329 arose from moving actor feet in the native character frame. Audit actor bounding envelope was corrected to foot+12 only after pinpointing these pixels; outside-actor background and illegal Owner occlusion remain STRICT ZERO.
- Independent ZIP cold-extraction: 236 file SHA256 verifications and SIX complete native rebuild stages PASS: full source re-extraction, layer compilation, route planner, Game.exe build, 16 native frames and real walking, semantic/negative audit. Final ZIP includes cold report, tested for per-file SHA and ZIP CRC.

## Private playable release
Google Drive: https://drive.google.com/file/d/1_K6CFCZZG_JnEhwo6FruL3rFfirLrhNH/view?usp=drivesdk

ZIP: FS_STYLE_FIRST_V231_HOUSE_SCALE_SOURCE_REPAIR_20261025_PRIVATE_PLAYABLE.zip
Size: 20,841,764 bytes. Entries: 238.
SHA256: 1476fc9b34cf844ccf44d774891fe2a44d360262b9e6478c47e57032a2fb0b61

Unzip on Windows and run START_V231_GAME.cmd. Developer-only RUN_V231_ALL_CHECKS.cmd uses Python/Pillow/rubymarshal and a graphical desktop. Full Source/Native/LOG included in private ZIP.

Current Google Drive Handoff:
https://docs.google.com/document/d/1t0KNS8HRg6cVGNylqdgbZEwz9jXIodPfD2t__HyhHeE/edit?usp=drivesdk

## Fail-closed scope
User Human Visual for V231 is PENDING. Neither rich reference-village completeness, Castle Town, old V8 height-aware Level0/1/2 bridge/treehouse integration nor the formal Forest Symphony SEALED Runtime is passed by this isolated test. Previously accepted V21 well, V22 sacred grove and V1 art direction remain preserved. Publish source-only Python programs and Authority to this public repository; preserve original AI master, source PNGs and Windows Game.exe/ZIP only on the user's private Drive.


## 2026-10-25 Post-Drive verified cleanup
After Drive cloud metadata confirmed the private ZIP, E:/G: SHA256 plus ZIP CRC matched, and six independent native cold-extraction gate stages passed, removed ONLY the redundant V231 cold-extracted smoke-test directory (237 files; 20.73 MiB). Original V23 negative source, accepted V21/V22, current V231 source/Game.exe/ZIP and all formal FS sealed baselines remain unchanged. Local audit: E:\GameAssetToolLab_20261023\logs\V231_SAFE_CLEANUP_20261025.json. The delivered private ZIP hash remains 1476fc9b34cf844ccf44d774891fe2a44d360262b9e6478c47e57032a2fb0b61.
