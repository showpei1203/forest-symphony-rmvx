#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEM Item Overhaul
# 【用途】重寫 Item Scene，將道具、戰鬥道具、武器、防具、雜項、關鍵道具整合為分類 UI，並在右側 Data Window 顯示治療、傷害、元素、State、能力與自訂資料。
# 【來源】Yanfly Engine Melody - Item Overhaul；Last Date Updated: 2010.06.20。
# 【分類】COMMANDS 可使用 :usable、:battle、:weapons、:armours、:misc、:key_items、:all_items；VOCAB 設定各分類文字。目前 FS 主要啟用 :all_items、:misc、:key_items。
# 【Notetag】<key item>：標記為關鍵道具，只影響分類。<custom data> ... </custom data>：每行格式為 icon, string1, string2，用指定圖示／類別／文字加入 Data Window 自訂資料。
# 【Item Data】ITEM_DATA 控制 properties、gold_value、fontsize、HP/MP 回復圖示與文字、base damage/heal、multiplier、element、State 增減、growth/resist/bonus 等欄位。
# 【Equip Data】EQUIP_DATA 控制裝備 Data Window；:shown_stats 支援 :hp、:mp、:atk、:def、:spi、:res、:dex、:agi；ele_weapon／ele_armour／state_weapon／state_armour 是顯示文字資料。
# 【元素】SHOWN_ELEMENTS 指定要列出的元素 ID／Range；ELEMENT_ICONS 將元素 ID 對應 Icon。FS 目前已配置 Pokémon 屬性 4～21。
# 【相關素材】目前直接使用 MenuBack_item、MenuBack_mask，並使用 Iconset、角色圖等既有 UI 資源。若改版面先反查 FS Menu／Equip Help 等後續整合。
# 【相容性】會檢查 BattleEngineMelody、RES/DEX Stat、StatusMenuMelody、EquipmentOverhaul 等 $imported；因此本頁資料顯示不是孤立系統，維持現行順序。
# 【呼叫方式】一般由主選單 Item command 進入 Scene_Item；不需要事件 Script Call。自訂物品顯示優先使用上述 Notetag，而非在 Window_ItemData 寫死 Item ID。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#===============================================================================
# 
# Yanfly Engine Melody - Item Overhaul
# Last Date Updated: 2010.06.20
# 
# 
#===============================================================================
# -----------------------------------------------------------------------------
#===============================================================================
# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# <key item>
# 
# <custom data>
# </custom data>
#===============================================================================

$imported = {} if $imported == nil
$imported["ItemOverhaul"] = true

module YEM
  module ITEM
    
    #===========================================================================
    # --------------------------------------------------------------------------
    #===========================================================================
    
    # 
    # 
    COMMANDS =[
      :all_items,
      :misc,
      :key_items,
    ] # 此結構不可刪除。
    
    VOCAB ={
      :usable         => "",
      :battle         => "",
      :weapons        => "",
      :armours        => "",
      :misc           => "",
      :key_items      => "",
      :all_items      => "",
    } # 此結構不可刪除。
    
    #===========================================================================
    # --------------------------------------------------------------------------
    #===========================================================================
    
    DRAW_GOLD_ICON  = 205
    DRAW_GOLD_TEXT  = "價錢"
    
    ITEM_DATA ={
      :properties   => "資訊",
      :gold_value   => true,
      :fontsize     => 20,
      :hp_heal_icon => 128,
      :hp_heal_text => "恢復HP",
      :mp_heal_icon => 214,
      :mp_heal_text => "恢復MP",
      :dmg_icon     => 119,
      :base_dmg     => "傷害",
      :heal_icon    => 128,
      :base_heal    => "回覆",
      :multiplier   => "%s 影響",
      :element      => "屬性",
      :add_state    => "附加",
      :rem_state    => "解除",
      :growth       => "%s Growth",
      :resist       => "%s Resist",
      :bonus        => "%s Bonus",
    } # 此結構不可刪除。
    
    EQUIP_DATA ={
      :properties   => "裝備",
      :gold_value   => false,
      :fontsize     => 20,
      :shown_stats  => [:hp, :mp, :atk, :def, :spi, :res, :dex, :agi],
      :ele_weapon   => "Adds",
      :ele_armour   => "Guards",
      :state_weapon => "Applies",
      :state_armour => "Resists",
    } # 此結構不可刪除。
    
    SHOWN_ELEMENTS = []
    
    ELEMENT_ICONS ={
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
    } # 此結構不可刪除。
    
  end
end

#===============================================================================
#===============================================================================

module YEM
  module REGEXP
  module BASEITEM
      
    KEY_ITEM = /<(?:KEY_ITEM|key item|key)>/i
    
    CUSTOM_DATA1 = /<(?:CUSTOM_DATA|custom data)>/i
    CUSTOM_DATA2 = /<\/(?:CUSTOM_DATA|custom data)>/i
    
  end
  end
  module ITEM
    module_function
    #--------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    def convert_integer_array(array)
      result = []
      array.each { |i|
        case i
        when Range; result |= i.to_a
        when Integer; result |= [i]
        end }
      return result
    end
  
    #--------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    SHOWN_ELEMENTS = convert_integer_array(SHOWN_ELEMENTS)
  end
