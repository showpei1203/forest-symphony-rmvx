# Forest Symphony｜T-B R16｜2026-11-23｜霜晶狼三階 KO 全幀復核＋來源鎖定 Revive 原生驗證正式交接

## TARGET / Scope / Rule precedence
- TARGET **T-B Monster ART ONLY**, branch `feat/fs-pixellab-tb-monster-20261121`. No main/T-A/T-C, Battle, ATB, ACT, HUD, Enemy ID, integration or original E: user files modified.
- Current user instruction (2026-11-23), latest CURRENT_HANDOFF, `FS_CONTROL_TOWER_PROTOCOL`, approved `fs-monster-evolution`, `fs-godot-testing`, `fs-handoff-qa`, `ai-pc-routing` skills control. `fs-rmvx-router` historical **VX as main** conflicts with later **Godot 4.7.2** authority; current Godot instruction wins. Older launch prompt's initial PMD task was completed before this R16 handoff and not restarted. Latest AI PC Routing Protocol forbids improvising arbitrary Windows access; zero Desktop Commander/Codex use.
- Source of truth **R15P owner-private** ZIP SHA256 `a8088f4e76e3f63d7b9a58857213d138ecb2e43a5af92547f4b2222f77fd04f7`, 373 files. Existing 90 image clips and all original historical PNG preserved byte-identical.

## M1｜完整三階候選：SOURCE QA PASS
- Extracted each stage's **all eight authentic PixelLab KO PNG frames F0–F7**, not the prior comparison contact's F3. Observed true KO **F7 actually lies prone**. The prior R15P claim `Wolf KO not collapsed` was **overstated due to preview sampling**: do not delete or blindly regenerate real KO clips.
- Original art's fall progression from F0→F7 validated at source pixel level (nonblank, alpha, no edge clipping, source SHA match):
  | Glacier Jackal stage | Original source SHA256 | KO F7 height/F0 | Bounding-box top moves DOWN | Gate |
  |---|---|---:|---:|---|
  | 1 Glacier Jackal Pup | `b3c5ac1487b5f68f01f792f18ce0de85c662f3ec255766d9bf97bb7cb6a8de20` | 0.6753 | 26px | structural KO PASS |
  | 2 Crystal Wolf Guardian | `2e5a53ab2558bb5922b63e2a335408e9e87831aeb8661b977fd7548bb4708359` | 0.5904 | 34px | structural KO PASS |
  | 3 Ancient Glacier Fenrir | `6ad516093d262670a45893b44905d86513e6224be6b35d5b7b65642ef342de6e` | 0.7636 | 26px | structural KO PASS |
- **Three complete NEW 11-frame REVIVE atlases**, one per stage (128px,160px,192px). Exactly source KO `F7,F6,...,F0` plus existing Idle `F1,F2,F3`, with original KO F0 pixel-identical to Idle F0. No new bodies, pixels, flames, random transformation, AI provider jobs or generation charges. Original R15P motions remain untouched.
- Stage1 revive atlas SHA `4e2a0ddb2f5350ef2cb6115ea352ec6b3b95e2cac34b28bcd99dd65b62b9a01f`, Stage2 `240abac078357c86e38ebaeee87bd271c00c8061294af42639a86e3ec1518858`, Stage3 `93df5d1fb520563c912b94e3204f855462576c8b4e0d341c489e9c09c3a3c7ce`.
- 3×11 new original-frame-derived slots **+33**; total **9 forms, 87 base motion clips/742 base slots +6 evolution FX/96 slots = 93 clips/838 slots**. Third family now **5/12 motions per stage**. **PixelLab R16: NOT_RUN; cost zero.**

