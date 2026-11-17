# Forest Symphony｜P537 原版 BATTLE 指令美術／真 ATB 介面｜正式 Handoff
日期：2026-11-18（Asia/Taipei）
**Godot 4.7.2 ONLY，BATTLE / MENU / 原版 UI 優先，A35 地圖整合暫緩，Phase1 SEAL=NO，ART HOLD。**
## 0. 延續而非重頭來
保留上游 [P536 真原圖 native Handoff](HANDOFF_20261118_P536_ORIGINAL_UI_NATIVE.md)、[P535 source 202 PNG Handoff](HANDOFF_20261118_UI_ART_535.md)、P532–533 真 Map→Event→ACT→Victory→Map 整合流程、FSBattle Tankentai 60fps ATB、FSVXBattleBridge、MENU 和 505 source audit。RPG Maker VX E: 只讀；不修改 main／A35／A52-A54 動畫工作線。新優先順序：BATTLE 的演出與美術 → MENU／各頁 UI  → 正式 A35 地圖。
## 1. 真正私有原版素材／來源識別
- Owner-only 202 PNG source ZIP：https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view，SHA256 c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6，202 PNG 逐檔 source SHA/CRC、private Drive shared=false。
- 實際原始 `Graphics/Menu/Battle01.png` 攻擊、`Battle02.png` 技能、`Battle03.png` 防禦、`Battle04.png` 道具、`Battle05.png` 逃跑；各 54×48，附對應 `Battle01a..05a.png` 低彩度版本。原圖經 Pixel 1:1 目視核對，並非按順序猜測指令。**只有 01～04 因已有合法遊戲指令真正接線，05 逃跑只存來源藝術，不新增不安全的逃跑機制。**
- `scripts/ui/FSUIArtLibrary.gd` 新增 10 張 Battle01..05 + a 原圖 SHA authority，與 P536 既有 Source BG/Btskin/Gauge/Portrait locks 並存，無來源則 fail closed，禁止公開 GitHub 存任何原版 PNG/RVData。
## 2. 本輪實際工程
1. `scripts/FSScreen.gd`：真正的 Attack/Skill/Guard/Item 按鈕根據源固定圖片 ID 01/02/03/04 對應美術，剛開始 ATB 未就緒顯示 `Battle0ia.png` 灰色且 disabled，當 `FSBattle.ready_actors()` 有合法就緒且沒有 queued ACT 時切成 `Battle0i.png` 彩色且 enabled。此切換是原系統事件真實結果，不是 UI 假 progress。原來的 `queue_actor_action` / 技能成本 / 目標優先權不變。
2. 首輪四個完整 54×48 圖直排，真 Godot 544×416 GPU 捕捉發現第 3/4 個被捲動擋住，**隨即修為 Godot `GridContainer` 兩欄 2×2**，可在同一原版 544×416 畫面看完整 Attack/Guard/Skill/Item；保留可用滑鼠／鍵盤與系統原生滾動。返回選單按鈕保留。
3. `scripts/ui/FSUIBattleHUD.gd`：在 P536 Btskin_main 135×40 + source HP/MP/OD 72×6 實際填充基礎上，將已存在 source panel 之 HP/MP 多段重複狀態改合併成一行短標籤，降低戰鬥 UI 垂直高度。缺 source 時仍是安全的原生 Godot Bars。
4. `tests/test_fs_original_battle_icons_537.gd`：真 Godot 4.7.2 項目測原 ACT Battle UI 的四按鈕、2×2 Grid, inactive/active 真 ATB 時序、私有圖有來源才有 icon、無來源 public CI 拒絕假裝私有美術、原 Battle05 不提供虛構 Escape。完整 P532–P536 系統回歸保留。
5. `tests/capture_fs_battle_icons_537_private.gd`：正式私人原圖原生 GPU 取證腳本，須手動 staged owner-only 202 PNG、設定明確臨時 `FS_UI_QA_DIR` 與 `FS_UI_QA_WIDTH`，同一原生真 Godot Battle `inactive→READY→attack target selector` 產生三張原生 PNG；各 544×416 或 1088×832；真機內檢查 valid icon/grid/ATB 後才寫。沒有 E:／user:// 寫入，不把 private PNG 加入 Github。
## 3. 真實 QA 驗證與私人封存
- P537 code source icon mapping commit [a33e3ea](https://github.com/showpei1203/forest-symphony-rmvx/commit/a33e3eab8a8c841eb86c229cd1ada919b6260d49)：已在 Godot public CI #44191578371 SUCCESS。
- 2×2 和 HUD 簡潔化 commit [c7d2b49](https://github.com/showpei1203/forest-symphony-rmvx/commit/c7d2b49555a9d2bba34215bba1e6c82d369efe04)：full GitHub native CI #44192136418 SUCCESS（84/84 steps，0 failed）。
- 真正可重現的正式 capture script 加 native Grid gate commit [db8a8ee](https://github.com/showpei1203/forest-symphony-rmvx/commit/db8a8eea07885da2178574c09a41617de90e5491)，其最後 CI #44192518222 需查完成狀態後才能宣稱 PASS。
- 真私圖 native 結果：由正式 db8a8ee GitHub source artifact 下載到隔離工作區，private 202 PNG source SHA+CRC staged，Godot 4.7.2 原生 editor import PASS；`FS_PRIVATE_UI_QA=1` 跑真 `test_fs_original_battle_icons_537.gd` PASS；source `capture_fs_battle_icons_537_private.gd` 用 **Mesa OpenGL 4.5 llvmpipe 真 Godot viewport** 產生 inactive／ready／select_target × 544×416、1088×832 = **6/6 真原圖原生 GPU PASS**。角色／敵人資料仍是明確合成 source-shaped fixture，非真正 original FS DB；不能稱原版 battle all ART PASS。
- **最終 P537 原生私人 QA ZIP**：https://drive.google.com/file/d/1CM3cQRXFT_-9TJm4v0t_Z2qDE58lvXiE/view ，`FS_P537_BATTLE_ORIGINAL_ICONS_NATIVE_QA_PRIVATE_20261118.zip`，415,866 bytes、SHA256 `68823205ea662501b097715c25e6131dc2036866ab842481799bb3ad00fce30f`，owner-only Google Drive provider shared=false，11 entries（6 原生 PNG + 4 logs + 1 JSON SHA manifest）。
## 4. Failure Log 與剩餘真風險
詳見 `FAIL_LOG_UI_ART_537_20261118.md`。原 4 張指令直排導致 544×416 一部分被捲動是實際 GPU 發現，已改 2×2 並重跑原生 GPU。仍 ART HOLD：原 BATTLE Scene 的 BattleScape 背景/舞台、怪物與角色正式戰鬥多幀 6/12+ A52/A54 動作、武器 Body/Weapon/FX 與 Hitstop、source state 的 11 post-Apply / 505 last-wins 動態權威仍未合併。原 `Battle05` Escape 是美術不是合法逃跑功能。未持有原 VX 同狀態截圖比對，不能叫 UI pixel-parity。這次軟體 OpenGL 驗證也不是 RX6700XT 實測。
## 5. 下一階段（仍 BATTLE 優先）
- **P537B**：讀取現有動畫工作線最新 A52/A54 正式 Handoff，再實際把角色動畫 Body/Weapon/FX 及怪物 Battlers／戰鬥舞台和 ACT 命中時間/Hitstop 整合到 `FSBattle/FSScreen`，以 owner-only 真角色／怪物原圖做 Godot 原生 GPU 與實際 ACT 操作 QA；不要倒退 VX 三幀，也別再做只有合成線框的 demo。
- **P538**：完整 Godot MENU 原版主畫面（`MenuBack_a` 本身是中性/空背景）、按鍵 Menu01..08、Item/Skill/Equip/Status/Formation 真來源布局及 9-slice；保留所有既有原版數值 Authority gates。
- A35 第一組真地圖與敘事 NPC 事件整合最後續，ART HOLD/PHASE1 SEAL NO，所有階段保留 GitHub code+Handoff、私有 Drive GPU ZIP+FailureLog。
