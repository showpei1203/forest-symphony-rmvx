#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ComboCore v1.1.1 OD
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_ComboCore v1.1.1 OD」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::State、Game_Battler、Game_Actor、Game_Enemy、Game_Party、ALBERT_COMBO_CORE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：POKEMON_IDS、ROBOT_IDS、CLONE_IDS、COVER_ALLOW_ALL_TARGET、COVER_ALLOW_ITEMS、COVER_RECALC_DAMAGE、COVER_REDIRECT_STATES、COVER_ANIMATION_ID。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 11 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertComboCore；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】<bonus_if_od 50:30>
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

# ■ Albert_RMVX_ComboCore_AllInOne_v1_1_1_OD_RGSS2Fix.rb

#------------------------------------------------------------------------------

# RPG Maker VX / RGSS2

#

# 建議放置位置：

#   AutoBattleAI_IntegrationFix

#   [本補丁]

#   全腳本導出工具

#   Main

#

# 功能：

#   1. 召喚物分類：Pokemon / Robot / Clone

#   2. 重製 Cover：停用 Lusitano 舊 Cover 的直接傷害與跳躍位移

#   3. Mana Shield：支援舊格式 <absorb X Y>

#   4. 對特定 State 增傷、依狀態數增傷、依單位種類增傷

#   5. State 爆發 / 消耗 / 疊層傷害

#   6. State 擴散 / 飄移 / 轉換 / 死亡傳染

#   7. 特定條件提高 State 附加成功率

#   8. ATB 直接削減與「條件式削減幅度加成」

#   9. OverDrive / 怒氣值條件：增傷、減傷、狀態率、ATB 幅度

#

# 重要：

#   - 本補丁是依 Albert 2026-07-11 的完整腳本順序設計。

#   - 不使用 Array#sample、Module#prepend、keyword arguments 等新版 Ruby 功能。

#   - 舊 Lusitano Cover 不必刪除，本補丁會在最下方停用其核心判定。

#==============================================================================

=begin

$game_party.albert_pokemons

$game_party.albert_robots

$game_party.albert_clones



---cover---

<COVER 1 0>

永遠代替承受物理攻擊

<COVER 2 50>

50%機率代替物理攻擊

<COVER 6 30>

當被保護者HP低於30%時，代替承受物理或魔法攻擊

類型	效果

1	永遠保護物理攻擊

2	依機率保護物理攻擊

3	目標HP低於指定比例時保護物理攻擊

4	永遠保護物理與魔法

5	依機率保護物理與魔法

6	目標HP低於指定比例時保護物理與魔法



---mana shield----

<absorb 500 50>

護盾總容量：500

每次受到HP傷害時，最多將50%轉移到MP

用腳本取得剩餘值

battler.albert_mana_shield_remaining(state_id)



----特定狀態增傷----

直接寫在：

技能

武器

防具

使用者身上的State

敵人Note



<bonus_vs_state 31:50>

目標有 State 31 時，傷害＋50%



<bonus_vs_state 31:50>

<bonus_vs_state 32:40>

<bonus_vs_state 33:70>



31 = 中毒

32 = 濕潤

33 = 麻痺



那就能設計：



中毒目標＋50%



濕潤目標＋40%



麻痺目標＋70%



----使用者自己有特定狀態時增傷

<bonus_if_user_state 40:30>

使用者有State 40時，傷害＋30%



----依目標異常數量增傷

<bonus_per_target_state:10>

敵人每多一個State：

傷害＋10%。



----達到特定異常數量才增傷

<bonus_if_state_count 3:50>

目標至少具有3種State：

傷害＋50%。





----依召喚物種類增傷----

<bonus_vs_type robot:50>

對機器人：

傷害＋50%。

<bonus_vs_type pokemon:30>



----狀態爆發與消耗----

<detonate_state 31:150>

目標每有1層State 31，追加150固定傷害，然後消耗State 31

追加到原技能傷害中。

之後移除中毒。



<consume_state 31>

<damage_per_stack:150>

效果相同



----狀態擴散----

<spread_state 31:2>

將目標身上的State 31複製給另外2名同陣營角色



擴散成功率

<spread_state 31:2:50>





----狀態飄移----

<drift_state 31:1>





----狀態轉換----

<convert_state 31:32>

State 31轉換成State 32



----死亡傳染----

<spread_on_death:2>

帶著這個狀態死亡時，傳染給另外2名同陣營存活者



<drift_on_death:1>

將狀態轉移給1名其他存活者



----特定條件下更容易上狀態----

<state_chance 31:20>

State 31成功率額外＋20個百分點



----目標已經有特定State時，更容易追加另一個State

<state_chance_vs_state 31,32:25>



----使用者有某狀態時，提高異常成功率

<state_chance_if_user_state 31,40:30>

使用者具有State 40時，附加State 31的成功率＋30%



----ATB直接削減----

<atb_shift:-25>

目標ATB減少25%

<atb_shift:30>

增加30%



----ATB削減幅度在特定條件下增加----

<atb_shift:-20>

<atb_bonus_vs_state 31:50>



----使用者有特定State時強化

<atb_bonus_if_user_state 40:50>

艾卓處於超載狀態：

ATB削減幅度＋50%。



----依目標異常數量強化----

<atb_bonus_per_target_state:10>

敵人有4個State：

ATB削減幅度 +40%



#==============================================================================

# ■ v1.1 OverDrive / 怒氣 Note 範例

#------------------------------------------------------------------------------

# <bonus_if_od 50:30>

怒氣達50%以上，傷害＋30%

# <bonus_per_od_percent:0.5>

每1%怒氣，傷害＋0.5%

<bonus_if_od 25:10>

<bonus_if_od 50:20>

<bonus_if_od 75:30>

怒氣	總加成

0～24%	0%

25～49%	+10%

50～74%	+30%

75～100%	+60%





# <bonus_per_od_100:10>

每100點 OverDrive：

傷害＋10%。



# <reduce_damage_if_od 50:20>

自身怒氣達50%以上時，受到傷害降低20%

# <reduce_damage_per_od_percent:0.2>

每1%怒氣：

減傷0.2%。

# <state_chance_if_od 31,50:20>

用者怒氣達50%以上時，附加State 31的成功率額外＋20個百分點

