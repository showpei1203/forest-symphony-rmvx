# Forest Symphony / Agent Skills V3 | Native Movement, Canopy Exit, Full Grid QA | 2026-11-07

## 判定與權威
- 此次專案仍以 **RPG Maker VX / RGSS2** 為主引擎；Godot 僅作輔助渲染。測試工程為隔離副本，來源是 `E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST`，使用 A36F R2 的完整 Ground + 保守的原生 Occlusion PAR，及 A36F 的 Map050。
- **SOURCE HASH VERIFIED UNCHANGED**。沒有碰 A36F R1、A36G R5、PMD 原始素材或封版工程；本次沒有重新生成房屋、森林或花費 PixelLab credits。
- 最終結論：**12／12 移動抽樣 PASS；4／4 樹冠走出遮擋變化測試 PASS（局部案例）；1160／1160 原生地圖格、3576／3576 方向通行判定與 Scene Manifest 一致**。
- **Art / 全圖遮擋語意 / 原生 PMD XML-SBS 整合 / Formal Seal = 未通過**。原 A36F/A36G 美術 FAIL 不變；本次 Gate 都只針對 A36F R2 隔離測試候選。

## 新發現：ISS - ParaPassa API 與失敗歸因
FS 原生 `Scripts.rvdata` 中的 `ISS - ParaPassa` 改寫了 Game_Character 與 Game_Player 的通行流程：
- `Game_Character#passable?(x,y)` 只接受兩個座標；`Game_Player#move_passable?(xo,yo,xt,yt)` 才檢查起點至終點的方向性通行，`move_up/down/left/right` 實際使用此方法。
- V6 曾誤用三參數 `passable?(x,y,d)`，觸發真正的 VX RGSS 錯誤視窗。**V6 = FAIL（測試程式缺陷），不得當作地圖故障**。V7 改用四參數正確 API 重新測試，成功完成。

## V7 真正 RPG Maker VX 移動 12／12
隔離腳本：`fs_v7_native_movement.py`。
| case | 起點 -> 目標 | Manifest 預期 | VX 真正 `move_*` |
| ROAD_FREE | (20,14)->(21,14) | 可以 | PASS |
| HOUSE_A_WALL | (17,14)->(17,13) | 阻擋 | PASS |
| HOUSE_A_PATH | (17,15)->(17,14) | 可以 | PASS |
| HOUSE_B_WALL | (27,18)->(27,17) | 阻擋 | PASS |
| HOUSE_B_PATH | (27,19)->(27,18) | 可以 | PASS |
| FOREST_TREE_BLOCK | (4,6)->(3,6) | 阻擋 | PASS |
| FOREST_WALK | (4,6)->(4,7) | 可以 | PASS |
| FOREST_CANOPY_EXIT_W | (8,6)->(7,6) | 可以 | PASS |
| FOREST_CANOPY_EXIT_S | (25,7)->(25,8) | 可以 | PASS |
| FOREST_CANOPY_EXIT_N | (10,17)->(10,16) | 可以 | PASS |
| FOREST_CANOPY_EXIT_E | (29,15)->(30,15) | 可以 | PASS |
| HOUSE_A_BACK_MOVE | (17,9)->(18,9) | 可以 | PASS |
203 狀態切換 12／12；鏡頭座標 OFF／ON 12／12；真 544×416 實機截圖。

## V8 開場 UI 污染與修正
V7 的首兩組照片數千像素背景差異，發現並非 PAR 失準，而是開場位置名稱「米亞」UI 正在移動。增加 280 frame 暖機後重新執行，結果：
- ROAD_FREE OFF/ON 差異 9819 -> **0** 像素。
- HOUSE_A_WALL 8819 -> **5** 像素（角色周圍 4×2 小區域）。
- 另外兩個無遮擋對照案例 `HOUSE_B_WALL` 和 `HOUSE_B_PATH` 均 0 像素。
**規則：靜態鏡頭座標相同不足以判定可比較；必須檢查動態 UI/動畫是否污染 RGB diff**。

## V9 真正角色走出樹冠／203 起終點雙次切換
`fs_v9_canopy_exit_par_runtime.py` + `fs_v9_visual_qa.py` 在同一個原生 VX Test Build 中，四個方向逐次執行：OFF(start) -> ON(start) -> 真移動 -> AFTER(ON) -> OFF(end) -> ON(end)，全部實拍真畫面與固定鏡頭。
| 方向 | start OFF/ON changed pixels | end OFF/ON changed pixels | end/start | Test |
| W | 625 | 119 | 19.04% | PASS |
| S | 368 | 0 | 0% | PASS |
| N | 627 | 232 | 37.00% | PASS（**尚有部分遮擋**） |
| E | 454 | 1 | 0.22% | PASS |
這證明動態遮擋會隨座標變化，但 **不是對美術遮擋邊界畫得漂亮的證明**。北側有 232 像素殘留，需人工檢視，不得聲稱完全脫離。
可視化：`validation_v6/V9_CANOPY_EXIT_4CASES_5STATES_CONTACT.png`。

## V10/V11：原生 40×29 全圖通行掃描
真實執行 `Game.exe`，在 RGSS Player 上呼叫 `Game_Player#passable?(x,y)` 掃描全部 **1160** 格，並呼叫 `move_passable?(xo,yo,xt,yt)` 掃描所有從可通行格出發的合法相鄰移動 **3576** 條。
- V10 初掃：1160 格僅 (20,14) 出現不一致，四個方向邊也都指向 (20,14)。原因：**掃描角色自己站在出生格**，其角色碰撞污染了該格的可通行檢測。V10 Gate FAIL，作為測試設計失敗保留。
- V11 修正：掃描前將測試角色安置在 Manifest 已封鎖的 (3,6) 格（**僅限隔離測試複本**），不讓自身擋住原本可走的出生格。
- V11 最終：**1160／1160 格 PASS**（927 free + 233 blocked）；**3576／3576 方向 PASS**（2864 passable / 712 blocked）；0 mismatches；來源 SHA 不變，RGSS runtime 錯誤 0。
- 檔案：`fs_v11_native_grid_parked_actor.py`；證據 `validation_v8/FS_V11_NATIVE_COLLISION_GRID_QA.json`。
- V11 包含二值格子與相鄰有向邊掃描；不是所有過場、事件對話或劇情機制的證明。

## 術語、限制與下一步
- `AUTHORING_GROUND_ONLY + AUTHORING_COMPLETE_PAR`：生成產線完整分層，PAR 包含所有非地面物件。必須遵守 FS v3.2 / 同源素材 / Scene Manifest。
- `RUNTIME_FULL_SCENE_GROUND + RUNTIME_OCCLUSION_PAR`：FS 原生 Hanzo runtime 部分重疊像素前景。開關 203 控制其前景顯示，不得以獨立 Objects smoke 替代其測試。
- 目前已驗證的 **是 A36F R2 conservative native Test Build**，不是 A36G R5 自身，也不代表另一個對話最新美術工作樹自然繼承。
- 接下來應製作 32×32 遮擋語意的原版圖與 R2 逐格比對（特別是北側樹冠／房屋入口），再開始 A36G 新版本圖層與素材美術驗收。
- PMD 三幀現有技術 QA 並未因本次地圖測試自動變成動作／美術 PASS。
- GitHub、Drive 原本 V2 Handoff 與 SHA 報表要保留，本輪另存不可覆寫。
- 最終 `Formal Seal=NO`，Art Signoff 未通過。