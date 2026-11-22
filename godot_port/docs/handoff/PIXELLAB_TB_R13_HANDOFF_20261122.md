# Forest Symphony | T-B R13 monster art-only handoff | 2026-11-22 (Taipei)

## Mandate
Continue authentic three-stage monster evolution animation production; NO battle engine, ATB, ACT, HUD, enemy mapping, character T-A, map T-C or main modifications. Preserve all R12 sprites; Stage1 PMD0001 V6 and TB02 R8 user-approved bites must not be redrawn. Godot **4.7.2** is the exclusive engine.

## New completed production
- Two existing different monster species: TB02 **Leaf Bat** Stages 1/2/3, PMD **Lava Frog** Stages 1/2/3, all original-stage source locked and provider SHA traced.
- New actions for EACH of 6 stages:
  - **Stun 8F** = creature-specific disoriented stagger / loss of flight balance, distinct from Hurt.
  - **Taunt 8F** = creature-specific threatening fanged scream / magma frog open-mouth croak, distinct from Attack and Skill.
- **12 actual new PixelLab Skeleton v3 successful jobs** (12 x provider-reported 3.0 generations = **36.0 subscription generations**), **96 actual distinct-frame slots**. USD cash price not provided. No job ID invented.
- Bat cells: Stage 1 128², Stage 2 160², Stage 3 224². Frog: 128² per stage. Each new atlas is 4×2, 8 frames, RGBA, non-empty, **zero transparent-boundary clipping**, eight distinct frames for observed job results; SHA256 matched source provider ledger.
- Combined R12 + R13 release: **two species × three stages × nine actions = six forms, 54 atlas clips, 436 actual frame slots**. Every old R12 clip remains byte-identical; two original previously owner-approved bite actions retained.

## Real Godot proof
- Tested installed official **Godot 4.7.2.stable.official.ed1daf0bf** with actual private PNGs in an isolated Windows user TEMP art-only project.
- Native `--headless --editor --quit` import exit=0.
- Native `--headless --script res://tests/test_tb13_gallery_native.gd` exit=0, actual marker:
  `FS_TB_R13_GODOT472_NATIVE_ART_ONLY_PASS clips=54 frames=436 stages=6 actions=9`.
- Standalone **tb13_gallery.tscn** supports 1 Idle; 2 Attack; 3 Hurt; 4 KO; 5 Guard; 6 Skill; 7 Fly/Hop; 8 Stun; 9 Taunt; Space Replay. No gameplay wiring whatsoever.
- The R13 test was a REAL engine **headless native import/playback logic QA**, not a live graphics-window screenshot. Two exact-pixel Stun/Taunt 3-stage source contact sheets and 12 animated preview GIFs supplied, but no new R13 on-screen renderer screenshot claimed.
- **TECHNICAL_QA_PASS != USER_ART_ACCEPTED**. New 12 actions are `OWNER_ART_REVIEW_PENDING`; verify visual motion meanings (jaw readability, awkward fins/feet/wings, loops) before art final approval.

## Authentic private deliverables and hashes
- [Full 190-file R13 private ZIP](https://drive.google.com/file/d/1PGNJZfHKsL66zl1G1K-l-r4X6lYq_dEN/view), **3,984,990 bytes**, **SHA256 eebd4d0e1bb12252d8ae1bea8fef87227ce7b9719a71f0da1539b19ea79492d7**, ZIP CRC PASS, containing 54 original PNG atlases, independent Godot demo, 12 new-action GIFs, QA/provenance and review contact sheets.
- [R13 Leaf Bat 3-stage contact](https://drive.google.com/file/d/1v1SpdSMBmtdQ17tRNZePkS1e_v3-mEe2/view).
- [R13 Lava Frog 3-stage contact](https://drive.google.com/file/d/1ivnLsSQHMATIO7WReXZSB08wvhVxsXWe/view).
- [New-action technical QA](https://drive.google.com/file/d/1gszpz-4B4SYoSLgyG0OEPi4AZTZdrK3U/view).
- [Original provider job ledger](https://drive.google.com/file/d/1Yb4KYwJVv6pUEFIr8p5L--6KR5BXIaKB/view).
- [Godot native log](https://drive.google.com/file/d/1edaQdofOzn0vhxzPXFMu2eEEZDHBfyI7/view).
- [Release proof](https://drive.google.com/file/d/1rbNagaNTkqBX3Jlsx3e6pW_igPxDe0Jh/view).
- All linked artifacts returned in **private original Drive folder ID** `10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`, Google Drive metadata readback `shared=false`, ZIP size and ownership verified.

## Source-control and isolation
- Branch `feat/fs-pixellab-tb-monster-20261121` ONLY. New providers: `tb13_bat_stun_taunt_provider.py`, `tb13_frog_stun_taunt_provider.py`; packaging `build_tb13_art_release.py`; orchestration `finalize_tb13_private_release.py`. All are credential-free and raster-free. Prior R12 releases unchanged.
- Temporary working outputs used `%TEMP%/fs_tb13_staging` and preexisting `%TEMP%/fs_tb_r10_tmp`, `%TEMP%/fs_tb11_tmp`; no new permanent Windows asset library requested. **Clean verified R13 temporary outputs after Drive sync readback; preserve preexisting artifacts.**

## Failure log
See `PIXELLAB_TB_R13_FAILURE_LOG_20261122.md`. First Godot orchestration encountered Windows CP950 decoding of genuine engine output and aborted; repaired by explicit UTF-8 with error replacement and **reran genuine Godot PASS**. No sprite reroll, no false success claims.

## Next full ART macro unit
Produce **Charge/Release, Revive and evolution transformation**, with species-specific original source, at most two attempts per nonblocking cosmetic issue. Add a third distinct monster family benchmark **only after inspection of the now-complete 9-action two-family batch**. Maintain old 54 atlases immutable and publish only Drive private raster and GitHub code/QA/Handoff.
