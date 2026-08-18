#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：ItemAlmanac v1.2｜物品圖鑑
# 【來源】wltr3565，Item Almanac v1.2；原作者要求使用時列入 Credits，商業使用條件依原作者說明。
# 【用途】自動記錄玩家曾取得的 Item／Weapon／Armor，提供完整物品圖鑑 Scene、收集率、項目註解與圖片；目前 `ADD_TO_MENU=true`，屬正式 Menu/UI 功能。
# 【Notetag】`<Almanac out>`：依 DEFAULT_DOCUMENTATION 規則排除／納入圖鑑；`<Almanac com_on> ... <Almanac com_off>`：圖鑑註解；`<Almanac graphic name>`：GRAPHIC_USE=true 時讀取 `Graphics/Pictures/name`。
# 【事件 Script Call】`$game_system.complete_almanac` 全解鎖；`check_item_get("A",5)` 查 Armor 5；`flag_item_get("I",2,false)` 清除 Item 2 紀錄；`flag_item_get("W",2)` 登記 Weapon 2；`check_item_completition("IW")` 查完成；`check_item_completition_rate("IA",10)` 把比例寫 Variable 10；`check_item_total("A",5)`；`check_item_get_total("IWA",6)`；`$scene = Scene_Almanac.new("IWA")` 開啟圖鑑。
# 【主要設定】ALMANAC_SHOW_MENU="IWA"；GRAPHIC_USE=false；ADD_TO_MENU=true；ALMANAC_NAME、圖示、元素顯示與各狀態文字可在 WLTR::ALMANAC_SETUP 調整。DEFAULT_DOCUMENTATION=true 時 `<Almanac out>` 表示排除。
# 【資料紀錄】Game_Party#gain_item 會自動 flag；Game_System 保存 Item/Weapon/Armor 三類紀錄。改資料結構需測舊存檔。
# 【相關素材】PAGE_FLIP_SE=["Book",80,100]，專案含 Audio/SE/Book.ogg；BACKGROUND 若非空讀 Graphics/System；GRAPHIC_USE=true 時讀 Graphics/Pictures。
# 【Load Order】會擴充 Window_Command 與 Scene_Menu，並使用 KGC 類似的自動 Menu Command 方法；目前位置已驗證，不能因「圖鑑」概念與 EnemyGuide 類似就任意合併。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#===============================================================================
#===============================================================================
$imported = {} if $imported == nil
$imported["wltr3565's_Item_Almanac"] = true
#===============================================================================
#===============================================================================
module WLTR
  module ALMANAC_SETUP
#===============================================================================
#===============================================================================
    UNKNOWN_WORD = "?"
    
#===============================================================================
#===============================================================================
    UNKNOWN_ICON = 50

#===============================================================================
#===============================================================================
    UNKNOWN_HELP = "???"
    
#===============================================================================
#   true：含 <Almanac out> 的項目不加入圖鑑。
#   false：沒有 <Almanac out> 的項目不加入圖鑑。
#===============================================================================
    DEFAULT_DOCUMENTATION = true
    
#===============================================================================
#===============================================================================
    UNKNOWN_COMMENT = ""
  
#===============================================================================
#===============================================================================
    UNKNOWN_GRAPHIC = ""
    
#===============================================================================
#===============================================================================
    ITEM_GRAPH_HEIGHT = 208
  
#===============================================================================
#===============================================================================
    PAGE_1_TEXT = "Type = %s"

#===============================================================================
#===============================================================================
    ALMANAC_SHOW_MENU = "IWA"
    
#===============================================================================
#   true  = use
#   false = don't use
#===============================================================================
    GRAPHIC_USE = false
  
#===============================================================================
# PAGE_FLIP_SE = [filename, volume, pitch]
#===============================================================================
    PAGE_FLIP_SE = ["Book", 80, 100]
    
#===============================================================================
#===============================================================================
    BACKGROUND = ""
    
#===============================================================================
#    true   = make it available to access via menu.
#    false  = make it not available to access via menu.
#===============================================================================
    ADD_TO_MENU = true
    
#===============================================================================
#===============================================================================
    ALMANAC_NAME = "Item Almanac"
    
#===============================================================================
#===============================================================================
    ITEM_ICON = 144 # 詳見頁首繁中說明
    WEAPON_ICON = 2 # 詳見頁首繁中說明
    ARMOR_ICON = 41 # 詳見頁首繁中說明
      
    ELEMENT_ICONS  = {
    #   id => icon_id
        4  => 3988,  # 普通
  5  => 3989,  # 格鬥
  6  => 3990,  # 飛行
  7  => 3991,  # 毒
  8  => 3992,  # 地面
  9  => 3993,  # 岩石
  10 => 4004,  # 蟲
  11 => 4005,  # 幽靈
  12 => 4006,  # 鋼
  13 => 4007,  # 火
  14 => 4008,  # 水
  15 => 4009,  # 草
  16 => 4020,  # 電
  17 => 4021,  # 超能力
  18 => 4022,  # 冰
  19 => 4023,  # 龍
  20 => 4024,  # 惡
  21 => 4025,  # 妖精
      }
