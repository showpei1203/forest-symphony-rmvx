#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SkillCost_Authority v2.0.0
# 【用途】Forest Symphony 技能成本最終 Authority：統一解析、計算、可用判定、選單支付、戰鬥 MP／Angry 支付與成本 UI。Phase 24 起正式取代已退休的 `Skill Cost Fix`。
# 【主要機制】MP 成本由本頁單一計算並明確套用 YEZ Skill Level `apply_level_cost` modifier；選單支付由本頁單一執行。戰鬥中的 HP／Gold／Variable／Item 仍透過前方 Holy87 Battle Timing Bridge 在既有時點呼叫本頁支付政策，以保持外層戰鬥機制的時序等價。
# 【主要影響】RPG::Skill、Game_Battler、Scene_Battle、Scene_Skill、Window_Skill、Window_Skill2、Scene_Title
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：LEGACY_MP_CLEAR_WIDTH、GENERATED_SUPPORT_MP_COSTS、COST_KEYS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 8 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Skill Cost AllFix；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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



# ■ FS_SkillCost_Authority v2.0.0



#------------------------------------------------------------------------------



# RPG Maker VX / RGSS2



#



# 【目的】



# 統一修復「技能消耗改變」在目前 Forest Symphony 腳本順序下的：



#   1. 戰鬥中一般技能不扣 MP。



#   2. Skill Window 只剩 MP，物品／HP／金錢／變數／怒氣／狀態不顯示。



#   3. <costo angry:x> 只顯示但未檢查、未扣除。



#   4. <costo state:x> 只顯示但未作為使用條件。



#   5. AutoSetup 或後段補丁改寫 Note 後，舊快取未重新解析。



#



# 【安裝位置】



#   SoulMark_Resonance_Expansion



#   ↓



#   FS_SoulMark_Resonance_Hotfix_v2_0_2



#   ↓



#   本補丁



#   ↓



#   ElementRate_FinalGuard



#   ↓



#   Main



#



# 【支援 Note】



#   <costo hp:x>       固定 HP 消耗



#   <costo hp:x%>      最大 HP 百分比消耗



#   <costo mp:x>       固定 MP 消耗，覆蓋資料庫 MP 欄位



#   <costo mp:x%>      最大 MP 百分比消耗



#   <costo oro:x>      固定金錢消耗



#   <costo oro:x%>     現有金錢百分比消耗



#   <costo var:x>      變數 281 固定消耗



#   <costo var:x%>     變數 281 現值百分比消耗



#   <usa oggetto:x>    消耗 Item x 一個



#   <costo angry:x>    消耗 KGC OverDrive／怒氣 x



#   <costo state:x>    必須持有 State x；不移除該狀態



#



# 【重要】



# - HP／MP／金錢／變數／物品可同時存在，全部支付一次。



# - KGC 的 <overdrive N> 與 <costo angry:x> 仍是兩筆獨立成本。

# - Skill Window 會合併顯示兩者總 OD，使用條件也會檢查總和，實際仍各自支付一次。



# - 狀態是使用條件，不是消耗品。



# - 偷竊技能原腳本已有自己的 MP 扣除，本補丁會辨識並避免重扣。



#==============================================================================







$imported = {} if $imported == nil



$imported["FS Skill Cost AllFix"] = "2.0.0"
$imported["FS Skill Cost Authority"] = "2.0.0"







module FS_SKILL_COST_ALLFIX



  VERSION = "2.0.0"

  # 原始Window_Skill會先在右側畫一個裸MP數字。
  # 完整成本重畫前至少清除此寬度，避免同時出現「4」與「4MP」。
  LEGACY_MP_CLEAR_WIDTH = 64

  # SoulMark系統正式生成的六個維護技能MP。
  GENERATED_SUPPORT_MP_COSTS = {
    193 => 12, # 魂刻療護
    194 => 30, # 魂刻復甦
    195 => 10, # 回憶
    196 => 28, # 新生
    197 => 8,  # 冷卻
    198 => 24  # 重組
  }

