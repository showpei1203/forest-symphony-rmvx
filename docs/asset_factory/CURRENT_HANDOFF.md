# FS AI Asset Factory CURRENT_HANDOFF — A05 (2026-11-08)

This file is the **active entrypoint for A06**. A01-A04 remain historical evidence. Do not overwrite sealed FS, do not merge main, do not claim a native or art seal from geometry QA.

## Authority / links
- Global cloud-first priority: https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit
- Main authority: authority/FS_CURRENT_RULES_INDEX_20261107.md; .agents/skills/fs-rmvx-router/SKILL.md
- GitHub Draft PR [#15](https://github.com/showpei1203/forest-symphony-rmvx/pull/15), branch feat/fs-asset-factory-v1-20261107, unmerged.
- [A05 full private Drive Handoff](https://docs.google.com/document/d/1C2gAck-U1lVDGo5yvKBPbqSj25crtoKZdvvp2_Mm52A/edit)
- [A05 private actual-source QA](https://docs.google.com/document/d/1P663Mgd9C03gPjAFv7X2E4D1t-G1zxudcqz95o8PgGo/edit)
- [A05 public technical evidence](A05_REAL_EXPORT_AND_AUTHORING_GAP_QA_20261108.md)
- [Orca independent review taskboard](ORCA_A04_TASKBOARD_20261108.md).
- [A04 previous Handoff](https://docs.google.com/document/d/1uutNu7PzEveBqeohO8ltuIeNU4hbP5bdZ80FSej1Fj0/edit), [A02 original PMD SHA authority](SOURCE_INVENTORY_A02_20261107.md).

## A05 verified real execution
### PMD (real direct committed exporter)
- Actual source bytes were read from original private Drive ZIPs PMD0001/0002/0003.
- Copied the exact public GitHub pmd.py and native_action_export.py into isolated runtime and verified their actual Git blob SHA:
  - pmd.py a97778e8c886b839d5dd9a4993e9dabf4177b739
  - native_action_export.py dd7d5b71b5f96a35fb2d76c09a94d96f8e3cb92b
- Ran actual compile_native_action() against native XML+SHA-locked full action source PNGs for Idle and Walk, six original+variant folder families, 12/12. The explicit one-row input came from **that same exact preexisting native direction row**; re-encode is RGBA pixel-exact across Anim/Offsets/Shadow, other rows unchanged. One controlled 1-channel mutation in original_0001 Walk row3 frame0 affected exactly one intended channel; all other 7 native direction rows unchanged. **PASS_REAL_SOURCE_FORMAT_ONLY**; this did NOT create new approved lava creature art.
- A26 PixelLab lava-frog approved Idle/Walk exact private ZIP remains SOURCE_NOT_VERIFIED; do not pass off original_0001 or rock_0001 as that art. Old Handoff ZIP SHA 460b8ca230e579e78d2f3350f0f10c0ba0ab5af2fbaee063faf3bdb3baee1399; targeted private Drive, known old PC directory and Project/Library searches did not verify file. Exhaustive E: scan was not possible; do not claim definitive nonexistence.

### Map (private V3)
- Actual V3 frozen master 1280×928 SHA 091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530.
- Authoring CompletePAR SHA b9935121ef816fb4c79c958c839167b1e9fb9917f120efe0d5bd42c76a9e5d74 has **864,528** alpha pixels; runtime four-object PAR SHA e2486f7a780d260ccfceadac024b94ee37108371c91c7a73f2cf254463c76edb has **118,425** alpha pixels, all within Authoring; Authoring-only **746,103** pixels across **1,049 32px tiles**. Draft walkable tiles include 476,566 of these pixels. This is an **object provenance coverage gap, NOT a prescription to copy all pixels into Runtime PAR**.
- Static potential actor/eave shortlist from V3 own grayscale binary masks and draft collision:
  - LEFT_HOUSE_ROOF 6 draft walkable alpha intersect tiles / 4 with assumed 25×32 actor bbox; suggested x/y (5,4), (13,6), (7,6).
  - RIGHT_HOUSE_ROOF 9 / 9; x/y (25,6), (30,4), (29,4).
  - Left canopy 49 / 48; right/lower canopy 57 / 56. All NOT native engine legal-footpoint approval, and no switch203 was run in A05.
- **QA bug/failure log:** first static footpoint trial converted L-mode grayscale masks to RGBA then took alpha, false 790 walkable tiles for every object. INVALID, discarded. Corrected with L mode grayscale values and RGBA alpha; actual results above. Test future L vs RGBA mask mode explicitly.

### A05 code and CI
- Added tools/asset_factory/adapters/authoring_coverage.py for authoring-vs-runtime alpha subset, Master same XY RGB, 32px tile hotspot and optional binary draft collision scope; status cannot promote object owners, art or native VX.
- Added tests/test_a05_authoring_coverage.py with 8 positive/negative fixtures. Existing A01 14 + A02 15 + A03 11 + A04 9 + A05 8 = **57** synthetic tests.
- Actual GitHub Actions run [42416671913](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42416671913), source commit c04cb60ef1c36cd0feb1be1b0619e05e58a5c97b: SUCCESS, 57/57. After doc commits check final PR HEAD and final-head CI.
- Real private-map pixel count is independently computed in isolated Python, **not claimed as actual execution of the newly committed coverage module**.

## Orca permissions / honest status
- Remote Desktop Commander authorized device DESKTOP-90VT437 ONLINE. Installed Orca processes and historical Codex agents visible; old A36F R4 independent review details previously read. Historical Codex YOLO warning persists.
- Read-only inspected Orca app configuration paths and searched for available sandbox/approval fields; did NOT obtain authoritative proof that current Orca GUI agent uses approval-required, read-only mode. **NEW ORCA AGENTS S1/M1 NOT LAUNCHED.** Do not disguise an ordinary ChatGPT analysis as multi-agent orchestration.
- Orca Agent S1/M1 cloud task assignments exist in ORCA_A04_TASKBOARD_20261108.md. Do not launch unrestricted Codex, write PC worktrees, or run Windows Game.exe without previously scoped temp-file approval and cleanup.
- No PixelLab paid generation, no PC persistent project new files, main unchanged.

## Gate matrix
- Real direct native exporter source format: PASS 12/12 and 1 controlled mutation.
- A05 synthetic Actions: PASS 57/57 on recorded run, final head to verify.
- Full Authoring PAR per-object ownership: FAIL_CLOSED / NOT_VERIFIED.
- Static potential walkable roof candidates: IDENTIFIED, but true legal-footpoint semantics NOT_TESTED.
- Orca new agent independent QA: NOT_LAUNCHED.
- Native VX / switch203 A05: NOT_RUN; user art approval new asset: PENDING; formal seal NO.

## Precise A06
1. Keep new Codex/Orca execution restricted until actual approval policy is verified, then independently review **this exact A05 exporter and L-mode QA failure** through S1/M1, not broad art rework.
2. A26 source loss exception remains open, no further blind loops over same PC path. If recoverable, lock source SHA in private Drive first. Next one-action real new appearance requires eight independently valid direction assets, not rotation copies.
3. Expand Authoring object register (full source object inventory with complete and runtime occlusion masks). Use the 1,049-tile delta as diagnostic scope, NEVER blanket Runtime PAR.
4. Validate left (5,4)/(13,6)/(7,6), right (25,6)/(30,4)/(29,4) only after reviewing V3 legal collision and actual actor footpoint; native Game.exe switch203 requires separate scoped PC permission, per-frame camera/pose evidence and 1× art gate.
5. Archive new stage private Drive Handoff + public GitHub only source and metadata, CI and readback, strict ART/NATIVE statuses.

Rollback only A05 feature branch additions. Main/approved original private ZIP unchanged.
