#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_File
# 【用途】VX 存／讀檔場景共用父類，管理存檔列表、游標與檔案選擇。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_File
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
# ** Scene_File
#------------------------------------------------------------------------------
#  這個類用來執行顯示存取進度畫面的程式。
#==============================================================================

class Scene_File < Scene_Base
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     saving     : 存檔標幟（若為false則顯示讀檔的介面）
  #     from_title : 呼叫判斷標幟：由標題畫面的[讀取存檔]介面所呼叫
  #     from_event : 呼叫判斷標幟：由事件指令[打開存檔介面]所呼叫
  #--------------------------------------------------------------------------
  def initialize(saving, from_title, from_event)
    @saving = saving
    @from_title = from_title
    @from_event = from_event
  end
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @help_window = Window_Help.new
    create_savefile_windows
    if @saving
      @index = $game_temp.last_file_index
      @help_window.set_text(Vocab::SaveMessage)
    else
      @index = self.latest_file_index
      @help_window.set_text(Vocab::LoadMessage)
    end
    @savefile_windows[@index].selected = true
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    dispose_item_windows
  end
  #--------------------------------------------------------------------------
  # * 返回之前的畫面
  #--------------------------------------------------------------------------
  def return_scene
    if @from_title
      $scene = Scene_Title.new
    elsif @from_event
      $scene = Scene_Map.new
    else
      $scene = Scene_Menu.new(4)
    end
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    update_savefile_windows
    update_savefile_selection
  end
  #--------------------------------------------------------------------------
  # * 創建進度檔案資料視窗
  #--------------------------------------------------------------------------
  def create_savefile_windows
    @savefile_windows = []
    for i in 0..3
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    @item_max = 4
  end
  #--------------------------------------------------------------------------
  # * 清除進度檔案資料視窗
  #--------------------------------------------------------------------------
  def dispose_item_windows
    for window in @savefile_windows
      window.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 更新進度檔案資料視窗內容
  #--------------------------------------------------------------------------
  def update_savefile_windows
    for window in @savefile_windows
      window.update
    end
  end
  #--------------------------------------------------------------------------
  # * 更新進度存檔位元選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_savefile_selection
    if Input.trigger?(Input::C)
      determine_savefile
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    else
      last_index = @index
      if Input.repeat?(Input::DOWN)
        cursor_down(Input.trigger?(Input::DOWN))
      end
      if Input.repeat?(Input::UP)
        cursor_up(Input.trigger?(Input::UP))
      end
      if @index != last_index
        Sound.play_cursor
        @savefile_windows[last_index].selected = false
        @savefile_windows[@index].selected = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 判定要執行的行為是存檔行為還是讀檔行為
  #--------------------------------------------------------------------------
  def determine_savefile
    if @saving
      Sound.play_save
      do_save
    else
      if @savefile_windows[@index].file_exist
        Sound.play_load
        do_load
      else
        Sound.play_buzzer
        return
      end
    end
    $game_temp.last_file_index = @index
  end
  #--------------------------------------------------------------------------
  # * 游標下移
  #     wrap : 允許自動換行
  #--------------------------------------------------------------------------
  def cursor_down(wrap)
    if @index < @item_max - 1 or wrap
      @index = (@index + 1) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # * 游標上移
  #     wrap :允許自動換行
  #--------------------------------------------------------------------------
  def cursor_up(wrap)
    if @index > 0 or wrap
      @index = (@index - 1 + @item_max) % @item_max
    end
  end
  #--------------------------------------------------------------------------
  # * 創建存檔檔案名
  #     file_index : 進度檔位元編號
  #--------------------------------------------------------------------------
  def make_filename(file_index)
    return "Save#{file_index + 1}.rvdata"
  end
  #--------------------------------------------------------------------------
  # * 選擇時間戳記最新的進度
  #--------------------------------------------------------------------------
  def latest_file_index
    index = 0
    latest_time = Time.at(0)
    for i in 0...@savefile_windows.size
      if @savefile_windows[i].time_stamp > latest_time
        latest_time = @savefile_windows[i].time_stamp
        index = i
      end
    end
    return index
  end
  #--------------------------------------------------------------------------
  # * 執行存檔指令
  #--------------------------------------------------------------------------
  def do_save
    file = File.open(@savefile_windows[@index].filename, "wb")
    write_save_data(file)
    file.close
    return_scene
  end
  #--------------------------------------------------------------------------
  # * 執行讀檔指令
  #--------------------------------------------------------------------------
  def do_load
    file = File.open(@savefile_windows[@index].filename, "rb")
    read_save_data(file)
    file.close
    $scene = Scene_Map.new
    RPG::BGM.fade(1500)
    Graphics.fadeout(60)
    Graphics.wait(40)
    @last_bgm.play
    @last_bgs.play
  end
  #--------------------------------------------------------------------------
  # * 寫入進度檔案資料
  #     file : 寫入的檔案物件（開放）
  #--------------------------------------------------------------------------
  def write_save_data(file)
    characters = []
    for actor in $game_party.members
      characters.push([actor.character_name, actor.character_index])
    end
    $game_system.save_count += 1
    $game_system.version_id = $data_system.version_id
    @last_bgm = RPG::BGM::last
    @last_bgs = RPG::BGS::last
    Marshal.dump(characters,           file)
    Marshal.dump(Graphics.frame_count, file)
    Marshal.dump(@last_bgm,            file)
    Marshal.dump(@last_bgs,            file)
    Marshal.dump($game_system,         file)
    Marshal.dump($game_message,        file)
    Marshal.dump($game_switches,       file)
    Marshal.dump($game_variables,      file)
    Marshal.dump($game_self_switches,  file)
    Marshal.dump($game_actors,         file)
    Marshal.dump($game_party,          file)
    Marshal.dump($game_troop,          file)
    Marshal.dump($game_map,            file)
    Marshal.dump($game_player,         file)
  end
  #--------------------------------------------------------------------------
  # * 讀取進度檔案資料
  #     file : 供讀取的檔案物件
  #--------------------------------------------------------------------------
  def read_save_data(file)
    characters           = Marshal.load(file)
    Graphics.frame_count = Marshal.load(file)
    @last_bgm            = Marshal.load(file)
    @last_bgs            = Marshal.load(file)
    $game_system         = Marshal.load(file)
    $game_message        = Marshal.load(file)
    $game_switches       = Marshal.load(file)
    $game_variables      = Marshal.load(file)
    $game_self_switches  = Marshal.load(file)
    $game_actors         = Marshal.load(file)
    $game_party          = Marshal.load(file)
    $game_troop          = Marshal.load(file)
    $game_map            = Marshal.load(file)
    $game_player         = Marshal.load(file)
    if $game_system.version_id != $data_system.version_id
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
  end
end
