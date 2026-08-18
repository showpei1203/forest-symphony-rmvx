#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Special Codes Formatter v1.0（Paragraph Formatter 2.0 Add-on）
# 【作者】modern algebra（rmrk.net），2009-09-15。
# 【用途】讓 Paragraph Formatter／Artist 支援 VX 常用替換碼、資料庫名稱／價格／圖示、字體樣式與對齊控制。主要類別為 Formatter_SpecialCodes、Artist_SpecialCodes。
# 【常用替換碼】\V[x]=變數；\N[x]=Actor 名稱；\C[x]=色盤顏色；\C[#HEX]=十六進位顏色；\=輸出反斜線；\PID[x]=隊伍位置 x 的 Actor ID；\NC[x]=職業名；\NP[x]=隊伍成員名；\NE[x]=地圖事件名；\NM[x]=敵人名；\NI[x]/\NW[x]/\NA[x]=道具／武器／防具名。
# 【數量／價格】\MIID[x]/\MWID[x]/\MAID[x]=持有數量；\PI[x]/\PW[x]/\PA[x]=道具／武器／防具價格。
# 【圖示】\IICON[x]、\WICON[x]、\AICON[x] 顯示資料庫物件圖示；\ICON[x] 顯示指定 Icon ID。使用 Graphics/System/Iconset。
# 【Vocab】\VOCAB[value] 讀取 Vocab；原文件列出的常用 value 包含 level、level_a、hp、hp_a、mp、mp_a、atk、def、spi、agi、weapon、armor1～4、attack、skill、guard、item、equip、status、save、game_end、fight、escape、new_game、shutdown、to_title、continue、cancel、gold。
# 【樣式】\B／\/B 粗體開關；\I／\/I 斜體；\U／\/U 底線；\S／\/S 陰影；\HL[x] 開啟 Highlight、\HL 關閉；\C 或 \CENTRE 置中；\RIGHT 靠右。
# 【Actor 方法】\A...[x] 可呼叫 Game_Actor 的公開方法，例如 hp、maxhp、mp、maxmp、atk、def、spi、agi、exp_s、level、weapon_id 等。這是強力入口，新增可呼叫方法前需考慮顯示安全性。
# 【Filter】Paragrapher::FILTERS 自訂 \F[key] 替換內容。現有範例：FILTERS['PF3'] 與 FILTERS[0]；不要刪除 FILTERS = {} 初始化。
# 【換行】單一 \n（原文件特別註明不是雙反斜線）代表段落換行；實際 Ruby 字串 escaping 依呼叫位置而異。
# 【載入順序】必須在 Paragraph Formatter 2.0 的 Formatter／Artist 基類之後。它不是 Message Window 本身，而是格式化器擴充。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#==============================================================================
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: September 15, 2009
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#      \\ - \
#
#
#    Formatter_SpecialCodes
#    Artist_SpecialCodes
#==============================================================================

