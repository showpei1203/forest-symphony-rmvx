#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：AdvancedFog_Core v1.2｜Shuu_Fog
# 【來源】Shuuchan，Advanced Fog Script v1.2，2009-02-11，RGSS2 / RPG Maker VX。
# 【用途】在地圖上以 Graphics/Pictures 圖片建立類似 RPG Maker XP 的 Fog Plane，支援捲動、Opacity、Blend 與漸變切換；並把 Fog 設定寫入 Save。
# 【Script Call】`Shuu_Fog.change(time, filename, vel_x=0, vel_y=0, opacity=128, blend=0)`。time 以 frame 計；filename 為 Pictures 檔名。
# 【範例】`Shuu_Fog.change(60,"img_01",0,5,64,1)`：60 frame 內切成 img_01、Y 速度 5、Opacity 64、加法 Blend；`Shuu_Fog.change(120,"")`：120 frame 淡出目前 Fog；`Shuu_Fog.change(30,"img_02",10)`：只設定 X 速度，其他用預設。
# 【預設地圖 Fog】Scene_Title#create_game_objects 內 `$fog_data = { map_id => [filename,vel_x,vel_y,opacity,blend] }`；目前 Map 1 預設 `fog,-5,-5,128,2`。此區所有欄位都必填。
# 【保存】Scene_File#write_save_data/read_save_data 會額外 Marshal `$fog_data` 與 `$fog_transition`；變更序列化格式要測舊存檔。
# 【Load Order】alias Scene_Title、Scene_File、Spriteset_Map。後方 Multiple Fogs／Battle Fog 等是不同層，不能因名稱相似隨意替代。
# 【素材】Graphics/Pictures/<fog filename>，固定範例為 `fog`；實際檔名可由事件 Script Call 動態指定。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#===============================================================================
# 以下為實際 Runtime 程式；使用方式請見頁首繁中完整說明。
#===============================================================================
class Scene_Title < Scene_Base
  alias shuu_fog_create_game_objects create_game_objects
  def create_game_objects
    shuu_fog_create_game_objects
#===============================================================================
#-------------------------------------------------------------------------------
#
#   $fog_data = { Map_ID_A => [nomefile_A, vel_x, vel_y, opacit? blend],
#                 ...
#                 }
#
#
#-------------------------------------------------------------------------------

    $fog_data = { 1 => ["fog", -5, -5, 128, 2]
                  }
                  
#-------------------------------------------------------------------------------
#===============================================================================
    $fog_transition = 0
  end
  
end

class Scene_File < Scene_Base
  alias shuu_fog_write write_save_data
  alias shuu_fog_read read_save_data
  def write_save_data(file)
    shuu_fog_write(file)
    Marshal.dump($fog_data, file)
    Marshal.dump($fog_transition, file)
  end
  def read_save_data(file)
    shuu_fog_read(file)
    $fog_data = Marshal.load(file)
    $fog_transition = Marshal.load(file)
  end
end

module Shuu_Fog
  def self.change(transition,nomefile,vel_x=0,vel_y=0,opacity=128,blend=0)
    if $game_map.map_id != nil
      $fog_data[$game_map.map_id] = [nomefile, vel_x, vel_y, opacity, blend]
      $fog_transition = transition
    end
  end
end

