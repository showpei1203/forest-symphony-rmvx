#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：MOG_顯示地名
# 【用途】保留的 Runtime 元件「MOG_顯示地名」。
# 【主要機制】主要定義／擴充 Game_System、Game_Map、Window_Base、Mpname；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_System、Game_Map、Window_Base、Mpname、Scene_Map、MOG
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MPFONT、MPNMFD、MPNMTM、MPNMPS、WM_SWITCH_VIS_DISABLE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Mpname。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Moghunter。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#_______________________________________________________________________________
# MOG_Location_Name_VX V1.0            
#_______________________________________________________________________________
# By Moghunter       
# http://www.atelier-rgss.com
#_______________________________________________________________________________
# Apresenta uma janela com o nome do map.
# � necess�rio ter uma imagem com o nome de  MAPNAME
# dentro da pasta Graphics/System.
#_______________________________________________________________________________
module MOG
#Font Name.
MPFONT = "微軟正黑體"
#Fade ON/OFF(True - False).
MPNMFD = true
#Fade Time.
MPNMTM = 10
#Window Position.
# 0 = Upper Left.
# 1 = Lower Left.
# 2 = Upper Right.
# 3 = Lower Right.
MPNMPS = 0
# Disable Switch(ID).
WM_SWITCH_VIS_DISABLE = 31
end
#_________________________________________________
###############
# Game_System #
###############
class Game_System
attr_accessor :fdtm
attr_accessor :mpnm_x
attr_accessor :mpnm_y
alias mog_vx06_initialize initialize
def initialize
mog_vx06_initialize
@fdtm = 255 + 40 * MOG::MPNMTM
if MOG::MPNMPS == 0 
@mpnm_x = -300
@mpnm_y = 0
elsif MOG::MPNMPS == 1
@mpnm_x = -300
@mpnm_y = 320
elsif MOG::MPNMPS == 2
@mpnm_x = 640
@mpnm_y = 0
else 
@mpnm_x = 640
@mpnm_y = 320
end  
end
def mpnm_x
return @mpnm_x
end
def mpnm_y
return @mpnm_y
end
def fdtm
if @fdtm <= 0
@fdtm = 0 
end
return @fdtm
end
end 
############
# Game_Map #
############
class Game_Map
attr_reader   :map_id  
def mpname
$mpname = load_data("Data/MapInfos.rvdata") 
$mpname[@map_id].name
end
end
###############
# Window Base #
###############
class Window_Base < Window
def nd_mapic 
mapic = Cache.system("")     
end  
def draw_mpname(x,y)
mapic = Cache.system("Mpname") rescue nd_mapic   
cw = mapic.width  
ch = mapic.height 
src_rect = Rect.new(0, 0, cw, ch)
self.contents.blt(x , y - ch + 65, mapic, src_rect)
self.contents.font.name = MOG::MPFONT
self.contents.font.size = 22
self.contents.font.bold = true
self.contents.font.shadow = false
self.contents.font.color = Color.new(0,0,0,255)
self.contents.draw_text(x + 53, y + 20, 110, 32, $game_map.mpname.to_s,1)
self.contents.font.color = Color.new(255,255,255,255)
self.contents.draw_text(x + 52, y + 19, 110, 32, $game_map.mpname.to_s,1)
end
end
##########
# Mpname #
##########
class Mpname < Window_Base
def initialize(x , y)
super($game_system.mpnm_x, $game_system.mpnm_y, 250, WLH + 70)
self.opacity = 0
refresh
end
def refresh
self.contents.clear
draw_mpname(10,0)    
end
end
#############
# Scene_Map #
#############
class Scene_Map
alias mog_vx06_start start 
def start
@mpnm = Mpname.new($game_system.mpnm_x, $game_system.mpnm_y)
@mpnm.contents_opacity = $game_system.fdtm
if $game_switches[MOG::WM_SWITCH_VIS_DISABLE] == false
@mpnm.visible = true
else
@mpnm.visible = false  
end  
mog_vx06_start  
end  
alias mog_vx06_terminate terminate
def terminate
mog_vx06_terminate
@mpnm.dispose 
end
alias mog_vx06_update update
def update 
mog_vx06_update  
location_name_update 
end
def location_name_update
$game_system.mpnm_x = @mpnm.x
$game_system.mpnm_y = @mpnm.y
if $game_switches[MOG::WM_SWITCH_VIS_DISABLE] == true or $game_system.fdtm <= 0
@mpnm.visible = false  
else
@mpnm.visible = true 
end 
if MOG::MPNMPS == 0 or MOG::MPNMPS == 1 
if @mpnm.x < 0
@mpnm.x += 5
elsif @mpnm.x >= 0
@mpnm.x = 0
end   
else
if @mpnm.x > 300
@mpnm.x -= 5
elsif @mpnm.x <= 300
@mpnm.x = 300
end     
end 
@mpnm.contents_opacity = $game_system.fdtm
if MOG::MPNMFD == true
$game_system.fdtm -= 3
end
end
alias mog_vx06_update_transfer_player update_transfer_player
def update_transfer_player
return unless $game_player.transfer? 
@mpnm.contents_opacity = 0
mog_vx06_update_transfer_player
if MOG::MPNMPS == 0 
$game_system.mpnm_x = -340
$game_system.mpnm_y = 0
elsif MOG::MPNMPS == 1
$game_system.mpnm_x = -340
$game_system.mpnm_y = 320
elsif MOG::MPNMPS == 2
$game_system.mpnm_x = 640
$game_system.mpnm_y = 0
else 
$game_system.mpnm_x = 640
$game_system.mpnm_y = 320
end  
@mpnm.y = $game_system.mpnm_y
@mpnm.x = $game_system.mpnm_x
$game_system.fdtm = 255 + 60 * MOG::MPNMTM
@mpnm.refresh
end
end
$mogscript = {} if $mogscript == nil
$mogscript["location_name_vx"] = true