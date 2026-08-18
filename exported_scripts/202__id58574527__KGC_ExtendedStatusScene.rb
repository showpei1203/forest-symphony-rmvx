#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_ExtendedStatusScene
# 【用途】UI／選單元件「KGC_ExtendedStatusScene」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_StatusCommand、Window_Status、Window_StatusDetail、KGC、ExtendedStatusScene、KGC::ExtendedStatusScene
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PROFILE、COMMANDS、COMMAND_NAME、PARAMS、PARAMETER_NAME、RESIST_STYLE、RESIST_NUM_STYLE、CHART_LINE_COLOR。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：ExtendedStatusScene、GenericGauge、SkillCPSystem、EquipExtension、BitmapExtension。
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
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/    ◆ 拡張ステータス画面 - KGC_ExtendedStatusScene ◆ VX ◆
#_/    ◇ Last update : 2009/09/26 ◇
#_/----------------------------------------------------------------------------
#_/  ステータス画面に表示する内容を詳細化します。
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

$data_states = load_data("Data/States.rvdata") if $data_states == nil
$data_system = load_data("Data/System.rvdata") if $data_system == nil

#==============================================================================
# ★ カスタマイズ項目 - Customize BEGIN ★
#==============================================================================

module KGC
module ExtendedStatusScene
  # ◆ プロフィール
  PROFILE = []
  # ここから下に
  #  PROFILE[アクターID] = 'プロフィール'
  # という書式で設定。
  # 改行する場合は、改行したい位置に \| を入力。
  PROFILE[1] =
    'Name: \N[1]\|' +
    '\C[2]プロフィールテスト\C[0]\|' +
    '\|' +
    'くぁｗせｄｒｆｔｇｙふじこｌｐ；＠：「'

  # ◆ コマンド
  #  コマンドを表示したい順に記述。
  #  表示したくないコマンドは省略可 (0 個はダメ)。
  #   :param          .. パラメータ
  #   :resist         .. 属性/ステート耐性
  #   :element_resist .. 属性耐性
  #   :state_resist   .. ステート耐性
  #   :profile        .. プロフィール
  COMMANDS = [:param, :element_resist, :state_resist, :profile]

  # ◆ コマンド名
  COMMAND_NAME = {
    :param          => "能力値",
    :resist         => "耐性",
    :element_resist => "属性耐性",
    :state_resist   => "ステート耐性",
    :profile        => "プロフィール",
  }

  # ◆ 表示するパラメータ
  #  :param ページに表示したい順に記述。
  #  表示したくない項目は省略可。
  #   :atk .. 攻撃力
  #   :def .. 防御力
  #   :spi .. 精神力
  #   :agi .. 敏捷性
  #   :hit .. 命中率
  #   :eva .. 回避率
  #   :cri .. クリティカル率
  #   :cp  .. CP (≪スキルCP制≫ に対応)
  #   :ep  .. EP (≪装備拡張≫ に対応)
  PARAMS = [:atk, :def, :spi, :agi, :hit, :eva, :cri, :cp, :ep]

  # ◆ パラメータ名
  #  :param, :resist コマンドで使用。
  PARAMETER_NAME = {
    # :param 用
    :hit => "命中率",
    :eva => "回避率",
    :cri => "クリティカル",
    # :resist 用
    :element_resist => "属性耐性",
    :state_resist   => "ステート耐性",
  }  # ← これは消さないこと！

  # ◆ 属性耐性の表記方法
  #   0 .. 数値
  #   1 .. チャート
  #   2 .. チャート＆数値 (:resist はチャートのみ)
  #  1, 2 は ≪ビットマップ拡張≫ が必要。
  RESIST_STYLE = 2
  # ◆ 耐性の数値
  #   0 .. 属性: 100 で通常、99 以下は軽減 (マイナスは吸収)、101 以上は弱点
  #        ステート: 付加成功率 (かかりやすさ)
  #   1 .. 属性: 0 で通常、プラスは軽減 (101 以上は吸収)、マイナスは弱点
  #        ステート: 付加回避率 (かかりにくさ)
  RESIST_NUM_STYLE = 1

  # ◆ チャート色
  CHART_LINE_COLOR  = Color.new(128, 255, 128)  # ライン色
  CHART_BASE_COLOR  = Color.new(128, 192, 255)  # ベース色
  CHART_FLASH_COLOR = Color.new(128, 255, 128)  # フラッシュ色
  # ◆ チャートをなめらかにする
  #   true  : 高品質、低速
  #   false : 低品質、高速
  CHART_HIGHQUALITY = true

  # ～ 以下の項目は ≪モンスター図鑑≫ と互換性があります。 ～
  # ～ ≪モンスター図鑑≫ 側の設定をコピーしても構いません。～

  # ◆ 属性耐性を調べる範囲
  #  耐性を調べる属性の ID を配列に格納。
  #  .. や ... を使用した範囲指定も可能。
  ELEMENT_RANGE = [4..21]
  # ◆ 属性のアイコン
  #  各属性に対応するアイコンの番号を指定。
  #  配列の添字が属性 ID に対応。
  #  (最初が属性 ID: 0 に対応、あとは ID: 1, 2, 3, ... の順)
  ELEMENT_ICON = [0,                         # ID: 0 はダミー (未使用)
      1,   1,   1, 3988, 3989, 3990, 3991, 3992,  # ID: 1 ～  8
    3993, 4004,   4005,   4006, 4007, 4008, 4009, 4020,  # ID: 9 ～ 16
    4021, 4022, 4023, 4024, 4025,
  ]  # ← これは消さないこと！

  # ◆ ステート耐性を調べる範囲
  #  耐性を調べるステートの ID を配列に格納。
  #  記述方法は ELEMENT_RANGE と同様。
  STATE_RANGE = [1...$data_states.size]
