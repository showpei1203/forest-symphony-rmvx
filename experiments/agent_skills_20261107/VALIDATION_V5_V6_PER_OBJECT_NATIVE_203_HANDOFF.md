# Forest Symphony | V5 / A36G V6 two-source semantic occlusion | 2026-11-07

## 1. 這次真正完成了什麼
A36G R6 C1/C2 因整片森林方格遮罩失敗，這次改為**單件來源遮擋**，不再用 forest_group depth-slice 足點模擬樹冠。

**兩種獨立原生 VX（RGSS2）測試都實際完成：**
- 原版 FS Ground3／Par3 的 2 組局部原始像素遮擋：一棟屋頂與一區樹冠，外加一個空地負控制。
- A36G R5 保存的 **左屋完整來源 PNG** 與 **tree_003 單棵樹 PNG**，以各自來源 Alpha + 區域語意製作局部 PAR，對 A36G R5 完整圖作精確 RGB 取樣，再於隔離 VX Map50 真實啟用開關 203 與截圖。

兩輪都通過真正的 203 OFF/ON 控制、鏡頭位置一致、源檔 SHA256 保護及空地對照。**這是原生局部遮擋技術測試通過，不是全圖可玩版本，不是美術封版。**

## 2. V5 原版 FS「屋頂/樹冠」遮擋基準
來源：
- `E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png` (full RGB 1280×928)。
- `E:\遊戲專案開發\三大項目現行專案\FS project\Overlays\par3.png` (RGBA 1280×928)。
- ROI 屋頂 world bbox (170,104,358,295)；樹冠 ROI (390,0,575,200)。這些 ROI 是**人工限定的局部來源遮擋見證**，不是完整原生建築／完整單樹 source art extraction。
- 輸出原始 Par3 精確 alpha/RGB 片，以及同 Alpha 但 opaque RGB 採用 Ground3 對位像素的 normalized runtime 片，用於排除 Par3 少量本身像素色差造成的背景假差異。
- 原始素材不動。用標準 FS native test clone 的 Game.exe，獨立複本把 `Overlays/ground50.png` 替換為同源完整 Ground3，把 `Overlays/Par50.png` 替換為兩個 ROI 的局部前景。不是 `Graphics/Parallaxes/ground50.png`，因 VX 測試 Map50 `parallax_name` 為空，`HK - Ultimate Overlay Mapping` 使用 Overlays/ground50。
- 開關 203 真正 false→true，`@par.visible` false→true，原生 544×416 截圖；280 frame warmup，固定角色／鏡頭。
- **House/roof (8,4)：627 changed px，25×32 差異框 PASS**。
- **Tree/crown (14,1)：625 changed px，25×32 差異框 PASS**。
- **Clear (11,10)：0 changed px，PASS**。
- 真實圖：`FS_ORIGINAL_ROOF_TREE_NATIVE_203_V5_20261107/V5_CANONICAL_3_TESTS_OFF_ON_CONTACT.png`；QA JSON：`V5_ORIGINAL_ROOF_TREE_NATIVE_203_QA.json`。
- 工程判定：**3／3 sampled actor occlusion PASS**。

## 3. A36G V6：從真正一棟屋與一棵樹的來源建獨立 PAR
依 `A36G_R5_SCENE_MANIFEST.json`：
- 來源屋 `A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png` 284×259，世界左上 (353,209)，SHA `964fe9bf9fe4048bc4b96fab573285cc9a2042faeefe38f1fde9501a23ccb699`。
- 來源樹 `A36F_tree_003_ORIGINAL_RGBA.png` 74×81，世界左上 (676,24)，SHA `85ae0a70f8b10c7eb22cd95fba69cba0be7c3de3aa95a3a7e96b3dc241b24b36`。
- C1：初次人工幾何 roof polygon 對屋頂覆蓋不足，仍留多塊綠色未遮擋，**C1 semantic candidate FAIL/需修正**。
- C2：依 2× 原始屋頂格線視圖補上大屋面和側工坊，並用 roof HSV 色域排除木牆/門窗，保留 source Alpha。Tree crown 由 HSV 綠色植被 + source Alpha 連續語意 mask；不使用 32px sampling lattice 或 forest_group 抽象足點。**C2 幾何仍 DRAFT，非人工美術批准**。
- A36G V6 C2 分離輸出：
  `AUTHORING_GROUND_ONLY.png`、`AUTHORING_COMPLETE_PAR.png`（R5 原始來源副本）；
  `RUNTIME_FULL_SCENE_GROUND50.png`（R5 full-scene master 同 SHA）；
  `RUNTIME_PAR50_ROOF_TREE_ONLY.png`（僅該左屋屋頂與 tree_003 前景，exact same-scene RGB）。
- C2 物件 Alpha mask：左屋 16,185 像素，占左屋 source alpha 43.472%；樹冠 2,326，佔單樹 source alpha 93.077%。世界 runtime PAR 遮擋覆蓋 **1.5584%**。注意這**不是**「全圖只需遮擋 1.56%」的意思，它僅包含 2 個限定物件。
- VX 3 獨立 case clone 都開啟 native `Game.exe`：
  - `A36G_ELF_HOUSE_AND_WORKSHOP` 角色 tile (15,10)：**627 pixels, bbox 25×32, PASS**；
  - `tree_003` tile (22,1)：**434 pixels, 23×29 bbox, PASS**；樹冠僅部分遮擋人物，頭頂可見，**是否自然留待美術驗收**；
  - `CLEAR_NEGATIVE_CONTROL` tile (20,14)：**0 pixels, PASS**。
