#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：TPet_Character
# 【用途】保留的 Runtime 元件「TPet_Character」。
# 【主要機制】主要定義／擴充 TPet_Character；下方原始說明與程式碼保留作細節依據。
# 【主要影響】TPet_Character
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Audio/SE/Saint9.ogg。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ TPet_Character
#------------------------------------------------------------------------------
# 　ペットのキャラクタークラス
#==============================================================================

class TPet_Character < Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    @real_x = (rand(TPET::HOUSE_W - 32) + TPET::HOUSE_X) << 3
    @real_y = (TPET::HOUSE_Y + TPET::HOUSE_H - 32 - 8 ) << 3
    @step_anime = true
    @vx = 0
    @vy = 0
    @sprite = Sprite_Character.new(nil, self)
    @mode = 0
    @count = 0
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 画面 X 座標の取得
  #--------------------------------------------------------------------------
  def screen_x
    return (@real_x >> 3) + 16
  end
  #--------------------------------------------------------------------------
  # ● 画面 Y 座標の取得
  #--------------------------------------------------------------------------
  def screen_y
    return (@real_y >> 3) + 16
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update(id)
    update_action(id)
    @real_x += @vx
    x = TPET::HOUSE_X << 3
    @real_x = x if @real_x < x
    x += (TPET::HOUSE_W - 32) << 3
    @real_x = x if @real_x > x
    @vy += 1 if @vy < 64
    @real_y += @vy
    y = (TPET::HOUSE_Y + TPET::HOUSE_H - 32 - 8 ) << 3
    @real_y = y if @real_y > y
    @anime_count += 1 if @step_anime    # アニメカウントを進める
    update_animation
    @sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 行動の更新
  #--------------------------------------------------------------------------
  def update_action(id)
    @count -= 1 if @count > 0
    case @mode
    when 0    # 待機状態
      if @count == 0    # 移動状態へ移行
        turn_down if @eat == 1###
        turn_up   if @eat == 2###
        @vx = (rand(3) - 1) * 8 unless move_toward_item
        @count = rand(30) + 30
        @mode = 1
        if @vx < 0
          turn_left
          @eat = 1###
        elsif @vx > 0
          turn_right
          @eat = 2###
        end
      end
    when 1    # 移動状態
      if @count == 0    # 停止状態へ移行
        @vx = 0
        @count = 15
        @mode = 0
      elsif item_hit? >= 0    # アイテムと接触したら食事状態へ
        @vx = 0
        @count = 15
        @mode = 2
      end
    when 2    # 食事状態
      if @count == 0    # 停止状態へ移行
        turn_down if @eat == 1###
        turn_up   if @eat == 2###
        i = item_hit?
        if i >= 0
          cry(80, 125)   # 鳴き声
          @balloon_id = 3   # フキダシアイコンの設定
          add_exp(id, $scene.item[i].get_exp)    # 経験値の取得
          add_cal(id, $scene.item[i].get_cal)    # カロリー（満腹度）の取得
          $scene.erase_item(i)    # アイテムの削除
        end
        @vx = 0
        @count = 60
        @mode = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムへ近づく
  #--------------------------------------------------------------------------
  def move_toward_item
    for i in 0...$scene.item.size
      next if $scene.item[i] == nil
      @vx = (@real_x < $scene.item[i].real_x ? 8 : -8)
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● アイテムとの接触判定
  #--------------------------------------------------------------------------
  def item_hit?
    for i in 0...$scene.item.size
      next if $scene.item[i] == nil
      if @real_x < $scene.item[i].real_x + (24 << 3) and
        @real_x + (32 << 3) > $scene.item[i].real_x
        return i
      end
    end
    return -1
  end
  #--------------------------------------------------------------------------
  # ● 経験値の増加
  #--------------------------------------------------------------------------
  def add_exp(id, value)
    i = TPET::USE_VARIABLES_ID + id * 6 + 2
    $game_variables[i] += value
    # レベルアップ
    if $game_variables[i] >= $game_variables[i - 1] * 10
      Audio.se_play("Audio/SE/Saint9.ogg", 80, 100)
      $game_variables[i] = 0
      $game_variables[i - 1] += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 満腹度の増加
  #--------------------------------------------------------------------------
  def add_cal(id, value)
    i = TPET::USE_VARIABLES_ID + id * 6 + 3
    $game_variables[i] += value
    $game_variables[i] = 0 if $game_variables[i] < 0
    $game_variables[i] = 100 if $game_variables[i] > 100
  end
  #--------------------------------------------------------------------------
  # ● 新密度の増加
  #--------------------------------------------------------------------------
  def add_love(id, value)
    i = TPET::USE_VARIABLES_ID + id * 6 + 4
    $game_variables[i] += value
    $game_variables[i] = 0 if $game_variables[i] < 0
    $game_variables[i] = 100 if $game_variables[i] > 100
  end
  #--------------------------------------------------------------------------
  # ● カーソルとの接触判定
  #--------------------------------------------------------------------------
  def cursor_hit?
    if (@real_x >> 3) < $scene.cursor.x and (@real_x >> 3) + 32 > $scene.cursor.x
    if (@real_y >> 3) < $scene.cursor.y and (@real_y >> 3) + 32 > $scene.cursor.y
      return true
    end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● おさわり
  #--------------------------------------------------------------------------
  def touch(id)
    add_cal(id, -10)    # 満腹度１０減少
    if ($game_variables[TPET::USE_VARIABLES_ID + id * 6 + 3] == 0)
      @balloon_id = 7   # ぐしゃぐしゃ
      cry(80, 75)   # 鳴き声
    else
      add_love(id, 1)     # 新密度１増加
      @balloon_id = 4   # ハート
      cry(80, 100)   # 鳴き声
    end
  end
end


