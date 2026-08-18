#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Area+｜Complete Authority
# 【用途】Area+ 地圖區域系統完整 Authority，已把原使用說明、設定、Window、Character 與 Encounter 五頁依原順序合併。
# 【主要機制】用於定義／顯示區域並可與遇敵邏輯結合；設定與使用範例仍保留於本頁原始說明。
# 【主要影響】Scene_Map、Window_area、Game_Event、Game_Interpreter、Area、AREA、RPG
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：AREA_ENTERED_ARRAY。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意。
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
# PHASE 8 AUTHORITY: Area+｜Complete Authority
# Area+ 使用說明、設定、Window、Character、Encounter 全套原始順序整併。
# Original load order: 338:======AREA+===== -> 339:Area+_parameters -> 340:Area+_window -> 341:Area+_character -> 342:Area+_encounters
#==============================================================================
# PHASE8 ORIGINAL PAGE: 338 | ======AREA+=====
#==============================================================================
############################################
## AREA + by dricc
## mode d'emploi !
## user's guide

## All setups are in "Area+_parameters"
## tout les parametres sont dans "Area+_parameters"

# toutes les fonctionalités faites ici fonctionnent par nom de zone , vous pouvez donc faires des zones "composites" non rectangulaires
# all features works by the name of area . It means that you can make "composite" areas .

# 1 
# random moving for characters
# mouvement aléatoire pour les PNJ
# =>
# Mettez "[AREA]" dans le nom de l'evenement et mettez votre personnage en "deplacement aléatoire"
# Put "[AREA]" in the name of the event and put your event normaly in "random moving"

# 2
# window appaering when you are in an area

# 3
# switch triggered when going in or out an area
# check in script Area+_parameters
# use these switch in common events ....

# 4
# can change encounters in a an area
# call script : enable_area('Zone des monstres')
# => enable encounters in this area
# call script : disable_area('Zone des monstres')
# => disable encounters in this area
# call script : switch_area('area_name1','area_name2')
# switch encounters in these areas

# 5
# event know in which areas they are
# call script : set_var_area_name(25)
# And then , use "\v[25]" to display the current area in a message window

#==============================================================================
# PHASE8 ORIGINAL PAGE: 339 | Area+_parameters
#==============================================================================
##################################################
### Area parameter
### par dricc
##################################################

# C'est ici que vous parametez vos areas !!
# For setup on AREAs , it's here !
#C:\Users\User\Desktop\綠曲-重製\Area_plus_eng
################################################################################

module AREA

  # don't touch this -- ne pas modifier
  AREA_ENTERED_ARRAY = []

   #setup
  # when <nom de la zone>
  # ;return [<true si les PNJ peuvent s'y promener>,interupteur premiere entrée ,interrupteur à chaque entrée,interrupteur à chaque sortie]
  # mettez -1 si vous ne voulez pas d'interupteur .
  # when <name of area>
  # ;return [<true if character events can walk here>,switch for first entry only ,switch for each entry,switch for each exit]
  # put -1 if you do not want a switch .
  
  def self.area_info(area_name)
    case area_name
    when '上邊界'; return [false,-1,105,106]
    when '下邊界'; return [false,-1,107,108]
    when '左邊界'; return [false,-1,109,110]
    when '右邊界'; return [false,-1,111,112]
    else; return [true, -1,-1, -1]
    end
  end


end

#==============================================================================
# PHASE8 ORIGINAL PAGE: 340 | Area+_window
#==============================================================================
##################################################
### Area window
### par dricc
##################################################

# Ce premier script sert à l'affichage de la fenetre avec le nom de l'area en haut à droite
# thsi script is used to show the window with the name of the area

################################################################################

