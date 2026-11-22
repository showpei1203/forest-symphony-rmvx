# Forest Symphony P539B｜整套原版 BATTLE Scene／指令／BattleScape 整合 Handoff
2026-11-22 · Godot 4.7.2 ONLY · Source-integrated GPU PASS · Phase1 SEAL NO / ART HOLD

## 一、真正施工，不再逐張圖片拆分
- 以已完整封存的原始 Scripts.rvdata 505 段 Ruby 為唯一來源。P539B 直接整合來源 #232 ATB Scene、#264 BattleScape／戰鬥背景、#268 五項原指令、#312 封印保護的 Scene_Battle 和 Window 視覺子系統。沒有改動 E: VX 來源，Godot 繼承 P532–P539A 已通過的 ACT、ATB、事件、MENU 和原美術接口。
- 原 #232/#268 是五個直向錯位的 54×48 Battle01～05 指令，不是舊 Godot 測試用 2×2。來源原位置 x=[410,411,422,443,469]，y=[230,267,302,333,360]，依原始五個選中與未選中圖切換。按鍵順序 0攻擊→1技能→2防禦→3道具→4逃跑，實際合法操作仍走現有 FSBattle / FSActionQueue；#312 a_seal/s_seal/g_seal/i_seal 有 UI 封印旗標判定，完整有效來源尚待 505 alias 執行證明。Escape 只呈現原圖，未經原 VX 逃跑與 Event301 驗證一律 disabled。沒有私有 source PNG 就維持舊 2×2 合成測試介面，不假稱它是原版。
- 原 #264 是三段 Game_Map battle_scapes 的實際覆寫 chain，Troop > Variable1000 > Area > Map。特別注意 Ruby TROOP_BATTLE_SCAPES.default=[1]，所以任何正數且未列在映射內的 Troop 直接選 [1]，不能誤選 Map。Troop36 原腳本重複定義，後面的 [15,3] 生效。Troop12=[14,3]；背景 z49 ffog additive/opacity250 和 z51 new_back01；原霧捲動每 60fps source frame 位移 scroll_x*2/16。來源 script 264 所列全 10 種 Scape ID 的設定、zoom、opacity、z、scroll 已納入同一個 resolver/stage。
- 從原始 Graphics/Parallaxes 唯讀找到真正的七張：new_back00.png、temp1.png、ffog.png、new_back01.png、new_back02.png、back02.jpg、back08.jpg。另 Bridge 與 BlueSky 在原來源資料夾內確實不存在，標示 ART HOLD，拒絕偽造或貼別張當代用品。
- 程式模組：scripts/ui/FSOriginalBattleCommandLayer.gd、FSOriginalBattleScapeRules.gd、FSOriginalBattleScapeArt.gd、FSOriginalBattleScapeStage.gd；FSScreen.gd 直接組合 source #264 背景、來源敵人、A52 Body／Weapon／FX 與五指令，只有來源 hash lock 成功才啟用真來源。來源私有圖片保留在 gitignored assets/battle_scapes，不公開到 GitHub。

## 二、GitHub 真實提交與 Godot 原生回歸
- 整套程式及 synthetic Godot/Python 原生測試：https://github.com/showpei1203/forest-symphony-rmvx/commit/b369e51c08196a15cc426c428ca50977304391a7
- owner-private 原版 GPU 專用腳本：https://github.com/showpei1203/forest-symphony-rmvx/commit/1f9f8a9fc735531220ae463fc7398bac547a3e28
- 實際看原圖後修正大量 Godot 原型頁籤、文字與「返回 MENU」蓋住戰場：https://github.com/showpei1203/forest-symphony-rmvx/commit/bf32eb9ba0806b5330df890696ca3abd53431ccf
- Source #264 的 Troop36 Ruby duplicate last wins、正數 Troop default、variable-empty/area/map fallback、z49 additive fog、scroll_x 13/8、#268 五指令原座標及 Escape disabled、#312 flag source-shaped + 真 ATB wait/lock 都有 Godot native/合成圖測試。私圖缺失時 fail closed。
- 官方 Godot 4.7.2 全套 GitHub CI #44988257528 completed SUCCESS 92／92 steps、failed 0；public CI 不含原始受限圖片。https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44988257528

