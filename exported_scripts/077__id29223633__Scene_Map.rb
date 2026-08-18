#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Map
# 【用途】VX 地圖場景，更新地圖、玩家、訊息視窗、選單與場景切換。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Map
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
# ** Scene_Map
#------------------------------------------------------------------------------
#  這個類用來執行顯示地圖場景畫面的程式。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    $game_map.refresh
    @spriteset = Spriteset_Map.new
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # * 執行畫面過渡顯示漸變
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0       # 作戰結束或者讀檔等事件之後
      fadein(30)
    else                              # 從ESC選單等畫面返回
      Graphics.transition(15)
    end
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    if $scene.is_a?(Scene_Battle)     # 若切換至作戰畫面
      @spriteset.dispose_characters   # 為生成作戰畫面背景而隱藏所有人物
    end
    snapshot_for_background
    @spriteset.dispose
    @message_window.dispose
    if $scene.is_a?(Scene_Battle)     # 若切換至作戰畫面
      perform_battle_transition       # 執行作戰前畫面過渡顯示漸變
    end
  end
  #--------------------------------------------------------------------------
  # * 基礎更新進程
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update                   # 更新遊戲螢幕
    Input.update                      # 更新指令輸入資訊
    $game_map.update                  # 更新地圖顯示
    @spriteset.update                 # 更新精靈物設
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.interpreter.update      # 更新直譯器
    $game_map.update                  # 更新地圖顯示
    $game_player.update               # 更新主角隊
    $game_system.update               # 更新計時器
    @spriteset.update                 # 更新精靈物設
    @message_window.update            # 更新文本訊息視窗
    unless $game_message.visible      # 顯示文本訊息以外的情況下
      update_transfer_player
      update_encounter
      update_call_menu
      update_call_debug
      update_scene_change
    end
  end
  #--------------------------------------------------------------------------
  # * 漸顯螢幕內容[淡入]
  #     duration : 持續時間
  #    如果你在地圖畫面直接執行類似 Graphics.fadeout 這樣的指令則會引發一系列
  #    問題，比如說遠景圖和天氣圖片會凍結掉等，所以執行動態淡入。
  #--------------------------------------------------------------------------
  def fadein(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 * i / duration
      update_basic
    end
    Graphics.brightness = 255
  end
  #--------------------------------------------------------------------------
  # * 漸隱螢幕內容[淡出]
  #     duration : 持續時間
  #    和上文[淡入]一樣，Graphics.fadein 這個語句也不是直接執行的。
  #--------------------------------------------------------------------------
  def fadeout(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 - 255 * i / duration
      update_basic
    end
    Graphics.brightness = 0
  end
  #--------------------------------------------------------------------------
  # * 場所移動處理
  #--------------------------------------------------------------------------
  def update_transfer_player
    return unless $game_player.transfer?
    fade = (Graphics.brightness > 0)
    fadeout(30) if fade
    @spriteset.dispose              # 清除精靈物設顯示
    $game_player.perform_transfer   # 執行場所移動指令
    $game_map.autoplay              # 自動切換BGM和BGS
    $game_map.update
    Graphics.wait(15)
    @spriteset = Spriteset_Map.new  # 重建精靈物設
    fadein(30) if fade
    Input.update
  end
  #--------------------------------------------------------------------------
  # * 地雷遇敵處理
  #--------------------------------------------------------------------------
  def update_encounter
    return if $game_player.encounter_count > 0        # 核查步數
    return if $game_map.interpreter.running?          # 正在執行事件指令？
    return if $game_system.encounter_disabled         # 禁用地雷遇敵模式？
    troop_id = $game_player.make_encounter_troop_id   # 判定敵人隊伍
    return if $data_troops[troop_id] == nil           # 敵人隊伍非法？
    $game_troop.setup(troop_id)
    $game_troop.can_escape = true
    $game_temp.battle_proc = nil
    $game_temp.next_scene = "battle"
    preemptive_or_surprise
  end
  #--------------------------------------------------------------------------
  # * 先發制人和偷襲的概率判定
  #--------------------------------------------------------------------------
  def preemptive_or_surprise
    actors_agi = $game_party.average_agi
    enemies_agi = $game_troop.average_agi
    if actors_agi >= enemies_agi
      percent_preemptive = 5
      percent_surprise = 3
    else
      percent_preemptive = 3
      percent_surprise = 5
    end
    if rand(100) < percent_preemptive
      $game_troop.preemptive = true
    elsif rand(100) < percent_surprise
      $game_troop.surprise = true
    end
  end
  #--------------------------------------------------------------------------
  # * 按下取消按鈕呼叫ESC選單的判定
  #--------------------------------------------------------------------------
  def update_call_menu
    if Input.trigger?(Input::B)
      return if $game_map.interpreter.running?        # 正在執行事件指令？
      return if $game_system.menu_disabled            # 禁用ESC選單？
      $game_temp.menu_beep = true                     # 設置SE播放標幟
      $game_temp.next_scene = "menu"
    end
  end
  #--------------------------------------------------------------------------
  # * 按下F9建調用DEBUG介面的判定
  #--------------------------------------------------------------------------
  def update_call_debug
    if $TEST and Input.press?(Input::F9)    # 測試遊戲時可用的F9鍵
      $game_temp.next_scene = "debug"
    end
  end
  #--------------------------------------------------------------------------
  # * 執行螢幕切換指令
  #--------------------------------------------------------------------------
  def update_scene_change
    return if $game_player.moving?    # 主角正在事件指令化移動中？
    case $game_temp.next_scene
    when "battle"
      call_battle
    when "shop"
      call_shop
    when "name"
      call_name
    when "menu"
      call_menu
    when "save"
      call_save
    when "debug"
      call_debug
    when "gameover"
      call_gameover
    when "title"
      call_title
    else
      $game_temp.next_scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # * 切換至作戰畫面
  #--------------------------------------------------------------------------
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
    $game_system.battle_bgm.play
    $game_temp.next_scene = nil
    $scene = Scene_Battle.new
  end
  #--------------------------------------------------------------------------
  # * 切換至交易畫面
  #--------------------------------------------------------------------------
  def call_shop
    $game_temp.next_scene = nil
    $scene = Scene_Shop.new
  end
  #--------------------------------------------------------------------------
  # * 切換至名稱輸入畫面
  #--------------------------------------------------------------------------
  def call_name
    $game_temp.next_scene = nil
    $scene = Scene_Name.new
  end
  #--------------------------------------------------------------------------
  # * 切換至ESC選單畫面
  #--------------------------------------------------------------------------
  def call_menu
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Menu.new
  end
  #--------------------------------------------------------------------------
  # * 切換至進度存取畫面
  #--------------------------------------------------------------------------
  def call_save
    $game_temp.next_scene = nil
    $scene = Scene_File.new(true, false, true)
  end
  #--------------------------------------------------------------------------
  # * 切換至DEBUG畫面
  #--------------------------------------------------------------------------
  def call_debug
    Sound.play_decision
    $game_temp.next_scene = nil
    $scene = Scene_Debug.new
  end
  #--------------------------------------------------------------------------
  # * 切換至GAMEOVER畫面
  #--------------------------------------------------------------------------
  def call_gameover
    $game_temp.next_scene = nil
    $scene = Scene_Gameover.new
  end
  #--------------------------------------------------------------------------
  # * 切換至標題畫面
  #--------------------------------------------------------------------------
  def call_title
    $game_temp.next_scene = nil
    $scene = Scene_Title.new
    fadeout(60)
  end
  #--------------------------------------------------------------------------
  # * 執行作戰前畫面過渡顯示漸變
  #--------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(80, "Graphics/System/BattleStart", 80)
    Graphics.freeze
  end
end
