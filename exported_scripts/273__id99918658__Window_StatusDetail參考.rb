#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_StatusDetail參考
# 【用途】UI／選單元件「Window_StatusDetail參考」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_StatusDetail3
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】登記 $imported：SkillCPSystem、EquipExtension、BitmapExtension。
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
# □ Window_StatusDetail
#------------------------------------------------------------------------------
#   ステータス画面で、アクターの詳細情報を表示するウィンドウです。
#==============================================================================

class Window_StatusDetail3 < Window_Base
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
    r  = (contents.height - y - 56) / 2
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
    draw_chart_flash(@element_chart_sprite, x, y, r, points, pw)

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