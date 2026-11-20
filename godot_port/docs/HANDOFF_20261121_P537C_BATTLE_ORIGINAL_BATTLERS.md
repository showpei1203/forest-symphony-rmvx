# Forest Symphony｜P537C 戰鬥原版敵人 Battlers 與 A52 12 幀演出｜正式 Handoff
Date 2026-11-21 Asia/Taipei. Godot 4.7.2 only. Branch feature/fs-godot-phase1.
Owner priority remains **BATTLE visuals and system → MENU original visuals → A35 map later**. Original VX on E: READ-ONLY. T-A/T-B/T-C independent branch and original source untouched.

## 1. REAL original source archive delivered privately (not a mock)
- Original VX Graphics/Battlers read-only, 167 PNG files, all raw bytes preserved in a ZIP with individual PNG names, SHA256, dimensions and CRC.
- Owner-only Drive archive: https://drive.google.com/file/d/1xd1ZIxLt-xPQ4NKqx3MoRpysdHYBJ1So/view
- Drive API verified: file ID 1xd1ZIxLt-xPQ4NKqx3MoRpysdHYBJ1So, bytes 183,658, shared=false, owner-only permission.
- Full source ZIP SHA256: `4d2f629ea643187d2b96999798214c1fdf75a1ec969df1c29561bf7bfa1ee9e3`; ZIP CRC PASS and 167/167 PNG signed source manifest entries.
- Includes Unicode names (e.g. `$騎狼矮人.png`), source image sizes vary: `$001.png` 24×24, `$002.png` 31×31, `$003.png` 45×41, `$llama.png` 96×192; image filenames are NOT the same as enemy record IDs.
- This archive does not prove all 11 original post-Apply FS DB tables are imported. Actual battle/enemy image ID authority must be original enemy `battler_name`; there is NO ID guessing.

## 2. Actual engineering
1. `tools/stage_private_battlers_537c.py`: archive SHA lock, per-PNG original SHA+dimensions+CRC, ZipSlip/duplicates/symlink/excess-size rejection and no-overwrite. Original PNG imported unchanged into gitignored `godot_port/assets/battlers/` in authorized ephemeral Godot workspace. Never upload source PNGs into public GitHub.
2. `scripts/ui/FSOriginalBattlerArt.gd`: mandatory private staged source manifest (167 files / archive SHA), original source filename + PNG per-file SHA guard. Render only when source `Enemy.battler_name` EXACTLY selects the original filename. Unknown enemy art, tampered PNG, missing owner art and unsupported original VX `battler_hue` changes fail closed.
3. `scripts/FSDatabase.gd`: original source enemy property `battler_hue` is retained in battle enemy stats, allowing proper source-only gating instead of silently inventing palette shifts.
4. `scripts/ui/FSBattleOriginalEnemyStage.gd`: additional Godot Control overlay shows only actual original source sprites for living enemies; reflects target HP/death by hiding dead sprites. It NEVER invents BattleScape backdrop, hitbox, new damage, AI, or a fake combat state.
5. `scripts/FSScreen.gd`: wires this source-only enemy stage into actual BATTLE; hidden on MENU, refreshes live, remains isolated from 544×416 main source 2×2 ATB/ACT command GridContainer and P537B Actor01 attack rig.
6. `scripts/ui/FSBattleActor01Presenter.gd`: actual 12-frame A52 Body/Weapon/FX presenter now hides its last attack frame when animation completes, avoiding a permanently frozen F11 sprite; actual attack serial and gameplay calculations stay unchanged.
7. `.gitignore` and public source-archive workflow explicitly EXCLUDE new private `battlers/` AND existing `ta_actor01/`; source PNG never goes to public artifact by accidental glob. Standard GitHub code archive remains safe.
8. Public Python fixture tests `test_private_battlers_stage_537c.py` validate all 167 original-format manifest rows, source corruption refusal, no-overwrite and path guard. Native `test_fs_battle_enemy_stage_537c.gd` validates original art absent fail-closed, Unicode path support, actual Godot enemy sprite render from synthetic image texture, dead hide, reset and real FSScreen link. Native P537B test checks A52 animation final pose is hidden without changing combat authority.
9. Source-art PRIVATE OpenGL reproducibility capture script `tests/capture_fs_p537c_private.gd`: only runs in authorized Linux /tmp staging with `FS_PRIVATE_SOURCE_QA=1`, checks real 167 Battlers and A52 original 3-layer atlas installed, takes `original_enemy`, `atb_ready`, `a52_f7_contact` screenshots at native 544 or 1088 width. The battle enemy DB fixture is still synthetic and specifically marked, NOT source final 11-table original parity.

