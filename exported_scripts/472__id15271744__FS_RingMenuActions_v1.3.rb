#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_RingMenuActions v1.3
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_RingMenuActions v1.3」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Temp、Game_System、Scene_Title、Scene_RM2、Scene_SoulBookSelect、Scene_CharacterBook、Sword_Synthesize
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：UNLOCK_SWITCHES、COMMANDS、DRAGON_UNLOCK_SWITCH、WOLF_RIDER_SWITCH、RING_SWITCH、RESET_SWITCHES、ACTOR_ID、NORMAL_CHARACTER。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 7 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS RingMenu Actions；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Jump1。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ FS_RingMenuActions v1.3
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
#
# 將 Scene_RM2 的六個選項改為純腳本執行，不再依賴公共事件 145～150。
#
# 選項：
#   1. 魂譜     -> 角色魂譜／敵人魂譜
#   2. 交織     -> Sword_Synthesize
#   3. 騎乘     -> 騎狼／騎龍／下坐騎
#   4. 橡木聖地 -> 記錄原位置；原地透明化並播放動畫40，
#                    傳送後再次播放動畫40，動畫開始時立即解除透明；
#                    聖地出口可返回原位置
#   5. 小地圖   -> FS_NORMAL_MINIMAP.toggle
#   6. 檔案庫   -> Sword_Library
#
# 解鎖開關：
#   139 魂譜、140 交織、141 騎乘、142 橡木聖地、143 小地圖、144 檔案庫
#   185 騎龍解鎖
#
# 安裝位置：
#   FS_Scene_CharacterBook_v2_1
#   FS_Scene_EnemyBook v1.0
#   Sword_Synthesize / Sword_Library
#   乗り物拡張
#   RandomDungeon_v0_9_1_FS
#   FS_NormalMap_Minimap v1.0.4
#   FS_LegacyScripts_SafetyPatch v1.0.14
#   FS_RingMenuActions v1.3       ← 本腳本
#   FS_SaveCompatibilityCore
#   Main
#==============================================================================

$imported = {} if $imported == nil
$imported["FS RingMenu Actions"] = "1.3"

#==============================================================================
# ■ 暫存資料
#==============================================================================
class Game_Temp
  attr_accessor :fs_ring_return_index
  attr_accessor :fs_ring_subscene
  attr_accessor :fs_ring_mount_task
  attr_accessor :fs_soulbook_from_ring
  attr_accessor :fs_oak_transfer_mode
  attr_accessor :fs_oak_transfer_task
end

#==============================================================================
# ■ 橡木聖地返回資料
#   Game_System 會被核心存檔，因此每個存檔槽彼此獨立。
#==============================================================================
class Game_System
  attr_accessor :fs_oak_return_data
end

