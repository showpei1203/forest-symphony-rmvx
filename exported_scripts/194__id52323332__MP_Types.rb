#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：MP Types
# 【用途】保留的 Runtime 元件「MP Types」。
# 【主要機制】主要定義／擴充 Window_Base；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_Base
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
#=========================== CONFIG HERE

MP_Types = [283, 285, 283, 284, 284, 273, 284, 283]
MP_Colour = [[11,31], [30,31], [20,21], [22,23], [22,23], [10,10], [22,23],
              [30,31]]
Dont_Have = [8]
#
=begin
MP_Types = [283, 285, 283, 284, 284, 273, 284, 283]
MP_Colour = [[30,31], [28,29], [30,31], [22,23], [22,23], [1,1], [22,23],
              [30,31]]
Dont_Have = [6]
=end
#



class Window_Base < Window
  
  # HP TOO ;)
  def draw_actor_hp(actor, x, y, width = 120)
    draw_actor_hp_gauge(actor, x, y, width)
    
    self.contents.font.size -= 3#self.contents.font.size -= 4
    self.contents.font.color = normal_color
    self.contents.draw_text(x+2, y+2, 30, WLH, "")
    self.contents.font.size += 3
    
    #self.contents.draw_icon(272, x, y)
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
# * Draw MP
#     actor : actor
#     x     : draw spot x-coordinate
#     y     : draw spot y-coordinate
#     width : Width
#--------------------------------------------------------------------------
def draw_actor_mp(actor, x, y, width = 120)
  have_or_not = 0
  work = 0
  while have_or_not == 0
    if actor.class.id == Dont_Have[work]  
      have_or_not = 1
      break
    else
      work += 1
      if work == Dont_Have.size
        break
      end
    end
  end
  if have_or_not == 1
    final_word = MP_Types[actor.class.id - 1]
    #self.contents.draw_icon(final_word, x, y)
    #self.contents.draw_text(x, y, 30, WLH, final_word)
  else
    draw_actor_mp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    final_word = MP_Types[actor.class.id - 1]    
    
    self.contents.font.size -= 4
    self.contents.font.color = normal_color
    case actor.class.id
    when 1, 2, 8
      self.contents.draw_text(x+2, y+2, 38, WLH, "")
    when 3
      self.contents.draw_text(x+2, y+2, 38, WLH, "")
    when 4..6, 7
      self.contents.draw_text(x+2, y+2, 38, WLH, "")
    end
    self.contents.font.size += 4
    
    #self.contents.draw_icon(final_word, x, y)
    #self.contents.draw_text(x, y, 30, WLH, final_word)
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
end
#~ #--------------------------------------------------------------------------
#~ # * Draw MP Gauge
#~ #     actor : actor
#~ #     x     : draw spot x-coordinate
#~ #     y     : draw spot y-coordinate
#~ #     width : Width
#~ #--------------------------------------------------------------------------
#def draw_actor_mp_gauge(actor, x, y, width = 120)
#  gw = width * actor.mp / [actor.maxmp, 1].max
#  gc1 = mp_gauge_color1(actor)
#  gc2 = mp_gauge_color2(actor)
#  self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
#  self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
#end
#--------------------------------------------------------------------------
# * Get MP Gauge Color 1
#--------------------------------------------------------------------------
def mp_gauge_color1(actor)
  return Color.new(0,0,150,205)
end
#def mp_gauge_color1(actor)
#return text_color(MP_Colour[actor.class.id - 1][0])
#end
#--------------------------------------------------------------------------
# * Get MP Gauge Color 2
#--------------------------------------------------------------------------
def mp_gauge_color2(actor)
  return Color.new(0,150,200,205)
end
#def mp_gauge_color2(actor)
#return text_color(MP_Colour[actor.class.id - 1][1])
#end
end
#######################
# CREDIT TO KAIMONKEY #
#######################