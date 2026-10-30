# Forest Symphony｜GROUND-ONLY PIPELINE v2.0｜正式執行規格
制定日期：2026-10-30｜適用：精靈村 Ground-first 測試線｜文件性質：待實作規範，不代表美術 PASS
實作狀態：SPEC_READY / GROUND_ART_FAIL（沿用 R1–R3 最新結果）/ PAR_NOT_STARTED / FORMAL_SEAL_NO

## 0｜目標與先決原則
目標：先獨立創作一張真正只有水平地表的高品質 GROUND.png；等 Ground 美術、語義與座標驗收通過並鎖定 SHA-256 後，才以同一 Blueprint 與原圖條件製作獨立透明 PAR 來源。絕不從已含房屋、樹木的 Master 逆切 Ground／PAR。
本規格以使用者提供的 14 頁《Forest Symphony 精靈村 Ground-first → PAR 生成流程可行性研究》及 R17 Stage12／Stage13、R0／R1–R3 的負例為依據。原 FS/K4 SEALED、正式 Map.rvdata、Scripts.rvdata、Collision、Passability 不得修改。
核心改善：R1–R3 已證明「道路座標／連通／SHA／接縫指標 PASS」不等於「ground3 級美術 PASS」。v2 必須先解決地表素材品質與整體構圖，不能只換拼貼演算法。

## 1｜正式輸出與所有權契約
第一階段唯一必須完成的美術成品：GROUND.png，RGB、PNG、544×416、原生 1×、與 Blueprint 同一像素座標。
GROUND 允許：水平草地、苔蘚、泥土、自然起伏的顏色過渡、平面碎石及石板路、低矮貼地小花草、落葉、已存在地面的磨耗與環境色差。一般貼地植物參考範圍高 6–18px／寬 8–28px；較大低植被群高 18–28px／寬 20–40px 必須列入白名單，不能長成屋寬三分之一大小的灌木。
GROUND 禁止：房屋、屋頂、門窗、完整樹木／樹冠、直立樹幹、木樁、木桶、柵欄、燈、招牌、井、桌椅、突起石柱、岩壁、會擋住角色的立體植被及未來 PAR 物件的烘焙陰影。可容許的平面碎石，不等於立體巨石。
PAR 物件在 v2 Ground Art PASS 前一律 NOT_STARTED；不准用舊 PAR 疊新 Ground 假稱配對成功。
樹底 32×32 接地樹幹之既有使用者權威不擅自刪改：純地表 GROUND 初版不畫任何樹幹；待核心 PAR 階段另設完整樹在 PAR 的 A 方案與「創作階段將最底接地 32px 放入新 Ground 分支」的 B 方案。B 需重跑 Ground Art Gate，絕不能由完成 PAR 事後裁切或覆蓋鎖定 Ground。這是尚待 A/B 驗證的相容性問題，不是 v2 已改規則。

## 2｜固定 Scene Blueprint：A 精靈村主街
CANVAS 544×416（17×13 個 32px 網格）；正交俯視偏 3/4，不要等距菱形透視；光源左上；色盤依 FS SCENE21／ground3、A2_VSCliff、TileB／D／E 原始私有來源。
世界錨點：House A 門口 (144,208)；House B 門口 (400,208)；Sacred Tree 樹根 (272,304)；中央路口 (272,240)；西 (0,240)、東 (543,240)、南 (272,415) 出口。
PAR 預留 region：House A [72,72,200,224]；House B [344,64,472,224]；Sacred Tree [208,184,336,352]。預留是「未來立體物件的佔位規劃」，不是塗白空地；下方仍須有完整合理草地／地表。
接觸區：House A [132,200,156,224]；House B [388,200,412,224]；Sacred Tree [248,288,296,328]（邊界座標視為半開區間）。
關鍵衝突：樹根位於中央向南的通道上，路徑不能直穿樹根後又聲稱樹根未鋪石。南向主路須自然繞樹根接地範圍兩側，再於下方匯回南出口；可有自然接近樹根的支線，但根部接觸區不可被石板佔據。門口需有視覺連續的道路與可站立的前方空地。
角色測試使用正式 FS 32px 角色 1× 對照；任何布局變更均須寫入 Blueprint 版本，不可只改 prompt。

## 3｜分區遮罩：先定義地表，再呼叫生成
以程式或編輯器製作同尺寸 544×416 的可審查 mask，RGB/灰階 8-bit PNG、0/255 範圍、世界座標不動，並儲存 source hash：
01 ROAD_MASK：道路核心、石板主體、門口接路與繞樹根的雙側通道。
02 ROAD_EDGE_MASK：不規則石土草過渡，不可由高斯模糊或線性縮放冒充 pixel-art 邊界。
03 SOIL_MASK：土壤磨耗、泥路、色差與草地破碎區。
04 GRASS_MASK：連續水平地表基底。
05 FLORA_MASK：低矮花草許可區，避開主路中心與角色落腳區。
06 RESERVED_OBJECT_MASK：House A/B、Sacred Tree 的未來物件規劃範圍；禁止立體物件，不要求去除天然地表。
07 ROOT_CONTACT_MASK：樹根精確接觸限制，用於驗證石板不得穿越。
08 FORBIDDEN_STANDING_MASK／SEMANTIC_LIST：禁止出現的直立物件類別與人工巡查區。
各 Mask 以 machine-readable scene_blueprint.yaml 描述 owner、priority、anchor 與例外。交疊優先序：禁止物件 > 樹根接地限制 > 主要道路 > 道路邊界 > 土地／草地 > 低植被。
先在不含任何生成圖的純色 Layout Preview 證明 Anchor 路徑可達、路口不與樹根矛盾，才進入素材生成。

