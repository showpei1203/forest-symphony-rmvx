# Forest Symphony | T-B R14 | 2026-11-22 | Monster art-only production Handoff

## Source of authority and scope
Latest R13 CURRENT Handoff remains authoritative. **No battle engine, ACT/ATB, HUD, EnemyID, T-A, T-C or main modifications**. Only source-locked monster art, true PixelLab Sprite Sheets, provenance, art-only Godot 4.7.2 previews and QA. Preserve previously owner-approved PMD0001 V6 Attack and TB02 LeafBat R8 bite exactly; all old R13 PNGs preserved byte for byte.

## Completed real work
- Two separate ORIGINAL monster families, **TB02 Leaf Bat / PMD Lava Frog**; Stages 1,2,3 of each remain their own authored and source-SHA-locked shape, not recolors/resizes.
- For EACH 6 forms, **three new real PixelLab Skeleton v3 jobs**:
  - CHARGE **10 genuine frames**: form-specific energy accumulation and posture held.
  - RELEASE **9 genuine frames**: begins from the real **PixelLab Charge frame F6** of the SAME creature stage, for continuity. Bat wing-cast or frog mouth/magma release (external projectile FX not fabricated).
  - REVIVE **11 genuine frames**: FIRST FRAME source derived from real SAME-STAGE KO **last (F7) 8-frame animation**, transitions from collapsed to standing/flying.
- **18 genuine provider jobs x 3.0 provider-reported generations = 54.0 generations; 180 NEW AI-generated PixelLab frame slots.** All 18 exact n/size/alpha/no-border, unique frames, source-lineage and provider sha checks PASS. USD amount is NOT reported.
- Four separate **16-frame deterministic source-authentic pixel transitions**, precisely **BAT Stage1→2 / Stage2→3** and **FROG Stage1→2 / Stage2→3**. **Frame0 is pixel-exact old original stage source; Frame15 pixel-exact successor source**. Intermediate frames are **local pixel dissolve + emerald/magma spark FX programmed with PIL**, **NOT PixelLab generated** and not an AI morph. No invented Stage4.
- **New 22 clips / 244 slots** (18 provider /180 + 4 procedural evolution /64).
- Cumulative R14: **6 forms; 12 base actions each = 72 genuine motion clips / 616 slots; +4 independent evolution FX clips /64 slots = 76 clips / 680 total frame slots**.
- Original prior **54 R13 motion atlases preserved byte-identical**. New outputs are separately named; no source overwrite.

## Actual native engine QA
- Windows native official engine **4.7.2.stable.official.ed1daf0bf** was executed via authorized device.
- `--headless --editor --path <private-actual-PNG project> --quit`: **exit 0**.
- `--headless --path <private-actual-PNG project> --script res://tests/test_tb14_art_native.gd`: **exit 0**; authoritative log:
  `FS_TB_R14_GODOT472_NATIVE_ART_ONLY_PASS baseline=72 evolved=4 clips=76 frames=680 stages=6 actions=12`.
- Independent Godot 12-action gallery with keys 1–9 / Q charge / W release / E revive / Space replay; separate evolution gallery plays all 4 inter-stage effects.
- This **is true native headless 4.7.2 logic and import**, not a non-headless renderer screenshot, gameplay integration, or approval of the actual art.

