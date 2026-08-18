#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Shop FS v1.2
# 【用途】物品／商店元件「Scene_Shop FS v1.2」。
# 【主要機制】處理物品資料、交易、製作、庫存或 UI；事件入口與資料庫設定需要一起確認。
# 【主要影響】Scene_Shop
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】登記 $imported：Scene Shop FS。
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
# ■ Scene_Shop FS v1.4
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 完整替換 v1.1 版 Scene_Shop FS。
#
# 保留目前544×416商店版面，並整合：
#   - VX一般商店事件
#   - FS區域自訂價格
#   - 黑市章節限量庫存
#   - KGC Large Party 的狀態視窗捲動鍵
#   - 鍵盤A（Input::X）的能力／數值詳情切換
#
# 已移除離開商店時強制執行 Common Event 12 的舊價格還原行為。
#==============================================================================

$imported = {} if $imported == nil
$imported["Scene Shop FS"] = "1.4"

class Scene_Shop < Scene_Base
  def start
    super
    create_menu_background
    create_command_window
    @title_window = Window_Base.new(0, 0, @command_window.x, 56)
    @title_window.contents.draw_text(0, 0, @title_window.width - 32, 24,
      $game_temp.shop_name.to_s, 1)
    @help_window = Window_Help.new
    @help_window.contents.draw_text(0, 0, 512, 24,
      $game_temp.shop_word.to_s)
    @help_window.y = 56
    @help_window.opacity = 255
    @gold_window = Window_Gold.new(
      FS_SHOP_ALL_PARTY::GOLD_WINDOW_X,
      FS_SHOP_ALL_PARTY::BOTTOM_WINDOW_Y)
    @gold_window.width =
      FS_SHOP_ALL_PARTY::GOLD_WINDOW_WIDTH
    @gold_window.height =
      FS_SHOP_ALL_PARTY::BOTTOM_WINDOW_HEIGHT
    @gold_window.create_contents
    @gold_window.refresh
    @dummy_window = Window_Base.new(0, 112, 544, 304)
    @dummy_window.opacity = 0
    @buy_window = Window_ShopBuy.new(0, 112)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    @sell_window = Window_ShopSell.new(0, 112, 544, 224)
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    @number_window = Window_ShopNumber.new(0, 112)
    @number_window.active = false
    @number_window.visible = false
    @status_window = Window_ShopStatus.new(304, 112)
    @status_window.visible = false
    if @status_window.respond_to?(:fs_shop_buy_window=)
      @status_window.fs_shop_buy_window = @buy_window
    end
    fs_align_bottom_windows
  end

  #--------------------------------------------------------------------------
  # ● 對齊底部提示窗與金錢窗
  #--------------------------------------------------------------------------
  # 金錢窗若被其他舊商店腳本移回y=336，會在同一幀修正回y=348。
  def fs_align_bottom_windows
    return if @gold_window == nil || @gold_window.disposed?

    changed_size = false
    if @gold_window.width != FS_SHOP_ALL_PARTY::GOLD_WINDOW_WIDTH
      @gold_window.width = FS_SHOP_ALL_PARTY::GOLD_WINDOW_WIDTH
      changed_size = true
    end
    if @gold_window.height != FS_SHOP_ALL_PARTY::BOTTOM_WINDOW_HEIGHT
      @gold_window.height = FS_SHOP_ALL_PARTY::BOTTOM_WINDOW_HEIGHT
      changed_size = true
    end

    @gold_window.x = FS_SHOP_ALL_PARTY::GOLD_WINDOW_X
    @gold_window.y = FS_SHOP_ALL_PARTY::BOTTOM_WINDOW_Y

    if changed_size
      @gold_window.create_contents
      @gold_window.refresh
    end
  end

  def terminate
    super
    dispose_menu_background
    dispose_command_window
    @help_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
    @title_window.dispose
    $game_temp.fs_shop_key = nil if $game_temp.respond_to?(:fs_shop_key=)
    $game_temp.fs_shop_profile = nil if
      $game_temp.respond_to?(:fs_shop_profile=)
  end

  def update
    fs_align_bottom_windows

    # KGC Large Party 的商店狀態捲動功能。
    if fs_shop_status_scroll?
      super
      update_menu_background
      @help_window.update
      @gold_window.update
      update_scroll_status
      return
    end

    @status_window.cursor_rect.empty if @status_window != nil
    super
    update_menu_background
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update
    if @command_window.active
      update_command_selection
    elsif @buy_window.active
      update_buy_selection
    elsif @sell_window.active
      update_sell_selection
    elsif @number_window.active
      update_number_input
    end
  end

  def fs_shop_status_scroll?
    return false unless defined?(KGC)
    return false unless defined?(KGC::LargeParty)
    return false unless KGC::LargeParty.const_defined?("SHOP_STATUS_SCROLL_BUTTON")
    button = KGC::LargeParty::SHOP_STATUS_SCROLL_BUTTON
    return false if button == nil
    return false unless @buy_window != nil && @buy_window.active
    return false unless @status_window != nil && @status_window.visible
    return Input.press?(button)
  end

  def update_scroll_status
    @status_window.cursor_rect.width = @status_window.contents.width
    @status_window.cursor_rect.height = @status_window.height - 32
    @status_window.update
    if Input.press?(Input::UP)
      @status_window.oy = [@status_window.oy - 4, 0].max
    elsif Input.press?(Input::DOWN)
      max_pos = [@status_window.contents.height -
        (@status_window.height - 32), 0].max
      @status_window.oy = [@status_window.oy + 4, max_pos].min
    end
  end

  def create_command_window
    s1 = Vocab::ShopBuy
    s2 = Vocab::ShopSell
    s3 = Vocab::ShopCancel
    @command_window = Window_Command.new(384, [s1, s2, s3], 3)
    @command_window.x = Graphics.width - @command_window.width
    @command_window.y = 0
    @command_window.draw_item(1, false) if $game_temp.shop_purchase_only
  end

  def dispose_command_window
    @command_window.dispose
  end

  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0
        Sound.play_decision
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1
        if $game_temp.shop_purchase_only
          Sound.play_buzzer
        else
          Sound.play_decision
          @command_window.active = false
          @dummy_window.visible = false
          @sell_window.active = true
          @sell_window.visible = true
          @sell_window.refresh
        end
      when 2
        Sound.play_decision
        $scene = Scene_Map.new
      end
    end
  end

  def update_buy_selection
    @status_window.item = @buy_window.item

    # RPG Maker VX預設鍵盤A對應Input::X。
    if Input.trigger?(Input::X) &&
       @status_window.respond_to?(:fs_toggle_detail_page)
      if @status_window.fs_toggle_detail_page
        Sound.play_cursor
      else
        Sound.play_buzzer
      end
      return
    end

    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      @help_window.set_text($game_temp.shop_word.to_s)
      return
    end

    if Input.trigger?(Input::C)
      @item = @buy_window.item
      price = @buy_window.price(@item)
      number = @item == nil ? 0 : $game_party.item_number(@item)
      stock = @buy_window.respond_to?(:remaining_stock) ?
        @buy_window.remaining_stock : 99
      if @item == nil || price > $game_party.gold ||
         number >= 99 || stock <= 0
        Sound.play_buzzer
      else
        Sound.play_decision
        max = price == 0 ? 99 : $game_party.gold / price
        max = [max, 99 - number, stock].min
        @status_window.visible = false
        @buy_window.active = false
        @buy_window.visible = false
        @number_window.set(@item, max, price)
        @number_window.active = true
        @number_window.visible = true
      end
    end
  end

  def update_sell_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      @help_window.set_text($game_temp.shop_word.to_s)
    elsif Input.trigger?(Input::C)
      @item = @sell_window.item
      @status_window.item = @item
      if @item == nil || @item.price == 0
        Sound.play_buzzer
      else
        Sound.play_decision
        max = $game_party.item_number(@item)
        @sell_window.active = false
        @sell_window.visible = false
        @number_window.set(@item, max, @item.price / 2)
        @number_window.active = true
        @number_window.visible = true
        @status_window.visible = false
      end
    end
  end

  def update_number_input
    if Input.trigger?(Input::B)
      cancel_number_input
    elsif Input.trigger?(Input::C)
      decide_number_input
    end
  end

  def cancel_number_input
    Sound.play_cancel
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0
      @buy_window.active = true
      @buy_window.visible = true
      @status_window.visible = true
    when 1
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
    end
  end

  def decide_number_input
    Sound.play_shop
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0
      price = @buy_window.price(@item)
      amount = @number_window.number
      $game_party.lose_gold(amount * price)
      $game_party.gain_item(@item, amount)
      if defined?(FS_BLACK_MARKET) &&
         $game_temp.respond_to?(:fs_shop_key) &&
         $game_temp.fs_shop_key == :black_market
        FS_BLACK_MARKET.record_purchase(@buy_window.current_good, amount)
      end
      @gold_window.refresh
      @buy_window.refresh
      @status_window.refresh
      @buy_window.active = true
      @buy_window.visible = true
      @status_window.visible = true
    when 1
      $game_party.gain_gold(@number_window.number * (@item.price / 2))
      $game_party.lose_item(@item, @number_window.number)
      @gold_window.refresh
      @sell_window.refresh
      @status_window.refresh
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
    end
  end
end