## 4｜原始地表素材庫：最小 13 件
產出四類獨立 bank（各自保留原生來源和授權）：
GRASS ×4：暖草、陰影草、苔蘚草、較疏草；每款需有足夠 1× 細節與多種微觀紋理，不能僅一塊32px tile。
COBBLE ×3：暖灰不規則石、苔石、磨耗／碎石過渡；不可出現方正棋盤路。
SOIL ×3：淺棕泥土、暗濕土、草土漸變。
FLORA ×3：白黃低花、淡紫小花、低矮地被植物；每個來源需清楚區分真地表與高草／立體灌木。
生成提示詞只描述「overhead pixel-art FLAT TERRAIN MATERIAL / horizontal ground surface texture, no scene, no props, no upright objects」。避免使用 forest village scene 等容易誘發樹木與建築的整景語言。若引擎支援 img2img、layout/ControlNet/mask，優先提供專案色盤、同視角與禁物件 mask；文字禁止詞只是輔助，絕不是像素級保證。
素材品質 Gate：原始尺寸和裁切位置可追溯；不含直立物件；精細度與 ground3／SCENE21 原生像素一致；禁止模糊／筆刷油畫感／影像插值／虛假透明棋盤。若生成圖有高物件，只能引用經人工檢查、真正純地表的局部素材，不能把整張高物件場景冒充 Ground。素材從大圖取用時採 1:1 原像素裁切；不能任意縮小後稱為真正像素美術。
來源不足時先補 bank，不要急著編譯整張 Ground。第三方圖授權不明時僅限私有研究，不公開上傳 GitHub。

## 5｜合成引擎：連續地表而非重複補丁
第一層以多尺度、具高度細節的草土地表連續鋪底，增加非週期性區塊紋理與微地形感。
第二層依 ROAD_MASK 選擇原生石板來源，讓石板結構沿道路方向、曲率與寬度變化，不按固定32／49px切塊重複排列；與土草接界需有原生可追溯的破碎邊、縫隙苔蘚及短距離視覺過渡。
第三層依 SOIL_MASK／ROAD_EDGE_MASK 加入土壤磨耗、碎石、草苔侵蝕、輪廓不規則變化，禁止平滑濾鏡掩飾明顯切邊。
第四層依 FLORA_MASK 放置低花、野草、落葉；按道路邊緣或草土變化自然成群，不按固定格點平均灑點，也不能讓花草取代完整場景層次。
合成只使用 native pixel ownership；任一世界像素的 Ground 材質 owner 必須能從來源及 mask 追溯。局部 texture quilting、graph-cut/min-error seam 可作細部手段，但 R3 的 seam ratio 1.0526 已證明「接縫指標合格 ≠ 美術合格」。要新增重複圖樣／材質斷裂／道路生硬等美術檢查，不用同一片來源反覆 stamp 來湊滿畫布。
所有真正立體的接地陰影等 PAR 專屬效果，保留到後續獨立 effect/overlay 候選，不得在尚未生成物件時猜位置並烘焙進鎖定 Ground。
輸出不許 resize 模糊；如生成尺寸不等於 544×416，必須透過事先規劃的原像素裁切或明確 pixel-quantized 處理驗證，不得假裝比例與像素尺寸一致。

## 6｜四個獨立 Ground 候選與回退邏輯
在同一 Blueprint 與相同道路／門口 Anchor 下，製作 G1–G4 四個確實不同的地表來源配置：G1自然暖草、G2苔石微地形、G3疏密花草、G4低飽和土草。四版本須有實際 source-material／layout microvariation 差異，不能僅換顏色或將同一圖片裁成四張。
每一版本都輸出：GROUND_Gx.png、terrain masks、source manifest、1× 真像素預覽、2× nearest 預覽、含32px角色對照及 Door/Root 局部放大圖。
每版先跑 Tech Gate 再跑 Art Gate；若四版 Art 都 FAIL，停止製作 PAR，依明確類別退回素材銀行、道路合成或 Blueprint，不能挑「比較不差」的一張當 PASS。

