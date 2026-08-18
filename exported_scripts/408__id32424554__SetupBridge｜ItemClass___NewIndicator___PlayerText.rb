#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：ItemClass_NewIndicator_AutoSetup
# 【用途】ItemClass／New Indicator／Player Text 等 Setup Bridge 集合；在 MasterSetup 注入前後銜接既有 UI／資料模組。
# 【主要機制】處理物品資料、交易、製作、庫存或 UI；事件入口與資料庫設定需要一起確認。
# 【主要影響】Game_Party、Game_Actor、Game_Interpreter、BaseItem、Window_Base、Window_ItemList、Window_Equip_Item
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：OFFSET_X、OFFSET_Y、CATEGORIES、SUMMON_CLASS、ACCESSORY_CLASS、NAMES、FS_DATABASE_POP_TEXT_REGEX、SKILL_NAMES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】本頁部分 load-time 對 AutoSetup DATA 的修改會在 FS_MasterSetup 18 Apply 後重新套用；不可把它當第二份 Data Authority。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】SETUP BRIDGE / UI DATA SUPPORT
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

# ■ FS_ItemClass_NewIndicator_AutoSetup v1.3

#------------------------------------------------------------------------------

# 對應專案：Forest Symphony / RPG Maker VX (RGSS2)

#

# 【安裝位置】

#   放在以下兩支原腳本「下方」，並放在 Main 之前：

#   1. Galv's New Item Indication（物品顯示NEW）

#   2. Classi Oggetto（物品打星星）

#

# 【不必刪除原腳本】

#   本補丁會接管兩支腳本在目前專案中的問題方法，保留既有資料與圖檔。

#

# 【修正內容】

#   1. 舊存檔沒有 @nitems 時自動補建，避免物品視窗報錯。

#   2. 修正 METHOD 1 的 clear_new：原版清空陣列反而會把全部物品變成 NEW。

#   3. 游標左右移動、首次開窗、各種自訂物品／裝備視窗都能正確解除 NEW。

#   4. METHOD 2 只在「實際獲得物品」時標 NEW；換裝／卸裝不再誤判。

#   5. 保留 disabled 半透明顯示，不再被原 Galv 強制 enabled=true。

#   6. Classi Oggetto 評級值與圖示 ID 做安全限制，舊資料／錯誤 Note 不報錯。

#   7. Auto Setup 自動寫入 <classe:x>，不必逐筆到資料庫 Note 設星級。

#   8. 修正六主角五階武器名稱：爪／魔法弓／長槍／笛／巨斧／拳甲。

#   9. 技能／武器 Pop Text 均支援資料庫 Note 優先通道。

#  10. 六主角技能名稱與台詞配合爪、魔法弓、長槍、笛、巨斧、拳甲。

#  11. 自動補齊玩家用物品、武器、防具、技能說明。

#  12. Help Window 保持單行高度，過長時自動縮字至 16px。

#

# 【Auto Setup 星級規則】

#   Weapon 100～129：每位角色五階武器，自動 1～5 星。

#   Armor 296～315：四組五階身體裝備，自動 1～5 星。

#   Armor 316～333：三階飾品，自動 2／3／4 星。

#   Armor 286～295：五名映紋＋五台機器核心，固定 4 星。

#   Item 200～265、600～665：依對應召喚物稀有度。

#   Armor 220～285：專屬裝備沿用對應召喚物稀有度。

#

# 【五個超模召喚物】

#   超夢、夢幻、雷公、炎帝、水君固定 5 星。

#

# 【手動覆蓋】

#   任何物品／武器／防具仍可在 Note 寫：

#     <classe:4>

#   0 = 不顯示；1～5 = 星級。超過範圍會自動限制。

#==============================================================================



$imported = {} if $imported == nil

$imported["FS ItemClass NewIndicator AutoSetup"] = "1.3"



#==============================================================================

# ■ Galv 新物品標記：共用核心

#==============================================================================

module FS_GALV_NEW_ITEM

  # NEW 圖相對於物品圖示的位置。

  # 原圖為 24x24；往右移可避免與 Classi 星級圖完全疊在一起。

  OFFSET_X = 12

  OFFSET_Y = -6



  CATEGORIES = [:item, :weapon, :armor]



  def self.category(item)

    return :item   if item.is_a?(RPG::Item)

    return :weapon if item.is_a?(RPG::Weapon)

    return :armor  if item.is_a?(RPG::Armor)

    return :none

  end



  def self.valid_category?(category)

    return CATEGORIES.include?(category)

  end



  def self.party_ready?

    return false if $game_party == nil

    return $game_party.respond_to?(:nitems)

  end



  def self.new_item?(item)

    return false if item == nil

    return false unless party_ready?

    category = self.category(item)

    return false unless valid_category?(category)

    flags = $game_party.nitems[category]

    if Galv_Nitem::METHOD == 1

      return !flags[item.id]

    else

      return flags[item.id] == true

    end

  end



  def self.mark_seen(item)

    return false if item == nil

    return false unless party_ready?

    category = self.category(item)

    return false unless valid_category?(category)

    was_new = new_item?(item)

    if Galv_Nitem::METHOD == 1

      $game_party.nitems[category][item.id] = true

    else

      $game_party.nitems[category][item.id] = false

    end

    return was_new

  end



  def self.owned_items

    result = []

    return result if $game_party == nil

    begin

      result.concat($game_party.items.compact)

    rescue

    end

    begin

      $game_party.members.each do |actor|

        next if actor == nil || !actor.respond_to?(:equips)

        result.concat(actor.equips.compact)

      end

    rescue

    end

    return result.uniq

  end



  def self.clear(type)

    return unless party_ready?

    types = type == :all ? CATEGORIES : [type]

    types.each do |category|

      next unless valid_category?(category)

      if Galv_Nitem::METHOD == 1

        # METHOD 1 中 true 代表「看過」。原版清成 [] 會讓全部重新變 NEW。

        owned_items.each do |item|

          next unless self.category(item) == category

          $game_party.nitems[category][item.id] = true

        end

      else

        $game_party.nitems[category] = []

      end

    end

  end

end



#==============================================================================

# ■ Game_Party

#==============================================================================

class Game_Party < Game_Unit

  attr_writer :nitems



  # 舊存檔相容：沒有 @nitems 或內容被其他腳本破壞時自動補建。

  def nitems

    @nitems = {} unless @nitems.is_a?(Hash)

    FS_GALV_NEW_ITEM::CATEGORIES.each do |category|

      @nitems[category] = [] unless @nitems[category].is_a?(Array)

    end

    return @nitems

  end



  def fs_nitem_suppress_begin

    @fs_nitem_suppress_depth = 0 if @fs_nitem_suppress_depth == nil

    @fs_nitem_suppress_depth += 1

  end



  def fs_nitem_suppress_end

    @fs_nitem_suppress_depth = 0 if @fs_nitem_suppress_depth == nil

    @fs_nitem_suppress_depth -= 1

    @fs_nitem_suppress_depth = 0 if @fs_nitem_suppress_depth < 0

  end



  def fs_nitem_suppressed?

    @fs_nitem_suppress_depth = 0 if @fs_nitem_suppress_depth == nil

    return @fs_nitem_suppress_depth > 0

  end



  # 直接呼叫 Galv 安裝前的 gain_item，避開原版 METHOD 2 的誤判邏輯。

  if method_defined?(:galv_nitem_gp_gain_item)

    def gain_item(item, amount, include_equip = false)

      before = item == nil ? 0 : item_number(item)

      galv_nitem_gp_gain_item(item, amount, include_equip)

      return if item == nil

      return unless Galv_Nitem::METHOD == 2

      return if fs_nitem_suppressed?

      category = FS_GALV_NEW_ITEM.category(item)

      return unless FS_GALV_NEW_ITEM.valid_category?(category)

      after = item_number(item)

      nitems[category][item.id] = true if after > before

    end

  end

end



#==============================================================================

# ■ Game_Actor

#------------------------------------------------------------------------------

# METHOD 2：換裝會先把舊裝備放回背包，不能把這個流程視為「新取得」。

#==============================================================================

class Game_Actor < Game_Battler

  unless method_defined?(:fs_nitem_change_equip_without_suppress)

    alias fs_nitem_change_equip_without_suppress change_equip

  end



  def change_equip(equip_type, item, test = false)

    if $game_party != nil && $game_party.respond_to?(:fs_nitem_suppress_begin)

      $game_party.fs_nitem_suppress_begin

    end

    begin

      return fs_nitem_change_equip_without_suppress(equip_type, item, test)

    ensure

      if $game_party != nil && $game_party.respond_to?(:fs_nitem_suppress_end)

        $game_party.fs_nitem_suppress_end

      end

    end

  end

end



#==============================================================================

# ■ Game_Interpreter

#==============================================================================

class Game_Interpreter

  def clear_new(type)

    FS_GALV_NEW_ITEM.clear(type)

  end

end



#==============================================================================

# ■ Classi Oggetto：安全讀取與快取

#==============================================================================

if defined?(H87_ItemClass)

  module H87_ItemClass

    # 由本補丁統一判斷合法星級。

    def self.max_class

      keys = Icone.keys

      return 0 if keys == nil || keys.empty?

      return keys.max.to_i

    end



    def self.valid_icon(value)

      value = value.to_i

      return nil if value <= 0

      value = [value, max_class].min

      return Icone[value]

    end

  end

end



