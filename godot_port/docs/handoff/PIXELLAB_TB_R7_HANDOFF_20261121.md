# Forest Symphony | T-B R7｜第一家族封版展示與第二異種葉翼蝠成功重現

日期：2026-11-21，Asia/Taipei。工作分支：`feat/fs-pixellab-tb-monster-20261121`。Linear：SHO-37。

## 1. 本輪真正的狀態變更

- **PMD0001 熔岩蛙 Attack V6 = USER_ART_ACCEPTED**：使用者在本輪明示「這個攻擊動畫很好，繼續」。不再要求 F4/F5/F6 微修；11 幀、96×96、原始 PixelLab job `3fea688e-1c8c-451c-aa3f-84941166dca2`，已花 3 generations。三個家族造型和 Idle 技術整合 PASS；非此處獲得明確使用者美術核准的部分仍按原有 Gate。
- **PMD0001 family Godot 4.7.2 integrated showcase PASS**：3 stages + historical 3F Idle + user accepted V6 11F Attack；F2 Rush/F5 Hit/F7 Return，Hit exact once；與第二家族工程合體後重新 regression PASS。
- **第二完全不同物種：`TB02_LEAF_BAT` 葉翼蝠**。來源：過去 P1E MIT `pixel-asset-gen` 蝙蝠 16px 僅作物種語意參考，真正像素圖以 PMD0001 96px source style reference 運用 PixelLab `generate-with-style-v2` 新製，非直接放大 OSS bat，也不是熔岩蛙換色。
- TB02 3 階（96、128、160px），母體 8F 96px Idle、**11F 128px Attack** 均為真正 PixelLab 生成；**已通過 16/16 Python QA + Godot 4.7.2 原生功能回歸 + 8/8 + 11/11 原生擷取**；ART 仍 `PENDING_USER_REVIEW`，不是自動替使用者核准。
- **96px 初代 Attack 嚴重翅膀裁切（10/11 touching canvas）→ 128px 有透明邊緣的原圖 input + 明確翼骨架重生 → 新版 11/11 邊緣接觸數 0，阻斷解除。** 失敗素材單獨存，不覆蓋。

## 2. Provider 工作與成本（實際使用，不杜撰美元等價）

| 工作 | Job ID | generations | 結果 |
|---|---|---:|---|
| Stage 1 style reference，4候選 | `2f226aea-61d0-4db2-a49c-ab617d6b1c1b` | 10.0 | 96px 母圖選第一候選 |
| Stage 2 edit v1 | `ae2b1e16-5a04-4c67-83c1-7faf96bd10c6` | 1.0 | REJECT：剪影相似 0.858 |
| Stage 2 edit v2 | `e9c4d096-673d-44b4-8a28-a96e4d422679` | 1.0 | 128px候選、身份維持 |
| Stage 3 edit | `1ce20fda-4af6-4a3c-a1ff-1cf1bcb5537a` | 1.0 | 160px最終候選 |
| Stage1 Idle 8F Skeleton v3 | `2475d037-ee79-4033-a403-35eea4abe47e` | 3.0 | 384×192 atlas，8幀無裁切 |
| Stage1 Attack 11F 原96px Skeleton v3 | `34b4b03b-aa08-4c43-9629-eb3c263e2ae6` | 3.0 | REJECT：10/11幀邊界，疑似翅翼被切 |
| Stage1 Attack 11F padded 128px Skeleton v3 | `75368d39-ba66-42fd-b90c-b1b19833258d` | 3.0 | 512×384 atlas，11/11無邊界接觸 |

**TB02 合計 22.0 訂閱 generations**（含 2 次拒收工作、7個實際 Job），不是美元金額。熔岩蛙 V6 原已支付 3.0 generations，這輪沒有重新生成熔岩蛙。

## 3. 來源鎖定

- P1E MIT procedural 16px bat `bat.png` SHA256 `321582743a4aa6b2e5105221b46da0fa29729bcfce63356a6bd078c3a22983b1`；僅作物種語意，不直接作 96px 素材。
- PMD0001 approved style reference 96px SHA256 `e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72`，只借技法，不借身體構造。
- TB02 Stage1: SHA256 `208e28e4f7732233c75456e9e5de671f5616fb68ef735165219a4b3aa2a959a2`。
- Stage2: `1b98c93ab8827b07d3b1c4ba7a92063fb800054d23a3256beab81e226864faac`。
- Stage3: `13491e632d9ed453e2c77c4799a3d63bd382b4433cf6135a1afdb0ed2a8d00f3`。
- Idle: `5153e58ccf29dee9d924937fb185169f45e2d0f748a36373cc2f53d4eb72e0a2`。
- **128px Attack accepted as TECH candidate**: `0a4327d1a951673f2fea6ce982f5b9790a9398066d614d9a85809d9daad5da58`，PixelLab generation ID `8c9dfea5-dd81-4e14-953b-df2d4ae2f41a`。

