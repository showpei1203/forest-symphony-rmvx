# ASF A09-3 TEST-ONLY native RGSS2 frame capture bridge.
# Original Tankentai code and all original Graphics unchanged.
module ASF_A093
  ROOT = "A09_3_ENGINE_NATIVE"
  POSES = [
    ["actor01_7",0,-1],
    ["actor01_2",2,-1],
    ["actor01_2",0,2],
    ["actor01_7",1,-1],
    ["actor01_7",0,-1],
    ["actor01_1",0,-1],
    ["actor01_1",3,-1]
  ]
  def self.log(v)
    File.open("A09_3_ENGINE_TEST.log","ab") {|f| f.write(v.to_s + "\n")}
  rescue
  end
  def self.export_ppm(name, bitmap)
    path = ROOT + "/" + name
    File.open(path, "wb") do |f|
      f.write("P6\n#{bitmap.width} #{bitmap.height}\n255\n")
      y = 0
      while y < bitmap.height
        raw = ""
        x = 0
        while x < bitmap.width
          c = bitmap.get_pixel(x,y)
          raw << c.red.to_i.chr << c.green.to_i.chr << c.blue.to_i.chr
          x += 1
        end
        f.write(raw)
        y += 1
      end
    end
    log("PPM "+name+" "+bitmap.width.to_s+"x"+bitmap.height.to_s)
  end
  def self.run
    Dir.mkdir(ROOT) unless File.directory?(ROOT)
    log("A093_BRIDGE_STARTED")
    title = $data_system ? "DATA_SYSTEM_OK" : "NO_DATA_SYSTEM"
    log(title)
    bg = Sprite.new
    bg.bitmap = Bitmap.new(544,416)
    bg.bitmap.fill_rect(0,0,544,416,Color.new(235,241,245,255))
    bg.z = 20000
    persons = []
    7.times do |i|
      source,row,fixed = POSES[i]
      s = Sprite.new
      s.bitmap = Cache.character("$" + source)
      s.src_rect.set(0,row*32,32,32)
      s.x = 48 + 70*i
      s.y = 100
      s.ox = 16
      s.oy = 21
      s.z = 21000 + i
      persons.push(s)
      log("POSE "+i.to_s+" "+source+" ROW "+row.to_s+" FIXED "+fixed.to_s)
    end
    Graphics.transition(0)
    12.times { Graphics.update }
    shot1 = Graphics.snap_to_bitmap
    shot1a = Bitmap.new(544,140)
    shot1a.blt(0,0,shot1,Rect.new(0,0,544,140))
    export_ppm("vx_rgss2_first.ppm",shot1a)
    shot1a.dispose
    shot1.dispose
    persons.each_with_index do |s,i|
      source,row,fixed=POSES[i]
      col = fixed >= 0 ? fixed : 2
      s.src_rect.set(col*32,row*32,32,32)
    end
    15.times { Graphics.update }
    shot2 = Graphics.snap_to_bitmap
    shot2a = Bitmap.new(544,140)
    shot2a.blt(0,0,shot2,Rect.new(0,0,544,140))
    export_ppm("vx_rgss2_second.ppm",shot2a)
    shot2a.dispose
    shot2.dispose
    log("A093_BRIDGE_CAPTURED_ALL")
    persons.each {|s| s.dispose}
    bg.bitmap.dispose
    bg.dispose
    log("A093_BRIDGE_FINISHED")
  end
end

ASF_A093.log("ADAPTER_EVALUATED_BEFORE_MAIN")
begin
  ASF_A093.run
rescue Exception => e
  ASF_A093.log("ADAPTER_TOPLEVEL_FAIL " + e.class.to_s + ": " + e.message.to_s)
  ASF_A093.log(e.backtrace[0,8].join("|")) if e.backtrace
end

class Scene_Title
  alias asf_a093_original_start start
  def start
    asf_a093_original_start
    begin
      ASF_A093.run
    rescue Exception => e
      ASF_A093.log("A093_BRIDGE_FAIL "+e.class.to_s+": "+e.message.to_s)
      ASF_A093.log(e.backtrace[0,8].join("|")) if e.backtrace
    end
  end
end