#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：事件移動
# 【用途】地圖／事件元件「事件移動」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Event、Sprite_Character
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
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
# ● [VX Snippet] ◦ Sprite Mover ◦ □
# * Move sprite in pixel to get right location~ *
#--------------------------------------------------------------
# ◦ by Woratana [woratana@hotmail.com]
# ◦ Thaiware RPG Maker Community
# ◦ Released on: 02/06/2008
# ◦ Version: 1.0
#--------------------------------------------------------------

#==================================================================
# ** HOW TO USE **
#-----------------------------------------------------------------
# * In the event page that you want to move sprite, add comment:
#  MOVE x_plus, y_plus
# ** x_plus: how many pixel you want to move sprite horizontally
# (- number: move left | + number: move right)
# ** y_plus: how many pixel you want to move sprite vertically
# (- number: move up | + number: move down)

# * For example, add comment:
#  MOVE 0, -20
# ** to move sprite up 20 pixel~
#==================================================================


class Game_Event < Game_Character
  attr_accessor :spr_move
  alias wora_mover_gameve_setup setup
  
  def setup(*args)
    wora_mover_gameve_setup(*args)
    mover = comment?('MOVE', true)
    if !mover[0]
      @spr_move = nil
    else
      @spr_move = @list[mover[1]].parameters[0].clone
      @spr_move.sub!('MOVE','').gsub!(/\s+/){''}
      @spr_move = @spr_move.split(',')
      @spr_move.each_index {|i| @spr_move[i] = @spr_move[i].to_i }
    end
  end
  
  def comment?(comment, return_index = false )
    if !@list.nil?
      for i in 0...@list.size - 1
        next if @list[i].code != 108
        if @list[i].parameters[0].include?(comment)
          return [true, i] if return_index
          return true
        end
      end
    end
    return [false, nil] if return_index
    return false
  end
end

class Sprite_Character < Sprite_Base
  alias wora_mover_sprcha_upd update
  
  def update
    wora_mover_sprcha_upd
    if @character.is_a?(Game_Event) and !@character.spr_move.nil?
      self.x = @character.screen_x + @character.spr_move[0]
      self.y = @character.screen_y + @character.spr_move[1]
    end
  end
end