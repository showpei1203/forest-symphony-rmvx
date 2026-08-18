#==============================================================================
# ■ FS_Runtime_LoadOrder_Guide v3.1
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
#
# 【目的】
#   這一頁是目前正式 Scripts.rvdata 的「載入順序地圖」。
#   Forest Symphony 已有大量 alias / class reopen / integration patch，
#   因此整理原則不是把同類腳本任意搬在一起，而是：
#
#     1. 先保留已驗證可玩的實際相對順序。
#     2. 用統一分區把功能責任整理清楚。
#     3. 後期整合 Patch 必須放在它所修補的原插件之後。
#     4. 真正要移動或合併腳本時，先解除 alias / constant / API 依賴。
#
# 【目前分區】
#   00～04  VX CORE
#            RPG Maker VX 原生 Module / Game Object / Sprite / Window / Scene。
#            禁止任意改變順序。
#
#   10      PROJECT RUNTIME / AutoSetup
#            FS_DB_AutoSetup_Engine → 01～06/08 Engine Adapter → 07 Audit → 90 User Hook。
#            Adapter 僅保留 Placeholder；正式資料唯一來源為 FS_MasterSetup 00～17。
#
#   11～17  Legacy Foundation / Gameplay / Map / Event / Quest
#            舊插件基礎與仍被事件、地圖、資料庫實際使用的功能。
#
#   20      Menu / UI / Save / Status
#            YEM Core 與其 Menu / Item / Status / Save 擴充保持現行順序。
#
#   30～39  Battle Runtime
#            AI → Tankentai/SBS → ATB → Add-ons → OD → HUD/畫面 →
#            Bestiary → Summon/Targeting → KGC → Additional → Skill Activation。
#
#   40～44  Job / Skill / Map Utility / Vehicle / Minigame
#
#   50      Legacy Compatibility / Core Fixes
#            這一區開始大量 reopen / alias 前面插件。
#            原則：只能往「被修補腳本之後」放，不可提前。
#
#   51      FS Battle Systems
#            Combo / Character Mechanic / HUD / Summon / Target / Capture 等正式整合。
#
#   52      FS UI / Database Support
#            Actor Profile、UI、圖鑑、Boss/Field Runtime、資料支援。
#
#   53      FS SBS Hero Action Sequences
#            六名主角 SBS Action Add-on；維持於 SBS / Battle Runtime 之後。
#
#   60      FS MasterSetup 00～20
#            必須依編號順序。
#            00 Base 先建立 namespace；01～17 定義資料；18 Apply 負責套用；
#            19 / 20 為 Apply 後完整性修正，不可提前。
#
#   61      FS Gameplay
#            Economy / Drop / Shop / Quest Bridge / Object Placement。
#
#   62      FS Final Integration
#            MarkedCommand、Battle HUD Patch、ForceAction、Map SBS、RandomDungeon、
#            Minimap、ATS/Safety、RingMenu、Save Compatibility 等最終整合層。
#            這批通常依賴前面一個以上舊插件，不要搬到原插件之前。
#
#   90      Validation
#            SaveCompatibilityTest / NonBattleValidation。
#            正式功能不依賴測試結果，但開發期間保留。
#
#   99      BOOT
#            Main → 全腳本導出工具 → 標題Final-0714。
#            依專案規則，後兩頁必須保留在 Main 下方。
#
#   100     Documentation
#            說明、設計、ID、State、技能庫等知識頁。
#            位於 Main 後，不參與正常 Runtime，可自由整併但不可丟失內容。
#
# 【幾條絕對不要踩的順序】
#   A. VX Core 原順序不要搬。
#   B. YEM Core 要先於其 Menu / Item / Status 等 YEM 擴充。
#   C. Tankentai General Settings / Battler Configuration / Sideview Core
#      必須先於其 Add-ons 與 FS SBS Action Add-on。
#   D. 所有 IntegrationFix / SafetyPatch / HOTFIX 必須位於被修補系統之後。
#   E. FS_MasterSetup 00～20 按編號排列，18 Apply 不得提前。
#   F. FS 最終安全層與 Validation 保持在 Main 前最後區段。
#
# 【Phase 6 已建立的 Authority Bundle】
#   - KGC_Steal｜Base + Tankentai Compatibility
#   - KGC_EnemyGuide｜Base + SBS Compatibility
#   - FS_BattleFormula_Authority v1.2
#   - FS_RandomTarget_Authority v1.2｜TargetPriority / Provoke
#   - FS_SummonUI_Authority v2.8
#   - FS_BattleTargetUI_Authority v1.4.1
#
#   以上只合併「原本相鄰」的腳本，內部仍依原載入順序排列。
#   詳細方法接管鏈見 FS_Battle_Authority_Map v2.0。
#
# 【未來新增腳本規則】
#   - 先判斷「誰是 Authority」，不要再新增 FinalFix2 / PatchFinal 之類平行實作。
#   - 若只是修正既有 FS Authority，優先併回該 Authority，而不是永久新增補丁頁。
#   - 新頁開頭需寫：用途、依賴、必須放在誰之後、事件/腳本呼叫、可調參數。
#==============================================================================
#
# 原 RPG Maker VX「外掛程式插入說明」保留摘要：
# 外掛應放於 Materials/外掛區、Main 之前；作者若有指定載入位置，以作者說明為準。
# RPG Maker XP 腳本不保證與 VX 相容。

