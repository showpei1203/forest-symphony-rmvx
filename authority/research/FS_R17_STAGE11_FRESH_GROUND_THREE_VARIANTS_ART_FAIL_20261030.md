# Forest Symphony R17 Stage11｜三種全新 Ground 材質試驗（2026-10-30）

**正式：TECH CANDIDATE / GROUND ART FAIL / PAR SOURCE HOLD / PAIR ART FAIL / FINAL SEAL NO。**

## 目標與做法
延續 Stage10 的 Ground 美術未達標：使用同一張 544×416、高細節且真透明的既有 PAR（不重新從完成 MASTER 擷取），真正重新製作 Ground，不讀取 Stage4–10 任一完成的 Ground 圖片。這次不是套用舊 Ground 修草皮、也不是只改筆數；新規格改用草地多尺度明暗、暖色非規則石板材料、道路近端聚集的低矮花飾與房屋接地陰影。

已從原始繪圖程式實際產生三張 544×416 RGB Ground：
- C_WARM_GARDEN：暖色草地、45個低花叢群，Ground SHA256 `b99c2caeb191f5afe8e1df29ca43242779978ad1488e278753df9b15e677a9e0`。
- D_DARK_MOSS：暗綠苔地、34個低花叢群，Ground SHA256 `289eea1e87958946e66dacf22920fc02bb64b5d62e9b28072c062bb4cb2a6468`。
- E_OLIVE_MEADOW：橄欖綠色調、34個低花叢群，Ground SHA256 `5e236976f718f2aec065ad11b12ed4de20b66d0120f44c2a21f0450ad3edceec`。**E 是本輪只供技術檢查的比較候選，不是美術 PASS。**

沿用 PAR SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`，它是上一輪獨立透明 PAR 來源的 Alpha 修復/等比例縮小結果；高細節房屋與樹冠保留，但並非原始逐物件可編輯來源。保留來源現況，不謊稱全新的原生獨立素材套件已完成。

## 真正技術測試
- Ground RGB 544×416，PAR RGBA 544×416，32px 網格為17×13。
- PAR Alpha0 =112,766，Alpha255 =108,885，半透明1..254 =4,653；四周外框全部透明。
- 從**正式 Ground.png + PAR.png**重新做 Alpha 合成，與 COMPOSITE_QA_ONLY.png 逐像素完全一致（0差）；此結果不能代替藝術驗收。
- 隔離目錄只提供原始 source generator 與既有透明 PAR，重新執行後 Ground C/D/E、正式 Ground、PAR、正式合成 QA 的6個SHA全部一致。
- 人為裁掉PAR1px、PAR邊界注入一個Alpha=1的像素、偽造 Ground SHA，三個負向測試均拒絕。
- 正式 ZIP **4,586,215 bytes／16 items／CRC PASS**，SHA256 `35c827e4c7f0cce804cde45f6548abb9ba5ed18f143c0bc0406e64a0d9266441`。
- 關於來源的核對：Stage11 Ground 生成器只取繪圖原語、色盤、隨機種子和原創幾何；**不讀任何前一輪 Ground PNG**。PAR 保持前一輪的檔案完全不變。

## 實際目視
- **GROUND_ART FAIL**：E 比 C 不那麼亮、暖色石板路有較明顯的大小與石縫，但草地還是能看到程式化斑塊；與使用者 high-detail ground3 / 精靈村參考相差明顯。
- **GROUND 植被比例候選**：單一低花群原始尺寸限制在13×9px，遠小於村屋，不再有「花草比房子巨大」或 Ground 突兀樹幹。
- **PAR_SOURCE_HOLD**：此PAR美術豐富，但單幅已組合多個物件，沒有逐物件原生可編輯來源，部分地面花卉歸屬待定。
- **TREE_FOOT_SEMANTIC_HOLD**：Ground只有陰影、整棵樹仍在PAR；避免孤立樹幹但與早期底部32×32樹幹歸Ground規則不同。
- **PAIR_ART FAIL / FORMAL SEAL NO**。任何生成圖片內印有PASS的四格QA展示板不是技術證據，這輪又產生一張，已排除，不作來源素材或驗收佐證。

## 交付
- [Drive Stage11正式Ground／真透明PAR／合成QA備份](https://drive.google.com/drive/folders/1PFMDeEYdzxjLY0OfG3Lir7JR13HkFNJx)
- [Ground E PNG](https://drive.google.com/file/d/1L8ON_YTI7fAZQZgIfHnDt5rsM-dRZvcD/view)
- [PAR PNG](https://drive.google.com/file/d/1qPA7Blt6JjWe6YV94mTa1BzLM1DAUpwB/view)
- [實際合成QA](https://drive.google.com/file/d/1Z3-W5YOI71deo0MHMDwn0WjgwDQUSFqu/view)
- 完整三版本可重現ZIP目前在本次對話的可下載附件 `FS_R17_STAGE11_NEW_GROUND_TECH_CANDIDATE_ART_FAIL_20261030.zip`，**尚未上傳到 Drive**，勿謊稱雲端 ZIP已同步。

## 真正需要改進的下一步
Stage6–11已證實：只提高雜訊、草點、石板程序多樣性，無法達到相同風格的高藝術品質。下一輪應優先建立與目前PAR同級的**原創藝術可編輯地面材質家族**（高品質可變草地、暖色不規則石路、低矮花草），而不是再多產生幾張技術 PASS 的低美術 Ground。PAR也需要每棟屋／每棵樹／路燈與柵欄的個別原生來源。封版的 FS/K4、Map.rvdata、Scripts.rvdata、碰撞及使用者通行度全部不動。

**Handoff：** Source-first architecture valid as TECH candidate, Art FAIL. 不達美術 Gate 前，禁止宣稱最終封版。
