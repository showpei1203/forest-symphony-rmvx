# FS B1｜OWNER DEPTH V3 CURRENT_HANDOFF｜2026-10-24

## 已完成
- Rich Pilot V2 的 48 物件 / 864x640 基準只讀沿用，保留原完整場景像素。
- 出生與可達分析：原本五互動、12/12 原生雙引擎 smoke 的正式記錄已存 logs/RICH_V2_BASELINE_FINAL_REGRESSION.json（歷史成果，非本輪重測）。
- 新 Owner v3：117100 可見非 Ground 像素、48 物件 ID 及腳點深度、212 動態遮擋獨立 oracle 位置 0 差異。
- 原生 VX Project1 隔離副本，兩張 frame (8,2), (4,2) 動態 Screenshot native BG 0px 外部偏差；前景 owner 被錯誤角色覆蓋 0px；已執行實機 Game.exe。
- 負向 +1px 與錯誤靜態 PAR 的偏差可偵測，fail-closed。
- 本輪手動試玩副本在 VX_B1_RICH_MANUAL_PLAYABLE，關閉自動移位，等待人工走圖。

## 狀態（嚴格）
ENGINE ISOLATED NATIVE DEPTH PASS / VISUAL B1 2 of 9 PENDING / SEALED FS NOT TESTED / HUMAN GATE F PENDING / NOT FORMAL PASS.
已知圖樣過於稀疏，房屋僅換屋頂顏色，未達 ground3、SCENE21、SCENE001(1) 品質目標。不可宣稱完成精靈村。

## 問題與下一步
P0 保持 Direct GPT + 素材集生成的漂亮視覺構圖，編製源素材 ID/foot/masks/Hidden-ground 補繪規格，禁止直接從 flattened Master 假裝有真可編譯的 Ground/PAR。
P1 擴充至異形旅館/樹屋、河流/橋、神聖樹，且必須在 same manifest 下編譯。
P2 高度區域/橋上橋下語意切割，演算法預設只有 foot-Y，不能冒充 level-aware。
P3 已封版 FS Runtime 只能在隔離唯讀 clone 執行；既有 N5 B0 height gate 有 FAIL 紀錄，需另外除錯。
P4 人工美術驗收 Gate V + Human F 才可提升正式地圖。

## 交付
START_B1_MANUAL_VX.cmd / RUN_OWNER_V3.cmd / RUN_FULL_V3.cmd
outputs/、logs/、baseline/、input/、VX_B1_RICH_MANUAL_PLAYABLE/
ZIP 類型 = 私有技術測試包，禁止公開素材。每個 ZIP 含 SHA256、CRC 回歸。

## Source / Handoff identity
Google Drive: https://docs.google.com/document/d/1InLCJ1uCn8Pqbo-vWEWOjtZX55qxXoRILEnQZBA8lqU/edit
Private ZIP (not uploaded to public repo): E:\GameAssetToolLab_20261023\FS_B1_OWNER_DEPTH_V3_20261024_PRIVATE_NATIVE.zip
ZIP SHA256: 3485e4166bc01c1bb45ae7a48171be47ece47c1197faef7db270ae72d5060514
Pixel-owner code: tools/fs_b1_pixel_owner_v3.py