## 4. Native QA and Visual Gate

- Version `4.7.2.stable.official.ed1daf0bf`, Godot headless import and script PASS; real private PNG, not synthetic test fixture.
- OpenGL Compatibility / Mesa llvmpipe with Xvfb: stage lineup screenshot plus 8 Idle + 11 Attack native PNG captures PASS, sprite atlas `cell_size=(128,128)` used by parametric timeline. F2 Rush, F5 Hit once, F7 Return, cancellation regression of first family unaffected.
- Python technical checks **16/16 PASS** (dimensions, visible pixels, 2 silhouette IoU thresholds, atlas, unique frames, event, exact costs). Idle border contacts all 0; **new Attack border contacts all 0**.
- Stage3 static touches left canvas at 2 opaque pixels, logged **NONBLOCKING** for first template. Precise 45° human art gate is still pending. No false ART pass: second species `ART_REVIEW_PENDING`.
- Silhouette IoU Stage1→2 `0.467` Stage2→3 `0.528` on centered canvas. Unlike recoloring, wings/torso/crown silhouettes change.

## 5. Deliverables / SOURCE OF TRUTH

**All rasters/GIF/native screenshots/private Godot ZIP are PRIVATE Drive; scripts, QA tools and handoff in GitHub only.**

- [Private complete two-family Godot+evidence ZIP](https://drive.google.com/file/d/1EGL4eOiZq3Bx0Rxl83fIBjlzklGMHEEo/view) · **80 entries**, CRC PASS, SHA256 `7c8d84fc1e0b7dfc9081222e31728e521d452897603ef77985c29b68ecdf317f`.
- [Actual Godot 4.7.2 TB02 family screenshot](https://drive.google.com/file/d/1dXB8AQrNHXCuqQD_AjKEjHF3ruKNlCsQ/view)
- [Bat native Idle 8F GIF](https://drive.google.com/file/d/1HIsgGUkTrKd2bn1CPwn9H0vrR63Tb2u4/view)
- [Bat native Attack 11F GIF](https://drive.google.com/file/d/1ja7b3CNzMD0i-H9sR2Y6HKDEUhmpM0qE/view)
- [128px Attack spritesheet](https://drive.google.com/file/d/1rup099nbuW2I7kuQj-cqSyS1Ma7Lcye8/view) / [technical QA](https://drive.google.com/file/d/1AmVK7bPNgZeQudHkV1wvvrKJoXEbVmCp/view) / [cost register](https://drive.google.com/file/d/1EOZ7aHhGZYBYOGVPOVm1Vn7IEHrf5PYc/view)
- [Earlier R7 first family approved V6 comparison ZIP](https://drive.google.com/file/d/1RssdQoIWl-Tcy6R-JPNi1vWOKexj8IzQ/view)
- New source script: `godot_port/tools/pixellab_tb/tb02_bat_style_family_provider.py`, `tb02_bat_evolve_edit_pixen_v2.py`, `tb02_bat_animation_provider.py`, `tb02_bat_attack_pad128_provider.py`, `tb02_factory_qa.py`; Godot `tb_attack_timeline_parametric.gd`, `tb02_bat_showcase.gd`, `tests/tb02_bat_native.gd`, `tests/tb02_bat_capture.gd`, `tests/tb02_bat_frame_capture.gd`.
- Do not merge these assets into FS main battle code until next integration gate. `main`, T-A, T-C untouched.

## 6. Next FULL production unit

1. Request user art review of second species **based on actual Godot native animation and family progression**; keep `ART_REVIEW_PENDING` until explicit approval.
2. Once approved, promote TB02 to `USER_ART_ACCEPTED` and connect TB02 to the independent FS battle preview under the existing event API. Verify 45° in real battle camera.
3. To validate low-cost repeatability, benchmark third distinct source at same established production model, compare pass rate and 22-generation spend including retries. No batch 500 monsters until family/style/attack consistency gate.
4. Preserve artifact registry / Failure Log / cost in cloud, avoid further discretionary micro-pixel rerolls.
