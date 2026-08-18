#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：BarterShop_Core v1.0｜交換商店
# 【來源】Omegas7 (J.V.Wong.)，Barter shop system v1.0（2010-04-20），原站 omega-dev.net；原作者 Credits／網址保留。
# 【用途】不用一般金錢價格，而以玩家提供的 Item／Weapon／Armor／Gold「價值」交換 Vendor 庫存。Vendor 會真的失去被換走的物品並取得玩家提供物。
# 【主要資料】`BARTER::Vendors[id]` 定義初始庫存；格式支援 `Gold,N`、`Item,ID,N`、`Weapon,ID,N`、`Armor,ID,N`。目前內建 Vendor 0/1。
# 【事件／腳本入口】既有專案事件使用 `Barter.new(vendor_id)` 開啟交換商店；補 Vendor 庫存使用 `BARTER.addItemForVendor(vendorID, string)`，例如 `BARTER.addItemForVendor(0,"Item,6,3")`。
# 【可交換物】目前玩家物品列表實際以 Note 含 `<BARTER>` 才加入；舊原手冊提到 `<NOBARTER>`，但本專案 Runtime 的 `<NOBARTER>` 判定已被註解，維護時以實際程式為準。
# 【設定】`BG="BarterBG"`（Graphics/System）、`ShowWindows=false`、`Gold_Icon=205`、`Gold_Description`。BG 留空可不使用背景圖。
# 【保存資料】Game_Party#vendors 保存每個 Vendor 的動態庫存，因此改 Vendor 結構時要測舊存檔。
# 【Load Order】alias Game_Party#initialize 建立 vendors；屬 Economy/Shop 基礎系統。後方 FS Economy/Shop 整合仍可能呼叫它，不可因已有一般 Shop 就刪除。
# 【相關素材】Graphics/System/BarterBG（若 BG 非空）。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
# =============================================================================
# =============================================================================
# Author: Omegas7 (J.V.Wong.)
# Version: 1.0    (20/04/10)
# Site: http://www.omega-dev.net/forums
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 可交換物：有 <BARTER> 才可以放進交換清單
# -----------------------------------------------------------------------------
#                                                          <NOBARTER>
#                    BARTER.addItemForVendor(vendorID,string)
# -----------------------------------------------------------------------------
# =============================================================================

module BARTER
  
  BG = "BarterBG" # 詳見頁首繁中說明
  ShowWindows = false # 詳見頁首繁中說明
  Gold_Icon = 205 # 詳見頁首繁中說明
  Gold_Description = "Some gold coins." # 詳見頁首繁中說明
  
  Vendors = [] # 詳見頁首繁中說明
  
  
  Vendors[0] = ["weapon,8,10","Weapon,13,5","Armor,2,5","armor,7,10"]
  Vendors[1] = ["Gold,3500","Item,6,10","Item,8,10","Item,9,5","Item,15,5"]
  
  
  
  
  
  
  def self.addItemForVendor(vendorID,s)
    if s =~ /\s*(\w+)\s*,\s*(\d+)\s*(,(\s*(\d+)\s*)|)/
      case $1.downcase
      when "gold"
        item = "GOLD"
      when "item"
        item = $data_items[$2.to_i]
      when "weapon"
        item = $data_weapons[$2.to_i]
      when "armor"
        item = $data_armors[$2.to_i]
      end
      f = false
      for obj in $game_party.vendors[vendorID]
        if obj[0] == item
          if obj[0] == "GOLD"
            obj[1] += $2.to_i
          else
            obj[1] += $4.to_i
          end
          f = true
        end
      end
      if !f
        if item == "GOLD"
          $game_party.vendors[vendorID].push([item,$2.to_i])
        else
          $game_party.vendors[vendorID].push([item,$4.to_i])
        end
      end
    end
  end
end

class Game_Party < Game_Unit
  attr_accessor :vendors
  alias omega_barter_initialize initialize
  def initialize
    omega_barter_initialize
    @vendors = []
    for i in 0...BARTER::Vendors.size
      @vendors[i] = []
      for s in BARTER::Vendors[i]
        if s =~ /\s*(\w+)\s*,\s*(\d+)\s*(,(\s*(\d+)\s*)|)/
          case $1.downcase
          when "gold"
            @vendors[i].push(["GOLD",$2.to_i])
          when "item"
            @vendors[i].push([$data_items[$2.to_i],$4.to_i])
          when "weapon"
            @vendors[i].push([$data_weapons[$2.to_i],$4.to_i])
          when "armor"
            @vendors[i].push([$data_armors[$2.to_i],$4.to_i])
          end
        end
      end
    end
  end
