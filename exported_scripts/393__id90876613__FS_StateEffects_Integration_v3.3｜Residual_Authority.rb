#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_StateEffects_Integration v3.3｜Residual Authority
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_StateEffects_Integration v3.3｜Residual Authority」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Battler、Game_Actor、Scene_Battle、Game_Enemy、RPG::State、Game_Interpreter、ALBERT_STATE_EFFECTS_V2
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PROTECT_STATE_ID、LEECH_SEED_DIVISOR、LEECH_SEED_MIN_DAMAGE、LEECH_SEED_STATE_ID、KEEP_TANKENTAI_VARIANCE、REQUIRE_SLIP_CHECKBOX、CSP_SLIP_TAG、STATE_PERCENT_DELTA_TAG。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 17 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertStateEffectsIntegration、AlbertStateEffectsIntegrationVersion；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# 【Phase 25】Protect 與 <state_chance> 原雙層 skill_effect 已收斂成單一 wrapper，順序與 context 還原規則維持不變。
#==============================================================================
#==============================================================================

# Albert_StateEffects_Integration_v3_2.rb

# RPG Maker VX / RGSS2

#------------------------------------------------------------------------------

# 放置位置：所有 Sideview / ATB / YEZ CSP / YEM Equipment Overhaul / 

# BattleUtility_IntegrationFix / BattleFormula / State 補丁之下，Main 之上。

#

# 本補丁整合：

#  1. Tankentai ATB 的 <slip: ...> 依 CSP State Stack 倍增。

#  2. Tankentai ATB 也會執行 CSP 的 CLOSE effect。

#  3. 寄生種子改為參考 Pokémon：每次結算吸取目標 MaxHP 的 1/8，

#     可致死，施術者回復實際吸取量。

#  4. State 72 實裝「守住」：阻擋敵方普通攻擊、技能、物品的效果。

#  5. 補回 YEM Equipment Overhaul 覆蓋掉的 Actor State HIT/EVA/CRI/ODDS。

#  6. 額外支援 State Note 的「增減百分點」語法：

#       <atk -4%> <def -8%> <spi +20%> <agi -15%>

#     這是增減百分點，不是把能力直接設為該百分比。

#  7. 修正 <state_chance ID:X>：可自行宣告要附加的 State，

#     X 作為基礎成功率，不再要求資料庫先勾選該 State。

#  8. v2.9修正AutoSetup覆寫State Note後，YEZ CSP快取沒有失效：

#     @max_stack、疊層能力、Slip、Lunatic Effect會依最新Note重建。

#  9. AutoSetup完成後同步清除BattleStateHUD的State Note快取。

# 10. v3.0恢復Forest Symphony能力狀態的正式規則：
#     State 54～61重複施加時，只增加剩餘回合，不提高能力倍率。
#     例如剩3回合再次施加Hold Turn 4，變成7回合。
#     其他State仍遵守YEZ::STATE::REMAINED_RULES。
# 11. v3.2明確攔截事件指令command_313／command_333：
#     原事件執行前保存回合，執行後增加hold_turn。
# 12. 其他腳本直接add_state仍有備援，並用Guard避免重複累加。
#

# 13. Phase 27：正式成為 Residual Authority；hp/mp slip、regen/degen、寄生種子數值與 popup 以本頁為準。
#     舊 BattleUtility 10%/999 cap 寄生公式已退休，避免兩份規則並存。
#

# 注意：

#  - 核心 State 建議仍使用資料庫的 ATK/DEF/SPI/AGI 變化率，最穩定。

#  - 同一效果不要同時寫在資料庫與 Note，否則會重複計算。

#==============================================================================



$imported = {} if $imported == nil

$imported["AlbertStateEffectsIntegration"] = true

$imported["AlbertStateEffectsIntegrationVersion"] = "3.3"



module ALBERT_STATE_EFFECTS_V2

  RESIDUAL_AUTHORITY_VERSION = "3.3"

  PROTECT_STATE_ID = 72

  LEECH_SEED_DIVISOR = 8        # MaxHP / 8 = 12.5%

  LEECH_SEED_MIN_DAMAGE = 1
  LEECH_SEED_STATE_ID = 35

  KEEP_TANKENTAI_VARIANCE = false



  # true 時，資料庫必須勾「連續傷害」才處理 Note。

  # false 時，只要 Note 有 slip / degen / regen 就會處理。

  REQUIRE_SLIP_CHECKBOX = false



  CSP_SLIP_TAG = /<\s*(HP|MP)\s+(DEGEN|REGEN)\s+([-+]?\d+(?:\.\d+)?)\s*([%％])?\s*>/i

  STATE_PERCENT_DELTA_TAG = /<\s*(ATK|DEF|SPI|AGI)\s*([+-]\d+(?:\.\d+)?)\s*[%％]\s*>/i

  STATE_FLAT_DELTA_TAG = /<\s*(HIT|EVA|CRI|ODDS)\s*([+-]\d+(?:\.\d+)?)\s*>/i



  def self.stack_count(battler, state)

    return 1 if battler == nil || state == nil

    return 1 unless battler.respond_to?(:stack)

    begin

      value = battler.stack(state).to_i

      return value < 1 ? 1 : value

    rescue

      return 1

    end

  end



  def self.state_has_slip_note?(state, type = nil)

    return false if state == nil

    text = state.respond_to?(:note) ? state.note.to_s : ""

    if type == nil

      return true if text =~ /<\s*slip\s*:/i

      return true if text =~ CSP_SLIP_TAG

    else

      return true if text =~ /<\s*slip\s*:\s*#{type}\s*,/i

      text.scan(CSP_SLIP_TAG) do |data|

        return true if data[0].to_s.downcase == type.to_s.downcase

      end

    end

    return false

  end



  # 回傳 [found, value_per_stack, popup, can_kill]

  def self.tankentai_value(state, type, max_value)

    return [false, 0.0, true, true] if state == nil

    return [false, 0.0, true, true] unless state.respond_to?(:slip_extension)

    list = nil

    begin

      list = state.slip_extension

    rescue

      list = nil

    end

    return [false, 0.0, true, true] if list == nil



    found = false

    value = 0.0

    popup = true

    can_kill = true

    for ext in list

      next if ext == nil || ext.size < 3

      next unless ext[0].to_s.downcase == type.to_s.downcase

      found = true

      value += ext[1].to_f + max_value.to_f * ext[2].to_f / 100.0

      popup = ext[3] unless ext[3] == nil

      can_kill = ext[4] unless ext[4] == nil

    end

    return [found, value, popup, can_kill]

  end



  # 正值為損失，負值為回復。

  def self.csp_value(state, type, max_value)

    return 0.0 if state == nil || !state.respond_to?(:note)

    total = 0.0

    state.note.to_s.scan(CSP_SLIP_TAG) do |data|

      next unless data[0].to_s.downcase == type.to_s.downcase

      number = data[2].to_f

      amount = data[3] == nil ? number : max_value.to_f * number / 100.0

      total += data[1].to_s.upcase == "DEGEN" ? amount : -amount

    end

    return total

  end



  # Tankentai <slip> 優先，避免同一 State 兩套 Note 重複計算。

  def self.state_slip_value(battler, state, type, max_value)

    stack = stack_count(battler, state)

    tank = tankentai_value(state, type, max_value)

    if tank[0]

      return [tank[1] * stack, tank[2], tank[3], :tankentai]

    end

    value = csp_value(state, type, max_value) * stack

    can_kill = type.to_s.downcase == "hp" ? false : true

    return [value, true, can_kill, :csp]

  end



  def self.apply_variance(value)

    return value unless KEEP_TANKENTAI_VARIANCE

    return value + value * (rand(5) - rand(5)) / 100.0

  end



  def self.round_nonzero(value)

    n = value.round

    if n == 0 && value != 0.0

      n = value > 0 ? 1 : -1

    end

    return n

  end



  def self.percent_delta(state, key)

    return 0.0 if state == nil || !state.respond_to?(:note)

    total = 0.0

    state.note.to_s.scan(STATE_PERCENT_DELTA_TAG) do |data|

      total += data[1].to_f if data[0].to_s.upcase == key.to_s.upcase

    end

    return total

  end



  def self.flat_delta(state, key)

    return 0.0 if state == nil || !state.respond_to?(:note)

    total = 0.0

    state.note.to_s.scan(STATE_FLAT_DELTA_TAG) do |data|

      total += data[1].to_f if data[0].to_s.upcase == key.to_s.upcase

    end

    return total

  end