#==============================================================================
# 【Phase 7：FS Battle Authority 命名與收斂】
#------------------------------------------------------------------------------
# 1. 頁名開始統一：FS_<Subsystem>_<Role> <Version>
#    Role 常用：Base / Core / Authority / Integration / Hotfix。
# 2. Phase 7 新增／收斂：
#    - FS_SummonRuntime_Authority v2.0.1
#    - FS_EquipSummonPage_Authority v1.0
#    - FS_StealResult_Authority v1.0
#    - FS_SBS_PresentationBridge_Authority v1.0.1
# 3. 只有原本相鄰的頁面才直接合併；跨區 alias chain 不因外觀整齊而搬動。
# 4. BattleStateHUD / Targeting / EquipmentCombo 仍有跨區後載入 外層包裝，
#    詳細 Authority 請查 FS_Battle_Authority_Map v1.1。
#==============================================================================

#==============================================================================
# 【Phase 8：Structural Authority Cleanup】
#------------------------------------------------------------------------------
# 本輪只直接合併「原本已相鄰、且屬於同一 Base/Extension/Fix chain」的頁面。
# 因此不改任何其他 Runtime 的相對順序。
#
# 新 Authority：
#   Bitmap Addons｜Core + Extension Authority
#   FS_Z21_Eventeer_Authority v1.1
#   MenuWindow_NoCursor｜Selectable + Command Core
#   BattleScape｜Base + Variable + Troop Authority
#   FS_BattleFog_Authority v1.0
#   KGC_PassiveSkill｜Base + Extension Authority
#   Area+｜Complete Authority
#   FS_ElementTypeAndUI_Provider v1.1
#   FS_ActorEnemyGrowth_Authority v2.1
#
# 【重要：仍不可物理合併的跨區鏈】
# EquipmentCombo：
#   Base → BattleIntegrity_MultiFix → 多個後續角色/狀態/資料庫補丁
#        → OpeningSkill_FinalAuthority
# BattleStateHUD：
#   Core → BreakZeroHide → MarkedCommand → BattleTargetUI
# 上述鏈的中間腳本會在載入時 snapshot/alias 既有方法，因此 Phase 8 只做
# Authority 命名與依賴說明，不把它們硬搬成一頁。
#==============================================================================

