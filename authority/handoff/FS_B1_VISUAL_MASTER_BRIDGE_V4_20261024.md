# FS B1｜VISUAL MASTER BRIDGE V4｜CURRENT HANDOFF
2026-10-24｜STATUS: SOURCE-COMPILER + STRICT RGBA OWNER + NATIVE VX ISOLATED PASS / VISUAL BENCHMARK NOT PASS / SEALED FS NOT TESTED / HUMAN NOT TESTED.

## 本輪實作已驗證
- 同源重建 Rich Pilot V2，864x640：Ground、Par_COMPLETE、Master、Collision 對原 v2 原檔 0px 差異；真 grass/path 素材已存 v4 的 source/terrain，Manifest 含 SHA。
- 新增 24 ground flora，合計 91 個來源實例 100% source SHA，從同一 scene_manifest.json 輸出；與原 V2 Master 6,001px 視覺改動，原 48 PAR 及碰撞不動。
- 修復 RGBA difference().getbbox() alpha 相同會漏抓 RGB 漂移的錯誤，v4 的比對全用 RGBA bytes 或逐像素 tuple。
- 新 external Master Gate：原 master 0px；負向 RGB 1px=>1px、未登錄紋樣=>41px、房屋移位 1px=>14,508px、隱藏 Ground 空洞雖展平 0px 差異仍被來源＋不透明度抓出；Tiled independent 0px。
- Pixel Owner 嚴格重測：48 個來源物件、117,100 可見 owner pixels，212 個合法深度角色站位 0px 差異。
- 隔離原生 VX 的 2 個動態前後場景截圖，無關角色的背景像素差 0，前景物件被角色錯誤覆蓋 0；manual Game.exe 100 幀 smoke PASS。
- 已建立 ZIP，內含 Game.exe、腳本、來源、圖層、負向 QA、LOG、README。FS 正式封版 Scripts 未修改。

## 尚未解決
1) 圖像美術尚未達 ground3／SCENE21／SCENE001(1) 品質；異形建築、樹屋、神聖樹、河橋、高低區仍未施工；B1 Visual Gate FAIL／NOT APPROVED。
2) 外部 GPT 已展平完整圖不能直接還原被樹／屋遮住的 Ground。正式流程需保留來源物件 Placement Ledger、遮擋面與 Hidden-Ground 補繪。
3) Owner 支援 alpha=0/255，光影／透明水／橋上橋下跨層邏輯仍待研究。
4) FS SEALED RUNTIME 本輪未驗，使用者 Human Gate F 未驗。
5) 部分來源權利未核准，完整 ZIP 僅私人使用，不得公開發布其圖片。

## 下一步
P0：將具 benchmark 級外觀的 GPT／素材集直出場景導入新的 Visual Master Gate，產生差異熱區清單，優先以 Source Ledger 解決每個非地表物件及被遮蓋的地表補繪。
P1：保留像素銳利與現有視覺品質，增加至少一個真正不同輪廓的高品質旅館／樹屋組件，在 Manifest 下編譯，編譯及 VX 原生驗證。
P2：真實河橋高度語意與正式 sealed FS 隔離相容測試，通過才擴展完整精靈村和城堡鎮。

## 本輪交付
E:\GameAssetToolLab_20261023\FS_B1_VISUAL_MASTER_BRIDGE_V4_20261024_PRIVATE_VX.zip
START_B1_V4_GAME.cmd / RUN_V4_ALL_CHECKS.cmd / AUDIT_EXTERNAL_MASTER.cmd
請參考 README_繁體中文.md、logs/V4_VISUAL_MASTER_GATE.json、logs/V4_NATIVE_AUDIT.json。
既有 V3 Drive handoff：https://docs.google.com/document/d/1InLCJ1uCn8Pqbo-vWEWOjtZX55qxXoRILEnQZBA8lqU/edit
品質 Authority：https://docs.google.com/document/d/1Mv-ijuSH432yTd3ZtuK5Afj3daQYxuLTrKJYpGOAzI0/edit

## 本輪實際證據
- ZIP 內容：366 files、12,546,086 bytes；zip SHA256 64f08c1d66e126ed85192bbd1b3bc1fe21aa4f2a46d57920234738ba8625b41c。
- 整包重新解壓到另一資料夾，從新資料夾成功運行 Python compile/Owner/master Gate 與原生 Game.exe：PASS。
- 詳細 Drive Handoff：https://docs.google.com/document/d/1NUrTQQE2sdIhwNu49p9dAzn0sPrbDj7HjFIUSdtbA9c/edit
- 公開可重跑程式：tools/fs_b1_source_compiler_v4.py、tools/fs_b1_owner_depth_v4.py、tools/fs_b1_visual_master_gate_v4.py（無私有素材）。
- 所有源圖片及 Game.exe 只保存在私人 Windows ZIP，禁止公開推送授權未查明的圖像。
