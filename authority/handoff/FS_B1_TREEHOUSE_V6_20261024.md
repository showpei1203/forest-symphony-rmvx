# FS B1 TREEHOUSE V6｜CURRENT_HANDOFF｜2026-10-24
STATUS：ISOLATED VX NATIVE TECH PASS / B1 REFERENCE VISUAL NOT PASS / SEALED FS NOT TESTED / HUMAN GATE F NOT TESTED。

## 這輪實際已完成
一、遠端 Windows 舊版清理：先把 B1 v3、v4、v5 三份 ZIP 備份到 Drive，雲端檔案大小及本地雜湊一致；備份資料夾：https://drive.google.com/drive/folders/1RMgJpAnJ13rlj_6_D5yaPz8KSNkLfuSC。再刪除 11 項已被新版取代或重複測試文件，釋出 83.91 MiB，清理紀錄 E:\GameAssetToolLab_20261023\logs\CLEANUP_20261024_AUDIT.json。大型正式 Runtime、來源素材庫及工具環境均保留。
二、由素材集與源 SHA 原圖建立真正不同輪廓的高架樹屋：160x192，來源 4 種 Sprite，替換 grove_tree_south，x361 y142 footY334；有上層平台、梯子、樹幹、枝葉與屋頂。獨立 generator scripts/generate_treehouse_v6.py 可重建。來源權限仍私有。
三、B1 v6 48 立體物件／43 地表裝飾，134,793 個可見 Owner 像素，230 個合法深度站位 0px 差異。新圖相對 v5 改變 20,105 RGBA 像素；Ground 保持與 v5 0px 差異；同源 Ground/PAR/Master 0px；獨立 Tiled 0px。
四、V6 樹屋腳點、碰撞與後方／前方動態檢查：461 可走格全部可由出生點抵達，後方 (13,7) 與前方 (15,10) 合法。故意樹屋 X+1px 真正重編抓到 13,129px；假 SHA 編譯被拒；過大的碰撞盒會擋住原本前方合法站位也被偵測。
五、原生隔離 VX Game.exe 六張 screenshot PASS：原森林2、旅店2、樹屋後方／前方2。背景非角色像素錯位 0，前景 Owner 錯蓋 0；樹屋後方角色完全被遮蔽、前方角色正常露出，手動 Game.exe 不自動瞬移。正式 SEALED FS Runtime 並未動。

## 交付與測試
私人 ZIP：E:\GameAssetToolLab_20261023\FS_B1_TREEHOUSE_V6_20261024_PRIVATE_VX.zip
入口 START_B1_V6_GAME.cmd / RUN_V6_ALL_CHECKS.cmd / RUN_NATIVE_V6.cmd / AUDIT_EXTERNAL_MASTER.cmd。
原始 Sprite／Manifest／Ground／PAR／Owner／Collision／Native Game.exe／陰性對照／原生六張截圖／LOG／README_繁體中文.md／PACKAGE_FILE_SHA256.json 均附。
本輪 v6 ZIP 應同步備份到前述 Drive 資料夾，且必須檢查雲端真的出現才能刪除 v5 本機副本。

## 未完成與下一輪
樹屋梯子暫為視覺，真 level1 平台走圖與進出尚未寫入 RGSS2；橋上橋下與透明光效也未完。美術目標仍是 ground3／SCENE21 參考級村落，現有參考 Gate NOT PASS；還需要神聖樹、真河橋、更多合法的屋型與環境細節。
下一輪 P0 對樹屋建立明確 level0/level1 狀態、平台頂面與碰撞 owner 及可上下梯子的事件，做原生 VX 負向測試；P1 製作神聖樹／河橋 Source-backed 層；P2 Visual Gate 與 Sealed FS 唯讀隔離整合後才可稱正式完成。
上一輪 Handoff：https://docs.google.com/document/d/1JAgQuJ_626H_IbVjrLbgWT6eB1mqxVXvhPdjL8xbPtE/edit
參考圖 Authority：https://docs.google.com/document/d/1Mv-ijuSH432yTd3ZtuK5Afj3daQYxuLTrKJYpGOAzI0/edit
Linear issue SHO-39。

## Final backup and release receipt
Google Drive cloud-verified V6 private ZIP: https://drive.google.com/file/d/1wvyGVhTlDPnVlVcZlu8onhbc2mqDqlUo/view
ZIP bytes: 15,291,896; 431 entries; SHA256: ed40eded22f17611a1227a311a47a4711256c14fedc7124c7b2a4421f84d203b.
Full extract rerun PASS: 429 SHA checked, generate/owner/tiled/negative source checks PASS, isolated VX 6 original window screenshots PASS. FS sealed runtime NOT TESTED; B1 reference visual NOT PASS; human gate F NOT RUN.
Drive Handoff: https://docs.google.com/document/d/1zKF-oi2VvTB9lJZfmdhwNMTF0UicGNj-qWK1P0Cium0/edit
