#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ATS_DialogueExtension v1.7
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_ATS_DialogueExtension v1.7」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_ATS、Game_Message、Window_NameBox、Window_Message、Game_Interpreter、Spriteset_Battle、Window_BattleMessage
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：AUTO_FIT_DEFAULT、AUTO_WRAP_DEFAULT、NORMAL_WINDOWSKIN、NORMAL_BACKGROUND、DIM_BACKGROUND、TRANSPARENT_BACKGROUND、KEEP_DIM_IMAGE_NATIVE_SIZE、DIM_AUTO_CURRENT_EVENT。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 15 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS ATS Dialogue Extension；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_ATS_DialogueExtension v1.7
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 依賴：
#   Advanced Text System 3.0c
#   FS_LegacyScripts_SafetyPatch v1.0.14 以上
#
# 安裝位置：
#   ATS 3.0
#   其他會修改 Window_Message / Window_BattleMessage 的腳本
#   FS_LegacyScripts_SafetyPatch v1.0.14
#   本腳本
#   Main
#
# 功能：
#   1. 修正繁中姓名框寬度低估、右側切字。
#   2. 姓名框自動固定在對話框左上角。
#   3. 一般對話依實際文字自動調整寬度、高度，保留手動分行。
#   4. 地圖事件的普通對話，自動定位到目前事件，不必逐段 ats_next。
#   5. 提供對話設定檔，一次切換整段／全域風格。
#   6. 戰鬥事件可指定 Actor／Enemy，將 ATS 對話框置於 battler 頭上。
#   7. 依背景樣式分流：
#      正常＝Default 自動尺寸；暗化＝固定圖片尺寸，只自動換行。
#   8. 戰鬥背景樣式完整分流：
#      正常＝頭頂 ATS；暗化＝MessageBack；透明＝Battle_Message。
#   9. 戰鬥背景使用 Window 自己保存的模式，不再混讀 clear 後的全域值。
#  10. 特殊 ATS 戰鬥對話期間，阻止 Battle Log refresh 清空逐字文字。
#  11. 透明背景直接沿用原戰鬥訊息腳本的 @b_sprite／Battle_Message。
#  12. MessageBack 使用圖片專屬安全文字區與繁中自動換行。
#  13. 三種模式皆使用原 Window_BattleMessage#contents，不另建文字層。
#  14. 透明模式不再複製、重建或接管 Battle_Message 圖片 Bitmap。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS ATS Dialogue Extension"] = 1.70

