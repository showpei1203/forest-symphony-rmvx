# Forest Symphony｜R13 32px 遮擋格新規則＋新版全村PAR候選｜2026-10-28

**Result：RULES UPLOADED，52物件原圖同源PAR TECH PASS，原生VX 2輪各14/14動作PASS，User Art Gate F HOLD。**

## 使用者正式修正
「角色走在地圖中，邏輯上會遮擋角色的32×32格都應該屬於PAR」；
- 樹 **整顆樹冠＋樹身**都要保留PAR，**只保留樹幹接地那一格 Ground-only**，不能按foot-y整排砍樹；
- 路燈、燈柱、欄杆、柵欄、橋側扶手、噴泉上半部、小型獨立立體物件均列PAR；
- 32格負責「應遮擋或否」語義；同格Ground/PAR像素可以混合。Ground永遠是同一張完整母圖，不重畫PAR；Collision是獨立規則。
- Red標註優先於SAM2；Blue硬排除Ground地面與台階。完整條文：`R13_PAR_OCCLUSION_TILE_RULES_20261028.md`，GitHub Authority：`authority/research/FS_R13_PAR_32PX_OCCLUSION_TILE_RULES_20261028.md`。

## 新版製作流程
- 現有新村莊 `R12_NEW_ELF_VILLAGE_001/MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png`，1280×928 (40×29)，保留原圖與原有R12 PAR14版不動。
- 執行 `r13_build_tile_first_par.py`，讀R12已通過的14 source masks，加手動登錄38個遮擋物件/群組（9棵新增樹，10個路燈，16段欄杆扶手，3種獨立立體設施/招牌），合計**52個獨立同源PAR**。
- 原有14內的樹亦套用全樹格與接地根格排除。**共12棵樹候選的接地格Alpha=0**（不代表全樹藝術邊界正確）。
- 補漏以人工多邊形與32格優先判斷。路燈/欄杆使用多邊形的同源像素，避免整格泥土都遮住角色；樹的大區域採保守tile snap確保枝葉/樹冠不被SAM2弱結果切掉。**多邊形和保守整格仍可能過遮：尤其廣場/花園/樹旁地面及橋的平面。這是需下一輪修正的明確限制。**
- 單一格可以註冊多個object ID/類別，`R13_GRID_PAR_CANDIDATE_REGISTRY.json`有844? 以本輪實測**843格**作為單格候選。置信度不是絕對美術真值。
- R12原PAR Alpha 233,875px，R13新版 **684,860px**，新加入 **453,725px**，相較舊版另外排除 **2,740px**，主要根格及地面台階候選，**不可假定所有2,740px移除都是美術正確**，需要局部檢查。
- 52獨立整幅(1280×928)RGBA物件容易耗盡32bit VX記憶體；`r13_optimize_par_crop.py`依每張Alpha非零bbox裁成最小 PNG，輸出 (left,top,z) 及原Master同源像素。所有裁切資產bitmap pixel footprint從61,767,680縮至1,147,942 px，約 **98.14%下降**。不代表真正遊戲FPS也改善相同比例。
- `PAR_R13_GRID_FIRST_SOURCE_CANDIDATE.png` 同源原像素RGB全通過；`R13_OBJECT_OWNER_16BIT.png`和`R13_32PX_OCCLUSION_GRID_QA.png`用於反查每格漏項/重疊；所有52件PNG和優化裁切PNG都有獨立檔案。

## Native VX 檢查
- 建立隔離版`R13_NEW_ELF_VILLAGE_NATIVE/FULL505`，從R12最後已經實機對上新Master的隔離環境複製，不碰原FS封版。
- 修改Test Adapter：由14來源深度Sprite改載52個 crop sprite，sp.x=object_left-camera.display_x/8, sp.y=object_top-camera.display_y/8, z=foot_y。修正先前所有透明大圖共用零偏移的資源浪費。
- 每輪14個原生`Game_Player#move_*`／NPC與橋/障礙/空地測試，兩輪不同Windows Game.exe PID重播，**14/14 + 14/14，共28張544×416實機截圖**。
- Fail Closed `r13_final_gate.py`：官方K4 Scripts505/Map003原SHA不變、正式504個原腳本page tuple unchanged／只在隔離停用舊#480 alias錯誤、原地圖二進位完全相同、新Master背景實際Cache取樣[3,22,18]、52個source mask逐個 RGB exact、12樹根格hard-exclude、crop bbox原像素完全一致、每次玩家/NPC移動pass、每個攝影機畫面52物件的世界偏移完全吻合。結果`R13_NEW_PAR32_GRID_52_OBJECTS_NATIVE_TWO_RUN_TECH_PASS_ART_HOLD`。
- 尚未跑全場ART前後遮擋A1/B/A2和長時間FPS；正式Map003的25個原始事件仍被隔離Adapter清除，未做正式故事/事件驗收。新Master正式地圖資產Key仍在隔離專用`ground3`別名，Production不可沿用。

## 本輪錯誤與改進
- 原始R12 14物件SAM2只切到大樹一部分，漏欄杆燈柱及小物：R13從**tile semantics**強制補完整樹冠及細長遮擋物。
- 第一版R13 52物件若全部整格Opaque，總alpha784,727px、大量廣場地板會被PAR遮人，判定Overcapture風險，未接受原版。第二版將欄杆/路燈改為多邊形直接來源像素，不再整格Opaque，alpha降為685,884px。
- 又發現原有R12選取的樹沒有同步排除單格接地樹幹底部，追加修正並重跑全pipeline，最新定版tech候選alpha**684,860px**。先前測試畫面不是最新補丁後的憑據，重新build並執行兩輪Native後才通過。
- 任何小地塊或高枝葉精細度的像素邊緣，單憑32格/多邊形仍可能過切。**本輪絕不稱這樣已是完美PAR**。

## 下一輪真正必做
1. 使用者後續依`R13_MASTER_PINK_PAR_COVERAGE.png` + `PAR_R13_GRID_FIRST_SOURCE_CANDIDATE.png`檢討，尤其廣場、欄杆周邊和房前台階是否過遮；將所有每格多物件真Alpha逐格精修。
2. 完整物件盤點，人工或分割工具追查所有未登記燈/欄/樹與小物；不能把843格視為自動完整率百分百。
3. Actor front/back、三個攝影機位置的A1/B/A2自動回復性、multi NPC、人眼1×截圖，動態地面與光影。
4. 新名字R12_ELF_VILLAGE_001資源Key分離、可靠Map.rvdata輸出，去除test-only別名，保護K4；Art Gate F後再 Seal。

**Formal FS SEALED維持不變；目前的新PAR版本是 R13 TECH CANDIDATE，Gate F HOLD。**