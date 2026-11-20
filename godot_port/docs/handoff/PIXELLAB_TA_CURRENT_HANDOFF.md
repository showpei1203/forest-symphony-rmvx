# PIXELLAB T-A｜CURRENT HANDOFF
Updated: **2026-11-21 Asia/Taipei**. Owner: T-A character/motion branch.

**TARGET:** T-A / ACTOR01, 45° 3/4 battle-view white hair. **STAGE:** M1 real 12-frame candidate + M2 runtime-engineer wiring; M3 blocking artwork remains. **STATUS:** ART_HOLD (NOT VERIFIED_PASS).

## BASELINE
- Repository: `showpei1203/forest-symphony-rmvx` dedicated branch `feat/fs-pixellab-ta-actor-20261121`.
- Source A62 original approved idle SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`.
- A35 PixelLab RUN 8 source SHA256 `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`.
- A52 real PixelLab Skeleton V3 original Body SHA256 `a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f`; original A52 job `094a45f9-c279-4c06-94e4-a1708a13daac`; original Handoff https://docs.google.com/document/d/1D1n1NSHW4xQS_vhkq79BkxMZr_V5xvKe/edit .
- No A54 newer source found via this round's accessible Google Drive/GitHub search; no unverified override of A52.

## DELTA: what was actually done
1. Read original approved A62 / A35 RUN / A52 ATTACK Body, Weapon, FX bytes from private Drive; computed raw sha256 and inspected candidate motion sheet.
2. **RUN12 candidate atlas** produced from actual A35 RUN8 plus 4 algorithmic optical-flow in-between frames; confirmed 12 different image frames at 64×64 and 256×192. A35 original leg exchange is visible. This is **not a new PixelLab model result**.
3. Kept existing A52 **ATTACK12** original source exact, including distinct Body/Weapon/FX, F7 at 0.63 sec and 70ms hitstop metadata. No already-passed old animation was overwritten.
4. New public *Godot 4.7.2* rig: `godot_port/scripts/animation/FSTAActorMotionRig.gd`, 3 separate sprites, 12-frame RUN and ATTACK timing and fail-closed cloud private atlas loader. Isolated `TAActor01Preview.tscn` + script to play RUN/ATTACK with staged private Drive files. No change to damage, map, old ATB, VX or main.
5. Dedicated CI regression in `.github/workflows/fs-ta-actor.yml`; 4.7.2 official download + headless engine tests, no owner-private images inside public CI.
6. Motion manifest in `godot_port/docs/handoff/TA_ACTOR01_MOTION_CANDIDATE_MANIFEST_20261121.md`, failure log in `godot_port/docs/handoff/TA_ACTOR01_FAILURE_LOG_20261121.md`.

## ARTIFACTS (PRIVATE GOOGLE DRIVE, verified cloud readback)
- Folder: https://drive.google.com/drive/folders/1Di5InlU4yuiFMsMzcHw21YPiqTKLUmeT
- RUN body real candidate: https://drive.google.com/file/d/1_iP5j4LRtPXyd-VKpmDiotmlr-Z7_ziX/view
- RUN Weapon placeholder: https://drive.google.com/file/d/1377yLyqjLh8a5T8jnmhWIxrVdX3HbLLs/view
- RUN FX placeholder: https://drive.google.com/file/d/1p2878CC0FXnHQSR8exER_YJPVwgKH5k9/view
- 12+12 storyboard: https://drive.google.com/file/d/1tmdxXfHbt5gPyROa48kXrTWgu2PhmWfF/view
- A52 original Body/Weapon/FX remain only in their previous private Drive location.
- Source SHA256 and requested staging filenames: [Motion Manifest](TA_ACTOR01_MOTION_CANDIDATE_MANIFEST_20261121.md).

## PIXELLAB
- 2026-11-21 `Animate with Text v3`: **NOT RUN**. `Skeleton v3`: **NOT RUN**. API/model job: **NONE**. New model expense: **0**, no invented price.
- Existing A52 Skeleton V3 paid 3.0 units already completed Nov 16, **not today's expenditure**.
- Cause: available connected tools do not expose PixelLab generation API or authenticated provider action. Never call offline optical flow "real PixelLab" generation.

## QA gates, do not conflate
- **SOURCE SHA / IMAGE FORMAT:** PASS on input PNG SHA and candidate atlas 256×192 / 12 distinguishable cells. Approved source identity preserved in source selection; candidate full animation visual remains HOLD.
- **NEW GODOT ENGINE RIG (synthetic in-memory atlas):** PASS in official GitHub Actions Godot 4.7.2 run https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44830768516 : layers, loop, F7 0.63 contact once, cancel. This runner was from first rig commit. After scene preview commits, verify newer run separately.
- **GODOT NATIVE REAL PRIVATE PIXELS:** NOT RUN (no authorized private Drive-to-runner staging); original A52 prior proof does not count as new T-A candidate art proof.
- **ART:** HOLD: A35 F6/F7 remains suspect, four newly interpolated in-betweens need whole-motion review, RUN has no validated equipped sword, 12 distinct frames is not same as 12 valid run poses; ATTACK is existing approved A52 reused, not a second fresh animation.
- **M4 REPRODUCIBILITY:** NOT RUN.

## FAILURE LOG / blocker gate
- B1 Major / ART: RUN weapon layer transparent placeholder, identity/equipped weapon **not preserved**. Need real separate weapon consistent with source.
- B2 Major / ART: A35 RUN F6/F7 previous deformation not resolved; new interpolation does not repair existing source.
- B3 Major / AUTH: fresh PixelLab v3 unavailable in current tool connections; no new provider-backed run.
- B4 Major / TEST: private source image staging not present in public GitHub CI, cannot claim genuine private-art Godot GPU PASS.
- No micro-pixel fine-tune cycles. **0/2** repeated minor-fix loops.

## NEXT_MACRO_UNIT
Generate **one entire native PixelLab Text v3 RUN12 cycle** grounded in original A62, selecting correct left/right boot poses, 45° view and separate sword all at once; if this fails twice, switch to Skeleton V3 keyed limbs. Replace only RUN candidate on T-A branch/private Drive, then stage six legal atlases into isolated Godot preview, capture actual 1× GPU animation, verify 0.63 attack contact and artwork side-by-side; then validate second motion/character for M4. Do not revert to VX or rewrite unrelated game systems.

## STORAGE / SAFETY
Only T-A branch GitHub text/GDScript and owner-private Drive binary sprites/QA. No user's PC new repository. Existing baseline unchanged, not merged into main. Google Drive folder list READBACK passed. No PixelLab paid retry or API secrets.