end
end

#==============================================================================
# ☆ カスタマイズ項目 終了 - Customize END ☆
#==============================================================================

$imported = {} if $imported == nil
$imported["ExtendedStatusScene"] = true

module KGC::ExtendedStatusScene
  module_function
  #--------------------------------------------------------------------------
  # ○ Range と Integer の配列を Integer の配列に変換 (重複要素は排除)
  #--------------------------------------------------------------------------
  def convert_integer_array(array, type = nil)
    result = []
    array.each { |i|
      case i
      when Range
        result |= i.to_a
      when Integer
        result |= [i]
      end
    }
    case type
    when :element
      result.delete_if { |x| x >= $data_system.elements.size }
    when :state
      result.delete_if { |x|
        x >= $data_states.size ||
        $data_states[x].nonresistance ||
        $data_states[x].priority == 0
      }
    end
    return result
  end

  # チェックする属性リスト
  CHECK_ELEMENT_LIST = convert_integer_array(ELEMENT_RANGE, :element)
  # チェックするステートリスト
  CHECK_STATE_LIST   = convert_integer_array(STATE_RANGE, :state)

  # 耐性表記方法
  case RESIST_STYLE
  when 0
    RESIST_STYLE_SYMBOL = :num
  when 1
    RESIST_STYLE_SYMBOL = :chart
  else
    RESIST_STYLE_SYMBOL = :both
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# □ Window_StatusCommand
#------------------------------------------------------------------------------
#   ステータス画面で、表示する内容を選択するウィンドウです。
#==============================================================================

class Window_StatusCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    commands = []
    KGC::ExtendedStatusScene::COMMANDS.each { |c|
      commands << KGC::ExtendedStatusScene::COMMAND_NAME[c]
    }
    super(160, commands)
    self.height = WLH * 5 + 32
    self.active = true
  end
  #--------------------------------------------------------------------------
  # ○ 選択中のコマンド取得
  #--------------------------------------------------------------------------
  def command
    return KGC::ExtendedStatusScene::COMMANDS[index]
  end
  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ後ろに移動
  #--------------------------------------------------------------------------
  def cursor_pagedown
    return if Input.repeat?(Input::R)
    super
  end
  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ前に移動
  #--------------------------------------------------------------------------
  def cursor_pageup
    return if Input.repeat?(Input::L)
    super
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_Status
#==============================================================================

