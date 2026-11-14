# Forest Symphony A36｜大型蒼翠精靈林 Ground-first + 完整獨立 PAR｜正式施工紀錄

日期：2026-11-14｜Godot 4.7.2 stable｜80×58 格 @32px＝**2560×1856**｜狀態：**技術實作 PASS / 美術 ART HOLD / 玩法碰撞 HOLD / 非封版**。

## 使用者指示及工作範圍

本對話只做 **Ground、完整獨立 PAR、美術、SHADOW、LIGHT、水流動畫候選、大地圖量產**。事件、NPC、劇情、門口觸發和戰鬥由另一對話負責。遵守 `FS_ASSET_FACTORY_ACTIVE_MASTER.md` v1.3：Ground-only 先製作，再放**整棵完整來源**樹木、整棟房屋、完整燈具，**禁止從完成地圖切 PAR**。

## A36 真正交付

1. **單張新生成 Ground-only**：原始生成 PNG **1478×1064 RGB**，SHA256 `020e8c8a7a84f43653ffc43fe660614525d13ee9e956fd7e27b5a18923315a38`；不是把 A34 1280×928 地圖貼四份。含自然溪流、分叉及交織步道、三處建築空地、碎石與花草群落，沒有樹冠或房屋。
2. **真正工程 Ground**：用最近鄰縮放成 **2560×1856**（X 1.73207、Y 1.74436），SHA256 `ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911`。原生畫幅是 1478×1064，**不是原生 2560×1856 或 32px 對位繪圖**，X/Y 縮放相差約 0.7%；需要使用者看 1x 美術再決定是否需原生 32px 重繪或精修。這個轉換保留原圖，不使用模糊插值。
3. **完整獨立 PAR**：310 個可分別移動的完整樹木（4 款較高精細度來源）、2 棟 A34 完整房屋、6 支 A33 完整燈柱、1 口井、7 組岩石；合計 **326 個 YSort 物件**、**9 種現有來源家族**。每個有獨立透明 PNG、來源 SHA、腳點 XY、足底碰撞候選，並非從 A36 全景切圖。舊 A35 場景作獨立回歸基準，不改其圖像。
4. **獨立 SHADOW**：`a36_contact_shadows_2560x1856.png`，SHA256 `f65ffa73fa49fffec4179084d712f03dccc3cfb828ef02b99857d03800a603a3`，作為 Ground 上、PAR 下獨立貼圖，沒有烤進 Ground。
5. **溪流禁行語意候選**：初步色彩分類 148 個候選 32px 溪流水格，搭配足底接觸合計 331 個候選禁行格；候選自由格 4,309，最大候選連通區 4,305，另有 3 小孤立區。**未將這 148 格做成完成碰撞 TileMapLayer，更沒有通過玩家實走及出入口驗收**。不能聲稱溪流已不可走、地圖全通行。
6. **Godot 真正原生場景**：`scenes/a36_large_verdant_forest_80x58.tscn`，使用 SceneTree 的 `Sprite2D` Ground / `Sprite2D` SHADOW / `Node2D YSort` 完整 PAR+碰撞 / `CharacterBody2D` 玩家暫代 F0；含完整 2560×1856 **真正 Godot 4.7.2 OpenGL framebuffer PNG** 和 4 個 1280×928 原生等比 1x 區段、原生樹前後 544×416 比較。人物 F0 是原版 45° 戰鬥靜態影格，不冒充已完成的四方向城鎮行走。

## 真正跑過的 QA

| 檢查 | 來源 | 結果 |
|---|---|---|
| 原始新 Ground SHA、nearest derivation、來源家族、候選通行拓撲 | 獨立 Python/Pillow | **1,633 PASS** |
| 真實原始 PNG、Godot 載入、326 物件腳點、來源 SHA、326 個 CollisionShape2D、YSort、Camera2D | Godot 4.7.2 Mesa llvmpipe | **2,301 PASS** |
| 不含任何私有 PNG 的 Godot 編輯器匯入、場景與 326 物件內容測試 | Godot 4.7.2 clean public copy | **2,306 PASS**，沒有 parser/error log |
| 從 A35 獨立重新生成 A36 Ground、SHADOW、Scene、Manifest 和溪流候選資料 | 隔離 cold build | **8／8 關鍵檔 SHA256 一致**，冷原生 Godot 2,301 PASS |
| 真實原生 framebuffer | Godot 4.7.2 | **2560×1856 全圖及兩張 544×416 樹前後畫面已輸出** |
| 樹前後角色變動 | 原生 RGB pixel diff | **507 pixels**，樹後角色確實被完整物件遮擋，樹前角色可見；是否符合美術仍 HOLD |

## Failure Log／未通過的藝術關卡

