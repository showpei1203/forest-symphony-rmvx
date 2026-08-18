#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EconomyCore v1.1
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_EconomyCore v1.1」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_System、RPG::Armor、RPG::Weapon、Game_Interpreter、FS_ECONOMY
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SOUL_COUNT、HEADGEAR_START、SOUL_ARMOR_START、ECHO_ITEM_START、FRAGMENT_ITEM_START、SPECIAL_WEAPON_MIN、SPECIAL_WEAPON_MAX、SERVICE_KEYS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 10 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Economy Core；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_EconomyCore v1.1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 【安裝位置】
# 放在：
#   - 魔劍工舖 - 合成系統 1.08-FS
#   - SoulRepeatRecipe
#   - FS_SoulMark_Resonance_Expansion v2.1.0
# 之下，Main 之上。
#
# 【功能】
# 1. 統一鳴刻冠 Armor 220～285 的配方與金錢代價。
# 2. 保留其他五名角色 Weapon 266～275 的配方並加上製作費。
# 3. 支線服務旗標、章節、一次性獎勵資料。
# 4. 鳴刻冠與角色殘響武器的鍛造／調律資料。
# 5. 不處理舊存檔遷移。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Economy Core"] = "1.1"

module FS_ECONOMY
  VERSION = "1.1"

  SOUL_COUNT          = 66
  HEADGEAR_START      = 220
  SOUL_ARMOR_START    = 600
  ECHO_ITEM_START     = 200
  FRAGMENT_ITEM_START = 600
  SPECIAL_WEAPON_MIN  = 266
  SPECIAL_WEAPON_MAX  = 275

  SERVICE_KEYS = [
    :luka_return_credit,
    :new_name_blessing,
    :migration_route,
    :night_supply,
    :habel_forging,
    :zero_protocol_license,
    :nameless_tuning,
    :root_exchange,
    :anomaly_record_access,
    :black_market_access,
    :memory_reconstruction
  ]

  QUEST_SERVICE = {
    20 => :luka_return_credit,
    21 => :new_name_blessing,
    22 => :migration_route,
    23 => :night_supply,
    24 => :habel_forging,
    25 => :zero_protocol_license,
    26 => :nameless_tuning,
    27 => :root_exchange,
    28 => :anomaly_record_access
  }

  SPECIAL_WEAPON_ACTOR = {
    266 => 2, 267 => 2,
    268 => 3, 269 => 3,
    270 => 4, 271 => 4,
    272 => 5, 273 => 5,
    274 => 6, 275 => 6
  }

  TUNING_NAMES = {
    :force   => "強攻調律",
    :harmony => "共護調律"
  }

  FORCE_ALL_RECIPES_100 = true


  def self.data
    return nil if $game_system == nil
    return $game_system.fs_economy_data
  end

  def self.valid_headgear_id?(id)
    return id.to_i >= HEADGEAR_START && id.to_i < HEADGEAR_START + SOUL_COUNT
  end

  def self.valid_special_weapon_id?(id)
    return id.to_i >= SPECIAL_WEAPON_MIN && id.to_i <= SPECIAL_WEAPON_MAX
  end

  def self.offset_from_headgear(id)
    offset = id.to_i - HEADGEAR_START
    return -1 if offset < 0 || offset >= SOUL_COUNT
    return offset
  end

  def self.offset_from_soul_armor(id)
    offset = id.to_i - SOUL_ARMOR_START
    return -1 if offset < 0 || offset >= SOUL_COUNT
    return offset
  end

  def self.headgear_id(offset)
    return 0 if offset.to_i < 0 || offset.to_i >= SOUL_COUNT
    return HEADGEAR_START + offset.to_i
  end

  def self.echo_item_id(offset)
    return 0 if offset.to_i < 0 || offset.to_i >= SOUL_COUNT
    return ECHO_ITEM_START + offset.to_i
  end

  def self.fragment_item_id(offset)
    return 0 if offset.to_i < 0 || offset.to_i >= SOUL_COUNT
    return FRAGMENT_ITEM_START + offset.to_i
  end

  def self.unlocked?(key)
    d = data
    return false if d == nil
    return d[:services][key.to_sym] == true
  end

  def self.unlock(key)
    key = key.to_sym
    return false unless SERVICE_KEYS.include?(key)
    d = data
    return false if d == nil
    d[:services][key] = true
    return true
  end

  def self.lock(key)
    d = data
    return false if d == nil
    d[:services].delete(key.to_sym)
    return true
  end

  def self.chapter
    d = data
    return 0 if d == nil
    return d[:chapter].to_i
  end

  def self.chapter=(value)
    d = data
    return if d == nil
    old = d[:chapter].to_i
    d[:chapter] = [value.to_i, 0].max
    if old != d[:chapter]
      d[:black_market_purchases] = {}
      d[:night_supply_chapter] = -1
    end
  end

  def self.quest_claimed?(quest_id)
    d = data
    return false if d == nil
    return d[:quest_rewards][quest_id.to_i] == true
  end

  def self.mark_quest_claimed(quest_id)
    d = data
    return false if d == nil
    d[:quest_rewards][quest_id.to_i] = true
    return true
  end

  def self.complete_quest_service(quest_id, branch = 0)
    quest_id = quest_id.to_i
    key = QUEST_SERVICE[quest_id]
    unlock(key) if key != nil
    if quest_id == 29
      if branch.to_i == 1
        unlock(:black_market_access)
        lock(:memory_reconstruction)
      elsif branch.to_i == 2
        unlock(:memory_reconstruction)
        lock(:black_market_access)
        d = data
        d[:free_retune] = d[:free_retune].to_i + 1 if d != nil
      end
    end
    return true
  end

  def self.captured_offset?(offset)
    return false if $game_party == nil
    return false unless $game_party.respond_to?(:albert_soul_captured?)
    armor_id = SOUL_ARMOR_START + offset.to_i
    return $game_party.albert_soul_captured?(armor_id)
  end

  #--------------------------------------------------------------------------
  # ● 配方與金錢代價
  #--------------------------------------------------------------------------
  def self.headgear_craft_gold(offset)
    offset = offset.to_i
    return 800  if offset <= 19
    return 1800 if offset <= 34
    return 3500 if offset <= 50
    return 6000
  end

  def self.special_weapon_craft_gold(weapon_id)
   return (weapon_id.to_i % 2 == 0) ? 3500 : 9000
  end

  def self.default_recipe_gold(kind, row)
    return 0 if row == nil
    unit_count = 0
    type_count = 0
    (0..2).each do |i|
      hash = row[i]
      next unless hash.is_a?(Hash)
      type_count += hash.size
      hash.each_value { |amount| unit_count += amount.to_i }
    end
    base = kind.to_i == 0 ? 150 : (kind.to_i == 1 ? 600 : 700)
    value = base + unit_count * 120 + type_count * 180
    return [[value, 100].max, 8000].min
  end

  def self.apply_recipes
    return false unless defined?(Sword)
    return false unless Sword.const_defined?("Sword4_Synthesize")
    table = Sword::Sword4_Synthesize
    table[0] = [] if table[0] == nil
    table[1] = [] if table[1] == nil
    table[2] = [] if table[2] == nil

    # 所有既有配方統一100%成功，並補上基礎製作費。
    # 舊配方仍沿用原材料，不再讓失敗率額外吞掉玩家時間。
    (0..2).each do |kind|
      i = 1
      while i < table[kind].size
        row = table[kind][i]
        if row.is_a?(Array)
          row[3] = 100 if FORCE_ALL_RECIPES_100
          row[4] = default_recipe_gold(kind, row) if row[4] == nil
        end
        i += 1
      end
    end

    SOUL_COUNT.times do |offset|
      armor_id = headgear_id(offset)
      echo_id = echo_item_id(offset)
      fragment_id = fragment_item_id(offset)
      table[2][armor_id] = [
        {echo_id => 2, fragment_id => 4},
        {},
        {},
        100,
        headgear_craft_gold(offset)
      ]
      table[1][200 + offset] = nil
    end

    if defined?(FS_SOULMARK_RESONANCE) &&
       FS_SOULMARK_RESONANCE.const_defined?("RESONANCE_RECIPES")
      FS_SOULMARK_RESONANCE::RESONANCE_RECIPES.each do |weapon_id, row|
        items = {row[0].to_i => row[1].to_i, row[2].to_i => row[3].to_i}
        weapons = {}
        weapons[row[4].to_i] = 1 if row[4].to_i > 0
        table[1][weapon_id.to_i] = [
          items,
          weapons,
          {},
          100,
          special_weapon_craft_gold(weapon_id)
        ]
      end
    end
    return true
  end

  #--------------------------------------------------------------------------
  # ● 鍛造與調律
  #--------------------------------------------------------------------------
  def self.headgear_level(id)
    d = data
    return 0 if d == nil
    return d[:headgear_level][id.to_i].to_i
  end

  def self.headgear_tuning(id)
    d = data
    return nil if d == nil
    return d[:headgear_tuning][id.to_i]
  end

  def self.special_weapon_level(id)
    d = data
    return 0 if d == nil
    return d[:special_weapon_level][id.to_i].to_i
  end

  def self.special_weapon_tuning(id)
    d = data
    return nil if d == nil
    return d[:special_weapon_tuning][id.to_i]
  end

  def self.special_core_item_id(weapon_id)
    return 0 unless valid_special_weapon_id?(weapon_id)
    return 800 + ((weapon_id.to_i - SPECIAL_WEAPON_MIN) / 2)
  end

  def self.discounted_service_gold(value, use_craft_credit = true)
    value = value.to_i
    # 第零協議授權：哈貝爾的鍛造／調律服務費降低10%。
    value = value * 90 / 100 if unlocked?(:zero_protocol_license)
    # 記憶重構路線：所有相關服務費再降低20%。
    value = value * 80 / 100 if unlocked?(:memory_reconstruction)
    d = data
    if use_craft_credit && d != nil && d[:craft_credit].to_i > 0
      value = [value - 1000, 0].max
    end
    return value
  end

  def self.consume_craft_credit
    d = data
    return false if d == nil || d[:craft_credit].to_i <= 0
    d[:craft_credit] -= 1
    return true
  end

  def self.has_material?(item_id, amount)
    item = $data_items[item_id] rescue nil
    return false if item == nil || $game_party == nil
    return $game_party.item_number(item) >= amount.to_i
  end

  def self.consume_material(item_id, amount)
    item = $data_items[item_id] rescue nil
    return false if item == nil || $game_party == nil
    $game_party.lose_item(item, amount.to_i)
    return true
  end

  def self.forge_headgear(id)
    return :locked unless unlocked?(:habel_forging)
    return :invalid unless valid_headgear_id?(id)
    armor = $data_armors[id.to_i] rescue nil
    return :not_owned if armor == nil || $game_party == nil ||
      !$game_party.has_item?(armor, true)
    level = headgear_level(id)
    return :max_level if level >= 2
    offset = offset_from_headgear(id)
    next_level = level + 1
    echo_need = next_level == 1 ? 2 : 3
    frag_need = next_level == 1 ? 6 : 10
    gold_need = discounted_service_gold(next_level == 1 ? 2500 : 6000)
    return :material_short unless has_material?(echo_item_id(offset), echo_need)
    return :material_short unless has_material?(fragment_item_id(offset), frag_need)
    return :gold_short if $game_party.gold < gold_need
    consume_material(echo_item_id(offset), echo_need)
    consume_material(fragment_item_id(offset), frag_need)
    $game_party.lose_gold(gold_need)
    consume_craft_credit
    data[:headgear_level][id.to_i] = next_level
    return :success
  end

  def self.tune_headgear(id, branch)
    return :locked unless unlocked?(:nameless_tuning)
    return :invalid unless valid_headgear_id?(id)
    branch = branch.to_sym
    return :invalid unless TUNING_NAMES.has_key?(branch)
    armor = $data_armors[id.to_i] rescue nil
    return :not_owned if armor == nil || $game_party == nil ||
      !$game_party.has_item?(armor, true)
    old = headgear_tuning(id)
    d = data
    free = d != nil && d[:free_retune].to_i > 0 && old != nil
    offset = offset_from_headgear(id)
    echo_need = old == nil ? 2 : 3
    frag_need = old == nil ? 8 : 12
    gold_need = free ? 0 : discounted_service_gold(old == nil ? 7000 : 4500)
    return :material_short unless has_material?(echo_item_id(offset), echo_need)
    return :material_short unless has_material?(fragment_item_id(offset), frag_need)
    return :gold_short if $game_party.gold < gold_need
    consume_material(echo_item_id(offset), echo_need)
    consume_material(fragment_item_id(offset), frag_need)
    $game_party.lose_gold(gold_need)
    consume_craft_credit unless free
    d[:free_retune] -= 1 if free
    d[:headgear_tuning][id.to_i] = branch
    return :success
  end

  def self.forge_special_weapon(id)
    return :locked unless unlocked?(:habel_forging)
    return :invalid unless valid_special_weapon_id?(id)
    weapon = $data_weapons[id.to_i] rescue nil
    return :not_owned if weapon == nil || $game_party == nil ||
      !$game_party.has_item?(weapon, true)
    level = special_weapon_level(id)
    return :max_level if level >= 2
    next_level = level + 1
    core_id = special_core_item_id(id)
    core_need = next_level == 1 ? 1 : 2
    gold_need = discounted_service_gold(next_level == 1 ? 5000 : 12000)
    return :material_short unless has_material?(core_id, core_need)
    return :gold_short if $game_party.gold < gold_need
    consume_material(core_id, core_need)
    $game_party.lose_gold(gold_need)
    consume_craft_credit
    data[:special_weapon_level][id.to_i] = next_level
    return :success
  end

  def self.tune_special_weapon(id, branch)
    return :locked unless unlocked?(:nameless_tuning)
    return :invalid unless valid_special_weapon_id?(id)
    branch = branch.to_sym
    return :invalid unless TUNING_NAMES.has_key?(branch)
    weapon = $data_weapons[id.to_i] rescue nil
    return :not_owned if weapon == nil || $game_party == nil ||
      !$game_party.has_item?(weapon, true)
    old = special_weapon_tuning(id)
    d = data
    free = d != nil && d[:free_retune].to_i > 0 && old != nil
    core_id = special_core_item_id(id)
    core_need = old == nil ? 1 : 2
    gold_need = free ? 0 : discounted_service_gold(old == nil ? 9000 : 6000)
    return :material_short unless has_material?(core_id, core_need)
    return :gold_short if $game_party.gold < gold_need
    consume_material(core_id, core_need)
    $game_party.lose_gold(gold_need)
    consume_craft_credit unless free
    d[:free_retune] -= 1 if free
    d[:special_weapon_tuning][id.to_i] = branch
    return :success
  end

  def self.recycle_fragments(offset, amount = 6)
    return :locked unless unlocked?(:root_exchange)
    amount = amount.to_i
    amount = 6 if amount < 6
    item_id = fragment_item_id(offset)
    return :invalid if item_id <= 0
    return :material_short unless has_material?(item_id, amount)
    consume_material(item_id, amount)
    data[:craft_credit] = data[:craft_credit].to_i + 1
    return :success
  end

  # 記憶重構路線：把兩份製作抵用重構成一枚指定角色的特別殘響。
  # 一份抵用由6枚同譜系碎片回收而來，因此實際代價至少12枚碎片。
  def self.reconstruct_special_core(actor_id)
    return :locked unless unlocked?(:memory_reconstruction)
    actor_id = actor_id.to_i
    item_id = 798 + actor_id
    return :invalid unless actor_id >= 2 && actor_id <= 6
    item = $data_items[item_id] rescue nil
    return :invalid if item == nil || $game_party == nil
    d = data
    return :material_short if d == nil || d[:craft_credit].to_i < 2
    gold_need = discounted_service_gold(4000, false)
    return :gold_short if $game_party.gold < gold_need
    d[:craft_credit] -= 2
    $game_party.lose_gold(gold_need)
    $game_party.gain_item(item, 1)
    return :success
  end

  def self.result_text(result)
    case result
    when :success        then return "完成。"
    when :locked         then return "尚未解鎖這項服務。"
    when :invalid        then return "指定資料無效。"
    when :not_owned      then return "隊伍沒有持有該裝備。"
    when :max_level      then return "已達目前最高鍛造等級。"
    when :material_short then return "材料不足。"
    when :gold_short     then return "金錢不足。"
    end
    return result.to_s
  end

  #--------------------------------------------------------------------------
  # ● 動態裝備參數
  #--------------------------------------------------------------------------
  def self.parameter_bonus(kind, item_id, parameter, base_value = 0)
    kind = kind.to_sym
    item_id = item_id.to_i
    level = 0
    branch = nil
    # Armor 266～275 與 Weapon 266～275 同時存在，因此不能只靠ID判定。
    # 必須連同資料種類一起傳入，否則角色特殊武器會誤讀同ID鳴刻冠資料。
    if kind == :armor && valid_headgear_id?(item_id)
      level = headgear_level(item_id)
      branch = headgear_tuning(item_id)
    elsif kind == :weapon && valid_special_weapon_id?(item_id)
      level = special_weapon_level(item_id)
      branch = special_weapon_tuning(item_id)
    else
      return 0
    end
    bonus = 0
    # 鍛造只強化原裝備本來就擁有的能力，避免每件裝備平均長出四維。
    bonus += level * 2 if base_value.to_i != 0
    if branch == :force
      bonus += 3 if parameter == :atk || parameter == :agi
    elsif branch == :harmony
      bonus += 3 if parameter == :def || parameter == :spi
    end
    return bonus
  end

  def self.upgrade_suffix(kind, item_id)
    kind = kind.to_sym
    if kind == :armor && valid_headgear_id?(item_id)
      level = headgear_level(item_id)
      branch = headgear_tuning(item_id)
    elsif kind == :weapon && valid_special_weapon_id?(item_id)
      level = special_weapon_level(item_id)
      branch = special_weapon_tuning(item_id)
    else
      return ""
    end
    result = []
    result.push("鍛造+" + level.to_s) if level > 0
    result.push(TUNING_NAMES[branch]) if branch != nil
    return result.empty? ? "" : " [" + result.join("／") + "]"
  end
