#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：KGC_DrawFormatText
# 【用途】保留的 Runtime 元件「KGC_DrawFormatText」。
# 【主要機制】主要定義／擴充 Bitmap；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Bitmap
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】登記 $imported：DrawFormatText。
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
#_/    ◆ 書式指定文字描画 - KGC_DrawFormatText ◆ VX ◆
#_/    ◇ Last update : 2007/12/19 ◇
#_/----------------------------------------------------------------------------
#_/  書式指定文字描画機能を追加します。
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

$imported = {} if $imported == nil
$imported["DrawFormatText"] = true

class Bitmap
  @@__dummy_window = Window_Base.new(-64, -64, 64, 64)
  @@__dummy_window.visible = false
  #--------------------------------------------------------------------------
  # ● 書式指定文字描画
  #--------------------------------------------------------------------------
  def draw_format_text(x, y, width, height, text, align = 0)
    str = convert_special_characters(text)
    dx = 0
    buf = Bitmap.new(Graphics.width * 2, Window_Base::WLH)
    buf.font = self.font.clone
    loop {
      c = str.slice!(/./m)              # 次の文字を取得
      case c
      when nil                          # 描画すべき文字がない
        break
      when "\x01"                       # \C[n]  (文字色変更)
        str.sub!(/\[([0-9]+)\]/, "")
        buf.font.color = @@__dummy_window.text_color($1.to_i)
        next
      else                              # 普通の文字
        buf.draw_text(dx, 0, 40, Window_Base::WLH, c)
        c_width = buf.text_size(c).width
        dx += c_width
      end
    }
    self.font = buf.font.clone
    # バッファをウィンドウ内に転送
    dest = Rect.new(x, y, [width, dx].min, height)
    src = Rect.new(0, 0, dx, Window_Base::WLH)
    offset = width - dx
    case align
    when 1  # 中央揃え
      dest.x += offset / 2
    when 2  # 右揃え
      dest.x += offset
    end
    stretch_blt(dest, buf, src)
    buf.dispose
  end
  #--------------------------------------------------------------------------
  # ● 特殊文字の変換
  #--------------------------------------------------------------------------
  def convert_special_characters(str)
    text = str.dup
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    text.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    text.gsub!(/\\G/)              { $game_party.gold }
    text.gsub!(/\\\\/)             { "\\" }
    return text
  end
end
