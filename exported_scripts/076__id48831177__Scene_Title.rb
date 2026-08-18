#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Title
# 【用途】VX 正常標題場景，處理資料載入、新遊戲、讀檔與結束遊戲。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Title
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Title。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ** Scene_Title
#------------------------------------------------------------------------------
#  這個類用來執行顯示標題畫面的程式。
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # * 主程序
  #--------------------------------------------------------------------------
  def main
    if $BTEST                         # 作戰測試？
      battle_test                     # 開始作戰測試
    else                              # 正常遊戲
      super                           # 正常執行主程序
    end
  end
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    load_database                     # 載入資料庫
    create_game_objects               # 創建遊戲物件
    check_continue                    # 讀檔可行性判定
    create_title_graphic              # 創建標題圖形
    create_command_window             # 創建命令視窗
    play_title_music                  # 播放標題畫面BGM
  end
  #--------------------------------------------------------------------------
  # * 執行畫面過渡顯示漸變
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(20)
  end
  #--------------------------------------------------------------------------
  # * 程式開始後的處理
  #--------------------------------------------------------------------------
  def post_start
    super
    open_command_window
  end
  #--------------------------------------------------------------------------
  # * 程式終止前的處理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    close_command_window
  end
  #--------------------------------------------------------------------------
  # * 終止程式
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_command_window
    snapshot_for_background
    dispose_title_graphic
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    @command_window.update
    if Input.trigger?(Input::C)
      case @command_window.index
      when 0    # 新的劇情
        command_new_game
      when 1    # 繼續遊戲
        command_continue
      when 2    # 退出遊戲
        command_shutdown
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 讀取數據
  #--------------------------------------------------------------------------
  def load_database
    $data_actors        = load_data("Data/Actors.rvdata")
    $data_classes       = load_data("Data/Classes.rvdata")
    $data_skills        = load_data("Data/Skills.rvdata")
    $data_items         = load_data("Data/Items.rvdata")
    $data_weapons       = load_data("Data/Weapons.rvdata")
    $data_armors        = load_data("Data/Armors.rvdata")
    $data_enemies       = load_data("Data/Enemies.rvdata")
    $data_troops        = load_data("Data/Troops.rvdata")
    $data_states        = load_data("Data/States.rvdata")
    $data_animations    = load_data("Data/Animations.rvdata")
    $data_common_events = load_data("Data/CommonEvents.rvdata")
    $data_system        = load_data("Data/System.rvdata")
    $data_areas         = load_data("Data/Areas.rvdata")
  end
  #--------------------------------------------------------------------------
  # * 讀取資料（作戰測試用）
  #--------------------------------------------------------------------------
  def load_bt_database
    $data_actors        = load_data("Data/BT_Actors.rvdata")
    $data_classes       = load_data("Data/BT_Classes.rvdata")
    $data_skills        = load_data("Data/BT_Skills.rvdata")
    $data_items         = load_data("Data/BT_Items.rvdata")
    $data_weapons       = load_data("Data/BT_Weapons.rvdata")
    $data_armors        = load_data("Data/BT_Armors.rvdata")
    $data_enemies       = load_data("Data/BT_Enemies.rvdata")
    $data_troops        = load_data("Data/BT_Troops.rvdata")
    $data_states        = load_data("Data/BT_States.rvdata")
    $data_animations    = load_data("Data/BT_Animations.rvdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rvdata")
    $data_system        = load_data("Data/BT_System.rvdata")
  end
  #--------------------------------------------------------------------------
  # * 創建遊戲物件
  #--------------------------------------------------------------------------
  def create_game_objects
    $game_temp          = Game_Temp.new
    $game_message       = Game_Message.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
  end
  #--------------------------------------------------------------------------
  # * 讀檔可行性判定
  #--------------------------------------------------------------------------
  def check_continue
    @continue_enabled = (Dir.glob('Save*.rvdata').size > 0)
  end
  #--------------------------------------------------------------------------
  # * 創建標題圖形
  #--------------------------------------------------------------------------
  def create_title_graphic
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system("Title")
  end
  #--------------------------------------------------------------------------
  # * 清除標題圖形
  #--------------------------------------------------------------------------
  def dispose_title_graphic
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 創建命令視窗
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = Vocab::new_game
    s2 = Vocab::continue
    s3 = Vocab::shutdown
    @command_window = Window_Command.new(172, [s1, s2, s3])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = 288
    if @continue_enabled                    # 如果[讀取存檔]可用
      @command_window.index = 1             # 移動游標至該命令項目上
    else                                    # 如果[讀取存檔]不可用
      @command_window.draw_item(1, false)   # 半透明顯示該命令項
    end
    @command_window.openness = 0
    @command_window.open
  end
  #--------------------------------------------------------------------------
  # * 清除命令視窗
  #--------------------------------------------------------------------------
  def dispose_command_window
    @command_window.dispose
  end
  #--------------------------------------------------------------------------
  # * 展開命令視窗
  #--------------------------------------------------------------------------
  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
  end
  #--------------------------------------------------------------------------
  # * 合攏命令視窗
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
  end
  #--------------------------------------------------------------------------
  # * 播放標題畫面BGM
  #--------------------------------------------------------------------------
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
  #--------------------------------------------------------------------------
  # * 檢查玩家起點事件是否存在
  #--------------------------------------------------------------------------
  def confirm_player_location
    if $data_system.start_map_id == 0
      print "玩家起始位置沒有被指定。"
      exit
    end
  end
  #--------------------------------------------------------------------------
  # * 命令項：新的劇情
  #--------------------------------------------------------------------------
  def command_new_game
    confirm_player_location
    Sound.play_decision
    $game_party.setup_starting_members            # 隊伍初期陣容設置
    $game_map.setup($data_system.start_map_id)    # 玩家起始位置設置
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $scene = Scene_Map.new
    RPG::BGM.fade(1500)
    close_command_window
    Graphics.fadeout(60)
    Graphics.wait(40)
    Graphics.frame_count = 0
    RPG::BGM.stop
    $game_map.autoplay
  end
  #--------------------------------------------------------------------------
  # * 命令項：讀取存檔
  #--------------------------------------------------------------------------
  def command_continue
    if @continue_enabled
      Sound.play_decision
      $scene = Scene_File.new(false, true, false)
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * 命令項：退出遊戲
  #--------------------------------------------------------------------------
  def command_shutdown
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # * 作戰測試
  #--------------------------------------------------------------------------
  def battle_test
    load_bt_database                  # 從資料庫中載入作戰測試所需資料
    create_game_objects               # 創建遊戲物件
    Graphics.frame_count = 0          # 初始化遊戲時間
    $game_party.setup_battle_test_members
    $game_troop.setup($data_system.test_troop_id)
    $game_troop.can_escape = true
    $game_system.battle_bgm.play
    snapshot_for_background
    $scene = Scene_Battle.new
  end
end
