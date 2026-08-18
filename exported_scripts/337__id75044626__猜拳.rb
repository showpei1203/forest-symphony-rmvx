#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：猜拳
# 【用途】保留的 Runtime 元件「猜拳」。
# 【主要機制】主要定義／擴充 Scene_PPT、Pernalonga；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Scene_PPT、Pernalonga
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
#==============================================================================#
#                       ::. PPT System                                         #
# ::.                       By: Master I                                       #
#==============================================================================#

#===============================================================================
# For call the scritp
#-------------------------------------------------------------------------------
########################
#$scene = Scene_PPT.new#
########################

module Pernalonga
#===============================================================================
# Pictures Name
#-------------------------------------------------------------------------------
Pedra = "Pedra"          
Papel = "Papel"          
Tesoura = "Tesoura"      
PPT_Cursor = "Cursor"    
PPT_Fundo = "temp2"           #Back Picture
PPT_Fundo_Opacidade = 255  #Back Opacity
#===============================================================================
# Switches ID
#-------------------------------------------------------------------------------
PPT_Switch = 71           # ID of the switch when win
PPT_Switch_lose = 72      # ID of the switch when lose
PPT_Switch_emp = 73       # ID of the switch when wench
end

#===============================================================================
#Scene PPT (Pedra, Papel, Tesoura)
#-------------------------------------------------------------------------------
class Scene_PPT < Scene_Base
  
  def start
    create_menu_background
    command_window
    @cursor = Sprite.new
    @cursor.bitmap = Cache.picture(Pernalonga::PPT_Cursor)
    @cursor.x = 99
    @cursor.y = 300
    @contador = 0
    @ppt_npc = rand(3)
    @pedra = Sprite.new
    @papel = Sprite.new
    @tesoura = Sprite.new
    @pedra.bitmap = Cache.picture(Pernalonga::Pedra)
    @papel.bitmap = Cache.picture(Pernalonga::Papel)
    @tesoura.bitmap = Cache.picture(Pernalonga::Tesoura)
    @tesoura.z = 2
    @pedra.z = 2
    @papel.z = 2
    @pedra.x = 100
    @papel.x = 250
    @tesoura.x = 400
    @pedra.y = 300
    @papel.y = 300
    @tesoura.y = 300
    @cursor.z = 3
    @pedra_npc = Sprite.new
    @papel_npc = Sprite.new
    @tesoura_npc = Sprite.new
    @pedra_npc.bitmap = Cache.picture(Pernalonga::Pedra)
    @papel_npc.bitmap = Cache.picture(Pernalonga::Papel)
    @tesoura_npc.bitmap = Cache.picture(Pernalonga::Tesoura)
    @pedra_npc.z = 2
    @papel_npc.z = 2
    @tesoura_npc.z = 2
    @pedra_npc.x = 250
    @papel_npc.x = 250
    @tesoura_npc.x = 250
    @pedra_npc.y = - 50
    @papel_npc.y = - 50
    @tesoura_npc.y = - 50
    @fundo_ppt = Sprite.new
    @fundo_ppt.bitmap = Cache.picture(Pernalonga::PPT_Fundo)
    @fundo_ppt.z = 1
    @fundo_ppt.opacity = Pernalonga::PPT_Fundo_Opacidade
  end
  
  def update
    command_window
      end
  
  def terminate
Graphics.wait(40)
@pedra.dispose
@papel.dispose
@tesoura.dispose
@cursor.dispose
@pedra_npc.dispose
@tesoura_npc.dispose
@papel_npc.dispose
@fundo_ppt.dispose
  end
  
  def command_window
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::RIGHT)
      Sound.play_cursor
      @contador += 1
      if @contador == 1
      @cursor.x = 250
      elsif @contador == 2
      @cursor.x = 400
    elsif @contador >= 2
      @contador = 2
    end
  elsif Input.trigger?(Input::LEFT)
    Sound.play_cursor
    @contador -= 1
    if @contador == 1
      @cursor.x = 250
    elsif @contador == 0
      @cursor.x = 99
    elsif @contador <= - 1
      @contador = 0
    end
  elsif Input.trigger?(Input::C)
    Sound.play_decision
    @cursor.visible = false
    definição_ppt
    definição_ppt_npc
    case @contador
