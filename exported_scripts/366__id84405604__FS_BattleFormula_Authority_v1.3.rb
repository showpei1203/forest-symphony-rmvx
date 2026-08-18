#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleFormula_Authority v1.3
# 【用途】Forest Symphony 戰鬥公式核心 Authority，集中命中／迴避／暴擊與平滑防禦整合；仍位於完整 Damage Pipeline 的中段。
# 【主要機制】它仍位於更長的傷害鏈中，不代表所有 make_obj_damage_value 都由此頁單獨決定；最終 ownership 需查 Battle Authority Map。
# 【主要影響】Game_Battler、ALBERT_BATTLE_FIX、ALBERT_BATTLE_RUNTIME_FIX
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAIN_ACTOR_MAX_ID、SUMMON_ACTOR_IDS、ACTOR_TARGET_WEIGHT、ENEMY_TARGET_WEIGHT、DISAPPEAR_STATE_ID、PROVOKE_STATE_ID、POSITION_WEIGHT、SUMMON_TARGET_WEIGHT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】Phase 10 已把技能等級命中回寫主 calc_hit；Phase 26 移除 YEZ calc_hit_jpsl 死 Wrapper並恢復 KGC <ignore evasion>；Phase 28 再退休本頁已被 FinalAuthority 覆寫的 elements_max_rate，中段傷害公式只呼叫最終 Element Authority。載入順序仍具有語意；登記 $imported：AlbertBattleFormulaRuntimeIntegration、EnemyLevelControl；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# PHASE6 ORIGINAL PAGE: 383 | BattleFormula_TargetFix
#==============================================================================
#==============================================================================
# Albert_RMVX_BattleFormula_TargetFix_RGSS2_v1_1.rb
#------------------------------------------------------------------------------
# For RPG Maker VX / RGSS2
# 放置位置：所有戰鬥、召喚、傷害、KGC_RateDamage、XRXSV44 相關腳本之下，Main 之上。
# 目的：
#  1. 統一「主角 / 召喚物 / 敵人」判定，不再用 eva == 6 當身分旗標。
#  2. 修正 random_target：挑釁優先、消失排除、站位/召喚物權重生效。
#  3. 覆寫最終命中、迴避、暴擊、屬性倍率與 XRXSV44 的 make_damage_value。
#  4. RGSS2 相容：不使用 Array#sample，不假設 Actor 有 note。
#==============================================================================

module ALBERT_BATTLE_FIX
  #--------------------------------------------------------------------------
  # 基本設定
  #--------------------------------------------------------------------------
  MAIN_ACTOR_MAX_ID = 6

  # 你的召喚物 Actor ID。若留空，會使用 actor.id > MAIN_ACTOR_MAX_ID 當過渡判斷。
  # 建議正式完成後，把召喚物 ID 全部列在這裡。
  SUMMON_ACTOR_IDS = [7, 8, 9, 10, 11, 12,
                      13, 14, 15, 16, 17, 18]

  # 可選：個別 Actor 目標權重覆蓋。例：{7=>20, 8=>35}
  ACTOR_TARGET_WEIGHT = {}

  # 可選：個別 Enemy 目標權重覆蓋。例：{15=>0}
  ENEMY_TARGET_WEIGHT = {}

  # 狀態 ID：沿用你目前的 Provoke / Disappear 設定
  DISAPPEAR_STATE_ID = 13
  PROVOKE_STATE_ID   = 14

  # 站位權重：對應 class.position
  # 原公式 100 - position * 45 等同：0=>100, 1=>55, 2=>10
  # 若你覺得後排太安全，可把 2 改成 25。
  POSITION_WEIGHT = {
    0 => 100,
    1 => 55,
    2 => 10
  }

  # 召喚物在敵方亂數目標輪盤中的基礎權重
  SUMMON_TARGET_WEIGHT = 25

  # 傷害公式設定
  DEF_CONST     = 120.0   # 越高，防禦減傷越不明顯；越低，防禦越有感
  CRIT_MULT     = 170     # 170 = 1.7 倍。原本 3 倍太容易讓 Boss 戰變賭場
  MIN_HIT       = 10
  MAX_HIT       = 97
  MAX_EVA       = 60
  MAX_CRIT      = 60
  MIN_DAMAGE    = 1

  # AGI 對命中 / 迴避 / 暴擊的影響
  HIT_AGI_RATE  = 0.15
  EVA_AGI_RATE  = 0.08
  CRIT_AGI_RATE = 0.05

  # 穿透上限。80 代表最高穿透 80% 防禦
  MAX_PEN_RATE  = 80

  # 屬性倍率相乘後的上下限
  ELEMENT_RATE_MIN = -100
  ELEMENT_RATE_MAX = 400

  #--------------------------------------------------------------------------
  # RGSS2 安全 Note 讀取：Actor 不使用 note；Enemy / Skill / Item / Equip / State 可用
  #--------------------------------------------------------------------------
  def self.note(obj)
    return "" if obj == nil
    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil
    return ""
  end

  def self.note_number(obj, key, default_value = 0)
    text = note(obj)
    if text =~ /<#{key}\s*:\s*(-?\d+)>/i
      return $1.to_i
    end
    return default_value
  end

  def self.note_tag?(obj, key)
    text = note(obj)
    return text =~ /<#{key}>/i ? true : false
  end

  def self.note_ele_number(obj, key, element_id, default_value = 0)
    text = note(obj)
    # 支援 <ele_res 13:25> 與 <ele_res[13]:25>
    if text =~ /<#{key}\s+#{element_id}\s*:\s*(-?\d+)>/i
      return $1.to_i
    end
    if text =~ /<#{key}\[#{element_id}\]\s*:\s*(-?\d+)>/i
      return $1.to_i
    end
    return default_value
  end
