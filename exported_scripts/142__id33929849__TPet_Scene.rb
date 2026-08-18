#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：TPet_Scene
# 【用途】保留的 Runtime 元件「TPet_Scene」。
# 【主要機制】主要定義／擴充 TPet_Scene；下方原始說明與程式碼保留作細節依據。
# 【主要影響】TPet_Scene
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：back。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ TPet_Scene
#------------------------------------------------------------------------------
# 　ペットのシーンクラス
#==============================================================================
class TPet_Scene < Scene_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :pet
  attr_reader :item
  attr_reader :cursor
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(from_event = true)
    @from_event = from_event
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    create_menu_background
    @back_ground = Sprite.new
    @back_ground.bitmap = Cache.system("back")
    @back_ground.x = TPET::HOUSE_X
    @back_ground.y = TPET::HOUSE_Y
    $game_temp.map_bgm = RPG::BGM.last
    $game_temp.map_bgs = RPG::BGS.last
    RPG::BGM.stop
    RPG::BGS.stop
    Audio.bgm_play(TPET::BGM, 100, 100)
    @help_window = Window_Help.new
    @help_window.opacity = 255
    @help_window.visible = false
    @item_window = TPet_Window_Item.new(0, 56, 544, 152)
    @item_window.help_window = @help_window
    @item_window.visible = false
    @item_window.active = false
    @status_window = TPet_Status.new
    create_command_window
    @command_window.x = 195
    @command_window.y = 60
    create_pet    # ペットの作成
    @cursor = TPet_Cursor.new
    @item = []
  end
  #--------------------------------------------------------------------------
  # ● ペットの作成
  #--------------------------------------------------------------------------
  def create_pet
    @pet = []
    for i in 0...TPET::MAX_PET
      id = i * 6 + TPET::USE_VARIABLES_ID
      if $game_variables[id] > 0
        case $game_variables[id]
        when 1
          @pet[i] = TPet_Dog.new
        when 2
          @pet[i] = TPet_Cat.new
        when 3
          @pet[i] = TPet_Chicken.new
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = "          安撫"
    s2 = "          餵食"
    s3 = "          詳情"
    s4 = "          結束"
    @command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @command_window.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    dispose_menu_background
    $game_temp.map_bgm.play
    $game_temp.map_bgs.play
    @back_ground.dispose
    @help_window.dispose
    @item_window.dispose
    @command_window.dispose
    @status_window.dispose
    @cursor.dispose
    for i in 0...TPET::MAX_PET
      @pet[i].dispose if @pet[i] != nil
    end
    for i in 0...TPET::MAX_ITEM
      @item[i].dispose if @item[i] != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    for i in 0...TPET::MAX_PET
      @pet[i].update(i) if @pet[i] != nil
    end
    for i in 0...TPET::MAX_ITEM
      next if @item[i] == nil
      @item[i].update
      @item[i] = nil if @item[i].disposed?
    end
    @command_window.update
    if @command_window.active
      update_command
    elsif @item_window.active
      update_item
    elsif @status_window.visible
      update_status
    elsif @cursor.visible
      update_cursor
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウ更新
  #--------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @command_window.visible = false
      @command_window.active = false
      case @command_window.index
      when 0      # さわる
        @cursor.visible = true
        @cursor.move(272, 208)
      when 1  # 餌を与える
        @help_window.visible = true
        @item_window.visible = true
        @item_window.active = true
      when 2
        @status_window.refresh
        @status_window.visible = true
      when 3      # 終了
        return_scene
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウ更新
  #--------------------------------------------------------------------------
  def update_item
    @item_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.visible = true
      @command_window.active = true
      @help_window.visible = false
      @item_window.visible = false
      @item_window.active = false
    elsif Input.trigger?(Input::C)
      if @item_window.item != nil
        i = @item.index(nil)
        i = @item.size if i == nil and @item.size < TPET::MAX_ITEM
        if i != nil   # アイテムに空きがあれば
          Sound.play_decision
          @item[i] = TPet_Item.new(@item_window.item)
          $game_party.lose_item(@item_window.item, 1)
          @item_window.refresh
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウ更新
  #--------------------------------------------------------------------------
  def update_status
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.visible = true
      @command_window.active = true
      @status_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● おさわりタイム更新
  #--------------------------------------------------------------------------
  def update_cursor
    @cursor.update
    if Input.trigger?(Input::C)
      for i in 0...TPET::MAX_PET
        next if @pet[i] == nil
        @pet[i].touch(i) if @pet[i].cursor_hit?
      end
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.visible = true
      @command_window.active = true
      @cursor.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 元の画面へ戻る
  #--------------------------------------------------------------------------
  def return_scene
    if @from_event
      $scene = Scene_Map.new
    else
      $scene = Scene_Menu.new(4)
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム削除
  #--------------------------------------------------------------------------
  def erase_item(id)
    return if @item[id] == nil
    @item[id].dispose
    @item[id] = nil
  end
end


