#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：勝利音樂漸隱
# 【用途】保留的 Runtime 元件「勝利音樂漸隱」。
# 【主要機制】主要定義／擴充 Scene_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Scene_Battle
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Kylock。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# ■ Fade Battle End ME
#     6.5.2008
#------------------------------------------------------------------------------
#  Script by: Kylock
#==============================================================================
#    This script fades the Battle End ME at the end of the battle instead of
#  playing out the entire sound file.
#==============================================================================

class Scene_Battle < Scene_Base
  def battle_end(result)
    if result == 2 and not $game_troop.can_lose
      call_gameover
    else
      $game_party.clear_actions
      $game_party.remove_states_battle
      $game_troop.clear
      if $game_temp.battle_proc != nil
        $game_temp.battle_proc.call(result)
        $game_temp.battle_proc = nil
      end
      #Fades Fanfare ME
      RPG::ME.fade(1000)
      unless $BTEST
        $game_temp.map_bgm.play
        $game_temp.map_bgs.play
      end
      $scene = Scene_Map.new
      @message_window.clear
      Graphics.fadeout(30)
      #Stops fanfare me, starts Map BGM
      RPG::ME.stop
    end
    $game_temp.in_battle = false
  end
end