end



#==============================================================================

# ■ Game_Battler

#==============================================================================

class Game_Battler

  #--------------------------------------------------------------------------

  # State 72：守住

  #--------------------------------------------------------------------------

  def albert_protecting?

    return state?(ALBERT_STATE_EFFECTS_V2::PROTECT_STATE_ID)

  end



  def albert_protect_blocks?(user)

    return false unless albert_protecting?

    return false if user == nil

    return false if user == self

    return false unless user.respond_to?(:actor?) && respond_to?(:actor?)

    return user.actor? != actor?

  end



  if method_defined?(:attack_effect) && !method_defined?(:albert_sev2_attack_effect)

    alias albert_sev2_attack_effect attack_effect

    def attack_effect(attacker)

      if albert_protect_blocks?(attacker)

        clear_action_results

        @skipped = true

        return

      end

      albert_sev2_attack_effect(attacker)

    end

  end



  if method_defined?(:skill_effect) && !method_defined?(:albert_sev2_skill_effect)
    alias albert_sev2_skill_effect skill_effect

    # Phase 25：Protect + <state_chance> 單一 wrapper。
    # 保留舊順序：先準備 state_chance context，再判定 Protect，再呼叫原效果，最後記錄 Note origin。
    def skill_effect(user, skill)
      chances = ALBERT_STATE_CHANCE_V27.base_chances(skill)
      if chances.empty?
        if albert_protect_blocks?(user)
          clear_action_results
          @skipped = true
          return
        end
        return albert_sev2_skill_effect(user, skill)
      end

      original_plus_states = skill.plus_state_set.clone
      @albert_sev27_state_chances = chances
      @albert_sev27_state_user = user
      @albert_sev27_state_obj = skill
      skill.plus_state_set.replace((original_plus_states + chances.keys).uniq)
      result = nil
      begin
        if albert_protect_blocks?(user)
          clear_action_results
          @skipped = true
          result = nil
        else
          result = albert_sev2_skill_effect(user, skill)
        end
        albert_sev28_record_note_origins(chances, user)
      ensure
        skill.plus_state_set.replace(original_plus_states)
        @albert_sev27_state_chances = nil
        @albert_sev27_state_user = nil
        @albert_sev27_state_obj = nil
      end
      return result
    end
  end



  if method_defined?(:item_effect) && !method_defined?(:albert_sev2_item_effect)

    alias albert_sev2_item_effect item_effect

    def item_effect(user, item)

      if albert_protect_blocks?(user)

        clear_action_results

        @skipped = true

        return

      end

      albert_sev2_item_effect(user, item)

    end

  end



  #--------------------------------------------------------------------------

  # Signed percentage State Note：<atk -4%> 等。

  #--------------------------------------------------------------------------

  [:atk, :def, :spi, :agi].each do |param|

    old_name = "albert_sev2_#{param}".to_sym

    next if method_defined?(old_name)

    alias_method old_name, param

    define_method(param) do

      base = send(old_name)

      delta = 0.0

      for state in states

        next if state == nil

        delta += ALBERT_STATE_EFFECTS_V2.percent_delta(state, param) *

                 ALBERT_STATE_EFFECTS_V2.stack_count(self, state)

      end

      value = base.to_f * (100.0 + delta) / 100.0

      value = 1 if value < 1

      return value.to_i

    end

  end



end



#==============================================================================

# ■ Cover v2.1 相容修正

#------------------------------------------------------------------------------

# Lusitano Cover 會直接比較 @cover_type > 3。

# 舊存檔、戰鬥測試中先建立的 Battler，或曾被其他 setup 重建的 Actor，

# 可能沒有 Cover 新增的實例變數，使魔法技能在判斷時對 nil 執行 >。

# 這裡採取惰性補值，並把 HP/MP damage 保證為數字。

#==============================================================================

