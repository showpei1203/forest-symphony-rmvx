#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MarkedCommand_ConditionTransparency v1.6
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_MarkedCommand_ConditionTransparency v1.6」。
# 【主要機制】管理鳴刻指令、共鳴標記合法目標、OD／ATB／追擊與相關 UI。Phase 13 起職能 HUD 資料只由 role_text 提供，BattleStateHUD Authority 於 Runtime 晚綁定讀取；本頁不再 alias extra_info_rows。
# 【主要影響】RPG::Skill、Scene_Title、Game_Battler、Game_BattleAction、Scene_Battle、Window_LevelData、FS_MARKED_COMMAND
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MARK_STATE_ID、MARK_SKILL_ID、COMMAND_SKILL_ID、COMMAND_FOLLOW_SKILL_ID、COMMAND_ROLE、COMMAND_MAX_LEVEL、COMMAND_OD_NEED_BY_LEVEL、COMMAND_OD_COST_BY_LEVEL。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】仍含鳴刻指令／Targeting／Action 等既有 alias，載入順序具有語意；登記 $imported：FS_MarkedCommand_ConditionTransparency。Phase 13 已解除 BattleStateHUD extra_info_rows alias；Targeting 與 execute_action 鏈仍依 Authority Map 維持位置。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
# -*- coding: utf-8 -*-



#==============================================================================



# ** FS_MarkedCommand_ConditionTransparency v1.6



#------------------------------------------------------------------------------



#  Forest Symphony／RPG Maker VX／RGSS2／Ruby 1.8



#------------------------------------------------------------------------------



# 【v1.6 目標選擇刷新效能修正】
#
#  v1.5 在鳴刻指令選擇目標期間，每一幀都會重新指定 @target_members、
#  重設 Tankentai 游標，並重畫 Window_Help。當 Help Window 同時繪製
#  屬性、狀態與魂刻擷取率時，會產生可感知的卡頓。
#
#  v1.6 改用 Albert_TargetPriority_SelectionFix 相同策略：
#    ・每幀仍重新取得合法目標，以支援 ATB 中死亡、離場或失去標記。
#    ・若 targets == @target_members 且目前 index 合法，立即返回。
#    ・只有合法目標清單真的改變，才重設游標與重畫 Help Window。
#    ・開始選擇時仍強制同步一次，確保首次顯示完全正確。
#
# 【v1.5 魂刻追擊後普通攻擊目標模式殘留修正】

#

#  Skill 104「鳴刻指令」完成後，Scene_Battle 的 @skill 仍可能保留

#  Skill 104。下一名角色選擇普通攻擊時，舊版 fs_mc_selecting_command?

#  會先讀取其他目標腳本的 @skill 後備值，因而把普通攻擊誤判成

#  「仍在選擇鳴刻指令」，並顯示：

#

#      場上沒有可指定的【共鳴標記】目標。

#

#  v1.5：

#    ・鳴刻指令判定只信任目前指令使用者的 Game_BattleAction。

#    ・普通攻擊、防禦與其他基本行動不再讀取殘留的 @skill／@item。

#    ・新角色開始輸入指令時清除上一名角色的技能／物品快取。

#    ・開始選擇目標前，依目前 action 重新同步 @skill／@item。

#    ・同一角色取消鳴刻指令後改選普通攻擊，也不會再次誤觸。

#

# 【v1.4 Scene_Battle 巢狀類別修正】



#



#  v1.3 將第二段：



#



#      class Scene_Battle < Scene_Base



#



#  錯誤插入在第一個 Scene_Battle 尚未結束的位置，Ruby 因此建立：



#



#      Scene_Battle::Scene_Battle



#



#  該巢狀類別沒有 execute_action，啟動時便在 alias 行發生 NameError。



#



#  v1.4：



#    ・移除第二個 Scene_Battle 宣告。



#    ・把鳴刻指令的延後 ATB 回饋，直接整合進既有 execute_action 包裝。



#    ・完整行動結束後才套用 Lv2／Lv3 的 15%／25% ATB 回饋。



#    ・保留 v1.3 的升級、OD顯示、動態說明、合法目標與標記必中。



#



# 【v1.3 鳴刻指令正式升級與完整 UI 同步】



#



#  Skill 104「鳴刻指令」改為可升 3 級。



#



#                  基礎    Lv1    Lv2    Lv3



#    追擊增傷       50%    60%    70%    80%



#    啟動OD門檻     350    325    300    300



#    成功OD消耗      80     80     80     60



#    喬伊ATB前進      0%     0%    15%    25%



#



#  其他正式調整：



#



#    ・冷卻由 1 回合改為 2 回合。



#    ・追擊命中後不再消耗共鳴標記。



#    ・技能列表消耗欄顯示當前等級的 OD 成本。



#    ・技能 Help 依目前等級即時更新全部數值。



#    ・技能升級頁直接顯示升級前後：



#         追擊增傷／OD門檻／OD消耗／ATB前進／標記規則／冷卻。



#    ・升級頁不再顯示毫無意義的「0 傷害倍率」。



#    ・實際追擊、可用條件、說明與升級預覽共用同一組資料。



#



#  注意：



#    鳴刻指令的 OD 是「追擊成功後支付」的條件成本，



#    因此不加入 KGC <overdrive N>，避免技能使用時與追擊完成時扣兩次。



#    本補丁只在技能消耗欄補上玩家可見的動態 OD 數字。



#



# 【v1.2 共鳴爪印必中與提示生命週期修正】



#



#  A. Skill 101「共鳴爪印」



#



#     原本的 <state_chance 40:100> 會再乘上目標的 State 40 有效率：



#



#         最終機率 = 100% × 目標 State 40 有效率



#



#     因此敵人若只有 60% 有效率，實際仍只有 60%。



#



#     v1.2 將 Skill 101／State 40 視為戰術座標，不是一般異常：



#



#       ・技能成功命中後，State 40 最終機率固定為 100%。



#       ・無視敵人的 State 40 抗性與 Rank。



#       ・技能本身若被跳過、Miss 或 Evade，仍不會附加。



#       ・目標已有 State 40 時，沿用原 remained_rules 刷新持續時間。



#



#  B. 戰鬥提示



#



#     ・提示預設由 90 Frames 縮短為 45 Frames。



#     ・記錄提示所屬的行動者。



#     ・下一名行動者接手時立即清除。



#     ・下一個 execute_action 開始前立即清除。



#     ・下一名角色進入指令選擇時立即清除。



#     ・只在 Help 目前仍顯示本補丁文字時才清空，避免抹掉新角色的 Help。



#



# 【v1.1 合法目標選擇修正】



#



#  v1.0 錯誤攔截 VX 預設的 update_target_enemy_selection。



#  本專案實際使用 Tankentai ATB 的：



#



#      start_target_selection



#      update_target



#      @target_members



#



#  因此 v1.1 改為：



#



#    1. 開始選擇 Skill 104 目標時，直接把 @target_members 篩成



#       「存活、可手動指定、持有 State 40」的敵人。



#



#    2. 游標只能在這份合法清單中移動，未標記敵人不會出現在選擇循環。



#



#    3. 確認時保存敵人在原始 $game_troop.members 中的真正 index，



#       並相容 ALBERT_EXACT_TARGET_FIX.albert_exact_selected_target。



#



#    4. 實際執行 Game_BattleAction#make_obj_targets 時再次驗證：



#       若原目標死亡、離場或失去標記，回傳空目標，不得自動轉打其他敵人。



#



#    5. Skill 104 自動加入 <ignore target priority>，



#       避免 TargetPriority_SelectionFix 在每幀更新時把未標記高優先敵人



#       重新塞回 @target_members。



#



# 【功能】



#



#  A. 共鳴爪印／鳴刻指令正式連動



#



#     共鳴爪印（State 40）



#       ・喬伊技能仍可對標記目標獲得既有增傷。



#       ・任何我方召喚物以傷害技能命中標記目標時，



#         每次行動額外替喬伊回收 40 OD。



#



#     鳴刻指令（Skill 104）



#       ・喬伊目前 OD 必須至少 450。



#       ・場上必須有可行動的【先導型】召喚物。



#       ・場上必須有存活的共鳴標記目標。



#       ・只能確認共鳴標記目標。



#       ・命令先導型召喚物使用 Skill 190 立即追擊。



#       ・該次追擊對標記目標最終傷害 +30%。



#       ・追擊命中後消耗目標的共鳴標記。