- **A36-F01 來源畫素尺度**：圖片生成原尺寸 1478×1064，最近鄰近似放大到 2560×1856；這是技術上符合格數的候選，不代表原生 A32 pixel-perfect。待比對 1x Ground3 參考，必要時針對道路、植被像素做真實原生修正。
- **A36-F02 樹種重複**：目前採四款完整樹來源替換 310 棵，林帶連續但有樹型重複感；需要 8～12 款真正不同的完整樹冠／樹幹造型，並以林群生態布局（非均勻撒點）取得自然度。不能只改色來假裝新增物種。
- **A36-F03 房屋與地圖比例**：兩棟 A34 屋尺寸只有 288×282、252×252，與四倍面積世界空地仍有比例差異；新建築種類、門前動線與建物位置待 1x 美術確認。事件交給另一個對話。
- **A36-F04 水域語意與動態**：溪流已在 Ground 畫出但靜態，正式 `ANIMATED_WATER` 與 148 格禁行 TileMapLayer 均尚未完成；不能宣稱有水動畫、完整碰撞或全部可走。
- **A36-F05 冷建置測試遺失**：初版生成器清理目錄時把當輪新增的 `tests/*a36*.gd` 一併清掉；改成在最終編譯後寫測試，並於冷建置重新複製 A36 測試，全部重跑 PASS。下輪應將 scaffold 生成納入可重建產線，以免覆蓋未封版測試。
- **A36-F06 Godot 數字比較**：GDScript 與 JSON 的 `Array[float]` 比較使最初世界尺寸檢查誤報 FAIL；改成兩座標分別 `int()` 後原生測試 2,301 PASS。
- **不代表美術封版**：雖然新大圖真實可用，仍是 **ART HOLD**，尤其樹種重複感與源圖最近鄰放大的像素尺度。沒有事件/NPC/ATB/門事件/Windows export，也不聲稱六地形另外 11 張已建立。

## 下一階段 A36B（此對話）

1. 依 1x 原生截圖改善**完整獨立樹種多樣性**與疏密林群；避免均勻排列、重複複製與「樹幹像電線桿」的視覺問題，Ground SHA 不改。
2. 純美術方式修正大地圖地面重複感／像素精度，分離可控的 `ANIMATED_WATER` 候選（不偽裝為已完成水流動畫），並校驗溪流岸線及道路步道接點。
3. 明確交接場景 `FS_A36_LARGE_FOREST`、80×58/32px、足點 ID、獨立資產檔／SHA，保留碰撞候選狀態，讓事件對話接手人物／NPC／劇情；本對話不寫事件。
4. A37 六地形迷宮＋村莊的 12 張地圖仍在**規格階段**；先證明森林大地圖的 1x 美術品質能通過，再逐系製作 Ground-only／完整 PAR，禁止十二張漂亮概念圖冒充可用的地圖工程。

## 雲端保管

- 公開 GitHub **Draft PR #16**：只放 Script / Scene / Manifest / Source-Only tests / CI / Handoff，不包含私人原始 Ground 或任何 PNG。
- 原始生成 PNG、可完整打開的 A36 Godot 專案、原生 2560×1856 framebuffer、全部 Full RGBA PAR 源及冷建置報告，僅在 owner-only Google Drive；通過上傳→下載 SHA/CRC 才標為雲端已驗證。
- 舊 A35/A34、GitHub main、VX 原封版保持只讀；使用者 PC 無新增檔案。

## A36 雲端完工回讀（2026-11-14）

- [Owner-only full A36 Godot project ZIP](https://drive.google.com/file/d/1_RuQUGpURoASJmJ6_H0tEtNESz_FjmQU/view) **212 files／55,657,235 bytes／SHA256 `1877cfef806b907243b9bc4714713422d484e3ae651314e09094cc385be6c760`**。上傳→下載完整位元組再校驗：ZIP CRC PASS、211 member SHA PASS、存取 shared=false。
- [真正 Godot 4.7.2 native full framebuffer PNG](https://drive.google.com/file/d/1Hq5WLRNpBj91k90B5PVxhBpLPQo2lv3i/view)，[mobile native preview](https://drive.google.com/file/d/1ZSawHsLoC7u9GGKwFY5XQAz9ZvxhBnxJ/view)，[Godot native actor tree depth A/B](https://drive.google.com/file/d/1KjCPdJZpH_ARs9Hjcqrn3g6mQx-gZc6u/view)。
- 正式核心限制依舊：原始生成 1478×1064 nearest 轉換，**不是 2560×1856 原生畫素**；326 個來自 9 家族可能重複；水/動畫/碰撞及整體 1x 美術尚未封版。請勿把 ZIP CRC/Godot 全綠冒充使用者美術通過。
