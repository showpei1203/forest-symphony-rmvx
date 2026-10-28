# Forest Symphony｜R12 NEW_ELF_VILLAGE_001 新美術 Master＋14同源PAR＋原生VX｜2026-10-28

**STATUS：全新美術 Master 已實際生成、1280×928 Map (40×29)、14個同源PAR技術候選、2獨立Windows Game.exe×14真移動=28張照片，TECH PASS；Master精緻美術驗收Gate A、PAR語義、整場景漏項、Gate F全部 HOLD。正式FS專案SEALED未修改。**

## 一、本輪不是重用ground3
- R12 Master 檔：`R12_NEW_ELF_VILLAGE_001/MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png` 1280×928 RGB，已由**新圖片生成**取得，原產物1471×1069，裁切至約40:29比例並**最近鄰縮放**1280×928，保留獨立原檔；SHA256 `eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80`。
- 視覺內容：木石混構建築、教堂、房屋、噴泉、梯階、木橋、河溪瀑布、植被等。不是將K4原ground3移動拼貼；可與正式ground3作像素比較，原圖不相同。
- Master是**首輪藝術候選**，雖畫面細節多，仍需人眼審查：原畫的斜視/透視一致性、原生32px角色比例、1× pixel-crisp、是否因最近鄰縮放失真、路面/梯階是否能合理導航；本輪不可稱達正式美術Gate A／Art Gate F。
- Google Drive已儲存Master原圖與32px格線QA。

## 二、同源PAR候選 18→14
- 新Master作唯一 RGB 權威。SAM2.1 small CPU用人工候選ROI、正負提示點，切出18個候選物件；15個prompt consistency過關。
- 檢視遮罩 owner 衝突：A11_SE_TREES（prompt FAIL＋近91% overlap）、A14_NORTH_EAST_TREE（prompt FAIL／意外選到瀑布周邊）、A15_SOUTH_GARDEN_BUSH（prompt FAIL）、A17_MILL_SHRUB（與其他物件近99.7%重疊）**四組停止載入VX**。不再硬把錯誤遮罩當PASS。
- 剩餘**14個候選**：9個建築類、樹與噴泉、小型植被等，每個獨立`A##_..._PAR.png`，合成`PAR_R12_VX_SELECTED14_SOURCE_ONLY.png`。
- 合成PAR共**233,875 個Alpha非零像素，RGB全部逐像素等於原Master同位置**。這僅代表 same-source pixel 技術，不保證全物件邊界/沒有漏項。使用者後續將回饋 PAR，美術語義一直保持 `HOLD`。
- `R12_MASTER_PAR_COLLISION_4PANEL_QA.png` 同時展示新Master、14組遮罩粉色覆蓋、單獨透明PAR及候選通行格。也有`R12_SCALE_QA_32PX_ACTOR_4SPOTS.png` 真FS $001 sprite比例草圖（此張為PIL視覺稿，非Game.exe）。

## 三、獨立 Collision Compiler（不是直接把PAR全設阻擋）
- 40×29＝1160格；以人工幾何多邊形標出房屋占地、樹根、噴泉、深水、溪流與高低差，給地面預設通行。
- 候選 `769可走686格`、`768阻擋474格`。橋、台階刻意保留可走；灌木與其他微小PAR可以遮擋但不必實體阻擋。
- 程式 `r12_filter_source_par_and_collision.py` 產生 `R12_TILE_GRID_40x29.json` 與`R12_COLLISION_GRID_CANDIDATE_QA.png`。註記為**粗略的多邊形候選**，可能有牆壁/梯階過擋、跨樓層導航及漏實體格，不代表完美美術或通行Gate F。
- 為避免破壞`Map003`原25個Event的 Ruby Marshal object graph，**不使用有問題的 Python rubymarshal exporter**。透過隔離Adapter在原始Map003 raw binary完成載入後，只在runtime建立第三層候選格，保留原Map003二進位逐位元一致；工程可跑、候選`Map*.rvdata`**未輸出**，必須修真正確的序列化方案後才可正式成套移植。

