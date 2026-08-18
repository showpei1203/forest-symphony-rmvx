#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：STR15_Enemy HP Gauge
# 【用途】保留的 Runtime 元件「STR15_Enemy HP Gauge」。
# 【主要機制】主要定義／擴充 Sprite_Battler；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Sprite_Battler
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：GAUGE_M、GAUGE_BC、GAUGE_GC、GAUGE_W、GAUGE_H、GAUGE_S、GAUGE_T、GAUGE_O。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】star：http://strcatyou.u-abel.net/。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# ★RGSS2
# STR15_Enemy HP Gauge v1.1a
# By star：http://strcatyou.u-abel.net/
# Translated by Mr. Bubble
#
# ・Show HP gauge of enemies when hit.
# ・You can hide a specified enemy's HP gauge by adding "HIDEHP" to
# the enemy's Notes field in the Database.
# ・Updated with a back attack fix by Moonlight.  Use this version ONLY with the
#  ATB+SBS scripts.
#------------------------------------------------------------------------------

#==============================================================================
# ★このスクリプトの機能を有効にする
if true
#==============================================================================
# ■ Sprite_Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  # Word used in enemy Notes field to hide HP gauge
  GAUGE_M = "HIDEHP"
# Gauge back color　[Border color, Inside color]
  GAUGE_BC = [Color.new(34,27,23), Color.new(80,62,47)]
  # Color gradient　[Left, Right]
  GAUGE_GC = [Color.new(71,8,10), Color.new(155,34,33)]
  #
  GAUGE_W = 56 # Gauge width
  GAUGE_H = 6 # Gauge height
  GAUGE_S = 2 # Gauge speed (more than 2)
  GAUGE_T = 640 # Gauge display length　(more 510)
  GAUGE_O = 18 # Gauge opacity
  #
  GAUGE_V = false # STR cursor appears when damaged. Requires STRxx Cursor.                  # ※XP風バトルを導入してない場合は有効にしないでください
  #--------------------------------------------------------------------------
  # ● ゲージスプライト作成(追加)
  #--------------------------------------------------------------------------
  def create_enhpgauge
    g_width = GAUGE_W  # 幅
    g_height = GAUGE_H # 高さ
    f_color = GAUGE_BC # ゲージバックカラー
    g_color = GAUGE_GC # ゲージカラー
    # ビットマップ作成
    bitmap = Bitmap.new(g_width, g_height * 2)
    # 上半分:ゲージバック
    bitmap.fill_rect(0, 0, g_width, g_height, f_color[0])         # 枠外
    bitmap.fill_rect(1, 1, g_width - 2, g_height - 2, f_color[1]) # 枠内
    # 下半分:グラデゲージ
    bitmap.gradient_fill_rect(1, g_height + 1, g_width - 2, g_height - 2,
                              g_color[0], g_color[1])             # グラデ
    # スプライト作成 # [0] = ゲージバック; [1] = ゲージ
    @hp_gauge = [Sprite.new, Sprite.new]
    for i in 0..1
      sprite = @hp_gauge[i]
      sprite.viewport = self.viewport
      sprite.bitmap = bitmap
      sprite.src_rect.set(0, 0, g_width, g_height)
      sprite.src_rect.y = g_height if i == 1
      if $back_attack && N01::BACK_ATTACK && N01::BACK_ATTACK_NON_BACK_MIRROR
        sprite.x = Graphics.width - @battler.screen_x
      else
        sprite.x = @battler.screen_x
      end
      sprite.y = @battler.screen_y + 10#sprite.y = @battler.screen_y-10 - 8or-2
      sprite.ox = g_width / 2
      sprite.oy = g_height / 2
      sprite.z = 2000#sprite.z = 200
      sprite.z += 20 if i == 1#sprite.z += 20 if i == 1
      sprite.opacity = 0
    end
    # いろいろ
    @enid = @battler.enemy_id
    @hp = @battler.hp
    @gauge_width = GAUGE_W + 1
    @gauge_opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● ゲージ更新(追加)
  #--------------------------------------------------------------------------
  def enhpgauge_update
    # エネミーIDが変動していたらメモの内容を再取得・可視状態も更新
    if @enid != @battler.enemy_id
      @enid = @battler.enemy_id
      @gauge_visible = true
      @gauge_visible = false if $data_enemies[@enid].note.include?(GAUGE_M)
      for i in @hp_gauge do i.visible = @gauge_visible end
      end
    return unless @gauge_visible
    # ゲージ更新
    if @hp != @battler.hp
      g_width = (@battler.hp / (@battler.maxhp * 1.0))
      @gauge_width = ((GAUGE_W * g_width) + 1).truncate
      @gauge_opacity = GAUGE_T
      @hp = @battler.hp
    end
    # 幅
    g_width = @hp_gauge[1].src_rect.width
    speed = GAUGE_S
    rect = @hp_gauge[1].src_rect
    rect.width = (@gauge_width + (g_width * (speed - 1))) / speed
    if rect.width != @gauge_width
      if rect.width > @gauge_width
        rect.width -= 1
      else
        rect.width += 1
      end
    end
    rect.width = 2 if rect.width <= 1 and @hp > 0
    # 透明度
    if GAUGE_V and @battler.cursor_flash
      @gauge_opacity += GAUGE_O * 2 if @gauge_opacity <= GAUGE_T / 2
    else
      @gauge_opacity -= GAUGE_O if @gauge_opacity > 0
    end
    # 透明度適用
    for i in @hp_gauge do i.opacity = @gauge_opacity end
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化(エイリアス)
  #--------------------------------------------------------------------------
  alias initialize_str15 initialize
  def initialize(viewport, battler = nil)
    initialize_str15(viewport, battler)
    if @battler.is_a?(Game_Enemy)
      create_enhpgauge
      @gauge_visible = true
      @gauge_visible = false if $data_enemies[@enid].note.include?(GAUGE_M)
      for i in @hp_gauge do i.visible = @gauge_visible end
    end
  end
  #--------------------------------------------------------------------------
  # ● 解放(エイリアス)
  #--------------------------------------------------------------------------
  alias dispose_str15 dispose
  def dispose
    dispose_str15
    if @battler.is_a?(Game_Enemy)
      @hp_gauge[0].bitmap.dispose
      @hp_gauge[0].dispose
      @hp_gauge[1].dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新(エイリアス)
  #--------------------------------------------------------------------------
  alias update_str15 update
  def update
    update_str15
    enhpgauge_update if @battler.is_a?(Game_Enemy)
  end
end
#
end