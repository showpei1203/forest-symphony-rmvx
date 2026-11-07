# Forest Symphony｜A36H R2 真正 Ground／PAR 美術修正交接｜2026-11-07

## 本輪實際交付和立場
這是一個**新製作、完整可編譯的 1280×928 美術候選**，不是概念生圖。先修先前使用者明確指出「與原版 Ground3 風格越差越多」的可量測部分：兩棟屋頂的木紋、林冠色彩、草地與道路色彩。本輪尚未重新構造屋頂剪影與所有森林群組的自然形狀。**ENGINE PASS、ART CANDIDATE、USER ART APPROVAL PENDING、Formal Seal NO**。
原始 A36G R5、R7 及原版 Ground3/Par3 都保留不變，不對使用者的正式遊戲工程直接寫入。

## 原版美術權威
- `E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png` RGB 1280×928，SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`。
- 同來源 `FS project\Overlays\par3.png` 原生人物遮擋規則。
- 舊版唯讀來源 `E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104`，原始 192 件獨立 `SOURCE_INDEPENDENT_RGBA` + `A36G_R5_SCENE_MANIFEST.json`。
- 本輪從原版 Ground3 的**真正木板屋頂像素**取材，而非生成概念、未使用 PixelLab token。

## 真正美術修改
### 房屋來源
- V1 `a36h_v1_roof_texture_from_original.py`：兩棟屋頂材質初版，仍有大片茅草葉形與漏選綠色區，**ART FAIL，僅供失敗對照**。
- V2 `a36h_v2_roof_exact_reference.py`：對真正原始獨立來源房屋 RGBA 的屋頂色域與來源選區補畫，木色／木板紋理以原版 Ground3 屋頂像素參考；一棟左屋含連接工坊整體來源、一棟右屋完整來源，未貼另座建築，也未修改 1280 場景中的來源放置。精確保留各 source RGBA Alpha、木門、窗、牆與來源尺寸。修改部分：
  - 左屋 `A36G_ELF_HOUSE_AND_WORKSHOP_WOOD_ROOF_V2_RGBA.png`；
  - 右屋 `A36G_R5_COTTAGE_B_SINGLE_ROOF_WOOD_ROOF_V2_RGBA.png`。
- 1× 原始獨立來源 before/after：`A36G_ELF_HOUSE_AND_WORKSHOP_SOURCE_V2_BEFORE_AFTER_1X.png`、`A36G_R5_COTTAGE_B_SINGLE_ROOF_SOURCE_V2_BEFORE_AFTER_1X.png`。
- 仍需指出：**兩棟頂邊有原 R5 茅草造型殘留、房屋的整體建築造型並未真正改為 Ground3 原版木造房屋**；此版本只能評估視覺進步，不能宣稱原版樣式 100% 還原。

### 林群／樹冠
- `a36h_r1_compile_actual_ground_par.py` 從 R5 來源每一件 SHAs 驗證後獨立重編 192 件，44 個 forest_group 深度切片與 59 棵樹做來源 RGBA 色彩轉移（保留 Alpha / 來源幾何），使用連續世界座標場確保相鄰 depth-slice 不因獨立 random seed 產生色彩矩形切邊；色彩參照原 Ground3 藍綠林冠。
- 更改兩棟房屋+59棵樹+44個森林切片，**105 個實際來源**；樹及林群來源花色調整約 1,221,004 個來源像素，原始 R5 192 件全部唯讀。
- `a36h_tree_palette_test.py` 直接 palette quantization 曾太過藍白，**沒有納入正式 R1/R2 工程**；正式版本使用更克制的同世界座標 hue/brightness grading。

### Ground：R2 直接對齊原版 Grass/Path 像素中位色
`a36h_r2_canonical_ground_palette.py` 以真正原版 `ground3` 與 R5 的 grass/path 全圖 HSV/RGB 分類值比較，將**新版 Ground 源像素**以 1× 調色，不模糊任何像素／移動道路：
- 草：R5 中位 RGB [120,161,10] → 原版 Ground3 [104,146,21]；套用 RGB shift [-16,-15,+11]，另微幅自然空間色差。
- 路：R5 中位 RGB [214,185,100] → 原版 [198,161,81]；shift [-16,-24,-19]。
- 直接 Ground 實際修正：**1,076,318 個草地像素 + 62,796 個道路像素**。原始色彩分類區各自的 RGB 中位值達原版 Ground3 參照值。
- 路形、圖塊幾何和既有草花位置沒有重新設計，**不要宣稱道路形狀自然度通過**。

## Ground／PAR 來源與輸出真實對應
根：
`E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107`
- `A36H_R1_TRUE_GROUND_PAR_RECOMPILE\SOURCE_INDEPENDENT_RGBA`：新的獨立完整 192 source set，全部保留原始格式與尺寸；Source Manifest SHA 更新。
- `A36H_R2_GROUND3_PALETTE_MATCH\A36H_R2_AUTHORING_GROUND_ONLY.png` 真正地表。
- `A36H_R2_GROUND3_PALETTE_MATCH\A36H_R2_AUTHORING_COMPLETE_PAR.png` 192件完整前景。
- `A36H_R2_GROUND3_PALETTE_MATCH\A36H_R2_RUNTIME_FULL_SCENE_GROUND.png` 完整合成地圖，供 VX 用。
- `A36H_R2_GROUND3_PALETTE_MATCH\A36H_R2_RUNTIME_SOURCE_OWNED_5_PAR.png` 從同源 final full ground RGB 重新對位的**局部** VX 203 遮擋層（只有 R7 既有 5 件來源語意，**不是全場景完整 VX 遮擋**）。
- `A36H_R2_GROUND3_PALETTE_MATCH\A36H_R2_SCENE_MANIFEST.json` 包含 192 件新來源 SHA、原碰撞 919/241 未變及美術狀態。
- `A36H_R2_GROUND3_PALETTE_MATCH\A36H_R2_PALETTE_AND_LAYER_QA.json` 真正色票統計 + 來源一致性 QA。
- 重要：R1 重跑源自 R5 的完整 PAR **每個像素差異 0**；因此其後的 A36H PAR 編譯不是重新推測的拼接演算。
- R2 Runtime PAR 的不透明 RGB **100%** 等於相同座標 Runtime Full Ground，Alpha 與 R7 的 5 件語意選區一致。這一點**不等於**美術遮擋完成。

## 原生 VX 驗證
- 存取 R2 局部 Runtime FULL + PAR、V12 原生 A36G R5 `Map050.rvdata`（非 A36F collision），隔離在 `A36H_R2_NATIVE_VISUAL_203_QA_20261107`。
- 真正 RPG Maker VX `Game.exe`，固定角色／鏡頭，HK UOM `$game_switches[203]` OFF / ON。
- 左屋／右屋／tree_093／tree_010／tree_020 各 **627 個人物像素** 正確改變；空地對照 **0**。**6／6 PASS**；原始源檔的 SHAs 沒更動。
- 真實 544×416 接觸圖：`A36H_R2_NATIVE_5OBJECTS_6CASES_OFF_ON_CONTACT.png`，QA：`A36H_R2_NATIVE_203_REAL_R5_COLLISION_QA.json`。
- R7 上一輪 5/5 dynamic 移動 Gate 是 **R7 候選**的先前成績；本輪 **A36H R2 未再做動態移動測試**。不要移植 R7 成績到 R2。
- 192 件 full PAR 作者分層 QA PASS（編譯），但 R2 VX Runtime 遮擋仍僅 5 件；不算全場景 PAR 遮擋完成。Godot 本輪未重跑。

## 視覺前後對照（全部是真實 Ground／PAR 編譯圖，非生圖）
`A36H_R2_GROUND3_PALETTE_MATCH\A36H_R2_FULL_SCENE_R5_BEFORE_AFTER_640.png`：R5 vs A36H R2 實際全圖。
`A36H_R1_TRUE_GROUND_PAR_RECOMPILE\A36H_R1_LEFT_HOUSE_BEFORE_AFTER_1X.png`：真左屋/周圍林群 1x。
`A36H_R1_TRUE_GROUND_PAR_RECOMPILE\A36H_R1_RIGHT_HOUSE_BEFORE_AFTER_1X.png`：真右屋 1x。
`A36H_R2_GROUND3_PALETTE_MATCH\GROUND_CENTER_R1_VS_R2_1X.png`：真正草地+道路同座標。
`A36H_R2_NATIVE_VISUAL_203_QA_20261107\A36H_R2_NATIVE_5OBJECTS_6CASES_OFF_ON_CONTACT.png`：真正 VX 遊戲畫面。

## 下階段，不許又只做測試
1. **建築幾何**：目前木色解決了「兩棟屋頂的色彩與材質不一致」，但是兩棟 R5 的原茅草檐口輪廓尚未改成原版 Ground3 木建築實際屋頂線。下一階段先處理邊框、木板/屋脊與窗門/側工坊設計，使用原版 Townset/ground3 真素材有來源證據，不依賴反覆 R5 生成參照。
2. **森林美術**：除調色外，44 個 forest_group 的空間形狀、邊界與重複樣式仍需從完整大型林群 source 重新整合；不能把 depth slice 當 44 棵樹，也不能自行拿落在別物件後的低 visibility source 當前景。須保留來源 Alpha、完整 PAR、R7 source-ownership 對照。
3. **道路自然度**：本輪是色彩比照；下一階段做道路邊界自然化與植被群落，不可宣稱已重造地形。
4. 新美術 candidate 自動重編 Authoring Ground/Complete PAR，再重編 Runtime FullGround/OcclusionPar 和 native VX 203；每次 1x before/after 對照原版 Ground3。直到使用者認可**美術**，不得 Formal Seal。

## Gate
- 192件來源舊版 R5 精確重新編譯：PASS（0 different pixels）
- 105件真正來源修改；Alpha 守恆、來源 SHA 記錄：PASS
- 草地／道路原版中位色匹配：PASS（量測，不是美感判斷）
- 新的 Authoring GROUND_ONLY／COMPLETE_PAR：PASS（同來源編譯）
- Runtime FULL GROUND／5-source PAR RGB：PASS
- A36H R2 RGSS2 203 靜態 ON/OFF 6/6：PASS
- R2 dynamic actor/exit：NOT TESTED
- Forest shape/house original geometry art approval：PENDING / NOT PASS
- A36H user aesthetic signoff：PENDING
- Formal Seal：NO