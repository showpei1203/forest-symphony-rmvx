#==============================================================================
# ■ FS_LegacyCode_Archive_Index v1.4
#------------------------------------------------------------------------------
# Forest Symphony Script Cleanup Phase 3
#
# 目的：
#   將原本 Main 後、完全不參與正常遊戲 Runtime 的大量舊腳本分頁，
#   自 Script Editor 移出完整 Legacy Source，只保留索引；完整原始碼存於外部 Archive ZIP。
#
# 保留原則：
#   - Main、全腳本導出工具、標題Final-0714：原封不動。
#   - Main 前所有 Runtime：原封不動。
#   - 所有既有說明／手冊（512～527）：原封不動。
#   - 528～648 舊頁面的完整文字內容：已自 Scripts.rvdata 移出，完整保存在 FS_SCRIPT_ARCHIVE_PHASE3.zip。
#   - FS_SCRIPT_ARCHIVE_PHASE3.zip 保存 121 份原始 .rb byte-exact 備份；本頁保留名稱、分類、大小與 SHA。
#
# 若要復原單一舊腳本，請由 FS_SCRIPT_ARCHIVE_PHASE3.zip 取回對應 .rb。
#============================================================================== 
#
# [Part 01] 原頁 528～544 / 17 pages / 308.2 KiB
#   528 | 臨時加入                                       | CUSTOM_LOCAL                   |    3826 B | eb4483b2c7b7
#   529 | BattleStateHUD_Core                        | BATTLE,UI_MENU                 |   46073 B | dc5925934862
#   530 | SBS_ActionRandomTarget_Fix                 | BATTLE                         |    6445 B | cc0b55d3b518
#   531 | Auto Skill Candidates for EAC              | BATTLE                         |   10058 B | 177e7fc176f0
#   532 | SummonGuard_TargetEffect                   | BATTLE                         |    3659 B | 087a5cddd276
#   533 | 屬性相剋系統                                     | CUSTOM_LOCAL                   |    3797 B | f517cd2dc2f0
#   534 | YERD_BattleAggro                           | BATTLE                         |   18414 B | a173ddca6989
#   535 | BattleAISelector                           | BATTLE,CUSTOM_LOCAL            |    2822 B | 5513a61d8947
#   536 | Protect Skill v 1.2.3                      | BATTLE                         |   14450 B | ded9f65fc4dd
#   537 | KGC_OverDrive                              | BATTLE                         |   48516 B | 7bc306b86274
#   538 | 戰鬥HUD-0226                                 | BATTLE,UI_MENU                 |   24887 B | 8db0034405b1
#   539 | 全局工具                                       | CUSTOM_LOCAL                   |    1951 B | 6c97126d82f4
#   540 | 臨時加入                                       | CUSTOM_LOCAL                   |    2776 B | dbc194c34a5d
#   541 | 臨時加入-2                                     | CUSTOM_LOCAL                   |    3425 B | b48fa7136045
#   542 | SKILL DELAY DI HOLY87                      | BATTLE                         |   20099 B | 062e4af2da76
#   543 | 戰鬥結果統計-2                                   | BATTLE                         |   52522 B | ad03b329a949
#   544 | 戰鬥結果統計                                     | BATTLE                         |   51865 B | 6af27a3321a8
#
# [Part 02] 原頁 545～567 / 23 pages / 302.9 KiB
#   545 | 戰鬥HUD-0222                                 | BATTLE,UI_MENU                 |   24882 B | 4ef2028ac6ef
#   546 | 初始化選擇的索引                                   | CUSTOM_LOCAL                   |    1723 B | f8453067f72b
#   547 | 戰鬥系統核心 - 行動處理                              | BATTLE                         |    1009 B | 6f849d68efaa
#   548 | 目標過濾-2                                     | BATTLE,CUSTOM_LOCAL            |    2055 B | ae3f4ee1c0a3
#   549 | 目標過濾                                       | BATTLE,CUSTOM_LOCAL            |    3453 B | 1dfa14999726
#   550 | Mana Shield v1.3.0                         | BATTLE                         |    4059 B | 7eb9f69b0e70
#   551 | Provoke & Disappear State System v1.2.3    | BATTLE                         |    2568 B | 71480f1a1ad1
#   552 | 敵データ表示機能v2.0                               | BATTLE                         |   32289 B | 91a389b285b2
#   553 | Kread's AI Packages                        | BATTLE                         |   24140 B | 879f5db43518
#   554 | 自動戰鬥邏輯擴充                                   | BATTLE,CUSTOM_LOCAL            |    9089 B | 31779d8f7020
#   555 | 臨時加入備份                                     | REFERENCE,CUSTOM_LOCAL         |    2482 B | 6d973f76238b
#   556 | 敵データ表示機能v2.0                               | BATTLE                         |   30951 B | 627deceb44e0
#   557 | YEZ Class Stat: DUR                        | MISC                           |   31130 B | 041de94d8618
#   558 | CharacterBook                              | MAP_EVENT,CUSTOM_LOCAL         |    9173 B | e913c6de2587
#   559 | Out_Enemy                                  | BATTLE                         |    8579 B | a41098692baa
#   560 | 受け流し/防御/庇う                                 | MISC                           |   37473 B | 05566bc4eb1e
#   561 | 特殊ステート集                                    | BATTLE                         |   48670 B | a3a4eae4843b
#   562 | 敵人選擇效果-未做                                  | BATTLE,REFERENCE               |    3414 B | 926b5274b35c
#   563 | Substitute Bypassing Skills                | BATTLE                         |    4434 B | 8f6d8ff9d74e
#   564 | Untargetable State                         | BATTLE                         |    7308 B | 74f497337a57
#   565 | Simple Battle Rows                         | BATTLE                         |   10502 B | 3420f68ddcaa
#   566 | BELOW the ATB scripts                      | BATTLE                         |    6829 B | bf9b70cd4c54
#   567 | Linked Death                               | MISC                           |    3983 B | 3beeffc5c34c
#
# [Part 03] 原頁 568～606 / 39 pages / 327.5 KiB
#   568 | 詳盡幫助Window_Help10                          | UI_MENU                        |   34083 B | 8741ab9c4920
#   569 | Easy Skill Combo Script                    | BATTLE                         |    8182 B | 4f3a7cf6002a
#   570 | Advanced forced action                     | MISC                           |    3237 B | 261f4104216f
#   571 | 戰鬥加乘burst gauge                            | BATTLE                         |   35116 B | 5eb5a797f036
#   572 | Break Gauge Chaos Ring                     | MISC                           |   11238 B | 7d74825b0ca8
#   573 | Minigame Susun Gambar                      | MINIGAME                       |    6530 B | f4550de64a66
#   574 | Minigame Tower of Hanoi                    | MINIGAME                       |    6799 B | 846b25a05534
#   575 | 獲取使用對象                                     | MISC                           |    4518 B | 3bf7fc4fcc31
#   576 | Savepoint System *61修改                     | MAP_EVENT                      |    2573 B | 86423cb91e31
#   577 | Scene Transitions                          | MISC                           |    5669 B | 4d779fa19cb4
#   578 | Versus Popup                               | UI_MENU                        |    6334 B | 0b7cefd1fd5b
#   579 | Sliding Graphics                           | UI_MENU                        |    7940 B | 48c9360a54fc
#   580 | Note Editor                                | MISC                           |    8954 B | c90e8e0641e8
#   581 | Revive State  死亡立刻回復                       | BATTLE                         |    7058 B | 4197b70226df
#   582 | Record Target Variable                     | BATTLE                         |    4483 B | f56c54edd9f6
#   583 | Replace Skill                              | BATTLE                         |    5279 B | 16c0cdef7d56
#   584 | Encounter Levels Script                    | MISC                           |    5975 B | f8b3d853d080
#   585 | 敵スキル行動最適化                                  | BATTLE                         |   30743 B | 121c28ecbf3f
#   586 | 技能前コモン                                     | BATTLE                         |    2820 B | f51b5e0c62b6
#   587 |  行動バトラー情報取得                                | BATTLE                         |    5990 B | 6235bf701c04
#   588 | アクター・エネミー固有変数追加                            | MISC                           |   14583 B | 59a0a11df7c0
#   589 | アクター・エネミー固有変数追加拡張                          | MISC                           |    2326 B | 164520311c2a
#   590 | アイテム/スキル使用時スイッチ/変数変更                       | MISC                           |    8910 B | 74eef829f5a0
#   591 | ダメージ減衰特徴                                   | MISC                           |    7068 B | 9ae528321299
#   592 | RGSS2 属性攻撃時にメッセージ色変更Ver1.00                | MISC                           |    5066 B | afb5b77727af
#   593 | エネミー最適化行動                                  | BATTLE                         |    6415 B | b3ddf039753b
#   594 | 特定スキル無効化                                   | MISC                           |    2911 B | a39fc1228379
#   595 | 変数条件＆変数変動アイテム・スキル                          | MISC                           |    3908 B | 2bebc8c8a922
#   596 |  暗号化作品テストモード禁止                             | MISC                           |    1789 B | d1ef9858395b
#   597 | Recharge Skills (MA)                       | BATTLE                         |   15981 B | 4515b58ed430
#   598 | Battle Turn Count Window                   | BATTLE,UI_MENU                 |    6773 B | 6f763ba5ef92
#   599 | 戰鬥AI思路                                     | BATTLE,REFERENCE               |     778 B | ca9ccc22e287
#   600 | H87-Critical Light                         | BATTLE                         |    4748 B | 1b919805983d
#   601 | Smooth Scrolling +                         | MAP_EVENT                      |   15405 B | fe9090534a5a
#   602 | H87 - Equip Sets                           | MISC                           |    9249 B | 99a67034a7d7
#   603 | combo表示[待用]                                | MINIGAME,REFERENCE             |   12585 B | f3be4ae58724
#   604 | Enemy ID (per SCAN)[待用]                    | BATTLE,REFERENCE               |    1196 B | ac749b61c534
#   605 | 敵人屬性變量[待用]                                 | BATTLE,REFERENCE               |   11359 B | 0b2c2bdde3b0
#   606 | 获取敌人ID[待用]                                 | REFERENCE                      |     779 B | 5f3bde549f45
#
# [Part 04] 原頁 607～634 / 28 pages / 327.4 KiB
#   607 | YERD_SwapMonster[待用]                       | REFERENCE                      |    3442 B | 6c4ebef49cba
#   608 | KGC_CursorAnimation                        | UI_MENU                        |   15321 B | 1eff5348d1ab
#   609 | Rei Explosion Blur Effect                  | MISC                           |   10570 B | b6db467a17fb
#   610 | H87-Magic Weapons造成傷害1                     | BATTLE                         |    6513 B | aa7c2647c70f
#   611 | 血少顯現 會報錯                                   | REFERENCE                      |    4538 B | d8dfc8fe1cd6
#   612 | 狀態跟隨步數解除                                   | MISC                           |   14415 B | 4015cc9180a7
#   613 | バトルの格闘場化・サイドビュー対応版                         | BATTLE                         |   36530 B | 5cff063b4dd2
#   614 | 战斗结束后删除隊員                                  | MISC                           |     717 B | a1e5036b2dee
#   615 | Kread's AI Packages                        | BATTLE                         |   23051 B | f9a40e988da7
#   616 | 欄位名稱+底圖                                    | UI_MENU                        |    4045 B | 532b653da8f8
#   617 | 敵人能力，會覆蓋                                   | BATTLE,CUSTOM_LOCAL            |   16254 B | d38645f304e6
#   618 | 物品飄動                                       | UI_MENU                        |   10354 B | ee73999d2ee5
#   619 | バトルの格闘場化                                   | BATTLE                         |   29548 B | 6cee3b430a1c
#   620 | Advanced forced action                     | MISC                           |    3176 B | 5021467bba98
#   621 | AUTO STATE SWITCHES                        | BATTLE,MAP_EVENT               |   14698 B | 132be91a24f0
#   622 | Cover                                      | BATTLE                         |   13326 B | 3ccc85a61e64
#   623 | 水晶系統參考                                     | REFERENCE                      |   11748 B | f756877bec13
#   624 | 戰鬥轉盤+逃跑                                    | BATTLE                         |   20805 B | a5d025a72ce2
#   625 | Update Action Orders Per Action            | MISC                           |    6477 B | b0b8253de446
#   626 | FFXIII Layout                              | UI_MENU                        |   22123 B | 3f3406475b77
#   627 | シーンクラス備份                                   | REFERENCE                      |   12993 B | 40296eb58737
#   628 | KGC_MPCostAlter                            | MISC                           |   16094 B | 0aba02231151
#   629 | WORA_CallEventVX                           | MAP_EVENT                      |    2411 B | bf71d19359e4
#   630 | WORA_AdvanceScrollMap                      | MAP_EVENT                      |    2261 B | 27f1c2354f27
#   631 | Chara Textbox                              | UI_MENU,MAP_EVENT              |    6449 B | 7ebb9e435082
#   632 | Game_SelfVariables                         | MAP_EVENT                      |    7199 B | 4f8e00333136
#   633 | 召喚スキル                                      | BATTLE                         |   16991 B | de7f3a52e11a
#   634 | Summon(Type1) for_Sideview                 | BATTLE                         |    3201 B | e75a40975111
#
# [Part 05] 原頁 635～648 / 14 pages / 261.3 KiB
#   635 | menu背景音樂                                   | UI_MENU                        |    4143 B | bc8bf354cb95
#   636 | Item Popup                                 | UI_MENU                        |   21321 B | 6a9fb6d96a9c
#   637 | 限量商店                                       | MISC                           |   35241 B | 7570a87ad8a6
#   638 | 標題Final                                    | UI_MENU                        |   25072 B | e4aefefacde7
#   639 | Gold_Map                                   | UI_MENU,MAP_EVENT              |    2236 B | 6b3bcfd2d9ec
#   640 | 乗り物拡張                                      | MAP_EVENT                      |   98335 B | 36528c083330
#   641 | HK - Ultimate Overlay Mapping              | MAP_EVENT                      |    8178 B | 34b8514364dc
#   642 | Anti-missing file error                    | MISC                           |    2894 B | 7f14a500ed3c
#   643 | ISS - ParaLayers                           | MAP_EVENT                      |    8660 B | 6d83913e950e
#   644 | Hookshot                                   | MAP_EVENT                      |   21822 B | 79b241526f02
#   645 | Randomized Gold                            | MISC                           |    1821 B | 01d215dae4ef
#   646 | 戰鬥公式                                       | BATTLE                         |   16921 B | fa44492c653f
#   647 | 戰鬥公式                                       | BATTLE                         |   16921 B | 29e8c6ec6b00
#   648 | KGC_RateDamage                             | BATTLE                         |    4007 B | 16d46dcbc64b
#


