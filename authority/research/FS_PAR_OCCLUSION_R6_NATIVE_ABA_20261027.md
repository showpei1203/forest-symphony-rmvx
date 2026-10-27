# Forest Symphony｜完整 Master Ground＋同源透明 PAR｜R6 單一原生 VX 進程 A/B/A 像素驗證
**Date: 2026-10-27｜Result: ISOLATED NATIVE VX RENDERER TECH PASS（兩輪重跑）｜Full 505-page boot FAIL｜美術/完整遮罩 Gate F HOLD**

## 最重要成果
在**同一個 Game.exe 進程**，固定地圖、鏡頭、玩家／NPC 站位，採 A1=HK 靜態PAR、B=按物件接地深度排序的同源PAR、A2=還原 HK 靜態PAR。每一情境暫停會使畫面產生變化的完整 Scene_Map update，但保留 Graphics.update 以便呈現 alpha/visible 變化。真實 VX 原生 544x416 截圖。

兩輪**獨立 Game.exe 重播**各15張、合計30張。每一輪在「任何一個 RGB channel 不同即計入」的嚴格 zero threshold 下：
| player/NPC 位置 | A1→B：變化像素（均在兩角角色ROI） | 非角色 ROI | A1→A2 恢復差異 |
|---|---:|---:|---:|
| PLAYER_FRONT_NPC_BEHIND | 107 | 0 | 0 |
| PLAYER_BEHIND_NPC_FRONT | 11 | 0 | 0 |
| BOTH_FRONT | 134 | 0 | 0 |
| BOTH_BEHIND | 0 | 0 | 0 |
| CLEAR | 0 | 0 | 0 |
以上兩輪數據完全重現。所有人像 ROI 只用幾何附近區域界定，不能取代逐像素角色精細輪廓檢驗；僅論證本測試定義下的圖層顯示差異局部化和 A/B/A 還原性。

## 重要先決條件與來源權威
- 本輪測試使用正式 Forest Symphony 505 原始腳本作為唯讀權威，原始 `Data/Scripts.rvdata` SHA256：
  `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`
- 在 R5/R6 **隔離副本**之中，原 FS #480 `FS_BattleRegression_AIEdgeI v1.0` 因 pre-Main alias NameError 不能啟動，被暫停成測試空白；其他原始504個 Script 元組的來源位元一致；一頁 R6/R5 專用 Adapter 插在 Main 前。不是原始505頁原封不動的正式運行通過。
- 第145 HK-UOM（PAR 獨立 Viewport z=8）、146 Animated Parallax、342 ISS ParaPassa 的原始頁面完全未動。
- 玩家和 NPC 均使用 RGSS2 / RPGVX 原生角色圖／Game_Event；3組早期 SAM2 同源候選遮擋（左樹／右樹／房屋），不是完整 PAR 美術候選封版。
- 母圖是 SCENE21 544×416 完整美術圖；原圖 Alpha 外圍於輸出級黑底襯固定，使背景技術輸出不受透明地圖背層影響。未對原始Ground進行修補或生成新的樹／房屋。
- 靜態 PAR 由原 HK 的 `Overlays/Par1.png` 顯示並由 switch203控制；動態版將這張上層關閉，改用 `@viewport1` 三個原畫素材 Sprite，各自根據接地點的 z 值排序。測試過程只有 visibility 改變，角色與地圖內容均保持不變。
- 通行仍是原 ISS 第三層768（擋）769（行），R5已在真正 Game.exe 驗證實際 playerMoveUp pass/block，R6 log再驗證 mapPass=true mapBlock=false。