module RPG

  class BaseItem

    # getter 改為永遠回傳安全整數；動態資料也能在第一次顯示時補快取。

    def classe_oggetto

      carica_cache_personale_class unless @cache_caricata2

      value = @classe_oggetto.to_i

      value = 0 if value < 0

      if defined?(H87_ItemClass)

        value = [value, H87_ItemClass.max_class].min

      end

      return value

    end



    # 手動／AutoSetup Note 優先；沒有標籤時才使用原始自動公式。

    def carica_cache_personale_class

      return if @cache_caricata2

      @cache_caricata2 = true

      @classe_oggetto = 0



      text = self.note == nil ? "" : self.note.to_s

      if text =~ /<\s*classe\s*:\s*(\d+)\s*>/i

        @classe_oggetto = $1.to_i

      else

        case self

        when RPG::Skill

          calcola_valore_skill if H87_ItemClass::Prop_Skill > 0

        when RPG::Item

          calcola_valore_item if H87_ItemClass::Prop_Item > 0

        when RPG::Weapon

          calcola_valore_weapon if H87_ItemClass::Prop_Weap > 0

        when RPG::Armor

          calcola_valore_armor if H87_ItemClass::Prop_Armr > 0

        end

      end



      @classe_oggetto = self.classe_oggetto

    end



    # 原版把 plus_state_set（State ID 陣列）拿去比對 $data_states[1] 物件，

    # 復活效果永遠判定不到。這裡在原計算後補回最低一階價值。

    if method_defined?(:calcola_valore_item) &&

       !method_defined?(:fs_itemclass_calc_item_without_revive_fix)

      alias fs_itemclass_calc_item_without_revive_fix calcola_valore_item

      def calcola_valore_item

        fs_itemclass_calc_item_without_revive_fix

        if self.plus_state_set.include?(1)

          @classe_oggetto = [@classe_oggetto.to_i + 1,

            H87_ItemClass.max_class].min

        end

      end

    end



    if method_defined?(:calcola_valore_skill) &&

       !method_defined?(:fs_itemclass_calc_skill_without_revive_fix)

      alias fs_itemclass_calc_skill_without_revive_fix calcola_valore_skill

      def calcola_valore_skill

        fs_itemclass_calc_skill_without_revive_fix

        if self.plus_state_set.include?(1)

          @classe_oggetto = [@classe_oggetto.to_i + 1,

            H87_ItemClass.max_class].min

        end

      end

    end

  end

end



#==============================================================================

# ■ Window_Base：統一繪製

#------------------------------------------------------------------------------

# 原 Galv 會把 enabled 強制改成 true；原 Classi 與 NEW 又會互相搶圖示座標。

# 這裡統一由一個方法處理：物品圖示 → 星級圖示 → NEW 圖。

#==============================================================================

class Window_Base < Window

  def fs_draw_item_class(item, x, y, enabled = true)

    return if item == nil || !item.respond_to?(:classe_oggetto)

    return unless defined?(H87_ItemClass)

    icon = H87_ItemClass.valid_icon(item.classe_oggetto)

    return if icon == nil

    draw_icon(icon, x, y, enabled)

  end



  def fs_draw_new_item(item, x, y)

    return unless FS_GALV_NEW_ITEM.new_item?(item)

    bitmap = Cache.system(Galv_Nitem::IMAGE)

    rect = Rect.new(0, 0, 24, 24)

    self.contents.blt(

      x + FS_GALV_NEW_ITEM::OFFSET_X,

      y + FS_GALV_NEW_ITEM::OFFSET_Y,

      bitmap, rect, 255)

  end



  def draw_item_name(item, x, y, enabled = true)

    return if item == nil

    draw_icon(item.icon_index, x, y, enabled)

    self.contents.font.color = normal_color

    self.contents.font.color.alpha = enabled ? 255 : 128

    self.contents.draw_text(x + 24, y, 172, WLH, item.name)

    fs_draw_item_class(item, x, y, enabled)

    fs_draw_new_item(item, x, y)

  end



  def draw_item_name10(item, x, y, enabled = true)

    draw_item_name(item, x, y, enabled)

  end

end



#==============================================================================

# ■ YEM Item Overhaul：物品清單

#==============================================================================

if defined?(Window_ItemList)

  class Window_ItemList < Window_Selectable

    # Classi 原相容層的 nuovo_draw_item 指向 YEM 原始 draw_obj_name。

    if method_defined?(:nuovo_draw_item)

      def draw_obj_name(obj, rect, enabled)

        nuovo_draw_item(obj, rect, enabled)

        fs_draw_item_class(obj, rect.x, rect.y, enabled)

      end

    end



    # 跳過 Galv 原版 draw_item 的重複 NEW 繪製，只畫一次。

    if method_defined?(:galv_nitem_wi_draw_item)

      def draw_item(index)

        galv_nitem_wi_draw_item(index)

        item = @data[index]

        return if item == nil

        rect = item_rect(index)

        fs_draw_new_item(item, rect.x, rect.y)

      end

    end

  end

end



#==============================================================================

# ■ YEM Equipment Overhaul：裝備候選清單

#==============================================================================

if defined?(Window_Equip_Item)

  class Window_Equip_Item < Window_Selectable

    # 原 Galv 的 draw_item 會在 Window_Base 已畫 NEW 後再畫一次，故直接繞過。

    if method_defined?(:galv_nitem_wi_draw_item_name)

      def draw_item(index)

        galv_nitem_wi_draw_item_name(index)

      end

    end

  end

end



#==============================================================================

# ■ 游標停留即解除 NEW

#==============================================================================

module FS_GALV_NEW_ITEM_WINDOW

  def fs_nitem_current_item

    return nil unless respond_to?(:item)

    begin

      return item

    rescue

      return nil

    end

  end



  def fs_nitem_touch_current(before_new = nil)

    current = fs_nitem_current_item

    key = current == nil ? nil : [FS_GALV_NEW_ITEM.category(current), current.id]

    was_new = before_new == nil ? FS_GALV_NEW_ITEM.new_item?(current) : before_new

    FS_GALV_NEW_ITEM.mark_seen(current)

    changed = (@fs_nitem_last_key != key)

    @fs_nitem_last_key = key

    return if current == nil

    # 一般物品清單有 draw_item，可只重畫目前那一列。
    if respond_to?(:draw_item)

      if was_new || changed

        begin

          draw_item(self.index)

        rescue

        end

      end

      return

    end

    # YEM Window_Equip 只有整體 draw_equipment_items，沒有 draw_item。
    # 自動換裝後選到已裝備的新裝備時，資料雖已標為看過，
    # 畫面卻不會自行清除 NEW。只在原本確實為 NEW 時 refresh 一次，
    # 不在游標移動時反覆刷新整個裝備視窗。
    if was_new && respond_to?(:refresh)

      begin

        last_index = self.index

        refresh

        self.index = last_index if last_index != nil

      rescue

      end

    end

  end

end



fs_nitem_window_classes = []

fs_nitem_window_classes.push(Window_ItemList) if defined?(Window_ItemList)

fs_nitem_window_classes.push(Window_Item) if defined?(Window_Item)

fs_nitem_window_classes.push(Window_Equip_Item) if defined?(Window_Equip_Item)

fs_nitem_window_classes.push(Window_Equip) if defined?(Window_Equip)

fs_nitem_window_classes.push(Window_ShopBuy) if defined?(Window_ShopBuy)

fs_nitem_window_classes.push(Window_ShopSell) if defined?(Window_ShopSell)



fs_nitem_window_classes.uniq.each do |klass|

  klass.send(:include, FS_GALV_NEW_ITEM_WINDOW)



  # 讓原 Galv update_help 即使呼叫 add_to_known_items，也走安全版本。

  klass.class_eval do

    def add_to_known_items(item)

      FS_GALV_NEW_ITEM.mark_seen(item)

    end

  end



  next unless klass.method_defined?(:update_help)

  alias_name = ("fs_nitem_update_help_" + klass.to_s.gsub(/[^A-Za-z0-9]/, "_")).to_sym

  next if klass.method_defined?(alias_name)



  klass.class_eval do

    alias_method alias_name, :update_help

    define_method(:update_help) do |*args|

      current = fs_nitem_current_item

      before_new = FS_GALV_NEW_ITEM.new_item?(current)

      send(alias_name, *args)

      fs_nitem_touch_current(before_new)

    end

  end

end



#==============================================================================

# ■ METHOD 2：離開物品畫面後清除尚未逐一查看的 NEW

#==============================================================================

if defined?(Scene_Item)

  class Scene_Item < Scene_Base

    unless method_defined?(:fs_nitem_terminate_without_clear)

      alias fs_nitem_terminate_without_clear terminate

    end



    def terminate

      fs_nitem_terminate_without_clear

      FS_GALV_NEW_ITEM.clear(:all) if Galv_Nitem::METHOD == 2

    end

  end

end



#==============================================================================

# ■ Auto Setup 星級設定

#==============================================================================

module FS_ITEM_CLASS_AUTOSET

  # 依目前召喚物設計：

  # 1 = 常見早期型、2 = 一般型、3 = 強力／稀有型、4 = Boss／準神、5 = 超模誘因。

  SUMMON_CLASS = {

     0=>2,  1=>2,  2=>2,  3=>1,  4=>1,  5=>1,  6=>1,  7=>1,

     8=>1,  9=>2, 10=>1, 11=>2, 12=>2, 13=>3, 14=>2, 15=>1,

    16=>1, 17=>2, 18=>2, 19=>3, 20=>2, 21=>3, 22=>3, 23=>3,

    24=>3, 25=>2, 26=>3, 27=>1, 28=>2, 29=>3, 30=>2, 31=>2,

    32=>2, 33=>2, 34=>2, 35=>5, 36=>5, 37=>1, 38=>1, 39=>3,

    40=>3, 41=>3, 42=>5, 43=>5, 44=>5, 45=>4, 46=>2, 47=>2,

    48=>2, 49=>2, 50=>3, 51=>2, 52=>3, 53=>3, 54=>3, 55=>4,

    56=>4, 57=>3, 58=>3, 59=>2, 60=>2, 61=>4, 62=>3, 63=>2,

    64=>3, 65=>3

  }



  ACCESSORY_CLASS = [2, 3, 4]



  def self.summon_class(index)

    value = SUMMON_CLASS[index.to_i]

    return value == nil ? 2 : value

  end



  def self.item_class(id)

    return summon_class(id - 200) if id >= 200 && id <= 265

    return summon_class(id - 600) if id >= 600 && id <= 665

    return nil

  end



  def self.weapon_class(id)

    return nil unless id >= 100 && id <= 129

    return ((id - 100) % 5) + 1

  end



  def self.armor_class(id)

    return summon_class(id - 220) if id >= 220 && id <= 285

    return summon_class(id - 600) if id >= 600 && id <= 665

    return 4 if id >= 286 && id <= 295

    return ((id - 296) % 5) + 1 if id >= 296 && id <= 315

    if id >= 316 && id <= 333

      return ACCESSORY_CLASS[(id - 316) % 3]

    end

    return nil

  end



  def self.apply_one(group, category, id, value)

    return if value == nil || value.to_i <= 0

    return if group == nil || group[id] == nil

    obj = group[id]

    FS_DB_AUTOSET.merge_note(

      obj,

      "item_class_#{category}",

      id,

      "<classe:#{value.to_i}>")

    obj.instance_variable_set("@cache_caricata2", false)

    obj.instance_variable_set("@classe_oggetto", 0)

  end



  def self.apply

    if defined?(FS_DB_AUTOSET_ITEMS) && FS_DB_AUTOSET_ITEMS.const_defined?(:DATA)

      FS_DB_AUTOSET_ITEMS::DATA.keys.each do |id|

        apply_one($data_items, "item", id, item_class(id))

      end

    end



    if defined?(FS_DB_AUTOSET_WEAPONS) && FS_DB_AUTOSET_WEAPONS.const_defined?(:DATA)

      FS_DB_AUTOSET_WEAPONS::DATA.keys.each do |id|

        apply_one($data_weapons, "weapon", id, weapon_class(id))

      end

    end



    if defined?(FS_DB_AUTOSET_ARMORS) && FS_DB_AUTOSET_ARMORS.const_defined?(:DATA)

      FS_DB_AUTOSET_ARMORS::DATA.keys.each do |id|

        apply_one($data_armors, "armor", id, armor_class(id))

      end

    end



    # Armor 600～665 是資料庫保留的魂刻，不在 05_Armors::DATA 內，

    # 但仍由本擴充補上與對應召喚物一致的星級。

    (600..665).each do |id|

      apply_one($data_armors, "armor", id, armor_class(id))

    end

  end

