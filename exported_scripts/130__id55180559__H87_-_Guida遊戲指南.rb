#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：H87 - 遊戲指南（Holy87 Guide v1.0）
# 【用途】提供分類式遊戲內指南。每個 Category 對應一組 Help/*.txt 頁面，Scene_Guide 可顯示分類清單、未讀標記、翻頁、圖片與圖示。
# 【原文】此腳本原始說明主要為義大利文；Phase 17 一併整理成繁中，程式碼與實際既有資料字串不改。
# 【資料格式】H87_Guide::Guide_Contents：key => [標題, Help Window 描述, PageFile1, PageFile2, ...]。PageFile 不含 .txt，Runtime 會讀取 Help/PageFile.txt。
# 【初始解鎖】InitialContents 列出新遊戲一開始可讀的 Category；目前含 "Movimento"。
# 【Script Call】show_guide：開啟指南主畫面；add_guide("nomecategoria")：解鎖分類；show_guide("nomecategoria")：直接開指定分類並自動解鎖。
# 【Help Text 標記】[S]=★、[B]=●、[C]=©、[L]=♥；[H] 放在行首可使用大字；[IMG]圖片名 會從 Graphics/Pictures 顯示圖片，該行只能放標記與圖片名；<icon id> 在行首顯示指定 Icon。
# 【顯示設定】Page_Sound=翻頁 SE；New_Guide=未讀標籤；Background=Graphics/Pictures 背景；Back_Opacity=背景透明度；FontSize/FontColor/FontName/FontShadow/FontBold/FontItalic/Spacing 與 BigFont* 控制一般／大字；Allign 0/1/2=左／中／右。
# 【相關素材】Help/*.txt、Graphics/Pictures/Online Back、Graphics/System/Iconset、Audio/SE/Book。刪除指南系統時這些才是可追蹤的專用資產候選，但必須先確認其他頁沒有共用。
# 【相容性】原作者標示幾乎全面相容；FS 另有 SafetyPatch 針對 H87 Guide，故不可只看本頁就搬動或退休。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
$imported = {} if $imported == nil
$imported["H87_Guide"] = true
#===============================================================================
# Versione 1.0
#===============================================================================
#===============================================================================
# <icon id>：在該行開頭顯示指定 ID 的圖示。
# 
# add_guide("nomecategoria")
# show_guide("nomecategoria")
##########################
# 
#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================
module H87_Guide
    
  Guide_Contents = {
  "Movimento"=>                 ["Movimento",             "Istruzioni sul movimento, configurazione dei comandi, menu,|interazione con altri oggetti.",
                                "Base1","Base2","Base3"],
  "Salvare il gioco"=>          ["Salvare il gioco",      "Cos'è un cristallo di salvataggio e come funziona?",
                                "Cry1"],
  "Combattimento (Base)"=>      ["Combattimento (Base)",  "Apprendi le basi del combattimento e le regole per giocare.",
                                "Combat1","Combat2","Combat3"],
  "Combattimento (Dettagli)"=>  ["Combattimento (Dettagli)","Informazioni sulle ricompense in battaglia, parametri e|modi per ripristinare le energie.",
                                "Combat4","Combat5","Combat6"],
  2 =>                          ["Combattimento (Esperto)","Informazioni sui ruoli dei personaggi, sull'IA nemica e sulla|gestione dell'Odio.",
                                "Combat9","Combat10","Combat7","Combat8"],
  "Equipaggiamento"=>           ["Equipaggiamento",       "Per sapere tutto su cosa possono indossare i tuoi eroi!",
                                "Equip1","Equip2","Equip3"],
  "Incontri"=>                  ["Incontri",              "Spiegazioni sugli incontri con i nemici su mappa.",
                                "Nemici"],
  "Mappa del mondo"=>           ["Mappa del mondo",       "Istruzioni su come ambientarsi nella mappa del mondo.",
                                "Map1"],
  "Sinergia"=>                  ["Sinergia",              "Scopri come sfruttare al massimo la Sinergia.",
                                "Sine1","Sine2","Sine3","Sine4","Sine5"],
  "Missioni"=>                  ["Missioni",              "Il poco che c'è da sapere sulle missioni secondarie.",
                                "Mission"],
  "Abilità"=>                   ["Abilità",               "Guida all'uso e all'apprendimento delle numerose abilità.",
                                "Skill1","Skill3","Skill2","Skill4"],
  1=>                           ["Stati alterati",         "Funzioni degli stati alterati in battaglia, elenco degli stati|positivi e negativi più comuni e delle modalità.",
                                "Status1","Status2","Status3","Status4"],
  3=>                           ["Elementi e attributi",  "Cose da sapere sui tipi di danni e difese.",
                                "Attr1","Attr2"],
  "Cambio gruppo"=>             ["Cambio gruppo",         "Impara a cambiare la tua formazione!",
                                "Formazione"],
  "Fabbro"=>                    ["Fabbro",                "Forgiatura, potenziamento e sintetizzazione del tuo equipaggiamento.",
                                "Blacksm","Blacksm2","Blacksm3"],
  "Sfera Dimensionale"=>        ["Sfera Dimensionale",    "Guida al funzionamento di questo strano oggetto. Vivere nella|comunità, rispetto negli altri.",
                                "Sphere1","Sphere2"],
  "Dominazioni"=>               ["Dominazioni",           "Alla scoperta delle evocazioni più forti!",
                                "Dominations1","Dominations2","Dominations3"],
  }
  
  InitialContents = ["Movimento"]
  
  Page_Sound = "Book"
  
  New_Guide = "NUOVO"
  
  Background = "Online Back"
  Back_Opacity = 200
  
  PageY = 20
  FontSize = 3+Font.default_size
  FontColor = Color.new(255,255,255)
  FontName = "微軟正黑體"
  FontShadow = false
  FontBold = false
  FontItalic = false
  Spacing = 24
  BigFontSize = Font.default_size + 15
  BigFontColor = Color.new(242,108,79)
  BigFontName = "微軟正黑體"
  BigFontShadow = false
  BigFontBold = false
  BigFontItalic = false
  SpacingB = 35
  Allign = 0
  
