# Forest Symphony｜R7 真正來源可見性＋A36G 原生 Map050／PAR｜2026-11-07

## 結論
正式成果：A36G R5 原始工程完全未修改，隔離生成 R7 C1 `AUTHORING_GROUND_ONLY`、`AUTHORING_COMPLETE_PAR`、`RUNTIME_FULL_SCENE_GROUND50`、`RUNTIME_PAR50_5OBJECTS`、5 個獨立 semantic SOURCE PNG、逐來源 witness PNG；另外**真正重建 A36G 專用 `Map050.rvdata`**，實際 RPG Maker VX / RGSS2 引擎 QA 通過。
- A36G 地圖原生通行：**1160/1160 cells PASS**、**3544/3544 合法相鄰方向 PASS**，919 可走、241 阻擋，零 mismatch。注意前一輪 A36F 是 927/233 與 3576 edges，不能混在一起。
- A36G 兩屋屋頂＋3 棵來源真正可見的樹冠：實際 RPG Maker VX `Game.exe` 以 R5 collision Map50 與 HK UOM ParSwitch203，**5 個正面案例＋1 個空地負控制=6/6 PASS**。
- 在相同新 VX 工程中，**五次實際角色 `move_left/move_down` 由遮擋區走到更開闊位置**，每次都有 203 OFF/ON 起終點對照、真實 544×416 截圖；**5/5 Dynamic PASS**。
- **Source ownership 新增 Gate**，更正先前 V6 `tree_003` 的語意假陽性。A36G R5 的**美術仍 FAIL**，不能因技術整合通過而升級。未產生新美術、未耗 PixelLab 額度。Formal Seal NO。

## 專案來源／實際檔案
唯讀權威：`E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104\A36G_R5_SCENE_MANIFEST.json`、同資料夾 `A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png`、`SOURCE_INDEPENDENT_RGBA` 原始素材。批准美術原版仍為 `FS project\Graphics\Parallaxes\ground3.png`／`Overlays\par3.png`。
工作根：`E:\FS_AGENT_SKILLS_PILOT_20261106`。
- `fs_v12_a36g_real_map050_grid.py`：重編 native Table layer 2，並真正執行 VX 原生每格／每邊通行檢查。隔離資料夾 `A36G_V7_R5_NATIVE_COLLISION_REAL_MAP50_20261107`，QA `FS_V12_A36G_REAL_MAP050_COLLISION_QA.json`。
- `fs_a36g_r7_c1_five_sources.py`：5 個 source-owned masks，原始 SHA、物件 Alpha 與 final-scene RGB 註冊；產出完整 Authoring／Runtime 分離 PNG。輸出 `A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107`，QA `R7_C1_FIVE_OBJECTS_SOURCE_QA.json`。
- `fs_v13_r7_five_objects_real_native203.py`：同一隔離 VX 工程 R5 真碰撞 + 5 個可走格實測 + 清楚負控制，QA `A36G_R7_REAL_NATIVE_203_AND_COLLISION_20261107\R7_NATIVE_203_REAL_R5_COLLISION_QA.json`。
- `fs_v14_r7_native_dynamic_exits.py` + `fs_v14_a36g_dynamic_visual_qa.py`：5×真角色移動/5-state 相機＋203 遮擋組，QA `A36G_V7_REAL_NATIVE_MOVEMENT_V14_20261107\V14_A36G_R7_DYNAMIC_203_VISUAL_QA.json`。

## 防假陽性大修正（必須永久保存）
上一輪 V6 的 `tree_003` 原始 PNG 有 2481 不透明像素，但其所在世界位置在最終 A36G Master 裡只有 **5.12%** RGB 精確相同；`tree_056` 更只有 **1.92%**。兩棵樹被其他層覆蓋，直接使用它們的來源 Alpha 來決定最終場景遮擋會「遮住人物」，卻不一定是該棵樹在畫面中真正存在。
- V6 的 tree_003 **Engine ParSwitch203 PASS 仍有效**，但 **Source-ownership semantic Gate 由原來隱含 PASS 更正為 FAIL**。舊 Handoff／GitHub 需附更正，禁止沿用作 per-source 語意通過的案例。
- R7 從所有 59 棵來源樹逐棵比對不透明 PNG RGB 與最終同世界座標合成圖，挑選 `tree_093` 100%、`tree_010` 99.69%、`tree_020` 100%；其樹冠語意 mask RGB 與 final master 的相符率約 100%。
- R7 五物件遮擋所有來源 masked pixel 同世界座標 RGB ownership >99%；只對 final Master 正確可見的 SOURCE Alpha 做分層，其後才在最後 Master RGB 上取樣。同時確保人物腳所在 tile 在 A36G R5 manifest 屬可走格。
- 這項檢查避免其他 `forest_group` 或上層素材已完全蓋住某個來源後，仍錯拿該來源 Alpha 當該畫面物件前景。