- Source SHA256 在所有 cloned VX 測試前後不變；Meta: `A36G_V6_C2_2OBJECT_NATIVE_203_20261107/V6_OBJECT_ROOF_TREE_NATIVE_203_QA.json`（依實際磁碟檔名為準，應檢查該資料夾的 JSON）；contact `V6_A36G_TWO_OBJECT_3_TESTS_OFF_ON_CONTACT.png`。
- **工程結論：V6 C2 兩種來源的 native partial-Par actor switch test 3／3 PASS；並無通過 A36G R5 241 格碰撞一致、完整場景 192 件前景遮擋或獨立 Godot 渲染。**
- 測試 Map50 的碰撞仍 A36F（非 R5），角色都是測試專用 teleport；**不得宣稱 R5 整圖碰撞已通過**。

## 4. 重要失敗與預防
- R6 C1 / C2 global footpoint field（上輪 V4）已明確 FAIL：32px lattice 81.682% 與過寬 mask 52.761%。這一輪根本沒有再調整 global mask。
- A36G V6 C1 手工屋頂初始輪廓漏掉部分綠色屋面。已保留 C1 和 2× 素材格線檢視，C2 才進行 VX。即使 C2 Native PASS，也不表示多房屋/複雜樹林的所有局部遮擋都正確。
- 原版 Par3 有不透明區域 2-4% 的 RGB 與 Ground 略不同。若直接用原 Par3 OFF/ON 背景像素當判斷會受污染；故建立**保留原始 Alpha、對齊 Ground RGB 的 native test copy**，同時原始 ROI RGB/Alpha 精確版本完整保留。
- 用 **ISS - ParaPassa** 正確 API；本輪不做移動判定。避免把圖片煙霧測試當真正前景 switch203 Gate。
- 不生成新美術、不調用 PixelLab、不覆寫 R5 來源或舊封版版本。

## 5. 下一關施工權威
1. 先以 V5 approved Ground3/Par3 真實 ROI 的屋頂/樹冠 Alpha witness 作基準，逐件對新候選屋頂／樹冠明確畫 semantic crown/overhang mask。**只有編譯器組裝後，才可宣稱 PAR 可用**。
2. 按已驗證的 V6 C2 方法逐次擴張到右屋、幾棵高風險樹，而不是直接上 44 組 forest group；每件獨立 mask、來源 SHA 和 native OFF/ON 正/負控制。
3. 解決 R5 美術風格：**必須回到 FS Ground3 1× 已確認色盤/木造／雙色樹冠**，新素材要先過風格簽核；現有茅草屋 R5 使用者原判 **ART FAIL**，不因遮擋可用而變 PASS。
4. 全圖高密度森林生成要等可獨立重用的單株樹冠/遮擋語意通過後才製作。PixelLab 額度先保持，禁止從 R5 生成圖自我參照。
5. 原始 A36F R2 的 V11 1160/1160 collision 和 3576/3576 edges PASS 是上一輪不同候選；本輪 A36G 使用的 Map50 collision 未對齊，不能混用。

## 6. Gate Verdict
- Original Ground3/Par3 ROI alpha source / exact registered RGB: PASS（Reference）
- Original FS native 203 House / Tree / Clear: PASS / PASS / PASS
- A36G V6 C2 two-object native 203 House / Tree / Clear: PASS / PASS / PASS
- A36G V6 C1 roof mask coverage: FAIL
- A36G V6 C2 per-object semantic art signoff: **UNVERIFIED**
- A36G full-map authoring completeness and native collision: **NOT TESTED**
- A36G original style vs FS Ground3: **ART FAIL (R5 inherited)**
- New game art generated: NO
- Formal Seal: **NO**

## R7 Critical Source Visibility Erratum (2026-11-07)
前一版提到 `tree_003`「單件來源樹冠原生測試 PASS」，現有新的驗證必須區分：203 開關切換＋實機截圖這一段 **ENGINE PASS 不變**，但 `tree_003` 原始 PNG 在 R5 最終場景同位置的可見不透明 RGB 只有 **5.12%** 一致，該來源絕大部分實際被其他物件覆蓋，因此 **「true tree_003 source-owned semantic PAR」FAIL**。這種情況若只檢查 source SHA 與角色消失會產生假陽性；同理 tree_056 只有 1.92% 可見。

R7 已新增 source ownership pixel gate，改採 `tree_093`、`tree_010`、`tree_020` 的真正可見來源，並重新用 A36G R5 本身的 native Map050 測試。R7 Native 6/6、動態 5/5；仍只有 5/192 物件，不是美術或全圖遮擋驗收。權威： [R7 Handoff](../agent_skills_20261107/VALIDATION_R7_REAL_MAP050_5SOURCE_HANDOFF.md) 與 [Drive R7 package](https://drive.google.com/drive/folders/1ZDnzVEtFh2SbcJ4vyZqOkFrGjPJ9AOBl)。保留 V6 原本證據和此更正，禁止改寫歷史紀錄。
