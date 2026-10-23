# Forest Symphony｜精靈村 Rich Pilot V2 使用說明（繁體中文）
版本：2026-10-23。所有內容均為 **候選測試版**，嚴禁宣稱 FORMAL PASS。

## 一、這次交付了什麼？
場景為 864×640 像素（27×20 格，VX 每格 32×32），玩家遊戲視窗仍是 544×416。完整 Scene Manifest 定義 **48 個前景物件、19 組地面裝飾、5 個互動點**。
角色可在真正 RPG Maker VX 原生 Game.exe 和 Godot 4.7.2 運行的獨立測試地圖上驗證基本移動、碰撞、深度排序與互動辨識。
- `scene_manifest.json`：唯一物件座標、來源 SHA256、尺寸、上下層、碰撞、事件座標。
- `source/clean/`：來源裁切後的測試素材（部分尚未人工批准）；`source/candidate_v1_original/`：上一輪候選檔。
- `build/FS_ELF_RICH_Ground.png`：草地、路面和地面花草。
- `build/FS_ELF_RICH_Par_COMPLETE.png`：除 Ground 以外的全部非地表物件。
- `build/FS_ELF_RICH_Par_BASE.png`、`build/FS_ELF_RICH_Occlusion.png`：可見像素所有權分層，兩者合成後逐像素等於完整 PAR。
- `build/FS_ELF_RICH_Collision.png`：碰撞語義遮罩。
- `build/FS_ELF_RICH_Master.png`、`build/FS_ELF_RICH_TILED.png`：兩個獨立編譯器的對照圖。
- `vx_test/FS_RICH_VX_ISOLATED/`：完整原生 VX 專用測試遊戲；`godot_test/`：完整 Godot 專用測試專案。
- `logs/`：逐項自動驗證、截圖、錯誤與引擎 LOG。

## 二、最簡單的操作方式
若在原本的遠端 Windows 電腦測試，開啟資料夾：
`E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023`
雙擊 **RUN_RICH_V2_ALL.cmd**，即可重跑整套 12 步測試，包含重新組合素材、編譯 Manifest、Tiled 負向測試、Godot 實機及 VX Game.exe 真正視窗截圖。
也可用命令：`python scripts/run_rich_v2_all.py`。
**注意：** 此自動測試依賴該電腦上的 RPG Maker VX 原生 Project1 模板、Godot 4.7.2 與 Tiled，因此把 ZIP 搬到其他電腦不保證無設定即可重跑。

想直接玩原生 VX 測試地圖：執行 `vx_test/FS_RICH_VX_ISOLATED/Game.exe`，使用方向鍵走路。這個副本不代表正式 FS 遊戲；既有 SEALED Scripts.rvdata 一律沒有被改動。
Godot 直接開啟 `godot_test/project.godot`；方向鍵走路、確認鍵接近物件時觸發測試用互動辨識（顯示於輸出記錄，不等於正式 FS 事件文字窗）。
需要最終驗收，請由真人操作完整跑圖、調整遮擋、檢查建築一致性與物件碰撞。

## 三、最新客觀結果
- 資產、地圖、可達性及圖層編譯：**14/14 PASS**。
- Tiled vs Python Master 864×640 RGBA：**0 像素差異**。
- Par BASE + Occlusion 靜態重組完整 PAR：**0 像素差異**，原先有 1,117 異常像素，已補上 Visible Owner Partition。
- 故意將指示牌 X 偏移 1px：**669 個異常像素被抓出**。
- Godot RX 6700 XT 544×416 GPU 實機：**PASS**，48 個獨立 Sprite、五項互動辨識、基本角色移動、房屋碰撞與前後景深度測試。
- VX 原生 Game.exe：48 個物件、17 種來源、83 個阻擋 Tile、五項互動辨識、基本玩家移動及 100 更新影格皆 PASS。
- VX 原生截圖在 Master 世界座標 (160,224) 對齊，角色 Sprite 區域以外背景 RGB：**差異0像素**。原始 LOG 的初始化畫面位移是 (96,224)，不能用它直接充當最終鏡頭位置。

## 四、對已經發生的錯誤要怎麼預防？
**分層失敗根因：** 全部 Base 先畫、全部 Occlusion 後畫，遇到屋子/樹木重疊就改變 Z-order；靜態分層須以完整 PAR 的最後可見像素所有權歸屬拆分。
**移動角色限制：** 真正角色移動必須按照每個物件自己的 Z-order 動態排序，不能用一張靜態合成 Occlusion 解決全部遮擋。Godot/VX 測試使用的是各物件獨立 Sprite。
**素材品質限制：** 商店與民宅目前只是配色不同的相同屋型，市集攤位已縮成單層，但整體素材密度、美術風格以及神聖林地的豐富程度還需要後續改進。03_Approved_Assets 資料夾目前不應視為已正式核准素材。
**正式 Runtime 限制：** 目前的 VX 遊戲使用 **空白 Project1 的隔離副本**，沒有整合正式 Forest Symphony 已封版引擎。正式專案封版保護優先於任何煙霧測試成果；需要取得真正 Binary 並在獨立複本做相容性驗證。

## 五、驗收與交接
機器總結：`logs/RICH_V2_FINAL_REGRESSION.json`。
截圖：`logs/RICH_VX_NATIVE_FRAME.png`、`godot_test/captures/RICH_GODOT_V2_NATIVE.png`。
可恢復任務與下一個 Gate：`NEXT_CHAT_HANDOFF_RICH_PILOT_V2.md`。
正式狀態：**DUAL_ENGINE_NATIVE_SMOKE_PASS / FORMAL_FS_RUNTIME_PENDING / HUMAN_VISUAL_GATE_F_PENDING**。