#==============================================================================
# ■ Ring Menu 設定與派送
#==============================================================================
module FS_RING_MENU_ACTIONS
  VERSION = "1.3"

  UNLOCK_SWITCHES = [139, 140, 141, 142, 143, 144]

  # [顯示名稱, 圖片名稱, 動作 Symbol]
  COMMANDS = [
    ["魂譜",     "cm_5", :soul_book],
    ["交織",     "cm_4", :synthesize],
    ["騎乘",     "cm_3", :ride],
    ["橡木聖地", "cm_2", :oak_sanctuary],
    ["小地圖",   "cm_1", :minimap],
    ["檔案庫",   "cm_6", :library]
  ]

  def self.build_commands
    $game_ring_cm = []
    COMMANDS.each do |row|
      $game_ring_cm << [row[0], Cache.picture(row[1]), row[2]]
    end
    refresh_dynamic_labels
    return $game_ring_cm
  end

  def self.refresh_dynamic_labels
    return if $game_ring_cm == nil || $game_ring_cm[3] == nil
    if defined?(FS_OAK_SANCTUARY) && FS_OAK_SANCTUARY.inside?
      $game_ring_cm[3][0] = "返回原處"
    else
      $game_ring_cm[3][0] = "橡木聖地"
    end
  end

  def self.unlocked?(index)
    switch_id = UNLOCK_SWITCHES[index]
    return true if switch_id == nil
    return $game_switches[switch_id] == true
  end

  def self.current_return_index
    return 0 if $game_temp == nil
    return $game_temp.fs_ring_return_index.to_i
  end

  def self.open_ring(index = nil, move = false)
    index = current_return_index if index == nil
    index = [[index.to_i, 0].max, COMMANDS.size - 1].min
    $game_temp.fs_ring_return_index = index if $game_temp != nil
    refresh_dynamic_labels
    $scene = Scene_RM2.new(index, move)
  end

  def self.dispose_screen_print
    if defined?(FS_LEGACY_SAFE) &&
       FS_LEGACY_SAFE.respond_to?(:safe_screen_print_dispose)
      FS_LEGACY_SAFE.safe_screen_print_dispose
      return
    end
    if defined?($screen_print) && $screen_print != nil
      begin
        $screen_print.dispose unless $screen_print.disposed?
      rescue
      end
      $screen_print = nil
    end
  end

  def self.show_message(text)
    return if $game_message == nil
    $game_message.texts.push(text.to_s)
  end

  # true：已切換 Scene／已執行；false：留在 Ring Menu
  def self.execute(action, index)
    $game_temp.fs_ring_return_index = index.to_i if $game_temp != nil
    case action
    when :soul_book
      $game_temp.fs_soulbook_from_ring = true
      $game_temp.fs_ring_subscene = :soul_book
      $scene = Scene_SoulBookSelect.new
      return true
    when :synthesize
      unless defined?(Sword_Synthesize)
        Sound.play_buzzer
        return false
      end
      $game_temp.fs_ring_subscene = :synthesize
      $scene = Sword_Synthesize.new
      return true
    when :ride
      unless defined?(Scene_FSRideSelect)
        Sound.play_buzzer
        return false
      end
      $game_temp.fs_ring_subscene = :ride
      $scene = Scene_FSRideSelect.new
      return true
    when :oak_sanctuary
      return FS_OAK_SANCTUARY.enter_or_return
    when :minimap
      unless defined?(FS_NORMAL_MINIMAP) &&
             FS_NORMAL_MINIMAP.respond_to?(:available?) &&
             FS_NORMAL_MINIMAP.respond_to?(:toggle)
        Sound.play_buzzer
        return false
      end
      unless FS_NORMAL_MINIMAP.available?
        Sound.play_buzzer
        return false
      end
      FS_NORMAL_MINIMAP.toggle
      $scene = Scene_Map.new
      return true
    when :library
      unless defined?(Sword_Library)
        Sound.play_buzzer
        return false
      end
      $game_temp.fs_ring_subscene = :library
      $scene = Sword_Library.new
      return true
    end
    Sound.play_buzzer
    return false
  rescue Exception => e
    Sound.play_buzzer
    p "FS Ring Menu action error: #{e.class}: #{e.message}"
    return false
  end
end

# 重新建立新版 Ring Menu 指令。
class Scene_Title < Scene_Base
  unless method_defined?(:fs_ring_actions_create_game_objects_v10)
    alias fs_ring_actions_create_game_objects_v10 create_game_objects
    def create_game_objects
      fs_ring_actions_create_game_objects_v10
      FS_RING_MENU_ACTIONS.build_commands
    end
  end
end

#==============================================================================
# ■ Scene_RM2：停用 eval／公共事件，改用 Symbol 派送
#==============================================================================
if defined?(Scene_RM2)
  class Scene_RM2 < Scene_Base
    def create_command_window
      FS_RING_MENU_ACTIONS.build_commands if $game_ring_cm == nil
      FS_RING_MENU_ACTIONS.refresh_dynamic_labels
      commands = []
      icons = []
      for i in 0...$game_ring_cm.size
        commands << $game_ring_cm[i][0]
        icons << $game_ring_cm[i][1]
      end
      @command_window = Window_RingMenu.new(
        240, 174, commands, icons, @move, @menu_index
      )
      FS_RING_MENU_ACTIONS::UNLOCK_SWITCHES.each_with_index do |switch_id, i|
        @command_window.disable_item(i) unless $game_switches[switch_id]
      end
    end

    def update_command_selection
      if Input.trigger?(Input::B)
        Sound.play_cancel
        FS_RING_MENU_ACTIONS.dispose_screen_print
        $scene = Scene_Map.new
        return
      end
      return unless Input.trigger?(Input::C)

      unless @command_window && @command_window.enabled?
        Sound.play_buzzer
        return
      end

      index = @command_window.index
      command = $game_ring_cm[index]
      unless command && FS_RING_MENU_ACTIONS.unlocked?(index)
        Sound.play_buzzer
        return
      end

      Sound.play_decision
      changed = FS_RING_MENU_ACTIONS.execute(command[2], index)
      FS_RING_MENU_ACTIONS.dispose_screen_print if changed
    end
  end
