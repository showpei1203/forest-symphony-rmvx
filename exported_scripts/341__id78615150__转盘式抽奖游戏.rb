#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：转盘式抽奖游戏
# 【用途】保留的 Runtime 元件「转盘式抽奖游戏」。
# 【主要機制】主要定義／擴充 Game_System、Change、Prize、Prize_Cam；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_System、Change、Prize、Prize_Cam、Prize_Gold、Scene_Prize、X
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Iconset、Audio/SE/#{X☆R::Change_se}、Audio/BGM/#{X☆R::Bgm_name}、Audio/SE/#{X☆R::Stop_se}、Graphics/Pictures/转盘背景、Graphics/Pictures/转盘标题、Graphics/Pictures/转盘指针、Graphics/Pictures/奖品背景、Graphics/Pictures/抽奖选择#{index}、Graphics/Pictures/金钱窗口背景。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ 转转乐（转盘式抽奖游戏）<VX> ■     -> by 芯☆淡茹水
#==============================================================================
#
# ■ 使用方法：复制该脚本，插入到 main 前，并复制范例工程 Graphics\Pictures 
#              文件夹下所有图片到目标游戏工程。
#
#    呼出抽奖场景方法：事件 -> 脚本：$scene = Scene_Prize.new
#
#==============================================================================
#
# ■ 说明： 1，该转盘抽奖为随机，制作者不能控制（作弊）。制作者需要把可以抽奖
#              的物品ID对应的填入下面的设置项即可。
#
#           2，每一盘抽奖的物品不会重复，得到的物品数量为 1 。
#
#           3，该范例仅支持 24 X 24 的物品图标 。
#
#           4，该范例的图片来源于网络。
#==============================================================================
module X☆R
#==============================================================================
# ■ 设置：↓
  #-------------------------------------------------------------------------
  # 消耗方式（0 固定金钱； 1 变量指定金钱； 2 消耗物品<数量为1>）。
  Consumption_mode = 2
  #-------------------------------------------------------------------------
  # 消耗方式为 0 时，抽奖一次需要的金钱。
  Need_gold = 500
  #-------------------------------------------------------------------------
  # 消耗方式为 1 时，抽奖一次需要的指定金钱的变量ID。
  Need_gold_var = 10
  #-------------------------------------------------------------------------
  # 消耗方式为 2 时，抽奖一次需要的物品ID。
  Need_item_id = 21
  #-------------------------------------------------------------------------
  # 场景BGM(不需要就写空白引号 "" )。
  Bgm_name = ""
  #-------------------------------------------------------------------------
  # 转针转动时播放的SE。
  Change_se = "Cursor"  
  #-------------------------------------------------------------------------
  # 转针停止时播放的SE。
  Stop_se = "Item1"  
  #-------------------------------------------------------------------------
  # 可以出现在转盘里的普通物品ID。
  Prize_items1 = [1,2,4,5,9,11,12,13,14,15,16]  
  #-------------------------------------------------------------------------
  # 可以出现在转盘里的珍贵物品ID。
  Prize_items2 = [3,6,10,17,18,19,20]
  #-------------------------------------------------------------------------
  # 可以出现在转盘里的普通武器ID。
  Prize_weapons1 = [1,2,3,5,6,7,9,10,11,13,14,15,17,18,19]
  #-------------------------------------------------------------------------
  # 可以出现在转盘里的珍贵武器ID。
  Prize_weapons2 = [4,8,12,16,20]  
  #-------------------------------------------------------------------------
  # 可以出现在转盘里的普通防具ID。
  Prize_armors1 = [1,2,3,5,6,7,9,10,11,13,14,15,17,18,19]  
  #-------------------------------------------------------------------------
  # 可以出现在转盘里的珍贵防具ID。
  Prize_armors2 = [4,8,12,16,20,25,26,27,28,29,30]  
  #-------------------------------------------------------------------------
  # 物品在转盘里出现的几率（百分比）。
  Item_rate = 60
  #-------------------------------------------------------------------------
  # 珍贵物品出现的概率为总物品数的（百分比）。
  Precious_item_rate = 20  
  #-------------------------------------------------------------------------
  # 武器在转盘里出现的几率（百分比）。
  Weapon_rate = 20
  #-------------------------------------------------------------------------
  # 珍贵武器出现的概率为总武器数的（百分比）。
  Precious_weapon_rate = 20  
  #-------------------------------------------------------------------------
  # 防具在转盘里出现的几率（百分比）。
  Armor_rate = 20  
  #-------------------------------------------------------------------------
  # 珍贵防具出现的概率为总防具数的（百分比）。
  Precious_armor_rate = 20
  #==========================================================================
  #==========================================================================
  # ■ 脚本正文 ↓
  #==========================================================================
  def self.can_start?
    case Consumption_mode
    when 0 :return ($game_party.gold >= Need_gold)
    when 1 :return ($game_party.gold >= $game_variables[Need_gold_var])
    when 2 :return ($game_party.item_number($data_items[Need_item_id]) >= 1)
    end
  end
  #-------------------------------------------------------------------------
  def self.consumption
    case Consumption_mode
    when 0 :$game_party.lose_gold(Need_gold)
    when 1 :$game_party.lose_gold($game_variables[Need_gold_var])
    when 2 :$game_party.lose_item($data_items[Need_item_id], 1)
    end
  end