#===============================================================================
#===============================================================================
    ELEMENTS_SHOWN = [4..21]
  
#===============================================================================
#===============================================================================
    PRICE_ICON = 85
    HRECOVERY_PER_ICON = 64
    HRECOVERY_ICON = 64
    MRECOVERY_PER_ICON = 65
    MRECOVERY_ICON = 65
    HP_ICON = 96
    MP_ICON = 97
    ATK_ICON = 1
    DEF_ICON = 52
    SPI_ICON = 18
    MDF_ICON = 57
    AGI_ICON = 48
    
#===============================================================================
#===============================================================================
    HP_REC_TEXT = "HP Heal = %d"
    HP_PER_TEXT = "HP Heal = %d%"
    HP_TEXT     = "MaxHP = %d"
    MP_REC_TEXT = "MP Heal = %d"
    MP_PER_TEXT = "MP Heal = %d%"
    MP_TEXT     = "MaxMP = %d"
    ATK_TEXT    = "Attack = %d"
    DEF_TEXT    = "Defense = %d"
    SPI_TEXT    = "Intellegence = %d"
    MDF_TEXT    = "Resistance = %d"
    AGI_TEXT    = "Speed = %d"
    STATUS_ADD_TEXT = "Status Effects"
    STATUS_REMOVE_TEXT ="Status Remove"
    STATUS_GUARD_TEXT = "Status Resistance"
    ELEMENT_ADD = "Attack Elements"
    ELEMENT_GUARD = "Element Resistance"
    PRICE_TEXT  = "Cost = %d %s"
    PARAMETER_TEXT = "Parameter Boost"
    NO_STATUS_TEXT = "None"
    PERCENTAGE_SHOW = "Collection Rate = %10.2f%"
  end

"=============================================================================="
"   BELOW IS TOO DANGEROUS TO READ WITHOUT PROPER SCRIPTING SKILLS. THEREFOR,  "
"                            EDIT AT YOUR OWN RISK!                            "
"=============================================================================="
  
  module ALMANAC_REGEXP
    DONT_INCLUDE = /<Almanac out>/i
    COMMENT_ON = /<Almanac com_on>/i
    COMMENT_OFF = /<Almanac com_off>/i
    GRAPHIC = /<Almanac graphic[ ]*(\w+)>/i
  end
end


module RPG
  class BaseItem
    attr_accessor :include_flag
    attr_accessor :comment
    attr_accessor :graphic
    
    def scan_almanac_property
      @include_flag = WLTR::ALMANAC_SETUP::DEFAULT_DOCUMENTATION
      @comment = ""; @graphic = "";
      start_comment_scan
      self.note.split(/[\r\n]+/).each { |line|
      case line
      when WLTR::ALMANAC_REGEXP::DONT_INCLUDE
        @include_flag = (!WLTR::ALMANAC_SETUP::DEFAULT_DOCUMENTATION)
      when WLTR::ALMANAC_REGEXP::GRAPHIC
        @graphic = $1.to_s
      end
      }
    end
    
    def start_comment_scan
      read = false
      self.note.split(/[\r\n]+/).each { |line|
      case line
      when WLTR::ALMANAC_REGEXP::COMMENT_ON
        read = true
      when WLTR::ALMANAC_REGEXP::COMMENT_OFF
        read = false
      else
        if read
          @comment += line
        end
      end
      }
      @comment = WLTR::ALMANAC_SETUP::UNKNOWN_COMMENT if @comment == ""
    end
  end
end

