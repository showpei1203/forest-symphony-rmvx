#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Neo Save System v5.0-FS1.1
# 【來源】Woratana／Thaiware RPG Maker Community；Neo Save System V（v3→v5），Helladen 延續支援；Screenshot 原始 Credits 包含 Woratana、Andreas21、Cybersam。
# 【FS 修正】v5.0-FS1.1 將預覽讀檔統一使用 rb 二進位模式，並禁止 dispose Cache.picture 回傳的共用背景 Bitmap，避免快取資源被 Save Scene 錯誤釋放。
# 【用途】取代／擴充 Scene_File，提供多存檔槽、存檔預覽、地圖截圖、角色臉圖／等級／名稱、金錢、遊戲時間、地點、覆寫確認與自訂存檔路徑。
# 【目前核心設定】MAX_SAVE_SLOT=10；SLOT_NAME='存檔 {id}'；SAVE_FILE_NAME='Save {id}.rvdata'；SAVE_PATH='Saves/'；SAVED_SLOT_ICON=133；EMPTY_SLOT_ICON=141；EMPTY_SLOT_TEXT='沒有存檔'。
# 【背景／截圖】NSS_IMAGE_BG='save'、NSS_IMAGE_BG_OPACITY=255，素材為 Graphics/Pictures/save；SCREENSHOT_IMAGE=true，暫存／預覽圖片副檔名 IMAGE_FILETYPE='.png'。若 SCREENSHOT_IMAGE=false 則改走地圖繪製路徑，並涉及 Swap Tile 相容。
# 【Scene 行為】SCENE_CHANGE=true 時成功存檔後回到地圖。OPACITY_DEFAULT／NSS_WINDOW_OPACITY 控制視窗透明度；背景圖片模式通常搭配較低 window opacity。
# 【顯示欄位】DRAW_GOLD／DRAW_PLAYTIME／DRAW_LOCATION／DRAW_FACE／DRAW_LEVEL／DRAW_NAME 決定預覽內容；DRAW_TEXT_GOLD 決定是否額外顯示 Vocab::Gold。
# 【地圖名稱隱藏】MAP_NAME_TEXT_SUB 可移除地圖名稱中的標記；MAP_NO_NAME_LIST=[2]，且 Switch 30 開啟時，清單內地圖顯示 MAP_NO_NAME='???'。這會讀取存檔中的 map_id，修改時請測舊存檔。
# 【確認視窗】SFC_Text_Confirm／SFC_Text_Cancel、SFC_Window_Width、X/Y Offset 控制覆寫存檔確認 UI。
# 【檔案／資料夾】Runtime 會建立 SAVE_PATH，Save 圖片亦寫在此目錄。不要把 Saves/ 或 Save *.rvdata／預覽 PNG 當成可隨素材精簡刪除的靜態資源。
# 【呼叫方式】由 Scene_Save／Scene_Load／Scene_File 與標題／地圖流程自動使用；沒有建議的事件 Script Call。修改檔名、路徑、slot 數時必須實測新存、覆寫、讀檔、刪除／空槽與舊存檔相容。
# 【載入順序】本頁重開 Scene_File、Scene_Title、Scene_Map 等核心類別；後方 FS SaveCompatibility／Validation 仍依賴現行 Save 介面，不能單純換成另一套 Save System。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
#==========================================================================

#    Forest Symphony 修正版 v5.0-FS1.1
#    - 預覽讀檔統一使用 rb 二進位模式
#    - 不再 dispose Cache.picture 共用背景 Bitmap

#---------------------------------------------------------------------------

# ◦ Author: Woratana [woratana@hotmail.com]


# ◦ Last Updated:

# ◦ Version: 3.0 -> 5.0

# ◦ Continued support by Helladen 


#---------------------------------------------------------------------------





#---------------------------------------------------------------------------








#---------------------------------------------------------------------------




#---------------------------------------------------------------------------





#---------------------------------------------------------------------------













#===========================================================================