COST_KEYS = [



    :hp, :hp_per, :mp_fixed, :mp_per, :gold, :gold_per,



    :var, :var_per, :item, :angry, :state



  ]







  def self.zero_costs



    result = {}



    COST_KEYS.each { |key| result[key] = 0 }



    return result



  end







  def self.parse_number(note, label, percent)



    mark = percent ? '[%％]' : ''



    if percent



      regexp = /<\s*#{label}\s*:\s*(\d+)\s*[%％]\s*>/i



    else



      regexp = /<\s*#{label}\s*:\s*(\d+)\s*>/i



    end



    match = regexp.match(note)



    return match == nil ? 0 : match[1].to_i



  end







  def self.parse(skill, force = false)



    return zero_costs if skill == nil



    note = skill.respond_to?(:note) ? skill.note.to_s : ""







    unless force



      old_note = skill.instance_variable_get(:@fs_sc_allfix_note)



      old_data = skill.instance_variable_get(:@fs_sc_allfix_data)



      return old_data if old_note == note && old_data.is_a?(Hash)



    end







    data = zero_costs



    data[:hp]       = parse_number(note, 'costo\s+hp', false)



    data[:hp_per]   = parse_number(note, 'costo\s+hp', true)



    data[:mp_fixed] = parse_number(note, 'costo\s+mp', false)



    data[:mp_per]   = parse_number(note, 'costo\s+mp', true)



    data[:gold]     = parse_number(note, 'costo\s+oro', false)



    data[:gold_per] = parse_number(note, 'costo\s+oro', true)



    data[:var]      = parse_number(note, 'costo\s+var', false)



    data[:var_per]  = parse_number(note, 'costo\s+var', true)



    data[:item]     = parse_number(note, 'usa\s+oggetto', false)



    data[:angry]    = parse_number(note, 'costo\s+angry', false)



    data[:state]    = parse_number(note, 'costo\s+state', false)







    if data[:mp_fixed] > 0 && skill.respond_to?(:mp_cost=)



      skill.mp_cost = data[:mp_fixed]



    end







    # 同步舊腳本欄位，讓其他既有腳本仍可讀取。



    skill.instance_variable_set(:@costohp,     data[:hp])



    skill.instance_variable_set(:@costohp_per, data[:hp_per])



    skill.instance_variable_set(:@costomp_per, data[:mp_per])



    skill.instance_variable_set(:@costog,      data[:gold])



    skill.instance_variable_set(:@costog_per,  data[:gold_per])



    skill.instance_variable_set(:@costov,      data[:var])



    skill.instance_variable_set(:@costov_per,  data[:var_per])



    skill.instance_variable_set(:@costoi,      data[:item])



    skill.instance_variable_set(:@costoangry,  data[:angry])



    skill.instance_variable_set(:@costostate,  data[:state])



    skill.instance_variable_set(:@cache_caricata, true)







    skill.instance_variable_set(:@fs_sc_allfix_note, note)



    skill.instance_variable_set(:@fs_sc_allfix_data, data)



    return data



  end







  def self.value(skill, key)



    data = parse(skill)



    value = data[key]



    return value == nil ? 0 : value.to_i



  end







  def self.normalize_generated_support_costs

    return if $data_skills == nil

    GENERATED_SUPPORT_MP_COSTS.each do |skill_id, mp_cost|

      skill = $data_skills[skill_id]
      next if skill == nil

      skill.mp_cost = mp_cost.to_i if skill.respond_to?(:mp_cost=)
      skill.instance_variable_set(:@fs_sc_allfix_note, nil)
      skill.instance_variable_set(:@fs_sc_allfix_data, nil)
      skill.instance_variable_set(:@level_cost, nil)

    end

  end



  def self.rebuild_all

    return if $data_skills == nil

    normalize_generated_support_costs

    for skill in $data_skills



      next if skill == nil



      parse(skill, true)

      # AutoSetup 可能改寫 Note，KGC OverDrive 的舊快取也必須重建。

      skill.instance_variable_set(:@__is_overdrive, nil)

      skill.instance_variable_set(:@__od_cost, nil)

      skill.instance_variable_set(:@__od_gain_rate, nil)



    end



  end







  def self.half?(battler)



    return battler.respond_to?(:half_mp_cost) && battler.half_mp_cost



  end







  def self.angry_value(battler)



    return 0 if battler == nil



    if battler.respond_to?(:overdrive)



      return battler.overdrive.to_i



    elsif battler.respond_to?(:od)



      return battler.od.to_i



    elsif battler.respond_to?(:angry)



      return battler.angry.to_i



    end



    return 0



  end







  def self.kgc_od_cost(battler, skill)

    return 0 if battler == nil || skill == nil

    return 0 unless battler.respond_to?(:calc_od_cost)

    value = battler.calc_od_cost(skill)

    return value == nil ? 0 : [value.to_i, 0].max

  rescue

    return 0

  end



  def self.total_od_cost(battler, skill)

    angry = 0

    angry = battler.calc_angry_cost(skill) if battler != nil &&

      battler.respond_to?(:calc_angry_cost)

    return kgc_od_cost(battler, skill) + angry.to_i

  end



  def self.lose_angry(battler, amount)



    return if battler == nil



    amount = amount.to_i



    return if amount <= 0







    if battler.respond_to?(:overdrive) && battler.respond_to?(:overdrive=)



      battler.overdrive = [battler.overdrive.to_i - amount, 0].max



    elsif battler.respond_to?(:od) && battler.respond_to?(:od=)



      battler.od = [battler.od.to_i - amount, 0].max



    elsif battler.respond_to?(:angry) && battler.respond_to?(:angry=)



      battler.angry = [battler.angry.to_i - amount, 0].max



    end



  end







  #--------------------------------------------------------------------------
  # Phase 24：支付政策（Policy）
  #--------------------------------------------------------------------------
  # 這兩個方法不決定「支付時點」；Battle Timing Bridge 與 Scene_Skill Authority
  # 只在既有時點呼叫它們，讓金額規則集中、時序保持不變。
  def self.pay_battle_legacy_costs(battler, skill)
    return if battler == nil || skill == nil

    # 舊 Holy87 battle wrapper：若使用者已死亡，HP／Gold 不支付；
    # Variable 與 Item 仍照舊處理。這個歷史行為刻意保留。
    unless battler.dead?
      hp_cost = battler.calc_hp_cost(skill)
      battler.hp -= hp_cost if hp_cost > 0

      gold_cost = battler.calc_gold_cost(skill)
      $game_party.lose_gold(gold_cost) if $game_party != nil && gold_cost > 0
    end

    if defined?(Skill_Costs) && $game_variables != nil
      var_cost = battler.calc_var_cost(skill)
      $game_variables[Skill_Costs::Variabile] -= var_cost if var_cost > 0
    end

    if battler.respond_to?(:actor?) && battler.actor?
      item_id = battler.calc_item_cost(skill)
      if item_id > 0 && $data_items != nil && $game_party != nil
        item = $data_items[item_id] rescue nil
        $game_party.lose_item(item, 1) if item != nil
      end
    end
  end

  def self.pay_menu_standard_costs(actor, skill)
    return if actor == nil || skill == nil

    hp_cost = actor.calc_hp_cost(skill)
    actor.hp -= hp_cost if hp_cost > 0

    mp_cost = actor.calc_mp_cost(skill)
    actor.mp -= mp_cost if mp_cost > 0

    if $game_party != nil
      gold_cost = actor.calc_gold_cost(skill)
      $game_party.lose_gold(gold_cost) if gold_cost > 0
    end

    if defined?(Skill_Costs) && $game_variables != nil
      var_cost = actor.calc_var_cost(skill)
      $game_variables[Skill_Costs::Variabile] -= var_cost if var_cost > 0
    end

    item_id = actor.calc_item_cost(skill)
    if item_id > 0 && $data_items != nil && $game_party != nil
      item = $data_items[item_id] rescue nil
      $game_party.lose_item(item, 1) if item != nil
    end
  end

  def self.steal_skill?(skill)



    return false if skill == nil



    return false unless skill.respond_to?(:steal?)



    begin



      return skill.steal?



    rescue



      return false



    end



  end







  def self.color(window, method_name, fallback_index)



    if window.respond_to?(method_name)



      return window.send(method_name)



    end



    return window.text_color(fallback_index)



  end







  def self.cost_entries(window, actor, skill)



    return [] if actor == nil || skill == nil



    parse(skill)







    entries = []







    item_id = value(skill, :item)



    if item_id > 0 && $data_items != nil



      item = $data_items[item_id] rescue nil



      entries << [:icon, item.icon_index, nil] if item != nil



    end







    state_id = value(skill, :state)



    if state_id > 0 && $data_states != nil



      state = $data_states[state_id] rescue nil



      entries << [:icon, state.icon_index, nil] if state != nil



    end







    od_total = total_od_cost(actor, skill)



    if od_total.to_i > 0



      entries << [:text, od_total.to_i.to_s + "OD",



        color(window, :colore_angry, 1)]



    end







    hp = actor.respond_to?(:calc_hp_cost) ? actor.calc_hp_cost(skill) : 0



    if hp.to_i > 0



      suffix = defined?(Vocab) && Vocab.respond_to?(:hp_a) ?



        Vocab.hp_a.to_s : "HP"



      entries << [:text, hp.to_i.to_s + suffix,



        color(window, :colore_hp, 11)]



    end







    mp = actor.respond_to?(:calc_mp_cost) ? actor.calc_mp_cost(skill) : 0



    if mp.to_i > 0



      suffix = defined?(Vocab) && Vocab.respond_to?(:mp_a) ?



        Vocab.mp_a.to_s : "MP"



      entries << [:text, mp.to_i.to_s + suffix,



        color(window, :colore_mp, 5)]



    end







    var = actor.respond_to?(:calc_var_cost) ? actor.calc_var_cost(skill) : 0



    if var.to_i > 0



      suffix = defined?(Vocab) && Vocab.respond_to?(:var_skill) ?



        Vocab.var_skill.to_s : "氣"



      entries << [:text, var.to_i.to_s + suffix,



        color(window, :colore_var, 2)]



    end







    gold = actor.respond_to?(:calc_gold_cost) ? actor.calc_gold_cost(skill) : 0



    if gold.to_i > 0



      suffix = defined?(Vocab) && Vocab.respond_to?(:gold) ?



        Vocab.gold.to_s : "G"



      entries << [:text, gold.to_i.to_s + suffix,



        color(window, :colore_gold, 6)]



    end







    return entries



  end







  def self.draw_costs(window, actor, skill, rect, enabled)

    return if window.contents == nil

    entries = cost_entries(window, actor, skill)

    old_size = window.contents.font.size
    old_color = window.contents.font.color
    old_alpha = window.contents.font.color.alpha

    window.contents.font.size = [old_size, 14].min

    right = rect.x + rect.width - 4
    min_left = rect.x + 48
    legacy_left = [right - LEGACY_MP_CLEAR_WIDTH, min_left].max

    bar_height = 0
    if defined?(H87_Delay) && H87_Delay.const_defined?(:Lgzz)
      bar_height = H87_Delay::Lgzz.to_i + 1
    end
    clear_height = [rect.height - bar_height, 1].max

    # 即使沒有任何消耗，也要清除原Window_Skill先畫的裸MP數字。
    if entries.empty?
      window.contents.clear_rect(
        legacy_left, rect.y, right - legacy_left + 4, clear_height)
      window.contents.font.size = old_size
      window.contents.font.color = old_color
      window.contents.font.color.alpha = old_alpha
      return
    end

    widths = []
    total = 0
    entries.each do |entry|
      if entry[0] == :icon
        width = 24
      else
        width = window.contents.text_size(entry[1]).width + 6
      end
      widths << width
      total += width
    end

    left = [right - total, min_left].max
    clear_left = [left, legacy_left].min
    window.contents.clear_rect(
      clear_left, rect.y, right - clear_left + 4, clear_height)

    cursor = right
    entries.each_with_index do |entry, index|
      width = widths[index]
      cursor -= width
      if entry[0] == :icon
        window.draw_icon(entry[1], cursor, rect.y, enabled)
      else
        window.contents.font.color = entry[2]
        window.contents.font.color.alpha = enabled ? 255 : 128
        window.contents.draw_text(
          cursor, rect.y, width, rect.height, entry[1], 2)
      end
    end

    window.contents.font.size = old_size
    window.contents.font.color = old_color
    window.contents.font.color.alpha = old_alpha

  end



