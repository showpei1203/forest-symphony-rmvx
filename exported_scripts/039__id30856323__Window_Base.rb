#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_Base
# 【用途】VX 所有視窗的基礎類，提供字型、顏色、圖示、角色圖、臉圖、HP/MP 與文字繪製共用方法。
# 【主要機制】由各 Scene 建立並逐幀更新；後續 UI 插件通常以 class reopen／alias 擴充。
# 【主要影響】Window_Base
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：WLH。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Window、Iconset。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ** Window_Base
#------------------------------------------------------------------------------
#  這個類是遊戲中所有視窗所共同繼承的父類。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * 常數
  #--------------------------------------------------------------------------
  WLH = 24                  # 視窗行高
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x      : 視窗X座標
  #     y      : 視窗Y座標
  #     width  : 視窗寬度
  #     height : 視窗高度
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super()
    self.windowskin = Cache.system("Window")
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    self.back_opacity = 200
    self.openness = 255
    create_contents
    @opening = false
    @closing = false
  end
  #--------------------------------------------------------------------------
  # * 清除視窗
  #--------------------------------------------------------------------------
  def dispose
    self.contents.dispose
    super
  end
  #--------------------------------------------------------------------------
  # * 創建視窗內容
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, height - 32)
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    if @opening
      self.openness += 48
      @opening = false if self.openness == 255
    elsif @closing
      self.openness -= 48
      @closing = false if self.openness == 0
    end
  end
  #--------------------------------------------------------------------------
  # * 展開視窗
  #--------------------------------------------------------------------------
  def open
    @opening = true if self.openness < 255
    @closing = false
  end
  #--------------------------------------------------------------------------
  # * 合攏視窗
  #--------------------------------------------------------------------------
  def close
    @closing = true if self.openness > 0
    @opening = false
  end
  #--------------------------------------------------------------------------
  # * 從視窗皮膚素材拾取文本顏色
  #     n : 文本顏色編號（0-31）
  #--------------------------------------------------------------------------
  def text_color(n)
    x = 64 + (n % 8) * 8
    y = 96 + (n / 8) * 8
    return windowskin.get_pixel(x, y)
  end
  #--------------------------------------------------------------------------
  # * 獲取普通文本顏色
  #--------------------------------------------------------------------------
  def normal_color
    return text_color(0)
  end
  #--------------------------------------------------------------------------
  # * 獲取系統文本顏色
  #--------------------------------------------------------------------------
  def system_color
    return text_color(16)
  end
  #--------------------------------------------------------------------------
  # * 獲取重傷危象文本顏色
  #--------------------------------------------------------------------------
  def crisis_color
    return text_color(17)
  end
  #--------------------------------------------------------------------------
  # * 獲取瀕死文本顏色
  #--------------------------------------------------------------------------
  def knockout_color
    return text_color(18)
  end
  #--------------------------------------------------------------------------
  # * 獲取值槽背景顏色
  #--------------------------------------------------------------------------
  def gauge_back_color
    return text_color(19)
  end
  #--------------------------------------------------------------------------
  # * 獲取HP值槽過渡起始顏色
  #--------------------------------------------------------------------------
  def hp_gauge_color1
    return text_color(20)
  end
  #--------------------------------------------------------------------------
  # * 獲取HP值槽過渡結束顏色
  #--------------------------------------------------------------------------
  def hp_gauge_color2
    return text_color(21)
  end
  #--------------------------------------------------------------------------
  # * 獲取MP值槽過渡起始顏色
  #--------------------------------------------------------------------------
  def mp_gauge_color1
    return text_color(22)
  end
  #--------------------------------------------------------------------------
  # * 獲取MP值槽過渡結束顏色
  #--------------------------------------------------------------------------
  def mp_gauge_color2
    return text_color(23)
  end
  #--------------------------------------------------------------------------
  # * 獲取整備介面主角參數值提升顏色
  #--------------------------------------------------------------------------
  def power_up_color
    return text_color(24)
  end
  #--------------------------------------------------------------------------
  # * 獲取整備介面主角參數值下降顏色
  #--------------------------------------------------------------------------
  def power_down_color
    return text_color(25)
  end
  #--------------------------------------------------------------------------
  # * 繪製圖示
  #     icon_index : 圖示編號
  #     x     : 圖示繪製區域X座標
  #     y     : 圖示繪製區域Y座標
  #     enabled    : 可用性標幟，如果為false則半透明化圖示繪製。
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 128)
  end
  #--------------------------------------------------------------------------
  # * 繪製臉圖
  #     face_name  : 臉圖檔案名
  #     face_index : 臉圖編號
  #     x     : 臉圖繪製區域X座標
  #     y     : 臉圖繪製區域Y座標
  #     size       : 顯示尺寸
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, size = 96)
    bitmap = Cache.face(face_name)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = face_index % 4 * 96 + (96 - size) / 2
    rect.y = face_index / 4 * 96 + (96 - size) / 2
    rect.width = size
    rect.height = size
    self.contents.blt(x, y, bitmap, rect)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * 繪製人物特徵圖
  #     character_name  : 人物特徵圖圖檔名
  #     character_index : 人物特徵圖編號
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # * 獲取HP文本顏色
  #     actor : 主角
  #--------------------------------------------------------------------------
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < actor.maxhp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * 獲取MP文本顏色
  #     actor : 主角
  #--------------------------------------------------------------------------
  def mp_color(actor)
    return crisis_color if actor.mp < actor.maxmp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * 繪製主角步行圖
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    draw_character(actor.character_name, actor.character_index, x, y)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角臉圖
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     size  : Display size
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, size = 96)
    draw_face(actor.face_name, actor.face_index, x, y, size)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角名稱
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y)
    self.contents.font.color = hp_color(actor)
    self.contents.draw_text(x, y, 108, WLH, actor.name)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角職業
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 108, WLH, actor.class.name)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角等級
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, WLH, Vocab::level_a)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 32, y, 24, WLH, actor.level, 2)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角狀態
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     width : draw spot width
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, width = 96)
    count = 0
    for state in actor.states
      draw_icon(state.icon_index, x + 24 * count, y)
      count += 1
      break if (24 * count > width - 24)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製HP
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     width : 繪製寬度
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 120)
    draw_actor_hp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 30, WLH, Vocab::hp_a)
    self.contents.font.color = hp_color(actor)
    last_font_size = self.contents.font.size
    xr = x + width
    if width < 120
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.hp, 2)
    else
      self.contents.draw_text(xr - 99, y, 44, WLH, actor.hp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.maxhp, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製HP槽
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     width : 繪製寬度
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    gw = width * actor.hp / actor.maxhp
    gc1 = hp_gauge_color1
    gc2 = hp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end
  #--------------------------------------------------------------------------
  # * 繪製MP
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     width : 繪製寬度
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 120)
    draw_actor_mp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 30, WLH, Vocab::mp_a)
    self.contents.font.color = mp_color(actor)
    last_font_size = self.contents.font.size
    xr = x + width
    if width < 120
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.mp, 2)
    else
      self.contents.draw_text(xr - 99, y, 44, WLH, actor.mp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.maxmp, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製MP槽
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     width : 繪製寬度
  #--------------------------------------------------------------------------
  def draw_actor_mp_gauge(actor, x, y, width = 120)
    gw = width * actor.mp / [actor.maxmp, 1].max
    gc1 = mp_gauge_color1
    gc2 = mp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end
  #--------------------------------------------------------------------------
  # * 繪製主角參數
  #     actor : 主角
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     type  : 主角參數種類（0-3）
  #--------------------------------------------------------------------------
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = Vocab::atk
      parameter_value = actor.atk
    when 1
      parameter_name = Vocab::def
      parameter_value = actor.def
    when 2
      parameter_name = Vocab::spi
      parameter_value = actor.spi
    when 3
      parameter_name = Vocab::agi
      parameter_value = actor.agi
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, WLH, parameter_value, 2)
  end
  #--------------------------------------------------------------------------
  # * 繪製條目
  #     item    : 條目（技能、物品、防具都可以）
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     enabled    : 可用性標幟，如果為false則半透明化條目繪製。
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true)
    if item != nil
      draw_icon(item.icon_index, x, y, enabled)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x + 24, y, 172, WLH, item.name)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製條目
  #     item    : 條目（技能、物品、防具都可以）
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     enabled    : 可用性標幟，如果為false則半透明化條目繪製。
  #--------------------------------------------------------------------------
  def draw_item_name10(item, x, y, enabled = true)
    if item != nil
      draw_icon(item.icon_index, x, y, enabled)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x + 24, y, 172, WLH, item.name)
    end
  end
   #--------------------------------------------------------------------------
  # * 繪製條目
  #     item    : 條目（技能、物品、防具都可以）
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     enabled    : 可用性標幟，如果為false則半透明化條目繪製。
  #--------------------------------------------------------------------------
  def draw_item_name11(item, x, y, enabled = true)
    if item != nil
      draw_icon(item.icon_index, x, y, enabled)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x + 24, y, 172, WLH, item.name)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製帶有貨幣單位的數值
  #     value : 數字值（資金等）
  #     x     : 繪製區域X座標
  #     y     : 繪製區域Y座標
  #     width : 繪製寬度
  #--------------------------------------------------------------------------
  def draw_currency_value(value, x, y, width)
    cx = contents.text_size(Vocab::gold).width
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, Vocab::gold, 2)
  end
end
