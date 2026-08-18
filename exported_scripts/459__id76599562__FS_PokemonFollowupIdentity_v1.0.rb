#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_PokemonFollowupIdentity v1.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_PokemonFollowupIdentity v1.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Scene_Battle、Game_Battler、FS_POKEMON_FOLLOWUP_IDENTITY
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BASE_DAMAGE、ATK_F、SPI_F、ELEMENT_SYMBOL_TO_ID、ROLE_EFFECTS、TYPE_FALLBACK。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_PokemonFollowupIdentity；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_PokemonFollowupIdentity v1.0
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2 / Ruby 1.8
#
# 【用途】
# 喬伊觸發的 Pokémon 追擊統一改為：
#   1. 使用追擊者自己的主屬性。
#   2. 傷害係數固定為 ATK 50% + SPI 50%。
#   3. 依 ALBERT_ACTOR_PROFILE 的 Role 附加一項特色。
#   4. 狀態效果走既有 <state_chance>、CSP 疊層、動態抗性與 HUD 管線。
#
# 【放置位置】
#   ActorProfile
#   SummonChain3
#   FS_MarkedCommand_ConditionTransparency
#   ↓
#   FS_PokemonFollowupIdentity v1.0
#   ↓
#   Main
#
# 不修改 $data_skills；每次追擊只建立暫時 Skill 副本，執行後自然釋放。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_PokemonFollowupIdentity"] = "1.0"