end







#==============================================================================



# ■ RPG::Skill：最終、可自動重建的消耗欄位



#==============================================================================







if defined?(RPG::Skill)



  class RPG::Skill



    def fs_sc_allfix_value(key)



      FS_SKILL_COST_ALLFIX.value(self, key)



    end







    def costohp;      fs_sc_allfix_value(:hp);       end



    def costohp_per;  fs_sc_allfix_value(:hp_per);   end



    def costomp_per;  fs_sc_allfix_value(:mp_per);   end



    def costog;       fs_sc_allfix_value(:gold);     end



    def costog_per;   fs_sc_allfix_value(:gold_per); end



    def costov;       fs_sc_allfix_value(:var);      end



    def costov_per;   fs_sc_allfix_value(:var_per);  end



    def costoi;       fs_sc_allfix_value(:item);     end



    def costoangry;   fs_sc_allfix_value(:angry);    end



    def costostate;   fs_sc_allfix_value(:state);    end



  end



end







#==============================================================================



# ■ Game_Battler：計算、可用條件、怒氣支付



#==============================================================================







class Game_Battler
  #--------------------------------------------------------------------------
  # Phase 24：MP 成本最終 Authority（不再 alias 前方 calc_mp_cost）
  #--------------------------------------------------------------------------
  def calc_mp_cost(skill)
    return 0 if skill == nil

    FS_SKILL_COST_ALLFIX.parse(skill)

    base = skill.respond_to?(:mp_cost) ? skill.mp_cost.to_i : 0
    base += maxmp * FS_SKILL_COST_ALLFIX.value(skill, :mp_per) / 100
    base /= 2 if FS_SKILL_COST_ALLFIX.half?(self)
    # Phase 23 舊鏈會先由 Skill Cost Fix clamp，再套 Skill Level modifier。
    # 此中間 clamp 必須保留，避免極端資料下改變舊行為。
    base = [[base.to_i, 0].max, 999999].min

    # YEZ Job Skill Levels Phase 24 起只提供 modifier，不再 alias calc_mp_cost。
    if (!$imported || !$imported["CustomSkillEffectsZeal"]) &&
       respond_to?(:apply_level_cost)
      base = apply_level_cost(base, skill)
    end

    return [[base.to_i, 0].max, 999999].min
  rescue
    base = skill.respond_to?(:mp_cost) ? skill.mp_cost.to_i : 0
    base += maxmp * FS_SKILL_COST_ALLFIX.value(skill, :mp_per) / 100
    base /= 2 if FS_SKILL_COST_ALLFIX.half?(self)
    return [[base.to_i, 0].max, 999999].min
  end

  def calc_hp_cost(skill)



    return 0 if skill == nil



    cost = FS_SKILL_COST_ALLFIX.value(skill, :hp)



    cost += maxhp * FS_SKILL_COST_ALLFIX.value(skill, :hp_per) / 100



    if defined?(Skill_Costs) && Skill_Costs::Dimezza_C_HP



      cost /= 2 if FS_SKILL_COST_ALLFIX.half?(self)



    end



    return [[cost.to_i, 0].max, 999999].min



  end







  def calc_gold_cost(skill)



    return 0 if skill == nil



    cost = FS_SKILL_COST_ALLFIX.value(skill, :gold)



    if $game_party != nil



      cost += $game_party.gold.to_i *



        FS_SKILL_COST_ALLFIX.value(skill, :gold_per) / 100



    end



    if defined?(Skill_Costs) && Skill_Costs::Dimezza_C_G



      cost /= 2 if FS_SKILL_COST_ALLFIX.half?(self)



    end



    return [[cost.to_i, 0].max, 99999999].min



  end







  def calc_var_cost(skill)



    return 0 if skill == nil



    return 0 unless defined?(Skill_Costs)



    cost = FS_SKILL_COST_ALLFIX.value(skill, :var)



    cost += Skill_Costs.var_act.to_i *



      FS_SKILL_COST_ALLFIX.value(skill, :var_per) / 100



    if Skill_Costs::Dimezza_C_V



      cost /= 2 if FS_SKILL_COST_ALLFIX.half?(self)



    end



    return [[cost.to_i, 0].max, 99999999].min



  end







  def calc_angry_cost(skill)



    return 0 if skill == nil



    cost = FS_SKILL_COST_ALLFIX.value(skill, :angry)



    if defined?(Skill_Costs) &&



       Skill_Costs.const_defined?(:Dimezza_C_A) &&



       Skill_Costs::Dimezza_C_A



      cost /= 2 if FS_SKILL_COST_ALLFIX.half?(self)



    end



    return [[cost.to_i, 0].max, 999999].min



  end







  def calc_state_cost(skill)



    return FS_SKILL_COST_ALLFIX.value(skill, :state)



  end







  def calc_item_cost(skill)



    return FS_SKILL_COST_ALLFIX.value(skill, :item)



  end







  def no_item_required?(skill)



    return false if skill == nil



    item_id = calc_item_cost(skill)



    return false if item_id <= 0



    return true if $data_items == nil



    item = $data_items[item_id] rescue nil



    return true if item == nil



    return true if $game_party == nil



    return !$game_party.has_item?(item)



  end







  def fs_sc_allfix_state_requirement_met?(skill)



    state_id = calc_state_cost(skill)



    return true if state_id <= 0



    return state?(state_id)



  end







  def fs_sc_allfix_angry_enough?(skill)



    cost = calc_angry_cost(skill)



    return true if cost <= 0



    return FS_SKILL_COST_ALLFIX.angry_value(self) >= cost



  end







  def fs_sc_allfix_total_od_enough?(skill)

    total = FS_SKILL_COST_ALLFIX.total_od_cost(self, skill)

    return true if total <= 0

    return FS_SKILL_COST_ALLFIX.angry_value(self) >= total

  end



  def fs_sc_allfix_pay_angry(skill)



    FS_SKILL_COST_ALLFIX.lose_angry(self, calc_angry_cost(skill))



  end







  unless method_defined?(:fs_sc_allfix_skill_can_use_without_extra_cost)



    alias fs_sc_allfix_skill_can_use_without_extra_cost skill_can_use?



  end







  def skill_can_use?(skill)



    return false unless skill.is_a?(RPG::Skill)



    FS_SKILL_COST_ALLFIX.parse(skill)







    return false unless fs_sc_allfix_state_requirement_met?(skill)



    return false unless fs_sc_allfix_total_od_enough?(skill)



    return false if calc_hp_cost(skill) > hp



    return false if calc_mp_cost(skill) > mp







    if actor?



      return false if $game_party != nil &&



        calc_gold_cost(skill) > $game_party.gold



      if defined?(Skill_Costs)



        return false if calc_var_cost(skill) > Skill_Costs.var_act



      end



      return false if no_item_required?(skill)



    end







    return fs_sc_allfix_skill_can_use_without_extra_cost(skill)



  end



