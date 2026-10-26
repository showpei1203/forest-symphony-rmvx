# Forest Symphony | V6 高精度大型地圖與動態 Ground 正式美術目標（2026-10-26）

狀態：USER TARGET CONFIRMED / ART PENDING / NATIVE ANIMATION PENDING。
此文件是 FS v3.2、Style-first v4、V5 Source-first QA 的新增目標與施工順序，不解除 SEALED，也不覆蓋正在其他對話開發的地圖。SOURCE ART quality 與 technical pixel QA 須各自過關。

## 1. 使用者指定之參考與分類
本次對話使用者提供 12 張圖：SCENE001(2)、SCENE05、SCENE06、SCENE14、SCENE18、SCENE21(3)、ground3(1)、ground10(2)、ground10_1、ground10_2、ground10_3、ground10_4。
美術 DNA：SCENE001 鄉村木屋和豐富小物件；SCENE05 乾燥荒漠與岩壁；SCENE06 森林洞穴入口；SCENE14 多高度石壁森林；SCENE18 深色晶洞/水與冷光；SCENE21 神聖林地/石屋/豐富植栽。各 Biome 保持各自色盤、光向、材質與尺度。
最終視覺要求與這些例圖同等級：主次明確的建築、植栽層次、多樣樹種、自然草土路、石造建築與崖邊、多種小物件、苔蘚/花草/葉片的細膩表現。圓盤輪廓與黑色背景暫時不納入正式成品要求。不可只用簡單拼貼 Tileset 或低精度程序色塊交差。Concept/Master 僅供風格依據，不可直接視為引擎 Ground/PAR 已完成。

Drive 原圖與合法素材索引：
https://docs.google.com/document/d/1aa9UjWLr7FP7-sGKChXJ26POtCZkQJRl19KAPh07PgQ/edit
來源資料夾：Forest Symphony/08_Assets/00_Reference_Original/01_Maps_Parallax/Ground（ID 1fARpYIVEn4T2-3Q5Zv6HOy5O3Ia9z6-1）
Full_Map_References（ID 1dzRwlr3Npz9zr-uX3fnE0bM-HaDGicqe）。
若權利不明，Private Reference/Research Only，禁止把原圖公開上傳 GitHub 或宣稱可以正式商用。

## 2. 最終世界尺寸
ground3：1280x928 px、32px 網格 40x29、共 1,160 格。村莊和野外地圖以這個完整世界量級作正式 Benchmark，可視需求繼續擴大；不能把此比例壓縮到 544x416 的 VX viewport。
ground10、ground10_1～ground10_4：960x1280 px、32px 網格 30x40、共 1,200 格，作大型動態水/地表範本。
SCENE001/06/14/18/21：544x416 px，作為 17x13 局部美術密度比較範本；SCENE05 544x418 多2px，只能當參考，不能不經驗證當整格 VX output。
遊戲原生 RMVX viewport 544x416；必須正式測 Camera scrolling、世界邊界與多場景移動，禁止硬縮房屋或物件湊單屏。
Actor 比例取實際 Game.exe / Actors.rvdata 與真角色 PNG 1x 判定，過往 Actor1 32x32 frame、28x32可見身形只是 F2 測量範例。Pixel-crisp 不 blur、不雙線性、不 subpixel shift；可核准的縮放採 nearest neighbor。

## 3. 美術 Gate 新增三層豐富度
Macro：清楚的 Hero/地形焦點，建築/樹群/石壁/洞穴/高低平台等輪廓與可探索性；具真實世界尺度。
Meso：房屋材料、屋簷、煙囪、井與花圃、道路轉彎、石崖起伏、不同種類樹冠、自然轉場、地景密度變化。不可有切斷的屋頂/樹/木樁、上下牆面不同素材、方形拼貼、明顯印章重複。
Micro：地面顆粒、苔草、小花、葉緣、根部、接觸陰影與拾掇小物件要清晰；不能以大量散亂素材掩飾 Source 缺損，也不得讓小細節淹沒玩家/遊玩通路。
每個區域交 Ground-only、物件 1x、2x nearest 與 native VX 對照 Reference；Human 視覺 Gate 有獨立簽核，0像素重組差只代表 TECH PASS。

## 4. 分層碰撞及來源基本 Authority 不變
Source-first，Ground 是連續的水平地表，草土路/低花全部預設可走；水、洞、懸崖缺口為可審計 terrain exception。完整房屋、樹、石、木樁、岩壁等屬有真正接地 Footprint 的 PAR Source，再獨立定義真實阻擋；上方樹冠/屋簷只是 Actor Occlusion，柔軟花叢即使在 PAR 仍可走。保持 Ground underpaint 連續、contact/transition shadow 分離。
遊戲最終布局 Geometry/Placement 由使用者核准。唯一 Scene Manifest 的 World XY/Foot/Z/Height/Hash/Mask 產出 Ground opaque、PAR_COMPLETE alpha、BASE、Actor Occlusion、Pixel Owner、Collision、Events、Tiled/Godot/VX adapter。不得獨立生成兩張互不對位 Ground/PAR，也不動封版 FS runtime。

