# Forest Symphony｜A36H R3 美術調整與實機檢查 Handoff｜2026-11-07

## 本輪結果（請勿把工程合格混同美術合格）
A36H R3 C1 是從 R2 真正的單源 Ground＋完整 PAR 編譯，新增**屋簷木條／屋脊收邊**、**7 組完整森林 authoring 工作稿**、**森林細孔整理**與**5 棵既有真實獨立來源樹**；建立 **197 來源物件**的正式候選、Authoring GroundOnly/CompletePAR、Runtime FullGround/局部 10-source Par203、A36G 自己的原生 Map050 檔案供測試。

原版 FS 與 R5/R7/R2 Source 全部唯讀。沒有新的 AI 概念圖、未使用 PixelLab 額度，也未動正式遊戲來源。**A36H R3 Art 人工驗收：PENDING。Formal Seal：NO。**

### 1. 來源與權威
- FS 原版美術權威 `E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png` + `Overlays\par3.png`。房屋木色/林冠基色沿用 A36H R2 已從 Ground3 正式校正後的材料。
- R2 候選來源 `E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107\A36H_R1_TRUE_GROUND_PAR_RECOMPILE\SOURCE_INDEPENDENT_RGBA`（192 真來源）及同根 R2 地表。
- GitHub 上傳的是檢查／編譯程式與 QA，不是尚未清除授權的 Hanzo/既有遊戲圖集；真正源圖保存私人 Google Drive 備份。Google Drive FS_SOURCE_ASSET_LOCATION_REGISTRY V1 註明 Hanzo 與部分來源素材授權未確認，不可以擅自公版化。
- 舊版 R2 源圖重新合成 CompletePAR 與當版原始 CompletePAR **逐像素一致**（0 pixel diff），再進行新的 R3 artwork。

### 2. 屋頂幾何與失敗案例
- `a36h_r3_fascia_test.py` C1：在主要屋頂中間多畫了一道看似「漂浮」的木條，**ART FAIL**。
- `a36h_r3_c3_trim_old_thatch_fringe.py` C3：以刪 Alpha 消除兩屋垂草邊，各移除 970／957 個 Alpha 像素，結果露出原本沒有繪製的牆面，形成灰色破洞，**ART FAIL，禁止使用**。
- 選用 `a36h_r3_c2_roof_edge_only.py`：從 R2 已批准引用 Ground3 原版木板紋理的 V2 來源，添加**位於實際屋簷／斜坡邊界**的木條與屋脊；沒有新增懸浮內部線、沒有移除 Alpha、不修改完整相連工坊／主屋來源切片。左屋新改約 1,085 像素，右屋約 544 像素。**這只是屋簷局部美化，房屋依舊保留 R5 茅草系架構，尚未真正改造成原 FS Ground3 的木建築。**

### 3. 林群由 44 個切片重建成 7 個完整來源工作稿
- `a36h_r3_restore_whole_forests.py` 以每組相同 x、寬464、原 y 連續的深度切片恢復 7 個 RGBA 整體 Source：
  `north_west`、`north_east`、`west`、`east`、`south_west`、`south_centre`、`south_east`。
- 在**整組林群**而非各 depth slice 上做 tiny void canopy cleanup：9×9 closing，新增的像素限制 <=4.4px 距既有實物植被、且只在原 Native R5 碰撞 blocked cell 或畫布外。總填補 **9,040 來源像素**。不刪源 Alpha，也不侵入可走格。
- 保存 `GROUP_FULL_SOURCE/*_WHOLE_FOREST_BEFORE.png`／`*_AFTER.png`／1x before-after，再把 7 完整 group **無縮放切回原 44 件深度切片**，維持既有 Sprite 層疊順序、來源座標、足點。
- **限制**：目前是整組林群重建+小孔修整，不是 7 組都已大幅重畫外形；原林群部分材質仍顯模糊與重複，User Art Gate 仍 PENDING。

### 4. 五個既有真實樹木來源，增進林緣密度
- `a36h_r3_forest_edge_tree_trial.py` 從 A36H R1 真樹 source `tree_093`、`tree_010`、`tree_020` 以 1×、不模糊/不放大、部分水平鏡像，建立 5 個新獨立 PNG；不是畫 5 張概念圖：
  1. NW root(176,144)、foot blocked true；
  2. NE (976,176) blocked；
  3. E (1168,464) blocked；
  4. SE (944,784) blocked；
  5. SW (144,784) blocked。