module FS_POKEMON_FOLLOWUP_IDENTITY
  VERSION = "1.0"

  BASE_DAMAGE = 120
  ATK_F = 50
  SPI_F = 50

  ELEMENT_SYMBOL_TO_ID = {
    :normal   => 4,
    :fighting => 5,
    :flying   => 6,
    :poison   => 7,
    :ground   => 8,
    :rock     => 9,
    :bug      => 10,
    :ghost    => 11,
    :steel    => 12,
    :fire     => 13,
    :water    => 14,
    :grass    => 15,
    :electric => 16,
    :psychic  => 17,
    :ice      => 18,
    :dragon   => 19,
    :dark     => 20,
    :fairy    => 21
  }

  # 越前面的 Role 優先。一次追擊只採用一項特色。
  ROLE_EFFECTS = [
    ["poison_starter",   {:type=>:state, :state=>31, :chance=>40}],
    ["poison_spreader",  {:type=>:state, :state=>31, :chance=>40}],
    ["parasite_starter", {:type=>:state, :state=>35, :chance=>25}],
    ["burn_starter",     {:type=>:state, :state=>34, :chance=>35}],
    ["burn_finisher",    {:type=>:state, :state=>34, :chance=>35}],
    ["wet_starter",      {:type=>:state, :state=>32, :chance=>55}],
    ["wet_finisher",     {:type=>:state, :state=>32, :chance=>55}],
    ["paralysis_engine", {:type=>:state, :state=>33, :chance=>25}],
    ["wet_paralysis",    {:type=>:state, :state=>33, :chance=>25}],
    ["sleep_controller", {:type=>:state, :state=>46, :chance=>18}],
    ["freeze_controller",{:type=>:state, :state=>47, :chance=>15}],
    ["root_controller",  {:type=>:state, :state=>44, :chance=>25}],
    ["corrosion_engine", {:type=>:state, :state=>37, :chance=>35}],
    ["fragile_engine",   {:type=>:state, :state=>39, :chance=>30}],
    ["state_controller", {:type=>:state, :state=>38, :chance=>30}],
    ["heavy_breaker",    {:type=>:break, :power=>2}],
    ["fast_breaker",     {:type=>:break, :power=>1}],
    ["ground_finisher",  {:type=>:break, :power=>1}],
    ["breaker",          {:type=>:break, :power=>1}],
    ["atb_controller",   {:type=>:atb, :percent=>-8}],
    ["resonance_fast",   {:type=>:atb, :percent=>-5}],
    ["crit_hunter",      {:type=>:crit, :rate=>15}],
    ["low_hp_finisher",  {:type=>:finisher, :hp=>30, :rate=>125}],
    ["legendary_finisher",{:type=>:finisher, :hp=>50, :rate=>120}],
    ["finisher",         {:type=>:finisher, :hp=>35, :rate=>115}],
    ["mana_support",     {:type=>:mana_support, :percent=>4}],
    ["healer",           {:type=>:heal_support, :percent=>5}],
    ["shield_support",   {:type=>:self_recover, :percent=>4}],
    ["protector",        {:type=>:self_recover, :percent=>4}],
    ["tank",             {:type=>:self_recover, :percent=>4}]
  ]

  # 沒有可辨識 Role 時，使用副屬性優先、主屬性備援。
  TYPE_FALLBACK = {
    :poison   => {:type=>:state, :state=>31, :chance=>30},
    :fire     => {:type=>:state, :state=>34, :chance=>30},
    :water    => {:type=>:state, :state=>32, :chance=>40},
    :electric => {:type=>:state, :state=>33, :chance=>20},
    :ice      => {:type=>:state, :state=>47, :chance=>12},
    :grass    => {:type=>:state, :state=>44, :chance=>20},
    :ghost    => {:type=>:state, :state=>39, :chance=>20},
    :dark     => {:type=>:state, :state=>39, :chance=>20},
    :ground   => {:type=>:break, :power=>1},
    :rock     => {:type=>:break, :power=>1},
    :steel    => {:type=>:break, :power=>1},
    :fighting => {:type=>:break, :power=>1},
    :psychic  => {:type=>:atb, :percent=>-5},
    :fairy    => {:type=>:heal_support, :percent=>3},
    :flying   => {:type=>:crit, :rate=>8},
    :normal   => {:type=>:crit, :rate=>8},
    :dragon   => {:type=>:finisher, :hp=>35, :rate=>110}
  }

  def self.pokemon?(battler)
    return false if battler == nil
    return battler.albert_pokemon? if battler.respond_to?(:albert_pokemon?)
    return false
  end

  def self.roles(battler)
    return [] if battler == nil
    if battler.respond_to?(:albert_mx_summon_roles)
      return battler.albert_mx_summon_roles.collect {|r| r.to_s.downcase}
    end
    return []
  end

  def self.primary_element(battler)
    return :normal if battler == nil
    if battler.respond_to?(:primary_element)
      value = battler.primary_element
      return value.to_sym if value != nil
    end
    return :normal
  end

  def self.secondary_element(battler)
    return nil if battler == nil
    if battler.respond_to?(:secondary_element)
      value = battler.secondary_element
      return value.to_sym if value != nil
    end
    return nil
  end

  def self.effect_for(battler)
    list = roles(battler)
    for pair in ROLE_EFFECTS
      return pair[1].dup if list.include?(pair[0])
    end
    secondary = secondary_element(battler)
    return TYPE_FALLBACK[secondary].dup if secondary != nil &&
      TYPE_FALLBACK.has_key?(secondary)
    primary = primary_element(battler)
    return TYPE_FALLBACK[primary].dup if TYPE_FALLBACK.has_key?(primary)
    return nil
  end

  def self.note_for_effect(effect)
    return "" if effect == nil
    case effect[:type]
    when :state
      return sprintf("\n<state_chance %d:%d>", effect[:state], effect[:chance])
    when :break
      return sprintf("\n<break_power:%d>\n<break_state:50>\n<broken_state:51>",
        effect[:power])
    when :atb
      return sprintf("\n<atb_shift:%d>", effect[:percent])
    when :crit
      return sprintf("\n<crit_rate:%d>", effect[:rate])
    end
    return ""
  end

  def self.damage_rate(target, effect)
    return 100 if target == nil || effect == nil
    return 100 unless effect[:type] == :finisher
    return 100 if target.maxhp.to_i <= 0
    hp_rate = target.hp.to_f * 100.0 / target.maxhp.to_f
    return effect[:rate].to_i if hp_rate <= effect[:hp].to_i
    return 100
  end

  def self.build_skill(original, summon, target, include_effect)
    skill = original.dup
    rate = damage_rate(target, effect_for(summon))
    skill.base_damage = BASE_DAMAGE * rate / 100
    skill.atk_f = ATK_F * rate / 100
    skill.spi_f = SPI_F * rate / 100
    element_id = ELEMENT_SYMBOL_TO_ID[primary_element(summon)]
    skill.element_set = element_id == nil ? [] : [element_id]
    if include_effect
      skill.note = original.note.to_s + note_for_effect(effect_for(summon))
    else
      skill.note = original.note.to_s
    end
    return skill
  end

  def self.lowest_hp_ally(user)
    return nil if user == nil
    unit = user.actor? ? $game_party : $game_troop
    list = unit.existing_members.compact
    return nil if list.empty?
    return list.sort_by {|b| b.hp.to_f / [b.maxhp, 1].max}[0]
  end

  def self.lowest_mp_ally(user)
    return nil if user == nil
    unit = user.actor? ? $game_party : $game_troop
    list = unit.existing_members.compact
    list = list.select {|b| b.maxmp.to_i > 0}
    return nil if list.empty?
    return list.sort_by {|b| b.mp.to_f / [b.maxmp, 1].max}[0]
  end

  def self.apply_support(user, effect)
    return if user == nil || effect == nil
    case effect[:type]
    when :heal_support
      target = lowest_hp_ally(user)
      return if target == nil
      value = (target.maxhp.to_i * effect[:percent].to_i / 100.0).round
      target.hp += [value, 1].max
    when :mana_support
      target = lowest_mp_ally(user)
      return if target == nil
      value = (target.maxmp.to_i * effect[:percent].to_i / 100.0).round
      target.mp += [value, 1].max
    when :self_recover
      value = (user.maxhp.to_i * effect[:percent].to_i / 100.0).round
      user.hp += [value, 1].max
    end
  end