#==============================================================================
# 【Phase 28：Element Authority】
#------------------------------------------------------------------------------
# 1. FS_ElementTypeAndUI_Provider v1.1：提供唯一 FS_ELEMENT_TYPE_DATA、雙屬性資料、pokemon_element_rate
#    與屬性 UI，不再覆寫 element_rate / elements_max_rate。
# 2. KGC_AddEquipmentOptions：只提供 element_resistance / weak / guard /
#    invalid / absorb 等裝備資料；不再接管 Game_Actor#element_rate。
# 3. FS_ActorEnemyGrowth_Authority v2.1：USE_ENEMY_ELEMENT_RATE 設定仍保留，
#    由最終 Element Authority 讀取，不再自行包裝 element_rate。
# 4. FS_BattleBalanceCore v1.4：不再持有中間 element_rate wrapper。
# 5. FS_ElementRate_FinalAuthority v2.0：唯一最終戰鬥倍率入口，順序固定在
#    Element / Equipment / Growth Patch 之後。
# 6. FS_SupportStateSkillRules 仍在其後包裝 max_rate_for，僅用於回復／
#    Note 狀態技能的屬性中立化，不改一般攻擊倍率。
#==============================================================================

#==============================================================================
# 【Phase 9：中文文件標準】
#------------------------------------------------------------------------------
# Forest Symphony 保留／新增腳本的固定規則：
# 1. 腳本開頭必須有繁體中文維護說明。
# 2. 至少包含：用途、主要機制、設定／可調參數、依賴／載入順序、呼叫方式。
# 3. 有可直接呼叫 API／事件 Script Call／Notetag 時，必須附實際範例。
# 4. 原英文說明需在開頭中文區整理／翻譯其重要資訊；原作者英文文件、署名、
#    Credits 與 License 保留在下方，不可因中文化而刪除。
# 5. 不得為了補「範例」而杜撰不存在的 API；沒有對外入口時應明寫「自動執行」。
# 6. Alias／Compatibility／Authority Chain 的中文說明必須明確標出載入順序。
#==============================================================================

#==============================================================================
# 【Phase 10：AI／Targeting／Formula Authority 收斂】
#------------------------------------------------------------------------------
# 1. AutoBattleAI 已升級為 FS_AutoBattleAI_Authority v2.1。
#    Phase 11 將 MechanicExpansion 的角色 AI 條件／加分改為晚綁定 Hook：
#    Authority 在執行時呼叫 albert_mx_*，MechanicExpansion 不再 alias AI 八方法與 make_action。
#    兩頁位置仍維持既有順序，因 MechanicExpansion 其他戰鬥機制仍有載入時序語意。
# 2. TargetGroup_System + Target Selection Exact 收斂為
#    FS_TargetGroupExact_Authority v2.1；兩者原本相鄰，內部順序不變。
# 3. FS_BattleFormula_Authority v1.2 將同頁 calc_hit 的技能等級命中 外層包裝
#    直接回寫主 calc_hit，移除 albert_bfrt_old_calc_hit 一層 alias。
# 4. Targeting 前段 YERD_TargetEffects、DynamicThreat、Provoke、TargetingCompatibility
#    仍需保持 分階段依賴鏈；MarkedCommand／BattleTargetUI 仍是後段 外層包裝。
#==============================================================================

#==============================================================================
# 【Phase 11：AutoBattleAI ↔ MechanicExpansion Alias 解耦】
#------------------------------------------------------------------------------
# 1. FS_AutoBattleAI_Authority v2.1 直接內建晚綁定 Mechanic 掛鉤。
# 2. FS_MechanicExpansion 保留 albert_mx_ai_* / Robot Protocol 資料與方法，
#    但不再 alias albert_ai_damage_score、albert_auto_ai_note_bonus、五種 package、
#    process_ai_package 或 Game_Actor#make_action。
# 3. 實際行為順序維持：require_state 過濾 → AI 評分／選技 → target bonus → 最終目標修正。
# 4. Robot Protocol 仍優先於一般 AI；改由 AutoBattleAI#make_action 在執行時直接呼叫 Hook。
#==============================================================================

