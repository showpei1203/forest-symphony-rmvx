#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Zoom 大小
# 【用途】保留的 Runtime 元件「Zoom 大小」。
# 【主要機制】主要定義／擴充 Game_Character、Sprite_Character、Game_Player；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Character、Sprite_Character、Game_Player
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】$game_map.events[Event ID].zoom(x,y)   event zoom command
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
#==================================================================#
#  #*****************#         Zoom char V 0.5 , Falcao script     #
#  #*** By Falcao ***#         allow you to increse the chara size #                   
#  #*****************#         making zoom effect.                 #
#         RMVX                                                     #
# makerpalace.onlinegoo.com                                        #
#==================================================================#

#-------------------------------------------------------------------
# * Commands
#
# $game_player.zoom(x,y)      player zoom command,
# Example.  $game_player.zoom(2,2) increase double
#
# $game_map.events[Event ID].zoom(x,y)   event zoom command  
# Example  $game_map.events[1].zoom(2,2)  event ID 1 increase double
#
# Note: Zoom support decimals
# Default zoom for each character is "(1,1)"
#--------------------------------------------------------------------

class Game_Character
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  alias falcaozoom_ini initialize
  def initialize
    falcaozoom_ini
    @zoom_x = 1.0
    @zoom_y = 1.0
  end
  def zoom(x,y)
    self.zoom_x = x
    self.zoom_y = y
  end
end

class Sprite_Character < Sprite_Base
alias character_zoom_update update
 def update 
     character_zoom_update
     if @zoom_x != @character.zoom_x or
        @zoom_y != @character.zoom_y
        @zoom_x = @character.zoom_x
        @zoom_y = @character.zoom_y       
        self.zoom_x = @character.zoom_x
        self.zoom_y = @character.zoom_y
     end   
 end 
end

class Game_Player < Game_Character
  def zoom(x,y)
    self.zoom_x = x
    self.zoom_y = y
  end
end