## 5. ground10 動態基準與現有腳本
從遠端 FS 專案真實 Scripts Export 確認：
- 現行 Animated Parallax 2.1（modern algebra），會依 filename 後綴 _1、_2、_3... 自動循環。ground10_1 才是應採的動畫開頭；無後綴 ground10 不能自動混進同一系列。
- 此專案設定：Map 10 每 40 frames；Map 8 每20 frames；預設每30 frames，資料以60 FPS計。MAAP_PRELOAD_PARALLAXES=true。既有 FS_LegacyScripts_SafetyPatch v1.0.14 修正過幀長0與誤 Dispose cached Bitmap。
- 真 Windows Graphics/Parallaxes 來源經RGBA逐像素稽核：ground10_1～_4 除左下動畫 Region 外完全不變。原動畫變動 BBox 可包在32px整格 ROI (x0,y0,x1,y1)=(0,928,640,1280)，尺寸640x352。
- 靜態 ground10_1 加上逐張 ROI 之四張重組，四個 Frame 全部 RGBA 0 diff；不正確影格負向測試檢出91,656個差異像素。
- ground10_2、ground10_4 decoded rgba 完全相同（PNG file SHA不同是編碼差異），所以保留四影格時序 1→2→3→2，但可只儲存 3 個獨特局部 Texture。
- 無後綴 ground10.png 與 ground10_1 在動畫 ROI 外另有約8,733個像素差異，嚴禁未驗證就當作可互換的第0幀。
- 理論未壓縮RGBA：4張960x1280全圖=19,660,800 bytes；1張Static＋3張640x352 ROI=7,618,560 bytes；少61.25%。這是素材資料量推估，並非宣稱 FPS、VRAM 或原生播放速度已提升。

動畫兩種選擇：
A（baseline）既有 Animated Parallax v2.1 + SafetyPatch，以原始四影格在隔離原生 VX 實測兼容、frame timer、相機、事件；
B（candidate）單一 static Ground＋局部 ROI Sprite，timeline [0,1,2,1]，畫面外 Region 可裁切顯示，不改 Game Time；底層水深度要正確，PAR、角色及遮擋依 Scene Manifest 決定。對雲、霧、光影建立獨立有 alpha 的 effect region 與各自 z/scroll/speed/loop，禁止用整張背景對付每種動畫。若使用 B 必須將靜態 Parallax 指向測試用不含 _1 suffix 的圖片，避免與現有自動循環雙重觸發。

## 6. 獨立施工階段與止損門檻
V6-0（已執行）目標鎖定：12圖 Style Reference、來源索引、ground3/ground10真像素尺寸、現有播放腳本與來源SHA；保持 sealed readonly。
V6-1（接下來）分6個Biomes設定各自 Style DNA、asset family inventory、Macro/Meso/Micro 視覺 QA、授權、提示詞合約與 1x actor source scale；先建立 style goldens。
V6-2 高密度最小場景：先 SCENE21 神聖森林 17x13；全新 Ground-only（草/路自然密度）先過 Human P2，之後一棟完整石屋、一樹、完整花灌木、石牆與 contact blending；ART 不過不准進完整場景整合。F2 G5R4 320x256只是 source alpha/scale pilot，不可交當最終美術。
V6-3 17x13 的真 Tiled/VX/Godot Source-first 同源編譯、嚴格RGBA、1px Negative、玩家腳點與落地 collision、屋前可走格、上下層互動。
V6-4 正式 40x29/1280x928 村莊或野外：延展已視覺通過之 asset kit，不偷用長方形 donor patch；Camera Scroll四角/中段、密度一致、合理世界動線/建物尺度。
V6-5 動態地圖：ground10 的30x40/960x1280 使用 Mode A 成立後，再在隔離 Game.exe 對比 Mode B；要核對100%/200%原生畫面、相機跟隨ROI、動畫路徑、PAR遮擋、場景切換、30分鐘記憶體與起碼10分鐘播放。不能無憑宣稱性能提升。
V6-6 封版前：Gate A-F、source/rights、人工美術、原生 VX 実機及 Godot adapter、冷解壓 ZIP+CMD+LOG+SHA/CRC讀回、Drive/GitHub/Linear與CURRENT_HANDOFF一致。

## 7. 保留負向案例與本輪狀態
Ground blur、v2.5 donor quilt道路、房子屋頂被切、上/下材質不一致、木樁缺角、角色巨大花、門前碰撞錯誤等已知 FAIL 不得因 source 0diff 冒稱 PASS。
F2 G5R4 目前有 Ground Source crop 與 Flora Alpha 研究素材，但都還不具備本次「高精緻度 final reference」的藝術驗收。
本輪狀態 V6_ART_TARGET_ACCEPTED / MAP_40x29_NOT_BUILT / HIGH_FIDELITY_VISUAL_PENDING / ANIM_REGION_STATIC_RGBA_4_OF_4_PASS / ANIM_RUNTIME_NOT_TESTED。

隔離輸出：E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261026
FS GitHub 正式 Authority 位於 authority/handoff；計畫同步至 Linear SHO-39。