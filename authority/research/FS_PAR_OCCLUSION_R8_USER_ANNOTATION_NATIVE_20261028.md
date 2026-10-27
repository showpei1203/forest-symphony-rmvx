# Forest Symphony｜R8 使用者紅／藍圈 Occlusion PAR 驗證｜2026-10-28

**Status：R8 原生 VX 隔離 TECH PASS（兩輪×18張）；Semantic/Art Gate F HOLD；原封 505 Scripts Boot FAIL（既有 Harness #480）。**

## 最重要修正：使用者標註是強制約束
- 完整 Master Ground = SCENE21 544×416（原圖不改），輸出透明 PAR RGB 一律直接複製同座標 Master，沒有二次重新畫屋／樹／草。
- 依使用者 548×400 標註圖建立 8 個**紅圈強制納入**物件：RED_R01 屋右針葉樹；RED_R02 最右側針葉樹；RED_R03 左下外側灌木；RED_R04 左下內側灌木／立體石；RED_R05 下方偏左微小灌木；RED_R06 下方中右小植株；RED_R07 下方偏右綠色灌木；RED_R08 右下小植株。
- 1 個**藍圈強制排除**區：BLUE_B01 房屋門前石階。台階只 Ground，PAR Alpha=0。注意遮擋判定與通行判定獨立。
- 以 JSON 規範 `R8_USER_ANNOTATION_20261028/R8_USER_ANNOTATION_AUTHORITY.json` 建 registry（8條工程規則，物件ID/box/正負點/foot anchor/優先序）。
- **重要座標警示**：使用者截圖 548×400 且帶有不同色調，原素材 544×416；這次 bbox 為目視對位的近似標註（已視覺檢視位置），不是經像素配準的精確使用者真值。不能自動宣稱物件輪廓 Artist PASS。

## R7 基準失敗（先留證）
- 以紅圈中心每個約 13×13 方格抽樣，R7 原 PAR **0/8** 達到涵蓋門檻；藍圈石階原遮罩也包含非透明像素。以上是針對「標註中心格」的粗略測試，不代表 R7 在其他區域完全沒有遮擋。
- 原始檔 `R8_BASELINE_RED_BLUE_COVERAGE.json` 與 `R8_PRE_R7_LABELLED_RED_BLUE_COVERAGE.png`。

## R8 SAM2 8紅+1藍
- SAM2.1 Hiera Small CPU，對使用者正／反提示點+box分割 8個獨立透明物件，**小型物件不再因 foot_y 以下裁切而丟失**。
- R8 首次 RED_R07 綠色灌木 negative point 落在本物件上，只有7/8提示一致。修改 RED_R07 的 positive/negative points 後完整重跑，8/8 prompt consistency、8/8 seed 13x13 覆蓋通過。這只是提示一致性，不代表達成人工語義IoU標註。
- 使用者藍色橢圓遮罩具最高優先權；把R7 union含石階的717個前景像素歸零，且把**每一個獨立動態Sprite的藍區Alpha也歸零**，禁止動態切換再把石階顯示回PAR。
- R8新增前景Alpha 9,265px；R8合成PAR Alpha非零58,436px；藍圈中心0px Alpha。所有合成PAR不透明像素RGB與原 SCENE21原像素相同（逐位元實測）。
- 此數量證明有更多候選前景，並**不證明多出來的全部是正確前景**，ART HOLD。

## 角色四方向空間掃描（非原FS正式通行）
- 使用原FS K4 $001.png 4方向32×32真角色輪廓，搭配 R5 **隔離測試的假第三層通行地圖** 17×13（218個769候選走格）。逐個檢查8紅圈物件的 foot-z 深度及角色Alpha重疊。
- 屋右針葉樹 RED_R01：在樹後(13,3)的兩個姿勢最大約261個角色像素被候選mask遮住；前面(12,5)只有最多15px有遮擋衝突。故單一原生A/B在(13,5) 0px差不能認定樹未遮。
- RED_R02 前後都有重疊；RED_R03/RED_R06 有樹後重疊；RED_R04/RED_R05/RED_R08 只有測試格前方重疊（可能 anchor欠準或該物件處在外圈，仍待正式通行）；RED_R07 前後均有重疊。
- `R8_4DIR_FOOTPRINT_AUDIT.json` 與空間圖保存所有數值。這**不是實際四方向走路測試，也不是原始SCENE21正式 MapXXX 通行權威**。

