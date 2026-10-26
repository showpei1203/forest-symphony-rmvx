# FS V6 | Biome Style DNA + Asset Inventory 2026-10-26

狀態：STYLE DNA INITIAL / USER REFERENCE LOCKED / ART FAMILY NOT GENERATED。來源為本輪使用者親附 12圖；所有 raw image 留 Private Source，不同步到 Public Github。

## 共用 Style DNA（達到 user-reference 等級的最低設計語法）
高俯視3/4 RPG projection，角色1x現場尺度，畫面內 Macro 樹/屋/懸崖、Meso 花叢/石階/木柵、Micro 苔藓/花/土紋/落葉三層皆清楚。高精度材質有陰影方向但不洗成柔焦/糊成油畫；有自然不規則輪廓與密度高低差，不平均散播單一小花圖塊。絕不模仿圓形浮空地台和黑色背景作正式 Ground。Road 分叉與草/土/石交界都不出現 donor-box拼貼；屋前能行走、門/台階接地自然。

## Biome Samples / Golden References
SCENE001（木屋村／田園）：苔瓦/木屋頂、窗戶門階、井、路牌、木籬笆、木柴堆、木桶木箱、圓樹和草花，主木屋+中小物件互相呼應。用于 Village Hero/Secondary Building Family。
SCENE05（荒漠／邊境）：裂土細節、砂岩平台/枯樹/舊圍欄、少量器物和水坑，低植被密度但豐富紋理，不用草地代替砂土。
SCENE06（森林洞口）：連續厚草地、成群闊葉樹、石崖與洞口、少量野花，留大片可玩中央，根與牆壁依 Ground/PAR語義分離。
SCENE14（多層岩壁）：3D感卻遵守 topdown3/4 的懸崖頂面與垂直立面、階梯、邊緣樹群；Height Level/Foot/Bridge 必須先規劃，Ground只有水平頂面。
SCENE18（水晶地城）：冷藍發光水晶/黑石壁/水面反射、石橋和祭壇/雕像。動態水/光不是把四張完整地圖重新渲染成四張不一致場景；局部Effect ROI+一個靜態世界幾何。
SCENE21（神聖林地）：細膩苔綠石屋、樹、石階、野花和灌木，朝精靈村美術密度；用來做第一個 17x13 High-fidelity Visual Pilot。
ground3（正式大型可探索村莊）：1280x928 / 40x29，屋型差異、河岸/崖壁/商店/樹群和地形高度，世界級密度與變化，分多段場景/Camera scroll檢查，不限制於可視單屏。
ground10及_1..4：960x1280/30x40 動態場景。水/雲/霧畫素與同一Static Source，優先局部 RGBA 影格；shader或particle選用都不能降低風格與 pixel crisp。

## Source inventory 接下來必做
GROUND_FAMILIES：森林/荒漠/地城等水平底土; path straight/turn/junction; edge transitions; stone floor/paving; cliff TOP/water TOP; 地表稀草與落葉。每個家族試至少3x3 seamless，微細節與參考角色1x檢查。SOURCE assets 需保留連續已覆蓋的 Object Foot ground underpaint。
PAR_ARCHITECTURE：主屋與側屋、門/窗/屋簷/壁燈/階梯/井、同材質外牆，完整源邊界；2棟屋亦不可上下半材質改變。
PAR_VEGETATION：冠葉/枝幹/根/腳點分開 + 2-3變體、花叢，花可 walk-through，腳底 footprint 非整個 alpha。
PAR_TERRAIN_OBJECTS：直立崖壁/護欄/岩石/洞口/石階/橋；Height top及 collision 互不混用。
PROPS：箱桶、木柴、木籬/牌子、路燈/井/花圃等；裁切不丟掉附件。
HERO：祭壇、大樹、主屋、地城雕像等個別 Source+Mask+Foot+Owner+Z驗收。
DYNAMIC_REGION：水反光、流動水、霧、雲影、發光水晶；每種需要靜態世界座標、alpha/seam、節拍、z、fps與效能基準。

## 17x13 Pilot 最低視覺呈現（不是隨意數字的假通過）
A. 1個視覺焦點（主屋或神聖樹）、樹叢/石壁的宏觀層次、主要道路通行清楚。
B. 有多種 Meso（草花群、岩石、樹根、柵欄/井）及 micro（不同大小葉/花、苔與土顆粒），但每個 Source 都完整且自然落地。
C. 對 SCENE21 截圖做 1x、2x nearest 的 Reference-vs-Compiled 四格對照；Human reviewer 確認「精緻、豐富、自然」才是合格，QA 不能數湊多少 asset 就自封合格。
D. 先 Ground-only Art Gate；失敗禁止拉房屋/水域修飾。通過後才做完整 Source/前後遮擋/純地面預設可走/真Native VX。

## 維護
這個 P1 Style DNA 為AI建立候選方向，不假裝取得用戶 Human Art PASS；V6 P2 首個高質 Ground-only Source 仍未生成，F2 G5R4 花叢/地面僅是技術研究。世界最終 Layout/Placement 歸使用者。
