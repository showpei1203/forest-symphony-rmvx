#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Neo Database Text
# 【用途】保留的 Runtime 元件「Neo Database Text」。
# 【主要機制】主要定義／擴充 Bitmap；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Bitmap
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
# ** [ERZVX] Enhanced Bitmap#draw_text (by ERZENGEL at 27-April-2008 at 19:53)
#------------------------------------------------------------------------------
#  Bitmap#draw_text is able to convert control characters.
#==============================================================================
=begin
###############################################################################

Default control characters:

\V[n]    Replaced by the value of variable n (n = ID of a variable).
\N[n]    Replaced by the name of actor n (n = ID of an actor).
\C[n]    Change the color of the following text(n = 0 til 31).
\G       Replaced by the current gold amount.
\\       Replaced by the '\' character.

Control characters from woratanas NMS (v2.52):

\MAP      Replaced by the current map name.
\NC[n]    Replaced by the class of actor n (n = ID of an actor).
\NP[n]    Replaced by the name of actor n in the party (n = integer between 1 and 4).
\NM[n]    Replaced by the name of enemy n (n = ID of an enemy).
\NT[n]    Replaced by the name of troop n (n = ID of a troop).
\NI[n]    Replaced by the name of item n (n = ID of an item).
\NW[n]    Replaced by the name of weapon n (n = ID of a weapon).
\NA[n]    Replaced by the name of armor n (n = ID of an armor).
\NS[n]    Replaced by the name of skill n (n = ID of a skill).
\PRICE[n] Replaced by the price of the item n (n = ID of an item).
\IC[n]    Replaced by the icon with the index n (n = Index of icon in the Iconset).
\DW[n]    Replaced by the icon and name of weapon n (n = ID of a weapon).
\DI[n]    Replaced by the icon and name of item n (n = ID of an item).
\DA[n]    Replaced by the icon and name of armor n (n = ID of an armor).
\DS[n]    Replaced by the icon and name of skill n (n = ID of a skill).
\FN[str]  Following text is in font str (str = name of a font).
\FS[n]    Following text is in fontsize n (n = integer. Standard is 20).
\IA       1號物品數量

Other control characters:

\BO       Following text is or isn't bold.
\IT       Following text is or isn't italic.
\SH       Folling text is or isn't shadowed.
\AL[n]    Align text (n = integer between 0 and 2 (0 = left, 1 = center, 2 = right)).

