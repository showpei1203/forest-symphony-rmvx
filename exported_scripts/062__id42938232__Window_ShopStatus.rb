#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_ShopStatus
# 【用途】UI／選單元件「Window_ShopStatus」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_ShopStatus
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
# ** Window_ShopStatus
#------------------------------------------------------------------------------
#  本視窗顯示于交易畫面中，
#  用於即時顯示可以交易的裝備在各個主角身上裝備後會產生的參數變化。
#==============================================================================

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x      : 視窗X座標
  #     y      : 視窗Y座標
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x-130, y, 370, 224)#240 304
    @item = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @item != nil
      number = $game_party.item_number(@item)
      self.contents.font.color = system_color
      self.contents.font.size = 16
      self.contents.draw_text(4, 0, 200, WLH, Vocab::Possession)
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, 200, WLH, number, 1)
      
      if @item.is_a?(RPG::Item)
        # 物品范围描述
        scope = "[對象] : "
        case @item.scope
        when 0;  scope += "無"
        when 1;  scope += "敵單體"
        when 2;  scope += "敵全體"
        when 3;  scope += "敵單體 連續"
        when 4;  scope += "敵單體 隨機"
        when 5;  scope += "敵二體 隨機"
        when 6;  scope += "敵二體 隨機"
        when 7;  scope += "我方單體"
        when 8;  scope += "我方全體"
        when 9;  scope += "我方單體 (陣亡)"
        when 10; scope += "我方全體 (陣亡)" 
        when 11; scope += "使用者"
        end
        self.contents.draw_text(0, 24, 512, 24, scope)
        # 物品范围描述结束
        # 物品恢复效果描述
        effection = "[效果] : "
        if @item.hp_recovery_rate > 0
          effection += "#{Vocab.hp}+#{@item.hp_recovery_rate}% "
        elsif @item.hp_recovery_rate < 0
          effection += "#{Vocab.hp}-#{@item.hp_recovery_rate}% "
        elsif @item.hp_recovery > 0
          effection += "#{Vocab.hp}+#{@item.hp_recovery} "
        elsif @item.hp_recovery < 0
          effection += "#{Vocab.hp}-#{@item.hp_recovery} "
        end
        if @item.mp_recovery_rate > 0
          effection += "#{Vocab.mp}+#{@item.mp_recovery_rate}% "
        elsif @item.mp_recovery_rate < 0
          effection += "#{Vocab.mp}-#{@item.mp_recovery_rate}% "
        elsif @item.mp_recovery > 0
          effection += "#{Vocab.mp}+#{@item.mp_recovery} "
        elsif @item.mp_recovery < 0
          effection += "#{Vocab.mp}-#{@item.mp_recovery} "
        end
        effection += "傷害#{@item.base_damage} " if @item.base_damage != 0
        case @item.parameter_type
        when 1
          effection += "最大#{Vocab.hp}+#{@item.parameter_points}"
        when 2
          effection += "最大#{Vocab.mp}+#{@item.parameter_points}"
        when 3
          effection += "#{Vocab.atk}+#{@item.parameter_points}"
        when 4
          effection += "#{Vocab.def}+#{@item.parameter_points}"
        when 5
          effection += "#{Vocab.spi}+#{@item.parameter_points}"
        when 6
          effection += "#{Vocab.agi}+#{@item.parameter_points}"
        end
        if @item.id == 6
          effection += "解除單人中毒狀態。"
        end
        self.contents.draw_text(0, 48, 512, 24, effection)
        # 物品恢复效果描述结束
      end
      

      for actor in $game_party.members
        x = 4
        y = (WLH+1) * (2 + actor.index * 2)
        draw_actor_parameter_change(actor, x, y)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製主角當前裝備資訊及各項參數資訊
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_actor_parameter_change(actor, x, y)
    return if @item.is_a?(RPG::Item)
    enabled = actor.equippable?(@item)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(x, y, 200, WLH, actor.name)
    if @item.is_a?(RPG::Weapon)
      item1 = weaker_weapon(actor)
    elsif actor.two_swords_style and @item.kind == 0
      item1 = nil
    else
      item1 = actor.equips[1 + @item.kind]
    end
    if enabled
      if @item.is_a?(RPG::Weapon)
        atk1 = item1 == nil ? 0 : item1.atk
        atk2 = @item == nil ? 0 : @item.atk
        #hit = @item.hit
        change = atk2 - atk1
      else
        def1 = item1 == nil ? 0 : item1.def
        def2 = @item == nil ? 0 : @item.def
        change = def2 - def1
      end
      self.contents.draw_text(x, y, 200, WLH, sprintf("%+d", change), 2)
      #self.contents.draw_text(x, y, 200, WLH, sprintf("%+d", hit), 2)
    end
    draw_item_name(item1, x, y + WLH, enabled)
  end
  #--------------------------------------------------------------------------
  # * 獲取主角裝備的雙手武器中較弱的武器資訊（僅限貳刀流主角）
  #     actor : 主角
  #--------------------------------------------------------------------------
  def weaker_weapon(actor)
    if actor.two_swords_style
      weapon1 = actor.weapons[0]
      weapon2 = actor.weapons[1]
      if weapon1 == nil or weapon2 == nil
        return nil
      elsif weapon1.atk < weapon2.atk
        return weapon1
      else
        return weapon2
      end
    else
      return actor.weapons[0]
    end
  end
  #--------------------------------------------------------------------------
  # * 設置條目
  #     item : 新條目
  #--------------------------------------------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
end