## 原生 FS VX R8 20物件測試
- R7原12個候選 + 新增8個使用者紅圈 = 20個原像素 Alpha occluder sprite；靜態原HK PAR用一張 R8 合成Par1.png；動態使用20獨立按接地點Z排序源圖，不覆寫Ground。
- 原正式505腳本維持封版，正式Scripts SHA256 `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`。R8隔離複本保留其中504頁原始binary元組不變（HK#145、Animated#146、ISS#342原樣），僅**在隔離副本**停用原#480先存的Harness NameError並加一頁專用Adapter。**原封505全頁Boot仍FAIL，不能宣稱正式Runtime總PASS。**
- 同一原生 VX `Game.exe` 的 A1=HK static PAR / B=20物件depth sprite / A2=恢復HK; 每輪6站位×3=18張544×416截圖，凍結背景動畫/光影變動。兩輪不同PID獨立重播，共36張。
- 雙輪於 strict pixel threshold 0（任一 RGB 通道只要差1）得到完全一致：
  * RED_HOUSE_CONIFER（玩家13,5/NPC13,3）A/B角色區**0px**（這個站位本來無預期前方mask重疊；另有角色後方掃描證據）。需要再選更精準前景位置／走路，不能當人物遮擋語義驗收。
  * RED_FAR_RIGHT_CONIFER A/B角色區**313px**。
  * RED_LEFT_INNER_MICRO A/B角色區**307px**。
  * RED_BOTTOM_MICRO A/B角色區**463px**。
  * BLUE_STEPS A/B **0px**。
  * CLEAR A/B **0px**。
- 以上六站位 **A1=A2 各0像素差，A1/B非角色背景全部0像素差**。結果來自 `R8_FINAL_GATE.json` 與 native pixel `R6_PIXEL_GATE.json`。若以RGB threshold 5則前三非零站位數字311／300／452，不可混用不同threshold。
- 直接原生VX可顯示小物件遮擋的前後轉換，但**不代表每個小物件邊緣均切得正確**。

## 測試期錯誤與永久規則
1. R8-ERR-001：R7已把下方部分微型植被當作地面裁掉／未納入；紅圈8個seed全未達門檻，藍圈仍誤收。改為 user-red priority 物件、微物件保留全Alpha、user-blue hard excluded。
2. R8-ERR-002：首輪 RED_R07 negative point 誤設在灌木本體，prompt 7/8；調整成物件外反例點後再跑SAM2，8/8提示一致，保留完整紀錄。
3. R8-ERR-003：WSL Python的 `np.int64` 無法JSON serialize，在產出RGBA後報錯；修 JSON default conversion；仍不可把寫檔錯誤當成成功，修正後重跑驗證並落地JSON。
4. R8-ERR-004：沿用R7 Native capture器仍硬編碼15張，R8首次雖抓到18張但標成 FAIL；改為 `len(marks)` 與每輪站位×3，重跑原生Game.exe成功兩次、重新做pixel Gate。
5. R8-ERR-005：原生房側針葉樹前方站位(13,5) A/B差0，四方向掃描說明其它座標確有front/behind物件重疊。改善探針座標不能用單一0差異推論遮擋缺失或成功。

## Gate與R9建議
- Source color pixel exact：PASS。
- User RED 8個seed coverage / 8個prompt consistency：TECH PASS（非藝術標註真值）。
- User BLUE exclusion 靜態Par1 + 20動態sprite：PASS。
- 兩輪原生VX 6種情境 A/B/A 非角色背景不變＋回復性：PASS。
- 精確同物件 full pixel boundary、全部前景漏項、1px鋸齒/美術層級：ART HOLD。
- FS 真正式原生MapXXX第三層通行、玩家與多NPC四向真正逐格走路：NOT TESTED。
- 原地圖 Ground 動態Loop（ground10系列）、Light/Shadow與大尺寸 Map003 40×29：NOT TESTED。
- 第480頁Harness全頁正常啟動：既有 FAIL。
- **Gate F使用者人眼：HOLD**，沒有封版，不得改正式FS或另一對話正進行的地圖資產。

R9先：做「原標註圖 548×400 → 原始 Master 544×416」正式幾何配準與手標輪廓的獨立語義QA；修小物件完整度/foot anchors；隔離真FS對應通行 map 原生走路；再拓展 ground3 40×29與光影動畫。

## 文件位置
`E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027\R8_USER_ANNOTATION_20261028` 8紅1藍註冊表／SAM2遮罩PNG／QA JSON
`R8_NATIVE_FULL_MASTER/NATIVE_ABA` 第二輪18張；`REPLAY1_NATIVE_ABA` 第一輪18張；`R8_NATIVE_FULL_MASTER/R8_FINAL_GATE.json`。
可重跑程序 `RUN_R8_USER_ANNOTATED_TEST.cmd`；原始FS正式文件SHA全程未動。