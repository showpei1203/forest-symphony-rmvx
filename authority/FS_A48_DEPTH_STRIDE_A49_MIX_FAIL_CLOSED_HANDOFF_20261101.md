# FS A48 深度跨步、固定戰鬥視角及 A49 混合試驗 Handoff (2026-11-01)

## 來源
沿用 A46 PixelLab 旋轉成功的 F0 40×40 與估算18關節，完全不修改封版FS及A46/A47原始檔。針對A47的過大橫向跨步，A48以更緊密 x(約.43～.65) + 拉開 y(.82～.927) 的雙腳骨架進行單次真實 PixelLab /animate-with-skeleton-v3 三幀生成。動作循環仍0→1→0→2（只需三張不同圖）。

## 客觀結果
三張供應商真實輸出的PNG均是40×40 RGBA、無邊緣裁切，已組成120×40 Sprite Sheet。A48真實結果中的F0相較原始鎖定F0有67個像素變動。
頭部ROI差：F0對F1 257、F0對F2 257、F1對F2 6；腿部ROI差：F0對F1 167、F0對F2 183、F1對F2 131。
使用整數dx/dy ±4 像素自動搜尋校準，最佳仍是(0,0)，頭部差異268（不同ROI），故不是單純畫布偏移，不能宣稱平移已修正。
本輪 PixelLab 一次工作回傳3張真實PNG，實際餘額1679.6/2000，比A47後1681.6減少2.0 generation，所有調用紀錄已鎖定，避免重複扣點。

## 影像後處理 A/B
將同一張F0上半身像素嚴格複製至A48 F1、F2，分別測試y=23、25、27三個切點，保留供應商輸出的下半身，沒有畫布裁切。Y25視覺上頭部、肩部最連貫，是『精確來源拼接候選』，但不能稱完全由PixelLab原始產生的三張圖，更不能宣稱自然跑步已通過。
A49進一步製作A47大跨步F1+ A48深度F2、及相反組合共兩條透明0-1-0-2循環，以及4版本同框比較。兩條混合步幅不對稱，均不可正式採用。

## 綜合判定
格式/技術 PASS。F0來源鎖定實驗有效，Y25接縫尚待人眼最後驗收。但A48 F1/F2整體動作不具備令人一眼辨識的左腳/右腳交替：新生成常將同側靴子留在前面。45度藝術視角尚未原生SBS實測。A48／A49 = **ART FAIL / NO FORMAL PASS**。A47在目前的三幀角色一致性與動作區分度仍是較好的基準，但同樣未獲正式美術PASS。

## 後續最小施工方向
停止盲目增加全身生成次數；先將A47 F1/F2的左/右靴（及小腿）拆成局部獨立像素部件，在受限場景內做兩組真正交換前/後景腿部動作，不准改頭部/肩膀/整體朝向。分開審查：角度、美術、腿部、圖片裁切、0-1-0-2連續性、Tankentai SBS實機。保留所有失敗案例與原始源檔。

## 證據
- A48_PROVIDER_RAW_3FRAME_120x40.png
- A48_A46_A47_A48_12FRAME_VISUAL.png
- A48_ALIGNMENT_QA.json 與 A48_REGISTERED_VS_RAW_VS_A47_9FRAME.png
- A48_F0_UPPER_LOCK_SEAM_COMPARE_5ROWS.png / A48_UPPER_LOCK_AB_QA.json
- A48_LOCK_UPPER_Y25_3FRAME.png
- A49_MOTION_COMBINATIONS_4ROWS.png 與 A49_COMBINATIONS_QA.json
- A48_VISUAL_QA.json、A48_PIXEL_LAB_SUBMISSION_LOCK.json
- a48_*.py 等重建程式