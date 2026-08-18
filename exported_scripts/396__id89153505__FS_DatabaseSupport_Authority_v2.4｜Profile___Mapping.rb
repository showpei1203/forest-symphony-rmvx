#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_DatabaseSupport_Authority v2.4 CompactID
# 【用途】Compact ID／Profile／ArmorMapping Authority；負責 Actor Profile、成長 Enemy 映射與舊存檔 ArmorMapping 遷移。
# 【主要機制】統一 Actor 7～16 的 Compact ID：Robot Skill 185～189、核心 Armor 286～295、成長來源 Enemy 590～599；提供 Lv60 上限、成長公式、EquipmentCombo 安全門與 ArmorMapping 正規化資料。Phase 29 起新遊戲／讀檔時機統一交由 FS_SaveCompatibilityCore v1.1 呼叫 rebuild_armor_mapping。
# 【主要影響】Game_Actor、Game_Enemy、Scene_Battle、Scene_Title、ForestSymphonyDB、ALBERT_HPMP_SCALE_GROWTH
# 【設定／可調參數】主要設定：LEVEL_CAP、ARMOR_TO_ACTOR、LEGACY_ARMOR_TO_ACTOR、ACTOR_TO_GROWTH_ENEMY、PROFILES、CHECK_RANGES。正式 Robot Skill ID 為 185～189；正式召喚核心 Armor 為 286～295。
# 【依賴／載入順序】位於 AutoSetup 初期 Adapter 後、後續 Runtime Provider 前；不屬於 MasterSetup Data 表，但其 ID 必須與 MasterSetup Equipment/Enemy Authority 一致。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】PROFILE / MAPPING AUTHORITY
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# ■ FS_DatabaseSupport_Authority v2.4 CompactID
# RGSS2 / RPG Maker VX
#------------------------------------------------------------------------------
# 安裝：ActorProfile、MechanicExpansion、EquipmentCombo、ActorEnemyGrowth、
#       HPMP Scale、EnemyLevelControl 之下，Main 之上。
#
# 核心 ID：
#   Skill 100-159 主角 / 160-184 映體 / 185-189 Robot / 190-192 追擊
#   Enemy 590-599 成長來源
#   Armor 286-295 映體與 Robot 核心
#
# 事件腳本：
#   ForestSymphonyDB.preflight_report
#   ForestSymphonyDB.rebuild_armor_mapping
#==============================================================================
module ForestSymphonyDB
  VERSION = "2.3"
  LEVEL_CAP = 60
  ARMOR_TO_ACTOR = {
    286=>7, 287=>8, 288=>9, 289=>10, 290=>11,
    291=>12, 292=>13, 293=>14, 294=>15, 295=>16
  }

  # v2.0 曾使用的舊召喚核心 ID。
  # 只用於舊存檔遷移；正式 Runtime 不再建立這批 mapping。
  LEGACY_ARMOR_TO_ACTOR = {
    732=>7, 733=>8, 734=>9, 735=>10, 736=>11,
    737=>12, 738=>13, 739=>14, 740=>15, 741=>16
  }

  ACTOR_TO_GROWTH_ENEMY = {
    7=>590,8=>591,9=>592,10=>593,11=>594,
    12=>595,13=>596,14=>597,15=>598,16=>599
  }
  PROFILES = {
    1=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_summon_action:60>"]},
    2=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_heal_percent:4>","<cc_od_overheal_percent:3>"]},
    3=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_atb_per_10:30>"]},
    4=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_state_stack:50>"]},
    5=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>[]},
    6=>{:summon=>false,:groups=>["main"],:roles=>[],:tags=>["<cc_od_break_point:35>","<cc_od_break:150>"]},
    7=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_aizhuo","atb_disruptor"],:tags=>[],:clone_stability_max=>100,:clone_action_cost=>0},
    8=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_ivy","emergency_guard"],:tags=>[],:clone_stability_max=>100,:clone_action_cost=>0},
    9=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_mia","healer"],:tags=>["<cmb:30>"],:clone_stability_max=>100,:clone_action_cost=>0},
    10=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_vina","state_starter"],:tags=>["<cvb:15>"],:clone_stability_max=>100,:clone_action_cost=>0},
    11=>{:summon=>true,:type=>:clone,:groups=>["summon","clone"],:roles=>["clone_tyler","armor_breaker"],:tags=>["<ctb:90,15>"],:clone_stability_max=>100,:clone_action_cost=>0},
    12=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["protector"],:tags=>[],:robot_protocol=>{:skill=>185,:interval=>3,:if_state=>[]}},
    13=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["atb_controller"],:tags=>[],:robot_protocol=>{:skill=>186,:interval=>2,:if_state=>[]}},
    14=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["corrosion_engine"],:tags=>[],:robot_protocol=>{:skill=>187,:interval=>3,:if_state=>[]}},
    15=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["breaker"],:tags=>[],:robot_protocol=>{:skill=>188,:interval=>4,:if_state=>[]}},
    16=>{:summon=>true,:type=>:robot,:groups=>["summon","robot"],:roles=>["healer","mana_engine"],:tags=>[],:robot_protocol=>{:skill=>189,:interval=>3,:if_state=>[]}}
  }
  CHECK_RANGES = {
    :skill=>[100,192], :item=>[200,265], :weapon=>[100,129],
    :armor=>[220,333], :enemy=>[590,599]
  }
  def self.nonblank?(obj)
    return false if obj == nil
    return true if obj.respond_to?(:name) && obj.name.to_s != ""
    return true if obj.respond_to?(:note) && obj.note.to_s != ""
    return false
  end
  def self.preflight_report
    report=[]
    sources={:skill=>$data_skills,:item=>$data_items,:weapon=>$data_weapons,
             :armor=>$data_armors,:enemy=>$data_enemies}
    CHECK_RANGES.each do |kind,range|
      data=sources[kind]
      for id in range[0]..range[1]
        obj=data[id] rescue nil
        report << sprintf("%s %d 已有資料：%s",kind,id,obj.name) if nonblank?(obj)
      end
    end
    return ["Compact ID 預檢：未發現既有資料衝突。"] if report.empty?
    return report
  end
  def self.rebuild_armor_mapping
    return false unless defined?(ArmorMapping)
    if ArmorMapping.respond_to?(:mapping)
      mapping = ArmorMapping.mapping

      # 最早期臨時 mapping。僅在值仍完全吻合舊資料時移除，避免誤刪其他系統自訂值。
      {101=>8,103=>7,105=>9}.each do |armor_id,actor_id|
        mapping.delete(armor_id) if mapping[armor_id] == actor_id
      end

      # Phase 12：移除 v2.0 的 732～741 舊召喚核心 mapping。
      # 舊存檔會把 $game_system.armor_mapping 一起保存，因此不能只刪舊腳本。
      LEGACY_ARMOR_TO_ACTOR.each do |armor_id,actor_id|
        mapping.delete(armor_id) if mapping[armor_id] == actor_id
      end
    end

    ARMOR_TO_ACTOR.each {|armor_id,actor_id| ArmorMapping.add_mapping(armor_id,actor_id)}
    return true
  end
  def self.apply_profiles
    return false unless defined?(ALBERT_ACTOR_PROFILE)
    return false unless ALBERT_ACTOR_PROFILE.const_defined?(:ACTORS)
    PROFILES.each {|actor_id,data| ALBERT_ACTOR_PROFILE::ACTORS[actor_id]=data}
    return true
  end
