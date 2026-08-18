#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleBalanceCore v1.4
# 【用途】Forest Symphony 傷害平衡核心；Phase 28 起不再保存重複 Element Rank／Type 資料或 element_rate wrapper。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Battler、Scene_Battle、FS_BATTLE_BALANCE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：NORMAL_ATTACK_BASE_DAMAGE、DEFAULT_NORMAL_ATK_RATE、MIN_NORMAL_ATK_RATE、MAX_NORMAL_ATK_RATE、LEGACY_NORMAL_POWER_RATE、ELEMENT_RATE_MIN、ELEMENT_RATE_MAX、CRITICAL_RATE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Battle Balance Core；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_BattleBalanceCore_v1_4

#------------------------------------------------------------------------------

# RPG Maker VX / RGSS2

#

# 【安裝位置】

#   BattleFormula_TargetFix

#   BattleFormula_RuntimeIntegration

#   FS_BattleBalanceCore_v1_4        ← 本腳本

#   SummonEquipSkill_PowerAndDesc

#   ComboCore / CharacterMechanicCore / IvyClone

#   FS_DB_AutoSetup_11_FieldWeather

#   Main

#

# 【功能】

# 1. 普通攻擊改用與技能相同尺度：Base＋ATK倍率，再套平滑防禦。

# 2. 取消普攻額外等級倍率，等級成長只透過 ATK／裝備成長。

# 3. 五階武器建議普攻 ATK 係數：110／120／130／140／150%。

# 4. 相容舊 <normal_power:N>，自動換算為新係數；新資料建議使用
#    <normal_atk_rate:N>。

# 5. 保留既有普攻屬性、裝備特效、暴擊、Variance、Guard、吸血流程。

# 6. 暴擊統一為 1.7 倍，並安全處理敵方 Skill 的 nil cri。

# 7. 修正 Pokémon 屬性表未進入最終 element_rate 的問題。

# 8. 多屬性仍相乘，但總倍率上限改為 250%。

# 9. 修正 ATB charge_set 修改快取 Array，造成詠唱 bonus 每次累積。

#==============================================================================



$imported = {} if $imported == nil

$imported["FS Battle Balance Core"] = "1.4"



module FS_BATTLE_BALANCE

  # 普攻核心：與技能使用同一個 ATK_F 尺度。
  # 例如一階武器 110，等同技能 atk_f = 110 的攻擊端貢獻。
  NORMAL_ATTACK_BASE_DAMAGE = 20
  DEFAULT_NORMAL_ATK_RATE = 100
  MIN_NORMAL_ATK_RATE = 50
  MAX_NORMAL_ATK_RATE = 200

  # 舊資料相容。主角五階武器原值會轉成 110／120／130／140／150。
  LEGACY_NORMAL_POWER_RATE = {
    55  => 110,
    260 => 110,
    300 => 120,
    340 => 130,
    380 => 140,
    420 => 150
  }

  ELEMENT_RATE_MIN = -100

  ELEMENT_RATE_MAX = 250

  CRITICAL_RATE = 170



  # Phase 28：Element ID、Type Chart、Database Rank 與裝備屬性倍率
  # 已由 FS_ELEMENT_TYPE_DATA / FS_ElementRate_FinalAuthority v2.0 統一管理。

  def self.note_number(obj, key, default_value = 0)

    return default_value if obj == nil || !obj.respond_to?(:note)

    if obj.note.to_s =~ /<#{key}\s*:\s*(-?\d+)>/i

      return $1.to_i

    end

    return default_value

  end



  def self.clamp_normal_atk_rate(value)

    value = value.to_i

    return [[value, MIN_NORMAL_ATK_RATE].max, MAX_NORMAL_ATK_RATE].min

  end



  # 舊 <normal_power:N> 轉成新 ATK 係數。
  # 50～100 的舊值以 Power 50 = 100% 為基準；
  # 240 以上沿用舊五階間距換算，避免舊資料突然失效。
  def self.legacy_power_to_atk_rate(value)

    value = value.to_i

    mapped = LEGACY_NORMAL_POWER_RATE[value]

    return clamp_normal_atk_rate(mapped) unless mapped == nil

    if value > 0 && value <= 100

      return clamp_normal_atk_rate(value * 2)

    elsif value >= 240

      return clamp_normal_atk_rate((45.0 + value / 4.0).round)

    end

    return clamp_normal_atk_rate(value)

  end



  def self.normal_atk_rate(battler)

    return DEFAULT_NORMAL_ATK_RATE if battler == nil

    if battler.respond_to?(:weapons)

      values = []

      battler.weapons.compact.each do |weapon|

        value = note_number(weapon, "normal_atk_rate", 0)

        if value > 0

          values.push(clamp_normal_atk_rate(value))

          next

        end

        legacy = note_number(weapon, "normal_power", 0)

        values.push(legacy_power_to_atk_rate(legacy)) if legacy > 0

      end

      unless values.empty?

        return values.inject(0) { |sum, value| sum + value } / values.size

      end

    end

    return DEFAULT_NORMAL_ATK_RATE

  end



  # 讓其他舊補丁若曾呼叫 normal_power，仍取得可用的新係數。
  def self.normal_power(battler)

    return normal_atk_rate(battler)

  end



  def self.attack_stat_multiplier

    begin

      return YE::BATTLE::SKILL::ATK_F.to_f

    rescue

      return 2.0

    end

  end