class Game_Battler

  def albert_sev21_prepare_cover_runtime

    @covered = false if @covered == nil

    @protector = 0 if @protector == nil

    @protector_spr_id = 0 if @protector_spr_id == nil

    @cover_type = 0 if @cover_type == nil

    @cover_param = 0 if @cover_param == nil

    @is_covering = false if @is_covering == nil

    @hp_damage = 0 if @hp_damage == nil

    @mp_damage = 0 if @mp_damage == nil

  end



  if method_defined?(:make_obj_damage_value) &&

     !method_defined?(:albert_sev21_cover_make_obj_damage_value)

    alias albert_sev21_cover_make_obj_damage_value make_obj_damage_value

    def make_obj_damage_value(user, obj)

      albert_sev21_prepare_cover_runtime

      albert_sev21_cover_make_obj_damage_value(user, obj)

      @hp_damage = 0 if @hp_damage == nil

      @mp_damage = 0 if @mp_damage == nil

    end

  end



  if method_defined?(:make_attack_damage_value) &&

     !method_defined?(:albert_sev21_cover_make_attack_damage_value)

    alias albert_sev21_cover_make_attack_damage_value make_attack_damage_value

    def make_attack_damage_value(attacker)

      albert_sev21_prepare_cover_runtime

      albert_sev21_cover_make_attack_damage_value(attacker)

      @hp_damage = 0 if @hp_damage == nil

      @mp_damage = 0 if @mp_damage == nil

    end

  end



  if method_defined?(:can_be_Covered) &&

     !method_defined?(:albert_sev21_cover_can_be_covered)

    alias albert_sev21_cover_can_be_covered can_be_Covered

    def can_be_Covered

      albert_sev21_prepare_cover_runtime

      return false unless @covered == true

      return false if @protector.to_i <= 0

      protector = nil

      begin

        protector = $game_actors[@protector.to_i]

      rescue

        protector = nil

      end

      return false if protector == nil

      return albert_sev21_cover_can_be_covered

    end

  end

end



#==============================================================================

# ■ Game_Actor

# YEM Equipment Overhaul 在 CSP 後重寫 hit/eva/cri/odds，這裡補回 State。

#==============================================================================

class Game_Actor < Game_Battler

  [:hit, :eva, :cri, :odds].each do |param|

    old_name = "albert_sev2_actor_#{param}".to_sym

    next unless method_defined?(param)

    next if method_defined?(old_name)

    alias_method old_name, param

    define_method(param) do

      value = send(old_name).to_f

      for state in states

        next if state == nil

        value += ALBERT_STATE_EFFECTS_V2.flat_delta(state, param) *

                 ALBERT_STATE_EFFECTS_V2.stack_count(self, state)

      end

      value = 0 if value < 0

      return value.to_i

    end

  end

end



#==============================================================================

# ■ Scene_Battle

#==============================================================================

class Scene_Battle < Scene_Base

  # 執行 CSP CLOSE effect。必須使用 clone，避免 effect 移除 State 時改動陣列。

  def albert_sev2_run_close_effects(member)

    return if member == nil

    return unless member.respond_to?(:custom_status_effects)

    list = member.states.clone

    for state in list

      next if state == nil

      member.custom_status_effects(state, "CLOSE")

    end

  end



  if method_defined?(:hp_slip_damage)

    def hp_slip_damage(member)

      member.clear_action_results

      return unless member.exist?



      member.slip_damage = false

      total = 0.0

      popup = true

      can_kill = true

      found = false



      for state in member.states.clone

        next if state == nil

        if state.respond_to?(:extension) && state.extension.include?("ZEROTURNLIFT")

          member.remove_state(state.id)

          next

        end



        has_note = ALBERT_STATE_EFFECTS_V2.state_has_slip_note?(state, "hp")

        if ALBERT_STATE_EFFECTS_V2::REQUIRE_SLIP_CHECKBOX

          next unless state.slip_damage

        else

          next unless state.slip_damage || has_note

        end



        data = ALBERT_STATE_EFFECTS_V2.state_slip_value(member, state, "hp", member.maxhp)

        value = data[0]

        next if value == 0.0

        value = ALBERT_STATE_EFFECTS_V2.apply_variance(value) if data[3] == :tankentai



        # 回復不能阻擋負值（regen）。

        if value < 0 && member.respond_to?(:albert_hp_heal_blocked?)

          next if member.albert_hp_heal_blocked?

        end



        total += value

        popup = data[1]

        can_kill = false unless data[2]

        found = true

        member.slip_damage = true if value > 0

      end



      if member.actor? && member.auto_hp_recover && member.exist?

        blocked = member.respond_to?(:albert_hp_heal_blocked?) && member.albert_hp_heal_blocked?

        unless blocked

          total -= member.maxhp / 20.0

          popup = true

          found = true

        end

      end



      damage = ALBERT_STATE_EFFECTS_V2.round_nonzero(total)

      damage = member.hp - 1 if damage >= member.hp && !can_kill

      member.hp -= damage



      if found && popup && @spriteset != nil

        @spriteset.set_damage_pop(member.actor?, member.index, damage)

      end

      member.perform_collapse if member.dead? && member.slip_damage



      # Tankentai ATB 原本不會呼叫 Game_Battler#slip_damage_effect，

      # 因此寄生種子等 CLOSE effect 必須在這裡執行。

      albert_sev2_run_close_effects(member)



      member.clear_action_results

      @status_window.refresh if @status_window != nil

    end

  end



  if method_defined?(:mp_slip_damage)

    def mp_slip_damage(member)

      member.clear_action_results

      return unless member.exist?



      total = 0.0

      popup = true

      found = false



      for state in member.states.clone

        next if state == nil

        has_note = ALBERT_STATE_EFFECTS_V2.state_has_slip_note?(state, "mp")

        if ALBERT_STATE_EFFECTS_V2::REQUIRE_SLIP_CHECKBOX

          next unless state.slip_damage

        else

          next unless state.slip_damage || has_note

        end



        data = ALBERT_STATE_EFFECTS_V2.state_slip_value(member, state, "mp", member.maxmp)

        value = data[0]

        next if value == 0.0

        value = ALBERT_STATE_EFFECTS_V2.apply_variance(value) if data[3] == :tankentai



        if value < 0 && member.respond_to?(:albert_mp_heal_blocked?)

          next if member.albert_mp_heal_blocked?

        end



        total += value

        popup = data[1]

        found = true

      end



      damage = ALBERT_STATE_EFFECTS_V2.round_nonzero(total)

      member.mp_damage = damage if member.respond_to?(:mp_damage=)

      member.mp -= damage



      if found && popup && @spriteset != nil

        @spriteset.set_damage_pop(member.actor?, member.index, damage)

      end

      member.clear_action_results

      @status_window.refresh if @status_window != nil

    end

  end

