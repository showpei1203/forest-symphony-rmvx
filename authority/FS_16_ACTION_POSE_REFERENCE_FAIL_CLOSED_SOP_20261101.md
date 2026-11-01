# FS 16動作三幀骨架權威參考與省額度作業規範（2026-11-01）

來源：使用者提供 300×519 PNG，16列、每列三個人物姿勢。來源像素 SHA256：ba786a21f2fac0874d78b3332967a0717ca1b9f8206c365b39bf741a0b80d5be。這是動作參考，不是可直接導入FS的40×40戰鬥SPRITE。鏡頭與角色外觀仍以FS原版 `$actor01_1/_2/_3` 的45度SBS素材為權威。**先解析動作骨架，絕不能直接用PixelLab文字提示賭結果。**

## 關鍵發現：Moving to Close Attack三幀欄位
參考圖片左欄=單側跨步、中欄=雙腳中立、右欄=另一側跨步。FS內部應轉換成：`F0=原圖中欄`、`F1=原圖左欄`、`F2=原圖右欄`；播放為`0→1→0→2`，四個時間節點、三張實際PNG，而不是照原圖左→中→右循環。世界空間跑向敵人的位移由Tankentai SBS負責，角色紙娃娃必須只在原地交換腿。其他四方向Walking亦是兩側步態配合中立，但不能使用側面Walking人物冒充45度戰鬥。

## 全部16列分類與主導關節
|列|圖上標籤|類型|三張姿勢與骨架意義|
|---|---|---|---|
|1|Walking Down|LOOP|正面固定朝向，左右腳交替，雙臂反向小擺，少量上下起伏|
|2|Walking to the Left|LOOP|向左側面步態；腿交替，臉型固定；不可作45度戰鬥鏡頭|
|3|Walking to the Right|LOOP|向右側面步態；腿交替，臉型固定；不可作45度戰鬥鏡頭|
|4|Walking Up|LOOP|背面步態；髮束、背部方向固定，兩腿交替|
|5|Waiting|LOOP|站姿不換腳，肩與頭自然微呼吸，小幅上下動|
|6|Damage|ONCE|受擊後仰→屈膝收縮→復原，嚴禁像跑步|
|7|Critic Damaged|LOOP|瀕危弱姿/喘息/回擺，可有汗滴；不該大步走|
|8|Moving to Close Attack|LOOP|左跨步/中立/右跨步；FS依中立/左/右重排、循環0-1-0-2|
|9|Victory Pose|ONCE|站立→舉手→完成/保持；主要變化肩肘手|
|10|Dodging|ONCE|閃身側傾→蹲低翻避→回正；可改重心不可換鏡頭|
|11|Nothing|EMPTY|三欄空白，不能補畫角色|
|12|Death|HOLD|倒臥保持，三幀近似重複，不可以自動起身|
|13|Front Jump / Close Attack|ONCE|起跳→騰空前進→出招/落地，世界位移交由SBS|
|14|Ranged Attack I|ONCE|準備→瞄準→釋放，手肘變化；不要內建武器|
|15|Close / Ranged Attack|ONCE|起手→出招→回收；肩肘手與重心配合|
|16|Magi Skill Use|LOOP|原地施法，手部/能量微脈動；VFX分層，頭腳大致穩定|

## 18關節設計
`FACE`：NOSE、LEFT EYE、RIGHT EYE、LEFT EAR、RIGHT EAR；`AXIS`：NECK、LEFT SHOULDER、RIGHT SHOULDER、LEFT HIP、RIGHT HIP；`ARMS`：LEFT ELBOW、RIGHT ELBOW、LEFT ARM、RIGHT ARM；`LEGS`：LEFT KNEE、RIGHT KNEE、LEFT LEG、RIGHT LEG。左右側關節必須區別「人物的左右」與「畫面的左右」，先確認再設定位移。對RUN LOOP應鎖FACE/AXIS的原生45度方向，允許約1px自然上下起伏，左右腿與反向擺臂主導動畫。對Dodging與Damage才允許頭肩與髖部整體改變姿勢，但不應使人物變成正面或90度側臉。

## 必須先過的 Gate（不准跳過）
1. 選定動作列，標明 LOOP/ONCE/EMPTY/HOLD，逐格描述實際姿勢與播放順序。
2. 指定FS原版45度戰鬥F0來源與SHA，不可把Walk Right的90度步態直接當成SBS鏡頭。
3. 依原圖動作拆18關節F0/F1/F2，先完成姿勢比對表與免付費骨架／Silhouette預覽，並標記頭/腰/膝/靴的關節變化。
4. 對於RUN：確認三格40×40、總120×40，F0中立、F1/F2反向的左/右靴位置清楚，靴子/膝動作不得被衣襬遮蓋，頭與肩一致，無裁切、無武器；任何條件不符都禁止呼叫付費API。
5. 若本地局部像素/骨架工具可完成，就不使用付費重生成；若必須使用PixelLab，只准提交已有Approved Spec的一次生成工作。POST前記錄唯一lock、source SHA、pose JSON，回傳Job ID後只查詢狀態，不盲目再次POST。
6. 真實輸出三張PNG分別檢查「45度面向、角色識別、相反腳、動作可讀性、循環接點、裁邊」；`south-east` 參數不是角度驗收證據。
7. 以隔離的Tankentai SBS/VX實際跑0→1→0→2，留GIF/截圖/QA，全部過關才可以宣告FORMAL PASS，否則FAIL-CLOSED；不要覆蓋封版素材。

## 歷史失敗監控
A43側臉FAIL、A44偏正面FAIL、A45獨立旋轉臉角度漂移、A46骨架方向較穩定但F2交叉、A47頭穩定而步幅太大、A48改深度步伐但臉和腿發生不一致、A49混搭左右步幅不對稱、A50下半身鏡像仍有接縫和衣襬風險。

**人像先固定，姿勢再解構，局部重組優先。AI只負責執行已驗證的骨架，不負責猜測什麼是跑步。**

完整逐格圖解、JSON Pose Manifest和不付費的預檢程式，另附在當次使用者可下載的ZIP。