end



class Game_Battler

  #--------------------------------------------------------------------------

  # ● 安全暴擊判定

  #--------------------------------------------------------------------------

  # TargetFix 舊版直接做 percent += obj.cri。

  # 某些 Skill Cache 尚未建立時 obj.cri 可能為 nil。

  def evaluate_critical(user, obj = nil)

    return false if user == nil

    return false if prevent_critical



    if obj != nil && obj.respond_to?(:has_critical?)

      return false unless obj.has_critical?

    end



    percent = user.respond_to?(:cri) ? user.cri.to_i : 0

    percent += obj.cri.to_i if obj != nil && obj.respond_to?(:cri)

    if user.respond_to?(:albert_crit_bonus)

      percent += user.albert_crit_bonus(obj).to_i

    end



    user_agi = user.respond_to?(:agi) ? user.agi.to_i : 0

    target_agi = respond_to?(:agi) ? agi.to_i : 0

    agi_rate = 0.0

    if defined?(ALBERT_BATTLE_FIX) &&

       ALBERT_BATTLE_FIX.const_defined?(:CRIT_AGI_RATE)

      agi_rate = ALBERT_BATTLE_FIX::CRIT_AGI_RATE.to_f

    end

    bonus = ((user_agi - target_agi) * agi_rate).to_i

    percent += bonus if bonus > 0



    max_crit = 60

    if defined?(ALBERT_BATTLE_FIX) &&

       ALBERT_BATTLE_FIX.const_defined?(:MAX_CRIT)

      max_crit = ALBERT_BATTLE_FIX::MAX_CRIT.to_i

    end

    percent = [[percent.to_i, 0].max, max_crit].min

    return rand(100) < percent

  end



  # Custom Dmg Formulas 的 common_critical 原本是空方法。

  # 接回上方的安全暴擊判定。

  def common_critical(user, obj = nil)

    @critical = evaluate_critical(user, obj)

  end



  def critical_damage(damage)

    return damage * FS_BATTLE_BALANCE::CRITICAL_RATE / 100.0

  end



  #--------------------------------------------------------------------------
  # ● Element Rate（Phase 28）
  #--------------------------------------------------------------------------
  # 本頁不再覆寫 element_rate / elements_max_rate。
  # Pokémon Type、資料庫 Rank、State、防具 KGC Element Options、
  # 多屬性倍率與最終 Clamp 全部集中於 FS_ElementRate_FinalAuthority v2.0。

  #--------------------------------------------------------------------------
  # ● 普通攻擊平滑防禦整合
  #--------------------------------------------------------------------------
  # 先完整執行舊普攻流程，保留屬性、裝備特效、暴擊、Variance、Guard、
  # 吸血與其他 alias；再用「新核心／舊核心」比率換算最終傷害。
  #
  # 新核心：
  #   (Base + ATK × 技能ATK倍率 × normal_atk_rate%)
  #   × DEF_CONST / (DEF_CONST + 有效DEF)
  #
  # 普攻不再額外乘角色等級。角色成長已經存在於 ATK，不需重複發薪。
  unless method_defined?(:fs_balance_original_make_attack_damage_value)

    alias fs_balance_original_make_attack_damage_value make_attack_damage_value

  end



  def make_attack_damage_value(attacker)

    fs_balance_original_make_attack_damage_value(attacker)

    return if attacker == nil

    return if @hp_damage == nil || @hp_damage <= 0



    old_core = fs_balance_legacy_attack_core(attacker)

    new_core = fs_balance_smooth_attack_core(attacker)

    return if old_core <= 0.0 || new_core <= 0.0



    value = @hp_damage.to_f * new_core / old_core

    @hp_damage = [value.round, 1].max

  end



  # Custom Dmg Formulas 現行普攻的核心值。
  # 保持原式的 to_i 時點，讓比率能準確抵消舊等級公式。
  def fs_balance_legacy_attack_core(attacker)

    level = attacker.respond_to?(:level) ? attacker.level.to_i : 1

    level = 1 if level < 1

    attack = attacker.respond_to?(:atk) ? attacker.atk.to_f : 1.0

    defense = respond_to?(:def) ? self.def.to_f : 1.0

    defense = 1.0 if defense <= 0.0



    value = (((((2.0 * level / 5.0) + 2.0) * 50.0 *

             (attack / defense)) / 50.0) + 2.0).to_i

    value = 1 if value < 1

    return value.to_f

  end



  def fs_balance_smooth_attack_core(attacker)

    rate = FS_BATTLE_BALANCE.normal_atk_rate(attacker).to_f

    atk_mul = FS_BATTLE_BALANCE.attack_stat_multiplier

    raw = FS_BATTLE_BALANCE::NORMAL_ATTACK_BASE_DAMAGE.to_f

    raw += attacker.atk.to_f * atk_mul * rate / 100.0



    effective_def = self.def.to_f

    if attacker.respond_to?(:albert_pen_rate)

      begin

        pen = attacker.albert_pen_rate(nil).to_f

        effective_def *= (100.0 - pen) / 100.0

      rescue

      end

    end

    effective_def = 0.0 if effective_def < 0.0



    def_const = 120.0

    if defined?(ALBERT_BATTLE_FIX) &&

       ALBERT_BATTLE_FIX.const_defined?(:DEF_CONST)

      def_const = ALBERT_BATTLE_FIX::DEF_CONST.to_f

    end

    def_const = 1.0 if def_const <= 0.0



    value = raw * def_const / (def_const + effective_def)

    value = 1.0 if value < 1.0

    return value

  end

