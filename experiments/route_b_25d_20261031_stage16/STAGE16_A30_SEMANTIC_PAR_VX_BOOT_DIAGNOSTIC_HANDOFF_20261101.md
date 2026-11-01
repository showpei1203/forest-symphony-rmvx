# Forest Symphony Stage16 A30 — Semantic PAR Authority + VX Native Bootstrap Diagnostics
Date: 2026-11-01 (Asia/Taipei)
Status: **PROVISIONAL BOOT WITHOUT MODAL in isolated MAP-ONLY test copy; A29 map NOT REGISTERED OR TESTED IN VX. Visual PENDING. Formal Seal NO.**

## 1. Required reading
1. `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md`
2. `authority/FS_PAR_SEMANTIC_ORIGINAL_OBJECT_GENERATION_V1_20261101.md`
3. `experiments/route_b_25d_20261031_stage16/STAGE16_A29_DETAILED_HANDOFF_A30_TEST_PLAN_20261101.md`
4. Drive `FS_SOURCE_ASSET_LOCATION_REGISTRY_V1_20261023`, and A29 private source+manifest.

## 2. New user-approved policy
When FS visual style is established, isolated original PAR objects may be independently generated to match user-described scene semantics; they do NOT need to be the identical sprites in the user's existing Drive reference collection. Source ownership and generated provenance must remain explicit. The source-first workflow still applies to Ground, alpha completeness, collision/foot, tone and cold native-engine QA. The authorization is conditional and does not imply A29 art or engine approval. See the new detailed GitHub authority file.

