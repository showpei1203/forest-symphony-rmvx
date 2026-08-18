#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleMechanic_AuditFix v2.5
# 【用途】Forest Symphony 相容／修正頁「FS_BattleMechanic_AuditFix v2.5」，針對既有系統補正專案需要的行為。
# 【主要機制】通常透過 alias／class reopen 包裝前方實作；它不是可任意搬動的獨立功能，需維持在被修正腳本之後。
# 【主要影響】Game_Battler、FS_BATTLE_V22、ALBERT_CHARACTER_CORE、ALBERT_TARGET_GROUP、FS_BATTLE_MECHANIC_AUDIT_V22
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PASSIVE_NAMES、PASSIVE_DEFAULTS、ROLE_FAMILIES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 7 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
#==============================================================================



# ■ FS_BattleMechanic_AuditFix_v2_5_OD_Economy



#------------------------------------------------------------------------------



# RPG Maker VX / RGSS2 / Ruby 1.8



#



# 目的：



#   修正「資料庫寫了被動效果，但戰鬥核心根本沒有讀到」的斷鏈。



#



# 安裝位置：



#   BattleFormula_TargetFix / ComboCore / CharacterMechanicCore



#   MechanicExpansion / TargetGroup / SummonChain3



#   FS_DatabaseSupport_v2_1_CompactID



#   FS_BattleMechanic_AuditFix_v2_5_OD_Economy  ← 本腳本



#   Main



#



# 請移除 FS_MechanicCompatibility_v2_1。本版完整取代它。



#==============================================================================



