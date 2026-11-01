# A32 人形角色 16 動作標準（2026-11-01）

## 來源
- 使用者上傳的 300×519 像素動作參考圖；前三欄對應每格32×32，16列，每列3格。
- 本對話私有產物：FS_Humanoid_16_Actions_4_Sheets_Reference.zip，四張96×128 PNG，每張4列動作；15列原始動作GIF，Nothing為空。
- 圖片原背景(255,204,153)需去背；原圖分隔線/截圖雜訊不能直接當遊戲素材。
- 這是人形姿勢來源，不是已完成的新FS角色素材；非人形PMD怪物使用其各自四足、翼、尾、觸手的物種骨架。

## 人體18骨架
頭/臉: NOSE, LEFT EYE, RIGHT EYE, LEFT EAR, RIGHT EAR, NECK。
兩側 SHOULDER, ELBOW, ARM(手端), HIP, KNEE, LEG(腳端)。
這是骨架名稱與部位語意，不是從32px截圖直接量出的真實座標；實際角色要estimate-skeleton。
頭髮、胸部、骨盆是視角判讀必備區域，不可只旋轉臉部以假裝45度。

## 四張動作對照（原圖行索引0～15）
Sheet 01: 00 Walking Down; 01 Walking to the Left; 02 Walking to the Right; 03 Walking Up。
Sheet 02: 04 Waiting; 05 Damage; 06 Critic Damaged(重傷); 07 Moving to Close Attack。
Sheet 03: 08 Victory Pose; 09 Dodging; 10 Nothing(空白); 11 Death(倒地保持)。
Sheet 04: 12 Front Jump / Close Attack; 13 Ranged Attack 1; 14 Close / Ranged Attack; 15 Magi Skill Use(魔法)。
所有動作以3個實際畫面作起手/動作高潮/恢復的語意與姿勢參考，最終幀數遵守SBS腳本與原版動畫時序，不可單純套成3幀循環。

## 動作語意
Walk：前腳接地→中立/跨步→後腳接地，左右手反擺，固定地面基準但容許真實1px步態起伏；FS正式A31保留c0-c1-c2-c1。
Waiting：根據原版，FS可維持靜止Idle；不強制呼吸，更不能只有肩膀抖。
Damage：受擊後縮、膝蓋吸收、回防；Critic Damaged：後仰更深、蹲低失衡。
Moving to Close Attack：前傾備戰，人物世界位移由SBS根節點管理。
Victory：轉入勝利姿勢並Hold。
Dodging：縮身低重心→側閃→回防；全身頭胸髖腳協調，不是小步走路。
Nothing：保持透明空白，不需生成。
Death：倒地/死亡後Hold，禁止當成循環待機。
Front Jump / Close Attack：彎膝蓄力→離地躍前→落地，離地屬合法例外。
Ranged Attack 1：準備瞄準→空手釋放動作→復位。
Close/Ranged Attack：蓄勢→出手/接觸→收勢；魔法技能：聚氣→伸掌施法→收手。
所有武器（劍/刀柄/鞘/弓/盾）及法術/箭矢均需從人物本體移除，SBS紙娃娃和VFX獨立。

## PixelLab Prompt模板
"Preserve the approved white-haired 1:1 chibi character, consistent southeast 45-degree 3/4 battle view, teal-gold armor and tiny legs. Use the three supplied humanoid action poses as exact sequential motion guidance, not as character identity. Pose 1: [START]. Pose 2: [MAIN_ACTION]. Pose 3: [RECOVER_OR_HOLD]. Joint behavior: [HEAD_NECK_SHOULDER_ELBOW_ARM_HIP_KNEE_LEG]. Ground/root behavior: [ANCHOR]. Preserve identical repeated neutral frames from source. Entire sprite must be UNARMED at all times, empty hands, no sword/hilt/sheath/shield/bow/projectile/VFX. Native transparent 40x40 pixel art, no resampling, no extra limbs, no facing drift."

對 "Nothing" 禁止呼叫API。One-shot動作絕不因 GIF 可循環就判動作合理。若 User 參考圖有三張原始姿勢，首選把三張影格直接輸入 edit-animation-v2 或 transfer-outfit-v2 做姿勢條件控制，而不是只有文字Prompt。

## A32 PixelLab 實際試驗 (Row 09 Dodging)
- 真實測試工作 e1d05e30-8541-4c94-8bce-a1e89f18405f，/animate-with-text-v3，實際扣1 generation，最終餘額 1811.8/2000。
- 參考圖三種姿勢只解析為文字語意，並未作為圖片給API，且動作看起來較像小幅踏步，沒有清楚的壓低重心/側閃/回防。因此美術Gate FAIL。原始PNG五張保留，不可宣稱已通過。
- 使用者人形標準和PMD非人形例外記錄於 Google Doc: https://docs.google.com/document/d/1iQB7hBchJX36Ko0cnAKhB9H9KOV7yYxTXpUdmQFZzaM/edit