end 
#==============================================================================
class Game_System
  attr_accessor :prize_items
end
#==============================================================================
class Change < Sprite
  #-------------------------------------------------------------------------
  def initialize
    super()
    self.bitmap = Bitmap.new("Graphics/Pictures/转盘背景")
    self.x = 0; self.y = 10; self.z = 500
    @tit = Sprite.new
    @tit.bitmap = Bitmap.new("Graphics/Pictures/转盘标题")
    @tit.x = self.x + 50; @tit.y = self.y + 24; @tit.z = 600
    @item_sprite = []
    for i in 0..7
      @item_sprite[i] = Sprite.new
      @item_sprite[i].bitmap = Bitmap.new(24,24)
      @item_sprite[i].x, @item_sprite[i].y = get_item_place(i)
      @item_sprite[i].x += self.x; @item_sprite[i].y += self.y
      @item_sprite[i].z = 600
    end
    @zhen = Sprite.new
    @zhen.bitmap = Bitmap.new("Graphics/Pictures/转盘指针")
    @zhen.ox = @zhen.bitmap.width / 2; @zhen.oy = @zhen.bitmap.height / 2
    @zhen.x = self.x + 176; @zhen.y = self.y + 230; @zhen.z = 700
    @zhen.angle = 337.5
    @item_index = 0
  end
  #-------------------------------------------------------------------------
  def dispose
    @item_sprite.each{|w| w.bitmap.dispose; w.dispose}
    @tit.bitmap.dispose
    @zhen.bitmap.dispose
    self.bitmap.dispose
    @tit.dispose
    @zhen.dispose
    super
  end
  #-------------------------------------------------------------------------
  def get_item_place(index)
    case index
    when 0 :return 195, 146
    when 1 :return 238, 186
    when 2 :return 242, 248
    when 3 :return 192, 290
    when 4 :return 138, 290
    when 5 :return  90, 247
    when 6 :return  94, 190
    when 7 :return 134, 150
    end
  end
  #-------------------------------------------------------------------------
  def item_index
    return  @item_index
  end
  #-------------------------------------------------------------------------
  def set_items(items)
    @item_sprite.each{|w| w.bitmap.clear}
    return if items == []
    for i in 0..7
      item = items[i]
      bitmap = Cache.system("Iconset")
      rect = Rect.new(item.icon_index % 16 * 24, item.icon_index / 16 * 24, 24, 24)
      @item_sprite[i].bitmap.blt(0, 0, bitmap, rect)
    end
  end
  #-------------------------------------------------------------------------
  def zhuan
    Audio.se_play("Audio/SE/#{X☆R::Change_se}", 100, 100)
    @zhen.angle -= 45
    @item_index = (@item_index+1) % 8
  end