when 0
Graphics.wait(5)
@papel.y += 25
@tesoura.y += 25
@pedra.x += 25
@pedra.y -= 25
Graphics.wait(5)
@papel.y += 25
@tesoura.y += 25
@pedra.x += 25
@pedra.y -= 25
Graphics.wait(5)
@papel.y += 25
@tesoura.y += 25
@pedra.x += 25
@pedra.y -= 25
Graphics.wait(5)
@papel.y += 25
@tesoura.y += 25
@pedra.x += 25
@pedra.y -= 25
Graphics.wait(5)
@papel.y += 25
@tesoura.y += 25
@pedra.x += 25
@pedra.y -= 25
Graphics.wait(5)
@papel.y += 25
@tesoura.y += 25
@pedra.x += 25
@pedra.y -= 25
Graphics.wait(10)
when 1
Graphics.wait(5)
@pedra.y += 25
@tesoura.y += 25
@papel.y -= 25
Graphics.wait(5)
@pedra.y += 25
@tesoura.y += 25
@papel.y -= 25
Graphics.wait(5)
@pedra.y += 25
@tesoura.y += 25
@papel.y -= 25
Graphics.wait(5)
@pedra.y += 25
@tesoura.y += 25
@papel.y -= 25
Graphics.wait(5)
@pedra.y += 25
@tesoura.y += 25
@papel.y -= 25
Graphics.wait(5)
@pedra.y += 25
@tesoura.y += 25
@papel.y -= 25
Graphics.wait(10)
when 2
Graphics.wait(5)
@pedra.y += 25
@papel.y += 25
@tesoura.y -= 25
@tesoura.x -= 25
Graphics.wait(5)
@pedra.y += 25
@papel.y += 25
@tesoura.y -= 25
@tesoura.x -= 25
Graphics.wait(5)
@pedra.y += 25
@papel.y += 25
@tesoura.y -= 25
@tesoura.x -= 25
Graphics.wait(5)
@pedra.y += 25
@papel.y += 25
@tesoura.y -= 25
@tesoura.x -= 25
Graphics.wait(5)
@pedra.y += 25
@papel.y += 25
@tesoura.y -= 25
@tesoura.x -= 25
Graphics.wait(5)
@pedra.y += 25
@papel.y += 25
@tesoura.y -= 25
@tesoura.x -= 25
Graphics.wait(10)
    end
  end
end 

def definição_ppt_npc
  case @ppt_npc
  when 0
Graphics.wait(5)
@pedra_npc.y += 25
Graphics.wait(5)
@pedra_npc.y += 25
Graphics.wait(5)
@pedra_npc.y += 25
Graphics.wait(5)
@pedra_npc.y += 25
Graphics.wait(5)
@pedra_npc.y += 25
Graphics.wait(10)
  when 1
Graphics.wait(5)
@papel_npc.y += 25 
Graphics.wait(5)
@papel_npc.y += 25 
Graphics.wait(5)
@papel_npc.y += 25 
Graphics.wait(5)
@papel_npc.y += 25 
Graphics.wait(5)
@papel_npc.y += 25 
Graphics.wait(10)
  when 2
Graphics.wait(5)
@tesoura_npc.y += 25
Graphics.wait(5)
@tesoura_npc.y += 25
Graphics.wait(5)
@tesoura_npc.y += 25
Graphics.wait(5)
@tesoura_npc.y += 25
Graphics.wait(5)
@tesoura_npc.y += 25
Graphics.wait(10)
  end
end

    def definição_ppt
    if @ppt_npc == @contador
      #empata
     $game_switches[Pernalonga::PPT_Switch_emp] = true
     $game_switches[Pernalonga::PPT_Switch] = false
     $game_switches[Pernalonga::PPT_Switch_lose] = false
   elsif @contador == 2 and @ppt_npc == 1
        #ganha
      $game_switches[Pernalonga::PPT_Switch] = true
      $game_switches[Pernalonga::PPT_Switch_emp] = false
      $game_switches[Pernalonga::PPT_Switch_lose] = false
    elsif @contador == 2 and @ppt_npc == 0
      #perde
      $game_switches[Pernalonga::PPT_Switch_lose] = true 
      $game_switches[Pernalonga::PPT_Switch_emp] = false
      $game_switches[Pernalonga::PPT_Switch] = false
    elsif @contador == 0 and @ppt_npc == 2
        #ganha
      $game_switches[Pernalonga::PPT_Switch] = true
      $game_switches[Pernalonga::PPT_Switch_emp] = false
      $game_switches[Pernalonga::PPT_Switch_lose] = false
    elsif @contador == 0 and @ppt_npc == 1
      #perde
      $game_switches[Pernalonga::PPT_Switch_lose] = true
      $game_switches[Pernalonga::PPT_Switch_emp] = false
      $game_switches[Pernalonga::PPT_Switch] = false
    elsif @contador == 1 and @ppt_npc == 0
       #ganha
      $game_switches[Pernalonga::PPT_Switch] = true
      $game_switches[Pernalonga::PPT_Switch_emp] = false
      $game_switches[Pernalonga::PPT_Switch_lose] = false
    elsif @contador == 1 and @ppt_npc == 2
      #perde
      $game_switches[Pernalonga::PPT_Switch_lose] = true
      $game_switches[Pernalonga::PPT_Switch_emp] = false
      $game_switches[Pernalonga::PPT_Switch] = false
  end
  $scene = Scene_Map.new
end
end
