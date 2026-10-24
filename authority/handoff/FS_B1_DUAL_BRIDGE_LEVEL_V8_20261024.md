# Forest Symphony｜B1 DUAL-LEVEL RIVER BRIDGE V8｜CURRENT HANDOFF
2026-10-24｜ISOLATED VX SOURCE+NATIVE TECH PASS / REFERENCE VISUAL NOT PASS / SEALED FS NOT TESTED / HUMAN F NOT RUN

## 專案目的及 Authority
使用者認為直接向 GPT 提供素材集，生成的地圖具有好的創意／細節／豐富度，但其 Ground/PAR 分層常出錯。本專案目標在保留該美術品質，建立同源 Source Manifest → Ground/PAR/Owner/Collision/Height 與可玩的 RPG Maker VX；後續完整精靈村及城堡鎮以 Drive 範例地圖的複雜度驗收，不能拿稀疏候選代替正式完成。
繼承 v7（兩格樹屋 Level1、原多翼旅店、Source Owner），不回滾任何 SEALED 基線。

## v8 真正實作內容
1. 加入南側河道和橫向木橋；河水由來源草地與路磚 palette 參考加程序化 Pixel-crisp 水岸／淺灘生成 `source/terrain/river_patch_v8.png`，source SHA 鎖定；橋 160×108，x448 y419，foot y527，`source/clean/bridge_timber_upper_v8.png`，帶橋面、立柱、欄杆、繩索、吊牌、木板細節。所有來源在 `input/V8_BRIDGE_AND_RIVER_LEDGER.json`。
2. Manifest 同時定義 `water_semantics`：8 個深水 blocked 格，4 個河中心 ford 格可走但**只允許縱向移動**；`height_layers.timber_bridge`：上層 Level2 3 格 (15/16/17,15)、西岸入口 (14,15)、東岸 (18,15)，上層 actor z820 / 顯示上移 30px。原 treehouse Level1 繼續獨立。橋中央 (16,15) 同時存在 Level0 ford 和 Level2 deck，角色只能由正確入口切換，不能從橋下憑空上橋。
3. 新 `scripts/compile_scene_v8.py` 以同一 Manifest 讀入河面 Source SHA、產出 Ground／PAR／Collision 和 Tiled；現共 49 PAR 立體物件／43 Ground Flora，僅把水中央一個花叢移到右岸。畫面 Ground 比 v7 改 17,153 RGBA pixels，Master 改 19,497 px，橋 Pixel Owner 有 7,970 可見 px，場景總 144,225 Pixel Owner，239 合法地面深度 oracle PASS。
4. `scripts/native_vx_v8.py` 注入真正可玩的 RGSS2 Level2：橋上左右移動、上岸／下橋 C 確認、岸邊與深水阻擋、橋下縱向淺灘通行、禁止橋上跨邊界、禁止從橋中央切層、東西兩向皆可過。**17 個真實橋梁互動 Gate 加原 v7 樹屋 8 個 Gate PASS**。
5. 真 `Game.exe` 擷取 13 個原生角色畫面（兩樹／兩旅店／兩樹屋前後／樹屋 Level1 3／橋下／橋上西與中／東岸），非角色背景錯位 0、非法前景蓋圖 0；橋下局部被橋面遮住，橋上顯示在橋板之上。地面 452 個可從出生點到達的格子，Level2 另外3格。
6. `scripts/audit_bridge_v8.py` 從 Manifest＋原始遮蔽下 Ground 驗證來源／碰撞／路線／畫面同源，負向橋體 x+1px 重編偵測 2,058 RGBA mismatches，偽造水與橋的 source SHA 均拒絕；Tiled 獨立渲染 0px mismatch。
7. 正式 SEALED Forest Symphony Runtime 未修改，候選 Level2 僅在 isolated VX Project1 中可玩；素材權利狀態 PRIVATE，不可放公開 GitHub。

