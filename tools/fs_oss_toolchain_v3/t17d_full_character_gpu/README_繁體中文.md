# Forest Symphony 工具鏈 T17D｜LPC 多圖層角色 + Godot 24-frame GPU 驗證

2026-10-24 交付。**T17D1_T17D2_REAL_GPU_5_OF_5_PASS**。驗證完整角色模組、頭部、髮型、單手劍前後景，以及 Godot 4.7.2 RX6700XT 真正 OpenGL GPU 每格輸出。
正式 Forest Symphony 地圖維持 N5/B0 PAUSED、505 SEALED Scripts 未變，Human Visual Gate F PENDING。Tankentai SBS、正式 RPG Maker VX Attack/Hit Timing 未測，不准誤標 PASS。

## 測試結果
- **T17D1 圖層：**原生 64×64 `male body slash` + `human male head` + `buzzcut hair`；插入 128×128 單手劍 behind/foreground 的局部 (32,32)，無 resize。
- 來源官方 Universal LPC Generator pinned commit `9bf06be193b053db256b2536824af426de046aa2`。由 `inputs/CREDITS.csv` 對照 **每個 logical asset 5 項授權**。所有五項都有 OGA-BY 3.0 供選，保留全部作者：LPC body多人、head bluecarrot16/BenCreating/Redshrike、buzzcut ElizaWy、sword ElizaWy（步行/朝下作者補 JaidynReiman）。本包僅私人開發驗證，非正式授權批准的遊戲出貨資產。
- 24 幀（6×4，四方向）頭、髮、武器均有非透明像素。24格重新合成對整表 RGBA byte-exact PASS；還原原64人物 RGBA byte-exact PASS。已目視檢查 `outputs/T17D1_HUMAN_CONTACT_SHEET.png`，沒有整列錯位；仍需仔細看手部握刀、頭身/配色、角色形體。
- 故意錯誤：head右移1px = 2233像素差；髮型方向交換 = 2138；缺髮型 = 4356；武器 Z 反序 = 655；人物嵌入x+1px = 12454。所有錯誤可被系統抓到。
- 24幀角色 body+head+hair 每幀最底部在64px格局部 y=61~62；正式足點/碰撞/pivot 人工/引擎 gameplay 仍未封版。
- **T17D2 GPU Godot：**隔離專案 `godot/LPC128_24frame` 使用 Godot 4.7.2 OpenGL 3.3 RX6700XT。每格 AtlasTexture 128×128，Sprite2D position(16,16)，NEAREST，非 headless 真 GPU 24次 draw + screen capture。
- 24 PNG均生成且 SHA256 24種不同。畫面本身與 `RGBA source over Godot background` **全 24 張 RGB 逐像素 0 誤差**，且128px繪製範圍外異常像素0。
- 重跑主命令 `RUN_T17D.cmd`，5 stage PASS：T17D1_build、T17D2_prepare、T17D2_import、T17D2_real_gpu、T17D2_audit；Windows已實跑6秒完整成功。
- 正式 FS N5 clone `Data/Scripts.rvdata` SHA256 前後一致 `3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9`，與正式505 SEALED 系統無任何寫入。

## 執行方式
在原 Windows `E:\GameAssetToolLab_20261023\ToolValidation_T17D_20261024`：
- `RUN_T17D.cmd`（依賴 Python + Pillow + Godot 4.7.2 路徑、桌面 GPU 登入狀態、原 N5 clone scripts）。
- `run_t17d1.py` 僅處理可追溯素材圖層；正式 bundle 下 `inputs` 已完整快取，不再上網。
- `prepare_t17d2_godot.py` 建立獨立 Godot scene。
- `audit_t17d2_gpu.py` 嚴格檢查 24 GPU 截圖的 RGB/位置/唯一性。
- `T17D_INCREMENTAL_REGRESSION.json`, `T17D2_GODOT_GPU_RENDER_AUDIT.json`, `T17D1_MODULAR_CHAR_WEAPON_RESULT.json` 與5個 Stage LOG。

## 未驗證與下一步
1. Godot 這輪只驗證 frame-by-frame **rendering**，沒有封版真正連播幀間隔、攻擊判定。
2. 需要正式 Tankentai SBS Godot / RPG Maker VX 被封版的武器動作腳本契約，確認 `_1/_2/_3` 武器/人連號、武器前後排序、hit signal frame。不能從 24張 sprite 推導時間。
3. Heads/hair/weapon 用有署名要求的授權；商用輸出得逐份遵守 attribution/相容規範。
4. 地圖 Human Gate F 尚未通過。不可用這份測試替換正式 Forest Symphony map 或 SBS v0.6 baseline。

## 交付
- `DELIVERY_INTEGRITY.json` 逐檔SHA及完整 ZIP自檢；一鍵 RUN +五階段 LOG。
- 正式權威報告放 GitHub、Drive Handoff、Linear SHO-39。
