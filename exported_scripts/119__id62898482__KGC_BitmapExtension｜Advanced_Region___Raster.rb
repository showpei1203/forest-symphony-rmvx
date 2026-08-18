#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：KGC_BitmapExtension｜Advanced Region / Raster
# 【定位】KGC 的進階 Bitmap／Region／Raster 擴充，不是 `Bitmap Addons｜Core + Extension Authority` 的重複品。Bitmap Addons 主要提供 fill_rounded_rect、Ellipse、greyscale 等輕量 UI API；本頁提供 TRGSSX.dll 驅動的高階裁剪、合成、多邊形、文字與輸出功能。
# 【依賴】專案根目錄必須存在 `TRGSSX.dll`；本專案 ZIP 已確認包含該 DLL。缺少或版本不合時本頁會顯示錯誤並 exit，因此不能只刪 DLL 留腳本。
# 【主要 Bitmap API】rop_blt、clip_blt、blend_blt、stretch_blt_r、skew_blt/skew_blt_r、draw_polygon/fill_polygon、draw_regular_polygon/fill_regular_polygon、draw_spoke、draw_text_na、draw_text_fast、text_size_na/text_size_fast、save(filename)。
# 【Region 類別】Region、RectRegion、RoundRectRegion、EllipticRegion、CircularRegion、PolygonRegion、StarRegion、PieRegion、CombinedRegion；Region 支援 `&/*` 交集、`|/+` 聯集、`^` XOR、`-` 差集。
# 【設定】KGC::BitmapExtension::DEFAULT_MODE=0 使用原 draw_text；1 使用 draw_text_na；2 使用 draw_text_fast。DEFAULT_FONT_NAME 可依模式指定 Font；DEFAULT_FRAME 控制預設描邊；DEFAULT_GRAD_COLOR 控制預設漸層色。
# 【TRGSSX 常數】BLEND_NORMAL/ADD/SUB/MUL/HILIGHT；SRCCOPY 等 Raster Operation；IM_* 補間模式；SM_* 平滑模式；FM_FIT/FM_CIRCLE 填色模式；FS_BOLD/ITALIC/UNDERLINE/STRIKEOUT/SHADOW/FRAME 字型旗標。
# 【使用範例】`contents.draw_polygon(points, Color.new(255,255,255), 2)`；`contents.fill_polygon(points, Color.new(0,0,0,0), Color.new(255,255,255,128))`；`temp_bitmap.clip_blt(0,0,source,rect,RoundRectRegion.new(rect,8,8))`。
# 【專案實際依賴】Extended Status／Custom Status 等後續頁直接使用 draw_polygon、fill_polygon、draw_regular_polygon、draw_spoke；另有 UI 直接使用 clip_blt。因此不能與 Bitmap Addons 二選一，也不能搬到這些 UI 後方。
# 【相關素材】非 Graphics／Audio；固定外部依賴為專案根目錄 `TRGSSX.dll`。
# 【來源】KGC BitmapExtension／TRGSSX。原作者來源資訊與程式識別字保留；原外語完整手冊已翻成此繁中手冊，修改前原稿另存 Archive。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
# ★ カスタマイズ項目 - Customize BEGIN ★
#==============================================================================

module KGC
module BitmapExtension
  # ◆ draw_text の動作モード
  #   0 : draw_text (デフォルト)
  # 1 or 2 を指定すると、draw_text が draw_text_na 等に置換されます。
  # (元の draw_text は _draw_text で呼び出せます)
  DEFAULT_MODE = 0

  # ◆ 各モードのデフォルトフォント名
  #   ["フォント 1", "フォント 2", ...],
  #  という書式で設定。
  DEFAULT_FONT_NAME = [
    Font.default_name,  # 0
    ["微軟正黑體"],  # 1
    Font.default_name,  # 2
  ]

  # ◆ デフォルトで縁取りにする
  #  draw_text には無効。
  DEFAULT_FRAME = false

  # ◆ デフォルトのグラデーション色
  #  グラデーションをかけない場合は nil
  #  draw_text には無効。
  DEFAULT_GRAD_COLOR = nil
end
end

#==============================================================================
# ☆ カスタマイズ項目終了 - Customize END ☆
#==============================================================================


$imported = {} if $imported == nil
$imported["BitmapExtension"] = true

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   "TRGSSX.dll" の機能を扱うモジュールです。
#==============================================================================