## M2｜Godot 4.7.2 actual native proof PASS
- Tool route: new **fixed, reviewable allowlisted** task `fs_tb_r16_godot_native` only in private `showpei1203/chatgpt-pc-bridge`. No Issue-supplied shell/path/URL/coordinates/secrets. Fixed private ZIP SHA+size+385 entries are checked prior to extracting into unique Windows TEMP. Uses existing installed official Windows Godot `4.7.2.stable.official.ed1daf0bf`.
- **Security negative test** [Issue #79](https://github.com/showpei1203/chatgpt-pc-bridge/issues/79) sent an extra `command` payload; GitHub Actions [run 45101638338](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45101638338) **correctly FAILED BEFORE EXECUTION**, expected denial. This is a security PASS, **not** an art native failure.
- Real positive **[Issue #80](https://github.com/showpei1203/chatgpt-pc-bridge/issues/80)** and [Actions run 45101707739 SUCCESS](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45101707739). Godot editor import **exit 0**, independent source-real gallery `res://tests/test_tb16_frost_art_native.gd` **exit 0**, exact real log marker:
  `FS_TB_R16_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=87 evolutions=6 clips=93 frames=838 frost_revive=3`.
- Official sanitized native log: [Private Drive R16 M2 Godot 4.7.2 QA](https://drive.google.com/file/d/1RNpKw7vx2V36uOZcpatxJCAzqi6frguu/view), SHA256 `65b50d830d2430678c7f92c4c26bb62690091021bb303a3fa5a5dd0810239ce7`. Runner cleanup required and completed (Issue SUCCESS); zero Desktop Remote calls.
- **No R16 non-headless GPU screenshot/recorded 1× motion**. Godot native code/import and source structure PASS, **VISUAL owner review pending**, not visual certified.

## M3｜阻斷修正與修復原因
- Visual-related previous KO rejection was caused by contact sheet not displaying **F7**; R16 full 3×8 KO contact correctly shows all frames. Morphology passes structural collapse numeric gate, but only owner may approve appearance.
- **R16 M1 trial archive v1** accidentally included stale previous proof JSON whose hash did not correspond to new ZIP. Corrected with R16 source commit `a9131b487cd30d469cbb3b25e8198c320a5eeef6`: delete stale proof from output staging BEFORE creating ZIP; the true SHA proof is external. M1v2 verified 385-entry ZIP SHA `6491d333bc4a56c89a542849074e5054df4ff22b9e1b39c1fd0a2324cfdd31d1`, size 10,545,696. V1 remains historical Native-HOLD candidate, never promoted.
- After the authentic Bridge success, verified promotion helper `promote_tb16_verified_native.py` integrated **actual 539-byte exact log** into formal ZIP without changing any previous or new PNG raster pixel. No claim container itself ran Godot.

## M4｜second/third stage repeatability
- The same source exact KO→Revive algorithm ran independently on **three distinct morphologies** 128/160/192px, with source SHA, full KO 8F semantic QA and independent revive atlas 11F. All three passed source, Godot native loaded 93 clips.
- Normal battle integration NOT_RUN per T-B art-only scope.

## Private Drive release (verified WRITE → READBACK)
- **[Official R16 full private ZIP, 387 files](https://drive.google.com/file/d/1Mi0BcmKdK6qwiQKnmSrcXbX5cSFpgs7p/view)**, **10,547,433 bytes**, SHA256 `a3292f8e9ce94648f8a9d61bb22271a4d3d3f92fc02f132fb18c5278e92d9efe`. Actual Drive raw re-download in isolated container: 387/387 ZIP entries, **CRC PASS**, SHA256 matches, imported native proof SHA matches, manifest 93/838 PASS. Google Drive metadata: original private folder `10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`, `shared=false`, permissions `user:owner` only.
- [Final release proof JSON](https://drive.google.com/file/d/17EA_rhQ5JYAlJDJ4hGxT5vdJvGSUWlfZ/view).
- [Full three-stage KO F0..F7 + Revive F0..F10 contact](https://drive.google.com/file/d/1TFkrrmC0lraDBAOOMWRYAKlZs7Xl-00X/view).
- [True source retimed GIF Stage1](https://drive.google.com/file/d/1vmXVDa9rGjeu07HYKIuytJU9H5-BHSwR/view) | [Stage2](https://drive.google.com/file/d/14usp-ADo-YvPmvCh7sq8Y5Qr27CfUQgJ/view) | [Stage3](https://drive.google.com/file/d/1EpDduvE6zEprHbXTGJNdvKcoGEkOVK4K/view).
- [Original source pixel/KO 8F QA JSON](https://drive.google.com/file/d/1rAaiW1Dz6QbFA3ckC9kaeKKaWSNV8Zwe/view). All private pictures in Drive, public T-B branch scripts/docs only.
- P0 Windows TEMP: exact run-specific directory cleaned by Bridge finally and execution successful. No user PC project / source game edits, no retained R16 workdir. Isolated model container working files not user PC.

## Actual project source
- `godot_port/tools/pixellab_tb/build_tb16_frost_ko_revive.py` [source patch commit a9131b4](https://github.com/showpei1203/forest-symphony-rmvx/commit/a9131b487cd30d469cbb3b25e8198c320a5eeef6).
- `godot_port/tools/pixellab_tb/promote_tb16_verified_native.py` [commit f9e1676](https://github.com/showpei1203/forest-symphony-rmvx/commit/f9e1676d12f86e3063f095b143430f7df87e5a63).
- Approved Bridge task `bridge/tasks/Invoke-FSTBR16GodotNative.ps1`, exact switch `fs_tb_r16_godot_native`, negative and positive Issues above. This ability is **narrow and one-off**, NOT general Windows shell authorization.

## Explicit QA Gate summary
| Gate | R16 actual outcome |
|---|---|
| SOURCE / SHA / LICENSE AUTHORITY | **PASS** from authorized immutable private R15P source, all original PNG preserved |
| STRUCTURAL KO / REVIVE | **PASS** original all-8-frame proof, exact reversal, no clipping |
| GODOT 4.7.2 NATIVE editor + test | **PASS** real Windows Runner, log in private Drive |
| VISUAL ART / USER SIGNOFF | **OWNER_ART_REVIEW_PENDING**, technical collapse does not guarantee artistic taste |
| COMBAT / GAMEPLAY INTEGRATION | **NOT_RUN** (explicitly out of scope) |
| CLOUD P0 / Runner TEMP cleanup | **PASS** Drive CRC/SHA/permissions/readback, temporary Windows QA folder removed |

## NEXT_COMPLETE_MACRO_UNIT
Complete **Glacier Jackal 3-stage remaining seven source-locked motions**: `Guard, Skill, Locomotion, Stun, Taunt, Charge, Cast Release`, **21 true new PixelLab sheets**. Prior source authorized; use existing stage PNGs and proven motion provider; stage2/3 are true independent test samples; no battle systems. Any paid PixelLab generation requires approved authorized API/tool route and verified actual generation costs. If routing/credential not approved in new dialogue, mark paid generation HOLD and still produce complete no-cost preview/QA work as permitted.
