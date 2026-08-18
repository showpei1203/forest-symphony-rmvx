#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ElementTypeAndUI_Provider v1.1
# 【用途】提供寶可夢雙屬性資料、pokemon_element_rate 查詢與屬性 UI；Phase 28 起不再接管最終 element_rate。
# 【主要機制】初始化 Actor／Enemy 的 primary_element、secondary_element，提供寶可夢屬性表查詢與 Window_Base 屬性圖示；真正戰鬥倍率由 FS_ElementRate_FinalAuthority v2.0 統一計算。
# 【主要影響】FS_ELEMENT_TYPE_DATA、Game_Battler、Game_Actor、Game_Enemy、Window_Base
# 【設定／可調參數】屬性克制表只修改 FS_ELEMENT_TYPE_DATA::CHART；VX Element ID 對應只修改 ELEMENT_ID_TO_SYMBOL；UI 圖示修改 Window_Base::ELEMENT_ICON_TABLE。
# 【依賴／載入順序】必須先於 FS_ElementRate_FinalAuthority v2.0 載入；本頁是 Type Data/UI Provider，不是最終倍率 Authority。
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
# PHASE 28 PROVIDER: FS_ElementTypeAndUI_Provider v1.1
# 寶可夢屬性 Base→elements_max_rate 修正→Window 屬性顯示。最終戰鬥倍率仍受後載入 BattleFormula/ElementRate Guard 接管。
# Original load order: 372:屬性相剋系統2 -> 373:修正 elements_max_rate -> 374:描繪屬性
#==============================================================================
# PHASE8 ORIGINAL PAGE: 372 | 屬性相剋系統2
#==============================================================================



#==============================================================================
# ■ FS_ELEMENT_TYPE_DATA｜Phase 28 單一屬性資料來源
#------------------------------------------------------------------------------
# 戰鬥、圖鑑／UI 與 pokemon_element_rate 共用同一份 ID→Symbol 與克制表。
# 此處是 Type Data Authority；倍率套用（Rank／State／Equipment／Absorb）仍由
# 後載入的 FS_ElementRate_FinalAuthority v2.0 負責。
#==============================================================================
module FS_ELEMENT_TYPE_DATA
  ELEMENT_ID_TO_SYMBOL = {
    4  => :normal,
    5  => :fighting,
    6  => :flying,
    7  => :poison,
    8  => :ground,
    9  => :rock,
    10 => :bug,
    11 => :ghost,
    12 => :steel,
    13 => :fire,
    14 => :water,
    15 => :grass,
    16 => :electric,
    17 => :psychic,
    18 => :ice,
    19 => :dragon,
    20 => :dark,
    21 => :fairy
  }
  CHART = {
    :normal => {
      :rock=>0.5, :ghost=>0.0, :steel=>0.5
    },
    :fighting => {
      :normal=>2.0, :ice=>2.0, :rock=>2.0, :dark=>2.0, :steel=>2.0,
      :poison=>0.5, :flying=>0.5, :psychic=>0.5, :bug=>0.5, :fairy=>0.5,
      :ghost=>0.0
    },
    :flying => {
      :fighting=>2.0, :bug=>2.0, :grass=>2.0,
      :rock=>0.5, :steel=>0.5, :electric=>0.5
    },
    :poison => {
      :grass=>2.0, :fairy=>2.0,
      :poison=>0.5, :ground=>0.5, :rock=>0.5, :ghost=>0.5,
      :steel=>0.0
    },
    :ground => {
      :poison=>2.0, :rock=>2.0, :steel=>2.0, :fire=>2.0, :electric=>2.0,
      :bug=>0.5, :grass=>0.5, :flying=>0.0
    },
    :rock => {
      :flying=>2.0, :bug=>2.0, :fire=>2.0, :ice=>2.0,
      :fighting=>0.5, :ground=>0.5, :steel=>0.5
    },
    :bug => {
      :grass=>2.0, :psychic=>2.0, :dark=>2.0,
      :fighting=>0.5, :flying=>0.5, :poison=>0.5, :ghost=>0.5,
      :steel=>0.5, :fire=>0.5, :fairy=>0.5
    },
    :ghost => {
      :ghost=>2.0, :psychic=>2.0,
      :dark=>0.5, :normal=>0.0
    },
    :steel => {
      :rock=>2.0, :ice=>2.0, :fairy=>2.0,
      :steel=>0.5, :fire=>0.5, :water=>0.5, :electric=>0.5
    },
    :fire => {
      :bug=>2.0, :steel=>2.0, :grass=>2.0, :ice=>2.0,
      :rock=>0.5, :fire=>0.5, :water=>0.5, :dragon=>0.5
    },
    :water => {
      :ground=>2.0, :rock=>2.0, :fire=>2.0,
      :water=>0.5, :grass=>0.5, :dragon=>0.5
    },
    :grass => {
      :ground=>2.0, :rock=>2.0, :water=>2.0,
      :flying=>0.5, :poison=>0.5, :bug=>0.5, :steel=>0.5,
      :fire=>0.5, :grass=>0.5, :dragon=>0.5
    },
    :electric => {
      :flying=>2.0, :water=>2.0,
      :grass=>0.5, :electric=>0.5, :dragon=>0.5,
      :ground=>0.0
    },
    :psychic => {
      :fighting=>2.0, :poison=>2.0,
      :steel=>0.5, :psychic=>0.5, :dark=>0.0
    },
    :ice => {
      :flying=>2.0, :ground=>2.0, :grass=>2.0, :dragon=>2.0,
      :steel=>0.5, :fire=>0.5, :water=>0.5, :ice=>0.5
    },
    :dragon => {
      :dragon=>2.0, :steel=>0.5, :fairy=>0.0
    },
    :dark => {
      :ghost=>2.0, :psychic=>2.0,
      :fighting=>0.5, :dark=>0.5, :fairy=>0.5
    },
    :fairy => {
      :fighting=>2.0, :dragon=>2.0, :dark=>2.0,
      :poison=>0.5, :steel=>0.5, :fire=>0.5
    }
  }
