#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_改變血條
# 【用途】保留的 Runtime 元件「KGC_改變血條」。
# 【主要機制】主要定義／擴充 Bitmap、Game_Actor、Window_Base、Window_Status；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Bitmap、Game_Actor、Window_Base、Window_Status、KGC、GenericGauge
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：HP_IMAGE、MP_IMAGE、EXP_IMAGE、HP_OFFSET、MP_OFFSET、EXP_OFFSET、HP_LENGTH、MP_LENGTH。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：GenericGauge、BitmapExtension。
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
#_/    ◆ 汎用ゲージ描画 - KGC_GenericGauge ◆ VX ◆
#_/    ◇ Last update : 2009/09/26 ◇
#_/----------------------------------------------------------------------------
#_/  汎用的なゲージ描画機能を提供します。
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

#==============================================================================
# ★ カスタマイズ項目 - Customize BEGIN ★
#==============================================================================

module KGC
module GenericGauge
  # ◆ ゲージ画像
  #  "Graphics/System" から読み込む。
  HP_IMAGE  = "GaugeHP"   # HP
  MP_IMAGE  = "GaugeMP"   # MP
  EXP_IMAGE = "GaugeEXP"  # EXP

  # ◆ ゲージ位置補正 [x, y]
  HP_OFFSET  = [-23, -2]  # HP
  MP_OFFSET  = [-23, -2]  # MP
  EXP_OFFSET = [-23, -2]  # EXP

  # ◆ ゲージ長補正
  HP_LENGTH  = -4  # HP
  MP_LENGTH  = -4  # MP
  EXP_LENGTH = -4  # EXP

  # ◆ ゲージの傾き角度
  #  -89 ～ 89 で指定。
  HP_SLOPE  = 0  # HP
  MP_SLOPE  = 0  # MP
  EXP_SLOPE = 30  # EXP
end
end

#==============================================================================
# ☆ カスタマイズ項目 終了 - Customize END ☆
#==============================================================================

$imported = {} if $imported == nil
$imported["GenericGauge"] = true

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Bitmap
#==============================================================================

unless $imported["BitmapExtension"]
class Bitmap
  #--------------------------------------------------------------------------
  # ○ 平行四辺形転送
  #--------------------------------------------------------------------------
  def skew_blt(x, y, src_bitmap, src_rect, slope, opacity = 255)
    slope = [[slope, -90].max, 90].min
    sh    = src_rect.height
    off  = sh / Math.tan(Math::PI * (90 - slope.abs) / 180.0)
    if slope >= 0
      dx   = x + off.round
      diff = -off / sh
    else
      dx   = x
      diff = off / sh
    end
    rect = Rect.new(src_rect.x, src_rect.y, src_rect.width, 1)

    sh.times { |i|
      blt(dx + (diff * i).round, y + i, src_bitmap, rect, opacity)
      rect.y += 1
    }
  end
