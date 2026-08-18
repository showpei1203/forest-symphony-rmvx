#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：STR14_サイドテキスト v0.8
# 【用途】保留的 Runtime 元件「STR14_サイドテキスト v0.8」。
# 【主要機制】主要定義／擴充 Sprite_Sidetext、Game_Temp、Spriteset_Map、Spriteset_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Sprite_Sidetext、Game_Temp、Spriteset_Map、Spriteset_Battle、Bitmap
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：Y_OFFSET_MAP、Y_OFFSET_BATTLE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 7 個 alias／方法包裝，載入順序具有語意。
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
# ★RGSS2 
# STR14_サイドテキスト v0.8 09/03/17
#
# ・マップ/バトル画面左横に文字をスライド表示させることができます。
# ・用法はいろいろ。
# 　入手アイテム表示、ちょっとしたアナウンス、地名表示、etc...
# ・戦闘中にもサイドテキスト表示が可能になりました。(v0.7)
if false
# 以下をコマンドのスクリプト等に貼り付けてテキスト表示
s = $game_temp.sidetext  # 
i = s.index(nil)         # 基本設定
i = s.size if (i == nil) # 
t = "サイドテキスト"     # テキスト
f = true                 # 縁取り
w = 120                  # 表示時間
c = Color.new(64,32,128) # 縁取りの色
s[i] = Sprite_Sidetext.new(t,f,w,c)
# ここまで
# ・縁取り指定　true = 有効　false = 無効
# ・表示時間　w/60秒
end
#------------------------------------------------------------------------------
#
# 更新履歴
# ◇0.7→0.8
#　Y座標の基準位置を設定できるようになった
#　名前から汎用が消える。
# ◇0.6→0.7
#　戦闘中のサイドテキスト対応
# ◇0.5→0.6
#　Z座標変更
#　縁取りカラーを指定できるようになった
#
#==============================================================================
# ■ Sprite_Sidetext
#==============================================================================
class Sprite_Sidetext < Sprite
  # Y座標の基準位置
  Y_OFFSET_MAP    = 82  # マップ画面
  Y_OFFSET_BATTLE = 128 # バトル画面
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(text, frame = false, wait = 120, c = Color.new(64,32,128))
    super()
    self.x = 16
    num = $game_temp.sidetext.index(nil)
    num = $game_temp.sidetext.size if (num == nil)
    y = ($game_temp.in_battle ?  Y_OFFSET_BATTLE : Y_OFFSET_MAP) + (num * 24)
    self.y = y
    self.z = 200
    bitmap = Bitmap.new(32, 24)
    w = bitmap.text_size(text).width
    bitmap.dispose
    bitmap = Bitmap.new(w, 24)
    if frame
      bitmap.draw_text_f(0, 0, w, 24, text, 0, c)
    else
      bitmap.draw_text(0, 0, w, 24, text)
    end
    self.bitmap = bitmap
    self.opacity = 0
    @wait = wait
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    if @wait > 0
      self.opacity += 24
      return if self.opacity != 255
      @wait -= 1
    else
      self.x += 4
      self.opacity -= 8
      dispose if self.opacity == 0
    end
  end
end
#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :sidetext
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_str14 initialize
  def initialize
    initialize_str14
    @sidetext = []
  end
end
#==============================================================================
# ■ Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● Sテキストの作成
  #--------------------------------------------------------------------------
  def create_sidetext
    $game_temp.sidetext = []
  end
  #--------------------------------------------------------------------------
  # ● Sテキストの解放
  #--------------------------------------------------------------------------
  def dispose_sidetext
    for i in 0...$game_temp.sidetext.size
      $game_temp.sidetext[i].dispose if $game_temp.sidetext[i] != nil
    end
    $game_temp.sidetext = []
  end
  #--------------------------------------------------------------------------
  # ● Sテキストの更新
  #--------------------------------------------------------------------------
  def update_sidetext
    for i in 0...$game_temp.sidetext.size
      if $game_temp.sidetext[i] != nil
        $game_temp.sidetext[i].update
        if $game_temp.sidetext[i].disposed?
          $game_temp.sidetext[i] = nil
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ★ エイリアス
  #--------------------------------------------------------------------------
  alias create_parallax_str14 create_parallax
  def create_parallax
    create_parallax_str14
    create_sidetext
  end
  alias dispose_str14 dispose
  def dispose
    dispose_sidetext
    dispose_str14
  end
  alias update_str14 update
  def update
    update_str14
    update_sidetext
  end
end
#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● Sテキストの作成
  #--------------------------------------------------------------------------
  def create_sidetext
    $game_temp.sidetext = []
  end
  #--------------------------------------------------------------------------
  # ● Sテキストの解放
  #--------------------------------------------------------------------------
  def dispose_sidetext
    for i in 0...$game_temp.sidetext.size
      $game_temp.sidetext[i].dispose if $game_temp.sidetext[i] != nil
    end
    $game_temp.sidetext = []
  end
  #--------------------------------------------------------------------------
  # ● Sテキストの更新
  #--------------------------------------------------------------------------
  def update_sidetext
    for i in 0...$game_temp.sidetext.size
      if $game_temp.sidetext[i] != nil
        $game_temp.sidetext[i].update
        if $game_temp.sidetext[i].disposed?
          $game_temp.sidetext[i] = nil
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ★ エイリアス
  #--------------------------------------------------------------------------
  alias create_battleback_str14 create_battleback
  def create_battleback
    create_battleback_str14
    create_sidetext
  end
  alias dispose_str14 dispose
  def dispose
    dispose_sidetext
    dispose_str14
  end
  alias update_str14 update
  def update
    update_str14
    update_sidetext
  end
end
#==============================================================================
# ■ Bitmap
#==============================================================================
class Bitmap
  #--------------------------------------------------------------------------
  # ● 文字縁取り描画
  #--------------------------------------------------------------------------
  def draw_text_f(x, y, width, height, str, align = 0, color = Color.new(64,32,128))
    shadow = self.font.shadow
    b_color = self.font.color.dup
    font.shadow = false
    font.color = color
    draw_text(x + 1, y, width, height, str, align) 
    draw_text(x - 1, y, width, height, str, align) 
    draw_text(x, y + 1, width, height, str, align) 
    draw_text(x, y - 1, width, height, str, align) 
    font.color = b_color
    draw_text(x, y, width, height, str, align)
    font.shadow = shadow
  end
  def draw_text_f_rect(r, str, align = 0, color = Color.new(64,32,128)) 
    draw_text_f(r.x, r.y, r.width, r.height, str, align = 0, color) 
  end
end