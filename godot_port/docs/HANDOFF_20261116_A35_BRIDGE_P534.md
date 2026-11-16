# Forest Symphony｜Godot 4.7.2｜P534 A35 R8 R3 PRIVATE MAP BRIDGE Handoff

**2026-11-16 | Phase1 SEAL=NO | ENGINE BASELINE PASS | PRIVATE A35 IN-PORT REAL GPU NOT RUN | ART HOLD**

## 0. 施工目標與現有權威

承接 P532–533 真可玩 synthetic 切片（Map999→VX301→ATB/ACT→601→Map1000→任務／記憶體進度），絕不倒退或改動 VX read-only 原始專案。這輪只改 feature/fs-godot-phase1 / godot_port 與 root .gitignore；不改 main、地圖工作線或 A35 已封存 Ground/PAR。跨工作線真素材來源：A35 branch feat/fs-a35-r3-hd2d-20261115，GitHub HEAD 4887b3d6247d07a174981eb5bc2ac9c6efee767a（地圖工作線仍可獨立推進）。A35 R8 R3 正式素材在 PRIVATE owner-only Drive：
https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view
檔名 FS_A35_R8_R3_GROVE_NATIVE_QA_PRIVATE_20261116.zip；provider 199,988,204 bytes，shared=false，ZIP expected SHA256 1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830；原始 Ground SHA256 3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000。

## 1. 實際提交程式與操作

1. tools/stage_private_a35_534.py：只接受已取得的原封不動 owner-only A35 R8 R3 QA ZIP；核對整檔 SHA、Ground 原始位元 SHA、ZIP CRC、文件合法性、內容目錄及單一正確 Godot scene。防 Zip Slip、符號連結與過大解壓；輸出拒絕覆蓋已有目的地。
2. 不合併 A35 的 res://scripts 等相對路徑到既有 godot_port/scripts。僅將 zip 內 scenes/scripts/ground/PAR 等原始素材保留在隔離的 res://a35_private/ namespace，所有相關文字資源的 res:// 引用改到該 namespace；PNG 原 bytes 未改。原 A35 project.godot 不覆蓋 godot_port/project.godot。額外生成 fs_private_a35_manifest.json，明確標識 FS_01_VILLAGE / ART HOLD / hash / origin。
3. .gitignore 明確忽略 godot_port/a35_private/，永遠不提交 PNG/ZIP/RVData 到公開倉庫。只在 owner-authorized ephemeral QA/build workspace 執行 staging；**不要在使用者本機建立常駐私有工程**。
4. scripts/story/FSPrivateA35Gate.gd：讀取 manifest、確認來源 ZIP SHA/原 Ground SHA、Scene PackedScene 可用，拒絕缺少素材／未驗證來源／未經原生匯入場景。無 synthetic 補圖路徑。
5. scripts/FSScreen.gd：只有真實 gate PASS 時在主畫面出現「A35 苔光村真實森林預覽（ART HOLD，尚未接事件）」；SubViewportContainer 子視口載入真 A35 原始場景，不覆蓋 P532–533 的原有可玩事件與戰鬥；提供返回選單。這是**來源場景預覽**，不是已接通正史任務／事件／戰鬥的宣稱。
6. tests/test_private_a35_stage_534.py：只用自建微型 fixture ZIP，五組測試覆蓋 path rewrite、dry-run、SHA 不符、Ground 不符、缺失原始場景／不安全路徑／拒絕覆蓋，絕不攜帶原版 PNG。tests/test_fs_private_a35_gate_534.gd 用真 Godot native 驗證缺原版私人場景時 fail closed。CI 完整既有 P532 流程同步回歸。

## 2. Native QA 逐一對照

- Commit: 25e521ca6557c4221cef37e652bb37df75287f24
- Full GitHub Godot 4.7.2 runner: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43818163395
- GitHub Actions job headless-smoke：SUCCESS，77 steps completed，failure 0。
- P534 Python synthetic archive staging safety PASS；P534 native Godot A35 gate missing-private fail-closed PASS；原 P532 real VX301→ATB/ACT→Map1000→save 流程 PASS；原有全套 Boss/Ivy/Weather/Animation 和 OpenGL QA 未退步。
- **未測**：真正 Drive 200MB ZIP 在 godot_port/a35_private staging 的 hash/read/write；完整 A35 真素材在同一 Godot project 的冷匯入／實際 GPU frame；真 A35 event marker、角色走路與 PAR 碰撞同 P532 VX301 戰鬥實際接線；正式 11-table post-Apply DB 和 505 runtime last-wins authority。不可把上面的 native gate test 當真圖 native QA。
- A35 原 workstream的 R8 R3 NATIVE/GPU/NAV PASS 與 ART HOLD 是其**獨立工程**已確認的成果，不能轉稱此主移植分支合併已通過。

## 3. 正確 staging 方式（僅於使用者授權的臨時環境）

1. 先從 owner-only Drive 取得原始 A35 R8 R3 ZIP（不要分享公開連結，不上傳 GitHub）。
2. 在可隨完成即銷毀的臨時 build/QA 環境先執行：
   python3 godot_port/tools/stage_private_a35_534.py --archive "/private/archive.zip" --dry-run
3. SHA/CRC 完全核對後，於同環境執行：
   python3 godot_port/tools/stage_private_a35_534.py --archive "/private/archive.zip" --output godot_port/a35_private
4. 以 Godot 4.7.2 原生 editor import 檢查並啟動 godot_port/project.godot；只有 gate PASS 才會出現苔光村真實場景預覽。未完整核對前不得宣稱原圖已整合。
5. QA 用完移除臨時 staging；唯一長期備份為 owner-only Drive archive＋ GitHub 的公開 source/metadata。

## 4. Failure Log / 待處理風險

參見 FAIL_LOG_A35_BRIDGE_P534_20261116.md。
- 已驗證本輪 7 檔 code stage 的 CI 成功，尚未使用私人 ZIP 本身執行 staging，所以 real-source import / GPU 是**NOT RUN**，不是 PASS 也不是 FAIL。
- 原 A35 actor 是 CharacterBody2D，會執行自己行走邏輯；目前只預覽原場景。還沒將 world/map_id、VX event interact、A35 footpoint、32px→HD-2D 畫面座標與 existing FSPlayableSlice 的 GameState 接成同一正式可玩世界。這是下一輪 P535 優先工程。
- 原 11 post-Apply 表／505 RGSS2 final alias witness 仍缺；原版 FS 戰鬥不可宣稱正式 migration.
- 沒有美術 ART SEAL，A35 ART HOLD 不變。

## 5. 下一輪優先

在「私人臨時 staging 真原圖 Native GPU PASS」後，建立 A35 場景中真實 CharacterBody2D / obstacle / YSort / 事件 marker 對 FSVXEventInterpreter / FSVXBattleBridge 的座標接線；用實際遊戲輸入逐段測試走路→NPC→戰鬥→返回苔光村，檢查「可視」不是「可互動」。維持同一 FSGameState；不拿原 Map999/1000 正式代替苔光村。再尋找完整 post-Apply 11 DB authoritative runtime witness。每輪提交 Handoff、Failure Log、Godot 原生 QA 證據，不碰 VX 原檔。