#       ・追擊執行後仍沿用原系統消耗 80 OD。



#       ・追擊未命中時，標記保留，但原追擊 OD 成本仍照舊支付。



#



#  B. 技能條件透明化



#



#     ・重寫具有隱藏門檻、條件成本或狀態消耗的主角技能說明。



#     ・戰鬥中選擇鳴刻指令時，Help 額外顯示目前可追擊者或失敗原因。



#     ・追擊未發動時，直接顯示具體原因。



#     ・召喚物 Battle State HUD 詳細資訊增加：



#



#         職能：先導型／運轉型／終結型



#



#     ・未來使用 <特殊使用条件> 的技能，自動在說明後附加條件摘要。



#



# 【不修改】



#



#     ・Skill 104 原本的 MP、冷卻、Skill 190 與 OD 數值。



#     ・Skill 107／108／109 的追擊邏輯與連鎖數值。



#     ・召喚物正常 ATB 與下一回合。



#     ・共鳴標記對喬伊技能原本的 30%／45%／60% 增傷。



#



# 【安裝位置】



#



#  必須放在下列所有腳本之後、Main 正上方：



#



#     FS_MasterSetup_AllData



#     FS_AUTOSET_PLAYER_TEXT_V12



#     CharacterMechanicCore



#     MechanicExpansion



#     SummonChain3



#     ActorProfile／Clone Stability



#     Battle State HUD



#     所有 Skill Cost／OD／skill_can_use? 補丁



#



#  本腳本是後置整合補丁，不需要修改技能 Note。



#==============================================================================







$imported = {} if $imported == nil



$imported["FS_MarkedCommand_ConditionTransparency"] = "1.6"







