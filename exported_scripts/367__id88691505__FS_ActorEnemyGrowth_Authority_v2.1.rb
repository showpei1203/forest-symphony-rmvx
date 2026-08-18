#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ActorEnemyGrowth_Authority v2.1
# 【用途】Forest Symphony Actor→Enemy 成長資料 Authority；Phase 28 起 element_rate 不再由本頁包裝，USE_ENEMY_ELEMENT_RATE 由最終 Element Authority 讀取。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Game_Actor、Game_Enemy、ALBERT_ACTOR_ENEMY_GROWTH、ALBERT_HPMP_SCALE_GROWTH
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ACTOR_TO_ENEMY、ADD_EQUIP_BONUS、USE_ENEMY_ELEMENT_RATE、USE_ENEMY_STATE_RATE、ADD_EQUIP_TO_HPMP、HP_SCALE、MP_SCALE、APPLY_TO_NORMAL_ACTOR。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 13 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# PHASE 28 AUTHORITY: FS_ActorEnemyGrowth_Authority v2.1
# Actor 讀 Enemy 種族值成長→HP/MP Scale；第二段明確要求位於第一段之下。
# Original load order: 384:ActorEnemyGrowth -> 385:HPMP_Scale_Growth
#==============================================================================
# PHASE8 ORIGINAL PAGE: 384 | ActorEnemyGrowth
#==============================================================================
#==============================================================================
# ■ Albert_RMVX_ActorEnemyGrowth.rb
#------------------------------------------------------------------------------
#  指定 Actor ID 使用 Enemy 資料庫的「種族值 + Lv 公式」計算能力。
#
#  適用：RPG Maker VX / RGSS2
#  建議位置：
#    放在「YERD_EnemyLevelControl / 你改寫敵人成長公式」之下，
#    放在「Main」之上。
#
#  功能：
#    1. 只有 ACTOR_TO_ENEMY 裡指定的 Actor 會改用 Enemy 種族值公式。
#    2. 未指定的 Actor 完全維持原本資料庫參數曲線。
#    3. 可選擇是否把裝備數值加回攻防精敏。
#    4. 可選擇是否同步使用 Enemy 的屬性有效度 / 狀態有效度。
#==============================================================================