end







#==============================================================================

# ■ v2.6：寄生種子紅／綠 POP 共用路徑

#------------------------------------------------------------------------------

# 舊 BattleUtility_IntegrationFix 的 albert_csp_popup_damage / recovery

# 分別自行尋找 Actor / Enemy Sprite，且以空白 rescue 吞掉錯誤。

# 本版統一改用 Scene_Battle 的 @spriteset.set_damage_pop：

#   正數 = HP 損傷紅字

#   負數 = HP 回復綠字

# Actor 與 Enemy 都走完全相同的入口。

#==============================================================================

class Scene_Battle < Scene_Base

  def albert_sev26_set_damage_pop(battler, value)

    return if battler == nil

    return if @spriteset == nil

    @spriteset.set_damage_pop(battler.actor?, battler.index, value.to_i)

  end

end



class Game_Battler

  # 統一 POP。顯示時暫時清除 MP / 雙重傷害旗標，確保使用 HP 圖案。

  def albert_sev26_popup_hp(value)

    number = value.to_i

    return if number == 0

    return unless $scene.is_a?(Scene_Battle)

    return unless $scene.respond_to?(:albert_sev26_set_damage_pop)



    old_mp_damage = respond_to?(:mp_damage) ? mp_damage : nil

    old_double_damage = respond_to?(:double_damage) ? double_damage : nil

    has_mp_writer = respond_to?(:mp_damage=)

    has_double_writer = respond_to?(:double_damage=)



    self.mp_damage = 0 if has_mp_writer

    self.double_damage = false if has_double_writer

    $scene.albert_sev26_set_damage_pop(self, number)

  ensure

    self.mp_damage = old_mp_damage if has_mp_writer

    self.double_damage = old_double_damage if has_double_writer

  end



  # 覆蓋舊版 helper，避免敵方 Sprite 尋找失敗後被 rescue 靜默吞掉。

  def albert_csp_popup_damage(value)

    amount = value.to_i.abs

    return if amount <= 0

    albert_sev26_popup_hp(amount)

  end



  def albert_csp_popup_recovery(value)

    amount = value.to_i.abs

    return if amount <= 0

    albert_sev26_popup_hp(-amount)

  end



  # 寄生種子：目標顯示紅字，來源顯示實際回復量的綠字。

  def albert_csp_leech_seed(effect_state)

    return if effect_state == nil

    return if dead?



    origin = nil

    begin

      origin = state_origin(effect_state) if respond_to?(:state_origin)

    rescue

      origin = nil

    end

    origin = nil if origin == self



    amount = maxhp.to_i / ALBERT_STATE_EFFECTS_V2::LEECH_SEED_DIVISOR

    minimum = ALBERT_STATE_EFFECTS_V2::LEECH_SEED_MIN_DAMAGE

    amount = minimum if amount < minimum

    amount = hp if amount > hp

    return if amount <= 0



    self.hp -= amount

    albert_csp_popup_damage(amount)



    can_heal = origin != nil && !origin.dead?

    if can_heal && origin.respond_to?(:albert_hp_heal_blocked?)

      can_heal = false if origin.albert_hp_heal_blocked?

    end



    if can_heal

      before_hp = origin.hp

      origin.hp += amount

      healed = origin.hp - before_hp

      origin.albert_csp_popup_recovery(healed) if healed > 0

    end



    perform_collapse if dead? && respond_to?(:perform_collapse)

  end

end


#==============================================================================
# ■ v2.8：明確保存Note狀態的施術者
#------------------------------------------------------------------------------
# YEZ CSP原本依 $scene.active_battler 建立State origin。
# 開場強制技能執行時，active_battler不一定可靠，因此寄生狀態可能把
# 目標自己當成來源。這裡在技能成功處理後，直接用skill_effect收到的user
# 寫回CSP既有的 @state_origin / @origin_side。
#==============================================================================
class Game_Battler

  def albert_sev28_record_state_origin(state_id, user)
    return if user == nil
    return unless user.respond_to?(:actor?)

    @state_origin = {} if @state_origin == nil
    @origin_side = {} if @origin_side == nil

    if user.actor?
      return unless user.respond_to?(:id)
      @state_origin[state_id] = user.id
      @origin_side[state_id] = 0
    else
      return unless user.respond_to?(:index)
      @state_origin[state_id] = user.index
      @origin_side[state_id] = 1
    end
  end

  def albert_sev28_record_note_origins(chances, user)
    return if chances == nil || chances.empty?
    return if @skipped || @missed || @evaded

    for state_id in chances.keys
      next unless state?(state_id)
      albert_sev28_record_state_origin(state_id, user)
    end
  end
end

#==============================================================================

# ■ v2.8：Skill Note 狀態成功率橋接

#------------------------------------------------------------------------------

# 修正原本 <state_chance ID:X> 的兩個結構性問題：

#

#  1. VX / YEZ CSP 只會處理 obj.plus_state_set 內的 State。

#     因此資料庫未勾選 State 時，Note 寫了成功率也完全不會進入判定。

#

#  2. 原 ComboCore 把 <state_chance 34:18> 當成「目標原始成功率 +18」。

#     若目標對該 State 的有效度為 100%，結果會被夾到 100%，看起來必定命中。

#

# v2.7 統一規則：

#

#   <state_chance 34:18>

#     = 此技能會嘗試附加 State 34，基礎成功率 18%。

#

#   最終成功率 = (基礎成功率 + 條件加成) × 目標 State 有效率

#

# 例：基礎 18%，目標有效率 80% → 最終 14.4%。

#

# 使用方式：

#  - 使用 Note 控制的 State，資料庫「附加狀態」可不勾選。

#  - 即使資料庫已勾選，也只判定一次，且仍以 Note 的機率為準。

#  - 已存在的堆疊 State 再次附加時，也會重新擲成功率，不再必定疊層。

#  - 技能 Miss / Evade 時不會附加。

#

# 條件加成仍支援：

#   <state_chance_vs_state 34,31:20>

#   <state_chance_if_user_state 34,40:20>

#   <state_chance_if_od 34,50:20>