end
#==============================================================================
class Prize < Sprite
  #-------------------------------------------------------------------------
  def initialize
    super()
    self.x = 350; self.y = 10; self.z = 500
    @messages = []
  end
  #-------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end
  #-------------------------------------------------------------------------
  def add_mess(txt)
    @messages.unshift(txt)
  end
  #-------------------------------------------------------------------------
  def set_messages
    self.bitmap.dispose if self.bitmap
    self.bitmap = Bitmap.new("Graphics/Pictures/奖品背景")
    return if @messages == []
    x = 14; y = 52
    self.bitmap.font.bold = true
    for i in 0...@messages.size
      self.bitmap.font.size = (i == 0 ? 20 : 16)
      txt = @messages[i]
      if i == 0
        self.bitmap.font.color = Color.new(0,0,0)
        self.bitmap.draw_text(x-1, y-1, 120, 22, txt)
        self.bitmap.draw_text(x-1, y+1, 120, 22, txt)
        self.bitmap.draw_text(x-1, y-1, 120, 22, txt)
        self.bitmap.draw_text(x+1, y-1, 120, 22, txt)
      end
      self.bitmap.font.color = (i == 0 ? Color.new(255,120,0) : Color.new(255,255,255))
      self.bitmap.draw_text(x, y, 120, 22, txt)
      y += (i == 0 ? 32 : 24)
    end
  end
  #-------------------------------------------------------------------------
  def update
    super
    @messages.pop until @messages.size <= 9 
    if @data_mes != @messages
      @data_mes = @messages.clone
      set_messages
    end
  end
end
#==============================================================================
class Prize_Cam < Window_Selectable
  #--------------------------------------------------------------------------
  def initialize
    super(334, 283, 182, 112)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    @column_max = 1
    @item_max = 2
    self.index = 0
  end
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    bitmap = Bitmap.new("Graphics/Pictures/抽奖选择#{index}")
    self.contents.blt(0, 0, bitmap, Rect.new(0, 0, 150, 80))
  end
  #--------------------------------------------------------------------------
  def update
    super
    if @data_index != index
      @data_index = index
      refresh
    end
  end
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(8, index*32+8, 134, 32)
  end
end
#==============================================================================
class Prize_Gold < Sprite
  #-------------------------------------------------------------------------
  def initialize
    super()
    self.x = 349; self.y = 378; self.z = 500
  end
  #-------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end
  #-------------------------------------------------------------------------
  def set_show
    self.bitmap.dispose if self.bitmap
    self.bitmap = Bitmap.new("Graphics/Pictures/金钱窗口背景")
    self.bitmap.font.bold = true
    self.bitmap.font.color = Color.new(255,255,255)
    if X☆R::Consumption_mode == 2
      self.bitmap.font.size = 18
      item = $data_items[X☆R::Need_item_id]
      bitmap = Cache.system("Iconset")
      rect = Rect.new(item.icon_index % 16 * 24, item.icon_index / 16 * 24, 24, 24)
      self.bitmap.blt(8, 5, bitmap, rect)
      txt = "#{item.name} X #{$game_party.item_number(item)}"
      self.bitmap.draw_text(36, 2, 110, 32, txt)
    else
      self.bitmap.font.size = 20
      self.bitmap.draw_text(0, 2, 100, 32, $game_party.gold.to_s, 2)
      self.bitmap.font.color = Color.new(192, 224, 255)
      self.bitmap.draw_text(102, 2, 48, 32, $data_system.terms.gold, 1)
    end
  end
  #-------------------------------------------------------------------------
  def update
    super
    if X☆R::Consumption_mode == 2
      if @data_num != $game_party.item_number($data_items[X☆R::Need_item_id])
        @data_num = $game_party.item_number($data_items[X☆R::Need_item_id])
        set_show
      end
    else
      if @data_gold != $game_party.gold
        @data_gold = $game_party.gold
        set_show
      end
    end
  end