#==============================================================================
# 【Phase 12：Robot / DatabaseSupport Authority 收斂】
#------------------------------------------------------------------------------
# 1. 舊「6主角＋5映體＋5機器人資料庫 v2.0」不再參與 Main 前 Runtime；
#    其完整原始碼已整合保存於 Main 後 FS_LegacyCode_Archive_Index，另有外部 Archive。
# 2. Compact ID 正式 Authority：FS_DatabaseSupport_Authority v2.2 CompactID。
#    Robot Skill 185～189；核心 Armor 286～295；成長 Enemy 590～599。
# 3. Robot fixed pattern 已回寫 FS_AutoBattleAI_Authority v2.2：
#      協議回合 -> albert_mx_try_robot_protocol
#      非協議回合 -> 固定普通攻擊
#    DatabaseSupport 不再 alias Game_Actor#make_action。
# 4. 舊存檔若仍保存 v2.0 ArmorMapping 732～741，rebuild_armor_mapping 會精確移除
#    舊值後再建立 286～295；不得重新加入 732～741 Runtime mapping。
#==============================================================================

#==============================================================================
# 【Phase 13：BattleStateHUD extra_info_rows Authority 收斂】
#------------------------------------------------------------------------------
# 最終責任：FS_BattleStateHUD_Authority v2.6.0 TC。
#
# 原 staged chain：
#   BattleStateHUD Core
#     -> FS_ActorProfile（Clone 穩定度 wrapper）
#     -> BreakZeroHide Hotfix
#     -> FS_MarkedCommand（職能 wrapper）
#
# Phase 13：
#   1. Break 0/x 隱藏直接整合 break_rows。
#   2. ActorProfile 保留 clone_stability_rows 資料 Provider，不再 alias。
#   3. MarkedCommand 保留 role_text 資料 Provider，不再 alias。
#   4. extra_info_rows 只剩 BattleStateHUD Authority 一份正式定義。
#
# BattleTargetUI 仍位於後方，因其負責 Detail Window layout、Target Overlay、
# Scene_Battle lifecycle 與 update_basic 支援，Phase 13 不搬動。
#==============================================================================

#==============================================================================
# 【Phase 19：Steal / BattleStatusHUD 文件與責任校正】
#------------------------------------------------------------------------------
# 1. KGC Steal 頁的正式定位改稱「Base + Tankentai Compatibility」，不是最終 Authority。
#    正式鏈：KGC Base/Compat → FS_DynamicCaptureRate → FS_SoulRepeatRecipe
#            → FS_SkillCost_AllFix → FS_StealResult_Authority。
# 2. BattleStatusHUD_Core｜0226 是底部隊伍 HP/MP/OD Skin Core；下一頁 OverDrive
#    直接依賴其 BTSKIN_* 常數與 sprite index。它與 FS_BattleStateHUD_Authority
#    （狀態詳細資訊 Overlay）是兩套不同責任，不能互相取代。
# 3. Phase 19 只做名稱／文件校正，不改這兩條 Runtime chain。
#==============================================================================
#
# 【Phase 20：Bitmap / EnemySummon 責任釐清】
# 1. Bitmap Addons 與 KGC_BitmapExtension 不重複：前者是輕量 UI Bitmap API；後者是
#    TRGSSX.dll 驅動的 Region／Raster／Polygon 進階層，兩者皆有正式後續依賴。
# 2. EnemySummon_SafePosition 已從 TargetingCompatibility 移回 EnemySummon_Core v1.1。
# 3. FS_TargetingCompatibility_Layer v1.1 不再管理 ma_call_ally；Targeting 與 Enemy Summon
#    的責任邊界正式分離。
# 4. AutoSetup_12｜FS_EnemySummonGuard_FinalAuthority 仍留在後段，作 Actor 禁用與強制行動
#    的最終安全層；不得因 SafePosition 已回寫就提前。