end

# 📌 擴充 Game_Battler，加入雙屬性處理
class Game_Battler
  attr_accessor :primary_element, :secondary_element

  # 🛠 計算屬性相剋倍率（寶可夢風格）
  def pokemon_element_rate(attacking_element)
    # 確保 `primary_element` 存在
    return 1.0 unless @primary_element

    # Phase 28：共用唯一 Type Data Authority。
    pokemon_chart = FS_ELEMENT_TYPE_DATA::CHART

    # 主要屬性倍率
    primary_multiplier = pokemon_chart[attacking_element] && pokemon_chart[attacking_element][@primary_element] || 1.0
    # 次要屬性倍率（如果沒有次要屬性則為 1.0）
    secondary_multiplier = @secondary_element ? (pokemon_chart[attacking_element] && pokemon_chart[attacking_element][@secondary_element] || 1.0) : 1.0

    return primary_multiplier * secondary_multiplier
  end

  # Phase 28：不再覆寫 element_rate。
  # 最終倍率請查 FS_ElementRate_FinalAuthority v2.0。
end

# 📌 擴充 Game_Actor，讓角色初始化時根據職業設定雙屬性
class Game_Actor < Game_Battler
  alias original_initialize initialize
  def initialize(actor_id)
    original_initialize(actor_id)
    setup_elements
  end

  def setup_elements
    elements = ElementalSettings::CLASS_ELEMENT_TABLE[@class_id] || [:normal, nil]
    @primary_element, @secondary_element = elements
  end
end

# 📌 擴充 Game_Enemy，讓敵人初始化時根據敵人 ID 設定雙屬性
class Game_Enemy < Game_Battler
  alias original_initialize initialize
  def initialize(index, enemy_id)
    original_initialize(index, enemy_id)
    setup_elements
  end

  def setup_elements
    elements = ElementalSettings::ENEMY_ELEMENT_TABLE[@enemy_id] || [:normal, nil]
    @primary_element, @secondary_element = elements
  end
end

#==============================================================================
# Phase 28：舊 elements_max_rate 中間覆寫已退休。
# 多屬性倍率統一由 FS_ElementRate_FinalAuthority v2.0#max_rate_for 管理。
#==============================================================================

#==============================================================================
# PHASE8 ORIGINAL PAGE: 374 | 描繪屬性
#==============================================================================
#draw_actor_enemy_elements($game_actors[1], 10, 20)
#draw_actor_enemy_weak($game_troop.members[0], 10, 20)
=begin
        4 => 3988,
        5 => 3989,
        6 => 3990,
        7 => 3991,
        8 => 3992,
        9 => 3993,
        10 => 4004,
        11 => 4005,
        12 => 4006,
        13 => 4007,
        14 => 4008,
        15 => 4009,
        16 => 4020,
        17 => 4021,
        18 => 4022,
        19 => 4023,
        20 => 4024,
        21 => 4025,
=end
class Window_Base < Window
  ELEMENT_ICON_TABLE = {
    :normal => 3988, :fighting => 3989, :flying => 3990, :poison => 3991, :ground => 3992, :rock => 3993,
    :bug => 4004, :ghost => 4005, :steel => 4006, :fire => 4007, :water => 4008, :grass => 4009,
    :electric => 4020, :psychic => 4021, :ice => 4022, :dragon => 4023, :dark => 4024, :fairy => 4025
  }

  # 屬性克制表：Phase 28 起與戰鬥共用同一份 Authority Data。
  POKEMON_CHART = FS_ELEMENT_TYPE_DATA::CHART

  # **繪製角色或敵人屬性資訊**
  def draw_actor_enemy_elements(battler, x, y)
    return unless battler

    elements = []
    elements.push(battler.primary_element) if battler.primary_element
    elements.push(battler.secondary_element) if battler.secondary_element

    y_offset = 0
    elements.each do |element|
      if battler.secondary_element
        draw_element(element, x -24 + y_offset, y)
      else
        draw_element(element, x, y)
      end
      #draw_element(element, x - y_offset, y)
      #draw_weaknesses(element, x + 120, y + y_offset)
      y_offset += 24
    end
  end

    # **繪製角色或敵人屬性資訊**
  def draw_actor_enemy_weak(battler, x, y)
    return unless battler

    elements = []
    elements.push(battler.primary_element) if battler.primary_element
    elements.push(battler.secondary_element) if battler.secondary_element

    y_offset = 0
    elements.each do |element|
      #draw_element(element, x, y + y_offset)
      draw_weaknesses(element, x, y + y_offset)
      y_offset += 24
    end
  end
  # **繪製單一屬性**
  def draw_element(element, x, y)
    icon_index = ELEMENT_ICON_TABLE[element] || 0
    draw_icon(icon_index, x, y)
  end

  # **繪製該屬性的弱點（只畫 Icon）**
  def draw_weaknesses(element, x, y)
    weak_elements = []
    POKEMON_CHART[element].each do |key, value|
      weak_elements.push(key) if value == 2.0
    end

    # 繪製弱點屬性的 icon
    x_offset = 0
    for i in 0...weak_elements.size
      icon_index = ELEMENT_ICON_TABLE[weak_elements[i]] || 0
      draw_icon(icon_index, x + x_offset, y)
      x_offset += 24  # 間距
    end
  end
end