end

#===============================================================================
# module Icon
#===============================================================================

module Icon
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.gold_cost; return YEM::ITEM::DRAW_GOLD_ICON; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.element(element_id)
    icon = YEM::ITEM::ELEMENT_ICONS[element_id]
    return (icon == nil) ? 0 : icon
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.hp_heal; return YEM::ITEM::ITEM_DATA[:hp_heal_icon]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.mp_heal; return YEM::ITEM::ITEM_DATA[:mp_heal_icon]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.base_damage; return YEM::ITEM::ITEM_DATA[:dmg_icon]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.base_healing; return YEM::ITEM::ITEM_DATA[:heal_icon]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def self.stat(actor, item); return 0; end
  
end # 圖示

#===============================================================================
#===============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :custom_data
  attr_accessor :key_item
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yem_cache_baseitem_io
    return if @cached_baseitem_io; @cached_baseitem_io = true
    @key_item = false
    enable_custom_data = false
    @custom_data = [] unless self.is_a?(RPG::Skill)
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEM::REGEXP::BASEITEM::KEY_ITEM
        @key_item = true
      #---
      when YEM::REGEXP::BASEITEM::CUSTOM_DATA1
        next if self.is_a?(RPG::Skill)
        enable_custom_data = true
      when YEM::REGEXP::BASEITEM::CUSTOM_DATA2
        next if self.is_a?(RPG::Skill)
        enable_custom_data = false
      when /(\d+),[ ](.*),[ ](.*)/i
        next unless enable_custom_data
        next if self.is_a?(RPG::Skill)
        array = [$1.to_i, $2.to_s, $3.to_s]
        @custom_data.push(array)
      end
    } # end self.note.split
  end
  
end

#===============================================================================
#===============================================================================

class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias 方法： load_bt_database
  #--------------------------------------------------------------------------
  alias load_bt_database_io load_bt_database unless $@
  def load_bt_database
    load_bt_database_io
    load_io_cache
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： load_database
  #--------------------------------------------------------------------------
  alias load_database_io load_database unless $@
  def load_database
    load_database_io
    load_io_cache
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：load_io_cache
  #--------------------------------------------------------------------------
  def load_io_cache
    groups = [$data_items, $data_weapons, $data_armors]
    for group in groups
      for obj in group
        next if obj == nil
        obj.yem_cache_baseitem_io if obj.is_a?(RPG::BaseItem)
      end
    end
  end
  
end

#===============================================================================
#===============================================================================

class Window_ItemStatus < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    super(160, 0, Graphics.width - 160, 128)
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item = @item_window == nil ? nil : @item_window.item
    draw_party_members
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_item_window(new_item_window)
    @item_window = new_item_window
    update
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    return if @item_window == nil
    refresh if @item != @item_window.item
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item
    return if @item == nil
    draw_icon(@item.icon_index, 0, 0)
    #self.contents.draw_text(24, 0, contents.width-28, WLH, @item.name, 0)
    self.contents.draw_text(29, 0, contents.width-33, WLH, @item.name, 0)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_party_members
    $game_temp.in_battle = true
    size = $game_party.members.size
    dx = (contents.width - (size * 64))/2 - 48
    #dx = 38
    #dx = 8
    dy = contents.height * 3/4 - 10
    for member in $game_party.members
      next if member == nil
      rect = Rect.new (dx-15, dy-35, 68, 40)
      self.contents.fill_rounded_rect(rect, Color.new(0, 0, 0, 128))
      draw_member(member, dx, dy)#控制間距
      draw_actor_hp_gauge(member, dx+20, dy-40, 25)
      draw_actor_mp_gauge(member, dx+20, dy-25, 25)
      draw_actor_state(member, dx-13, dy+3, 25)
      
      dx += 84
    end
    $game_temp.in_battle = false
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_member(actor, dx, dy)
    bitmap = Cache.character(actor.character_name + "_1")
    sign = actor.character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = actor.character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    if @item.is_a?(RPG::Weapon) or @item.is_a?(RPG::Armor)
      opacity = actor.equippable?(@item) ? 255 : 128
    elsif @item.is_a?(RPG::Item)
      opacity = @item.for_friend? ? 255 : 128
    else
      opacity = 255
    end
    self.contents.blt(dx - cw / 2, dy - ch, bitmap, src_rect, opacity)
  end
  
end

#===============================================================================
#===============================================================================

