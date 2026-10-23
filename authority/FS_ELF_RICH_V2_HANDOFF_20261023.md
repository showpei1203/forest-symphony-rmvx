# Forest Symphony｜精靈村 Rich Pilot V2｜2026-10-23 可恢復 Handoff

## 正式狀態
**雙引擎原生隔離測試 PASS / 原版封存 FS Runtime 相容性未驗證 / 美術與人眼 Gate F 待驗收 / NOT FORMAL PASS**。
不可回滾 Forest Symphony 已封版 Scripts、Map、Enemies 或其他既有專案。所有修改僅限遠端電腦 `E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023`。

## 新成果（相較 v1）
- 864×640 地圖、48 個 PAR 物件、19 組 Ground 花草、5 個互動點。
- house_shop 已由相同 house_A 來源改為銅褐屋瓦版本，來源 SHA 不同；商店造型仍屬同一屋型候選，待美術批准。
- market_full 原128×255雙層攤位截成128×155單層；不縮放、不重繪整張 Ground，保留原素材出處。
- 刪除部分不自然重疊配置，追加不同種類的邊界樹、枯樹、小灌木、路邊石塊，增加 scene composition 密度。
- 所有物件 geometry / anchor / source hash / collision / ground semantics 都在同一 `scene_manifest.json`；原 V1 見 `work/baseline_rich_v1`，不得不經紀錄覆蓋。

## 重大根因與修復
舊版把所有物件 Base 畫完，再畫 Occlusion，遇物件互相遮擋會破壞原先完整 PAR 的 Z-order。實測有 **1117 個 RGBA 差異像素**。
V2 `scripts/partition_visible_owner.py` 按 Manifest draw_order 追蹤最後可見物件屬於 Base/Upper，並從已完成的完整 PAR 做像素分配，達到 Par_BASE + Occlusion == Par_COMPLETE **0 差異**。
注意：此解法只保證靜態重組，可動角色必須透過各物件獨立 Sprite 深度排序實作，不能把靜態 Occlusion 當成唯一的動態角色遮擋機制。

## 核驗結果
1. 同一 Manifest Ground / Par_COMPLETE / Par_BASE / Occlusion / Collision 編譯 864×640；Tiled vs Python Master RGBA 完全相同。
2. 靜態分層重組 0px 差異；`scripts/validate_rich_v2.py` 14/14 GATE PASS；五個互動點可達。
3. `scripts/negative_tiled_1px.py` 故意偏移指示牌 1px，Tiled 選出 669 個差異像素；Negative Gate PASS。
4. Godot 4.7.2 在 Radeon RX6700XT 真正 OpenGL 渲染 544×416；48 個獨立來源物件、五互動辨識、角色基本移動、房屋碰撞、世界座標深度前後排序，全項 Smoke PASS；截圖 `godot_test/captures/RICH_GODOT_V2_NATIVE.png`。
5. RPG Maker VX 原生 Game.exe / RGSS2 從獨立 Project1 模板建立測試副本，只在該副本注入 RGSS2 Layer Script；48 props / 17 種素材 / 83 blocked tiles / 5事件辨識 / 攝影機 / 100幀，原生 LOG 全 PASS。
6. VX 原生截圖 `logs/RICH_VX_NATIVE_FRAME.png`，Python 對位 Master (160,224)，全部差異只有角色本體 627 pixels，實際角色 bbox (261,316,287,348)，其餘背景 **0 差異像素**。`logs/RICH_VX_NATIVE_PIXEL_AUDIT.json` 留證。啟動時 scroll 命令請求 (96,224)，實際 camera 隨 player refresh 滾至 (160,224)；後續 QA 需以真正圖像對位，不可採用初始參數猜測。

## 一鍵回歸
執行 `RUN_RICH_V2_ALL.cmd` 或 `python scripts/run_rich_v2_all.py`。
整套12步自動 Gate 重新編譯並執行 Godot + VX、Tiled Negative、真實 Game.exe 截圖一致性：**12/12 PASS**，詳細機器記錄 `logs/RICH_V2_FINAL_REGRESSION.json`。
每一個 Gate 的 stdout/stderr 存 `logs/00_...11_*.log`。

## 未完成與阻塞
- 正式 Forest Symphony 已封版 Scripts.rvdata 二進位來源未成功接入本隔離專案。Drive 已找出分割的原版封存資料 `Forest Symphony/02_Current_Development/FS_PROJECT_SPLIT_TRANSPORT_20260818`，分三件 `FS project.z01`、`FS project.z02`、`FS project.zip`，各約 200MiB/200MiB/95MiB。未提取/雜湊/比對正式 SEALED Runtime，**不可聲稱「正式 Forest Symphony Runtime Adapter PASS」**。
- 獨立 VX 模板是合法測試原生引擎；不等同正式 FS Runtime。不修改正式原專案，後續需拿原 binary 完全複製成獨立工作目錄並做 compatibility baseline。
- 目前互動測試為內部近距離事件辨識，尚缺正式 FS Event Command / 對話視窗的完整功能測試。
- 地圖風格有進步但仍偏稀疏，商店與民宅只是換色、相同屋型，沒有不同建築幾何；Market 與林地需要美術調整。批准素材夾仍未授權這些 Candidate。
- 人工操作行走、連續跨樹冠遮擋、地圖捲動/鏡頭畫面、正式可玩性及美術驗收 Gate F 尚未封版。正式狀態保留 Candidate。

## 接續優先步驟
1. 先讀 `README_繁體中文_V2.md`、`logs/RICH_V2_FINAL_REGRESSION.json`、`scene_manifest.json` 和本 Handoff。
2. 在 Drive 找到真正 FS 500MB 三片完整 binary，核對 SHA256，僅解壓至新的 isolated clone，絕不可覆寫使用者正式專案；先讀正式 Authority 判斷 SEALED Scripts 插件策略。
3. 從正式 FS clone 實作非破壞性 adapter（受封存 scripts 不更改），確認角色遮擋、事件、傳送與既有 SBS 相容。
4. 強化 Approved Asset Kit，增加真正不同房屋、攤位、標記、草地/花圃/水岸/神聖林等合法來源，不使用 AI 全景再切層來冒充。
5. Human Gate F 逐點走圖，含 Sprite 綁定、行走碰撞、鏡頭捲動及五互動，經使用者批准才可將美術由候選提升正式。
6. 每一次交付附完整 ZIP + Test Build + LOG + README + CURRENT_HANDOFF，上傳 Drive / 更新 Linear SHO-39 / GitHub Authority。

## 斷線應變
網頁「訊息傳送逾時」不能證實遠端作業停止，必須檢查遠端 Windows 和 LOG。現在每次完整測試12步皆落盤；只要指定「請接續最新 FS Rich Pilot V2 handoff，從未通過 Gate 繼續」，無需重新交代歷史。