###############################################################################
=end
#==============================================================================
# ** Bitmap
#==============================================================================
class Bitmap
  #--------------------------------------------------------------------------
  # * Draw text
  #--------------------------------------------------------------------------
  alias :erzvx_draw_text :draw_text unless $@
  def draw_text(*args)
    # Falls erstes Argument ein Rectobjekt ist
    if args[0].is_a?(Rect)
      if args.size > 3 then raise(ArgumentError) end
      x, y, width, height = args[0].x, args[0].y, args[0].width, args[0].height
      str = args[1]
      align = args[2]
    else
      if args.size > 6 then raise(ArgumentError) end
      x, y, width, height, str, align = args[0..5]
    end
    # Links ausrichten, falls Wert von align nil oder größer als 2 ist
    align = 0 if align.nil? || align > 2
    # Standardeigenschaften in Variablen speichern
    name, size,   color  = self.font.name, self.font.size,   self.font.color
    bold, italic, shadow = self.font.bold, self.font.italic, self.font.shadow
    # Temporäre Variablen erstellen
    tstr = (str.is_a?(String) ? str : str.to_s) + "\n";  tc = '';  tx = 0
    begin
      lasttstr = tstr.clone
      tstr = convert_special_characters(tstr)
    end until tstr == lasttstr
    while (!(c = tstr.slice!(/./m)).nil?)
      case c
      when "\x01"  # \C[n]
        tstr.sub!(/\[([0-9]+)\]/, "")
        tcolor = $1.to_i
        self.font.color = text_color(tcolor) if tcolor >= 0 && tcolor <= 31
      when "\x02"  # \C[n]
        tstr.sub!(/\[([0-2]+)\]/, "")
        align = $1.to_i        
      when "\x83"  # \IC[n]
        tstr.sub!(/\[([0-9]+)\]/, "")
        icon_index = $1.to_i
        draw_icon(icon_index, x, y)
        tx += 24
      when "\x84"  # \FN[*]
        tstr.sub!(/\[(.*?)\]/, "")
        self.font.name = $1.to_s
      when "\x85"  # \FS[n]
        tstr.sub!(/\[([0-9]+)\]/, "")
        self.font.size = $1.to_i
      when "\x88"  # \BO
        self.font.bold = !self.font.bold
      when "\x89"  # \IT
        self.font.italic = !self.font.italic
      when "\x93"  # \SH
        self.font.shadow = !self.font.shadow
      when "\n"    # Neue Zeile
        if align == 1     # Zentriert
          tx = width - tx
          tx = tx / 2
          erzvx_draw_text((x + tx), y, (width - tx), height, tc)
        elsif align == 2  # Rechts
          tx = width - tx
          erzvx_draw_text((x + tx), y, (width - tx), height, tc)
        end
        # Temporäre Variablen zurücksetzen
        tc = tstr = '';  tx = 0
      else         # Normal text character
        # Ausrichtungsabfrage (Links)
        if align == 0
          erzvx_draw_text((x + tx), y, width, height, c, align)
          tx += text_size(c).width
        else
          tc += c
          tx += text_size(c).width
        end
      end
    end
    # Standardeigenschaften wiederherstellen
    self.font.name, self.font.size,   self.font.color  = name, size,   color
    self.font.bold, self.font.italic, self.font.shadow = bold, italic, shadow
  end
  #--------------------------------------------------------------------------
  # * Convert Special Characters
  #--------------------------------------------------------------------------
  def convert_special_characters(str)
    # Mit Wert einer Variable ersetzen
    str.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    # Mit Namen eines Heldens ersetzen
    str.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    # Nachfolgenden Text in anderer Farbe anzeigen
    str.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    # Mit dem aktuellen Goldbetrag ersetzen
    str.gsub!(/\\G/) { $game_party.gold.to_s }
    # Mit dem aktuellen Goldbetrag ersetzen###
    str.gsub!(/\\IA1/) { $game_party.item_number($data_items[1]) }###
    # Backslash anzeigen
    str.gsub!(/\\\\/) { "\\" }
    # Ausrichtung ändern
    str.gsub!(/\\AL\[([0-2]+)\]/i) { "\x02[#{$1}]" }
    # Woratana's :: Map Name
    str.gsub!(/\\MAP/i) { get_map_name }
    # Woratana's :: Actor Class Name
    str.gsub!(/\\NC\[([0-9]+)\]/i) {
      $data_classes[$data_actors[$1.to_i].class_id].name }
    # Woratana's :: Party Actor Name
    str.gsub!(/\\NP\[([0-9]+)\]/i) { $game_party.members[($1.to_i - 1)].name }
    # Woratana's :: Monster Name
    str.gsub!(/\\NM\[([0-9]+)\]/i) { $data_enemies[$1.to_i].name }
    # Woratana's :: Troop Name
    str.gsub!(/\\NT\[([0-9]+)\]/i) { $data_troops[$1.to_i].name }
    # Woratana's :: Item Name
    str.gsub!(/\\NI\[([0-9]+)\]/i) { $data_items[$1.to_i].name }
    # Woratana's :: Weapon Name
    str.gsub!(/\\NW\[([0-9]+)\]/i) { $data_weapons[$1.to_i].name }
    # Woratana's :: Armor Name
    str.gsub!(/\\NA\[([0-9]+)\]/i) { $data_armors[$1.to_i].name }
    # Woratana's :: Skill Name
    str.gsub!(/\\NS\[([0-9]+)\]/i) { $data_skills[$1.to_i].name }
    # Woratana's :: Item Price
    str.gsub!(/\\PRICE\[([0-9]+)\]/i) { $data_items[$1.to_i].price.to_s }
    # Woratana's :: Draw Icon
    str.gsub!(/\\IC\[([0-9]+)\]/i) { "\x83[#{$1}]" }
    # Woratana's :: Draw Weapon Name + Icon
    str.gsub!(/\\DW\[([0-9]+)\]/i) {
      "\x83[#{$data_weapons[$1.to_i].icon_index}]\\NW[#{$1.to_i}]" }
    # Woratana's :: Draw Item Name + Icon
    str.gsub!(/\\DI\[([0-9]+)\]/i) {
      "\x83[#{$data_items[$1.to_i].icon_index}]\\NI[#{$1.to_i}]" }
    # Woratana's :: Draw Armor Name + Icon
    str.gsub!(/\\DA\[([0-9]+)\]/i) {
      "\x83[#{$data_armors[$1.to_i].icon_index}]\\NA[#{$1.to_i}]" }
    # Woratana's :: Draw Skill Name + Icon
    str.gsub!(/\\DS\[([0-9]+)\]/i) {
      "\x83[#{$data_skills[$1.to_i].icon_index}]\\ns[#{$1.to_i}]" }
    # Woratana's :: Font Name Change
    str.gsub!(/\\FN\[(.*?)\]/i) { "\x84[#{$1}]" }
    # Woratana's :: Font Size Change
    str.gsub!(/\\FS\[([0-9]+)\]/i) { "\x85[#{$1}]" }
    # Woratana's :: BOLD Text
    str.gsub!(/\\BO/i) { "\x88" }
    # Woratana's :: ITALIC Text
    str.gsub!(/\\IT/i) { "\x89" }
    # Woratana's :: SHADOW Text
    str.gsub!(/\\SH/i) { "\x93" }
    return str
  end
  #--------------------------------------------------------------------------
  # * Get Text Color
  #--------------------------------------------------------------------------
  def text_color(n)
    x = 64 + (n % 8) * 8
    y = 96 + (n / 8) * 8
    windowskin = Cache.system('Window')
    return windowskin.get_pixel(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get Map Name
  #--------------------------------------------------------------------------
  def get_map_name
    $data_mapinfos = load_data('Data/MapInfos.rvdata') if $data_mapinfos.nil?
    map_id = $game_map.map_id
    return $data_mapinfos[map_id].name
  end
  #--------------------------------------------------------------------------
  # * Draw Icon
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y)
    bitmap = Cache.system('Iconset')
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.blt(x, y, bitmap, rect)
  end
end