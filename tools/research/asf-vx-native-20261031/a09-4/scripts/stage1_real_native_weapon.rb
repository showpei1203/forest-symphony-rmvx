# A09-4 isolated VX RGSS2 native Sprite_Weapon probe.
# Run ONLY on cloned N5_B0 candidate. Uses actual weapon #2 from Weapons.rvdata.
module ASF_A094
  LOG = "ASF_A094_DIAGNOSTIC.log"
  OUT = "ASF_A094_NATIVE_PROOFS"
  def self.log(s)
    File.open(LOG,"ab") {|f| f.write(s.to_s + "\n")}
  rescue
  end
  class Proxy
    attr_accessor :position_x, :position_y, :position_z
    def initialize(x,y,z)
      @position_x=x;@position_y=y;@position_z=z
    end
    def actor?; true; end
    def weapons; [$data_weapons[2],nil]; end
  end
  def self.export_crop(file,bmp,left,top,w,h)
    File.open(OUT+"/"+file,"wb") do |f|
      f.write("P6\n"+w.to_s+" "+h.to_s+"\n255\n")
      h.times do |y|
        line=""
        w.times do |x|
          px=bmp.get_pixel(left+x,top+y)
          line << px.red.to_i.chr << px.green.to_i.chr << px.blue.to_i.chr
        end
        f.write(line)
      end
    end
    log("PNG_EQUIV_PPM="+file)
  end
end
ASF_A094.log("A094_SCRIPT_EVALUATED")
class Scene_Title
  alias asf_a094_orig_title_update update
  def update
    unless @asf_a094_title_seen
      @asf_a094_title_seen=true
      ASF_A094.log("A094_TITLE_UPDATE_ENTERED")
    end
    asf_a094_orig_title_update
  end
end
class Spriteset_Map
  alias asf_a094_orig_map_initialize initialize
  alias asf_a094_orig_map_update update
  alias asf_a094_orig_map_dispose dispose
  def initialize
    asf_a094_orig_map_initialize
    @a094_frame=0
    @a094_weapons=[]
    @a094_actors=[]
    @a094_bg=nil
    return unless $game_map.map_id==900
    begin
      Dir.mkdir(ASF_A094::OUT) unless File.directory?(ASF_A094::OUT)
      @a094_bg=Sprite.new(@viewport1)
      @a094_bg.bitmap=Bitmap.new(544,176)
      @a094_bg.bitmap.fill_rect(0,0,544,176,Color.new(237,242,246,255))
      @a094_bg.y=55
      @a094_bg.z=1500
      setups=[["p01","$actor01_2",2,"喬伊普攻武器"],
              ["p03","$actor01_7",1,"喬伊普攻武器2"],
              ["p05","$actor01_1",0,"正常武器待機"]]
      setups.each_with_index do |item,i|
        x=90+i*180;y=145
        proxy=ASF_A094::Proxy.new(x,y,2000)
        actor=Sprite.new(@viewport1)
        actor.bitmap=Cache.character(item[1])
        actor.src_rect.set(32,item[2]*32,32,32)
        actor.x=x;actor.y=y;actor.ox=16;actor.oy=21;actor.z=2000
        weapon=Sprite_Weapon.new(@viewport1,proxy)
        ASF_A094.log("A094_SOURCE_ICON="+$data_weapons[2].icon_index.to_s+" profile="+item[0])
        weapon.weapon_action(item[3],2)
        weapon.update
        @a094_actors << actor
        @a094_weapons << weapon
      end
      ASF_A094.log("A094_SPRITES_CREATED count="+@a094_weapons.size.to_s)
    rescue Exception => e
      ASF_A094.log("A094_INIT_FAIL "+e.class.to_s+": "+e.message.to_s)
      ASF_A094.log(e.backtrace[0,5].join("|")) if e.backtrace
    end
  end
  def update
    asf_a094_orig_map_update
    return unless $game_map.map_id==900 && @a094_weapons && @a094_weapons.size==3
    @a094_frame+=1
    if @a094_frame==35
      ASF_A094.log("A094_MAP_FRAME_35")
    end
    # Exact native Sprite_Weapon 4 action ticks, spaced so screenshot reads the prior render.
    if @a094_frame>=40 && @a094_frame<=73
      stage=@a094_frame-40
      tick=stage/8
      sub=stage%8
      if tick<4 && sub==0
        @a094_weapons.each_with_index do |wp,i|
          begin
            wp.action
            wp.update
            ASF_A094.log("A094_WPN i="+i.to_s+" tick="+tick.to_s+
              " angle="+wp.angle.to_s+" x="+wp.x.to_s+" y="+wp.y.to_s+
              " z="+wp.z.to_s+" ox="+wp.ox.to_s+" oy="+wp.oy.to_s+
              " mirror="+wp.mirror.to_s+" icon="+wp.src_rect.x.to_s+","+wp.src_rect.y.to_s)
          rescue Exception => e
            ASF_A094.log("A094_TICK_FAIL "+e.class.to_s+":"+e.message.to_s)
          end
        end
      end
      if tick<4 && sub==2
        begin
          bmp=Graphics.snap_to_bitmap
          @a094_weapons.each_with_index do |wp,i|
            x=90+i*180
            ASF_A094.export_crop("weapon_"+i.to_s+"_tick_"+tick.to_s+".ppm",bmp,x-45,90,90,105)
          end
          bmp.dispose
        rescue Exception => e
          ASF_A094.log("A094_SNAP_FAIL "+e.class.to_s+":"+e.message.to_s)
        end
      end
      ASF_A094.log("A094_CAPTURE_DONE") if @a094_frame==73
    end
  end
  def dispose
    if @a094_weapons
      @a094_weapons.each {|w|w.dispose unless w.disposed?}
    end
    if @a094_actors
      @a094_actors.each {|a|a.dispose unless a.disposed?}
    end
    if @a094_bg && !@a094_bg.disposed?
      @a094_bg.bitmap.dispose if @a094_bg.bitmap
      @a094_bg.dispose
    end
    asf_a094_orig_map_dispose
  end
end