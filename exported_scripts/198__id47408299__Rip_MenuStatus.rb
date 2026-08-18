#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Rip_MenuStatus
# 【用途】UI／選單元件「Rip_MenuStatus」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_RipMenuStatus
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】登記 $imported：Icons。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：f96-frame2。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  This window displays party member status on the menu screen.
#==============================================================================

class Window_RipMenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y+50, 258, 416)
    self.opacity = 0
    refresh
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh    
    self.contents.clear
    @item_max = $game_party.members.size
    for actor in $game_party.members
      #draw_actor_face(actor, 0, actor.index * 96, 96)
      #self.contents.fill_rect(0, (actor.index * 96)+6, 84, 84, Color.new(0,0,0,200))
      
      draw_actor_face(actor, 2, (actor.index * 96)+8, 80)
      bitmap = Cache.picture("f96-frame2")
      rect = Rect.new(0,0,84,84)
      self.contents.blt(0,(actor.index * 96)+6,bitmap,rect)
      x = 104
      y = actor.index * 96 + WLH / 2
      draw_actor_name(actor, x, y)
      ###
      #draw_actor_class(actor, x + 120, y)
      #draw_actor_level(actor, x, y + WLH * 1)
      draw_actor_jp(actor, x, y, 96)
      ###
      draw_actor_state(actor, x + 96, y)
      draw_actor_hp(actor, x, y + WLH * 1)
      draw_actor_mp(actor, x, y + WLH * 2)
    end
  end
  
  def draw_actor_jp(actor, dx, dy, dw = 50)
    return if actor.class_id == nil
    icon = $imported["Icons"] ? YEZ::ICONS[:txtjp] : YEZ::JOB::JP_ICON
    draw_icon(icon, dx + dw - 24, dy)
    text = actor.class_jp[actor.class_id]
    self.contents.font.size = 16
    self.contents.draw_text(dx, dy, dw - 24, WLH, text, 2)
    self.contents.font.size = 20
  end
  
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor 
    if @index < 0               # No cursor
      self.cursor_rect.empty
    elsif @index < @item_max    # Normal
      self.cursor_rect.set(-2, (@index * 96)-2, 236, 96+4)
    elsif @index >= 100         # Self
      self.cursor_rect.set(0, (@index - 100) * 96, contents.width, 96)
    else                        # All
      self.cursor_rect.set(0, 0, contents.width, @item_max * 96)
    end
  end
end