module FS_ATS_DIALOGUE
  #--------------------------------------------------------------------------
  # ■ 一般對話框自動尺寸
  #--------------------------------------------------------------------------
  AUTO_FIT_DEFAULT = true
  AUTO_WRAP_DEFAULT = true

  # 事件編輯器「背景樣式：正常」使用的 windowskin。
  NORMAL_WINDOWSKIN = "Default"

  # 背景樣式：
  #   0 = 正常視窗
  #   1 = 暗化背景
  #   2 = 透明
  NORMAL_BACKGROUND = 0
  DIM_BACKGROUND = 1
  TRANSPARENT_BACKGROUND = 2

  # 暗化背景維持圖片原始尺寸，不依文字縮放。
  KEEP_DIM_IMAGE_NATIVE_SIZE = true

  # 地圖暗化背景若未明確指定說話者，尊重事件編輯器的上／中／下位置，
  # 不自動綁定目前事件。
  DIM_AUTO_CURRENT_EVENT = false

  # MessageBack 544×160 專用文字安全區。
  # Window contents 實際寬度為 512 px（544 - 32）。
  # 左側避開裝飾框；有立繪時依 FACE_SIDE 保留對應側空間。
  MESSAGEBACK_TEXT_LEFT = 36
  MESSAGEBACK_TEXT_RIGHT = 24
  MESSAGEBACK_FACE_RESERVE = 152
  MESSAGEBACK_MIN_TEXT_WIDTH = 120


  # 戰鬥事件的背景樣式對應：
  #   正常(0) → battler 頭頂 Default 視窗
  #   暗化(1) → ATS @back_sprite／MessageBack 固定大框
  #   透明(2) → 原戰鬥訊息腳本 @b_sprite／Battle_Message
  BATTLE_OVERHEAD_BACKGROUND = NORMAL_BACKGROUND
  BATTLE_MESSAGEBACK_BACKGROUND = DIM_BACKGROUND
  BATTLE_MESSAGE_GRAPHIC_BACKGROUND = TRANSPARENT_BACKGROUND

  # 保留事件編輯器中的手動分行；過長的單行仍會自動換行。
  PRESERVE_MANUAL_LINES = true

  MAP_MIN_WIDTH = 180
  MAP_MAX_WIDTH = 360

  BATTLE_MIN_WIDTH = 180
  BATTLE_MAX_WIDTH = 320

  # Windowskin 左右內距以外，再多留的安全像素。
  WIDTH_SAFETY_PADDING = 10

  MIN_LINES = 1
  MAX_LINES = 4

  #--------------------------------------------------------------------------
  # ■ 姓名框
  #--------------------------------------------------------------------------
  NAME_LEFT_PADDING = 12

  # 姓名框與主對話框上緣重疊的像素。
  NAME_EDGE_OVERLAP = 8

  # 修正字型量測誤差與右側切字。
  NAME_WIDTH_PADDING = 12

  #--------------------------------------------------------------------------
  # ■ 地圖事件定位
  #--------------------------------------------------------------------------
  AUTO_CURRENT_EVENT = true

  # 4：優先顯示於事件上方，空間不足時改到下方。
  AUTO_EVENT_CHAR_REF = 4

  #--------------------------------------------------------------------------
  # ■ 戰鬥頭頂對話
  #--------------------------------------------------------------------------
  BATTLE_GAP = 8

  # 戰鬥正常視窗沿用 ATS Speech Tag。
  BATTLE_USE_SPEECH_TAG = true

  # 視窗在 battler 上方時，ATS 的向下箭頭會有一部分與視窗重疊。
  # 這個值沿用原 ATS 的「tag height - 16」規則。
  SPEECH_TAG_WINDOW_OVERLAP = 16

  # 額外 Y 修正。負數往上，正數往下。
  ACTOR_Y_OFFSETS = {
    # Actor ID => Y offset
  }

  ENEMY_Y_OFFSETS = {
    # Enemy database ID => Y offset
  }

  #--------------------------------------------------------------------------
  # ■ 共用工具
  #--------------------------------------------------------------------------
  def self.font_for(name, size)
    font = Font.new
    font.name = name
    font.size = size.to_i
    return font
  end

  def self.convert_text(text)
    value = text.to_s.dup
    if defined?($game_message) && $game_message &&
       $game_message.respond_to?(:convert_special_characters)
      $game_message.convert_special_characters(value)
    end
    value.gsub!("\x16", "\x00")
    return value
  rescue
    return text.to_s
  end

  def self.line_width_from_result(max_width, line_space, draw_count)
    count = draw_count.to_i
    divisor = [count - 1, 0].max
    width = max_width.to_f - line_space.to_f * divisor
    width = 0 if width < 0
    return width.ceil
  end

  # 將已轉換過 ATS 控制碼的文字，依指定寬度切成實際顯示行。
  # 現有 \x00 手動分行會保留。
  def self.layout_converted_text(text, font, max_width)
    width = [max_width.to_i, 1].max
    work = text.to_s.dup
    work << "\x00" unless work[-1, 1] == "\x00"

    formatter = P_Formatter_ATS.new(font.dup)
    lines = []
    guard = 0

    until work.empty?
      guard += 1
      break if guard > 999

      before_size = work.size
      line_space, draw_count, justify =
        formatter.format_by_line(work, width)

      null_index = work.index("\x00")
      page_index = work.index("\x1d")

      if null_index == nil &&
         page_index != nil
        raw_line = work.slice!(0, page_index + 1)
        line_width = line_width_from_result(
          width, line_space, draw_count)
        lines.push([raw_line, line_width])
        next
      end

      if null_index == nil
        raw_line = work.dup
        work = ""
      else
        raw_line = work.slice!(0, null_index + 1)
      end

      line_width = line_width_from_result(
        width, line_space, draw_count)
      lines.push([raw_line, line_width])

      break if work.size >= before_size
    end

    formatter.dispose
    return lines
  rescue
    formatter.dispose if formatter &&
      formatter.respond_to?(:dispose)
    return [[text.to_s, 0]]
  end

  def self.message_source_text
    texts = $game_message.texts.dup
    unless $game_message.choice_window
      texts += $game_message.choices.dup
    end
    return texts.collect { |line| line.to_s }.join("\x00")
  end

  def self.name_from_source
    for line in $game_message.texts
      if line.to_s[/\\(?:NB|NAME)\[(.*?)\]/im]
        return $1.to_s
      end
    end
    return ""
  end

  def self.background_mode
    return NORMAL_BACKGROUND unless
      defined?($game_message) && $game_message
    return $game_message.background.to_i
  rescue
    return NORMAL_BACKGROUND
  end

  def self.battle_window?(window)
    return false unless defined?(Window_BattleMessage)
    return window.is_a?(Window_BattleMessage)
  end

  def self.battle_speech?(window)
    return false unless battle_window?(window)
    return false unless
      window.respond_to?(:fs_ats_battle_speech?)
    return window.fs_ats_battle_speech?
  end

  def self.dim_background?
    return background_mode == DIM_BACKGROUND
  end

  def self.battle_background_mode(window)
    if window &&
       window.respond_to?(:fs_ats_battle_background_mode)
      return window.fs_ats_battle_background_mode
    end
    return background_mode
  rescue
    return NORMAL_BACKGROUND
  end

  def self.battle_messageback_mode?(window)
    return false unless battle_speech?(window)
    return battle_background_mode(window) ==
      BATTLE_MESSAGEBACK_BACKGROUND
  end

  def self.battle_legacy_graphic_mode?(window)
    return false unless battle_speech?(window)
    return false unless
      defined?(Window_BattleMessage::GRAPHIC_NAME)
    return false if Window_BattleMessage::GRAPHIC_NAME == nil
    return battle_background_mode(window) ==
      BATTLE_MESSAGE_GRAPHIC_BACKGROUND
  rescue
    return false
  end

  def self.auto_fit_enabled_for?(window)
    return false unless defined?($game_message) && $game_message
    return false unless $game_message.fit_window_to_text

    # 地圖暗化背景使用 MessageBack 原始尺寸。
    return false if dim_background? && !battle_window?(window)

    if battle_window?(window)
      return false unless battle_speech?(window)
      return battle_background_mode(window) ==
        BATTLE_OVERHEAD_BACKGROUND
    end
    return true
  end

  def self.auto_wrap_enabled_for?(window)
    return false unless defined?($game_message) && $game_message

    enabled = true
    if $game_message.respond_to?(:fs_ats_auto_wrap)
      enabled = $game_message.fs_ats_auto_wrap
    end
    return false unless enabled

    if battle_window?(window)
      return battle_speech?(window)
    end
    return true
  end

  def self.normal_windowskin_available?
    return false if NORMAL_WINDOWSKIN.to_s.empty?
    Cache.system(NORMAL_WINDOWSKIN)
    return true
  rescue
    return false
  end

  def self.native_dim_window_size
    bmp = Cache.system($game_message.message_dim)
    width = bmp.width
    height = bmp.height - 32
    height = 33 if height < 33
    return [width, height]
  rescue
    return [
      $game_message.message_width,
      $game_message.message_height
    ]
  end

  def self.battle_graphic_window_size
    width = 400
    content_height = 96

    if defined?(Window_BattleMessage::BTWIDTH)
      width = Window_BattleMessage::BTWIDTH.to_i
    end
    if defined?(Window_BattleMessage::BTHEIGHT)
      content_height =
        Window_BattleMessage::BTHEIGHT.to_i
    end

    width = 33 if width < 33
    content_height = 24 if content_height < 24
    return [width, content_height + 32]
  rescue
    return [400, 128]
  end

  def self.apply_background_profile(window)
    return unless defined?($game_message) && $game_message

    case background_mode
    when NORMAL_BACKGROUND
      if normal_windowskin_available?
        $game_message.message_windowskin =
          NORMAL_WINDOWSKIN
      end
      size = nil
    when DIM_BACKGROUND
      size = KEEP_DIM_IMAGE_NATIVE_SIZE ?
             native_dim_window_size : nil
    when TRANSPARENT_BACKGROUND
      if battle_window?(window) &&
         battle_speech?(window)
        size = battle_graphic_window_size
      else
        size = nil
      end
    end

    if size != nil
      $game_message.message_width = size[0]
      $game_message.message_height = size[1]
      $game_message.max_lines = [
        (size[1] - 32) /
        [$game_message.wlh.to_i, 1].max,
        1
      ].max
    end
  rescue
  end

  def self.messageback_layout?(window)
    return false unless defined?($game_message) && $game_message

    if battle_window?(window) &&
       window.respond_to?(:fs_ats_battle_messageback?)
      return window.fs_ats_battle_messageback?
    end

    local_background = nil
    begin
      local_background =
        window.instance_variable_get("@background")
    rescue
      local_background = nil
    end

    return true if local_background.to_i == DIM_BACKGROUND
    return background_mode == DIM_BACKGROUND
  rescue
    return false
  end

  def self.messageback_face_present?
    return false unless defined?($game_message) && $game_message
    return false if $game_message.face_name == nil
    return !$game_message.face_name.to_s.empty?
  rescue
    return false
  end

  def self.messageback_text_area(window)
    content_width =
      window && window.contents ?
      window.contents.width.to_i : 0

    left = MESSAGEBACK_TEXT_LEFT
    right = MESSAGEBACK_TEXT_RIGHT

    if messageback_face_present?
      if $game_message.face_side
        left += MESSAGEBACK_FACE_RESERVE
      else
        right += MESSAGEBACK_FACE_RESERVE
      end
    end

    width = content_width - left - right
    if width < MESSAGEBACK_MIN_TEXT_WIDTH
      width = MESSAGEBACK_MIN_TEXT_WIDTH
    end

    if left + width > content_width
      width = [content_width - left, 1].max
    end

    return [left, width]
  rescue
    return [0, window.contents.width]
  end

  def self.max_window_width(window)
    if defined?(Window_BattleMessage) &&
       window.is_a?(Window_BattleMessage)
      return BATTLE_MAX_WIDTH
    end
    return MAP_MAX_WIDTH
  end

  def self.min_window_width(window)
    if defined?(Window_BattleMessage) &&
       window.is_a?(Window_BattleMessage)
      return BATTLE_MIN_WIDTH
    end
    return MAP_MIN_WIDTH
  end

  def self.name_text_width(name)
    font = font_for(
      $game_message.name_fontname,
      $game_message.name_fontsize
    )
    converted = convert_text(name)
    lines = layout_converted_text(converted, font, 5000)
    widths = lines.collect { |line| line[1] }
    return widths.empty? ? 0 : widths.max
  end

  def self.battle_default_y_offset(battler)
    return 0 if battler == nil

    if battler.actor?
      return ACTOR_Y_OFFSETS[battler.id].to_i
    end

    enemy_id = battler.respond_to?(:enemy_id) ?
               battler.enemy_id : 0
    return ENEMY_Y_OFFSETS[enemy_id].to_i
  end
