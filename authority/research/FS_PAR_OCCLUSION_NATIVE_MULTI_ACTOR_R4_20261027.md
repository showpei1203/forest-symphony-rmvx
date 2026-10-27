# FS｜完整 Ground＋同源 PAR 遮擋 R4 原生多角色測試
**2026-10-27｜Isolated R4 NATIVE Game.exe TECH PASS｜正式 FS 505 腳本未測｜PAR ART HOLD**

## 正式目標
不分割完美 Ground；Ground 是完整藝術場景（本輪以 SCENE21 544×416 現有圖），只從同一母圖提取會顯示於角色上方的 PAR 遮擋像素，不讓 AI 重新繪製 PAR；通行由 FS 腳本。原 Scene21 的透明外圍僅在測試輸出合成黑色背襯（不更動 Master）。
32px 方格是選取/掃描工具，不是全格不透明 PAR；混合格應使用原生像素 Alpha Mask。

## R4 實作
- 承襲 R3 隔離 B1 TEST-only native Game.exe，建立 R4_NATIVE_VX/STATIC 和 R4_NATIVE_VX/DEPTH，兩版使用相同原圖、相同三個初步 PAR 物件 mask。
- 建立真正的 `RPG::Event` → `Game_Event` 地圖 NPC，圖片為專案來源 `$002.png`（僅私人隔離複製）。
- 玩家與 NPC 實際使用 VX `Sprite_Character`，其 z 都來自各自角色腳底 y*32+32，沒有偷用 Python 假角色；PAR STATIC z=900，DEPTH 物件 z=foot_contact_y。
- 5 組情境，兩模式 Game.exe 真實運行，總共 10 張 544×416 截圖。演算與圖片：R4_NATIVE_SCREENSHOTS/R4_MULTI_ACTOR_NATIVE_PIXEL_AUDIT.json。

## R4 原生實測
| 站位 | STATIC vs DEPTH 差異 | 玩家區域差異 | NPC 區域差異 | 背景非角色區差異 |
|---|---:|---:|---:|---:|
| 玩家樹前，NPC樹後 | 140 | 140 | 0 | 0 |
| 玩家樹後，NPC樹前 | 23 | 0 | 23 | 0 |
| 兩者在樹前 | 191 | 140 | 52 | 0 |
| 兩者樹後 | 0 | 0 | 0 | 0 |
| 空曠位置 | 0 | 0 | 0 | 0 |

注：兩者樹前差異歸屬 ROI 可能交疊，140+52 可 >191。數字是真實截圖靜態/動態之差，不是獨立完整人工遮擋真值。所有情況對比 master 的兩模式非角色區失真均0像素。
Log 皆驗證 `R4_REAL_GAME_EVENT_CREATED class=Game_Event`、`R3_NATIVE_BASIC_PASS`、`npcCount=1`、兩角色各自 SpriteZ。

## 全格角色圖風險掃描 R4
- 地圖 17×13 ＝221個32px格，依目前 R3 隔離測試的 **只有3個人工阻擋格** 推定 218個候選可走格；這不是 FS ISS-ParaPassa 正式通行圖。
- 掃描真實 FS `$001.png` 的四方向 32×32 角色輪廓，對比 3 個 PAR 候選遮罩（右樹仍有語義瑕疵）。
- 固定 PAR 在角色位於前方仍壓人的格子：**2格**（左樹 (4,5)、(5,5)，候選），最大48個角色像素。
- 整個32px格暴力覆蓋有額外**非物件遮擋風險43格**。熱圖用紅色表示深度修正格、橘色是整格過度遮擋候選。
- 圖片：R4_WALKABLE_GRID_OCCLUSION_SCAN/R4_17x13_OCCLUSION_RISK_HEATMAP.png，原 JSON 包含每一格掃描。
- 此數量只是現有 mask＋測試通行假設下的範圍診斷；不代表正式地圖的完整通行規則或所有方向已達畫質驗收。

## 本輪發現的問題與修正
- R4_ERR_001：首次 Game_Event 建立成功，但測試模板沒有 `Graphics/Characters/$002.png`，Game.exe 載入畫面中斷（沒有 capture）。修正在隔離 build 複製唯一需要的角色圖，重新建立兩個版本與重新執行後通過。
- R4_ERR_002：右樹遮罩仍有語義錯抓；既有 R0/R1 人眼 ART HOLD 繼續有效，不得把這次 renderer PASS 當成 masks PASS。
- R4_ERR_003：R4 測試版使用自建 B1 99 script template，**不是 FS 505 script 正式環境**；現有 HK Ultimate Overlay PAR 使用另一 Viewport（可能始終蓋住角色），所以直接複製本腳本的 z 排序不保證兼容，正式腳本測試仍需獨立進行。

## Gate
- 兩角色原生腳本 + 圖像渲染：PASS（隔離）。
- 5情境 STATIC vs DEPTH，真人物前後像素差，非角色背景無改動：PASS（隔離）。
- 218候選格四方向危險點掃描：TECH PASS FOR INVENTORY，不代表正確通行／ART。
- 整張圖的前景抽取：ART HOLD（本輪仍只有3個物件）。
- 正式 505 scripts 的 HK/ISS/Light/Shadow/Animated compatibility：NOT TESTED。
- 多NPC移動路徑、隊伍跟隨、角色走到橋上、滾動/大圖、用户 Gate F：NOT TESTED。
- 不得覆蓋正式封版/另一對話工作；保留 RAW、測試版本、原生 Screen、LOG、SHA 於私人 Drive。

## R5 工作順序
1. 真正讀取正式 FS 505-script 目前的 HK-UOM/ISS-Passa load/passability，產出**隔離正式來源的 Adapter Probe**，避免擅自改封版。
2. 針對整張 SCENE21 以 SAM2 negative point + connected components + category tags 加強 mask：樹冠/屋簷才需要遮擋，其他細節的地面留 Ground。專門阻擋右樹混入下方灌木的 false positive。
3. 以實際 ParaPassa MapXXX.rvdata 第3層 768..799 得到 walkability，不再把 R3測試3格當真實通行度。
4. 多角色動態 moving + passability + 17x13 四方向 1px/32px 掃描+ Visual A/B；先完成一張小圖，再擴 1280x928；正式封版和動畫 layer 一律在隔離副本測。
5. 確認 PAR static 可滿足時優先不加 dynamic adapter；僅在真正可行走衝突格啟用 actor-aware sprite depth。

## 可重現與打包
- `build_native_multi_actor_r4.py`：從 test-only R3 複製出 STATIC/DEPTH 真實VX，插入 Game_Event NPC，並只在隔離版本更新 Scripts.rvdata。
- `verify_native_multi_actor_r4.py`：Win Game.exe 兩輪，10張原生 screenshots，核對 NPC class 和角色深度 log。
- `analyze_native_multi_actor_r4.py`：WSL/Python 逐像素 Gate，Fail-Closed。
- `scan_reachable_occlusion_r4.py`：FS $001 4方向 sprite×候選可走格；輸出熱圖與 JSON。
- `make_native_multi_actor_r4_contact.py`：原生截圖 A/B 最近鄰放大。
- 完整私有工區：E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027。
- 跨對話接續：CURRENT_HANDOFF_R4.md。