end
ForestSymphonyDB.apply_profiles
if defined?(ALBERT_ACTOR_ENEMY_GROWTH) && ALBERT_ACTOR_ENEMY_GROWTH.const_defined?(:ACTOR_TO_ENEMY)
  ForestSymphonyDB::ACTOR_TO_GROWTH_ENEMY.each {|a,e| ALBERT_ACTOR_ENEMY_GROWTH::ACTOR_TO_ENEMY[a]=e}
end
if defined?(ALBERT_IVY_CLONE) && ALBERT_IVY_CLONE.const_defined?(:CLONE_ACTOR_ROLES)
  ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES.clear
  {7=>:aizhuo,8=>:ivy,9=>:mia,10=>:vina,11=>:tyler}.each {|a,r| ALBERT_IVY_CLONE::CLONE_ACTOR_ROLES[a]=r}
end
if defined?(YE::BATTLE::ENEMY) && YE::BATTLE::ENEMY.const_defined?(:MAX_LEVEL)
  YE::BATTLE::ENEMY.send(:remove_const,:MAX_LEVEL)
  YE::BATTLE::ENEMY.const_set(:MAX_LEVEL,ForestSymphonyDB::LEVEL_CAP)
end
class Game_Actor < Game_Battler
  def albert_growth_level
    lv=@level==nil ? 1 : @level.to_i
    [[lv,1].max,ForestSymphonyDB::LEVEL_CAP].min
  end
  unless method_defined?(:fsdb_change_level_v21)
    alias fsdb_change_level_v21 change_level
    def change_level(level,show)
      fsdb_change_level_v21([[level.to_i,ForestSymphonyDB::LEVEL_CAP].min,1].max,show)
    end
  end
  unless method_defined?(:fsdb_level_up_v21)
    alias fsdb_level_up_v21 level_up
    def level_up
      return if @level.to_i >= ForestSymphonyDB::LEVEL_CAP
      fsdb_level_up_v21
    end
  end
  unless method_defined?(:fsdb_change_exp_v21)
    alias fsdb_change_exp_v21 change_exp
    def change_exp(exp,show)
      cap_index=ForestSymphonyDB::LEVEL_CAP+1
      if @exp_list && @exp_list[cap_index] && @exp_list[cap_index]>0
        exp=[exp.to_i,@exp_list[cap_index]-1].min
      end
      fsdb_change_exp_v21(exp,show)
    end
  end
  # Phase 12：Robot fixed pattern 已回寫 FS_AutoBattleAI_Authority v2.2。
  # 本頁不再 alias Game_Actor#make_action。
end
class Game_Enemy < Game_Battler
  if method_defined?(:level) && !method_defined?(:fsdb_enemy_level_v21)
    alias fsdb_enemy_level_v21 level
    def level
      [[fsdb_enemy_level_v21.to_i,1].max,ForestSymphonyDB::LEVEL_CAP].min
    end
  end
  def albert_growth_level
    lv=respond_to?(:level) ? level.to_i : 1
    [[lv,1].max,ForestSymphonyDB::LEVEL_CAP].min
  end
end

if defined?(ALBERT_HPMP_SCALE_GROWTH)
  module ALBERT_HPMP_SCALE_GROWTH
    def self.hpmp_raw(base_value,level)
      lv=[[level.to_i,1].max,ForestSymphonyDB::LEVEL_CAP].min
      ((2*base_value.to_i+31)*lv/100.0)+lv+10
    end
  end
end

# Phase 31：舊 DatabaseSupport「必須已學會開場技能」Override 已退休。
# 後載入 OpeningSkill FinalAuthority v1.3 原本就明確規定：開場技不要求召喚物
# 已自然學會；因此舊 Gate 在實際 Phase 30 Runtime 也已被 Final 覆寫。
# DatabaseSupport 回歸 Profile / Growth / Mapping 單一責任。

# Phase 29：ArmorMapping lifecycle hook 已移至 FS_SaveCompatibilityCore v1.1。
# 本頁只擁有 Mapping Data / normalization policy。
#==============================================================================
# ■ END
#==============================================================================