end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 次のレベルの経験値取得
  #--------------------------------------------------------------------------
  def next_exp
    return @exp_list[@level+1]
  end
  #--------------------------------------------------------------------------
  # ○ 次のレベルの差分経験値取得
  #--------------------------------------------------------------------------
  def next_diff_exp
    return (@exp_list[@level+1] - @exp_list[@level])
  end
  #--------------------------------------------------------------------------
  # ○ 次のレベルまでの経験値取得
  #--------------------------------------------------------------------------
  def next_rest_exp
    return (@exp_list[@level+1] - @exp)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_Base
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  # ゲージ転送元座標 [x, y]
  GAUGE_SRC_POS = {
    :normal   => [ 0, 24],
    :decrease => [ 0, 48],
    :increase => [72, 48],
  }
  #--------------------------------------------------------------------------
  # ○ クラス変数
  #--------------------------------------------------------------------------
  @@__gauge_buf = Bitmap.new(320, 24)
  #--------------------------------------------------------------------------
  # ○ ゲージ描画
  #     file       : ゲージ画像ファイル名
  #     x, y       : 描画先 X, Y 座標
  #     width      : 幅
  #     value      : 現在値
  #     limit      : 上限値
  #     offset     : 座標調整 [x, y]
  #     len_offset : 長さ調整
  #     slope      : 傾き
  #     gauge_type : ゲージタイプ
  #--------------------------------------------------------------------------
  def draw_gauge(file, x, y, width, value, limit, offset, len_offset, slope,
      gauge_type = :normal)
    img    = Cache.system(file)
    x     += offset[0]
    y     += offset[1]
    width += len_offset
    draw_gauge_base(img, x, y, width, slope)
    gw = width * value / limit
    draw_gauge_bar(img, x, y, width, gw, slope, GAUGE_SRC_POS[gauge_type])
  end
  #--------------------------------------------------------------------------
  # ○ ゲージベース描画
  #     img   : ゲージ画像
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #     slope : 傾き
  #--------------------------------------------------------------------------
  def draw_gauge_base(img, x, y, width, slope)
    rect = Rect.new(0, 0, 24, 24)
    if slope != 0
      self.contents.skew_blt(x, y, img, rect, slope)
      rect.x = 96
      self.contents.skew_blt(x + width + 24, y, img, rect, slope)

      rect.x     = 24
      rect.width = 72
      dest_rect = Rect.new(0, 0, width, 24)
      @@__gauge_buf.clear
      @@__gauge_buf.stretch_blt(dest_rect, img, rect)
      self.contents.skew_blt(x + 24, y, @@__gauge_buf, dest_rect, slope)
    else
      self.contents.blt(x, y, img, rect)
      rect.x = 96
      self.contents.blt(x + width + 24, y, img, rect)
      rect.x     = 24
      rect.width = 72
      dest_rect = Rect.new(x + 24, y, width, 24)
      self.contents.stretch_blt(dest_rect, img, rect)
    end
  end
  #--------------------------------------------------------------------------
  # ○ ゲージ内部描画
  #     img     : ゲージ画像
  #     x, y    : 描画先 X, Y 座標
  #     width   : 全体幅
  #     gw      : 内部幅
  #     slope   : 傾き
  #     src_pos : 転送元座標 [x, y]
  #     start   : 開始位置
  #--------------------------------------------------------------------------
  def draw_gauge_bar(img, x, y, width, gw, slope, src_pos, start = 0)
    rect = Rect.new(src_pos[0], src_pos[1], 72, 24)
    dest_rect = Rect.new(0, 0, width, 24)
    @@__gauge_buf.clear
    @@__gauge_buf.stretch_blt(dest_rect, img, rect)
    dest_rect.x     = start
    dest_rect.width = gw
    x += start
    if slope != 0
      self.contents.skew_blt(x + 24, y, @@__gauge_buf, dest_rect, slope)
    else
      self.contents.blt(x + 24, y, @@__gauge_buf, dest_rect)
    end
  end
  #--------------------------------------------------------------------------
  # ● HP ゲージの描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    draw_gauge(KGC::GenericGauge::HP_IMAGE,
      x, y, width, actor.hp, actor.maxhp,
      KGC::GenericGauge::HP_OFFSET,
      KGC::GenericGauge::HP_LENGTH,
      KGC::GenericGauge::HP_SLOPE
    )
  end
  #--------------------------------------------------------------------------
  # ● MP ゲージの描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_mp_gauge(actor, x, y, width = 120)
    draw_gauge(KGC::GenericGauge::MP_IMAGE,
      x, y, width, actor.mp, [actor.maxmp, 1].max,
      KGC::GenericGauge::MP_OFFSET,
      KGC::GenericGauge::MP_LENGTH,
      KGC::GenericGauge::MP_SLOPE
    )
  end
  #--------------------------------------------------------------------------
  # ○ Exp の描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_exp(actor, x, y, width = 180)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width, WLH, actor.exp_s, 2)
  end
  #--------------------------------------------------------------------------
  # ○ NextExp の描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_next_exp(actor, x, y, width = 180)
    draw_actor_exp_gauge(actor, x, y, width)

    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width, WLH, actor.next_rest_exp_s, 2)
  end
  #--------------------------------------------------------------------------
  # ○ Exp ゲージの描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_exp_gauge(actor, x, y, width = 180)
    diff = [actor.next_diff_exp, 1].max
    rest = [actor.next_rest_exp, 1].max
    draw_gauge(KGC::GenericGauge::EXP_IMAGE,
      x, y, width, diff - rest, diff,
      KGC::GenericGauge::EXP_OFFSET,
      KGC::GenericGauge::EXP_LENGTH,
      KGC::GenericGauge::EXP_SLOPE
    )
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_Status
#==============================================================================

class Window_Status < Window_Base
  #--------------------------------------------------------------------------
  # ● 経験値情報の描画
  #     x : 描画先 X 座標
  #     y : 描画先 Y 座標
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y + WLH * 0, 180, WLH, Vocab::ExpTotal)
    self.contents.draw_text(x, y + WLH * 2, 180, WLH, s_next)
    draw_actor_exp(@actor, x, y + WLH * 1)
    draw_actor_next_exp(@actor, x, y + WLH * 3)
  end
end