#===============================================================================
#===============================================================================



  
#===============================================================================
#===============================================================================

  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def self.get_text(content)
    textfile = content[1]
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def load_help(help_file)
    load_text("Help/",help_file)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def load_text(path,filename)
    filepath = path+filename+".txt"
    if File.exist? (filepath)
      array = []
      File.open(filepath,"r") do |f|
        f.each_line {|riga| array.push(riga.to_s)}
        @testo = array
      end
      return @testo
    else
      ex = Exception.new(sprintf("File guida %s non trovato",filename))
      raise(ex)
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def self.text_pages(index)
    content = Guide_Contents[index]
    array = []
    for i in 2..content.size-1
      array.push(content[i])
    end
    return array
  end
  
end
  

#===============================================================================
#===============================================================================
class Scene_Guide < Scene_Base
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def initialize(index = nil)
    @index = index
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def start
    super
    $game_party.add_content_guide(@index) if @index != nil
    create_background
    create_help_window
    create_list_window
    create_guide_window
    show_guide(@index) if @index != nil
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def create_background
    create_menu_background
    @background = Sprite.new
    @background.bitmap = Cache.picture(H87_Guide::Background)
    @background.opacity = H87_Guide::Back_Opacity
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.y = 0 - @help_window.height
    @helpY = 0 if @index == nil
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def create_list_window
    h = Graphics.height - @help_window.height
    @list_window = Window_GuideList.new(Graphics.width,@help_window)
    @list_window.y = Graphics.width
    @list_window.height = h
    if @index == nil
      @listY = @help_window.height
      @list_window.active = true
    else
      @list_window.active = false
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def create_guide_window
    @guide_book = Guide_Book.new
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update
    super
    decision if Input.trigger?(Input::C)
    left if Input.repeat?(Input::LEFT)
    right if Input.repeat?(Input::RIGHT)
    rett if Input.trigger?(Input::B)
    update_animations
    @list_window.update
    @guide_book.update
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def terminate
    super
    dispose_background
    dispose_help_window
    dispose_list_window
    dispose_guide_window
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def dispose_background
    dispose_menu_background
    @background.dispose
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def dispose_help_window
    @help_window.dispose
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def dispose_list_window
    @list_window.dispose
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def dispose_guide_window
    @guide_book.dispose
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def decision
    if @list_window.active
      Sound.play_decision
      show_guide(@list_window.category)
      Graphics.wait(10)
    else
      right
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def show_guide(index)
    @list_window.active = false
    @listY = Graphics.height
    @helpY = 0 - @help_window.height
    @guide_book.set_text(H87_Guide.text_pages(index))
    $game_party.add_readed(@list_window.category)
  end   
    
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def left
    return if @list_window.active
    if @guide_book.actual_page <= 1
      return_list
    else
      @guide_book.page_prev
      Sound.play_Page
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def right
    return if @list_window.active
    if @guide_book.actual_page == @guide_book.page_number
      return_list
    else
      @guide_book.page_next
      Sound.play_Page
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def rett
    if @list_window.active
      return_map
    else
      return_list
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def return_map
    Sound.play_cancel
    $scene = Scene_Map.new
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def return_list
    @list_window.refresh
    @guide_book.hide
    @list_window.active = true
    @helpY = 0
    @listY = @help_window.height
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update_animations
    div = 4
    distanza = @helpY - @help_window.y
    if distanza.abs < div
      @help_window.y = @helpY
    else
      @help_window.y += distanza/div
    end
    
    distanza = @listY - @list_window.y
    if distanza.abs < div
      @list_window.y = @listY
    else
      @list_window.y += distanza/div
    end    
  end
  
