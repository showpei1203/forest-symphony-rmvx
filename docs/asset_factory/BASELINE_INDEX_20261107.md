# FS Asset Factory — Cloud Baseline Index v0.1

Date: 2026-11-07. Status: **RESEARCHED / NOT PROMOTED**. This is a source locator and evidence-status index, **not** an inventory of SHA-verified binaries.

## Governing sources
1. [Current rule priority](../../authority/FS_CURRENT_RULES_INDEX_20261107.md), baseline Git blob `1228828d7d68f8b33cef352798ddb626ad879e54`.
2. [Global cloud-only policy](../../docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md) plus [Drive global rules](https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit).
3. [FS asset-generation precheck](../../ASSET_GENERATION_PRECHECK.md) and [FS agent router](../../.agents/skills/fs-rmvx-router/SKILL.md).
4. [Asset Factory V1 execution plan, private Drive](https://docs.google.com/document/d/1p6OZ9TSG0kThKbrLqEN4ONKInBy4EM3eikqPzDBdYR4/edit).

## Source records, verified as document/folder locators
| Family | Source / evidence locator | Status known from that source | Remaining provenance gate |
| --- | --- | --- | --- |
| PMD0001 | [A27 Handoff](https://docs.google.com/document/d/1YodsahI7qOdz6c0KcWavTLgejnQczIMi5iolpgSlgk0/edit) | Accepted A25 appearance and A26 Idle/Walk; other actions candidates; native XML full 8-direction art **not passed** | Locate actual approved source PNG and XML; verify binary SHA/rights; confirm later A-stage handoff |
| PMD0002 | [Drive PMD0002 folder](https://drive.google.com/drive/folders/1VFk-dy83y_3lHMplt6CoDHoKCi0fMXeU) | Folder exists; no binary inspection in this iteration | Verify exact approved master, action XML, SHA, and newest acceptance |
| PMD0003 | [A27 PMD evolution tests](https://docs.google.com/document/d/1YodsahI7qOdz6c0KcWavTLgejnQczIMi5iolpgSlgk0/edit) / [later PMD003 job folder](https://drive.google.com/drive/folders/1WchGp9e_JVo1K_y1ofgtk2uOoTzAwiuP) | History exists; do not infer formal seal of all 8-direction motions | Locate true current approved 0003 file and native XML, SHA and rights |
| Actor01 | [A29 PixelLab 45° test](https://docs.google.com/document/d/1s5zSqLMVI6yXQ1YmX7ib7sStg4qB5wddymItouRTy7g/edit) | Source chibi look approved in earlier work; 45° exact motion and SBS integration **pending**, 5-frame intermediate `!=` 3-keyframe runtime | Compare latest actor A62+ motion handoff, inspect approved source/frame hashes, sheet and weapon anchor |
| Elf village V3 | [Master-first native handoff](../../experiments/agent_skills_20261107/MASTER_FIRST_V3_NATIVE_203_COLLISION_HANDOFF.md) / [private Drive evidence](https://drive.google.com/drive/folders/1XD7sRcUJnVu_MIb5SLk0MTDY6ICnpKNf) | Native collision table 1160/1160; real actor tree exit + clear-control 3/3; roof walkable occlusion **unverified**; user art **pending**; Formal seal **NO** | Verify binary Master SHA against Drive, per-object masks and actor legal-footpoint evidence |
| A36H R3 (separate track) | [Drive current handoff](https://drive.google.com/file/d/1kB87UfBWasEiDCbkkuULRoCWg5H97ojb/view) | 197-source art candidate; 6/6 sampled native static QA, **new five trees dynamic NOT RUN**; Art **PENDING**, Formal seal **NO** | Verify individual source SHA and private files; do **not** merge with V3 master |
| PixelLab MCP | [FS toolchain verified configuration in Drive](https://docs.google.com/document/d/1lx8pbTkwetZFowHWqLI9r4NtXb7WUxFswSq450Vrln4/edit) | Connected six read-only tools and historical balance query; no generation granted by this file | Recheck live balance only before explicitly approved paid work |

**Every binary SHA above is `UNVERIFIED_THIS_ITERATION`** until corresponding Google Drive binary has been read and SHA-checked. Source docs can describe historic QA; they do not prove that the current binary still matches. Third-party/unclear-license images stay in **private Drive**; this public repository only stores code and synthetic test fixtures.

## Native contracts already established, do not replace with generic research defaults
- FS: RPG Maker VX / RGSS2, **32px world grid**; classic **544×416 viewport** is not map canvas. Map trial 40×29 grid = 1280×928.
- Map authoring: complete Master-first source; four distinct `Authoring_GroundOnly`, `Authoring_CompletePAR`, `Runtime_FullGround`, `Runtime_OcclusionPAR`; RGB from original Master same XY. Geometry and art require separate acceptance.
- Actor: native $actor01 3×4 walk grid (32px per cell); SBS battle 45° unarmed + paper-doll weapons, **3 keyframes per action** with `_1/_2/_3` semantics. Intermediate 40×40 frames are not automatically legal runtime.
- PMD: use **actual native XML-specific geometry and frame counts**; A27 examples Idle 32×40×3, Walk 40×40×6, Attack 64×72×11. Other moves/directions are not globally defined by these examples.
- Never call synthetic unit tests native VX PASS; real `Game.exe` / switch 203 and human visual acceptance are separate gates.

## Next reproducible gate
Run the new `tools/asset_factory/tests` **synthetic fixtures** (only positive/negative statics, no private assets). Then authorize access to relevant *private* binary sources and add exact source SHA to this index before writing production Actor/PMD XML adapters.

## Current cloud-delivery policy
No user's-PC workspace, worktree, clone, log archive, or generated image created for this task. Temporary CI runner files are isolated GitHub-owned build artifacts. Native Windows VX testing needs separately explained and approved temporary storage.


## A02 update — actual private source bytes checked (2026-11-07)
New authority: [SOURCE_INVENTORY_A02_20261107.md](SOURCE_INVENTORY_A02_20261107.md). Unlike the A01 research-only index above, A02 **downloaded and SHA-checked actual original PMD0001, PMD0002, PMD0003 and A63 Actor binary ZIPs**, plus original AnimData.xml files and selected PNGs. Full native Anim/Offsets/Shadow geometry was independently inspected across 34/12/12 PMD actions; 2 aliases each, with true 1-row/8-row action variation.

**Keep the status split:** original source-byte checks and XML geometry PASS. Historical source images are **not proof of approval of lava variants or 8-direction identity**. New A02 PMD, Actor and map-object adapters pass **29/29 synthetic CI**, but private source scans through the actual committed adapter and native VX remain separate gates. See the newest [CURRENT_HANDOFF](CURRENT_HANDOFF.md) and private A02 Drive Handoff.