module TRGSSX
  # 合成タイプ
  BLEND_NORMAL  = 0  # 通常
  BLEND_ADD     = 1  # 加算
  BLEND_SUB     = 2  # 減算
  BLEND_MUL     = 3  # 乗算
  BLEND_HILIGHT = 4  # 覆い焼き

  # ラスタオペレーションコード
  SRCCOPY     = 0x00CC0020 # 詳見頁首繁中說明
  SRCPAINT    = 0x00EE0086 # 詳見頁首繁中說明
  SRCAND      = 0x008800C6 # 詳見頁首繁中說明
  SRCINVERT   = 0x00660046 # 詳見頁首繁中說明
  SRCERASE    = 0x00440328 # 詳見頁首繁中說明
  NOTSRCCOPY  = 0x00330008 # 詳見頁首繁中說明
  NOTSRCERASE = 0x001100A6 # 詳見頁首繁中說明

  # 補間方法
  IM_INVALID             = -1
  IM_DEFAULT             = 0
  IM_LOWQUALITY          = 1
  IM_HIGHQUALITY         = 2
  IM_BILINEAR            = 3
  IM_BICUBIC             = 4
  IM_NEARESTNEIGHBOR     = 5
  IM_HIGHQUALITYBILINEAR = 6
  IM_HIGHQUALITYBICUBIC  = 7

  # スムージングモード
  SM_INVALID     = -1
  SM_DEFAULT     = 0
  SM_HIGHSPEED   = 1
  SM_HIGHQUALITY = 2
  SM_NONE        = 3
  SM_ANTIALIAS   = 4

  # 塗り潰しモード
  FM_FIT    = 0  # 形状通り
  FM_CIRCLE = 1  # 外接円

  # フォントスタイル
  FS_BOLD      = 0x0001  # ボールド
  FS_ITALIC    = 0x0002  # イタリック
  FS_UNDERLINE = 0x0004  # 下線
  FS_STRIKEOUT = 0x0008  # 取り消し線
  FS_SHADOW    = 0x0010  # 影
  FS_FRAME     = 0x0020  # 縁取り

  DLL_NAME = 'TRGSSX'
  begin
    NO_TRGSSX = false
    unless defined?(@@_trgssx_version)
      @@_trgssx_version =
        Win32API.new(DLL_NAME, 'DllGetVersion', 'v', 'l')
      @@_trgssx_get_interpolation_mode =
        Win32API.new(DLL_NAME, 'GetInterpolationMode', 'v', 'l')
      @@_trgssx_set_interpolation_mode =
        Win32API.new(DLL_NAME, 'SetInterpolationMode', 'l', 'v')
      @@_trgssx_get_smoothing_mode =
        Win32API.new(DLL_NAME, 'GetSmoothingMode', 'v', 'l')
      @@_trgssx_set_smoothing_mode =
        Win32API.new(DLL_NAME, 'SetSmoothingMode', 'l', 'v')
      @@_trgssx_rop_blt =
        Win32API.new(DLL_NAME, 'RopBlt', 'pllllplll', 'l')
      @@_trgssx_clip_blt =
        Win32API.new(DLL_NAME, 'ClipBlt', 'pllllplll', 'l')
      @@_trgssx_blend_blt =
        Win32API.new(DLL_NAME, 'BlendBlt', 'pllllplll', 'l')
      @@_trgssx_stretch_blt_r =
        Win32API.new(DLL_NAME, 'StretchBltR', 'pllllplllll', 'l')
      @@_trgssx_skew_blt_r =
        Win32API.new(DLL_NAME, 'SkewBltR', 'pllpllllll', 'l')
      @@_trgssx_draw_polygon =
        Win32API.new(DLL_NAME, 'DrawPolygon', 'pplll', 'l')
      @@_trgssx_fill_polygon =
        Win32API.new(DLL_NAME, 'FillPolygon', 'ppllll', 'l')
      @@_trgssx_draw_regular_polygon =
        Win32API.new(DLL_NAME, 'DrawRegularPolygon', 'pllllll', 'l')
      @@_trgssx_fill_regular_polygon =
        Win32API.new(DLL_NAME, 'FillRegularPolygon', 'plllllll', 'l')
      @@_trgssx_draw_spoke =
        Win32API.new(DLL_NAME, 'DrawSpoke', 'pllllll', 'l')
      @@_trgssx_draw_text_na =
        Win32API.new(DLL_NAME, 'DrawTextNAA', 'pllllpplpll', 'l')
      @@_trgssx_draw_text_fast =
        Win32API.new(DLL_NAME, 'DrawTextFastA', 'pllllpplpll', 'l')
      @@_trgssx_get_text_size_na =
        Win32API.new(DLL_NAME, 'GetTextSizeNAA', 'pppllp', 'l')
      @@_trgssx_get_text_size_fast =
        Win32API.new(DLL_NAME, 'GetTextSizeFastA', 'pppllp', 'l')
      @@_trgssx_save_to_bitmap =
        Win32API.new(DLL_NAME, 'SaveToBitmapA', 'pp', 'l')
    end
  rescue
    NO_TRGSSX = true
    print "\"#{DLL_NAME}.dll\" が見つからない、" +
      "もしくは古いバージョンを使用しています。"
    exit
  end

  module_function
  #--------------------------------------------------------------------------
  # ○ バージョン取得
  #     (<例> 1.23 → 123)
  #--------------------------------------------------------------------------
  def version
    return -1 if NO_TRGSSX

    return @@_trgssx_version.call
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_interpolation_mode
    return @@_trgssx_get_interpolation_mode.call
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_interpolation_mode(mode)
    @@_trgssx_set_interpolation_mode.call(mode)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_smoothing_mode
    return @@_trgssx_get_smoothing_mode.call
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_smoothing_mode(mode)
    @@_trgssx_set_smoothing_mode.call(mode)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def rop_blt(dest_info, dx, dy, dw, dh, src_info, sx, sy, rop)
    return @@_trgssx_rop_blt.call(dest_info, dx, dy, dw, dh,
      src_info, sx, sy, rop)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def clip_blt(dest_info, dx, dy, dw, dh, src_info, sx, sy, hRgn)
    return @@_trgssx_clip_blt.call(dest_info, dx, dy, dw, dh,
      src_info, sx, sy, hRgn)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def blend_blt(dest_info, dx, dy, dw, dh, src_info, sx, sy, blend)
    return @@_trgssx_blend_blt.call(dest_info, dx, dy, dw, dh,
      src_info, sx, sy, blend)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def stretch_blt_r(dest_info, dx, dy, dw, dh, src_info, sx, sy, sw, sh, op)
    return @@_trgssx_stretch_blt_r.call(dest_info, dx, dy, dw, dh,
      src_info, sx, sy, sw, sh, op)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def skew_blt_r(dest_info, dx, dy, src_info, sx, sy, sw, sh, slope, op)
    return @@_trgssx_skew_blt_r.call(dest_info, dx, dy,
      src_info, sx, sy, sw, sh, slope, op)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_polygon(dest_info, pts, n, color, width)
    return @@_trgssx_draw_polygon.call(dest_info, pts,
      n, color, width)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def fill_polygon(dest_info, pts, n, st_color, ed_color, fm)
    return @@_trgssx_fill_polygon.call(dest_info, pts,
      n, st_color, ed_color, fm)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_regular_polygon(dest_info, dx, dy, r, n, color, width)
    return @@_trgssx_draw_regular_polygon.call(dest_info, dx, dy,
      r, n, color, width)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def fill_regular_polygon(dest_info, dx, dy, r, n, st_color, ed_color, fm)
    return @@_trgssx_fill_regular_polygon.call(dest_info, dx, dy,
      r, n, st_color, ed_color, fm)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_spoke(dest_info, dx, dy, r, n, color, width)
    return @@_trgssx_draw_spoke.call(dest_info, dx, dy,
      r, n, color, width)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_text_na(dest_info, dx, dy, dw, dh, text,
      fontname, fontsize, color, align, flags)
    return @@_trgssx_draw_text_na.call(dest_info, dx, dy, dw, dh, text.dup,
      fontname, fontsize, color, align, flags)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_text_fast(dest_info, dx, dy, dw, dh, text,
      fontname, fontsize, color, align, flags)
    return @@_trgssx_draw_text_fast.call(dest_info, dx, dy, dw, dh, text.dup,
      fontname, fontsize, color, align, flags)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_text_size_na(dest_info, text, fontname, fontsize, flags, size)
    return @@_trgssx_get_text_size_na.call(dest_info, text,
      fontname, fontsize, flags, size)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def get_text_size_fast(dest_info, text, fontname, fontsize, flags, size)
    return @@_trgssx_get_text_size_fast.call(dest_info, text,
      fontname, fontsize, flags, size)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def save_to_bitmap(filename, info)
    return @@_trgssx_save_to_bitmap.call(filename, info)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # ○ 補間モード取得
  #--------------------------------------------------------------------------
  def self.interpolation_mode
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.get_interpolation_mode
  end
  #--------------------------------------------------------------------------
  # ○ 補間モード設定
  #--------------------------------------------------------------------------
  def self.interpolation_mode=(value)
    return if TRGSSX::NO_TRGSSX

    TRGSSX.set_interpolation_mode(value)
  end
  #--------------------------------------------------------------------------
  # ○ スムージングモード取得
  #--------------------------------------------------------------------------
  def self.smoothing_mode
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.get_smoothing_mode
  end
  #--------------------------------------------------------------------------
  # ○ スムージングモード設定
  #--------------------------------------------------------------------------
  def self.smoothing_mode=(value)
    return if TRGSSX::NO_TRGSSX

    TRGSSX.set_smoothing_mode(value)
  end
  #--------------------------------------------------------------------------
  # ○ ビットマップ情報 (object_id, width, height) の pack を取得
  #--------------------------------------------------------------------------
  def get_base_info
    return [object_id, width, height].pack('l!3')
  end
  #--------------------------------------------------------------------------
  # ○ ラスタオペレーションを使用して描画
  #     rop : ラスタオペレーションコード
  #--------------------------------------------------------------------------
  def rop_blt(x, y, src_bitmap, src_rect, rop = TRGSSX::SRCCOPY)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.rop_blt(get_base_info,
      x, y, src_rect.width, src_rect.height,
      src_bitmap.get_base_info, src_rect.x, src_rect.y, rop)
  end
  #--------------------------------------------------------------------------
  # ○ クリッピング描画
  #     region : リージョン
  #--------------------------------------------------------------------------
  def clip_blt(x, y, src_bitmap, src_rect, region)
    return -1 if TRGSSX::NO_TRGSSX

    hRgn = region.create_region_handle
    return if hRgn == nil || hRgn == 0

    result = TRGSSX.clip_blt(get_base_info,
      x, y, src_rect.width, src_rect.height,
      src_bitmap.get_base_info, src_rect.x, src_rect.y, hRgn)
    # 後始末
    Region.delete_region_handles

    return result
  end
  #--------------------------------------------------------------------------
  # ○ ブレンド描画
  #     blend : ブレンドタイプ
  #--------------------------------------------------------------------------
  def blend_blt(x, y, src_bitmap, src_rect, blend = TRGSSX::BLEND_NORMAL)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.blend_blt(get_base_info,
      x, y, src_rect.width, src_rect.height,
      src_bitmap.get_base_info, src_rect.x, src_rect.y, blend)
  end
  #--------------------------------------------------------------------------
  # ○ 高画質ブロック転送
  #--------------------------------------------------------------------------
  def stretch_blt_r(dest_rect, src_bitmap, src_rect, opacity = 255)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.stretch_blt_r(get_base_info,
      dest_rect.x, dest_rect.y, dest_rect.width, dest_rect.height,
      src_bitmap.get_base_info,
      src_rect.x, src_rect.y, src_rect.width, src_rect.height,
      opacity)
  end
  #--------------------------------------------------------------------------
  # ○ 平行四辺形転送
  #--------------------------------------------------------------------------
  def skew_blt(x, y, src_bitmap, src_rect, slope, opacity = 255)
    slope = [[slope, -89].max, 89].min
    sh    = src_rect.height
    off  = sh / Math.tan(Math::PI * (90 - slope.abs) / 180.0)
    if slope >= 0
      dx   = x + off.to_i
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
  #--------------------------------------------------------------------------
  # ○ 高画質平行四辺形転送
  #--------------------------------------------------------------------------
  def skew_blt_r(x, y, src_bitmap, src_rect, slope, opacity = 255)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.skew_blt_r(get_base_info,
      x, y, src_bitmap.get_base_info,
      src_rect.x, src_rect.y, src_rect.width, src_rect.height,
      slope, opacity)
  end
  #--------------------------------------------------------------------------
  # ○ 多角形描画
  #--------------------------------------------------------------------------
  def draw_polygon(points, color, width = 1)
    return -1 if TRGSSX::NO_TRGSSX

    _points = create_point_pack(points)

    return TRGSSX.draw_polygon(get_base_info,
      _points, points.size, color.argb_code, width)
  end
  #--------------------------------------------------------------------------
  # ○ 多角形塗り潰し
  #--------------------------------------------------------------------------
  def fill_polygon(points, st_color, ed_color, fill_mode = TRGSSX::FM_FIT)
    return -1 if TRGSSX::NO_TRGSSX

    _points = create_point_pack(points)

    return TRGSSX.fill_polygon(get_base_info,
      _points, points.size, st_color.argb_code, ed_color.argb_code, fill_mode)
  end
  #--------------------------------------------------------------------------
  # ○ 座標リストの pack を作成
  #--------------------------------------------------------------------------
  def create_point_pack(points)
    result = ''
    points.each { |pt| result += pt.pack('l!2') }
    return result
  end
  private :create_point_pack
  #--------------------------------------------------------------------------
  # ○ 正多角形描画
  #--------------------------------------------------------------------------
  def draw_regular_polygon(x, y, r, n, color, width = 1)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.draw_regular_polygon(get_base_info,
      x, y, r, n, color.argb_code, width)
  end
  #--------------------------------------------------------------------------
  # ○ 正多角形塗り潰し
  #--------------------------------------------------------------------------
  def fill_regular_polygon(x, y, r, n, st_color, ed_color,
      fill_mode = TRGSSX::FM_FIT)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.fill_regular_polygon(get_base_info,
      x, y, r, n, st_color.argb_code, ed_color.argb_code, fill_mode)
  end
  #--------------------------------------------------------------------------
  # ○ スポーク描画
  #--------------------------------------------------------------------------
  def draw_spoke(x, y, r, n, color, width = 1)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.draw_spoke(get_base_info,
      x, y, r, n, color.argb_code, width)
  end
  #--------------------------------------------------------------------------
  # ○ アンチエイリアス無効テキスト描画
  #--------------------------------------------------------------------------
  def draw_text_na(*args)
    return -1 if TRGSSX::NO_TRGSSX

    x, y, width, height, text, align = get_text_args(args)
    fname = get_available_font_name
    flags = get_draw_text_flags

    return TRGSSX.draw_text_na(get_base_info, x, y, width, height, text,
      fname, font.size, get_text_color, align, flags)
  end
  #--------------------------------------------------------------------------
  # ○ 高速テキスト描画
  #--------------------------------------------------------------------------
  def draw_text_fast(*args)
    return -1 if TRGSSX::NO_TRGSSX

    x, y, width, height, text, align = get_text_args(args)
    fname = get_available_font_name
    flags = get_draw_text_flags

    return TRGSSX.draw_text_fast(get_base_info, x, y, width, height, text,
      fname, font.size, get_text_color, align, flags)
  end
  #--------------------------------------------------------------------------
  # ○ 描画サイズ取得 (na)
  #--------------------------------------------------------------------------
  def text_size_na(text)
    return -1 if TRGSSX::NO_TRGSSX

    fname = get_available_font_name
    flags = get_draw_text_flags
    size  = [0, 0].pack('l!2')

    result = TRGSSX.get_text_size_na(get_base_info, text.to_s,
      fname, font.size, flags, size)

    size = size.unpack('l!2')
    rect = Rect.new(0, 0, size[0], size[1])
    return rect
  end
  #--------------------------------------------------------------------------
  # ○ 描画サイズ取得 (fast)
  #--------------------------------------------------------------------------
  def text_size_fast(text)
    return -1 if TRGSSX::NO_TRGSSX

    fname = get_available_font_name
    flags = get_draw_text_flags
    size  = [0, 0].pack('l!2')

    result = TRGSSX.get_text_size_fast(get_base_info, text.to_s,
      fname, font.size, flags, size)

    size = size.unpack('l!2')
    rect = Rect.new(0, 0, size[0], size[1])
    return rect
  end
  #--------------------------------------------------------------------------
  # ○ 描画引数を取得
  #--------------------------------------------------------------------------
  def get_text_args(args)
    if args[0].is_a?(Rect)
      # 矩形
      if args.size.between?(2, 4)
        x, y = args[0].x, args[0].y
        width, height = args[0].width, args[0].height
        text  = args[1].to_s
        align = (args[2].equal?(nil) ? 0 : args[2])
      else
        raise(ArgumentError,
          "wrong number of arguments(#{args.size} of #{args.size < 2 ? 2 : 4})")
        return
      end
    else
      # 数値
      if args.size.between?(5, 7)
        x, y, width, height = args
        text  = args[4].to_s
        align = (args[5].equal?(nil) ? 0 : args[5])
      else
        raise(ArgumentError,
          "wrong number of arguments(#{args.size} of #{args.size < 5 ? 5 : 7})")
        return
      end
    end
    return [x, y, width, height, text, align]
  end
  private :get_text_args
  #--------------------------------------------------------------------------
  # ○ 有効なフォント名を取得
  #--------------------------------------------------------------------------
  def get_available_font_name
    if font.name.is_a?(Array)
      font.name.each { |f|
        return f if Font.exist?(f)
      }
      return nil
    else
      return font.name
    end
  end
  private :get_available_font_name
  #--------------------------------------------------------------------------
  # ○ 文字色 (main, gradation, shadow, needGrad) の pack を取得
  #--------------------------------------------------------------------------
  def get_text_color
    need_grad = !font.gradation_color.equal?(nil)
    result = []
    result << font.color.argb_code
    result << (need_grad ? font.gradation_color.argb_code : 0)
    result << 0xFF000000
    result << (need_grad ? 1 : 0)
    return result.pack('l!4')
  end
  private :get_text_color
  #--------------------------------------------------------------------------
  # ○ テキスト描画フラグを取得
  #--------------------------------------------------------------------------
  def get_draw_text_flags
    flags  = 0
    flags |= TRGSSX::FS_BOLD   if font.bold
    flags |= TRGSSX::FS_ITALIC if font.italic
    flags |= TRGSSX::FS_SHADOW if font.shadow && !font.frame
    flags |= TRGSSX::FS_FRAME  if font.frame
    return flags
  end
  private :get_draw_text_flags
  #--------------------------------------------------------------------------
  # ○ 保存
  #     filename : 保存先
  #--------------------------------------------------------------------------
  def save(filename)
    return -1 if TRGSSX::NO_TRGSSX

    return TRGSSX.save_to_bitmap(filename, get_base_info)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#==============================================================================