end

#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  def fs_economy_data
    @fs_economy_data ||= {
      :version => FS_ECONOMY::VERSION,
      :chapter => 0,
      :services => {},
      :quest_rewards => {},
      :headgear_level => {},
      :headgear_tuning => {},
      :special_weapon_level => {},
      :special_weapon_tuning => {},
      :craft_credit => 0,
      :free_retune => 0,
      :black_market_purchases => {},
      :night_supply_chapter => -1
    }
    @fs_economy_data[:services] ||= {}
    @fs_economy_data[:quest_rewards] ||= {}
    @fs_economy_data[:headgear_level] ||= {}
    @fs_economy_data[:headgear_tuning] ||= {}
    @fs_economy_data[:special_weapon_level] ||= {}
    @fs_economy_data[:special_weapon_tuning] ||= {}
    @fs_economy_data[:black_market_purchases] ||= {}
    return @fs_economy_data
  end
end

#==============================================================================
# ■ RPG::Armor / RPG::Weapon：鍛造與調律數值
#==============================================================================
class RPG::Armor < RPG::BaseItem
  alias fs_econ_armor_atk atk unless method_defined?(:fs_econ_armor_atk)
  alias fs_econ_armor_def def unless method_defined?(:fs_econ_armor_def)
  alias fs_econ_armor_spi spi unless method_defined?(:fs_econ_armor_spi)
  alias fs_econ_armor_agi agi unless method_defined?(:fs_econ_armor_agi)
  alias fs_econ_armor_description description unless method_defined?(:fs_econ_armor_description)

  def atk
    base = fs_econ_armor_atk
    return base + FS_ECONOMY.parameter_bonus(:armor, @id, :atk, base)
  end

  def def
    base = fs_econ_armor_def
    return base + FS_ECONOMY.parameter_bonus(:armor, @id, :def, base)
  end

  def spi
    base = fs_econ_armor_spi
    return base + FS_ECONOMY.parameter_bonus(:armor, @id, :spi, base)
  end

  def agi
    base = fs_econ_armor_agi
    return base + FS_ECONOMY.parameter_bonus(:armor, @id, :agi, base)
  end

  def description
    return fs_econ_armor_description.to_s + FS_ECONOMY.upgrade_suffix(:armor, @id)
  end
