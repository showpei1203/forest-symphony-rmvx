# Forest Symphony | Agent Skills 導入 Handoff (2026-11-06)

## 狀態
- 導入方式：**隔離安裝 / 不覆寫任何 FS 正式工程**。
- 來源：`https://github.com/gamedev-skills/awesome-gamedev-agent-skills`，固定 SHA `19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9`，Apache-2.0。
- 測試根目錄：`E:\FS_AGENT_SKILLS_PILOT_20261106`。
- 自訂 FS router：`FS_RMVX_AGENT_SKILL.md`，已裝入 `.agents/skills/fs-rmvx-router/SKILL.md`。
- 上游已安裝：`router`, `create-game-assets`, `procedural-gen`, `level-design`, `godot-tilemap`, `godot-gdscript-headless-testing`, `rpg`（原始 scripts/references/assets 目錄完整複製）。
- 執行腳本：`fs_asset_pilot.py`。
- 逐項技術證據：`outputs/FS_AGENT_SKILLS_PILOT_QA.json`，預覽：`outputs/PMD0001_0003_3FRAME_CONTACT.png`。

## 本次已實測
- 10/10 元資料／工具／來源完整性檢查 PASS。
- A36F Ground／PAR／真合成 1280x928，真重組 RGB **逐像素完全相同**，平均通道誤差 [0,0,0]。
- A36F Ground 為 RGB，PAR 為 RGBA，PAR 具有效透明度。
- PMD0001～0003 每個動作 3 幀，共 9 幀；每張 128x128；三幀尺寸一致；透明度檢查 PASS。
- 上游 contact sheet 已真實輸出；假透明的 RGBA 負面測試成功被工具拒絕。
- 讀取前與驗證後的 A36F／PMD 檔案 SHA256 全部未改變。

## 不得誤讀
- 本次僅驗證**技術元資料和工具接入**；**沒有產生新房屋、森林或動作**，沒有宣稱美術改善。
- A36F R1 仍是歷史工程驗證 PASS / 美術 FAIL；此次並未重新啟動原生 VX／Godot。
- **Visual Art Approval = UNVERIFIED; Formal Seal = NO**。
- `create-game-assets` 的 Alpha 和尺寸檢查不能證明跑步交替、角色骨架、戰鬥動畫品質、完整林群或遮擋。
- 來源規則優先順序：Drive `SHARED_GAME_ASSET_GENERATION_AUTHORITY` → Drive `ASSET_GENERATION_PRECHECK_FS v3.2` → FS 專案最新 Authority/Handoff → upstream 通用 Skill。
- FS 主引擎為 RPG Maker VX/RGSS2，Godot 僅輔助 QA；`project.godot` 不得蓋過 FS 引擎分類。

## 下一個正式測試
1. 在另一個獨立輸出樹上對 PMD0001 從原版修改一個三幀動作；量測 45 度視角、左右腳交替、骨架與紙娃娃限制；視覺需人工驗收。
2. 在 A36F 副本上以整體完整建築 RGBA 和完整森林群 RGBA 進行 A36G 局部候選，輸出真 Ground／完整 PAR／Scene Manifest；VX/Godot 真機檢查。
3. 每次批次保留 before/after、SHA、故障紀錄，art Gate、runtime Gate 及正式封版分開。

## 可重跑方式（不需新增全域工具）
`python "E:\FS_AGENT_SKILLS_PILOT_20261106\fs_asset_pilot.py" --upstream "E:\FS_AGENT_SKILLS_PILOT_20261106\upstream" --pilot "E:\FS_AGENT_SKILLS_PILOT_20261106" --fs-skill "E:\FS_AGENT_SKILLS_PILOT_20261106\FS_RMVX_AGENT_SKILL.md" --a36f "E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103" --pmd "E:\FS_AI_STUDIO_PILOT_20261104_R2\outputs\PMD_R2_PARETO_CANDIDATE"`

## Project GitHub
https://github.com/showpei1203/forest-symphony-rmvx
建議以獨立分支納入 FS 路由規則、可重跑導入／QA 腳本和本交接文件；不得在沒有新美術／引擎證據時提升 A36F/A36G 驗收狀態。