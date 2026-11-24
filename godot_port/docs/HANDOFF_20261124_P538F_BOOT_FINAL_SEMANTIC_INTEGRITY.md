# Forest Symphony｜P538F｜正式 VX boot-final 11 表語意完整性防線｜2026-11-24

**工程線：** Godot 4.7.2 正式移植 `feature/fs-godot-phase1`，T-A/T-B/T-C 各分支不動。原 VX 只讀；新程式/紀錄存 GitHub，使用者 PC 零寫入。

## M0：讀取來源，辨別真 RAW 與 boot-final
- 讀取正式 `CURRENT_HANDOFF.md`、`FS_GODOT_MASTER_ROADMAP_20261114.md`、`FSDatabase.gd`、`verify_boot_final_bundle.py`、原先 `test_fs_boot_authority_guard.gd`、GitHub Skill `.agents/skills/fs-rmvx-router/SKILL.md` 和 `authority/FS_CURRENT_RULES_INDEX_20261107.md`。現行使用者決議：**Godot 4.7.2 是正式目標引擎**；舊 Skill 的 VX 主引擎說法不覆寫。
- Owner-only Drive 真查核 [FS_P539F_RAW_VX_DATA_NOT_POST_APPLY_BOOT_AUTHORITY.json](https://drive.google.com/file/d/1Ot7NnCqtJ2ZsRIM3Sqxnf2yJyU43-kzH/view)，內容標記 `postApplyRuntimeVerified:false`、`originalVXProjectEPathMounted:false`；原始 11 張 RAW RVData 有來源 SHA/位元組，**但不是 FS_DB_AUTOSET.apply_all 之後的 11 張正式資料表**。Drive 亦未找到可核對的 `fs_boot_final_runtime_witness.json` 或真正 postApply 證據。從原始資料推算正式表、或假裝同名 JSON 就等於真 VX runtime，都是拒絕事項。
- 前階段 [P538E 真 Godot 原版 44 張 UI QA](https://drive.google.com/file/d/16wtWALH4oJvrPIfxfAoYKGwoDwnK0GLp/view) 及 [P538E 真引擎 101 steps PASS](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45301488209) 完整保留。P538F 沒有更改任何原版 PNG/戰鬥 UI 或對使用者 PC 遠端操作。

## M1：實際可執行的資料/安全施工
1. 原先 `FSDatabase.load_all` 的 `validate_boot_manifest` 對 11 個檔案做每檔 SHA，`validate_runtime_witness` 做來源 stage/數量/隊伍，`validate_witness_against_tables` 只比筆數與 System party。**缺口：同筆數的 Actor.class_id、Actor.parameters、Troop.enemy_id 或 Class.learnings.skill_id 被改成不存在的 ID，全部檔案重新哈希後，舊 Gate 沒有足夠的跨表語意檢查。**
2. commit `51f2acbc6641517b6584e42feabb650819914730` 在 `godot_port/scripts/FSDatabase.gd` 增加 `validate_runtime_table_integrity()` 並在 `load_all` 正式入口 fail-closed 叫用：11 種類別的原始 VX null-zero index／每筆 id=index、Actor→Class、Actor 六維 `RPG::Table` (6×level, int16/signed/size)、System party actor IDs+重複、Troop→Enemy、Class→Skill 引用。任何錯誤使 `load_all` 拒絕，不能把憑空補的類別當成來源正式資料。**此檢查僅測已涵蓋欄位，不等於所有 RGSS2 505 alias 已完成。**
3. commit `b9c7895e12bc6ae1427061cc744e838561fb4bfc` 新 `godot_port/tests/test_fs_p538f_boot_final_integrity.gd`；1 組 11-table source-shaped 正常 fixture + **12 組明確負例**（類別 ID、parameter 長度/值域/維度、隊伍 FK/重複、Troop 敵人 FK、Class skills FK、記錄索引、id0 null、表型、System 來源 roster）。特別驗證當 Actor.class_id 變更但表筆數及 witness roster **完全一致**時，舊 `validate_witness_against_tables` 沒有抓到，而新增 Gate 會拒絕。這是人工造的 negative control，非 VX 真執行資料。
4. commit `9086939a892a0e5902b5fda5bda898930504bf4d` 同步 `godot_port/tools/verify_boot_final_bundle.py`：匯入前 Python 現在獨立驗 source array `[0] is None`、System party 重複、Class.learnings.skill_id 是否真指向 Skills；增加**重算合法 SHA 但引用不存在技能**的自我測試，避免只靠 SHA 卻忽略壞連結。原始 Python 的 Actors Table/FK/Troops 檢查繼續保留。
5. commit `029d6a20bd8a04205a1fdbb21229122810b73fd0` 在既有 GitHub full workflow 加入 P538F 這項 Godot4.7.2 native 必過 gate，不刪除先前 QA。

## M2 官方 native / 雙獨立來源
- 第一輪 code head `029d6a20bd8a04205a1fdbb21229122810b73fd0` GitHub Actions [#45309419061](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45309419061) **102/102 workflow steps SUCCESS**；包含 P538F 12 negative control 與原完整 101 項/工作流步驟。
- Python preflight 補強後最終 source code head `9086939a892a0e5902b5fda5bda898930504bf4d` GitHub Actions [#45309636925](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45309636925) **102/102 workflow steps SUCCESS**。其中 P538F Godot 原生步驟和 `verify_boot_final_bundle.py --self-test` 獨立 Python 步驟均確定 SUCCESS；以前 Battle、ACT、ATB、Boss、Quest/Event、Maps、真原版 UI source-dimensions 回歸全綠。
- 警告：102 是 workflow **steps**，不是 102 個原版功能完成；新的資料驗證使用合成 source-shaped 11-table fixtures，**不是已從 VX 取得真 postApply witness**。

## M3 重現缺口與修正
- 可再現資料完整性漏洞：把 synthetic Actor #1 `class_id` 改成 999，保留記錄數與原始 party，舊 `validate_witness_against_tables` 回傳空錯誤，**新增 `validate_runtime_table_integrity` 正確拒絕 Actor 職業不存在**。其它 11 組類似反例均被拒；不冒充從原 VX 玩到這些錯誤。
- 可再現 re-hash 路徑：Python synthetic bundle 先 baseline PASS，再把 Class 的 `learnings` 改成不存在 Skill #999、**同步更新 JSON 與 manifest SHA**，原單純 hash gate 無法辨識，此時新增 Python 語意 Gate 回報 `class ... learns missing skill`；還原來源數據及 SHA 後 PASS。
- P538F 官方 Godot/Python CI 均首次 PASS，**沒有捏造 CI 引擎 FAIL→FIX**。真來源未知的部分保持 HOLD。

## M4 雲端持久成果及 HOLD
- 正式程式、測試、失敗因子、完整 Handoff 及 Roadmap 優先存本分支 GitHub；此次**未新製作任何來源私人 PNG／RVData／VX runtime ZIP，不需要憑空製造 Drive 照片來冒充 M4**。舊 RAW 11-table evidence 仍在私人 Drive、原始檔不改。Github 絕不公開上傳 RAW 私有素材。
- 電腦/工具：GitHub Connector + Google Drive Connector + GitHub Actions runner；**Windows PC 新檔案 0、Codex 0、Desktop Remote 0、PC Bridge 0、VX 現場執行 0**，未安裝工具。
- 現行仍 **HOLD：真 VX `FS_DB_AUTOSET.apply_all` 後的 11 個 JSON + 來源真 runtime witness（SHA），505 RGSS2 alias/effective runtime 對照，原版 VX 與 Godot 相同狀態像素/字型、使用者 RX6700XT GPU 與美術批准**。RAW 的來源 SHA 和本人未授權的模擬樣本絕不能代替 postApply 有效證據；**Phase 1 SEAL NO**。
- 下一完整工程 P538G：在明確授權且遵守 Cloud-only 的原版 VX read-only runtime 中，先取得 **事件前、apply_all 後** 11 張原始資料輸出、不可偽造的來源過程佐證及 505 runtime symbol witness，立刻以已完成的 Python + Godot 兩道 Gate 核對，使用真表跑初始 Party/Skill/Equip/Troop 回歸；若無安全執行權限，先繼續 source-proven 事件/技能移植及 negative gates，但不得假稱原 VX 已可執行或來源表已驗完。更多長期 Event Studio 不可取代主線移植。