end

#==============================================================================
# Game_Battler：單位類型、權重、Note 輔助
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # 單位類型
  #--------------------------------------------------------------------------
  def albert_actor_id
    return actor? ? self.id : 0
  end

  def albert_enemy_id
    return (!actor? && self.respond_to?(:enemy_id)) ? self.enemy_id : 0
  end

  def albert_summon?
    return false unless actor?
    return true if ALBERT_BATTLE_FIX::SUMMON_ACTOR_IDS.include?(self.id)
    return true if self.id > ALBERT_BATTLE_FIX::MAIN_ACTOR_MAX_ID
    return false
  end

  def albert_main_actor?
    return actor? && !albert_summon?
  end

  def albert_enemy_note
    return "" if actor?
    return ALBERT_BATTLE_FIX.note(self.enemy) if self.respond_to?(:enemy)
    return ""
  end

  def albert_no_random_target?
    return true if state?(ALBERT_BATTLE_FIX::DISAPPEAR_STATE_ID)
    return true if !actor? && ALBERT_BATTLE_FIX.note_tag?(self.enemy, "no_random_target") rescue false
    return true if !actor? && albert_enemy_note.include?("対象不可")
    return false
  end

  def albert_targetable_unit?
    return false unless exist?
    return false if albert_no_random_target?
    return true
  end

  def albert_provoke?
    return state?(ALBERT_BATTLE_FIX::PROVOKE_STATE_ID)
  end

  #--------------------------------------------------------------------------
  # 站位 / 召喚物 / 敵人目標權重
  #--------------------------------------------------------------------------
  def albert_position_weight
    pos = 0
    if actor?
      begin
        pos = self.class.position.to_i
      rescue
        pos = 0
      end
    end
    return ALBERT_BATTLE_FIX::POSITION_WEIGHT[pos] || 0
  end

  def albert_target_weight
    if actor?
      custom = ALBERT_BATTLE_FIX::ACTOR_TARGET_WEIGHT[self.id]
      return custom if custom != nil
      return ALBERT_BATTLE_FIX::SUMMON_TARGET_WEIGHT if albert_summon?
      return albert_position_weight
    else
      custom = ALBERT_BATTLE_FIX::ENEMY_TARGET_WEIGHT[albert_enemy_id]
      return custom if custom != nil
      note_value = ALBERT_BATTLE_FIX.note_number(self.enemy, "target_weight", -999999) rescue -999999
      return note_value if note_value != -999999
      return 100
    end
  end

  #--------------------------------------------------------------------------
  # 傷害公式用輔助
  #--------------------------------------------------------------------------
  def albert_notes_for_user
    text = ""
    if actor?
      if self.respond_to?(:equips)
        for item in self.equips.compact
          text += ALBERT_BATTLE_FIX.note(item)
        end
      end
    else
      text += albert_enemy_note
    end
    for state in states.compact
      text += ALBERT_BATTLE_FIX.note(state)
    end
    return text
  end

  def albert_notes_for_target
    text = ""
    if actor?
      if self.respond_to?(:armors)
        for item in self.armors.compact
          text += ALBERT_BATTLE_FIX.note(item)
        end
      end
    else
      text += albert_enemy_note
    end
    for state in states.compact
      text += ALBERT_BATTLE_FIX.note(state)
    end
    return text
  end

  def albert_number_from_text(text, key, default_value = 0)
    if text =~ /<#{key}\s*:\s*(-?\d+)>/i
      return $1.to_i
    end
    return default_value
  end

  def albert_ele_number_from_text(text, key, element_id, default_value = 0)
    if text =~ /<#{key}\s+#{element_id}\s*:\s*(-?\d+)>/i
      return $1.to_i
    end
    if text =~ /<#{key}\[#{element_id}\]\s*:\s*(-?\d+)>/i
      return $1.to_i
    end
    return default_value
  end

  def albert_pen_rate(obj = nil)
    pen = 0
    pen += ALBERT_BATTLE_FIX.note_number(obj, "pen_rate", 0)
    pen += albert_number_from_text(albert_notes_for_user, "pen_rate", 0)
    pen = [[pen, 0].max, ALBERT_BATTLE_FIX::MAX_PEN_RATE].min
    return pen
  end

  def albert_crit_bonus(obj = nil)
    bonus = 0
    bonus += ALBERT_BATTLE_FIX.note_number(obj, "crit_rate", 0)
    bonus += albert_number_from_text(albert_notes_for_user, "crit_rate", 0)
    return bonus
  end

  # 目標對某元素的額外抗性。正數 = 減少受到該屬性傷害。
  # 例：<ele_res 13:25> 表示對 13 號屬性再減 25% 倍率。
  #     <ele_weak 13:50> 表示對 13 號屬性再增加 50% 倍率。
  def albert_element_extra_rate(element_id)
    text = albert_notes_for_target
    res  = albert_ele_number_from_text(text, "ele_res", element_id, 0)
    weak = albert_ele_number_from_text(text, "ele_weak", element_id, 0)
    return weak - res
  end