module Wora_NSS Wora_NSS

  #==========================================================================


  #--------------------------------------------------------------------------

  OPACITY_DEFAULT = false


  NSS_WINDOW_OPACITY = 0


  NSS_IMAGE_BG = 'save'


  NSS_IMAGE_BG_OPACITY = 255

  


  SWAP_TILE = false

  SWAP_TILE_SWITCH = 29


  


  SCREENSHOT_IMAGE = true



  

  IMAGE_FILETYPE = '.png'


  


  SCENE_CHANGE = true



  MAX_SAVE_SLOT = 10

  SLOT_NAME = '存檔 {id}'


  SAVE_FILE_NAME = 'Save {id}.rvdata'


  


  SAVE_PATH = 'Saves/'

  SAVED_SLOT_ICON = 133

  

  EMPTY_SLOT_ICON = 141

  EMPTY_SLOT_TEXT = '沒有存檔'

  

  DRAW_GOLD = true # 顯示金錢

  DRAW_PLAYTIME = true # 顯示遊戲時間

  DRAW_LOCATION = true # 顯示地點

  DRAW_FACE = true # 顯示 Actor 臉圖

  DRAW_LEVEL = true # 顯示 Actor 等級

  DRAW_NAME = true # 顯示 Actor 名稱

  DRAW_TEXT_GOLD = false

  

  PLAYTIME_TEXT = '遊戲時間: '

  GOLD_TEXT = '　　: '

  LOCATION_TEXT = '地點: '

  LV_TEXT = '等級 '

  

  MAP_NAME_TEXT_SUB = %w{}



  MAP_NO_NAME_LIST = [2]

  MAP_NO_NAME = '???'





  MAP_NO_NAME_SWITCH = 30

  

  MAP_BORDER = Color.new(0, 0, 0, 200)

  FACE_BORDER = Color.new(0, 0, 0, 200)

  


  SFC_Text_Confirm = '確定要存檔嗎'

  SFC_Text_Cancel = '取消'

  SFC_Window_Width = 200

  SFC_Window_X_Offset = 0

  SFC_Window_Y_Offset = 0

  

  #-------------------------------------------------------------------------


  #=========================================================================

  

  #-------------------------------------------------------------


  #-------------------------------------------------------------

  @screen = Win32API.new 'screenshot', 'Screenshot', %w(l l l l p l l), ''

  @readini = Win32API.new 'kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l'

  @findwindow = Win32API.new 'user32', 'FindWindowA', %w(p p), 'l' 

  module_function

  def self.shot(file_name)

    case IMAGE_FILETYPE

    when '.bmp'; typid = 0

    when '.jpg'; typid = 1

    when '.png'; typid = 2

    end


    filename = file_name + IMAGE_FILETYPE

    @screen.call(0, 0, Graphics.width, Graphics.height, filename, self.handel,

    typid)

  end

  def self.handel

    game_name = "\0" * 256

    @readini.call('Game','Title','',game_name,255,".\\Game.ini")

    game_name.delete!("\0")

    return @findwindow.call('RGSS Player',game_name)

  end

  

end