# <state_chance_per_od_percent 31:0.2>

每1%怒氣：

State 31成功率＋0.2個百分點。

# <atb_bonus_if_od 50:50>

怒氣達50%後：

ATB削減幅度＋50%

# <atb_bonus_per_od_percent:0.5>

#==============================================================================



=end

$imported = {} if $imported == nil

$imported["AlbertComboCore"] = true



#==============================================================================

# ■ ALBERT_COMBO_CORE

#==============================================================================

module ALBERT_COMBO_CORE



  VERSION = "1.1"



  #--------------------------------------------------------------------------

  # ● 召喚物 Actor ID 分類

  #   請依資料庫實際 ID 填入。

  #   未列入三類、但被原本 albert_summon? 判定為召喚物者，仍會回傳 :summon。

  #--------------------------------------------------------------------------

  POKEMON_IDS = []

  ROBOT_IDS   = []

  CLONE_IDS   = []



  #--------------------------------------------------------------------------

  # ● Cover 設定

  #--------------------------------------------------------------------------

  COVER_ALLOW_ALL_TARGET = false   # false：全體技不能被 Cover

  COVER_ALLOW_ITEMS      = false   # false：傷害物品不觸發 Cover

  COVER_RECALC_DAMAGE     = true    # true：用保護者自身 DEF/RES 重算傷害

  COVER_REDIRECT_STATES   = true    # true：技能附加/解除 State 也轉給保護者

  COVER_ANIMATION_ID      = 0       # > 0：保護者承傷時播放動畫 ID

  COVER_DAMAGE_POPUP      = true    # true：手動在保護者身上顯示傷害數字



  #--------------------------------------------------------------------------

  # ● Mana Shield 設定

  #   <absorb 500 50>

  #   500 = 此 State 可累計吸收 500 傷害

  #   50  = 每次受到 HP 傷害時，最多 50% 轉由 MP 承擔

  #--------------------------------------------------------------------------

  MANA_SHIELD_BREAK_ON_ZERO_MP = false



  #--------------------------------------------------------------------------

  # ● 傷害加成安全上下限

  #   -100 = 傷害歸 0；900 = +900%，即 10 倍

  #--------------------------------------------------------------------------

  DAMAGE_BONUS_MIN = -100

  DAMAGE_BONUS_MAX = 900



  #--------------------------------------------------------------------------

  # ● State 附加率安全上下限

  #--------------------------------------------------------------------------

  STATE_CHANCE_MIN = 0

  STATE_CHANCE_MAX = 100



  #--------------------------------------------------------------------------

  # ● 狀態計數時排除的 State ID

  #   State 1 通常為死亡。

  #--------------------------------------------------------------------------

  STATE_COUNT_EXCLUDE = [1]



  #--------------------------------------------------------------------------

  # ● 通用 Note 讀取

  #--------------------------------------------------------------------------

  def self.note(obj)

    return "" if obj == nil

    if defined?(ALBERT_BATTLE_FIX) && ALBERT_BATTLE_FIX.respond_to?(:note)

      return ALBERT_BATTLE_FIX.note(obj)

    end

    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil

    return ""

  end



  def self.source_text(user, obj = nil)

    text = ""

    text += note(obj)

    return text if user == nil



    if user.respond_to?(:albert_notes_for_user)

      text += user.albert_notes_for_user.to_s

      return text

    end



    if user.actor?

      if user.respond_to?(:equips)

        for item in user.equips.compact

          text += note(item)

        end

      end

    else

      if user.respond_to?(:enemy)

        text += note(user.enemy)

      end

    end



    for state in user.states.compact

      text += note(state)

    end

    return text

  end



  def self.clamp(value, min_value, max_value)

    return [[value, min_value].max, max_value].min

  end

end



#==============================================================================

# ■ RPG::State

#==============================================================================

class RPG::State



  #--------------------------------------------------------------------------

  # ● Mana Shield

  #   支援：<absorb 500 50>

  #         <mana_shield 500:50>

  #         <mana shield 500 50>

  #--------------------------------------------------------------------------

  def albert_mana_shield_data

    text = ALBERT_COMBO_CORE.note(self)

    if text =~ /<absorb\s+(\d+)\s+(\d+)\s*>/i

      return [$1.to_i, $2.to_i]

    end

    if text =~ /<mana[_\s]?shield\s+(\d+)\s*[: ,]\s*(\d+)\s*>/i

      return [$1.to_i, $2.to_i]

    end

    return nil

  end



  #--------------------------------------------------------------------------

  # ● Cover

  #   <COVER type param>

  #--------------------------------------------------------------------------

  def albert_cover_data

    text = ALBERT_COMBO_CORE.note(self)

    if text =~ /<cover\s+(\d+)\s+(\d+)\s*>/i

      return [$1.to_i, $2.to_i]

    end

    return nil

  end



  #--------------------------------------------------------------------------

  # ● 死亡傳染

  #   <spread_on_death:2>       複製給 2 個同陣營存活單位

  #   <drift_on_death:1>        飄移給 1 個同陣營存活單位

  #--------------------------------------------------------------------------

  def albert_spread_on_death_count

    text = ALBERT_COMBO_CORE.note(self)

    return $1.to_i if text =~ /<spread_on_death\s*:\s*(\d+)\s*>/i

    return 0

  end



  def albert_drift_on_death_count

    text = ALBERT_COMBO_CORE.note(self)

    return $1.to_i if text =~ /<drift_on_death\s*:\s*(\d+)\s*>/i

    return 0

  end

end



#==============================================================================

# ■ Game_Battler

#==============================================================================

