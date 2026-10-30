# ASF × Forest Symphony A09-4: real native VX Sprite_Weapon trace and Godot parity study

**2026-10-31. TEST-ONLY and fail-closed. STATUS: native Sprite_Weapon runtime evidence PASS; Godot 4.7.2 comparable 12-ROI render PASS; pixel-exact parity FAIL; full Scene_Battle dispatch, art and formal seal PENDING.**

## The native VX capture breakthrough

The prior A09-3 K4-only test clone launched Game.exe but could not execute the injected adapter or produce useful image/log output; that underlying failure is still unexplained. A known-good **N5+B0 isolated test runtime** was re-executed on the same PC, again passing its native frame and screenshot test. This proves the platform is not categorically unable to render/capture VX.

A separate working N5+B0 candidate was cloned without editing sealed sources and had **one new test-only script** inserted after the existing B0 adapter and before Main. Baseline: 505 original sealed N5 scripts, B0 adapter -> 506, new ASF test adapter -> 507; all earlier script entries remained byte-identical.

**Stage0:** actual Game.exe log demonstrated `SCRIPT_EVALUATED`, `Scene_Title.update`, `Spriteset_Map` frame 35; the real 544×416 RGSS2 window yielded a nonblack image (fraction 0.9998), confirming that the test hook and native renderer were actually running.

**Stage1:** actual `Sprite_Weapon` class from original Tankentai Sideview 2 (3.4d) was instantiated *inside Scene_Map* against test battler proxies that reference the real `$data_weapons[2]`. Three profiles: p01 normal attack 1, p03 normal attack 2, p05 weapon standby. A test-only overlay used real original character poses and native weapon sprites; the engine recorded `Sprite_Weapon.action/update` values during 4 steps and exported **twelve 90×105 PPM crops** using its own `Graphics.snap_to_bitmap`. User's private PNG contact sheet and PPM are local, NOT public GitHub resources.

**Important scope:** this is a real original RGSS2 Sprite_Weapon execution and render, but run in an isolated N5 **Scene_Map** control harness, **NOT yet** a fully traced original `Scene_Battle` attack dispatch. Never call it complete Tankentai combat acceptance.

## Two factual corrections, both supported by the native database/runtime

1. **Weapon ID ≠ IconSet index.** Actor#1 Joe's initial weapon ID is `2`, but `Weapons.rvdata[2].icon_index = 548`; its real 24×24 crop from `Graphics/System/IconSet.png` is **x=96, y=816**. A09-2 and A09-3 mistakenly drew icon **index 2 (x=48,y=0)**. Their screenshots are wrong-source art for this actor and are explicitly **REJECTED for actual weapon visual acceptance**. All A09-4 native Sprite_Weapon records report icon `96,816`.
2. **ANIME_PATTERN timing denominator is 3**, not 4. In original Tankentai, `@time` starts `N01::ANIME_PATTERN+1 = 4`, but the actual incremental angle/movement uses `time=N01::ANIME_PATTERN = 3`. A09-3's proposed 4-way formula was a source-reading mistake, now superseded by real native recorded values.

### Authentic logged RGSS2 angles (degrees)

| Sprite_Weapon call | tick0 | tick1 | tick2 | tick3 |
|---|---:|---:|---:|---:|
| Joe attack 1, p01 | -203 | -67 | +69 | +205 |
| Joe attack 2, p03 | +205 | +140 | +75 | +10 |
| Joe weapon standby, p05 | +65 | +65 | +65 | +65 |

Native p01: `z=2999` (in front of body `z=2000`), `ox=24 oy=24`, `mirror=false`. Native p03: `z=1999` (behind body), **`ox=0 oy=24`, `mirror=true`**. Native p05: `z=1999`, `ox=12 oy=12`, `mirror=false`. Actual X/Y changes at each tick, including integer step rounding, are preserved in `data/native_weapon_12_samples.json`.

## VX/Godot graphical parity attempt

Use the **correct native icon index 548**, original 32x32 FS source characters, exact recorded native weapon X/Y/pivot/mirror/front-back/angle (Godot rotation sign conversion). Real Godot 4.7.2 AMD RX 6700 XT OpenGL produced a 360×315 PNG containing **twelve** 90×105 comparable tiles. Each native tile was matched with the corresponding Godot render. Measured **real RGB pixel differences**, not just text-only technical output.