class Scene_File < Scene_Base

  include Wora_NSS

  attr_reader :window_slotdetail

  #-------------------------------------------------------------------------


  #-------------------------------------------------------------------------

  def start

    super

    create_menu_background

    if NSS_IMAGE_BG != ''

      @bg = Sprite.new

      @bg.bitmap = Cache.picture(NSS_IMAGE_BG)

      @bg.opacity = NSS_IMAGE_BG_OPACITY

    end

    @help_window = Window_Help.new

    @help_window.y = 5

    command = []

    (1..MAX_SAVE_SLOT).each do |i|

      command << SLOT_NAME.clone.gsub!(/\{ID\}/i) { i.to_s }

    end

    @window_slotdetail = Window_NSS_SlotDetail.new

    @window_slotlist = Window_SlotList.new(160, command)

    @window_slotlist.y = @help_window.height

    @window_slotlist.height = Graphics.height - @help_window.height

    if OPACITY_DEFAULT == false

    @help_window.opacity = NSS_WINDOW_OPACITY

    @window_slotdetail.opacity = @window_slotlist.opacity = NSS_WINDOW_OPACITY

    end



  # 建立存檔資料夾

  if SAVE_PATH != ''

    Dir.mkdir(SAVE_PATH) if !FileTest.directory?(SAVE_PATH)

  end

    if @saving

      @index = $game_temp.last_file_index

      @help_window.set_text(Vocab::SaveMessage)

    else

      @index = self.latest_file_index

      @help_window.set_text(Vocab::LoadMessage)

      (1..MAX_SAVE_SLOT).each do |i|

        @window_slotlist.draw_item(i-1, false) if !@window_slotdetail.file_exist?(i)

     end

    end

    @window_slotlist.index = @index


    @last_slot_index = @window_slotlist.index

    @window_slotdetail.draw_data(@last_slot_index + 1)

    ###############################

    @as_flame = 0

    @as = Sprite.new

    @as.x = 110

    @light = Sprite.new

		@light.bitmap = Cache.picture("le.png")

		@light.visible = true

    @light.x = 407

    @light.y = -20

    @light.zoom_x = 200 / 100.0

    @light.zoom_y = 200 / 100.0

    @light.opacity = 100

    @light.tone = Tone.new(255,-100,-255, 0)

    @light.blend_type = 1

		@light.z = 1000

    fireflies(5)

    ###############################

  end

  #--------------------------------------------------------------------------  


  #--------------------------------------------------------------------------

  def terminate

    super

    dispose_menu_background

    unless @bg.nil?

      # Cache.picture 回傳的是共用快取 Bitmap。
      # Scene 只釋放 Sprite，不得 dispose 共用 Bitmap。
      @bg.bitmap = nil

      @bg.dispose unless @bg.disposed?

    end

    @window_slotlist.dispose

    @window_slotdetail.dispose

    @help_window.dispose

    @as.dispose

    @light.dispose

    fireflies(0)

  end

  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def update

    super

    ################

    @light.opacity = rand(20) + 90

    @light.x = 407 + rand(3) - 3

    @light.y = -20 + rand(3) - 3

    ###############

    if !@confirm_window.nil?

      @confirm_window.update

      if Input.trigger?(Input::C)

        if @confirm_window.index == 0

          determine_savefile

          @confirm_window.dispose

          @confirm_window = nil

        else

          Sound.play_cancel

          @confirm_window.dispose

          @confirm_window = nil

        end

      elsif Input.trigger?(Input::B)

      Sound.play_cancel

      @confirm_window.dispose

      @confirm_window = nil

      end

    else

      update_menu_background

      @window_slotlist.update

      if @window_slotlist.index != @last_slot_index

        @last_slot_index = @window_slotlist.index

        @window_slotdetail.draw_data(@last_slot_index + 1)

      end

      @help_window.update

      update_savefile_selection

    end

  end

  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def update_savefile_selection

    ############################################

    @as_flame = 0 if Input.trigger?(Input::UP)

    @as_flame = 0 if Input.trigger?(Input::DOWN)

    @as.bitmap = Cache.character("$actor01#") if $scene.window_slotdetail.file_exist?(@last_slot_index+1)

    @as.bitmap = Cache.character("$actor01_5") if !$scene.window_slotdetail.file_exist?(@last_slot_index+1)

    @as.z = 9999

    @as.y = 63 if @last_slot_index == 0#+24

    @as.y = 87 if @last_slot_index == 1

    @as.y = 111 if @last_slot_index == 2

    @as.y = 135 if @last_slot_index == 3

    @as.y = 159 if @last_slot_index == 4

    @as.y = 183 if @last_slot_index == 5

    @as.y = 207 if @last_slot_index == 6

    @as.y = 231 if @last_slot_index == 7

    @as.y = 255 if @last_slot_index == 8

    @as.y = 279 if @last_slot_index == 9

    @as.y = 303 if @last_slot_index == 10

    if @as_flame <= 60

       @as_flame = 0 if @as_flame == 60





       @as.src_rect.set(0,  0, 32, 32) if @as_flame == 45

       @as.src_rect.set(32,  0, 32, 32) if @as_flame == 30

       @as.src_rect.set(64,  0, 32, 32) if @as_flame == 15

       @as.src_rect.set(32,  0, 32, 32) if @as_flame == 0

      @as_flame += 1

    end    #####

    #############################################

    if Input.trigger?(Input::C)

      if @saving and @window_slotdetail.file_exist?(@last_slot_index + 1)

        Sound.play_decision

        text1 = SFC_Text_Confirm

        text2 = SFC_Text_Cancel

        @confirm_window = Window_Command.new(SFC_Window_Width,[text1,text2])

        @confirm_window.x = ((544 - @confirm_window.width) / 2) + SFC_Window_X_Offset

        @confirm_window.y = ((416 - @confirm_window.height) / 2) + SFC_Window_Y_Offset

      else

        determine_savefile

      end

    elsif Input.trigger?(Input::B)

      Sound.play_cancel

      return_scene

    end

  end

  

  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def do_save

    if SCREENSHOT_IMAGE

    File.rename(SAVE_PATH + 'temp' + IMAGE_FILETYPE,

    make_filename(@last_slot_index).gsub(/\..*$/){ '_ss' } + IMAGE_FILETYPE)  

    end  

    file = File.open(make_filename(@last_slot_index), "wb")

    write_save_data(file)

    file.close   

    if SCENE_CHANGE

    $scene = Scene_Map.new

    else

    $scene = Scene_File.new(true, false, false)

    end

  end

  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def do_load

    file = File.open(make_filename(@last_slot_index), "rb")

    read_save_data(file)

    file.close

    $scene = Scene_Map.new

    RPG::BGM.fade(1500)

    Graphics.fadeout(60)

    Graphics.wait(40)

    @last_bgm.play

    @last_bgs.play

  end

  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def determine_savefile

    if @saving

      Sound.play_save

      do_save

    else

      if @window_slotdetail.file_exist?(@last_slot_index + 1)

        Sound.play_load

        do_load

      else

        Sound.play_buzzer

        return

      end

    end

    $game_temp.last_file_index = @last_slot_index

  end

  #--------------------------------------------------------------------------


  # file_index：存檔索引（save file index (0-3)）

  #--------------------------------------------------------------------------

  def make_filename(file_index)

    return SAVE_PATH + SAVE_FILE_NAME.gsub(/\{ID\}/i) { (file_index + 1).to_s }

  end

  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def latest_file_index

    latest_index = 0

    latest_time = Time.at(0)

    (1..MAX_SAVE_SLOT).each do |i|

      file_name = make_filename(i - 1)

      next if !@window_slotdetail.file_exist?(i)

      file_time = File.mtime(file_name)

      if file_time > latest_time

        latest_time = file_time

        latest_index = i - 1

      end

    end

    return latest_index

  end