end

#==============================================================================
# ■ 魂譜分類選單
#==============================================================================
class Scene_SoulBookSelect < Scene_Base
  def start
    super
    create_menu_background
    @help_window = Window_Help.new
    @help_window.set_text("選擇要查閱的魂譜")
    @command_window = Window_Command.new(240, ["角色魂譜", "敵人魂譜"])
    @command_window.x = (Graphics.width - @command_window.width) / 2
    @command_window.y = @help_window.height + 72
  end

  def terminate
    super
    dispose_menu_background rescue nil
    @help_window.dispose if @help_window && !@help_window.disposed?
    @command_window.dispose if @command_window && !@command_window.disposed?
  end

  def update
    super
    @command_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $game_temp.fs_soulbook_from_ring = false
      $game_temp.fs_ring_subscene = nil
      FS_RING_MENU_ACTIONS.open_ring(0, false)
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0
        unless defined?(Scene_CharacterBook)
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        $game_temp.fs_soulbook_from_ring = true
        $scene = Scene_CharacterBook.new
      when 1
        unless defined?(Scene_EnemyBook)
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        $game_temp.fs_soulbook_from_ring = true
        $scene = Scene_EnemyBook.new
      end
    end
  end
end

# 角色魂譜若由分類選單進入，B 返回分類選單。
if defined?(Scene_CharacterBook)
  class Scene_CharacterBook < Scene_Base
    unless method_defined?(:fs_ring_soulbook_old_update_v10)
      alias fs_ring_soulbook_old_update_v10 update
      def update
        if Input.trigger?(Input::B) && $game_temp != nil &&
           $game_temp.fs_soulbook_from_ring == true
          Sound.play_cancel
          $scene = Scene_SoulBookSelect.new
          return
        end
        fs_ring_soulbook_old_update_v10
      end
    end
  end
end

#==============================================================================
# ■ 交織／檔案庫返回 Ring Menu
#==============================================================================
if defined?(Sword_Synthesize)
  class Sword_Synthesize
    unless method_defined?(:fs_ring_synthesize_old_update_v10)
      alias fs_ring_synthesize_old_update_v10 update
      def update
        if $game_temp != nil &&
           $game_temp.fs_ring_subscene == :synthesize &&
           @command_window != nil && @command_window.active &&
           Input.repeat?(Input::B)
          Sound.play_cancel
          $game_temp.fs_ring_subscene = nil
          FS_RING_MENU_ACTIONS.open_ring(1, false)
          return
        end
        fs_ring_synthesize_old_update_v10
      end
    end
  end
end

if defined?(Sword_Library)
  class Sword_Library
    unless method_defined?(:fs_ring_library_old_update_v10)
      alias fs_ring_library_old_update_v10 update
      def update
        if $game_temp != nil &&
           $game_temp.fs_ring_subscene == :library &&
           Input.trigger?(Input::B)
          Sound.play_cancel
          $game_temp.fs_ring_subscene = nil
          FS_RING_MENU_ACTIONS.open_ring(5, false)
          return
        end
        fs_ring_library_old_update_v10
      end
    end
  end
end