class Spriteset_Map
  alias shuu_fog_initialize initialize
  alias shuu_fog_update update
  alias shuu_fog_dispose dispose
  
  def initialize
    create_fog
    shuu_fog_initialize
  end
  
  def update
    update_fog
    shuu_fog_update
  end
  
  def dispose
    dispose_fog
    shuu_fog_dispose
  end
  
  def create_fog
    @sprite_fog = Plane.new
    @sprite_fog.opacity = 0
    @sprite_fog.z = 10
    @fog_creata = false
    @data_fog = []
    @fog_vel_counter_x = 0
    @fog_vel_counter_y = 0
    @vel_x_fog = 0
    @vel_y_fog = 0
    @bit_wid = 1
    @bit_hei = 1
    @change_transition = 0
    if $fog_data.keys.include?($game_map.map_id)
      if $fog_data[$game_map.map_id][0] != ""
        @fog_creata = true
        @data_fog = $fog_data[$game_map.map_id]
        bitmap_base = Cache.picture($fog_data[$game_map.map_id][0])
        @sprite_fog.opacity = $fog_data[$game_map.map_id][3]
        @starting_opacity = @sprite_fog.opacity 
        @sprite_fog.blend_type = $fog_data[$game_map.map_id][4]
        @vel_x_fog = $fog_data[$game_map.map_id][1]
        @vel_y_fog = $fog_data[$game_map.map_id][2]
        @bit_wid = bitmap_base.width
        @bit_hei = bitmap_base.height
        @sprite_fog.bitmap = bitmap_base
      end
    end
  end
  
  def change_fog
    dispose_fog
    @sprite_fog = Plane.new
    @sprite_fog.opacity = 0
    @sprite_fog.z = 10
    @fog_creata = false
    @data_fog = []
    @fog_vel_counter_x = 0
    @fog_vel_counter_y = 0
    if $fog_data.keys.include?($game_map.map_id)
      if $fog_data[$game_map.map_id][0] != ""
        @fog_creata = true
        bitmap_base = Cache.picture($fog_data[$game_map.map_id][0])
        @sprite_fog.blend_type = $fog_data[$game_map.map_id][4]
        @vel_x_fog = $fog_data[$game_map.map_id][1]
        @vel_y_fog = $fog_data[$game_map.map_id][2]
        @bit_wid = bitmap_base.width
        @bit_hei = bitmap_base.height
        @sprite_fog.bitmap = bitmap_base
      end
    end
  end
  
  def update_fog
    if @fog_creata
      if @data_fog == $fog_data[$game_map.map_id]
        normal_update_fog
      else
        update_change_fog
      end
    else
      if $fog_data[$game_map.map_id] != nil
        update_change_fog
      end
    end
  end
  
  def normal_update_fog
    @fog_vel_counter_x += @vel_x_fog
    @fog_vel_counter_y += @vel_y_fog
    @fog_vel_counter_x -= @bit_wid*8 if @fog_vel_counter_x >= @bit_wid*8
    @fog_vel_counter_y -= @bit_hei*8 if @fog_vel_counter_y >= @bit_hei*8
    @sprite_fog.ox = ($game_map.display_x + @fog_vel_counter_x) / 8
    @sprite_fog.oy = ($game_map.display_y + @fog_vel_counter_y) / 8
  end
  
  def update_change_fog
    if @change_transition == 0
      @change_transition = $fog_transition
      @change_transition = 1 if @change_transition == 0
      @starting_opacity = @sprite_fog.opacity
      @destination_opacity = $fog_data[$game_map.map_id][3]
      @scompare = @starting_opacity
      @appare = 0
      @rapp_change = (@starting_opacity.to_f/@change_transition) # 詳見頁首繁中說明
      @new_rapp_change = (@destination_opacity.to_f/@change_transition) # 詳見頁首繁中說明
    end
    if $fog_transition > 0
      $fog_transition -= 1
      $fog_transition = 0 if $fog_transition < 0 or not @fog_creata
      @scompare -= @rapp_change
      @sprite_fog.opacity = @scompare.floor
      @sprite_fog.opacity = 0 if @sprite_fog.opacity < 0
      change_fog if $fog_transition == 0
    else
      @change_transition -= 1
      @change_transition = 0 if @change_transition < 0
      @appare += @new_rapp_change
      @sprite_fog.opacity = @appare.ceil
      @sprite_fog.opacity = @destination_opacity if @sprite_fog.opacity > @destination_opacity
      @data_fog = $fog_data[$game_map.map_id] if @change_transition == 0
    end
    normal_update_fog
  end
  
  def dispose_fog
    @sprite_fog.dispose
  end
  
end