class Window_Status < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor : アクター
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(160, 0, Graphics.width - 160, WLH * 5 + 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_basic(104, 0)
    draw_exp(104, WLH * 3)
  end
  #--------------------------------------------------------------------------
  # ● 基本情報の描画
  #     x : 描画先 X 座標
  #     y : 描画先 Y 座標
  #--------------------------------------------------------------------------
  def draw_basic(x, y)
    draw_actor_face(@actor, 0, (contents.height - 96) / 2)
    draw_actor_name(@actor, x, y)
    draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH)
    draw_actor_state(@actor, x, y + WLH * 2)
    draw_actor_hp(@actor, x + 120, y + WLH)
    draw_actor_mp(@actor, x + 120, y + WLH * 2)
  end
  #--------------------------------------------------------------------------
  # ● 経験値情報の描画
  #     x : 描画先 X 座標
  #     y : 描画先 Y 座標
  #--------------------------------------------------------------------------
  def draw_exp(x, y)
    if $imported["GenericGauge"]
      draw_actor_exp(@actor, x, y + WLH * 0, 240)
      draw_actor_next_exp(@actor, x, y + WLH * 1, 240)
    end

    s1 = @actor.exp_s
    s2 = @actor.next_rest_exp_s
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y + WLH * 0, 180, WLH, Vocab::ExpTotal)
    self.contents.draw_text(x, y + WLH * 1, 180, WLH, s_next)
    self.contents.font.color = normal_color

    unless $imported["GenericGauge"]
      self.contents.draw_text(x, y + WLH * 0, 240, WLH, s1, 2)
      self.contents.draw_text(x, y + WLH * 1, 240, WLH, s2, 2)
    end
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# □ Window_StatusDetail
#------------------------------------------------------------------------------
#   ステータス画面で、アクターの詳細情報を表示するウィンドウです。
#==============================================================================