#==============================================================================
# ■ 騎乘
#==============================================================================
module FS_RING_MOUNT
  DRAGON_UNLOCK_SWITCH = 185
  WOLF_RIDER_SWITCH = 23
  RING_SWITCH = 37
  RESET_SWITCHES = [52, 53, 54, 55]
  ACTOR_ID = 1
  NORMAL_CHARACTER = "$actor01"
  WOLF_CHARACTER = "$actor01_r"
  FACE_NAME = "F96"
  FACE_INDEX = 0
  START_WAIT = 15

  def self.vehicle_type
    return -1 if $game_player == nil
    return $game_player.vehicle_type.to_i
  end

  def self.wolf?
    return vehicle_type == 3
  end

  def self.dragon?
    return vehicle_type == 4
  end

  def self.other_vehicle?
    return vehicle_type >= 0 && !wolf? && !dragon?
  end

  def self.dragon_unlocked?
    return $game_switches[DRAGON_UNLOCK_SWITCH] == true
  end

  def self.clear_repeat_animation
    if $game_player && $game_player.respond_to?(:repeat_anim=)
      $game_player.repeat_anim = 0
    end
  end

  def self.set_actor_graphic(character_name)
    actor = $game_actors[ACTOR_ID]
    return if actor == nil
    actor.set_graphic(character_name, 0, FACE_NAME, FACE_INDEX)
    $game_player.refresh if $game_player
  end

  def self.prepare(type)
    return false if $game_player == nil || $game_map == nil
    return false if vehicle_type >= 0

    vehicle = nil
    case type
    when :wolf
      vehicle = $game_map.horse if $game_map.respond_to?(:horse)
    when :dragon
      return false unless dragon_unlocked?
      vehicle = $game_map.big_airship if $game_map.respond_to?(:big_airship)
    end
    return false if vehicle == nil
    return false unless vehicle.respond_to?(:call_test_here)
    return false unless vehicle.call_test_here
    return false unless vehicle.respond_to?(:instant_call_here)
    return false unless vehicle.instant_call_here

    clear_repeat_animation
    RESET_SWITCHES.each { |id| $game_switches[id] = false }

    if type == :wolf
      set_actor_graphic(WOLF_CHARACTER)
      $game_switches[WOLF_RIDER_SWITCH] = true
      $game_switches[RING_SWITCH] = true
      $game_system.encounter_disabled = true
    else
      set_actor_graphic(NORMAL_CHARACTER)
      $game_switches[WOLF_RIDER_SWITCH] = false
      $game_switches[RING_SWITCH] = false
    end
    $game_system.menu_disabled = true
    $game_map.need_refresh = true if $game_map != nil

    $game_temp.fs_ring_mount_task = {
      :type => type,
      :phase => :wait,
      :wait => START_WAIT
    }
    return true
  rescue Exception => e
    p "FS Ring mount prepare error: #{e.class}: #{e.message}"
    return false
  end

  def self.update
    return if $game_temp == nil
    task = $game_temp.fs_ring_mount_task
    return if task == nil

    case task[:phase]
    when :wait
      task[:wait] = task[:wait].to_i - 1
      return if task[:wait] > 0
      begin
        RPG::SE.new("Jump1", 80, 100).play
      rescue
      end
      $game_player.jump(0, 0)
      task[:phase] = :jump
    when :jump
      return if $game_player.jumping?
      if task[:type] == :wolf
        $game_player.get_on_horse
      else
        # 必須呼叫正式 API，讓 FS_FLIGHT_VISUAL 接管 Fog／Overlay。
        $game_player.get_on_big_airship
      end
      $game_temp.fs_ring_mount_task = nil
    end
  rescue Exception => e
    p "FS Ring mount update error: #{e.class}: #{e.message}"
    $game_temp.fs_ring_mount_task = nil if $game_temp
    $game_system.menu_disabled = false if $game_system
    $game_system.encounter_disabled = false if $game_system
  end

  def self.dismount
    return false unless wolf? || dragon?
    return $game_player.get_off_vehicle
  rescue Exception => e
    p "FS Ring dismount error: #{e.class}: #{e.message}"
    return false
  end
end

# 騎乘演出期間鎖定玩家移動，避免瞬間召喚的載具被玩家甩在原地。
if defined?(Game_Player)
  class Game_Player < Game_Character
    unless method_defined?(:fs_ring_mount_old_movable_v10)
      alias fs_ring_mount_old_movable_v10 movable?
      def movable?
        if $game_temp != nil
          return false if $game_temp.fs_ring_mount_task != nil
          return false if $game_temp.fs_oak_transfer_task != nil
        end
        return fs_ring_mount_old_movable_v10
      end
    end
  end
end

if defined?(Scene_Map)
  class Scene_Map < Scene_Base
    unless method_defined?(:fs_ring_mount_old_update_v10)
      alias fs_ring_mount_old_update_v10 update
      def update
        fs_ring_mount_old_update_v10
        FS_RING_MOUNT.update
        FS_OAK_SANCTUARY.update_transfer_task if defined?(FS_OAK_SANCTUARY)
      end
    end
  end