## 四、原生VX發現重大錯誤及修復

第一次R12原生Game.exe測試雖然真行走14/14，**畫面是新PAR疊在舊ground3**，不是新Master！這輪被視為**R12-FAIL-001畫面不合格**，不准TECH PASS。
- 根因：FS舊Overlay/Ground讀取了 `ground3`資源Key，`@map.parallax_name`更新不足以改變已快取資源。先前標準只檢查腳本中source PNG hashes和角色pass，沒有驗證Game內實際載入的Master bitmap。
- 修復：僅於獨立測試工程，將新Master複製為`Graphics/Parallaxes/ground3.png`，作為舊腳本Key暫時別名（**K4原ground3不動**），同時輸出 `R12_ELF_VILLAGE_001.png` 正式候選檔名。
- Test Adapter在Game.exe記錄實際 `Cache.parallax("ground3").get_pixel(100,100)` RGB，結果**[3,22,18]**與新Master對應像素完全一致（舊正式ground3相同座標為[52,119,10]）。真正native Game.exe螢幕畫面亦人工檢視全村新地形一致，排除了混圖。
- 修後重建／重跑：`14/14 PASS`原生真Move Up/Down/Left/Right＋NPC移動/阻擋，第二獨立Game.exe重播也是`14/14 PASS`，共**28張544×416 native PNG**。
- 每張都有 Map camera display + R12 14物件第一個Sprite x/y，Fail Closed核對 `(-display_x/8,-display_y/8)`；各個測試場景通過；Source alpha 233875 px RGB exactly same。
- **臨時資源名稱別名必須正式修正**，不能將新村莊發佈時仍叫ground3，否則和正式既有地圖互相覆蓋。R12現在只是一個分離候選ZIP/隔離跑測。
- 新圖的 40×29 資料仍使用正式原Map003的25個Event作載入Binary，但R5 test Adapter仍清除這25個原始Event再新增NPC900；所以**這不是原本正式劇情Event執行PASS**。
- 遊戲畫面原有HUD/dialogue/暗色光層仍遮擋部分美術，故沒有乾淨的1×實機人眼Art Gate畫面。

## 五、其他 FAIL/修正記錄
- R12-FAIL-002：Wsl SAM2環境缺`rubymarshal`；把PAR與Collision alpha+grid步驟留在WSL；Ruby Marshal Map資產轉譯改由Windows獨立工具。起初Windows exporter觸發`invalid link destination: Object id 293 not yet unmarshaled`，刪除產生的錯誤二進位候選。現階段只用runtime in-memory inject; 資料來源／K4不動。
- R12-FAIL-003：SAM2 18候選中4個失敗／overlap，按清單剔除；完整記錄與候選PNG仍留作人工Par檢討，未偷偷修改Master遮錯。
- R12-FAIL-004：若僅看脚本日志14/14動作便PASS，會漏掉背景來源混圖問題。新增**GPU資產實際Cache bitmap pixel sample**以及native screenshot人工檢查；將此檢查加入R12後續嚴格Gate。

## 六、權威與下一步
- K4 Source正式505 Script SHA256= `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`，原正式Map003 SHA256= `118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4`。正式Data、Ground3、各專案另線地圖未修改。
- R12隔離Test Adapter仍有舊#480 pre-main NameError，於隔離副本停用原一頁、504原正式頁byte-exact，增加1 Test Adapter；不能宣稱未修改正式505頁完整Boot PASS。
- 後續優先：由使用者之後檢查PAR alpha／邊緣、補四個被淘汰物件及全地圖漏項；畫面比例／像素品質 Gate A；真正新MapKey檔名與可靠的`.rvdata` Map輸出器、連續移動＋多NPC／水雲Loop／LightShadow、乾淨HUD-free原生圖與長時FPS；最後使用者Gate F。
- 本輪每次修改都保留隔離術語，**NEW MASTER EXISTS, NATIVE TEST RUNS, ART HOLD**。