end

class Barter < Scene_Base
  attr_accessor :help
  attr_accessor :barterValuePlayer
  attr_accessor :barterValueVendor
  def initialize(id)
    @id = id
  end
  def start
    if !BARTER::BG.empty?
      @bg = Sprite_Base.new
      @bg.bitmap = Cache.system(BARTER::BG)
      @bg.z = 0
    end
    @help = Window_Help.new
    @help.contents.font.size = 18
    @inventory = BarterList.new("PLAYER")
    @vendor = BarterList.new("VENDOR",@id)
    @playerOffer = OfferList.new("PLAYER")
    @vendorOffer = OfferList.new("VENDOR")
    @barterValuePlayer = BarterValue.new(150,416 - 60)
    @barterValueVendor = BarterValue.new(544 - 150 - (244/2),416 - 60)
    @inventory.send_help
    @focus = 1
    @notification = nil
    @barterAmount = nil
    @limit = 0
    @chosenAmount = 0
    @endMenu = nil
    if !BARTER::ShowWindows
      @help.opacity = 0
    end
  end
  def update
    if @endMenu != nil
      @endMenu.update
      return
    end
    if @barterAmount != nil
      @barterAmount.update
      return
    end
    if @notification.nil?
      if Input.trigger?(Input::B)
        @endMenu = EndBarterMenu.new
      end
      if Input.trigger?(Input::RIGHT)
        @focus += 1
        @focus = 1 if @focus > 4
      end
      if Input.trigger?(Input::LEFT)
        @focus -= 1
        @focus = 4 if @focus < 1
      end
      if Input.trigger?(Input::C)
        case @focus
        when 1
          if !@inventory.hasSomething?
            Sound.play_buzzer
            return
          end
          @limit = @inventory.getLimit
          @notification = BarterNotification.new("增加這項你的商品？")
        when 2
          if !@playerOffer.hasSomething?
            Sound.play_buzzer
            return
          end
          @limit = @playerOffer.getLimit
          @notification = BarterNotification.new("移除這項你的商品？")
        when 3
          if !@vendorOffer.hasSomething?
            Sound.play_buzzer
            return
          end
          @limit = @vendorOffer.getLimit
          @notification = BarterNotification.new("移除這項店家的商品？")
        when 4
          if !@vendor.hasSomething?
            Sound.play_buzzer
            return
          end
          @limit = @vendor.getLimit
          @notification = BarterNotification.new("增加這項店家的商品？")
        end
      end
      case @focus
      when 1
        @inventory.update
        @inventory.send_help
      when 2
        @playerOffer.update
        @playerOffer.send_help
      when 3
        @vendorOffer.update
        @vendorOffer.send_help
      when 4
        @vendor.update
        @vendor.send_help
      end
    else
      @notification.command.update
      if Input.trigger?(Input::C)
        case @focus
        when 1,2,3,4
          case @notification.command.index
          when 0
            @barterAmount = BarterAmount.new(@limit)
            @notification.finish
            @notification = nil
          when 1
            @notification.finish
            @notification = nil
          end
        end
      end
    end
  end
  def acceptedAmount(amount)
    @chosenAmount = amount
    transferItems
    @barterAmount.finish
    @barterAmount = nil
  end
  def canceledAmount
    @barterAmount.finish
    @barterAmount = nil
  end
  def transferItems
    case @focus
    when 1
      @playerOffer.addItems(@inventory.getItem,@chosenAmount)
      @inventory.removeItems(@chosenAmount)
    when 2
      @inventory.addItems(@playerOffer.getItem,@chosenAmount)
      @playerOffer.removeItems(@chosenAmount)
    when 3
      @vendor.addItems(@vendorOffer.getItem,@chosenAmount)
      @vendorOffer.removeItems(@chosenAmount)
    when 4
      @vendorOffer.addItems(@vendor.getItem,@chosenAmount)
      @vendor.removeItems(@chosenAmount)
    end
  end
  def returnFromEnd
    @endMenu.finish
    @endMenu = nil
  end
  def executeTransaction
    playerItems = @playerOffer.allItems
    vendorItems = @vendorOffer.allItems
    for item in vendorItems
      if item[0] == "GOLD"
        $game_party.gain_gold(item[1])
      else
        $game_party.gain_item(item[0],item[1])
      end
    end
    $game_party.vendors[@id].compact!
    for item in playerItems
      if item[0] == "GOLD"
        $game_party.gain_gold(-item[1])
        @vendor.addItems(item,item[1])
      else
        $game_party.lose_item(item[0],item[1])
        @vendor.addItems(item,item[1])
      end
    end
    finish
  end
  def finish
    @bg.dispose if @bg != nil
    @help.dispose
    @inventory.finish
    @vendor.finish
    @playerOffer.finish
    @vendorOffer.finish
    @barterValuePlayer.finish
    @barterValueVendor.finish
    if @notification != nil
      @notification.finish
      @notification = nil
    end
    if @barterValue != nil
      @barterValue.finish
      @barterValue = nil
    end
    if @endMenu != nil
      @endMenu.finish
      @endMenu = nil
    end
      #################恢復原售價
      Game_Interpreter_Self.new(12)
      #################
    $scene = Scene_Map.new
  end
  def canAccept?
    return @barterValuePlayer.value > @barterValueVendor.value
  end
  def vendorRecover
    vendorItems = @vendorOffer.allItems
    for item in vendorItems
      @vendor.addItems(item,item[1])
    end
  end
