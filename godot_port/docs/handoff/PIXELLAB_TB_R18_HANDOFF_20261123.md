# Forest Symphony｜T-B Monster ART｜R18 Handoff｜2026-11-23
## Scope／正式權威
- 此對話唯一施工線 **T-B 怪物美術／進化／Sprite Sheet 量產**，與 T-A 角色、T-C Ground→PAR、Godot 主線 P539 等隔離。正式 GitHub `feat/fs-pixellab-tb-monster-20261121`，嚴禁改動 main/T-A/T-C 或戰鬥 ATB/ACT/UI/EnemyID。Godot **4.7.2** 正式引擎。
- 以最新使用者繼續施工、T-B CURRENT_HANDOFF、`FS_CONTROL_TOWER_PROTOCOL`、共用 GitHub 正式 Skill `fs-monster-evolution`、`fs-godot-testing`、`fs-handoff-qa`、`ai-pc-routing` 及 [PC Control Routing](https://github.com/showpei1203/chatgpt-pc-bridge/blob/main/docs/PC_CONTROL_TOOL_ROUTING_PROTOCOL.md) 為準。舊 FS VX-first Skill 與目前 Godot 4.7.2 衝突，採最新規定；這些 Skill **經 GitHub 實際讀取**，不能當作這個對話自動載入 Windows Skill。
- 原始 R17 owner-private [真 PixelLab 三階 Guard + Native ZIP](https://drive.google.com/file/d/1v3X73vvfkfH1i--dLYd-vYlMvd8de1Ku/view)，SHA256 `d7e8d8b168e8f4553ba735972d1fb573f1439d3850aedb1c2dd5bd30b6e581ad`，430 files，11,295,309 bytes，完整保留；此前 96 clips / 862 frame slots。
- **P0** 私人 PNG/原始Provider生成/ZIP/Review/QA 僅存 owner-only Google Drive，GitHub 只存程式、Handoff、Failure Log；Window Runner 只允許 run-specific TEMP，結果雲端回讀成功才能清理，絕不操作使用者正式 `E:\遊戲專案開發`。Desktop Remote=0，Codex=0。

## R18 M1｜三階真 RUN 步態 12F，各自真實 PixelLab｜來源 PASS
- 新增第三家族 Glacier Jackal 三階的 **RUN / Locomotion 12F ×3**，固定東南 3/4 視角，原本 4 足／耳／深藍吻／冰晶／尾巴與來源身份一致。實際 `PixelLab v2 /animate-with-text-v3`，不是程序性上下跳動、也不是重新生成 3 張沒有來源的概念圖。
- 每階分開固定 Bridge 任務。先測真正來源、提示詞、整套 Mock 帳本/12F 封包：Windows [Issue #93](https://github.com/showpei1203/chatgpt-pc-bridge/issues/93) / [Actions 45115175552 SUCCESS](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115175552)；三階 prompt 長度 462/465/466，**零新付費**。安全負面測試 [#92](https://github.com/showpei1203/chatgpt-pc-bridge/issues/92) 拒絕 Issue 多餘 command。
- 真 Provider 工作：
  | 階級 | 實際 Windows Action | Provider Job ID | RAW→Export | 實際 generations |
  |---|---|---|---|---:|
  | S1 Glacier Jackal Pup 128px | [#94 SUCCESS 45115317384](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115317384) | `cbb6bde2-ec68-4512-8624-a4105daece3d` | 13→12F | **3.0** |
  | S2 Crystal Wolf Guardian 160px | [#95 SUCCESS 45115563273](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115563273) | `da7e1a88-4a36-46c8-94e3-5e3c10d74657` | 13→12F | **5.0** |
  | S3 Ancient Glacier Fenrir 192px | [#96 SUCCESS 45115743279](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45115743279) | `0a3b653b-6995-4c04-adc4-f900fd98ad47` | 13→12F | **7.0** |
- **總計 3 真 PixelLab 動畫工作、39 original provider returned raster frames、36 source-locked exported frame slots、真實 Provider `15.0 generations`（USD 未提供，絕不可猜）。** 第0與最後影格直接比對既有 Idle F0 源像素一致，所有中段是實際 V3 生成影格。下部身體 alpha 11 distinct frames／各階，並有非透明/像素裁切/source SHA/圖集格式檢查，**足部交替美術合理性仍須使用者以 1× GIF 驗收**。
- Per-stage actual owner-private sources（包含 immutable raw frames、source anchor、provider ledger、工作 ID、generation usage、幀 SHA、PNG atlas；每個分別逐檔 QA，不合格不得再提交相同付費 request）：
  - [S1 98,077-byte genuine ZIP](https://drive.google.com/file/d/15T1F7JUcRrirfpazRWOBj1103NYCuYpj/view) SHA `e280445ad90a18f7e57edce91e8b717d0bc1866d2493478cad4d4a65c9512c99`;
  - [S2 162,559-byte genuine ZIP](https://drive.google.com/file/d/1OcJwLftaCTcphF4xYIg0j1NyIoEABVQI/view) SHA `313006e9478dee93801ee8c46169d0c03db095a61857122ddba24294d91ac1f3`;
  - [S3 311,214-byte genuine ZIP](https://drive.google.com/file/d/1E3i3FUvy4xz5oP1SzKZgIaCVRUCvAf9e/view) SHA `6e16c3a3c4361e7e033a3b68e92898605cfeb7e5b0c777bf9311c780f7fd1bd5`.
- [三階真 36F 逐幀接觸圖](https://drive.google.com/file/d/1-B4JZO2AFwjQOvKGTaaKiCLlIFfnJKjj/view)｜[初階 12F GIF](https://drive.google.com/file/d/1LBInhk-3zMjQiF4L1ARiUTA8-oZHLrYR/view)｜[中階](https://drive.google.com/file/d/10ReKgLaNieagQpWKOf8NFZcAuSRFUnzY/view)｜[高階](https://drive.google.com/file/d/1kD1HbeuVkOLOZxN-dWOUB6mKjgeeqebE/view)。
- 真 M1（**不是 synthetic test**）：[446 檔、12,625,007 bytes Private ZIP](https://drive.google.com/file/d/18Wj8NoZT-YHydfnt0HgO967_LhmPnevL/view) SHA256 `7cecc170615a205c30ed28efa0c1d19887f8782aeb5d73784a4b52cbd200e40e`，原 R17 PNG 逐檔 SHA/位元組未修改；Manifest 原先 `technical_qa=NATIVE_NOT_RUN`，含獨立新 R18 Godot scene/test。原實際 Godot 源專案 3 家族 /9 階、**93 個基本動作／6 個 EVO FX＝99 clips／898 frame slots**。

## R18 M2｜Windows 官方 Godot 4.7.2 原生真驗證 PASS
- 第三個獨立 Bridge 固定原生任務 `fs_tb_r18_run_native`，白名單只接受 `{"schema":1,"task":"fs_tb_r18_run_native"}`，只認固定 owner-private M1 **SHA `7cecc...`、12,625,007 bytes、446 entries**。Issue 額外 `command` [negative #97](https://github.com/showpei1203/chatgpt-pc-bridge/issues/97) 如預期 REJECT（Security PASS）。
- 實際使用者 Windows Runner [正向 Issue #98](https://github.com/showpei1203/chatgpt-pc-bridge/issues/98) / [Actions 45116388305 SUCCESS](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45116388305)，**Godot 4.7.2.stable.official.ed1daf0bf**，編輯器 headless import ExitCode 0，原生動畫載入/播放/影格/尺寸/數量的 `res://tests/test_tb18_frost_run_native.gd` ExitCode 0。完整真 Native marker：
  `FS_TB_R18_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=93 evolutions=6 clips=99 frames=898 frost_run=3`.
- [官方私有 Drive 原生日誌](https://drive.google.com/file/d/1szEjFDy_hWXmewFC0fpmB87Ud5-v2pU9/view)，585 bytes、SHA256 `58ac2673eac5311d09f6fb9443ed5a13f418c5f853bb23ae3d35671be255afb3`；已從 Drive 實際下載驗證原始 log SHA/成功標記。**不是**舊 R17 native proof；沒有非 headless GPU 截圖，不宣稱完整 FSBattle / ATB / ACT 或劇情整合。

## R18 M3｜正式 Cloud-only 提升與 P0 完整性
- 原生測試完後，使用固定[原生驗證升版程式](../../tools/pixellab_tb/promote_tb18_native_art.py)只把同一份已通過 M2 的 M1 manifest 改為 `NATIVE_4_7_2_WINDOWS_VERIFIED`，內嵌 exact Windows log + 原生證明檔；所有舊／新 PNG 與三份真 Provider ZIP **逐檔 SHA 相同**，未重新生成素材，追加 provider generations **0**。
- **最新 R18 完整正式私人封包：** [448 entries、12,626,646 bytes](https://drive.google.com/file/d/1UAaekoyo-HLqNYK8gDHppMCzLIVCMPyp/view)，SHA256 `8cc85ea1ca326ce854b3432a46c63fb311aaba3ca5628d101e10a54fc03cae6c`，ZIP CRC PASS。Google Drive API 確認 parent `10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`、`shared=false`、唯一 `user:owner` 權限；**重新透過 Google Drive connector 下載完整 ZIP 後**又驗證 448 entries/完整 CRC/SHA/native marker/Manifest **PASS**。
- [正式 Release 證明 JSON](https://drive.google.com/file/d/1TGdajg2DOJfHj3Khk6UNTVoV5VkInp_R/view) | [M1 歷史原始證明](https://drive.google.com/file/d/1y0O_iUKjueRjst-a6wj66nfadKGwMVQq/view)。R17 source、R18 3 stage provider zip、R18 M1 均留私人 Drive 供回溯。
- Windows 上每個 native/生成程序只建立以 numeric GitHub RunID 名稱的工作 TEMP 並於成功/例外清理；正式 E: 及其他專案資料從未更動。無 Desktop Remote、Codex。

## R18 M4｜三個不同成熟度的真樣本（不能當成三個新家族）
- R18 同一套真步態規格已分別在 128/160/192 三種 **來源 SHA 鎖定**成長型態，均產出真 provider 12F、來源格式/alpha/足部輪廓驗證並共同通過實際 Godot 4.7.2 原生展示；**仍須 OWNER 視覺 ART 1× 驗收**。

## 最新真實 Gate
| 項目 | R18 |
|---|---|
| SOURCE / 授權／身份／原始 R17 PNG 完整性 | PASS |
| 真 PixelLab 3×12F RUN + provider ledger/cost | PASS（15.0 generations） |
| 逐幀圖集、alpha 與下半身形變 | PASS（不等於視覺認可） |
| Windows Godot 4.7.2 editor + native animation gallery | PASS |
| 私人 Google Drive source/native/CRC/SHA/write-readback | PASS |
| 1× GIF 人工視覺與 owner 最終美術核准 | **AWAIT_USER_ART** |
| 主線 Battle/ATB/ACT/事件/存檔整合 | **NOT_RUN_ART_ONLY** |

**Next complete M1→M4 ART unit = R19**：霜晶狼三階 **SKILL 12F** 真實 PixelLab 攻擊/冰晶釋放動畫（需可見起手、能量展開、收招，不能變成新增怪物或整張圖晃動），用三階分開、source-locked single-paid-job + journal/raw archival 模板，先跑離線完整 ledger/schema，附官方 Godot472 native test、私人 Drive與逐幀視覺 QA。到 R18 止 Glacier Jackal 每階 **7/12 動作**，尚缺五類 **Skill、Stun、Taunt、Charge、Release**，共 **15 true animation clips**。

**Handoff/Failure source：** `godot_port/docs/handoff/PIXELLAB_TB_R18_FAILURE_LOG_20261123.md`；指定分支 `feat/fs-pixellab-tb-monster-20261121`。No generic Windows tools or unreviewed paid API calls.