#   <state_chance_per_od_percent 34:0.2>

#

# 額外提供：

#   <state_chance_bonus 34:10>

# 可放在裝備、使用者 State、Enemy Note，作為無條件 +10 個百分點。

#==============================================================================

module ALBERT_STATE_CHANCE_V27

  BASE_TAG = /<state_chance\s+(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i

  BONUS_TAG = /<state_chance_bonus\s+(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i

  VS_STATE_TAG = /<state_chance_vs_state\s+(\d+)\s*,\s*(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i

  USER_STATE_TAG = /<state_chance_if_user_state\s+(\d+)\s*,\s*(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i

  OD_THRESHOLD_TAG = /<state_chance_if_od\s+(\d+)\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i

  OD_PER_PERCENT_TAG = /<state_chance_per_od_percent\s+(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i



  def self.note(obj)

    return "" if obj == nil

    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil

    return ""

  end



  # Skill / Item 自己的 <state_chance> 才是「基礎成功率／宣告 State」。

  # 同一 State 重複寫時，採用最後一筆，避免意外累加成另一個數字。

  def self.base_chances(obj)

    result = {}

    note(obj).scan(BASE_TAG) do |data|

      result[data[0].to_i] = data[1].to_f

    end

    return result

  end



  def self.source_text(user, obj)

    if defined?(ALBERT_COMBO_CORE) &&

       ALBERT_COMBO_CORE.respond_to?(:source_text)

      return ALBERT_COMBO_CORE.source_text(user, obj).to_s

    end



    text = note(obj)

    return text if user == nil

    if user.respond_to?(:actor?) && user.actor?

      if user.respond_to?(:equips)

        for item in user.equips.compact

          text += note(item)

        end

      end

    elsif user.respond_to?(:enemy)

      text += note(user.enemy)

    end

    if user.respond_to?(:states)

      for state in user.states.compact

        text += note(state)

      end

    end

    return text

  end



  def self.od_rate(user)

    return 0.0 if user == nil

    if user.respond_to?(:albert_od_rate)

      return user.albert_od_rate.to_f

    end

    return 0.0

  end



  def self.conditional_bonus(target, user, obj, state_id)

    text = source_text(user, obj)

    bonus = 0.0



    text.scan(BONUS_TAG) do |data|

      bonus += data[1].to_f if data[0].to_i == state_id

    end



    text.scan(VS_STATE_TAG) do |data|

      apply_id = data[0].to_i

      condition_id = data[1].to_i

      value = data[2].to_f

      if apply_id == state_id && target != nil && target.state?(condition_id)

        bonus += value

      end

    end



    text.scan(USER_STATE_TAG) do |data|

      apply_id = data[0].to_i

      condition_id = data[1].to_i

      value = data[2].to_f

      if apply_id == state_id && user != nil && user.state?(condition_id)

        bonus += value

      end

    end



    if user != nil

      rate = od_rate(user)

      text.scan(OD_THRESHOLD_TAG) do |data|

        apply_id = data[0].to_i

        need_rate = data[1].to_f

        value = data[2].to_f

        bonus += value if apply_id == state_id && rate >= need_rate

      end



      text.scan(OD_PER_PERCENT_TAG) do |data|

        apply_id = data[0].to_i

        value = data[1].to_f

        bonus += rate * value if apply_id == state_id

      end

    end



    return bonus

  end



  # 取得「尚未被 ComboCore 的 <state_chance> 加成過」的目標 State 有效率。

  # 這兩個 alias 由目前專案的 ComboCore 建立，保留 KGC 裝備抗性、

  # State Option、Actor/Enemy Rank 等既有修正。

  def self.resistance(target, state_id)

    return 100.0 if target == nil



    if target.respond_to?(:actor?) && target.actor?

      if target.respond_to?(:albert_combo_old_actor_state_probability)

        return target.albert_combo_old_actor_state_probability(state_id).to_f

      end

    else

      if target.respond_to?(:albert_combo_old_enemy_state_probability)

        return target.albert_combo_old_enemy_state_probability(state_id).to_f

      end

    end



    # 理論上目前專案一定會走上面的 ComboCore alias。

    # 留 100% 防呆，避免因腳本刪除或改名直接報錯。

    return 100.0

  end



  def self.clamp(value, min_value, max_value)

    return [[value, min_value].max, max_value].min

  end



  def self.final_probability(target, user, obj, state_id, base_chance)

    chance = base_chance.to_f

    chance += conditional_bonus(target, user, obj, state_id)

    chance = clamp(chance, 0.0, 100.0)



    resist = resistance(target, state_id)

    resist = 0.0 if resist < 0.0

    result = chance * resist / 100.0

    # VX 使用 rand(100) 的整數擲骰；先四捨五入，避免 14.4 實際變成 15%。

    return clamp(result.round, 0, 100)

  end

end



#==============================================================================
# ■ FS Parameter State Duration Stack
#------------------------------------------------------------------------------
# State 54～61為固定倍率的能力上升／下降：
#   54 攻擊提升  +20%
#   55 防禦提升  +20%
#   56 精神提升  +20%
#   57 速度提升  +20%
#   58 攻擊降低  -20%
#   59 防禦降低  -20%
#   60 精神降低  -20%
#   61 速度降低  -20%
#
# 它們的max_stack維持1，所以能力倍率不會疊加。
# 同一State重複成功施加時，只將hold_turn加入目前剩餘回合。
#==============================================================================

module FS_PARAMETER_STATE_DURATION_STACK

  VERSION = "1.0"

  STATE_IDS = [54, 55, 56, 57, 58, 59, 60, 61]

  def self.include?(state_id)
    return STATE_IDS.include?(state_id.to_i)
  end

  def self.current_turns(battler, state_id)
    return 0 if battler == nil

    begin
      if battler.respond_to?(:state_turns)
        table = battler.state_turns
        if table.is_a?(Hash) || table.is_a?(Array)
          value = table[state_id.to_i]
          return value.to_i unless value == nil
        end
      end
    rescue
    end

    begin
      table = battler.instance_variable_get(:@state_turns)
      if table.is_a?(Hash) || table.is_a?(Array)
        value = table[state_id.to_i]
        return value.to_i unless value == nil
      end
    rescue
    end

    return 0
  end

  def self.set_turns(battler, state_id, turns)
    return false if battler == nil

    turns = [turns.to_i, 0].max

    begin
      if battler.respond_to?(:state_turns)
        table = battler.state_turns
        if table.is_a?(Hash) || table.is_a?(Array)
          table[state_id.to_i] = turns
          return true
        end
      end
    rescue
    end

    begin
      table = battler.instance_variable_get(:@state_turns)
      if table.is_a?(Hash) || table.is_a?(Array)
        table[state_id.to_i] = turns
        return true
      end
    rescue
    end

    return false
  end
end


#==============================================================================

# ■ Game_Battler：暫時把 Note State 加入候選清單

#==============================================================================

class Game_Battler

  def albert_sev27_state_chance_active?(state_id)

    return false if @albert_sev27_state_chances == nil

    return @albert_sev27_state_chances.has_key?(state_id)

  end



  def albert_sev27_state_probability(state_id)

    return nil unless albert_sev27_state_chance_active?(state_id)

    base = @albert_sev27_state_chances[state_id]

    return ALBERT_STATE_CHANCE_V27.final_probability(

      self,

      @albert_sev27_state_user,

      @albert_sev27_state_obj,

      state_id,

      base

    )

  end



  # CSP 對「已存在 State」原本不擲機率，直接 remained_rules → 疊層。

  # Note 控制的 State 在這裡補回一次成功率判定。

  if method_defined?(:remained_rules) &&

     !method_defined?(:albert_sev27_remained_rules)

    alias albert_sev27_remained_rules remained_rules

    def remained_rules(state_id, obj = nil)

      chance = albert_sev27_state_probability(state_id)

      if chance != nil

        return if rand(100) >= chance

      end

      if FS_PARAMETER_STATE_DURATION_STACK.include?(state_id)

        state = $data_states[state_id]

        before_turns =
          FS_PARAMETER_STATE_DURATION_STACK.current_turns(
            self, state_id)

        result =
          albert_sev27_remained_rules(state_id, obj)

        if state != nil && state?(state_id)

          added_turns = [state.hold_turn.to_i, 0].max

          FS_PARAMETER_STATE_DURATION_STACK.set_turns(
            self,
            state_id,
            before_turns + added_turns)

        end

        return result

      end

      return albert_sev27_remained_rules(state_id, obj)

    end

  end



  # Phase 25：Skill 的 state_chance 已整合至前方單一 skill_effect wrapper。



  # Item 也支援相同語法。雖然目前手冊主要用在 Skill，順手把門補完整，

  # 免得未來又為同一扇門鑿第二個洞。

  if method_defined?(:item_effect) &&

     !method_defined?(:albert_sev27_item_effect)

    alias albert_sev27_item_effect item_effect

    def item_effect(user, item)

      chances = ALBERT_STATE_CHANCE_V27.base_chances(item)

      return albert_sev27_item_effect(user, item) if chances.empty?



      original_plus_states = item.plus_state_set.clone

      @albert_sev27_state_chances = chances

      @albert_sev27_state_user = user

      @albert_sev27_state_obj = item

      item.plus_state_set.replace((original_plus_states + chances.keys).uniq)

      result = nil

      begin

        result = albert_sev27_item_effect(user, item)

        albert_sev28_record_note_origins(chances, user)

      ensure

        item.plus_state_set.replace(original_plus_states)

        @albert_sev27_state_chances = nil

        @albert_sev27_state_user = nil

        @albert_sev27_state_obj = nil

      end

      return result

    end

  end

end



#==============================================================================

# ■ Game_Actor / Game_Enemy：初次附加時使用 Note 的最終成功率

#==============================================================================

class Game_Actor < Game_Battler

  unless method_defined?(:albert_sev27_actor_state_probability)

    alias albert_sev27_actor_state_probability state_probability

  end



  def state_probability(state_id)

    chance = albert_sev27_state_probability(state_id)

    return chance if chance != nil

    return albert_sev27_actor_state_probability(state_id)

  end

end



class Game_Enemy < Game_Battler

  unless method_defined?(:albert_sev27_enemy_state_probability)

    alias albert_sev27_enemy_state_probability state_probability

  end



  def state_probability(state_id)

    chance = albert_sev27_state_probability(state_id)

    return chance if chance != nil

    return albert_sev27_enemy_state_probability(state_id)

  end

end
#==============================================================================
# ■ FS State Stack Cache Sync v1.1
#------------------------------------------------------------------------------
# 根因：
#   FS_DB_AUTOSET會在Scene_Title載入時以權威資料替換State Note，
#   但原invalidate_note_cache沒有清除YEZ CSP使用的：
#     @max_stack、@traits、@stat_set、@stat_per、
#     @slip_set、@slip_per、各種Lunatic Effect陣列。
#
#   若CSP在Note替換前曾解析過State，state.max_stack會永久保留舊值。
#   increase_stack又以state.max_stack作上限，結果不是HUD算錯而已，
#   而是實際疊層也會被鎖在1層。
#
# 修正：
#   1. AutoSetup每次替換State Note時，清除全部CSP快取。
#   2. AutoSetup全部完成後，重建所有State的CSP資料。
#   3. RPG::State#max_stack會偵測Note內容是否改變。
#   4. 同步清除BattleStateHUD的Note解析快取。
#==============================================================================

module FS_STATE_STACK_CACHE_SYNC

  VERSION = "1.1"

  MAX_STACK_TAG =
    /<\s*(?:MAX_STACK|max stack)\s*(\d+)\s*>/i

  CSP_CACHE_VARIABLES = [
    :@max_stack,
    :@traits,
    :@state_animation,
    :@stat_set,
    :@stat_per,
    :@slip_set,
    :@slip_per,
    :@apply_effect,
    :@erase_effect,
    :@leave_effect,
    :@react_effect,
    :@shock_effect,
    :@begin_effect,
    :@while_effect,
    :@close_effect
  ]

  def self.note_signature(state)
    return "" if state == nil
    return "" unless state.respond_to?(:note)
    return state.note.to_s
  rescue
    return ""
  end

  def self.note_max_stack(state)
    text = note_signature(state)
    return 1 unless text =~ MAX_STACK_TAG
    return [$1.to_i, 1].max
  rescue
    return 1
  end

  def self.invalidate_state_cache(state)
    return false if state == nil
    return false unless defined?(RPG::State)
    return false unless state.is_a?(RPG::State)

    for variable_name in CSP_CACHE_VARIABLES
      begin
        state.instance_variable_set(variable_name, nil)
      rescue
      end
    end

    begin
      state.instance_variable_set(
        :@fs_state_stack_cached_note, nil)
    rescue
    end

    return true
  end

  def self.rebuild_state_cache(state)
    return false unless invalidate_state_cache(state)

    if state.respond_to?(:yez_cache_state_csp)
      begin
        state.yez_cache_state_csp
      rescue
        return false
      end
    end

    begin
      state.instance_variable_set(
        :@fs_state_stack_cached_note,
        note_signature(state))
    rescue
    end

    return true
  end

  def self.rebuild_all_state_caches
    return false if $data_states == nil

    for state in $data_states
      next if state == nil
      rebuild_state_cache(state)
    end

    if defined?(AlbertBattleStateHUD) &&
       AlbertBattleStateHUD.respond_to?(:clear_cache)
      begin
        AlbertBattleStateHUD.clear_cache
      rescue
      end
    end

    return true
  end

  def self.runtime_stack(battler, state)
    return 0 if battler == nil || state == nil

    if battler.respond_to?(:stack)
      begin
        return battler.stack(state).to_i
      rescue
      end
      begin
        return battler.stack(state.id).to_i
      rescue
      end
    end

    begin
      table = battler.instance_variable_get(:@state_stack)
      if table.is_a?(Hash) && table.include?(state.id)
        return table[state.id].to_i
      end
    rescue
    end

    return battler.state?(state.id) ? 1 : 0
  rescue
    return 0
  end

  def self.report_battler(lines, battler, label)
    return if battler == nil

    lines.push("")
    lines.push("[#{label}] #{battler.name}")

    found = false
    for state in battler.states
      next if state == nil
      note_max = note_max_stack(state)
      next if note_max <= 1

      found = true
      lines.push(
        "State #{state.id} #{state.name} " +
        "stack=#{runtime_stack(battler, state)} " +
        "note_max=#{note_max} " +
        "runtime_max=#{state.max_stack} " +
        "icon=#{state.icon_index}")
    end

    lines.push("(沒有目前生效的可疊層State)") unless found
  end

  def self.write_report
    rebuild_all_state_caches

    lines = []
    lines.push("FS State Stack Cache Report v#{VERSION}")
    lines.push("=" * 72)
    lines.push("Database stackable states:")

    mismatch = []

    if $data_states != nil
      for state in $data_states
        next if state == nil
        note_max = note_max_stack(state)
        next if note_max <= 1

        runtime_max = state.max_stack.to_i
        hud_max = if defined?(AlbertBattleStateHUD) &&
                     AlbertBattleStateHUD.respond_to?(:state_max_stack)
                    AlbertBattleStateHUD.state_max_stack(state).to_i
                  else
                    -1
                  end

        status = note_max == runtime_max ? "OK" : "MISMATCH"
        mismatch.push(state.id) unless status == "OK"

        lines.push(
          "State #{state.id} #{state.name} | " +
          "note_max=#{note_max} runtime_max=#{runtime_max} " +
          "hud_max=#{hud_max} icon=#{state.icon_index} | #{status}")
      end
    end

    if $game_party != nil
      for actor in $game_party.members
        report_battler(lines, actor, "Actor")
      end
    end

    if $game_troop != nil
      for enemy in $game_troop.members
        report_battler(lines, enemy, "Enemy")
      end
    end

    lines.push("")
    lines.push(
      mismatch.empty? ?
      "RESULT: PASS" :
      "RESULT: FAIL states=#{mismatch.inspect}")

    File.open("FS_StateStack_Cache_Report.txt", "wb") do |file|
      file.write(lines.join("\r\n"))
    end

    return mismatch.empty?
  rescue
    return false
  end
end

#==============================================================================
# ■ RPG::State：Note變更偵測
#==============================================================================
if defined?(RPG::State) &&
   RPG::State.method_defined?(:yez_cache_state_csp)

  class RPG::State

    unless method_defined?(:fs_sscs_yez_cache_state_csp_v29)
      alias fs_sscs_yez_cache_state_csp_v29 yez_cache_state_csp
    end

    def yez_cache_state_csp
      result = fs_sscs_yez_cache_state_csp_v29
      @fs_state_stack_cached_note =
        FS_STATE_STACK_CACHE_SYNC.note_signature(self)
      return result
    end

    if method_defined?(:max_stack) &&
       !method_defined?(:fs_sscs_max_stack_v29)

      alias fs_sscs_max_stack_v29 max_stack

      def max_stack
        current_note =
          FS_STATE_STACK_CACHE_SYNC.note_signature(self)

        if @fs_state_stack_cached_note != current_note
          FS_STATE_STACK_CACHE_SYNC.invalidate_state_cache(self)
          fs_sscs_yez_cache_state_csp_v29
          @fs_state_stack_cached_note = current_note
        end

        return fs_sscs_max_stack_v29
      end
    end
  end
end

#==============================================================================
# ■ FS_DB_AUTOSET：State Note替換時清除CSP快取
#==============================================================================
if defined?(FS_DB_AUTOSET)

  module FS_DB_AUTOSET

    class << self

      unless method_defined?(:fs_sscs_invalidate_note_cache_v29)
        alias fs_sscs_invalidate_note_cache_v29 invalidate_note_cache
      end

      def invalidate_note_cache(obj)
        result = fs_sscs_invalidate_note_cache_v29(obj)

        if defined?(RPG::State) && obj.is_a?(RPG::State)
          FS_STATE_STACK_CACHE_SYNC.invalidate_state_cache(obj)
        end

        return result
      end

      unless method_defined?(:fs_sscs_apply_all_v29)
        alias fs_sscs_apply_all_v29 apply_all
      end

      def apply_all
        result = fs_sscs_apply_all_v29
        FS_STATE_STACK_CACHE_SYNC.rebuild_all_state_caches
        return result
      end
    end
  end
end

#==============================================================================
# ■ 測試指令
#==============================================================================
class Game_Interpreter

  def fs_state_stack_rebuild
    result =
      FS_STATE_STACK_CACHE_SYNC.rebuild_all_state_caches

    if $game_message != nil
      $game_message.texts.push(
        result ?
        "State疊層快取已重建。" :
        "State疊層快取重建失敗。")
    end

    return result
  end

  def fs_state_stack_report
    result = FS_STATE_STACK_CACHE_SYNC.write_report

    if $game_message != nil
      $game_message.texts.push(
        result ?
        "State疊層報告已輸出。" :
        "State疊層報告發現異常。")
    end

    return result
  end
end
#==============================================================================
# ■ State 54～61回合累加測試指令
#==============================================================================
class Game_Interpreter

  # 用法：
  #   fs_parameter_state_turn_report(1)
  #
  # actor_id預設1。輸出角色目前State 54～61的剩餘回合。
  def fs_parameter_state_turn_report(actor_id = 1)
    actor = $game_actors[actor_id.to_i]

    if actor == nil
      $game_message.texts.push("找不到Actor #{actor_id}。")
      return false
    end

    found = false

    for state_id in FS_PARAMETER_STATE_DURATION_STACK::STATE_IDS
      next unless actor.state?(state_id)

      found = true
      state = $data_states[state_id]
      turns =
        FS_PARAMETER_STATE_DURATION_STACK.current_turns(
          actor, state_id)

      name = state == nil ? "State #{state_id}" : state.name

      $game_message.texts.push(
        "#{name}：剩#{turns}回合")
    end

    unless found
      $game_message.texts.push(
        "#{actor.name}目前沒有能力上升／下降State。")
    end

    return true
  end
end

#==============================================================================
# ■ State 54～61：回合累加 v3.2
#==============================================================================

module FS_PARAMETER_STATE_DURATION_STACK

  def self.add_hold_turn(battler, state_id, turns_before)
    return false if battler == nil

    state = $data_states[state_id.to_i]
    return false if state == nil
    return false unless battler.state?(state_id.to_i)

    added_turns = [state.hold_turn.to_i, 0].max

    result = set_turns(
      battler,
      state_id,
      turns_before.to_i + added_turns)

    if result && battler.respond_to?(:albert_bshud_touch!)
      begin
        battler.albert_bshud_touch!
      rescue
      end
    end

    return result
  end
end

#==============================================================================
# ■ 其他腳本直接add_state的備援
#==============================================================================
class Game_Battler

  unless method_defined?(:fs_param_turn_direct_add_v32)

    alias fs_param_turn_direct_add_v32 add_state

    def add_state(*args)

      state_id = args[0].to_i
      tracked =
        FS_PARAMETER_STATE_DURATION_STACK.include?(state_id)

      existed_before =
        tracked && state?(state_id)

      turns_before = if existed_before
                       FS_PARAMETER_STATE_DURATION_STACK.current_turns(
                         self, state_id)
                     else
                       0
                     end

      result = fs_param_turn_direct_add_v32(*args)

      guarded =
        instance_variable_get(
          :@fs_parameter_event_guard_state_id).to_i

      if existed_before &&
         state?(state_id) &&
         guarded != state_id

        FS_PARAMETER_STATE_DURATION_STACK.add_hold_turn(
          self, state_id, turns_before)

      end

      return result
    end
  end
end

#==============================================================================
# ■ 事件指令command_313／command_333
#==============================================================================
class Game_Interpreter

  def fs_param_collect_actors_v32
    result = []
    iterate_actor_id(@params[0]) do |actor|
      result.push(actor) unless actor == nil
    end
    return result
  end

  def fs_param_collect_enemies_v32
    result = []
    iterate_enemy_index(@params[0]) do |enemy|
      result.push(enemy) unless enemy == nil
    end
    return result
  end

  def fs_param_prepare_event_v32(targets, state_id)
    data = {}

    for battler in targets
      existed = battler.state?(state_id)
      turns = existed ?
        FS_PARAMETER_STATE_DURATION_STACK.current_turns(
          battler, state_id) : 0

      data[battler.object_id] = [
        battler, existed, turns
      ]

      battler.instance_variable_set(
        :@fs_parameter_event_guard_state_id,
        state_id)
    end

    return data
  end

  def fs_param_finish_event_v32(data, state_id)
    data.each_value do |row|
      battler = row[0]
      existed = row[1]
      turns_before = row[2]

      battler.instance_variable_set(
        :@fs_parameter_event_guard_state_id,
        nil)

      next unless existed
      next unless battler.state?(state_id)

      FS_PARAMETER_STATE_DURATION_STACK.add_hold_turn(
        battler, state_id, turns_before)
    end
  end

  unless method_defined?(:fs_param_command_313_v32)
    alias fs_param_command_313_v32 command_313
  end

  def command_313
    state_id = @params[2].to_i

    unless @params[1] == 0 &&
           FS_PARAMETER_STATE_DURATION_STACK.include?(state_id)
      return fs_param_command_313_v32
    end

    data = fs_param_prepare_event_v32(
      fs_param_collect_actors_v32, state_id)

    begin
      return fs_param_command_313_v32
    ensure
      fs_param_finish_event_v32(data, state_id)
    end
  end

  unless method_defined?(:fs_param_command_333_v32)
    alias fs_param_command_333_v32 command_333
  end

  def command_333
    state_id = @params[2].to_i

    unless @params[1] == 0 &&
           FS_PARAMETER_STATE_DURATION_STACK.include?(state_id)
      return fs_param_command_333_v32
    end

    data = fs_param_prepare_event_v32(
      fs_param_collect_enemies_v32, state_id)

    begin
      return fs_param_command_333_v32
    ensure
      fs_param_finish_event_v32(data, state_id)
    end
  end

  def fs_parameter_enemy_turn_report(enemy_index = 0)
    enemy = $game_troop.members[enemy_index.to_i]

    if enemy == nil
      $game_message.texts.push(
        "找不到敵人索引#{enemy_index}。")
      return false
    end

    found = false

    for state_id in
        FS_PARAMETER_STATE_DURATION_STACK::STATE_IDS
      next unless enemy.state?(state_id)

      found = true
      state = $data_states[state_id]
      turns =
        FS_PARAMETER_STATE_DURATION_STACK.current_turns(
          enemy, state_id)

      name = state == nil ?
        "State #{state_id}" : state.name

      $game_message.texts.push(
        "#{name}：剩#{turns}回合")
    end

    unless found
      $game_message.texts.push(
        "#{enemy.name}沒有能力上升／下降State。")
    end

    return true
  end
end
