# FS R17 Stage12｜使用者正式否決：Ground 美術與 Ground/PAR 配合（2026-10-30）

**權威驗收結果：GROUND_ART = FAIL；GROUND_PAR_VISUAL_INTEGRATION = FAIL；OBJECT_GROUND_CONTACT_AND_STYLE = FAIL；FORMAL_SEAL = NO。**

本文件的藝術 FAIL 優先於之前 Stage12 自動化技術結果或「C 版美術候選 / HUMAN HOLD」的描述。**C 版已撤銷藝術候選身分，只保留為失敗證據與原始來源技術回歸樣本。** 本輪明確否決來自使用者原話：「GROUND本身美術不合格，GROUND和PAR配合的部分也不合格」。

## 直接從 Stage12 正式 PNG 檢視到的缺點

1. **GROUND 單圖：空泛且視覺不自然。** 大片單一橄欖草皮，只有零星小花；缺少有節奏的自然地表、植栽叢聚、層次與材質變化；手繪石板雖比程序石頭好，整條路卻顯得過於整齊，路緣與草地過渡不足。單獨 Ground 未達 ground3／精靈村高精緻標準，不能因背景看起來乾淨就判藝術通過。
2. **GROUND/PAR 完整場景不一致。** PAR 有高明暗對比、精密磚瓦、窗台與成群花圃；Ground 大面積平、暗且低細節，兩層的光照、色彩密度、筆觸與地表豐富度不屬同一場景。
3. **接地邏輯與物件腳點未經共同繪製。** 神聖樹根與周邊花簇、兩間屋的門檻/台階、欄杆和路燈基部都屬 PAR 的已組合物件，但 Ground 的道路、接地暗部、花土與草坡不是按照其真實 source footprint 共同設計。合成時能看到視覺上的拼貼感，無法以同一 PNG 原點或 0px QA 差異解除。
4. **道路 / 房屋 / 植被相互配合失敗。** 石路走向雖已修通，但路寬、入口過渡、路緣草土與屋前環境仍不是一個共同設計的街角； PAR 的樹木與屋旁花圃形狀也沒有和 Ground 草地紋理自然銜接。
5. **技術一致性不等於藝術配對。** 原來只有 Alpha、共同 544×416、PNG 合成 0px 與自述 source manifest 的檢查；這些只能證明兩張檔案可疊合，不能證明它們在自然視覺、比例、接地、結構或風格上配對。

## 自原圖及測試工具可核對的保留事實

- `GROUND.png`：544×416 RGB，SHA256 `1e3e97fc1ec9288f78eabd42c351b694f5aa55e8123bd1e8d7a8acf556911363`。
- `PAR.png`：544×416 RGBA，SHA256 `e5c33ddd1ca4ffb00eb89306c57fbd60f3ed2c5bf4e83992f2124a47d07ef3e9`。
- 前次 source validator 與 strict alpha/canvas gate：exit0，僅 `TECH_CANDIDATE_ONLY_NO_ART_PASS`；自原始來源冷重建 7 份雜湊一致；三個負向突變皆 exit2。以上技術證據**保留**，不修改原數據，也**不得再使用為「配合度 PASS」**。
- `PAR.png` 來自 Stage7 原本獨立生成但已一次組合多個物件的透明來源，非逐物件、native 1x 的同源分層 kit。Stage12 將這張既成 PAR 與獨立新繪 Ground 放一起，正是本輪 Visual Integration FAIL 的重要製程風險。
- 封版的 FS/K4、Map.rvdata、Scripts.rvdata、collision 與使用者通行度全部保持不動。

## Stage13 修正流程（不得原地僅微調 Stage12 C）

**第一關是共同場景設計，不是 Alpha。**

- G0｜**共同美術風格與尺度鎖定**：以使用者精靈村/ground3 參考圖作美術品質標準；以 32px 世界網格、門寬、樹徑、角色高度定義 Ground 花草/石路/建築之相對比例。Ground 自身就須達標，才允許配圖。
- G1｜**共享世界場景 Blueprint**：先決定兩房屋門座標與門前足點、樹根基部、道路、花圃、欄杆、陰影和可行走空間的落點。記錄物件原生 Alpha footprint 和世界座標，不能只是事後把兩張圖都寫上相同 blueprint_id。
- G2｜**兩份真正對應的來源圖**：重建不含巨大灌木或孤立樹幹的獨立高品質 Ground，同時以共同世界尺度原生創作高豐富度 PAR 物件及其各自來源。**禁止先完成 Master 再逆切 PAR，也禁止繼續沿用 Stage7 既成 PAR、獨立亂畫一份 Ground 來冒稱配對。** 舊高細節 PAR 只能當藝術密度參考，不是新場景完成品。
- G3｜**人眼失敗先止損**：審 Ground 單圖；審 PAR RGBA 原圖；審真實原圖的 1x 合成與門口／樹根局部放大比較。任何一項藝術 FAIL，直接停止，不准僅靠高重建率或漂亮概念圖 PASS。
- G4｜**技術回歸在藝術候選後**：做尺寸、真 Alpha、遮擋、座標、來源 hash、PNG 合成、冷重建和負向突變。結果必須區分 `TECH_PASS` 與 `ART_PASS`，最終藝術驗收歸使用者。

## 成果與故障記錄

- [Stage12 原圖與可重建技術包（保留作 FAIL 證據）](https://drive.google.com/drive/folders/1c6w2ffUrA_jA349VlUXpYZkXm13twx4g)
- [Stage12 使用者否決與標注視覺問題的 QA-only 圖](https://drive.google.com/drive/folders/12Zr1hr0isHHYz3_mjHAk8Ylgkj7VPlpZ)
- [原 Stage12 技術報告](FS_R17_STAGE12_SOURCE_QUILT_ART_CANDIDATE_20261030.md) ：保留歷史，不得視為最新藝術狀態。

**最新結論：GROUND_ART FAIL / PAR_PAIR_ART FAIL / ART CANDIDATE REVOKED / TECH HISTORY RETAINED / FORMAL SEAL NO.**