end

#==============================================================================
# ■ Game_ATS：新遊戲預設啟用自動尺寸
#==============================================================================
if defined?(Game_ATS)
  class Game_ATS
    attr_accessor :fs_ats_auto_wrap

    alias fs_ats_dialogue_original_reset reset unless
      method_defined?(:fs_ats_dialogue_original_reset) ||
      private_method_defined?(:fs_ats_dialogue_original_reset)

    def reset
      fs_ats_dialogue_original_reset
      self.fit_window_to_text =
        FS_ATS_DIALOGUE::AUTO_FIT_DEFAULT
      self.fs_ats_auto_wrap =
        FS_ATS_DIALOGUE::AUTO_WRAP_DEFAULT
      self.message_windowskin =
        FS_ATS_DIALOGUE::NORMAL_WINDOWSKIN
      self.paragraph_format = false if
        FS_ATS_DIALOGUE::PRESERVE_MANUAL_LINES
      @fs_ats_dialogue_defaults_v1_1 = true
    end
  end
end

#==============================================================================
# ■ Game_Message：舊存檔遷移與戰鬥說話者資料
#==============================================================================
if defined?(Game_Message)
  class Game_Message
    attr_accessor :fs_ats_battle_kind
    attr_accessor :fs_ats_battle_id
    attr_accessor :fs_ats_battle_y_offset
    attr_accessor :fs_ats_battle_auto_name
    attr_accessor :fs_ats_auto_wrap

    alias fs_ats_dialogue_original_clear clear unless
      method_defined?(:fs_ats_dialogue_original_clear) ||
      private_method_defined?(:fs_ats_dialogue_original_clear)

    def clear
      if defined?($game_ats) && $game_ats &&
         !$game_ats.instance_variable_get(
           "@fs_ats_dialogue_defaults_v1_1")
        $game_ats.fit_window_to_text =
          FS_ATS_DIALOGUE::AUTO_FIT_DEFAULT
        $game_ats.fs_ats_auto_wrap =
          FS_ATS_DIALOGUE::AUTO_WRAP_DEFAULT
        $game_ats.message_windowskin =
          FS_ATS_DIALOGUE::NORMAL_WINDOWSKIN
        $game_ats.paragraph_format = false if
          FS_ATS_DIALOGUE::PRESERVE_MANUAL_LINES
        $game_ats.instance_variable_set(
          "@fs_ats_dialogue_defaults_v1_1", true)
      end

      fs_ats_dialogue_original_clear

      @fs_ats_auto_wrap =
        $game_ats.fs_ats_auto_wrap if
        defined?($game_ats) && $game_ats &&
        $game_ats.respond_to?(:fs_ats_auto_wrap)

      @fs_ats_battle_kind = nil
      @fs_ats_battle_id = nil
      @fs_ats_battle_y_offset = 0
      @fs_ats_battle_auto_name = nil
    end
  end
end

#==============================================================================
# ■ Window_NameBox：使用真正姓名字型量測寬度
#------------------------------------------------------------------------------
# 原 ATS 在 Window_WordBox 建立初期以預設字型量測，
# 之後才改成 NAME_FONTSIZE。繁中與較大字型因此容易少算寬度。
#==============================================================================
if defined?(Window_NameBox) &&
   defined?(Window_WordBox)
  class Window_NameBox < Window_WordBox
    def initialize(name, viewport = nil)
      @word_sprite = Sprite_Base.new(viewport)

      wlh = $game_message.name_wlh > 0 ?
            $game_message.name_wlh :
            $game_message.wlh
      rows = name.to_s.scan(/\x00/).size + 1
      height = [
        ($game_message.name_border_size * 2) +
        rows * wlh,
        33
      ].max

      text_width =
        FS_ATS_DIALOGUE.name_text_width(name)
      width = [
        text_width +
        ($game_message.name_border_size * 2) +
        FS_ATS_DIALOGUE::NAME_WIDTH_PADDING,
        33
      ].max
      width = [width, Graphics.width].min

      super(viewport, name, 0, 0,
            width, height, true)

      self.viewport = viewport
      @word_sprite.x =
        $game_message.name_border_size
      @word_sprite.y =
        $game_message.name_border_size
      @word_sprite.bitmap = Bitmap.new(
        [self.width -
         2 * $game_message.name_border_size, 1].max,
        [self.height -
         2 * $game_message.name_border_size, 1].max
      )
      @word_sprite.bitmap.font.name =
        $game_message.name_fontname
      @word_sprite.bitmap.font.size =
        $game_message.name_fontsize
      @word_sprite.bitmap.font.color =
        text_color($game_message.name_fontcolour)

      @contents_x = 2
      @line_x = 2
      draw_word(name, @word_sprite.bitmap)
    end
  end
