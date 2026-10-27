# Forest Symphony｜R5 真實 FS 腳本整合研究｜2026-10-27

**STATUS：ISOLATED ORIGINAL-HK/ISS REAL VX TECH PASS / FULL 505 BOOT REGRESSION FAIL / VISUAL & SEMANTIC ART HOLD**

## 一、單一方向不變
沿用使用者 Master-first Parallax 方案：整張完整母圖當 Ground；PAR 只把人物需要被遮住的原畫像素複製為透明前景。32×32 用來決定選區、通行座標；必要時 Alpha 邊界精修。Light/Shadow 原生 Overlay，Animated Parallax 另外測。
禁止回到「強制扣掉所有物件並補造隱藏地面」作為主要製圖流程。並保留先前 R1/R2、R3、R4 完整紀錄。

## 二、正式來源實際核對
- K4_BASELINE 正式資料夾唯讀，Scripts.rvdata SHA-256：
  `5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa`
- 確認 505 個原始腳本頁；包含 145 HK - Ultimate Overlay Mapping、146 Animated Parallax v2.1、342 ISS - ParaPassa、480 FS_BattleRegression_AIEdgeI。
- 第 145 腳本：HK PAR 在不同 Viewport z=8，基礎 @viewport1 z=0，因此單純在人物 @viewport1 上調整 Sprite.z 無法凌駕原 HK 的 PAR。
- HK overlay 路徑 Overlays/Par<map_id>.png、原生 Light/Shadow 實際依 jpg 檔案存在決定是否啟用。Overlays/Ground 不可錯當 Parallaxes 圖。
- ParaPassa 第 342 腳本：讀第三層 data[x,y,2] ID768..799，`USE_TILEMAP=false`。768阻擋、769全通、方向/水域 tile 有額外規則。

## 三、51 張正式地圖（完全唯讀）實際掃描
- 51張 MapXXX.rvdata；39張有使用 768..799 的特殊通行標記，總計**17,196 個格位**。
- Map003 尺寸 **40x29**，共有1,155格第三層通行標記：768阻擋642格、769通行503格、其餘10格方向性限制。
- Map010 含 785、796 等水域特殊值，需要照現有原腳本 flag 判斷，禁止一律視為一般通行。
- 全部資料 `R5_FORMAL_READONLY_AUDIT/R5_TRUE_FORMAL_PASSPASSA_THIRDLAYER_USAGE.json`。

## 四、實際 505 腳本相容性測試的障礙與解法
1. 首次完整505原封不動 + 額外 R5 測試頁，在 Main 前卡住。Window #32770 真的顯示：
   `FS_BattleRegression_AIEdgeI v1.0: undefined method 'p45b_prepare_resources' for class Module`。
2. 嘗試只在隔離版插入 Diagnostic bridge 後，出現下一個缺失 `p45b_restore_battle_skill_slot`。判定不是地圖管線問題，而是未對齊的舊 regression harness 方法依賴。
3. 最終**只在隔離副本**將第480頁 FS_BattleRegression_AIEdgeI 改為測試空白頁，其餘原始504頁數據元組保持 byte-exact，145 HK／146 Animated／342 ISS 逐頁比對一致，並在 Main 前插入一頁 R5 測試 Adapter。總共506頁（504未改原頁＋1停用回歸＋1新測試）。
4. 新測試 Adapter 曾因 Ruby ternary `to_s:"MISSING"` 缺空格而 SyntaxError（line39），已改為 `to_s : "MISSING"`。這次錯誤屬於 R5 測試工具，不是原正式 FS 的錯。
5. 之後真正 Windows `Game.exe` 在上述**受控條件**啟動，沒有覆寫原 K4_BASELINE 或 V6 地圖。
6. 正式未修改505頁完整啟動 Gate 明確**FAIL**；不得稱「完整505腳本原樣通過」。

## 五、隔離原生 VX 的實測結果
- 產出兩種模式：`HK_STATIC`（原 HK Par1.png + switch203=true），`DYNAMIC_ADAPTER`（HK 實例仍有 Viewport，但 switch203=false，在 @viewport1 新增3個獨立同源 PAR Sprite）。
- 每種實際 Windows Game.exe 完成5組兩角色測試，共10張 544x416 原生截圖。
- 真實 `RPG::Event` NPC → `Game_Event`，角色存在並於引擎中繪製，`R5_REAL_NPC_CLASS Game_Event`。
- HK `@par_viewport.z = 8` 確認，原生 @viewport1 z=0。STATIC `parVisible=true`，動態 `parVisible=false`，動態物件3組已配置。
- 真正呼叫 `$game_map.passable?` 和 `$game_player.move_up`：
  `mapPass769=true mapBlock768=true playerMovePass=true playerMoveBlocked=true`。**實際行走＋阻擋 TECH PASS**，非僅靜態ID。