## 3. Locked A29 baseline (preserved)
- Original 544×416 PixelLab-native opaque Ground SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`.
- 12 separate PAR objects, 4 complete trees (3 Drive-derived, 1 PixelLab existing).
- Godot 4.7.2 8/8 native GPU screenshot cold SHA exact; BFS 209/209 walkable.
- A29 native VX never reached A29 map, error modal `undefined method p45b_prepare_resources for class Module`.
- A29 visuals pending; Formal Seal NO.
- A30 did **not** generate or change any A29 Ground or PAR images.

## 4. A30 read-only script diagnosis
- Remote PC `DESKTOP-90VT437` was online and A29 original deliverables existed.
- Four different existing VX script baseline files were identified: A09_3_INENGINE_BRIDGE, A09_4_N5_RUNTIME, A09_4_N5_CONTROL and A09_NATIVE_ISOLATED. Each `Data/Scripts.rvdata` has a distinct SHA.
- At first, a 250k-decompressed-character cap yielded a FALSE negative for `p45b_prepare_resources` (a useful new failure lesson); a full 5MB per-stream cap found its definition and subsequent alias in a long `FS_BattleRegression_AIEdgeI v1.0` TEST-only RGSS script. Never claim the definition is absent based on truncated script extraction.
- Actual A09_3 source `Scripts.rvdata` SHA256 `eab34378a5923a84f5f161b1625afa7aa000dff15e3eb77167efa27f67dbeec9`, Ruby Marshal contains 506 script entries, affected test-only script index 480. Read-only Ruby Marshal dump/load round-trip produced the **identical byte-for-byte file SHA**.
- The long test script includes `def p45b_prepare_resources`, later `alias fs_phase45b1_prepare_resources_base p45b_prepare_resources` under singleton-class scope. This is an alias/scope dependency failure candidate; complete root cause still not proved.

## 5. Native VX isolated tests (NOT production patches)
### Test A — one-line alias guard
- New clone `E:\FS_ROUTE_B_STAGE16_A30_SEMANTIC_PAR_VX_20261101\VX_NATIVE_BOOT_ALIAS_GUARD_ISOLATED` from A29 clone; source original untouched.
- Replaced one occurrence of `unless method_defined?(:fs_phase45b1_prepare_resources_base)` with `if method_defined?(:p45b_prepare_resources) && !method_defined?(:fs_phase45b1_prepare_resources_base)`.
- New script SHA256 `83d8e9935ae8b584a372e02907662e78aea4e4d709a06da40f1138ab0341b343`; all other Ruby Marshal script entry payloads verified equal.
- Real native Game.exe was run. **Still BLOCKED**: next modal is `undefined method p45b_restore_battle_skill_slot for class Module` at line 2678 in `FS_BattleRegression_AIEdgeI v1.0`.
- Conclusion: suppressing the first alias failure only reveals the next; do not repeat blind single-error patches or claim a fix.

### Test B — map-only test harness (limited workaround)
- New independent clone `E:\FS_ROUTE_B_STAGE16_A30_SEMANTIC_PAR_VX_20261101\VX_NATIVE_BOOT_MAP_ONLY_TEST_HARNESS` from unpatched A29 clone.
- In **this clone only**, Ruby Marshal script index 480 (the TEST-only BattleRegression_AIEdgeI, not any sealed production script) was replaced by a short explicit comment to bypass startup regression alias errors. All other script compressed payloads verified equal. Original Scripts.rvdata SHA above; clone Scripts.rvdata new SHA256 `550f2f9873f9048a6f1188cc8dc28cf0da180e8991770be396fad3d434e03bc2`.
- Native `Game.exe` alive after 6 seconds; Windows enumeration identified a visible `RGSS Player` main window, **zero #32770 modal windows**, then process was terminated by QA script.
- This is **BOOT WITH NO MODAL (PROVISIONAL)**, NOT actual map, movement, character depth ordering, or native VX visual acceptance. The A29 `ground999/par999` files are still only staged, not map-bound.
- Disabling the test-only regression script is a documented **workaround solely for map tests**, NOT a repair for game combat tests. Do not promote this modified Scripts.rvdata to production.

## 6. Evidence inventory and reproducibility
Local private base dir: `E:\FS_ROUTE_B_STAGE16_A30_SEMANTIC_PAR_VX_20261101`.
- Read-only audit: `a30_vx_script_variants_probe.py`, `A30_VX_SCRIPT_VARIANTS_PROBE.json`, `a30_target_rgss_scope_audit.py`, `a30_ruby_marshal_probe.py`.
- Two controlled patch scripts: `a30_vx_guarded_sandbox_patch.py`, `a30_make_map_only_vx_sandbox.py`.
- Native Window QA scripts: `a30_native_vx_guard_boot_probe.py`, `a30_native_vx_map_only_boot_probe.py`.
- Truthful QA: `A30_VX_TEST_ONLY_ALIAS_PATCH.json`, `A30_VX_GUARDED_NATIVE_BOOT_QA.json`, `A30_VX_MAP_ONLY_TEST_HARNESS_PATCH.json`, `A30_VX_MAP_ONLY_NATIVE_BOOT_QA.json`.
- Actual native Windows GUI proof PNGs: `A30_VX_WINDOW_0_dlg32770.png`, `A30_VX_WINDOW_1_RGSS Player.png`, `A30_MAP_ONLY_VX_WINDOW_0_RGSS Player.png`.
- No source art or private 500MB VX cloned projects should go to public GitHub.

## 7. Mandatory next gates
1. Build/attach an explicit VX map+events in **map-only isolated test clone**, using original A29 Ground/PAR, true 544×416 native test scene and actual FS actor. Do not assume files named ground999/par999 are consumed.
2. Capture actual gameplay front/behind/partial canopy, road movement, collision blocker and legal foot (32×32 grid) with GUI screenshots and RGSS logs. The current no-modal screen is not sufficient.
3. Revisit the regression alias/scope error in TEST-only module separately; for map QA the bypassed script may remain isolated, but combat test validity must be restored before full project validation.
4. Only after A29 style is explicitly accepted, create distinct original PAR candidates per semantic generation authority. Preserve original Ground SHA and independently verify alpha/sprite/collision/tone. Log any purchased generation credits.
5. Native Godot, cold ZIP and actual VX map replay; source/hash/license ledger; private Drive upload and readback; update CURRENT_HANDOFF. **Formal Seal NO until verified both engines plus visuals.**

## A29 authoritative visual review
- Detailed Handoff: https://drive.google.com/file/d/1yMZS6zdYazsMTXaZT60GTwovGfG41Fc3/view
- A28 vs A29 mobile comparison: https://drive.google.com/file/d/1X_vUXPvVrs4rIkNi6jSy-8BdcblmT3nr/view
- A29 private stage folder: https://drive.google.com/drive/folders/1Rqdo_qw1Vdvpfcx2a5iOf7joH83ncVtT

**A30 Gate status**: semantic PAR authorization RECORDED; VX bootstrap in MAP-ONLY isolation NO MODAL / provisional; VX actual map NOT TESTED; original A29 Godot 8/8 baseline unchanged; art PENDING; Formal Seal NO.