#==============================================================================
# [Phase 12] 專案自製 Legacy 完整保留：6主角＋5映體＋5機器人資料庫 v2.0
#------------------------------------------------------------------------------
# 狀態：已自 Main 前 Runtime 退休，因 v2.1 CompactID 為較新正式 Authority。
# 原 Phase 11 page：404（當時頁名因封裝器 bug 為空，但 Header 可識別原名稱）。
# SHA-256：30d69d94d09768261ea08b294d6ca5af26fa165f454dfdd63a228a6435dc8359
# 原始碼保留方式：以下每行加 #| 註解，完整內容仍留在專案 Project History；
#                   byte-exact 原檔另存 FS_SCRIPT_ARCHIVE_PHASE12_COMPONENTS.zip。
# 退休理由：此 v2.0 位於 CompactID v2.1 後方，會反向覆蓋成舊 ID：
#   Robot Skill 857～861 / Armor 732～741 / Growth Enemy 746～755，
# 並重複包裝 change_level / change_exp / level_up / make_action / enemy level / create_game_objects。
#==============================================================================
#| #==============================================================================
#| # 【Forest Symphony｜繁體中文維護說明】
#| #------------------------------------------------------------------------------
#| # 腳本：6主角＋5映體＋5機器人資料庫
#| # 【用途】保留的 Runtime 元件「6主角＋5映體＋5機器人資料庫」。
#| # 【主要機制】主要定義／擴充 Game_Actor、Game_Enemy、Scene_Battle、Scene_Title；下方原始說明與程式碼保留作細節依據。
#| # 【主要影響】Game_Actor、Game_Enemy、Scene_Battle、Scene_Title、ForestSymphonyDB、ALBERT_HPMP_SCALE_GROWTH
#| # 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：LEVEL_CAP、ARMOR_TO_ACTOR、PROFILES。核心方法除非已確認依賴鏈，不建議直接覆寫。
#| # 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意。
#| # 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
#| # 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
#| # 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
#| # 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#| #------------------------------------------------------------------------------
#| # 維護規則：
#| # 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
#| # 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
#| # 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
#| # 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#| #==============================================================================
#| #==============================================================================
#| # ■ Forest_Symphony_DatabaseSupport_v2_0
#| #    對應「6主角＋5映體＋5機器人資料庫施工手冊 v2.0 Rebuilt」
#| #------------------------------------------------------------------------------
#| # 安裝位置：所有 ActorProfile、IvyCloneMechanicPatch、MechanicExpansion、
#| # EquipmentCombo、ActorEnemyGrowth、HPMP Scale、YERD EnemyLevelControl 之下，
#| # Main 之上。
#| #
#| # v2.0 重要修正：
#| #   1. Robot 只有一招協議技能；非協議回合必定普通攻擊。
#| #   2. Armor 732～741 對應 Actor 7～16；不覆蓋 Pokémon 600～665 mapping。
#| #   3. EquipmentCombo 開場技只有在召喚物已學會該技能時才排入，避免幼體
#| #      提前使用最終形態技能。
#| #   4. Actor / Enemy 等級上限統一為 60。
#| #
#| # 舊存檔：事件腳本執行 ForestSymphonyDB.rebuild_armor_mapping
#| #==============================================================================
#| module ForestSymphonyDB
#|   LEVEL_CAP = 60
#|   ARMOR_TO_ACTOR = {
#|     732=>7, 733=>8, 734=>9, 735=>10, 736=>11,
#|     737=>12, 738=>13, 739=>14, 740=>15, 741=>16
#|   }
#|
#|   PROFILES = {
#|     1=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_summon_action:60>"]},
#|     2=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_heal_percent:4>","<cc_od_overheal_percent:3>"]},
#|     3=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_atb_per_10:30>"]},
#|     4=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_state_stack:50>"]},
#|     5=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>[]},
#|     6=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_break_point:35>","<cc_od_break:150>"]},
#|
#|     7=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_aizhuo","atb_disruptor"],:tags=>[],:clone_stability_max=>100,:clone_action_cost=>0},
#|     8=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_ivy","emergency_guard"],:tags=>[],:clone_stability_max=>100,:clone_action_cost=>0},
#|     9=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_mia","healer"],:tags=>["<cmb:30>"],:clone_stability_max=>100,:clone_action_cost=>0},
#|     10=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_vina","state_starter"],:tags=>["<cvb:15>"],:clone_stability_max=>100,:clone_action_cost=>0},
#|     11=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_tyler","armor_breaker"],:tags=>["<ctb:90,15>"],:clone_stability_max=>100,:clone_action_cost=>0},
#|
#|     12=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["protector"],:tags=>[],:robot_protocol=>{:skill=>857,:interval=>3,:if_state=>[]}},
#|     13=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["atb_controller"],:tags=>[],:robot_protocol=>{:skill=>858,:interval=>2,:if_state=>[]}},
#|     14=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["corrosion_engine"],:tags=>[],:robot_protocol=>{:skill=>859,:interval=>3,:if_state=>[]}},
#|     15=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["breaker"],:tags=>[],:robot_protocol=>{:skill=>860,:interval=>4,:if_state=>[]}},
#|     16=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["healer","mana_engine"],:tags=>[],:robot_protocol=>{:skill=>861,:interval=>3,:if_state=>[]}}
#|   }
#|
#|   def self.rebuild_armor_mapping
#|     return false unless defined?(ArmorMapping)
#|     ARMOR_TO_ACTOR.each do |armor_id, actor_id|
#|       ArmorMapping.add_mapping(armor_id, actor_id)
#|     end
#|     return true
#|   end
#|
#|   def self.apply_profiles
#|     return false unless defined?(ALBERT_ACTOR_PROFILE)
#|     return false unless ALBERT_ACTOR_PROFILE.const_defined?(:ACTORS)
#|     PROFILES.each { |actor_id, data| ALBERT_ACTOR_PROFILE::ACTORS[actor_id] = data }
#|     return true
#|   end
#| end
#|
#| ForestSymphonyDB.apply_profiles
#|
#| if defined?(ALBERT_ACTOR_ENEMY_GROWTH) &&
#|    ALBERT_ACTOR_ENEMY_GROWTH.const_defined?(:ACTOR_TO_ENEMY)
#|   {7=>746,8=>747,9=>748,10=>749,11=>750,
#|    12=>751,13=>752,14=>753,15=>754,16=>755}.each do |actor_id, enemy_id|
#|     ALBERT_ACTOR_ENEMY_GROWTH::ACTOR_TO_ENEMY[actor_id] = enemy_id
#|   end
#| end
#|
#| if defined?(ALBERT_IVY_CLONE) && ALBERT_IVY_CLONE.const_defined?(:CLONE_ACTOR_ROLES)
#|   ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES.clear
#|   ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES[7]  = :aizhuo
#|   ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES[8]  = :ivy
#|   ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES[9]  = :mia
#|   ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES[10] = :vina
#|   ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES[11] = :tyler
#| end
#|
#| if defined?(YE::BATTLE::ENEMY) && YE::BATTLE::ENEMY.const_defined?(:MAX_LEVEL)
#|   YE::BATTLE::ENEMY.send(:remove_const, :MAX_LEVEL)
#|   YE::BATTLE::ENEMY.const_set(:MAX_LEVEL, ForestSymphonyDB::LEVEL_CAP)
#| end
#|
#| class Game_Actor < Game_Battler
#|   def albert_growth_level
#|     lv = @level == nil ? 1 : @level.to_i
#|     return [[lv, 1].max, ForestSymphonyDB::LEVEL_CAP].min
#|   end
#|
#|   unless method_defined?(:fsdb_change_level_v20)
#|     alias fsdb_change_level_v20 change_level
#|     def change_level(level, show)
#|       level = [[level.to_i, ForestSymphonyDB::LEVEL_CAP].min, 1].max
#|       fsdb_change_level_v20(level, show)
#|     end
#|   end
#|
#|   unless method_defined?(:fsdb_change_exp_v20)
#|     alias fsdb_change_exp_v20 change_exp
#|     def change_exp(exp, show)
#|       cap_index = ForestSymphonyDB::LEVEL_CAP + 1
#|       if @exp_list && @exp_list[cap_index] && @exp_list[cap_index] > 0
#|         exp = [exp.to_i, @exp_list[cap_index] - 1].min
#|       end
#|       fsdb_change_exp_v20(exp, show)
#|     end
#|   end
#|
#|   unless method_defined?(:fsdb_level_up_v20)
#|     alias fsdb_level_up_v20 level_up
#|     def level_up
#|       return if @level.to_i >= ForestSymphonyDB::LEVEL_CAP
#|       fsdb_level_up_v20
#|     end
#|   end
#|
#|   # 機器人固定行動模式：
#|   # 協議回合使用唯一協議技能；其他回合固定使用普通攻擊。
#|   unless method_defined?(:fsdb_robot_fixed_old_make_action_v20)
#|     alias fsdb_robot_fixed_old_make_action_v20 make_action
#|     def make_action
#|       if respond_to?(:albert_robot?) && albert_robot?
#|         self.action.clear
#|         return unless movable?
#|         if respond_to?(:albert_mx_try_robot_protocol)
#|           return if albert_mx_try_robot_protocol
#|         end
#|         self.action.set_attack
#|         self.action.decide_random_target
#|         return
#|       end
#|       fsdb_robot_fixed_old_make_action_v20
#|     end
#|   end
#| end
#|
#| class Game_Enemy < Game_Battler
#|   if method_defined?(:level) && !method_defined?(:fsdb_enemy_level_v20)
#|     alias fsdb_enemy_level_v20 level
#|     def level
#|       [[fsdb_enemy_level_v20.to_i, 1].max, ForestSymphonyDB::LEVEL_CAP].min
#|     end
#|   end
#|   def albert_growth_level
#|     lv = respond_to?(:level) ? level.to_i : 1
#|     return [[lv, 1].max, ForestSymphonyDB::LEVEL_CAP].min
#|   end
#| end
#|
#| if defined?(ALBERT_HPMP_SCALE_GROWTH)
#|   module ALBERT_HPMP_SCALE_GROWTH
#|     def self.hpmp_raw(base_value, level)
#|       lv = [[level.to_i, 1].max, ForestSymphonyDB::LEVEL_CAP].min
#|       return ((2 * base_value.to_i + 31) * lv / 100.0) + lv + 10
#|     end
#|   end
#| end
#|
#| # EquipmentCombo 安全門：目前進化型態必須確實已學會開場技能。
#| # 重新建立戰鬥開始處理，額外加入「已學會技能」檢查。
#| class Scene_Battle < Scene_Base
#|   if method_defined?(:albert_prepare_equipment_combo_battle_effects)
#|     def albert_prepare_equipment_combo_battle_effects
#|       $game_party.members.each do |member|
#|         next unless member.is_a?(Game_Actor)
#|         member.albert_refresh_combo_actor_states
#|       end
#|
#|       @forcing_battlers ||= []
#|       queued_summon_ids = {}
#|
#|       $game_party.members.each do |owner|
#|         next unless owner.is_a?(Game_Actor)
#|         owner.albert_active_combo_equips.each do |equip|
#|           summon_actor_id = owner.albert_combo_summon_actor_id_for(equip)
#|           next if summon_actor_id <= 0
#|           summon = $game_actors[summon_actor_id]
#|           next if summon == nil
#|           next unless $game_party.members.include?(summon)
#|           next unless summon.exist?
#|
#|           equip.albert_combo_summon_state_ids.each do |state_id|
#|             next if state_id <= 0 || $data_states[state_id] == nil
#|             summon.add_state(state_id) unless summon.state?(state_id)
#|           end
#|
#|           skill_id = equip.albert_combo_summon_opening_skill_id
#|           next if skill_id <= 0 || queued_summon_ids[summon_actor_id]
#|           skill = $data_skills[skill_id]
#|           next if skill == nil
#|           next if summon.respond_to?(:skill_learn?) && !summon.skill_learn?(skill)
#|
#|           summon.action.clear
#|           summon.action.set_skill(skill_id)
#|           target_index = equip.albert_combo_summon_opening_target
#|           if target_index < 0
#|             summon.action.decide_random_target
#|           else
#|             summon.action.target_index = target_index
#|           end
#|           summon.action.forcing = true
#|           @forcing_battlers << summon
#|           queued_summon_ids[summon_actor_id] = true
#|         end
#|       end
#|       @status_window.refresh unless @status_window == nil
#|     end
#|   end
#| end
#|
#| class Scene_Title < Scene_Base
#|   unless method_defined?(:fsdb_create_game_objects_v20)
#|     alias fsdb_create_game_objects_v20 create_game_objects
#|     def create_game_objects
#|       fsdb_create_game_objects_v20
#|       ForestSymphonyDB.rebuild_armor_mapping
#|     end
#|   end
#| end
#| #==============================================================================
#| # ■ END
#| #==============================================================================