end







#==============================================================================



# ■ 戰鬥：補上目前 Tankentai 流程遺失的 MP，並支付自訂怒氣



#------------------------------------------------------------------------------



# 現況：



# - Sideview 2 的 execute_action_skill 將標準 MP 扣除註解掉。



# - KGC 偷竊技能自己扣 MP。



# - 舊技能消耗頁仍會扣 HP／金錢／變數／物品。



# 因此這裡只補「一般技能 MP」與「自訂怒氣」，避免其他成本重扣。



#==============================================================================







class Scene_Battle < Scene_Base



  unless method_defined?(:fs_sc_allfix_execute_action_skill_without_payment)



    alias fs_sc_allfix_execute_action_skill_without_payment execute_action_skill



  end







  def execute_action_skill(*args)



    battler = @active_battler



    skill = nil



    valid = false







    if battler != nil && battler.respond_to?(:action) && battler.action != nil



      begin



        skill = battler.action.skill



      rescue



        skill = nil



      end



      if skill != nil



        begin



          valid = battler.action.valid?



        rescue



          valid = battler.skill_can_use?(skill)



        end



      end



    end







    mp_cost = valid && battler != nil ? battler.calc_mp_cost(skill) : 0



    angry_cost = valid && battler != nil ? battler.calc_angry_cost(skill) : 0



    steal_skill = FS_SKILL_COST_ALLFIX.steal_skill?(skill)







    result = fs_sc_allfix_execute_action_skill_without_payment(*args)







    if valid && battler != nil && skill != nil



      # KGC 偷竊分支已在 execute_action_steal 內扣除 MP。



      battler.mp -= mp_cost if mp_cost > 0 && !steal_skill



      FS_SKILL_COST_ALLFIX.lose_angry(battler, angry_cost)



      @status_window.refresh if @status_window != nil



    end







    return result



  end



