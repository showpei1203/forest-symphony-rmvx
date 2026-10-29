# FS R17 Stage6｜可重現原生雙圖技術候選與藝術不合格紀錄（2026-10-29）

## 總結
**TECH PASS / ART FAIL / FORMAL SEAL NO**。這輪在 Windows 原機真正從一套來源和共同世界座標製作了一組 544×416 Ground/PAR。這組並未達到使用者所要求的 ground3 與精靈村參考圖的高精緻美術，不可當作正式候選封版。

Stage5 最新 ImageGen 圖面 1434×1097 / 1448×1086 + PAR 假不透明是正式 FAIL，保留原證據。另一張 imagegen 生成的「R17 Stage4 V3 PASS」四格展示板**只有印刷文字和圖片**，沒有對應真正的分層 PNG，必須明確歸檔為 MISLEADING_FAKE_PASS_VISUAL，不能作為 Gate 結果或素材。

## 執行程序
1. 原生 Ground 由 `tools/r17_direct_stage6/build_stage6_native_pair_v2.py` 在 Windows Python3.11/Pillow/NumPy 直接建立。它不讀任何舊 `GROUND.png`、V6 GROUND_B，也不從完整 Master 反向挖洞；地表道路、草地、貼地小花在來源創作階段完成。
2. PAR 基於相同 544×416 Blueprint，將 V23 原始獨立透明藍房與赭色小屋、V6 神聖樹原始 Sprite、1棵 nearest 小樹和作者階段畫出的路燈、柵欄、木牌、井、板凳與盆栽等 **19 個來源物件**放到原生透明畫布。
3. V1 曾把 11px 根部 SOURCE 繪入 Ground，Ground 單圖可見突兀樹根；V2 移除該可見 stump，把完整樹木保留 PAR，Ground 僅接觸陰影，**但歷來『樹幹最低32×32屬 Ground』規則語義衝突列 HOLD，不假稱全部已修好**。
4. 所有輸出原生 1×，沒有將 ImageGen 高解析概念圖獨立縮成兩幅互不對位的尺寸。所有原始透明 Sprite 保存在私人包內，不上傳公開 GitHub。

## 實測數值

| 項目 | 結果 |
|---|---|
| GROUND.png | RGB 544×416 / SHA256 `a7b8a40fd5b08ea270374c8c14aebbd9b3948ecb107ceb624e51f048d374bf26` |
| PAR.png | RGBA 544×416 / SHA256 `353856053490e77a84073451e75c6e6708491d798b77469b3729f2131723bfee` |
| PAR alpha0 | 158330 |
| PAR alpha255 | 67974 |
| PAR partial alpha | 0 |
| PAR 四邊非透明像素 | 0 |
| 完整物件 | 19 |
| Ground 實際花草物件尺寸上限 | 作者規格 ≤18px 寬，遠小於屋寬153px（不代表整體美術 PASS） |
| 官方 source validator | Exit 0 / `TECH_CANDIDATE_ONLY_NO_ART_PASS` |
| Stage5 strict alpha/canvas gate | Exit 0 / `TECH_CANDIDATE_ONLY_ART_HOLD` |
| 冷重建 | 使用 ZIP 保存來源與 V2 腳本重新執行，Ground/PAR/QA 三張 SHA 完全一致 |
| 故意裁短PAR 1px | Exit 2 / 擋下 |
| PAR 四邊注入半透明點 | Exit 2 / 擋下 |
| 篡改 Ground SHA 來源宣告 | Exit 2 / 擋下 |
| 原機 E: ↔ 掛載雲端 G: | Ground/PAR/ZIP 三個 SHA 一致 |
| 私人 ZIP | 1,901,130 bytes／40 entries／CRC PASS／SHA256 `948407e174c9aa5c0ee1b1935df82a78c82c1feaed6478e82641a0e71287e63c` |

注意：`source_manifest` 的來源身份仍有 self-declaration 成分；冷重建結果加強可重現性，但不能自動證明任何由模型生成圖像的美術完整性。

## 獨立藝術 Gate
- **Ground ART FAIL**：草地仍像程式雜點、石路過於制式，難以接近使用者提供的 ground3 / SCENE21 / 精靈村高細節質地。
- **PAR ART FAIL**：雖放了 19 物件，房屋比單純拼貼好，但欄杆、盆栽、燈等與兩棟高細節來源仍存在風格與像素精緻度落差；無法取代最新 Model Generated PAR 的豐富概念畫面。
- **Pair TECH PASS / Pair VISUAL HOLD**：相同世界座標、PNG容器與遮擋大方向成立；樹底32×32接地語義仍未正式確認，美術也不通過。
- **正式封版 = NO**。使用者後續自行把 Ground + PAR 合成 NEW_GROUND，自己用原腳本設定通行度；本輪沒有修改任何正式 FS/K4、Map.rvdata、Scripts.rvdata 或 Collision。

## 後續唯一路徑
必須優先改善 **可重現、高品質原生物件與地面材質來源**，而不是增加隨機草點。對大型精靈村參考品質，先完善一個美術風格鎖定的 house/tree/fence/flower kit，再依單一世界 Blueprint 原生輸出 Ground+PAR。禁止將圖片展示板上印出的 PASS 當實際 Gate、禁止把先完成的大 Master 逆切 PAR、禁止拿以前舊 Ground 局部補丁冒充全新 Ground。

## 檔案與追溯
- [Google Drive Stage6 私人雙圖／QA／來源／ZIP／驗證](https://drive.google.com/drive/folders/1Dbq20qw79F4VFF3ScnWTEWf67Ywxmv1v)
- [GROUND.png](https://drive.google.com/file/d/1iV0QRKDjAT5kQO5QEf--pzTeHT9qIgNu/view)
- [PAR.png](https://drive.google.com/file/d/1L3bToaVFM7LEH3W3apqQr6ewrOTT5cBB/view)
- [COMPOSITE_QA_ONLY.png](https://drive.google.com/file/d/1WyzpHUXjDOaf4S-mChFbx5ZJLKk4y8Xc/view)
- [Private zip](https://drive.google.com/file/d/1DBYLHvpvBhSmc2yftODu8AxZ6IHamM6_/view)
- [V2 原生生成器](../../tools/r17_direct_stage6/build_stage6_native_pair_v2.py)
- [驗證和打包腳本](../../tools/r17_direct_stage6/package_and_test_stage6.py)

舊的 R17 Authority 與 K4 Sealed Baseline 完全不動。**下一輪接續 ART SOURCE QUALITY，不要重做已證實的 Alpha Gate。**