class Window_SlotList < Window_Command

  #--------------------------------------------------------------------------


  #--------------------------------------------------------------------------

  def draw_item(index, enabled = true)

    rect = item_rect(index)

    rect.x += 4

    rect.width -= 8

    icon_index = 0

    self.contents.clear_rect(rect)

    if $scene.window_slotdetail.file_exist?(index + 1)

      icon_index = Wora_NSS::SAVED_SLOT_ICON

    else

      icon_index = Wora_NSS::EMPTY_SLOT_ICON

    end

    if !icon_index.nil?

      rect.x -= 4

      draw_icon(icon_index, rect.x, rect.y, enabled) # 繪製圖示

      rect.x += 26

      rect.width -= 20

    end

    self.contents.clear_rect(rect)

    self.contents.font.color = normal_color

    self.contents.font.color.alpha = enabled ? 255 : 128

    self.contents.draw_text(rect, @commands[index])

  end

  

  def cursor_down(wrap = false)

    if @index < @item_max - 1 or wrap

      @index = (@index + 1) % @item_max

    end

  end



  def cursor_up(wrap = false)

    if @index > 0 or wrap

      @index = (@index - 1 + @item_max) % @item_max

    end

  end

end



class Window_NSS_SlotDetail < Window_Base

  include Wora_NSS

  def initialize

    super(160, 56, 384, 360)

    @data = []

    @exist_list = []

    @bitmap_list = {}

    @map_name = []

  end

  

  def dispose

    dispose_tilemap

    super

  end



  def draw_data(slot_id)

    contents.clear # 352, 328

    dispose_tilemap

    load_save_data(slot_id) if @data[slot_id].nil?

    if @exist_list[slot_id]

      save_data = @data[slot_id]

      # DRAW SCREENSHOT

     contents.fill_rect(0,30,352,160, MAP_BORDER)

     if SCREENSHOT_IMAGE

      if save_data['ss']

        bitmap = get_bitmap(save_data['ss_path'])

        rect = Rect.new((Graphics.width-348)/2,(Graphics.height-156)/2,348,156)

        contents.blt(2,32,bitmap,rect)

      end

     else 

      if SWAP_TILE and $game_switches[SWAP_TILE_SWITCH]

      create_swaptilemap(save_data['gamemap'].data, save_data['gamemap'].display_x,

      save_data['gamemap'].display_y)

      else

      create_tilemap(save_data['gamemap'].data, save_data['gamemap'].display_x,

      save_data['gamemap'].display_y)

      end

     end

      if DRAW_GOLD

        # DRAW GOLD

        gold_textsize = contents.text_size(save_data['gamepar'].gold).width

        goldt_textsize = contents.text_size(GOLD_TEXT).width  

        contents.font.color = system_color

        contents.draw_text(0, 0, goldt_textsize, WLH, GOLD_TEXT)

        contents.font.color = normal_color

        contents.draw_text(goldt_textsize, 0, gold_textsize, WLH, save_data['gamepar'].gold)  

       if DRAW_TEXT_GOLD == false

        gold_textsize = 0

        goldt_textsize = 0    

       else

        contents.draw_text(goldt_textsize + gold_textsize, 0, 200, WLH, Vocab::gold)

       end

      end

      if DRAW_PLAYTIME

        # DRAW PLAYTIME

        hour = save_data['total_sec'] / 60 / 60

        min = save_data['total_sec'] / 60 % 60

        sec = save_data['total_sec'] % 60

        time_string = sprintf("%02d:%02d:%02d", hour, min, sec)

        pt_textsize = contents.text_size(PLAYTIME_TEXT).width

        ts_textsize = contents.text_size(time_string).width

        contents.font.color = system_color

        contents.draw_text(contents.width - ts_textsize - pt_textsize, 0,

        pt_textsize, WLH, PLAYTIME_TEXT)

        contents.draw_text(goldt_textsize + gold_textsize,0,200,WLH, Vocab::gold)

        contents.font.color = normal_color

        contents.draw_text(0, 0, contents.width, WLH, time_string, 2)

      end

      if DRAW_LOCATION

        # DRAW LOCATION

        lc_textsize = contents.text_size(LOCATION_TEXT).width

        mn_textsize = contents.text_size(save_data['map_name']).width

        contents.font.color = system_color

        contents.draw_text(0, 190, contents.width, WLH, LOCATION_TEXT)

        contents.font.color = normal_color

        contents.draw_text(lc_textsize, 190, contents.width, WLH, save_data['map_name'])

      end


        save_data['gamepar'].members.each_index do |i|

          actor = save_data['gameactor'][save_data['gamepar'].members[i].id]

          face_x_base = (i*80) + (i*8)

          face_y_base = 216

          lvn_y_plus = 10

          lv_textsize = contents.text_size(actor.level).width

          lvt_textsize = contents.text_size(LV_TEXT).width

        if DRAW_FACE

          # 繪製臉圖

          


          #contents.fill_rounded_rect (rect, Color.new (65, 117, 120))

          #contents.fill_rect(face_x_base, face_y_base, 84, 84, FACE_BORDER)

          draw_face(actor.face_name, actor.face_index, face_x_base + 2,

          face_y_base + 2, 80)

          bitmap2 = Cache.picture("f96-frame2")

          rect2 = Rect.new(0,0,84,84)

          contents.blt(face_x_base,face_y_base,bitmap2,rect2)

        end

        if DRAW_LEVEL

          # 繪製等級

          contents.font.color = system_color

          contents.draw_text(face_x_base + 2 + 80 - lv_textsize - lvt_textsize,

          face_y_base + 2 + 80 - WLH + lvn_y_plus, lvt_textsize, WLH, LV_TEXT)

          contents.font.color = normal_color

          contents.draw_text(face_x_base + 2 + 80 - lv_textsize,

          face_y_base + 2 + 80 - WLH + lvn_y_plus, lv_textsize, WLH, actor.level)

        end

        if DRAW_NAME

          # 繪製名稱

          contents.draw_text(face_x_base, face_y_base + 2 + 80 + lvn_y_plus - 6, 84,

          WLH, actor.name, 1)

        end

      end

    else

      contents.draw_text(0,0, contents.width, contents.height - WLH, EMPTY_SLOT_TEXT, 1)

   end

  end

  

  def load_save_data(slot_id)

    file_name = make_filename(slot_id)

    if file_exist?(slot_id) or FileTest.exist?(file_name)

      @exist_list[slot_id] = true

      @data[slot_id] = {}

      # 開始載入資料

      file = File.open(file_name, "rb")

      @data[slot_id]['time'] = file.mtime

      @data[slot_id]['char'] = Marshal.load(file)

      @data[slot_id]['frame'] = Marshal.load(file)

      @data[slot_id]['last_bgm'] = Marshal.load(file)

      @data[slot_id]['last_bgs'] = Marshal.load(file)

      @data[slot_id]['gamesys'] = Marshal.load(file)

      @data[slot_id]['gamemes'] = Marshal.load(file)

      @data[slot_id]['gameswi'] = Marshal.load(file)

      @data[slot_id]['gamevar'] = Marshal.load(file)

      @data[slot_id]['gameselfvar'] = Marshal.load(file)

      @data[slot_id]['gameactor'] = Marshal.load(file)

      @data[slot_id]['gamepar'] = Marshal.load(file)

      @data[slot_id]['gametro'] = Marshal.load(file)

      @data[slot_id]['gamemap'] = Marshal.load(file)

      @data[slot_id]['total_sec'] = @data[slot_id]['frame'] / Graphics.frame_rate

      if SCREENSHOT_IMAGE

      @data[slot_id]['ss_path'] = file_name.gsub(/\..*$/){'_ss'} + IMAGE_FILETYPE

      @data[slot_id]['ss'] = FileTest.exist?(@data[slot_id]['ss_path'])

      end

      @data[slot_id]['map_name'] = get_mapname(@data[slot_id]['gamemap'].map_id)

      file.close

    else

      @exist_list[slot_id] = false

      @data[slot_id] = -1

    end

  end



  def make_filename(file_index)

    return SAVE_PATH + SAVE_FILE_NAME.gsub(/\{ID\}/i) { (file_index).to_s }

  end

  

  def file_exist?(slot_id)

    return @exist_list[slot_id] if !@exist_list[slot_id].nil?

    @exist_list[slot_id] = FileTest.exist?(make_filename(slot_id))

    return @exist_list[slot_id]

  end

  

  def get_bitmap(path)

    if !@bitmap_list.include?(path)

      @bitmap_list[path] = Bitmap.new(path)

    end

  return @bitmap_list[path]

  end

  

 def get_mapname(map_id)

    if @map_data.nil?

      @map_data = load_data("Data/MapInfos.rvdata")

    end

   if @map_name[map_id].nil?

     if MAP_NO_NAME_LIST.include?(map_id) and $game_switches[MAP_NO_NAME_SWITCH]

       @map_name[map_id] = MAP_NO_NAME

     else

       @map_name[map_id] = @map_data[map_id].name

     end  

       MAP_NAME_TEXT_SUB.each_index do |i|

       @map_name[map_id].sub!(MAP_NAME_TEXT_SUB[i], '')

       @mapname = @map_name[map_id]

     end 

   end

    return @map_name[map_id] 

 end  

  

  def create_tilemap(map_data, ox, oy)

    @viewport = Viewport.new(self.x + 2 + 16, self.y + 32 + 16, 348,156)

    @viewport.z = self.z

    @tilemap = Tilemap.new(@viewport)

    @tilemap.bitmaps[0] = Cache.system("TileA1")

    @tilemap.bitmaps[1] = Cache.system("TileA2")

    @tilemap.bitmaps[2] = Cache.system("TileA3")

    @tilemap.bitmaps[3] = Cache.system("TileA4")

    @tilemap.bitmaps[4] = Cache.system("TileA5")

    @tilemap.bitmaps[5] = Cache.system("TileB")

    @tilemap.bitmaps[6] = Cache.system("TileC")

    @tilemap.bitmaps[7] = Cache.system("TileD")

    @tilemap.bitmaps[8] = Cache.system("TileE")

    @tilemap.map_data = map_data

    @tilemap.ox = ox / 8 + 99

    @tilemap.oy = oy / 8 + 90

  end

  

    def create_swaptilemap(map_data, ox, oy)

    @viewport = Viewport.new(self.x + 2 + 16, self.y + 32 + 16, 348,156)

    @viewport.z = self.z

    @tilemap = Tilemap.new(@viewport)

    

    tile1 = Cache_Swap_Tiles.swap($tileA1 + ".png") rescue nil

    tile2 = Cache_Swap_Tiles.swap($tileA2 + ".png") rescue nil

    tile3 = Cache_Swap_Tiles.swap($tileA3 + ".png") rescue nil

    tile4 = Cache_Swap_Tiles.swap($tileA4 + ".png") rescue nil

    tile5 = Cache_Swap_Tiles.swap($tileA5 + ".png") rescue nil

    tile6 = Cache_Swap_Tiles.swap($tileB + ".png") rescue nil

    tile7 = Cache_Swap_Tiles.swap($tileC + ".png") rescue nil

    tile8 = Cache_Swap_Tiles.swap($tileD + ".png") rescue nil

    tile9 = Cache_Swap_Tiles.swap($tileE + ".png") rescue nil

    