end







#==============================================================================



# ■ 選單：FS_SkillCost_Authority 最終支付流程（Phase 24）



#==============================================================================







class Scene_Skill < Scene_Base

  #--------------------------------------------------------------------------
  # Phase 24：選單技能支付最終 Authority
  #--------------------------------------------------------------------------
  # 支付順序刻意等價 Phase 23 最終鏈：
  # KGC OD -> Sound -> HP/MP/Gold/Var/Item -> H87 Delay 登錄 -> Scene 切換 -> Angry。
  def use_skill_nontarget
    return if @skill == nil

    skill = @skill
    actor = @actor
    angry_cost = actor != nil ? actor.calc_angry_cost(skill) : 0

    consume_od_gauge if respond_to?(:consume_od_gauge)
    Sound.play_use_skill
    FS_SKILL_COST_ALLFIX.pay_menu_standard_costs(actor, skill)

    # H87 Skill Delay：舊 wrapper 的效果直接整合，避免再靠 use_skill_nontarget alias。
    if actor != nil && skill.respond_to?(:battle_delay) && skill.battle_delay > 0
      actor.add_battle_skill(skill) if actor.respond_to?(:add_battle_skill)
    elsif actor != nil && skill.respond_to?(:step_delay) && skill.step_delay > 0
      actor.add_step_skill(skill) if actor.respond_to?(:add_step_skill)
    end

    @status_window.refresh if @status_window != nil
    @skill_window.refresh if @skill_window != nil
    @target_window.refresh if @target_window != nil

    if $game_party.all_dead?
      $scene = Scene_Gameover.new
    elsif skill.common_event_id > 0
      $game_temp.common_event_id = skill.common_event_id
      $scene = Scene_Map.new
    end

    FS_SKILL_COST_ALLFIX.lose_angry(actor, angry_cost) if angry_cost > 0
    @status_window.refresh if @status_window != nil
    @skill_window.refresh if @skill_window != nil
    return nil
  end