## Private Drive readback
- [R14 authentic 272-file full ZIP](https://drive.google.com/file/d/1X3V0Mk6ppVyNwLthZkYoLpqGGjLG8Cem/view), **6,439,086 bytes**, CRC PASS, **SHA256 `07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575`**.
- Google Drive API metadata readback confirmed same intended private parent folder `10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`, ZIP size **6,439,086** and **shared=false**, owner-only file permissions.
- [Bat full three-stage Charge/Release/Revive contact](https://drive.google.com/file/d/1SGMgFoiBo0rA4fitvY_6IQ-av50OTMJu/view); [Frog contact](https://drive.google.com/file/d/1KP5BpsR5jxkBsL3gFZ-ijn-1inHO2cgi/view).
- Four separate genuine original-source procedural evolution GIFs: [Bat 1→2](https://drive.google.com/file/d/1lL-RbhnLcrSJWXgRR2nFvlGszH6u9sEd/view), [Bat 2→3](https://drive.google.com/file/d/1gCTMoEG73HrKy8MxOZRI_BWmZCHuiuDf/view), [Frog 1→2](https://drive.google.com/file/d/1P5wHXe7LoNyG6vKZJDOkFb4xwQO_82Fe/view), [Frog 2→3](https://drive.google.com/file/d/1XSvRZr7RjuPTE2K_xd4Z0Y8L7-q9pDy8/view).
- [Provider job IDs/provenance](https://drive.google.com/file/d/1tCeLgTU9d4UZr2oOlKSMD6A_EQXVmHOX/view) | [R14 QA JSON](https://drive.google.com/file/d/17UNkmx_9YpRaQiZSfF47LIhd_GtdCgev/view) | [Native PASS log](https://drive.google.com/file/d/1W94pGGx6hySeaETCfhLwtAZNN5kEqGXh/view) | [Manifest](https://drive.google.com/file/d/1vrfngzcZhdb8FsXaENyeU3Uuq5RhlZox/view).
- 18 genuine action review GIFs + all original atlases + Godot demo/GDScript + original KO/Charge lineage included in private ZIP. All raster remains private Drive, GitHub stores scripts/docs only.

## Honest art gates / visual observation
- Technical test 76/76 and 18 new genuine clips PASS, **but R14 22 NEW clips are OWNER_ART_REVIEW_PENDING**. No owner approval was received for this round.
- Visual review of actual private 3-stage contact sheets: **Bat REVIVE mid-animation shows a turn away from southeast view / wings and head seen too far from the rear**, potentially breaking locked 45° view; **priority ART HOLD on Bat Revive**, do not certify as final.
- Frog REVIVE has some head/body orientation drift and final stance should be reviewed. Charge/Release mechanics are distinct on contacts but require GIF motion review to verify semantic clarity.
- Evolution effects intentionally use pixel dissolution rather than physical skeleton morphing; treat as a separate effect style pending approval, not as automatic full morph success.
- See R14 failure log for one packaging code bug fixed by genuine native rerun.

## Persistent code and replay
- `godot_port/tools/pixellab_tb/tb14_three_motion_provider.py`
- `godot_port/tools/pixellab_tb/build_tb14_art_release.py` (post-fix commit `bec0fda3ab0ca1f89acd26d36e586b7618513881`)
- `godot_port/tools/pixellab_tb/orchestrate_tb14_release.py`, `cleanup_tb14_ephemeral.py`.
- Only branch `feat/fs-pixellab-tb-monster-20261121`. Last source archive R13 fixed SHA, full R14 release SHA verified; do not alter the prior stage identity/owner-approved bites.
- Temporary Windows `%TEMP%/fs_tb14_*` work is disposable, **cleanup after confirmed private Drive readback** (separate P0 gate).

## Next macro unit
**Correct the blocking Bat Revive 45° rotation**, and check Frog Revive semantic stance, with at most two bounded art iterations before escalation; run real Godot art-only visual review. Then start **third genuinely distinct monster family full three-stage template**, avoiding battle-system detour. Preserve R14 archive unchanged as a historical candidate.


## R14 post-release storage closure
- **P0 owner Windows TEMP CLEANUP VERIFIED** after actual private Google Drive file metadata readback: source-controlled `cleanup_tb14_ephemeral.py` removed seven named R14 temporary outputs (two work directories + five specific files), retained R10-R13 original staging and all private Drive assets. Rechecked full private ZIP SHA256 **07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575**, original Drive release untouched.
- `orchestrate_tb14_release.py` pinned corrected builder commit `bec0fda3ab0ca1f89acd26d36e586b7618513881`, fixing initial wrapper's old failing pin.
- **Final technical state**: R14 76/76 native headless PASS, 680 frame slots; R14 ART REVIEW PENDING. Distinguish quality gate from technical gate in all public communication.