## A36G 專用 Map050 真正重編過程
- 原 A36F Map050 `Data/Map050.rvdata` 的 `RPG::Map @data` 是 Little-endian Table，header `<5I>` = `(3,40,29,3,3480)`。Layer z=0/1 全 0，z=2 使用 **tile ID 768 = 阻擋**、**769 = 可走**。
- 實際在隔離檔案重編 z=2 為 A36G R5 Manifest 241 格阻擋、919 格可走，總共 12 格與 A36F 版不同。**不是覆寫 `Game_Player#passable?` 讓回傳符合 Manifest**。
- 重新 RubyMarshal 寫入 `Map050.rvdata`，再反序列化逐值驗證；實際 VX `Game.exe` + ISS-ParaPassa 掃 1160 格和 3544 合法有向邊，0 差異，所有正式源檔 SHA 未變。
- 繼續遵守「測試角色泊在已封鎖 (3,6)」以排除自己站在出生格造成假阻擋；不可回改原工程。

## R7 五件遮擋素材
| Source ID | 本地來源遮罩 | Source 物件真正可見性 | R7 walkable sample |
| 左屋 A36G_ELF_HOUSE_AND_WORKSHOP | C2 先前已個別繪製屋面，保留原源 PNG | mask ownership 99.42% | tile (15,8) |
| 右屋 A36G_R5_COTTAGE_B_SINGLE_ROOF | 單源屋面人工 polygon + HSV 材質限制 | mask ownership 100% | tile (26,14) |
| tree_093 | source Alpha + 每株 canopy HSV/semantic | 100% | tile (13,4) |
| tree_010 | 同上 | 99.87% | tile (26,7) |
| tree_020 | 同上 | 100% | tile (36,3) |
- 僅 5/192 物件完成可見性歸屬／局部遮擋，R7 Runtime PAR 不透明覆蓋率 **4.8080%**，**不能**宣稱全圖 PAR 就應該只有 4.8%。原 Authoring COMPLETE_PAR 仍不變。
- `R7_RUNTIME_PAR50_5OBJECTS.png` 含 5 物件聯集遮擋，最終不透明 RGB 完全由 `R7_RUNTIME_FULL_SCENE_GROUND50.png` 同一像素取樣；Alpha = binary，無 32px 取樣方格。
- R5 茅草屋／森林美術無重畫，本輪不改風格 FAIL。

## 原生 203 六個樣本
6/6 PASS，五件 source positive 的 changed actor pixels 分別都是 **627**（約25×32人物 bbox），空地對照 0；每次左右相機固定，`$game_switches[203]` 和 `HK UOM @par.visible` 真正切換。截圖：`R7_NATIVE_5OBJECTS_6CASES_OFF_ON_CONTACT.png`。

## 原生角色移動 5-state（五次都成功）
`OFF(start)` → `ON(start)` → 真實 `move_left`／`move_down` → `AFTER` → `END_OFF` → `END_ON`。每次起終點兩對 OFF/ON 的鏡頭固定，R5 兩個格子均可走，源檔 SHA 不變。
| Move case | 從 -> 到 | 起點 changed pixels | 終點 changed pixels | Gate |
| RIGHT_ROOF_EXIT | (24,15)->(23,15) | 626 | 0 | PASS |
| TREE_093_EXIT | (12,5)->(11,5) | 495 | 0 | PASS |
| TREE_010_EXIT | (26,8)->(26,9) | 478 | 46 | PASS |
| TREE_020_EXIT | (35,4)->(34,4) | 616 | 56 | PASS |
| LEFT_ROOF_EXIT | (14,8)->(13,8) | 473 | 0 | PASS |
- QA `V14_A36G_R7_DYNAMIC_203_VISUAL_QA.json`；實拍 contact `V14_R7_FIVE_DYNAMIC_EXITS_FIVE_STATES_CONTACT.png`。
- 此 Gate 證明在測試路段人物出入遮擋可用，尚未審核**所有**角色位置、遮罩邊緣、屋頂遮擋自然度、完整 UI 或全遊戲事件。

## 下一個高價值施工方向
1. 先將右屋、左屋屋頂 Semantic Mask 的跨格、屋簷與建築前門的步行效果做人工視覺 Gate；如不自然，只修遮罩與可走格，不因 RGSS 成功就批准美術。
2. 樹木優先從已確認真正可見的來源擴展，另外應處理大量未真正顯示來源的 tree/forest_group，不能用「來源 PNG 存在」冒充主畫面存在；每件 Source ownership > threshold 才進行遮擋。
3. 解決原 R5 並不符合 FS ground3 的美術色盤、房屋整體風格與森林拼接問題。產線應以 Ground3 真正美術為準，先修到批准再擴大製作，不要自我參照 R5 概念圖。
4. Godot 仍為輔助實機對照；本輪沒有重新做 Godot 冷渲染。不可以說全專案 Godot PASS。
5. A36G R7 C1 僅 Candidate／Source gate，藝術美感與未處理 187 個物件不准封版。

### 最終 Gate（2026-11-07）
- R5 Map050 real native collision 1160/1160：**PASS**
- R5 native directed movement 3544/3544：**PASS**
- Source visibility ownership 五件：**PASS**
- R7 static native 203 on walkable cells + negative：**6/6 PASS**
- R7 5 dynamic native walk-to-clear and before/after 203：**5/5 PASS**
- V6 tree_003 semantic source ownership：**FAIL/ERRATUM**
- A36G R7 187 unprocessed sources：**NOT TESTED**
- A36G R5 aesthetic original-approved style：**ART FAIL**
- Formal Seal：**NO**