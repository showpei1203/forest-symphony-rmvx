#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Footsteps
# 【用途】地圖腳步聲系統，依地形／角色移動播放不同 SE。
# 【主要機制】通常由 Game_Player／Game_Character 移動流程自動觸發；設定重點是地形或地圖對應的音效表。
# 【主要影響】Game_Character、Game_Player、Game_Event、Game_Map、Mm12
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：START_WITH_SE、BRIDGE_TILES、CARPET_TILES、DIRT_TILES、GRASS_TILES、ICE_TILES、LAVA_TILES、SAND_TILES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 4 個 alias／方法包裝，載入順序具有語意；登記 $imported：Mm12Footsteps。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：walk2。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
# 148 FOR EVENT
# 105 FOR PLAYER

#==============================================================================
# ** Simple Footstep script
#  Version 2.5
#  Credits:
#    Creator: Miget man12, Help improving from: Modern Algebra, Yanfly, Twilight1300
#    Formula for getting Tile ID by DerVVulfman
#-----------------------------------------------------------------------------
#  I made this just so I could have a not-laggy, easy to use script. It doesn't
# really have any special features, but it works without very much lag. It is
# also being used in "The Legend of Zelda: Realm of the Gods", a Zelda
# fan-game(Hence the SE's from OoT :D) that I'm working on with Twilight1300.
#-----------------------------------------------------------------------------
# Instructions:
#  To have an event have footstep sounds, just put Comment:
# [footstep]
# To have an event or the player use footsteps:
# For The Player:
#  $game_player.footstep_se = true/false
# For an Event:
#  $game_map.events[(Event ID)].footstep_se = true/false
#  The Event ID is the ID of the event on the map you are on
# If you want an event to have a special footstep sound effect, put a comment
# like so:
#  [footstepse:SE Name]
# e.g.
#  [footstepse:OOT_LikeLike_Move]
# ***Event settings are reset when you tranfer*** (this doesn't apply to comment-
#  related settings)
#==============================================================================
$imported = {} if $imported == nil
$imported["Mm12Footsteps"] = true
module Mm12
  START_WITH_SE = true # Start out with player's footsteps enabled?
  BRIDGE_TILES = []
  CARPET_TILES = [1..99999]
  DIRT_TILES = []
  GRASS_TILES = []
  ICE_TILES = []
  LAVA_TILES = []
  SAND_TILES = []
  STONE_TILES = []
  TGRASS_TILES = []
  WOOD_TILES = []
  SNOW_TILES = []
  LADDER_TILES = []
  BRIDGE_SE = ["walk"]
  CARPET_SE = ["walk"]
  DIRT_SE = ["walk"]
  GRASS_SE = ["walk"]
  ICE_SE = ["walk"]
  LAVA_SE = ["walk"]
  SAND_SE = ["walk"]
  STONE_SE = ["walk"]
  TGRASS_SE = ["walk"]
  WOOD_SE = ["walk"]
  SNOW_SE = ["walk"]
  LADDER_SE = ["walk"]
end
#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass of the
# Game_Player and Game_Event classes.
#==============================================================================
class Game_Character
  attr_accessor :footstep_se
end

class Game_Player
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias ftstp_gp_initialize initialize
  alias ftstp_gp_increase_steps increase_steps
  def initialize
    @se_ok = true
    @footstep_se = true
    ftstp_gp_initialize
  end
  def increase_steps
    ftstp_gp_increase_steps
    footstep_se
  end
  #---------------------------------------------------------------------------
  # * Footstep SE
  #---------------------------------------------------------------------------
  def footstep_se
    if @se_ok == true
      @num = 0
      play_se
      @se_ok = false
    elsif @se_ok == false
      if $game_player.dash?
        @se_ok = true
      else
        @num = 1
        play_se
        @se_ok = true
      end
      return
    end
  end
  def play_se

        RPG::SE.new("walk2", 60, rand(30) + 60).play

  end