class Window_StatusDetail < Window_Base
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :category
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor : アクター
  #--------------------------------------------------------------------------
  def initialize(actor)
    @category = nil
    y = WLH * 5 + 32
    super(0, y, Graphics.width, Graphics.height - y)
    create_chart_sprite
    @actor    = actor
    @duration = 0
    self.z = z
  end
  #--------------------------------------------------------------------------
  # ○ レーダーチャートスプライト作成
  #--------------------------------------------------------------------------
  def create_chart_sprite
    @element_chart_sprite = Sprite_Base.new
    @element_chart_sprite.bitmap = Bitmap.new(height - 32, height - 32)
    @element_chart_sprite.ox = @element_chart_sprite.width  / 2
    @element_chart_sprite.oy = @element_chart_sprite.height / 2
    @element_chart_sprite.blend_type = 1
    @element_chart_sprite.opacity = 0
    @element_chart_sprite.visible = false

    @state_chart_sprite = Sprite_Base.new
    @state_chart_sprite.bitmap = Bitmap.new(height - 32, height - 32)
    @state_chart_sprite.ox = @state_chart_sprite.width  / 2
    @state_chart_sprite.oy = @state_chart_sprite.height / 2
    @state_chart_sprite.blend_type = 1
    @state_chart_sprite.opacity = 0
    @state_chart_sprite.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 破棄
  #--------------------------------------------------------------------------
  def dispose
    @element_chart_sprite.bitmap.dispose
    @element_chart_sprite.dispose
    @state_chart_sprite.bitmap.dispose
    @state_chart_sprite.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ○ Z 座標設定
  #--------------------------------------------------------------------------
  def z=(value)
    super(value)
    @element_chart_sprite.z = z + 1 if @element_chart_sprite != nil
    @state_chart_sprite.z   = z + 1 if @state_chart_sprite   != nil
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリー設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @element_chart_sprite.visible = false
    @state_chart_sprite.visible   = false
    return if @category == nil

    self.contents.clear
    case @category
    when :param
      draw_parameter_list
    when :resist
      draw_resistance
    when :element_resist
      draw_element_resistance(0, 0,
        KGC::ExtendedStatusScene::RESIST_STYLE_SYMBOL)
    when :state_resist
      draw_state_resistance(0, 0,
        KGC::ExtendedStatusScene::RESIST_STYLE_SYMBOL)
    when :profile
      draw_profile
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ○ パラメータ描画
  #--------------------------------------------------------------------------
  def draw_parameter_list
    y = 0
    KGC::ExtendedStatusScene::PARAMS.each { |param|
      draw_parameter(param, 0, y)
      y += WLH
    }

    x = 192
    contents.font.color = system_color
    contents.draw_text(x, 0, 120, WLH, Vocab::equip)
    @actor.equips.each_with_index { |item, i|
      draw_item_name(item, x, WLH * (i + 1))
    }
    contents.font.color = normal_color
  end
  #--------------------------------------------------------------------------
  # ○ 個別パラメータ描画
  #--------------------------------------------------------------------------
  def draw_parameter(param, x, y)
    case param
    when :atk
      draw_actor_parameter(@actor, x, y, 0)
    when :def
      draw_actor_parameter(@actor, x, y, 1)
    when :spi
      draw_actor_parameter(@actor, x, y, 2)
    when :agi
      draw_actor_parameter(@actor, x, y, 3)
    when :hit
      draw_actor_parameter(@actor, x, y, 4)
    when :eva
      draw_actor_parameter(@actor, x, y, 5)
    when :cri
      draw_actor_parameter(@actor, x, y, 6)
    when :cp
      return unless $imported["SkillCPSystem"]
      return unless KGC::SkillCPSystem::SHOW_STATUS_CP
      draw_actor_cp(@actor, x, y, 156)
    when :ep
      return unless $imported["EquipExtension"]
      return unless KGC::EquipExtension::SHOW_STATUS_EP
      draw_actor_ep(@actor, x, y, 156)
    end
  end
  #--------------------------------------------------------------------------
  # ● 能力値の描画
  #     actor : アクター
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #     type  : 能力値の種類 (0～6)
  #--------------------------------------------------------------------------
  def draw_actor_parameter(actor, x, y, type)
    return super(actor, x, y, type) if type <= 3

    names = KGC::ExtendedStatusScene::PARAMETER_NAME
    case type
    when 4
      parameter_name  = names[:hit]
      parameter_value = actor.hit
    when 5
      parameter_name  = names[:eva]
      parameter_value = actor.eva
    when 6
      parameter_name  = names[:cri]
      parameter_value = actor.cri
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, WLH, parameter_value, 2)
  end
  #--------------------------------------------------------------------------
  # ○ 耐性描画
  #--------------------------------------------------------------------------
  def draw_resistance
    case KGC::ExtendedStatusScene::RESIST_STYLE
    when 0
      type = :num
    else
      type = :chart
    end

    x = 0
    contents.font.color = system_color
    contents.draw_text(x, 0, 120, WLH,
      KGC::ExtendedStatusScene::PARAMETER_NAME[:element_resist])
    contents.font.color = normal_color
    x = draw_element_resistance(x, WLH, type)

    contents.font.color = system_color
    contents.draw_text(x, 0, 120, WLH,
      KGC::ExtendedStatusScene::PARAMETER_NAME[:state_resist])
    x = draw_state_resistance(x, WLH, type)

    contents.font.color = normal_color
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性描画
  #     x, y : 描画先 X, Y
  #     type : 表示形式 (:num, :chart, :both)
  #    描画終了時の X 座標を返す。
  #--------------------------------------------------------------------------
  def draw_element_resistance(x, y, type)
    rect = Rect.new (0, 0, 212,207)
    self.contents.fill_rounded_rect(rect, Color.new(0, 0, 0, 128))
    if KGC::ExtendedStatusScene::CHART_HIGHQUALITY
      Bitmap.smoothing_mode = TRGSSX::SM_ANTIALIAS
    end

    if [:chart, :both].include?(type) && $imported["BitmapExtension"]
      x = draw_element_resistance_chart(x, y)
      @element_chart_sprite.visible = true
    end
    #if [:num, :both].include?(type)
    #  x = draw_element_resistance_num(x, y)
    #end

    Bitmap.smoothing_mode = TRGSSX::SM_DEFAULT

    return x
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性描画 (チャート)
  #     x, y : 描画先 X, Y
  #    描画終了時の X 座標を返す。
  #--------------------------------------------------------------------------
  def draw_element_resistance_chart(x, y)
    r  = (contents.height-20 - y - 56) / 2
    cx = x + r + 28
    cy = y + r + 28
    pw = (Bitmap.smoothing_mode == TRGSSX::SM_ANTIALIAS ? 2 : 1)
    elements = KGC::ExtendedStatusScene::CHECK_ELEMENT_LIST

    draw_chart_line(cx, cy, r, elements.size, 3, pw)

    # チャート
    points = []
    elements.each_with_index { |e, i|
      n   = @actor.element_rate(e)
      n   = 100 - n if KGC::ExtendedStatusScene::RESIST_NUM_STYLE == 1
      n   = [[n, -100].max, 200].min
      dr  = r * (n + 100) / 100 / 3
      rad = Math::PI * (360.0 * i / elements.size - 90.0) / 180.0
      dx  = cx + Integer(dr * Math.cos(-rad))
      dy  = cy + Integer(dr * Math.sin(rad))
      points << [dx, dy]

      dx = cx + Integer((r + 14) * Math.cos(-rad)) - 12
      dy = cy + Integer((r + 14) * Math.sin(rad))  - 12
      draw_icon(KGC::ExtendedStatusScene::ELEMENT_ICON[e], dx, dy)
    }

    draw_chart(cx, cy, r, points, pw)
    #draw_chart_flash(@element_chart_sprite, x, y, r, points, pw)

    return (x + cx + r + 42)
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性描画 (数値)
  #     x, y : 描画先 X, Y
  #    描画終了時の X 座標を返す。
  #--------------------------------------------------------------------------
  def draw_element_resistance_num(x, y)
    origin_y = y
    contents.font.color = normal_color
    KGC::ExtendedStatusScene::CHECK_ELEMENT_LIST.each { |i|
      if y + WLH > contents.height
        x += 84
        y  = origin_y
      end
      draw_icon(KGC::ExtendedStatusScene::ELEMENT_ICON[i], x, y)
      n = @actor.element_rate(i)
      n = 100 - n if KGC::ExtendedStatusScene::RESIST_NUM_STYLE == 1
      rate = sprintf("%4d%%", n)
      contents.draw_text(x + 24, y, 52, WLH, rate, 2)
      y += WLH
    }
    return (x + 96)
  end
  #--------------------------------------------------------------------------
  # ○ ステート耐性描画
  #     x, y : 描画先 X, Y
  #     type : 表示形式 (:num, :chart, :both)
  #    描画終了時の X 座標を返す。
  #--------------------------------------------------------------------------
  def draw_state_resistance(x, y, type)
    if KGC::ExtendedStatusScene::CHART_HIGHQUALITY
      Bitmap.smoothing_mode = TRGSSX::SM_ANTIALIAS
    end

    if [:chart, :both].include?(type) && $imported["BitmapExtension"]
      x = draw_state_resistance_chart(x, y)
      @state_chart_sprite.visible = true
    end
    #if [:num, :both].include?(type)
    #  x = draw_state_resistance_num(x, y)
    #end

    Bitmap.smoothing_mode = TRGSSX::SM_DEFAULT

    return x
  end
  #--------------------------------------------------------------------------
  # ○ ステート耐性描画 (チャート)
  #     x, y : 描画先 X, Y
  #    描画終了時の X 座標を返す。
  #--------------------------------------------------------------------------
  def draw_state_resistance_chart(x, y)
    r  = (contents.height - y - 56) / 2
    cx = x + r + 28
    cy = y + r + 28
    pw = (Bitmap.smoothing_mode == TRGSSX::SM_ANTIALIAS ? 2 : 1)
    states = KGC::ExtendedStatusScene::CHECK_STATE_LIST

    draw_chart_line(cx, cy, r, states.size, 2, pw)

    # チャート
    points = []
    states.each_with_index { |s, i|
      state = $data_states[s]
      n   = @actor.state_probability(s)
      n   = 100 - n if KGC::ExtendedStatusScene::RESIST_NUM_STYLE == 1
      dr  = r * n / 100
      rad = Math::PI * (360.0 * i / states.size - 90.0) / 180.0
      dx  = cx + Integer(dr * Math.cos(-rad))
      dy  = cy + Integer(dr * Math.sin(rad))
      points << [dx, dy]

      dx = cx + Integer((r + 14) * Math.cos(-rad)) - 12
      dy = cy + Integer((r + 14) * Math.sin(rad))  - 12
      draw_icon(state.icon_index, dx, dy)
    }

    draw_chart(cx, cy, r, points, pw)
    draw_chart_flash(@state_chart_sprite, x, y, r, points, pw)

    return (x + cx + r + 42)
  end
  #--------------------------------------------------------------------------
  # ○ ステート耐性描画 (数値)
  #     x, y : 描画先 X, Y
  #    描画終了時の X 座標を返す。
  #--------------------------------------------------------------------------
  def draw_state_resistance_num(x, y)
    origin_y = y
    contents.font.color = normal_color
    KGC::ExtendedStatusScene::CHECK_STATE_LIST.each { |i|
      state = $data_states[i]
      if y + WLH > contents.height
        x += 76
        y  = origin_y
      end
      draw_icon(state.icon_index, x, y)
      n = @actor.state_probability(i)
      n = 100 - n if KGC::ExtendedStatusScene::RESIST_NUM_STYLE == 1
      rate = sprintf("%3d%%", n)
      contents.draw_text(x + 24, y, 44, WLH, rate, 2)
      y += WLH
    }
    return x
  end
  #--------------------------------------------------------------------------
  # ○ チャートライン描画
  #     cx, cy : 中心 X, Y
  #     r      : 半径
  #     n      : 頂点数
  #     breaks : 空間数
  #     pw     : ペン幅
  #--------------------------------------------------------------------------
  def draw_chart_line(cx, cy, r, n, breaks, pw)
    color = KGC::ExtendedStatusScene::CHART_BASE_COLOR.clone
    contents.draw_regular_polygon(cx, cy, r, n, color, pw)
    color.alpha = color.alpha * 5 / 8
    contents.draw_spoke(cx, cy, r, n, color, pw)
    (1..breaks).each { |i|
      contents.draw_regular_polygon(cx, cy, r * i / breaks, n, color, pw)
    }
  end
  #--------------------------------------------------------------------------
  # ○ チャート描画
  #     cx, cy : 中心 X, Y
  #     r      : 半径
  #     points : 頂点リスト
  #     pw     : ペン幅
  #--------------------------------------------------------------------------
  def draw_chart(cx, cy, r, points, pw)
    contents.draw_polygon(points, KGC::ExtendedStatusScene::CHART_LINE_COLOR, 2)
  end
  #--------------------------------------------------------------------------
  # ○ チャートフラッシュ描画
  #     sprite : チャートスプライト
  #     x, y   : 基準 X, Y
  #     r      : 半径
  #     points : 頂点リスト
  #     pw     : ペン幅
  #--------------------------------------------------------------------------
  def draw_chart_flash(sprite, x, y, r, points, pw)
    points = points.clone
    points.each { |pt| pt[0] -= x }

    cx = x + r + 28
    cy = y + r + 28
    color = KGC::ExtendedStatusScene::CHART_FLASH_COLOR
    sprite.bitmap.clear
    sprite.bitmap.fill_polygon(points, Color.new(0, 0, 0, 0), color)
    sprite.ox = cx - x
    sprite.oy = cy
    sprite.x  = self.x + cx + 16
    sprite.y  = self.y + cy + 16
  end
  #--------------------------------------------------------------------------
  # ○ プロフィール描画
  #--------------------------------------------------------------------------
  def draw_profile
    profile = KGC::ExtendedStatusScene::PROFILE[@actor.id]
    return if profile == nil

    self.contents.font.color = normal_color
    profile.split(/\\\|/).each_with_index { |line, i|
      draw_profile_text(0, WLH * i, line)
    }
  end
  #--------------------------------------------------------------------------
  # ○ プロフィールテキスト描画
  #     x, y : 描画先座標
  #     text : 描画テキスト
  #--------------------------------------------------------------------------
  def draw_profile_text(x, y, text)
    buf = convert_special_characters(text)
    while (c = buf.slice!(/./m)) != nil
      case c
      when "\x01"                       # \C[n]  (文字色変更)
        buf.sub!(/\[(\d+)\]/, "")
        contents.font.color = text_color($1.to_i)
        next
      when "\x02"                       # \G  (所持金表示)
        n  = $game_party.gold.to_s
        cw = contents.text_size(n).width
        contents.draw_text(x, y, cw + 8, WLH, n)
        x += cw
      else                              # 普通の文字
        contents.draw_text(x, y, 40, WLH, c)
        x += contents.text_size(c).width
      end
    end
    contents.font.color = normal_color
  end
  #--------------------------------------------------------------------------
  # ○ 特殊文字の変換
  #     text : 変換対象テキスト
  #--------------------------------------------------------------------------
  def convert_special_characters(text)
    buf = text.dup
    buf.gsub!(/\\V\[(\d+)\]/i) { $game_variables[$1.to_i] }
    buf.gsub!(/\\V\[(\d+)\]/i) { $game_variables[$1.to_i] }
    buf.gsub!(/\\N\[(\d+)\]/i) { $game_actors[$1.to_i].name }
    buf.gsub!(/\\C\[(\d+)\]/i) { "\x01[#{$1}]" }
    buf.gsub!(/\\G/)           { "\x02" }
    buf.gsub!(/\\\\/)          { "\\" }
    return buf
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_chart
  end
  #--------------------------------------------------------------------------
  # ○ チャート更新
  #--------------------------------------------------------------------------
  def update_chart
    return if @element_chart_sprite == nil

    @element_chart_sprite.update
    @state_chart_sprite.update

    zoom = opacity = 0
    case @duration
    when 0..11
      zoom    = @duration / 11.0
      opacity = 255
    when 12..27
      zoom    = 1
      opacity = (27 - @duration) * 16
    end
    @element_chart_sprite.zoom_x  = @element_chart_sprite.zoom_y = zoom
    @element_chart_sprite.opacity = opacity
    @state_chart_sprite.zoom_x    = @state_chart_sprite.zoom_y   = zoom
    @state_chart_sprite.opacity   = opacity

    @duration = (@duration + 1) % Graphics.frame_rate
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Scene_Status
#==============================================================================