class Color
  #--------------------------------------------------------------------------
  # ○ ARGB コード取得
  #--------------------------------------------------------------------------
  def argb_code
    n  = 0
    n |= alpha.to_i << 24
    n |= red.to_i   << 16
    n |= green.to_i <<  8
    n |= blue.to_i
    return n
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#==============================================================================

class Font
  unless const_defined?(:XP_MODE)
    # XP 専用処理
    unless method_defined?(:shadow)
      XP_MODE = true
      @@default_shadow = false
      attr_writer :shadow
      def self.default_shadow
        return @@default_shadow
      end
      def self.default_shadow=(s)
        @@default_shadow = s
      end
      def shadow
        return (@shadow == nil ? @@default_shadow : @shadow)
      end
    else
      XP_MODE = false
    end
  end
  #--------------------------------------------------------------------------
  # ○ クラス変数
  #--------------------------------------------------------------------------
  @@default_frame           = KGC::BitmapExtension::DEFAULT_FRAME
  @@default_gradation_color = KGC::BitmapExtension::DEFAULT_GRAD_COLOR
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :gradation_color
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  unless private_method_defined?(:initialize_KGC_BitmapExtension)
    alias initialize_KGC_BitmapExtension initialize
  end
  def initialize(name = Font.default_name, size = Font.default_size)
    initialize_KGC_BitmapExtension(name, size)

    @frame = nil
    @gradation_color = @@default_gradation_color
    if XP_MODE
      @shadow = nil
    end
  end
  #--------------------------------------------------------------------------
  # ○ デフォルト縁取りフラグ設定
  #--------------------------------------------------------------------------
  def self.default_frame
    return @@default_frame
  end
  #--------------------------------------------------------------------------
  # ○ デフォルト縁取りフラグ設定
  #--------------------------------------------------------------------------
  def self.default_frame=(value)
    @@default_frame = value
  end
  #--------------------------------------------------------------------------
  # ○ デフォルトグラデーション色設定
  #--------------------------------------------------------------------------
  def self.default_gradation_color
    return @@default_gradation_color
  end
  #--------------------------------------------------------------------------
  # ○ デフォルトグラデーション色設定
  #--------------------------------------------------------------------------
  def self.default_gradation_color=(value)
    @@default_gradation_color = value
  end
  #--------------------------------------------------------------------------
  # ● 影文字フラグ設定
  #--------------------------------------------------------------------------
  unless method_defined?(:shadow_eq) || XP_MODE
    alias shadow_eq shadow=
  end
  def shadow=(value)
    XP_MODE ? @shadow = value : shadow_eq(value)
  end
  #--------------------------------------------------------------------------
  # ○ 縁取りフラグ取得
  #--------------------------------------------------------------------------
  def frame
    return (@frame == nil ? @@default_frame : @frame)
  end
  #--------------------------------------------------------------------------
  # ○ 縁取りフラグ設定
  #--------------------------------------------------------------------------
  def frame=(value)
    @frame = value
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   クリッピング用のリージョンを扱うクラスです。
#==============================================================================