end

class EndBarterMenu
  def initialize
    @menu = Window_Command.new(180,["同意交換","繼續交換","離開"])
    @menu.x = (544/2) - (180/2)
    @menu.y = 170
    @menu.draw_item(0,false) if !$scene.canAccept?
  end
  def update
    @menu.update
    if Input.trigger?(Input::C)
      case @menu.index
      when 0
        if !$scene.canAccept?
          Sound.play_buzzer
          return
        end
        $scene.executeTransaction
      when 1
        $scene.returnFromEnd
      when 2
        $scene.vendorRecover
        
        $scene.finish
        
      end
    end
  end
  def finish
    @menu.dispose
  end
end

class BarterAmount
  def initialize(limit)
    @window = Window_Base.new((544/2) - (200/2),150,200,50)
    @window.contents.font.size = 16
    @menu = Window_Command.new(100,["同意","取消"])
    @menu.contents.font.size = 16
    @menu.x,@menu.y = (544/2) - (100/2),200
    @menu.refresh
    @amount = 1
    @limit = limit
    refresh
  end
  def refresh
    @window.contents.clear
    @window.contents.draw_text(0,0,@window.width - 32,16,"< [ #{@amount} ] >",1)
  end
  def update
    @menu.update
    if Input.repeat?(Input::Y)
      @amount += 100
      @amount = @limit if @amount > @limit
      refresh
    end
    if Input.repeat?(Input::X)
      @amount -= 100
      @amount = @limit if @amount < 1
      refresh
    end
    if Input.repeat?(Input::R)
      @amount += 10
      @amount = @limit if @amount > @limit
      refresh
    end
    if Input.repeat?(Input::L)
      @amount -= 10
      @amount = @limit if @amount < 1
      refresh
    end
    if Input.repeat?(Input::RIGHT)
      @amount += 1
      @amount = @limit if @amount > @limit
      refresh
    end
    if Input.repeat?(Input::LEFT)
      @amount -= 1
      @amount = 1 if @amount < 1
      refresh
    end
    if Input.trigger?(Input::C)
      case @menu.index
      when 0
        $scene.acceptedAmount(@amount)
      when 1
        $scene.canceledAmount
      end
    end
  end
  def finish
    @window.dispose
    @menu.dispose
  end
end

class BarterNotification
  attr_reader :command
  def initialize(txt)
    @window = Window_Base.new(100,150,544 - 200,50)
    @window.contents.font.size = 17
    @window.contents.draw_text(0,0,@window.width - 16,17,txt)
    @command = Window_Command.new(144,['是','否'])
    @command.x,@command.y = 200,200
    @command.contents.font.size = 16
    @command.refresh
  end
  def finish
    @window.dispose
    @command.dispose
  end
end

class BarterValue
  attr_accessor :value
  def initialize(x,y)
    @value = 0
    @window = Window_Base.new(x,y,244/2,60)
    @window.contents.font.size = 16
    if !BARTER::ShowWindows
      @window.opacity = 0
    end
    refresh
  end
  def refresh
    @window.contents.clear
    a = ["總價值:","#{@value}"]
    @window.contents.draw_text(0,-4+4,200,16,a[0])
    @window.contents.draw_text(30,12,200,16,a[1])
  end
  def finish
    @window.dispose
  end
end

