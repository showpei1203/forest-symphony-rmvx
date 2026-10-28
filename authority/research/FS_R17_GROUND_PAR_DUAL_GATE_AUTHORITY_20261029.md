# FS R17｜高密度精靈村 Ground+PAR 雙目標 Benchmark Authority v1.0
更新：2026-10-29｜開發線 R17 獨立候選，正式 FS、K4、R12–R16 全保留
STATUS: 研究規則已建立，**沒有任何藝術 Gate F 被批准。**

## 研究問題（不得偷換）
能否創造一幅**ground3 級美術細緻與豐富度**的 544×416 (17×13, 32px) 精靈村高密度街角，
同時輸出：
- `GROUND_FULL.png`：與最終美術 MASTER 完全相同、**包含所有可見物件**的完整場景，用於 FS 原 parallax mapping。
- `PAR_TRANSPARENT.png`：僅包含角色走到其背後時必須遮擋之立體物件原色像素；**透明背景、不能混入貼地地板**。
- `LIGHT` `SHADOW` `LOOP`：涉及時分別輸出，不把陰影黑邊和泥土誤交給PAR。
- `OBJECT_REGISTER.json`：全物件世界座標/foot Y/屬性、Alpha 和碰撞幾何獨立資料、可追溯來源與擷取信心。
- `ACTOR_FRONT_BACK`：FS 32×32 角色的前後遮擋，先 Godot 視覺，再 VX Game.exe native。

## 三條製作方法，同題對照且不得虛構未執行項目
**A Pair Generation**：同一張場景Blueprint讓生圖模型分別生成「完整場景」和「透明前景」，兩者經同源坐標檢查。若本輪沒有能輸出準確單獨 transparent object 的真正生成服務，標 `NOT_RUN`，不能拿程式複製 Master 冒充 AI 雙生。
**B Master-first constrained Layer Proposal**：以同一張細緻 Master 為唯一 RGB 權威，局部SAM2/GrabCut/人工 Mask 提案、全部在 native 像素座標，強制 source exact RGB；不靠全格補洞，不允許 Mask 自帶地板。
**C Separate Object-first Continuous Plate**：不是 2–4塊草地tile覆蓋整圖，而是完整細緻**無烘焙立體物件**的連續 Plate，加同風格、同光向的乾淨 RGBA 原生物件；透過 Godot 場景 source layers 同坐標雙匯出。若 source plate 原本已有烘焙房屋/樹，C 必須標 `CONFOUNDING`，不能宣稱分層精確。
三流程的 Ground+PAR 必須**同規格**、不能比較美術來源毫不相干的漂亮照片與粗糙tiles後說已證明勝負；資料不足的 Gate HOLD 而不是任意評高分。

## 固定 544×416 場景需求
- 1棟精緻主屋，完整屋頂/門窗/基座，透視Top-down 3/4。
- 3棵視覺差異明顯的立體樹（大冠、細長針葉、枝葉外擴），整棵樹進PAR但**只排最底一個32×32接地樹幹格**。
- 一盞窄路燈；一排欄杆、柵欄或扶手；彎曲自然石板路/泥路。
- 花、草、小石頭、欄杆端點、陰影、建物與地面交接等精緻環境細節，不能重複2種地面tile就交差。
- 至少3個玩家測試站位：樹後/前、屋後/前、細欄杆/燈柱前後，Actor32px真影格。
- **畫面不得出現大尺度細線、接縫、色彩漂移、比例失衡、重疊假影、物件截斷**。

## 永久禁令
1. 禁止使用32×32整格alpha rescue：tile是語義/碰撞坐標，不是PAR像素輪廓。
2. 禁止讓地面或任何貼地陰影污染PAR。樓梯平面、橋面、地面陰影、草路/花鋪地都不進PAR。
3. 禁止以少量tileset拼出低細節地面冒充本題美術完成。
4. 禁止把一張完整Master和獨立生成、不對位的PAR疊出兩層假PASS。
5. 禁止將 `Ground完整 + 同源PAR → 無人物重合0px` 視作PAR語義合格：它**可以在Mask亂切時依然0px**。
6. 不許以 SAM prompt PASS、OpenCV跑通、cache source RGB exact、Godot能載入、原生人物能走就說Art F PASS。
7. 禁止覆寫K4 Scripts505、正式ground3、原Map003或其他對話分支。
8. 不得把未跑的A、Qwen、SAM3、PixelART、LayerDiffuse完整diffusion稱作已完成。
9. 產生美術/Source Assets應按許可與授權記錄，第三方雲端上傳私人FS圖先取得允許。

