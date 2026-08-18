#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Thomas Edison VX
# 【用途】保留的 Runtime 元件「Thomas Edison VX」。
# 【主要機制】主要定義／擴充 Spriteset_Map、Light_Effect；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Spriteset_Map、Light_Effect
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FIRE、LIGHT、GROUND、TORCH、ENABLE_KGC_DAY_NIGHT_SCRIPT、KGC_DAY_NIGHT_SCRIPT_VARIABLE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：le.png。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
=begin
                              Thomas Edison VX

Version: 0.1
Author: BulletXt (bulletxt@gmail.com)
Date: 12/06/2009
Script based upon Kylock's (http://www.rpgmakervx.net/index.php?showtopic=2432)


Description:
 To make an event glow, put a Comment inside event with one of the following
 light modes. When importing this script to a new project, be sure to copy
 Graphics/Pictures/le.png to your project.
 
Light Modes:
  
 GROUND - Medium steady white light.
 GROUND2 - Medium white light with slight flicker.
 GROUND3 - Small steady red light.
 GROUND4 - Medium steady green light.
 GROUND5 - Medium steady blu light.
 FIRE - Large red light with a slight flicker.
 LIGHT - Small steady white light.
 LIGHT2 - X-Large steady white light.
 LIGHT3 - Small white light with slight flicker.
 TORCH - X-Large red light with a heavy flicker.
 TORCH2 - X-Large red light with a sleight flicker.
 TORCH3 - Large white light with a slight flicker.

You can make a specific light type turn off/on by turning
one of the following switches id ON/off. By default, the switches are off so
the lights will show. Of course, turning all switches to ON will make all
light types go off.

=end

#id switch that if ON turns off FIRE mode lights
#applies only to light mode: FIRE
FIRE = 17
#id switch that if ON turns off LIGHT mode lights
#applies to light mode: LIGHT, LIGHT2, LIGHT3
LIGHT = 16
#id switch that if ON turns off GROUND mode lights
#applies to light mode: GROUND, GROUND2, GROUND3, GROUND4, GROUND5
GROUND = 15
#id switch that if ON turns off TORCH mode lights
#applies to light mode: TORCH, TORCH2, TORCH3
TORCH = 14


# this value can be true or false. If true, it enables compatibility with
# KGC_DayNight script. When it's night, lights will automatically go on, when
# morning comes back lights will go off. If you set this to true, be sure to
# place this script below KGC_DayNight script in the Scripting Editor of VX.
ENABLE_KGC_DAY_NIGHT_SCRIPT = false

=begin
This value must be exactly the same of "PHASE_VARIABLE" setting in KGC_DayNight
script. By default the script sets it to 11.
To make the event light go on/off with DayNight system, set the event page
to be triggered with this variable id and set it to be 1 or above.
=end
KGC_DAY_NIGHT_SCRIPT_VARIABLE = 11

=begin
Tips and tricks:
  You can't make a single specific light inside event go on/off if 
  a condition applies, for example if a switch is ON.
  For the moment, you can achieve this by doing
  a script call immediatley after you make the condition apply.
  If for example the light event must go on if switch 100 is ON, after you turn
  on the switch do this call script:
  $scene = Scene_Map.new
  
  Be aware that doing this call script will make game freeze
  for 30 milliseconds.

################################################################################
=end


$bulletxt_day_check = 0