| Godot sampler | Mean foreground silhouette IoU | Sum of changed RGB pixels (12 × 90 × 105) | Mean absolute RGB channel difference |
|---|---:|---:|---:|
| Nearest (pixel-art default) | **0.98284** | **943** | 0.44873 |
| Linear | 0.97386 | 1172 | **0.43229** |

Nearest preserves sharper pixel boundaries and better foreground silhouette intersection; Linear has slightly smaller mean color error but significantly more mismatched pixels. **Selected: Nearest for pixel-art candidate.** Neither is 0-error; output remains **TECHNICAL NEAR-MATCH / PIXEL EXACT FAIL / HUMAN ART GATE PENDING.** Differences are concentrated visually near transformed weapon edges; no ungrounded claim of exact VX renderer equivalence.

## Isolation, artifacts and reproducibility

- Main K4 `Data/Scripts.rvdata` SHA256: `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`, checked unchanged.
- N5 formally sealed `Data/Scripts.rvdata` SHA256: `3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9`, checked unchanged.
- Isolated known-good N5+B0 candidate SHA256: `26f85ad278b6e08cc8634e3f9dc8b4ba15539888bf2920567d12244e328fa03c`.
- New test-only clones: `E:\GameAssetToolLab_20261023\ASF_Test_20261031\VX_A09_4_N5_CONTROL` (Stage0) and `VX_A09_4_N5_RUNTIME` (Stage1), never merged into FS game.
- Native & Godot actual screenshots, icon #548 crop, all 12 RGSS2 PPM frames, 12-frame contact sheet, per-pixel difference image, JSON and test source code are bundled in the **private Windows-only** ZIP:
`E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031\a09_4\ASF_A09_4_NATIVE_WEAPON_PARITY_PRIVATE_20261031.zip`.
**43 files; 110,916 bytes; ZIP CRC PASS; SHA256 `70fc24813dff9fb0de44575cf927c5f4840ce2e964c588b31530f0772d8f9f4b`.** This private binary ZIP is NOT uploaded to Drive or GitHub. Public GitHub stores only self-written code, non-image metadata, hashes and QA, to preserve image licensing boundaries.

Key repo files:
- `scripts/stage0_marker.rb`, `scripts/build_stage0.py`, `scripts/run_stage0.py`: clean boot and render-capture control.
- `scripts/stage1_real_native_weapon.rb`, `scripts/build_stage1.py`, `scripts/run_stage1.py`: actual RGSS2 native weapon runtime + PPM capture.
- `scripts/extract_real_weapon_frames.py`, `scripts/capture_a094_native_parity.gd`, `scripts/compare_vx_godot_stage1.py`, `scripts/compare_sampler_variants.py`: handoff to Godot with original art and compare.
- `data/native_weapon_12_samples.json`, `data/A09_4_QA.json`, `data/A094_RENDER_SAMPLER_AB.json`: numeric proof. Full exact local images retain native SHA, but are excluded here.

## Handoff / next gates

1. A09-5: probe actual `Scene_Battle` actor#1 attack dispatch, including ActionSequence/WeaponKey, actor equipment change, Z/mirror and timing in an isolated test map or safe runtime; compare with this **real** `Sprite_Weapon` reference.
2. Improve cross-engine weapon edge rasterization through deterministic sampling tests; **do not blur source sprite art to artificially inflate mean error scores**. Preserve native and Godot same-source, screen origin and nearest-neighbor.
3. Keep earlier 7 original Joe pose ASF clips TECH PASS as an asset-transport result. No claimed AI-generated new six-action actor. Only authorize new FS style art production after native battle/runtime test and human Gate F. Do not edit FS/R17/Tankentai/LPC sealed code or maps.

**Final status:** Native RGSS2 original Sprite_Weapon render **PASS**; Godot near match **PASS (candidate)**; RGB exact parity **FAIL**; actual Scene_Battle runtime **NOT RUN**; art approval **PENDING**; formal FS seal **NOT GRANTED**.
