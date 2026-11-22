# FS P539F Failure Log｜2026-11-22 source #381 7 InfoRows 與目標 Dictionary 清空重大修復

R1 原 Battle 381 七個 extra_info_rows 完全未移植；原 #381 lines686–896 真順序 ManaShield→ATBResist→IvyCover→Break→StateResist→RobotProtocol→TargetPriority；現由 FSOriginalBattleInfo381共用Adapter source gating，#462選敵先 info 再state，不發明沒有來源的傷害／護盾等值。
R2 新 Source測試預期第6行 State77但前面同priority State50先排序，六行截斷到State50。Source priority規則本身正確；修 synthetic State77明確priority=9，native才PASS，不動遊戲原source語義。
R3 重大 bug（已修）：SourceTargetHelp.select/clear_source原先 active_target.clear() 其實會清空被參照的原Battle enemy/ally Dictionary。Godot CI source539f test最初報 line83 invalid index，診斷真正是刷新後 original enemy已被 clear。改用 active_target={} 僅放掉 UI reference；新native assert 對目標不停刷新、切換第二敵人、結束Help後 enemy name/HP/MP/states全部維持完整。這是戰鬥資料完整性而非純視覺修正。
R4 改造新 source InfoRows後，P539E舊未知State fixture原本只報1次錯，新 InfoRows和StateDetail分別報2次警告；修相同未驗證 battler 僅報一個 fail-closed來源訊息，回歸不再失敗。
R5 六個狀態資訊UI原左側面板可能壓原 #269 主角肖像 x9..144,y249+，新來源選敵詳情4–6行移到 x>=152，544/1088真顯示後目視角色肖像、HP/MP與怪物皆沒覆蓋，選敵Button仍保留。
R6 私有GPU script修測試時重複宣告 var enemy causing GDScript Parse Error，與 owner-only G guard誤沿用P539E路徑，兩者已修，真正R6測到原 SHA原圖 RadeonRX6700XT 544與1088各8/8 source PNG。
R7 原 VX boot-final：私人 ZIP有原 505 Ruby 與11 raw RVData資料SHA，但並非真 post FS_DB_AUTOSET.apply_all runtime；所需 fs_boot_final_runtime_witness.json未找到，預期E: FS project於目前遠端未掛載，無法有權威讀回，不得宣稱正式DB通過。

正式驗證：Godot4.7.2完整CI https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44998957776 completed SUCCESS 96/96 steps failed0。真原始source GPU16/16，544特殊信息物理差33712、1088差133517，私有 G Drive https://drive.google.com/drive/folders/1tWSHFtaIoPsohfL6pavJVCSCHnqACLRk。正式私人ZIP FS_P539F_ORIGINAL_381_SPECIAL_INFO_BOOT_RAW_SOURCE_PRIVATE_QA_20261122.zip 7189128bytes SHA 2f97554ac38a4c12c0e433d4c7489feabf13a37e221a9afd016a829dc6176237，37 entries CRC PASS。ART HOLD／Phase1 SEAL NO。

P539F 完整原版來源 QA ZIP 已以 Google Drive provider readback 確認只有 owner 權限（shared=false）：https://drive.google.com/file/d/1yfdT-Ra63t2fIl3U2LNULQr7Rh8d6Jha/view，7,189,128 bytes，SHA256 2f97554ac38a4c12c0e433d4c7489feabf13a37e221a9afd016a829dc6176237，ZIP CRC PASS 37 entries。不得將 private 原圖上傳 GitHub。
