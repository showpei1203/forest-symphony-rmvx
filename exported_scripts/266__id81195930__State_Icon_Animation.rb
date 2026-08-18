#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：State Icon Animation
# 【用途】保留的 Runtime 元件「State Icon Animation」。
# 【主要機制】主要定義／擴充 StateIcons、Window_Base、StateAnime；下方原始說明與程式碼保留作細節依據。
# 【主要影響】StateIcons、Window_Base、StateAnime
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：NOR、SPE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
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
=begin ************************************************************************
  * State Icon Animation Ver2.00
      Actor states will animate and cycle through multiple icons rather
      than display a limited amount.
      
      Script by ziifee
=end # ************************************************************************

module StateAnime
  # * Settings
  NOR = 0             # "Normal" state icon. Use icon index number from Iconset.
  SPE = 50            # Icon change speed. (1 second = 60)
end

#==============================================================================
# ■ StateIcons
#==============================================================================

class StateIcons
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :x                        # X 座標
  attr_reader   :y                        # Y 座標
  attr_reader   :bitmap                   # ビットマップ (アイコンの裏)
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(icons, x, y, bitmap)
    @icons  = icons.empty? ? [0] : icons
    @x , @y = x , y
    @bitmap = bitmap
    @index  = 0
  end
  #--------------------------------------------------------------------------
  # ● アイコンアニメーションするかどうか
  #--------------------------------------------------------------------------
  def change?
    return true if @icons.size > 1
    return false
  end
  #--------------------------------------------------------------------------
  # ● アイコンの取得
  #--------------------------------------------------------------------------
  def icon
    icon = @icons[@index]
    @index = (@index + 1) % @icons.size
    return icon
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    @bitmap.dispose
  end
end

#==============================================================================
# ■ Window_Base
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias :stateanime_initialize :initialize
  def initialize(x, y, width, height)
    stateanime_initialize(x, y, width, height)
    @stateanime_new   = true
    @stateanime_set   = []
    @stateanime_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias :stateanime_dispose :dispose
  def dispose
    stateanime_dispose
    for state in @stateanime_set do state.dispose end
  end
  #--------------------------------------------------------------------------
  # ● ステートアニメのクリア
  #--------------------------------------------------------------------------
  def clear_stateanime
    for state in @stateanime_set do state.dispose end
    @stateanime_new   = false
    @stateanime_set   = []
    @stateanime_count = 0
  end
  #--------------------------------------------------------------------------
  # ● ステートアニメーションの描画
  #     obj : 描画するステートアイコンクラス
  #--------------------------------------------------------------------------
  def draw_stateanime(obj, setting = false)
    return if not obj.change? and not setting
    self.contents.clear_rect(obj.x, obj.y, 24, 24)
    self.contents.blt(obj.x, obj.y, obj.bitmap, Rect.new(0, 0, 24, 24))
    draw_icon(obj.icon, obj.x, obj.y)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias :stateanime_update :update
  def update
    stateanime_update
    unless @stateanime_set.empty?
      @stateanime_count += 1
      if @stateanime_count % StateAnime::SPE == 0
        @stateanime_new = true unless @stateanime_new
        for obj in @stateanime_set do draw_stateanime(obj) end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ステートの描画 改造
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, dummy_width = 24)
    clear_stateanime if @stateanime_new
    icons = []
    for state in actor.states
      #next if state.priority == 0###
      icons.push(state.icon_index) if state.icon_index > 0
    end
    if icons.empty?
      return if StateAnime::NOR <= 0 # ！ 空なので作成なし
      icons.push(StateAnime::NOR)
    end
    icons.uniq!
    bitmap   = Bitmap.new(24, 24)
    src_rect = Rect.new(x, y, 24, 24)
    bitmap.blt(0, 0, self.contents, src_rect)
    obj = StateIcons.new(icons, x, y, bitmap)
    @stateanime_set.push(obj)
    draw_stateanime(obj, true)
  end
end