end

#===============================================================================
#===============================================================================
class Window_GuideList < Window_Command
  include H87_Guide
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def initialize(width,help)
    create_list
    @item_max = @contents.size
    @help_window = help
    super(width,@contents)
    setup
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def create_list
    @contents = []
    @cat_key = {}
    Guide_Contents.each_key do |category|
      if $game_party.guide_unlocked.include?(category)
        @contents.push(Guide_Contents[category][0].to_s) 
        @cat_key[Guide_Contents[category][0]] = category
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def setup
    refresh
    @index = 0
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(category == nil ? "" : help_text)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def help_text
    return Guide_Contents[category][1]
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item
    return @contents[self.index]
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def category(i = self.index)
    return @cat_key[@contents[i]]
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def draw_item(index)
    super(index, true)
    return if $game_party.guide_readed?(category(index))
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.font.color = crisis_color
    self.contents.draw_text(rect, H87_Guide::New_Guide,2)
  end
   
end

#===============================================================================
#===============================================================================
class Guide_Book
  include H87_Guide
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def initialize
    @width = Graphics.width
    @setup = false
    @active_page = 0
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def width
    return @width
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def show
    @showing = true
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def hide
    for i in 0..@pages.size-1
      @pages[i].opacity = 0
    end
    @page_sprite.opacity = 0
    @showing = false
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update
    return if @setup == false
    update_pages
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update_pages
    return unless @showing
    for i in 0..@pages.size-1
      move_page(@pages[i],i)
    end
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def move_page(page,index)
    if index == @active_page
      x = 0
      page.opacity += 20
    else
      page.opacity -= 30
      if index > @active_page
        x = @width
      else
        x = 0 - @width
      end
    end
    distanza = x - page.x
    page.x += distanza/4
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def page_number
    return @pages.size
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def actual_page
    return @active_page + 1
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def page_next
    return if actual_page >= page_number
    @active_page += 1
    @page_sprite.bitmap = create_page_bitmap
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def page_prev
    return if actual_page <= 1
    @active_page -= 1
    @page_sprite.bitmap = create_page_bitmap
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def dispose
    return unless @setup
    for i in 0..@pages.size-1
      @pages[i].dispose
    end
    @page_sprite.dispose
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def set_text(page_array)
    @active_page = 0
    @setup = true
    @showing = true
    clear_pages if @pages != nil
    @pages = []
    position = 0
    for i in 0..page_array.size-1
      @pages.push(new_page(page_array[i],position))
      position += @width
    end
    create_page_numbers
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def clear_pages
    @pages.each do |p|
      p.dispose
    end
  end

  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def new_page(page,position)
    text = load_help(page)
    bitmap = Bitmap.new(@width, Graphics.height)
    l = PageY
    for i in 0..text.size-1
      l = fetch_text(text[i],bitmap,l)
    end
    sprite = Sprite.new
    sprite.bitmap = bitmap
    sprite.x = position
    sprite.opacity = 0
    return sprite
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def fetch_text(text,bitmap, l)
    if image?(text)
      text.chomp!
      bitmap2 = Cache.picture(image_from_text(text))
      x = (@width - bitmap2.width)/2
      rect = Rect.new(0,0,bitmap2.width,bitmap2.height)
      bitmap.blt(x, l, bitmap2, rect)
      sp = bitmap2.height
    else
      x = 0
      iconid = check_icon(text)
      if iconid > 0
        text.gsub!(sprintf("<icon %d>",iconid),"")
        draw_icon(iconid,bitmap,l)
        x = 24
      end
      if big_text?(text.gsub(" ","").chomp)
        bitmap.font.size = BigFontSize
        bitmap.font.name = BigFontName
        bitmap.font.color = BigFontColor
        bitmap.font.shadow = BigFontShadow
        bitmap.font.italic = BigFontItalic
        bitmap.font.bold = BigFontBold
        sp = SpacingB
      else 
        bitmap.font.size = FontSize
        bitmap.font.name = FontName
        bitmap.font.color = FontColor
        bitmap.font.shadow = FontShadow
        bitmap.font.italic = FontItalic
        bitmap.font.bold = FontBold
        sp = Spacing
      end
      bitmap.draw_text(20+x,l,self.width-20-x,sp,formatted_text(text),Allign)
    end
    return l + sp
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def big_text?(text)
    return true if text[0..2] == "[H]"
    return false
  end
  
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def image?(text)
    return true if text[0..4].upcase == "[IMG]"
    return false
  end
  
  def check_icon(text)
    texti = /<(?:icon)[ ]*(\d+)>/i
    case text.gsub(/[\r\n]+/,"")
    when texti
      return $1.to_i
    end
    return 0
  end
  
  def draw_icon(iconid,bitmap,y)
    bitmap2 = Cache.system("Iconset")
    rect = Rect.new(iconid % 16 * 24, iconid / 16 * 24, 24, 24)
    bitmap.blt(20, y, bitmap2, rect)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def image_from_text(txt)
    return txt.gsub("[IMG]","")
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def formatted_text(text)
    text.gsub!("\n","") if text.gsub("\n","") != nil
    text.gsub!("[C]","©")
    text.gsub!("[L]","♥")
    text.gsub!("[S]","★")
    text.gsub!("[B]","●")
    text.gsub!("[H]","")
    return text
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def create_page_numbers
    @page_sprite = Sprite.new
    @page_sprite.bitmap = create_page_bitmap
    @page_sprite.y = Graphics.height - @page_sprite.height
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def create_page_bitmap
    w = 24
    bitmap = Bitmap.new(Graphics.width,w)
    bitmap.fill_rect(0,0,Graphics.width,w,Color.new(0,0,0,125))
    bitmap.draw_text(0,0,Graphics.width,w,sprintf("%2d/%2d",actual_page,page_number),1)
    return bitmap
  end
  
end

#===============================================================================
#===============================================================================
class Game_Party < Game_Unit
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def guide_unlocked
    @guide_unlocked = setup_initial_contents if @guide_unlocked == nil
    return @guide_unlocked
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def guide_readed?(guide_type)
    @guides_readed = [] if @guides_readed == nil
    return true if @guides_readed.include?(guide_type)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def add_readed(guide_type)
    @guides_readed = [] if @guides_readed == nil
    @guides_readed.push(guide_type) unless guide_readed?(guide_type)
  end  
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def setup_initial_contents
    @guide_unlocked = H87_Guide::InitialContents
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def add_content_guide(item)
    @guide_unlocked = setup_initial_contents if @guide_unlocked == nil
    @guide_unlocked.push(item) unless @guide_unlocked.include?(item)
  end
  
end

#===============================================================================
#===============================================================================
module Sound  
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def self.play_Page
    RPG::SE.new(H87_Guide::Page_Sound,100,100).play
  end
  
end

#===============================================================================
#===============================================================================
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def show_guide(index = nil)
    $scene = Scene_Guide.new(index)
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def add_guide(category)
    $game_party.add_content_guide(category)
  end
  
end