if $tileA1 != nil

@tilemap.bitmaps[0] = tile1

else

@tilemap.bitmaps[0] = Cache.system("TileA1")

end



if $tileA2 != nil

@tilemap.bitmaps[1] = tile2

else

@tilemap.bitmaps[1] = Cache.system("TileA2")

end



if $tileA3 != nil

@tilemap.bitmaps[2] = tile3  

else

@tilemap.bitmaps[2] = Cache.system("TileA3")

end  



if $tileA4 != nil

@tilemap.bitmaps[3] = tile4

else

@tilemap.bitmaps[3] = Cache.system("TileA4")

end



if $tileA5 != nil

@tilemap.bitmaps[4] = tile5  

else

@tilemap.bitmaps[4] = Cache.system("TileA5")

end



if $tileB != nil

@tilemap.bitmaps[5] = tile6

else

@tilemap.bitmaps[5] = Cache.system("TileB")  

end  



if $tileC != nil

@tilemap.bitmaps[6] = tile7

else

@tilemap.bitmaps[6] = Cache.system("TileC")

end  



if $tileD != nil

@tilemap.bitmaps[7] = tile8

else

@tilemap.bitmaps[7] = Cache.system("TileD")  

end



if $tileE != nil

@tilemap.bitmaps[8] = tile9

else

@tilemap.bitmaps[8] = Cache.system("TileE")  

end

  

    @tilemap.map_data = map_data

    @tilemap.ox = ox / 8 + 99

    @tilemap.oy = oy / 8 + 90

end

  

  def dispose_tilemap

    unless @tilemap.nil?

      @tilemap.dispose

      @tilemap = nil

    end

  end

end

end



class Scene_Title < Scene_Base

  def check_continue

    file_name = Wora_NSS::SAVE_PATH + Wora_NSS::SAVE_FILE_NAME.gsub(/\{ID\}/i) { '*' }

    @continue_enabled = (Dir.glob(file_name).size > 0)

  end

end



class Scene_Map < Scene_Base

  alias wora_nss_scemap_ter terminate

  def terminate

    Wora_NSS.shot(Wora_NSS::SAVE_PATH + 'temp')

    wora_nss_scemap_ter

  end

end

#======================================================================


#======================================================================