module FS_MARKED_COMMAND







  VERSION = "1.6"







  MARK_STATE_ID             = 40



  MARK_SKILL_ID             = 101



  COMMAND_SKILL_ID          = 104



  COMMAND_FOLLOW_SKILL_ID   = 190



  COMMAND_ROLE              = "starter"



  COMMAND_MAX_LEVEL         = 3







  COMMAND_OD_NEED_BY_LEVEL = {



    0 => 350,



    1 => 325,



    2 => 300,



    3 => 300



  }







  COMMAND_OD_COST_BY_LEVEL = {



    0 => 80,



    1 => 80,



    2 => 80,



    3 => 60



  }







  COMMAND_DAMAGE_BY_LEVEL = {



    0 => 50,



    1 => 60,



    2 => 70,



    3 => 80



  }







  COMMAND_ATB_BY_LEVEL = {



    0 => 0,



    1 => 0,



    2 => 15,



    3 => 25



  }







  COMMAND_JP_BY_LEVEL = {



    1 => 600,



    2 => 1800,



    3 => 4500



  }







  COMMAND_COOLDOWN           = 2



  MARK_HIT_OD_GAIN          = 40



  NOTICE_FRAMES             = 45







  ROLE_LABELS = {



    "starter"  => "先導型",



    "engine"   => "運轉型",



    "finisher" => "終結型"



  }







  TYPE_LABELS = {



    "pokemon" => "寶可夢",



    "robot"   => "機器人",



    "clone"   => "映體"



  }







  #--------------------------------------------------------------------------



  # ● 最終玩家技能說明



  #--------------------------------------------------------------------------



  # 僅覆蓋存在隱藏門檻、條件成本、狀態消耗或原說明不符實際效果者。



  #--------------------------------------------------------------------------



  SKILL_HELP = {



    # 喬伊



    100 => "草物理；45%標記。成功標記且OD≥100時耗100，最快召喚ATB前進12%（刷新18%）。",



    101 => "小幅傷害並必定標記。召喚攻擊標記目標時替喬伊回收40 OD；可供鳴刻指令消耗。",



    102 => "被動：召喚物正常完成一次行動時，喬伊獲得55 OD。",



    103 => "草傷、削ATB12%、40%遲緩；對共鳴標記目標增傷30%。",



    104 => "只能指定共鳴標記目標；先導型免費追擊。基礎增傷50%，需350 OD，成功耗80 OD；標記保留，冷卻2回合。",



    105 => "敵單體草／龍混合傷；對共鳴標記目標增傷45%。",



    106 => "被動：OD≥70%時增傷20%，並提高最大MP10%。",



    107 => "混合傷、對標記增傷30%；場上寶可夢於OD≥600時追擊，成功後耗120 OD。",



    108 => "三聲連鎖：寶可夢650→機器人700（耗100）→映體178（耗250）；缺任一段即中止。",



    109 => "全體草／龍、對標記增傷60%；先導178→運轉900（耗150）→終結1000（耗350）。",







    # 米亞



    111 => "單體治療；每產生相當於目標最大HP 10%的溢療，米亞獲得1層魔力。",



    112 => "被動：每1%溢療獲2.5 OD；每1% OD使治療量提高0.15%。",



    113 => "單體治療；消耗150 OD，將75%溢療轉為護盾。",



    115 => "妖精魔法；米亞每層魔力使傷害提高15%。",



    117 => "妖精／飛行爆發；每層魔力增傷20%，命中後消耗最多3層。",



    118 => "復活單體；起手OD≥300時耗300，至少復至60%HP並獲20%最大HP護盾。",



    119 => "全體治療；60%溢療轉護盾，每25%最大HP溢療使米亞獲得1層魔力。",







    # 艾卓



    121 => "鋼／電物理、削ATB16%；目標ATB≥60%時削減幅度再提高35%。",



    123 => "電混合、削ATB14%；濕潤時削減幅度+60%，麻痺附加率再+35%。",



    124 => "消耗250 OD獲得超載；下一次ATB削減與穿透各提高30%。",



    125 => "削ATB24%；目標ATB≥80%時強化。成功打斷可耗200 OD並附遲緩2回合。",



    127 => "敵全體電魔法；濕潤目標傷害+35%、ATB削減幅度+40%。",



    128 => "削ATB35%；目標ATB≥90%時強化。成功打斷可耗350 OD並附遲緩2回合。",



    129 => "全體電爆發；目標ATB≥70%時傷害+40%、ATB削減幅度+50%。",







    # 維娜



    132 => "被動：毒、寄生、腐蝕成功率+10%；每1% OD再提高0.1%。",



    133 => "消耗150 OD，把目標中毒完整擴散給最多2名其他敵人。",



    134 => "草傷；將1份中毒轉移至其他敵人，並有40%機率附加寄生。",



    135 => "中毒轉腐蝕；起手OD≥150時成功後耗150，並保留1層中毒。",



    137 => "每個目標異常增傷12%；異常達3種時再增傷35%。",



    138 => "消耗300 OD引爆中毒並增幅20%，傷害上限6000；結算後保留1層中毒。",



    139 => "全體毒／草傷；目標每個異常增傷8%，並附加中毒與腐蝕。",







    # 艾薇



    142 => "被動：OD≥50%時減傷12%，且每1% OD再減傷0.08%。",



    143 => "草／毒物理；每1% OD增傷0.35%，蓄痛每25%再增傷5%，最多30%。",



    147 => "追加蓄痛50%的固定復仇傷害；成功後清空全部蓄痛。",



    148 => "消耗250 OD；OD≥70%時增傷45%，每100 OD再增傷5%。",



    149 => "全體重擊並追加蓄痛80%的固定傷害；成功後清空全部蓄痛。",







    # 泰勒



    153 => "對已有破勢者增傷35%；起手OD≥100時成功後耗100，再增傷15%並延後破勢回復。",



    155 => "基礎累積2點破勢；OD≥50%可耗150加1點，OD≥80%再耗200加1點。",



    158 => "對崩防目標增傷120%；命中後消耗崩防狀態。",



    159 => "全體累積2點破勢；OD≥80%時可耗150再增加1點。"



  }







  FOLLOWUP_SKILL_IDS = [104, 107, 108, 109]







  #--------------------------------------------------------------------------



  # ● 通用工具



  #--------------------------------------------------------------------------



  def self.note(obj)



    return "" if obj == nil



    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil



    return ""



  end







  def self.joey?(actor)



    return false if actor == nil



    return actor.albert_cc_joey? if actor.respond_to?(:albert_cc_joey?)



    if defined?(ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID) &&



       actor.respond_to?(:id)



      return actor.id.to_i == ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID



    end



    return actor.respond_to?(:id) && actor.id.to_i == 1



  end







  def self.joey



    return nil if $game_party == nil



    for actor in $game_party.members.compact



      return actor if joey?(actor)



    end



    if defined?(ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID) &&



       $game_actors != nil



      return $game_actors[ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID]



    end



    return nil



  end







  def self.od(actor)



    return 0 if actor == nil



    return actor.overdrive.to_i if actor.respond_to?(:overdrive)



    return 0



  end







  def self.summon?(actor)



    return false if actor == nil



    return false unless actor.respond_to?(:actor?) && actor.actor?



    return actor.albert_summon? if actor.respond_to?(:albert_summon?)



    return false



  end







  def self.role?(actor, role_name)



    return false unless summon?(actor)



    if actor.respond_to?(:albert_mx_summon_role?)



      return actor.albert_mx_summon_role?(role_name.to_s)



    end



    if actor.respond_to?(:albert_mx_summon_roles)



      return actor.albert_mx_summon_roles.include?(role_name.to_s.downcase)



    end



    return false



  end







  def self.type?(actor, type_name)



    return false unless summon?(actor)



    if actor.respond_to?(:albert_summon_type)



      return actor.albert_summon_type.to_s.downcase ==



             type_name.to_s.downcase



    end



    return false



  end







  def self.in_battle?(actor)



    return false if actor == nil



    if defined?(ALBERT_CHARACTER_CORE) &&



       ALBERT_CHARACTER_CORE.respond_to?(:actor_in_battle?)



      return ALBERT_CHARACTER_CORE.actor_in_battle?(actor)



    end



    return false if $game_party == nil



    return $game_party.members.include?(actor)



  end







  def self.active?(actor)



    return false if actor == nil



    return actor.active ? true : false if actor.respond_to?(:active)



    return false



  end







  def self.existing?(actor)



    return false if actor == nil



    return actor.exist? if actor.respond_to?(:exist?)



    return !actor.dead? if actor.respond_to?(:dead?)



    return false



  end







  def self.party_summons



    result = []



    return result if $game_party == nil



    for actor in $game_party.members.compact



      result.push(actor) if summon?(actor)



    end



    return result



  end







  def self.role_candidates(role_name, ready_only = false)



    result = []



    for actor in party_summons



      next unless role?(actor, role_name)



      next unless in_battle?(actor)



      if ready_only



        next unless existing?(actor)



        next if active?(actor)



      end



      result.push(actor)



    end



    return result



  end







  def self.type_candidates(type_name, ready_only = false)



    result = []



    for actor in party_summons



      next unless type?(actor, type_name)



      next unless in_battle?(actor)



      if ready_only



        next unless existing?(actor)



        next if active?(actor)



      end



      result.push(actor)



    end



    return result



  end







  def self.marked_enemies



    result = []



    return result if $game_troop == nil



    for enemy in $game_troop.members.compact



      next unless existing?(enemy)



      result.push(enemy) if enemy.state?(MARK_STATE_ID)



    end



    return result



  end







  #--------------------------------------------------------------------------



  # ● 鳴刻指令真正可手動選擇的敵人



  #--------------------------------------------------------------------------



  # 同時套用專案既有的「不可手動指定」規則：



  #   Friendly Enemy、対象不可、albert_targetable_unit? 等。



  #--------------------------------------------------------------------------



  def self.command_target_candidates



    result = []



    return result if $game_troop == nil







    for enemy in $game_troop.members.compact



      next unless command_target_valid?(enemy)







      if defined?(ALBERT_EXACT_TARGET_FIX) &&



         ALBERT_EXACT_TARGET_FIX.respond_to?(:manual_enemy_targetable?)



        next unless ALBERT_EXACT_TARGET_FIX.manual_enemy_targetable?(enemy)



      else



        if enemy.respond_to?(:friendly?)



          begin



            next if enemy.friendly?



          rescue



          end



        end



        if enemy.respond_to?(:albert_targetable_unit?)



          begin



            next unless enemy.albert_targetable_unit?



          rescue



          end



        end



        if enemy.respond_to?(:special_target?)



          begin



            next if enemy.special_target?



          rescue



          end



        end



      end







      result.push(enemy)



    end







    return result



  end







  def self.command_target_valid?(target)



    return false if target == nil



    return false unless existing?(target)



    return target.state?(MARK_STATE_ID)



  end







  def self.compact_names(actors)



    names = []



    for actor in actors.compact



      names.push(actor.name.to_s)



    end



    return "" if names.empty?



    return names[0] if names.size == 1



    return names[0] + "、" + names[1] if names.size == 2



    return names[0] + "、" + names[1] + "等" + names.size.to_s + "名"



  end







  #--------------------------------------------------------------------------



  # ● 鳴刻指令技能等級與實際數值



  #--------------------------------------------------------------------------



  def self.command_level(actor = nil)



    actor = joey if actor == nil



    return 0 if actor == nil



    return 0 if $data_skills == nil







    skill = $data_skills[COMMAND_SKILL_ID]



    return 0 if skill == nil



    return 0 unless actor.respond_to?(:skill_level)







    level = actor.skill_level(skill).to_i



    level = 0 if level < 0



    level = COMMAND_MAX_LEVEL if level > COMMAND_MAX_LEVEL



    return level



  rescue



    return 0



  end







  def self.command_value(table, actor = nil, level = nil)



    level = command_level(actor) if level == nil



    level = 0 if level.to_i < 0



    level = COMMAND_MAX_LEVEL if level.to_i > COMMAND_MAX_LEVEL



    return table[level.to_i].to_i



  end







  def self.command_od_need(actor = nil, level = nil)



    return command_value(COMMAND_OD_NEED_BY_LEVEL, actor, level)



  end







  def self.command_od_cost(actor = nil, level = nil)



    return command_value(COMMAND_OD_COST_BY_LEVEL, actor, level)



  end







  def self.command_damage_bonus(actor = nil, level = nil)



    return command_value(COMMAND_DAMAGE_BY_LEVEL, actor, level)



  end







  def self.command_atb_gain(actor = nil, level = nil)



    return command_value(COMMAND_ATB_BY_LEVEL, actor, level)



  end







  def self.command_description(actor = nil)



    level = command_level(actor)



    damage = command_damage_bonus(actor, level)



    need = command_od_need(actor, level)



    cost = command_od_cost(actor, level)



    atb = command_atb_gain(actor, level)







    text = "只能指定共鳴標記目標；先導型以技能190免費追擊，傷害+#{damage}%。"



    text += "需OD≥#{need}，追擊成功耗#{cost} OD。"



    text += "命中後喬伊ATB前進#{atb}%。" if atb > 0



    text += "標記保留；冷卻#{COMMAND_COOLDOWN}回合。"



    return text



  end







  def self.command_level_value_text(actor, level)



    return {



      :damage => command_damage_bonus(actor, level),



      :need   => command_od_need(actor, level),



      :cost   => command_od_cost(actor, level),



      :atb    => command_atb_gain(actor, level)



    }



  end







  #--------------------------------------------------------------------------



  # ● 鳴刻指令可用條件



  #--------------------------------------------------------------------------



  def self.command_reason(user, selected_targets = nil, start_od = nil)



    current_od = start_od == nil ? od(user) : start_od.to_i







    need = command_od_need(user)







    if current_od < need



      return "鳴刻指令需要#{need} OD，目前#{current_od}。"



    end







    if command_target_candidates.empty?



      return "場上沒有可指定的【共鳴標記】目標。"



    end







    all_starters = []



    for actor in party_summons



      all_starters.push(actor) if role?(actor, COMMAND_ROLE)



    end



    if all_starters.empty?



      return "隊伍中沒有【先導型】鳴刻者。"



    end







    field_starters = role_candidates(COMMAND_ROLE, false)



    if field_starters.empty?



      return "【先導型】鳴刻者尚未上場。"



    end







    alive = []



    for actor in field_starters



      alive.push(actor) if existing?(actor)



    end



    if alive.empty?



      return "場上的【先導型】鳴刻者已倒下。"



    end







    ready = role_candidates(COMMAND_ROLE, true)



    if ready.empty?



      return "【先導型】鳴刻者正在執行其他行動。"



    end







    if selected_targets != nil



      list = selected_targets.compact



      return "鳴刻指令沒有合法目標。" if list.empty?



      return "鳴刻指令只能指定【共鳴標記】目標。" unless command_target_valid?(list[0])



    end







    skill = $data_skills[COMMAND_FOLLOW_SKILL_ID] rescue nil



    return "追擊技能#{COMMAND_FOLLOW_SKILL_ID}不存在。" if skill == nil







    return nil



  end







  def self.command_usable?(user)



    return command_reason(user) == nil



  end







  #--------------------------------------------------------------------------



  # ● 玩家職能名稱



  #--------------------------------------------------------------------------



  def self.role_labels(actor)



    result = []



    for key in ["starter", "engine", "finisher"]



      result.push(ROLE_LABELS[key]) if role?(actor, key)



    end



    result.push("未分類") if summon?(actor) && result.empty?



    return result



  end







  def self.role_text(actor)



    return role_labels(actor).join("／")



  end







  #--------------------------------------------------------------------------



  # ● 追擊／連鎖動態 Help



  #--------------------------------------------------------------------------



  def self.single_followup_status(skill, user)



    text = note(skill)







    if text =~ /<summon_followup_role\s+([a-z0-9_]+)\s*:\s*(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?\s*>/i



      role_name = $1.to_s.downcase



      need = $3.to_i



      cost = $4 == nil ? 0 : $4.to_i



      label = ROLE_LABELS[role_name] || role_name



      return "OD#{od(user)}/#{need}" if od(user) < need



      ready = role_candidates(role_name, true)



      return "無可用#{label}" if ready.empty?



      return "可追：" + compact_names(ready) + "；耗#{cost}OD"



    end







    if text =~ /<summon_followup_type\s+([a-z_]+)\s*:\s*(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?\s*>/i



      type_name = $1.to_s.downcase



      need = $3.to_i



      cost = $4 == nil ? 0 : $4.to_i



      label = TYPE_LABELS[type_name] || type_name



      return "OD#{od(user)}/#{need}" if od(user) < need



      ready = type_candidates(type_name, true)



      return "無可用#{label}" if ready.empty?



      return "可追：" + compact_names(ready) + "；耗#{cost}OD"



    end







    return ""



  end







  def self.chain_status(skill, user)



    text = note(skill)



    stages = {}







    text.scan(/<summon_chain_type\s+([1-3])\s*:\s*([a-z_]+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?(?:\s*:\s*(\d+))?\s*>/i) do |data|



      stages[data[0].to_i] = [:type, data[1].to_s.downcase,



                              data[3].to_i, data[4].to_i]



    end







    text.scan(/<summon_chain_role\s+([1-3])\s*:\s*([a-z0-9_]+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?(?:\s*:\s*(\d+))?\s*>/i) do |data|



      stages[data[0].to_i] = [:role, data[1].to_s.downcase,



                              data[3].to_i, data[4].to_i]



    end







    return "" if stages.empty?







    result = []



    for stage in stages.keys.sort



      spec = stages[stage]



      kind = spec[0]



      name = spec[1]



      need = spec[2]



      short = stage.to_s







      if kind == :type



        short = {"pokemon"=>"寶", "robot"=>"機", "clone"=>"映"}[name] || stage.to_s



        ready = type_candidates(name, true)



      else



        short = {"starter"=>"先", "engine"=>"運", "finisher"=>"終"}[name] || stage.to_s



        ready = role_candidates(name, true)



      end







      if od(user) < need



        result.push(short + "OD缺")



      elsif ready.empty?



        result.push(short + "缺")



      else



        result.push(short + "可")



      end



    end







    return result.join(" ")



  end







  def self.dynamic_status(skill)



    return "" if skill == nil



    return "" if $game_temp == nil || !$game_temp.in_battle



    return "" unless FOLLOWUP_SKILL_IDS.include?(skill.id)







    user = joey



    return "" if user == nil







    if skill.id == COMMAND_SKILL_ID



      reason = command_reason(user)



      if reason == nil



        return "可追：" +



          compact_names(role_candidates(COMMAND_ROLE, true)) +



          "；門檻#{command_od_need(user)}／耗#{command_od_cost(user)}OD"



      end



      return reason



    end







    chain = chain_status(skill, user)



    return chain unless chain.empty?



    return single_followup_status(skill, user)



  end







  #--------------------------------------------------------------------------



  # ● <特殊使用条件> 自動摘要



  #--------------------------------------------------------------------------



  def self.special_condition_text(skill)



    return "" if skill == nil



    inside = false



    result = []







    note(skill).each_line do |raw|



      line = raw.to_s.gsub("\r", "").strip



      if line == "<特殊使用条件>"



        inside = true



        next



      elsif line == "</特殊使用条件>"



        inside = false



        next



      end



      next unless inside



      next if line.empty?







      data = line.split(/\s*,\s*/)



      key = data[0].to_s



      value = data[1].to_i







      case key



      when "最大HP";   result.push("最大HP≥#{value}")



      when "最大MP";   result.push("最大MP≥#{value}")



      when "HP";       result.push("HP≥#{value}")



      when "MP";       result.push("MP≥#{value}")



      when "HP％以上"; result.push("HP≥#{value}%")



      when "MP％以上"; result.push("MP≥#{value}%")



      when "HP％以下"; result.push("HP≤#{value}%")



      when "MP％以下"; result.push("MP≤#{value}%")



      when "攻撃力";   result.push("攻擊≥#{value}")



      when "守備力";   result.push("防禦≥#{value}")



      when "精神力";   result.push("精神≥#{value}")



      when "敏捷性";   result.push("敏捷≥#{value}")



      when "ステート"; result.push("需狀態#{value}")



      when "武器";     result.push("需武器#{value}")



      when "防具";     result.push("需防具#{value}")



      when "属性";     result.push("需普攻屬性#{value}")



      when "スイッチ"; result.push("需開關#{value}")



      when "狀態開關"; result.push("開關#{value}須OFF")



      when "封印狀態"; result.push("狀態#{value}時封印")



      end



    end







    return result.join("、")



  end







  def self.decorate_description(skill, base)



    text = base.to_s







    if skill != nil && skill.id == COMMAND_SKILL_ID



      text = command_description(joey)



    end







    condition = special_condition_text(skill)



    if !condition.empty? && text.index("條件：") == nil



      text += " 條件：" + condition



    end







    status = dynamic_status(skill)



    text += "｜" + status unless status.empty?







    return text



  end







  #--------------------------------------------------------------------------



  # ● 寫入技能與 State 40 說明



  #--------------------------------------------------------------------------



  def self.update_help_table(mod)



    return if mod == nil



    return unless mod.const_defined?(:SKILL_HELP)



    table = mod.const_get(:SKILL_HELP)



    return unless table.is_a?(Hash)



    for id in SKILL_HELP.keys



      table[id] = SKILL_HELP[id]



    end



  end







  def self.apply_data



    if $data_skills != nil



      for id in SKILL_HELP.keys



        skill = $data_skills[id]



        skill.description = SKILL_HELP[id] if skill != nil



      end







      # Skill 104 的合法性由共鳴標記決定。



      # 必須無視「最高目標優先級」的游標替換，否則 TargetPriority



      # 會在 update_target 每幀把未標記敵人重新塞回選擇清單。



      command = $data_skills[COMMAND_SKILL_ID]



      if command != nil



        command_note = command.note.to_s







        # 重新建立正式 Note。



        command_note.gsub!(/<cannot level>/i, "")



        command_note.gsub!(



          /<ricarica turni:\s*\d+>/i,



          "<ricarica turni:#{COMMAND_COOLDOWN}>"



        )



        command_note.gsub!(



          /<summon_followup_role\s+starter\s*:\s*190\s*:\s*\d+\s*:\s*\d+\s*>/i,



          "<summon_followup_role starter:190:350:80>"



        )







        # 清掉舊等級 Tag，避免重複。



        command_note.gsub!(/<max level\s+\d+>/i, "")



        command_note.gsub!(/<level dmg all:\s*[+\-]?\d+%>/i, "")



        command_note.gsub!(/<level \d+ jp cost:\s*\d+>/i, "")







        command_note += "\n<max level 3>"



        command_note += "\n<level dmg all:+0%>"



        command_note += "\n<level 1 jp cost:600>"



        command_note += "\n<level 2 jp cost:1800>"



        command_note += "\n<level 3 jp cost:4500>"







        unless command_note =~ /<\s*ignore\s+target\s+priority\s*>/i



          command_note += "\n<ignore target priority>"



        end







        command.note = command_note







        # YEM Skill Level 快取。



        [



          :@max_level, :@cannot_level, :@level_jp, :@level_dmg,



          :@level_hit, :@level_cost, :@level_state, :@level_chain,



          :@level_speed, :@level_cool, :@level_limit



        ].each do |ivar|



          command.instance_variable_set(ivar, nil)



        end



        command.yez_cache_baseitem_jpsl if



          command.respond_to?(:yez_cache_baseitem_jpsl)







        # H87 冷卻快取。



        command.instance_variable_set(:@cache_caricata3, nil)



        command.carica_cache_personale3 if



          command.respond_to?(:carica_cache_personale3)







        # KGC 與統一消耗快取不得殘留舊 Note。



        command.instance_variable_set(:@__is_overdrive, nil)



        command.instance_variable_set(:@__od_cost, nil)



        command.instance_variable_set(:@__od_gain_rate, nil)







        if defined?(FS_SKILL_COST_ALLFIX) &&



           FS_SKILL_COST_ALLFIX.respond_to?(:parse)



          FS_SKILL_COST_ALLFIX.parse(command, true)



        end



      end



    end







    update_help_table(FS_AUTOSET_PLAYER_TEXT_V12) if defined?(FS_AUTOSET_PLAYER_TEXT_V12)







    if defined?(FS_MASTER_SETUP)



      if FS_MASTER_SETUP.const_defined?(:PLAYER_TEXT)



        update_help_table(FS_MASTER_SETUP.const_get(:PLAYER_TEXT))



      end



    end







    if defined?(PLAYER_TEXT)



      update_help_table(PLAYER_TEXT)



    end







    if $data_states != nil && $data_states[MARK_STATE_ID] != nil



      state = $data_states[MARK_STATE_ID]



      detail = "喬伊技能對此目標增傷；召喚命中時回收40 OD；鳴刻指令可追擊且標記保留。"



      text = state.note.to_s



      if text =~ /<hud_detail_text:[^>]*>/i



        text.gsub!(/<hud_detail_text:[^>]*>/i,



                   "<hud_detail_text:#{detail}>")



      else



        text += "\n<hud_detail_text:#{detail}>"



      end



      state.note = text



    end



  end







  #--------------------------------------------------------------------------



  # ● 召喚物攻擊標記目標時回收 OD



  #--------------------------------------------------------------------------



  def self.reset_summon_action_flags(actor)



    return if actor == nil



    actor.instance_variable_set(:@fs_mc_mark_od_awarded, false)



    actor.instance_variable_set(:@fs_mc_command_hit, false)



  end







  def self.effect_success?(target)



    return false if target == nil



    missed = target.instance_variable_get(:@missed)



    evaded = target.instance_variable_get(:@evaded)



    skipped = target.instance_variable_get(:@skipped)



    return false if missed || evaded || skipped



    return true



  end







  #--------------------------------------------------------------------------



  # ● 鳴刻指令升級後的喬伊 ATB 回饋



  #--------------------------------------------------------------------------



  def self.shift_atb(actor, percent)



    return if actor == nil



    percent = percent.to_i



    return if percent <= 0







    delta = percent * 10







    if actor.respond_to?(:act_count) &&



       actor.act_count.to_i > 0 &&



       actor.respond_to?(:act_count=)



      actor.act_count = [[actor.act_count.to_i + delta, 0].max, 1000].min



    elsif actor.respond_to?(:at_count) &&



          actor.respond_to?(:at_count=)



      actor.at_count = [[actor.at_count.to_i + delta, 0].max, 1000].min



    elsif actor.respond_to?(:albert_combo_apply_atb_delta)



      actor.albert_combo_apply_atb_delta(delta)



    end



  end







  def self.award_mark_od(user)



    return if user == nil



    return if user.instance_variable_get(:@fs_mc_mark_od_awarded)







    actor = joey



    return if actor == nil







    if defined?(ALBERT_CHARACTER_CORE) &&



       ALBERT_CHARACTER_CORE.respond_to?(:gain_od)



      ALBERT_CHARACTER_CORE.gain_od(actor, MARK_HIT_OD_GAIN)



    elsif actor.respond_to?(:overdrive) && actor.respond_to?(:overdrive=)



      actor.overdrive = actor.overdrive.to_i + MARK_HIT_OD_GAIN



    end







    user.instance_variable_set(:@fs_mc_mark_od_awarded, true)



  end



end







#==============================================================================



# ** ALBERT_CHARACTER_CORE



#------------------------------------------------------------------------------



#  原追擊系統仍負責挑選召喚物、執行 Skill 190 與成功後扣 OD。



#  這裡只把 Skill 104 的門檻／成本改成目前技能等級的實際值。



#==============================================================================



if defined?(ALBERT_CHARACTER_CORE) &&



   ALBERT_CHARACTER_CORE.respond_to?(:summon_followup_specs)







  module ALBERT_CHARACTER_CORE



    class << self



      unless method_defined?(:fs_mc_v13_original_summon_followup_specs)



        alias fs_mc_v13_original_summon_followup_specs \



              summon_followup_specs



      end







      def summon_followup_specs(skill)



        result = fs_mc_v13_original_summon_followup_specs(skill)







        if skill != nil &&



           skill.id == FS_MARKED_COMMAND::COMMAND_SKILL_ID



          actor = FS_MARKED_COMMAND.joey



          need = FS_MARKED_COMMAND.command_od_need(actor)



          cost = FS_MARKED_COMMAND.command_od_cost(actor)







          for spec in result



            next if spec == nil



            spec[2] = need



            spec[3] = cost



          end



        end







        return result



      end



    end



  end



end







#==============================================================================



# ** RPG::Skill



#------------------------------------------------------------------------------



#  Help 讀取時加入動態候選者與 <特殊使用条件> 摘要。



#==============================================================================



class RPG::Skill



  unless method_defined?(:fs_mc_original_description)



    alias fs_mc_original_description description



  end







  def description



    base = fs_mc_original_description



    return FS_MARKED_COMMAND.decorate_description(self, base)



  end



end







#==============================================================================



# ** Scene_Title



#------------------------------------------------------------------------------



#  資料庫及 MasterSetup 完成後，套用最終說明。



#==============================================================================



class Scene_Title < Scene_Base



  if method_defined?(:load_database) &&



     !method_defined?(:fs_mc_original_load_database)



    alias fs_mc_original_load_database load_database







    def load_database



      fs_mc_original_load_database



      FS_MARKED_COMMAND.apply_data



    end



  end







  if method_defined?(:load_bt_database) &&



     !method_defined?(:fs_mc_original_load_bt_database)



    alias fs_mc_original_load_bt_database load_bt_database







    def load_bt_database



      fs_mc_original_load_bt_database



      FS_MARKED_COMMAND.apply_data



    end



  end



end







#==============================================================================



# ** FS_SKILL_COST_ALLFIX



#------------------------------------------------------------------------------



#  鳴刻指令不是 KGC 固定前置扣款，因此只補「顯示」，不加入 <overdrive>。



#==============================================================================



if defined?(FS_SKILL_COST_ALLFIX) &&



   FS_SKILL_COST_ALLFIX.respond_to?(:cost_entries)







  module FS_SKILL_COST_ALLFIX



    class << self



      unless method_defined?(:fs_mc_v13_original_cost_entries)



        alias fs_mc_v13_original_cost_entries cost_entries



      end







      def cost_entries(window, actor, skill)



        entries = fs_mc_v13_original_cost_entries(window, actor, skill)



        entries = [] if entries == nil







        if skill != nil &&



           skill.id == FS_MARKED_COMMAND::COMMAND_SKILL_ID







          # 防止日後誤加 <overdrive N> 後顯示兩次。



          entries.delete_if do |entry|



            entry != nil &&



            entry[0] == :text &&



            entry[1].to_s =~ /^\d+OD$/



          end







          value = FS_MARKED_COMMAND.command_od_cost(actor)



          entries.unshift([



            :text,



            value.to_i.to_s + "OD",



            color(window, :colore_angry, 1)



          ])



        end







        return entries



      end



    end



  end



end







#==============================================================================



# ** ALBERT_STATE_CHANCE_V27



#------------------------------------------------------------------------------



#  共鳴爪印是戰術座標。Skill 101 成功命中後，State 40 不受抗性影響。



#  這個入口位於真正 state_probability 擲骰之前，因此既有：



#    ・added_states／remained_states



#    ・joey_resonance_pull



#    ・狀態刷新



#  都仍走原本完整流程，不需要事後硬塞 State。



#==============================================================================



unless defined?(ALBERT_STATE_CHANCE_V27)



  raise "FS_MarkedCommand v1.2 需要 ALBERT_STATE_CHANCE_V27。"



end







module ALBERT_STATE_CHANCE_V27



  class << self



    unless method_defined?(:fs_mc_v12_original_final_probability)



      alias fs_mc_v12_original_final_probability final_probability



    end



  end







  def self.final_probability(target, user, obj, state_id, base_chance)



    if obj != nil &&



       obj.is_a?(RPG::Skill) &&



       obj.id == FS_MARKED_COMMAND::MARK_SKILL_ID &&



       state_id.to_i == FS_MARKED_COMMAND::MARK_STATE_ID



      return 100



    end







    return fs_mc_v12_original_final_probability(



      target, user, obj, state_id, base_chance



    )



  end



end







#==============================================================================



# ** Game_Battler



#------------------------------------------------------------------------------



#  1. 鳴刻指令在條件不足時直接灰化。



#  2. 鳴刻指令追擊對標記目標 +30%。



#  3. 召喚物傷害命中標記目標時替喬伊回收 OD。



#==============================================================================



class Game_Battler







  unless method_defined?(:fs_mc_original_skill_can_use)



    alias fs_mc_original_skill_can_use skill_can_use?



  end







  def skill_can_use?(skill)



    return false unless fs_mc_original_skill_can_use(skill)







    if skill != nil &&



       skill.id == FS_MARKED_COMMAND::COMMAND_SKILL_ID &&



       FS_MARKED_COMMAND.joey?(self) &&



       $game_temp != nil && $game_temp.in_battle



      return false unless FS_MARKED_COMMAND.command_usable?(self)



    end







    return true



  end







  if method_defined?(:make_obj_damage_value) &&



     !method_defined?(:fs_mc_original_make_obj_damage_value)







    alias fs_mc_original_make_obj_damage_value make_obj_damage_value







    def make_obj_damage_value(user, obj)



      fs_mc_original_make_obj_damage_value(user, obj)







      if user != nil &&



         user.instance_variable_get(:@fs_mc_command_bonus) &&



         state?(FS_MARKED_COMMAND::MARK_STATE_ID)







        hp_value = @hp_damage == nil ? 0 : @hp_damage.to_i



        mp_value = @mp_damage == nil ? 0 : @mp_damage.to_i



        rate = 100 + FS_MARKED_COMMAND.command_damage_bonus(FS_MARKED_COMMAND.joey)







        @hp_damage = hp_value * rate / 100 if hp_value > 0



        @mp_damage = mp_value * rate / 100 if mp_value > 0



      end



    end



  end







  if method_defined?(:execute_damage) &&



     !method_defined?(:fs_mc_original_execute_damage)







    alias fs_mc_original_execute_damage execute_damage







    def execute_damage(user)



      marked_before = state?(FS_MARKED_COMMAND::MARK_STATE_ID)



      opposite_side = false







      if user != nil && respond_to?(:actor?) && user.respond_to?(:actor?)



        opposite_side = actor? != user.actor?



      end







      fs_mc_original_execute_damage(user)







      return unless marked_before



      return unless opposite_side



      return unless FS_MARKED_COMMAND.summon?(user)



      return unless FS_MARKED_COMMAND.effect_success?(self)







      # 鳴刻指令的「命中」判定，不要求傷害大於 0。



      if user.instance_variable_get(:@fs_mc_command_bonus)



        user.instance_variable_set(:@fs_mc_command_hit, true)



      end







      # 一般共鳴回收需要實際造成正傷害，每次召喚物行動最多一次。



      hp_value = @hp_damage == nil ? 0 : @hp_damage.to_i



      mp_value = @mp_damage == nil ? 0 : @mp_damage.to_i



      if hp_value > 0 || mp_value > 0



        FS_MARKED_COMMAND.award_mark_od(user)



      end



    end



  end



end







#==============================================================================



# ** Game_BattleAction



#------------------------------------------------------------------------------



#  Skill 104 執行時再次驗證原目標。



#  目標死亡、離場或失去標記時回傳空陣列，不得 smooth_target 到別人。



#==============================================================================



class Game_BattleAction







  unless method_defined?(:fs_mc_v11_make_obj_targets)



    alias fs_mc_v11_make_obj_targets make_obj_targets



  end







  def make_obj_targets(obj)



    if obj != nil &&



       obj.is_a?(RPG::Skill) &&



       obj.id == FS_MARKED_COMMAND::COMMAND_SKILL_ID &&



       battler != nil && battler.respond_to?(:actor?) && battler.actor?







      target = nil







      if respond_to?(:albert_exact_selected_target)



        target = albert_exact_selected_target



      end







      if target == nil && opponents_unit != nil &&



         @target_index != nil && @target_index >= 0 &&



         @target_index < opponents_unit.members.size



        target = opponents_unit.members[@target_index]



      end







      return [] unless FS_MARKED_COMMAND.command_target_valid?(target)







      # 原目標仍然合法時，直接鎖定同一個 battler。



      # 不進入 smooth_target，避免失去標記後改打旁邊的敵人。



      return [target]



    end







    return fs_mc_v11_make_obj_targets(obj)



  end



end







#==============================================================================
# ** BattleStateHUD 職能資料 Provider（Phase 13）
#------------------------------------------------------------------------------
# role_text 仍由 FS_MARKED_COMMAND 提供；FS_BattleStateHUD_Authority 會在
# Runtime 晚綁定讀取，不再於此頁 alias AlbertBattleStateHUD.extra_info_rows。
#==============================================================================



# ** Scene_Battle



#------------------------------------------------------------------------------



#  ・阻止鳴刻指令確認未標記目標。



#  ・建立追擊增傷 Context。



#  ・命中後消耗標記。



#  ・失敗時顯示原因。



#==============================================================================



class Scene_Battle < Scene_Base







  #--------------------------------------------------------------------------



  # ● 戰鬥提示



  #--------------------------------------------------------------------------



  def fs_mc_notice_actor



    return @active_battler if defined?(@active_battler) &&



      @active_battler != nil



    return @commander if defined?(@commander) && @commander != nil



    return nil



  end







  def fs_mc_show_notice(text, frames = FS_MARKED_COMMAND::NOTICE_FRAMES)



    return if text == nil || text.empty?







    @fs_mc_notice_text = text.to_s



    @fs_mc_notice_frames = [frames.to_i, 1].max



    @fs_mc_notice_owner = fs_mc_notice_actor







    if @help_window != nil



      begin



        @help_window.set_text(@fs_mc_notice_text, 1)



      rescue



        @help_window.set_text(@fs_mc_notice_text)



      end



      @help_window.visible = true



    end



  end







  # 只清除仍由本補丁佔用的 Help，避免擦掉新技能／新角色的說明。



  def fs_mc_clear_notice



    old_text = @fs_mc_notice_text







    @fs_mc_notice_text = nil



    @fs_mc_notice_frames = nil



    @fs_mc_notice_owner = nil







    return if @help_window == nil



    return if old_text == nil







    current_text = ""



    begin



      current_text = @help_window.instance_variable_get(:@text).to_s



    rescue



      current_text = ""



    end







    return unless current_text == old_text.to_s







    begin



      @help_window.set_text("", 0)



    rescue



      begin



        @help_window.set_text("")



      rescue



      end



    end



    @help_window.visible = false



  end







  if method_defined?(:update) &&



     !method_defined?(:fs_mc_v12_original_update)







    alias fs_mc_v12_original_update update







    def update



      # 若上一幀已切換行動者，先清掉舊提示，再讓新介面正常更新。



      current_actor = fs_mc_notice_actor



      if @fs_mc_notice_text != nil &&



         @fs_mc_notice_owner != nil &&



         current_actor != nil &&



         !current_actor.equal?(@fs_mc_notice_owner)



        fs_mc_clear_notice



      end







      fs_mc_v12_original_update



      fs_mc_update_notice



    end



  end







  def fs_mc_update_notice



    return if @fs_mc_notice_frames == nil







    current_actor = fs_mc_notice_actor



    if @fs_mc_notice_owner != nil &&



       current_actor != nil &&



       !current_actor.equal?(@fs_mc_notice_owner)



      fs_mc_clear_notice



      return



    end







    if @fs_mc_notice_frames > 0



      @fs_mc_notice_frames -= 1







      if @help_window != nil && @fs_mc_notice_text != nil



        begin



          @help_window.set_text(@fs_mc_notice_text, 1)



        rescue



          @help_window.set_text(@fs_mc_notice_text)



        end



        @help_window.visible = true



      end



    else



      fs_mc_clear_notice



    end



  end







  # 下一個實際行動開始時，上一個行動的結果提示立即退場。



  if method_defined?(:execute_action) &&



     !method_defined?(:fs_mc_v12_original_execute_action)







    alias fs_mc_v12_original_execute_action execute_action







    def execute_action(*args)



      fs_mc_clear_notice if @fs_mc_notice_text != nil







      result = fs_mc_v12_original_execute_action(*args)







      # 鳴刻指令的 ATB 回饋必須在完整行動結束後套用，



      # 否則 Tankentai 後續的行動重置會把獎勵歸零。



      pending = @fs_mc_command_atb_pending



      @fs_mc_command_atb_pending = nil







      if pending != nil



        actor = pending[0]



        percent = pending[1].to_i



        FS_MARKED_COMMAND.shift_atb(actor, percent)



      end







      return result



    end



  end







  # ATB 指令階段可能先於 execute_action 出現，因此也在新角色取得指令時清除。



  if method_defined?(:start_actor_command_selection) &&



     !method_defined?(:fs_mc_v12_original_start_actor_command_selection)







    alias fs_mc_v12_original_start_actor_command_selection \



          start_actor_command_selection







    def start_actor_command_selection(*args)



      fs_mc_clear_notice if @fs_mc_notice_text != nil



      # v1.5：上一名角色使用過 Skill 104 時，Tankentai 可能仍保留

      # @skill。新角色的普通攻擊不得繼承這個選擇快取。

      @skill = nil

      @item = nil



      return fs_mc_v12_original_start_actor_command_selection(*args)



    end



  end







  #--------------------------------------------------------------------------



  # ● 取得目前 Tankentai 正在選擇的技能／物品



  #--------------------------------------------------------------------------



  def fs_mc_current_target_object



    user = nil

    user = @commander if defined?(@commander) && @commander != nil

    user = @active_battler if user == nil &&

      defined?(@active_battler) && @active_battler != nil



    # v1.5：Game_BattleAction 是目前指令的唯一權威來源。

    # 一旦 action 已經是普通攻擊／防禦，就必須回傳 nil，

    # 不得再落回上一招殘留的 @skill。

    if user != nil && user.respond_to?(:action) && user.action != nil

      begin

        return user.action.skill if user.action.skill?

        return user.action.item  if user.action.item?

        return nil unless user.action.nothing?

      rescue

      end

    end



    # 只有 action 尚未建立、且技能／物品選擇視窗仍存在時，

    # 才允許使用畫面快取。這是給舊 Tankentai 選單流程的後備。

    if defined?(@skill_window) && @skill_window != nil &&

       defined?(@skill) && @skill != nil

      return @skill

    end



    if defined?(@item_window) && @item_window != nil &&

       defined?(@item) && @item != nil

      return @item

    end



    return nil

  end







  #--------------------------------------------------------------------------



  # ● 目前是否正在選擇鳴刻指令的敵方目標



  #--------------------------------------------------------------------------



  def fs_mc_selecting_command?



    user = fs_mc_current_user

    return false if user == nil

    return false unless user.respond_to?(:action)



    action = user.action

    return false if action == nil



    # v1.5：只要目前 action 不是技能，就絕不可能是鳴刻指令。

    # 這一行直接切斷「上一招 @skill 殘留污染下一名角色」的路徑。

    return false unless action.skill?



    obj = action.skill

    return false if obj == nil

    return obj.id == FS_MARKED_COMMAND::COMMAND_SKILL_ID



  end







  #--------------------------------------------------------------------------



  # ● 取得目前指令使用者



  #--------------------------------------------------------------------------



  def fs_mc_current_user



    return @commander if defined?(@commander) && @commander != nil



    return @active_battler if defined?(@active_battler) &&



      @active_battler != nil



    return nil



  end







  #--------------------------------------------------------------------------



  # ● v1.5：依目前 Game_BattleAction 同步技能／物品快取



  #--------------------------------------------------------------------------



  def fs_mc_sync_selection_cache_from_action



    user = fs_mc_current_user

    return if user == nil || !user.respond_to?(:action)



    action = user.action

    return if action == nil



    begin

      if action.skill?

        @skill = action.skill

        @item = nil

      elsif action.item?

        @item = action.item

        @skill = nil

      elsif !action.nothing?

        # 普通攻擊、防禦、逃走等基本行動。

        @skill = nil

        @item = nil

      end

    rescue

    end

  end







  #--------------------------------------------------------------------------



  # ● 同步合法目標清單與 Tankentai 游標



  #--------------------------------------------------------------------------



  def fs_mc_sync_command_targets(cancel_if_empty = true, force_refresh = false)

    return true unless fs_mc_selecting_command?

    return true if @target_actors

    # 每幀保留這個便宜的合法性檢查，以支援 ATB 中目標死亡、離場、
    # 失去共鳴標記或重新取得標記；但不再每幀重畫 Help Window。
    targets = FS_MARKED_COMMAND.command_target_candidates

    if targets.empty?

      fs_mc_show_notice("場上沒有可指定的【共鳴標記】目標。")

      Sound.play_buzzer

      if cancel_if_empty && respond_to?(:end_target_selection)

        end_target_selection(true)

      end

      return false

    end

    # 參照 Albert_TargetPriority_SelectionFix：合法目標陣列沒有改變時，
    # 不重設 @target_members、不碰游標、不重畫 Help Window。
    # 只有 index 已失效時才允許往下修復。
    same_targets = (@target_members != nil && targets == @target_members)
    valid_index = (@index != nil && @index >= 0 && @index < targets.size)

    if !force_refresh && same_targets && valid_index

      return true

    end

    current = nil

    if @target_members != nil && @index != nil &&

       @index >= 0 && @index < @target_members.size

      current = @target_members[@index]

    end

    @target_members = targets

    new_index = current == nil ? nil : @target_members.index(current)

    @index = new_index == nil ? 0 : new_index

    @max_index = @target_members.size - 1

    target = @target_members[@index]

    @cursor.set(target) if @cursor != nil

    if defined?(@help_window2) && @help_window2 != nil

      @help_window2.set_text_n01add(target)

    end

    return true

  end







  #--------------------------------------------------------------------------



  # ● 開始選擇時，游標清單只保留合法標記目標



  #--------------------------------------------------------------------------



  unless method_defined?(:fs_mc_v11_start_target_selection)



    alias fs_mc_v11_start_target_selection start_target_selection



  end







  def start_target_selection(actor = false)



    # v1.5：先依目前 action 清除或同步 @skill／@item，

    # 再讓所有舊目標補丁讀取，避免普通攻擊被上一招 Skill 104 污染。

    fs_mc_sync_selection_cache_from_action



    fs_mc_v11_start_target_selection(actor)



    fs_mc_sync_command_targets(true, true)



  end







  #--------------------------------------------------------------------------



  # ● 每幀更新與確認時再次驗證



  #--------------------------------------------------------------------------



  # 本專案使用的是 Tankentai 的 update_target，不是 VX 預設的



  # update_target_enemy_selection。



  #--------------------------------------------------------------------------



  unless method_defined?(:fs_mc_v11_update_target)



    alias fs_mc_v11_update_target update_target



  end







  def update_target



    command_selection = fs_mc_selecting_command?







    if command_selection



      return unless fs_mc_sync_command_targets(true, false)



    end







    confirming = command_selection && Input.trigger?(Input::C)



    selected = nil



    action = nil



    real_index = nil







    if confirming



      if @target_members == nil || @target_members.empty? ||



         @index == nil || @index < 0 || @index >= @target_members.size



        Sound.play_buzzer



        fs_mc_show_notice("鳴刻指令沒有合法目標。")



        return



      end







      selected = @target_members[@index]







      unless FS_MARKED_COMMAND.command_target_valid?(selected)



        Sound.play_buzzer



        fs_mc_show_notice(



          "鳴刻指令只能指定【共鳴標記】目標。"



        )



        fs_mc_sync_command_targets(false, true)



        return



      end







      user = fs_mc_current_user



      begin



        action = user.action if user != nil



      rescue



        action = nil



      end







      if defined?(ALBERT_EXACT_TARGET_FIX) &&



         ALBERT_EXACT_TARGET_FIX.respond_to?(:real_index)



        real_index = ALBERT_EXACT_TARGET_FIX.real_index(selected)



      else



        begin



          real_index = $game_troop.members.index(selected)



        rescue



          real_index = nil



        end



      end



    end







    result = fs_mc_v11_update_target







    # 舊 Tankentai update_target 會把「篩選後 index」寫入 target_index。



    # 必須在整條舊鏈完成後，回寫原始 Troop index 與 battler 身分。



    if confirming && selected != nil && action != nil && real_index != nil



      action.target_index = real_index







      if action.respond_to?(:albert_exact_selected_target=)



        action.albert_exact_selected_target = selected



      end







      begin



        $game_temp.target_index = real_index if $game_temp != nil



      rescue



      end



    end







    return result



  end







  #--------------------------------------------------------------------------



  # ● 正常召喚物行動開始時重置「本次行動只回收一次 OD」



  #--------------------------------------------------------------------------



  if method_defined?(:execute_action_attack) &&



     !method_defined?(:fs_mc_original_execute_action_attack)







    alias fs_mc_original_execute_action_attack execute_action_attack







    def execute_action_attack(*args)



      FS_MARKED_COMMAND.reset_summon_action_flags(@active_battler)



      return fs_mc_original_execute_action_attack(*args)



    end



  end







  if method_defined?(:execute_action_skill) &&



     !method_defined?(:fs_mc_original_execute_action_skill)







    alias fs_mc_original_execute_action_skill execute_action_skill







    def execute_action_skill(*args)



      FS_MARKED_COMMAND.reset_summon_action_flags(@active_battler)



      return fs_mc_original_execute_action_skill(*args)



    end



  end







  #--------------------------------------------------------------------------



  # ● 追擊實際執行：在 Skill 104 Context 中套用 +30%



  #--------------------------------------------------------------------------



  if method_defined?(:albert_cc_execute_summon_followup) &&



     !method_defined?(:fs_mc_original_execute_summon_followup)







    alias fs_mc_original_execute_summon_followup \



          albert_cc_execute_summon_followup







    def albert_cc_execute_summon_followup(summon, follow_skill, targets)



      command_context = @fs_mc_command_context ? true : false







      if command_context



        FS_MARKED_COMMAND.reset_summon_action_flags(summon)



        summon.instance_variable_set(:@fs_mc_command_bonus, true)



      end







      result = nil







      begin



        result = fs_mc_original_execute_summon_followup(



          summon, follow_skill, targets



        )







        if command_context && result



          @fs_mc_command_executed = true



          if summon.instance_variable_get(:@fs_mc_command_hit)



            @fs_mc_command_hit = true



          end



        end







        return result



      ensure



        if command_context && summon != nil



          summon.instance_variable_set(:@fs_mc_command_bonus, false)



          summon.instance_variable_set(:@fs_mc_command_hit, false)



        end



      end



    end



  end







  #--------------------------------------------------------------------------



  # ● Skill 104：標記、追擊、消耗標記與失敗回饋



  #--------------------------------------------------------------------------



  if method_defined?(:albert_cc_try_summon_followups) &&



     !method_defined?(:fs_mc_original_try_summon_followups)







    alias fs_mc_original_try_summon_followups \



          albert_cc_try_summon_followups







    def albert_cc_try_summon_followups(joey, trigger_skill,



                                       pre_od, original_targets)



      unless trigger_skill != nil &&



             trigger_skill.id == FS_MARKED_COMMAND::COMMAND_SKILL_ID



        return fs_mc_original_try_summon_followups(



          joey, trigger_skill, pre_od, original_targets



        )



      end







      reason = FS_MARKED_COMMAND.command_reason(



        joey, original_targets, pre_od



      )



      unless reason == nil



        fs_mc_show_notice(reason)



        return



      end







      @fs_mc_command_context = true



      @fs_mc_command_executed = false



      @fs_mc_command_hit = false







      begin



        result = fs_mc_original_try_summon_followups(



          joey, trigger_skill, pre_od, original_targets



        )







        targets = original_targets == nil ? [] : original_targets.compact







        if @fs_mc_command_hit



          atb_gain = FS_MARKED_COMMAND.command_atb_gain(joey)



          @fs_mc_command_atb_pending = [joey, atb_gain] if atb_gain > 0







          if atb_gain > 0



            fs_mc_show_notice(



              "先導追擊命中：標記保留，喬伊ATB前進#{atb_gain}%。"



            )



          else



            fs_mc_show_notice(



              "先導追擊命中：共鳴標記保留。"



            )



          end



        elsif @fs_mc_command_executed



          fs_mc_show_notice(



            "先導追擊未命中：共鳴標記保留。"



          )



        else



          reason = FS_MARKED_COMMAND.command_reason(



            joey, original_targets, pre_od



          )



          reason = "鳴刻指令中止：追擊執行失敗。" if reason == nil



          fs_mc_show_notice(reason)



        end







        return result



      ensure



        @fs_mc_command_context = false



        @fs_mc_command_executed = false



        @fs_mc_command_hit = false



      end



    end



  end







end







#==============================================================================



# ** Window_LevelData



#------------------------------------------------------------------------------



#  Skill 104 是自訂指揮技能。升級頁直接展示真正會改變的數值。



#==============================================================================



if defined?(Window_LevelData)







  class Window_LevelData < Window_Base



    unless method_defined?(:fs_mc_v13_original_refresh)



      alias fs_mc_v13_original_refresh refresh



    end







    def refresh(skill, class_id)



      unless skill != nil &&



             skill.id == FS_MARKED_COMMAND::COMMAND_SKILL_ID



        return fs_mc_v13_original_refresh(skill, class_id)



      end







      self.contents.clear



      self.contents.font.color = normal_color



      self.contents.font.size = Font.default_size







      @skill = skill



      @class_id = class_id







      draw_skill_name







      self.contents.font.size = YEZ::JOB::REQUIRE_SIZE



      dy = WLH



      dy = draw_level(dy)







      current = FS_MARKED_COMMAND.command_level(@actor)



      target = @mode ? current + 1 : current - 1



      target = 0 if target < 0



      target = FS_MARKED_COMMAND::COMMAND_MAX_LEVEL if



        target > FS_MARKED_COMMAND::COMMAND_MAX_LEVEL







      # 滿等升級模式仍展示目前最終效果，不呼叫會取到 nil 的下一級 JP。



      unless @mode &&



             current >= FS_MARKED_COMMAND::COMMAND_MAX_LEVEL



        dy = draw_jp_cost(dy)



      end







      from = FS_MARKED_COMMAND.command_level_value_text(@actor, current)



      to = FS_MARKED_COMMAND.command_level_value_text(@actor, target)







      same_level = current == target







      dy = fs_mc_v13_draw_command_row(



        dy, "追擊增傷",



        fs_mc_v13_level_pair(from[:damage], to[:damage], "%", same_level)



      )



      dy = fs_mc_v13_draw_command_row(



        dy, "啟動OD門檻",



        fs_mc_v13_level_pair(from[:need], to[:need], "", same_level)



      )



      dy = fs_mc_v13_draw_command_row(



        dy, "成功OD消耗",



        fs_mc_v13_level_pair(from[:cost], to[:cost], "", same_level)



      )



      dy = fs_mc_v13_draw_command_row(



        dy, "喬伊ATB前進",



        fs_mc_v13_level_pair(from[:atb], to[:atb], "%", same_level)



      )



      dy = fs_mc_v13_draw_command_row(dy, "共鳴標記", "追擊後保留")



      dy = fs_mc_v13_draw_command_row(



        dy, "冷卻", FS_MARKED_COMMAND::COMMAND_COOLDOWN.to_s + "回合"



      )



      dy = fs_mc_v13_draw_command_row(dy, "追擊者", "先導型／Skill 190")



    end







    def fs_mc_v13_level_pair(value1, value2, suffix = "", same = false)



      left = value1.to_i.to_s + suffix



      return left if same



      right = value2.to_i.to_s + suffix



      return left + " → " + right



    end







    def fs_mc_v13_draw_command_row(dy, label, value)



      self.contents.font.color = system_color



      self.contents.draw_text(0, dy, self.width - 32, WLH, label)



      self.contents.font.color = normal_color



      self.contents.draw_text(



        0, dy, self.width - 36, WLH, value.to_s, 2



      )



      return dy + WLH



    end



  end



end







# 測試模式或熱載入時，資料庫可能已經存在。



FS_MARKED_COMMAND.apply_data if



  defined?($data_skills) && $data_skills != nil