end



# UserExtensions 是 Auto Setup 最後一個分類，最適合追加 <classe:x>。

if defined?(FS_DB_AUTOSET_USER_EXTENSIONS)

  module FS_DB_AUTOSET_USER_EXTENSIONS

    class << self

      unless method_defined?(:fs_item_class_apply_without_item_class)

        alias fs_item_class_apply_without_item_class apply

      end



      def apply

        fs_item_class_apply_without_item_class

        FS_ITEM_CLASS_AUTOSET.apply

      end

    end

  end

end



#==============================================================================

# ■ Auto Setup：六主角武器名稱校正（v1.1 相容前置；v1.2 最終值在後段覆蓋）

#------------------------------------------------------------------------------

# 只修改 Weapon 100～124 的 :name。

# ATK／DEF／SPI／AGI／Hit／Normal Power／裝備技能與其他 Note 全部保留。

# Weapon 125～129（泰勒拳甲）維持原設定。

#

# 對應：

#   100～104 喬伊：爪

#   105～109 米亞：魔法弓（射擊動作，不使用實體箭矢）

#   110～114 艾卓：長槍

#   115～119 維娜：笛

#   120～124 艾薇：巨斧

#   125～129 泰勒：拳甲（不修改）

#==============================================================================

module FS_AUTOSET_WEAPON_NAME_FIX

  NAMES = {

    # 喬伊／爪

    100 => "林芽爪刃",

    101 => "鳴脈爪刃",

    102 => "殘響連爪",

    103 => "龍森雙爪",

    104 => "森律龍爪",



    # 米亞／魔法弓

    105 => "木靈魔弓",

    106 => "祈光魔弓",

    107 => "溢光星弓",

    108 => "星輝長弓",

    109 => "大地聖弓",



    # 艾卓／長槍

    110 => "電鋼長槍",

    111 => "截流長槍",

    112 => "雷鎖長槍",

    113 => "零時鋒槍",

    114 => "終端超頻槍",



    # 維娜／笛

    115 => "毒霧短笛",

    116 => "培養長笛",

    117 => "腐蝕導笛",

    118 => "病灶魔笛",

    119 => "萬毒花笛",



    # 艾薇／巨斧

    120 => "藤盾巨斧",

    121 => "棘牆戰斧",

    122 => "庇護重斧",

    123 => "痛爐壁斧",

    124 => "怒海城斧"

  }



  def self.apply_to_autoset_data

    return unless defined?(FS_DB_AUTOSET_WEAPONS)

    return unless FS_DB_AUTOSET_WEAPONS.const_defined?(:DATA)

    data = FS_DB_AUTOSET_WEAPONS::DATA

    NAMES.each do |id, name|

      next unless data[id].is_a?(Hash)

      data[id][:name] = name

    end

  end

end



# Auto Setup 真正執行前，直接改寫 DATA 名稱。

FS_AUTOSET_WEAPON_NAME_FIX.apply_to_autoset_data



#==============================================================================

# ■ Auto Setup：技能 Pop Text 雙通道

#------------------------------------------------------------------------------

# 最終規則：

#   1. 資料庫 Skill Note 只要存在至少一條 <pop_text:...>，

#      就採用資料庫中的全部 pop_text，並移除腳本 DATA 內的 pop_text。

#   2. 資料庫 Skill Note 沒有 pop_text，才沿用 AutoSetup 腳本 DATA 的設定。

#   3. 除 pop_text 以外，Auto Setup 仍維持「腳本權威 Note」；不會把資料庫

#      內其他過期 JP／Scope／Target／State／AI 標籤偷偷帶回來。

#

# 因 BattlePopText_Note 最終讀取的是 $data_skills[id].note，故不必再修改

# BattlePopText_Note 本體，也不會重複顯示。

#==============================================================================

if defined?(FS_DB_AUTOSET_SKILLS)

  module FS_DB_AUTOSET_SKILLS

    FS_DATABASE_POP_TEXT_REGEX = /<pop_text\s*:\s*([^>\r\n]+)\s*>/i unless const_defined?(:FS_DATABASE_POP_TEXT_REGEX)



    def self.fs_database_pop_text_lines(id)

      return [] if $data_skills == nil

      skill = $data_skills[id] rescue nil

      return [] if skill == nil || !skill.respond_to?(:note)

      result = []

      skill.note.to_s.scan(FS_DATABASE_POP_TEXT_REGEX) do |data|

        line = data[0].to_s.strip

        next if line.empty?

        tag = "<pop_text:#{line}>"

        result.push(tag) unless result.include?(tag)

      end

      return result

    end



    def self.fs_remove_script_pop_text(note)

      lines = note.to_s.gsub("\r", "").split("\n")

      lines = [] unless lines.is_a?(Array)

      lines.delete_if do |line|

        line.to_s.strip =~ /^<pop_text\s*:[^>\r\n]+>$/i

      end

      return lines.join("\n")

    end



    class << self

      unless method_defined?(:fs_pop_channel_authoritative_note_without_database_override)

        alias fs_pop_channel_authoritative_note_without_database_override authoritative_note_for

      end



      def authoritative_note_for(id, data)

        scripted = fs_pop_channel_authoritative_note_without_database_override(id, data)

        database_lines = fs_database_pop_text_lines(id)

        return scripted if database_lines.empty?



        base = fs_remove_script_pop_text(scripted)

        parts = []

        parts.push(base) unless base.to_s.strip.empty?

        parts.concat(database_lines)

        return parts.join("\n")

      end

    end

  end

end







#==============================================================================

# ■ v1.2：資料庫文字一致化、武器 Pop Text、Help Window 自適應

#==============================================================================

