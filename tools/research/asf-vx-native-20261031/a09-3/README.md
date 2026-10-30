# ASF × Forest Symphony A09-3: Joe weapon formulas, native capture blocker, fail-closed

**Date: 2026-10-31. STATUS: SOURCE AUTHORITY PARSED + GODOT GPU CANDIDATE RENDERED; RPG Maker VX native battle comparison NOT PASS.** This is an isolated test, not a new official FS asset and not a sealed acceptance.

## Important correction to A08/A09-2
The original generic `VERT_SWING` angles `[-75,-15,+45]` from prior reference are **NOT Joe's normal attack weapon angles**. The exact Joe weapon keys and their values were read from the original private K4 binary `Data/Scripts.rvdata` at script **#225: SBS Battler Configuration (K)**, not derived from image appearance. Parsed by `scripts/extract_joe_weapon.py`.

| Original Tankentai weapon key | Xa | Ya | Za front | A1 | A2 | Or | Inv | Xp | Yp |
|---|---:|---:|---|---:|---:|---:|---|---:|---:|
| 喬伊普攻武器 | -7 | +2 | true | -205 | +205 | 4 (bottom-right) | false | -1 | 0 |
| 喬伊普攻武器2 | +7 | -2 | false | +205 | +10 | 4 (bottom-right before mirroring) | true | -1 | 0 |
| 正常武器待機 | +3 | +3 | false | +65 | +65 | 0 (center) | false | -18 | +2 |

All three have `Xs=Ys=1`, `Weapon2=false`. Actor #1 is 喬伊 with `$actor01` and initial weapon ID 2 in actual `Actors.rvdata`; seven Joe-named pose keys exist (0 missing required sprite cells), and the weapon bindings are p01→normal weapon, p03→weapon2, p05→standby; four others specify no weapon animation. **This is a static reference, not proof each pose or exact timing is taken in a live battle.**

## Second key discovery: runtime Sprite_Weapon semantics

Original script **#227: Sideview 2 (3.4d)**, `Sprite_Weapon#weapon_action/#action/#update`, reveals:
- `N01::ANIME_PATTERN=3` and `time=4`. `Xa/Ya` are **increments divided by the 4-update period**, not full initial displacements. The initial Godot preview incorrectly applied full `Xa` at t0 and looked detached.
- Ruby Fixnum integer division and remainder are used for `@moving_x/@moving_y` and `@angling`. For `-205→+205`, four-step division = `102` with remainder `2`; for `+205→+10`, = `-49` with remainder `1`. An arbitrary `lerp` does not exactly reproduce these integer updates.
- If the weapon is mirrored, origin **4 (bottom-right) is transformed to 3 (bottom-left)** before assigning the sprite's `ox/oy`. Previously the preview retained Or4 despite horizontal mirroring.
- The renderer uses `x=battler.position_x + move_x + plus_x`, `y=battler.position_y + move_y + plus_y`; Z is front/back according to the native action.
- `@mirroring` from the battler may further reverse X and angles. This test assumes an **unmirrored battler**. Full dynamic battle mirror & exact call-order are NOT verified.

`scripts/audit_weapon_runtime_formulas.py` makes a source-inferred four-step table for three weapon actions in `data/source_formula_audit.json`. This table is a **source-derived timing candidate**, not a captured RGSS event trace; runtime invocation/cadence must be measured before parity PASS.

## What ran
- Native Godot 4.7.2 + AMD RX 6700 XT OpenGL displayed **15** V1 actor/weapon snapshots (p01,p03,p05 × 5 fractions). V1 identified as **VISUAL FAIL** due to full Xa at initial frame, mirroring pivot error and generic interpolation.
- Godot 4.7.2 rendered **12** source-inferred V2 candidate samples (3 weapon actions × 4 steps), with corrected mirror pivot, per-update movement, native source offsets and Z layering. Exported `A09_3_WEAPON_FORMULA_V2_CANDIDATE.png` and `A09_3_WEAPON_FORMULA_V2_LOG.json` **on the PRIVATE Windows PC**. GPU render worked, but **NO native VX image-matched comparison or human visual approval**, so remain candidate.
- A separate 3,860-file (~524.8 MiB) K4 clone `VX_A09_3_INENGINE_BRIDGE` was created for instrumented RGSS testing. Script #482 *before* Main was instrumented with one test-only adapter; the **505 original entry contents were byte-identical** after removing the extra test entry. Its `Data/Scripts.rvdata` candidate has 506 entries. Two probes (Scene_Title hook and top-level pre-Main invocation) launched Game.exe and waited 65 sec but **produced no adapter log or native framebuffer pixels**. The earlier screen capture returned all black while the foreground desktop bbox showed a browser, with `foreground_ok=false`. A live Game.exe process is not evidence of a successful boot-to-battle or screenshot.
- The result is **VX_NATIVE_CAPTURE_BLOCKED / NO PARITY PASS**. Root cause is unresolved; do not assert the title screen, Graphics or adapter executed.

## Art rights and proofs

Actual K4 source sprites, cropped weapon icons and GPU screenshots were deliberately **NOT uploaded to this GitHub branch**. Code, source SHA, JSON metadata, runtime adapter and provenance are retained here. Complete private local bundle:
`E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031\a09_3\ASF_A09_3_WEAPON_PRIVATE_20261031.zip`:
**21 files, 79,799 bytes, CRC PASS, SHA256 `0b2e106168f83b31408126f683edcfed59bbf52681d858d990690ff267cb8ca1`.**
This ZIP remains local only. Repo text files are not evidence of cloud binary backup.

Original baseline `Scripts.rvdata` SHA256: `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`. Original `$actor01.png` SHA256: `df6abaa888dc4ffcaf5351daf26d678bace121e277f21b4651eb69884591a2a5`.

## Acceptance decision and next gate

**Technical source mapping: PASS.** **Godot render execution: PASS (candidate only).** **Weapon visual/native parity: NOT PASSED.** **Original AI model six-action generation: NOT TESTED.**

Next is A09-4: secure authorized interactive RGSS2 rendering with deterministic input and capture. First produce a verifiable in-engine frame or log (the A09-3 adapter did not execute), then run actor #1's actual battle action and inspect `Sprite_Weapon` actual angle, mirror, offset and `position_x/y` at each frame against Godot. Resolve the native lifecycle blocker rather than adjusting art by eye. Keep FS, R17, D32A3a, LPC, PMD seals intact. All failures are retained; no source art is generated or replaced this round.
