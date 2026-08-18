#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_FriendInfo
# 【用途】UI／選單元件「Window_FriendInfo」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_FriendInfo
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
# ■ Window_FriendInfo召喚物視窗
#==============================================================================
class Window_FriendInfo < Window_Base
   #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    super(412, -12, 142, 128)
    self.opacity = 0
    self.active = false
    self.visible = false  
    self.z = 0 
    update
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
     if $game_troop.members[x] != nil
     self.visible = true
     self.contents.clear
     color = Color.new(0, 0, 0, 128)
     #rect = Rect.new(0, -15, 142, 128)
     #self.contents.fill_rounded_rect(rect, color)
     self.contents.fill_rect(0, -15, 142, 128, color)
     self.contents.font.size = 19
     self.contents.font.color = system_color
     self.contents.draw_text(10, 5, self.width - 40, WLH, "[召喚物]")
     self.contents.font.color = normal_color
     self.contents.draw_text(10, 25, self.width - 40, WLH, @mem.name)
     self.contents.draw_text(10, 45, self.width - 40, WLH, "Lv")
     self.contents.draw_text(30, 45, self.width - 40, WLH, @mem.level)
     self.contents.font.size = 17
     draw_actor_hp(@mem, 10, 57, 90)
     draw_actor_mp(@mem, 10, 68, 90)
     draw_actor_state(@mem,45,45)
     end
    end
  end
  
  def dispose
    self.contents.dispose
    super
  end
end