end



# Tankentai ATB 原 charge_set 直接修改 Skill／Weapon 的快取 Array。

# 每次使用技能都會再次累加 charge bonus。改用 clone，並限制 0%～200%。

class Scene_Battle < Scene_Base

  def charge_set(member)

    act_type = member.charge.clone



    if member.actor? && member.action.attack? && member.weapon_id != 0

      if member.weapons[0] != nil

        act_type = member.weapons[0].charge.clone

      end

      if member.weapons[1] != nil

        act_type2 = member.weapons[1].charge.clone

        act_type[1] = (act_type[1] + act_type2[1]) / 2

      end

    elsif member.action.attack?

      if member.actor? && member.weapon_id != 0

        act_type = $data_weapons[member.weapon_id].charge.clone

      elsif !member.actor? && member.weapon != 0

        act_type = $data_weapons[member.weapon].charge.clone

      end

    end



    if member.action.skill?

      act_type = $data_skills[member.action.skill_id].charge.clone

    elsif member.action.item?

      act_type = $data_items[member.action.item_id].charge.clone

    end



    if member.actor?

      if member.weapon_id != 0

        act_type[1] += $data_weapons[member.weapon_id].charge_bonus

      end

      member.armors.compact.each do |armor|

        act_type[1] += armor.charge_bonus

      end

    end

    member.states.compact.each do |state|

      act_type[1] += state.charge_bonus

    end



    act_type[1] = [[act_type[1].to_i, 0].max, 200].min

    return act_type

  end

end
