#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：STR20_入手インフォメーション v1.2
# 【用途】保留的 Runtime 元件「STR20_入手インフォメーション v1.2」。
# 【主要機制】主要定義／擴充 Window_Getinfo、Game_Temp、Bitmap；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_Getinfo、Game_Temp、Bitmap
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：G_ICON、Y_TYPE、TIME、OPACITY、B_COLOR、INFO_SE、STR20W。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：On。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# STR20_入手インフォメーション v1.2 09/03/17
# 
# ◇必須スクリプト　STEMB_マップエフェクトベース
#
# ・マップ画面にアイテム入手・スキル修得などの際に表示するインフォです。
# ・表示内容は 任意指定の名目+アイテム名+ヘルプメッセージとなります。
# ・アイテムのメモ欄に info[/任意の文字列/] と記述することで
# 　通常とは別の説明文をインフォに表示させることができます。(v1.1)
# [仕様]インフォが表示されている間も移動できます。
# 　　　移動させたくない場合はウェイトを入れてください。
#------------------------------------------------------------------------------
#
# 更新履歴
# ◇1.1→1.2
#　メッセージウィンドウより上に表示されてしまうのを修正(Z座標を変更した)
# ◇1.0→1.1
#　通常とは別の説明文をインフォに表示できるようになった
#
#==============================================================================
# ■ Window_Getinfo
#==============================================================================
class Window_Getinfo < Window_Base
  # 設定箇所
  G_ICON  = 205    # ゴールド入手インフォに使用するアイコンインデックス 
  Y_TYPE  = 0     # Y座標の位置(0 = 上基準　1 = 下基準)
  Z       = 188   # Z座標(問題が起きない限り変更しないでください)
  TIME    = 100   # インフォ表示時間(1/60sec)
  OPACITY = 32    # 透明度変化スピード
  B_COLOR = Color.new(0, 0, 0, 160)        # インフォバックの色
  INFO_SE = RPG::SE.new("On", 70, 100) # インフォ表示時の効果音
  STR20W  = "info"# メモ設定ワード(※なるべく変更しないでください)
end
#
if false
# ★以下をコマンドのスクリプト等に貼り付けてテキスト表示----------------★

# 種類 / 0=ｱｲﾃﾑ 1=武器 2=防具 3=ｽｷﾙ 4=金
type = 0
# ID  / 金の場合は金額を入力
id   = 1
# 入手テキスト / 金の場合無効
text = "アイテム入手！"
#
y=""
e = $game_temp.streffect
e.push(Window_Getinfo.new(id, type, text,y))

# ★ここまで------------------------------------------------------------★
#
# ◇スキル修得時などにアクター名を直接打ち込むと
# 　アクターの名前が変えられるゲームなどで問題が生じます。
# 　なので、以下のようにtext部分を改造するといいかもしれません。
#
# 指定IDのアクターの名前取得
t = $game_actors[1].name 
text = t + " / スキル修得！"
#
end
#==============================================================================
# ■ Window_Getinfo
#==============================================================================
class Window_Getinfo < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor : アクター
  #--------------------------------------------------------------------------
  def initialize(id, type, text = "", y="")
    super(-16, 0, 544 + 32, 38 + 32)
    self.z = Z
    self.contents_opacity = 0
    self.back_opacity = 0
    self.opacity = 0
    @count = 0
    @i = $game_temp.getinfo_size.index(nil)
    @i = $game_temp.getinfo_size.size if (@i == nil)
    if Y_TYPE == 0
      self.y = -14 + (@i * 40)
    else
      self.y = 416 - 58 - (@i * 40)
    end
    $game_temp.getinfo_size[@i] = true 
    refresh(id, type, text,y)
    INFO_SE.play
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    $game_temp.getinfo_size[@i] = nil
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    self.viewport = nil
    @count += 1
    unless @count >= TIME
      self.contents_opacity += OPACITY
    else
      if Y_TYPE == 0
        self.y -= 1
      else
        self.y += 1
      end
      self.contents_opacity -= OPACITY
      dispose if self.contents_opacity == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(id, type, text = "",y="")
    case type
    when 0 ; data = $data_items[id]
    when 1 ; data = $data_weapons[id]
    when 2 ; data = $data_armors[id]
    when 3 ; data = $data_skills[id]
    when 4 ; data = id
    else   ; p "typeの値がおかしいです><;"
    end
    c = B_COLOR
    self.contents.fill_rect(0, 14, 544, 24, c)
    if type < 4
      draw_item_name(data, 4, 14)
      self.contents.draw_text(204, 14, 340, WLH, description(data))
    else
      draw_icon(G_ICON, 4, 14)
      self.contents.draw_text(28, 14, 176, WLH, data.to_s + Vocab::gold)
    end
    self.contents.font.size = 14
    w = self.contents.text_size(text).width
    self.contents.fill_rect(0, 0, w + 4, 14, c)
    self.contents.draw_text_f(124, 0+20, 340, 14, text)
    self.contents.draw_text_f(104, 0+20, 340, 14, y)
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● 解説文取得
  #--------------------------------------------------------------------------
  def description(data)
    return $1.gsub!(/[\t\n\r\f]*/,"") if (data.note[/#{STR20W}\[\/(.*)\/\]/im]) != nil
    return data.description
  end
end
#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :getinfo_size
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_str20 initialize
  def initialize
    initialize_str20
    @getinfo_size = []
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