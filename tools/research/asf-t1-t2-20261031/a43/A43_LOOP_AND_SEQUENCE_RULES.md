# FS A43 正式修正：3 張儲存幀與 LOOP／SEQUENCE 動作分類
日期：2026-11-01。由使用者明確指定，A42 Moving to Close Attack 原試作外觀像受傷，判美術／動作語意 FAIL。使用者修正：這個動作只是跑步循環，無須設計三格「起步→突進→停下」。不得再次犯同樣錯誤。

## 1. 兩種動作播放模式
**LOOP 類**：Moving to Close Attack、Waiting、Critical Damage、Magic Skill Use，以及一般 Walking（按實際腳本/動作指定循環）。
**SEQUENCE 類**：Damage、Dodging、Death、Victory、Front Jump/Close Attack、Ranged Attack、Close/Ranged Attack等按順序播放的類別；個別演出還需以原版 SBS 設定核實，不能把這個分類誤當完成了引擎測試。
三格是**存圖規格**，不是固定播放三個時間點。每個動作持有 F0、F1、F2 共三格（40×40 測試尺寸，整張 120×40 透明 PNG）。

## 2. Moving to Close Attack 正式循環
- F0 兩腳平／中立跨步間隔（原 A31 已通過走路圖的 c1）。
- F1 邁左腳（原 A31 c0）。
- F2 邁右腳（原 A31 c2）。
- **播放順序 0 → 1 → 0 → 2 → repeat**，絕不可硬儲存第 4 張 PNG。
- GIF 的4個播放時間片段不等於4張 Sprite Sheet 圖；播放器只引用儲存的3格。
- 先以115ms/拍製作8倍放大循環 GIF，速度只是驗收參數（使用者可調）。
- 這次直接沿用 A31 原先已經通過的真實像素行走素材，而不是另外要求 PixelLab AI 猜一個跑步姿勢。不生成新影格，不扣 PixelLab credits。

## 3. Waiting、Critical Damage、Magic Skill Use 的 LOOP 規則
- Waiting 可以是原始靜止三格：在循環狀態仍保持靜止，不強迫產生搖肩或上下浮動。
- Critical Damage 應有適合重傷狀態持續循環的 F0/F1/F2，不能直接把 A40 的「站姿→受擊→重度倒下」序列設為循環；否則人物會一次次站起來受傷。**A40 保留作重傷動作骨架研究，現有畫面不是已驗收的重傷LOOP**。後續先生成一致受傷姿勢中的循環變化，再測。
- Magic Skill Use 的三格應表現蓄力／施法持續的 LOOP，絕不能當作一次性傷害施放或要求把武器/魔法效果畫進角色；SBS 特效與武器紙娃娃獨立。
- 對不同 LOOP 類的幀序列，預設可採 0→1→0→2；但可由權威原始動作腳本決定相位。任何 LOOP 的F0/F1/F2必須在角色攝影機與服裝上一致。

## 4. 階段狀態與 Fail-closed Gate
- A42：被使用者判定受傷感/沒有跑步語意，**FAIL**，不可引用該動作圖作新版來源。
- A43：使用 A31 SOURCE c1/c0/c2 真實影格重新排列，原始動畫 A31 相位 c0/c1/c2/c1 中 c1=c3 逐像素已驗證。0、1、0、2 真正GIF持續播放；F0/F1/F2為3個不同儲存影格，120×40格式 PASS。
- 正式遊戲 Engine PASS **尚未完成**：SBS世界座標位移、武器紙娃娃疊層與回歸原位需要另作VX實機測試。這個階段只做正式格式素材候選與播放預覽，不能冒稱遊戲集成已通過。
- 嚴禁超過三個實際圖格。必須逐格比對45°朝向、頭身1:1、無武器、雙腳有差異、畫布無切邊。只要動作觀感仍不像跑步，使用者可判FAIL。
- A37 使用者指定 Dodging 第4種 T4 永不回退、A31 已驗收動作不回退。原始FS/PMD/Tankentai SBS和封版檔案一律不覆蓋。