module FS_AUTOSET_PLAYER_TEXT_V12

  SKILL_NAMES = {

    100 => "森芽裂爪",

    101 => "共鳴爪印",

    102 => "共鳴感知",

    103 => "藤脈牽引",

    104 => "鳴刻指令",

    105 => "龍森爪舞",

    106 => "和聲領袖",

    107 => "共鳴轉奏",

    108 => "三聲連鎖",

    109 => "森之交響",

    110 => "療癒弦光",

    111 => "溢光弦",

    112 => "溢光回路",

    113 => "護幕弦音",

    114 => "群星祈弦",

    115 => "魔力弦彈",

    116 => "大地祝福",

    117 => "星輝放弦",

    118 => "生命回響",

    119 => "大地和弦",

    120 => "電鋒突刺",

    121 => "截流槍",

    122 => "靜電回收",

    123 => "雷鎖",

    124 => "超載迴路",

    125 => "時間斷層",

    126 => "超頻神經",

    127 => "鏈式放電",

    128 => "零時封鎖",

    129 => "終端超頻",

    130 => "毒音刺",

    131 => "毒音培養",

    132 => "毒理學",

    133 => "霧笛擴散",

    134 => "寄生轉調",

    135 => "腐蝕變奏",

    136 => "病灶連鎖",

    137 => "百病和鳴",

    138 => "毒音處刑",

    139 => "萬毒交響",

    140 => "斧背震撞",

    141 => "荊棘護陣",

    142 => "怒意不熄",

    143 => "怒斧",

    144 => "根網挑釁",

    145 => "痛苦熔爐",

    146 => "替身承擔",

    147 => "復仇斷斧",

    148 => "城牆斷斧",

    149 => "怒海歸斧",

    150 => "震拳",

    151 => "破甲連擊",

    152 => "鬥志打磨",

    153 => "乘隙追打",

    154 => "破陣震波",

    155 => "破勢超載",

    156 => "破城者",

    157 => "崩防追獵",

    158 => "斷城終結",

    159 => "地裂終章",

  }

  SKILL_HELP = {

    82 => "敵單體汲取魂刻；首次得魂刻，之後取得素材。",

    100 => "敵單體草物理；45%附加共鳴標記。",

    101 => "敵單體施加共鳴標記，啟動召喚追擊。",

    102 => "被動：召喚物有效行動時，提高OD回收。",

    103 => "敵單體草傷；削減ATB並機率遲緩。",

    104 => "指定敵人，命令起手型召喚物立即追擊。",

    105 => "敵單體草／龍混合傷；標記目標增傷。",

    106 => "被動：高OD時增傷，並提高最大MP。",

    107 => "敵單體混合傷；由寶可夢自動接續追擊。",

    108 => "敵單體混合傷；依序發動三類召喚追擊。",

    109 => "敵全體草／龍重擊；發動完整三段連鎖。",

    110 => "我方單體恢復HP，基礎單體治療。",

    111 => "我方單體恢復HP；溢療轉為魔力層。",

    112 => "被動：溢療時獲得更多OD。",

    113 => "我方單體恢復HP；50%溢療轉護盾。",

    114 => "我方全體恢復HP，適合群體受傷時使用。",

    115 => "敵單體妖精魔法；魔力層越多越強。",

    116 => "被動：提高最大MP與精神。",

    117 => "敵單體妖精／飛行爆發；消耗3層魔力。",

    118 => "復活一名倒下隊友；冷卻3回合。",

    119 => "我方全體大補；溢療轉護盾與魔力層。",

    120 => "敵單體電物理；快速削減少量ATB。",

    121 => "敵單體鋼／電物理；高ATB削減更多。",

    122 => "被動：ATB削減轉換更多OD。",

    123 => "敵單體電混合傷；濕潤時更易麻痺。",

    124 => "自身獲得超載；提高輸出但承擔副作用。",

    125 => "敵單體鋼／電重擊；打斷高ATB詠唱。",

    126 => "被動：提高敏捷，更容易搶先行動。",

    127 => "敵全體電魔法；濕潤目標增傷並削ATB。",

    128 => "敵單體鋼／電大招；強力封鎖高ATB。",

    129 => "敵全體電爆發；高ATB敵人越多越有效。",

    130 => "敵單體毒魔法；高機率累積中毒。",

    131 => "敵單體快速疊毒，適合毒層不足時使用。",

    132 => "被動：提高毒、寄生、腐蝕成功率與精神。",

    133 => "將目標中毒擴散給其他敵人。",

    134 => "敵單體草傷；轉移中毒並機率寄生。",

    135 => "將目標中毒轉為腐蝕；冷卻1回合。",

    136 => "被動：新增異常疊層時獲得更多OD。",

    137 => "敵單體毒／超能傷；異常越多越強。",

    138 => "引爆並清除目標中毒，依疊層重創。",

    139 => "敵全體毒／草傷；附加中毒與腐蝕。",

    140 => "敵單體鋼物理；低機率暈眩。",

    141 => "立即進入護衛，替隊友承受攻擊。",

    142 => "被動：怒氣越高，受到的傷害越低。",

    143 => "敵單體草／毒物理；怒氣越高越痛。",

    144 => "提高被鎖定機率並獲得減傷。",

    145 => "自身進入痛苦熔爐，提高蓄痛效率。",

    146 => "被動：蓄痛上限提高至最大HP的400%。",

    147 => "消耗全部蓄痛，轉為單體復仇傷害。",

    148 => "敵單體鋼重擊；高怒氣增傷，不耗蓄痛。",

    149 => "敵全體草／毒重擊；消耗蓄痛復仇。",

    150 => "敵單體格鬥物理；累積1點破勢。",

    151 => "敵單體格鬥連擊；累積2點破勢。",

    152 => "被動：累積破勢時獲得更多OD。",

    153 => "敵單體格鬥傷；對已有破勢者增傷。",

    154 => "敵全體格鬥傷；全體累積1點破勢。",

    155 => "敵單體火／格鬥重擊；高OD多加破勢。",

    156 => "被動：攻擊常駐獲得12%穿透。",

    157 => "敵單體格鬥重擊；對崩防目標大幅增傷。",

    158 => "敵單體火／格鬥終結；消耗崩防狀態。",

    159 => "敵全體地面／格鬥重擊；高OD加破勢。",

    160 => "敵單體電物理傷害；削減ATB8、消耗穩定度10。",

    161 => "敵單體電魔法傷害；削減ATB20、消耗穩定度22。",

    162 => "敵單體電魔法傷害；消耗穩定度26。",

    163 => "自身支援效果；消耗穩定度0、回復穩定度30。",

    164 => "敵單體鋼／電魔法傷害；削減ATB30、消耗穩定度48。",

    165 => "自身支援效果；消耗穩定度8。",

    166 => "敵單體鋼物理傷害；消耗穩定度14。",

    167 => "敵單體草／鋼物理傷害；消耗穩定度24。",

    168 => "自身支援效果；消耗穩定度0、回復穩定度25。",

    169 => "敵全體草／鋼物理傷害；消耗穩定度48。",

    170 => "敵單體妖精魔法傷害；消耗穩定度10。",

    171 => "敵全體妖精魔法傷害；消耗穩定度16。",

    172 => "我方單體恢復HP；消耗穩定度20。",

    173 => "我方全體恢復HP；消耗穩定度28。",

    174 => "我方全體恢復HP；消耗穩定度48、回復穩定度20。",

    175 => "敵單體毒魔法傷害；消耗穩定度10、附加中毒。",

    176 => "敵全體毒魔法傷害；消耗穩定度18、附加遲緩。",

    177 => "敵單體超能魔法傷害；消耗穩定度22。",

    178 => "敵單體毒魔法傷害；消耗穩定度26、附加腐蝕。",

    179 => "敵全體毒／超能魔法傷害；消耗穩定度48。",

    180 => "敵單體格鬥物理傷害；消耗穩定度10。",

    181 => "敵單體格鬥物理傷害；消耗穩定度18。",

    182 => "敵全體格鬥物理傷害；消耗穩定度24。",

    183 => "自身支援效果；消耗穩定度0、回復穩定度30。",

    184 => "敵單體火／格鬥物理傷害；消耗穩定度52。",

    185 => "我方全體獲得防禦提升；附加防禦提升。",

    186 => "敵單體電魔法傷害；削減ATB20。",

    187 => "敵單體毒魔法傷害；55%腐蝕、對中毒增傷。",

    188 => "敵單體鋼物理傷害；累積2點破勢、對崩防增傷。",

    189 => "我方全體恢復HP。",

    190 => "敵單體魔法傷害。",

    191 => "敵單體鋼魔法傷害。",

    192 => "敵單體魔法傷害；消耗穩定度20。",

    600 => "敵單體草物理傷害。",

    601 => "敵單體支援效果；40%中毒。",

    602 => "敵單體支援效果；40%寄生。",

    604 => "敵單體支援效果；35%睡眠。",

    605 => "敵單體草魔法傷害；對寄生增傷。",

    606 => "敵單體草魔法傷害；對崩防增傷。",

    607 => "敵單體一般物理傷害。",

    608 => "敵單體火魔法傷害；18%灼燒。",

    610 => "敵單體一般物理傷害；會心+10%。",

    611 => "敵單體支援效果；55%速度降低、削減ATB10。",

    612 => "敵單體火魔法傷害；20%灼燒。",

    613 => "敵單體飛行物理傷害；會心+5%。",

    614 => "敵單體龍物理傷害。",

    615 => "敵單體火魔法傷害；25%灼燒。",

    616 => "敵單體一般物理傷害。",

    617 => "敵單體水魔法傷害；20%濕潤。",

    618 => "自身獲得守住；附加守住。",

    619 => "敵單體惡物理傷害；18%恐懼、30%暈眩。",

    620 => "敵單體水魔法傷害；25%濕潤。",

    621 => "敵全體水魔法傷害；25%濕潤。",

    622 => "敵單體冰魔法傷害；8%冰凍。",

    623 => "敵單體水魔法傷害；30%濕潤。",

    624 => "敵單體蟲物理傷害。",

    625 => "敵全體蟲魔法傷害。",

    626 => "敵單體魔法傷害；異常越多越強。",

    627 => "敵單體蟲物理傷害；對崩防增傷。",

    628 => "敵單體蟲魔法傷害；10%混亂。",

    631 => "敵單體毒物理傷害；30%中毒。",

    632 => "敵單體支援效果；55%中毒。",

    633 => "敵單體蟲物理傷害。",

    634 => "敵單體飛行物理傷害。",

    636 => "敵單體飛行物理傷害；會心+5%。",

    637 => "敵單體支援效果；60%攻擊降低。",

    639 => "敵單體一般物理傷害。",

    640 => "敵單體惡物理傷害；18%恐懼。",

    641 => "敵單體一般物理傷害。",

    642 => "敵單體一般物理傷害；對崩防增傷。",

    643 => "敵單體飛行物理傷害；會心+5%。",

    644 => "敵單體毒魔法傷害；20%中毒、25%腐蝕。",

    645 => "敵單體毒魔法傷害；30%中毒、20%腐蝕。",

    646 => "敵單體支援效果；45%麻痺。",

    649 => "敵單體支援效果；45%麻痺。",

    650 => "敵單體電魔法傷害；30%麻痺。",

    651 => "敵單體電魔法傷害；20%麻痺。",

    652 => "敵單體地面物理傷害；10%暈眩、累積1點破勢。",

    653 => "敵單體地面魔法傷害。",

    654 => "敵單體格鬥物理傷害；累積1點破勢。",

    655 => "敵全體地面物理傷害；累積2點破勢。",

    656 => "敵單體地面物理傷害；累積1點破勢。",

    657 => "我方全體獲得防禦提升；附加防禦提升。",

    658 => "敵單體毒魔法傷害；30%中毒。",

    659 => "我方單體恢復HP。",

    660 => "敵單體支援效果；60%攻擊降低。",

    661 => "敵單體一般魔法傷害。",

    662 => "敵單體火物理傷害；22%灼燒。",

    663 => "敵單體支援效果；50%灼燒。",

    665 => "敵單體支援效果；35%混亂。",

    666 => "敵單體支援效果；30%睡眠。",

    667 => "敵單體一般物理傷害；25%麻痺。",

    669 => "敵單體支援效果；50%睡眠。",

    670 => "敵單體超能魔法傷害；8%混亂、削減ATB6。",

    671 => "敵單體支援效果；50%封鎖網。",

    672 => "敵單體水物理傷害；25%濕潤、15%暈眩。",

    673 => "敵全體支援效果；35%濕潤。",

    674 => "敵單體格鬥物理傷害；會心+10%。",

    676 => "自身獲得會心提升；附加會心提升。",

    677 => "敵單體格鬥物理傷害；累積2點破勢、會心+10%。",

    678 => "敵單體一般物理傷害；對崩防增傷。",

    679 => "敵單體一般物理傷害。",

    680 => "敵單體支援效果；35%睡眠。",

    681 => "敵單體冰魔法傷害；35%遲緩、削減ATB8。",

    682 => "敵單體超能魔法傷害；削減ATB10。",

    683 => "敵單體超能魔法傷害；10%混亂、削減ATB8。",

    684 => "自身恢復HP。",

    685 => "自身獲得精神提升／魔力再生；附加精神提升、附加魔力再生。",

    686 => "敵單體超能魔法傷害；削減ATB10。",

    687 => "自身獲得攻擊提升／防禦提升；附加攻擊提升、附加防禦提升。",

    688 => "敵單體格鬥物理傷害；35%混亂、累積2點破勢。",

    690 => "敵單體支援效果；30%混亂。",

    691 => "敵單體岩石物理傷害。",

    693 => "敵單體地面物理傷害。",

    695 => "敵單體一般物理傷害；20%暈眩。",

    697 => "敵單體電魔法傷害；22%麻痺。",

    698 => "敵單體鋼物理傷害。",

    700 => "自身獲得防禦提升；附加防禦提升。",

    701 => "敵單體幽靈魔法傷害；20%脆弱、異常越多越強。",

    702 => "敵單體幽靈物理傷害；15%脆弱、20%麻痺。",

    704 => "敵單體支援效果；55%防禦降低、20%脆弱。",

    705 => "我方全體獲得精神提升；附加精神提升。",

    706 => "敵單體一般物理傷害；20%暈眩。",

    707 => "敵單體地面物理傷害。",

    709 => "敵全體岩石物理傷害；20%暈眩、累積1點破勢。",

    710 => "我方單體恢復HP。",

    715 => "敵單體岩石魔法傷害。",

    718 => "敵單體龍魔法傷害；30%麻痺。",

    720 => "自身獲得攻擊提升／精神提升；附加攻擊提升、附加精神提升。",

    722 => "我方單體獲得攻擊提升／精神提升；附加攻擊提升、附加精神提升。",

    724 => "敵單體一般魔法傷害。",

    725 => "敵單體飛行魔法傷害。",

    726 => "敵單體支援效果；60%根縛。",

    728 => "敵單體幽靈物理傷害；20%脆弱。",

    729 => "敵全體支援效果；35%脆弱。",

    730 => "敵單體鋼物理傷害；累積1點破勢。",

    731 => "敵全體一般物理傷害；對崩防增傷。",

    732 => "敵單體鋼物理傷害；累積2點破勢。",

    735 => "敵單體冰魔法傷害；8%冰凍。",

    736 => "敵全體支援效果；25%恐懼、削減ATB15。",

    740 => "敵單體一般物理傷害。",

    741 => "敵單體草魔法傷害；對寄生增傷。",

    748 => "敵全體水魔法傷害；30%濕潤。",

    749 => "敵單體格鬥物理傷害。",

    750 => "敵單體惡物理傷害；18%恐懼、對攻擊提升增傷。",

    751 => "自身獲得防禦提升；附加防禦提升。",

    752 => "敵單體水魔法傷害；25%濕潤、15%混亂。",

    753 => "自身獲得攻擊提升；附加攻擊提升。",

    755 => "敵單體鋼物理傷害；累積1點破勢。",

    764 => "敵單體支援效果；55%精神降低、20%脆弱。",

    765 => "敵單體飛行魔法傷害；20%暈眩、會心+5%。",

    767 => "敵單體蟲物理傷害；20%中毒、會心+5%。",

    768 => "敵全體支援效果；35%遲緩。",

    769 => "自身獲得防禦提升；附加防禦提升。",

    770 => "敵單體毒物理傷害；20%中毒。",

    771 => "自身獲得速度提升；附加速度提升。",

  }

  SKILL_POP = {

    100 => ["先留下第一道爪痕。", "讓森林從這一爪醒來。"],

    101 => ["爪印會記住你的聲音。", "標記完成，大家跟上。"],

    103 => ["藤脈，纏住他的腳步。", "別急，森林會抓住你。"],

    104 => ["鳴刻，接續！", "輪到你回應了！"],

    105 => ["龍息纏上爪鋒。", "森林和龍，一起撕開。"],

    107 => ["換一段旋律，接著追。", "別停，讓召喚物接手。"],

    108 => ["三聲，依序響起！", "第一爪之後，別眨眼。"],

    109 => ["爪痕會連成整座森林。", "這就是我們的交響。"],

    110 => ["弦光會找到傷口。", "放鬆，我把光送過去。"],

    111 => ["多出的光，留在弦上。", "讓溢光成為下一次力量。"],

    113 => ["這一弦，替你擋下。", "護幕展開，別離開光。"],

    114 => ["同一段弦音，照亮大家。", "讓光沿著弓弦散開。"],

    115 => ["弦已繃緊，魔力釋放。", "沒有箭，也能命中。"],

    117 => ["星光上弦，放！", "累積的光，全部釋放。"],

    118 => ["聽見弦音就回來。", "生命還沒有斷弦。"],

    119 => ["大地與弓弦，一起共鳴。", "這一弦，托住所有人。"],

    120 => ["槍尖導通，直線突入。", "電位確認，貫穿。"],

    121 => ["長槍截流，停在這裡。", "你的節奏，卡在槍尖上。"],

    123 => ["濕度足夠，槍尖導通。", "雷鎖完成，別想移動。"],

    124 => ["迴路開放，槍壓提升。", "提高輸出，承擔風險。"],

    125 => ["槍鋒切開你的下一秒。", "時間窗口，現在關閉。"],

    127 => ["接點完成，放電連鎖。", "槍尖一指，一個都別漏。"],

    128 => ["槍尖所到，時間歸零。", "封鎖完成，不准前進。"],

    129 => ["限制解除，直到結束。", "讓計算追上這一槍。"],

    130 => ["先吹入一點毒音。", "第一個音，留下樣本。"],

    131 => ["濃度不夠，再加一拍。", "讓毒在旋律裡成熟。"],

    133 => ["霧笛響起，病灶擴散。", "這段旋律，不只感染一個。"],

    134 => ["換個宿主，旋律繼續。", "寄生，跟著音階漂移。"],

    135 => ["把毒音變成腐蝕。", "原料成熟，開始變奏。"],

    137 => ["症狀越多，和聲越完整。", "你的病歷，正在合奏。"],

    138 => ["曲終，毒性一次結算。", "最後一音，全部引爆。"],

    139 => ["歡迎進入萬毒交響。", "每個音符都有副作用。"],

    140 => ["斧背開路，退後！", "不想被撞飛就讓開。"],

    141 => ["站我後面，斧牆撐住。", "想碰他們，先過我這把斧。"],

    143 => ["怒氣夠了，吃我一斧。", "這一斧算你的。"],

    144 => ["看我，不准看別人。", "有膽就衝斧頭來。"],

    145 => ["打吧，斧頭會全部記住。", "痛苦不會白費。"],

    147 => ["剛才那幾下，斧頭記著。", "我挨的，現在由你結帳。"],

    148 => ["城牆會倒，但先砸你。", "守完了，輪到巨斧。"],

    149 => ["欠下的痛，全部歸斧。", "你打多少，我劈多少。"],

    150 => ["先敲一道裂縫。", "拳頭比城門講道理。"],

    151 => ["一層一層拆。", "護甲不是永久建築。"],

    153 => ["裂了就別想補。", "我看到破口了。"],

    154 => ["一起裂開吧。", "站成一排，省我時間。"],

    155 => ["還差一點？那就加倍。", "用力不夠，只是藉口。"],

    157 => ["門開了，大家上！", "崩防窗口，別浪費！"],

    158 => ["窗口歸我，結束。", "城倒了，人也別站著。"],

    159 => ["地面先投降了。", "整片戰場，一起碎。"],

  }



  WEAPON_NAMES = {

    100 => "森芽爪",

    101 => "鳴脈爪",

    102 => "殘響連爪",

    103 => "龍森雙爪",

    104 => "森律龍爪",

    105 => "木靈魔弓",

    106 => "祈光魔弓",

    107 => "溢光弦弓",

    108 => "星輝長弓",

    109 => "大地聖弓",

    110 => "電鋼長槍",

    111 => "截流雷槍",

    112 => "雷鎖長槍",

    113 => "零時鋒槍",

    114 => "終端超頻槍",

    115 => "毒音短笛",

    116 => "培養長笛",

    117 => "腐蝕導笛",

    118 => "病灶魔笛",

    119 => "萬毒花笛",

    120 => "藤護巨斧",

    121 => "棘牆戰斧",

    122 => "庇護重斧",

    123 => "痛爐壁斧",

    124 => "怒海城斧",

    125 => "粗鐵拳甲",

    126 => "破甲拳甲",

    127 => "震城臂鎧",

    128 => "斷城拳鎧",

    129 => "地裂王拳",

  }

  WEAPON_HELP = {

    100 => "喬伊爪｜基礎攻擊與精神均衡提升。",

    101 => "喬伊爪｜裝備時習得「共鳴爪印」。",

    102 => "喬伊爪｜詠唱-3%，開場獲得共鳴和聲。",

    103 => "喬伊爪｜高攻擊、精神與敏捷。",

    104 => "喬伊爪｜習得森之交響，開場和聲，ATB+5%。",

    105 => "米亞魔弓｜基礎精神提升；以魔力弦光射擊。",

    106 => "米亞魔弓｜裝備時習得「溢光弦」。",

    107 => "米亞魔弓｜詠唱-2%，開場獲得療癒共振。",

    108 => "米亞魔弓｜大幅提高精神與敏捷。",

    109 => "米亞魔弓｜習得大地和弦，開場共振，詠唱-5%。",

    110 => "艾卓長槍｜提高攻擊與敏捷，適合快速突刺。",

    111 => "艾卓長槍｜裝備時習得「截流槍」。",

    112 => "艾卓長槍｜詠唱-4%，開場獲得靜電場。",

    113 => "艾卓長槍｜初始ATB+8%，詠唱-5%。",

    114 => "艾卓長槍｜習得終端超頻，開場靜電，ATB+10%。",

    115 => "維娜笛｜提高精神與敏捷，適合毒音起手。",

    116 => "維娜笛｜裝備時習得「毒音培養」。",

    117 => "維娜笛｜詠唱-2%，開場獲得毒華專精。",

    118 => "維娜笛｜大幅提高精神與敏捷。",

    119 => "維娜笛｜習得萬毒交響，開場專精，詠唱-5%。",

    120 => "艾薇巨斧｜同時提高攻擊與防禦。",

    121 => "艾薇巨斧｜裝備時習得「荊棘護陣」。",

    122 => "艾薇巨斧｜開場獲得痛苦熔爐。",

    123 => "艾薇巨斧｜蓄痛上限提高至最大HP的350%。",

    124 => "艾薇巨斧｜習得怒海歸斧，蓄痛上限400%。",

    125 => "泰勒拳甲｜基礎攻擊與防禦提升。",

    126 => "泰勒拳甲｜裝備時習得「破甲連擊」。",

    127 => "泰勒拳甲｜穿透+6%，並提高少量敏捷。",

    128 => "泰勒拳甲｜穿透+10%，適合崩防追擊。",

    129 => "泰勒拳甲｜習得地裂終章，穿透+14%、會心+4%。",

  }

  WEAPON_POP = {

    100 => ["爪鋒剛好，先試一痕。", "森林，跟上我的手。"],

    101 => ["鳴脈接上了。", "這一爪會留下回聲。"],

    102 => ["殘響同步，連爪。", "別讓共鳴斷掉。"],

    103 => ["雙爪交會，龍森並行。", "一左一右，撕開節奏。"],

    104 => ["森律就位，全員跟上。", "龍爪起奏，別掉隊。"],

    105 => ["弓弦已亮。", "把光放出去。"],

    106 => ["祈光上弦。", "這一發不需要箭。"],

    107 => ["溢光沿著弦流動。", "弦音會留下力量。"],

    108 => ["星輝瞄準。", "光落在哪裡，我說了算。"],

    109 => ["大地為弓，光為弦。", "聖弦展開，準備釋放。"],

    110 => ["槍線校準。", "貫穿路徑確認。"],

    111 => ["截流點已鎖定。", "長槍會替時間踩煞車。"],

    112 => ["雷鎖纏上槍鋒。", "導通完成。"],

    113 => ["零時槍鋒，就位。", "下一秒由我決定。"],

    114 => ["終端超頻，槍壓全開。", "計算完成，一槍解決。"],

    115 => ["試吹一個樣本。", "毒音，開始。"],

    116 => ["培養節拍穩定。", "讓濃度跟著音階上升。"],

    117 => ["腐蝕音色，調準。", "這段旋律會咬人。"],

    118 => ["病灶已經跟上節拍。", "聽清楚，副作用要來了。"],

    119 => ["萬毒花笛，開奏。", "每個音都有毒。"],

    120 => ["斧頭比你有耐心。", "過來，讓我試試重量。"],

    121 => ["棘牆立起，巨斧在前。", "先過這把斧。"],

    122 => ["庇護不只靠防守。", "重斧落地，誰都別過。"],

    123 => ["痛苦進爐，斧刃出火。", "打得越重，我記得越清楚。"],

    124 => ["怒海上斧。", "城牆與巨斧，一起壓下去。"],

    125 => ["拳甲扣緊。", "先打一個缺口。"],

    126 => ["破甲模式。", "一拳不夠，就多幾拳。"],

    127 => ["臂鎧震動完成。", "城牆也有裂縫。"],

    128 => ["斷城拳鎧，就位。", "這一拳專拆硬的。"],

    129 => ["地裂王拳，全力。", "地面先替你認輸。"],

  }



  ITEM_HELP = {

    200 => "重複汲取素材；3個可合成「叢生芽冠」。",

    201 => "重複汲取素材；3個可合成「灼翼導流環」。",

    202 => "重複汲取素材；3個可合成「沼鎧承壓器」。",

    203 => "重複汲取素材；3個可合成「夢粉複眼鏡」。",

    204 => "重複汲取素材；3個可合成「雙針聚焦鞘」。",

    205 => "重複汲取素材；3個可合成「風壓尾羽」。",

    206 => "重複汲取素材；3個可合成「疾走門牙扣」。",

    207 => "重複汲取素材；3個可合成「貫空喙環」。",

    208 => "重複汲取素材；3個可合成「蛇瞳催眠墜」。",

    209 => "重複汲取素材；3個可合成「雷尾蓄電環」。",

    210 => "重複汲取素材；3個可合成「砂掘爪套」。",

    211 => "重複汲取素材；3個可合成「狐火燈芯」。",

    212 => "重複汲取素材；3個可合成「月歌共鳴鈴」。",

    213 => "重複汲取素材；3個可合成「超聲翼膜」。",

    214 => "重複汲取素材；3個可合成「毒粉花冠」。",

    215 => "重複汲取素材；3個可合成「孢子菌核」。",

    216 => "重複汲取素材；3個可合成「幻粉觸角」。",

    217 => "重複汲取素材；3個可合成「念波止流器」。",

    218 => "重複汲取素材；3個可合成「怒拳繃帶」。",

    219 => "重複汲取素材；3個可合成「神速足環」。",

    220 => "重複汲取素材；3個可合成「雨紋腹帶」。",

    221 => "重複汲取素材；3個可合成「光牆湯匙陣」。",

    222 => "重複汲取素材；3個可合成「四臂鍛帶」。",

    223 => "重複汲取素材；3個可合成「酸囊導管」。",

    224 => "重複汲取素材；3個可合成「岩殼護心」。",

    225 => "重複汲取素材；3個可合成「焰蹄馬鐙」。",

    226 => "重複汲取素材；3個可合成「磁音共振器」。",

    227 => "重複汲取素材；3個可合成「三首節拍器」。",

    228 => "重複汲取素材；3個可合成「溶化黏核」。",

    229 => "重複汲取素材；3個可合成「亂光影燈」。",

    230 => "重複汲取素材；3個可合成「眠波擺錘」。",

    231 => "重複汲取素材；3個可合成「超速放電殼」。",

    232 => "重複汲取素材；3個可合成「回旋骨扣」。",

    233 => "重複汲取素材；3個可合成「原始螺殼」。",

    234 => "重複汲取素材；3個可合成「裂岩刃架」。",

    235 => "重複汲取素材；3個可合成「預知思維框」。",

    236 => "重複汲取素材；3個可合成「無限揮指環」。",

    237 => "重複汲取素材；3個可合成「協奏尾旗」。",

    238 => "重複汲取素材；3個可合成「封鎖蛛絲輪」。",

    239 => "重複汲取素材；3個可合成「祝福羽冠」。",

    240 => "重複汲取素材；3個可合成「幻光耳墜」。",

    241 => "重複汲取素材；3個可合成「光牆育護囊」。",

    242 => "重複汲取素材；3個可合成「雷雲脈衝環」。",

    243 => "重複汲取素材；3個可合成「王吼焰鬃」。",

    244 => "重複汲取素材；3個可合成「風薄紗」。",

    245 => "重複汲取素材；3個可合成「沙暴核心」。",

    246 => "重複汲取素材；3個可合成「雨舞蓮帽」。",

    247 => "重複汲取素材；3個可合成「順風喉囊」。",

    248 => "重複汲取素材；3個可合成「猛推腰綱」。",

    249 => "重複汲取素材；3個可合成「鐵顎護髮環」。",

    250 => "重複汲取素材；3個可合成「鋼岩胸核」。",

    251 => "重複汲取素材；3個可合成「鬼面背鰭」。",

    252 => "重複汲取素材；3個可合成「癒潮鱗帶」。",

    253 => "重複汲取素材；3個可合成「冥火靈燈」。",

    254 => "重複汲取素材；3個可合成「災兆劍飾」。",

    255 => "重複汲取素材；3個可合成「龍息翼扣」。",

    256 => "重複汲取素材；3個可合成「彗星演算核」。",

    257 => "重複汲取素材；3個可合成「冰風面紗」。",

    258 => "重複汲取素材；3個可合成「攀瀑逆鱗環」。",

    259 => "重複汲取素材；3個可合成「導電燈囊」。",

    260 => "重複汲取素材；3個可合成「撒菱殼匣」。",

    261 => "重複汲取素材；3個可合成「地脈刃」。",

    262 => "重複汲取素材；3個可合成「巨角鍛環」。",

    263 => "重複汲取素材；3個可合成「焦獄項圈」。",

    264 => "重複汲取素材；3個可合成「鋼羽撒菱匣」。",

    265 => "重複汲取素材；3個可合成「祈願心紗」。",

    600 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    601 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    602 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    603 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    604 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    605 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    606 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    607 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    608 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    609 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    610 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    611 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    612 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    613 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    614 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    615 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    616 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    617 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    618 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    619 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    620 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    621 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    622 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    623 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    624 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    625 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    626 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    627 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    628 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    629 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    630 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    631 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    632 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    633 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    634 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    635 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    636 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    637 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    638 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    639 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    640 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    641 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    642 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    643 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    644 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    645 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    646 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    647 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    648 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    649 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    650 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    651 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    652 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    653 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    654 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    655 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    656 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    657 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    658 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    659 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    660 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    661 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    662 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    663 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    664 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

    665 => "野生戰鬥掉落素材；不可替代重複汲取殘片。",

  }

  ARMOR_HELP = {

    220 => "搭配妙蛙花魂刻：開場施放「寄生種子」。",

    221 => "搭配噴火龍魂刻：開場施放「翅膀攻擊」。",

    222 => "搭配巨沼怪魂刻：開場施放「守住」。",

    223 => "搭配巴大蝶魂刻：開場施放「催眠粉」。",

    224 => "搭配大針蜂魂刻：開場施放「聚氣」。",

    225 => "搭配比雕魂刻：開場施放「羽毛舞」。",

    226 => "搭配拉達魂刻：開場施放「電光一閃」。",

    227 => "搭配大嘴雀魂刻：開場施放「燕返」。",

    228 => "搭配阿柏怪魂刻：開場施放「大蛇瞪眼」。",

    229 => "搭配雷丘魂刻：開場施放「電磁波」。",

    230 => "搭配穿山王魂刻：開場施放「挖洞」。",

    231 => "搭配九尾魂刻：開場施放「鬼火」。",

    232 => "搭配胖可丁魂刻：開場施放「唱歌」。",

    233 => "搭配叉字蝠魂刻：開場施放「超音波」。",

    234 => "搭配霸王花魂刻：開場施放「毒粉」。",

    235 => "搭配派拉斯特魂刻：開場施放「蘑菇孢子」。",

    236 => "搭配摩魯蛾魂刻：開場施放「催眠粉」。",

    237 => "搭配哥達鴨魂刻：開場施放「定身法」。",

    238 => "搭配火爆猴魂刻：開場施放「聚氣」。",

    239 => "搭配風速狗魂刻：開場施放「神速」。",

    240 => "搭配蚊香泳士魂刻：開場施放「求雨」。",

    241 => "搭配胡地魂刻：開場施放「光牆」。",

    242 => "搭配怪力魂刻：開場施放「健美」。",

    243 => "搭配毒刺水母魂刻：開場施放「溶解液」。",

    244 => "搭配隆隆岩魂刻：開場施放「守住」。",

    245 => "搭配烈焰馬魂刻：開場施放「火焰輪」。",

    246 => "搭配自爆磁怪魂刻：開場施放「金屬音」。",

    247 => "搭配嘟嘟利魂刻：開場施放「三重攻擊」。",

    248 => "搭配臭臭泥魂刻：開場施放「溶化」。",

    249 => "搭配耿鬼魂刻：開場施放「奇異之光」。",

    250 => "搭配引夢貘人魂刻：開場施放「定身法」。",

    251 => "搭配頑皮雷彈魂刻：開場施放「刺耳聲」。",

    252 => "搭配嘎啦嘎啦魂刻：開場施放「骨頭回力鏢」。",

    253 => "搭配多刺菊石獸魂刻：開場施放「原始之力」。",

    254 => "搭配鐮刀盔魂刻：開場施放「岩崩」。",

    255 => "搭配超夢魂刻：開場施放「預知未來」。",

    256 => "搭配夢幻魂刻：開場施放「揮指」。",

    257 => "搭配大尾立魂刻：開場施放「幫助」。",

    258 => "搭配阿利多斯魂刻：開場施放「蛛網」。",

    259 => "搭配波克基斯魂刻：開場施放「祈願」。",

    260 => "搭配夢妖魔魂刻：開場施放「奇異之光」。",

    261 => "搭配幸福蛋魂刻：開場施放「光牆」。",

    262 => "搭配雷公魂刻：開場施放「電磁波」。",

    263 => "搭配炎帝魂刻：開場施放「吼叫」。",

    264 => "搭配水君魂刻：開場施放「冰凍之風」。",

    265 => "搭配班基拉斯魂刻：開場施放「沙暴」。",

    266 => "搭配樂天河童魂刻：開場施放「求雨」。",

    267 => "搭配大嘴鷗魂刻：開場施放「起風」。",

    268 => "搭配鐵掌力士魂刻：開場施放「健美」。",

    269 => "搭配大嘴娃魂刻：開場施放「鐵壁」。",

    270 => "搭配波士可多拉魂刻：開場施放「鐵壁」。",

    271 => "搭配巨牙鯊魂刻：開場施放「鬼面」。",

    272 => "搭配美納斯魂刻：開場施放「自我再生」。",

    273 => "搭配黑夜魔靈魂刻：開場施放「鬼火」。",

    274 => "搭配阿勃梭魯魂刻：開場施放「劍舞」。",

    275 => "搭配暴飛龍魂刻：開場施放「龍息」。",

    276 => "搭配巨金怪魂刻：開場施放「彗星拳」。",

    277 => "搭配雪妖女魂刻：開場施放「冰凍之風」。",

    278 => "搭配暴鯉龍魂刻：開場施放「攀瀑」。",

    279 => "搭配電燈怪魂刻：開場施放「電磁波」。",

    280 => "搭配佛烈托斯魂刻：開場施放「撒菱」。",

    281 => "搭配烈咬陸鯊魂刻：開場施放「泥巴射擊」。",

    282 => "搭配赫拉克羅斯魂刻：開場施放「健美」。",

    283 => "搭配黑魯加魂刻：開場施放「鬼火」。",

    284 => "搭配盔甲鳥魂刻：開場施放「撒菱」。",

    285 => "搭配沙奈朵魂刻：開場施放「祈願」。",

    286 => "召喚艾卓映體；佔用一個召喚欄位。",

    287 => "召喚艾薇映體；佔用一個召喚欄位。",

    288 => "召喚米亞映體；佔用一個召喚欄位。",

    289 => "召喚維娜映體；佔用一個召喚欄位。",

    290 => "召喚泰勒映體；佔用一個召喚欄位。",

    291 => "召喚壁壘機；依固定協議自動行動。",

    292 => "召喚雷序機；依固定協議自動行動。",

    293 => "召喚腐蝕機；依固定協議自動行動。",

    294 => "召喚破城機；依固定協議自動行動。",

    295 => "召喚淨化機；依固定協議自動行動。",

    296 => "輕裝：HP+55，提高精神／敏捷，詠唱-0%。",

    297 => "輕裝：HP+120，提高精神／敏捷，詠唱-1%。",

    298 => "輕裝：HP+220，提高精神／敏捷，詠唱-2%。",

    299 => "輕裝：HP+360，提高精神／敏捷，詠唱-3%。",

    300 => "輕裝：HP+520，提高精神／敏捷，詠唱-4%。",

    301 => "法衣：MP+20，大幅提高精神。",

    302 => "法衣：MP+45，大幅提高精神。",

    303 => "法衣：MP+80，大幅提高精神。",

    304 => "法衣：MP+125，大幅提高精神。",

    305 => "法衣：MP+180，大幅提高精神，MP消耗減半。",

    306 => "重鎧：HP+90，大幅提高防禦。",

    307 => "重鎧：HP+200，大幅提高防禦。",

    308 => "重鎧：HP+360，大幅提高防禦。",

    309 => "重鎧：HP+560，大幅提高防禦。",

    310 => "重鎧：HP+800，大幅提高防禦，防止暴擊。",

    311 => "突擊甲：大幅提高攻擊，並補足防禦。",

    312 => "突擊甲：大幅提高攻擊，並補足防禦。",

    313 => "突擊甲：大幅提高攻擊，並補足防禦。",

    314 => "突擊甲：大幅提高攻擊，並補足防禦。",

    315 => "突擊甲：大幅提高攻擊，並補足防禦。",

    316 => "喬伊專屬：召喚物有效行動時回收OD 70。",

    317 => "喬伊專屬：召喚物有效行動時回收OD 80。",

    318 => "喬伊專屬：召喚物有效行動時回收OD 90。",

    319 => "米亞專屬：每次溢療提高OD回收4。",

    320 => "米亞專屬：每次溢療提高OD回收5。",

    321 => "米亞專屬：開場獲得療癒共振。",

    322 => "艾卓專屬：詠唱時間縮短3%。",

    323 => "艾卓專屬：詠唱時間縮短5%。",

    324 => "艾卓專屬：開場獲得靜電場。",

    325 => "維娜專屬：新增異常疊層時回收OD 60。",

    326 => "維娜專屬：新增異常疊層時回收OD 70。",

    327 => "維娜專屬：開場獲得毒華專精。",

    328 => "艾薇專屬：HP+120，蓄痛上限325%。",

    329 => "艾薇專屬：HP+260，蓄痛上限350%。",

    330 => "艾薇專屬：HP+460，蓄痛上限400%。",

    331 => "泰勒專屬：穿透率+4%。",

    332 => "泰勒專屬：穿透率+8%。",

    333 => "泰勒專屬：穿透率+12%。",

  }

  SOUL_ARMOR_HELP = {

    600 => "鳴刻妙蛙花系召喚物；搭配「叢生芽冠」啟動共鳴。",

    601 => "鳴刻噴火龍系召喚物；搭配「灼翼導流環」啟動共鳴。",

    602 => "鳴刻巨沼怪系召喚物；搭配「沼鎧承壓器」啟動共鳴。",

    603 => "鳴刻巴大蝶系召喚物；搭配「夢粉複眼鏡」啟動共鳴。",

    604 => "鳴刻大針蜂系召喚物；搭配「雙針聚焦鞘」啟動共鳴。",

    605 => "鳴刻比雕系召喚物；搭配「風壓尾羽」啟動共鳴。",

    606 => "鳴刻拉達系召喚物；搭配「疾走門牙扣」啟動共鳴。",

    607 => "鳴刻大嘴雀系召喚物；搭配「貫空喙環」啟動共鳴。",

    608 => "鳴刻阿柏怪系召喚物；搭配「蛇瞳催眠墜」啟動共鳴。",

    609 => "鳴刻雷丘系召喚物；搭配「雷尾蓄電環」啟動共鳴。",

    610 => "鳴刻穿山王系召喚物；搭配「砂掘爪套」啟動共鳴。",

    611 => "鳴刻九尾系召喚物；搭配「狐火燈芯」啟動共鳴。",

    612 => "鳴刻胖可丁系召喚物；搭配「月歌共鳴鈴」啟動共鳴。",

    613 => "鳴刻叉字蝠系召喚物；搭配「超聲翼膜」啟動共鳴。",

    614 => "鳴刻霸王花系召喚物；搭配「毒粉花冠」啟動共鳴。",

    615 => "鳴刻派拉斯特系召喚物；搭配「孢子菌核」啟動共鳴。",

    616 => "鳴刻摩魯蛾系召喚物；搭配「幻粉觸角」啟動共鳴。",

    617 => "鳴刻哥達鴨系召喚物；搭配「念波止流器」啟動共鳴。",

    618 => "鳴刻火爆猴系召喚物；搭配「怒拳繃帶」啟動共鳴。",

    619 => "鳴刻風速狗系召喚物；搭配「神速足環」啟動共鳴。",

    620 => "鳴刻蚊香泳士系召喚物；搭配「雨紋腹帶」啟動共鳴。",

    621 => "鳴刻胡地系召喚物；搭配「光牆湯匙陣」啟動共鳴。",

    622 => "鳴刻怪力系召喚物；搭配「四臂鍛帶」啟動共鳴。",

    623 => "鳴刻毒刺水母系召喚物；搭配「酸囊導管」啟動共鳴。",

    624 => "鳴刻隆隆岩系召喚物；搭配「岩殼護心」啟動共鳴。",

    625 => "鳴刻烈焰馬系召喚物；搭配「焰蹄馬鐙」啟動共鳴。",

    626 => "鳴刻自爆磁怪系召喚物；搭配「磁音共振器」啟動共鳴。",

    627 => "鳴刻嘟嘟利系召喚物；搭配「三首節拍器」啟動共鳴。",

    628 => "鳴刻臭臭泥系召喚物；搭配「溶化黏核」啟動共鳴。",

    629 => "鳴刻耿鬼系召喚物；搭配「亂光影燈」啟動共鳴。",

    630 => "鳴刻引夢貘人系召喚物；搭配「眠波擺錘」啟動共鳴。",

    631 => "鳴刻頑皮雷彈系召喚物；搭配「超速放電殼」啟動共鳴。",

    632 => "鳴刻嘎啦嘎啦系召喚物；搭配「回旋骨扣」啟動共鳴。",

    633 => "鳴刻多刺菊石獸系召喚物；搭配「原始螺殼」啟動共鳴。",

    634 => "鳴刻鐮刀盔系召喚物；搭配「裂岩刃架」啟動共鳴。",

    635 => "鳴刻超夢系召喚物；搭配「預知思維框」啟動共鳴。",

    636 => "鳴刻夢幻系召喚物；搭配「無限揮指環」啟動共鳴。",

    637 => "鳴刻大尾立系召喚物；搭配「協奏尾旗」啟動共鳴。",

    638 => "鳴刻阿利多斯系召喚物；搭配「封鎖蛛絲輪」啟動共鳴。",

    639 => "鳴刻波克基斯系召喚物；搭配「祝福羽冠」啟動共鳴。",

    640 => "鳴刻夢妖魔系召喚物；搭配「幻光耳墜」啟動共鳴。",

    641 => "鳴刻幸福蛋系召喚物；搭配「光牆育護囊」啟動共鳴。",

    642 => "鳴刻雷公系召喚物；搭配「雷雲脈衝環」啟動共鳴。",

    643 => "鳴刻炎帝系召喚物；搭配「王吼焰鬃」啟動共鳴。",

    644 => "鳴刻水君系召喚物；搭配「風薄紗」啟動共鳴。",

    645 => "鳴刻班基拉斯系召喚物；搭配「沙暴核心」啟動共鳴。",

    646 => "鳴刻樂天河童系召喚物；搭配「雨舞蓮帽」啟動共鳴。",

    647 => "鳴刻大嘴鷗系召喚物；搭配「順風喉囊」啟動共鳴。",

    648 => "鳴刻鐵掌力士系召喚物；搭配「猛推腰綱」啟動共鳴。",

    649 => "鳴刻大嘴娃系召喚物；搭配「鐵顎護髮環」啟動共鳴。",

    650 => "鳴刻波士可多拉系召喚物；搭配「鋼岩胸核」啟動共鳴。",

    651 => "鳴刻巨牙鯊系召喚物；搭配「鬼面背鰭」啟動共鳴。",

    652 => "鳴刻美納斯系召喚物；搭配「癒潮鱗帶」啟動共鳴。",

    653 => "鳴刻黑夜魔靈系召喚物；搭配「冥火靈燈」啟動共鳴。",

    654 => "鳴刻阿勃梭魯系召喚物；搭配「災兆劍飾」啟動共鳴。",

    655 => "鳴刻暴飛龍系召喚物；搭配「龍息翼扣」啟動共鳴。",

    656 => "鳴刻巨金怪系召喚物；搭配「彗星演算核」啟動共鳴。",

    657 => "鳴刻雪妖女系召喚物；搭配「冰風面紗」啟動共鳴。",

    658 => "鳴刻暴鯉龍系召喚物；搭配「攀瀑逆鱗環」啟動共鳴。",

    659 => "鳴刻電燈怪系召喚物；搭配「導電燈囊」啟動共鳴。",

    660 => "鳴刻佛烈托斯系召喚物；搭配「撒菱殼匣」啟動共鳴。",

    661 => "鳴刻烈咬陸鯊系召喚物；搭配「地脈刃」啟動共鳴。",

    662 => "鳴刻赫拉克羅斯系召喚物；搭配「巨角鍛環」啟動共鳴。",

    663 => "鳴刻黑魯加系召喚物；搭配「焦獄項圈」啟動共鳴。",

    664 => "鳴刻盔甲鳥系召喚物；搭配「鋼羽撒菱匣」啟動共鳴。",

    665 => "鳴刻沙奈朵系召喚物；搭配「祈願心紗」啟動共鳴。",

  }



  POP_LINE = /^<pop_text\s*:[^>\r\n]+>$/i



  def self.replace_pop_text(note, lines)

    result = note.to_s.gsub("\r", "").split("\n")

    result.delete_if { |line| line.to_s.strip =~ POP_LINE }

    lines.each { |line| result.push("<pop_text:#{line}>") }

    return result.join("\n")

  end



  def self.apply_data_overrides

    if defined?(FS_DB_AUTOSET_SKILLS) && FS_DB_AUTOSET_SKILLS.const_defined?(:DATA)

      SKILL_HELP.each do |id, text|

        next unless FS_DB_AUTOSET_SKILLS::DATA[id].is_a?(Hash)

        FS_DB_AUTOSET_SKILLS::DATA[id][:description] = text

      end

      SKILL_NAMES.each do |id, name|

        next unless FS_DB_AUTOSET_SKILLS::DATA[id].is_a?(Hash)

        FS_DB_AUTOSET_SKILLS::DATA[id][:name] = name

      end

      SKILL_POP.each do |id, lines|

        next unless FS_DB_AUTOSET_SKILLS::DATA[id].is_a?(Hash)

        old_note = FS_DB_AUTOSET_SKILLS::DATA[id][:note].to_s

        FS_DB_AUTOSET_SKILLS::DATA[id][:note] = replace_pop_text(old_note, lines)

      end

    end



    if defined?(FS_DB_AUTOSET_WEAPONS) && FS_DB_AUTOSET_WEAPONS.const_defined?(:DATA)

      WEAPON_NAMES.each do |id, name|

        next unless FS_DB_AUTOSET_WEAPONS::DATA[id].is_a?(Hash)

        FS_DB_AUTOSET_WEAPONS::DATA[id][:name] = name

      end

      WEAPON_HELP.each do |id, text|

        next unless FS_DB_AUTOSET_WEAPONS::DATA[id].is_a?(Hash)

        FS_DB_AUTOSET_WEAPONS::DATA[id][:description] = text

      end

      WEAPON_POP.each do |id, lines|

        next unless FS_DB_AUTOSET_WEAPONS::DATA[id].is_a?(Hash)

        old_note = FS_DB_AUTOSET_WEAPONS::DATA[id][:note].to_s

        FS_DB_AUTOSET_WEAPONS::DATA[id][:note] = replace_pop_text(old_note, lines)

      end

    end



    if defined?(FS_DB_AUTOSET_ITEMS) && FS_DB_AUTOSET_ITEMS.const_defined?(:DATA)

      ITEM_HELP.each do |id, text|

        next unless FS_DB_AUTOSET_ITEMS::DATA[id].is_a?(Hash)

        FS_DB_AUTOSET_ITEMS::DATA[id][:description] = text

      end

    end



    if defined?(FS_DB_AUTOSET_ARMORS) && FS_DB_AUTOSET_ARMORS.const_defined?(:DATA)

      ARMOR_HELP.each do |id, text|

        next unless FS_DB_AUTOSET_ARMORS::DATA[id].is_a?(Hash)

        FS_DB_AUTOSET_ARMORS::DATA[id][:description] = text

      end

    end

  end



  def self.apply_external_records

    SOUL_ARMOR_HELP.each do |id, text|

      next if $data_armors == nil || $data_armors[id] == nil

      $data_armors[id].description = text

    end

  end

