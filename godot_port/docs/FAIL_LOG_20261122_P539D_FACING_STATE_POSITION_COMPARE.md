# Forest Symphony P539D Failure Log｜角色反向、原 #381／#462 真畫面對照
2026-11-22。Godot4.7.2 ONLY。原來源E: READ-ONLY。

R0 錯朝向：原 A52 Actor01 戰鬥三層面向錯側，用 rig.scale.x=-1 同時鏡像Body/Weapon/FX；非真的rotate180倒立。原 A52像素SHA保持。原生測試transform determinant<0、rotation0、三層共父；真RX6700XT GPU 544方向像素差792、1088差3172。

R1 狀態圖示壓怪物臉：原 Script #381 取 battler_y 腳底，Godot第一次誤用Enemy TextureRect中心。實開原圖看見 badge 疊在怪物臉上，這是ART FAIL而非純Code測試PASS。修在 FSBattleSourceStateHUD381.enemy_anchor_from_rect(bounds)，source enemy中心x與底部y，#381 offset x−35,y0。原生坐標 Rect2(226,60,64,78) => feet(258,138) => badge(223,138)，真實R5 GPU 544/1088再驗通過。兩張前版錯位PNG保存在私人Drive native_gpu_before_feet_anchor_fix。

R2 修腳底後Source enemy永久名稱與badge重疊：原 #462 目標名只應在選敵Help中，不該在source Sprite上永遠顯示「測試木靈」。修 FSBattleOriginalEnemyStage.bind_real 隱藏caption（不破壞真正選敵/合成測試），真原圖 source R8 544/1088 GPU再次各6張PASS。第二組前版疊字PNG保存在私人Drive native_gpu_before_enemy_caption_cleanup。

R3 Public source-empty測試 vs 私人SHA實圖測試：既有P537B/537C native fixture硬預期任何runtime都沒private sources，Owner G: staging的真素材讓錯的測試前提直接FAIL。修測試同時支援 public absence fail-closed 和 owner validated original-source gating；不能用私人素材去覆蓋GitHub/public CI。另私人GPU capture原硬coded G目錄名錯誤，已更正授權FS_PRIVATE_P539D_FACING_AND_STATEHUD_20261122。

最終 #44994999882 GitHub Godot4.7.2完整CI SUCCESS 94/94 steps failed0。真 AMD RX6700XT OpenGL 3.3 source 544/1088各6張，12／12 GPU PASS；原 #381實 icon pixels 336/1346、A52朝向變動792/3172；code/GPU/修正前後證據與原source #269/#312/#381/#462 SHA都封在 owner-only G Drive https://drive.google.com/drive/folders/1PgNHwuFDxVAcbBjJCzAq9Lxg7Hk-7d27。私有證據ZIP FS_P539D_ACTOR_FACING_381_STATE_HUD_SOURCE_GPU_PRIVATE_QA_20261122.zip，6,405,355 bytes，SHA 01effe01107f516e955fa1f4c4008e06625a06e9969540b62644bb228293773d，CRC PASS，36 entries。

仍未完成：#381 stacks、turns、details；完整 #462 target-help；#269 number rolling；本場視覺命中0.63與真 ACT結算；T-A RUN12與五主角；505 source alias與11 boot-final資料、真 Boss AI與1:1同幀VX圖。ART HOLD Phase1 NO。