end

#==============================================================================
# Game_Battler：命中、迴避、暴擊、屬性、傷害核心
# 注意：不覆寫 make_obj_damage_value，保留 KGC_RateDamage 對比例傷害的外層處理。
#      只覆寫 make_damage_value，讓 XRXSV44 / 普攻物件仍可呼叫。
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # 最終命中率
  #--------------------------------------------------------------------------
  def calc_hit(user, obj = nil)
    if obj == nil
      hit = user.hit
      physical = true
    else
      hit = obj.hit > 0 ? obj.hit : user.hit
      physical = obj.physical_attack
    end

    hit /= 4 if physical && user.reduce_hit_ratio?
    hit += user.hit_rate_change_value(obj) if user.respond_to?(:hit_rate_change_value)
    hit += ((user.agi - self.agi) * ALBERT_BATTLE_FIX::HIT_AGI_RATE).to_i

    # 保留 Phase 9.1 舊鏈語意：先讓 BattleFormula TargetFix 自己 clamp 一次，
    # 再加入技能等級命中修正，最後再 clamp。如此即使 level_hit 為負值也等價。
    hit = [[hit, ALBERT_BATTLE_FIX::MIN_HIT].max, ALBERT_BATTLE_FIX::MAX_HIT].min

    # Phase 10：原 RuntimeIntegration 的技能等級命中加成直接回寫主 calc_hit。
    # 這兩段原本位於同一 Script Page，合併後不再需要 albert_bfrt_old_calc_hit alias。
    if obj != nil && obj.is_a?(RPG::Skill) && user != nil &&
       user.respond_to?(:skill_level) && obj.respond_to?(:level_hit)
      begin
        level = user.skill_level(obj).to_i
        table = obj.level_hit
        if table != nil && table[level] != nil
          hit += table[level].to_i
        end
      rescue
      end
    end

    hit = [[hit, ALBERT_BATTLE_FIX::MIN_HIT].max, ALBERT_BATTLE_FIX::MAX_HIT].min
    return hit
  end

  #--------------------------------------------------------------------------
  # 最終迴避率
  #--------------------------------------------------------------------------
  def calc_eva(user, obj = nil)
    # Phase 26：FS_BattleFormula 直接覆寫 calc_eva 後，舊 KGC ReproduceFunctions
    # 的「普通攻擊 + user.ignore_eva => 0 迴避」曾被遮蔽。
    # 這裡直接回寫同一語意，避免最終 Authority 吃掉既有裝備／被動效果。
    if obj == nil && user != nil && user.respond_to?(:ignore_eva) && user.ignore_eva
      return 0
    end

    eva_value = self.eva
    eva_value = 0 if obj != nil && !obj.physical_attack
    eva_value = 0 unless parriable?

    if eva_value > 0
      eva_value += eva_rate_change_value(obj) if self.respond_to?(:eva_rate_change_value)
      eva_value += ((self.agi - user.agi) * ALBERT_BATTLE_FIX::EVA_AGI_RATE).to_i
    end

    eva_value = [[eva_value, 0].max, ALBERT_BATTLE_FIX::MAX_EVA].min
    return eva_value
  end

  #--------------------------------------------------------------------------
  # 暴擊判定
  #--------------------------------------------------------------------------
  def evaluate_critical(user, obj)
    return false if prevent_critical
    percent = user.cri
    percent += obj.cri if obj != nil && obj.respond_to?(:cri)
    percent += user.albert_crit_bonus(obj)
    agi_bonus = ((user.agi - self.agi) * ALBERT_BATTLE_FIX::CRIT_AGI_RATE).to_i
    percent += agi_bonus if agi_bonus > 0
    percent = [[percent, 0].max, ALBERT_BATTLE_FIX::MAX_CRIT].min
    return rand(100) < percent
  end

  #--------------------------------------------------------------------------
  # 多屬性倍率（Phase 28）
  #--------------------------------------------------------------------------
  # 不再在 BattleFormula 內定義 elements_max_rate；戰鬥執行時直接呼叫
  # 後載入的 FS_ElementRate_FinalAuthority v2.0，避免同一倍率有兩份實作。

  #--------------------------------------------------------------------------
  # 平滑防禦傷害公式
  # Damage = (Base + Power) * DEF_CONST / (DEF_CONST + EffectiveDefense)
  #--------------------------------------------------------------------------
  def make_damage_value(user, obj)
    @critical = false
    damage = obj.base_damage.to_i

    if damage != 0
      sign = damage < 0 ? -1 : 1
      base = damage.abs.to_f

      atk_f = obj.respond_to?(:atk_f) ? obj.atk_f : 0
      spi_f = obj.respond_to?(:spi_f) ? obj.spi_f : 0
      coef_sum = [atk_f + spi_f, 1].max

      # 回復技能：保留 base_damage < 0 的語義，不套敵方防禦
      if sign < 0
        power = (user.atk * atk_f + user.spi * spi_f) / 100.0
        damage = -(base + power).to_i
      else
        power = (user.atk * atk_f + user.spi * spi_f) / 100.0

        if obj.ignore_defense
          effective_def = 0.0
        else
          mdef = self.respond_to?(:mnd) ? self.mnd : self.spi
          effective_def = (self.def * atk_f + mdef * spi_f) / coef_sum.to_f
          effective_def *= (100 - user.albert_pen_rate(obj)) / 100.0
          effective_def = [effective_def, 0.0].max
        end

        damage = (base + power) * ALBERT_BATTLE_FIX::DEF_CONST /
                 (ALBERT_BATTLE_FIX::DEF_CONST + effective_def)

        if obj.respond_to?(:has_critical?) && obj.has_critical?
          @critical = evaluate_critical(user, obj)
          damage = damage * ALBERT_BATTLE_FIX::CRIT_MULT / 100.0 if @critical
        end

        element_rate_value = elements_max_rate(obj.element_set)
        damage = damage * element_rate_value / 100.0

        if damage == 0 && element_rate_value > 0 && obj.respond_to?(:graze?) && obj.graze?
          damage = rand(2)
        end

        damage = apply_variance(damage.to_i, obj.variance)
        damage = apply_guard(damage)
        damage = [damage, ALBERT_BATTLE_FIX::MIN_DAMAGE].max if element_rate_value > 0
      end
    end

    if obj.damage_to_mp
      @mp_damage = damage.to_i
    else
      @hp_damage = damage.to_i
    end
    return damage.to_i
  end