end



FS_AUTOSET_PLAYER_TEXT_V12.apply_data_overrides



# 武器也採用「資料庫 Pop Text 優先；沒有才用腳本預設」。

if defined?(FS_DB_AUTOSET_WEAPONS)

  module FS_DB_AUTOSET_WEAPONS

    FS_WEAPON_DATABASE_POP_TEXT_REGEX = /<pop_text\s*:\s*([^>\r\n]+)\s*>/i unless const_defined?(:FS_WEAPON_DATABASE_POP_TEXT_REGEX)



    def self.fs_weapon_database_pop_lines(id)

      return [] if $data_weapons == nil

      weapon = $data_weapons[id] rescue nil

      return [] if weapon == nil || !weapon.respond_to?(:note)

      result = []

      weapon.note.to_s.scan(FS_WEAPON_DATABASE_POP_TEXT_REGEX) do |data|

        line = data[0].to_s.strip

        next if line.empty?

        tag = "<pop_text:#{line}>"

        result.push(tag) unless result.include?(tag)

      end

      return result

    end



    class << self

      unless method_defined?(:fs_v12_note_with_normal_power_without_weapon_pop_priority)

        alias fs_v12_note_with_normal_power_without_weapon_pop_priority note_with_normal_power

      end



      def note_with_normal_power(id, note)

        scripted = fs_v12_note_with_normal_power_without_weapon_pop_priority(id, note)

        database_lines = fs_weapon_database_pop_lines(id)

        return scripted if database_lines.empty?

        base = FS_AUTOSET_PLAYER_TEXT_V12.replace_pop_text(scripted, [])

        parts = []

        parts.push(base) unless base.to_s.strip.empty?

        parts.concat(database_lines)

        return parts.join("\n")

      end

    end

  end