end

#==============================================================================
# ■ Scene_Battle：建立 Pokémon 追擊 Context
#==============================================================================
class Scene_Battle < Scene_Base
  if method_defined?(:albert_cc_execute_summon_followup) &&
     !method_defined?(:fs_pfi_old_execute_summon_followup)

    alias fs_pfi_old_execute_summon_followup albert_cc_execute_summon_followup

    def albert_cc_execute_summon_followup(summon, follow_skill, targets)
      unless FS_POKEMON_FOLLOWUP_IDENTITY.pokemon?(summon) &&
             follow_skill != nil && follow_skill.for_opponent?
        return fs_pfi_old_execute_summon_followup(summon, follow_skill, targets)
      end

      old_context = summon.instance_variable_get(:@fs_pfi_context)
      context = {
        :skill_id => follow_skill.id,
        :effect_targets => {},
        :support_done => false
      }
      summon.instance_variable_set(:@fs_pfi_context, context)

      begin
        return fs_pfi_old_execute_summon_followup(summon, follow_skill, targets)
      ensure
        summon.instance_variable_set(:@fs_pfi_context, old_context)
      end
    end
  end
end

#==============================================================================
# ■ Game_Battler：把暫時追擊 Skill 送入既有完整效果鏈
#==============================================================================
class Game_Battler
  if method_defined?(:skill_effect) &&
     !method_defined?(:fs_pfi_old_skill_effect)

    alias fs_pfi_old_skill_effect skill_effect

    def skill_effect(user, skill)
      context = nil
      if user != nil
        context = user.instance_variable_get(:@fs_pfi_context)
      end

      unless context.is_a?(Hash) && skill != nil &&
             context[:skill_id].to_i == skill.id.to_i
        return fs_pfi_old_skill_effect(user, skill)
      end

      used = context[:effect_targets]
      used = {} unless used.is_a?(Hash)
      include_effect = !used[self.object_id]
      temp_skill = FS_POKEMON_FOLLOWUP_IDENTITY.build_skill(
        skill, user, self, include_effect
      )

      result = fs_pfi_old_skill_effect(user, temp_skill)

      success = !@missed && !@evaded && !@skipped
      if success && include_effect
        used[self.object_id] = true
        context[:effect_targets] = used
      end

      if success && !context[:support_done]
        effect = FS_POKEMON_FOLLOWUP_IDENTITY.effect_for(user)
        if effect != nil &&
           [:heal_support, :mana_support, :self_recover].include?(effect[:type])
          FS_POKEMON_FOLLOWUP_IDENTITY.apply_support(user, effect)
          context[:support_done] = true
        end
      end

      return result
    end
  end
end

#==============================================================================
# END
#==============================================================================
