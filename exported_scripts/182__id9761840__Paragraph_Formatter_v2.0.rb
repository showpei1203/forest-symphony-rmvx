#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：Paragraph Formatter v2.0
# 【來源】modern algebra（rmrk.net），v2.0，2009-09-10。
# 【用途】把長字串依指定寬高自動斷行成段落，並可用 Artist 做左右對齊／Justify；提供 Bitmap facade，讓 UI 不必自己寫換行算法。
# 【最簡用法】`bitmap.draw_paragraph(x, y, width, height, string)`。例如 `contents.draw_paragraph(0,0,220,120,help_text)`。方法會建立暫存 Bitmap、套目前 Font、排版後 blt 回原 Bitmap。
# 【Formatter／Artist】可指定 `bitmap.paragraph_formatter = Paragrapher::FormatterClass`、`bitmap.paragraph_artist = Paragrapher::ArtistClass`；未指定時使用 `$game_system.default_formatter/default_artist`。
# 【核心資料】Paragrapher::Formatted_Text 保存 lines、blank_width、bitmap；Formatter 負責切行，Artist 負責繪製。也可直接 `Paragrapher.new(formatter,artist).paragraph(string,specification)`。
# 【依賴／清理】無固定 Graphics／Audio。屬共用文字排版 API；退休前必須搜尋 `draw_paragraph`、`paragraph_formatter`、`paragraph_artist`。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#  Version: 2.0
#  Author: modern algebra (rmrk.net)
#  Date: September 10, 2009
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#      bitmap.draw_paragraph (x, y, width, height, string)
#
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 變更摘要：
#==============================================================================

class Bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_writer :paragraph_formatter # 詳見頁首繁中說明
  attr_writer :paragraph_artist # 詳見頁首繁中說明
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def paragraph_formatter
    @paragraph_formatter = $game_system.default_formatter if @paragraph_formatter.nil?
    return @paragraph_formatter.new
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def paragraph_artist
    @paragraph_artist = $game_system.default_artist if @paragraph_artist.nil?
    return @paragraph_artist.new
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_paragraph (x, y, max_width, max_height, string)
    bitmap = Bitmap.new (max_width, max_height)
    bitmap.font = self.font.dup
    pg = Paragrapher.new (paragraph_formatter, paragraph_artist)
    bitmap = pg.paragraph (string, bitmap)
    blt (x, y, bitmap, bitmap.rect)
    bitmap.dispose
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

module Paragrapher
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #``````````````````````````````````````````````````````````````````````````
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  class << self
    def new(*args, &block)
      return Paragrapher.new(*args, &block)
    end
  end
  
  #==========================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #==========================================================================
  Formatted_Text = Struct.new (:lines, :blank_width, :bitmap)
  
  #==========================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #==========================================================================
  class Paragrapher < Struct.new (:formatter, :artist)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #    string：要自動換行的文字。
    #    specifications：Formatter 所需的其他參數。
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def paragraph(string, *specifications)
      f = formatter.format (string, *specifications)
      return artist.draw (f)
    end
  end
  
  #============================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #============================================================================
  
  class Formatter
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #    string         : the string to be formatted
    #    specifications：段落目標寬度，或既有 Bitmap。
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def format (string, specifications)
      @string = string
      if specifications.is_a? (Bitmap)
        bitmap = specifications
        @max_width = specifications.width
      elsif specifications.is_a? (Numeric)
        @max_width = specifications
        bitmap = Bitmap.new (@max_width, 32)
      else
        f = format ('Specifications Error', Bitmap.new (200, 64))
        p 'Specifications Error: Please Pass Numeric or Bitmap'
        return f
      end
      @format_text = Formatted_Text.new ([], [], bitmap)
      @line_break = 0
      @last_word = 0
      for i in 0...@string.size
        format_character (i)
      end
      @format_text.lines.push ( @string[@line_break, @string.size - @line_break].scan (/./) )
      @format_text.blank_width.push (0)
      height = @format_text.lines.size*Window_Base::WLH
      @format_text.bitmap = Bitmap.new (@max_width, height) if specifications.is_a? (Numeric)
      formatted_text = @format_text.dup
      @format_text = nil
      return formatted_text
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #    i : index of position in the string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def format_character (i)
      character = @string[i, 1]
      if character == "\n" || character == " " || i == @string.size - 1
        i += 1 if i == @string.size - 1 # 詳見頁首繁中說明
        substring = @string[@line_break, i - @line_break]
        if @format_text.bitmap.text_size (substring).width > @max_width
          next_line (@last_word)
        end
        if character == "\n"
          next_line (i)
          @format_text.blank_width[-1] = 0
        end
        @last_word = i
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #    last_word：前一個單字開頭的索引。
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def next_line (last_word)
      line = @string[@line_break, last_word - @line_break]
      @format_text.lines.push ( line.scan (/./) )
      line_blank = @max_width - @format_text.bitmap.text_size(line).width
      @format_text.blank_width.push (line_blank.to_f / (line.size.to_f - 1.0) )
      @line_break = last_word + 1
    end
  end
 
  #============================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #============================================================================
  
  class Artist
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #    f            : Formatted Text Object
    #    justify_text：是否啟用左右對齊的布林值。
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def draw (f, justify_text = true)
      line_distance = f.bitmap.height.to_f / f.lines.size.to_f
      line_distance = [f.bitmap.font.size + 4, line_distance].min
      for i in 0...f.lines.size
        blank_space = f.blank_width[i]
        position = 0
        for j in 0...f.lines[i].size
          string = f.lines[i][j]
          tw = f.bitmap.text_size (string).width
          f.bitmap.draw_text (position, line_distance*i, tw, line_distance, string)
          position += tw
          position += blank_space if justify_text
        end
      end
      return f.bitmap
    end
  end
end

#========================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#========================================================================

class Game_System
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :default_formatter
  attr_accessor :default_artist
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_paragraph_formatter_init initialize
  def initialize
    ma_paragraph_formatter_init
    @default_formatter = Paragrapher::Formatter
    @default_artist = Paragrapher::Artist
  end
end