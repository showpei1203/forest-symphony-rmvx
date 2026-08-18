#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Fixed Font Formatter Algorithm
# 【用途】保留的 Runtime 元件「Fixed Font Formatter Algorithm」。
# 【主要機制】主要定義／擴充 Formatter_2、Paragrapher；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Formatter_2、Paragrapher
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
# ** Paragrapher::Formatter 2 (Using Zeriab's Algorithm)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This algorithm was written by Zeriab for fonts which have characters of 
# the same width. This is like Courier New, UMEGothic and fonts of that sort.
# This algorithm attaches a cost to each line based on the amount of white 
# space at the end of that line. It will display the way of writing the text
# with the lowest total cost. In prcatice, this will mean that it will, as 
# much as possible, reduce the spacing between letters in a line and make 
# the spacing more consistent for each line of the paragraph
#==============================================================================

module Paragrapher
  class Formatter_2
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Format
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def format (string, specifications)
      f = Formatted_Text.new
      f.lines, f.blank_width, word_lengths, words = [], [], [], []
      tracker = 0
      for i in 0...string.size
        if string[i,1] == " " || i == string.size - 1
          if i == string.size - 1
            i += 1
          end
          word_lengths.push (i - tracker)
          words.push (string[tracker, i - tracker])
          tracker = i + 1
        end
      end
      if specifications.class == Bitmap
        max_width = specifications.width
        f.bitmap = specifications
      elsif specifications.class == Fixnum || specifications.class == Float
        max_width = specifications
        f.bitmap = Bitmap.new (1,1)
      else
        # Error Catching: Bad specification
        bitmap = Bitmap.new (200, 64)
        f = format ('Specifications Error', bitmap)
        p 'Specifications Error: Please Pass Fixnum, Float or Bitmap'
        return f
      end
      tw = f.bitmap.text_size('a').width
      max_width = [max_width / tw, 180].min 
      # Error Catching: Word too long
      if word_lengths.max > max_width
        f = format ('Too long' , specifications)
        p 'One or more words is too long for specified width' 
        return f
      end
      position = line_break (word_lengths, max_width)
      lines = give_lines (position, position.size - 1, words)
      max_width *= tw
      for i in 0...lines.size 
        line = lines[i]
        f.lines.push (line.scan (/./))
        if i == lines.size - 1
          f.blank_width.push (0)
        else
          text_width = line.size * tw
          extra_space = max_width - text_width
          f.blank_width.push (extra_space.to_f / (line.size.to_f - 1.0))
        end
      end
      if f.bitmap != specifications
        f.bitmap = Bitmap.new (max_width, f.lines.size*32)
      end
      return f
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Line Break (written by Zeriab)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def line_break(word_lengths, max_length)
	    return false  if max_length > 180
	    word_lengths.unshift(nil)
	    extra_spaces = Table.new(word_lengths.size,word_lengths.size)
	    line_prices = Table.new(word_lengths.size,word_lengths.size)
	    word_price = []
	    position = []
	    inf = max_length*max_length + 1
	    for i in 1...word_lengths.size
	      extra_spaces[i,i] = max_length - word_lengths[i]
	      for j in (i+1)..[word_lengths.size-1, max_length/2+i+1].min
		      extra_spaces[i,j] = extra_spaces[i,j-1] - word_lengths[j]-1
	      end
	    end
	    for i in 1...word_lengths.size
	      for j in i..[word_lengths.size-1, max_length/2+i+1].min
		      if extra_spaces[i,j] < 0
		        line_prices[i,j] = inf
		      elsif j == word_lengths.size-1 and extra_spaces[i,j] >= 0
		        line_prices[i,j] = 0
		      else
		        line_prices[i,j] = extra_spaces[i,j]*extra_spaces[i,j]
		      end
        end
	    end
	    word_price[0] = 0
	    for j in 1...word_lengths.size
	      word_price[j] = inf
	      for ik in 1..j
	  	    i = j - ik + 1
	  	    break  if line_prices[i,j] == inf
	  	    if word_price[i-1] + line_prices[i,j] < word_price[j]
		        word_price[j] = word_price[i-1] + line_prices[i,j]
		        position[j] = i
		      end
	      end
	    end
	    return position
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Give_Lines (written by Zeriab)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def give_lines(position,last_index,words)
	    first_index = position[last_index]
	    word_array = []
	    if first_index != 1
	      word_array = give_lines(position, first_index - 1,words)
	    end
	    str = ""
	    for x in first_index..last_index
	      str += ' '  if x != first_index
	      str += words[x-1]
	    end
	    word_array << str
	    return word_array
    end
  end
end