end



# 確保外部魂刻 Armor 600～665 也有玩家可讀說明。

if defined?(FS_DB_AUTOSET_USER_EXTENSIONS)

  module FS_DB_AUTOSET_USER_EXTENSIONS

    class << self

      unless method_defined?(:fs_v12_apply_without_player_text)

        alias fs_v12_apply_without_player_text apply

      end



      def apply

        FS_AUTOSET_PLAYER_TEXT_V12.apply_data_overrides

        fs_v12_apply_without_player_text

        FS_AUTOSET_PLAYER_TEXT_V12.apply_external_records

      end

    end

  end

end



# Help Window 目前是 544×56、內容寬約 504px、單行 24px。

# 不改高度，避免戰鬥／商店／合成畫面位移；文字過長時只把字體由 20

# 逐步縮到 16。資料庫說明仍以一行「目標＋核心效果＋條件」為原則。

module FS_HELP_WINDOW_FIT_V12

  MIN_FONT_SIZE = 16

  HORIZONTAL_PADDING = 8



  def self.fit_size(bitmap, text, max_width)

    size = Font.default_size

    bitmap.font.size = size

    while size > MIN_FONT_SIZE && bitmap.text_size(text.to_s).width > max_width

      size -= 1

      bitmap.font.size = size

    end

    return size

  end

end



class Window_Help < Window_Base

  unless method_defined?(:fs_v12_set_text_without_auto_fit)

    alias fs_v12_set_text_without_auto_fit set_text

  end



  def set_text(text, align = 0)

    old_size = self.contents.font.size

    max_width = self.width - 40 - FS_HELP_WINDOW_FIT_V12::HORIZONTAL_PADDING

    self.contents.font.size = FS_HELP_WINDOW_FIT_V12.fit_size(self.contents, text, max_width)

    fs_v12_set_text_without_auto_fit(text, align)

    self.contents.font.size = old_size

  end

end
