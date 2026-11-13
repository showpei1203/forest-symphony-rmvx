# FS 劇情編輯器採用策略（2026-11-14）

## 原則
**先保留 VX 事件語意，後決定畫面編輯器，避免被單一第三方插件綁死。** 原始 MapNNN/CommonEvents 資料屬 FS Source Authority；目前 FSVXEventInterpreter.gd 是獨立的低階執行器。Godot 本體不提供完整 RPG Maker 事件頁編輯系統。

## 候選方案比較
| 方案 | 好處 | 風險 | 決策 |
|---|---|---|---|
| Kitchen Events (Sprite Kitchen) | 提供 RPG Maker 風格圖形事件列表、事件頁、開關、條件、常用事件、音效；作者聲稱 Windows Godot 4.7.2 已測試；MIT | 2026-10-25 發布、第三方插件有自己的事件格式及 Save API；不會自動匯入 FS RVData，未知是否相容 505 段腳本 | 先隔離試用，暫不納入正式依賴 |
| Dialogic 2 | 圖形化對話 Timeline、角色編輯、選項與條件，適合豐富劇情演出 | 官方文件仍標記 Alpha；不是完整 RMVX 地圖事件系統，FS 原始事件另需轉換 | 可作對話演出候選，不當 VX 事件核心 |
| 完全自建 FS Event Editor | 掌控所有舊事件命令、UI、數據和存檔語意 | 開發成本高，包含事件頁、編輯器、Undo/Redo 等基礎工作 | 插件不能滿足才自建 |

資料來源：
- Kitchen Events: https://spritekitchen.itch.io/kitchen-events-rpg-maker-style-events-for-godot
- Dialogic 2 docs: https://docs.dialogic.pro/
- Godot 4.7.2: https://godotengine.org/download/archive/

## 隔離試用驗收 Gate
1. 確認插件版本、授權與原始碼可審核度。
2. 測試 NPC 對話、選擇分歧、寶箱獨立開關、地圖傳送、事件觸發 FS BattleBridge。
3. 對接 FSGameState 的 switch/variable/self_switch/inventory/save，不得另存一套不一致的遊戲狀態。
4. 將具代表性的原版事件（含 355/655 Ruby Script）轉成候選格式，未支援必須明確報告，不得直接丟棄。
5. Godot 4.7.2 headless + GUI 與存檔 Gate 通過後才納入生產版，並固定插件版本。

**目前**：僅研究與制定驗收規範；兩個插件均未安裝，尚未納入正式 FS 專案。