class OfferList
  def initialize(source)
    @items = []
    @strings = []
    @icons = []
    @source = source
    @strings.push("無")
    @menu = Window_Command_Icon.new(244/2,@strings,@icons)
    @menu.contents.font.size = 16
    @menu.refresh
    if source == "PLAYER"
      @menu.x = 150
    else
      @menu.x = 544 - 150 - (244/2)
    end
    @menu.y = 54
    @menu.height = 416 - 80 - 54 + 20
    @index = @menu.index
    if !BARTER::ShowWindows
      @menu.opacity = 0
    end
  end
  def update
    @menu.update
    if @index != @menu.index
      @index = @menu.index
      send_help
    end
  end
  def addItems(item,amount)
    f = false
    for i in 0...@items.size
      break if @strings[0] == "無"
      if @items[i][0] == item[0]
        @items[i][1] += amount
        @strings[i] = "          : #{@items[i][1]}"
        if @items[i][0] == "GOLD"
          @icons[i] = BARTER::Gold_Icon
        else
          @icons[i] = @items[i][0].icon_index
        end
        f = true
        break
      end
    end
    if !f
      @items.push([item[0],amount])
      @strings[@items.size - 1] = "          : #{@items[@items.size - 1][1]}"
      if @items[@items.size - 1][0] == "GOLD"
        @icons[@items.size - 1] = BARTER::Gold_Icon
      else
        @icons[@items.size - 1] = @items[@items.size - 1][0].icon_index
      end
    end
    @menu.dispose
    @menu = Window_Command_Icon.new(244/2,@strings,@icons)
    @menu.contents.font.size = 16
    @menu.refresh
    if @source == "PLAYER"
      @menu.x = 150
    else
      @menu.x = 544 - 150 - (244/2)
    end
    @menu.y = 54
    @menu.height = 416 - 80 - 54 + 20
    @index = @menu.index
    send_value
    if !BARTER::ShowWindows
      @menu.opacity = 0
    end
  end
  def removeItems(amount)
    @items[@menu.index][1] -= amount
    @strings[@menu.index] = "          : #{@items[@menu.index][1]}"
    if @items[@menu.index][0] == "GOLD"
      @icons[@menu.index] = BARTER::Gold_Icon
    else
      @icons[@menu.index] = @items[@menu.index][0].icon_index
    end
    if @items[@menu.index][1] <= 0
      @items[@menu.index] = nil
      @strings[@menu.index] = nil
      @icons[@menu.index] = nil
      @items.compact!
      @strings.compact!
      @icons.compact!
    end
    if @items.empty?
      @strings = ["無"]
    end
    @menu.dispose
    @menu = Window_Command_Icon.new(244/2,@strings,@icons)
    @menu.contents.font.size = 16
    @menu.refresh
    if @source == "PLAYER"
      @menu.x = 150
    else
      @menu.x = 544 - 150 - (244/2)
    end
    @menu.y = 54
    @menu.height = 416 - 80 - 54 + 20
    @index = @menu.index
    send_value
    if !BARTER::ShowWindows
      @menu.opacity = 0
    end
  end
  def send_value
    v = 0
    if !@items.empty?
      for i in 0...@items.size
        if @items[i][0] == "GOLD"
          v += @items[i][1]
        else
          v += @items[i][0].price * @items[i][1]
        end
      end
    end
    case @source
    when "PLAYER"
      obj = $scene.barterValuePlayer
      obj.value = v
      obj.refresh
    when "VENDOR"
      obj = $scene.barterValueVendor
      obj.value = v
      obj.refresh
    end
  end
  def send_help
    if @strings[0] != "無"
      if @items[@menu.index][0] == "GOLD"
        $scene.help.set_text(BARTER::Gold_Description)
        return
      end
      $scene.help.set_text(@items[@menu.index][0].description)
    else
      $scene.help.set_text("")
    end
  end
  def getLimit
    return @items[@menu.index][1]
  end
  def getItem
    return @items[@menu.index]
  end
  def hasSomething?
    return @strings[0] != "無"
  end
  def allItems
    return @items
  end
  def finish
    @menu.dispose
  end
end