#==============================================================================
# [END Phase 12 Legacy Source]
#==============================================================================

#==============================================================================
# [Phase 13] 專案自製 Legacy 完整保留：FS_BattleStateHUD_Hotfix_BreakZeroHide v1.0
#------------------------------------------------------------------------------
# 狀態：Standalone Hotfix 已退休；功能已整合 FS_BattleStateHUD_Authority v2.6.0。
# 原 Phase 12 page：415
# SHA-256：a73b7f3e05534b6027e79b929c682c3261fbfd8402a49afd36f3116021f79b7e
# 原始碼保留方式：以下每行加 #| 註解，完整內容留在 Project History；
#                   byte-exact 原檔另存 FS_SCRIPT_ARCHIVE_PHASE13_COMPONENTS.zip。
#==============================================================================
#| #==============================================================================
#| # 【Forest Symphony｜繁體中文維護說明】
#| #------------------------------------------------------------------------------
#| # 腳本：FS_BattleStateHUD_Hotfix_BreakZeroHide v1.0
#| # 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_BattleStateHUD_Hotfix_BreakZeroHide v1.0」。
#| # 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
#| # 【主要影響】AlbertBattleStateHUD
#| # 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
#| # 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
#| # 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
#| # 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
#| # 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
#| # 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#| #------------------------------------------------------------------------------
#| # 維護規則：
#| # 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
#| # 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
#| # 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
#| # 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#| #==============================================================================
#| #==============================================================================
#| # ■ BattleStateHUD_破勢0層資訊列隱藏_HOTFIX
#| #------------------------------------------------------------------------------
#| # 功能：
#| #   BattleStateHUD 詳細資訊視窗中，
#| #   破勢進度為 0 時，不顯示「破勢 進度0/6……」資訊列。
#| #
#| #   破勢達到 1 層以上時，正常顯示。
#| #
#| # 放置位置：
#| #   所有 BattleStateHUD、破勢顯示相關腳本之後，Main 之前。
#| #==============================================================================
#|
#| if defined?(AlbertBattleStateHUD)
#|
#|   module AlbertBattleStateHUD
#|     class << self
#|
#|       # extra_info_rows 必須已由前方腳本定義
#|       if method_defined?(:extra_info_rows) &&
#|          !method_defined?(:albert_break_zero_hide_original_rows)
#|
#|         alias albert_break_zero_hide_original_rows extra_info_rows
#|
#|         def extra_info_rows(battler)
#|           rows = albert_break_zero_hide_original_rows(battler)
#|
#|           # 防止其他腳本意外回傳 nil 或非陣列
#|           return rows unless rows.is_a?(Array)
#|
#|           rows.reject do |row|
#|             # 相容資訊列為字串、陣列或巢狀陣列的情況
#|             values = row.is_a?(Array) ? row.flatten : [row]
#|
#|             text = values.collect { |value|
#|               value.to_s
#|             }.join(" ")
#|
#|             # 移除半形與全形空白，避免格式不同造成判斷失敗
#|             compact_text = text.gsub(/[　\s]/, "")
#|
#|             # 只排除「破勢」且進度為 0/x 的資訊列
#|             compact_text.include?("破勢") &&
#|               compact_text =~ /(?:進度)?0\//
#|           end
#|         end
#|
#|       end
#|     end
#|   end
#|
#| end
#==============================================================================
# [END Phase 13 Legacy Source]
#==============================================================================


