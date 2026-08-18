#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：地圖上的重複動畫(營火)
# 【用途】地圖／事件元件「地圖上的重複動畫(營火)」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Interpreter、Game_Character、Sprite_Character
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】set_anim(character, animation_id)；set_anim(10, 5)
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
# ? [VX Snippet] ? Auto-Repeat Animation ? ?
# * Show animation again and again on character in map~ *
#--------------------------------------------------------------
# ? by Woratana [woratana@hotmail.com]
# ? Thaiware RPG Maker Community
# ? Released on: 21/05/2008
# ? Version: 1.0
#--------------------------------------------------------------

#==================================================================
# ** HOW TO USE **
#-----------------------------------------------------------------
# To set repeat animation to character, call script:
#   set_anim(character, animation_id)
#
# * character: What character you want to set repeat animation?
# ** -1 for 'Player', 0 for 'This Event', and 1 or more for Event ID
# * animation_id: ID of the animation you want to set as repeat animation
# ** use 0 to remove repeat animation~

# For example:
#   set_anim(10, 5)
# * Script above will set Animation ID 5 as repeat animation for Event ID 10
#==================================================================

class Game_Interpreter
  def set_anim(character, anim_id)
    get_character(character).repeat_anim = anim_id
  end
end

class Game_Character
  attr_accessor :repeat_anim
  alias wora_autorepani_gamcha_ini initialize
  def initialize
    @repeat_anim = 0
    wora_autorepani_gamcha_ini
  end
end

class Sprite_Character < Sprite_Base
  alias wora_autorepani_sprcha_upd update
  def update
    wora_autorepani_sprcha_upd
    unless @animation_duration > 0
      @character.animation_id = @character.repeat_anim
    end
  end
end