class Spriteset_Map
	
  alias bulletxt_spriteset_map_initalize initialize
	def initialize
		@light_effects = []
		initialize_lights
		bulletxt_spriteset_map_initalize
		update
	end

  alias bulletxt_spriteset_map_dispose dispose
	def dispose
		bulletxt_spriteset_map_dispose
		for effect in @light_effects
			effect.light.dispose
		end
		@light_effects = []
	end
	
  alias bulletxt_spriteset_map_update update
	def update
		bulletxt_spriteset_map_update
    check_day_night if ENABLE_KGC_DAY_NIGHT_SCRIPT
		update_light_effects
    
	end

  
  def check_day_night
    #if night
   if $bulletxt_day_check == 0 
    if $game_variables[KGC_DAY_NIGHT_SCRIPT_VARIABLE] == 1
      $scene = Scene_Map.new
      $bulletxt_day_check = 1
  
    end
    
  else
    #if morning
    if $game_variables[KGC_DAY_NIGHT_SCRIPT_VARIABLE] == 3
      $game_variables[KGC_DAY_NIGHT_SCRIPT_VARIABLE] = -1
      $scene = Scene_Map.new
      $bulletxt_day_check = 0
    end
  end
  
    
    
  end
  
  
	def initialize_lights
		for event in $game_map.events.values
			next if event.list == nil
				for i in 0...event.list.size

					if event.list[i].code == 108 and event.list[i].parameters == ["FIRE"]
						type = "FIRE"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 300 / 100.0
						light_effects.light.zoom_y = 300 / 100.0
						light_effects.light.opacity = 100
						@light_effects.push(light_effects)
					end
          
					if event.list[i].code == 108 and event.list[i].parameters == ["LIGHT"]
						type = "LIGHT"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 1
						light_effects.light.zoom_y = 1
						light_effects.light.opacity = 150
						@light_effects.push(light_effects)
					end
					if event.list[i].code == 108 and event.list[i].parameters == ["LIGHT2"]
						type = "LIGHT2"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 6
						light_effects.light.zoom_y = 6
						light_effects.light.opacity = 150
						@light_effects.push(light_effects)
					end

					if event.list[i].code == 108 and event.list[i].parameters == ["LIGHT3"]
						type = "LIGHT3"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 1
						light_effects.light.zoom_y = 1
						light_effects.light.opacity = 150
						@light_effects.push(light_effects)
					end
          
					if event.list[i].code == 108 and event.list[i].parameters == ["TORCH"]
						type = "TORCH"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 6
						light_effects.light.zoom_y = 6
						light_effects.light.opacity = 150
						@light_effects.push(light_effects)
					end
					if event.list[i].code == 108 and event.list[i].parameters == ["TORCH2"]
						type = "TORCH2"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 6
						light_effects.light.zoom_y = 6
						light_effects.light.opacity = 150
						@light_effects.push(light_effects)
					end
					if event.list[i].code == 108 and event.list[i].parameters == ["TORCH3"]
						type = "TORCH3"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 300 / 100.0
						light_effects.light.zoom_y = 300 / 100.0
						light_effects.light.opacity = 100
						@light_effects.push(light_effects)
					end
          
					if event.list[i].code == 108 and event.list[i].parameters == ["GROUND"]
						type = "GROUND"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 2
						light_effects.light.zoom_y = 2
						light_effects.light.opacity = 100
						@light_effects.push(light_effects)
					end
					if event.list[i].code == 108 and event.list[i].parameters == ["GROUND2"]
						type = "GROUND2"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 2
						light_effects.light.zoom_y = 2
						light_effects.light.opacity = 100
						@light_effects.push(light_effects)
					end
					if event.list[i].code == 108 and event.list[i].parameters == ["GROUND3"]
						type = "GROUND3"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 2
						light_effects.light.zoom_y = 2
						light_effects.light.opacity = 100
						@light_effects.push(light_effects)
					end
					if event.list[i].code == 108 and event.list[i].parameters == ["GROUND4"]
						type = "GROUND4"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 2
						light_effects.light.zoom_y = 2
						light_effects.light.opacity = 100
						@light_effects.push(light_effects)
					end
					if event.list[i].code == 108 and event.list[i].parameters == ["GROUND5"]
						type = "GROUND5"
						light_effects = Light_Effect.new(event,type)
						light_effects.light.zoom_x = 2
						light_effects.light.zoom_y = 2
						light_effects.light.opacity = 100
						@light_effects.push(light_effects)
					end
				end
			end
			
	for effect in @light_effects
		case effect.type
		
		when "FIRE"
			effect.light.x = (effect.event.real_x - 600 - $game_map.display_x) / 8 + rand(6) - 3
			effect.light.y = (effect.event.real_y - 600 - $game_map.display_y) / 8 + rand(6) - 3
			effect.light.tone = Tone.new(255,-100,-255, 0)
			effect.light.blend_type = 1
		when "LIGHT"
			effect.light.x = (-0.25 / 2 * $game_map.display_x) + (effect.event.x * 32) - 15
			effect.light.y = (-0.25 / 2 * $game_map.display_y) + (effect.event.y * 32) - 15
			effect.light.blend_type = 1
		when "LIGHT2"
			effect.light.x = (effect.event.real_x - 1200 - $game_map.display_x) / 8 - 20
			effect.light.y = (effect.event.real_y - 1200 - $game_map.display_y) / 8
			effect.light.blend_type = 1
		when "LIGHT3"
			effect.light.x = (-0.25 / 2 * $game_map.display_x) + (effect.event.x * 32) - 15
			effect.light.y = (-0.25 / 2 * $game_map.display_y) + (effect.event.y * 32) - 15
			effect.light.blend_type = 1
		when "TORCH"
			effect.light.x = (effect.event.real_x - 1200 - $game_map.display_x) / 8 - 20
			effect.light.y = (effect.event.real_y - 1200 - $game_map.display_y) / 8
			effect.light.tone = Tone.new(255,-100,-255, 0)
			effect.light.blend_type = 1
		when "TORCH2"
			effect.light.x = (effect.event.real_x - 1200 - $game_map.display_x) / 8 - 20
			effect.light.y = (effect.event.real_y - 1200 - $game_map.display_y) / 8
			effect.light.tone = Tone.new(255,-100,-255, 0)
			effect.light.blend_type = 1
		when "TORCH3"
			effect.light.x = (effect.event.real_x - 600 - $game_map.display_x) / 8 + rand(6) - 3
			effect.light.y = (effect.event.real_y - 600 - $game_map.display_y) / 8 + rand(6) - 3
			effect.light.blend_type = 1
      
		when "GROUND"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
			effect.light.blend_type = 1
		when "GROUND2"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
			effect.light.blend_type = 1
		when "GROUND3"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
			effect.light.tone = Tone.new(255,-255,-255, 255)
			effect.light.blend_type = 1
		when "GROUND4"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
			effect.light.tone = Tone.new(-255,255,-255, 100)
			effect.light.blend_type = 1
		when "GROUND5"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
			effect.light.tone = Tone.new(-255,255,255, 100)
			effect.light.blend_type = 1
		end
	end