## R17 Gate 雙軌｜Fail-Closed
### G-Art 美術硬條件
- ART-1 完整地圖的視覺清晰度與ground3及使用者精靈村參考對照，非平鋪/無細線接縫。
- ART-2 屋、樹、燈、欄杆的透視一致與素材融合（不能像貼紙），1×源像素密度。
- ART-3 三棵完整樹、1主屋、路燈、欄杆、自然路徑及小物都有，而且不破碎/不缺角。
- ART-4 使用者主觀圖像驗收必須通過；未審即HOLD。
### G-Mask 技術硬條件
- MASK-1 PAR Alpha非零原RGB每像素 = Master相同座標，嚴格0差。
- MASK-2 Ground-only負向語義區：Alpha必須0（不能只抽查空地5格就認定全圖純淨）。
- MASK-3 立體物正向語義像素無漏件；樹冠完整、路燈1px輪廓不斷、欄杆/扶手全包含。必須有gold/ref人工標註，沒有標註HOLD。
- MASK-4 樹根只排除最底接地1格，不要在接地位置下方全裁切；接地陰影留Ground/Shadow。
- MASK-5 每個不同物件可有不同Foot-Y、Z/depth，不能全圖同一PAR永遠在角色上方。
- MASK-6 512×384等不同尺寸即FAIL；這個測試鎖544×416，32px tiles 17×13。
### G-Engine
- GODOT-1 解析尺寸同源，Preview與FULL source pixel差異0，並驗證物件本身的前/後遮擋（不是只在看不到人的位置）。
- VX-1 Game.exe原生腳本/角色走動/碰撞/相機/A-B-A 前後景/光層影層（用到才測）。
- Native VX 不是必須在每個AI art candidate上全跑：通過G-Art候選後才跑以免浪費；未跑標HOLD。

## 對照評分（只在硬條件全部PASS才計通過）
- 整體美術30；地面細節豐富20；PAR純度20；細物件完整10；世界坐標重建10；實機遮擋10。
- 85/100是必要條件、非充分：硬 Gate 任一FAIL不能PASS。
- 量測透明PAR面積大小不代表進步；大面積也可能地板污染。
- 各版本須記錄實際Master SHA、原生尺寸、來源生成方式、是否真GPU/native VX及FAIL序列，才可比賽。

## 施工順序｜禁止跳關
0. 鎖已有R12–R16權威與SHA，建立新候選資料夾，留User參考/美術合格目標。
1. 從 R12 精緻場景提取**代表性544x416參考片**作B基線並檢查內容是否滿足本題，不符需註記缺失。
2. A和C必須真實生成 Source Layer 素材；不可以模擬稱已完成。沒有模型/權重就NOT_RUN或做技術架構驗證候選。
3. 每法分別輸出 Master/Full/PAR/Alpha negative QA/局部放大/Actor 站位/來源登记，逐條記錄。
4. Pass G-Art + G-Mask 後才跑VX；不在低質候選上浪費無意義 native shots。
5. GitHub authority/、Drive原素材+ZIP、Linear SHO-34、`CURRENT_HANDOFF_R17.md`一致；Handoff必有NEXT_COMMAND、Files、Known FAIL、SHA、Gate、是否Seal。

## 目前開工決策
- **先做B的可驗證局部Benchmark**（已實測SAM2/Godot流程與原 Master來源），建立漏遮/誤收明確標記。
- **C先驗證「連續地表＋獨立源物件」的可編輯導出**，但如果來源不夠美就Art FAIL，不再把技術Pass當精緻完成。
- **A僅在取得真正可控的獨立圖層生成能力後實際進場**，絕對不能拿相同Master copy作假兩圖生成。

**本次為研究版 Authority，使用者 Gate F尚未驗收。**