class Game_System
  attr_accessor :almanac
  
  alias almanac_make initialize
  def initialize
    almanac_make
    
    @almanac = {
    "I" => make_item_blank_record,
    
    "W" => make_weapon_blank_record,
    
    "A" => make_armor_blank_record,
    }
  end
  
  def make_item_blank_record
    result = {}
    (1...$data_items.size).each { |i|
        item = $data_items[i]

        item.scan_almanac_property
        result[item.id] = false if item.include_flag
    }
    return result
  end
  
  def make_weapon_blank_record
    result = {}
    (1...$data_weapons.size).each { |i|
        item = $data_weapons[i]

        item.scan_almanac_property
        result[item.id] = false if item.include_flag
    }
    return result
  end
  
  def make_armor_blank_record
    result = {}
    (1...$data_armors.size).each { |i|
        item = $data_armors[i]

        item.scan_almanac_property
        result[item.id] = false if item.include_flag
    }
    return result
  end
  
  def complete_almanac
    (1...$data_items.size).each { |i|
        item = $data_items[i]

        next if !item.include_flag
        @almanac["I"][item.id] = true
    }
    (1...$data_weapons.size).each { |i|
        item = $data_weapons[i]

        next if !item.include_flag
        @almanac["W"][item.id] = true
    }
    (1...$data_armors.size).each { |i|
        item = $data_armors[i]

        next if !item.include_flag
        @almanac["A"][item.id] = true
    }
  end
  
  def check_item_get(code, id)
    return @almanac[code][id]
  end
  
  def flag_item_get(code, id, flag = true)
    @almanac[code][id] = flag
  end
  
  def check_item_completition(code = "IWA")
    if code.include?("I")
      (1...$data_items.size).each { |i|
        item = $data_items[i]

        next if !item.include_flag
        return false unless @almanac["I"][item.id] == true
      }
    end
    if code.include?("W")
      (1...$data_weapons.size).each { |i|
        item = $data_weapons[i]

        next if !item.include_flag
        return false unless @almanac["W"][item.id] == true
      }
    end
    if code.include?("A")
      (1...$data_armors.size).each { |i|
        item = $data_armors[i]

        next if !item.include_flag
        return false unless @almanac["A"][item.id] == true
      }
    end
    return true
  end
  
  def check_item_completition_rate(code = "IWA", variable = nil)
    total = 0
    total += @almanac["I"].size if code.include?("I")
    total += @almanac["W"].size if code.include?("W")
    total += @almanac["A"].size if code.include?("A")
    get = 0
    if code.include?("I")
      (1...$data_items.size).each { |i|
        item = $data_items[i]

        next if !item.include_flag
        get += 1 if @almanac["I"][item.id] == true
      }
    end
    if code.include?("W")
      (1...$data_weapons.size).each { |i|
        item = $data_weapons[i]

        next if !item.include_flag
        get += 1 if @almanac["W"][item.id] == true
      }
    end
    if code.include?("A")
      (1...$data_armors.size).each { |i|
        item = $data_armors[i]

        next if !item.include_flag
        get += 1 if @almanac["A"][item.id] == true
      }
    end
    result = 100.0 * get / total
    $game_variables[variable] = result if variable != nil
    return result
  end
  
  def check_item_total(code = "IWA", variable = nil)
    total = 0
    total += @almanac["I"].size if code.include?("I")
    total += @almanac["W"].size if code.include?("W")
    total += @almanac["A"].size if code.include?("A")
    $game_variables[variable] = total if variable != nil
    return total
  end
  
  def check_item_get_total(code = "IWA", variable = nil)
    get = 0
    if code.include?("I")
      (1...$data_items.size).each { |i|
        item = $data_items[i]

        next if !item.include_flag
        get += 1 if @almanac["I"][item.id] == true
      }
    end
    if code.include?("W")
      (1...$data_weapons.size).each { |i|
        item = $data_weapons[i]

        next if !item.include_flag
        get += 1 if @almanac["W"][item.id] == true
      }
    end
    if code.include?("A")
      (1...$data_armors.size).each { |i|
        item = $data_armors[i]

        next if !item.include_flag
        get += 1 if @almanac["A"][item.id] == true
      }
    end
    $game_variables[variable] = get if variable != nil
    return get
  end
end

class Game_Party < Game_Unit
  alias item_record gain_item
  def gain_item(item, n, include_equip = false)
    item_record(item, n, include_equip)
    
    case item
    when RPG::Item
      $game_system.almanac["I"][item.id] = true
    when RPG::Weapon
      $game_system.almanac["W"][item.id] = true
    when RPG::Armor
      $game_system.almanac["A"][item.id] = true
    end
  end
end

