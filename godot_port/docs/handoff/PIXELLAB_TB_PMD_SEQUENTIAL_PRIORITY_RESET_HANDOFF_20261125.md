# Forest Symphony｜T-B｜2026-11-25 最新施工交接：PMD 編號來源改造正式取代 R22 Frost CHARGE
狀態：**新 PMD 來源／順序硬閘 QA PASS；新改造 PixelLab STATIC NOT_RUN；Godot 新改造 Native NOT_RUN；Owner ART PENDING**。

## Latest user authority
使用者：**「怪物的生成請參考pmd系列去改造，從0001開始按順序逐個參考改造。參考骨架和物種和size的比例，但配色和屬性和特徵（譬如種子變熔岩）可以自由改造。」**  
因此 **T-B 下一個完整美術工作單位變為 PMD0001 結構鎖定改造**，不得執行舊 R21 Handoff 寫的「R22 Frost Wolf CHARGE 8F ×3」，那是已被更新指令暫停的舊 backlog。既有 R21 Frost Wolf 三階與所有 108 clips/982 slots 正式成果維持唯讀，絕不覆寫或再付費。

## 本次實際完成的來源查核
- 讀取確認真正原始 PMD 原生內容：[G11 native/production/XML/SE45 742-file ZIP](https://drive.google.com/file/d/1jh4qmzu3vVD8Cr2mkPgPgU189eLohMRd/view) SHA256 `47fbdaa5c7088c5612c4e53d262a70e64017e965160bd50e55fcf5c12dfe921f`。確認 `ORIGINAL_0001, ORIGINAL_0002, ORIGINAL_0003`、正確 **southeast 45° = DIR_1**，而 DIR_2 是東側面 90°，不能混淆。Idle 原始各 stage 身體 bbox：0001 20×19（32×40 格）、0002 22×22（32×32）、0003 26×25（32×32）。
- 從既有 owner-private T-B 改造版單獨取得 `PMD0001_STATIC_64.png` / `PMD0002_STATIC_64.png` / `PMD0003_STATIC_64.png`；這三張**已改造的熔岩蛙**是歷史候選而非 PMD 原始生物。64px 畫布實測 alpha bbox **38×32 / 48×45 / 59×49**，寬比約 1:1.263:1.553，高比約 1:1.406:1.531。要保留 PMD 原始體型演化關係，不能將 3 隻不同身材縮成一樣；也不能讓新視覺大幅偏離 PMD 原始物種與四肢／頭身比例。
- 離線產出 8-file 58,692 byte **PMD0001～0003 原始 45° 與舊改造參考封包** [owner-only Drive](https://drive.google.com/file/d/1p1itnEuUnbZkqe6pRy012tZk8GIR-Avh/view) SHA256 `d9d8d4fb292e0122d02acdba497ead947217fb4ec19be117bee1b1bfad32c004`。真正 Google Drive 文件 metadata：shared=false、唯一 user:owner、原本 private parent folder；完整 raw zip 重新下載，獨立 SHA256、8-entry CRC、三編號來源和 manifest PASS。
- [真正來源 QA Metadata/JSON](https://drive.google.com/file/d/1k_jSj8FObcCxWaSgb_m2YcRhD0g7rMxt/view)，[第一隻 PMD0001 靜態改造前工作規格](https://drive.google.com/file/d/1Ljhh16UHzhHu4zdmW3DXHPv_Fee0lKU3/view)。由於使用者尚未要求特定屬性，此工作單以現有熔岩屬性作案例，但**自由換成其他屬性**；原背種子可變熔岩核心，頭身／四足／背負量／腳點不應變形；`existing PMD0001 lava 64` 是過往已存在的候選，不是這次又付費生成的成果。
- 可執行 [Source + sequence hard gate](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/fs_tb_pmd_source_gate.py)：正式 G11 ZIP SHA/CRC、original Idle 45° PNG SHAs、0001→0002→0003 排序、改造版 64px PNG 實際 bbox/各 stage 身體 size、現階段 plan 的原始 source SHA、物種 quadruped／四足。實際完全離線執行 **FS_TB_PMD_SEQUENTIAL_REAL_SOURCE_GATE_PASS**，三個負測（PMD 跳號／少兩足／未驗證 PMD0004）**3/3 REJECT**，Generation Cost=0。既有前階候選 ART 判定仍不能從這個 deterministic gate 推出。
- GitHub [catalog](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/PMD_SEQUENTIAL_SOURCE_CATALOG_20261125.json)、[PMD0001 計畫](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/PMD0001_FIRST_REDESIGN_PLAN_20261125.json)、[**最新總規範**](https://github.com/showpei1203/forest-symphony-rmvx/blob/feat/fs-pixellab-tb-monster-20261121/godot_port/docs/research/FS_TB_PMD_SEQUENTIAL_REDESIGN_PROTOCOL_20261125.md)。之前 Roadmap、T-B launch prompt 已加入最新規範覆寫聲明；舊文作歷史記錄不刪除。
- 核心 Skills 的正統來源 `showpei1203/tankentai-sbs-godot`, branch `feat/ai-agent-skill-library-20261123`, `ai_agent_skills/.agents/skills/fs-monster-evolution/SKILL.md` 已同步改寫到 2026-11-25 規範；原本 immutable v0.1.0 mirror **不予假裝已自動更新/部署 Windows**。跨對話優先讀最新 GitHub 正式 source + 本 CURRENT。
- 未執行：本輪**沒有**重新生成改造版 PNG、沒有 paid PixelLab POST、沒有重新跑 Godot 原生場景、沒有額外遊戲整合。原始 PMD licence/attribution 仍需審核，公開發布不能直接把第三方原始檔當自有資產。

## 固定後續順序
1. **PMD0001**：使用已確認 ORIGINAL SE45 0001 固定物種四足、背上種子／質量位置、頭身比例與 source size，不限元素換成岩／冰／機械等。先 1 隻完整靜態候選與原始同倍率對照。若沿用舊 lava 品種，只能標 REUSE_EXISTING_CANDIDATE，需重新對照，不能冒稱新作品。
2. 靜態 ART Gate **1× 原圖／改造／alpha & body ratios**；來源 SHA、授權、完整四肢與 source-equivalent proportions、Godot 4.7.2 native 技術驗證分離；有品質阻斷需記錄 Failure Log。
3. **PMD0002 → PMD0003**：按原始來源順序逐隻，不為 PMD0001 擅自再生三個同一級；沿用新世界觀可把背上花芽／花盤替換成裂岩／晶體／能量裝置，必須保留 natural evolution 成長尺寸與原物種形態。
4. **PMD0004 及後續**：先確認真正原始來源，G11 現有僅 verified 0001～0003；在來源缺失時 SOURCE HOLD，不可編號假冒；若要取得 PC 上的其他原始圖，按 AI PC routing 用經核准的嚴格**唯讀** task，零 Desktop Remote/Codex，不得任意掃檔。
5. 按一隻完整靜態角色、Animation / Godot native art-only、human ART、private Drive SHA 和 Handoff 的閉環向下個 ID 前進；舊 Frost Wolf CHARGE/RELEASE 留在 backlog，未經新指示不再繼續。

## 下一個完整施工單位
**PMD0001 新規格下的一隻改造候選 + 原始 45° 1× 身份／骨架／相對比例審核**，保留原先已花費的版權內部參考。ART 未批准不得聲稱量產合格。所有成本如未執行一律寫 0/NOT_RUN，絕不拿 R21 狼的 108/982 當成這輪 PMD 新素材進度。
