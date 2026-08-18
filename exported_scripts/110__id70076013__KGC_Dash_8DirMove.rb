#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_Dash_8DirMove
# 【用途】保留的 Runtime 元件「KGC_Dash_8DirMove」。
# 【主要機制】主要定義／擴充 Game_Interpreter、Game_Party、Game_Character、Game_Player；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter、Game_Party、Game_Character、Game_Player、Sprite_Character、KGC、Dash_8DirMove
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ENABLE_8DIR、ENABLE_8DIR_ANIMATION、ENABLE_8DIR_ANIMATION2、DEFAULT_WALK_SPEED、DASH_SPEED_RATE、SLANT_SUFFIX、SLANT_ANIME_TABLE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 8 個 alias／方法包裝，載入順序具有語意；登記 $imported：Dash_8DirMove、TilesetExtension。
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
#_/    ◆ ダッシュ＆８方向移動 - KGC_Dash_8DirMove ◆ VX ◆
#_/    ◇ Last update : 2008/11/16 ◇
#_/----------------------------------------------------------------------------
#_/  ダッシュ速度の調整や、8方向移動機能を追加します。
#_/============================================================================
#_/ 【マップ】≪タイルセット拡張≫ より下に導入してください。
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

#==============================================================================
# ★ カスタマイズ項目 - Customize ★
#==============================================================================

module KGC
module Dash_8DirMove
  # ◆ 8方向移動を有効にする
  #  true  : 斜め移動可
  #  false : 4方向のみ
  ENABLE_8DIR           = true
  # ◆ 歩行アニメを8方向対応にする
  ENABLE_8DIR_ANIMATION = true
  ENABLE_8DIR_ANIMATION2 = false

  # ◆ 歩行速度 (デフォルト)
  #  ニューゲームから始めた場合のみ有効。
  #  イベントで速度を変更した場合、そちらを優先。
  DEFAULT_WALK_SPEED = 4
  # ◆ ダッシュ速度倍率
  #  小数も指定可能。
  #  0.5 などにすれば、ダッシュボタンで歩行も可。
  DASH_SPEED_RATE    = 2
end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

$imported = {} if $imported == nil
$imported["Dash_8DirMove"] = true

module KGC::Dash_8DirMove
  # 斜め画像の接尾辞
  SLANT_SUFFIX = "#"
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# □ KGC::Commands
#==============================================================================

module KGC
module Commands
  module_function
  #--------------------------------------------------------------------------
  # ○ 歩行速度のリセット
  #--------------------------------------------------------------------------
  def reset_walk_speed
    $game_player.reset_move_speed
  end
end
end

class Game_Interpreter
  include KGC::Commands
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_Party
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 歩数減少
  #--------------------------------------------------------------------------
  def decrease_steps
    @steps -= 1
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_Character
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ○ 向き (8方向用)
  #--------------------------------------------------------------------------
  def direction_8dir
    return @direction
  end
  #--------------------------------------------------------------------------
  # ● 指定方向に向き変更
  #     direction : 向き
  #--------------------------------------------------------------------------
  alias set_direction_KGC_Dash_8DirMove set_direction
  def set_direction(direction)
    last_dir = @direction

    set_direction_KGC_Dash_8DirMove(direction)

    if !@direction_fix && direction != 0
      @direction_8dir = direction
    end
  end
  #--------------------------------------------------------------------------
  # ● 左下に移動
  #--------------------------------------------------------------------------
  alias move_lower_left_KGC_Dash_8DirMove move_lower_left
  def move_lower_left
    move_lower_left_KGC_Dash_8DirMove

    @direction_8dir = 1 unless @direction_fix
  end
  #--------------------------------------------------------------------------
  # ● 右下に移動
  #--------------------------------------------------------------------------
  alias move_lower_right_KGC_Dash_8DirMove move_lower_right
  def move_lower_right
    move_lower_right_KGC_Dash_8DirMove

    @direction_8dir = 3 unless @direction_fix
  end
  #--------------------------------------------------------------------------
  # ● 左上に移動
  #--------------------------------------------------------------------------
  alias move_upper_left_KGC_Dash_8DirMove move_upper_left
  def move_upper_left
    move_upper_left_KGC_Dash_8DirMove

    @direction_8dir = 7 unless @direction_fix
  end
  #--------------------------------------------------------------------------
  # ● 右上に移動
  #--------------------------------------------------------------------------
  alias move_upper_right_KGC_Dash_8DirMove move_upper_right
  def move_upper_right
    move_upper_right_KGC_Dash_8DirMove

    @direction_8dir = 9 unless @direction_fix
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_Player
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_KGC_Dash_8DirMove initialize
  def initialize
    initialize_KGC_Dash_8DirMove

    reset_move_speed
  end
  #--------------------------------------------------------------------------
  # ○ 向き (8方向用)
  #--------------------------------------------------------------------------
  def direction_8dir
    @direction_8dir = @direction if @direction_8dir == nil
    return @direction_8dir
  end
  #--------------------------------------------------------------------------
  # ○ 移動速度のリセット
  #--------------------------------------------------------------------------
  def reset_move_speed
    @move_speed = KGC::Dash_8DirMove::DEFAULT_WALK_SPEED
  end