class Window_Item_Almanac_List < Window_Selectable
  def initialize(x, y, width, height, type = "I")
    super(x, y, width, height)
    @type = type
    if type.size == 2
      if type == "IW"
        @item_max = $game_system.almanac["I"].size + $game_system.almanac["W"].size
      elsif type == "IA"
        @item_max = $game_system.almanac["I"].size + $game_system.almanac["A"].size
      elsif type == "WA"
        @item_max = $game_system.almanac["W"].size + $game_system.almanac["A"].size
      end
    elsif type == "IWA"
      @item_max = ($game_system.almanac["I"].size + $game_system.almanac["W"].size + $game_system.almanac["A"].size)
    else
      @item_max = $game_system.almanac[@type].size
    end
    create_contents
    self.opacity = 0 if WLTR::ALMANAC_SETUP::BACKGROUND != ""
    @real_index = 0
    @real_item_id = []
    @index = 0
    draw_list
  end
  
  def item
    case @type
    when "I"; return $data_items[@real_item_id[@index]]
    when "W"; return $data_weapons[@real_item_id[@index]]
    when "A"; return $data_armors[@real_item_id[@index]]
    end
    if @type.size == 2
      if @type == "IW"
        if @index > $game_system.almanac["I"].size - 1
          return $data_weapons[@real_item_id[@index]]
        else
          return $data_items[@real_item_id[@index]]
        end
      elsif @type == "IA"
        if @index > $game_system.almanac["I"].size - 1
          return $data_armors[@real_item_id[@index]]
        else
          return $data_items[@real_item_id[@index]]
        end
      elsif @type == "WA"
        if @index > $game_system.almanac["W"].size - 1
          return $data_armors[@real_item_id[@index]]
        else
          return $data_weapons[@real_item_id[@index]]
        end
      end
    end
    if @type == "IWA"
      if @index > $game_system.almanac["I"].size + $game_system.almanac["W"].size - 1
        return $data_armors[@real_item_id[@index]]
      elsif @index > $game_system.almanac["I"].size - 1
        return $data_weapons[@real_item_id[@index]]
      else
        return $data_items[@real_item_id[@index]]
      end
    end
  end
  
  def draw_list
    case @type
    when "I"; size = $data_items.size
    when "W"; size = $data_weapons.size
    when "A"; size = $data_armors.size
    end
    if @type.size == 2
      if @type == "IW"
        size = $data_items.size + $data_weapons.size
      elsif @type == "IA"
        size = $data_items.size + $data_armors.size
      elsif @type == "WA"
        size = $data_weapons.size + $data_armors.size
      end
      size -= 1
    end
    if @type == "IWA"
      size = $data_items.size + $data_weapons.size + $data_armors.size
      size -= 2
    end
    for index in 1...size
      case @type
      when "I"; item = $data_items[index]
      when "W"; item = $data_weapons[index]
      when "A"; item = $data_armors[index]
      end
      if @type.size == 2
        if @type == "IW"
          if index > $data_items.size - 1
            item = $data_weapons[index - $data_items.size + 1]
          else
            item = $data_items[index]
          end
        elsif @type == "IA"
          if index > $data_items.size - 1
            item = $data_armors[index - $data_items.size + 1]
          else
            item = $data_items[index]
          end
        elsif @type == "WA"
          if index > $data_weapons.size - 1
            item = $data_armors[index - $data_weapons.size + 1]
          else
            item = $data_weapons[index]
          end
        end
      end
      if @type == "IWA"
        if index > $data_items.size + $data_weapons.size - 2
          item = $data_armors[index - $data_weapons.size - $data_items.size + 2]
        elsif index > $data_items.size - 1
          item = $data_weapons[index - $data_items.size + 1]
        else
          item = $data_items[index]
        end
      end
      draw_item(index) if item.include_flag
    end
  end
  
  def draw_item(index)
    @real_index += 1
    case @type
    when "I"; item = $data_items[index]
    when "W"; item = $data_weapons[index]
    when "A"; item = $data_armors[index]
    end
      if @type.size == 2
        if @type == "IW"
          if index > $data_items.size - 1
            item = $data_weapons[index - $data_items.size + 1]
          else
            item = $data_items[index] 
          end
        elsif @type == "IA"
          if index > $data_items.size - 1
            item = $data_armors[index - $data_items.size + 1]
          else
            item = $data_items[index]
          end
        elsif @type == "WA"
          if index > $data_weapons.size - 1
            item = $data_armors[index - $data_weapons.size + 1]
          else
            item = $data_weapons[index]
          end
        end
      end
    
      if @type == "IWA"
        if index > $data_items.size + $data_weapons.size - 2
          item = $data_armors[index - $data_weapons.size - $data_items.size + 2]
        elsif index > $data_items.size - 1
          item = $data_weapons[index - $data_items.size + 1]
        else
          item = $data_items[index]
        end
      end
    rect = item_rect(@real_index - 1)
    self.contents.clear_rect(rect)
    if item != nil
      case item
      when RPG::Item
        code = "I"
      when RPG::Weapon
        code = "W"
      when RPG::Armor
        code = "A"
      end
      known = $game_system.almanac[code][item.id]
      @real_item_id << item.id
      name = item.name
      icon = item.icon_index
      if !known
        count = name.size + 1
        icon = WLTR::ALMANAC_SETUP::UNKNOWN_ICON
        name = ""
        for i in 1...count
          name += WLTR::ALMANAC_SETUP::UNKNOWN_WORD
        end
      end
      rect.width -= 4
      self.contents.draw_text(0, rect.y, 24, rect.height, sprintf("%2d", @real_index), 2)
      draw_icon(icon, 24, rect.y, true)
      self.contents.draw_text(rect.x + 48, rect.y, 172, WLH, name)
    end
  end
  
  def update_help
    des = item.description
    case item
    when RPG::Item
      code = "I"
    when RPG::Weapon
      code = "W"
    when RPG::Armor
      code = "A"
    end
    des = WLTR::ALMANAC_SETUP::UNKNOWN_HELP if !$game_system.check_item_get(code, item.id)
    @help_window.set_text(item == nil ? "" : des)
  end
