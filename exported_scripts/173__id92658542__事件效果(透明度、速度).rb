#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：事件效果(透明度、速度)
# 【用途】地圖／事件元件「事件效果(透明度、速度)」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Event
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
#===============================================================
# ● [VX] ◦ Auto Event Properties Change ◦ □
# * Add tag in 'comment...' in event to change event's properties automatically~
#--------------------------------------------------------------
# ◦ by Woratana [woratana@hotmail.com]
# ◦ Thaiware RPG Maker Community
# ◦ Released on: 26/10/2008
# ◦ Version: 1.0
#--------------------------------------------------------------

#==================================================================
# ** HOW TO USE **
#-----------------------------------------------------------------
# * Insert event command 'Comment...' in an event, put following tags for the
# properties you want to add/change:

# [sp(number)] : Change event's walk speed to that number
# (** You can use decimal number, e.g. [sp9.5] )
# [o(number)] : Change event's opacity to that number
# [add] : Change event's blending mode to 'Add'
# [neg] : Change event's blending mode to 'Subtraction'
# [through] : Add property 'Through' to the event (It can walk on unpassable tile)

# * You can add many tags into one comment, for example:
# [sp5.2][o180][add]
# ^ The event will has walk speed 5.2, Opacity 180, and the character will be in
# blend mode.
#==================================================================

class Game_Event < Game_Character
  alias wor_ev_opac_setup setup
  
  def setup(new_page)
   wor_ev_opac_setup(new_page)
   if !@list.nil? 
    for i in 0...@list.size - 1
      next if @list[i].code != 108
      if @list[i].parameters[0].include?("[o")
        list = @list[i].parameters[0].scan(/\[o([0-9]+)\]/)
        @opacity = $1.to_i
      end
      if @list[i].parameters[0].include?("[sp")
        list = @list[i].parameters[0].scan(/\[sp([0-9]+)\]/)
        @move_speed = $1.to_i
      end
      if @list[i].parameters[0].include?("[add]")
        @blend_type = 1
      end
      if @list[i].parameters[0].include?("[neg]")
        @blend_type = 2
      end
      if @list[i].parameters[0].include?("[through]")
        @through = true
      end
    end
   end
  end
end