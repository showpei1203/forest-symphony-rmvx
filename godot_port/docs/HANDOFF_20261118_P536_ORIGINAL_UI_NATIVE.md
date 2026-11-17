# Forest Symphony Godot 4.7.2｜P536 原版 UI 真圖原生驗收 Handoff
日期：2026-11-18（Asia/Taipei）
## 結論與不能倒退的工作優先權
**BATTLE 戰鬥／視覺演出 → MENU／原版 UI 美術 → A35 地圖整合（暫緩）**。Phase1 SEAL NO。原始 VX `E:\遊戲專案開發\三大項目現行專案\FS project` 只讀；地圖與動畫其他分支保持獨立，不重做合成 UI。
本輪 P536 真正取得**私有原版 202 張 UI PNG**與官方 Godot 4.7.2 Linux runtime，在隔離工作環境真正使用原圖進行 Editor Import、Godot OpenGL 4.5 Compatibility rendering 與自動 6 張原生截圖（544×416 及 1088×832 的 MENU／STATUS／BATTLE）。不能以合成單元測試冒充來源美術，本輪證據是實際原圖（但 ACT／actor/enemy 數值是明確合成測試資料，不是完成的 original post-Apply）。
## 正式私人源與 QA
- 私人原圖來源：`FS_GODOT_UI_ORIGINAL_PRIVATE_20261118.zip`，Drive https://drive.google.com/file/d/1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT/view ，Google Drive provider `shared=false`，8,371,041 bytes，202 PNG + manifest，SHA256 `c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6`。原始 PNG bytes 未改。
- **最終 HEAD 真 Godot GPU 私人證據 ZIP**：https://drive.google.com/file/d/17BwXCHAlhAEDZBUyH8fntmhPZiAyBGV5/view ，`FS_P536_FINAL_HEAD_NATIVE_QA_PRIVATE_20261118.zip`，536,708 bytes，SHA256 `aa51669780d209ccad894a3e6d5ce882b6bc52efe99ce828b0ebbef523db6d55`，Google Drive metadata 已 readback，`shared=false`。
- Final QA ZIP 含 **6／6 真實 Godot 原圖 GPU PNG**（MENU/STATUS/BATTLE × 544×416 + 1088×832）、Editor Import log、private native script PASS log、兩種尺寸 GPU log、Manifest 每個檔 SHA256。渲染器是 Linux Mesa OpenGL 4.5 llvmpipe 軟體驅動，**非使用者 RX6700XT 的硬體效能驗收**。
- 較早的第一輪私人畫面證據包（A/B 歷史）：https://drive.google.com/file/d/1PjNCtNBix-gRYWtq8ItP5YNFwcrOAZdc/view，529,724 bytes、private、保留供比較，但最終 HEAD 以 17Bw... 包為準。
## 真正執行的程式變更
1. `scripts/ui/FSUIOriginalVitals.gd`：經實物核對 `Btskin_main.png` 135×40 與 `GaugeHP/MP/OD.png` 120×48，**只取原 atlas (0,42,72,6) 的下方 72×6 顏色條**，覆蓋到原 HUD 底框（HP y7 / MP y19 / OD y31），以來源 HP/maxHP、MP/maxMP、OD/od_max 的實際比例裁切。未知或 0 OD max 保留空白（不能憑空指定 100）。
2. `scripts/ui/FSUIBattleHUD.gd`：原先直接把整張 120×48 Gauge 當裝飾貼上會露出多個圖層；修為有真圖時使用 source-original vitals 圖，缺私圖時使用真正 Godot 進度條；兩者均由原 `FSBattle.party` 數值驅動，ATB 保持原有實際 0～1000 source gauge。
3. `scripts/ui/FSUIArtLibrary.gd`：在既有 ZIP manifest/單檔 SHA 之外，對主選單背景、六位主角立繪、Btskin、Gauge、IconSet 建立獨立、固定的**真原圖 SHA256 lock**，拒絕偽造 manifest 替代圖。沒有原圖即 fail closed，不把 generated/mock 圖叫正式。
4. `scripts/FSScreen.gd`：經第一輪 native GPU 發現 STATUS 的立繪/文字重疊，改成 HBox 左立繪、右單角色實際數值面板，減小 UI 字體／間距。保留 ITEM、SKILL、EQUIP、FORMATION 與正常 target/ACT 操作，不回 VX。
5. `tests/test_fs_original_ui_536.gd`：Godot 原生確認 source atlas 72px 裁切、真 HP/MP/OD 比例與 0 上限拒絕、compact STATUS UI；public GitHub CI 要求 private 原圖不存在，私人隔離 QA 僅在 `FS_PRIVATE_UI_QA=1` 下驗真原圖可載入。
6. `tests/capture_fs_original_ui_536_private.gd`：正式可重跑原圖私有 QA；必須已 staged 私人 202 PNG，且明確設定臨時 `FS_UI_QA_DIR`，`FS_UI_QA_WIDTH=544|1088`，輸出原始 Godot GPU PNG；不使用 user://，不修改 E:，不寫進 GitHub public。
## 官方原生測試
- CI 導入工具用 public short-retention `fs-p536-public-godot472-engine` 與 `fs-p536-public-source`，僅公開引擎/程式供私有 QA 組裝，**絕不在 GitHub Action artifact 放私有 FS PNG**。Bootstrap commit `463256b1ffac2d143a06d474a2f3c6bd385d2131`。
- 初次 P536 原始 sprite-atlas 工程 `cc4717c97f20fb038e00a74f5d5945416f242d00`：CI #44189126860 FAIL（GDScript `draw_texture_rect_region` 第四參數錯把 bool 當 Color）；真 Godot Editor Import log 已定位，沒有隱瞞。
- 修正版正式 code HEAD `67987383cb84b36b17cbfe767316d8fdf04c6903`：修正錯誤 + private capture harness；GitHub **完整 CI #44189891079 SUCCESS，83／83 steps，失敗 0**：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44189891079 。
- 再從上述修正版 GitHub public source Artifact 重新裝配私人原圖，完整實測 **native Editor Import PASS、原版素材圖 SHA Gate PASS、 private Godot GDScript Native QA PASS、GNU/Xvfb OpenGL 544×416 3/3 + 1088×832 3/3**。每張 PNG 與 log SHA 在私人 ZIP 中。不是只對照程式碼猜測。
## 本輪 Failure Log 與 HOLD
詳見 `FAIL_LOG_UI_ART_536_20261118.md`。這次已修復源 Gauge whole-sheet 顯示及 STATUS 立繪／文字重疊，但 **ART HOLD 仍保留**。原版 `MenuBack_a.png` 本身是中性透明/空背景，當前 MENU 按鈕仍為 Godot 控制項，尚未還原原 FS 完整主選單裝飾／按鍵設計；BattleScape、角色/怪物、A52/A54 多幀動畫、武器接觸、FX、9-slice 視窗與真正 VX 相同情境截圖視覺 parity 尚未驗證。原本 post-Apply 11 表、505 RGSS last-wins 的正式戰鬥資料 Authority 未完成。不要寫美術全過／Phase1 封版。
## 下一階段（不可回去只做地圖）
**P537**：由現有真原版 BATTLE HUD 加上真正 BattleScape／Enemy Battlers／A52-A54 戰鬥角色 Body/Weapon/FX/ACT Hitpoint 的 Godot 原生場景與實際操作；用相同真素材原生 GPU QA；來源不完整就 HOLD，不再拿合成戰鬥圖冒充原版。**P538**：完整還原原版 FS 主選單、技能、道具、裝備、編隊及六角色狀態視窗／skin，維持原版 544×416 參考並支援 1088×832。原 VX 完整 post-Apply DB/source last-wins 引入仍是隔離 gate。**地圖 A35** 繼續排後但不刪除。每輪 GitHub code/Handoff + 私人 Drive 真 QA + Failure Log。
