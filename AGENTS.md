# Repository Agent Rules

## GLOBAL HARD RULES 001 · 2026-11-07 · 優先於所有舊專案 SOP
在任何會產生／保存檔案的任務前，**先讀** [00_GLOBAL_HARD_RULES_跨對話最高優先規範](https://docs.google.com/document/d/1NftePmIsggrhnfPcZTZS2G6YBka2yBy_fdw-NBT5D8Y/edit)。所有新開發成果、原始碼、圖片、工程／ZIP、研究、QA／LOG、截圖及 Handoff，永久保存目的地只能是 **Google Drive 或 GitHub**；私人／敏感資料只進有適當權限的 Drive 或私人儲存庫，嚴禁推送公開 GitHub。使用者 PC **不得**作為新的工作目錄／Git clone／成果庫／備份庫。必要安裝及其不可避免的 Runtime 環境檔例外。確實必須在 PC 建立臨時工作檔時，必須**事前說明原因、範圍、清除方法並取得使用者授權**，不是自動允許；完成雲端 WRITE→READBACK→VERIFY 後清除臨時檔。不要擅自刪除／遷移舊 PC 檔案。
若舊腳本硬編碼輸出到 `C:\`／`D:\`／`E:\`／PC 同步磁碟 `G:\`，未改成真正的雲端路徑、或未取得上述臨時執行授權，不得直接執行。歷史 QA、封版、來源 SHA、專案技術規格仍有效；本規則只更新開發**工作檔案的持久儲存與驗收方式**，不變更正式功能、使用者裝置/App 自己的資料持久化需求。

**所有 Agent（無論是畫面、PMD、腳本或測試）必須先讀 [FS Current Rules Index](authority/FS_CURRENT_RULES_INDEX_20261107.md)，再按 P0／Precheck／Skill 作業。** 任何仍寫本機保存、Ground-first/直接 Ground+PAR 雙圖「最新」或 GitHub 尚未連通的舊文本均由索引覆寫。

## P0: 新產物只保存至 Drive/GitHub（2026-11-07，新舊文件均適用）
任何 FS 專案素材、Sprite、Ground/PAR、測試截圖、ZIP、LOG、Handoff 和備份都必須保存雲端（私人圖像→Google Drive；程式/規範→GitHub），**不得把使用者 PC 當工作檔案或長期儲存位置**。必要軟體/Runtime 安裝可存在 PC；原生 VX 實機非得本機執行，只能建立最小臨時副本，完成雲端驗 SHA 後清除。**舊指令中 `E:\`/本機 cache/output 皆為歷史例，不得重新使用。**進行任何任務前先讀 [FS P0 Cloud-only](docs/FS_CLOUD_ONLY_STORAGE_POLICY_20261107.md) 及 `.agents/skills/fs-rmvx-router/SKILL.md`。
FS 新精靈村的現行順序是**完整 Master-first → AI 語意 Mask /隱藏地表補畫 → 母圖同座標 RGB 取得 PAR → Authoring／Runtime 四層 → VX 真實碰撞/角色遮擋／美術 Gate**，不是另生 Ground 與 PAR 兩張相似畫面。

For any image generation, image editing, game-art asset production, parallax/master-scene generation, sprite generation, icon generation, or visual-asset prompt work in this repository, **read `ASSET_GENERATION_PRECHECK.md` before generating or editing any image**. Follow its required read order and the linked shared Google Drive authority.

For any runtime, AutoRegression, validator, generator/compiler, long-running tool, automation, or test-harness design/change, **read `BACKGROUND_EXECUTION_AUTHORITY.md` before implementation**. Background-capable execution is a permanent project requirement; losing foreground focus must not unnecessarily stop automated progress. Do not use unsafe threads as a shortcut, and preserve existing SEALED/runtime safety rules.

Pure documentation work that changes neither visual assets nor executable/runtime/test/tool behavior does not add extra preflight beyond the existing project authority.

## Forest Symphony Agent Skills routing (2026-11-06)

For Forest Symphony / RMVX / RGSS2 / A36F-A36G Ground-PAR / PMD or ACTOR sprites, **read `.agents/skills/fs-rmvx-router/SKILL.md` first** before any generic `router`, `create-game-assets`, Godot, or procedural generation skill. It holds FS-specific precedence, engine identification, preserved art and runtime acceptance gates. A nested `project.godot` is not evidence that FS runs primarily on Godot.

Upstream game-dev skills are pinned and installed separately using `tools/agent_skills/fs_asset_pilot.py` into an isolated pilot directory; never silently auto-upgrade the upstream dependency. Reference evidence: `experiments/agent_skills_20261106/CURRENT_HANDOFF.md`. Installation is not artistic approval or proof of a new VX/Godot native test.
