# Forest Symphony V6 / P3 R5: NEW BLUE HOUSE SOURCE, GROUND EXCLUSIVE ART HOLD (2026-10-27)

## Authorized source-first actual work
Continued from P3 R4 failure: repeated polygon segmentation of original gold/ochre house source removed the grass AND chopped the building's lower walls. User's Ground Exclusive Ownership V1 is mandatory: ALL free-standing grass/dirt/path/soil pixels belong Ground, NEVER object/PAR. Only roof moss, attached vines and tree roots have limited exception, requiring human independent visual review.

On Windows Remote Desktop Commander, 28 distinct previous house/cottage/roof candidates were deduplicated and reviewed from the FS isolated asset library. Selected alternate 303×251 blue-roof cottage (FS STYLE FIRST V233 generated source) to preserve roof, windows, arched door and chimney as original source RGBA, **exclude 15,696 previous backdrop/ground/ambiguous pixels**, and reconstruct exposed stone masonry ground floor explicitly as architectural Source independent of Ground B. No Ground B pixels were sampled into the architectural wall source.

### Three real artwork trials
- **R5A**: newly rendered stone base produced flat, artificial panels; explicitly ART REJECTED, with exact image comparison.
- **R5B**: texture and masonry blocks improved, but the left ground-floor wall was incomplete, leaving a visible hole; ART REJECTED.
- **R5C**: rebuilt full left masonry facade, kept source roof/door/windows/chimney; delivers a completely transparent source sprite `outputs/BLUE_HOUSE_R5C_REBUILT_COMPLETE_NO_TURF.png` with separate new masonry layer `outputs/BLUE_HOUSE_R5C_INDEPENDENT_STONE_FACADE.png`. Lower wall now structurally complete but stone texture still looks more regular than source art and SCENE21. Upper roof green growth may partly be old scene backdrop: Ground-exclusive candidate TECH only, **HUMAN ART HOLD**, no fake PASS.

### Same-Manifest 544×416 test scene
Ground B unchanged. R5C house (18,24); existing complete sacred tree (323,22); two transparent barrel prop source (268,225); 57×57 soft flower shrub (450,307). One manifest produces GROUND, PAR_COMPLETE, owner index, actor at four positions, per-object placed alpha and 17×13 hard collision. 15/221 tiles blocked by actual new house/walls, barrel and tree trunk, door-front tile (4,7) walkable and connected to spawn (8,11), soft shrub walkable. RPG Maker VX actual source Actor1 32×32 used for render, NOT claiming a native Game.exe run.

**13/13 tech QA PASS**: source/canvas, reconstruction, alpha owner, ground unchanged, four source placements, single-manifest recompilation zero pixel difference, new geometry collision, door approach, 1px artificial forbidden original grass/soil injection rejected, and intentional house shift 1px detects 31,546 changed pixels.

### Archive, verification, and tooling
Private R5 ZIP `FS_V6_R5_BLUE_HOUSE_GROUND_EXCLUSIVE_SOURCE_TECH_20261027.zip`, 11,795,050 bytes, SHA256 `49833a094e9be6de299ae4e8fbe2915fad1ca758f4978dc0042397db0990d2e5`. Windows cold unzip checked **54 individual file SHA256**; full replay original source build + R5B + R5C + scene compile/QA reproduced exact world PNG SHA256 `b6a020739fa3cf959b0575b2d9455fda5220c6cdbac94ac575df6d04508996fd`.

Drive private ZIP: https://drive.google.com/file/d/1w2ru1qttBA1WN_3Ma_05TOnzlLfOLCey/view
Drive R5 actual source, before-after 4×, real composite and Actor1 image review: https://docs.google.com/document/d/1LXfOAv34bQ5uv73NRrrayNclTwpkW4bVGS5Zzx9wkRA/edit
Windows isolated workspace: `E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261027\P3_R5_NEW_HOUSE_SOURCE`; local ZIP under `E:\GameAssetToolLab_20261023\deliveries`.
Executable Python (no private source PNG committed to GitHub):
- `tools/fs_map_v6/build_blue_house_structural_source_r5.py`
- `tools/fs_map_v6/refine_blue_house_masonry_r5c.py`
- `tools/fs_map_v6/compile_blue_house_ground_exclusive_r5.py`

### STOP / defect annotations
- **FS-ART-114 / masonry style mismatch**: new pixel stone appears synthetic and does not yet match source-level high-detail masonry. R5C remains ART HOLD despite complete geometry.
- **FS-ART-115 / roof moss uncertainty**: source green above roof may include old scenery lawn/growth unrelated to house; HUMAN review required. Do not relabel uncertain pixels as moss to satisfy source rule.
- **FS-ART-116 / image generation contact-sheet output is not production source**: an AI-rendered annotated contact sheet is not independent transparent building art, may contain fake labels, and was excluded from asset ZIP. No code should try to extract authoritative source parts from that representation.
- Soft-flora GrabCut, barrel contact and sacred-tree attachments remain independent ART review candidates. Native VX Game.exe, RGSS2 events, real-world camera scroll NOT RUN. User ART APPROVAL still PENDING. No alteration to F1R1 A04, sealed scripts, or other concurrent map conversation.

### Next
Source-level retouch and fidelity improvement of R5C new wall and uncertain roof growth, use exact 1× Ground B + VX actor and SCENE21 human check. Then separate stone well/sign/fence/rocks that intrinsically lack turf before broader village-world 1280×928 release. Never stamp 544×416 as repeated Ground tiles.
Ground Authority: https://github.com/showpei1203/forest-symphony-rmvx/blob/main/authority/art/FS_GROUND_EXCLUSIVE_OWNERSHIP_RULE_V1_20261027.md