end

#==============================================================================
# ■ Window_Message：姓名左上角、自動尺寸與保留手動分行的自動換行
#==============================================================================
if defined?(Window_Message)
  class Window_Message
    alias fs_ats_dialogue_original_fit_window_to_text \
      fit_window_to_text unless
      method_defined?(
        :fs_ats_dialogue_original_fit_window_to_text) ||
      private_method_defined?(
        :fs_ats_dialogue_original_fit_window_to_text)

    def fit_window_to_text
      if FS_ATS_DIALOGUE.dim_background?
        FS_ATS_DIALOGUE.apply_background_profile(self)
        return
      end

      unless FS_ATS_DIALOGUE.auto_fit_enabled_for?(self)
        return fs_ats_dialogue_original_fit_window_to_text
      end

      max_window =
        FS_ATS_DIALOGUE.max_window_width(self)
      min_window =
        FS_ATS_DIALOGUE.min_window_width(self)
      max_content = [max_window - 32, 1].max

      font = FS_ATS_DIALOGUE.font_for(
        $game_message.message_fontname,
        $game_message.message_fontsize
      )
      converted = FS_ATS_DIALOGUE.convert_text(
        FS_ATS_DIALOGUE.message_source_text
      )
      lines = FS_ATS_DIALOGUE.layout_converted_text(
        converted, font, max_content
      )

      widths = lines.collect { |line| line[1] }
      longest = widths.empty? ? 0 : widths.max

      name = FS_ATS_DIALOGUE.name_from_source
      unless name.empty?
        name_width =
          FS_ATS_DIALOGUE.name_text_width(name)
        longest = [longest, name_width + 8].max
      end

      target_width =
        32 + longest +
        FS_ATS_DIALOGUE::WIDTH_SAFETY_PADDING
      target_width = [
        [target_width, min_window].max,
        max_window
      ].min

      line_count = [
        [lines.size, FS_ATS_DIALOGUE::MIN_LINES].max,
        FS_ATS_DIALOGUE::MAX_LINES
      ].min

      $game_message.message_width = target_width
      $game_message.message_height =
        32 + line_count * @wlh
      $game_message.max_lines = line_count
      $game_message.choice_on_line = false if
        target_width +
        $game_message.choice_width >
        Graphics.width
    rescue
      fs_ats_dialogue_original_fit_window_to_text
    end

    alias fs_ats_dialogue_original_set_name_position \
      set_name_position unless
      method_defined?(
        :fs_ats_dialogue_original_set_name_position) ||
      private_method_defined?(
        :fs_ats_dialogue_original_set_name_position)

    def set_name_position(
      x = $game_message.name_x,
      y = $game_message.name_y
    )
      return if @name_window == nil ||
                @name_window.disposed?

      if x == -1
        x = self.x +
            FS_ATS_DIALOGUE::NAME_LEFT_PADDING
      end

      if y == -1
        y = self.y -
            @name_window.height +
            FS_ATS_DIALOGUE::NAME_EDGE_OVERLAP
        y = 0 if y < 0
      end

      x = [[x, 0].max,
           Graphics.width -
           @name_window.width].min
      y = [[y, 0].max,
           Graphics.height -
           @name_window.height].min

      @name_window.x = x
      @name_window.y = y
    end

    alias fs_ats_dialogue_original_contents_width \
      contents_width unless
      method_defined?(
        :fs_ats_dialogue_original_contents_width) ||
      private_method_defined?(
        :fs_ats_dialogue_original_contents_width)

    def contents_width(y = 0)
      if FS_ATS_DIALOGUE.messageback_layout?(self)
        return FS_ATS_DIALOGUE.messageback_text_area(self)
      end
      return fs_ats_dialogue_original_contents_width(y)
    end

    def fs_ats_dialogue_auto_wrap?
      return FS_ATS_DIALOGUE.auto_wrap_enabled_for?(
        self)
    end

    # 原 ATS 在 position_to_character 中負責建立 NPC Speech Tag。
    # 擴充版不覆寫該行為，只在自動定位後確認 tag 與角色定位同步。
    def fs_ats_dialogue_map_speech_tag?
      return false if $game_temp.in_battle
      return false unless $game_message
      return false if $game_message.character.to_i < 0
      return false if $game_message.speech_tag_index.to_i < 0
      return true
    rescue
      return false
    end

    def fs_ats_dialogue_wrap_current_text
      return unless fs_ats_dialogue_auto_wrap?
      return if @text == nil || @text.empty?
      return if $game_message.paragraph_format

      width = @contents_width
      width = contents.width if
        width == nil || width <= 0
      font = self.contents.font.dup

      lines = FS_ATS_DIALOGUE.layout_converted_text(
        @text, font, width
      )
      wrapped = ""
      lines.each { |line| wrapped += line[0] }
      @text = wrapped

      new_page
      format_line if respond_to?(:format_line)
    rescue
    end

    alias fs_ats_dialogue_original_start_message \
      start_message unless
      method_defined?(
        :fs_ats_dialogue_original_start_message) ||
      private_method_defined?(
        :fs_ats_dialogue_original_start_message)

    def start_message(*args)
      FS_ATS_DIALOGUE.apply_background_profile(self)
      fs_ats_dialogue_original_start_message(*args)
      fs_ats_dialogue_wrap_current_text
    end
  end
end