# 【Phase 21：Setup / AI / Equipment 三大整理主線】
# 1. Setup：AutoSetup_00～08/90 → DatabaseSupport/AutoSetup_09～12 → FS_MasterSetup_00～20 → Apply/Integrity。
#    先盤點誰建立資料、誰覆蓋資料、誰只做 Runtime Guard，再逐組 Authority 化；不可把 MasterSetup 當 AutoSetup 的重複品。
# 2. AI：FS_AutoBattleAI_Authority v2.2 已是 Game_Actor#make_action 專案層入口；MechanicExpansion 僅提供晚綁定 Hook。
#    後續還要整理 Actor/Robot/Enemy AI 資料來源與測試矩陣，避免再新增 make_action wrapper。
# 3. Equipment：KGC AddEquipmentOptions / Equipment Skills / YEM Equipment Overhaul → FS SafetyPatch / SummonEquip /
#    EquipmentCombo / MasterSetup Equipment / Shop&Help UI。此鏈尚未完成收斂，新增裝備機制前先查 Equipment Roadmap。
# 4. 測試框架：等上述三條 Authority 邊界固定後，新增 FS_TestHarness。預定使用不衝突的測試快捷鍵開啟
#    非戰鬥回歸與全自動戰鬥回歸，所有 ASSERT / Exception / Round / Action 寫入專用 LOG。
# 【Phase 21：Friendly Monsters】Gold reward hotfix 已回寫 FriendlyMonsters_Core；獨立 FS_FriendlyMonsters_GoldFix 退休。

#------------------------------------------------------------------------------
# 【Phase 22｜Setup 單一資料來源規則】
#------------------------------------------------------------------------------
# AutoSetup_00_Core / 01～06 / 08：Engine + Adapter。
#   - 01～06／08 的 DATA 等常數只保留型別正確 Placeholder。
#   - 不再保存可修改的第二份 Forest Symphony 正式資料。
# AutoSetup_07_Audit：Validation。
# AutoSetup_90_UserExtensions：最後使用者 Hook。
# FS_MasterSetup 00～17：唯一正式 Data Authority。
# FS_MasterSetup 18 Apply：Authority Data → AutoSetup Engine Bridge + Ready 握手。
# FS_MasterSetup 19／20：Post-Apply Integrity Guard。
#
# 正常時序：
#   Script load
#     → 建立 AutoSetup Engine/Placeholder
#     → 建立 MasterSetup Authority Data
#     → 18 Apply 取代 Placeholder，標記 READY
#   Scene_Title#load_database
#     → VX 載入 Data/*.rvdata
#     → FS_DB_AUTOSET.apply_all
#     → 以 Authority Data 寫回 $data_*
#
# 禁止：
#   - 在 AutoSetup Adapter DATA 內重新建立正式資料。
#   - 把 18 Apply 搬到 00～17 之前。
#   - 移除 Authority Ready Guard 後以空 Placeholder 啟動。
#------------------------------------------------------------------------------


#==============================================================================
# 【Phase 23｜AI Authority / Deterministic Random】
#------------------------------------------------------------------------------
# 1. AI 區第一個正式 Runtime Hook：FS_AI_DeterministicRandom v1.0。
#    必須位於 EnemyActionPattern / DynamicThreat / AutoBattleAI / Boss Runtime 之前。
# 2. 正常遊戲 FS_AI_RANDOM.enabled? == false；rand 直接委派 Kernel.rand，禁止預設啟用固定亂數。
# 3. 只有 $TEST 且測試腳本明確呼叫 FS_AI_RANDOM.enable(seed) 時才進 deterministic mode。
# 4. Actor AI Final：FS_AutoBattleAI_Authority v2.3；MechanicExpansion 仍只是 late-bound Provider。
# 5. Enemy AI：EnemyActionPattern_Core -> FriendlyMonsters ->
#    FS_EnemyActionDistribution_FinalAuthority v1.1。Boss Runtime 只動 candidate_actions_enemy。
# 6. Final random target：FS_RandomTarget_Authority v1.2；Provoke / target weight / hard exclude 在此收斂。
# 7. Phase 23 只收斂「AI 決策 RNG」。命中、傷害 variance、State 成功率等 Combat RNG 後續由
#    Battle Test Harness 另建 provider，不要把兩者混在同一層。
#==============================================================================