module ALBERT_ACTOR_ENEMY_GROWTH
  #--------------------------------------------------------------------------
  # ★ 指定 Actor ID 對應 Enemy ID
  #--------------------------------------------------------------------------
  # 寫法：
  #   Actor ID => Enemy ID
  #
  # 例：
  #   7  => 50,
  #   8  => 51,
  #   21 => 30,
  #
  # 代表：
  #   Actor 7 的能力值改讀 Enemy 50 的資料庫數值作為種族值。
  #--------------------------------------------------------------------------
  ACTOR_TO_ENEMY = {
    # 寶可夢召喚物範例
    7  => 50,
    8  => 51,
    9  => 52,
    10 => 53,
    11 => 54,
    12 => 55,
    13 => 56,
    14 => 57,
    15 => 58,
    16 => 59,
    17 => 60,
    18 => 61,
    19 => 62,
    20 => 63,
    21 => 64,
    22 => 65,
    23 => 66,
    24 => 67,
    25 => 68,
    26 => 69,

    # 機器人召喚物範例
    27 => 70,
    28 => 71,
    29 => 72,
    30 => 73,
    31 => 74,

    # 人類複製體範例
    32 => 75,
    33 => 76,
    34 => 77,
    35 => 78,
    36 => 79,
  }

  # 攻擊、防禦、精神、敏捷是否加上 Actor 裝備數值。
  # 召喚物沒有裝備時無影響；若人類複製體有裝備，可設 true。
  ADD_EQUIP_BONUS = true

  # 指定 Actor 是否同步使用對應 Enemy 的屬性有效度。
  # true  = Actor 受擊時，屬性倍率改讀 Enemy 頁面的屬性有效度。
  # false = Actor 仍讀職業頁面的屬性有效度。
  USE_ENEMY_ELEMENT_RATE = false

  # 指定 Actor 是否同步使用對應 Enemy 的狀態有效度。
  # true  = Actor 被上狀態時，成功率改讀 Enemy 頁面的狀態有效度。
  # false = Actor 仍讀職業頁面的狀態有效度。
  USE_ENEMY_STATE_RATE = false

  # 是否讓 HP/MP 也加上裝備或額外加值？
  # 通常不需要，因為 Game_Battler#maxhp/maxmp 本來會再加 @maxhp_plus / @maxmp_plus。
  # 請保持 false。
  ADD_EQUIP_TO_HPMP = false
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * 是否使用 Enemy 種族值成長
  #--------------------------------------------------------------------------
  def albert_enemy_growth?
    return ALBERT_ACTOR_ENEMY_GROWTH::ACTOR_TO_ENEMY.has_key?(@actor_id)
  end

  #--------------------------------------------------------------------------
  # * 對應的 Enemy ID
  #--------------------------------------------------------------------------
  def albert_growth_enemy_id
    return ALBERT_ACTOR_ENEMY_GROWTH::ACTOR_TO_ENEMY[@actor_id]
  end

  #--------------------------------------------------------------------------
  # * 對應的 Enemy 資料
  #--------------------------------------------------------------------------
  def albert_growth_enemy
    enemy_id = albert_growth_enemy_id
    return nil if enemy_id == nil
    return $data_enemies[enemy_id]
  end

  #--------------------------------------------------------------------------
  # * 安全等級
  #--------------------------------------------------------------------------
  def albert_growth_level
    return [[@level, 1].max, 99].min
  end

  #--------------------------------------------------------------------------
  # * HP/MP 公式：照你目前 Game_Enemy 的公式
  #   ((2 * 種族值 + 31) / 100.0 * Lv) + Lv + 10
  #--------------------------------------------------------------------------
  def albert_enemy_formula_hpmp(base_value)
    lv = albert_growth_level
    return Integer(((2 * base_value + 31) / 100.0 * lv) + lv + 10)
  end

  #--------------------------------------------------------------------------
  # * 攻防精敏公式：照你目前 Game_Enemy 的公式
  #   ((2 * 種族值 + 31) / 100.0 * Lv) + Lv + 5
  #--------------------------------------------------------------------------
  def albert_enemy_formula_param(base_value)
    lv = albert_growth_level
    return Integer(((2 * base_value + 31) / 100.0 * lv) + lv + 5)
  end

  #--------------------------------------------------------------------------
  # * 裝備加成
  #--------------------------------------------------------------------------
  def albert_equip_bonus(sym)
    return 0 unless ALBERT_ACTOR_ENEMY_GROWTH::ADD_EQUIP_BONUS
    n = 0
    for item in equips.compact
      case sym
      when :atk
        n += item.atk
      when :def
        n += item.def
      when :spi
        n += item.spi
      when :agi
        n += item.agi
      end
    end
    return n
  end

  #--------------------------------------------------------------------------
  # * base_maxhp
  #--------------------------------------------------------------------------
  alias albert_actor_enemy_growth_base_maxhp base_maxhp unless $@
  def base_maxhp
    enemy = albert_growth_enemy
    return albert_actor_enemy_growth_base_maxhp if enemy == nil
    return albert_enemy_formula_hpmp(enemy.maxhp)
  end

  #--------------------------------------------------------------------------
  # * base_maxmp
  #--------------------------------------------------------------------------
  alias albert_actor_enemy_growth_base_maxmp base_maxmp unless $@
  def base_maxmp
    enemy = albert_growth_enemy
    return albert_actor_enemy_growth_base_maxmp if enemy == nil
    return albert_enemy_formula_hpmp(enemy.maxmp)
  end

  #--------------------------------------------------------------------------
  # * base_atk
  #--------------------------------------------------------------------------
  alias albert_actor_enemy_growth_base_atk base_atk unless $@
  def base_atk
    enemy = albert_growth_enemy
    return albert_actor_enemy_growth_base_atk if enemy == nil
    return albert_enemy_formula_param(enemy.atk) + albert_equip_bonus(:atk)
  end

  #--------------------------------------------------------------------------
  # * base_def
  #--------------------------------------------------------------------------
  alias albert_actor_enemy_growth_base_def base_def unless $@
  def base_def
    enemy = albert_growth_enemy
    return albert_actor_enemy_growth_base_def if enemy == nil
    return albert_enemy_formula_param(enemy.def) + albert_equip_bonus(:def)
  end

  #--------------------------------------------------------------------------
  # * base_spi
  #--------------------------------------------------------------------------
  alias albert_actor_enemy_growth_base_spi base_spi unless $@
  def base_spi
    enemy = albert_growth_enemy
    return albert_actor_enemy_growth_base_spi if enemy == nil
    return albert_enemy_formula_param(enemy.spi) + albert_equip_bonus(:spi)
  end

  #--------------------------------------------------------------------------
  # * base_agi
  #--------------------------------------------------------------------------
  alias albert_actor_enemy_growth_base_agi base_agi unless $@
  def base_agi
    enemy = albert_growth_enemy
    return albert_actor_enemy_growth_base_agi if enemy == nil
    return albert_enemy_formula_param(enemy.agi) + albert_equip_bonus(:agi)
  end

  #--------------------------------------------------------------------------
  # * element_rate（Phase 28）
  #--------------------------------------------------------------------------
  # 不再在本頁包裝 element_rate。USE_ENEMY_ELEMENT_RATE 設定仍保留，
  # 由 FS_ElementRate_FinalAuthority v2.0 在唯一最終入口讀取。

  #--------------------------------------------------------------------------
  # * state_probability：可選擇同步 Enemy 狀態有效度
  #--------------------------------------------------------------------------
  alias albert_actor_enemy_growth_state_probability state_probability unless $@
  def state_probability(state_id)
    unless ALBERT_ACTOR_ENEMY_GROWTH::USE_ENEMY_STATE_RATE
      return albert_actor_enemy_growth_state_probability(state_id)
    end

    enemy = albert_growth_enemy
    return albert_actor_enemy_growth_state_probability(state_id) if enemy == nil

    if $data_states[state_id].nonresistance
      return 100
    else
      rank = enemy.state_ranks[state_id]
      return [0, 100, 80, 60, 40, 20, 0][rank]
    end
  end
