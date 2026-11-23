# Forest Symphony T-B | R16 Failure Log | 2026-11-23

### R16-F01 | Historical KO visual assessment only sampled mid-clip [FIXED PREVIEW, ART PENDING]
R15P current handoff marked Glacier Jackal 3-stage KO as ART HOLD and asserted not visibly collapsed. This judgment was based on contact sampling frame around F3, **not full 8-frame KO**. Reopened the authentic private 373-file R15P ZIP and inspected F0-F7 for each of three stages. All three source PixelLab KO F7s are ground-level collapsed, with bbox height ratios F7/F0 **0.6753, 0.5904, 0.7636** and top bbox Y shifts +26,+34,+26px. Replaced incomplete preview with full 3-stage all-8-frame KO contact and 11-frame exact-source revive. **Structural outcome PASS; owner visual art approval still pending.** No existing original KO atlas rerolls, no extra paid generations.

### R16-F02 | Local candidate ZIP proof got stale across reruns [FIXED]
First local R16 M1 candidate (386 entries) erroneously retained a prior `reports/R16_PACKAGE_PROOF.json` generated AFTER earlier ZIP, with a stale SHA and entry count. Did not claim it as formal release. Patched builder to remove stale proof before archiving, and publish SHA proof separately. Source commit `a9131b487cd30d469cbb3b25e8198c320a5eeef6`. Correct M1v2: **385 entries, 10,545,696 bytes, SHA256 `6491d333bc4a56c89a542849074e5054df4ff22b9e1b39c1fd0a2324cfdd31d1`**. The original V1 is retained as historical M1 NATIVE-HOLD evidence; it is not promoted. One corrected iteration, no PixelLab cost.

### R16-S01 | Bridge extra Issue argument rejection [EXPECTED SECURITY FAILURE]
New restricted Bridge task `fs_tb_r16_godot_native` accepts exactly `{"schema":1,"task":"fs_tb_r16_godot_native"}`. [Negative test Issue #79](https://github.com/showpei1203/chatgpt-pc-bridge/issues/79) added a disallowed `command` field. Runner result **FAILED** with `Unexpected Issue payload fields (R16 art native task)` and never ran Godot. This is **security PASS**, not a test defect. [Actions 45101638338](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45101638338).

### R16-N01 | Native execution valid [PASS]
[Allowed Issue #80](https://github.com/showpei1203/chatgpt-pc-bridge/issues/80) exactly two keys; [Actions 45101707739 SUCCESS](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45101707739), official Windows Godot 4.7.2 `--headless --editor --quit` exit0, independent art gallery test exit0. Log SHA256 `65b50d830d2430678c7f92c4c26bb62690091021bb303a3fa5a5dd0810239ce7`. Runner returned success **only after** private Drive log SHA readback and run-specific TEMP deletion. No Desktop Remote or Codex.

### R16-P01 | Formal publication [PASS]
Private Drive R16 final **387-entry** ZIP size **10,547,433** SHA256 `a3292f8e9ce94648f8a9d61bb22271a4d3d3f92fc02f132fb18c5278e92d9efe` with exact native log embedded. After upload, separately re-downloaded actual ZIP via live authenticated Drive connector into isolated runtime and rechecked full SHA256, every ZIP CRC, native log SHA, counts (93 clips/838 slots), and Google owner-only permissions. No source PNG bytes changed from M1v2 source; original R15P ZIP kept immutable.

### R16-A01 | Owner art, distinct from technical proof [OPEN]
KO source identity, 3/4 view, semantic collapse and Godot-native scene technical tests PASS, but no user art signoff or fresh GPU gameplay screen capture. Status **AWAIT_USER_ART**; *not* final game-art approval. Third Glacier Jackal species still has 5 of 12 actions per stage. Remaining 21 animations require real authorized PixelLab route and credit accounting; no hidden paid generation.

### Rule conflict recorded
Historical `fs-rmvx-router/SKILL.md` says VX authoritative, but latest user instructions and R15P Current Handoff mandate **Godot 4.7.2**. Latest wins. Older T-B initial prompt says start with PMD0001 original, but current task is third-family completion; do not restart old work. Bridge routing rule is a tool selection policy only, not a grant of arbitrary Windows shell access. New restricted Bridge task was specifically whitelisted and tested.
