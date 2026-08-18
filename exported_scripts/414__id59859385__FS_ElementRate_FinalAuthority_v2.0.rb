#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ElementRate_FinalAuthority v2.0
# 【用途】Forest Symphony 最終屬性倍率 Authority。統一 Pokémon 雙屬性、資料庫 Rank、State、防具 Element Options、吸收與多屬性技能倍率。
# 【主要機制】所有 Game_Battler／Game_Actor／Game_Enemy#element_rate 與 elements_max_rate 最後都導向 FS_ELEMENT_FINAL；前段腳本只提供 Type／裝備／資料庫資料，不再各自覆寫最終倍率。
# 【主要影響】Game_Battler、Game_Actor、Game_Enemy、FS_ELEMENT_FINAL、FS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ELEMENT_ID_TO_SYMBOL、RANK_RATE、RATE_MIN、RATE_MAX、CHART。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須位於所有 Element／Equipment／Growth Patch 後方；FS_SupportStateSkillRules 會在本頁後包裝 max_rate_for 以中立化回復技能屬性。
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
# ■ FS_ElementRate_FinalAuthority_v2_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 【必要位置】
# 這支腳本必須位於所有一般 Element／Equipment／Growth 倍率補丁之後。
# Phase 28 的正式順序是：
#
#   Element / Equipment / Growth Provider
#   FS_ElementRate_FinalAuthority_v2_0   ← 一般戰鬥倍率最後入口
#   FS_SupportStateSkillRules            ← 唯一允許的後段包裝：回復／Note狀態技能中立化
#   其他不再改 Element Rate 的驗證／資料頁
#   Main
#
# 不可在 FinalAuthority 後再新增一般傷害 element_rate 覆寫；若需要新倍率規則，
# 應擴充 FS_ELEMENT_FINAL 的資料 Provider 或核心。
#
# 【原因】
# 專案中有多支腳本直接重新定義：
#   Game_Battler#element_rate
#   Game_Battler#elements_max_rate
#
# FS_BattleBalanceCore 若放在角色機制／天候之前，後方腳本仍可能把屬性倍率
# 改回資料庫 Element Rank 的 100%。這支 FinalGuard 不參與 alias 鏈，
# 直接成為最終定義。
#
# 【測試】
# 戰鬥事件輸入：
#   FS.er
#
# 水躍魚受草屬性時應輸出：
#   [:water, nil, 2.0, 200, 200]
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Element Rate Final Guard"] = "2.0"
$imported["FS Element Rate Final Authority"] = "2.0"

module FS_ELEMENT_FINAL
  ELEMENT_ID_TO_SYMBOL = FS_ELEMENT_TYPE_DATA::ELEMENT_ID_TO_SYMBOL

  RANK_RATE = [0, 200, 150, 100, 50, 0, -100]
  RATE_MIN = -100
  RATE_MAX = 250

  # 完整屬性表由 FS_ELEMENT_TYPE_DATA 單一維護。
  CHART = FS_ELEMENT_TYPE_DATA::CHART

  def self.symbol(element_id)
    return ELEMENT_ID_TO_SYMBOL[element_id]
  end

  def self.type_multiplier(attacking_type, primary_type, secondary_type)
    table = CHART[attacking_type] || {}
    primary = table.has_key?(primary_type) ? table[primary_type] : 1.0
    secondary = 1.0
    if secondary_type != nil
      secondary = table.has_key?(secondary_type) ? table[secondary_type] : 1.0
    end
    return primary * secondary
  end

  def self.database_rate(battler, element_id)
    if battler.is_a?(Game_Enemy)
      return 100 if battler.enemy == nil
      rank = battler.enemy.element_ranks[element_id]
      value = RANK_RATE[rank]
      return value == nil ? 100 : value
    end

    if battler.is_a?(Game_Actor)
      # ActorEnemyGrowth 的 USE_ENEMY_ELEMENT_RATE 仍由最終 Authority 尊重，
      # 但不再讓 ActorEnemyGrowth 自己包裝 element_rate。
      if defined?(ALBERT_ACTOR_ENEMY_GROWTH) &&
         ALBERT_ACTOR_ENEMY_GROWTH.const_defined?(:USE_ENEMY_ELEMENT_RATE) &&
         ALBERT_ACTOR_ENEMY_GROWTH::USE_ENEMY_ELEMENT_RATE &&
         battler.respond_to?(:albert_growth_enemy)
        growth_enemy = battler.albert_growth_enemy
        if growth_enemy != nil
          rank = growth_enemy.element_ranks[element_id]
          value = RANK_RATE[rank]
          return value == nil ? 100 : value
        end
      end

      rank = battler.class.element_ranks[element_id]
      value = RANK_RATE[rank]
      value = 100 if value == nil
      # VX 原生 Armor#element_set 防禦：每件相符防具再減半。
      for armor in battler.armors.compact
        value /= 2 if armor.element_set.include?(element_id)
      end
      return value
    end

    return 100
  end

  #--------------------------------------------------------------------------
  # ● KGC AddEquipmentOptions 的 Actor Element 修正
  #--------------------------------------------------------------------------
  # Phase 27 的 FinalGuard 直接覆寫 Game_Actor#element_rate，會讓 KGC 原本
  # 的 element_resistance / weak / guard / invalid / absorb 無法進入最終倍率。
  # Phase 28 將該語意集中到真正最後的 Authority。
  def self.apply_actor_equipment_options(battler, element_id, value)
    return value unless battler.is_a?(Game_Actor)
    return value unless battler.respond_to?(:equips)

    result = value.to_i
    if battler.respond_to?(:element_resistance)
      result = result * battler.element_resistance(element_id).to_i / 100
    end

    absorb_flag = (result < 0)
    result = result.abs
    for item in battler.equips.compact
      if item.respond_to?(:invalid_element_set) &&
         item.invalid_element_set.include?(element_id)
        result = 0
        break
      end
      if item.respond_to?(:guard_element_set) &&
         item.guard_element_set.include?(element_id)
        result /= 2
      end
      if item.respond_to?(:weak_element_set) &&
         item.weak_element_set.include?(element_id)
        result = result * 3 / 2
      end
      if item.respond_to?(:absorb_element_set) &&
         item.absorb_element_set.include?(element_id)
        absorb_flag = true
      end
    end
    result = -result if absorb_flag
    return result
  end

  def self.state_rate(battler, element_id)
    result = 100
    for state in battler.states.compact
      if state.respond_to?(:element_set) &&
         state.element_set.include?(element_id)
        result /= 2
      end
    end
    return result
  end
