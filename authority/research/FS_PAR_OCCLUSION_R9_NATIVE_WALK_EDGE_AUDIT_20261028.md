# Forest Symphony｜R9 真實移動＋PAR 輪廓獨立風險稽核｜2026-10-28

**STATUS: ISOLATED NATIVE VX ONE-TILE WALK TECH PASS（2獨立進程×10種＝20原生截圖）｜Occlusion Art / exact screenshot registration / Formal scene map PASSABILITY HOLD**

## 主要改變
R8已通過同畫面A1（靜態PAR）→B（動態20層）→A2（還原）兩輪×18張角色區／背景區像素TECH Gate，但只利用`moveto`設置站位，不能稱作真正行走。R9新增**實際執行 RPG Maker VX `$game_player.move_up/down/left/right`**，取得角色新座標與完成行走後原生VX截圖；與R8的靜態景深測試分開，不混淆。
R9每情境先用`moveto`設定起始條件，接著執行一個真實一步`Game_Player#move_*`並讓 Scene_Map 正常更新至完成，且記錄預期、實際與玩家腳底位置。每次只有一步，**不是完整路徑尋路、不是鍵盤人工長時間玩，也不代表正式SCENE21原始地圖通行**。

## 10個真實原生移動案例
| 測試 | 起點 | 真移動 | 預期終點 | Gate |
|---|---|---|---|---|
| T01_TREE_DOWN_BACK | (13,3) | 下 | (13,4) | PASS |
| T02_TREE_DOWN_FRONT | (13,4) | 下 | (13,5) | PASS |
| T03_TREE_UP | (13,5) | 上 | (13,4) | PASS |
| T04_BUSH_LEFT | (3,8) | 左 | (2,8) | PASS |
| T05_BUSH_RIGHT | (2,8) | 右 | (3,8) | PASS |
| T06_FAR_CONIFER_DOWN | (15,6) | 下 | (15,7) | PASS |
| T07_FAR_CONIFER_UP | (15,7) | 上 | (15,6) | PASS |
| T08_STEPS_DOWN | (9,5) | 下 | (9,6) | PASS |
| T09_BLOCKED_UP | (5,7) | 上 | (5,7)不動 | PASS |
| T10_BLOCKED_LEFT | (6,6) | 左 | (6,6)不動 | PASS |

- 兩輪分開啟動真正 Windows Game.exe。每輪10個移動截圖 544×416, 兩輪20張。
- 獨立 Fail-Closed `r9_final_gate.py`要求：原 native 2個不同PID、每個10個案例皆從 `R9_ACTUAL_MOVE` 中擷取成功，終點座標符合、反方向阻擋符合、每張PNG原生544×416、實際腳本留正式 byte guard。
- 原生 R8的20個動態遮擋 Sprite 與 Ground 保持；R9移動時統一 Dynamic PAR，無刻意freeze地圖動態效果，**因此不拿兩個不同 frame 的像素差當作前景正確的證據**。
- Map001第三層使用前R5專門設定的768禁行格／769通行格。這不是正式使用者SCENE21地圖的實際原始通行設定。通行資料和畫面是隔離測試環境，未證明任何正式原MapXXX的通行語義。

## R9 圖像邊緣獨立風險查核
R9對使用者標紅8個物件（R8 SAM2 source-pixel masks）做不同於模型prompt置信度的輪廓檢查：PIL + OpenCV Sobel強梯度、連通元件、bbox填充/逸出範圍及高分辨近鄰原圖/遮罩對照。
- 檢測8個物件，**6組標記需重查**：RED_R01、R02、R05、R06、R07、R08。
- RED_R01/R02大型針葉樹及 R05/R06/R08微型植物為「low image edge support」風險，RED_R07綠色灌木遮罩部分超出指定bbox（`OUTSIDE_ANNOTATED_BOX_2PCT`）。R03、R04未被本輪啟發式檢查標為異常。
- 全8個遮罩連通元件=1，沒有孤立漂浮像素群的問題（僅此意義）。
- **注意**：像素藝術紋理並不保證物件輪廓處於Sobel灰階最強4%梯度，因此6組是 Review Flags，不是6組確定切錯／更不能宣稱剩下2組美術真值PASS。
- `R9_EDGE_SEMANTIC_AUDIT/R9_8_RED_SOURCE_ALPHA_BOUNDARY_REVIEW.png` 保存每個物件的 source vs 粉色遮罩 1張對照圖，及 `R9_EDGE_RISK_AUDIT.json` 原始定量證據。

