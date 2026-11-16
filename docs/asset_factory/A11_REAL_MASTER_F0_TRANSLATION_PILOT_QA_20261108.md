# A11-M1/M2/S1｜高品質單張 → FS 資源轉換第一輪真實驗證
日期：2026-11-08。依 [唯一現行主規範](../../authority/FS_ASSET_FACTORY_ACTIVE_MASTER.md)。此實驗不取代舊 A10 工程，不宣稱重新生成已通過的 FS 美術。

## 這次實際做了什麼
- **地圖 M1**：從真實封存 Master-first V3 ZIP 冷讀取 1280×928 完整精緻 Master（SHA256 `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530`）。`Runtime_FullGround` **直接複製原 PNG 位元組**。重用 V3 兩個**待驗的舊樹冠語意遮罩**，僅將它們作為 Alpha，PAR 的 RGB 對每個像素都從 Master(x,y) 原址抽取。沒有獨立 AI 重繪 Ground／PAR。
- **M2 橋樑語意反證**：同一張 Master 上以整個近側橋欄的向量結構建立一個**全新粗略 Mask 提案**，保留來源 RGB；另標出保守的橋面核心不可遮擋區。這是物件級意圖/來源繪製，不是從木頭顏色 GrabCut 切全圖。橋欄仍有漏描與偏移，**ART HOLD**。
- **Sprite S1**：使用 A62 實際已認可的 48×48 F0（SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba`），以整數像素來源逆變形生成 **新的** Waiting F0/F1/F2＋GIF。F0 原始位元組不動，衍生影格色彩僅從 F0 選取。A62 Run 三幀僅拿來比對基準，不宣稱生成新 Run。新 Waiting 自然度待使用者核准，也不是 PixelLab 或 AI 的逐姿勢重繪。

## 真實測得，並非推論
| 比較項目 | 舊候選／原始 | A11 測量 |
|---|---:|---:|
| Master 尺寸 | 1280×928 | 1280×928 |
| Runtime FullGround 原始 PNG | 同源 | **二進位不變** |
| 兩個舊樹冠遮罩 Alpha 像素 | N/A | 88,655 |
| 包含橋欄的三物件 PAR Alpha 總數 | N/A | **90,076** |
| 三物件 PAR RGB 與 Master 相同 XY 不一致 | 未驗證 | **0** |
| 先前 V3 Authoring GroundOnly+CompletePAR 與 Master 重合 | V3 來源 | MAE 0、差異 0 |
| 舊 A06 橋欄遮罩／落入保守橋面核心 | 3,845 Alpha | **494** |
| A11 新橋欄向量遮罩／落入相同橋面核心 | 1,421 Alpha | **0** |
| 人物壓入候選橋欄模擬 | 假 203 不能認證 | 227／576 像素被覆蓋；比例 39.4% |
| Actor F0 | 48×48、舊 A62 核准 | 二進位完全不變 |
| 新 Waiting 三姿勢對 F0 改動像素 | N/A | 0／407／381 |
| 新 Waiting 使用來源外色彩 | N/A | **0 種** |
| 新 Waiting Alpha IoU 與 F0 | N/A | 1.000／0.8893／0.8896 |

注意：舊 A06 遮罩的 494 像素是和**同一個保守橋面核心 ROI**比，不代表完整橋面誤遮擋總數；新的 0 像素也不等於橋欄每一根木紋都正確。人工向量草稿只證實「從物件語意排除地板」可顯著避免以前的錯誤，但仍缺 AI/手工來源精準形狀，不能進正式 Runtime／Game.exe。

## 這次新增可實際檢查的 PNG/GIF
全部在**私人 Drive A11 實料 ZIP**。含 `M1_RUNTIME_FULL_GROUND_UNCHANGED.png`、`M2_COMBINED_TWO_CANOPIES_PLUS_BRIDGE_PAR_DRAFT.png`、`M2_BRIDGE_RAIL_YELLOW_DECK_RED_3X.png`、`M2_BRIDGE_ACTOR_NO_PAR_VS_PAR_SIMULATION.png`、`S1_WAITING_NEW_FROM_F0_3POSE.png`、`S1_WAITING_NEW_FROM_F0_LOOP.gif`、`S1_NEW_WAITING_VS_APPROVED_RUN_CONTACT_4X.png`、實驗 QA JSON 和完整來源腳本。

ZIP 名 `FS_A11_MASTER_F0_TRANSLATION_PILOT_20261108.zip`，**19,807,540 bytes／32 檔案**，SHA256 `3131fc99ba5d19f5d6328cfd43068ebea2ddda2d50486576b430df71fe7bc910`。已 Google Drive 上傳＋重新下載＋SHA/CRC驗證，存 owner-only Restricted_Binaries，GitHub **不放私人 ZIP ID 或圖像位元組**。

本次原始來源 ZIP 不做修改或覆寫。封包的三個可重跑腳本由 `--map-zip`、`--actor-zip`、`--legacy-bridge-zip`、`--out` 接收來源；隔離環境冷重跑後相同主要 PNG 位元組完全一致，無 PixelLab／外部費用。GitHub 公開精簡核心源碼 `tools/asset_factory/a11_master_f0_transform.py`，保留同源像素合成、防地板污染與 F0-only 48px 轉換，另有負面測試。

## 分離驗收，不做表面成功
- **SOURCE / CLOUD SHA／PNG COORD**：PASS，真實 Master/F0 完整且位元組可追溯。
- **SEMANTIC MASK**：PARTIAL/DRAFT。兩個樹冠遮罩來自 V3 舊 GrabCut 提案；新橋欄只是向量模型，尚不準確，並未做完整屋簷/河流/所有遮擋。
- **Sprite**：F0 source color / immutable pixel PASS；Waiting 動作是否自然、是否符合 FS 實際動畫 **ART HOLD**。
- **FULL GROUND／AUTHORING**：本輪延續 V3 既有 Authoring DRAFT，並非新產出成熟的 GroundOnly／CompletePAR 物件組。
- **VX Native / switch203 / legal footpoint / collision / Tankentai**：**NOT_RUN**，人物覆蓋圖僅為 Python/Pillow 模擬。
- **PixelLab**：0；**Orca 新 Agent**：0；**使用者 PC 新工作檔**：0；**正式 main**：未改；**Formal Seal**：NO。

## 下一個值得實驗的兩個瓶頸
1. M-A：在同一張高品質 Master 上，提供 AI 只輸出**像素遮罩／物件語意輪廓**而非重繪 RGB 的可重用流程。對橋欄必須測「木橋踏板 negative」及真正人物腳點，不要回到單根欄杆像素來回修補。
2. S-A：用 F0 作身份鎖，評估「骨架驅動姿勢＋逐姿勢像素重繪」是否能自然完成 Run／Waiting，而不是靠行列挪動取得很難看的小幅動態。最好有第二個不同原始 F0 驗證模板複用。
3. 真正 Game.exe 僅在使用者另行授權臨時副本工作範圍、清理規則後執行；不拿靜態模擬冒充。