end

class RPG::Weapon < RPG::BaseItem
  alias fs_econ_weapon_atk atk unless method_defined?(:fs_econ_weapon_atk)
  alias fs_econ_weapon_def def unless method_defined?(:fs_econ_weapon_def)
  alias fs_econ_weapon_spi spi unless method_defined?(:fs_econ_weapon_spi)
  alias fs_econ_weapon_agi agi unless method_defined?(:fs_econ_weapon_agi)
  alias fs_econ_weapon_description description unless method_defined?(:fs_econ_weapon_description)

  def atk
    base = fs_econ_weapon_atk
    return base + FS_ECONOMY.parameter_bonus(:weapon, @id, :atk, base)
  end

  def def
    base = fs_econ_weapon_def
    return base + FS_ECONOMY.parameter_bonus(:weapon, @id, :def, base)
  end

  def spi
    base = fs_econ_weapon_spi
    return base + FS_ECONOMY.parameter_bonus(:weapon, @id, :spi, base)
  end

  def agi
    base = fs_econ_weapon_agi
    return base + FS_ECONOMY.parameter_bonus(:weapon, @id, :agi, base)
  end

  def description
    return fs_econ_weapon_description.to_s + FS_ECONOMY.upgrade_suffix(:weapon, @id)
  end
end

