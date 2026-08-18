#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：       BattleSwirl
# 【用途】戰鬥系統元件「       BattleSwirl」。
# 【主要機制】負責戰鬥流程、數值、AI、演出或相容的一部分；可能透過 alias 疊加既有方法。
# 【主要影響】Scene_Map、P2BSWIRL
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：VARIABLE。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
module P2BSWIRL
  VARIABLE = 4997
  end
class Scene_Map < Scene_Base
    def perform_battle_transition
    Graphics.freeze
  end
    def call_battle
    @spriteset.update
    Graphics.update
    $game_player.make_encounter_count
    $game_player.straighten
    $game_temp.map_bgm = RPG::BGM.last
    $game_temp.map_bgs = RPG::BGS.last
    RPG::BGM.stop
    RPG::BGS.stop
    Sound.play_battle_start
    $game_temp.next_scene = nil
    Wora_NSS.shot('Saves/' + 'temp1')
    battleswirl
  end

  def battleswirl
    battleswirl_shot
    create_shot
    update_shot1
  end

  def battleswirl_shot
    $game_temp.background_bitmap.dispose
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    $game_temp.background_bitmap.radial_blur(0,0)
  end
  #--------------------------------------------------------------------------
  # * Create Background for Menu Screen
  #--------------------------------------------------------------------------
  def create_shot
    @swirl_sprite = Sprite.new
    @swirl_sprite.bitmap = $game_temp.background_bitmap
    @swirl_sprite.color.set(0, 0, 0, 0)
    @swirl_sprite.z = 1001
  end
  #--------------------------------------------------------------------------
  # * Dispose of Background for Menu Screen
  #--------------------------------------------------------------------------
  def dispose_menu_background
    @swirl_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Update Background for Menu Screen
  #--------------------------------------------------------------------------
  def update_shot1
    if $game_variables[P2BSWIRL::VARIABLE] >= 10
        
    $game_variables[P2BSWIRL::VARIABLE] += 4
    else
    $game_variables[P2BSWIRL::VARIABLE] += 1
    end
    update_shot2
  end
  def update_shot2
    if $game_variables[P2BSWIRL::VARIABLE] >=50
          
      Graphics.fadeout(5)
      @swirl_sprite.dispose
          $game_system.battle_bgm.play
      $scene = Scene_Battle.new   
      $game_variables[P2BSWIRL::VARIABLE] = 0
    else
    $game_temp.background_bitmap.radial_blur($game_variables[P2BSWIRL::VARIABLE]/1.5,0)
    @swirl_sprite.color.set(0, 0, 0, $game_variables[P2BSWIRL::VARIABLE]*5)
    Graphics.wait(6)
    update_shot1
  end
  end
end
