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
| 創作後可自動 cloud-only 存 GitHub | NOT DONE | 原生 Save 寫 `res://`，只能在雲端隔離 runner使用或使用 Copy JSON 導入 GitHub；未建立安全遠端直接存檔 API |
| NPC 對話視覺演出／選項預覽 | NOT DONE | Interpreter signal ready，尚無遊戲內 dialogue UI |
| RPG 地圖編輯器+移動+互動事件 | NOT DONE | Marker 可擺放，但玩家互動程式／觸發器尚未整合 |
| 外掛 Kitchen Events | NOT ADOPTED | FS 原生工具已做可控 MVP；仍可隔離對比，不直接綁死 |
| 原版所有事件／505 RGSS script | NOT REQUIRED TO MIGRATE; PARTIAL COMPAT | 遇到未支援 opcode 明確阻擋 |
| MENU/BATTLE 外觀與數值 parity | NOT DONE | 仍是 Godot Phase1 專屬後續重要任務 |

**已通過證據**：
- https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/43529305543
- 以上測試全為 Godot 4.7.2 正式引擎，使用合成資料和範例；不是 51 張原地圖全量移植證據。

**下一階段必做**：
1. 真正可見的遊戲對話框/選項框 GUI 與原來源 UI 資產。
2. FS Story Preview Play mode，在 editor 按「測試此頁」可看到實際演出。
3. 跟 TileMapLayer／角色互動整合；map view 可選事件格子。
4. 更完整的指令庫／公共事件／循環／移動路線／播放音效／分頁觸發器；按原有需要逐步增加，不強制移植全部。
5. 原始 FS 戰鬥規則及 MENU/BATTLE UI parity 仍須同步推進。
6. 雲端直接保存 Google Drive/GitHub 的作者工作流，避免任何本地持久檔。

本階段採 WIP，不進行 sealed main merge。