end

#==============================================================================

# ■ Skill Window：在既有名稱、技能等級、冷卻條之上重畫完整消耗



#==============================================================================







if defined?(Window_Skill)



  class Window_Skill < Window_Selectable



    unless method_defined?(:fs_sc_allfix_draw_item_without_costs)



      alias fs_sc_allfix_draw_item_without_costs draw_item



    end







    def draw_item(index)



      fs_sc_allfix_draw_item_without_costs(index)



      skill = @data[index] rescue nil



      return if skill == nil



      rect = item_rect(index)



      enabled = @actor != nil ? @actor.skill_can_use?(skill) : false



      FS_SKILL_COST_ALLFIX.draw_costs(self, @actor, skill, rect, enabled)



    end



  end



end







if defined?(Window_Skill2)



  class Window_Skill2 < Window_Selectable



    unless method_defined?(:fs_sc_allfix_draw_item2_without_costs)



      alias fs_sc_allfix_draw_item2_without_costs draw_item



    end







    def draw_item(index)



      fs_sc_allfix_draw_item2_without_costs(index)



      skill = @data[index] rescue nil



      return if skill == nil



      rect = item_rect(index)



      enabled = @actor != nil ? @actor.skill_can_use?(skill) : false



      FS_SKILL_COST_ALLFIX.draw_costs(self, @actor, skill, rect, enabled)



    end



  end