end

class Window_Almanac_Item_Status < Window_Base
  attr_accessor :item
  attr_accessor :page
  
  def initialize(x, y, width, height, item, page = 1)
    super(x, y, width, height)
    @item = item
    @page = page
    refresh(@page)
    self.opacity = 0 if WLTR::ALMANAC_SETUP::BACKGROUND != ""
  end
  
  def refresh(page)
    @page = page
    self.contents.clear
    case item
    when RPG::Item
      code = "I"
    when RPG::Weapon
      code = "W"
    when RPG::Armor
      code = "A"
    end
    known = $game_system.almanac[code][item.id]
    if !known
      draw_icon(WLTR::ALMANAC_SETUP::UNKNOWN_ICON, 0, 0, true)
      count = item.name.size + 1
      name = ""
      for i in 1...count
        name += WLTR::ALMANAC_SETUP::UNKNOWN_WORD
      end
      self.contents.draw_text(24, 0, 172, WLH, name)
        dy = WLH * 2
        x = 8
        y = WLH * 2
        text = WLTR::ALMANAC_SETUP::UNKNOWN_COMMENT
        return if text == nil
        txsize = 24
        nwidth = 500
        dx = 28; dy = WLH * 2
    
        text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
        text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
        text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
        lines = text.split(/(?:[|]|\\n)/i)
        lines.each_with_index { |l, i|
        l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
          self.contents.draw_text(0, i * txsize + dy, nwidth, WLH, l, 0)}
    else
      draw_item_name(item, 0, 0)
      case item
      when RPG::Item
        icon = WLTR::ALMANAC_SETUP::ITEM_ICON
      when RPG::Weapon
        icon = WLTR::ALMANAC_SETUP::WEAPON_ICON
      when RPG::Armor
        icon = WLTR::ALMANAC_SETUP::ARMOR_ICON
      end
      draw_icon(icon, self.width - 60, 0, true)
      page += 1 if !WLTR::ALMANAC_SETUP::GRAPHIC_USE
      case page
      when 1
        graph = Cache.picture(item.graphic)
        w = graph.width
        self.contents.blt((self.width / 2) - (w / 2) , WLH, graph, graph.rect)
        case item
        when RPG::Item
          type = Vocab::item
        when RPG::Weapon
          type = Vocab::weapon
        when RPG::Armor
          type = Vocab::armor3
        end
        y = WLTR::ALMANAC_SETUP::ITEM_GRAPH_HEIGHT
        y = WLH if item.graphic == ""
        self.contents.draw_text(0, y, self.width, 24, sprintf(WLTR::ALMANAC_SETUP::PAGE_1_TEXT, type))
      when 2
        case item
        when RPG::Item
          draw_icon(WLTR::ALMANAC_SETUP::HRECOVERY_ICON, 0, WLH*2, true)
          self.contents.draw_text(24, WLH * 2, 272, 24, sprintf(WLTR::ALMANAC_SETUP::HP_REC_TEXT, item.hp_recovery))
          draw_icon(WLTR::ALMANAC_SETUP::HRECOVERY_PER_ICON, 0, WLH*3, true)
          self.contents.draw_text(24, WLH * 3, 272, 24, sprintf(WLTR::ALMANAC_SETUP::HP_PER_TEXT, item.hp_recovery_rate))
          draw_icon(WLTR::ALMANAC_SETUP::MRECOVERY_ICON, 0, WLH*4, true)
          self.contents.draw_text(24, WLH * 4, 272, 24, sprintf(WLTR::ALMANAC_SETUP::MP_REC_TEXT, item.mp_recovery))
          draw_icon(WLTR::ALMANAC_SETUP::MRECOVERY_PER_ICON, 0, WLH*5, true)
          self.contents.draw_text(24, WLH * 5, 272, 24, sprintf(WLTR::ALMANAC_SETUP::MP_PER_TEXT, item.mp_recovery_rate))
          
          self.contents.draw_text(24, WLH * 6, 272, 24, WLTR::ALMANAC_SETUP::STATUS_ADD_TEXT)
          x = 0
          for state in item.plus_state_set   
            status = $data_states[state]
            draw_icon(status.icon_index, x, WLH * 7, true)
            x += 24
          end
          self.contents.draw_text(24, WLH * 8, 272, 24, WLTR::ALMANAC_SETUP::STATUS_REMOVE_TEXT)
          x = 0
          for state in item.minus_state_set
            status = $data_states[state]
            draw_icon(status.icon_index, x, WLH * 9, true)
            x += 24
          end
          
          draw_icon(WLTR::ALMANAC_SETUP::PRICE_ICON, 0, WLH*10, true)
          self.contents.draw_text(24, WLH * 10, 272, 24, sprintf(WLTR::ALMANAC_SETUP::PRICE_TEXT, item.price, Vocab::gold))
          
          self.contents.draw_text(0, WLH * 11, 272, 24, WLTR::ALMANAC_SETUP::PARAMETER_TEXT, 1)
          case item.parameter_type
          when 0
            self.contents.draw_text(0, WLH * 12, 272, 24, WLTR::ALMANAC_SETUP::NO_STATUS_TEXT, 1)
          when 1
            draw_icon(WLTR::ALMANAC_SETUP::HP_ICON, 0, WLH * 12, true)
            self.contents.draw_text(24, WLH * 12, 272, 24, sprintf(WLTR::ALMANAC_SETUP::HP_TEXT, item.parameter_points))
          when 2
            draw_icon(WLTR::ALMANAC_SETUP::MP_ICON, 0, WLH * 12, true)
            self.contents.draw_text(24, WLH * 12, 272, 24, sprintf(WLTR::ALMANAC_SETUP::MP_TEXT, item.parameter_points))
          when 3
            draw_icon(WLTR::ALMANAC_SETUP::ATK_ICON, 0, WLH * 12, true)
            self.contents.draw_text(24, WLH * 12, 272, 24, sprintf(WLTR::ALMANAC_SETUP::ATK_TEXT, item.parameter_points))
          when 4
            draw_icon(WLTR::ALMANAC_SETUP::DEF_ICON, 0, WLH * 12, true)
            self.contents.draw_text(24, WLH * 12, 272, 24, sprintf(WLTR::ALMANAC_SETUP::DEF_TEXT, item.parameter_points))
          when 5
            draw_icon(WLTR::ALMANAC_SETUP::SPI_ICON, 0, WLH * 12, true)
            self.contents.draw_text(24, WLH * 12, 272, 24, sprintf(WLTR::ALMANAC_SETUP::SPI_TEXT, item.parameter_points))
          when 6
            draw_icon(WLTR::ALMANAC_SETUP::AGI_ICON, 0, WLH * 12, true)
            self.contents.draw_text(24, WLH * 12, 272, 24, sprintf(WLTR::ALMANAC_SETUP::AGI_TEXT, item.parameter_points))
          end
        
        when RPG::Weapon
          draw_icon(WLTR::ALMANAC_SETUP::ATK_ICON, 0, WLH * 2, true)
          self.contents.draw_text(24, WLH * 2, 200, 24, sprintf(WLTR::ALMANAC_SETUP::ATK_TEXT, item.atk), 2)
          draw_icon(WLTR::ALMANAC_SETUP::DEF_ICON, 0, WLH * 3, true)
          self.contents.draw_text(24, WLH * 3, 200, 24, sprintf(WLTR::ALMANAC_SETUP::DEF_TEXT, item.def), 2)
          draw_icon(WLTR::ALMANAC_SETUP::SPI_ICON, 0, WLH * 4, true)
          self.contents.draw_text(24, WLH * 4, 200, 24, sprintf(WLTR::ALMANAC_SETUP::SPI_TEXT, item.spi), 2)
          if defined?(CSU) != nil
            draw_icon(WLTR::ALMANAC_SETUP::AGI_ICON, 0, WLH * 6, true) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
            self.contents.draw_text(24, WLH * 6, 200, 24, sprintf(WLTR::ALMANAC_SETUP::AGI_TEXT, item.agi), 2) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
          else
            draw_icon(WLTR::ALMANAC_SETUP::AGI_ICON, 0, WLH * 5, true)
            self.contents.draw_text(24, WLH * 5, 200, 24, sprintf(WLTR::ALMANAC_SETUP::AGI_TEXT, item.agi), 2)
          end
          if defined?(CSU)
            draw_icon(WLTR::ALMANAC_SETUP::MDF_ICON, 0, WLH * 5, true) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
            self.contents.draw_text(24, WLH * 5, 200, 24, sprintf(WLTR::ALMANAC_SETUP::MDF_TEXT, item.mdf), 2) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
          end 
          
          self.contents.draw_text(24, WLH * 7, 200, 24, WLTR::ALMANAC_SETUP::ELEMENT_ADD)
          x = 0
          for el in item.element_set
            next unless WLTR::ALMANAC_SETUP::ELEMENTS_SHOWN.include?(el)
            draw_icon(WLTR::ALMANAC_SETUP::ELEMENT_ICONS[el], x, WLH * 8, true)
            x += 24
          end
          self.contents.draw_text(24, WLH * 9, 200, 24, WLTR::ALMANAC_SETUP::STATUS_ADD_TEXT)
          x = 0
          for state in item.state_set
            status = $data_states[state]
            draw_icon(status.icon_index, x, WLH * 10, true)
            x += 24
          end
        
          draw_icon(WLTR::ALMANAC_SETUP::PRICE_ICON, 0, WLH*11, true)
          self.contents.draw_text(24, WLH * 11, 272, 24, sprintf(WLTR::ALMANAC_SETUP::PRICE_TEXT, item.price, Vocab::gold))
        when RPG::Armor
          draw_icon(WLTR::ALMANAC_SETUP::ATK_ICON, 0, WLH * 2, true)
          self.contents.draw_text(24, WLH * 2, 200, 24, sprintf(WLTR::ALMANAC_SETUP::ATK_TEXT, item.atk), 2)
          draw_icon(WLTR::ALMANAC_SETUP::DEF_ICON, 0, WLH * 3, true)
          self.contents.draw_text(24, WLH * 3, 200, 24, sprintf(WLTR::ALMANAC_SETUP::DEF_TEXT, item.def), 2)
          draw_icon(WLTR::ALMANAC_SETUP::SPI_ICON, 0, WLH * 4, true)
          self.contents.draw_text(24, WLH * 4, 200, 24, sprintf(WLTR::ALMANAC_SETUP::SPI_TEXT, item.spi), 2)
          if defined?(CSU) != nil
            draw_icon(WLTR::ALMANAC_SETUP::AGI_ICON, 0, WLH * 6, true) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
            self.contents.draw_text(24, WLH * 6, 200, 24, sprintf(WLTR::ALMANAC_SETUP::AGI_TEXT, item.agi), 2) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
          else
            draw_icon(WLTR::ALMANAC_SETUP::AGI_ICON, 0, WLH * 5, true)
            self.contents.draw_text(24, WLH * 5, 200, 24, sprintf(WLTR::ALMANAC_SETUP::AGI_TEXT, item.agi), 2)
          end
          if defined?(CSU)
            draw_icon(WLTR::ALMANAC_SETUP::MDF_ICON, 0, WLH * 5, true) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
            self.contents.draw_text(24, WLH * 5, 200, 24, sprintf(WLTR::ALMANAC_SETUP::MDF_TEXT, item.mdf), 2) if CSU::SCRIPTLIST.include?("Ultimate Battler Stat")
          end 
        
          self.contents.draw_text(24, WLH * 7, 200, 24, WLTR::ALMANAC_SETUP::ELEMENT_GUARD)
          x = 0
          for el in item.element_set
            next unless WLTR::ALMANAC_SETUP::ELEMENTS_SHOWN.include?(el)
            draw_icon(WLTR::ALMANAC_SETUP::ELEMENT_ICONS[el], x, WLH * 8, true)
            x += 24
          end
          self.contents.draw_text(24, WLH * 9, 200, 24, WLTR::ALMANAC_SETUP::STATUS_GUARD_TEXT)
          x = 0
          for state in item.state_set
            status = $data_states[state]
            draw_icon(status.icon_index, x, WLH * 10, true)
            x += 24
          end
        
          draw_icon(WLTR::ALMANAC_SETUP::PRICE_ICON, 0, WLH*11, true)
          self.contents.draw_text(24, WLH * 11, 272, 24, sprintf(WLTR::ALMANAC_SETUP::PRICE_TEXT, item.price, Vocab::gold))
        end
      when 3
        dy = WLH * 2
        x = 8
        y = WLH * 2
        text = @item.comment
        return if text == nil
        txsize = 24
        nwidth = 500
        dx = 28; dy = WLH * 2
    
        text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
        text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
        text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
        lines = text.split(/(?:[|]|\\n)/i)
        lines.each_with_index { |l, i|
        l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
          self.contents.draw_text(0, i * txsize + dy, nwidth, WLH, l, 0)}
      else
        custom_page(page)
      end
    end
  end
  
  def custom_page(page)