class Game_Battler



  #--------------------------------------------------------------------------

  # ● 召喚物分類

  #--------------------------------------------------------------------------

  def albert_pokemon?

    return actor? && ALBERT_COMBO_CORE::POKEMON_IDS.include?(self.id)

  end



  def albert_robot?

    return actor? && ALBERT_COMBO_CORE::ROBOT_IDS.include?(self.id)

  end



  def albert_clone?

    return actor? && ALBERT_COMBO_CORE::CLONE_IDS.include?(self.id)

  end



  def albert_summon_type

    return :pokemon if albert_pokemon?

    return :robot   if albert_robot?

    return :clone   if albert_clone?

    return :summon  if respond_to?(:albert_summon?) && albert_summon?

    return nil

  end



  def albert_unit_type_symbol

    return :pokemon   if albert_pokemon?

    return :robot     if albert_robot?

    return :clone     if albert_clone?

    return :summon    if respond_to?(:albert_summon?) && albert_summon?

    return :main_actor if actor?

    return :enemy

  end



  #--------------------------------------------------------------------------

  # ● OverDrive / 怒氣通用讀取

  #   直接使用 KGC_OverDrive 的 overdrive / max_overdrive。

  #   沒有安裝 OverDrive 時安全回傳 0。

  #--------------------------------------------------------------------------

  def albert_od_value

    return 0 unless respond_to?(:overdrive)

    return overdrive.to_i

  end



  def albert_od_rate

    return 0.0 unless respond_to?(:overdrive)

    return 0.0 unless respond_to?(:max_overdrive)

    max_value = max_overdrive.to_f

    return 0.0 if max_value <= 0.0

    return overdrive.to_f * 100.0 / max_value

  end



  #--------------------------------------------------------------------------

  # ● 取得目標目前真正的 State ID

  #--------------------------------------------------------------------------

  def albert_combo_state_ids

    result = []

    for state in states

      next if state == nil

      result.push(state.id)

    end

    return result

  end



  def albert_combo_state_count

    count = 0

    for state in states

      next if state == nil

      next if ALBERT_COMBO_CORE::STATE_COUNT_EXCLUDE.include?(state.id)

      count += 1

    end

    return count

  end



  #--------------------------------------------------------------------------

  # ● 取得 State 疊層數

  #--------------------------------------------------------------------------

  def albert_combo_stack_count(state_id)

    return 0 unless state?(state_id)

    if respond_to?(:stack)

      begin

        return [stack(state_id).to_i, 1].max

      rescue

      end

    end

    return 1

  end



  #--------------------------------------------------------------------------

  # ● 同陣營存活成員

  #--------------------------------------------------------------------------

  def albert_combo_same_side_members

    if actor?

      return $game_party.existing_members

    else

      return $game_troop.existing_members

    end

  end



  #--------------------------------------------------------------------------

  # ● 不使用 Array#sample 的安全亂數抽取

  #--------------------------------------------------------------------------

  def albert_combo_random_members(pool, count)

    work = pool.compact.clone

    result = []

    count = count.to_i

    while count > 0 && !work.empty?

      index = rand(work.size)

      result.push(work[index])

      work.delete_at(index)

      count -= 1

    end

    return result

  end



  #--------------------------------------------------------------------------

  # ● 複製 State 到另一名單位，盡量保留 CSP 疊層與原施術者

  #--------------------------------------------------------------------------

  def albert_combo_copy_state_to(target, state_id, stack_count = nil)

    return false if target == nil

    return false if target.dead?

    state = $data_states[state_id]

    return false if state == nil

    return false if target.state_resist?(state_id)



    stack_count = albert_combo_stack_count(state_id) if stack_count == nil

    stack_count = [stack_count.to_i, 1].max



    # RGSS2 內建 Ruby 沒有 Object#instance_variable_defined?。

    # 直接讀取不存在的實例變數會安全地回傳 nil。

    source_origin = nil

    source_side = nil

    hash = instance_variable_get(:@state_origin)

    source_origin = hash[state_id] if hash != nil

    hash = instance_variable_get(:@origin_side)

    source_side = hash[state_id] if hash != nil



    target.add_state(state_id)



    if target.respond_to?(:increase_stack) && target.respond_to?(:stack)

      current = target.stack(state_id).to_i

      extra = stack_count - current

      target.increase_stack(state_id, extra) if extra > 0

    end



    if source_origin != nil

      hash = target.instance_variable_get(:@state_origin)

      hash = {} if hash == nil

      hash[state_id] = source_origin

      target.instance_variable_set(:@state_origin, hash)

    end

    if source_side != nil

      hash = target.instance_variable_get(:@origin_side)

      hash = {} if hash == nil

      hash[state_id] = source_side

      target.instance_variable_set(:@origin_side, hash)

    end



    return true

  end



  #--------------------------------------------------------------------------

  # ● 實際效果上下文

  #--------------------------------------------------------------------------

  def albert_combo_set_effect_context(user, obj)

    @albert_effect_user = user

    @albert_effect_obj = obj

  end



  def albert_combo_clear_effect_context

    @albert_effect_user = nil

    @albert_effect_obj = nil

  end



  def albert_combo_effect_user

    return @albert_effect_user if @albert_effect_user != nil

    if $scene.is_a?(Scene_Battle) && $scene.respond_to?(:active_battler)

      return $scene.active_battler

    end

    return nil

  end



  def albert_combo_effect_obj

    return @albert_effect_obj if @albert_effect_obj != nil

    return @albert_last_damage_obj

  end



  #--------------------------------------------------------------------------

  # ● 技能效果上下文 + 後處理

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_skill_effect)

    alias albert_combo_old_skill_effect skill_effect

  end



  def skill_effect(user, skill)

    albert_combo_set_effect_context(user, skill)

    begin

      albert_combo_old_skill_effect(user, skill)



      # Cover 對物理技可能因 @hp_damage == 0 而讓原 skill_effect 提前 return，

      # 這裡補做被攔截的 State 變化。

      albert_combo_finish_cover_state_redirect(user, skill)



      unless @missed || @evaded || @skipped

        actual_target = @albert_cover_effect_target

        actual_target = self if actual_target == nil

        actual_target.albert_combo_process_skill_aftereffects(user, skill)

      end

    ensure

      @albert_cover_effect_target = nil

      @albert_cover_pending_state_target = nil

      albert_combo_clear_effect_context

    end

  end



  #--------------------------------------------------------------------------

  # ● 物品效果上下文

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_item_effect)

    alias albert_combo_old_item_effect item_effect

  end



  def item_effect(user, item)

    albert_combo_set_effect_context(user, item)

    begin

      albert_combo_old_item_effect(user, item)

    ensure

      albert_combo_clear_effect_context

    end

  end



  #--------------------------------------------------------------------------

  # ● 普攻效果上下文

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_attack_effect)

    alias albert_combo_old_attack_effect attack_effect

  end



  def attack_effect(attacker)

    albert_combo_set_effect_context(attacker, nil)

    begin

      albert_combo_old_attack_effect(attacker)

    ensure

      albert_combo_clear_effect_context

    end

  end



  #--------------------------------------------------------------------------

  # ● 條件式傷害加成

  #

  #   <bonus_vs_state 31:50>            目標有 State 31 時 +50%

  #   <bonus_if_user_state 40:30>       使用者有 State 40 時 +30%

  #   <bonus_per_target_state:10>       目標每有 1 種 State +10%

  #   <bonus_if_state_count 3:50>       目標至少 3 種 State 時 +50%

  #   <bonus_vs_type robot:50>          對 Robot +50%

  #   <bonus_if_od 50:30>                使用者怒氣 >= 50% 時 +30%

  #   <bonus_per_od_percent:0.5>         每 1% 怒氣 +0.5% 傷害

  #   <bonus_per_od_100:10>              每滿 100 點怒氣 +10% 傷害

  #

  # 可寫在 Skill / 裝備 / 使用者 State / Enemy Note。

  #--------------------------------------------------------------------------

  def albert_combo_damage_bonus_percent(user, obj)

    text = ALBERT_COMBO_CORE.source_text(user, obj)

    bonus = 0



    text.scan(/<bonus_vs_state\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      state_id = data[0].to_i

      value = data[1].to_i

      bonus += value if state?(state_id)

    end



    text.scan(/<bonus_if_user_state\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      state_id = data[0].to_i

      value = data[1].to_i

      bonus += value if user != nil && user.state?(state_id)

    end



    text.scan(/<bonus_per_target_state\s*:\s*(-?\d+)\s*>/i) do |data|

      bonus += albert_combo_state_count * data[0].to_i

    end



    text.scan(/<bonus_if_state_count\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      need = data[0].to_i

      value = data[1].to_i

      bonus += value if albert_combo_state_count >= need

    end



    text.scan(/<bonus_vs_type\s+([a-z_]+)\s*:\s*(-?\d+)\s*>/i) do |data|

      type = data[0].downcase.to_sym

      value = data[1].to_i

      bonus += value if albert_unit_type_symbol == type

    end



    # OverDrive / 怒氣：依使用者目前 Gauge 讀值。

    if user != nil

      text.scan(/<bonus_if_od\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

        need_rate = data[0].to_f

        value = data[1].to_f

        bonus += value if user.albert_od_rate >= need_rate

      end



      text.scan(/<bonus_per_od_percent\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

        bonus += user.albert_od_rate * data[0].to_f

      end



      text.scan(/<bonus_per_od_100\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

        bonus += (user.albert_od_value / 100) * data[0].to_f

      end

    end



    bonus = bonus.to_i

    return ALBERT_COMBO_CORE.clamp(

      bonus,

      ALBERT_COMBO_CORE::DAMAGE_BONUS_MIN,

      ALBERT_COMBO_CORE::DAMAGE_BONUS_MAX

    )

  end



  #--------------------------------------------------------------------------

  # ● 解析爆發 / 消耗 State

  #

  #   <detonate_state 31:150>

  #     每層 State 31 額外 +150 固定傷害，命中後移除 State 31。

  #

  #   <consume_state 31>

  #   <damage_per_stack:150>

  #     與上面同義。

  #--------------------------------------------------------------------------

  def albert_combo_detonate_data(obj)

    text = ALBERT_COMBO_CORE.note(obj)

    specs = {}

    consume_ids = []



    text.scan(/<detonate_state\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      state_id = data[0].to_i

      specs[state_id] = data[1].to_i

      consume_ids.push(state_id) unless consume_ids.include?(state_id)

    end



    per_stack = nil

    if text =~ /<damage_per_stack\s*:\s*(-?\d+)\s*>/i

      per_stack = $1.to_i

    end



    text.scan(/<consume_state\s+(\d+)\s*>/i) do |data|

      state_id = data[0].to_i

      consume_ids.push(state_id) unless consume_ids.include?(state_id)

      specs[state_id] = per_stack if per_stack != nil && !specs.has_key?(state_id)

    end



    return [specs, consume_ids]

  end



  #--------------------------------------------------------------------------

  # ● 依承傷者 OverDrive / 怒氣降低受到傷害

  #

  #   <reduce_damage_if_od 50:20>

  #     自身怒氣 >= 50% 時，受到的正傷害降低 20%。

  #

  #   <reduce_damage_per_od_percent:0.2>

  #     每 1% 怒氣減傷 0.2%，滿怒時減傷 20%。

  #

  # 可寫在承傷者裝備 / State / Enemy Note。最大總減傷 90%。

  #--------------------------------------------------------------------------

  def albert_combo_od_damage_reduction_percent

    text = ALBERT_COMBO_CORE.source_text(self, nil)

    reduction = 0.0



    text.scan(/<reduce_damage_if_od\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

      need_rate = data[0].to_f

      value = data[1].to_f

      reduction += value if albert_od_rate >= need_rate

    end



    text.scan(/<reduce_damage_per_od_percent\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

      reduction += albert_od_rate * data[0].to_f

    end



    return [[reduction, 0.0].max, 90.0].min

  end



  #--------------------------------------------------------------------------

  # ● 傷害核心後處理

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_make_obj_damage_value)

    alias albert_combo_old_make_obj_damage_value make_obj_damage_value

  end



  def make_obj_damage_value(user, obj)

    albert_combo_old_make_obj_damage_value(user, obj)

    @albert_last_damage_user = user

    @albert_last_damage_obj = obj



    return if obj == nil



    # 1. 百分比條件增傷，只影響正傷害，不影響回復。

    bonus_percent = albert_combo_damage_bonus_percent(user, obj)

    if @hp_damage != nil && @hp_damage > 0

      @hp_damage = (@hp_damage * (100 + bonus_percent) / 100.0).to_i

      reduction = albert_combo_od_damage_reduction_percent

      @hp_damage = (@hp_damage * (100.0 - reduction) / 100.0).to_i if reduction > 0

    elsif @mp_damage != nil && @mp_damage > 0

      @mp_damage = (@mp_damage * (100 + bonus_percent) / 100.0).to_i

      reduction = albert_combo_od_damage_reduction_percent

      @mp_damage = (@mp_damage * (100.0 - reduction) / 100.0).to_i if reduction > 0

    end



    # 2. State 爆發固定傷害。

    data = albert_combo_detonate_data(obj)

    specs = data[0]

    consume_ids = data[1]

    bonus_damage = 0



    specs.each_pair do |state_id, per_stack|

      next unless state?(state_id)

      bonus_damage += albert_combo_stack_count(state_id) * per_stack.to_i

    end



    if bonus_damage > 0 && !obj.damage_to_mp

      @hp_damage = 0 if @hp_damage == nil

      @hp_damage += bonus_damage

    end



    # 只有真正在 skill_effect / item_effect 中執行時才記錄待消耗 State。

    if @albert_effect_obj != nil && @albert_effect_obj.equal?(obj)

      @albert_pending_consume_states = []

      for state_id in consume_ids

        if state?(state_id) && !@albert_pending_consume_states.include?(state_id)

          @albert_pending_consume_states.push(state_id)

        end

      end

    end

  end



  #--------------------------------------------------------------------------

  # ● 記錄普通攻擊上下文

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_make_attack_damage_value)

    alias albert_combo_old_make_attack_damage_value make_attack_damage_value

  end



  def make_attack_damage_value(attacker)

    albert_combo_old_make_attack_damage_value(attacker)

    @albert_last_damage_user = attacker

    @albert_last_damage_obj = nil



    bonus_percent = albert_combo_damage_bonus_percent(attacker, nil)

    if @hp_damage != nil && @hp_damage > 0

      @hp_damage = (@hp_damage * (100 + bonus_percent) / 100.0).to_i

      reduction = albert_combo_od_damage_reduction_percent

      @hp_damage = (@hp_damage * (100.0 - reduction) / 100.0).to_i if reduction > 0

    end

  end



  #--------------------------------------------------------------------------

  # ● Mana Shield 初始化 / 查詢

  #--------------------------------------------------------------------------

  def albert_mana_shield_remaining(state_id)

    @albert_mana_shield_remaining = {} if @albert_mana_shield_remaining == nil

    state = $data_states[state_id]

    return 0 if state == nil

    data = state.albert_mana_shield_data

    return 0 if data == nil

    if @albert_mana_shield_remaining[state_id] == nil

      @albert_mana_shield_remaining[state_id] = data[0].to_i

    end

    return @albert_mana_shield_remaining[state_id]

  end



  def albert_setup_mana_shield(state_id)

    state = $data_states[state_id]

    return if state == nil

    data = state.albert_mana_shield_data

    return if data == nil

    @albert_mana_shield_remaining = {} if @albert_mana_shield_remaining == nil

    @albert_mana_shield_remaining[state_id] = data[0].to_i

  end



  def albert_clear_mana_shield(state_id)

    return if @albert_mana_shield_remaining == nil

    @albert_mana_shield_remaining.delete(state_id)

  end



  def albert_apply_mana_shield

    return if @hp_damage == nil || @hp_damage <= 0



    shield_state = nil

    shield_data = nil

    for state in states

      next if state == nil

      data = state.albert_mana_shield_data

      next if data == nil

      next if data[0].to_i <= 0

      next if data[1].to_i <= 0

      shield_state = state

      shield_data = data

      break

    end

    return if shield_state == nil



    state_id = shield_state.id

    capacity = albert_mana_shield_remaining(state_id)

    return if capacity <= 0



    rate = [[shield_data[1].to_i, 0].max, 100].min

    return if rate <= 0



    desired = (@hp_damage * rate / 100.0).to_i

    return if desired <= 0



    current_mp_damage = @mp_damage == nil ? 0 : [@mp_damage.to_i, 0].max

    available_mp = [self.mp - current_mp_damage, 0].max

    absorbed = [desired, capacity, available_mp].min

    return if absorbed <= 0



    @hp_damage -= absorbed

    @mp_damage = 0 if @mp_damage == nil

    @mp_damage += absorbed



    @albert_mana_shield_remaining[state_id] = capacity - absorbed



    if @albert_mana_shield_remaining[state_id] <= 0

      remove_state(state_id)

    elsif ALBERT_COMBO_CORE::MANA_SHIELD_BREAK_ON_ZERO_MP && available_mp - absorbed <= 0

      remove_state(state_id)

    end

  end



  #--------------------------------------------------------------------------

  # ● Cover：找保護者

  #--------------------------------------------------------------------------

  def albert_cover_candidate(user, obj)

    return nil if @hp_damage == nil || @hp_damage <= 0

    return nil if @albert_cover_redirect_guard

    return nil if obj != nil && obj.respond_to?(:for_all?) && obj.for_all? &&

                  !ALBERT_COMBO_CORE::COVER_ALLOW_ALL_TARGET

    return nil if obj.is_a?(RPG::Item) && !ALBERT_COMBO_CORE::COVER_ALLOW_ITEMS



    physical = (obj == nil)

    physical = obj.physical_attack if obj != nil && obj.respond_to?(:physical_attack)



    for state in states

      next if state == nil

      data = state.albert_cover_data

      next if data == nil



      cover_type = data[0]

      cover_param = data[1]



      # 1～3：只擋物理；4～6：物理 + 魔法

      next if cover_type <= 3 && !physical



      condition_ok = false

      case cover_type

      when 1, 4

        condition_ok = true

      when 2, 5

        condition_ok = rand(100) < cover_param

      when 3, 6

        hp_rate = self.maxhp > 0 ? self.hp * 100.0 / self.maxhp : 0

        condition_ok = hp_rate <= cover_param

      end

      next unless condition_ok



      protector = nil

      if respond_to?(:state_origin)

        begin

          protector = state_origin(state.id)

        rescue

          protector = nil

        end

      end



      # 舊 Cover 存檔或舊資料的保險 fallback。

      if (protector == nil || protector == self) && @protector != nil

        if actor?

          protector = $game_actors[@protector] rescue nil

        end

      end



      next if protector == nil

      next if protector == self

      next unless protector.exist?

      next if protector.dead?

      next unless protector.actor? == self.actor?



      return protector

    end



    return nil

  end



  #--------------------------------------------------------------------------

  # ● Cover：重算 / 轉移傷害

  #--------------------------------------------------------------------------

  def albert_execute_cover_redirect(user, obj, protector)

    return false if protector == nil



    # 原目標不承受 HP 傷害。

    @hp_damage = 0

    @albert_cover_pending_state_target = protector

    @albert_cover_effect_target = protector



    # Cover 攔截代表原目標的爆發 State 不應被消耗。

    @albert_pending_consume_states = []



    old_user = protector.instance_variable_get(:@albert_effect_user)

    old_obj = protector.instance_variable_get(:@albert_effect_obj)

    protector.instance_variable_set(:@albert_cover_redirect_guard, true)

    protector.albert_combo_set_effect_context(user, obj)



    begin

      if ALBERT_COMBO_CORE::COVER_RECALC_DAMAGE

        if obj == nil

          protector.make_attack_damage_value(user)

        else

          protector.make_obj_damage_value(user, obj)

        end

      else

        protector.instance_variable_set(:@hp_damage, @albert_cover_original_damage.to_i)

        protector.instance_variable_set(:@mp_damage, 0)

      end



      protector.execute_damage(user)



      if ALBERT_COMBO_CORE::COVER_ANIMATION_ID > 0

        protector.animation_id = ALBERT_COMBO_CORE::COVER_ANIMATION_ID

      end



      albert_combo_cover_damage_popup(protector)

    ensure

      protector.instance_variable_set(:@albert_cover_redirect_guard, false)

      protector.instance_variable_set(:@albert_effect_user, old_user)

      protector.instance_variable_set(:@albert_effect_obj, old_obj)

    end



    return true

  end



  #--------------------------------------------------------------------------

  # ● Cover 傷害 Popup，不移動角色

  #--------------------------------------------------------------------------

  def albert_combo_cover_damage_popup(protector)

    return unless ALBERT_COMBO_CORE::COVER_DAMAGE_POPUP

    return if protector == nil

    return unless $scene.is_a?(Scene_Battle)

    return unless $scene.respond_to?(:spriteset)

    return if $scene.spriteset == nil



    begin

      value = protector.hp_damage.to_i

      return if value <= 0



      if protector.actor?

        if $scene.spriteset.respond_to?(:pos_in_sprite_array) &&

           $scene.spriteset.respond_to?(:actor_sprites)

          index = $scene.spriteset.pos_in_sprite_array(protector.id)

          sprite = $scene.spriteset.actor_sprites[index] if index != nil && index >= 0

          sprite.damage_pop(value) if sprite != nil && sprite.respond_to?(:damage_pop)

        end

      else

        if $scene.spriteset.respond_to?(:enemy_sprites)

          sprite = $scene.spriteset.enemy_sprites[protector.index]

          sprite.damage_pop(value) if sprite != nil && sprite.respond_to?(:damage_pop)

        end

      end

    rescue

    end

  end



  #--------------------------------------------------------------------------

  # ● Cover State 轉移完成

  #--------------------------------------------------------------------------

  def albert_combo_finish_cover_state_redirect(user, obj)

    protector = @albert_cover_pending_state_target

    return if protector == nil

    return unless ALBERT_COMBO_CORE::COVER_REDIRECT_STATES



    # 如果 apply_state_changes 已經處理過，pending 會被清掉。

    old_user = protector.instance_variable_get(:@albert_effect_user)

    old_obj = protector.instance_variable_get(:@albert_effect_obj)

    protector.albert_combo_set_effect_context(user, obj)

    begin

      protector.apply_state_changes(obj)

    ensure

      protector.instance_variable_set(:@albert_effect_user, old_user)

      protector.instance_variable_set(:@albert_effect_obj, old_obj)

      @albert_cover_pending_state_target = nil

    end

  end



  #--------------------------------------------------------------------------

  # ● Cover State 轉移：攔截原本 apply_state_changes

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_apply_state_changes)

    alias albert_combo_old_apply_state_changes apply_state_changes

  end



  def apply_state_changes(obj)

    protector = @albert_cover_pending_state_target

    if protector != nil && ALBERT_COMBO_CORE::COVER_REDIRECT_STATES

      user = albert_combo_effect_user

      old_user = protector.instance_variable_get(:@albert_effect_user)

      old_obj = protector.instance_variable_get(:@albert_effect_obj)

      protector.albert_combo_set_effect_context(user, obj)

      begin

        protector.apply_state_changes(obj)

      ensure

        protector.instance_variable_set(:@albert_effect_user, old_user)

        protector.instance_variable_set(:@albert_effect_obj, old_obj)

        @albert_cover_pending_state_target = nil

      end

      return

    end



    albert_combo_old_apply_state_changes(obj)

  end



  #--------------------------------------------------------------------------

  # ● 執行傷害整合：Cover → Mana Shield → 原 execute_damage → 消耗 → 死亡傳染

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_execute_damage)

    alias albert_combo_old_execute_damage execute_damage

  end



  def execute_damage(user)

    was_dead = dead?

    obj = albert_combo_effect_obj



    unless @albert_cover_redirect_guard

      protector = albert_cover_candidate(user, obj)

      if protector != nil

        @albert_cover_original_damage = @hp_damage.to_i

        albert_execute_cover_redirect(user, obj, protector)

      else

        albert_apply_mana_shield

      end

    else

      albert_apply_mana_shield

    end



    albert_combo_old_execute_damage(user)



    albert_combo_consume_pending_states



    if !was_dead && dead?

      albert_combo_process_death_spread

    end

  end



  #--------------------------------------------------------------------------

  # ● 消耗爆發 State

  #--------------------------------------------------------------------------

  def albert_combo_consume_pending_states

    return if @albert_pending_consume_states == nil

    ids = @albert_pending_consume_states.clone

    @albert_pending_consume_states = []

    for state_id in ids

      remove_state(state_id) if state?(state_id)

    end

  end



  #--------------------------------------------------------------------------

  # ● State 附加 / Mana Shield / ATB 額外幅度

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_add_state)

    alias albert_combo_old_add_state add_state

  end



  def add_state(state_id)

    state = $data_states[state_id]

    atb_bonus = albert_combo_atb_bonus_percent if state != nil



    albert_combo_old_add_state(state_id)



    # 初始化 Mana Shield 容量。

    albert_setup_mana_shield(state_id) if state?(state_id)



    # 現有 Tankentai ATB 已先執行 base atb_damage，這裡只補「額外倍率」。

    if state != nil && atb_bonus != 0 && respond_to?(:at_count) &&

       state.respond_to?(:atb_damage) && state.atb_damage.to_i != 0

      base_delta = state.atb_damage.to_i * 10

      extra_delta = (base_delta * atb_bonus / 100.0).to_i

      albert_combo_apply_atb_delta(extra_delta, state)

    end

  end



  #--------------------------------------------------------------------------

  # ● State 移除 / Mana Shield 清理

  #--------------------------------------------------------------------------

  unless method_defined?(:albert_combo_old_remove_state)

    alias albert_combo_old_remove_state remove_state

  end



  def remove_state(state_id)

    albert_clear_mana_shield(state_id)

    albert_combo_old_remove_state(state_id)

  end



  #--------------------------------------------------------------------------

  # ● State 附加率條件加成

  #

  #   <state_chance 31:20>

  #     State 31 附加率 +20 個百分點

  #

  #   <state_chance_vs_state 31,32:25>

  #     目標已有 State 32 時，State 31 附加率再 +25

  #

  #   <state_chance_if_user_state 31,40:30>

  #     使用者有 State 40 時，State 31 附加率再 +30

  #

  #   <state_chance_if_od 31,50:20>

  #     使用者怒氣 >= 50% 時，State 31 附加率再 +20 個百分點。

  #

  #   <state_chance_per_od_percent 31:0.2>

  #     使用者每 1% 怒氣，State 31 附加率 +0.2 個百分點。

  #

  # 可寫在 Skill / 裝備 / 使用者 State / Enemy Note。

  #--------------------------------------------------------------------------

  def albert_combo_adjust_state_probability(state_id, base_probability)

    user = albert_combo_effect_user

    obj = albert_combo_effect_obj

    text = ALBERT_COMBO_CORE.source_text(user, obj)

    bonus = 0



    text.scan(/<state_chance\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      bonus += data[1].to_i if data[0].to_i == state_id

    end



    text.scan(/<state_chance_vs_state\s+(\d+)\s*,\s*(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      apply_id = data[0].to_i

      condition_id = data[1].to_i

      value = data[2].to_i

      bonus += value if apply_id == state_id && state?(condition_id)

    end



    text.scan(/<state_chance_if_user_state\s+(\d+)\s*,\s*(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      apply_id = data[0].to_i

      condition_id = data[1].to_i

      value = data[2].to_i

      if apply_id == state_id && user != nil && user.state?(condition_id)

        bonus += value

      end

    end



    if user != nil

      text.scan(/<state_chance_if_od\s+(\d+)\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

        apply_id = data[0].to_i

        need_rate = data[1].to_f

        value = data[2].to_f

        bonus += value if apply_id == state_id && user.albert_od_rate >= need_rate

      end



      text.scan(/<state_chance_per_od_percent\s+(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

        apply_id = data[0].to_i

        value = data[1].to_f

        bonus += user.albert_od_rate * value if apply_id == state_id

      end

    end



    result = base_probability.to_i + bonus.to_i

    return ALBERT_COMBO_CORE.clamp(

      result,

      ALBERT_COMBO_CORE::STATE_CHANCE_MIN,

      ALBERT_COMBO_CORE::STATE_CHANCE_MAX

    )

  end



  #--------------------------------------------------------------------------

  # ● ATB 條件加成

  #

  #   <atb_bonus:50>

  #     ATB 削減 / 增加幅度額外 +50%

  #

  #   <atb_bonus_vs_state 31:50>

  #     目標已有 State 31 時，ATB 幅度額外 +50%

  #

  #   <atb_bonus_if_user_state 40:50>

  #     使用者有 State 40 時，ATB 幅度額外 +50%

  #

  #   <atb_bonus_per_target_state:10>

  #     目標每有一種 State，ATB 幅度額外 +10%

  #

  #   <atb_bonus_if_od 50:50>

  #     使用者怒氣 >= 50% 時，ATB 幅度額外 +50%

  #

  #   <atb_bonus_per_od_percent:0.5>

  #     使用者每 1% 怒氣，ATB 幅度額外 +0.5%

  #--------------------------------------------------------------------------

  def albert_combo_atb_bonus_percent

    user = albert_combo_effect_user

    obj = albert_combo_effect_obj

    text = ALBERT_COMBO_CORE.source_text(user, obj)

    bonus = 0



    text.scan(/<atb_bonus\s*:\s*(-?\d+)\s*>/i) do |data|

      bonus += data[0].to_i

    end



    text.scan(/<atb_bonus_vs_state\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      bonus += data[1].to_i if state?(data[0].to_i)

    end



    text.scan(/<atb_bonus_if_user_state\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|

      if user != nil && user.state?(data[0].to_i)

        bonus += data[1].to_i

      end

    end



    text.scan(/<atb_bonus_per_target_state\s*:\s*(-?\d+)\s*>/i) do |data|

      bonus += albert_combo_state_count * data[0].to_i

    end



    if user != nil

      text.scan(/<atb_bonus_if_od\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

        need_rate = data[0].to_f

        value = data[1].to_f

        bonus += value if user.albert_od_rate >= need_rate

      end



      text.scan(/<atb_bonus_per_od_percent\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|

        bonus += user.albert_od_rate * data[0].to_f

      end

    end



    return bonus.to_i

  end



  #--------------------------------------------------------------------------

  # ● 實際改 ATB 值

  #--------------------------------------------------------------------------

  def albert_combo_apply_atb_delta(delta, state = nil)

    return if delta == 0

    return unless respond_to?(:at_count)

    return if @at_count == nil



    @at_count += delta.to_i



    allow_negative = false

    if state != nil && state.respond_to?(:atb_minus_damage)

      allow_negative = state.atb_minus_damage ? true : false

    end



    @at_count = 0 if @at_count < 0 && !allow_negative

    @at_count = 1000 if @at_count > 1000



    # 負 ATB 變化沿用原 Tankentai 邏輯：中斷吟唱 / 行動等待。

    if delta < 0

      @act_count = 0 if respond_to?(:act_count=)

      @act_active = false if respond_to?(:act_active=)

      @at_active = false if respond_to?(:at_active=)

      @atb_count_up = true if respond_to?(:atb_count_up=)

    end

  end



  #--------------------------------------------------------------------------

  # ● Skill 後處理

  #

  #   <atb_shift:-25>             直接削減 25% ATB

  #   <spread_state 31:2>         State 31 複製到 2 名同陣營其他單位

  #   <spread_state 31:2:50>      同上，但每名 50% 成功率

  #   <drift_state 31:1>          State 31 飄移到 1 名其他單位，原目標失去

  #   <convert_state 31:32>       State 31 轉為 State 32，盡量保留疊層

  #--------------------------------------------------------------------------

  def albert_combo_process_skill_aftereffects(user, skill)

    return if skill == nil

    text = ALBERT_COMBO_CORE.note(skill)



    # 1. State 轉換

    text.scan(/<convert_state\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|

      from_id = data[0].to_i

      to_id = data[1].to_i

      next unless state?(from_id)

      stacks = albert_combo_stack_count(from_id)

      remove_state(from_id)

      add_state(to_id)

      if respond_to?(:increase_stack) && respond_to?(:stack)

        current = stack(to_id).to_i

        extra = stacks - current

        increase_stack(to_id, extra) if extra > 0

      end

    end



    # 2. State 擴散

    text.scan(/<spread_state\s+(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?\s*>/i) do |data|

      state_id = data[0].to_i

      count = data[1].to_i

      chance = data[2] == nil ? 100 : data[2].to_i

      next unless state?(state_id)



      pool = albert_combo_same_side_members.clone

      pool.delete(self)

      targets = albert_combo_random_members(pool, count)

      stacks = albert_combo_stack_count(state_id)



      for target in targets

        next unless rand(100) < chance

        albert_combo_copy_state_to(target, state_id, stacks)

      end

    end



    # 3. State 飄移

    text.scan(/<drift_state\s+(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?\s*>/i) do |data|

      state_id = data[0].to_i

      count = data[1].to_i

      chance = data[2] == nil ? 100 : data[2].to_i

      next unless state?(state_id)



      pool = albert_combo_same_side_members.clone

      pool.delete(self)

      targets = albert_combo_random_members(pool, count)

      stacks = albert_combo_stack_count(state_id)

      moved = false



      for target in targets

        next unless rand(100) < chance

        moved = true if albert_combo_copy_state_to(target, state_id, stacks)

      end

      remove_state(state_id) if moved && state?(state_id)

    end



    # 4. 直接 ATB 改變，會吃同一套 atb_bonus 條件加成。

    text.scan(/<atb_shift\s*:\s*(-?\d+)\s*>/i) do |data|

      percent = data[0].to_i

      bonus = albert_combo_atb_bonus_percent

      delta = (percent * 10 * (100 + bonus) / 100.0).to_i

      albert_combo_apply_atb_delta(delta, nil)

    end

  end



  #--------------------------------------------------------------------------

  # ● 死亡時 State 傳染 / 飄移

  #--------------------------------------------------------------------------

  def albert_combo_process_death_spread

    source_states = states.clone

    for state in source_states

      next if state == nil



      spread_count = state.albert_spread_on_death_count

      drift_count = state.albert_drift_on_death_count

      next if spread_count <= 0 && drift_count <= 0



      pool = albert_combo_same_side_members.clone

      pool.delete(self)

      pool.delete_if { |member| member == nil || member.dead? }

      next if pool.empty?



      stacks = albert_combo_stack_count(state.id)



      if spread_count > 0

        targets = albert_combo_random_members(pool, spread_count)

        for target in targets

          albert_combo_copy_state_to(target, state.id, stacks)

        end

      end



      if drift_count > 0

        targets = albert_combo_random_members(pool, drift_count)

        for target in targets

          albert_combo_copy_state_to(target, state.id, stacks)

        end

      end

    end

  end



  #--------------------------------------------------------------------------

  # ● 停用 Lusitano 舊 Cover 核心判定

  #   舊腳本保留在工程內也沒關係。

  #--------------------------------------------------------------------------

  if method_defined?(:can_be_Covered)

    def can_be_Covered

      return false

    end

  end



  if method_defined?(:LUS_COVER_check_for_state_extensions)

    def LUS_COVER_check_for_state_extensions(state_id)

      return false

    end

  end

end



#==============================================================================

# ■ Game_Actor：State 附加成功率

#==============================================================================

class Game_Actor < Game_Battler

  unless method_defined?(:albert_combo_old_actor_state_probability)

    alias albert_combo_old_actor_state_probability state_probability

  end



  def state_probability(state_id)

    base = albert_combo_old_actor_state_probability(state_id)

    return albert_combo_adjust_state_probability(state_id, base)

  end

end



#==============================================================================

# ■ Game_Enemy：State 附加成功率

#==============================================================================

class Game_Enemy < Game_Battler

  unless method_defined?(:albert_combo_old_enemy_state_probability)

    alias albert_combo_old_enemy_state_probability state_probability

  end



  def state_probability(state_id)

    base = albert_combo_old_enemy_state_probability(state_id)

    return albert_combo_adjust_state_probability(state_id, base)

  end

end



#==============================================================================

# ■ Game_Party：三類召喚物快捷清單

#==============================================================================

class Game_Party < Game_Unit

  def albert_pokemons

    return members.select { |actor| actor.albert_pokemon? }

  end



  def albert_robots

    return members.select { |actor| actor.albert_robot? }

  end



  def albert_clones

    return members.select { |actor| actor.albert_clone? }

  end

end



#==============================================================================

# ■ 使用範例

#------------------------------------------------------------------------------

# if user.albert_pokemon?

# if target.albert_robot?

# robots = $game_party.members.select { |actor| actor.albert_robot? }

# robots = $game_party.albert_robots

#==============================================================================



#==============================================================================

# ■ v1.1 OverDrive / 怒氣 Note 範例

#------------------------------------------------------------------------------

# <bonus_if_od 50:30>

# <bonus_per_od_percent:0.5>

# <bonus_per_od_100:10>

# <reduce_damage_if_od 50:20>

# <reduce_damage_per_od_percent:0.2>

# <state_chance_if_od 31,50:20>

# <state_chance_per_od_percent 31:0.2>

# <atb_bonus_if_od 50:50>

# <atb_bonus_per_od_percent:0.5>

#==============================================================================
