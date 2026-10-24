# FS B1 MULTI-WING LODGE V5 | CURRENT HANDOFF | 2026-10-24

## Authority 決議
必須保留 GPT 搭配素材集的漂亮地圖品質，主攻 Source Manifest / Ground / PAR / Occlusion / Pixel Owner / Collision 的正確對位，正式完成地圖視覺要達 Drive 六張參考級豐富度。前幾輪技術 PASS 不可冒充全圖完成。

## 本輪完成
1. 以 house_A、house_shop、broadleaf_oak 真實來源圖 + 原創 pixel-crisp 門廊／閣樓窗／階梯／吊牌，生成新 source-backed 多翼旅店 160x192，替換原東側 96x160 單屋，x550 y76 footY268，私人來源 SHA 2fc53a21dcce376b4f61b3c5766b1686c1f966b05e1880c36f2c07f733c4f4bf。修改 lamp_shop 位置，其餘 46 PAR 與 43 flora 未動。
2. 修正原旅店碰撞 [15,140,154,190] 過深問題為 [15,140,154,178]，保留門廊合法前方重疊。旅店後方 (19,5) 18 步、前方 (19,8) 15 步，皆自出生點可到達；464 可走格 464 可達。
3. 48 PAR 物件 123,612 Visible Owner pixels，219 個合法角色重疊位置 oracle 零差異。新 Master 對 V4 改動 23,360 Pixel，但仍由同一 Manifest 同源編譯 Ground/PAR/Collision。
4. 新旅店故意 X+1px 真實重新編譯，偵測 17,318 Pixel 差異；偽造來源 SHA 會 fail closed；錯誤過深碰撞盒會擋住前方 tile。
5. 真正 RPG Maker VX 隔離 Project1 Game.exe 跑出四張原生圖。兩個舊樹測點與新旅店後方完全遮住、前方顯示角色均 PASS；原生背景差 0，前景錯誤覆蓋 0，手動 Game.exe 無自動瞬移並完成 100-frame smoke。
6. native_template、可重跑 source-generator、pixel-owner、1px negative、native screenshot harness 均留在私人 ZIP。未修改正式 Forest Symphony sealed baseline。

## 目前嚴格狀態
ISOLATED VX NATIVE TECH PASS; B1 REFERENCE VISUAL NOT PASS; SEALED FS RUNTIME NOT RUN; USER HUMAN GATE F NOT RUN; NOT FORMAL PASS.
來源版權仍 PRIVATE TEST CANDIDATE，不得公開發布圖片/ZIP。

## 後續 P0-P3
P0 完成真正不同輪廓的樹屋/神聖樹美術組件，在 source Sprite/foot anchor/occlusion mask/hidden Ground 同源編譯下生成。
P1 真河流／橋與橋上/橋下不同高度的 Height/Level/Collision，不能只依 Actor screen Y。
P2 照 ground3、SCENE21 的構圖、地形、建築、環境層次完成 VISUAL Gate；缺素材授權需另建 approved asset family。
P3 同一 Suite 在 sealed FS 唯讀隔離複本完成 Native Gate F，再取得使用者 Human Visual 驗收，通過才擴大城堡鎮。

## 完整私有交付
E:\GameAssetToolLab_20261023\FS_B1_MULTI_WING_LODGE_V5_20261024_PRIVATE_VX.zip
入口 START_B1_V5_GAME.cmd / RUN_V5_ALL_CHECKS.cmd / RUN_NATIVE_V5.cmd / AUDIT_EXTERNAL_MASTER.cmd。
logs/V5_LODGE_LAYER_GATE.json / logs/V5_NATIVE_LODGE_AUDIT.json / README_繁體中文.md。

## Final Release Verification
Private ZIP: E:\GameAssetToolLab_20261023\FS_B1_MULTI_WING_LODGE_V5_20261024_PRIVATE_VX.zip
ZIP SHA256: 9802352a31f0affaf4f3177fd7f53abe08122d7c6b452cd763e470f248a761ff; size 13,284,537 bytes, 415 ZIP entries.
Independent ZIP extraction verified 413 source file hashes; source compiler, Owner, Tiled visual and Lodge contract passed; native Game.exe four screenshots passed. The final repack only added the release verification log and was re-CRC/SHA checked.
Drive Handoff: https://docs.google.com/document/d/1JAgQuJ_626H_IbVjrLbgWT6eB1mqxVXvhPdjL8xbPtE/edit
NO SEALED FS PASS, NO B1 VISUAL PASS, NO HUMAN GATE F.