#===============================================================================
#===============================================================================


  end

end

class Scene_Almanac < Scene_Base
  def initialize(type = "IWA")
    @type = type
  end

  def start
    super
    create_menu_background
    if WLTR::ALMANAC_SETUP::BACKGROUND != ""
      @background = Sprite.new
      @background.bitmap = Cache.system(WLTR::ALMANAC_SETUP::BACKGROUND)
    end
    @viewport = Viewport.new(0, 0, 544, 416)
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    @help_window.opacity = 0 if WLTR::ALMANAC_SETUP::BACKGROUND != ""
    @collection_list = Window_Item_Almanac_List.new(0, 56, 272, 360 - 48, @type)
    @collection_list.viewport = @viewport
    @collection_status = Window_Almanac_Item_Status.new(272, 56, 272, 360, @collection_list.item)
    @collection_status.viewport = @viewport
    @collection_list.help_window = @help_window
    @percentage_window = Window_Base.new(0, 416 - 48, 272, 48)
    @percentage_window.contents.draw_text(0, 0, 272, 20, sprintf(WLTR::ALMANAC_SETUP::PERCENTAGE_SHOW, $game_system.check_item_completition_rate(@type)))
    @collection_list.active = true
    @page = 1
  end

  def terminate
    super
    dispose_menu_background
    @background.dispose if @background != nil
    @help_window.dispose
    @collection_list.dispose
    @collection_status.dispose
    @percentage_window.dispose
  end

  def return_scene
    $scene = Scene_Menu.new
  end

  def update
    super
    update_menu_background
    @help_window.update
    @collection_list.update
    @collection_status.update
    @percentage_window.update
    update_collection
  end

  def update_collection
    if @collection_status.item != @collection_list.item
      @collection_status.item = @collection_list.item 
      @collection_status.refresh(@page)
    end
    @collection_status.refresh(@page) if @page != @collection_status.page
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::RIGHT)
      return if @page == 2 and !WLTR::ALMANAC_SETUP::GRAPHIC_USE
      return if @page == 3
      Audio.se_play("Audio/SE/" + WLTR::ALMANAC_SETUP::PAGE_FLIP_SE[0], WLTR::ALMANAC_SETUP::PAGE_FLIP_SE[1], WLTR::ALMANAC_SETUP::PAGE_FLIP_SE[2])
      @page += 1
    elsif Input.trigger?(Input::LEFT)
      return if @page == 1
      Audio.se_play("Audio/SE/" + WLTR::ALMANAC_SETUP::PAGE_FLIP_SE[0], WLTR::ALMANAC_SETUP::PAGE_FLIP_SE[1], WLTR::ALMANAC_SETUP::PAGE_FLIP_SE[2])
      @page -= 1
    end
  end