#==============================================================================
# [Phase 21] FS_FriendlyMonsters_GoldFix 退休完整保留
#------------------------------------------------------------------------------
# 狀態：功能已等價回寫 `FriendlyMonsters_Core v1.1｜GoldFix Integrated`。
# 原 Phase 20 page：376
# SHA-256：5b148a7266ce80203d8e1abfe64a0798d9a1fab8b9503693fc5ed545845367e9
# 退休理由：本頁唯一功能是把第三方 gold_total 的 friendly_exp 誤植修成 friendly_gold；
#           無其他外部腳本引用本 Hotfix 的 alias／方法。回寫 Core 後保留同一最終金錢行為。
# byte-exact 原稿另存 Phase 21 Archive；以下為完整註解保留。
#==============================================================================
#| #==============================================================================
#| # 【Forest Symphony｜繁體中文維護說明】
#| #------------------------------------------------------------------------------
#| # 腳本：FS_FriendlyMonsters_GoldFix
#| # 【用途】Forest Symphony 相容／修正頁「FS_FriendlyMonsters_GoldFix」，針對既有系統補正專案需要的行為。
#| # 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
#| # 【主要影響】Game_Troop
#| # 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
#| # 【依賴／載入順序】依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
#| # 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
#| # 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
#| # 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
#| # 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#| #------------------------------------------------------------------------------
#| # 維護規則：
#| # 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
#| # 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
#| # 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
#| # 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#| #==============================================================================
#| #==============================================================================
#| # Albert_FriendlyMonsters_GoldFix_RGSS2.rb
#| #------------------------------------------------------------------------------
#| # RPG Maker VX / RGSS2
#| #
#| # 修正 Shanghai Simple Script - Friendly Monsters：
#| # 原本 gold_total 錯把 friendly_exp 當成金錢獎勵。
#| #
#| # 建議位置：Friendly Monsters 腳本之下，Main 之上。
#| #==============================================================================
#|
#| class Game_Troop < Game_Unit
#|   if method_defined?(:gold_total_sss_friendly_monsters)
#|     def gold_total
#|       total = gold_total_sss_friendly_monsters
#|
#|       for member in $game_troop.friendlies
#|         next if member == nil
#|         next if member.dead?
#|         total += member.enemy.friendly_gold
#|       end
#|
#|       return total
#|     end
#|   end
#| end