#==============================================================================
# ■ Game_Interpreter：地圖自動說話者、設定檔與戰鬥說話者 API
#==============================================================================
if defined?(Game_Interpreter)
  class Game_Interpreter
    #--------------------------------------------------------------------------
    # 對話設定檔
    #--------------------------------------------------------------------------
    def ats_dialogue_auto
      ats_all(:fit_window_to_text, true)
      ats_all(:paragraph_format, false)
      ats_dialogue_wrap(true)
      return true
    end

    def ats_dialogue_fixed(width = 544,
                           height = 128)
      ats_all(:fit_window_to_text, false)
      ats_all(:message_width, width.to_i)
      ats_all(:message_height, height.to_i)
      ats_dialogue_wrap(true)
      return true
    end

    def ats_dialogue_wrap(value = true)
      value = value ? true : false
      $game_ats.fs_ats_auto_wrap = value if
        defined?($game_ats) && $game_ats
      $game_message.fs_ats_auto_wrap = value if
        defined?($game_message) && $game_message
      return true
    end

    def ats_dialogue_reset
      $game_ats.reset
      $game_message.clear
      return true
    end

    def ats_dialogue_speed(speed = 1)
      ats_all(:message_speed, speed.to_i)
      return true
    end

    def ats_dialogue_tag(index = 0)
      ats_all(:speech_tag_index, index.to_i)
      return true
    end

    #--------------------------------------------------------------------------
    # 地圖說話者
    #--------------------------------------------------------------------------
    def ats_speaker_auto
      @fs_ats_map_speaker = nil
      return true
    end

    def ats_speaker_event(
      event_id = nil,
      char_ref = FS_ATS_DIALOGUE::AUTO_EVENT_CHAR_REF
    )
      event_id = @event_id if event_id == nil
      @fs_ats_map_speaker =
        [:event, event_id.to_i, char_ref.to_i]
      return true
    end

    def ats_speaker_player(
      char_ref = FS_ATS_DIALOGUE::AUTO_EVENT_CHAR_REF
    )
      @fs_ats_map_speaker =
        [:player, 0, char_ref.to_i]
      return true
    end

    def ats_speaker_none
      @fs_ats_map_speaker = [:none, -1, 0]
      return true
    end

    #--------------------------------------------------------------------------
    # 戰鬥說話者
    #--------------------------------------------------------------------------
    # Actor 使用資料庫 Actor ID。
    def ats_battle_actor(
      actor_id,
      y_offset = 0,
      auto_name = true
    )
      @fs_ats_battle_speaker = [
        :actor,
        actor_id.to_i,
        y_offset.to_i,
        auto_name
      ]
      return true
    end

    # Enemy 使用畫面／隊伍中的第幾隻，從 1 開始。
    def ats_battle_enemy(
      position,
      y_offset = 0,
      auto_name = true
    )
      @fs_ats_battle_speaker = [
        :enemy,
        position.to_i - 1,
        y_offset.to_i,
        auto_name
      ]
      return true
    end

    # 原始 0-based index 版本。
    def ats_battle_enemy_index(
      index,
      y_offset = 0,
      auto_name = true
    )
      @fs_ats_battle_speaker = [
        :enemy,
        index.to_i,
        y_offset.to_i,
        auto_name
      ]
      return true
    end

    def ats_battle_active(
      y_offset = 0,
      auto_name = true
    )
      @fs_ats_battle_speaker = [
        :active,
        0,
        y_offset.to_i,
        auto_name
      ]
      return true
    end

    def ats_battle_clear
      @fs_ats_battle_speaker = nil
      return true
    end

    def fs_ats_dialogue_map_target
      data = @fs_ats_map_speaker

      if data == nil &&
         FS_ATS_DIALOGUE::AUTO_CURRENT_EVENT &&
         @event_id.to_i > 0
        return [@event_id.to_i,
                FS_ATS_DIALOGUE::
                AUTO_EVENT_CHAR_REF]
      end

      return nil if data == nil
      return nil if data[0] == :none
      return [0, data[2]] if data[0] == :player
      return [data[1], data[2]]
    end

    def fs_ats_dialogue_battle_battler(data)
      return nil if data == nil

      case data[0]
      when :actor
        return $game_actors[data[1]]
      when :enemy
        return $game_troop.members[data[1]]
      when :active
        if defined?($scene) && $scene
          return $scene.instance_variable_get(
            "@active_battler")
        end
      end
      return nil
    rescue
      return nil
    end

    alias fs_ats_dialogue_original_command_101 \
      command_101 unless
      method_defined?(
        :fs_ats_dialogue_original_command_101) ||
      private_method_defined?(
        :fs_ats_dialogue_original_command_101)

    def command_101(*args)
      battle_data = nil
      battle_battler = nil

      if $game_temp.in_battle
        battle_data = @fs_ats_battle_speaker
        battle_battler =
          fs_ats_dialogue_battle_battler(
            battle_data)

        if battle_data != nil &&
           battle_battler != nil
          $game_message.fs_ats_battle_kind =
            battle_data[0]
          $game_message.fs_ats_battle_id =
            battle_data[1]
          $game_message.fs_ats_battle_y_offset =
            battle_data[2]
          $game_message.fs_ats_battle_auto_name =
            battle_data[3]
        end
      else
        map_target =
          fs_ats_dialogue_map_target

        command_background = 0
        begin
          command_background = @params[2].to_i
        rescue
          command_background = 0
        end

        # 暗化背景通常是固定全幅 MessageBack／立繪對話。
        # 未明確呼叫 ats_speaker_event/player 時，尊重事件編輯器位置。
        if command_background ==
           FS_ATS_DIALOGUE::DIM_BACKGROUND &&
           !FS_ATS_DIALOGUE::DIM_AUTO_CURRENT_EVENT &&
           @fs_ats_map_speaker == nil
          map_target = nil
        end

        current_character =
          $game_message.character == nil ?
          -1 : $game_message.character.to_i
        if map_target != nil &&
           current_character < 0
          $game_message.character =
            map_target[0]
          $game_message.char_ref =
            map_target[1]
        end
      end

      result =
        fs_ats_dialogue_original_command_101(
          *args)

      if result &&
         $game_temp.in_battle &&
         battle_data != nil &&
         battle_battler != nil &&
         battle_data[3] &&
         $game_message.texts &&
         !$game_message.texts.empty?
        has_name = false
        for line in $game_message.texts
          if line.to_s[
            /\\(?:NB|NAME)\[(.*?)\]/im
          ]
            has_name = true
            break
          end
        end
        unless has_name
          $game_message.texts[0] =
            "\\nb[" +
            battle_battler.name.to_s +
            "]" +
            $game_message.texts[0].to_s
        end
      end

      return result
    end
  end
end

#==============================================================================
# ■ Spriteset_Battle：依 battler 取得真正的 Tankentai Sprite_Battler
#==============================================================================
if defined?(Spriteset_Battle)
  class Spriteset_Battle
    def fs_ats_sprite_for_battler(battler)
      return nil if battler == nil

      sprites = []
      actor_sprites =
        instance_variable_get("@actor_sprites")
      enemy_sprites =
        instance_variable_get("@enemy_sprites")
      sprites += actor_sprites if
        actor_sprites.is_a?(Array)
      sprites += enemy_sprites if
        enemy_sprites.is_a?(Array)

      for sprite in sprites
        next if sprite == nil
        next unless sprite.respond_to?(:battler)
        return sprite if
          sprite.battler.equal?(battler)
      end
      return nil
    rescue
      return nil
    end
  end
end