class Region
  #--------------------------------------------------------------------------
  # ○ クラス変数
  #--------------------------------------------------------------------------
  @@handles = []  # 生成したリージョンハンドル
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  @@_api_delete_object = Win32API.new('gdi32', 'DeleteObject', 'l', 'l')
  #--------------------------------------------------------------------------
  # ○ リージョンハンドル生成
  #--------------------------------------------------------------------------
  def create_region_handle
    # 継承先で再定義
    return 0
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def &(obj)
    return nil unless obj.is_a?(Region)
    return CombinedRegion.new(CombinedRegion::RGN_AND, self, obj)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def *(obj)
    return self.&(obj)
  end
  #--------------------------------------------------------------------------
  # ○ OR (|)
  #--------------------------------------------------------------------------
  def |(obj)
    return nil unless obj.is_a?(Region)
    return CombinedRegion.new(CombinedRegion::RGN_OR, self, obj)
  end
  #--------------------------------------------------------------------------
  # ○ OR (+)
  #--------------------------------------------------------------------------
  def +(obj)
    return self.|(obj)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def ^(obj)
    return nil unless obj.is_a?(Region)
    return CombinedRegion.new(CombinedRegion::RGN_XOR, self, obj)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def -(obj)
    return nil unless obj.is_a?(Region)
    return CombinedRegion.new(CombinedRegion::RGN_DIFF, self, obj)
  end

  #--------------------------------------------------------------------------
  # ○ リージョンハンドル破棄
  #--------------------------------------------------------------------------
  def self.delete_region_handles
    @@handles.uniq!
    @@handles.each { |h| @@_api_delete_object.call(h) }
    @@handles.clear
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   矩形リージョンを扱うクラスです。
#==============================================================================