end

class Scene_FSRideSelect < Scene_Base
  def start
    super
    create_menu_background
    @help_window = Window_Help.new
    create_command_window
  end

  def create_command_window
    @mode = :walk
    type = FS_RING_MOUNT.vehicle_type
    if type == 3
      @mode = :wolf
      commands = ["下坐騎", "取消"]
    elsif type == 4
      @mode = :dragon
      commands = ["降落", "取消"]
    elsif type >= 0
      @mode = :other
      commands = ["目前無法切換載具", "取消"]
    else
      commands = ["騎狼", "騎龍", "取消"]
    end
    @command_window = Window_Command.new(220, commands)
    @command_window.x = (Graphics.width - @command_window.width) / 2
    @command_window.y = @help_window.height + 64
    if @mode == :walk && !FS_RING_MOUNT.dragon_unlocked?
      @command_window.draw_item(1, false)
    elsif @mode == :other
      @command_window.draw_item(0, false)
    end
    refresh_help
  end

  def refresh_help(text = nil)
    if text != nil
      @help_window.set_text(text)
    elsif @mode == :walk
      @help_window.set_text("選擇騎乘方式")
    elsif @mode == :wolf
      @help_window.set_text("目前正在騎狼")
    elsif @mode == :dragon
      @help_window.set_text("目前正在騎龍飛行")
    else
      @help_window.set_text("目前使用其他載具")
    end
  end

  def terminate
    super
    dispose_menu_background rescue nil
    @help_window.dispose if @help_window && !@help_window.disposed?
    @command_window.dispose if @command_window && !@command_window.disposed?
  end

  def update
    super
    @command_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $game_temp.fs_ring_subscene = nil
      FS_RING_MENU_ACTIONS.open_ring(2, false)
      return
    end
    return unless Input.trigger?(Input::C)

    if @mode == :walk
      case @command_window.index
      when 0
        start_mount(:wolf)
      when 1
        unless FS_RING_MOUNT.dragon_unlocked?
          Sound.play_buzzer
          refresh_help("尚未取得騎龍能力。")
          return
        end
        start_mount(:dragon)
      when 2
        Sound.play_cancel
        $game_temp.fs_ring_subscene = nil
        FS_RING_MENU_ACTIONS.open_ring(2, false)
      end
    elsif @mode == :wolf || @mode == :dragon
      if @command_window.index == 0
        if FS_RING_MOUNT.dismount
          Sound.play_decision
          $game_temp.fs_ring_subscene = nil
          $scene = Scene_Map.new
        else
          Sound.play_buzzer
          refresh_help(@mode == :dragon ? "這裡不能降落！" : "這裡不能下坐騎！")
        end
      else
        Sound.play_cancel
        $game_temp.fs_ring_subscene = nil
        FS_RING_MENU_ACTIONS.open_ring(2, false)
      end
    else
      if @command_window.index == 1
        Sound.play_cancel
        $game_temp.fs_ring_subscene = nil
        FS_RING_MENU_ACTIONS.open_ring(2, false)
      else
        Sound.play_buzzer
      end
    end
  end

  def start_mount(type)
    unless FS_RING_MOUNT.prepare(type)
      Sound.play_buzzer
      refresh_help("這裡不能騎乘！")
      return
    end
    Sound.play_decision
    $game_temp.fs_ring_subscene = nil
    $scene = Scene_Map.new
  end
end

