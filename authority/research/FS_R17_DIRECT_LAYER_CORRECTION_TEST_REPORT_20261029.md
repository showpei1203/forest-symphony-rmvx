# R17 使用者修正驗證：真正直接 Ground + PAR，不再逆向裁切｜2026-10-29

## 結論
使用者確認最終遊戲工作方法：**助手只生產/驗證 Ground.png 地面原圖及 PAR.png 真透明立體物件圖；使用者自己疊成新的完整 Ground，再上 PAR，使用FS現有通行度腳本自行設Passability。** 因此取消本流程原本要求助手先生成完整Master→SAM2/GrabCut切PAR、腳本自動Collision、原生VX每版測試等全部必要Gate。若另日特別要求Game.exe驗收可再做；不能默默回復。

## 新正式 Authority
`R17_DIRECT_GROUND_PAR_AUTHORITY.md`：新版流程優先於R17 Stage1/Stage2以及更早研究中的相反說法。生產標的只要
```
GROUND.png = 單獨畫出的精緻自然連續地表（無立體物件烘焙）
PAR.png    = 單獨畫出的真正RGBA立體物件（Alpha 0背景，細枝/欄杆/屋完整，無地面）
                        ↓
User merges GROUND+PAR to create new Ground, then overlays PAR in FS, sets collision himself.
```
樹冠／非接地幹全部PAR，唯接地最下32×32樹幹格留GROUND，草/道路/平面台階/橋面/貼地陰影留GROUND。要求同畫布544×416(後續1280×928)，同坐標、同風格、全物件不截斷，事後不再大規模裁PAR。生成物件不乾淨就改生成來源，不繼續使用整格／SAM2補救當正式程序。

## 本輪立即做的歷史回歸檢查
實際執行 `r17_direct_ground_par_pair_gate.py`，將兩個有真實位圖與場景來源的歷史案例代入新規則，讓原本可能「0px差PASS」的誤判變成可測的明確原因：
- **R14真正獨立SOURCE FIRST**：從Godot真源GROUND+CONTACT產`GODOT_BASE.png`，PAR獨立物件來源`GODOT_PAR.png`，都是544×416，真RGBA透明 173,519 px，重組與原`GODOT_FULL`差0px，5個地面負例透明Alpha都是0。來源獨立⇒`DUAL_LAYER_TECH_PASS`。但221個地板格只用了兩種圖塊，畫面低豐富度且有線條／貼圖感⇒`ART_FAIL`，不能交使用者。
- **R17 Stage2較好看新美術卻採先完整 Master後切PAR**：544×416 MASTER有屋/樹/欄杆早已烘焙；SAM2提11候選透明PAR，Alpha透明 140,774 px，重組看似仍跟Master0px差，但原GROUND並非獨立地表⇒`DUAL_LAYER_PROVENANCE_FAIL`；原11遮罩另有81px道路衝突+2欄杆PROMPT FAIL。不可當作合格雙生成。
- 兩個案例重組都0px，驗證**光看0px差距不能驗證使用者所要的獨立Ground/PAR。**
- `R17_USER_CORRECTION_TRUE_LAYER_VS_PREBAKED_6PANEL.png`清楚展示 2 案例，每案 Ground／真正透明PAR（僅圖像檢視中顯示棋盤）／合成預覽（僅做QA、不供使用者當Ground替代）；回歸細節 `R17_DIRECT_PAIR_PROVENANCE_GATE.json`。
- **目前沒有美術合格的原生雙層樣本**，不能假裝有。此回歸是正式修正既有工作標準，不是新Ground+PAR已成功生成。

## 後續唯一步驟
1. 在同一份精靈村Blueprint/Style Lock下**先生成原生完整、無前景烘焙的高精度連續GROUND**。Ground必須有自然道路/花草/地面陰影/樹幹接地底格，不可沿用R14少量tiles。
2. 依同一世界座標**直接生成原生透明立體物件PAR**，包含完整房屋、樹冠、立柱/欄杆、燈等，若素材失敗則局部重新生成，**不重新裁切已生成PAR**。
3. 只做兩圖各自的人眼品質/Alpha純度、完整物件、同風格同位置、疊圖預覽QA，向使用者交兩張PNG；不用替用戶合成正式Ground，不用設定通行度。
4. 人眼未確認兩張圖同時合格則`GROUND_LAYER_HOLD`/`PAR_LAYER_HOLD`/`PAIR_ALIGNMENT_HOLD`／No Seal。
5. 版本與fail例依舊同步GitHub/Drive/Linear + CURRENT_HANDOFF，原正式FS/K4與R12-R17歷史研究不覆寫。

**正式 FS 封版與所有通行度和Map.rvdata 未改動。**