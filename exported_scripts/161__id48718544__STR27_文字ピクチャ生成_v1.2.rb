#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：STR27_文字ピクチャ生成 v1.2
# 【用途】保留的 Runtime 元件「STR27_文字ピクチャ生成 v1.2」。
# 【主要機制】主要定義／擴充 Game_Interpreter、Sprite_Picture、Bitmap、STR_DumpFont；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter、Sprite_Picture、Bitmap、STR_DumpFont、STRRGSS2
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：STR27_FLIST。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Iconback、Iconback_2。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# STR27_文字ピクチャ生成 v1.2 09/04/18
#
# ・指定した文字列をピクチャ表示させます。
#
# ■使用方法
#　以下のスクリプトをイベントコマンドで実行した後、
#　ピクチャの表示"コマンドで文字ピクチャを表示させます。
=begin
ここから

AV[X] 可顯示變數，x為變數id

# テキスト
t = "hogehoge"
s = 20 # 文字サイズ
p = 0  # フォントパターン
text_picture(t, p, s)

ここまで
=end
#
# ※フォントパターンは下の設定箇所で定義します。
# ※フォントサイズが小さすぎたり大きすぎたりすると
# 　エラーがでます。注意してください。
#
#------------------------------------------------------------------------------
#
# 更新履歴
# ◇1.1→1.2
#　影文字を無効に出来ない不具合を修正
# ◇1.0→1.1
#　""内の改行箇所などで･が表示されるバグを修正
#
#==============================================================================
# ★ フォントパターン定義(設定箇所)
#==============================================================================
module STRRGSS2
  #              ↓対応する値
                # 通常の文字
  STR27_FLIST = {0 => ["微軟正黑體",             # フォント名
                       true,                 # 太字
                       false,                 # 斜体
                       true,                  # 影文字
                       true,                  # 縁取り
                       Color.new(255,255,255),# 文字色
                       #Color.new(-136, 0,17)
                       Color.new( 64, 32,128) # 縁取り色
                       ],
                # 斜め・縁取り
                 1 => ["Candara",             # フォント名
                       false,                 # 太字
                       true,                  # 斜体
                       true,                  # 影文字
                       false,                 # 縁取り
                       Color.new(255,255,255),# 文字色
                       Color.new( 64, 32,128) # 縁取り色
                       ],
                 2 => ["微軟正黑體",             # フォント名
                       true,                 # 太字
                       false,                 # 斜体
                       true,                  # 影文字
                       false,                  # 縁取り
                       Color.new(255,255,255),# 文字色
                       #Color.new(-136, 0,17)
                       Color.new( 64, 32,128) # 縁取り色
                       ],
                 }
#
end
#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 文字ピクチャ指定
  #--------------------------------------------------------------------------
  def text_picture(text, p = 0, size = 20)
    strfp = STRRGSS2::STR27_FLIST[p]
    font = Font.new(strfp[0], size)
    font.bold = strfp[1] ; font.italic = strfp[2]
    font.shadow = strfp[3] ; font.color = strfp[5]
    text.gsub!(/A\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/[\t\n\r\f]*/,"")
    
    @strtxpic = [text, STR_DumpFont.new(font, strfp[4], strfp[6])]
  end
  #--------------------------------------------------------------------------
  # ● ピクチャの表示(エイリアス)
  #--------------------------------------------------------------------------
  alias command_231_str27 command_231
  def command_231
    @params[1] = @strtxpic if @strtxpic != nil ; @strtxpic = nil
    command_231_str27
  end
end
#==============================================================================
# ■ Sprite_Picture
#==============================================================================
class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # ● フレーム更新(エイリアス)
  #--------------------------------------------------------------------------
  alias update_str27 update
  def update
    if @picture.name.is_a?(Array) and @picture_name != @picture.name 
      # 文字ピクチャ
      @picture_name = @picture.name
      str27_update_2 if @picture_name != ""
    elsif @picture_name != @picture.name
      # 通常ピクチャ
      @picture_name = @picture.name
      if @picture_name != ""
        self.bitmap.dispose unless @picture_name.is_a?(String)
        self.bitmap = Cache.picture(@picture_name)
      end
    end
    # 呼び戻し
    update_str27
  end
  #--------------------------------------------------------------------------
  # ● 文字ピクチャ生成(追加)
  #--------------------------------------------------------------------------
  def str27_update_2
    self.bitmap.dispose if self.bitmap != nil and not @picture_name.is_a?(String)
    f = @picture_name[1].undump
    # 文字サイズ取得
    self.bitmap = Bitmap.new(1, 1) ; self.bitmap.font = f[0]
    size = self.bitmap.text_size(@picture_name[0])
    size.width += f[0].size / 4 if f[0].italic
    size.width += 4 ; self.bitmap.dispose
    # イメージ作成圖像做成
    self.bitmap = Bitmap.new(size.width + 2, size.height + 2)
    self.bitmap.font = f[0] ; self.bitmap.font.shadow = f[0].shadow
    ##############
    # X基準
      xx = (false ? 0 : 24)
      x = -10
      y = -3
      #####
      i = self.bitmap.text_size(@picture_name[0]).width
      i = i + 10
      ####
      # 範囲設定
      rect = []
      rect[0] = Rect.new( 0, 0,12,24)#(x,y,width,height)
      rect[1] = Rect.new(11, 0, 2,24)
      rect[2] = Rect.new(12, 0,12,24)
      #d_rect = Rect.new(x + xx + 12-11, y, i - xx-12, 24)#172 102
      d_rect = Rect.new(x + xx + 12-17, y, i - xx, 24)#172 102
      # 描画

      bitmap2 = Cache.system("Iconback")
      #bitmap = Cache.system("Iconback")
      #bitmap = Cache.system("Iconback_2") if !@actor.skill_can_use?(item)
      self.bitmap.blt(x + xx-17, y, bitmap2, rect[0])#
      self.bitmap.stretch_blt(d_rect, bitmap2, rect[1])#
      self.bitmap.blt(x + i +12-17, y, bitmap2, rect[2])#

    ##############
    unless f[1]
      self.bitmap.draw_text(1, 1, size.width, size.height, @picture_name[0])
    else
      self.bitmap.draw_text_f(1, 1, size.width, size.height, @picture_name[0], 0, f[2])
    end
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
   # str.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }###
    draw_text(x, y, width, height, str, align)
    font.shadow = shadow
  end
  def draw_text_f_rect(r, str, align = 0, color = Color.new(64,32,128)) 
    draw_text_f(r.x, r.y, r.width, r.height, str, align = 0, color) 
  end
end
#==============================================================================
# ■ STR_DumpFont
#==============================================================================
class STR_DumpFont
  #--------------------------------------------------------------------------
  # ● 初期化
  #--------------------------------------------------------------------------
  def initialize(font, edge, ed_color)
    @name = font.name ; @size = font.size
    @bold = font.bold ; @italic = font.italic
    @shadow = font.shadow ; @edge = edge ; @ed_color = ed_color.clone
    @color = Color.new(font.color.red,font.color.green,font.color.blue,font.color.alpha)
  end
  #--------------------------------------------------------------------------
  # ● 変換
  #--------------------------------------------------------------------------
  def undump
    font = Font.new(@name, @size)
    font.bold = @bold ; font.italic = @italic
    font.shadow = @shadow ; font.color = @color
    return [font, @edge, @ed_color]
  end
end