#==============================================================================
# 【Phase 24｜Skill Cost Authority】
#------------------------------------------------------------------------------
# 1. `SkillCost_LegacyBase` 現在只負責 Holy87 Notetag／legacy accessor／UI 與
#    Battle Timing Bridge；不再擁有 calc_*、skill_can_use? 或 Scene_Skill 支付。
# 2. `Skill Cost Fix` 已正式退休並移到 Project History / 外部 Archive。
# 3. `YEZ Job System: Skill Levels` 不再 alias calc_mp_cost；只提供 apply_level_cost modifier。
# 4. `FS_SkillCost_Authority v2.0.0` 是最終成本 Authority：
#      Parse -> Calculate -> Availability -> Menu Payment -> Battle MP/Angry -> UI。
# 5. 戰鬥 HP/Gold/Variable/Item 的「支付時點」仍保留在 Legacy Battle Timing Bridge，
#    但金額與支付政策由最終 Authority 晚綁定提供，避免改變 CharacterMechanic 等外層時序。
# 6. Steal 技能 MP 仍由 KGC Steal 分支支付；Final Authority 會辨識並避免 MP 重扣。
#==============================================================================


#==============================================================================
# 【Phase 25｜Skill Effect Pipeline】
#------------------------------------------------------------------------------
# Game_Battler#skill_effect 仍是 staged chain，跨頁順序不可重排。
# Phase 25 只消除四個同頁自我 alias：CharacterMechanic、MechanicExpansion、
# StateEffects、IvyClone。跨頁 Steal／Field／Combo／ActorProfile／FieldWeather／
# SoulMark／SupportState／PokemonFollowup 等仍保留真實時序。
# AutoSetup_01 的 <fs_user_add_state> patch 於 Scene_Title#load_database 後晚安裝，
# 是資料載入完成後的最外層 adapter，不等同於早期 AutoSetup Page 順序。
#==============================================================================

#==============================================================================
# 【Phase 26：Damage Pipeline 第一輪】
#------------------------------------------------------------------------------
# 1. FS_BattleFormula_Authority v1.2 是 Hit/Eva/Crit/Smooth Defense 核心，
#    但不是 make_obj_damage_value / execute_damage 的全鏈最終頁。
# 2. YEZ Skill Levels 的 calc_hit_jpsl 已退休；level_hit 由 BattleFormula 直接讀。
# 3. 最終 calc_eva 必須保留 KGC ReproduceFunctions 的普通攻擊 ignore_eva 語意。
# 4. Damage Pipeline 目前仍是 Staged Chain：Custom Formula / Equipment / Integer /
#    BattleFormula / Combo / Character / State / Weather / SoulMark / Support / Marked。
# 5. 在 Phase 27 Residual/Drain 與 Phase 28 Element 完成前，不可把單一 make_obj
#    wrapper 誤稱為「所有傷害最終 Authority」。
#==============================================================================

#==============================================================================
# 【Phase 27：Residual / Drain / Leech】
#------------------------------------------------------------------------------
# 1. FS_StateEffects_Integration v3.3 是 HP/MP Slip、Regen/Degen 與寄生種子
#    的正式 Residual Authority。
# 2. FS_BattleUtility_RuntimeBridge 不再保存舊 10%/999 cap 寄生公式；
#    只保留 CSP dispatch / LifeLink / HealBlock / SkillDelay 等橋接。
# 3. VX 原生 absorb_damage 仍由 Game_Battler#make_obj_absorb_effect + execute_damage
#    處理；SoulMark :drain 是另一條 post-effect，尚不硬合併以免改時序。
# 4. 普攻 Armor 212 的 force_damage 吸血屬於舊 CustomDamage/Tankentai 演出路徑，
#    也先保留到 Equipment 整理。
# 5. Combat RNG（Slip variance / crit / damage variance）仍未導入 deterministic provider；
#    等 Element/Equipment baseline 完成後由正式 Battle Harness 一次接上。
#==============================================================================