if KGC::Dash_8DirMove::ENABLE_8DIR
  #--------------------------------------------------------------------------
  # ● 方向ボタン入力による移動処理
  #--------------------------------------------------------------------------
  def move_by_input
    return unless movable?
    return if $game_map.interpreter.running?

    # 予約済みの追加移動を実行
    if @reserved_move != nil
      case @reserved_move
      when :down
        move_down if passable_l?(2)
      when :left
        move_left if passable_l?(4)
      when :right
        move_right if passable_l?(6)
      when :up
        move_up if passable_l?(8)
      end
      @reserved_move = nil
      return
    end

    last_steps = $game_party.steps

    case Input.dir8
    when 1
      if !passable_l?(2) && passable_l?(4)
        # 左だけ
        move_left
        @reserved_move = :down
      elsif passable_l?(2) && !passable_l?(4)
        # 下だけ
        move_down
        @reserved_move = :left
      elsif passable_l?(2)
        # 下に優先的に移動
        move_down
        move_left
      end
      @direction = 2
    when 2
      move_down
    when 3
      if !passable_l?(2) && passable_l?(6)
        # 右だけ
        move_right
        @reserved_move = :down
      elsif passable_l?(2) && !passable_l?(6)
        # 下だけ
        move_down
        @reserved_move = :right
      elsif passable_l?(2)
        # 下に優先的に移動
        move_down
        move_right
      end
      @direction = 6
    when 4
      move_left
    when 6
      move_right
    when 7
      if !passable_l?(8) && passable_l?(4)
        # 左だけ
        move_left
        @reserved_move = :up
      elsif passable_l?(8) && !passable_l?(4)
        # 上だけ
        move_up
        @reserved_move = :left
      elsif passable_l?(8)
        # 上に優先的に移動
        move_up
        move_left
      end
      @direction = 4
    when 8
      move_up
    when 9
      if !passable_l?(8) && passable_l?(6)
        # 右だけ
        move_right
        @reserved_move = :up
      elsif passable_l?(8) && !passable_l?(6)
        # 上だけ
        move_up
        @reserved_move = :right
      elsif passable_l?(8)
        # 上に優先的に移動
        move_up
        move_right
      end
      @direction = 8
    else
      return
    end
    @direction_8dir = Input.dir8

    # ２歩進んでいたら１歩戻す
    if $game_party.steps - last_steps == 2
      $game_party.decrease_steps
    end
  end
  #--------------------------------------------------------------------------
  # ○ 簡易移動可否判定
  #     d : 移動方向
  #--------------------------------------------------------------------------
  def passable_l?(d)
    if $imported["TilesetExtension"]
      return passable?(@x, @y, d)
    else
      case d
      when 1
        return passable?(@x-1, @y+1)
      when 2
        return passable?(@x, @y+1)
      when 3
        return passable?(@x+1, @y+1)
      when 4
        return passable?(@x-1, @y)
      when 6
        return passable?(@x+1, @y)
      when 7
        return passable?(@x-1, @y-1)
      when 8
        return passable?(@x, @y-1)
      when 9
        return passable?(@x+1, @y-1)
      end
    end
    return false
  end
end  # ENABLE_8DIR

  #--------------------------------------------------------------------------
  # ● 移動時の更新
  #--------------------------------------------------------------------------
  def update_move
    distance = 2 ** @move_speed   # 移動速度から移動距離に変換
    if dash?                      # ダッシュ状態なら速度変更
      distance *= KGC::Dash_8DirMove::DASH_SPEED_RATE
    end
    distance = Integer(distance)

    @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
    @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
    @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
    @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
    update_bush_depth unless moving?
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Sprite_Character
#==============================================================================

if KGC::Dash_8DirMove::ENABLE_8DIR_ANIMATION

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  SLANT_ANIME_TABLE = { 1=>2, 3=>6, 7=>4, 9=>8 }
  #--------------------------------------------------------------------------
  # ● 転送元ビットマップの更新
  #--------------------------------------------------------------------------
  alias update_bitmap_KGC_Dash_8DirMove update_bitmap
  def update_bitmap
    name_changed = (@character_name != @character.character_name)

    update_bitmap_KGC_Dash_8DirMove

    if @tile_id > 0             # タイル画像使用
      @enable_slant = false
      return
    end
    return unless name_changed  # 画像名変化なし

    # 斜め移動アニメ有効判定
    @enable_slant = true
    begin
      @character_name_slant = @character_name + KGC::Dash_8DirMove::SLANT_SUFFIX
      Cache.character(@character_name_slant)
    rescue
      @enable_slant = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 転送元矩形の更新
  #--------------------------------------------------------------------------
  alias update_src_rect_KGC_Dash_8DirMove update_src_rect
  def update_src_rect
    return if @tile_id > 0  # タイル画像

    if @enable_slant
      update_src_rect_for_slant
    else
      update_src_rect_KGC_Dash_8DirMove
    end
  end
  #--------------------------------------------------------------------------
  # ○ 斜め移動用転送元矩形の更新
  #--------------------------------------------------------------------------
  def update_src_rect_for_slant
    index = @character.character_index
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (index % 4 * 3 + pattern) * @cw

    dir = @character.direction_8dir
    case dir % 2
    when 0  # 上下左右
      if @last_slant
        self.bitmap = Cache.character(@character_name)
        @last_slant = false
      end
    else    # 斜め
      unless @last_slant
        self.bitmap = Cache.character(@character_name_slant)
        @last_slant = true
      end
      # 1, 3, 7, 9 を 2, 6, 4, 8 に変換
      dir = SLANT_ANIME_TABLE[dir]
    end

    sy = (index / 4 * 4 + (dir - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
end

end  # ENABLE_8DIR_ANIMATION
