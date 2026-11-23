# FS / T-B Monster Art R18 Failure Log | 2026-11-23

## Scope / source freeze
- T-B `feat/fs-pixellab-tb-monster-20261121` only; main/T-A/T-C/FSBattle/ATB/ACT/HUD frozen.
- Source immutable user-private R17 430-file Godot 4.7.2 native ZIP `d7e8d8b168e8f4553ba735972d1fb573f1439d3850aedb1c2dd5bd30b6e581ad` (11,295,309 bytes), after real independent Drive SHA/CRC check.
- Goal R18 = Glacier Jackal Pup 128, Crystal Wolf Guardian 160, Ancient Glacier Fenrir 192, each 12 genuine PixelLab RUN frames, actual alternating four-paw gait; owner visual assessment independent of technology.
- Read current R17 Handoff/Failure Log, source manifests, P0 private Drive, official `fs-monster-evolution` and `ai-pc-routing` SKILL.md on GitHub; current Godot 4.7.2 authority overrides stale VX-as-main Skill lines. No Windows Skills assumed auto-imported.

## F01 | Paid request must not auto retry [FIXED BEFORE PAID]
- Initial reused R17 network helper retried a billable `POST /animate-with-text-v3` on some HTTP/network failures. Rejected: a lost POST response can still have incurred PixelLab generation cost, so retrying could charge twice. Changed `attempts=1 if body is not None else 3`: billable POST once, read-only job poll GET may retry. On unexpected API result without job ID, stop/hold rather than repeat request.
- Persist provider job ID to exact user-private `R18_RUN_STAGE{n}_JOB_JOURNAL_PRIVATE.json` **before first poll**, and dump all actual returned provider frame JSON in exact private Drive `R18_RUN_STAGE{n}_RAW_PROVIDER_RESPONSE_PRIVATE.json` **before any frame/semantic QA**. If a downstream failure occurs, source and usage remain recoverable without rebill.
- Exact four reviewed private Bridge allowlisted tasks: `fs_tb_r18_run_preflight`, `fs_tb_r18_run_stage1`, `fs_tb_r18_run_stage2`, `fs_tb_r18_run_stage3`. Each accepts only `{"schema":1,"task":"..."}`; no user-provided URLs, commands, prompts, source paths or tokens; fixed SHA-locked script. Each paid task can submit at most **one stage**.

## F02 | Full offline source/ledger mock and native Windows preflight [PASS NO API]
- Before first paid job, actual original user-private R17 archive checked and offline three-stage synthetic (clearly TEST ONLY) 12-frame atlas+ledger assembly validated with test marker `FS_TB_R18_OFFLINE_FULL_SCHEMA_AND_3STAGE_ATLAS_PASS`. The paid provider was never called in selftest. Source code SHA256 `89349697f0b9670423602d3ff6bbcb1d9832ebc5120da1dc57e80514b044c5f5`.
- Prompt lengths all prechecked: Stage 1/2/3 = **462/465/466 chars** (< 495).
- Strict Bridge negative field [Issue #92](https://github.com/showpei1203/chatgpt-pc-bridge/issues/92), Actions [45115167765](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115167765) intentionally FAILED with `Unexpected Issue payload fields (R18 fixed-stage art pipeline)` before any charged API call; **SECURITY PASS**.
- Genuine official Windows Runner preflight [Issue #93](https://github.com/showpei1203/chatgpt-pc-bridge/issues/93), Actions [45115175552 SUCCESS](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115175552): original R17 ZIP SHA and size validated and 3-stage 12F actual atlas/schema dry-run PASS; **paid jobs = 0**.
- Independently constructed an **isolated local synthetic three-stage M1 build only as unit test**, 99 clips /898 slots across 3 family forms with expected native test marker. This mock is NEVER uploaded as paid final art and does NOT prove actual PixelLab quality or official Godot runtime.

## Stage 1 actual TRUE provider [PASS original source]
- [Paid Issue #94](https://github.com/showpei1203/chatgpt-pc-bridge/issues/94), [Actions 45115317384 SUCCESS](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115317384): one real `animate-with-text-v3` job with original 128px source. Job ID `cbb6bde2-ec68-4512-8624-a4105daece3d`. Provider actually returned 13 raw frames / exported 12 source-anchored frames. Reported generation usage **3.0**. Footer of Runner: `FS_TB_R18_STAGE_PROVIDER_ARCHIVE_PASS stage=1 generations=3.0 zip_sha256=e280445ad90a18f7e57edce91e8b717d0bc1866d2493478cad4d4a65c9512c99 bytes=98077 raw_frames=13 foot_alpha_unique=11`.
- Authentic source+job+PNG+raw user-private owner Drive [stage1 12F ZIP](https://drive.google.com/file/d/15T1F7JUcRrirfpazRWOBj1103NYCuYpj/view), corresponding journal [private](https://drive.google.com/file/d/1rTgSmtAnXYcsLi6WpK85mL7hXF1_fWL_/view), original response [private](https://drive.google.com/file/d/1iakPo_ohyvQaArXxIhlsVcY5hECWOA9p/view). Original 12F contact visually inspected and shows lower limb variation, **user art gate PENDING**.
- Stage2 [Issue #95](https://github.com/showpei1203/chatgpt-pc-bridge/issues/95), Stage3 [Issue #96](https://github.com/showpei1203/chatgpt-pc-bridge/issues/96) separately fixed 12F provider jobs. Their completion/usage must be read live before claiming PASS.

## Final gate
- SOURCE: R17 SHA and all existing PNGs preserved PASS
- PROVIDER: Stage1 PASS; Stage2/3 **AWAIT_EXECUTION_RESULTS**
- R18 M1: **NOT RELEASED** while three genuine source clips incomplete
- Godot R18 4.7.2 native: **NOT_RUN** (R17 old native PASS does not count for R18)
- Visual art: **OWNER_REVIEW_PENDING**
- Gameplay integration: **NOT_RUN_ART_ONLY**
- Storage: user PC only run-scoped TEMP, original private G: Drive, public GitHub only text source and Handoff. Desktop Remote=0; Codex=0.