module FS_BATTLE_V22



  VERSION = "2.5"







  # Compact ID 與舊 v2.0 ID 都辨識。名稱也必須相符，避免誤把同 ID 舊技能當被動。



  PASSIVE_NAMES = {



    102=>"共鳴感知", 106=>"和聲領袖",



    112=>"溢光回路", 116=>"大地祝福",



    122=>"靜電回收", 126=>"超頻神經",



    132=>"毒理學",   136=>"病灶連鎖",



    142=>"怒意不熄", 146=>"替身承擔",



    152=>"鬥志打磨", 156=>"破城者",



    774=>"共鳴感知", 778=>"和聲領袖",



    784=>"溢光回路", 788=>"大地祝福",



    794=>"靜電回收", 798=>"超頻神經",



    804=>"毒理學",   808=>"病灶連鎖",



    814=>"怒意不熄", 818=>"替身承擔",



    824=>"鬥志打磨", 828=>"破城者"



  }







  # 三個原設計文字有功能描述、但原 Note 沒有完整落實者，補上缺漏。



  # 資料庫手動補寫相同標籤也可以；本腳本只在缺少時追加，不會重複。



  PASSIVE_DEFAULTS = {



    "共鳴感知"=>[



      [/<cc_od_summon_action\s*:/i, "<cc_od_summon_action:55>"]



    ],



    "和聲領袖"=>[



      [/<bonus_if_od\s+/i, "<bonus_if_od 70:20>"]



    ],



    "毒理學"=>[



      [/<state_chance_bonus\s+31\s*:/i, "<state_chance_bonus 31:10>"],



      [/<state_chance_bonus\s+35\s*:/i, "<state_chance_bonus 35:10>"],



      [/<state_chance_bonus\s+37\s*:/i, "<state_chance_bonus 37:10>"]



    ]



  }







  ROLE_FAMILIES = {



    "starter"=>["starter", "state_starter", "wet_paralysis"],



    "engine"=>["engine", "controller", "spreader", "support", "healer",



                "protector", "tank", "wet_paralysis"],



    "finisher"=>["finisher", "dps", "hunter", "breaker", "rage_dps"]



  }







  def self.note(obj)



    return "" if obj == nil



    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil



    return ""



  end







  def self.passive_name_match?(skill)



    return false if skill == nil



    expected = PASSIVE_NAMES[skill.id]



    return false if expected == nil



    return skill.name.to_s == expected



  end







  def self.mechanic_passive_skill?(skill)



    return false if skill == nil



    text = note(skill)



    return true if text =~ /<mechanic_passive>/i



    return true if skill.respond_to?(:passive) && skill.passive



    return true if passive_name_match?(skill)



    return false



  end







  def self.note_with_defaults(skill)



    text = note(skill)



    defaults = PASSIVE_DEFAULTS[skill.name.to_s]



    if defaults != nil



      for pair in defaults



        text += "\n" + pair[1] unless text =~ pair[0]



      end



    end



    return text



  end







  def self.passive_skill_note_text(user)



    text = ""



    return text if user == nil || !user.respond_to?(:skills)



    for skill in user.skills.compact



      next unless mechanic_passive_skill?(skill)



      text += "\n" + note_with_defaults(skill)



    end



    return text



  end







  def self.scan_values(text, key)



    result = []



    pattern = Regexp.escape(key.to_s)



    text.to_s.scan(/<\s*#{pattern}\s*:\s*(-?\d+(?:\.\d+)?)\s*>/i) do |data|



      result << data[0].to_f



    end



    return result



  end







  def self.sum_values(text, key)



    total = 0.0



    for value in scan_values(text, key)



      total += value



    end



    return total



  end







  def self.element_values(text, key, element_id)



    result = []



    pattern = Regexp.escape(key.to_s)



    text.to_s.scan(/<\s*#{pattern}\s+#{element_id}\s*:\s*(-?\d+(?:\.\d+)?)\s*>/i) do |data|



      result << data[0].to_f



    end



    text.to_s.scan(/<\s*#{pattern}\[#{element_id}\]\s*:\s*(-?\d+(?:\.\d+)?)\s*>/i) do |data|



      result << data[0].to_f



    end



    return result



  end







  def self.stack_count(target, state_id)



    return 0 if target == nil



    if defined?(ALBERT_CHARACTER_CORE) &&



       ALBERT_CHARACTER_CORE.respond_to?(:stack_count)



      return ALBERT_CHARACTER_CORE.stack_count(target, state_id).to_i



    end



    if target.respond_to?(:stack)



      begin



        return target.stack(state_id).to_i



      rescue



      end



    end



    return target.state?(state_id) ? 1 : 0



  end







  def self.note_state_ids(skill)



    result = []



    return result if skill == nil



    if skill.respond_to?(:plus_state_set)



      result += skill.plus_state_set



    end



    text = note(skill)



    patterns = [



      /<state_chance\s+(\d+)\s*:/i,



      /<state_chance_vs_state\s+(\d+)\s*,/i,



      /<state_chance_if_user_state\s+(\d+)\s*,/i,



      /<spread_state\s+(\d+)\s*:/i,



      /<drift_state\s+(\d+)\s*:/i,



      /<convert_state\s+\d+\s*:\s*(\d+)>/i



    ]



    for regex in patterns



      text.scan(regex) { |data| result << data[0].to_i }



    end



    return result.compact.uniq



  end







  def self.copy_counts_for_vina?(obj, state_id)



    text = note(obj)



    return true if text =~ /<spread_state\s+#{state_id}\s*:/i



    return true if text =~ /<drift_state\s+#{state_id}\s*:/i



    return false



  end







  def self.role_family_match?(actual_roles, requested)



    requested = requested.to_s.downcase



    return true if actual_roles.include?(requested)



    family = ROLE_FAMILIES[requested]



    return false if family == nil



    for actual in actual_roles



      value = actual.to_s.downcase



      for token in family



        return true if value == token



        return true if value.index("_#{token}") != nil



        return true if value.index(token + "_") != nil



      end



    end



    return false



  end



end







#------------------------------------------------------------------------------



# CharacterMechanicCore：已習得的自訂被動 Note 進入核心來源。



# cc_od_* 採所有來源最高值，避免 ActorProfile 的基準值擋住後學被動。



#------------------------------------------------------------------------------



if defined?(ALBERT_CHARACTER_CORE)



  module ALBERT_CHARACTER_CORE



    class << self



      unless method_defined?(:fs_v22_source_text_without_mechanic_passives)



        alias fs_v22_source_text_without_mechanic_passives source_text



      end



      def source_text(user, obj = nil)



        text = fs_v22_source_text_without_mechanic_passives(user, obj)



        text += FS_BATTLE_V22.passive_skill_note_text(user)



        return text



      end







      unless method_defined?(:fs_v22_note_number_without_max_cc_od)



        alias fs_v22_note_number_without_max_cc_od note_number



      end



      def note_number(text, tag, default_value)



        if tag.to_s =~ /^cc_od_/i



          values = FS_BATTLE_V22.scan_values(text, tag)



          return values.max unless values.empty?



        end



        return fs_v22_note_number_without_max_cc_od(text, tag, default_value)



      end



    end



  end



end







class Game_Battler



  # BattleFormula / ComboCore 使用的持續來源也加入被動 Note。



  if method_defined?(:albert_notes_for_user) &&



     !method_defined?(:fs_v22_notes_for_user_without_passives)



    alias fs_v22_notes_for_user_without_passives albert_notes_for_user



    def albert_notes_for_user



      return fs_v22_notes_for_user_without_passives +



             FS_BATTLE_V22.passive_skill_note_text(self)



    end



  end







  if method_defined?(:albert_notes_for_target) &&



     !method_defined?(:fs_v22_notes_for_target_without_passives)



    alias fs_v22_notes_for_target_without_passives albert_notes_for_target



    def albert_notes_for_target



      return fs_v22_notes_for_target_without_passives +



             FS_BATTLE_V22.passive_skill_note_text(self)



    end



  end







  # 穿透、暴擊、額外元素抗弱改為累加所有裝備／State／被動，不再只吃第一筆。



  if method_defined?(:albert_pen_rate)



    def albert_pen_rate(obj = nil)



      text = FS_BATTLE_V22.note(obj) + albert_notes_for_user.to_s



      value = FS_BATTLE_V22.sum_values(text, "pen_rate").to_i



      max_value = 100



      if defined?(ALBERT_BATTLE_FIX) && ALBERT_BATTLE_FIX.const_defined?(:MAX_PEN_RATE)



        max_value = ALBERT_BATTLE_FIX::MAX_PEN_RATE



      end



      return [[value, 0].max, max_value].min



    end



  end







  if method_defined?(:albert_crit_bonus)



    def albert_crit_bonus(obj = nil)



      text = FS_BATTLE_V22.note(obj) + albert_notes_for_user.to_s



      return FS_BATTLE_V22.sum_values(text, "crit_rate").to_i



    end



  end







  if method_defined?(:albert_element_extra_rate)



    def albert_element_extra_rate(element_id)



      text = albert_notes_for_target.to_s



      weak = 0.0



      resist = 0.0



      for value in FS_BATTLE_V22.element_values(text, "ele_weak", element_id)



        weak += value



      end



      for value in FS_BATTLE_V22.element_values(text, "ele_res", element_id)



        resist += value



      end



      return (weak - resist).to_i



    end



  end







  # 蓄痛上限採最高值。角色基準 300% 不再遮住「替身承擔」400%。



  if method_defined?(:albert_mx_cover_store_cap_percent)



    def albert_mx_cover_store_cap_percent



      text = ALBERT_MECHANIC_EXPANSION.source_text(self, nil)



      values = FS_BATTLE_V22.scan_values(text, "cover_store_cap_percent")



      unless values.empty?



        return values.max



      end



      return ALBERT_MECHANIC_EXPANSION::IVY_DEFAULT_STORE_CAP_PERCENT



    end



  end







  # generic role：starter／engine／finisher 可對應細分類 role。



  if method_defined?(:albert_mx_summon_role?)



    def albert_mx_summon_role?(role_name)



      return FS_BATTLE_V22.role_family_match?(albert_mx_summon_roles,



                                               role_name)



    end



  end







  # 維娜：Note 型 state_chance / convert 也納入原目標疊層偵測。



  if method_defined?(:albert_cc_capture_state_stacks)



    def albert_cc_capture_state_stacks(skill)



      result = {}



      for state_id in FS_BATTLE_V22.note_state_ids(skill)



        result[state_id] = FS_BATTLE_V22.stack_count(self, state_id)



      end



      return result



    end



  end







  if method_defined?(:albert_cc_process_vina_state_od)



    def albert_cc_process_vina_state_od(user, skill, before_stacks)



      return unless ALBERT_CHARACTER_CORE::ENABLE_VINA_STATE_OD



      return if user == nil || skill == nil



      return unless user.albert_cc_vina?



      return if @missed || @evaded || @skipped



      gained = 0



      for state_id in FS_BATTLE_V22.note_state_ids(skill)



        before = before_stacks[state_id].to_i



        after = FS_BATTLE_V22.stack_count(self, state_id)



        gained += after - before if after > before



      end



      return if gained <= 0



      text = ALBERT_CHARACTER_CORE.source_text(user, skill)



      per = ALBERT_CHARACTER_CORE.note_number(



        text, "cc_od_state_stack",



        ALBERT_CHARACTER_CORE::VINA_OD_PER_STATE_STACK)



      ALBERT_CHARACTER_CORE.gain_special_od(
        user, :vina_state, gained * per,
        ALBERT_CHARACTER_CORE::VINA_SPECIAL_OD_ACTION_CAP
      )



    end



  end







  # 維娜：spread / drift 實際複製到其他目標的層數也回收 OD。



  if method_defined?(:albert_combo_copy_state_to) &&



     !method_defined?(:fs_v22_copy_state_without_vina_od)



    alias fs_v22_copy_state_without_vina_od albert_combo_copy_state_to



    def albert_combo_copy_state_to(target, state_id, stack_count = nil)



      before = FS_BATTLE_V22.stack_count(target, state_id)



      user = respond_to?(:albert_combo_effect_user) ? albert_combo_effect_user : nil



      obj = respond_to?(:albert_combo_effect_obj) ? albert_combo_effect_obj : nil



      result = fs_v22_copy_state_without_vina_od(target, state_id, stack_count)



      after = FS_BATTLE_V22.stack_count(target, state_id)



      gained = after - before



      if result && gained > 0 && user != nil && obj != nil &&



         user.respond_to?(:albert_cc_vina?) && user.albert_cc_vina? &&



         FS_BATTLE_V22.copy_counts_for_vina?(obj, state_id)



        text = ALBERT_CHARACTER_CORE.source_text(user, obj)



        per = ALBERT_CHARACTER_CORE.note_number(

          text, "cc_od_state_copy",

          ALBERT_CHARACTER_CORE::VINA_OD_PER_COPIED_STATE_STACK)

        ALBERT_CHARACTER_CORE.gain_special_od(
          user, :vina_state, gained * per,
          ALBERT_CHARACTER_CORE::VINA_SPECIAL_OD_ACTION_CAP
        )



      end



      return result



    end



  end



end







#------------------------------------------------------------------------------



# TargetGroup：pokemon / robot / clone 依實際類型判定。



#------------------------------------------------------------------------------



if defined?(ALBERT_TARGET_GROUP)



  module ALBERT_TARGET_GROUP



    class << self



      unless method_defined?(:fs_v22_member_in_group_without_dynamic_types)



        alias fs_v22_member_in_group_without_dynamic_types member_in_group?



      end



      def member_in_group?(member, group, user = nil)



        name = normalize_group_name(group)



        if name == "pokemon"



          return member.respond_to?(:albert_pokemon?) && member.albert_pokemon?



        elsif name == "robot"



          return member.respond_to?(:albert_robot?) && member.albert_robot?



        elsif name == "clone"



          return member.respond_to?(:albert_clone?) && member.albert_clone?



        end



        return fs_v22_member_in_group_without_dynamic_types(member, group, user)



      end







      unless method_defined?(:fs_v22_same_group_without_dynamic_types)



        alias fs_v22_same_group_without_dynamic_types same_group_as_user?



      end



      def same_group_as_user?(member, user)



        if user.respond_to?(:albert_pokemon?) && user.albert_pokemon?



          return member_in_group?(member, "pokemon", user)



        elsif user.respond_to?(:albert_robot?) && user.albert_robot?



          return member_in_group?(member, "robot", user)



        elsif user.respond_to?(:albert_clone?) && user.albert_clone?



          return member_in_group?(member, "clone", user)



        end



        return fs_v22_same_group_without_dynamic_types(member, user)



      end



    end



  end



end







#==============================================================================



# ■ 執行時稽核器



#------------------------------------------------------------------------------



# 事件腳本：



#   FS_BATTLE_MECHANIC_AUDIT_V22.print_report



# 或寫入遊戲資料夾：



#   FS_BATTLE_MECHANIC_AUDIT_V22.write_report



#==============================================================================



module FS_BATTLE_MECHANIC_AUDIT_V22



  def self.add(lines, level, text)



    lines << "[#{level}] #{text}"



  end







  def self.skill(id)



    return nil if $data_skills == nil



    return $data_skills[id]



  end







  def self.note(id)



    obj = skill(id)



    return "" if obj == nil



    return obj.note.to_s



  end







  def self.overheal_state_rule(id)



    text = note(id)



    if text =~ /<overheal_to_user_state\s+41\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i



      return [:user, $1.to_f]



    end



    if text =~ /<overheal_to_state\s+41\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i



      return [:target, $1.to_f]



    end



    return nil



  end



  def self.note_has?(id, regex)



    return note(id) =~ regex ? true : false



  end



  def self.run



    lines = []



    add(lines, "INFO", "Forest Symphony 戰鬥機制稽核 v2.5 OD Economy")







    required_modules = [



      ["ComboCore", defined?(ALBERT_COMBO_CORE)],



      ["CharacterMechanicCore", defined?(ALBERT_CHARACTER_CORE)],



      ["MechanicExpansion", defined?(ALBERT_MECHANIC_EXPANSION)],



      ["TargetGroup", defined?(ALBERT_TARGET_GROUP)]



    ]



    for pair in required_modules



      add(lines, pair[1] ? "OK" : "ERROR",



          "#{pair[0]} #{pair[1] ? '已載入' : '未載入／安裝順序錯誤'}")



    end







    compact = {



      102=>"共鳴感知",106=>"和聲領袖",112=>"溢光回路",116=>"大地祝福",



      122=>"靜電回收",126=>"超頻神經",132=>"毒理學",136=>"病灶連鎖",



      142=>"怒意不熄",146=>"替身承擔",152=>"鬥志打磨",156=>"破城者"



    }



    for id in compact.keys.sort



      obj = skill(id)



      if obj == nil



        add(lines, "ERROR", "Skill #{id} #{compact[id]} 不存在")



      elsif obj.name.to_s != compact[id]



        add(lines, "WARN", "Skill #{id} 名稱是「#{obj.name}」，預期「#{compact[id]}」")



      elsif FS_BATTLE_V22.mechanic_passive_skill?(obj)



        add(lines, "OK", "Skill #{id} #{obj.name} 已納入被動機制來源")



      else



        add(lines, "ERROR", "Skill #{id} #{obj.name} 未被辨識為被動")



      end



    end







    # OD Note 規格稽核：固定成本只能使用 KGC <overdrive N>。
    fixed_costs = {113=>150, 124=>250, 133=>150, 138=>300, 148=>250}
    for id in fixed_costs.keys.sort
      text = note(id)
      cost = fixed_costs[id]
      if text =~ /<overdrive\s+#{cost}\s*>/i
        add(lines, "OK", "Skill #{id} 使用 KGC 固定 OD 成本 #{cost}")
      else
        add(lines, "ERROR", "Skill #{id} 缺少 <overdrive #{cost}>")
      end
      if text =~ /<costo\s+angry\s*:/i
        add(lines, "ERROR", "Skill #{id} 同時使用 <costo angry>，會造成雙重 OD 成本")
      end
    end

    if note_has?(125, /<atb_interrupt_cost\s*:\s*200\s*>/i) &&
       !note_has?(125, /<atb_interrupt_od\s*:/i)
      add(lines, "OK", "Skill 125 打斷採條件消耗 200 OD，已移除免費打斷 OD")
    else
      add(lines, "ERROR", "Skill 125 打斷 OD Note 未完成新版轉換")
    end
    if note_has?(128, /<atb_interrupt_cost\s*:\s*350\s*>/i) &&
       !note_has?(128, /<atb_interrupt_od\s*:/i)
      add(lines, "OK", "Skill 128 打斷採條件消耗 350 OD，已移除免費打斷 OD")
    else
      add(lines, "ERROR", "Skill 128 打斷 OD Note 未完成新版轉換")
    end
    if note_has?(132, /<state_chance_per_od_percent\s+31\s*:\s*0\.1\s*>/i) &&
       note_has?(132, /<state_chance_per_od_percent\s+35\s*:\s*0\.1\s*>/i) &&
       note_has?(132, /<state_chance_per_od_percent\s+37\s*:\s*0\.1\s*>/i)
      add(lines, "OK", "Skill 132 OD 可強化毒／寄生／腐蝕成功率")
    else
      add(lines, "ERROR", "Skill 132 的 state_chance_per_od_percent 格式不完整")
    end
    if note_has?(155, /<break_bonus_od_tier\s+50\s*:\s*1\s*:\s*150\s*>/i) &&
       note_has?(155, /<break_bonus_od_tier\s+80\s*:\s*1\s*:\s*200\s*>/i) &&
       !note_has?(155, /<break_bonus_if_od\s+/i)
      add(lines, "OK", "Skill 155 破勢加成改為分段支付 OD")
    else
      add(lines, "ERROR", "Skill 155 仍缺少新版分段 OD 支付")
    end

    rule = overheal_state_rule(111)



    if rule == nil



      add(lines, "ERROR", "Skill 111 溢光缺少 overheal_to_user_state 41:10")



    elsif rule[0] != :user



      add(lines, "ERROR", "Skill 111 溢光仍把魔力層加給治療目標，應改為施術者米亞")



    elsif (rule[1] - 10.0).abs > 0.001



      add(lines, "WARN", "Skill 111 溢光門檻為 #{rule[1]}%，目前設計值為 10%")



    else



      add(lines, "OK", "Skill 111 溢光：每 10% 溢療為米亞增加 1 層魔力")



    end



    if note_has?(115, /<bonus_per_user_state_stack\s+41\s*:/i)



      add(lines, "OK", "Skill 115 魔力弦彈讀取米亞自身魔力層")



    else



      add(lines, "ERROR", "Skill 115 魔力弦彈未讀取使用者 State 41")



    end



    burst_bonus = note_has?(117, /<bonus_per_user_state_stack\s+41\s*:/i)



    burst_cost = note_has?(117, /<consume_user_state\s+41\s*:\s*3\s*>/i)



    if burst_bonus && burst_cost



      add(lines, "OK", "Skill 117 星輝放弦讀取自身魔力並成功後消耗 3 層")



    else



      add(lines, "ERROR", "Skill 117 星輝放弦的自身增傷／3 層消耗鏈不完整")



    end



    life = skill(118)



    if life != nil



      if note(118) =~ /<phoenix>/i



        add(lines, "ERROR", "Skill 118 生命回響仍有 <phoenix>，可能混入敵方目標")



      elsif life.respond_to?(:for_dead_friend?) && life.for_dead_friend?



        add(lines, "OK", "Skill 118 生命回響為死亡友軍範圍")



      else



        add(lines, "WARN", "Skill 118 請在資料庫設為我方死亡單體")



      end



    end







    rule = overheal_state_rule(119)



    if rule == nil



      add(lines, "ERROR", "Skill 119 大地頌歌缺少 overheal_to_user_state 41:25")



    elsif rule[0] != :user



      add(lines, "ERROR", "Skill 119 大地頌歌仍把魔力層分散給治療目標")



    elsif (rule[1] - 25.0).abs > 0.001



      add(lines, "WARN", "Skill 119 大地頌歌門檻為 #{rule[1]}%，目前設計值為 25%")



    else



      add(lines, "OK", "Skill 119 大地頌歌：各目標溢療可為米亞累積魔力層")



    end



    if note_has?(109, /<cc_od_(?:heal|overheal)_percent\s*:/i)



      add(lines, "WARN", "Skill 109 森之交響仍殘留治療 OD 標籤；此技能不是治療技")



    else



      add(lines, "OK", "Skill 109 未混入無效的治療 OD 標籤")



    end



    if note_has?(149, /<cc_od_break(?:_point)?\s*:/i)



      add(lines, "WARN", "Skill 149 怒海歸斧仍殘留泰勒 Break OD 標籤")



    else



      add(lines, "OK", "Skill 149 未混入無效的 Break OD 標籤")



    end



    if note_has?(131, /<state_stack_if_present\s+31\s*:\s*2\s*>/i)

      add(lines, "OK", "Skill 131 毒素培養：未中毒成功+1，已中毒成功總共+2層")

    else

      add(lines, "ERROR", "Skill 131 毒素培養缺少 <state_stack_if_present 31:2>")

    end



    note_state_support = Game_Battler.method_defined?(:albert_cc_skill_state_ids) &&

                         Game_Battler.method_defined?(:albert_cc_process_state_stack_if_present)

    add(lines, note_state_support ? "OK" : "ERROR",

        "CharacterCore Note狀態疊層／維娜OD修正 #{note_state_support ? '已載入' : '未載入'}")



    weakness_break = defined?(ALBERT_CHARACTER_CORE) &&

                     ALBERT_CHARACTER_CORE.const_defined?(:ENABLE_WEAKNESS_BREAK) &&

                     ALBERT_CHARACTER_CORE::ENABLE_WEAKNESS_BREAK &&

                     ALBERT_CHARACTER_CORE.const_defined?(:WEAKNESS_BREAK_POWER) &&

                     ALBERT_CHARACTER_CORE::WEAKNESS_BREAK_POWER.to_i == 1 &&

                     Game_Battler.method_defined?(:albert_cc_weakness_break_eligible?)

    add(lines, weakness_break ? "OK" : "ERROR",

        "屬性克制傷害累積破勢+1 #{weakness_break ? '已啟用' : '未啟用／核心版本過舊'}")



    for id in 160..184



      obj = skill(id)



      if obj == nil



        add(lines, "ERROR", "Clone Skill #{id} 不存在")



      elsif note(id) !~ /<clone_stability_(?:cost|recover)\s*:/i



        add(lines, "WARN", "Clone Skill #{id} #{obj.name} 沒有穩定度消耗／回復標籤")



      end



    end



    add(lines, "INFO", "Clone 160-184 已逐招檢查穩定度標籤")







    for id in 185..189



      obj = skill(id)



      add(lines, obj == nil ? "ERROR" : "OK",



          "Robot Protocol Skill #{id} #{obj == nil ? '不存在' : obj.name}")



    end



    for id in 190..192



      obj = skill(id)



      add(lines, obj == nil ? "ERROR" : "OK",



          "共鳴追擊 Skill #{id} #{obj == nil ? '不存在' : obj.name}")



    end







    if $data_states != nil && $data_states[72] != nil



      add(lines, "OK", "State 72 守住／無敵已建立；仍須保留 v3.2 防禦補丁")



    else



      add(lines, "ERROR", "State 72 不存在")



    end







    [[633,"吸血"],[605,"終極吸取"],[741,"吸取"]].each do |pair|



      obj = skill(pair[0])



      next if obj == nil



      if obj.respond_to?(:absorb_damage) && obj.absorb_damage



        add(lines, "OK", "Skill #{pair[0]} #{pair[1]} 已勾吸收傷害")



      else



        add(lines, "WARN", "Skill #{pair[0]} #{pair[1]} 請確認勾選吸收傷害")



      end



    end







    add(lines, "INFO", "三段追擊缺少某一段候補時，現行腳本會在該段停止，不是跨段續接")



    add(lines, "INFO", "靜態稽核不能替代新存檔實戰；至少測一次每名角色兩個被動的前後差異")



    return lines



  end







  def self.print_report



    for line in run



      p line



    end



  end







  def self.write_report(filename = "BattleMechanicAudit_v2_2.txt")



    file = File.open(filename, "wb")



    file.write(run.join("\r\n"))



    file.close



    return filename



  end



end







#==============================================================================



# ■ END



#==============================================================================