## 三、真來源 Google Drive 與真正實體 GPU
- 七張原始 BattleScape ZIP（逐檔 SHA256、CRC，原文件不修改）：https://drive.google.com/file/d/1p9DvILBhvYh9acKk-7FIWu5f3vkj3xn9/view；2,183,815 bytes；整包 SHA256 fc0e5f7a14dd239bdf7dd5db3a9041bcdf59616cfef71da903c2ad1657b0c76b；owner-only shared=false。
- 真 Godot 4.7.2.stable.official.ed1daf0bf、AMD Radeon RX 6700 XT、OpenGL 3.3 Core Profile Compatibility。既有 202 原 UI＋167 原 Battlers＋3 A52 真 actor sprites 已在 G: Google Drive Godot QA 工程，額外 SHA-stage 七張 original Scape，editor 7／7 import exit0。
- 用 SOURCE TROOP12=[14,3]，合成來源形狀的 Enemy1 DB 設 battler_name=$001（不是原 VX 11 post-Apply 正式數據），真原圖 new_back01 + ffog、五 source 54×48 command sprites、原 enemy 與 A52 Body/Weapon/FX，在 544×416 及1088×832 各拍 idle、ATB READY、A52 F7，全部 6／6 native GPU PASS。原圖 background baseline hidden vs visible physical GPU pixel delta：544 有 88,826、1088 有 354,871 pixels；檢查五指令全部可見、Escape disabled、F7 contact 不提早扣 HP。
- 初版 R1 6／6 雖渲染成功，實際畫面卻有原型標題、MENU/BATTLE tabs、角色選擇和返回 MENU 大型文字壓在原版地板。已於 bf32eb9 修正：SOURCE BATTLE 使用原始 HUD、敵人、角色與五 icon，隱藏 prototype chrome；技能/物品/指定目標及缺 source 的測試 UI 才恢復 Godot 文字。R2 真機再次6／6通過並經直接開圖目視驗證原戰場乾淨。
- **正式 private native GPU QA ZIP**：https://drive.google.com/file/d/1s62sACD_IN5SPo9hclITqEYYyXngl4pR/view
  - 實際 Google Drive metadata 3,080,495 bytes；shared=false、owner-only；SHA256 8cb132f507898206040530dde6ee028b04b80f6eb331af05da4c552a51991836；ZIP CRC PASS。
  - 共 12 項：最終 GPU 六張 PNG、Godot Editor+兩解析度 native logs 三個、修正前兩張失敗視覺對照、每個檔案 SHA256 provenance JSON。
  - 544 最新 F7 圖 https://drive.google.com/file/d/1_2aearnHo7X1hrsjrNDGFuNhXKKiNT5e/view
  - 1088 最新 F7 圖 https://drive.google.com/file/d/1xur9E1jjv13bqsmre4tO2vz06ty2-pkC/view
  - 對應授權私人雲端工作區 https://drive.google.com/drive/folders/1rBtNxWvJHiqq2oNqMs744vYuo-zPPk5J

## 四、仍 HOLD 的來源語意
這是 SOURCE scene UI/backdrop/actor/enemy 原圖 native GPU PASS，**不是 505 段 RGSS2 已能直接執行於 Godot**。完整後載入 alias、來源 #312 seal 真實 State 推導、原 #232 65px slide/tone flash、Escape 與 VX Event301、BattleScape absent Bridge/BlueSky、原 Game_Map Areas / Map exact runtime witness、所有職業技能 AI/被動、A52 F7 0.63s 與 ACT 真結算/70ms hitstop、11 張 boot-final post-Apply 資料表、VX 同畫面 1:1 Pixel Parity 仍未合格。明確 ART HOLD，Phase1 SEAL NO。

下一大施工單位 P539C 應直接依全505來源整批補 Scene_Battle 的有效 command seal、攻擊/技能/AI/敵隊/Window HUD #269/#381/#462 真組合，以及完整原 boot-final DB witness；接續 P538 完整 MENU 原始 Scene/Window，不再逐張 UI 拆單。A35 地圖仍維持後順位。