end

#==============================================================================
# 使用方式補充
#------------------------------------------------------------------------------
# 1. Actor 沒 Note：召喚物請填 SUMMON_ACTOR_IDS 或用 actor.id > MAIN_ACTOR_MAX_ID 過渡。
# 2. Enemy 有 Note，可使用：
#      <target_weight:50>
#      <no_random_target>
# 3. Skill / Weapon / Armor / State 可用：
#      <pen_rate:20>      # 穿透 20% 防禦
#      <crit_rate:10>     # 暴擊率 +10
#      <ele_res 13:25>    # 對 13 號屬性倍率 -25
#      <ele_weak 13:50>   # 對 13 號屬性倍率 +50
#==============================================================================

#==============================================================================
# PHASE6 ORIGINAL PAGE: 384 | BattleFormula_RuntimeIntegration
#==============================================================================
#==============================================================================
# Albert_BattleFormula_RuntimeIntegration_v1_0.rb
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 放置位置：
#   緊接在「BattleFormula_TargetFix」之下，
#   並放在「SummonEquipSkill_PowerAndDesc」之上。
#
# 修正內容：
#   1. 恢復 YEZ Job System: Skill Levels 的技能等級命中加成。
#   2. 讓 BattleFormula_TargetFix 的平滑防禦概念真正進入
#      make_obj_damage_value 的實際技能／物品傷害流程。
#
# 設計原則：
#   - 先完整執行既有傷害 alias 鏈，再只修正「標準正傷害」的防禦倍率。
#   - ACDF 自訂傷害公式保持原樣，因為自訂公式本來就應由公式作者自己決定。
#   - Cover、MP 轉換／吸收等若已把 HP/MP 傷害改成 0，則不再強行修正。
#   - 後面 SummonEquipSkill、ComboCore、CharacterMechanicCore、
#     MechanicExpansion 的固定追加傷害仍在本補丁之後執行，因此不會被防禦倍率誤縮放。
#==============================================================================

