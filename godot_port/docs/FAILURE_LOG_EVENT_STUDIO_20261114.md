# FS Event Studio｜QA / Failure Log（2026-11-14）

| Gate | 狀態 | 證據或未完成原因 |
|---|---|---|
| Source 原始 E: 只讀 | PASS | 本階段全部新增內容在 GitHub；沒有在 PC 生成檔案 |
| Event Schema/版本/頁面條件 | PASS synthetic | `test_fs_event_studio.gd`；真正 FS 關卡編輯尚未測試 |
| VX 指令編譯/結構檢查 | PASS synthetic | if/else、choice、reward、self switch、message |
| UI 面板建立/插入/修改/儲存/復原 | PASS native headless | `test_fs_event_studio_ui.gd`；真人 GUI 截圖未驗證 |
| 2D 事件標記、寶箱首次/再次互動 | PASS synthetic | `test_fs_story_map_marker.gd`；地圖碰撞/角色控制未接 |
| 舊事件不搬移的 opcode 相容入口 | PASS restricted | `interact_legacy_vx` 接原指令；非所有 opcode 支援 |
| Battle event 301→結果分支 | PASS synthetic | `test_vx_battle_bridge.gd`；不代表真正 FS 戰鬥公式 |
| 編輯器本機永久寫入防護 | PASS synthetic | `test_fs_event_studio_cloud_guard.gd`：未授權環境 write_event 阻擋且不生成檔案；GitHub Actions/核准隔離雲端例外 |
| 創作後可自動 cloud-only 直存 GitHub | NOT DONE | 目前無 OAuth/connector API；Copy JSON → ChatGPT/GitHub 仍需人工一步 |
| NPC 對話視覺演出／選項預覽 | PASS synthetic native | `FSDialoguePanel.gd`, `test_fs_dialogue_panel.gd`，對話/選項/取消正確；正式原 FS 像素視覺尚未驗收 |
| 當前事件頁免存檔預覽 | PASS synthetic native | `FSStoryPreviewWindow.gd`, `test_fs_story_preview.gd`, `test_fs_event_studio_editor_preview.gd`，使用獨立預覽世界狀態 |
| 544×416 合成劇情地圖 + 角色步進 + 碰撞 + 互動 | PASS synthetic native | `FSStorySandbox.gd`，寶箱、NPC 報酬一次、按鍵+調查測試 |
| 真正 FS 地圖 TileMapLayer + 觸發器管理器 | NOT DONE | 尚未將原 FS Ground/PAR/地圖層/實際角色事件整理整合 |
| 外掛 Kitchen Events | NOT ADOPTED | FS 原生工具已做可控 MVP；仍可隔離對比，不直接綁死 |
| 原版所有事件／505 RGSS script | NOT REQUIRED TO MIGRATE; PARTIAL COMPAT | 遇到未支援 opcode 明確阻擋 |
| MENU/BATTLE 外觀與數值 parity | NOT DONE | 仍是 Godot Phase1 專屬後續重要任務 |

**已通過證據**：
- https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43531883953
- 以上測試全為 Godot 4.7.2 正式引擎，使用合成資料和範例；不是 51 張原地圖全量移植證據。

**下一階段必做**：
1. 對話框/選項框已有中性可運作版；下一步導入私人 Drive 授權的 FS 原始 UI 資產，對比原 VX 像素、輸入/動畫。
2. 未存檔預覽已有原生視窗；下一步補角色移動/鏡頭/事件動畫的預覽。
3. 有合成測試地圖和角色碰撞/互動；下一步接真 TileMapLayer／地圖選事件格子與觸發器管理。
4. 更完整的指令庫／公共事件／循環／移動路線／播放音效／分頁觸發器；按原有需要逐步增加，不強制移植全部。
5. 原始 FS 戰鬥規則及 MENU/BATTLE UI parity 仍須同步推進。
6. 雲端直接保存 Google Drive/GitHub 的作者工作流，避免任何本地持久檔。

本階段採 WIP，不進行 sealed main merge。