end







#==============================================================================



# ■ 資料庫載入後，對全部技能重新解析



#==============================================================================







if defined?(Scene_Title)



  class Scene_Title < Scene_Base



    unless method_defined?(:fs_sc_allfix_load_database)



      alias fs_sc_allfix_load_database load_database



      def load_database



        fs_sc_allfix_load_database



        FS_SKILL_COST_ALLFIX.rebuild_all



      end



    end







    unless method_defined?(:fs_sc_allfix_load_bt_database)



      alias fs_sc_allfix_load_bt_database load_bt_database



      def load_bt_database



        fs_sc_allfix_load_bt_database



        FS_SKILL_COST_ALLFIX.rebuild_all



      end



    end



  end



end

#==============================================================================
# ■ FS Skill Cost診斷
#==============================================================================
class Game_Interpreter

  # 地圖事件腳本：fs_skill_cost_report(1)
  def fs_skill_cost_report(actor_id = 1)
    actor = $game_actors[actor_id.to_i]
    if actor == nil
      $game_message.texts.push("找不到Actor #{actor_id}。")
      return false
    end

    lines = []
    lines.push("FS Skill Cost Report v2.0.0")
    lines.push("=" * 72)
    lines.push("Actor #{actor.id} #{actor.name}")

    for skill in actor.skills
      next if skill == nil
      calc_mp = if actor.respond_to?(:calc_mp_cost)
                  actor.calc_mp_cost(skill).to_i
                else
                  skill.mp_cost.to_i
                end
      data = FS_SKILL_COST_ALLFIX.parse(skill)
      item_id = data[:item].to_i
      od_cost = FS_SKILL_COST_ALLFIX.total_od_cost(actor, skill).to_i
      lines.push(
        "Skill #{skill.id} #{skill.name} | " +
        "db_mp=#{skill.mp_cost.to_i} calc_mp=#{calc_mp} " +
        "item=#{item_id} od=#{od_cost}")
    end

    File.open("FS_SkillCost_Report.txt", "wb") do |file|
      file.write(lines.join("\r\n"))
    end
    $game_message.texts.push("技能消耗報告已輸出。")
    return true
  rescue
    $game_message.texts.push("技能消耗報告輸出失敗。")
    return false
  end
end
