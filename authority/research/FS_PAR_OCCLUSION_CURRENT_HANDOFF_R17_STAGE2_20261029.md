# SUPERSEDED｜2026-10-29 使用者改定直接生成兩張圖

**最新規則與Handoff**： [直接Ground+PAR Authority](./FS_R17_DIRECT_GROUND_PAR_SOURCE_FIRST_AUTHORITY_20261029.md)； [CURRENT_HANDOFF_R17_DIRECT](./FS_PAR_OCCLUSION_CURRENT_HANDOFF_R17_DIRECT_20261029.md)。以下為Stage2歷史實驗，不可當成下一輪施工指令。

---

# CURRENT_HANDOFF_R17｜Stage 2｜Forest Symphony 2026-10-29

**最新Authority：`R17_STAGE2_RESEARCH_REPORT.md`，並沿用R17 Stage1 `R17_GROUND_PAR_DUAL_GATE_AUTHORITY.md`。本輪真正新生成544×416新精靈村Master（非R12裁片）＋11個Source-locked前景候選，Godot4.7.2真GPU TECH PASS，ART F / PAR語義HOLD，Formal Seal NO。**

## 新Master唯一Source
`R17_STAGE2_NEW_ART_20261029/MASTER_STAGE2_NEW_GENERATED.png` SHA256 `0a4d77cf98a1e4d33f3eb045c486c46da7fe71755751cc86fd7cbdd2857b2863`，來源**生成式展示板Master面板裁切**，大小544×416。它真的有新美術但不是獨立Layer生成；展示板內畫出的PAR/測試數字只是示意，絕對不能當真實測試。
Master屋頂/樹部分切到邊框，三完整樹/完整屋ART硬條件未達。

## 真測試
- SAM2.1 full544 CPU R1 5個：HOUSE 36769px、EAST_TREE14106、WEST_TREE9352、LAMP_CENTRAL1576為PromptPASS，BRIDGE_RAILING3719漏一正點FAIL。
- R2 新增 TREE_MIDDLE6045、LAMP_WEST1882、STALL6312、FENCE_LEFT2497為promptPASS；FENCE_NORTH_EAST2164和FENCE_SOUTH_EAST1296提示FAIL。GrabCut修原橋欄杆至3989px且提示OK。
- 11件source RGB完全同Master，PAR Alpha 85530。Ground-only三個樣本中中央道路有81px與MARKET_STALL重疊，其他兩區0；可能測試ROI或攤位底部要細分，別直接把81剪掉騙成PASS。SAM2種子總9/11，藝術輪廓未人眼驗收，全部ART HOLD。
- 本地新版Godot `R17_STAGE2_NEW_ART_20261029/godot_project/Stage2Village.tscn` 11物件真Sprite2D，Master新完整美術原圖，actor32來源原FS。AMD RX6700XT／Godot4.7.2真OpenGL匯出5個544×416 PNG。原Master vs MASTER輸出0 RGB px，vs FULL輸出0 RGB px；Godot PAR vs本地候選0 RGBA pixel差；Actor完全樹後0px可見差，放樹前271px可見差。
- 文件`R17_STAGE2_NEW_ART_SAM2_GATE.json`、`R17_STAGE2_R2_11OBJECT_GATE.json`、`R17_STAGE2_GODOT_SCENE_MANIFEST.json`、`R17_STAGE2_GODOT_FINAL_GATE.json`、`R17_STAGE2_TRUE_GODOT_4PANEL.png`、`R17_STAGE2_DETAIL_2X_4_PANEL.png`；本輪未跑正式VX Game.exe，不能稱VX PASS。
- 現有R12～R17 Stage1源及K4 source未覆寫。

## 下一步實際施工指令
**R17 Stage3美術邊界修正**：先產生一張無圖表、無字、純藝術新Master，**屋和3棵完整不同型樹都放進544×416畫框**，還有全數欄杆、路燈與細節的pixel-crisp；只有通過完整構圖ART Gate才進雙圖層；否則新模型再怎麼切遮罩都只是在切壞的構圖。
接著針對11件物件先修FENCE_NORTH_EAST/FENCE_SOUTH_EAST和MARKET_STALL與Road81px衝突、補其他漏項；獨立透明原生素材模型若無法產真Alpha而只產棋盤底圖片，記FAIL，禁止冒稱直接雙生成功。所有人眼遮擋Gate F須由使用者認可後才能Seal。正式 K4 Scripts505 和 Map003不動。