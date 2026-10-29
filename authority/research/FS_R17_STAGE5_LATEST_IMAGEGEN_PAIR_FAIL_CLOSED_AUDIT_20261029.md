# Forest Symphony R17｜Stage5 新生成 GROUND + PAR 真正 Gate 稽核（2026-10-29）

**結果：FAIL-CLOSED / ART NOT ACCEPTED / FORMAL SEAL = NO。** 本次已直接測試 2026-10-29 當前對話新生的兩張圖片，並非重新拿 Stage4 V1 圖片冒稱最新作品。

## 1. 兩份最新原始生成圖片的實際資料

| 項目 | 新 Ground | 新 PAR |
|---|---|---|
| 原名 | 像素風草原岔路地景.png | 精緻像素風精靈村落角落.png |
| 實際原生大小 | **1434 × 1097** | **1448 × 1086** |
| 圖片模式 | RGB | RGBA |
| SHA256 | `1b03b0907e0c0e45534e5d7b8fcbc1f038a19a76a2fafb57733515dd5fc85ae3` | `f44b7c11c7b5bbf345f4c5b8a7821d297fc8dd6c52166cb160bf6cc83ae7eb2d` |
| 32px 網格尺寸 | FAIL（餘數 26,9） | FAIL（餘數 8,30） |
| 544×416 或 1280×928 | FAIL | FAIL |

**W 相差14px；H 相差11px。** 不能原樣合法疊圖；也不能私自等比壓縮或裁邊以掩蓋錯誤，否則 1× Pixel-crisp、世界座標和腳點比例失真。

## 2. PAR 真 Alpha / 邊緣 Gate（實際統計）
- 總像素 1,572,528；Alpha=0 真透明 597,822；Alpha>0 可見像素 974,706。
- **Alpha 1～254 共974,430px，Alpha=255 僅276px，占可見像素約0.0283%。** 大部分實體圖案為近似255但不完全不透明；無法宣稱已是乾淨原生不透明 Sprite。
- Alpha 1～7 有75,344px，存在低 Alpha halo/dust。
- 上/下/左/右最外框有 29/114/118/69 個 Alpha>0 像素，應退回來源清理或重新生成，不能冒稱 PAR 邊界 Gate 通過。
- 試算較高Alpha連通區，房屋/樹冠本體存在；是否完整分層仍需人眼實物/原圖來源確認。

## 3. 人眼美術審核
- **畫面豐富度：進步。** PAR 有大樹、藍頂與黃頂兩棟房屋、欄杆、指路牌、燈、木桶、長椅、盆花等；這比較接近使用者要求的範例密度。
- **GROUND：** 原生草/路/低矮花草素材看起來豐富，未看見 Stage4 V2 孤立的樹幹。可是沒有一份同世界尺度、接地位置精確定義的 Ground+PAR Blueprint。
- **PAR 污染疑慮：** 樹/房屋底部帶有成片低矮花圃與草地樣式的圖形；部分應由 Ground 承擔。另 PAR 保有可見整個樹根，未在 GROUND 的該樹同位接地32×32格查得來源登記。這不一定代表所有花卉都不准在 PAR，但必須做語義分層驗收。
- **對位：** 因尺寸不同且無同一原始世界座標，無法判定房門步道、樹腳與遮擋位置準確。左上角截取共同大小的 QA 示意只能說明視覺方向，絕不能冒稱 Valid Pair。
- **授權/來源：** 本次屬原圖生成，尚未供應一個真正可驗證的 Scene Blueprint、兩層 source-manifest、Ground tree contact source 與 matching original PAR sprites。

## 4. Windows 原機真正執行與負向測試
- 已將兩張 latest ImageGen 原檔存入連線 Google Drive，Windows 的 Google Drive Desktop G: 同步讀取到相同大小與 SHA。
- 在 **DESKTOP-90VT437** Windows Python 3.11 實際執行新增 `tools/r17_pair_alpha_canvas_gate_v2.py`。
- **新圖退出碼2，`FAIL_CLOSED_TECH`**：same_canvas、native_canvas、32_grid、PAR_clean_borders、PAR_solid_interior 均 FALSE。RGB Ground、RGBA PAR 以及真 Alpha0 本身 PASS。
- **Stage4 V1 歷史技術正向對照：exit 0、`TECH_CANDIDATE_ONLY_ART_HOLD`**，說明驗證器不是全部機械判 FAIL，但此工具也永不簽核 Art。
- 針對 Stage4 V1 的 PAR 人為裁去1px，**負向對照 exit 2**；差一個像素立即擋下。
- 2張診斷圖：實際 PAR checkerboard；左上角截相同範圍的 QA Composite（**不是有效配對，不是交付 Ground**）。

## 5. Gate 結論

| Gate | 狀態 |
|---|---|
| GROUND_LAYER：原生 544×416、地面規則 | **FAIL**，尺寸/網格 |
| PAR_LAYER：原生透明、完整度 | **PARTIAL → FAIL**，真 Alpha 但 border dust / interior opacity 與尺寸 |
| PAIR_ALIGNMENT | **FAIL**，14px/11px 尺寸差與無 scene alignment authority |
| SOURCE_PROVENANCE | **NOT VERIFIED**，缺共同 blueprint / 原始同坐標來源 |
| PAR ART DENSITY | **PROMISING ONLY**，建築、樹、欄杆等內容較接近目標 |
| FORMAL SEAL | **NO** |

## 6. 下一步工作，不回到重複錯誤
- 確立一份**精確 544×416（17×13格）** 的同世界座標 Scene Blueprint（後續可擴1280×928），先標定兩屋、樹、道路、欄杆、燈、角色腳點的比例/位置，並對 Ground/PAR 共享。
- **全新生成**獨立 Ground，地表花草不能被房屋比例擠歪；不可從 Stage4 V2 裁草皮改圖冒充「全新 Ground」。
- **全新生成**同 Blueprint 的原生透明 PAR：保持本次美術細節密度、去除地面污染/全圖低 Alpha 灰邊；樹底的 32×32 在原件作者階段就分給 Ground。
- 從真正的原始來源先驗證同座標 1×、透明 Alpha、Tree Foot、House Foot、Palette/Light，再進合成 QA；有 Fail 不交正式兩圖。
- **不要碰** sealed FS/K4、Map.rvdata、Scripts.rvdata 或使用者自行設定的通行度。

## 7. 實際備份
- [Drive Stage5 原圖與 Windows Gate/QA](https://drive.google.com/drive/folders/1IAX5lVbQdu3sejy_pqpH-nEptEDrmnSM)
- [Ground 原始生成檔](https://drive.google.com/file/d/1VSwWUDctbCMGaeoD1FsJJ8wVNXh92QfG/view)
- [PAR 原始生成檔](https://drive.google.com/file/d/19biwoA-RmAc9uMYrKYNDwyqsLb3T8o6o/view)
- [Stage5 Windows 嚴格驗證器](../../tools/r17_pair_alpha_canvas_gate_v2.py)
- [上一輪 Stage4 候選報告](FS_R17_DIRECT_STAGE4_V1_SOURCE_FIRST_VISUAL_CANDIDATE_20261029.md)

**原始兩圖保留原封不動；任何 Alpha 調整/合成診斷都沒有被冒充為可交付 GROUND.png+PAR.png。**
