# Forest Symphony｜T-B R17｜2026-11-23｜霜晶狼三階真 PixelLab Guard＋Godot 4.7.2 原生驗證

## TARGET / 優先權
- **線別 T-B MONSTER ART ONLY**；指定 `feat/fs-pixellab-tb-monster-20261121`。凍結 R16 93 clips /838 slots 全部來源圖；main、T-A、T-C、Battle、ATB、ACT、HUD、EnemyID 不動。
- 本輪依最新 CURRENT_HANDOFF、使用者立即施工指令、Roadmap M1→M2→M3→M4、共用 `fs-monster-evolution` / `fs-godot-testing` / `fs-handoff-qa` / `ai-pc-routing` Skills。這些 Skill 是從 GitHub 正式 v0.1.0 SKILL.md **實際讀取**，不宣稱此聊天自動匯入 Windows Skills。舊 `fs-rmvx-router` 所謂 VX 為主的敘述已被新 Godot 4.7.2 使用者命令取代。
- 真正原始來源：[R16 user-private ZIP](https://drive.google.com/file/d/1Mi0BcmKdK6qwiQKnmSrcXbX5cSFpgs7p/view)，**10,547,433 bytes，387 entries，SHA256 `a3292f8e9ce94648f8a9d61bb22271a4d3d3f92fc02f132fb18c5278e92d9efe`**。三階 source SHA：一階 `b3c5ac1487b5f68f01f792f18ce0de85c662f3ec255766d9bf97bb7cb6a8de20`、二階 `2e5a53ab2558bb5922b63e2a335408e9e87831aeb8661b977fd7548bb4708359`、三階 `6ad516093d262670a45893b44905d86513e6224be6b35d5b7b65642ef342de6e`。

## M1：完整 3 階 Guard 真實生成｜SOURCE QA PASS
- 霜晶狼 TB03 Glacier Jackal Stage1 128×128、Stage2 160×160、Stage3 192×192，皆用**各自實際 R16 same-stage Idle source F0，PixelLab `/v2/animate-with-text-v3` 受控 SE 3/4 Guard 身體防禦動作**。每階 8F，總計 **3 組全新真實 PixelLab 動作 /24 個輸出影格**。不是舊動作重排、不是純程式晃動。
- 3 jobs：
  - Stage1 `fce98632-18e9-4dfa-bcb1-1517f916a6d7`，**2.0 provider-reported generations**，atlas SHA `23c1e6185708983a7fba431b5ce2a373a4965b1b36d7dc7b16cee340fdd9fdec`。
  - Stage2 `55f41d72-ffb8-4c82-992f-a9b3f80e5848`，**4.0 generations**，atlas SHA `ba138f26bda523f8c61f893b933a3b1bd0159573258a8f9379ca8ea029747a7b`。
  - Stage3 `649e7836-2cec-4272-a8eb-4d69efbcddc9`，**5.0 generations**，atlas SHA `d570f417b15b24bd8b6158c356374adc23274640a77e6405fa6328deb77905d2`。
  - **真實用量 11.0 generations；USD 未獲報價，不能猜。** 已知 3/3 provider jobs completed，真實原始 Provider frames/seed/prompt/usage/provider JobID/圖集 SHA/alpha bbox/不碰邊與 unique frame 驗證全存私人 release。
- 第 0 與最後影格像素精確鎖定原始同階 Idle F0，保留 v3 真實中段生成影格，**唯一影格 7/8**，3階 source identity 與 45° 東南 3/4 視角保持候選。原 R16 所有 PNG 位元組逐檔比對皆未變。
- [3 階逐幀真美術比較](https://drive.google.com/file/d/1au_ZQZ_okNrnspwQRyQuP-Vc9fTGVox5/view) | [初階 8F GIF](https://drive.google.com/file/d/1ZtyeBc2n3pOAWtxBq6WRN312KMrfleBi/view) | [中階](https://drive.google.com/file/d/13Q9zmTdezL7CP4Xowla9s5QNOZNjfi43/view) | [高階](https://drive.google.com/file/d/1d5Ij5RTGH_5JJWLY8_81RV_ffK7RWmjo/view)。**人工美術 USER/OWNER_REVIEW_PENDING**。

## M2：真正官方 Windows Godot 4.7.2 PASS
- 原生使用者 PC 工具依最新 [AI PC Routing](https://github.com/showpei1203/chatgpt-pc-bridge/blob/main/docs/PC_CONTROL_TOOL_ROUTING_PROTOCOL.md) 走**私人 GitHub PC Bridge 嚴格 allowlist**，完全沒有 Desktop Commander / Codex；不是直接假設可跑任意命令或自稱 Orca GUI 可用。
- 橋接器先跑只讀環境預檢：[Issue #83](https://github.com/showpei1203/chatgpt-pc-bridge/issues/83) [Actions success 45110459531](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45110459531)。Runner 源檔 SHA/大小/387 entries、既有 PixelLab token**僅可用性**、Godot 4.7.2 確認；沒有印任何 token 值。
- 源腳本 AST + Pillow + 三階提示詞 **476 /479 /480 chars** 的零費用真機 preflight PASS [Issue #88](https://github.com/showpei1203/chatgpt-pc-bridge/issues/88)、[Actions 45111282275](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45111282275)。
- 更重要，付費生成後 Windows QA 不再執行任何 PixelLab：固定 source M1 ZIP **428 entries，11,293,853 bytes，SHA `649632b8f384a34c8053bb66ad13a9644017dc3806c74b7a8460037a853ad693`**；私有 [M1原始候選](https://drive.google.com/file/d/1oyChp5HzDemmzAf5opBzauW1wDspx3kk/view)。
- 實際正向 [Native Issue #91](https://github.com/showpei1203/chatgpt-pc-bridge/issues/91) [Actions run **45112146277 SUCCESS**](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45112146277)：官方 Windows **Godot 4.7.2.stable.official.ed1daf0bf**，`--headless --editor --quit` exit0、原生獨立三階 Guard 動畫場景測試 exit0：
  `FS_TB_R17_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=90 evolutions=6 clips=96 frames=862 frost_guard=3`。
- [私人原生日誌](https://drive.google.com/file/d/1Dc0VKvkwYvLxcLOzeieHMjfLUkF96wmd/view)，599 bytes、SHA256 `e3e350e5e66ad7df9d494f6552ed02ccac67851dbd6852df14e725669f8ec368`。
- **不宣稱非 headless GPU screenshot、實際遊戲戰鬥／ATB 整合或最終美術合格**。

## M3：真正阻斷修正 [FIXED without paid reroll]
- 付費前第一次 Guard prompt 超過 520 chars，嚴格本機 assert 即停止；修正後 Stage3 為 496 >495 被預檢阻擋。兩次都 **0 PixelLab jobs / 0 generations**。已改為提交第一筆付費前先驗證三階全部 prompt，最終 476/479/480 chars。
- 第一批真正付費 [Issue #89](https://github.com/showpei1203/chatgpt-pc-bridge/issues/89), [Actions 45111349220](https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45111349220)：3/3 PixelLab **確實已產出並完成真實 PNG 幀技術 QA**，但最後 `create_project()` 將 `ledger['reported_usage']` 錯當成 `ledger['usage']`，出現 **KeyError: 'usage'**。因此 original live Actions FAILED 並非 PixelLab 動畫生成失敗。已自動封存 **419 文件／10,950,160 bytes／SHA256 `4845398136e7f11202af6b059a85f1dc7f68450d5d8eb229fdbe8177aa61baa0`** 的 [真正三階付費 ART HOLD 素材](https://drive.google.com/file/d/1wGrzPuXH_a_9k7170cl9WGfYC__-yqo-/view)，含3真Provider job及 raw frames。
- **沒有重跑 #89，不重複付費！** 使用 [R17 source recovery](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/build_tb17_guard_recovery.py) 從私有真付費 ZIP 逐筆重建 scene/manifest/atlas；M1 source source-pixel 技術 QA PASS。另使用 [R17 official native promoter](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/promote_tb17_guard_native.py) 核對真 Godot 日誌後升版。**復原新增 API generations 0**。
- 安全負向測試：付費任務額外 Issue command [#85](https://github.com/showpei1203/chatgpt-pc-bridge/issues/85) 受拒；救援 Godot 任務額外 command [#90](https://github.com/showpei1203/chatgpt-pc-bridge/issues/90) 受拒。預期 Actions FAILED 是 Security PASS，不是交付失敗。

## M4：第二、三獨立形態樣本
同一個已驗證的 guard template 於幼階（128）、中階（160）、高階（192）**各產出真正 PixelLab 8F** 並通過同樣 source→native 圖集驗證。不同階段角色身份、原像素來源／造型有明確差異；這是同一家族跨三階可重複利用性，不宣稱已有「第四家族」。

## Final PRIVATE cloud release (full byte readback)
- [**R17 430 檔完整正式私有 ZIP**](https://drive.google.com/file/d/1v3X73vvfkfH1i--dLYd-vYlMvd8de1Ku/view)，**11,295,309 bytes**，全檔 CRC PASS，SHA256 `d7e8d8b168e8f4553ba735972d1fb573f1439d3850aedb1c2dd5bd30b6e581ad`。正式 ZIP 包含原始 3 階真 Guard PixelLab PNG、Provider 真實原始影格／帳本／生成工作 ID、原生 Godot 專案／獨立測試與精確 QA 日誌。
- [Release proof](https://drive.google.com/file/d/1mbwuEAhVD-c_HPp3c8fzIEewN2GtWz6p/view)、[Source recovery QA](https://drive.google.com/file/d/1MytbdisAvwwlwG6jxKgHT6VkmAT3gtnB/view)。
- Google Drive API live metadata 直接回證原私人 folder `10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3`、ZIP 大小 **11,295,309**、**shared=false** 且 **user:owner** 唯一。由 Drive live 完整 **重新下載** ZIP，SHA256 / 430 entries / CRC / native marker 再驗 PASS。沒有私人美術 raster PNG 上傳至公開 GitHub。
- R16 原始 387 entries ZIP 保留；本輪真付費搶救 419 entries ZIP 與 R17 M1 428 entries ZIP 都保留回溯。
- PC Bridge 每次實際 Windows TEMP 僅建立以 numeric Actions run ID 的隔離目錄，live failed / native passed 均執行 finally 精確清理；沒有刪除其他專案或 E: 正式遊戲檔，**Desktop Remote 0，Codex 0**。

## True status & next full unit
| Gate | 本輪 |
|---|---|
| 原始資產權限、SOURCE SHA 與 3×8 真 PixelLab Provider | PASS |
| 3 階 Guard 影格格式/裁切/身份來源、CRC | PASS |
| 官方 Windows Godot 4.7.2 原生 import/gallery | PASS |
| 私人 Drive owner-only full ZIP write/readback | PASS |
| 視覺美術與使用者 1× 動態終驗 | **AWAIT_USER_ART** |
| Battle/ATB/ACT/Gameplay integration | **NOT_RUN_ART_ONLY** |

**Next complete T-B art unit:** 霜晶狼剩餘 **每階 6 個 ×3 =18 個**真 PixelLab 動作（Skill、Locomotion/Run、Stun、Taunt、Charge、Cast Release）。建議先完成三階 **Locomotion 12F 真步態** 以驗證腳足換位，不要重做已過的 Guard、KO、Revive。僅用經審核已授權的 API/Orca/嚴格固定 Bridge；每批少量付費加成本帳本、來源 SHA、Godot 原生、視覺 ART Gate，重複成功後再擴量。
