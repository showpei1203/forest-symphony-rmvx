# FS Godot P538A Failure Log｜2026-11-23

來源：owner-only 202 PNG SHA c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6。原版 Menu01–08 50x20、MenuBack_b 544x416、子頁原始頁籤 60x20，新增真正來源的 SHA，並且原 PNG 不上傳公開 GitHub。

## R1 FAIL→FIX：BATTLE 原生回歸因 MENU 清除流程遭破壞
- 觀察：新增 main menu overlay 後，官方完整 native CI #45101117251 FAILED at test_fs_battle_enemy_stage_537c.gd，訊息：battle screen must fill game window and keep source 2x2 commands visible。
- 原因：_clear_body 無條件 status_label.visible=true，BATTLE 原本正確隱藏的 debug chrome 被還原。修：限定在 view_name!=BATTLE 才重新顯示 status。commit 8b44b26。完整 CI #45101429156 SUCCESS，原 BATTLE/ATB/ACT 不退化。

## R2 FAIL→FIX：私有第二主角 fixture index
- 原 synthetic Data.database only actor1；誤假設 Actors[2] 在 QA 測試存在。非真正原版 RVData 欄位缺少。
- 修：僅於 private capture 測試建立合成 id2/name米亞 actor clone，不假裝正式表格，原版 米亞 立繪依私有原始 SHA 讀取；雙尺寸 544/1088 source rendering 成功。commit 6d09937。

## R3 成功但不是完整封版
- Official full Godot 4.7.2 https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45101720647 SUCCESS 97/97 steps, 0 failures。
- 本輪隔離雲端 Godot 4.7.2 OpenGL Mesa llvmpipe；14張 544x416＋1088x832 原版 UI 圖 source staging+editor import+native viewport PASS；不是本機 RX6700XT 實卡，也非原 VX 同一狀態 1:1 pixel parity。
- QA 私人 Drive https://drive.google.com/file/d/19x7wqwVbXInCR2OWWbbx9OGkafXrJ05B/view 1,965,809 bytes SHA256 c3fdeff4d3558231a7c6217ebbd1e95a05ffdc814a58f262803c71a519050001 CRC PASS，shared=false，owner only。
- 5 個原版選單按鍵可用；6–8 故意 disabled，不能當功能完成；子頁 tabs 當前是展示/來源驗證，次要功能未綁定。STATUS/SKILLS/ITEMS/EQUIPMENT/FORMATION 還有 developer chrome，ART HOLD。
- boot-final 11 Data source postApply witness / 505 RGSS2 effective runtime / original VX same-state compare / 完整 source scene / 原始實體 GPU P538A 仍 HOLD。
- 原 VX E:沒有修改；Desktop Commander、Codex、PC Bridge zero calls。下一完整單位 P538B。