#==============================================================================
# ■ 橡木聖地
#==============================================================================
module FS_OAK_SANCTUARY
  MAP_ID = 13
  X = 5
  Y = 7
  DIRECTION = 2
  ENTRY_ANIMATION_ID = 40

  ACTIVE_SWITCH = 206
  RING_SWITCH = 37
  RESET_SWITCHES = [52, 53, 54, 55]
  RETURN_MAP_VARIABLE = 50
  RETURN_X_VARIABLE = 51
  RETURN_Y_VARIABLE = 52

  def self.inside?
    return false if $game_map == nil
    return $game_map.map_id.to_i == MAP_ID
  end

  def self.return_data
    return nil if $game_system == nil
    return $game_system.fs_oak_return_data
  end

  def self.random_dungeon_active?
    return false unless defined?(FS_RandomDungeon)
    return false unless FS_RandomDungeon.respond_to?(:active?)
    return FS_RandomDungeon.active?
  rescue
    return false
  end

  def self.player_in_vehicle?
    return false if $game_player == nil
    return $game_player.vehicle_type.to_i >= 0
  end

  def self.clear_repeat_animation
    if $game_player && $game_player.respond_to?(:repeat_anim=)
      $game_player.repeat_anim = 0
    end
  end

  # VX 的動畫每個資料庫影格顯示 4 個遊戲影格。
  # 與 Sprite_Base#start_animation 的計算保持一致。
  def self.animation_wait_frames(animation_id)
    animation = $data_animations[animation_id] rescue nil
    return 30 if animation == nil
    return [animation.frame_max.to_i * 4 + 1, 1].max
  end

  # 從 Ring Menu 返回地圖後才開始播放，避免動畫在 Scene_RM2 中無法顯示。
  #
  # 流程：
  #   原地透明化 ON＋動畫40
  #   → 傳送
  #   → 聖地保持透明＋動畫40
  #   → 動畫結束後透明化 OFF
  def self.update_transfer_task
    return if $game_temp == nil
    task = $game_temp.fs_oak_transfer_task
    return if task == nil

    case task[:phase]
    when :start
      clear_repeat_animation
      $game_player.transparent = true
      $game_player.animation_id = ENTRY_ANIMATION_ID
      task[:wait] = animation_wait_frames(ENTRY_ANIMATION_ID)
      task[:phase] = :depart_animation

    when :depart_animation
      task[:wait] = task[:wait].to_i - 1
      return if task[:wait] > 0

      $game_temp.fs_oak_transfer_mode = :enter
      $game_player.reserve_transfer(MAP_ID, X, Y, DIRECTION)
      task[:phase] = :transfer

    when :transfer
      # 等待 Game_Player#perform_transfer 完成。
      # after_transfer(:enter) 會將階段切換為 :arrival_start。

    when :arrival_start
      clear_repeat_animation
      $game_player.transparent = true
      $game_player.animation_id = ENTRY_ANIMATION_ID

      # 抵達聖地後，動畫一開始就解除透明。
      # 角色會直接從召喚動畫中顯現，不等待動畫播完。
      $game_player.transparent = false
      $game_map.need_refresh = true if $game_map != nil

      task[:wait] = animation_wait_frames(ENTRY_ANIMATION_ID)
      task[:phase] = :arrival_animation

    when :arrival_animation
      task[:wait] = task[:wait].to_i - 1
      return if task[:wait] > 0

      $game_temp.fs_oak_transfer_mode = nil
      $game_temp.fs_oak_transfer_task = nil

    else
      $game_player.transparent = false if $game_player
      $game_temp.fs_oak_transfer_mode = nil
      $game_temp.fs_oak_transfer_task = nil
    end
  rescue Exception => e
    p "FS Oak Sanctuary animation error: #{e.class}: #{e.message}"
    $game_player.transparent = false if $game_player
    $game_temp.fs_oak_transfer_task = nil if $game_temp
    $game_temp.fs_oak_transfer_mode = nil if $game_temp
  end

  def self.enter_or_return
    if inside?
      return return_to_origin
    end
    return enter
  end

  def self.enter
    if random_dungeon_active?
      Sound.play_buzzer
      FS_RING_MENU_ACTIONS.show_message("隨機地城中無法前往橡木聖地。")
      $scene = Scene_Map.new
      return true
    end
    if player_in_vehicle?
      Sound.play_buzzer
      FS_RING_MENU_ACTIONS.show_message("請先離開坐騎。")
      $scene = Scene_Map.new
      return true
    end
    if return_data != nil
      Sound.play_buzzer
      FS_RING_MENU_ACTIONS.show_message("已保存一個橡木聖地返回位置。")
      $scene = Scene_Map.new
      return true
    end

    states = {}
    ([ACTIVE_SWITCH, RING_SWITCH] + RESET_SWITCHES).each do |switch_id|
      states[switch_id] = $game_switches[switch_id]
    end
    $game_system.fs_oak_return_data = [
      $game_map.map_id, $game_player.x, $game_player.y,
      $game_player.direction, states
    ]

    # 保留舊公共事件所使用的變數，避免既有地圖事件失去相容性。
    $game_variables[RETURN_MAP_VARIABLE] = $game_map.map_id
    $game_variables[RETURN_X_VARIABLE] = $game_player.x
    $game_variables[RETURN_Y_VARIABLE] = $game_player.y

    clear_repeat_animation
    $game_switches[ACTIVE_SWITCH] = false
    $game_switches[RING_SWITCH] = false
    RESET_SWITCHES.each { |id| $game_switches[id] = false }
    $game_map.need_refresh = true if $game_map != nil

    # 先回到 Scene_Map，將角色透明化並播放動畫40；
    # 傳送到橡木聖地後再播放同一動畫，動畫開始時解除透明。
    $game_temp.fs_oak_transfer_mode = nil
    $game_temp.fs_oak_transfer_task = {
      :phase => :start,
      :wait => 0
    }
    $scene = Scene_Map.new unless $scene.is_a?(Scene_Map)
    return true
  rescue Exception => e
    Sound.play_buzzer
    p "FS Oak Sanctuary enter error: #{e.class}: #{e.message}"
    return false
  end

  # 橡木聖地出口事件也可以直接使用：
  #   FS_OAK_SANCTUARY.return_to_origin
  def self.return_to_origin
    data = return_data
    if data == nil
      Sound.play_buzzer
      FS_RING_MENU_ACTIONS.show_message("沒有可返回的位置紀錄。")
      return false
    end
    unless inside?
      Sound.play_buzzer
      FS_RING_MENU_ACTIONS.show_message("只能從橡木聖地返回原處。")
      return false
    end

    clear_repeat_animation
    $game_switches[ACTIVE_SWITCH] = false
    $game_switches[RING_SWITCH] = false
    RESET_SWITCHES.each { |id| $game_switches[id] = false }
    $game_map.need_refresh = true if $game_map != nil

    $game_temp.fs_oak_transfer_mode = :return
    $game_player.reserve_transfer(
      data[0].to_i, data[1].to_i, data[2].to_i, data[3].to_i
    )
    $scene = Scene_Map.new unless $scene.is_a?(Scene_Map)
    return true
  rescue Exception => e
    Sound.play_buzzer
    p "FS Oak Sanctuary return error: #{e.class}: #{e.message}"
    return false
  end

  def self.after_transfer(mode)
    return if mode == nil

    if mode == :enter
      if inside?
        $game_switches[ACTIVE_SWITCH] = true
        $game_map.need_refresh = true if $game_map != nil

        # 抵達聖地後先保持透明完成轉場。
        # 下一個 Scene_Map 更新影格會再次播放動畫40，
        # 並在動畫開始的同一影格解除透明，讓角色從動畫中顯現。
        if $game_temp && $game_temp.fs_oak_transfer_task
          $game_temp.fs_oak_transfer_mode = nil
          $game_temp.fs_oak_transfer_task[:phase] = :arrival_start
          $game_temp.fs_oak_transfer_task[:wait] = 0
          return
        end
      end

      # 非預期狀況的保險，避免角色永久透明。
      $game_player.transparent = false if $game_player

    elsif mode == :return
      data = return_data
      if data != nil
        states = data[4] || {}
        states.each { |switch_id, value| $game_switches[switch_id] = value }
        $game_map.need_refresh = true if $game_map != nil
      end
      $game_system.fs_oak_return_data = nil
      $game_variables[RETURN_MAP_VARIABLE] = 0
      $game_variables[RETURN_X_VARIABLE] = 0
      $game_variables[RETURN_Y_VARIABLE] = 0
      $game_player.transparent = false if $game_player
    end

    if $game_temp
      $game_temp.fs_oak_transfer_mode = nil
      $game_temp.fs_oak_transfer_task = nil
    end
  end
end

# 必須放在 RandomDungeon 的 perform_transfer 覆寫之後，讓兩者都能執行。
if defined?(Game_Player)
  class Game_Player < Game_Character
    unless method_defined?(:fs_oak_old_perform_transfer_v10)
      alias fs_oak_old_perform_transfer_v10 perform_transfer
      def perform_transfer
        mode = $game_temp == nil ? nil : $game_temp.fs_oak_transfer_mode
        fs_oak_old_perform_transfer_v10
        FS_OAK_SANCTUARY.after_transfer(mode)
      end
    end
  end
end