#==============================================================================
# 【Phase 22｜AutoSetup Duplicate Default Data 退休紀錄】
#------------------------------------------------------------------------------
# 退休內容：AutoSetup_01～06／08 內原本的大型正式資料副本。
# 原因：正常 Runtime 在 Scene_Title 載入資料庫前，FS_MasterSetup 18 Apply 已會
#       整份取代這些 DATA／設定常數；它們不是最終 Runtime Authority。
# 現況：AutoSetup 僅保留 Engine／Adapter／型別正確 Placeholder；正式資料唯一來源
#       為 FS_MasterSetup。原始頁 byte-exact 保存在
#       FS_SCRIPT_ARCHIVE_PHASE22_SETUP_DEFAULTS.zip。
# 安全措施：FS_DB_AUTOSET v1.5.0 新增 Authority Ready Guard；若 MasterSetup 18 未
#           成功握手，apply_all 直接報錯，不會靜默使用 Placeholder。
#==============================================================================


#==============================================================================
# 【Phase 24 退休紀錄｜Skill Cost Fix】
#------------------------------------------------------------------------------
# 退休頁：Skill Cost Fix
# 原因：其 calc_* 與 skill_can_use? 已被 FS_SkillCost_Authority 最終覆寫；
#       唯一仍必要的 Scene_Skill 支付流程已等價整合進 Authority v2.0.0。
#       Game_Party#lose_gold 的最終實作與 VX 原生 gain_gold(-n) 等價。
# 保留：完整 byte-exact 原稿位於 FS_SCRIPT_ARCHIVE_PHASE24_SKILLCOST_ORIGINALS.zip。
# 注意：Holy87 Parser/UI/Battle Timing Bridge、H87 SkillDelay 與 YEZ Skill Level
#       仍保留；它們已各自降為資料／時序／Modifier Provider，不可與退休頁混淆。
#==============================================================================