#class Scene_Status < Scene_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor_index   : アクターインデックス
  #     command_index : コマンドインデックス
  #--------------------------------------------------------------------------
#  def initialize(actor_index = 0, command_index = 0)
#    @actor_index   = actor_index
#    @command_index = command_index
#  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
#  alias start_KGC_ExtendedStatusScene start
#  def start
#    start_KGC_ExtendedStatusScene#
#
#    @command_window = Window_StatusCommand.new
#    @command_window.index = @command_index
#    @detail_window = Window_StatusDetail.new(@actor)
#    @detail_window.category = @command_window.command
#  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
#  alias terminate_KGC_ExtendedStatusScene terminate
#  def terminate
#    terminate_KGC_ExtendedStatusScene

#    @command_window.dispose
#    @detail_window.dispose
#  end
  #--------------------------------------------------------------------------
  # ● 次のアクターの画面に切り替え
  #--------------------------------------------------------------------------
#  def next_actor
#    @actor_index += 1
#    @actor_index %= $game_party.members.size
#    $scene = Scene_Status.new(@actor_index, @command_window.index)
#  end
  #--------------------------------------------------------------------------
  # ● 前のアクターの画面に切り替え
  #--------------------------------------------------------------------------
#  def prev_actor
#    @actor_index += $game_party.members.size - 1
#    @actor_index %= $game_party.members.size
#    $scene = Scene_Status.new(@actor_index, @command_window.index)
#  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
#  alias update_KGC_ExtendedStatusScene update
#  def update
#    @command_window.update
#    @detail_window.update
#    @detail_window.category = @command_window.command

#    update_KGC_ExtendedStatusScene
#  end
#end