end

#==============================================================================
#==============================================================================
class Window_Command < Window_Selectable
  unless method_defined?(:add_command)
  #--------------------------------------------------------------------------
  # ? ???????
  #    ?????????
  #--------------------------------------------------------------------------
  def add_command(command)
    @commands << command
    @item_max = @commands.size
    item_index = @item_max - 1
    refresh_command
    draw_item(item_index)
    return item_index
  end
  #--------------------------------------------------------------------------
  # ? ???????????
  #--------------------------------------------------------------------------
  def refresh_command
    buf = self.contents.clone
    self.height = [self.height, row_max * WLH + 32].max
    create_contents
    self.contents.blt(0, 0, buf, buf.rect)
    buf.dispose
  end
  #--------------------------------------------------------------------------
  # ? ???????
  #--------------------------------------------------------------------------
  def insert_command(index, command)
    @commands.insert(index, command)
    @item_max = @commands.size
    refresh_command
    refresh
  end
  #--------------------------------------------------------------------------
  # ? ???????
  #--------------------------------------------------------------------------
  def remove_command(command)
    @commands.delete(command)
    @item_max = @commands.size
    refresh
  end
  end
end

class Scene_Menu < Scene_Base
  if WLTR::ALMANAC_SETUP::ADD_TO_MENU
  #--------------------------------------------------------------------------
  # ? ????????????
  #--------------------------------------------------------------------------
  alias create_command_window_item_almanac create_command_window
  def create_command_window
    create_command_window_item_almanac

    return if $imported["CustomMenuCommand"]

    @__command_item_almanac =
      @command_window.add_command(WLTR::ALMANAC_SETUP::ALMANAC_NAME)
    if @command_window.oy > 0
      @command_window.oy -= Window_Base::WLH
    end
    @command_window.index = @menu_index
  end
  end
  #--------------------------------------------------------------------------
  # ? ?????????
  #--------------------------------------------------------------------------
  alias update_command_selection_item_almanac update_command_selection
  def update_command_selection
    current_menu_index = @__command_item_almanac
    call_item_almanac = false

    if Input.trigger?(Input::C)
      case @command_window.index
      when @__command_item_almanac  # ???????
        call_enemy_guide_flag = true
      end
    end

    # ??????????
    if call_enemy_guide_flag
      Sound.play_decision
      $scene = Scene_Almanac.new(WLTR::ALMANAC_SETUP::ALMANAC_SHOW_MENU)
      return
    end

    update_command_selection_item_almanac
  end
end
#===============================================================================
#
# 
#===============================================================================