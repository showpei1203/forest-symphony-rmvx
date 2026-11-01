# A47 Moving to Close Attack: 45-degree battle running, 3-frame reverse-stride test (2026-11-01)

## 實際施工
使用 A46 的同一張 PixelLab 真實旋轉 40x40 原始角色當唯一影像基準，先由 A46 真人骨架估計的18關節出發，固定雙眼、鼻子、耳、頭頸、肩、臀，不讓角色整體轉向。F1 左腳前、右腳後，F2 右腳前、左腳後，兩腳位置明確反轉並避免 A46 F2 交叉。透過一次真正 PixelLab /animate-with-skeleton-v3 呼叫生成3張 RGBA 40x40 PNG，保留全部原版與工作紀錄。

## 客觀檢查
A47 原始 PixelLab 三幀完整，透明未裁切，尺寸各40×40，輸出120×40。
F0 原始供應商圖與選定基準有22像素差；交付候選的 F0 採原基準，F1與F2使用供應商實際生成的PNG，須明確註明是 source-anchored 選材，不可稱整排是 unmodified provider raw。
頭部差異：F0→F1 11像素，F0→F2 11像素；F1→F2 0像素（統計ROI）。
腿部差異：F0→F1 114像素，F0→F2 141像素，F1→F2 126像素。
SBS 時間循環明確為 F0,F1,F0,F2；只有3格獨立原圖，不需要生成第四格。

## 美術驗收
較 A46 F2 交叉腿已有改善，F1與F2 的動作更分離、頭部明顯更穩定；仍偏兩腳左右大幅撐開，未達自然的斜45°原地跑步。東南視角雖可維持，不可因API參數視為45°美術通過。美術Gate=待修正；正式SBS VX跑圖尚未測試。
不能把非正式美術候選覆蓋 FS正式資產。下一輪改為縮窄橫向跨步、增加前後深度差，保留原本人物頭部與武器分層規則。

## 證據／交付
- A47_PROVIDER_RAW_3FRAME_120x40.png 與 Provider_F0/F1/F2 為真實供應商原始影格
- A47_ANCHORED_F0_PLUS_REAL_F1F2_120x40.png 為選定Sprite Sheet候選
- A47_0_1_0_2_TRANSPARENT_LOOP.gif
- A47_A46_VS_A47_PROVIDER_VS_ANCHORED_9FRAME_VISUAL.png
- A47_ALL_FOUR_PLAYBACK_PHASES_STATIC.png
- A47_OPPOSITE_STRIDE_18JOINT_SPEC.json
- A47_PIXEL_LAB_SUBMISSION_LOCK.json
- A47_VISUAL_QA.json
- a47_*.py

最終判定：技術格式 PASS，美術修正候選未通過正式 Gate，VX 未實機驗證。