class RectRegion < Region
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :x               # X 座標
  attr_accessor :y               # Y 座標
  attr_accessor :width           # 幅
  attr_accessor :height          # 高さ
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  @@_api_create_rect_rgn = Win32API.new('gdi32',
    'CreateRectRgn', 'llll', 'l')
  @@_api_create_rect_rgn_indirect = Win32API.new('gdi32',
    'CreateRectRgnIndirect', 'l', 'l')
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(*args)
    if args[0].is_a?(Rect)
      rect = args[0]
      @x = rect.x
      @y = rect.y
      @width  = rect.width
      @height = rect.height
    else
      @x, @y, @width, @height = args
    end
  end
  #--------------------------------------------------------------------------
  # ○ リージョンハンドル生成
  #--------------------------------------------------------------------------
  def create_region_handle
    hRgn = @@_api_create_rect_rgn.call(@x, @y, @x + @width, @y + @height)
    @@handles << hRgn
    return hRgn
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   角丸矩形リージョンを扱うクラスです。
#==============================================================================

class RoundRectRegion < RectRegion
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :width_ellipse   # 丸みの幅
  attr_accessor :height_ellipse  # 丸みの高さ
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  @@_api_create_round_rect_rgn = Win32API.new('gdi32',
    'CreateRoundRectRgn', 'llllll', 'l')
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(*args)
    super
    if args[0].is_a?(Rect)
      @width_ellipse  = args[1]
      @height_ellipse = args[2]
    else
      @width_ellipse  = args[4]
      @height_ellipse = args[5]
    end
  end
  #--------------------------------------------------------------------------
  # ○ リージョンハンドル生成
  #--------------------------------------------------------------------------
  def create_region_handle
    hRgn = @@_api_create_round_rect_rgn.call(@x, @y, @x + @width, @y + @height,
      width_ellipse, height_ellipse)
    @@handles << hRgn
    return hRgn
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   楕円形リージョンを扱うクラスです。
#==============================================================================