module Paragrapher
  #============================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #============================================================================
  FILTERS = {}
  FILTERS['PF3'] = '\c[1]Paragraph Formatter\c[0], Version 2.0: Formatter_SpecialCodes'
  FILTERS[0] = 'Numbered filters work too'
  #============================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #============================================================================
  
  class Formatter_SpecialCodes < Formatter
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def format (string, specs)
      string = convert_special_characters (string)
      @code_argument = false
      @line_width = 0
      @word_width = 0
      @word_letter_count = 0
      @line_letter_count = 0
      # 執行原方法
      return super (string, specs)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def format_character (i)
      character = @string[i, 1]
      if args_codes.include? (character)
        extract_code (character)
        @code_argument = true
      elsif @code_argument 
        @code_argument = false if character == ">"
      elsif no_args_codes.include? (character) 
        extract_code (character)
      elsif character == " "
        char_width = @format_text.bitmap.text_size (character).width
        if @line_width + char_width + @word_width > @max_width
          if @line_width == 0 # 超長單字處理
            @last_word = i
            @line_width = @word_width
          end
          next_line (@last_word)
        else
          @line_width += char_width
          @line_letter_count += 1
        end
        @line_width += @word_width
        @line_letter_count += @word_letter_count
        @word_width = 0
        @word_letter_count = 0
        @last_word = i
      elsif character == "\n" # 換行
        char_width = @format_text.bitmap.text_size (" ").width
        next_line (@last_word) if @line_width + char_width + @word_width > @max_width
        @line_width += @word_width
        @line_letter_count += @word_letter_count
        next_line (i)
        @format_text.lines[-1].push (character)
        @format_text.blank_width[-1] = 0
        @word_width = 0
        @last_word = i
      else # 一般字元
        @word_width += @format_text.bitmap.text_size(character).width
        @word_letter_count += 1
        if i == @string.size - 1
          next_line (@last_word) if @line_width + @word_width > @max_width 
        end
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def next_line (last_word)
      line = @string[@line_break, last_word - @line_break]
      @format_text.lines.push ( line.scan (/./) )
      line_blank = @max_width - @line_width
      @format_text.blank_width.push (line_blank.to_f / (@line_letter_count.to_f) )
      @line_break = last_word + 1
      @line_width = 0
      @line_letter_count = 0
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def convert_special_characters (text = @string)
      return "" if text == nil
      text = perform_substitution (text) 
      # 取得替換文字
      text.gsub! (/\\C\[(\d+)\]/i)          { "\x01<#{$1.to_i}>" } # 調色盤顏色
      text.gsub! (/\\C\[#([\dABCDEF]+)\]/i) { "\x01<##{$1.to_s}>" } # 十六進位顏色   
      text.gsub! (/\\IIC?O?N?\[(\d+)\]/i) { $1.to_i > 0 ? "\x02<#{$data_items[$1.to_i].icon_index}>" : ""} # 道具圖示
      text.gsub! (/\\WIC?O?N?\[(\d+)\]/i) { $1.to_i > 0 ? "\x02<#{$data_weapons[$1.to_i].icon_index}>" : ""} # 武器圖示
      text.gsub! (/\\AIC?O?N?\[(\d+)\]/i) { $1.to_i > 0 ? "\x02<#{$data_armors[$1.to_i].icon_index}>" : ""} # 防具圖示
      text.gsub! (/\\IC?O?N?\[(\d+)\]/i)  { "\x02<#{$1.to_s}>" } # 圖示
      text.gsub! (/\\B/i) { "\x03" }                      # 開啟粗體
      text.gsub! (/\\I/i) { "\x04" }                      # 開啟斜體
      text.gsub! (/\\S/i) { "\x05" }                      # 開啟陰影
      text.gsub! (/\\U/i) { "\x06" }                      # 開啟底線
      text.gsub! (/\/B/i) { "\x07" }                      # 關閉粗體
      text.gsub! (/\/S/i) { "\x09" }                      # 關閉陰影
      text.gsub! (/\/I/i) { "\x08" }                      # 關閉斜體
      text.gsub! (/\/U/i) { "\x10" }                      # 關閉底線
      text.gsub! (/\\HL\[(-*\d+)\]/i) { "\x11<#{$1.to_s}>" }   # Highlight 高亮
      text.gsub! (/\\HL/i)          { "\x11<-1>" }   
      text.gsub! (/\\C/i)        { "\x12<1>" }          # 置中對齊
      text.gsub! (/\\CENTRE/i)   { "\x12<1>" }          # 置中對齊   
      text.gsub! (/\\RI?G?H?T?/i)   { "\x12<2>" }          # 靠右對齊
      return text
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def perform_substitution (text = @string)
      text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }   # 變數
      # FILTERS
      text.gsub!(/\\F\[["'](.+?)["']\]/i)  { FILTERS[$1.to_s] }
      text.gsub!(/\\F\[(.+?)\]/i)          { FILTERS[$1.to_i] }
      while text[/\\PID\[(\d+)\]/i] != nil
        x = $1.to_i < $game_party.members.size ? $game_party.members[$1.to_i].id : 0
        text.sub! (/\\PID\[(\d+)\]/i)  { x.to_s }
      end
      text.gsub!(/\\N\[([0-9]+)\]/i) { $1.to_i > 0 ? $game_actors[$1.to_i].name : ""} # Actor 名稱
      text.gsub!(/\\\\/)             { "\\" }
      begin
        text.gsub! (/\\VOCAB\[(\w+)\]/i) { Vocab.send ($1.downcase) } # Vocab
      rescue
      end
      text.gsub! (/\\AC\[(\d+)\]/i) { $game_actors[$1.to_i].class.name } # Actor 職業
      begin
        text.gsub! (/\\A([^\[]+?)\[(\d+)\]/i) { $game_actors[$2.to_i].send ($1.to_s.downcase) }
      rescue
      end
      text.gsub! (/\\NC\[(\d+)\]/i) { $1.to_i > 0 ? $data_classes[$1.to_i].name : "" } # 職業名稱
      text.gsub! (/\\NE\[(\d+)\]/i) { $1.to_i > 0 ? $game_map.events[$1.to_i].name : "" } # 事件名稱
      text.gsub! (/\\NM\[(\d+)\]/i) { $1.to_i > 0 ? $data_enemies[$1.to_i].name : "" } # 敵人名稱
      text.gsub! (/\\NI\[(\d+)\]/i) { $1.to_i > 0 ? $data_items[$1.to_i].name : "" }   # 道具名稱
      text.gsub! (/\\NW\[(\d+)\]/i) { $1.to_i > 0 ? $data_weapons[$1.to_i].name : "" } # 武器名稱
      text.gsub! (/\\NA\[(\d+)\]/i) { $1.to_i > 0 ? $data_armors[$1.to_i].name : "" } # 防具名稱
      text.gsub! (/\\PI\[(\d+)\]/i) { $1.to_i > 0 ? $data_items[$1.to_i].price.to_s : "" } # 道具價格
      text.gsub! (/\\PW\[(\d+)\]/i) { $1.to_i > 0 ? $data_weapons[$1.to_i].price.to_s : "" } # 武器價格
      text.gsub! (/\\PA\[(\d+)\]/i) { $1.to_i > 0 ? $data_armors[$1.to_i].price.to_s : "" } # 防具價格
      text.gsub! (/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }   # 變數
      text.gsub! (/\\MIID\[([0-9]+)\]/i) { $game_party.item_number($data_items[$1.to_i]) } 
      text.gsub! (/\\MWID\[([0-9]+)\]/i) { $game_party.item_number($data_weapons[$1.to_i]) } 
      text.gsub! (/\\MAID\[([0-9]+)\]/i) { $game_party.item_number($data_armors[$1.to_i]) } 
      return text
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def extract_code (code)
      case code
      when "\x02" 
        @word_letter_count += 1
        @word_width += 24
      when "\x03" then @format_text.bitmap.font.bold = true    # 粗體
      when "\x04" then @format_text.bitmap.font.italic = true  # 斜體
      when "\x05" then @format_text.bitmap.font.shadow = true  # 陰影
      when "\x07" then @format_text.bitmap.font.bold = false   # 粗體
      when "\x08" then @format_text.bitmap.font.italic = false # 斜體
      when "\x09" then @format_text.bitmap.font.shadow = false # 陰影
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def no_args_codes
      return ["\x03",  "\x04", "\x05", "\x06", "\x07",  "\x08", "\x09", "\x10"]
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def args_codes
      return ["\x01", "\x02", "\x11", "\x12"]
    end
  end
  
  #============================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #============================================================================
  
  class Artist_SpecialCodes
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def draw (f, justify_text = true)
      @f = f
      @justify_text = justify_text
      @highlight = -1
      @underline = false
      line_distance = @f.bitmap.height.to_f / @f.lines.size.to_f
      @line_distance = [@f.bitmap.font.size + 4, line_distance].min
      for i in 0...@f.lines.size
        @text = ""
        @f.lines[i].each { |char| @text += char }
        @blank_space = @f.blank_width[i] 
        @centre = @text[/\x12<1>/] != nil
        @right = @text[/\x12<2>/] != nil && !@centre
        total_blank = 0
        if @centre || @right
          @real_bitmap = @f.bitmap.dup
          @f.bitmap  = Bitmap.new (@real_bitmap.width, @line_distance)
          @f.bitmap.font = @real_bitmap.font.dup
          @y = 0
        else
          @y = i*@line_distance
        end
        @x = 0
        loop do 
          c = @text.slice!(/./m)
          break if c.nil?
          interpret_string (c)
        end
        if @centre || @right
          blank = (@real_bitmap.width - @x)
          blank /= 2 if @centre
          rect = Rect.new (0, 0, @real_bitmap.width, @line_distance)
          @real_bitmap.blt (blank, i*@line_distance, @f.bitmap, rect)
          @real_bitmap.font = @f.bitmap.font.dup
          @f.bitmap.dispose
          @f.bitmap = @real_bitmap
        end
      end
      return @f.bitmap
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def text_color(n)
      x = 64 + (n % 8) * 8
      y = 96 + (n / 8) * 8
      windowskin = Cache.system ("Window")
      return windowskin.get_pixel(x, y)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def draw_icon(icon_index, x, y)
      bitmap = Cache.system("Iconset")
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      @f.bitmap.blt(x, y, bitmap, rect)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def interpret_string (char)
      case char
      when "\x01" # 顏色
        @text.slice! (/<(#?[\dABCDEF]+)>/i)
        if $1.include? ("#")
          r, g, b = $1[1, 2].to_i (16), $1[3, 2].to_i (16), $1[5, 2].to_i (16)
          @f.bitmap.font.color = Color.new (r, g, b)
        else
          @f.bitmap.font.color = text_color ($1.to_i)
        end
      when "\x02" # 圖示
        @text.slice! (/<(\d+)>/)
        draw_icon ($1.to_i, @x, @y)
        @x += 24
        @x += @justify_text && !@centre && !@right ? @blank_space : 0
      when "\x03" then @f.bitmap.font.bold = true    # 開啟粗體
      when "\x04" then @f.bitmap.font.italic = true  # 開啟斜體
      when "\x05" then @f.bitmap.font.shadow = true  # 開啟陰影
      when "\x06" then @underline = true             # 開啟底線
      when "\x07" then @f.bitmap.font.bold = false   # 關閉粗體
      when "\x08" then @f.bitmap.font.italic = false # 關閉斜體
      when "\x09" then @f.bitmap.font.shadow = false # 關閉陰影
      when "\x10" then @underline = false           # 關閉底線
      when "\x11" # Highlight 高亮
        @text.slice! (/<(-?\d+)>/)
        @highlight = $1.to_i
      when "\x12" # 置中或靠右
        @text.slice! (/<\d>/)
      when "\n"   # 空白字元不繪製
      else
        draw_character (char)
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def draw_character (string)
      tw = @f.bitmap.text_size (string).width
      ls = @justify_text && !@centre && !@right ? @blank_space : 0
      hl_rect = Rect.new (@x, @y, tw + ls, @line_distance)
      if @highlight.between? (0, 31)
        colour = text_color (@highlight)
        colour.alpha = 120
        contents.fill_rect (hl_rect, colour)
      end
      if @underline
        y = @y + @line_distance - 2
        @f.bitmap.fill_rect (@x, y, hl_rect.width, 2, @f.bitmap.font.color)
      end
      @f.bitmap.draw_text (@x, @y, tw, @line_distance, string)
      @x += tw + ls
    end
  end
end