class Scene_Map < Scene_Base
  #-------------------------------------------------------------------------- 
  # * Frame Update
  #--------------------------------------------------------------------------
  alias dricc_area_update update
  alias dricc_area_start start
  alias dricc_area_terminate terminate

  attr_reader    :last_area_name
  
  def start
    dricc_area_start
    @window_area_dsp = Window_area.new(self.area_name)
    area_setup = AREA::area_info(self.area_name)
    area_entered = AREA::AREA_ENTERED_ARRAY
     if area_name != nil
       first_in_switch = area_setup[1]
       in_switch = area_setup[2]
       out_switch = area_setup[3]
       $game_switches[first_in_switch] = true if first_in_switch != -1 and not area_entered.include?(area_name)
       $game_switches[in_switch] = true if in_switch != -1
       $game_switches[out_switch] = false if out_switch != -1
       @last_area_name = area_name
        area_entered.push(area_name)
     end
  end
  
  def map_name
     return self.map_name
  end
  
  def terminate
    @window_area_dsp.dispose
    dricc_area_terminate
  end
  
  def update
      dricc_area_update
      @window_area_dsp.update(self.area_name)
      if @last_area_name != area_name
        if area_name != nil
          area_setup = AREA::area_info(area_name)
          area_entered = AREA::AREA_ENTERED_ARRAY
          first_in_switch = area_setup[1]
          in_switch = area_setup[2]
          out_switch = area_setup[3]
          $game_switches[first_in_switch] = true if first_in_switch != -1 and not area_entered.include?(area_name)
          $game_switches[in_switch] = true if in_switch != -1
          $game_switches[out_switch] = false if out_switch != -1
          area_entered.push(area_name)
        end
        if @last_area_name != nil
          area_setup = AREA::area_info(@last_area_name)
          in_switch = area_setup[2]
          out_switch = area_setup[3]
         $game_switches[in_switch] = false if in_switch != -1
         $game_switches[out_switch] = true if out_switch != -1
        end
        @last_area_name = area_name
      end
  end

  def area_name
    curr_area = nil
    for area in $data_areas.values
         if $game_player.in_area?(area)
            if curr_area == nil then
              curr_area = area.name
            end
         end
       end
       return curr_area
  end
end

class Window_area < Window_Base
#  attr_accessor  :area_window_fade_time
  
  def initialize(area_name)
    super(0,-100,250,52)
    @area_window_fade_time = 0
    self.opacity = 0
    self.visible = (area_name != nil) 
    refresh(area_name)
  end

  def refresh(area_name)
#    @area_window_fade_time += 1
    self.opacity = 0 
    self.visible = (area_name != nil) 
    contents.clear
#     if @area_window_fade_time > 100
#       self.width = area_name.length*25 + 10
      self.contents.draw_text(0, -5, self.width, WLH, area_name)
  #   end
  end

  def update(area_name)
#    self.visible = (area_name != nil) 
      refresh(area_name)
  end
end


#==============================================================================
# PHASE8 ORIGINAL PAGE: 341 | Area+_character
#==============================================================================
##################################################
### Area character
### par dricc
##################################################

# Ce deuxieme script gere les deplacements aléatoires des personnages
# mettez [AREA] dans le nom de l'evenement et celui-ci ne pourra pas sortir de la zone ou il est

# This script is used for the random move of the characters
# put [AREA] anywhere inthe name of the event and this event can't move outside his current area

################################################################################

#class Game_Character
class Game_Event
 attr_reader    :name
  alias dricc_area initialize

  def initialize(map_id, event)
    @name = event.name
    dricc_area(map_id, event)
  end
#--------------------------------------------------------------------------
  # * Move at Random
  #--------------------------------------------------------------------------
  def move_random
if  @name.index('[AREA]') != nil
    case rand(4)
    when 0;  move_down(false) if area_name(@x,@y) == area_name(@x,@y + 1) and AREA::area_info(area_name(@x,@y + 1))[0]
    when 1;  move_left(false) if area_name(@x,@y) == area_name(@x - 1,@y ) and AREA::area_info(area_name(@x- 1,@y))[0]
    when 2;  move_right(false) if area_name(@x,@y) == area_name(@x + 1,@y) and AREA::area_info(area_name(@x + 1,@y))[0]
    when 3;  move_up(false) if area_name(@x,@y) == area_name(@x,@y - 1) and AREA::area_info(area_name(@x,@y - 1))[0]
    end