class EllipticRegion < RectRegion
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  @@_api_create_elliptic_rgn = Win32API.new('gdi32',
    'CreateEllipticRgn', 'llll', 'l')
  @@_api_create_elliptic_rgn_indirect = Win32API.new('gdi32',
    'CreateEllipticRgnIndirect', 'l', 'l')
  #--------------------------------------------------------------------------
  # ○ リージョンハンドル生成
  #--------------------------------------------------------------------------
  def create_region_handle
    hRgn = @@_api_create_elliptic_rgn.call(@x, @y, @x + @width, @y + @height)
    @@handles << hRgn
    return hRgn
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   円形リージョンを扱うクラスです。
#==============================================================================

class CircularRegion < EllipticRegion
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :radius  # 半径
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, r)
    @cx = x
    @cy = y
    self.radius = r
    super(@cx - r, @cy - r, r * 2, r * 2)
  end
  #--------------------------------------------------------------------------
  # ○ 中心 X 座標参照
  #--------------------------------------------------------------------------
  def x
    return @cx
  end
  #--------------------------------------------------------------------------
  # ○ 中心 Y 座標参照
  #--------------------------------------------------------------------------
  def y
    return @cy
  end
  #--------------------------------------------------------------------------
  # ○ 中心 X 座標変更
  #--------------------------------------------------------------------------
  def x=(value)
    @cx = value
    @x = @cx - @radius
  end
  #--------------------------------------------------------------------------
  # ○ 中心 Y 座標変更
  #--------------------------------------------------------------------------
  def y=(value)
    @cy = value
    @y = @cy - @radius
  end
  #--------------------------------------------------------------------------
  # ○ 半径変更
  #--------------------------------------------------------------------------
  def radius=(value)
    @radius = value
    @x = @cx - @radius
    @y = @cy - @radius
    @width = @height = @radius * 2
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   多角形リージョンを扱うクラスです。
#==============================================================================

