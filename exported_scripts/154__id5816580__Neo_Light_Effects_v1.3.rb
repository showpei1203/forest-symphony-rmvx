#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Neo Light Effects v1.3
# 【來源】Khas Arcthunder，Neo Light Effects v1.3，2010-06-08；使用條款以原作者網站為準。本頁需要 Khas Script Core 1.0 以上。
# 【用途】讓地圖事件依事件註解掛上發光／粒子效果；Spriteset_Map 建立事件 Sprite 時會同步建立光效 Sprite，並隨事件位置、透明度、角度與 Hue 持續更新。
# 【事件用法】在事件頁「註解」寫一個已存在的效果名稱，且該行必須是事件註解指令（code 108）。例如直接寫：Light、Fire、Torch、Window、Door、Shine、Sparkle、Rainbow、Blood、Leaf、Xenon、Lantern 或 Arrow。名稱需與 Neo_Light::Effects Hash 的 Key 完全一致。
# 【全域開關】Neo_Light_Switch=2；Switch 2 ON 時所有 Neo Light Sprite 隱藏，OFF 時顯示。改 ID 前先確認事件／其他系統沒有共用同一 Switch。
# 【新增效果】簡易："名稱" => Neo_Effect.new("圖檔", opacity)。進階：Neo_Effect.new(圖檔, opacity, Tone, blend_type, ax, ay, angle, opacity_oscillation, hue_oscillation)。Hash 每筆後面要保留逗號。
# 【參數】opacity 0~255；blend_type 1~2；ax/ay 控制位置抖動；angle 控制旋轉；opacity_oscillation 控制透明度變化；hue_oscillation 控制色相變化。數值越大，視覺擾動越明顯。
# 【目前效果／素材】Graphics/Particles/ 目前直接使用：Lantern、Arrow、window、light3、light2、sparkle、circle、fire、light1、fire_big。Cache.particle／Bitcore 會預先載入 Effects 中所有圖檔。
# 【載入順序】必須在 Khas Script Core 後、使用本效果的地圖／事件 Runtime 前。Game_Event#initialize/setup/update 與 Spriteset_Map 會被 alias，不能隨意搬到其他完整覆寫這些方法的插件之前／之後。
# 【調整建議】要新增純視覺效果優先加 Effects Hash，不要改 update_light；若要退休本系統，只有確認 Graphics/Particles 對應圖檔未被其他腳本／事件使用後才能刪素材。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# * By Khas Arcthunder
# * Version: 1.3
# * Released on: 08/06/2010
#
# * Blog: http://arcthunder.com/
# * Forum: http://rgssx.com/
# * Twitter: http://twitter.com/arcthunder
# * Youtube: http://youtube.com/user/darkkhas
#
#-------------------------------------------------------------------------------
# Terms of Use | Termos de Uso
#-------------------------------------------------------------------------------
# Read updated terms of use at http://arcthunder.com/terms
#
# Leia os termos atualizados em http://arcthunder.com/termos
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#
#
#
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
if $enabled_core.nil?
  p "The script 'Neo Light Effects' requires Khas Script Core 1.0 or better"
  p "Please install Khas Script Core 1.0 or better"
  exit
elsif $enabled_core < 1
  p "The script 'Neo Light Effects' requires Khas Script Core 1.0 or better"
  p "Please install Khas Script Core 1.0"
  exit
else
  Core.register("Neo Light Effects",1.3)
end

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
module Neo_Light
  Neo_Light_Switch = 2
  
  # 以下核心區請勿任意修改！
  Effects = {
  
  
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#
#
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#
#
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

"Lantern" => Neo_Effect.new("Lantern",150,Tone.new(0,0,0),1),
"Arrow" => Neo_Effect.new("Arrow",255),

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
"Window" => Neo_Effect.new("window",100),
"Door" => Neo_Effect.new("light3",100),
"Shine" => Neo_Effect.new("light2",150,Tone.new(0,0,0),1,0,0,1,0,0),
"Sparkle" => Neo_Effect.new("sparkle",150,Tone.new(0,0,0),1,0,0,3,0,7),
"Rainbow" => Neo_Effect.new("circle",150,Tone.new(0,0,0),1,0,0,-2,0,4),
"Blood" => Neo_Effect.new("fire",180,Tone.new(255,-230,-230),1,0,0,0,0,0),
"Leaf" => Neo_Effect.new("fire",130,Tone.new(-150,255,-150),1,0,0,0,0,0),
"Xenon" => Neo_Effect.new("fire",180,Tone.new(-200,-200,255),1,0,0,0,0,0),

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
"Light" => Neo_Effect.new("light1",100),
"Fire" => Neo_Effect.new("fire",110,Tone.new(255,-100,-255),1,3,3,0,-20,0),
"Torch" => Neo_Effect.new("fire_big",110,Tone.new(255,-100,-255),1,1,1,0,-20,0),

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
  }
  def self.bc_sprites; bitmaps = []
    Effects.keys.each { |i| 
    bitmaps << Effects[i].picture_name unless bitmaps.include?(Effects[i].picture_name) }
    bitmaps.each { |i| Bitcore.add(Cache.particle(i), "neole_#{i}") }
  end; bc_sprites