end

module FS_ELEMENT_FINAL
  #--------------------------------------------------------------------------
  # ● 單一屬性倍率核心
  #--------------------------------------------------------------------------
  # 不透過 battler.element_rate 呼叫，避免再次落入 Game_Actor／Game_Enemy
  # 各自的一參數覆寫。
  def self.rate_for(battler, element_id)
    attacking_type = symbol(element_id)
    return 100 if attacking_type == nil

    battler.setup_elements if battler.respond_to?(:setup_elements)

    primary = battler.respond_to?(:primary_element) ?
      battler.primary_element : nil
    secondary = battler.respond_to?(:secondary_element) ?
      battler.secondary_element : nil
    primary = :normal if primary == nil

    type_rate = type_multiplier(
      attacking_type, primary, secondary
    ) * 100.0

    db_rate = database_rate(battler, element_id)
    st_rate = state_rate(battler, element_id)

    result = type_rate * db_rate / 100.0
    result = result * st_rate / 100.0
    result = apply_actor_equipment_options(battler, element_id, result)
    result = [[result, RATE_MIN].max, RATE_MAX].min
    return result.to_i
  end

  #--------------------------------------------------------------------------
  # ● 多屬性倍率核心
  #--------------------------------------------------------------------------
  def self.max_rate_for(battler, element_set)
    return 100 if element_set == nil || element_set.empty?

    result = 100.0
    used = []

    for element_id in element_set
      next if used.include?(element_id)
      used.push(element_id)

      value = rate_for(battler, element_id).to_f

      if battler.respond_to?(:albert_element_extra_rate)
        value += battler.albert_element_extra_rate(element_id).to_f
      end

      value = [[value, RATE_MIN].max, RATE_MAX].min
      result = result * value / 100.0
    end

    result = [[result, RATE_MIN].max, RATE_MAX].min
    return result.to_i
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler
  def element_rate(element_id, *args)
    return FS_ELEMENT_FINAL.rate_for(self, element_id)
  end

  def elements_max_rate(element_set, *args)
    return FS_ELEMENT_FINAL.max_rate_for(self, element_set)
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 專案內 Game_Actor 自己定義過一參數 element_rate。
# Ruby 會優先使用子類別方法，不會使用 Game_Battler 的同名方法。
# 因此必須在最終腳本直接覆寫子類別。
#==============================================================================
class Game_Actor < Game_Battler
  def element_rate(element_id, *args)
    return FS_ELEMENT_FINAL.rate_for(self, element_id)
  end

  def elements_max_rate(element_set, *args)
    return FS_ELEMENT_FINAL.max_rate_for(self, element_set)
  end
end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 同上。接受 *args，兼容專案中 1、2、3 參數的所有呼叫形式。
#==============================================================================
class Game_Enemy < Game_Battler
  def element_rate(element_id, *args)
    return FS_ELEMENT_FINAL.rate_for(self, element_id)
  end

  def elements_max_rate(element_set, *args)
    return FS_ELEMENT_FINAL.max_rate_for(self, element_set)
  end
end

# 超短測試指令。
module FS
  def self.er
    return if $game_troop == nil
    enemy = $game_troop.members[0]
    return if enemy == nil
    p [
      enemy.primary_element,
      enemy.secondary_element,
      FS_ELEMENT_FINAL.type_multiplier(
        :grass, enemy.primary_element, enemy.secondary_element
      ),
      enemy.element_rate(15),
      enemy.elements_max_rate([15])
    ]
  end
end