## 交付及 LOG
最新完整 ZIP：`E:\GameAssetToolLab_20261023\FS_B1_BRIDGE_DUAL_LEVEL_V8_20261024_PRIVATE_VX.zip`
直接玩：`START_B1_V8_GAME.cmd` → Game.exe；source gates `RUN_V8_ALL_CHECKS.cmd`，原生 gates `RUN_NATIVE_V8.cmd`，外部 Master `AUDIT_EXTERNAL_MASTER.cmd`。
保留 PNG Source／Manifest／Ground/PAR／visible Owner／獨立 Level1 Mask／River 與 Bridge／原生 13 截圖／LOG／README／SHA manifest；總結報告在 `logs/V8_NATIVE_DUAL_BRIDGE_AUDIT.json` 和 `logs/V8_DUAL_BRIDGE_CONTRACT_GATE.json`。
v7 雲端封存：https://drive.google.com/file/d/1r-xlmkTTk2snDWB9xJHgJu6oH-H95qeu/view
Authority Docs：https://docs.google.com/document/d/1ULgzaZIDOzpfMe9moZogdgI56dvf-2Xic6GH1sbQKak/edit
Linear SHO-39。

## 下輪工作與嚴格限制
P0 原生 Level2 橋完成可重用高度 schema，下一個是針對真河橋擴大可走空間與坡道/橋面邊界，解決 32 格硬跳樓造成的動畫不自然。
P1 神聖樹 source-backed 大型模組、建築種類／門廊／河岸／生活物件充實，直到參考圖視覺 Gate PASS；現階段孤立測試圖仍偏稀疏。
P2 正式 Forest Symphony SEALED Runtime 唯讀隔離相容測試，Gate F 人工圖層與可走驗收後才可正式整合與擴展城堡鎮。
封版 FS 未測、Visual Reference 未 PASS、Human Gate F 未測，不得宣稱 FORMAL PASS。
本機清理策略：舊的 v7 展開工作資料夾和重複 test 只有在 v7+v8 雲端私人 ZIP 皆存在並逐檔 SHA/CRC 驗證後才刪除。SEALED FS / Forest FINAL / Source / Tools 一律保留。

## 最終 Private Release Evidence｜2026-10-24
Google Drive 官方雲端端（已列出並確認大小）v8 Private ZIP：https://drive.google.com/file/d/1XHBeza2Bp09Hq-68XvzEFRmhPL7qzJPx/view
File: FS_B1_BRIDGE_DUAL_LEVEL_V8_20261024_PRIVATE_VX.zip；17,095,059 bytes；451 ZIP 項；SHA256 2d36734a479fe56d4544a1656ec5473d21b57f54e14e22fc9e99c8e756f1a69f。由 Windows Google Drive G: 複製並且與 E: 原始 ZIP SHA 完全相等，ZIP CRC 檢測 PASS。
自已封裝 ZIP 獨立解壓：449 項來源檔逐檔 SHA PASS；Source Generator、Visible Owner、Level1 Mask、v8 River-aware Tiled Master、v8 bridge negative tests 共五項 PASS；再由解壓檔啟動真正 VX Game.exe，十三張原生截圖與橋17+樹屋8共25個互動 Gate PASS。正式 SEALED FS 尚未測，不可標記 FORMAL PASS。
Docs Handoff：https://docs.google.com/document/d/18XZqneH0Wwt0TRDmn5XadbtgML7KUgvSLEt-1E5CJXM/edit
公開 GitHub 不含任何未核准 PNG/Sprites/ZIP。


## Fourth cloud-verified local cleanup (2026-10-24)
Both v7/v8 PRIVATE ZIP archives exist in Google Drive and pass E:\ / G:\ SHA256+ZIP CRC verification. Following v8 native VX 13-screenshot/25-interaction and extracted source Gate PASS, obsolete v7 expanded workspace, local v7 ZIP, and extracted v8 regression duplicate were deleted from local Windows. Fourth cleanup freed 50.13 MiB; total four stages **227.11 MiB**. Audit `E:\GameAssetToolLab_20261023\logs\CLEANUP_20261024_FOURTH_AUDIT.json`. Current playable v8 Game.exe/ZIP, original source assets, tools, accepted Forest FINAL, sealed FS runtime, and both private cloud archives are preserved. Cloud v8: https://drive.google.com/file/d/1XHBeza2Bp09Hq-68XvzEFRmhPL7qzJPx/view .
