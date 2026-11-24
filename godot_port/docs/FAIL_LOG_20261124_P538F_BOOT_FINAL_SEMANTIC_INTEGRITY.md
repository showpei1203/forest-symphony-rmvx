# FS Godot｜P538F Failure Log｜2026-11-24

**Project:** Forest Symphony 主線 `feature/fs-godot-phase1`（Godot 4.7.2），VX Source 唯讀；T-A/B/C 未動。與上一筆 `FAIL_LOG_20261124_P538E_TRUE_PRIVATE_NATIVE_UI.md` 銜接。

## ACTUAL authority blocker：RAW tables mistaken for final
- 重新核對私人 Drive 原始證據 [FS_P539F_RAW_VX_DATA_NOT_POST_APPLY_BOOT_AUTHORITY.json](https://drive.google.com/file/d/1Ot7NnCqtJ2ZsRIM3Sqxnf2yJyU43-kzH/view)，有 11 張 RAW .rvdata 來源 SHA 但 `postApplyRuntimeVerified=false`、`originalVXProjectEPathMounted=false`；搜尋後沒有可確認的 `fs_boot_final_runtime_witness.json`，也未獲授權操作使用者 PC 的 VX 進程。
- **HOLD 不等於 FAIL 的 native 程式碼**：Godot 確實還無法主張 11 表是執行 `FS_DB_AUTOSET.apply_all` 後的正式狀態；RAW→Godot 無法獨立推導 MasterSetup 22/505 RGSS2 effective alias 結果。不能根據假的 `vx_runtime_trace_verified:true` 直接解除來源關卡。

## Reproducible source consistency gap (synthetic negative fixtures)
- **R1**: 原 `FSDatabase.validate_witness_against_tables` 只核 table count 與 starting party。把 Actor[1].class_id 換成 999（但 records count/party 不變），舊驗證為 PASS；此 actor 根本沒有 Class #999 可用。即使 JSON+manifest SHA 重新計算，也不是正確的資料。**FIX `51f2acbc`**：在 `FSDatabase.load_all` 加 `validate_runtime_table_integrity`，逐表 id/index-null 以及 Actor→Class/parameter、Party→Actor、Troop→Enemy、Class→Skill 來源關聯 fail-closed，返錯阻止 boot_final_verified。
- **R2**: 模擬 11-table bundle 來源 `classes[1].learnings=[{skill_id:999}]`，重新 hash 兩端一致，原 `verify_boot_final_bundle.py` 的前置檢查只驗原檔 SHA，不檢學技能的引用。**FIX `9086939a`**：Python 同步新增 Class→Skills FK、初始隊伍重複、原 VX table id0 NULL 檢查，正反自我測試 PASS，原 JSON 完全恢復後重驗 PASS。
- **M3 truth standard:** 以上兩例都是**synthetic reproducer**，非宣稱發現使用者原 VX 真資料壞掉；本輪沒有真 CI native fail→fix。真 source postApply 數據尚未到手，不能評斷舊資料的有效 FK 是否全符。

## Native and independent regressions
- Godot `test_fs_p538f_boot_final_integrity.gd`：source-shaped 11-table baseline 1 + 12 false-source negatives，包含原計數 witness 可過但新語意 fail 的 negative control、未經來源驗證的 `boot_final_verified=false`。Official [#45309419061](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45309419061) **102/102 steps SUCCESS**（base code head `029d6a20`）。
- Python `verify_boot_final_bundle.py --self-test`：新「重新計算合法 SHA 的錯誤 skill FK」也 fail closed。Final official full [#45309636925](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45309636925) code head **`9086939a892a0e5902b5fda5bda898930504bf4d`**、**102/102 steps SUCCESS**；新 Godot step + Python step 以及全部舊 Battle/ATB/ACT/Story/Map QA 均 SUCCESS。102 是工作流 steps，不是正式移植功能數。
- No private source files, owner images, original E:\\ project or PC saved work modified. No actual VX execution attempted. Phase 1 Seal NO.

## Open holds and next engineering unit
- Full original runtime witness for `FS_DB_AUTOSET.apply_all` postApply 11 tables **NOT RUN/HOLD**, original 505 effective aliases & scene same-state VX graphics HOLD, owner RX6700XT native and human Art Gate HOLD.
- **P538G:** acquire legitimate VX boot-afterApply witness via already authorized read-only/cloud-only route only; if PC temporary export required, obtain explicit permission and detailed cleanup first, do not repurpose T-A bridge whitelist for the main workline. Once available, validate raw archive SHA, runtime stage, source 505 and MasterSetup 22, emit all 11 converted private JSON and witness on owner Drive with SHA readback, then run Godot main-game data load + ACT/ATB/UI tests. Otherwise advance code with explicit synthetic/source-authority boundaries.
