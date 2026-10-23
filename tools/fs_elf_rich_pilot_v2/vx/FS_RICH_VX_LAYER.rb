# TEST-ONLY RPG Maker VX/RGSS2 adapter. No sealed FS files are edited.
module FSRich
  WIDTH = 27
  HEIGHT = 20
  SOURCE_SHA = "__MANIFEST_SHA__"
  OBJECTS = __OBJECTS__
  BLOCKED = __BLOCKED__
  EVENTS = __EVENTS__
  SPAWN = [13,17]
  def self.log(line)
    File.open("FS_RICH_VX_LOG.txt","a") {|f| f.puts line }
  end
end
FSRich.log("RICH_SCRIPT_LOADED sha="+FSRich::SOURCE_SHA)
class Game_Map
  alias fs_source_width width
  alias fs_source_height height
  def width;FSRich::WIDTH;end
  def height;FSRich::HEIGHT;end
  def set_display_pos(x,y)
    @display_x = [[x,0].max,(FSRich::WIDTH-17)*256].min
    @display_y = [[y,0].max,(FSRich::HEIGHT-13)*256].min
    @parallax_x = @display_x
    @parallax_y = @display_y
  end
end

class Game_Character
  alias fs_native_passable passable?
  def passable?(x,y)
    if self.equal?($game_player)
      return false unless (0<=x && x<FSRich::WIDTH && 0<=y && y<FSRich::HEIGHT)
      return false if FSRich::BLOCKED.include?([x,y])
      return true
    end
    fs_native_passable(x,y)
  end
end

class Sprite_Character
  alias fs_native_dynamic_update update
  def update
    fs_native_dynamic_update
    if @character.equal?($game_player)
      self.z = $game_player.y*32+32
    end
  end
end

class Scene_Title
  alias fs_native_title_update update
  def update
    unless @fs_map_started
      @fs_map_started = true
      $game_party.setup_starting_members
      $game_map.setup(1)
      $game_player.moveto(FSRich::SPAWN[0],FSRich::SPAWN[1])
      $game_player.refresh
      $game_map.set_display_pos(3*256,7*256)
      FSRich.log("RICH_VX_BOOT spawn="+FSRich::SPAWN.inspect)
      $scene = Scene_Map.new
      return
    end
    fs_native_title_update
  end
end
class Spriteset_Map
  alias fs_native_initialize initialize
  alias fs_native_update update
  alias fs_native_dispose dispose
  def initialize
    fs_native_initialize
    @fs_ground = Sprite.new(@viewport1)
    @fs_ground.bitmap = Cache.picture("FS_ELF_RICH_Ground")
    @fs_ground.z = 1
    @fs_objects = []
    FSRich::OBJECTS.each do |ob|
      sp = Sprite.new(@viewport1)
      sp.bitmap = Cache.picture("FSOBJ_"+ob[1])
      sp.z = ob[4]
      @fs_objects.push([sp,ob])
    end
    @fs_frame = 0
    FSRich.log("RICH_VX_LAYERS ground=864x640 props="+@fs_objects.size.to_s)
  end
  def update
    fs_native_update
    if @fs_objects
      offx = $game_map.display_x / 8
      offy = $game_map.display_y / 8
      @fs_ground.x = -offx
      @fs_ground.y = -offy
      @fs_objects.each do |pair|
        sp,ob = pair
        sp.x = ob[2]-offx
        sp.y = ob[3]-offy
      end
      @fs_frame += 1
      if @fs_frame == 12
        FSRich.log("RICH_CAMERA offset="+offx.to_s+","+offy.to_s+" world=864x640")
      end
      if @fs_frame == 22
        FSRich.run_test_logic
      end
      if @fs_frame == 100
        FSRich.log("RICH_RUNTIME_100_FRAMES player="+$game_player.x.to_s+","+$game_player.y.to_s)
      end
    end
  end
  def dispose
    if @fs_objects
      @fs_objects.each {|pair| pair[0].dispose unless pair[0].disposed? }
      @fs_objects=nil
    end
    @fs_ground.dispose if @fs_ground and !@fs_ground.disposed?
    fs_native_dispose
  end
end

class Scene_Map
  alias fs_native_scene_map_update update
  def update
    fs_native_scene_map_update
    if Input.trigger?(Input::C)
      ev = FSRich.near_event
      FSRich.log("RICH_PLAYER_INTERACT="+ev.to_s) if ev
    end
  end
  def update_call_menu
    # Isolated test map: disable stock RPG menu to keep interactions deterministic.
  end
end
module FSRich
  def self.near_event
    px=$game_player.x*32+16
    py=$game_player.y*32+32
    EVENTS.each do |ev|
      dx=px-ev[1];dy=py-ev[2]
      return ev[0] if dx*dx+dy*dy <= 65*65
    end
    nil
  end
  def self.run_test_logic
    $game_player.moveto(SPAWN[0],SPAWN[1])
    $game_player.move_up
    walk=($game_player.y==SPAWN[1]-1)
    blocked=false
    BLOCKED.each do |b|
      bx,by=b
      if by+1<HEIGHT && !BLOCKED.include?([bx,by+1])
        $game_player.moveto(bx,by+1)
        $game_player.move_up
        blocked=($game_player.y==by+1)
        break
      end
    end
    events_pass=true
    labels=[]
    EVENTS.each do |ev|
      $game_player.moveto(ev[1]/32,ev[2]/32)
      hit=near_event
      labels.push(ev[0]+"="+(hit==ev[0]).to_s)
      events_pass=false unless hit==ev[0]
    end
    $game_map.set_display_pos(10*256,7*256)
    camera=($game_map.display_x/8==320 && $game_map.display_y/8==224)
    $game_map.set_display_pos(3*256,7*256)
    $game_player.moveto(SPAWN[0],SPAWN[1])
    depths=OBJECTS.map{|x| x[4]}.uniq.size>6
    ok=walk && blocked && events_pass && camera && depths
    log("RICH_VX_GATES move="+walk.to_s+" blocked="+blocked.to_s+
      " events="+events_pass.to_s+" camera="+camera.to_s+" depth="+depths.to_s)
    log("RICH_EVENTS "+labels.join(","))
    log(ok ? "RICH_VX_RUNTIME_GATE_PASS" : "RICH_VX_RUNTIME_GATE_FAIL")
  end
end