#==============================================================================
# 【Phase 28：Element Final Authority】
#------------------------------------------------------------------------------
# 1. FS_ELEMENT_TYPE_DATA 是 Pokémon 屬性表唯一資料來源；Battle / UI 共用同一 CHART。
# 2. FS_ElementRate_FinalAuthority v2.0 是 element_rate / elements_max_rate 正式倍率 Authority。
# 3. KGC equipment weak/guard/invalid/absorb/resistance 已直接整合 FinalAuthority；
#    KGC 舊 element_rate wrapper、ElementBase 中間 wrapper、ActorEnemyGrowth／BattleBalance
#    中間 element wrapper 已退休。
# 4. FS_SupportStateSkillRules 可合法位於 FinalAuthority 後，只負責 Recovery / Note-State
#    技能的 element-neutral 特例；不要誤認為另一套一般屬性倍率。
#==============================================================================

#==============================================================================
# 【Phase 29：Equipment Authority Pass 1】
#------------------------------------------------------------------------------
# 詳細責任請看 `FS_Equipment_Authority_Map v1.0`。
# 1. Equipment Data 唯一正式來源：FS_MasterSetup 09；AutoSetup 04/05 只是 Adapter。
# 2. FS_EquipmentSkill_Authority v2.1 已吸收 Modern Algebra \ls Parser + Runtime，
#    以及 Shanghai <equipskill> Parser + Runtime；兩個舊獨立頁正式退休。
# 3. KGC PassiveSkill 不再早期 alias change_equip；EquipmentSkill Authority 在 YEM
#    extra-slot 完整更新後統一 restore_passive_rev。
# 4. ArmorMapping Storage 不保存正式預設；Compact 286～295 由 DatabaseSupport v2.3
#    管理，SaveCompatibility v1.1 在新遊戲與每次讀檔後都 normalize。
# 5. PokemonSummon 101/103/105 Armor Mapping Init 已退休；舊存檔精確 migration 仍保留。
# 6. EquipmentCombo 仍是 staged chain：Base -> BattleIntegrity / middle runtime ->
#    OpeningSkill FinalAuthority；目前禁止物理合併。
#==============================================================================


#==============================================================================
# 【Phase 30｜YEM Equipment Core Authority】
#------------------------------------------------------------------------------
# YEM Equipment Overhaul｜FS CoreSafe v1.1
#   → 直接擁有 equip_type／equip_type=／add/delete type／purge／equip_legal_slot。
# FS_YEM_EquipmentUI_SafetyPatch v1.1
#   → 必須仍位於 YEM Core 後方，但只處理 UI／Summon Preview／Optimize／Scene 相容。
#   → 不再覆寫上述六個 Game_Actor Core 方法。
# SetupRuntime_10 仍依賴 ALBERT_YEM_EQUIP_SAFE.valid_type?，所以 helper module 不可刪除。
#==============================================================================

#==============================================================================
# 【Phase 31｜Equipment Combat / Combo Authority】
#------------------------------------------------------------------------------
# FS_EquipmentRuntime_Authority v1.2
#   → 裝備戰鬥政策 Provider；Armor 212 普攻吸血由此管理，仍在原 Custom Formula
#     時點呼叫 Tankentai force_damage，不改回復／Popup 時序。
# FS_EquipmentCombo_Base v1.2
#   → Combo 資料、狀態 Storage API、process_battle_start hook。
# FS_EquipmentCombo_OpeningSkill_FinalAuthority v2.0
#   → albert_prepare_equipment_combo_battle_effects 唯一正式實作。
#   → 保留 v1.3 正式規則：開場技能不要求 summon 已自然學會。
#   → 同時恢復 BattleIntegrity 的「只擁有本場新加入 State」清理安全。
# DatabaseSupport / BattleIntegrity 不再覆寫 prepare method。
#==============================================================================