## 3. Direct actual source A52 frame audit
- Real owner Drive A52 original three images were fetched independently, raw SHA reverified: Body `a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f`; Weapon `6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b`; FX `46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c`.
- All three are 256×192, 12 cells of 64×64 in 4×3. Body has real alpha geometry in all 12 frames; Weapon F0/F11 intentionally empty and F1–F10 visible; FX F5–F9 visible and others transparent.
- A52 contact F7 real source pixel check: Body 610 opaque pixels, Weapon 71, FX 38; Body/Weapon alpha overlap 8 pixels. This is a pixel audit, NOT a live Godot GPU or final art seal.

## 4. Native QA and essential limits
- Initial source-aware Battler+Stage code: https://github.com/showpei1203/forest-symphony-rmvx/commit/e5dc16020f559cb6fa8869d92a797616201c97cc
- Follow-up private screenshot harness and A52 finish cleanup: https://github.com/showpei1203/forest-symphony-rmvx/commit/57897ef6c0298a70f21865588254ed73dec2776f
- First entire official Godot 4.7.2 CI run `44834852276`: SUCCESS, public native & Python tests passed. Follow-up run `44835103484`: check completed conclusion separately before claiming full PASS (all new P537B/P537C steps observed success).
- Actual *private original A52 + original Battlers in SAME Godot 4.7.2 native GPU* **NOT RUN** yet this turn; private harness exists but not executed. No new GPU image generated on this line, no Drive GPU evidence zip falsely claimed.
- Original BattleScape/backdrop, original VX same-state pixel match, original Enemy.rvdata/post-Apply and 505 dynamic alias last-wins, A52 F7 animation 0.630sec vs actual ACT gameplay hit time, enemy battler_hue color shifts, unapproved RUN F6/F7: all remain HOLD.
- This branch is NOT final battle art. Phase1 SEAL NO; ART HOLD remains. Do not promote synthetic integration QA to ART PASS.

## 5. NEXT MACRO UNIT (no redoing P535–P537)
1. In an authorized isolated owner-only Godot workspace stage existing A52 Body+Weapon+FX from private Drive by `tools/stage_private_actor01_attack_537b.py` and private 167 Battlers ZIP by `tools/stage_private_battlers_537c.py`, run pinned Godot 4.7.2 --editor --quit then private capture harness with explicit Linux /tmp output and 544/1088 widths; verify 6/6 real OpenGL source images and archive proof privately to owner Drive.
2. Identify original BattleScape background authority from original RGSS2 and separately source-hash the correct background(s), not a random Parallax. Then align enemy source image positions and actor animation to actual FS combat viewport.
3. Reconcile A52 visible contact t=.630 with original ACT charge/hit timing without changing original damage authority based on visual-only signal; full source witness before 70ms Hitstop wiring.
4. P538 complete six-character original MENU visuals and skins; then return A35 Map and story/event scene. Keep P532 playable vertical slice and all prior tests intact.

## STATUS
Private Battlers source VERIFIED / SRC SHA+CRC PASS; new native code & regression QA underway; main real private GPU P537C NOT RUN; original VX source unchanged; GitHub text-only + private Google Drive binary authority; Phase1 SEAL NO.