class Window_ItemList < Window_Selectable
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(help_window)
    @help_window = help_window
    dy = @help_window.y + @help_window.height
    super(0, dy, Graphics.width - 240, Graphics.height - dy)
    refresh
    self.active = false
    self.index = 0
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item; return @data[[self.index, 0].max]; end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def used_item_refresh(array)
    for item in array
      next if item == nil
      next unless @data.include?(item)
      refresh
      break
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for item in $game_party.items
      next unless include?(item)
      @data.push(item)
    end
    @data.push(nil) if @data.size <= 0
    @item_max = @data.size
    self.index = [self.index, @item_max - 1].min
    create_contents
    for i in 0...@item_max; draw_item(i); end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.name == ""
    return false unless item.is_a?(RPG::Item)
    return item.menu_ok?
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    return if item == nil
    enabled = enable?(item)
    draw_obj_name(item, rect.clone, enabled)
    draw_obj_charges(item, rect.clone, enabled)
    draw_obj_total(item, rect.clone, enabled)
    ##############
    ##############
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if item == nil
    return $game_party.has_item?(item)
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：draw_obj_name
  #--------------------------------------------------------------------------
  def draw_obj_name(obj, rect, enabled)
    draw_icon(obj.icon_index, rect.x, rect.y, enabled)
    self.contents.font.size = Font.default_size# + 1
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    rect.width -= 48
    #self.contents.draw_text(rect.x+24, rect.y, rect.width-24, WLH, obj.name)
    self.contents.draw_text(rect.x+29, rect.y, rect.width-29, WLH, obj.name)
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：draw_obj_charges
  #--------------------------------------------------------------------------
  def draw_obj_charges(obj, rect, enabled)
    return unless $imported["BattleEngineMelody"]
    return unless obj.is_a?(RPG::Item)
    return unless obj.consumable
    return if obj.charges <= 1
    $game_party.item_charges = {} if $game_party.item_charges == nil
    $game_party.item_charges[obj.id] = obj.charges if
      $game_party.item_charges[obj.id] == nil
    charges = $game_party.item_charges[obj.id]
    dx = rect.x; dy = rect.y + WLH/3
    self.contents.font.size = YEM::BATTLE_ENGINE::ITEM_SETTINGS[:charge]
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, 24, WLH * 2/3, charges, 2)
    self.contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：draw_obj_total
  #--------------------------------------------------------------------------
  def draw_obj_total(obj, rect, enabled)
    if $imported["BattleEngineMelody"]
      hash = YEM::BATTLE_ENGINE::ITEM_SETTINGS
    else
      hash ={ :size => Font.default_size, :colour => 0, :text => "×%2d" }
    end
    number = $game_party.item_number(obj)
    dx = rect.x + rect.width - 36; dy = rect.y; dw = 32
    text = sprintf(hash[:text], number)
    self.contents.font.size = hash[:size]
    self.contents.font.color = text_color(hash[:colour])
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(dx, dy, dw, WLH, text, 2)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end

#===============================================================================
#===============================================================================

class Window_BattleItemList < Window_ItemList
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.name == ""
    return false unless item.is_a?(RPG::Item)
    return false if item.menu_ok?
    return item.battle_ok?
  end
  
end

#===============================================================================
#===============================================================================

class Window_WeaponItemList < Window_ItemList
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.name == ""
    return item.is_a?(RPG::Weapon)
  end
  
end

#===============================================================================
#===============================================================================

class Window_ArmourItemList < Window_ItemList
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.name == ""
    return item.is_a?(RPG::Armor)
  end
  
end

#===============================================================================
#===============================================================================

class Window_MiscItemList < Window_ItemList
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.name == ""
    return false if item.is_a?(RPG::Weapon)
    return false if item.is_a?(RPG::Armor)
    return false if item.menu_ok?
    return false if item.battle_ok?
    return false if item.key_item
    return true
  end
  
end

#===============================================================================
#===============================================================================

class Window_KeyItemList < Window_ItemList
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.name == ""
    return item.key_item
  end
  
end

#===============================================================================
#===============================================================================

class Window_AllItemList < Window_ItemList
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.name == ""
    return true
  end
  
end

#===============================================================================
#===============================================================================