#==============================================================================
# ■ Game_Interpreter：事件指令
#==============================================================================
class Game_Interpreter
  def fs_econ_unlock(key)
    return FS_ECONOMY.unlock(key)
  end

  def fs_econ_unlocked?(key)
    return FS_ECONOMY.unlocked?(key)
  end

  def fs_econ_set_chapter(value)
    FS_ECONOMY.chapter = value
    return true
  end

  def fs_econ_chapter
    return FS_ECONOMY.chapter
  end

  def fs_econ_forge_headgear(armor_id)
    result = FS_ECONOMY.forge_headgear(armor_id)
    $game_message.texts.push(FS_ECONOMY.result_text(result)) if $game_message != nil
    return result
  end

  def fs_econ_tune_headgear(armor_id, branch)
    result = FS_ECONOMY.tune_headgear(armor_id, branch)
    $game_message.texts.push(FS_ECONOMY.result_text(result)) if $game_message != nil
    return result
  end

  def fs_econ_forge_special_weapon(weapon_id)
    result = FS_ECONOMY.forge_special_weapon(weapon_id)
    $game_message.texts.push(FS_ECONOMY.result_text(result)) if $game_message != nil
    return result
  end

  def fs_econ_tune_special_weapon(weapon_id, branch)
    result = FS_ECONOMY.tune_special_weapon(weapon_id, branch)
    $game_message.texts.push(FS_ECONOMY.result_text(result)) if $game_message != nil
    return result
  end

  def fs_econ_recycle_fragments(offset, amount = 6)
    result = FS_ECONOMY.recycle_fragments(offset, amount)
    $game_message.texts.push(FS_ECONOMY.result_text(result)) if $game_message != nil
    return result
  end

  def fs_econ_reconstruct_special_core(actor_id)
    result = FS_ECONOMY.reconstruct_special_core(actor_id)
    $game_message.texts.push(FS_ECONOMY.result_text(result)) if $game_message != nil
    return result
  end

  def fs_econ_sync_recipes
    return FS_ECONOMY.apply_recipes
  end
end

#==============================================================================
# ■ 配方初始套用
#------------------------------------------------------------------------------
# Scene_Title 的最終載入時機由 FS_SoulMark_Resonance_Expansion 統一呼叫，
# 本頁不再增加另一層 load_database alias。
#==============================================================================
FS_ECONOMY.apply_recipes