else
    case rand(4)
    when 0;  move_down(false) if AREA::area_info(area_name(@x,@y + 1))[0]
    when 1;  move_left(false) if AREA::area_info(area_name(@x- 1,@y))[0]
    when 2;  move_right(false) if AREA::area_info(area_name(@x + 1,@y))[0]
    when 3;  move_up(false) if AREA::area_info(area_name(@x,@y - 1))[0]
    end
  end
  end

  #--------------------------------------------------------------------------
  # * 1 Step Forward
  #--------------------------------------------------------------------------
  def move_forward
if  @name.index('[AREA]') != nil
    case @direction
    when 2;  move_down(false) if area_name(@x,@y) == area_name(@x,@y + 1) and AREA::area_info(area_name(@x,@y + 1))[0]
    when 4;  move_left(false) if area_name(@x,@y) == area_name(@x - 1,@y ) and AREA::area_info(area_name(@x- 1,@y))[0]
    when 6;  move_right(false) if area_name(@x,@y) == area_name(@x + 1,@y) and AREA::area_info(area_name(@x + 1,@y))[0]
    when 8;  move_up(false) if area_name(@x,@y) == area_name(@x,@y - 1) and AREA::area_info(area_name(@x,@y - 1))[0]
    end
else
    case @direction
    when 2;  move_down(false)  if AREA::area_info(area_name(@x,@y + 1))[0]
    when 4;  move_left(false) if AREA::area_info(area_name(@x- 1,@y))[0]
    when 6;  move_right(false) if AREA::area_info(area_name(@x + 1,@y))[0]
    when 8;  move_up(false) if AREA::area_info(area_name(@x,@y - 1))[0]
end
      end
  end
  
  def  area_name_cur
    return area_name(@x,@y)
  end
  
    #--------------------------------------------------------------------------
  # * Determine if in Area
  #     area : Area data (RPG::Area)
  #--------------------------------------------------------------------------
  def in_area?(area,x,y)
    return false if area == nil
    return false if $game_map.map_id != area.map_id
    return false if x < area.rect.x
    return false if y < area.rect.y
    return false if x >= area.rect.x + area.rect.width
    return false if y >= area.rect.y + area.rect.height
    return true
  end
  
    def area_name(x,y)
    curr_area = nil
    for area in $data_areas.values
         if in_area?(area,x,y)
            if curr_area == nil then
              curr_area = area.name
            end
         end
      end
      return curr_area
    end
     
end
  
class Game_Interpreter

  def area_name_cur
    event = get_character(0)
    return event.area_name_cur
   end 

   def set_var_area_name(var_id)
     $game_variables[var_id] = area_name_cur
     if  $game_variables[var_id]  == 0
       id = $game_map.map_id
       $game_variables[var_id]  = $Data_Maps.values[id].name
      end
   end
   
end
 
 

#==============================================================================
# PHASE8 ORIGINAL PAGE: 342 | Area+_encounters
#==============================================================================
# ici , on gere les rencontres avec les monstre
# We deal with encounters here .


module RPG
  class Area

    alias old_initialize initialize

    attr_accessor :encounter_list_old
    attr_accessor :disable

    def initialize
      old_initialize
      @disable = false
      @encounter_list_old = []
    end
  end
end


class Game_Interpreter
  
  def disable_area(area_name)
    for area in $data_areas.values
         if area.name == area_name
           if not area.disable
             area.encounter_list_old = area.encounter_list
             area.encounter_list = []
             area.disable = true
           end
         end
      end
  end
  
  def enable_area(area_name)
    for area in $data_areas.values
         if area.name == area_name
           if area.disable
             area.encounter_list = area.encounter_list_old
             area.encounter_list_old = []
             area.disable = false
           end
        end
      end
  end
  
    def switch_area(area_name1,area_name2)
    encounter_list_temp1 = []
    encounter_list_temp2 = []
      for area in $data_areas.values
         if area.name == area_name1
            encounter_list_temp1 = area.encounter_list
         end
      end
      for area in $data_areas.values
         if area.name == area_name2
            encounter_list_temp2 = area.encounter_list
            area.encounter_list = encounter_list_temp1
         end
      end
      for area in $data_areas.values
         if area.name == area_name1
            area.encounter_list = encounter_list_temp2
         end
      end
  end
  
end 