end


def update_light_effects
################################################################################
  
  # handle FIRE
  if $game_switches[FIRE]
    for effect in @light_effects
      next if effect.type != "FIRE" 
      effect.light.visible = false
    end
  else
    for effect in @light_effects
     next if effect.type != "FIRE" 
      effect.light.visible = true
    end
  end

  # handle LIGHT
  if $game_switches[LIGHT]
    for effect in @light_effects
      next if effect.type != "LIGHT" && effect.type != "LIGHT2" && effect.type != "LIGHT3"
      effect.light.visible = false
    end
  else
    for effect in @light_effects
      next if effect.type != "LIGHT" && effect.type != "LIGHT2" && effect.type != "LIGHT3"
      effect.light.visible = true
    end
  end


  # handle GROUND
  if $game_switches[GROUND]
    for effect in @light_effects
      next if effect.type != "GROUND" && effect.type != "GROUND2" && effect.type != "GROUND3" && effect.type != "GROUND4" && effect.type != "GROUND5" 
      effect.light.visible = false
    end
  else
    for effect in @light_effects
      next if effect.type != "GROUND" && effect.type != "GROUND2" && effect.type != "GROUND3" && effect.type != "GROUND4" && effect.type != "GROUND5" 
      effect.light.visible = true
    end
  end


  # handle TORCH
  if $game_switches[TORCH]
    for effect in @light_effects
      next if effect.type != "TORCH" && effect.type != "TORCH2" && effect.type != "TORCH3"
      effect.light.visible = false
    end
  else
    for effect in @light_effects
      next if effect.type != "TORCH" && effect.type != "TORCH2" && effect.type != "TORCH3"
      effect.light.visible = true
    end
  end





################################################################################

	for effect in @light_effects
		case effect.type

	when "FIRE"
			effect.light.x = (effect.event.real_x - 600 - $game_map.display_x) / 8 + rand(6) - 3
			effect.light.y = (effect.event.real_y - 600 - $game_map.display_y) / 8 + rand(6) - 3
			effect.light.opacity = rand(10) + 90
      
	when "LIGHT"
			effect.light.x = (-0.25 / 2 * $game_map.display_x) + (effect.event.x * 32) - 15
			effect.light.y = (-0.25 / 2 * $game_map.display_y) + (effect.event.y * 32) - 15
	when "LIGHT2"
			effect.light.x = (effect.event.real_x - 1200 - $game_map.display_x) / 8 - 20
			effect.light.y = (effect.event.real_y - 1200 - $game_map.display_y) / 8
	when "LIGHT3"
			effect.light.x = (-0.25 / 2 * $game_map.display_x) + (effect.event.x * 32) - 15
			effect.light.y = (-0.25 / 2 * $game_map.display_y) + (effect.event.y * 32) - 15
			effect.light.opacity = rand(10) + 90
      
	when "TORCH"
			effect.light.x = (effect.event.real_x - 1200 - $game_map.display_x) / 8 - 20 + rand(20) - 10
			effect.light.y = (effect.event.real_y - 1200 - $game_map.display_y) / 8 + rand(20) - 10
			effect.light.opacity = rand(30) + 70
	when "TORCH2"
			effect.light.x = (effect.event.real_x - 1200 - $game_map.display_x) / 8 - 20
			effect.light.y = (effect.event.real_y - 1200 - $game_map.display_y) / 8
			effect.light.opacity = rand(10) + 90
	when "TORCH3"
			effect.light.x = (effect.event.real_x - 600 - $game_map.display_x) / 8 + rand(6) - 3
			effect.light.y = (effect.event.real_y - 600 - $game_map.display_y) / 8 + rand(6) - 3
			effect.light.opacity = rand(10) + 90
      
	when "GROUND"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
	when "GROUND2"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
			effect.light.opacity = rand(10) + 90
	when "GROUND3"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
	when "GROUND4"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
	when "GROUND5"
			effect.light.x = (effect.event.real_x - 400 - $game_map.display_x) / 8
			effect.light.y = (effect.event.real_y - 400 - $game_map.display_y) / 8
		end
	end

  #close def
	end
#close class	
end


class Light_Effect
	attr_accessor :light
	attr_accessor :event
	attr_accessor :type
	
	def initialize(event, type)
		@light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = true
		@light.z = 1000
		@event = event
		@type = type
	end

end