end

#==============================================================================
# PHASE8 ORIGINAL PAGE: 385 | HPMP_Scale_Growth
#==============================================================================
#==============================================================================
# ■ Albert_RMVX_HPMP_Scale_Growth_v2.rb
#------------------------------------------------------------------------------
#  RPG Maker VX / RGSS2
#
#  放置位置：
#    所有能力值成長、KGC PassiveSkill、Equipment Overhaul、
#    YERD Enemy Level Control、Albert_RMVX_ActorEnemyGrowth 之下，Main 之上。
#
#  依目前專案建議：
#    ctorEnemyGrowth
#    Albert_RMVX_HPMP_Scale_Growth_v2.rb
#    Main
#
#  功能：
#    1. HP / MP 使用「種族值 + Lv」公式後，再乘固定倍率。
#    2. 一般 Actor 與「讀 Enemy 種族值的 Actor」都會套用：
#         種族值公式 × HP/MP倍率
#         → 裝備百分比
#         → 裝備固定值
#         → 被動技能固定/百分比
#    3. 裝備固定值不會被 HP_SCALE / MP_SCALE 放大。
#    4. 不呼叫原本 base_maxhp / base_maxmp 來加裝備，避免雙重加成。
#
#  注意：
#    - Enemy 沒有裝備，因此 Enemy 只會把目前 base_maxhp/base_maxmp 乘倍率。
#    - 若後面還有其他腳本再次改 base_maxhp/base_maxmp，仍可能造成重複。
#==============================================================================