$imported = {} if $imported == nil
$imported["AlbertBattleFormulaRuntimeIntegration"] = true

module ALBERT_BATTLE_RUNTIME_FIX
  VERSION = "1.3"
  PRESERVE_KGC_IGNORE_EVA = true

  # 是否啟用平滑防禦實戰整合
  ENABLE_SMOOTH_DEFENSE = true

  # 比率極小時視為不修正，避免無意義浮點誤差。
  RATIO_EPSILON = 0.0001
end

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 修正 1：技能等級命中加成
  #--------------------------------------------------------------------------
  # Phase 10 已直接整合到上方主 calc_hit，因此不再建立額外 alias。

  #--------------------------------------------------------------------------
  # ● 修正 2：實際技能傷害流程套用平滑防禦
  #
  # 做法：
  #   1. 先讓目前既有 make_obj_damage_value 完整執行。
  #   2. 重新計算「舊線性扣防」與「新平滑防禦」在核心公式階段的比率。
  #   3. 將該比率套回已完成屬性、暴擊、分散、Guard、技能等級等處理後的傷害。
  #
  # 如此可保留既有 alias 鏈，又能讓防禦公式真正進入實戰。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_bfrt_old_make_obj_damage_value)
    alias albert_bfrt_old_make_obj_damage_value make_obj_damage_value
  end

  def make_obj_damage_value(user, obj)
    albert_bfrt_old_make_obj_damage_value(user, obj)

    return unless ALBERT_BATTLE_RUNTIME_FIX::ENABLE_SMOOTH_DEFENSE
    return if user == nil || obj == nil
    return unless defined?(ALBERT_BATTLE_FIX)

    ratio = albert_bfrt_smooth_defense_ratio(user, obj)
    return if ratio == nil
    return if (ratio - 1.0).abs < ALBERT_BATTLE_RUNTIME_FIX::RATIO_EPSILON

    if obj.respond_to?(:damage_to_mp) && obj.damage_to_mp
      return if @mp_damage == nil || @mp_damage <= 0
      @mp_damage = (@mp_damage.to_f * ratio).to_i
      @mp_damage = 1 if @mp_damage <= 0
    else
      return if @hp_damage == nil || @hp_damage <= 0
      @hp_damage = (@hp_damage.to_f * ratio).to_i
      @hp_damage = 1 if @hp_damage <= 0
    end
  end

  #--------------------------------------------------------------------------
  # ● 計算平滑防禦／舊線性扣防的核心比率
  #--------------------------------------------------------------------------
  def albert_bfrt_smooth_defense_ratio(user, obj)
    return nil unless obj.respond_to?(:base_damage)
    return nil if obj.base_damage.to_i <= 0
    return nil if obj.respond_to?(:ignore_defense) && obj.ignore_defense

    # ACDF 是明確自訂公式，不擅自插手。
    if obj.respond_to?(:acdf)
      return nil if obj.acdf.to_i > 0
    end

    raw = obj.base_damage.to_f

    #--------------------------------------------------------------
    # Custom Dmg Formulas RD：Base Damage 前置倍率
    #--------------------------------------------------------------
    level_ok = false
    begin
      level_ok = true if user.is_a?(Game_Actor)
      level_ok = true if $imported != nil && $imported["EnemyLevelControl"]
    rescue
      level_ok = false
    end

    user_level = 0
    begin
      user_level = user.level.to_i if user.respond_to?(:level)
    rescue
      user_level = 0
    end

    if level_ok && user_level > 0
      raw *= user_level if obj.respond_to?(:mul_level) && obj.mul_level
      raw /= user_level if obj.respond_to?(:div_level) && obj.div_level
    end

    if obj.respond_to?(:mul_variable) && obj.mul_variable.to_i > 0
      raw *= $game_variables[obj.mul_variable.to_i].to_f
    end

    if obj.respond_to?(:div_variable) && obj.div_variable.to_i > 0
      value = $game_variables[obj.div_variable.to_i].to_f
      return nil if value == 0.0
      raw /= value
    end

    #--------------------------------------------------------------
    # 取得 YEM / Custom Dmg Formula 使用中的倍率常數。
    # 若意外不存在，退回 VX 預設近似值。
    #--------------------------------------------------------------
    atk_f_mul = 4.0
    atk_d_mul = 2.0
    def_f_mul = 0.0
    def_d_mul = 0.0
    spi_f_mul = 2.0
    spi_d_mul = 1.0
    agi_f_mul = 0.0
    agi_d_mul = 0.0

    begin
      atk_f_mul = YE::BATTLE::SKILL::ATK_F.to_f
      atk_d_mul = YE::BATTLE::SKILL::ATK_D.to_f
      def_f_mul = YE::BATTLE::SKILL::DEF_F.to_f
      def_d_mul = YE::BATTLE::SKILL::DEF_D.to_f
      spi_f_mul = YE::BATTLE::SKILL::SPI_F.to_f
      spi_d_mul = YE::BATTLE::SKILL::SPI_D.to_f
      agi_f_mul = YE::BATTLE::SKILL::AGI_F.to_f
      agi_d_mul = YE::BATTLE::SKILL::AGI_D.to_f
    rescue
    end

    atk_f = obj.respond_to?(:atk_f) ? obj.atk_f.to_f : 0.0
    newatk_f = obj.respond_to?(:newatk_f) ? obj.newatk_f.to_f : 0.0
    def_f = obj.respond_to?(:def_f) ? obj.def_f.to_f : 0.0
    spi_f = obj.respond_to?(:spi_f) ? obj.spi_f.to_f : 0.0
    newspi_f = obj.respond_to?(:newspi_f) ? obj.newspi_f.to_f : 0.0
    agi_f = obj.respond_to?(:agi_f) ? obj.agi_f.to_f : 0.0

    atk_coef = newatk_f > 0.0 ? newatk_f : atk_f
    spi_coef = newspi_f > 0.0 ? newspi_f : spi_f

    #--------------------------------------------------------------
    # 攻擊端：完全依目前 Custom Dmg Formulas RD 的實際寫法重建。
    # 注意：原腳本的 newspi_f / agi_f 使用 user.def，這裡刻意保持一致，
    # 不趁修 bug 時偷偷改戰鬥平衡。
    #--------------------------------------------------------------
    raw += user.atk.to_f * atk_f_mul * atk_coef / 100.0
    raw += user.def.to_f * def_f_mul * def_f / 100.0 if def_f > 0.0

    if newspi_f > 0.0
      raw += user.def.to_f * spi_f_mul * newspi_f / 100.0
    else
      raw += user.spi.to_f * spi_f_mul * spi_f / 100.0
    end

    raw += user.def.to_f * agi_f_mul * agi_f / 100.0 if agi_f > 0.0

    # HP / MP 系數
    raw += user.hp.to_f * obj.hp_hi.to_f / 100.0 if obj.respond_to?(:hp_hi) && obj.hp_hi.to_f > 0.0
    if obj.respond_to?(:hp_lo) && obj.hp_lo.to_f > 0.0
      raw += (user.maxhp - user.hp).to_f * obj.hp_lo.to_f / 100.0
    end
    raw += user.mp.to_f * obj.mp_hi.to_f / 100.0 if obj.respond_to?(:mp_hi) && obj.mp_hi.to_f > 0.0
    if obj.respond_to?(:mp_lo) && obj.mp_lo.to_f > 0.0
      raw += (user.maxmp - user.mp).to_f * obj.mp_lo.to_f / 100.0
    end

    # 等級固定加減
    if level_ok && user_level > 0
      raw += user_level if obj.respond_to?(:add_level) && obj.add_level
      raw -= user_level if obj.respond_to?(:sub_level) && obj.sub_level
    end

    # 變數固定加減。保持你目前原腳本中 add_variable * 5 的客製設定。
    if obj.respond_to?(:add_variable) && obj.add_variable.to_i > 0
      raw += $game_variables[obj.add_variable.to_i].to_f * 5.0
    end
    if obj.respond_to?(:sub_variable) && obj.sub_variable.to_i > 0
      raw -= $game_variables[obj.sub_variable.to_i].to_f
    end

    #--------------------------------------------------------------
    # 舊公式的線性防禦扣除量
    #--------------------------------------------------------------
    legacy_penalty = 0.0
    weighted_def_sum = 0.0
    weight_sum = 0.0

    if atk_coef > 0.0 && atk_d_mul > 0.0
      weight = atk_coef * atk_d_mul
      legacy_penalty += self.def.to_f * weight / 100.0
      weighted_def_sum += self.def.to_f * weight
      weight_sum += weight
    end

    if def_f > 0.0 && def_d_mul > 0.0
      weight = def_f * def_d_mul
      legacy_penalty += self.def.to_f * weight / 100.0
      weighted_def_sum += self.def.to_f * weight
      weight_sum += weight
    end

    if spi_coef > 0.0 && spi_d_mul > 0.0
      weight = spi_coef * spi_d_mul
      spi_def = newspi_f > 0.0 ? self.def.to_f : self.spi.to_f
      legacy_penalty += spi_def * weight / 100.0
      weighted_def_sum += spi_def * weight
      weight_sum += weight
    end

    if agi_f > 0.0 && agi_d_mul > 0.0
      weight = agi_f * agi_d_mul
      legacy_penalty += self.def.to_f * weight / 100.0
      weighted_def_sum += self.def.to_f * weight
      weight_sum += weight
    end

    return nil if weight_sum <= 0.0

    # Custom Dmg Formulas RD 的最低傷害。
    min_damage = 1.0
    begin
      min_damage = YE::BATTLE::NATK::MIN_DMG.to_f
    rescue
      min_damage = ALBERT_BATTLE_FIX::MIN_DAMAGE.to_f
    end
    min_damage = 1.0 if min_damage <= 0.0

    legacy_core = raw - legacy_penalty
    legacy_core = min_damage if legacy_core < min_damage

    effective_def = weighted_def_sum / weight_sum

    # 穿透：沿用 BattleFormula_TargetFix 的 Note 規格。
    begin
      if user.respond_to?(:albert_pen_rate)
        effective_def *= (100.0 - user.albert_pen_rate(obj).to_f) / 100.0
      end
    rescue
    end
    effective_def = 0.0 if effective_def < 0.0

    smooth_core = raw * ALBERT_BATTLE_FIX::DEF_CONST.to_f /
                  (ALBERT_BATTLE_FIX::DEF_CONST.to_f + effective_def)
    smooth_core = min_damage if smooth_core < min_damage

    return nil if legacy_core <= 0.0
    return smooth_core / legacy_core
  end
end

#==============================================================================
# END
#==============================================================================