#==============================================================================
# ■ Window_BattleMessage：三種背景模式的單一路由
#------------------------------------------------------------------------------
# 重要：
#   Window_Message 的 @back_sprite 與戰鬥腳本的 @b_sprite 是兩個獨立 Sprite。
#   本版不再依賴「原方法先顯示、補丁後隱藏」。
#
#   update_back_sprite 完全由本類接管：
#     mode 1 才允許 MessageBack 顯示，其餘模式從源頭保持 hidden。
#
#   Battle_Message @b_sprite：
#     普通戰鬥記錄照舊顯示；
#     特殊 ATS 對話只有 mode 2 才顯示。
#==============================================================================
if defined?(Window_BattleMessage)
  class Window_BattleMessage < Window_Message
    alias fs_ats_battle_dialogue_original_initialize \
      initialize unless
      method_defined?(
        :fs_ats_battle_dialogue_original_initialize) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_initialize)

    def initialize(*args)
      fs_ats_battle_dialogue_original_initialize(*args)
      @fs_ats_battle_default_rect = [
        self.x, self.y, self.width, self.height
      ]
      @fs_ats_battle_speech_active = false
      @fs_ats_battle_background_mode =
        FS_ATS_DIALOGUE::NORMAL_BACKGROUND
      @fs_ats_back_sprite_mode = nil
    end

    #--------------------------------------------------------------------------
    # 狀態
    #--------------------------------------------------------------------------
    def fs_ats_battle_speech_requested?
      return false unless defined?($game_message) && $game_message
      return $game_message.fs_ats_battle_kind != nil
    rescue
      return false
    end

    def fs_ats_battle_speech?
      return true if @fs_ats_battle_speech_active
      return fs_ats_battle_speech_requested?
    end

    def fs_ats_battle_background_mode
      if @fs_ats_battle_speech_active
        return @fs_ats_battle_background_mode.to_i
      end
      return $game_message.background.to_i if
        defined?($game_message) && $game_message
      return FS_ATS_DIALOGUE::NORMAL_BACKGROUND
    rescue
      return FS_ATS_DIALOGUE::NORMAL_BACKGROUND
    end

    def fs_ats_capture_battle_mode
      @fs_ats_battle_speech_active =
        fs_ats_battle_speech_requested?
      if @fs_ats_battle_speech_active
        @fs_ats_battle_background_mode =
          $game_message.background.to_i
      end
    end

    def fs_ats_battle_overhead?
      return fs_ats_battle_speech? &&
        fs_ats_battle_background_mode ==
        FS_ATS_DIALOGUE::BATTLE_OVERHEAD_BACKGROUND
    end

    def fs_ats_battle_messageback?
      return fs_ats_battle_speech? &&
        fs_ats_battle_background_mode ==
        FS_ATS_DIALOGUE::BATTLE_MESSAGEBACK_BACKGROUND
    end

    def fs_ats_battle_legacy_dialogue?
      return fs_ats_battle_speech? &&
        fs_ats_battle_background_mode ==
        FS_ATS_DIALOGUE::BATTLE_MESSAGE_GRAPHIC_BACKGROUND
    end

    #--------------------------------------------------------------------------
    # Battler / sprite
    #--------------------------------------------------------------------------
    def fs_ats_battle_battler
      return nil unless fs_ats_battle_speech?

      case $game_message.fs_ats_battle_kind
      when :actor
        return $game_actors[$game_message.fs_ats_battle_id]
      when :enemy
        return $game_troop.members[
          $game_message.fs_ats_battle_id]
      when :active
        if defined?($scene) && $scene
          return $scene.instance_variable_get("@active_battler")
        end
      end
      return nil
    rescue
      return nil
    end

    def fs_ats_battle_sprite
      return nil unless defined?($scene) && $scene
      spriteset = $scene.instance_variable_get("@spriteset")
      return nil unless spriteset &&
        spriteset.respond_to?(:fs_ats_sprite_for_battler)
      return spriteset.fs_ats_sprite_for_battler(
        fs_ats_battle_battler)
    rescue
      return nil
    end

    #--------------------------------------------------------------------------
    # MessageBack 使用 ATS 背景 Sprite；Battle_Message 沿用原 @b_sprite
    #--------------------------------------------------------------------------
    def fs_ats_dispose_current_back_sprite
      return if @back_sprite == nil

      if @back_sprite.bitmap &&
         !@back_sprite.bitmap.disposed?
        @back_sprite.bitmap.dispose
      end
      @back_sprite.dispose unless @back_sprite.disposed?
      @back_sprite = nil
    rescue
      @back_sprite = nil
    end

    def fs_ats_build_messageback_sprite
      fs_ats_dispose_current_back_sprite

      @back_sprite = Sprite.new(self.viewport)
      source = Cache.system($game_message.message_dim)
      @back_sprite.bitmap =
        Bitmap.new(self.width, self.height + 32)
      @back_sprite.bitmap.stretch_blt(
        @back_sprite.bitmap.rect,
        source,
        source.rect
      )
      @back_sprite.visible = false
      @back_sprite.opacity = 0
      @back_sprite.z = self.z - 10
      @fs_ats_back_sprite_mode = :messageback
    rescue
      @fs_ats_back_sprite_mode = nil
    end

    def fs_ats_ensure_messageback_sprite
      if @back_sprite == nil ||
         @back_sprite.disposed? ||
         @back_sprite.bitmap == nil ||
         @back_sprite.bitmap.disposed? ||
         @fs_ats_back_sprite_mode != :messageback
        fs_ats_build_messageback_sprite
      end
    end

    def fs_ats_hide_ats_back_sprite
      return if @back_sprite == nil ||
                @back_sprite.disposed?
      @back_sprite.visible = false
      @back_sprite.opacity = 0
    rescue
    end

    def fs_ats_show_messageback_sprite
      fs_ats_ensure_messageback_sprite
      return if @back_sprite == nil ||
                @back_sprite.disposed?

      @back_sprite.x = self.x
      @back_sprite.y = self.y
      @back_sprite.z = self.z - 10
      @back_sprite.opacity = self.openness
      @back_sprite.visible = true
    rescue
    end

    def fs_ats_battle_uses_window_contents?
      return true
    end

    #--------------------------------------------------------------------------
    # 原戰鬥記錄背景 @b_sprite
    #--------------------------------------------------------------------------
    def fs_ats_battle_legacy_graphic
      return instance_variable_get("@b_sprite")
    rescue
      return nil
    end

    def fs_ats_hide_legacy_battle_graphic(reset = false)
      sprite = fs_ats_battle_legacy_graphic
      return if sprite == nil
      sprite.visible = false
      if reset
        sprite.opacity = 0
        sprite.src_rect.height = 16 if sprite.src_rect
      end
    rescue
    end

    def fs_ats_show_legacy_battle_graphic
      sprite = fs_ats_battle_legacy_graphic
      return if sprite == nil
      sprite.visible = true
      sprite.x = self.x
      sprite.y = self.y
      sprite.z = self.z - 10
    rescue
    end

    def fs_ats_route_legacy_battle_graphic
      # 普通 Battle Log 與「透明背景」特殊對話，都沿用原 @b_sprite。
      # 正常／暗化模式才隱藏原 Battle_Message。
      if fs_ats_battle_speech?
        if fs_ats_battle_legacy_dialogue?
          fs_ats_show_legacy_battle_graphic
        else
          fs_ats_hide_legacy_battle_graphic(true)
        end
      else
        fs_ats_show_legacy_battle_graphic
      end
    end

    #--------------------------------------------------------------------------
    # MessageBack：從源頭接管，不呼叫原 update_back_sprite
    #--------------------------------------------------------------------------
    alias fs_ats_battle_dialogue_original_create_back_sprite \
      create_back_sprite unless
      method_defined?(
        :fs_ats_battle_dialogue_original_create_back_sprite) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_create_back_sprite)

    def create_back_sprite(*args)
      fs_ats_build_messageback_sprite
      fs_ats_hide_ats_back_sprite
    end

    # 不呼叫 ATS 原 update_back_sprite。
    # @back_sprite 只負責暗化背景 MessageBack；
    # 透明背景使用原戰鬥訊息腳本自己的 @b_sprite。
    def update_back_sprite(*args)
      if fs_ats_battle_messageback?
        fs_ats_show_messageback_sprite
      else
        fs_ats_hide_ats_back_sprite
      end
    rescue
      fs_ats_hide_ats_back_sprite
    end

    #--------------------------------------------------------------------------
    # Speech Tag
    #--------------------------------------------------------------------------
    def fs_ats_battle_tag_extra
      return 0 unless FS_ATS_DIALOGUE::BATTLE_USE_SPEECH_TAG
      return 0 unless @speechtag_sprite
      return 0 if $game_message.speech_tag_index.to_i < 0

      height = @speechtag_sprite.height.to_i
      extra = height -
        FS_ATS_DIALOGUE::SPEECH_TAG_WINDOW_OVERLAP
      return [extra, 0].max
    rescue
      return 0
    end

    def fs_ats_hide_battle_speech_tag
      @speechtag_sprite.visible = false if @speechtag_sprite
    rescue
    end

    def fs_ats_position_battle_speech_tag(centre_x)
      return fs_ats_hide_battle_speech_tag unless
        FS_ATS_DIALOGUE::BATTLE_USE_SPEECH_TAG
      return fs_ats_hide_battle_speech_tag unless
        fs_ats_battle_overhead?
      return fs_ats_hide_battle_speech_tag unless
        @speechtag_sprite
      return fs_ats_hide_battle_speech_tag if
        $game_message.speech_tag_index.to_i < 0

      @speechtag_sprite.reset_graphic
      @speechtag_sprite.set_direction(0)
      @speechtag_sprite.opacity =
        $game_message.message_opacity
      @speechtag_sprite.x =
        centre_x.to_i - @speechtag_sprite.width / 2
      @speechtag_sprite.y =
        self.y + self.height -
        FS_ATS_DIALOGUE::SPEECH_TAG_WINDOW_OVERLAP
      @speechtag_sprite.z = self.z + 1
      @speechtag_sprite.visible = true
    rescue
      fs_ats_hide_battle_speech_tag
    end

    #--------------------------------------------------------------------------
    # 三種 Layout
    #--------------------------------------------------------------------------
    def fs_ats_battle_position
      return unless fs_ats_battle_overhead?

      sprite = fs_ats_battle_sprite
      battler = fs_ats_battle_battler
      return if sprite == nil || battler == nil
      return if sprite.respond_to?(:disposed?) && sprite.disposed?

      zoom_y = sprite.respond_to?(:zoom_y) ?
               sprite.zoom_y.to_f : 1.0
      zoom_y = 1.0 if zoom_y == 0

      centre_x = sprite.x.to_i
      sprite_top = sprite.y.to_f -
                   sprite.oy.to_f * zoom_y

      extra_y =
        FS_ATS_DIALOGUE.battle_default_y_offset(battler)
      extra_y += $game_message.fs_ats_battle_y_offset.to_i

      name_extra = 0
      if @name_window && !@name_window.disposed?
        name_extra = [
          @name_window.height -
          FS_ATS_DIALOGUE::NAME_EDGE_OVERLAP,
          0
        ].max
      end

      target_x = centre_x - self.width / 2
      target_y = sprite_top.to_i +
                 extra_y -
                 self.height -
                 name_extra -
                 fs_ats_battle_tag_extra -
                 FS_ATS_DIALOGUE::BATTLE_GAP

      target_x = [
        [target_x, 0].max,
        Graphics.width - self.width
      ].min
      target_y = [
        [target_y, 0].max,
        Graphics.height - self.height
      ].min

      self.x = target_x
      self.y = target_y
      self.opacity = $game_message.message_opacity
      self.back_opacity = $game_message.message_backopacity
      fs_ats_force_dialogue_contents_visible

      set_face_position if respond_to?(:set_face_position)
      set_name_position if respond_to?(:set_name_position)
      fs_ats_position_battle_speech_tag(centre_x)
    rescue
      fs_ats_hide_battle_speech_tag
    end

    def fs_ats_battle_messageback_layout
      return unless fs_ats_battle_messageback?

      size = FS_ATS_DIALOGUE.native_dim_window_size
      remake_window(size[0], size[1]) if
        self.width != size[0] || self.height != size[1]

      self.x = (Graphics.width - self.width) / 2

      case $game_message.position.to_i
      when 0
        self.y = 0
      when 1
        self.y = (Graphics.height - self.height) / 2
      else
        self.y = Graphics.height - self.height
      end

      self.opacity = 0
      self.back_opacity = 0
      self.visible = true
      self.contents_opacity = 255

      fs_ats_hide_battle_speech_tag
      fs_ats_hide_legacy_battle_graphic(true)
      fs_ats_show_messageback_sprite

      set_face_position if respond_to?(:set_face_position)
      set_name_position if respond_to?(:set_name_position)
    rescue
    end

    def fs_ats_battle_legacy_layout
      return unless fs_ats_battle_legacy_dialogue?

      # 尺寸要在 ATS 開始逐字繪製前由 reset_window 完成。
      # update 階段只在尺寸真的不同時重建，避免擦掉已畫內容。
      size = FS_ATS_DIALOGUE.battle_graphic_window_size
      remake_window(size[0], size[1]) if
        self.width != size[0] || self.height != size[1]

      rect = @fs_ats_battle_default_rect
      if rect
        self.x = rect[0]
        self.y = rect[1]
      else
        self.x = 0
        self.y = 10
      end

      self.opacity = 0
      self.back_opacity = 0
      self.visible = true
      self.contents_opacity = 255

      # MessageBack 必須完全隱藏。
      fs_ats_hide_ats_back_sprite
      fs_ats_hide_battle_speech_tag

      # 使用原「戰鬥訊息」腳本建立的 @b_sprite。
      # 它本來就能在 Battle Log 文字後方正確顯示 Battle_Message。
      fs_ats_show_legacy_battle_graphic

      set_face_position if respond_to?(:set_face_position)
      set_name_position if respond_to?(:set_name_position)
    rescue
      fs_ats_hide_ats_back_sprite
    end

    def fs_ats_battle_apply_background_mode
      return unless fs_ats_battle_speech?

      case fs_ats_battle_background_mode
      when FS_ATS_DIALOGUE::BATTLE_OVERHEAD_BACKGROUND
        fs_ats_hide_ats_back_sprite
        fs_ats_hide_legacy_battle_graphic(true)
        fs_ats_battle_position
      when FS_ATS_DIALOGUE::BATTLE_MESSAGEBACK_BACKGROUND
        fs_ats_battle_messageback_layout
      when FS_ATS_DIALOGUE::BATTLE_MESSAGE_GRAPHIC_BACKGROUND
        fs_ats_battle_legacy_layout
      end
    end

    #--------------------------------------------------------------------------
    # Battle Log refresh／clear 防護
    #--------------------------------------------------------------------------
    # 原 Window_BattleMessage#refresh 一開始就 contents.clear。
    # ATS 的 draw_line 在 @text != nil 時又不重畫 battle log，
    # 因此特殊對話進行中只要戰鬥流程 refresh 一次，就會只剩背景。
    def fs_ats_protect_dialogue_contents?
      return false unless fs_ats_battle_speech?
      return true if @text != nil
      return true if self.pause
      return true if $game_message && $game_message.visible
      return false
    rescue
      return false
    end

    alias fs_ats_battle_dialogue_original_refresh \
      refresh unless
      method_defined?(
        :fs_ats_battle_dialogue_original_refresh) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_refresh)

    def refresh
      return if fs_ats_protect_dialogue_contents?
      fs_ats_battle_dialogue_original_refresh
    end

    alias fs_ats_battle_dialogue_original_clear \
      clear unless
      method_defined?(
        :fs_ats_battle_dialogue_original_clear) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_clear)

    def clear
      if fs_ats_protect_dialogue_contents?
        # 戰鬥記錄資料可以清空，但目前 ATS 文字 Bitmap 必須保留。
        @lines.clear if @lines
        return
      end
      fs_ats_battle_dialogue_original_clear
    end

    def fs_ats_force_dialogue_contents_visible
      self.visible = true
      self.contents_opacity = 255

      if self.contents
        self.contents.font.color.alpha =
          $game_message.message_fontalpha.to_i
        if self.contents.font.color.alpha <= 0
          self.contents.font.color.alpha = 255
        end
      end
    rescue
    end

    #--------------------------------------------------------------------------
    # Lifecycle
    #--------------------------------------------------------------------------
    alias fs_ats_battle_dialogue_original_reset_window \
      reset_window unless
      method_defined?(
        :fs_ats_battle_dialogue_original_reset_window) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_reset_window)

    def reset_window
      unless fs_ats_battle_speech_requested? ||
             @fs_ats_battle_speech_active
        return fs_ats_battle_dialogue_original_reset_window
      end

      fs_ats_capture_battle_mode
      FS_ATS_DIALOGUE.apply_background_profile(self)

      # Window_BattleMessage 原版 reset_window 為空。
      super
      fs_ats_battle_apply_background_mode
    end

    alias fs_ats_battle_dialogue_original_create_namebox \
      create_namebox unless
      method_defined?(
        :fs_ats_battle_dialogue_original_create_namebox) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_create_namebox)

    def create_namebox(name)
      fs_ats_battle_dialogue_original_create_namebox(name)
      fs_ats_battle_apply_background_mode if fs_ats_battle_speech?
    end

    alias fs_ats_battle_dialogue_original_update \
      update unless
      method_defined?(:fs_ats_battle_dialogue_original_update) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_update)

    def update
      fs_ats_battle_dialogue_original_update

      if fs_ats_battle_speech?
        fs_ats_force_dialogue_contents_visible
        fs_ats_battle_apply_background_mode
      else
        # 普通戰鬥記錄：沿用原 @b_sprite／Battle_Message。
        if @back_sprite && !@back_sprite.disposed?
          @back_sprite.visible = false
          @back_sprite.opacity = 0
        end
        fs_ats_hide_battle_speech_tag
      end

      fs_ats_route_legacy_battle_graphic
    end

    def fs_ats_restore_battle_log_window
      return if @fs_ats_battle_default_rect == nil

      rect = @fs_ats_battle_default_rect
      self.x = rect[0]
      self.y = rect[1]
      remake_window(rect[2], rect[3]) if
        respond_to?(:remake_window) &&
        (self.width != rect[2] || self.height != rect[3])

      self.opacity = 0
      self.back_opacity = 0
      self.openness = 255
      @background = FS_ATS_DIALOGUE::NORMAL_BACKGROUND

      if @back_sprite && !@back_sprite.disposed?
        @back_sprite.visible = false
        @back_sprite.opacity = 0
      end

      fs_ats_hide_battle_speech_tag
      fs_ats_hide_ats_back_sprite
      fs_ats_show_legacy_battle_graphic
      refresh if respond_to?(:refresh)
    rescue
    end

    alias fs_ats_battle_dialogue_original_terminate_message \
      terminate_message unless
      method_defined?(
        :fs_ats_battle_dialogue_original_terminate_message) ||
      private_method_defined?(
        :fs_ats_battle_dialogue_original_terminate_message)

    def terminate_message(*args)
      was_speech = fs_ats_battle_speech?
      fs_ats_battle_dialogue_original_terminate_message(*args)

      if was_speech
        # Game_Message clear 已經發生。先結束 Window-local 模式，
        # 再恢復普通戰鬥記錄，兩套狀態不再跨幀互相誤判。
        @fs_ats_battle_speech_active = false
        @fs_ats_battle_background_mode =
          FS_ATS_DIALOGUE::NORMAL_BACKGROUND
        fs_ats_restore_battle_log_window
      end
    end
  end
end
