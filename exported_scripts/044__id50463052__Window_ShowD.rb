#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_ShowD
# 【用途】UI／選單元件「Window_ShowD」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_ShowD
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MA_SHOW_ICONS_NUM。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ** Window_Help
#------------------------------------------------------------------------------
#  本動態説明視窗用來及時顯示技能和物品的說明。
#==============================================================================

class Window_ShowD < Window_Base
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    super(272, -30, 272, 128)
    self.opacity = 0
    self.active = false
    self.visible = false  
    self.z = 0 
    update
  end
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Constants
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  MA_SHOW_ICONS_NUM = 3 # Number of icons to show prefacing the enemy name
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item (index, *args)
    mdlg_joy_drw_enmy_stt_drwitm_0gh3 (index, *args)
    name_rect = item_rect(index)
    w = 24*MA_SHOW_ICONS_NUM
    icon_rect = Rect.new (name_rect.x - w - 4, name_rect.y, w + 4, name_rect.height)
    contents.clear_rect (icon_rect)
    # Draw Enemy State by Actor State method
    draw_actor_state (@enemies[index], icon_rect.x, icon_rect.y, w)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item Rect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def item_rect (*args)
    rect = drbr_jy_enmyststes_show_itmrect_7j24 (*args)
    rect.x += ((24*MA_SHOW_ICONS_NUM) + 4)
    rect.width -= ((24*MA_SHOW_ICONS_NUM) + 4)
    return rect
  end
  #--------------------------------------------------------------------------
  # * 設置文本
  #  text  : 顯示於視窗中的字串
  #  align : 對齊方式（0為左對齊，1為劇中，二為右對齊）
  #--------------------------------------------------------------------------
  
   def update
    super
    self.contents.clear
    refresh
  end
  
  def refresh
    if $game_switches[50] == true
      x = $game_variables[121]
     @mem = $game_troop.members[x]
     @mem_id = $game_troop.members[x].id 
     self.visible = true
     self.contents.clear
     color = Color.new(0, 0, 0, 128)
     self.contents.fill_rect(0, 0, 272, 128, color)
     #self.contents.fill_rounded_rect(0, 0, 272, 128, color)
     self.contents.font.size = 19
     self.contents.font.color = normal_color
     self.contents.draw_text(148, 40, self.width - 40, WLH, @mem.name)
     self.contents.draw_text(148, 20, self.width - 40, WLH, "Lv")
     self.contents.draw_text(168, 20, self.width - 40, WLH, @mem.level)
     self.contents.font.size = 17
     draw_actor_hp(@mem, 148, 52, 90)
     draw_actor_mp(@mem, 148, 63, 90)
     draw_actor_state(@mem,205,20)
     
     #text = "["
     # for state in @mem.states
     #   next if N01::STATE_NON_DISPLAY.include?(state.id)
     #   text += " " if text != "["
     #   text += state.name
     # end
     # text += N01::WORD_NORMAL_STATE if text == "["
     # text += "]"
     # text = "" if text == "[]"
     # self.contents.font.size = 17
     # self.contents.draw_text(178, 40, 195, WLH, text, 0)
    end
  end
  
  def dispose
    self.contents.dispose
    super
  end
end
