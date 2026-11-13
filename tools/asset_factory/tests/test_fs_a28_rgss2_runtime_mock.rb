require 'minitest/autorun'

class Color
  attr_reader :alpha,:red,:green,:blue
  def initialize(r=0,g=0,b=0,a=0)
    @red,@green,@blue,@alpha=r,g,b,a
  end
end
class Bitmap
  attr_reader :width,:height, :set_count
  def initialize(w,h)
    @width,@height=w,h
    @data={}
    @disposed=false
    @set_count=0
  end
  def get_pixel(x,y)
    @data[[x,y]] || Color.new
  end
  def set_pixel(x,y,color)
    @data[[x,y]]=color
    @set_count+=1
  end
  def clear;@data.clear;end
  def dispose;@disposed=true;end
  def disposed?;@disposed;end
end
class Rect
  attr_accessor :x,:y,:width,:height
  def initialize(x,y,w,h);@x,@y,@width,@height=x,y,w,h;end
end
class Sprite
  attr_accessor :bitmap,:x,:y,:z,:ox,:oy,:zoom_x,:zoom_y,:visible,:opacity,:src_rect,:viewport
  def initialize(viewport=nil)
    @viewport=viewport
    @x,@y,@z,@ox,@oy=0,0,0,0,0
    @zoom_x,@zoom_y=1.0,1.0
    @opacity=255
    @visible=true
    @disposed=false
  end
  def dispose;@disposed=true;end
  def disposed?;@disposed;end
end
class FakeCharacter
  attr_accessor :tile_id
  def initialize;@tile_id=0;end
end
class Sprite_Character < Sprite
  attr_reader :original_updates
  def initialize(viewport=nil)
    super(viewport)
    @character=FakeCharacter.new
    @x,@y,@ox,@oy,@z=4,8,4,8,30
    @bitmap=Bitmap.new(8,8)
    @src_rect=Rect.new(0,0,8,8)
    8.times{|y|8.times{|x|@bitmap.set_pixel(x,y,Color.new(255,255,255,255))}}
    @original_updates=0
  end
  def update;@original_updates+=1;end
end
class GameMapMock
  attr_accessor :map_id,:display_x,:display_y
  def initialize;@map_id,@display_x,@display_y=1,0,0;end
end
$game_map=GameMapMock.new
module Cache
  @map={}
  @count=0
  def self.parallax(name)
    @count+=1
    @map[name]
  end
  def self.install(name,bitmap);@map[name]=bitmap;end
  def self.count;@count;end
end

load File.expand_path('fs_a28_rgss2_actor_occlusion.rb',File.dirname(__FILE__))
class TestRGSS2AdapterHook < Minitest::Test
  def setup
    @old_enabled=FS_A28_Occlusion::ENABLED
    @old_mapid=FS_A28_Occlusion::MAP_ID
    @old_objects=FS_A28_Occlusion::OBJECTS
    FS_A28_Occlusion.send(:remove_const,:ENABLED)
    FS_A28_Occlusion.const_set(:ENABLED,true)
    FS_A28_Occlusion.send(:remove_const,:MAP_ID)
    FS_A28_Occlusion.const_set(:MAP_ID,1)
    FS_A28_Occlusion.send(:remove_const,:OBJECTS)
    FS_A28_Occlusion.const_set(:OBJECTS,[["MOCK",0,0,8,8,1,9,0,8]])
    mask=Bitmap.new(8,8)
    mask.set_pixel(4,6,Color.new(12,24,36,255))
    Cache.install('MOCK',mask)
    $game_map.map_id=1
    $game_map.display_x=0
    $game_map.display_y=0
    @character=Sprite_Character.new(:viewport)
  end
  def teardown
    @character.dispose unless @character.disposed?
    {'ENABLED'=>@old_enabled,'MAP_ID'=>@old_mapid,'OBJECTS'=>@old_objects}.each do |name,v|
      FS_A28_Occlusion.send(:remove_const,name)
      FS_A28_Occlusion.const_set(name,v)
    end
  end
  def overlay;@character.instance_variable_get(:@fs_a28_overlay);end
  def test_first_update_creates_aligned_overlay
    @character.update
    refute_nil overlay
    assert_equal [4,8,31,4,8], [overlay.x,overlay.y,overlay.z,overlay.ox,overlay.oy]
    assert_equal 255,overlay.bitmap.get_pixel(4,6).alpha
    assert_equal 1,@character.original_updates
  end
  def test_scrolling_keeps_pixel_crop_in_world_position
    @character.update
    old=Cache.count
    $game_map.display_x=256
    @character.x=-28
    @character.update
    assert_equal(-28,overlay.x)
    assert_equal 255,overlay.bitmap.get_pixel(4,6).alpha
    assert_equal old,Cache.count
  end
  def test_map_switch_disables_overlay_without_modifying_original
    @character.update
    $game_map.map_id=2
    @character.update
    assert_equal false,overlay.visible
    assert_equal 2,@character.original_updates
  end
  def test_tile_graphics_do_not_crash
    @character.update
    @character.instance_variable_get(:@character).tile_id=3
    @character.update
    assert_equal false,overlay.visible
  end
  def test_dispose_frees_owned_bitmap
    @character.update
    bmp=overlay.bitmap
    spr=overlay
    @character.dispose
    assert bmp.disposed?
    assert spr.disposed?
    assert @character.disposed?
  end
  def test_inactive_state_avoids_new_bitmap
    $game_map.map_id=2
    @character.update
    assert_nil overlay
  end
end
