# FS R13｜PAR 遮擋格 Authority v1.0｜2026-10-28

## 正式核心原則
**Ground = 原始完整美術母圖，不刪任何像素。PAR = 原圖中在 32×32 世界格對角色產生視覺前景遮擋之元素，所有非透明像素必須來自 Ground 同座標。Collision = 真正實體碰撞獨立編譯，不能因進PAR就阻擋。**
優先判斷「角色站在格子時，格內哪些立體像素應該遮住玩家」，而不是依物件類別、體積、SAM2 面積門檻或僅依「物件接地點以上」自動裁掉。
重要：格子是**遮擋判斷／補漏單位**，而不是宣稱整格的泥土、道路一定要不透明。必要時可以先將整格標成候選，於 source-pixel 同源修正過遮；絕不重新生成PAR。

## 絕對包含（Include）
1. **樹木／針葉樹／灌木樹**：整棵冠幅、枝葉、樹幹與樹的可遮擋部分都須納入PAR；**只有明確的接地樹幹底部那一個32×32格**可以作 Ground-only 例外。不得用foot-y水平整排截掉樹幹；樹跨越幾格就檢查所有幾格。若底格混有樹冠/枝葉，只排除「接地樹幹底」像素，不隨意排整格。
2. 房屋/屋簷/牆面/突起煙囪/屋前立柱及棚架、拱門，若可能在角色後方形成遮擋，均列PAR；門前平面台階/地磚不列PAR。
3. **路燈、火把、燈柱、招牌、欄杆、圍籬、柵欄、橋樑扶手、橋側上緣、石牆立面頂緣、噴泉上半部、雕像**，凡向上立起、有視覺遮擋者，一律列入候選清單，不因窄或只有1格而忽略。
4. 小型獨立石塊、直立花叢、高灌木及地上裝飾物，如會遮到腿或軀幹也進PAR。
5. 使用者紅圈/紅標指定：即使模型分類有疑問也**強制列為遮擋候選**，必須保留調查及候選Mask，不可默默排除。

## 排除（Exclude）
1. **道路、平面草、地面花、地板/磚、平面石階、棧道/橋面、水面、洞/地表紋理**：原則 Ground-only，若有直立邊欄則另以PAR處理。
2. **樹接地樹幹底格**：只排除底部真正貼地的樹幹；不是把整個底格也可能在內的其他前景植物都排除。
3. 使用者藍圈/藍標：Ground-only 硬排除；優先級高於模型、置信度、全格自動補漏，但只排除指定實際結構，不粗暴排旁邊欄杆。
4. 假如人不可能走到物件後方，仍保留語義/Collision紀錄；不要把該物件完全消失當成正確，PAR是否顯示取決於世界深度與玩家可到達格。

## 32×32 實作契約
- Map尺寸：40×29即1280×928；Tile(x,y)的範圍 [32x..32x+31,32y..32y+31]。一個Tile可含多個不同物件 owner，也可同時有Ground-only和PAR pixel；二元 TileInclude 只作候選索引。
- 可視化輸出 `PAR_TILE_REGISTRY_R13.json`：每格可含`include_categories`,`object_ids`,`exclude_regions`,`uncertain`,`alpha_coverage_px`，所有漏遮欄位每次通報。
- 第一階段以人工標注 ROI+SAM2 exact mask，**第二階段做必覆蓋 32×32 tile 的 Source pixel rescue**：樹體跨格、窄燈柱、欄杆、石牆邊緣；絕不可因SAM2局部切到一半就視為完成。
- 首先確保每個應遮擋格**有實際RGB同源候選PAR像素**；其次針對同格地面誤收與角色前方過遮做分層修正。不能以 `alpha>0` 單一門檻當完整美術Gate。
- PAR 像素RGB源自唯一 `MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png`，不可獨立重畫、模糊、抗鋸齒縮放/插值；PX exact 是必要非充分條件。裁切後RGB source exact可自動驗證。
- Layer depth / foreground vs actor front-back 需在原生VX做實際 actor foot depth 與動態NPC檢測；靜態全圖PAR只是替代後景檢查模式，不能推出「不會蓋住角色前方」。
- Collision遵守Ground預設可走/水、洞、固體物件例外，樹全PAR≠樹全部區域不可走。

## Gate R13 A-F（Fail Closed）
A. Source：原 Master SHA-256/尺寸/無新圖重畫。PASS需PNG及SHA。
B. Registry：**全場掃描**屋頂、樹冠、每根燈柱、欄杆/扶手、獨立微型物件。任何未註冊的候選必須計為待補（HOLD），不能14個入選就假裝全場完整。
C. Same-source：PAR全部非透明pixel RGB=Master同座標；藍排除/樹根底格可視審核；將所有 include tile 的像素與 32格碰撞別分開輸出。
D. Static/Dynamic：每個物件有足點與Z；單格里多件可有不同owner；不能單一 global bitmap強制遮住所有玩家在前方的情形。
E. Native：至少3攝影機區域、前後左右4方向、障礙與通行、NPC走前走後、A1/B/A2背景不變與復原性；大型場景支持捲動、動態水/光影另行驗證；任何錯誤標 FAIL。
F. 人工：使用者看原圖、PAR紅色覆蓋、透明PAR、VX角色站位，補漏/過遮回饋後才可 Artist PASS；**使用者說後續檢討，所以本輪必須保持 HOLD**，即使 Gate C passes。

## 問題歷史要納入回歸
- R7漏8紅/藍階錯收、R8不足small occluder、R9邊界模糊；R12 SAM2只有14 selected/18，樹切斷、樹根水平遮罩截掉、欄杆/燈柱漏項。
- R12曾有新PAR疊在舊ground3、只靠movement gate誤判；必須保護 native actual Cache source pixel驗證。
- R13不覆寫R12既有PAR，產生全新`PAR_R13_GRID_LOGIC_SOURCE_CANDIDATE.png`等，保留R12對照數值。
- 所有新增內容先記錄失敗、保持隔離、上傳Drive/GitHub Authority，再編譯native；不得宣稱未測實機已通過。

**這份規則生效於R13候選研究線；正式FS SEALED不變。**