- 兩版本都完成站位：玩家樹前/NPC樹後、玩家樹後/NPC樹前、皆前、皆後、空曠。截圖保存於 `R5_FORMAL_ADAPTER_ISOLATED/NATIVE_CAPTURE`。
- 以上 R5 只證明原 HK/ISS 共存、實際本機引擎可執行；不是可用畫面與材質的最終驗收。

## 六、視覺 Gate 仍未通過
- 正式 FS 內建其他色調/光影/雲霧/介面：「功能地圖」標題、額外動態效果及非常暗的場景，在兩輪 screenshot 都存在。雖然原素材 Ground 相同，但截圖非受控。
- 5組 STATIC vs DYNAMIC 同位置，非角色 ROI pixel diff 範圍 **73,685～80,876**；嚴重違反「背景一致」Gate，不可仿照 R4 宣稱 0px。
- 原生截圖與 Master 差異約18萬px級，不能把它直接當成 PAR 不對位的證據；原因是完整 FS 全局顯示與效果還沒剝離。
- 需要下輪同一 Native Process 原地切換 A/B（減少動態特效差異），或不修改核心前提下隔離 UI、天候與畫面色調；先有公平基準再做角色像素 Gate。
- 三個初始 SAM2 mask 本身仍只有局部物件，右樹混入灌木錯誤，整張精靈村的 PAR 完整性 Gate 明確 ART HOLD。

## 七、測試輸出及 Authority
- `stage_full_fs505_r5.py`：核對原 Scripts hash、robocopy 只讀來源成獨立505 clone。
- `build_full_fs505_overlay_r5.py`：從真505源產生獨立 Map001 第三層通行資料、Par1同源 PNG、Master Ground 輸出、R5 插入Adapter。
- `r5_disable_regression_isolated.py`：只在隔離頁480排除啟動異常；真 HK/ISS byte-exact，已由 `r5_final_gate.py` 驗證。
- `verify_full_fs505_runtime_r5.py`：原生 Windows Game.exe、實際移動 Gate、Viewport Gate、5張截圖。
- `analyze_full_fs505_r5.py`：真 VX 兩版 screenshot A/B，絕不宣稱藝術 PASS。
- `r5_scan_official_passa_maps.py`：正式51 map只讀通行權威掃描。
- `r5_authority_audit.py`：正式腳本 index 與地圖素材配置。
- `r5_final_gate.py`：頁面 byte-exact、Native LOG、10張實圖、原 map 路徑完整交叉驗證，總結判定 `R5_ISOLATED_HK_PASSPASSA_NATIVE_TECH_PASS_VISUAL_HOLD`。
- Windows 私人孤立工區：
  `E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027`
- 重跑：`RUN_R5_REAL505_TEST.cmd`。
- Deliverables zip 只含增量腳本、真 Native Captures、正式只讀 metadata、少量同源素材與 Handoff；大型完整 K4 clone 531MB 留本機，依據原本權威來源隨時可重建，避免私人資料多餘傳播。

## 八、R6 應先做
1. 使用相同一個 Game.exe Session 靜態/動態切換（停住背景特效/光影更新），確認人物 ROI 及非人物 ROI 的 Ground 保真 Gate；動態 PAR 只有實際需要的前後景才開。
2. 先修 R5 測試畫面「功能地圖」與天候/全局色調造成的背景差異；不修改正式 HK/ISS，只在隔離工程創建 Renderer Normalized 實驗。
3. 整張 SCENE21 物件遮擋語義自動標記（含屋簷／樹冠／欄杆）。新增 SAM2 positive/negative prompts、human Visual Gate，禁把假 Ground 一起整格複製當 PAR。
4. 用 Map003 40×29 的實際 ParaPassa 方向 Tile 檢查對 ground3 大地圖（只是地形通行數據 source，不直接覆蓋原美術）。
5. 原正式 FS 480 回歸 Harness NameError 獨立列為修復項。沒有完整 regression 可重現修正之前，不能修改 sealed 505，亦不能宣稱正式總體 PASS。