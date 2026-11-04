# Forest Symphony | A36G R5 R2 | Ground/PAR 分層失敗稽核與產線修正權威 | 2026-11-04

**重大更正：R5 的渲染與載入煙霧測試 PASS，不等於原版 FS Ground/PAR 分層 PASS。本版本原生 Ground/PAR 驗收 FAIL。使用者判定美術風格偏離原版：ART FAIL。**
**正式封版 NO。保留 A36F / R3B / R4 / R5 現有檔案，停止任何新的 PixelLab 建築／森林生成，直到分層及風格來源的證據重新達標。**

## 1. 舊 FS 已經驗證的 Ground/PAR 真實基準
原始 FS 工程：`E:/遊戲專案開發/三大項目現行專案/FS project/`
- 真正完整原始美術是 `Graphics/Parallaxes/ground3.png`，1280×928 RGB，SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`。
- 對齊的前景遮擋是 `Overlays/par3.png`，1280×928 RGBA，SHA256 `dde64967b623c6da26e1f1afbd0ea5603532bfbd882b283ea7a2df66aa0fcada`。
- `Overlays/ground3.png` 是其他疊圖／效果，不是原始完整 Ground3 美術，SHA256 `a96efa5afdc01363050a542d600bbac5daf6c9d5d7d2816b1be9242ae23f236c`。不得拿它當美術風格參照。
- 原始 par3 有 Alpha >0 像素比例 **13.8563%**，Alpha≥200 的 163,436 點中，有 159,462 點（**97.5685%**）RGB 與完整 ground3 完全相同；錯誤 Overlays/ground3 只吻合 1.5009%。這證實原版採用「完整背景圖＋相同座標、近乎完全同色的局部前景複製遮擋」，不是把完整建築／整片森林從 Ground 拆掉。
- FS 原版 RGSS2 `HK - Ultimate Overlay Mapping` 腳本 index145：`ParMap="Par"`，`ParSwitch=203`，`@par = Sprite.new(@par_viewport)`、`@par.bitmap = Cache.overlay("Par"+map_id)`，`@par.visible=$game_switches[203]`；其獨立前景 viewport z=8。
- 地圖的實際通行由 `ISS::ParaPassa` E-layer Tile ID 768/769 控制，與 PAR Alpha 遮罩不是同一責任；SHADOW/LIGHT 仍分離。

## 2. R5 的失敗事實：以原始 PNG 真正逐像素計算
- `A36G_R5_GROUND_1280x928.png`：只有花草、道路、草地等地表；SHA256 `8c4acbfe3c7201de5f66c51f84af8b568972c5a09d97ebc0a76e3152d764e371`。
- `A36G_R5_PAR50_RGBA_1280x928.png`：合成房屋與大片林群等物件；SHA256 `9079fecdf2d0301817a3e06854a3ab1ffec691de6dac29f28102d9e4833bbe6d`。
- R5 PAR Alpha>0 畫素比例高達 **76.5090%**，與 FS 原始 13.8563% 的工作語意截然不同。
- R5 PAR Alpha≥200 共 853,057 點，只有 **279 點／0.0327%** RGB 與其 R5 Ground 完全相同。這說明 R5 PAR 並非從 Ground 同位置複製的遮擋片，而是另一套圖層。
- R5 Ground 與 Ground+PAR 真實合成有 **907,701 點（76.4161%）** 不同。左屋區域差 62.026%，右屋 39.848%，西森林 81.995%，Ground 本身完全不是完整場景。
- 全部檢查紀錄在 `A36G_R5_GROUND_PAR_LEGACY_FORENSIC.json`，重跑 `r5_audit_true_ground_par_vs_fs.py`；原版工程未動。
- 上游 A27 的「地面專用 Ground＋獨立物件 y-sort」是一種不同的*開發試作法*，不能拿它取代使用者指定的原版「完整 Ground 複製所需部分至 PAR」方式。**從今以使用者指定的原版分層語意做正式驗收**，不再混稱二者相同。

## 3. R5 VX 測試為什麼先前仍顯示 PASS
- R5 新增 Map50 測試腳本位於 `Data/Scripts.rvdata` index483，明確執行 `A36G_MAP::OBJECTS.each`，使用 `Cache.overlay(filename)` 載入 192 個獨立 Sprite，再以 `sprite.z=100+(foot_y-dy)` 排序。
- 原生 R5 `Par50.png` 檔案雖放在 Overlays 資料夾、並可由舊 HK UOM 腳本建立 `@par`，卻受開關 203 控制。
- 已建立完全獨立的 VX 複本 `E:\FS_STAGE16_A36G_R5_PAR_SWITCH_PROBE_20261104`，只在複本腳本加上原生 LOG；啟動真正 `Game.exe`，輸出明確記錄：**`A36G_PAR_SWITCH_203=false`**，並正常 Map050 載入 192 個物件。也就是 R5 原本 22 張角色截圖根本沒有測到啟用的 Par50。
- 原先「ENGINE_SMOKE_PASS」只證明：遊戲可載入、192 個獨立 sprite 可顯示與排序、11 個範例與 22 張截圖、9xx 可走格／碰撞與 Godot 合成誤差。不證明 **真正啟用的原版 Ground+PAR** 已通過。
- **新版 Gate**：`ENGINE_ASSET_RENDER_SMOKE = PASS`；`TRUE_FS_GROUND_PAR_LAYER_GATE = FAIL`；`ART_STYLE_GATE = FAIL（使用者拒絕）`；`FORMAL_SEAL = NO`。

## 4. 已確定的風格退化原因
1. 新建築 R5 右屋以新左屋生成圖的局部材質當風格參照；森林多片又以此前新生成的西林群當風格參照，形成二次／三次生成參照鏈，沒有逐版本對真正 FS `Graphics/Parallaxes/ground3.png` 做審美與像素風格追溯。
2. 只比對「兩棟新建築彼此」沒有驗收「兩棟是否都符合原始 FS 地圖風格」。
3. 將巨大片林群拆成深度切片後，RGBA 聚合面積大幅增加，既不符合原版 PAR 稀疏選擇遮擋，也增加接縫與遮擋不一致。
4. 程式與 Godot 的 RGB 最大誤差 1 只表示在同一套**錯誤的產線輸出**中渲染一致，並不證明其語意正確。

## 5. 下階段修復方法（不得跳過）
- 施工凍結：A36F R1 最後工程基準、A36G R4/R5 失敗候選完整封存；**停止 PixelLab 生圖和美術擴張**，先救回產線。不得再根據 R5 局部 style crop 衍生更多建築。
- 用原始 Ground3／Par3 以及其他 14 組既有 GroundN/parN 做可重複實驗，逐 32×32 tile 抽出 **occlusion semantic mask**。避免用 Alpha 或碰撞框推測所有遮擋；要對照樹冠、門廊、房屋屋頂、前景物、通行與角色腳點。
- 生成端固定 `GROUND_FULL_RGB`：同一座標的完整已核准場景畫面；`PAR_OCCLUSION_RGBA`：只從這份 Ground 裁取那些確實要擋角色的像素（RGB 必須一致；Alpha 為所選 mask）；`COLLISION_E_TILE_32`：獨立根部／屋基通行；`SHADOW`／`LIGHT` 個別素材。
- 再做一張最小 544×416 無新生圖 benchmark：**先從 approved source 畫面抽取**，兩張檔案不同角色站位、無漂移、Alpha與 RGB 比對、在**確實開啟開關 203** 的原生 VX 內截圖；必須包括角色房前可見、房後應遮、林冠下部分遮、空地無遮、房前可通行、根部阻擋與動態鏡頭。
- 只有在 203=TRUE、確認 `@par` 有效參與本輪渲染、改變可控遮擋像素、成功恢復 Ground3 類的視覺美術一致性，才可以把關卡列為 PASS。不得再以「合成圖和 Godot 看起來相同」宣稱原版 Ground/PAR PASS。

資料來源：本輪遠端真實原始 FS 素材、R5 原生 RGSS2 Code、獨立 ParSwitch 動態 Probe，以及先前 Drive `FS_GROUND3_TRUE_REFERENCE_AND_MATERIAL_EDGE_RULES_V1_20261101`、`FS_TERRAIN_PAR_LEGACY_TRIPLET_AUDIT_DEFERRED_V1_20261102`。所有原始／失敗 PNG 不刪除、不覆寫、不重送 PixelLab。
