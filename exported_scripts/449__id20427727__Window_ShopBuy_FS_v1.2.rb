#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_ShopBuy FS v1.2
# 【用途】UI／選單元件「Window_ShopBuy FS v1.2」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_ShopBuy、FS_SHOP_GOODS
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】登記 $imported：Window ShopBuy FS。
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
# ■ Window_ShopBuy FS v1.3
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 完整替換 v1.1 版 Window_ShopBuy FS。
#
# 相容商品格式：
#   VX一般商店： [種類, ID]
#   VX第一商品： [種類, ID, 只允許購買 true/false]
#   FS自訂價格： [種類, ID, 1, 自訂價格]
#
# 注意：VX的第三欄可能是 true/false，不能直接呼叫 to_i。
# 本版只有在「陣列至少四欄，而且第三欄正好等於數字1」時，
# 才視為自訂價格。人類終於不用靠布林值冒充貨幣制度。
#==============================================================================

$imported = {} if $imported == nil
$imported["Window ShopBuy FS"] = "1.3"

module FS_SHOP_GOODS
  VERSION = "1.3"

  def self.custom_price?(row)
    return false unless row.is_a?(Array)
    return false unless row.size >= 4
    return row[2] == 1
  end

  def self.item(row)
    return nil unless row.is_a?(Array) && row.size >= 2
    id = row[1].to_i
    case row[0].to_i
    when 0
      return $data_items[id] rescue nil
    when 1
      return $data_weapons[id] rescue nil
    when 2
      return $data_armors[id] rescue nil
    end
    return nil
  end

  def self.price(row, item)
    return 0 if item == nil
    if custom_price?(row)
      return [row[3].to_i, 0].max
    end
    return [item.price.to_i, 0].max
  end
end

class Window_ShopBuy < Window_Selectable
  def initialize(x, y)
    super(x, y, 174, 224)
    @shop_goods = $game_temp.shop_goods || []
    refresh
    self.index = 0
  end

  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  # Galv METHOD 1 的規則是：游標停到商品上時，NEW標記立即消失。
  # 舊相容補丁包住的是原版 update_help，但本視窗後來完整重寫了
  # update_help，因此舊包裝被覆蓋。改在最終視窗的 update 裡處理。
  def update
    super
    return unless self.active
    target = item
    return if target == nil
    return unless defined?(FS_GALV_NEW_ITEM)
    return unless FS_GALV_NEW_ITEM.new_item?(target)
    if FS_GALV_NEW_ITEM.mark_seen(target)
      draw_item(self.index) if self.index >= 0
    end
  end

  def item
    return nil if @data == nil || self.index < 0
    return @data[self.index]
  end

  def current_good
    return nil if @goods == nil || self.index < 0
    return @goods[self.index]
  end

  def current_price
    return price(item)
  end

  def price(target = nil)
    return 0 if @prices == nil || self.index < 0
    if target == nil || self.item == target
      return @prices[self.index].to_i
    end
    index = @data.index(target)
    return target.price.to_i if index == nil
    return @prices[index].to_i
  end

  def base_price(index = self.index)
    target = @data[index] rescue nil
    return 0 if target == nil
    return target.price.to_i
  end

  def custom_price?(index = self.index)
    row = @goods[index] rescue nil
    return FS_SHOP_GOODS.custom_price?(row)
  end

  def black_market?
    return false unless $game_temp.respond_to?(:fs_shop_key)
    return $game_temp.fs_shop_key == :black_market
  end

  def remaining_stock(index = self.index)
    return 99 unless black_market?
    return 99 unless defined?(FS_BLACK_MARKET)
    row = @goods[index] rescue nil
    return 0 if row == nil
    return FS_BLACK_MARKET.remaining_for_good(row)
  end

  def max_purchase(index = self.index)
    target = @data[index] rescue nil
    return 0 if target == nil
    number = $game_party.item_number(target)
    value = @prices[index].to_i
    gold_max = value == 0 ? 99 : $game_party.gold / value
    return [gold_max, 99 - number, remaining_stock(index)].min
  end

  def refresh
    aura_clear if respond_to?(:aura_clear)
    icon_clear if respond_to?(:icon_clear)
    @data = []
    @prices = []
    @goods = []
    (@shop_goods || []).each do |row|
      target = FS_SHOP_GOODS.item(row)
      next if target == nil
      @data.push(target)
      @prices.push(FS_SHOP_GOODS.price(row, target))
      @goods.push(row)
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  def draw_item(index)
    target = @data[index]
    number = $game_party.item_number(target)
    value = @prices[index].to_i
    stock = remaining_stock(index)
    enabled = (value <= $game_party.gold && number < 99 && stock > 0)
    rect = item_rect(index)
    self.contents.font.size = 16
    self.contents.clear_rect(rect)
    draw_item_name(target, rect.x, rect.y, enabled)
    rect.width -= 4
    self.contents.font.color = enabled ? normal_color : disabled_color
    self.contents.draw_text(rect, value, 2)
    self.contents.font.color = normal_color
  end

  def update_help
    if item == nil
      @help_window.set_text("") if @help_window != nil
      return
    end
    @help_window.set_text(item.description.to_s) if @help_window != nil
  end
end