end
#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================
class Game_Event < Game_Character
  alias ftstp_setup setup
  alias ftstp_ge_increase_steps increase_steps
  #--------------------------------------------------------------------------
  # * Event page setup
  #--------------------------------------------------------------------------
  def setup(new_page)
    ftstp_setup(new_page)
    if !@list.nil?
      for i in 0...@list.size - 1
        next if @list[i].code != 108
        if @list[i].parameters[0].include?("[footstepse:")
          cmd = @list[i].parameters[0].split(':')
          @custom_se_name=cmd.last if cmd.size>1 && /footstepse/===cmd.first
          @custom_se_name[-1, 1] = ""
          #list = @list[i].parameters[0].scan(/\[footstepse:([0-9]|[a-z]|[A-Z])+\]/)
          #p $1
          @footstep_se_custom = true
          #$1
        elsif @list[i].parameters[0].include?("[footstep]")
          #p "should work, right?"
          @footstep_se = true
        end
      end
    end
  end
  def footstep_se
    get_dist_vol
    play_se
  end
  def play_se
    if @footstep_se_custom
      RPG::SE.new(@custom_se_name, 80, rand(30) + 60).play
    elsif @footstep_se
      if Mm12::LADDER_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 2]))
        RPG::SE.new(Mm12::LADDER_SE[rand(Mm12::LADDER_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::BRIDGE_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0])) or Mm12::BRIDGE_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 2]))
        RPG::SE.new(Mm12::BRIDGE_SE[rand(Mm12::BRIDGE_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::CARPET_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::CARPET_SE[rand(Mm12::CARPET_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::DIRT_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::DIRT_SE[rand(Mm12::DIRT_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::GRASS_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::GRASS_SE[rand(Mm12::GRASS_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::ICE_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::ICE_SE[rand(Mm12::ICE_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::LAVA_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::LAVA_SE[rand(Mm12::LAVA_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::SAND_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::SAND_SE[rand(Mm12::SAND_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::STONE_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::STONE_SE[rand(Mm12::STONE_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::TGRASS_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::TGRASS_SE[rand(Mm12::TGRASS_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::WOOD_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::WOOD_SE[rand(Mm12::WOOD_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      elsif Mm12::SNOW_TILES.include?($game_map.tile_index($game_map.data[@x, @y, 0]))
        RPG::SE.new(Mm12::SNOW_SE[rand(Mm12::SNOW_SE.size-1)], rand(30) + 50, rand(30) + 80).play
      end
    end
  end
  def get_dist_vol
    @x_dist = $game_player.x - @x
    @y_dist = $game_player.y - @y
    @x_dist = @x_dist.abs
    @y_dist = @y_dist.abs
    @ttl_dist = Math.sqrt(@x_dist * @x_dist + @y_dist * @y_dist ).round
    #p @ttl_dist
    @dist_vol = 60
    @dist_vol2 = 20
    @dist_vol -= @ttl_dist*3
    @dist_vol += rand(30)
    if @dist_vol < 0
      @dist_vol = 0
    end
    #p @dist_vol
    @dist_vol2 -= @ttl_dist*2
    @dist_vol2 += rand(30)
    if @dist_vol2 < 0
      @dist_vol2 = 0
    end
    #p "Distance Volume: "+@dist_vol1.to_s
  end
  def increase_steps
    ftstp_ge_increase_steps
    footstep_se
  end
end
class Game_Map
  #--------------------------------------------------------------------------
  # * DerVVulfman's method L get_tile_index
  #--------------------------------------------------------------------------
  def tile_index(tile_id)
    case tile_id
      # Multi-tiled ids in Tileset 'A'
      when 2048..8191; return ((tile_id - 2000) / 48) - 1
      # Individual tile ids in Tileset 'A'
      when 1536..1663; return(tile_id - 1408)
      # Tilesets 'B' to 'E'
      when 0..1023; return (tile_id + 256)
    end
    return 0
  end
end