## 修正歷程（全部保留）
1. **R6-ERR-001 渲染時序干擾**：首次同進程 A/B/A 不暫停 Scene_Map，`A1→A2` 即使前景復原，非角色區仍有75,958～83,636個RGB差異（threshold>5）。鏡頭偏移掃描中心、屋、樹、背景皆以(0,0)最匹配，故主要屬於不同 frame 造成的視覺變化，不是地圖整體位移。
2. **R6-ERR-002 失敗的 freeze 實作**：嘗試每張位姿之間跳過 `Scene_Map#update`，但在 Ruby 1.8 RGSS2 `Array#each_index.any?` 無 block 觸發 `LocalJumpError: no block given`；native Game.exe 無法取圖（0/15）。已由真原生 error dialog 截圖定位；更正為 `each_with_index {|row,i|...}`（帶block）後重跑。
3. **R6-TECH-PASS**：正確 freeze：開場43 frame與每次改位置後1 frame允許完整 Scene_Map.update，其他期間只讓 Graphics.update 顯示可見性變化。15/15 native 截圖 PASS、A1=A2 exact zero、非角色 A/B diff exact zero。
4. **R6-REPLAY-PASS**：保存第一次 PASS 證據後第二次在全新 Game.exe PID 重播，第二輪15/15、所有五種每格數字一致。未聲稱每一渲染時點都能保持 gameplay 正常；freeze 只限測試截圖。

## Gates
- 實際原生 Game.exe 啟動及 FPS 圖層切換：**ISOLATED PASS**
- 同場同地點 A1/B/A2、回復性、非角色像素保真：**PASS（2×15 native images; 0 threshold）**
- 玩家/NPC 各自深度的局部切換：**PASS（tested 5 states）**
- ParaPassa 真實 Move：**R5 PASS，R6 read-only確認值**
- 第480頁 Regression Harness 不動的完整 505 頁 BOOT：**FAIL／阻擋；隔離暫停一頁才可測**。
- 完整 PAR、自動 SAM2語義準確、右樹灌木誤判：**ART HOLD**。
- 大圖 40×29、移動中多NPC/水波 Ground loop、正式FS美術人工Visual Gate F：**NOT TESTED**。

## 交付檔案
- `build_r6_same_session_vx.py`：從R5已隔離完整腳本副本衍生R6、byte-exact檢查其他504頁。
- `capture_r6_same_session_vx.py`：一個Native Game.exe 內5種站位×A1/B/A2共15shot、記錄PID。
- `analyze_r6_same_session.py`：計算閾值0/2/5/10/20、角色ROI/非角色、A1-A2。
- `r6_final_gate.py`：**fail-closed**要求兩次各15shot、角色前3個差異、後2個零、全部A1-A2零、全部背景A/B零、官方504頁逐頁相符。
- `diagnose_r6_temporal.py` 和 `observe_r6_error.py`：重現R6前兩次失敗定位。
- `make_r6_contact.py` 和 `R6_FS_NATIVE_STATIC_DYNAMIC_CONTACT.png`：實際 Native 截圖最近鄰3×對比。
- `R6_SAME_SESSION_ISOLATED/R6_UNFROZEN_BASELINE_R0`：R6-ERR001 15 native screenshots基準。
- `R6_SAME_SESSION_ISOLATED/ERROR_DIAG/R6_dialog_6.png`：R6-ERR002 RPG Maker 原生報錯畫面。
- `R6_SAME_SESSION_ISOLATED/R6_FROZEN_PASS_REPLAY_1` 和 `NATIVE_ABA`：第一、第二輪完整 A/B/A 15shot、log、JSON。
- `R6_SAME_SESSION_ISOLATED/R6_FINAL_GATE.json`：最終權威結論。
- Windows local isolated workspace：`E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027`。

## 下一階段 R7（不能把 renderer pass 當美術封版）
1. 先補足候選遮罩範圍，重做左樹/右樹/房屋的 semantic alpha 精度與左右/腳底對位，禁獨立生圖重新對齊。
2. 以實際第三層通行資料裁掉無法靠近的物件遮擋與危險點，重做正式高品質 SCENE21 PAR 候選；現有三物件mask仍未全圖。
3. 在 R6 的固定 renderer/圖片輸出上驗證移動過渡、人物四向、遮擋 alpha 邊界與整張圖完整性；客觀 Gate A-F 逐項檢核。
4. 之後接大地圖 Map003 40x29/ground3，動畫 Ground 如 ground10_1..N、水雲影光；第480 regression boot blocker交 SHO-56，不在地圖對話修改封版。
5. 每步按 fail-closed，先 Native 技術、後美術人工審核，沒有 Gate F 不報正式 PASS。