module ALBERT_HPMP_SCALE_GROWTH
  #--------------------------------------------------------------------------
  # ★ 基本倍率
  #--------------------------------------------------------------------------
  HP_SCALE = 14.0
  MP_SCALE = 2.2

  # 是否套用到一般 Actor。
  APPLY_TO_NORMAL_ACTOR = false

  # 是否套用到使用 Albert_RMVX_ActorEnemyGrowth 的指定 Actor。
  APPLY_TO_ENEMY_GROWTH_ACTOR = true

  # 讀 Enemy 種族值的 Actor 是否仍套用裝備與被動。
  # 通常應保持 true，否則召喚物裝備 / 被動不會影響 HP / MP。
  APPLY_EQUIP_AND_PASSIVE_TO_ENEMY_GROWTH_ACTOR = true

  # 是否套用到敵人 Game_Enemy。
  APPLY_TO_ENEMY = true

  # 是否提高 Actor HP 上限。
  # 若你的角色 HP 不會超過 9999，可以保持 false。
  CHANGE_ACTOR_MAXHP_LIMIT = false
  ACTOR_MAXHP_LIMIT = 99999

  #--------------------------------------------------------------------------
  # * HP / MP 共用公式
  #   ((2 * 種族值 + 31) / 100.0 * Lv) + Lv + 10
  #--------------------------------------------------------------------------
  def self.hpmp_raw(base_value, level)
    lv = [[level.to_i, 1].max, 99].min
    return ((2 * base_value.to_i + 31) * lv / 100.0) + lv + 10
  end

  def self.apply_scale(value, scale)
    return Integer(value.to_f * scale)
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * 安全讀取 Actor 種族值
  #   目前設計：Actor 資料庫 parameters[x, 1] = 種族值
  #--------------------------------------------------------------------------
  def albert_hpmp_scale_actor_species(param_index)
    return actor.parameters[param_index, 1]
  end

  #--------------------------------------------------------------------------
  # * 安全讀取等級
  #--------------------------------------------------------------------------
  def albert_hpmp_scale_level
    return [[@level.to_i, 1].max, 99].min
  end

  #--------------------------------------------------------------------------
  # * 是否有對應 Enemy 種族值
  #--------------------------------------------------------------------------
  def albert_hpmp_scale_enemy_data
    if respond_to?(:albert_growth_enemy)
      enemy = albert_growth_enemy
      return enemy if enemy != nil
    end
    return nil
  end

  #--------------------------------------------------------------------------
  # * 裝備百分比加成
  #--------------------------------------------------------------------------
  def albert_hpmp_scale_equip_percent(sym)
    percent = 100
    for item in equips.compact
      next unless item.respond_to?(:stat_per)
      next if item.stat_per == nil
      value = item.stat_per[sym]
      next if value == nil
      if respond_to?(:aptitude)
        percent += aptitude(value, sym)
      else
        percent += value
      end
    end
    return percent
  end

  #--------------------------------------------------------------------------
  # * 裝備固定加成
  #--------------------------------------------------------------------------
  def albert_hpmp_scale_equip_flat(sym)
    n = 0
    for item in equips.compact
      value = 0
      case sym
      when :hp
        value = item.respond_to?(:maxhp) ? item.maxhp : 0
      when :mp
        value = item.respond_to?(:maxmp) ? item.maxmp : 0
      end
      if respond_to?(:aptitude)
        n += aptitude(value, sym)
      else
        n += value
      end
    end
    return n
  end

  #--------------------------------------------------------------------------
  # * 被動技能固定 / 百分比加成
  #   注意：這裡只加 passive_params，不再額外加 base_maxhp_KGC_PassiveSkill。
  #--------------------------------------------------------------------------
  def albert_hpmp_scale_apply_passive(n, key)
    if respond_to?(:passive_params) && respond_to?(:passive_params_rate)
      pp = passive_params
      pr = passive_params_rate
      if pp != nil && pp[key] != nil
        n += pp[key]
      end
      if pr != nil && pr[key] != nil
        n = n * pr[key] / 100
      end
    end
    return n
  end

  #--------------------------------------------------------------------------
  # * Actor HP / MP 後處理：裝備百分比 → 裝備固定值 → 被動
  #--------------------------------------------------------------------------
  def albert_hpmp_scale_actor_post_process(n, sym, passive_key)
    n = n * albert_hpmp_scale_equip_percent(sym) / 100
    n += albert_hpmp_scale_equip_flat(sym)
    n = albert_hpmp_scale_apply_passive(n, passive_key)
    return Integer(n)
  end

  #--------------------------------------------------------------------------
  # * base_maxhp
  #--------------------------------------------------------------------------
  alias albert_hpmp_scale_growth_v2_base_maxhp base_maxhp unless $@
  def base_maxhp
    enemy = albert_hpmp_scale_enemy_data

    if enemy != nil && ALBERT_HPMP_SCALE_GROWTH::APPLY_TO_ENEMY_GROWTH_ACTOR
      raw = ALBERT_HPMP_SCALE_GROWTH.hpmp_raw(enemy.maxhp, albert_hpmp_scale_level)
      n = ALBERT_HPMP_SCALE_GROWTH.apply_scale(raw, ALBERT_HPMP_SCALE_GROWTH::HP_SCALE)
      if ALBERT_HPMP_SCALE_GROWTH::APPLY_EQUIP_AND_PASSIVE_TO_ENEMY_GROWTH_ACTOR
        n = albert_hpmp_scale_actor_post_process(n, :hp, :maxhp)
      end
      return Integer(n)
    end

    unless ALBERT_HPMP_SCALE_GROWTH::APPLY_TO_NORMAL_ACTOR
      return albert_hpmp_scale_growth_v2_base_maxhp
    end

    raw = ALBERT_HPMP_SCALE_GROWTH.hpmp_raw(albert_hpmp_scale_actor_species(0), albert_hpmp_scale_level)
    n = ALBERT_HPMP_SCALE_GROWTH.apply_scale(raw, ALBERT_HPMP_SCALE_GROWTH::HP_SCALE)
    n = albert_hpmp_scale_actor_post_process(n, :hp, :maxhp)

    return Integer(n)
  end

  #--------------------------------------------------------------------------
  # * base_maxmp
  #--------------------------------------------------------------------------
  alias albert_hpmp_scale_growth_v2_base_maxmp base_maxmp unless $@
  def base_maxmp
    enemy = albert_hpmp_scale_enemy_data

    if enemy != nil && ALBERT_HPMP_SCALE_GROWTH::APPLY_TO_ENEMY_GROWTH_ACTOR
      raw = ALBERT_HPMP_SCALE_GROWTH.hpmp_raw(enemy.maxmp, albert_hpmp_scale_level)
      n = ALBERT_HPMP_SCALE_GROWTH.apply_scale(raw, ALBERT_HPMP_SCALE_GROWTH::MP_SCALE)
      if ALBERT_HPMP_SCALE_GROWTH::APPLY_EQUIP_AND_PASSIVE_TO_ENEMY_GROWTH_ACTOR
        n = albert_hpmp_scale_actor_post_process(n, :mp, :maxmp)
      end
      return Integer(n)
    end

    unless ALBERT_HPMP_SCALE_GROWTH::APPLY_TO_NORMAL_ACTOR
      return albert_hpmp_scale_growth_v2_base_maxmp
    end

    raw = ALBERT_HPMP_SCALE_GROWTH.hpmp_raw(albert_hpmp_scale_actor_species(1), albert_hpmp_scale_level)
    n = ALBERT_HPMP_SCALE_GROWTH.apply_scale(raw, ALBERT_HPMP_SCALE_GROWTH::MP_SCALE)
    n = albert_hpmp_scale_actor_post_process(n, :mp, :maxmp)

    return Integer(n)
  end

  #--------------------------------------------------------------------------
  # * Actor HP 上限，可選
  #--------------------------------------------------------------------------
  alias albert_hpmp_scale_growth_v2_maxhp_limit maxhp_limit unless $@
  def maxhp_limit
    if ALBERT_HPMP_SCALE_GROWTH::CHANGE_ACTOR_MAXHP_LIMIT
      return ALBERT_HPMP_SCALE_GROWTH::ACTOR_MAXHP_LIMIT
    end
    return albert_hpmp_scale_growth_v2_maxhp_limit
  end
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * base_maxhp
  #   Enemy 沒有裝備，所以直接把目前最終 base_maxhp 乘固定倍率。
  #   這樣可以保留 YERD Enemy Level Control / ALVD 之類已接上的變動。
  #--------------------------------------------------------------------------
  alias albert_hpmp_scale_growth_v2_enemy_base_maxhp base_maxhp unless $@
  def base_maxhp
    n = albert_hpmp_scale_growth_v2_enemy_base_maxhp
    return n unless ALBERT_HPMP_SCALE_GROWTH::APPLY_TO_ENEMY
    return ALBERT_HPMP_SCALE_GROWTH.apply_scale(n, ALBERT_HPMP_SCALE_GROWTH::HP_SCALE)
  end

  #--------------------------------------------------------------------------
  # * base_maxmp
  #--------------------------------------------------------------------------
  alias albert_hpmp_scale_growth_v2_enemy_base_maxmp base_maxmp unless $@
  def base_maxmp
    n = albert_hpmp_scale_growth_v2_enemy_base_maxmp
    return n unless ALBERT_HPMP_SCALE_GROWTH::APPLY_TO_ENEMY
    return ALBERT_HPMP_SCALE_GROWTH.apply_scale(n, ALBERT_HPMP_SCALE_GROWTH::MP_SCALE)
  end
end
