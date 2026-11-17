# Forest Symphony｜A56 Failure Log｜2026-11-18

## FL-A56-001：第一次真實 A53 盾牌候選遮住大半角色臉部（R1 ART FAIL）
- 真實 A53 來源：`actor01_a53_body_12frames.png`，SHA256 `af2b94a424ab613fa5a8ff45125f0398da3a20432cdeaa744f87f9f1b1a9ac44`。
- R1 盾牌置於腕關節座標約 `(-4.5,-2)`、半徑約 (9,12)，雖讓 F5、F6 的手腕小範圍 alpha 在盾外為 0，卻在其他幀遮住角色頭部。視覺大幅不合格。
- 將 **真實 A53 Body alpha** 在頭部近似 ROI `(20,15)-(45,32)` 和盾牌 alpha 同座標交集計數。R1 十二幀最大 **121 px**、R2 最大 **1 px**。
- 注意頭部 ROI 是**近似位置的量測窗口**，不是經核准的精確人臉/頭髮語意遮罩；計數僅工程診斷，不能自動改判 ART PASS。

## FL-A56-002：只檢測手腕不代表全手臂或解剖正確
- R1／R2 使用真實 A53 Body 與 12 幀手腕錨點，在腕部 **3px 半徑附近**擷取當前像素作遮擋 Witness。全部 12 幀遮擋 Witness 在盾外殘留 **0 px**。
- F5 Witness **16px**、F6 **18px**；R2 F5/F6 顯示於盾外的合成劍尖各 **50px**。
- 但**完整前臂、拳頭、手持盾方式**從未完成經驗證的逐像素語意 mask。即便數值看似漂亮，仍是 ART HOLD。
- 防再發：將 `full_forearm_segmentation = NOT_RUN` 固定寫在兩版報告，禁止把局部 PASS 升格為完整遮擋 PASS。

## FL-A56-003：R2 盾牌與劍尖仍為程式產生的佔位圖
- R2 調整為腕部相對 `(+3,+3)`、盾牌半徑 `(7,9)`；保住頭部視覺與手腕 alpha 覆蓋，但**非真正經驗證的精靈村／FS 戰鬥美術**。
- 劍尖與劍柄不構成完整武器，盾牌的手持關係、縱深與重量還需正式 pixel artist / PixelLab 來源與真人 1× 比對。
- A53 真實 Body 的 12 幀完整保留、R1 與 R2 資料分開、不覆寫。

## FL-A56-004：驗證環境不要混淆
- 本次 **Pillow source-registered compositor** 對真實 A53 來源做十二幀運算、輸出 PNG/GIF、SHA 與 Alpha Gate。
- GitHub Actions **12 個 Python 正反負例**＋R2 無私有來源之幾何 smoke PASS。
- 這**不是 Godot GPU 原生真實 A53 渲染**，亦不等於 A54 原先 95 秒 timeout 已解除；A55 的 Godot GPU PASS 是獨立 synthetic 場景。
- FS 主 ATB/技能/戰鬥/敵人傷害未在 A56 跑；ART HOLD、正式整合 NOT RUN。

## FL-A56-005：原始圖像不可上公開 repo
- 所有含 A53 原始像素的 R1/R2 PNG 與 GIF 只上傳 owner-only Google Drive A56 資料夾，公開 GitHub 只有程式、測試、權威和不含私有像素的技術記錄。
- 12 幀人物的原始位元/檔案不變，所有處理發生於隔離環境，未寫入使用者 PC。