- 每棵新樹世界 alpha/pixel 可見比：0.6806、0.8667、0.9894、0.8587、0.6149。不同森林深度導致部分來源被後景樹林覆蓋，這**是實際真實場景關係**，不准將「來源檔存在」當成 100% 前景可見性。
- Runtime 203 的**新樹遮擋**由最終合成 RGB 與原始新樹 source 同座標 RGB 可見歸屬判斷後，抽取**上部樹冠的可見 alpha**；不使用全球 footpoint/32px 格子掃描。原本 5 個 R7 已通過的來源再加 5 樹 = 10 件候選局部 Runtime PAR。**新加五棵的角色實機遮擋尚未個別測試；不能說 10/10 PASS**。
- 新樹均落在 R5 原本 blocked root，不增減 919/241 格碰撞；但邊緣可走區域是否被樹冠自然遮住，仍需下一階段新樹角色動態遮擋測試。
- 實際目視新增樹木比較融入密林，因此整張地圖強化程度中等；如畫面風格仍不符合，需改用真正取得授權的 Ground3 風格樹源整組替代，不能反覆複製 R5 模糊樹。

### 5. 真正的 R3 Ground／PAR 結構
獨立新場景：
`E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107\A36H_R3_C1_FULL_TRUE_SCENE_197_OBJECTS`
- `SOURCE_INDEPENDENT_RGBA`：**197 件**附 SHA256 的源圖。包含 192 件歷史來源各自副本+5 件新增真樹源圖，44 森林 slices 有真正的候選修改，兩棟房屋來自 C2。
- `A36H_R3_AUTHORING_GROUND_ONLY.png`：真正可走地表來源；沿用 R2 真正 Ground3 草地／道路色系，R3 本輪**道路形狀與 Ground 紋理未再次改動**。
- `A36H_R3_AUTHORING_COMPLETE_PAR_197.png`：197 真正來源依 Manifest depth order 編譯。
- `A36H_R3_RUNTIME_FULL_SCENE_GROUND.png`：Ground+PAR 組合後完整場景 RGB，1280×928。
- `A36H_R3_RUNTIME_10SOURCE_PARTIAL_PAR.png`：舊五件+新五棵可見樹冠，局部前景；其 RGB 100% 取自上述完整 Ground 同座標，不代表全場景所有 PAR 完成。
- `A36H_R3_SCENE_MANIFEST.json`：獨立物件 ID、source SHA、位置、原 R5 碰撞，以及階段資訊。
- `A36H_R3_C1_PIXEL_QA.json`：來源、改色、局部遮擋、新樹可見所有權等真實 QA。
- 與 R2 整圖比較 **50,590 個不同像素**。這個數字描述視覺改動大小，不代表 50,590 個像素都比原本更好。

### 6. RPG Maker VX 原生實測
- 真正使用本輪 `A36H_R3_RUNTIME_FULL_SCENE_GROUND.png` + `A36H_R3_RUNTIME_10SOURCE_PARTIAL_PAR.png`，隔離複本採 A36G R5 專用重編 `Data/Map050.rvdata`（不是舊 A36F 的 Map50），run `Game.exe` / RGSS2 / HK UOM switch 203。
- 原 R7 的左屋、右屋、tree_093、tree_010、tree_020 各在可走格人物像素切換 627 px；空地控制 0 px；六組畫面同鏡頭、Source SHA 不變，**R3 原生靜態測試 6／6 PASS**。
- 但**新增五棵樹**獨立的 203/角色動態測試 NOT RUN。197 件全部的 Runtime PAR 自然遮擋 NOT RUN；Godot 未重跑。
- 原 919/241 碰撞規則與 R2 相同，沒有在 R3重新掃全圖；可引用 V12 A36G R5 Native Full Grid 1160/1160 / 3544/3544 的原碰撞資料一致，但不能叫「R3 已全新重測 native collision」。

### 7. 必須繼續，而不是再刷工程測試分數
優先權：房屋屋頂剪影 / 連接工坊整體構造 > 林群完整外輪廓 / 真正 Ground3 藍綠樹冠原始 sprite 替代 > 道路／花草自然生態 > Runtime 全圖 PAR / 新樹動態遮擋。
Source Registry：Drive `FS_SOURCE_ASSET_LOCATION_REGISTRY_V1_20261023` 指向 08_Assets/00_Reference_Original/Trees 與 Buildings，原始素材確實已建檔，但 Hanzo / 部分 asset license 為 UNVERIFIED；只在 private study 中使用，不應直接公開上傳至公共 GitHub。
Formal Seal **NO**。R3 不覆蓋 R2，不把使用者尚未驗收的美術推 main 正式封版。