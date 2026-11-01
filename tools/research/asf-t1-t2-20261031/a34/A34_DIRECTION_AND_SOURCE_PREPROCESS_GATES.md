# A34 正式施工與方向驗收規格

來源：使用者判定 A33 Dodging 的 F0 方向錯誤，故 A33 B/C 對該動畫的視角Gate均不通過。不得以「整體看起來45°」掩蓋F0錯誤。

## A34 新增 Gate 0
先從真實 FS 原版 $actor01_1、$actor01_2、$actor01_3 的 32x32 戰鬥影格取得雙眼/臉部平面、肩胸、骨盆朝向，不能使用原版 $actor01 行走純側臉當45°權威。
每一種新的動作先放大 F0 對照真實戰鬥角度，再逐格檢查 F1 ... Fn，任一格方向錯誤就 Camera Gate FAIL。
**人物不能自行帶武器**；由 Tankentai SBS 紙娃娃系統另行疊圖。全程保持核准的Q版1:1頭身比例，40x40透明、身份與裝甲一致。
F0方向→F1姿勢→F2回復：三者獨立驗收，不能靠Loop像素差當自然度證明。

## A33 失敗的參考圖來源問題
從300x519圖片擷取32x32，原DODGE1含44個完全獨立的上一列殘片；DODGE2另有右側長32px直線。Damage類似。DODGE0向側面且與上一列像素接觸，不可機械刪除，這是原始截圖的失真/方向污染，不能直接用作正式45度F0。
原始像素永久保留。只在新候選的原始來源副本中刪除能客觀證實為獨立且跨列的殘片，逐像素記錄修正；絕不重新繪製參考動作。

## A34 試作
1. 原生戰鬥角色 identity master：以真正的 $actor01_1 r1 c1、r2 c1 為姿勢輸入，A31已接受白髮青綠甲外觀作身份引用，PixelLab transfer-outfit-v2雙影格一次生成。已測明 /transfer-outfit-v2 最少接受2格，單格422拒絕，沒有計費。
2. Dodging直接控制B2：用上一步真實PixelLab回傳的原版戰鬥角度人物作F0和F2；F1採使用者DODGE1深蹲姿勢原圖精確去除44px外來殘片，x+4/y+6嵌入40x40。三格加同一身份引用，真正PixelLab transfer-outfit-v2一次生成。
3. 修正只限於Sprite Sheet複合：若提供者破壞F0鏡頭，可用真實Battle-master原始PNG像素逐格原樣置入F0/F2，F1只能使用真正的PixelLab生成結果。嚴禁把這種排列冒稱完整提供者原始結果，分開保留 RAW 和 CANDIDATE。
4. 重做逐格方向 Gate，先人工檢查F0眼睛/臉、肩甲胸口、骨盆、兩腳。結果可以是 QA FAIL；不自動繼續付費 C 組「文字修45度」重試。
5. 後續要進入受擊或其他動作，沿用相同參考清理+F0角度規則。原始FS、PMD、Tankentai SBS檔一律不覆蓋。

## 記錄/交付
所有原圖 SHA、輸入輸出 SHA、真實PixelLab job_id、balance、逐幀bbox、差異與裁切、GIF、並排10x預覽、錯誤/效果比較、私人ZIP、GitHub代碼、Google Drive Handoff。不得宣稱正式藝術或VX引擎PASS，除非實際驗收。
