# FS A33 人形角色 PixelLab 姿勢直控 A/B/C 施工規格
2026-11-01 | AUTHORITY: A31 原生步態已獲使用者核准；A26 白髮青綠Q版頭身1:1已核准；A32動作語意圖。

## 範圍 / 限制
- 使用者 16 行 3 姿勢/行，前三欄 32x32，四張透明96x128參考圖。人形專用，不把人類骨架強制套在 PMD 非人形怪物。
- FS Tankentai SBS 人物不畫武器、劍鞘、刀柄、弓、盾、魔法特效；全部由獨立武器紙娃娃層/VFX處理。
- 方向：45°東南3/4戰鬥視角，白髮臉、肩胸、髖、腳須一致；不可90°側臉。
- Idle：原版固定中立姿勢，不憑空加肩膀抖動。
- Walk：原版 $actor01 row2 c0-c1-c2-c1 的真實姿勢。A30人工關節步態FAIL不得沿用。
- 絕不把純 Prompt 動畫、漂亮概念圖或局部像素數據冒充遊戲引擎正式PASS。

## A/B/C 測試順序
1. R1 Waiting：原版靜態中心影格直接作免費對照。B若沒有增加可辨動作價值，不付費生成。
2. R1 Dodging：A 組 A32已測文字動畫 FAIL（工作 e1d05e30-8541-4c94-8bce-a1e89f18405f）；B組以使用者截圖第09行三張PNG直接當PixelLab /transfer-outfit-v2 keyposes，一次送件；先逐格QA。
3. R1 Damage：B組以截圖第05行三張真正姿勢送件一次；先依 Dodge 結果決定是否需要變更錨點與裁切。
4. C組：只有B動作可辨、頭身與身份保留時，才以整組 /edit-animation-v2 修正45°東南角度；若改壞原姿勢，C FAIL而非自稱PASS。
5. R2 Critical Damaged、Front Jump/Close Attack；R3 Ranged/Close/Cast；R4 Victory/Death，完成每階段 Art Gate 才擴充。

## 姿勢圖如何進入 API
以本次對話私有 ZIP 中原始32x32 PNG為實際來源，16～32色索引PNG顏色不變；每格左+4，上+6嵌入40x40透明畫布，NEAREST不縮放，不做新姿勢、不內插。逐張SHA256證實有三張實際參考，不是只用文字。
API B payload: reference_image=已核准的 A31 40px 空手角色；frames=[三張使用者參考姿勢40px]；image_size=40x40；additional_instructions=保留三個姿勢的膝髖與手腳動態、只轉衣裝外觀、空手45°。注意純骨架語意並不等於原始三張 pose image，兩者必須分別記錄。
若姿勢被失真，不可再同樣Prompt盲目重送。
測試來源原圖私人留在E槽，第三方像素圖片不可推GitHub公庫。

## Gate A～G（Fail-closed）
A Provenance: 真實截圖每張Pose SHA、FS原版SHA、PixelLab job_id、扣額；先寫SUBMISSION_LOCK，防雙重扣款。
B Motion: Dodging 要可辨防守屈膝→側閃→回防，Damage 為受擊→縮身→恢復；不能變成走路。
C Camera: 臉/胸/肩/骨盆/腳皆45°，90°側臉FAIL。
D Identity: 白髮Q版頭身約1:1、青綠盔甲、所有幀完全無武器。
E Physics: Waiting腳底接地靜止，Dodge髖部側移、Damage腿關節吸收，Jump合法騰空；場景根節點位移由SBS管理。
F Technical: 40x40透明完整，連貫身體無斷肢，One Shot不要求首尾Loop；source PNG and raw provider frames separately preserved.
G Human/Engine: 人眼通過後才做真正 VX/SBS/武器紙娃娃疊層驗收。未做之前不可宣稱正式PASS。

## 預算紀律
B每動作限1次、C每動作限1次；不因生成過濾而重複燒點。A32 Dodging文字版既有FAIL，不重生成。
前批餘額1811.8/2000（A32），每次完成都重新讀取Provider餘額，不推算冒充實際花費。