class Window_ItemData < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(help_window)
    dy = help_window.y + help_window.height
    super(Graphics.width - 240, dy, 240, Graphics.height - dy)
    create_clone
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_clone
    @clone = Game_Actor.new(1)
    @clone.maxhp = @clone.base_maxhp
    @clone.maxmp = @clone.base_maxmp
    @clone.atk = @clone.base_atk
    @clone.def = @clone.base_def
    @clone.spi = @clone.base_spi
    @clone.res = @clone.base_res if $imported["RES Stat"]
    @clone.dex = @clone.base_dex if $imported["DEX Stat"]
    @clone.agi = @clone.base_agi
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_item_window(new_item_window)
    @item_window = new_item_window
    update
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    return if @item_window == nil
    refresh if @item != @item_window.item
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item = @item_window.item
    return if @item == nil
    dx = 0; dy = 0
    dy = draw_item_name(dy)
    if @item.is_a?(RPG::Item)
      @hash = YEM::ITEM::ITEM_DATA
      dy = draw_item_properties(dy)
    elsif @item.is_a?(RPG::Weapon) or @item.is_a?(RPG::Armor)
      @hash = YEM::ITEM::EQUIP_DATA
      dy = draw_equip_properties(dy)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item_name(dy)
    draw_icon(@item.icon_index, 15, dy)
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    self.contents.draw_text(15, dy, contents.width-28, WLH, @item.name,1)
    dy += WLH
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item_properties(dy)
    dy = draw_properties(dy)
    dy = draw_item_value(dy)
    dy = draw_healing_properties(dy)
    dy = draw_base_damage(dy)
    dy = draw_multipliers(dy)
    dy = draw_elements(dy)
    dy = draw_plus_states(dy)
    dy = draw_minus_states(dy)
    dy = draw_item_growth(dy)
    dy = draw_custom_data(dy)
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_equip_properties(dy)
    dy = draw_properties(dy)
    dy = draw_item_value(dy)
    dy = draw_equip_stats(dy)
    dy = draw_elements(dy)
    dy = draw_states(dy)
    dy = draw_custom_data(dy)
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_properties(dy)
    text = @hash[:properties]
    self.contents.font.size = @hash[:fontsize]
    self.contents.font.color = system_color
    self.contents.draw_text(4, dy, contents.width-8, WLH, text, 1)
    dy += WLH
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item_value(dy)
    return dy unless @hash[:gold_value]
    return dy if @item.price == 0
    draw_icon(Icon.gold_cost, 0, dy)
    text = YEM::ITEM::DRAW_GOLD_TEXT
    self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
    text = sprintf("%d%s", @item.price, Vocab.gold)
    self.contents.font.color = normal_color
    self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
    dy += WLH
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_healing_properties(dy)
    return dy if dy + WLH > contents.height
    #---
    if @item.hp_recovery_rate != 0 or @item.hp_recovery != 0
      draw_icon(Icon.hp_heal, 0, dy)
      self.contents.font.color = system_color
      text = @hash[:hp_heal_text]
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      self.contents.font.color = normal_color
      if @item.hp_recovery_rate != 0 and @item.hp_recovery != 0
        text = sprintf("%+d%%", @item.hp_recovery_rate)
        self.contents.draw_text(24, dy, (contents.width-28)*2/3, WLH, text, 2)
        text = sprintf("%+d", @item.hp_recovery)
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      elsif @item.hp_recovery_rate != 0
        text = sprintf("%+d%%", @item.hp_recovery_rate)
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      elsif @item.hp_recovery != 0
        text = sprintf("%+d", @item.hp_recovery)
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      end
      dy += WLH
    end
    #---
    return dy if dy + WLH > contents.height
    #---
    if @item.mp_recovery_rate != 0 or @item.mp_recovery != 0
      draw_icon(Icon.mp_heal, 0, dy)
      self.contents.font.color = system_color
      text = @hash[:mp_heal_text]
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      self.contents.font.color = normal_color
      if @item.mp_recovery_rate != 0 and @item.mp_recovery != 0
        text = sprintf("%+d%%", @item.mp_recovery_rate)
        self.contents.draw_text(24, dy, (contents.width-28)*2/3, WLH, text, 2)
        text = sprintf("%+d", @item.mp_recovery)
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      elsif @item.mp_recovery_rate != 0
        text = sprintf("%+d%%", @item.mp_recovery_rate)
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      elsif @item.mp_recovery != 0
        text = sprintf("%+d", @item.mp_recovery)
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      end
      dy += WLH
    end
    #---
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_base_damage(dy)
    return dy if dy + WLH > contents.height
    return dy if (-5..5) === @item.base_damage
    if @item.base_damage > 0
      draw_icon(Icon.base_damage, 0, dy)
      text = @hash[:base_dmg]
    else
      draw_icon(Icon.base_healing, 0, dy)
      text = @hash[:base_heal]
    end
    self.contents.font.color = system_color
    self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
    self.contents.font.color = normal_color
    text = (@item.base_damage).abs
    self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2); dy += WLH
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_multipliers(dy)
    return dy if dy + WLH > contents.height
    return dy if @item.base_damage == 0
    icon = @item.base_damage > 0 ? Icon.base_damage : Icon.base_healing
    #---
    if @item.atk_f > 0
      draw_icon(icon, 0, dy)
      text = sprintf(@hash[:multiplier], Vocab.atk)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = sprintf("%s%%", @item.atk_f)
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    #---
    return dy if dy + WLH > contents.height
    #---
    if $imported["BattleEngineMelody"] and @item.def_f > 0
      draw_icon(icon, 0, dy)
      text = sprintf(@hash[:multiplier], Vocab.def)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = sprintf("%s%%", @item.def_f)
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    #---
    return dy if dy + WLH > contents.height
    #---
    if @item.spi_f > 0
      draw_icon(icon, 0, dy)
      text = sprintf(@hash[:multiplier], Vocab.spi)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = sprintf("%s%%", @item.spi_f)
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    #---
    return dy if dy + WLH > contents.height
    #---
    if $imported["BattleEngineMelody"] and $imported["RES Stat"] and
    @item.res_f > 0
      draw_icon(icon, 0, dy)
      text = sprintf(@hash[:multiplier], Vocab.res)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = sprintf("%s%%", @item.res_f)
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    #---
    return dy if dy + WLH > contents.height
    #---
    if $imported["BattleEngineMelody"] and $imported["DEX Stat"] and
    @item.dex_f > 0
      draw_icon(icon, 0, dy)
      text = sprintf(@hash[:multiplier], Vocab.dex)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = sprintf("%s%%", @item.dex_f)
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    #---
    return dy if dy + WLH > contents.height
    #---
    if $imported["BattleEngineMelody"] and @item.agi_f > 0
      draw_icon(icon, 0, dy)
      text = sprintf(@hash[:multiplier], Vocab.agi)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = sprintf("%s%%", @item.agi_f)
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    #---
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_elements(dy)
    return dy if @item.element_set == []
    for element_id in YEM::ITEM::SHOWN_ELEMENTS
      break if dy + WLH > contents.height
      next unless @item.element_set.include?(element_id)
      draw_icon(Icon.element(element_id), 0, dy)
      text = @hash[:element] if @item.is_a?(RPG::Item)
      text = @hash[:ele_weapon] if @item.is_a?(RPG::Weapon)
      text = @hash[:ele_armour] if @item.is_a?(RPG::Armor)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = $data_system.elements[element_id]
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def total_drawn_states(array)
    result = 0
    for state_id in array
      next if $data_states[state_id] == nil
      next if $data_states[state_id].icon_index == 0
      result += 1
    end
    return [result, 8].min
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_states(dy)
    return dy if @item.state_set == []
    total = total_drawn_states(@item.state_set)
    if total == 1
      return dy if dy + WLH > contents.height
      state = $data_states[@item.state_set[0]]
      draw_icon(state.icon_index, 0, dy)
      text = @hash[:state_weapon] if @item.is_a?(RPG::Weapon)
      text = @hash[:state_armour] if @item.is_a?(RPG::Armor)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = state.name
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
    else
      return dy if dy + WLH*2 > contents.height
      text = @hash[:state_weapon] if @item.is_a?(RPG::Weapon)
      text = @hash[:state_armour] if @item.is_a?(RPG::Armor)
      self.contents.font.color = system_color
      self.contents.draw_text(4, dy, contents.width-8, WLH, text, 1)
      dy += WLH
      dx = (contents.width - total*24)/2
      for state_id in @item.state_set
        break if dx + 24 > contents.width
        state = $data_states[state_id]
        next if state.icon_index == 0
        draw_icon(state.icon_index, dx, dy)
        dx += 24
      end
    end
    dy += WLH
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_plus_states(dy)
    return dy if @item.plus_state_set == []
    total = total_drawn_states(@item.plus_state_set)
    if total == 1
      return dy if dy + WLH > contents.height
      state = $data_states[@item.plus_state_set[0]]
      draw_icon(state.icon_index, 0, dy)
      text = @hash[:add_state]
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = state.name
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
    else
      return dy if dy + WLH*2 > contents.height
      text = @hash[:add_state]
      self.contents.font.color = system_color
      self.contents.draw_text(4, dy, contents.width-8, WLH, text, 1)
      dy += WLH
      dx = (contents.width - total*24)/2
      for state_id in @item.plus_state_set
        break if dx + 24 > contents.width
        state = $data_states[state_id]
        next if state.icon_index == 0
        draw_icon(state.icon_index, dx, dy)
        dx += 24
      end
    end
    dy += WLH
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_minus_states(dy)
    return dy if @item.minus_state_set == []
    total = total_drawn_states(@item.minus_state_set)
    if total == 1
      return dy if dy + WLH > contents.height
      state = $data_states[@item.minus_state_set[0]]
      draw_icon(state.icon_index, 0, dy)
      text = @hash[:rem_state]
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = state.name
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
    else
      return dy if dy + WLH*2 > contents.height
      text = @hash[:rem_state]
      self.contents.font.color = system_color
      self.contents.draw_text(4, dy, contents.width-8, WLH, text, 1)
      dy += WLH
      dx = (contents.width - total*24)/2
      for state_id in @item.minus_state_set
        break if dx + 24 > contents.width
        state = $data_states[state_id]
        next if state.icon_index == 0
        draw_icon(state.icon_index, dx, dy)
        dx += 24
      end
    end
    dy += WLH
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item_growth(dy)
    #---
    if @item.parameter_type != 0
      case @item.parameter_type
      when 1; text = sprintf(@hash[:growth], Vocab.hp)
      when 2; text = sprintf(@hash[:growth], Vocab.mp)
      when 3; text = sprintf(@hash[:growth], Vocab.atk)
      when 4; text = sprintf(@hash[:growth], Vocab.def)
      when 5; text = sprintf(@hash[:growth], Vocab.spi)
      when 6; text = sprintf(@hash[:growth], Vocab.agi)
      end
      draw_icon(@item.icon_index, 0, dy)
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = sprintf("%+d", @item.parameter_points)
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    #---
    if $imported["StatusMenuMelody"]
      for stat in [:hp, :mp, :atk, :def, :spi, :res, :dex, :agi]
        return dy if dy + WLH > contents.height
        next if stat == :res and !$imported["RES Stat"]
        next if stat == :dex and !$imported["DEX Stat"]
        next if @item.stat_growth[stat] == 0 or @item.stat_growth[stat] == nil
        text = sprintf(@hash[:growth], eval("Vocab." + stat.to_s))
        draw_icon(@item.icon_index, 0, dy)
        self.contents.font.color = system_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
        text = sprintf("%+d", @item.stat_growth[stat])
        self.contents.font.color = normal_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
        dy += WLH
      end
    end
    #---
    if $imported["BattleEngineMelody"]
      growth = []
      for key in @item.element_growth
        growth.push(key[0]) if YEM::ITEM::SHOWN_ELEMENTS.include?(key[0])
      end
      growth.sort!
      for element_id in growth
        return dy if dy + WLH > contents.height
        icon = Icon.element(element_id)
        next if icon == 0
        draw_icon(icon, 0, dy)
        text = sprintf(@hash[:resist], $data_system.elements[element_id])
        self.contents.font.color = system_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
        text = sprintf("%+d%%", -@item.element_growth[element_id])
        self.contents.font.color = normal_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
        dy += WLH
      end
    end
    #---
    if $imported["BattleEngineMelody"]
      growth = []
      for key in @item.state_growth
        growth.push(key[0])
      end
      growth.sort!
      for state_id in growth
        return dy if dy + WLH > contents.height
        state = $data_states[state_id]
        next if state == nil
        icon = state.icon_index
        next if icon == 0
        draw_icon(icon, 0, dy)
        text = sprintf(@hash[:resist], state.name)
        self.contents.font.color = system_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
        text = sprintf("%+d%%", -@item.state_growth[state_id])
        self.contents.font.color = normal_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
        dy += WLH
      end
    end
    #---
    if $imported["EquipmentOverhaul"]
      for stat in [:hp, :mp, :atk, :def, :spi, :res, :dex, :agi]
        return dy if dy + WLH > contents.height
        next if stat == :res and !$imported["RES Stat"]
        next if stat == :dex and !$imported["DEX Stat"]
        next if @item.apt_growth[stat] == 0 or @item.apt_growth[stat] == nil
        text = sprintf(@hash[:bonus], eval("Vocab." + stat.to_s))
        draw_icon(@item.icon_index, 0, dy)
        self.contents.font.color = system_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
        text = sprintf("%+d%%", @item.apt_growth[stat])
        self.contents.font.color = normal_color
        self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
        dy += WLH
      end
    end
    #---
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_equip_stats(dy)
    dx = 0
    array = [:hp, :mp, :atk, :def, :spi, :res, :dex, :agi]
    for stat in @hash[:shown_stats]
      return if dy + WLH > contents.height
      next if stat == :res and !$imported["RES Stat"]
      next if stat == :dex and !$imported["DEX Stat"]
      next if [:hp, :mp].include?(stat) and !$imported["EquipmentOverhaul"]
      next unless array.include?(stat)
      draw_icon(Icon.stat(@clone, stat), dx, dy)
      text = eval("Vocab." + stat.to_s)
      self.contents.font.color = system_color
      self.contents.draw_text(dx+12, dy, contents.width/2-28, WLH, text, 0)
      stat_text = stat.to_s
      stat_text = "max" + stat_text if ["hp", "mp"].include?(stat_text)
      item_value = eval("@item." + stat_text)
      text = sprintf("%+d", item_value)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = item_value == 0 ? 128 : 255
      self.contents.draw_text(dx+12, dy, contents.width/2-28, WLH, text, 2)
      if dx == 0
        dx = contents.width/2
      else
        dx = 0
        dy += WLH
      end
    end
    dy += WLH if dx != 0
    return dy
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_custom_data(dy)
    return dy if @item.custom_data == []
    for array in @item.custom_data
      break if dy + WLH > contents.height
      draw_icon(array[0], 0, dy)
      text = array[1]
      self.contents.font.color = system_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 0)
      text = array[2]
      self.contents.font.color = normal_color
      self.contents.draw_text(24, dy, contents.width-28, WLH, text, 2)
      dy += WLH
    end
    return dy
  end
  
