# Forest Symphony｜P539D 原版角色反方向與 #381 State HUD Handoff
日期 2026-11-22。Godot 4.7.2 ONLY。原始 VX E: READ-ONLY；原始 A52／UI／Battlers／Scape、Ruby 505 source、RX6700XT GPU 原圖只儲存 owner-only Google Drive。公共 GitHub 只存 GDScript／自動測試／Handoff。

## 來源、真正完成的功能
1. 使用者指出前次戰鬥角色臉朝錯方向。「面部 180° 另一方」依 45°戰鬥視角實作為水平相反朝向，而不是整張 Sprite 倒立旋轉。FSBattleActor01Presenter 的 A52 rig.scale=Vector2(-1,1)，原 12×64px Body、Weapon、FX 三張 256×192 原始 Atlas 共父、共幀、共鏡像，原 PNG SHA 不改、F7 visual contact 0.630 秒、ACT真正結算不更動。source SHA Body a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f, Weapon 6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b, FX 46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c。
2. 原 Script #381 AlbertBattleStateHUD 原始 Ruby 70616 bytes SHA256 b1df4785f85efbe412a84a227883b9b77bf11aab9b9e9fb70dcfb4ecd89c8b39。真正來源 MAX_ICONS_PER_BATTLER=4、ICON_SIZE=20、SPACING=20、OPACITY=180、State.note 隱藏與強制顯示／priority／icon，優先序降序同級 StateID 升序、四格超額時前三張＋N。FSBattleSourceStateHUD381.gd 以來源 state IDs / FSDatabase 查表，用原 SHA-locked private Iconset.png 384px Atlas（16欄24來源，縮成20px）。不存在來源 State／原圖不能假裝 source PASS。
3. 原 #381 Sprite_AlbertBattleStateHUD 的 actor 座標 x=bx-16, y=by+20,oy=20；enemy x=bx+45,ox=80, y=by+20,oy=20。真 enemy by 是**站立腳底**而非 Image.get_center()。因此 FSScreen 的原 #381 enemy badge 位置改用 Enemy TextureRect 底部中心，source_top_left 再應用 x−35。沒有真正 Actor01 Sprite2D 位置的其他角色不猜位置，維持 ART HOLD。
4. 原 #462 FS_BATTLE_TARGET_HUD_LAYOUT Ruby 63272 bytes SHA b65d704f87c50ec00788b23f49892042d99e10bc62016bdcc4c00f71d10e31e3：SHOW_HELP_STATE_ICONS=false，不能與#381在Help重複畫State icon。源敵方角色名稱應在 target help，而非永久壓在 Source Sprite 下。FSBattleOriginalEnemyStage.bind_real 只在源 SHA 真 Battler staged 時隱藏原本 Godot debug caption；合成 fixture 使用原先 caption 仍可驗證。真正完整 target help／detail 尚未移植。
5. 源戰鬥 Scene 同時保持 #264 original BattleScape、#269 Btskin 主角狀態欄、#232/#268 五縱向 source commands、#312 真 State 行動封印、原 enemy/Actor01 A52 及真原 Iconset state badge，僅加視覺變換，不修改戰鬥損傷/MP RNG authority。

## 真 QA，而不是只編譯
- 原生 Godot 4.7.2 官方整套 CI #44994999882 completed SUCCESS 94／94 steps、0 failed：https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/44994999882 。
- 真 owner Win64 Godot 4.7.2.stable.official.ed1daf0bf × AMD RX6700XT OpenGL3.3 在私人 G: Google Drive 原圖工程運作。544×416、1088×832 各完整拍 source battle idle、ATB READY、A52 F7、Before錯朝向、After正確反方向、來源 #381 真狀態圖示6張，合計 12／12 source GPU screenshot PASS。
- 同場景同幀 source Body/Weapon/FX before/after 真 GPU 改變 544：792 pixels、1088：3172 pixels；真 #381原 Iconset 畫面有效 pixels 544：336、1088：1346；原 #269 Btskin HUD 13060／52244；source #264 Scape 92625／370442。所有原始圖/戰鬥數值測試狀態有明確區分：source圖真、combat numeric fixture synthetic，非已經匯入 11 boot-final DB。
- 真正目視 R1 發現 Badge 放在怪物臉上；R5改到站立腳底，又見舊 permanent Godot debug enemy label與Badge重疊；R8隱藏來源敵方常駐 debug label，真 RX6700XT再次 544/1088 各6張實體GPU PASS，保存四張修正前錯誤圖片。舊 2x2 / public synthetic 測試模式未混同原版。
- Google Drive owner-only staging folder：https://drive.google.com/drive/folders/1PgNHwuFDxVAcbBjJCzAq9Lxg7Hk-7d27
- 正式私人ZIP：FS_P539D_ACTOR_FACING_381_STATE_HUD_SOURCE_GPU_PRIVATE_QA_20261122.zip，6,405,355 bytes，SHA256 01effe01107f516e955fa1f4c4008e06625a06e9969540b62644bb228293773d，ZIP CRC PASS 36 entries（12真正GPU、4失敗before對照、Godot native日誌、#269/#312/#381/#462來源SHA與逐檔manifest）。僅 G Drive 私有，直連須以Drive provider實際File ID為準。
- 有效圖連結，owner-only：錯方向Before https://drive.google.com/file/d/1iKmCH4BhOHei8iAng4r6hjwB2-_TN-Bx/view；正方向After https://drive.google.com/file/d/1mL7zPmGOQESszeJJarCxf_UgWMrRrFme/view；真原狀態Badge最後一輪 https://drive.google.com/file/d/1zvJ0tGe-zPrAUiJ69631Ec8-ZeKEbyMB/view。
- 施工提交：A52 facing c5dea4d9b8f8382ecbd56248ab46bed27f192e09；381整合6d197420c89884113980d408b01d369060be5b4a；GPU witness f65ad43db13ff786420172d1692e13e69bccf673；修腳底 a0a65b7dfb335519c1fd97082b578ca9a159bd63；原名除錯overlay修正2f696d2197338be16c6be3634d610d86193084cb；雙模式來源驗證b653202428605482fe066bc6a119e736fdbc3da7。

## 不可封版與下一個完整施工單位
原 #381 State stack badge/turn badge/Detail Window，完整原 #462 target help/detail/header、#269數字緩動、真正 A52 F7命中與原 ACT 70ms hitstop、T-A RUN12／其他五角色動作、全部505 Ruby effective alias、11 boot-final postApply資料表、Boss特殊AI和 VX/Godot同幀1:1對照皆未達原作等價。兩張缺來源 BattleScape Bridge/BlueSky 也維持 ART HOLD。**整體 Phase1 SEAL NO；ART HOLD**。
下階段 P539E 整批移植原 #462 target help/window與 #381 state detail/stack、#269 numeric easing、來源數據驗證；接續 P538 整套 MENU，A35 MAP排後。逐批比較原 FS → 實施工 → native/GPU QA → FailureLog/Handoff；不再以單張PNG/按鈕為單位。