class PolygonRegion < Region
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  # 多角形充填形式
  ALTERNATE = 1  # 交互モード
  WINDING   = 2  # 螺旋モード
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :points     # 頂点座標 [x, y] の配列
  attr_accessor :fill_mode  # 多角形充填形式
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  @@_api_create_polygon_rgn = Win32API.new('gdi32',
    'CreatePolygonRgn', 'pll', 'l')
  @@_api_create_polypolygon_rgn = Win32API.new('gdi32',
    'CreatePolyPolygonRgn', 'llll', 'l')
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(*points)
    @points = points  # [x, y] の配列
    @fill_mode = WINDING
  end
  #--------------------------------------------------------------------------
  # ○ リージョンハンドル生成
  #--------------------------------------------------------------------------
  def create_region_handle
    pts = ""
    points.each { |pt| pts += pt.pack("ll") }
    hRgn = @@_api_create_polygon_rgn.call(pts, points.size, fill_mode)
    @@handles << hRgn
    return hRgn
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   星型リージョンを扱うクラスです。
#==============================================================================

class StarRegion < PolygonRegion
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  POINT_NUM = 5               # 点数
  PI_4      = 4.0 * Math::PI  # 4 * Pi
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :x               # X 座標
  attr_reader   :y               # Y 座標
  attr_reader   :width           # 幅
  attr_reader   :height          # 高さ
  attr_reader   :angle           # 回転角度 (0 ～ 359)
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(*args)
    super()
    shape = args[0]
    ang = args[1]
    case shape
    when CircularRegion
      @x = shape.x - shape.radius
      @y = shape.y - shape.radius
      @width = @height = shape.radius * 2
    when Rect, RectRegion, EllipticRegion
      @x = shape.x
      @y = shape.y
      @width  = shape.width
      @height = shape.height
    when Integer
      @x, @y, @width, @height = args
      ang = args[4]
    else
      @x = @y = @width = @height = 0
    end
    @angle = (ang == nil ? 0 : ang % 360)
    @__init = true
    @points = create_star_points
  end
  #--------------------------------------------------------------------------
  # ○ 星型座標を生成
  #--------------------------------------------------------------------------
  def create_star_points
    return unless @__init

    dw = (width + 1) / 2
    dh = (height + 1) / 2
    dx = x + dw
    dy = y + dh
    base_angle = angle * Math::PI / 180.0
    pts = []
    POINT_NUM.times { |i|
      ang = base_angle + PI_4 * i / POINT_NUM
      pts << [dx + (Math.sin(ang) * dw).to_i,
        dy - (Math.cos(ang) * dh).to_i]
    }
    return pts
  end
  #--------------------------------------------------------------------------
  # ○ X 座標変更
  #--------------------------------------------------------------------------
  def x=(value)
    @x = value
    @points = create_star_points
  end
  #--------------------------------------------------------------------------
  # ○ Y 座標変更
  #--------------------------------------------------------------------------
  def y=(value)
    @y = value
    @points = create_star_points
  end
  #--------------------------------------------------------------------------
  # ○ 幅変更
  #--------------------------------------------------------------------------
  def width=(value)
    @width = value
    @points = create_star_points
  end
  #--------------------------------------------------------------------------
  # ○ 高さ座標変更
  #--------------------------------------------------------------------------
  def height=(value)
    @height = value
    @points = create_star_points
  end
  #--------------------------------------------------------------------------
  # ○ 開始角度変更
  #--------------------------------------------------------------------------
  def angle=(value)
    @angle = value % 360
    @points = create_star_points
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   扇形リージョンを扱うクラスです。
#==============================================================================