class BarterList
  def initialize(source,vendorID = 0)
    @items = []
    @strings = []
    @icons = []
    @source = source
    @vendorID = vendorID
    generate_items
    @menu = Window_Command_Icon.new(150,@strings,@icons)
    @menu.contents.font.size = 16
    @menu.refresh
    if source == "VENDOR"
      @menu.x = 544 - 150
    end
    @menu.y = 54
    @menu.height = 416 - 54
    @index = @menu.index
    if !BARTER::ShowWindows
      @menu.opacity = 0
    end
  end
  def update
    @menu.update
    if @index != @menu.index
      @index = @menu.index
      send_help
    end
  end
  def addItems(item,amount)
    f = false
    for i in 0...@items.size
      break if @strings[0] == "無"
      if @items[i][0] == item[0]
        @items[i][1] += amount
        @strings[i] = "          : #{@items[i][1]}"
        if @items[i][0] == "GOLD"
          @icons[i] = BARTER::Gold_Icon
        else
          @icons[i] = @items[i][0].icon_index
        end
        f = true
        break
      end
    end
    if !f
      @items.push([item[0],amount])
      @strings[@items.size - 1] = "          : #{@items[@items.size - 1][1]}"
      if @items[@items.size - 1][0] == "GOLD"
        @icons[@items.size - 1] = BARTER::Gold_Icon
      else
        @icons[@items.size - 1] = @items[@items.size - 1][0].icon_index
      end
    end
    @menu.dispose
    @menu = Window_Command_Icon.new(150,@strings,@icons)
    @menu.contents.font.size = 16
    @menu.refresh
    if @source == "VENDOR"
      @menu.x = 544 - 150
    end
    @menu.y = 54
    @menu.height = 416 - 54
    @index = @menu.index
    if !BARTER::ShowWindows
      @menu.opacity = 0
    end
  end
  def removeItems(amount)
    @items[@menu.index][1] -= amount
    @strings[@menu.index] = "          : #{@items[@menu.index][1]}"
    if @items[@menu.index][0] == "GOLD"
      @icons[@menu.index] = BARTER::Gold_Icon
    else
      @icons[@menu.index] = @items[@menu.index][0].icon_index
    end
    if @items[@menu.index][1] <= 0
      @items[@menu.index] = nil
      @strings[@menu.index] = nil
      @icons[@menu.index] = nil
      @items.compact!
      @strings.compact!
      @icons.compact!
    end
    if @items.empty?
      @strings = ["無"]
    end
    @menu.dispose
    @menu = Window_Command_Icon.new(150,@strings,@icons)
    @menu.contents.font.size = 16
    @menu.refresh
    if @source == "VENDOR"
      @menu.x = 544 - 150
    end
    @menu.y = 54
    @menu.height = 416 - 54
    @index = @menu.index
    if !BARTER::ShowWindows
      @menu.opacity = 0
    end
  end
  def send_help
    if !@items.empty?
      if @items[@menu.index][0] == "GOLD"
        $scene.help.set_text(BARTER::Gold_Description)
        return
      end
      $scene.help.set_text(@items[@menu.index][0].description)
    else
      $scene.help.set_text("")
    end
  end
  def generate_items
    case @source
    when "PLAYER"
      if $game_party.gold > 0
      end
      for item in $game_party.items
        if item.note.include?("<BARTER>")
        @items.push([item,$game_party.item_number(item)])
        @strings.push("          : #{$game_party.item_number(item)}")
        @icons.push(item.icon_index)
        end
      end
    when "VENDOR"
      @items = $game_party.vendors[@vendorID]
      for item in @items
        if item[0] == "GOLD"
          @strings.push("          : #{item[1]}")
          @icons.push(BARTER::Gold_Icon)
          next
        end
        @strings.push("           : #{item[1]}")
        @icons.push(item[0].icon_index)
      end
    end
    if @items.empty?
      @strings = ["無"]
    end
  end
  def getLimit
    return @items[@menu.index][1]
  end
  def getItem
    return @items[@menu.index]
  end
  def hasSomething?
    return @strings[0] != "無"
  end
  def finish
    @menu.dispose
  end
end

class Window_Command_Icon < Window_Selectable
  attr_accessor   :commands
  attr_accessor   :icons
  def initialize(width, commands, icons, column_max = 1, row_max = 0, spacing = 32)
    if row_max == 0
      row_max = (commands.size + column_max - 1) / column_max
    end
    super(0, 0, width, row_max * WLH + 32, spacing)
    @commands = commands
    @item_max = commands.size
    @column_max = column_max
    @icons = icons
    refresh
    self.index = 0
  end
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index])
    return if @commands[0] == "無"
    self.draw_icon(@icons[index],rect.x,rect.y)
    #contents.draw_text(x + 24, y, 172, WLH, item.name)
    #self.draw_item_name(@icons[index], rect.x, rect.y)
  end
end
