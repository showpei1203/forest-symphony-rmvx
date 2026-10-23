# encoding: utf-8
# TEST-ONLY: forest ground/par/occlusion/collision; no edits to source Forest Symphony.
module FSForest
  WIDTH = 17
  HEIGHT = 13
  TREES = [[80,70,64,43,134],[385,82,61,43,146],[92,284,64,43,348]]
  BLOCKED = __BLOCKED__
  def self.log(msg)
    File.open("FS_VX_TEST_LOG.txt", "a") {|f| f.puts msg }
  end
end
FSForest.log("FS_TEST_SCRIPT_LOADED")

class Scene_Title
  alias fs_original_title_start start
  def start
    FSForest.log("FS_TITLE_START")
    fs_original_title_start
  end
  alias fs_original_title_update update
  def update
    unless @fs_start_once
      @fs_start_once = true
      FSForest.log("FS_TITLE_UPDATE")
      $game_party.setup_starting_members
      $game_map.setup(1)
      $game_player.moveto(8, 11)
      $game_player.refresh
      $game_map.set_display_pos(0, 0)
      FSForest.log("VX_TEST_BOOT map=1 player=8,11")
      $scene = Scene_Map.new
      return
    end
    fs_original_title_update
  end
end

class Game_Character
  alias fs_original_passable_question passable?
  def passable?(x,y)
    if self.equal?($game_player)
      return false unless x >= 0 && x < FSForest::WIDTH && y >= 0 && y < FSForest::HEIGHT
      if FSForest::BLOCKED.include?([x,y])
        FSForest.log("BLOCKED tile=#{x},#{y}")
        return false
      end
      return true  # TEST-ONLY: standalone map owns passability via manifest-derived blocked tiles
    end
    fs_original_passable_question(x,y)
  end
end

class Game_Map
  alias fs_original_scroll_down scroll_down
  alias fs_original_scroll_left scroll_left
  alias fs_original_scroll_right scroll_right
  alias fs_original_scroll_up scroll_up
  def scroll_down(distance);end
  def scroll_left(distance);end
  def scroll_right(distance);end
  def scroll_up(distance);end
end

class Spriteset_Map
  alias fs_original_initialize initialize
  alias fs_original_update update
  alias fs_original_dispose dispose

  def initialize
    fs_original_initialize
    @fs_sprites = []
    @fs_ground = Sprite.new(@viewport1)
    @fs_ground.bitmap = Cache.picture("FS_FOREST_V32_Ground")
    @fs_ground.z = 10 # higher than stock VX Tilemap (0), lower than ParBase/player
    @fs_ground.x = 0
    @fs_ground.y = 0
    @fs_sprites.push(@fs_ground)
    @fs_base = Sprite.new(@viewport1)
    @fs_base.bitmap = Cache.picture("FS_FOREST_V32_Par_BASE")
    @fs_base.z = 80
    @fs_sprites.push(@fs_base)
    FSForest::TREES.each_with_index do |tree,i|
      canopy = Sprite.new(@viewport1)
      canopy.bitmap = Cache.picture("FS_TREE_OCCLUSION_"+(i+1).to_s)
      canopy.x = tree[0]
      canopy.y = tree[1]
      canopy.z = 200
      @fs_sprites.push(canopy)
    end
    FSForest.log("VX_LAYERS_CREATED ground=544x416 par_base=544x416 trees=3")
    @fs_frame=0
  end

  def update
    fs_original_update
    if @fs_sprites
      py = $game_player.y*32+32
      FSForest::TREES.each_with_index do |tree,i|
        @fs_sprites[i+2].z = (py <= tree[4]) ? 200 : 70
      end
      @fs_frame += 1
      if @fs_frame == 10
        FSForest.log("VX_RUNTIME_FRAME_10 player=#{$game_player.x},#{$game_player.y} canopy_z=#{@fs_sprites[2].z},#{@fs_sprites[3].z},#{@fs_sprites[4].z}")
      end
      if @fs_frame == 16
        collision_blocked = !$game_player.passable?(3,3)
        path_passable = $game_player.passable?(8,11)
        $game_player.moveto(3,2)
        @fs_sprites[2].z = ($game_player.y*32+32 <= FSForest::TREES[0][4]) ? 200 : 70
        canopy_behind = (@fs_sprites[2].z == 200)
        $game_player.moveto(3,7)
        @fs_sprites[2].z = ($game_player.y*32+32 <= FSForest::TREES[0][4]) ? 200 : 70
        canopy_front = (@fs_sprites[2].z == 70)
        $game_player.moveto(8,11)
        FSForest::TREES.each_with_index do |tree,i|
          @fs_sprites[i+2].z = ($game_player.y*32+32 <= tree[4]) ? 200 : 70
        end
        ok = collision_blocked && path_passable && canopy_behind && canopy_front
        FSForest.log("VX_GATE_F_LOGIC collision=#{collision_blocked} route=#{path_passable} behind=#{canopy_behind} front=#{canopy_front}")
        FSForest.log(ok ? "VX_GATE_F_LOGIC_PASS" : "VX_GATE_F_LOGIC_FAIL")
      end
      if @fs_frame == 24
        $game_player.moveto(8,11)
        $game_player.move_up
        walked = ($game_player.y == 10)
        $game_player.moveto(3,4)
        $game_player.move_up
        stopped = ($game_player.y == 4)
        $game_player.moveto(8,11)
        FSForest.log("VX_MOVEMENT_GATES walk=#{walked} blocked_walk=#{stopped}")
        FSForest.log((walked && stopped) ? "VX_MOVEMENT_GATES_PASS" : "VX_MOVEMENT_GATES_FAIL")
      end
      if @fs_frame == 100
        FSForest.log("VX_RUNTIME_FRAME_100 player=#{$game_player.x},#{$game_player.y}")
      end
    end
  end

  def dispose
    if @fs_sprites
      @fs_sprites.each {|sprite| sprite.dispose unless sprite.disposed? }
      @fs_sprites = nil
    end
    fs_original_dispose
  end
end

# TEST-ONLY: prevent external keyboard ESC from opening VX menu during visual QA.
class Scene_Map
  def update_call_menu
  end
end