class PieRegion < Region
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  HALF_PI = Math::PI / 2.0  # PI / 2
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :begin_angle     # 開始角度 [degree]
  attr_reader   :sweep_angle     # 描画角度 (0 ～ 359)
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(*args)
    super()
    shape = args[0]
    ang1, ang2 = args[1..2]
    case shape
    when CircularRegion
      @cx = shape.x
      @cy = shape.y
      self.radius = shape.radius
    else
      @cx = @cy = @x = @y = @radius = 0
    end
    self.start_angle = (ang1 == nil ? 0 : ang1)
    self.sweep_angle = (ang2 == nil ? 0 : ang2)
    @__init = true
    create_pie_region
  end
  #--------------------------------------------------------------------------
  # ○ 扇形リージョンを生成
  #--------------------------------------------------------------------------
  def create_pie_region
    return unless @__init

    # 座標・範囲調整
    st_deg = @start_angle += (@sweep_angle < 0 ? @sweep_angle : 0)
    st_deg %= 360
    ed_deg = st_deg + @sweep_angle.abs
    diff = st_deg % 90
    r = @radius * 3 / 2
    s = st_deg / 90
    e = ed_deg / 90

    # リージョン作成
    @region = nil
    (s..e).each { |i|
      break if i * 90 >= ed_deg
      if diff > 0
        st_rad = (i * 90 + diff) * Math::PI / 180.0
        diff = 0
      else
        st_rad = i * HALF_PI
      end
      if (i + 1) * 90 > ed_deg
        ed_rad = ed_deg * Math::PI / 180.0
      else
        ed_rad = (i + 1) * HALF_PI
      end
      pt1 = [@cx, @cy]
      pt2 = [
        @cx + Integer(Math.cos(st_rad) * r),
        @cy + Integer(Math.sin(st_rad) * r)
      ]
      pt3 = [
        @cx + Integer(Math.cos(ed_rad) * r),
        @cy + Integer(Math.sin(ed_rad) * r)
      ]
      rgn = PolygonRegion.new(pt1, pt2, pt3)
      if @region == nil
        @region = rgn
      else
        @region |= rgn
      end
    }
    @region &= CircularRegion.new(@cx, @cy, @radius)

    return @region
  end
  #--------------------------------------------------------------------------
  # ○ 中心 X 座標参照
  #--------------------------------------------------------------------------
  def x
    return @cx
  end
  #--------------------------------------------------------------------------
  # ○ 中心 Y 座標参照
  #--------------------------------------------------------------------------
  def y
    return @cy
  end
  #--------------------------------------------------------------------------
  # ○ 中心 X 座標変更
  #--------------------------------------------------------------------------
  def x=(value)
    @cx = value
    @x = @cx - @radius
    create_pie_region
  end
  #--------------------------------------------------------------------------
  # ○ 中心 Y 座標変更
  #--------------------------------------------------------------------------
  def y=(value)
    @cy = value
    @y = @cy - @radius
    create_pie_region
  end
  #--------------------------------------------------------------------------
  # ○ 半径変更
  #--------------------------------------------------------------------------
  def radius=(value)
    @radius = value
    @x = @cx - @radius
    @y = @cy - @radius
    create_pie_region
  end
  #--------------------------------------------------------------------------
  # ○ 開始角度変更
  #--------------------------------------------------------------------------
  def start_angle=(value)
    @start_angle = value
    create_pie_region
  end
  #--------------------------------------------------------------------------
  # ○ 描画角度変更
  #--------------------------------------------------------------------------
  def sweep_angle=(value)
    @sweep_angle = [[value, -360].max, 360].min
    create_pie_region
  end
  #--------------------------------------------------------------------------
  # ○ リージョンハンドル生成
  #--------------------------------------------------------------------------
  def create_region_handle
    return @region.create_region_handle
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#------------------------------------------------------------------------------
#   混合リージョンを扱うクラスです。
#==============================================================================

class CombinedRegion < Region
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  # 合成モード
  RGN_AND  = 1
  RGN_OR   = 2
  RGN_XOR  = 3
  RGN_DIFF = 4
  RGN_COPY = 5
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  @@_api_combine_rgn = Win32API.new('gdi32', 'CombineRgn', 'llll', 'l')
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(mode, region1, region2)
    @exp = CombinedRegionExp.new(mode, region1.clone, region2.clone)
  end
  #--------------------------------------------------------------------------
  # ○ リージョンハンドル生成
  #--------------------------------------------------------------------------
  def create_region_handle
    return combine_region(@exp.region1, @exp.region2, @exp.mode)
  end
  #--------------------------------------------------------------------------
  # ○ リージョン合成
  #     dest : 合成先
  #     src  : 合成元
  #     mode : 合成モード
  #--------------------------------------------------------------------------
  def combine_region(dest, src, mode)
    hdest = dest.create_region_handle
    hsrc  = src.create_region_handle
    @@_api_combine_rgn.call(hdest, hdest, hsrc, mode)
    return hdest
  end
  protected :combine_region
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
#==============================================================================

# □ CombinedRegionExp 構造体
CombinedRegionExp = Struct.new("CombinedRegionExp", :mode, :region1, :region2)

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

class Bitmap
  unless method_defined?(:_draw_text)
    alias _draw_text draw_text
    alias _text_size text_size

    case KGC::BitmapExtension::DEFAULT_MODE
    when 1  # na
      alias draw_text draw_text_na
      alias text_size text_size_na
    when 2 # 詳見頁首繁中說明
      alias draw_text draw_text_fast
      alias text_size text_size_fast
    end
  end
end

Font.default_name = KGC::BitmapExtension::DEFAULT_FONT_NAME[
  KGC::BitmapExtension::DEFAULT_MODE]