end

class Game_Event < Game_Character
  include Neo_Light
  alias nle_ini initialize
  alias nle_stp setup
  alias nle_up update
  def initialize(map_id, event)
    @nl_effect = false
    @nl_sprite = nil
    nle_ini(map_id, event)
  end
  def setup(new_page)
    nle_stp(new_page)
    refresh_light(new_page.nil?)
  end
  def update; nle_up
    update_light unless !@nl_effect
  end
  def update_light
    @nl_sprite.visible = !$game_switches[Neo_Light_Switch]
    @nl_sprite.x = self.screen_x
    @nl_sprite.y = self.screen_y - 16
    @nl_sprite.x += (rand(Effects[@nl_effect].ax*2)-Effects[@nl_effect].ax)
    @nl_sprite.y += (rand(Effects[@nl_effect].ay*2)-Effects[@nl_effect].ay)
    @nl_sprite.opacity = Effects[@nl_effect].opacity + rand(Effects[@nl_effect].opacity_oscillation)
    @nl_sprite.angle += Effects[@nl_effect].angle
    @nl_sprite.angle -= 360 if @nl_sprite.angle >= 360
    @nl_sprite.bitmap.hue_change(Effects[@nl_effect].hue_oscillation) unless !Effects[@nl_effect].hue_oscillation
  end
  def refresh_light(dispose_light=false)
    unless @nl_effect == false
      @nl_sprite.bitmap = nil
      @nl_sprite.dispose
      @nl_sprite = nil
    end
    @nl_effect = false
    unless dispose_light
      return if @list.nil?
      for key in 0...@list.size
        next unless @list[key].code == 108
        for string in Effects.keys
          @nl_effect = string if @list[key].parameters == [string]
        end
      end
      if @nl_effect != false
        @nl_sprite = Sprite.new
        @nl_sprite.bitmap = Bitcore["neole_"+Effects[@nl_effect].picture_name]
        @nl_sprite.ox = @nl_sprite.width/2
        @nl_sprite.oy = @nl_sprite.height/2
        @nl_sprite.x = 544 + 2*@nl_sprite.width
        @nl_sprite.y = 416 + 2*@nl_sprite.height
        @nl_sprite.z = $game_player.screen_z
        @nl_sprite.blend_type = Effects[@nl_effect].blend_mode
        @nl_sprite.opacity = Effects[@nl_effect].opacity
        @nl_sprite.tone = Effects[@nl_effect].color
        update_light if $scene.is_a?(Scene_Map)
      end
    end
  end
  def dispose_nl
    unless @nl_effect == false
      return unless @nl_sprite.is_a?(Sprite)
      @nl_sprite.bitmap = nil
      @nl_sprite.dispose
      @nl_sprite = nil
      @nl_effect = false
    end
  end
end

class Game_Map
  alias nle_setup setup
  def setup(map_id)
    dispose_neolight
    nle_setup(map_id)
  end
  def dispose_neolight
    return if @events.nil?
    @events.keys.each { |id| $game_map.events[id].dispose_nl }
  end
  def force_light_refresh
    return if @events.nil?
    @events.keys.each { |id| $game_map.events[id].refresh_light }
  end
end

class Spriteset_Map
  alias nle_initialize initialize
  alias nle_dispose dispose
  def initialize
    nle_initialize
    $game_map.force_light_refresh
  end
  def dispose
    nle_dispose
    $game_map.dispose_neolight
  end
end