end

#===============================================================================
#===============================================================================

class Scene_Item < Scene_Base

  #--------------------------------------------------------------------------
  # 覆寫方法：start
  #--------------------------------------------------------------------------
  def start
    super
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    @help_window.y = 128
    @data_window = Window_ItemData.new(@help_window)#右下
    @data_window.viewport = @viewport
    @data_window.x -= 3
    @windows = []
    
    @target_window = Window_RipMenuStatus.new(0, 0)
    @target_window.visible = false
    @target_window.active = false
    @target_windowbg = Sprite.new
    @target_windowbg.bitmap = Cache.system("Menu_TargetWindow")
    @target_windowbg.visible = false
    
    @status_window = Window_ItemStatus.new#右上空白
    @status_window.viewport = @viewport
    @com_count = 11
    @aura_count = 0
    create_command_window
    create_menu_background
    update_windows
  end
  
  def create_menu_background
    @menuback_sprite.dispose if @menuback_sprite != nil
    @menuback_sprite2.dispose if @menuback_sprite2 != nil
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Cache.system("MenuBack_item")
    @menuback_sprite.z -= 1
    @status_window.opacity = 0
    @help_window.opacity = 0
    @data_window.opacity = 0
    @command_window.opacity = 0 if @command_window != nil
    @all_item_window.opacity = 0 if @all_item_window != nil
    @misc_window.opacity = 0 if @misc_window != nil
    @key_item_window.opacity = 0 if @key_item_window != nil
    @usable_window.opacity = 0 if @usable_window != nil

    #####################################################################
    @sprites = []
    images_name =
    ["Item01","Item02","Item03"]
    for i in 0...images_name.size
     @sprites[i] = Sprite.new
     @sprites[i].bitmap = Cache.menu(images_name[i])
     @sprites[i].x = (i * 6) + 26 if i <= 1
     @sprites[i].x = (i * 6) + 18 if i > 1
     @sprites[i].y = (i * 26) + 19
     @sprites[i].opacity = 255
     @sprites[i].z = 9999
     @sprites[i].tone = Tone.new(0,0,0,255)
     @sprites[i].zoom_x = @sprites[i].zoom_y = 1.0############
    end
    ####################################################################
    
    ####################################################################
    @mask = Sprite.new
    @mask.bitmap = Cache.system("MenuBack_mask")
    @mask.z = 99
    @light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = true
    @light.x = 407
    @light.y = -20
    @light.zoom_x = 200 / 100.0
    @light.zoom_y = 200 / 100.0
    @light.opacity = 100
    @light.tone = Tone.new(255,-100,-255, 0)
    @light.blend_type = 1
		@light.z = 1000
    
    @light2 = Sprite.new
		@light2.bitmap = Cache.picture("le.png")
		@light2.visible = true
    @light2.x = 8
    @light2.y = 13
    @light2.zoom_x = 150 / 100.0
    @light2.zoom_y = 55 / 100.0
    @light2.opacity = 70
    @light2.tone = Tone.new(200,200,100, 100)
    @light2.blend_type = 1
		@light2.z = 1000
    
    fireflies(5)
    ####################################################################
    update_menu_background
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    commands = []; @data = []
    for command in YEM::ITEM::COMMANDS
      case command
      when :usable
        @usable_window = Window_ItemList.new(@help_window)
        @windows.push(@usable_window)
      when :battle
        @battle_window = Window_BattleItemList.new(@help_window)
        @windows.push(@battle_window)
      when :weapons
        @weapon_window = Window_WeaponItemList.new(@help_window)
        @windows.push(@weapon_window)
      when :armours
        @armour_window = Window_ArmourItemList.new(@help_window)
        @windows.push(@armour_window)
      when :misc
        @misc_window = Window_MiscItemList.new(@help_window)
        @windows.push(@misc_window)
      when :key_items
        @key_item_window = Window_KeyItemList.new(@help_window)
        @windows.push(@key_item_window)
      when :all_items
        @all_item_window = Window_AllItemList.new(@help_window)
        @windows.push(@all_item_window)
      else; next
      end
      @data.push(command)
      if YEM::ITEM::VOCAB[command] != nil
        commands.push(YEM::ITEM::VOCAB[command])
      end
    end
    for window in @windows
      next if window == nil?
      window.active = false
      window.viewport = @viewport
      window.help_window = @help_window if window.is_a?(Window_Selectable)
    end
    @command_window = Window_Command_Centered.new(160, commands)
    @command_window.viewport = @viewport
    @command_window.windowskin = Cache.windows("windowX")
    @command_window.height = 128
    @command_window.active = true
    @help_window.contents.clear
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_windows
  #--------------------------------------------------------------------------
  def update_windows
    @last_command_index = @command_window.index
    @help_window.y = Graphics.height*8
    @data_window.y = Graphics.height*8
    for window in @windows
      next if window == nil
      window.y = Graphics.height*8
    end
    #---
    case @data[@command_window.index]
    when :usable
      show_item_windows(@usable_window)
    when :battle
      show_item_windows(@battle_window)
    when :weapons
      show_item_windows(@weapon_window)
    when :armours
      show_item_windows(@armour_window)
    when :misc
      show_item_windows(@misc_window)
    when :key_items
      show_item_windows(@key_item_window)
    when :all_items
      show_item_windows(@all_item_window)
    end
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @command_window.dispose
    @status_window.dispose
    for window in @windows
      next if window == nil
      next if window.disposed?
      window.dispose
    end
    for i in 0..2
      @sprites[i].dispose
    end
    @light.dispose
    @light2.dispose
    @mask.dispose
    fireflies(0)
    @viewport.dispose
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
      @target_windowbg.visible = false
    if @command_window.active
      update_command_selection
    elsif @target_window.active
      @target_windowbg.visible = true
      update_target_selection
    elsif @item_window != nil and @item_window.active
      update_item_selection
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：update_command_selection
  #--------------------------------------------------------------------------
  def update_command_selection
    @help_window.set_text("查看所有得到的物品") if @command_window.index == 0
    @help_window.set_text("可以賣出換錢的物品") if @command_window.index == 1
    @help_window.set_text("重要物品") if @command_window.index == 2
    #@item_window.visible = false if @command_window.active###是否顯示物品欄
    ################################
    @mask.visible = true if @command_window.active###
    
    @light.opacity = rand(20) + 90
    @light.x = 407 + rand(3) - 3
    @light.y = -20 + rand(3) - 3
    
    
    @light2.opacity = rand(40) + 70
     @light2.x = (@command_window.index * 6) + 8 if @command_window.index <= 1
     @light2.x = (@command_window.index * 6) + 0 if @command_window.index > 1
    @light2.y = (@command_window.index * 26) + 13
    ################################
    ################################
    for i in 0..2
      @sprites[i].tone = Tone.new(0,0,0,255)
      @sprites[i].y = (i * 26) + 19
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::UP)
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::DOWN)
      @sprites[i].y = (i * 26) + 19 if Input.trigger?(Input::UP)
      @sprites[i].y = (i * 26) + 19 if Input.trigger?(Input::DOWN)
    end
    @sprites[@command_window.index].tone = Tone.new(0,0,0)
    @com_count = 0 if Input.trigger?(Input::UP)
    @com_count = 0 if Input.trigger?(Input::DOWN)
    @aura_count = 0 if Input.trigger?(Input::UP)
    @aura_count = 0 if Input.trigger?(Input::DOWN)
    @sprites[@command_window.index].color.set(255, 255, 255, 0) if Input.trigger?(Input::UP)
      @sprites[@command_window.index].color.set(255, 255, 255, 0) if Input.trigger?(Input::DOWN)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19 if Input.trigger?(Input::UP)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19 if Input.trigger?(Input::DOWN)
    if @com_count <= 10
      @sprites[@command_window.index].color.set(255, 255, 255, 0) if @com_count == 9
      @sprites[@command_window.index].color.set(200, 255, 255, 160) if @com_count == 4
      @sprites[@command_window.index].y += 3 if @com_count == 9
      @sprites[@command_window.index].y -= 3 if @com_count == 0
      @com_count +=1
    end
    #if @aura_count <= 90
    #  if @aura_count > 90 / 2
    #  elsif @aura_count == 80 / 2
    #  elsif @aura_count > 0
    #  end
    #end
    ####################################
    @command_window.update
    update_windows if @last_command_index != @command_window.index
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @sprites[@command_window.index].color.set(200, 255, 255, 160)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19
      @command_window.active = false
      case @data[@command_window.index]
      when :usable, :battle, :weapons, :armours, :misc, :key_items, :all_items
        @item_window.visible = true###是否顯示物品欄
        @mask.visible = false
        @item_window.active = true
        @data_window.visible = true
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：show_usable_windows
  #--------------------------------------------------------------------------
  def show_item_windows(window)
    @help_window.y = 128 + 11
    @data_window.set_item_window(window)
    @status_window.set_item_window(window)
    @data_window.y = @help_window.y-11 + @help_window.height
    window.y = @data_window.y
    window.update_help if !@command_window.active
    @item_window = window
  end
  
  #--------------------------------------------------------------------------
  # 覆寫方法：update_item_selection
  #--------------------------------------------------------------------------
  def update_item_selection
    @status_window.update
    @item_window.update
    @data_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @item_window.active = false
      @command_window.active = true
      @sprites[@command_window.index].color.set(255, 255, 255, 0)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19
      return unless @item_used
      for window in @windows
        next unless window.is_a?(Window_ItemList)
        window.used_item_refresh(@item_used)
      end
      @item_used = []
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if enable_item?
        Sound.play_decision
        determine_item
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：enable_item?
  #--------------------------------------------------------------------------
  def enable_item?
    return false unless @item.is_a?(RPG::Item)
    return false unless @item.menu_ok?
    return false unless @item_window.enable?(@item)
    return true
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： update_target_selection
  #--------------------------------------------------------------------------
  alias update_target_selection_io update_target_selection unless $@
  def update_target_selection
    @target_window.update
    @status_window.update
    update_target_selection_io
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： show_target_window
  #--------------------------------------------------------------------------
  alias show_target_window_io show_target_window unless $@
  def show_target_window(right)
    show_target_window_io(true)
  end
  
  #--------------------------------------------------------------------------
  # alias 方法： use_item_nontarget
  #--------------------------------------------------------------------------
  alias use_item_nontarget_io use_item_nontarget unless $@
  def use_item_nontarget
    @item_used = [] if @item_used == nil
    @item_used.push(@item) unless @item_used.include?(@item)
    use_item_nontarget_io
    @status_window.refresh
  end
  
end

#===============================================================================
# 
# 
#===============================================================================