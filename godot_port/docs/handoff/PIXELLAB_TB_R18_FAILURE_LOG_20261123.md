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


## Stage2/Stage3 actual providers [PASS, REAL COST]
- [Crystal Wolf Guardian Stage2 Issue #95](https://github.com/showpei1203/chatgpt-pc-bridge/issues/95), [Actions SUCCESS 45115563273](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115563273): real PixelLab JobID `da7e1a88-4a36-46c8-94e3-5e3c10d74657`, 13 authentic provider frames, 12 exported anchored frames, `reported_usage.generations=5.0`, foot silhouette SHA unique 11. Real [private 16-entry Stage2 ZIP](https://drive.google.com/file/d/1OcJwLftaCTcphF4xYIg0j1NyIoEABVQI/view) 162,559 bytes SHA256 `313006e9478dee93801ee8c46169d0c03db095a61857122ddba24294d91ac1f3`.
- [Ancient Glacier Fenrir Stage3 Issue #96](https://github.com/showpei1203/chatgpt-pc-bridge/issues/96), [Actions SUCCESS 45115743279](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115743279): real PixelLab JobID `0a3b653b-6995-4c04-adc4-f900fd98ad47`, 13 authentic provider frames, 12 exported anchored frames, `reported_usage.generations=7.0`, foot silhouette SHA unique 11. Real [private 16-entry Stage3 ZIP](https://drive.google.com/file/d/1E3i3FUvy4xz5oP1SzKZgIaCVRUCvAf9e/view) 311,214 bytes SHA256 `6e16c3a3c4361e7e033a3b68e92898605cfeb7e5b0c777bf9311c780f7fd1bd5`.
- **3/3 real providers done, exact 3+5+7 = 15.0 generations**, 39 raw original provider PNG frame outputs, 36 source anchored atlas slots. USD amount not reported. At most one actual billable POST per stage, all jobs durably tracked and private source archives re-read. No duplicate or reroll jobs.

## M1 | Exact three-stage Godot art source [PASS]
- Independently reconstructed full M1 from original **R17 430-entry user-private SHA256 `d7e8d8b168e8f4553ba735972d1fb573f1439d3850aedb1c2dd5bd30b6e581ad`** and the three authentic provider stage ZIPs, including native Godot scene/test derived from the *previously validated R17 gallery* instead of inventing a new engine.
- All historical original PNG contents compared byte-for-byte against R17 source, no mutation. M1 **446 entries, 12,625,007 bytes, ZIP CRC PASS, SHA256 `7cecc170615a205c30ed28efa0c1d19887f8782aeb5d73784a4b52cbd200e40e`**, exact [owner-only private Drive M1](https://drive.google.com/file/d/18Wj8NoZT-YHydfnt0HgO967_LhmPnevL/view). Actual Drive raw re-download, 446 ZIP CRC, SHA and new 99-clip/898-frame manifest confirmed. M1 manifest explicitly says `technical_qa=NATIVE_NOT_RUN` until M2.
- [Three-stage 36-frame genuine PixelLab review](https://drive.google.com/file/d/1-B4JZO2AFwjQOvKGTaaKiCLlIFfnJKjj/view) + all stages [S1 GIF](https://drive.google.com/file/d/1LBInhk-3zMjQiF4L1ARiUTA8-oZHLrYR/view) | [S2 GIF](https://drive.google.com/file/d/10ReKgLaNieagQpWKOf8NFZcAuSRFUnzY/view) | [S3 GIF](https://drive.google.com/file/d/1kD1HbeuVkOLOZxN-dWOUB6mKjgeeqebE/view). Pixel/alpha/source and distinct lower-body silhouettes PASS. Human 1× animation gait and art approval still `OWNER_ART_REVIEW_PENDING`, no false pixel-alpha-to-ART equivalence.
- Three-stage synthetic M1 **unit-test** happened only in isolated assistant runtime, was never published as completed art. Only true 3 provider stage ZIPs were used in official actual M1.

## M2 | Official Windows Godot472 positive [PASS]
- Separate zero-provider source-locked R18 PC Bridge task `fs_tb_r18_run_native` rejects any additional Issue JSON keys. Negative security [Issue #97](https://github.com/showpei1203/chatgpt-pc-bridge/issues/97), [Actions 45116383219](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45116383219) rejected extra `command` before Godot. Expected Actions failure is **SECURITY PASS**.
- Real [positive native Issue #98](https://github.com/showpei1203/chatgpt-pc-bridge/issues/98), [Actions SUCCESS 45116388305](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45116388305), Windows official `4.7.2.stable.official.ed1daf0bf`: editor import exit0, independent `res://tests/test_tb18_frost_run_native.gd` exit0. Marker `FS_TB_R18_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=93 evolutions=6 clips=99 frames=898 frost_run=3`.
- Real sanitized native log [owner-private Drive](https://drive.google.com/file/d/1szEjFDy_hWXmewFC0fpmB87Ud5-v2pU9/view), 585 bytes, SHA256 `58ac2673eac5311d09f6fb9443ed5a13f418c5f853bb23ae3d35671be255afb3`. Independent downloaded raw log SHA and exact marker/engine version confirmed. No non-headless GPU screenshot and no battle/ATB/ACT integration.

## M3 | Final private release [PASS, 0 extra API]
- Promoted exact **already native-tested M1** without altering any original R17 or new R18 PNG bytes, and without calling PixelLab. [Final **448-entry, 12,626,646-byte user-private Drive ZIP**](https://drive.google.com/file/d/1UAaekoyo-HLqNYK8gDHppMCzLIVCMPyp/view), SHA256 `8cc85ea1ca326ce854b3432a46c63fb311aaba3ca5628d101e10a54fc03cae6c`. Full Drive raw **re-download** verified 448 entries, CRC PASS, SHA matching local proof; native log hash and 99 clips /898 frame slots confirmed. Metadata: exact private parent `10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`, `shared=false`, `user:owner` only.
- Native proof [owner-private release JSON](https://drive.google.com/file/d/1TGdajg2DOJfHj3Khk6UNTVoV5VkInp_R/view); provenance preservation: original R17 ZIP and all 3 per-stage real provider ZIPs remain immutable/accessible; no private PNG raster committed to public GitHub.
- P0 Windows Runner tasks use numeric-run-id isolated TEMP and delete it during finally; real game `E:\遊戲專案開發` untouched. Desktop Commander calls **0**, Codex **0**.
- QA distinctions: SOURCE PASS; 3/3 TRUE_PIXEL_LAB 12F provider PASS; lower-body pixel silhouette QA PASS; official Godot472 native gallery PASS; full private Drive SHA/CRC/readback PASS; VISUAL_ART **OWNER_REVIEW_PENDING**, not approved; FSBattle/ATB/ACT/gameplay **NOT_RUN_ART_ONLY**.