end
#==============================================================================
class Scene_Prize
  #--------------------------------------------------------------------------
  def main
    @spriteset = Spriteset_Map.new
    @zhuan = Change.new
    @prize = Prize.new
    @command = Prize_Cam.new
    @gold = Prize_Gold.new
    @wait_count = 0
    @zhuan_count = 0
    @count = 0
    @speed = 1
    set_prize_items 
    if X☆R::Bgm_name != ""
      Audio.bgm_play("Audio/BGM/#{X☆R::Bgm_name}", 100, 100)
    end
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    @zhuan.dispose
    @prize.dispose
    @command.dispose
    @gold.dispose
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  def update
    @zhuan.update
    @prize.update
    @command.update
    @gold.update
    if @wait_count > 0
      @wait_count -= 1
      return
    end
    if @zhuan_count > 0
      @mess = ""
      update_zhuan
      return
    end
    if @command.active and Input.trigger?(Input::C)
      case @command.index
      when 0
        unless X☆R::can_start?
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        X☆R::consumption
        set_prize_items if @count > 0
        @zhuan_count = rand(150) + 150
      when 1
        Sound.play_cancel
        $scene = Scene_Map.new
      end
    end
  end
  #--------------------------------------------------------------------------
  def update_zhuan
    if @zhuan_count % @speed  == 0
      @speed = [@speed + [(100 - @zhuan_count) / 20, 0].max, 6].min
      @zhuan.zhuan
    end
    @zhuan_count -= 1
    if @zhuan_count == 0
      Audio.se_play("Audio/SE/#{X☆R::Stop_se}", 100, 100)
      @speed = 1
      @count += 1
      get_prize
      @wait_count = 60
    end
  end
  #--------------------------------------------------------------------------
  def get_prize
    item = @prize_items[@zhuan.item_index]
    return if item.nil?
    $game_party.gain_item(item, 1)
    $game_system.prize_items = []
    @prize.add_mess(item.name)
  end
  #--------------------------------------------------------------------------
  def set_prize_items
    @prize_items = []
    if $game_system.prize_items != nil and $game_system.prize_items != []
      @prize_items = $game_system.prize_items.clone
    else
      set_item_mod until @prize_items.size >= 8 
      $game_system.prize_items = @prize_items.clone
    end
    @zhuan.set_items(@prize_items)
  end
  #--------------------------------------------------------------------------
  def set_item_mod
    case rand (100)
    when 0...X☆R::Item_rate
      if rand (100) < X☆R::Precious_item_rate
        mod = X☆R::Prize_items1 + X☆R::Prize_items2
      else
        mod = X☆R::Prize_items1.clone
      end
      item = $data_items[mod[rand(mod.size)]]
      @prize_items << item unless @prize_items.include?(item)
    when X☆R::Item_rate...(X☆R::Item_rate + X☆R::Weapon_rate)
      if rand (100) < X☆R::Precious_weapon_rate
        mod = X☆R::Prize_weapons1 + X☆R::Prize_weapons2
      else
        mod = X☆R::Prize_weapons1.clone
      end
      item = $data_weapons[mod[rand(mod.size)]]
      @prize_items << item unless @prize_items.include?(item)
    else
      if rand (100) < X☆R::Precious_armor_rate
        mod = X☆R::Prize_armors1 + X☆R::Prize_armors2
      else
        mod = X☆R::Prize_armors1.clone
      end
      item = $data_armors[mod[rand(mod.size)]]
      @prize_items << item unless @prize_items.include?(item)
    end
  end
end
#==============================================================================