## Authority 與隔離
- 唯讀正式來源：`E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata`。
- 官方原始505頁 SHA256：`5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`，**本輪未修改**。
- 由R8隔離副本衍生R9。原505頁中有504頁逐tuple位元一致，包括HK-UOM#145／Animated#146／ISSParaPassa#342；原第480頁 FS_BattleRegression_AIEdgeI因既有pre-Main AliasError只在隔離本停用，額外加一頁專用Adapter（共506頁）。
- 本次**不能宣稱原封505頁正式全啟動PASS**。另一對話V6地圖與FS SEALED不修改。
- 圖像藝術：Ground原圖不修改；PAR仍R8同源20候選；user annotation image 548×400 vs SCENE21 Master 544×416未能用原附件完成嚴格圖像配準，**絕不宣稱使用者紅圈精準輪廓已逐px對齊**。

## Fail/Pass 不混淆
- R8 A/B/A原生景深切換：已通過、非R9新claim。
- R9真實單格上下左右：PASS，10/10×2進程。
- R9兩禁行格正確阻擋：PASS，2×2。
- R9足底與遮罩碰撞：動態顯示可觀察，但完整多方向連續走路/全部物件之視覺前後正確性仍HOLD。
- R9美術輪廓與完整度：6個需複核，ART HOLD。
- R9正式SCENE21對應原MapXXX第三層／水/洞/通行/方向：NOT TESTED。
- R9場景尺寸升級40×29與ground10 animated loop+Light/Shadow：NOT TESTED。
- K4原505未修改全腳本Boot：既有FAIL，獨立回歸修復線。
- **Gate F / FINAL SEAL = HOLD**。

## R10 Priority
1. 使用者原色標註圖548×400與Ground母圖544×416精確影像配準。只套bbox線性映射不算正式，需多landmark+殘差/檢查。
2. 人眼複核6個高風險遮罩，尤其兩高針葉樹邊緣；保留靜態/動態合成PAR完全源像素不會反彈回獨立生圖。
3. 調查真正SCENE21目標對應MapXXX，讀原Data/MapXXX第三層既有768..799，不能再把測試Map001當正式通行。
4. 真角色四方向連續行走，NPC獨立運動及低矮灌木 foot-anchor多角色遮擋。
5. Gate A–F 完成後才接 ground3大型地圖、ground10 loop、Light/Shadow；所有階段先QA fail-closed。

## 復現
- `build_r9_native_walking.py`：複製R8隔離全程，Append R9 one-step Test-only adapter，K4 Hash/byte guard。
- `capture_r9_native_walk.py`：真正Windows `Game.exe` 執行10測試、記錄`R9_ACTUAL_MOVE`與`R9_WALK_CAPTURE`及Native PNG。
- `r9_edge_semantic_risk_audit.py`：8個物件OpenCV連通＋Sobel風險，輸出1x nearest候選對照PNG。
- `r9_final_gate.py`：兩輪native Gate＋504byte-identical guard＋8個美術風險HOLD。
- `R9_NATIVE_WALKING_ISOLATED/NATIVE_WALK_REPLAY1`與`NATIVE_WALK`：兩輪各10原生PNG、Log、JSON；`R9_NATIVE_WALKING_ISOLATED/R9_FINAL_GATE.json`。
- `R9_EDGE_SEMANTIC_AUDIT/R9_EDGE_RISK_AUDIT.json`和`R9_8_RED_SOURCE_ALPHA_BOUNDARY_REVIEW.png`。
- 研究根路徑 `E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027`。