## 7｜QA Gate：一項不過不得晉級
G0 Blueprint：尺寸／錨點／接觸區／路徑繞樹根契約完整。任一衝突 FAIL。
G1 Source purity：13 個素材 bank 個別 Art 與語義檢查。任何直立樹、木樁、柵欄、岩壁、立體石柱或房屋殘片 FAIL。
G2 Ground technical：Ground RGB PNG 必須 544×416；Mask 同尺寸；Source/Prompt/Blueprint 各自 SHA-256；門口、交會點及三出口皆連接於可到達的道路網；ROOT_CONTACT_MASK 內不得含不允許的石板；沒有二次縮放、鋸齒邊緣污染及可疑行列條紋。故障注入 1px／16px 錯誤必須被攔截。
G3 Ground semantic：畫面任一範圍沒有禁止的直立物件。自動辨識只作候選提醒；顏色／高對比直線檢測無法證明高物件完全不存在。需對真 PNG 全圖逐區人工核對，包含邊緣、地表群、石板與預留區。
G4 Ground artistic：Macro 構圖、Meso 石草土過渡／地勢與生態層次、Micro 清晰細節、32px角色尺度、與 ground3／SCENE21 風格一致性五項逐條 PASS。禁止大片單色草皮、整齊貼圖道路、方形裁切痕跡、重複印章紋理、過大的地面植被。數值 seam score、hash zero diff 不能取代此 Gate。
G5 Human Gate：提交原尺寸 Ground 與 QA 對照給使用者審查；未明確核准為 HOLD，不得自稱 ART PASS，不得開始 PAR。
G6 Freeze：獲 G5 PASS 後鎖定 GROUND.png、Blueprint/Mask/Source hashes、model/version、seed（僅輔助）、生成日期、QA log。此後 Ground 不可靜默修改。後續修改需建立新分支重跑 G2–G5。
只有 G0–G6 全部 PASS 才能進 PAR Phase P1。

## 8｜交付結構與可重建性
GROUND_ONLY_V2/
  00_contract/scene_blueprint.yaml、style_lock.md、reference_hashes.json
  01_masks/ROAD_MASK.png、ROAD_EDGE_MASK.png、SOIL_MASK.png、GRASS_MASK.png、FLORA_MASK.png、RESERVED_OBJECT_MASK.png、ROOT_CONTACT_MASK.png、FORBIDDEN_STANDING_MASK.png
  02_source_banks/grass_01-04、cobble_01-03、soil_01-03、flora_01-03（來源檔／metadata／rights）
  03_scripts/build_ground.py、validate_ground.py、negative_tests.py、RUN_ALL.cmd
  04_candidates/G1-G4/（各版 Ground、source ownership、1x／2x／Actor QA）
  05_review/ART_CHECKLIST.md、FAIL_CASEBOOK.md、COMPARE.png、review_status.json
  06_release/（僅 Art PASS 後出現）GROUND.png、manifest.json、QA_RUN.log、SHA256SUMS.txt
  CURRENT_HANDOFF.md
本規格需保持每一階段可重建、可追查來源、失敗截圖、負向例、下一條 NEXT_COMMAND。ZIP 需可冷解壓且由原始素材重編譯相同 PNG；GitHub 放規則／程式／不涉授權的 log；私有圖片和完整 ZIP 放授權可用的私有 Drive，完成上傳後才可宣稱備份成功。

## 9｜失敗分流／禁止事項
SOURCE_FAIL：bank 含立體物件／模糊／像素尺度不符 → 重生該素材，不重新生成整個場景。
LAYOUT_FAIL：路穿樹根／門口不通／主路過窄 → 改 Blueprint 和 mask，重驗。
MATERIAL_FAIL：草地單調、道路整齊、貼圖接縫、石板風格不符 → 改來源及合成方法，不能靠後製 blur。
SEMANTIC_FAIL：藏有樹冠、木樁、圍欄、突起岩石 → 禁止以錯誤 Ground 進 PAR；回素材 owner 溯源替換。
ART_FAIL：技術過關但不漂亮 → 保留負例，重新評估構圖與 source style，不能改判 PASS。
不要進行 Master-first → segmentation 逆切，也不拿 Stage7 既有 PAR 拼貼；不要在 Ground Art 未通過時製作 House A/B、Sacred Tree PAR；不要自行動正式 FS/K4 Map、Scripts、通行度；不要把 PNG hash 一致說成美術正確。
首輪 v2 的成功定義：至少一張 544×416 Ground 通過所有 G0–G6，且沒有高物件污染。只有此時才進入 PAR 三核心物件接地試驗。最終正式 1280×928（40×29 tiles）須獨立規劃真正大型可探索世界，不能放大 544×416 再補邊冒充完整地圖。

## 10｜下一個執行指令
NEXT_COMMAND：
先讀取 FS 原始私有 SCENE21、ground3、A2_VSCliff、TileB/D/E，記錄版本與授權；
依第2節校驗 Blueprint 的道路與樹根衝突；
輸出 8 張真 Mask + 帶 Actor 的純色 layout preview；
只生成／收集第一批 13 件地表 bank，單獨做 G1 Source Art 驗收；
開始 G1–G4 前，必須證明 bank 的原生美術品質已達標；
不要先做 PAR。
