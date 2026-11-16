# FS A28 Ruby RGSS2 adapter mock tests. No proprietary RGSS engine required.
require 'minitest/autorun'
require 'digest'
require 'json'

class FSColor
  attr_accessor :red, :green, :blue, :alpha
  def initialize(r=0,g=0,b=0,a=0)
    @red,@green,@blue,@alpha = r,g,b,a
  end
  def bytes
    [@red,@green,@blue,@alpha].pack('C4')
  end
end

class FSRect
  attr_accessor :x,:y,:width,:height
  def initialize(x,y,w,h)
    @x,@y,@width,@height=x,y,w,h
  end
end

class FSBitmap
  attr_reader :width,:height
  def initialize(w,h,pixels=nil)
    @width,@height=w,h
    @pixels=pixels||{}
    @disposed=false
  end
  def get_pixel(x,y)
    return FSColor.new if x<0 || y<0 || x>=@width || y>=@height
    @pixels[y*@width+x] || FSColor.new
  end
  def set_pixel(x,y,c)
    raise 'bounds' if x<0 || y<0 || x>=@width || y>=@height
    @pixels[y*@width+x]=c
  end
  def clear
    @pixels.clear
  end
  def raw_rgba
    out=''.b
    @height.times do |y|
      @width.times do |x|
        out << get_pixel(x,y).bytes
      end
    end
    out
  end
  def dispose; @disposed=true; end
  def disposed?; @disposed; end
end

# Load WITHOUT Sprite_Character in scope for pure paint! unit tests.
load File.expand_path('fs_a28_rgss2_actor_occlusion.rb',File.dirname(__FILE__))

class TestA28Pure < Minitest::Test
  def setup
    @dest=FSBitmap.new(8,8)
    @actor=FSBitmap.new(8,8)
    8.times {|y| 8.times {|x| @actor.set_pixel(x,y,FSColor.new(220,220,220,255)) }}
    @mask=FSBitmap.new(8,8)
    @mask.set_pixel(4,2,FSColor.new(7,27,57,255))
    @mask.set_pixel(5,6,FSColor.new(19,39,59,255))
    @orig=FS_A28_Occlusion::OBJECTS
    FS_A28_Occlusion.send(:remove_const,:OBJECTS)
    FS_A28_Occlusion.const_set(:OBJECTS,[["test",0,0,8,8,1,9,0,8]])
  end
  def teardown
    FS_A28_Occlusion.send(:remove_const,:OBJECTS)
    FS_A28_Occlusion.const_set(:OBJECTS,@orig)
  end
  def render(foot=3)
    FS_A28_Occlusion.paint!(@dest,@actor,FSRect.new(0,0,8,8),0,0,foot,proc{|_|@mask})
  end
  def test_source_exact_rgba; render; assert_equal [7,27,57,255],vals(@dest.get_pixel(4,2)); end
  def test_source_at_bottom_exact; render; assert_equal [19,39,59,255],vals(@dest.get_pixel(5,6)); end
  def test_actor_front_no_overlay; render(11); assert_equal 0,@dest.raw_rgba.bytes.sum; end
  def test_clear_in_each_render; render(4); render(11); assert_equal 0,@dest.raw_rgba.bytes.sum; end
  def test_alpha_cut; @actor.set_pixel(4,2,FSColor.new); render; assert_equal 0,@dest.get_pixel(4,2).alpha; end
  def test_source_transparent; render; assert_equal 0,@dest.get_pixel(0,1).alpha; end
  def test_depth_edge; render(5); assert_equal 0,@dest.get_pixel(4,2).alpha; assert_equal 255,@dest.get_pixel(5,6).alpha; end
  def test_bad_dims_fail; assert_raises(RuntimeError) { FS_A28_Occlusion.paint!(@dest,@actor,FSRect.new(0,0,8,8),0,0,4,proc{|_|FSBitmap.new(7,8)}) }; end
  def test_offscreen_avoids_loading; FS_A28_Occlusion.paint!(@dest,@actor,FSRect.new(0,0,8,8),30,30,4,proc{|_|raise 'bad call'}); assert_equal 0,@dest.raw_rgba.bytes.sum; end
  def test_bad_geom_fail; FS_A28_Occlusion.send(:remove_const,:OBJECTS); FS_A28_Occlusion.const_set(:OBJECTS,[["bad",0,0,8,8,9,1,0,8]]); assert_raises(RuntimeError) { render }; end
  def test_optin_disabled; refute FS_A28_Occlusion.active?; end
  def test_outside_actor_source_empty; FS_A28_Occlusion.paint!(@dest,@actor,FSRect.new(0,0,8,8),0,7,4,proc{|_|@mask}); assert_equal 0,@dest.raw_rgba.bytes.sum; end
  def vals(c); [c.red,c.green,c.blue,c.alpha]; end
end

# Private real-image fixture is optional; never commit this JSON to a public GitHub repo.
class TestRealPrivateFixture < Minitest::Test
  def test_four_actual_fs_source_cases_when_available
    path=ENV['FS_A28_PRIVATE_FIXTURE']
    skip 'private fixture only in isolated Drive/local execution' if path.nil? || !File.file?(path)
    data=JSON.parse(File.read(path))
    assert_equal 'FS_A28_PRIVATE_PIXEL_PARITY',data['schema']
    data['cases'].each do |tc|
      bmp=FSBitmap.new(48,48)
      actor=FSBitmap.new(48,48)
      tc['actor_alpha'].each_with_index do |line,y|
        line.each_char.with_index {|a,x| actor.set_pixel(x,y,FSColor.new(255,255,255,255)) if a=='1'}
      end
      sources={}
      tc['object_patches'].each do |name, patch|
        layer=FS_A28_Occlusion::OBJECTS.find{|v|v[0]==name}
        raise 'no object layer' if layer.nil?
        bitmap=FSBitmap.new(layer[3],layer[4])
        patch.each do |p|
          bitmap.set_pixel(p[0],p[1],FSColor.new(p[2],p[3],p[4],p[5]))
        end
        sources[name]=bitmap
      end
      FS_A28_Occlusion.paint!(bmp,actor,FSRect.new(0,0,48,48),tc['top'][0],tc['top'][1],tc['foot'][1],proc{|name|sources[name]})
      assert_equal tc['expected_raw_sha256'],Digest::SHA256.hexdigest(bmp.raw_rgba),tc['case']
      assert_equal tc['expected_alpha_pixels'],bmp.raw_rgba.bytes.each_slice(4).count{|e|e[3]>0},tc['case']
    end
  end
end
