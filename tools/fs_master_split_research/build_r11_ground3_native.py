#!/usr/bin/env python3
"""R11 genuine unmodified formal Map003 40x29 ground3 loaded in isolated VX Test Adapter.
Real original Map003 from K4 gets copied byte-for-byte as Map001 because harness currently hardcodes map ID1.
No K4 writes. Original 25 Events replaced by single test NPC; this is a TECH stress fixture, not full formal event acceptance.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import subprocess,hashlib,shutil,zlib,json
from PIL import Image
R=Path(__file__).resolve().parent
BASE=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
m=BASE/"Data"/"Map003.rvdata";formal=BASE/"Data"/"Scripts.rvdata"
assert hashlib.sha256(m.read_bytes()).hexdigest()=="118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4"
assert hashlib.sha256(formal.read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
src=R/"R10_COLLISION_NATIVE_CANDIDATE"/"FULL505"
dst=R/"R11_GROUND3_40x29_NATIVE"/"FULL505";dst.parent.mkdir(exist_ok=True)
a=subprocess.run(["robocopy",str(src),str(dst),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert a.returncode<8,a.stdout[-1000:]
shutil.copy2(m,dst/"Data"/"Map001.rvdata")
assert hashlib.sha256((dst/"Data"/"Map001.rvdata").read_bytes()).hexdigest()==hashlib.sha256(m.read_bytes()).hexdigest()
# remove R10 test flag, add R11-only path.
(dst/"ENABLE_R10_FORMAL_MAP050.flag").unlink(missing_ok=True)
(dst/"ENABLE_R9_WALK_TEST.flag").unlink(missing_ok=True)
(dst/"ENABLE_R11_GROUND3.flag").write_text("K4_ORIGINAL_MAP003_BINARY_EXACT_TEST",encoding="ascii")
# IMPORTANT: R8 overlays belong to SCENE21; blank them for ground3 native scale-only audit.
Image.new("RGBA",(1280,928),(0,0,0,0)).save(dst/"Overlays"/"Par1.png")
script=dst/"Data"/"Scripts.rvdata"
pages=load(script.open("rb"))
baseline=load(formal.open("rb"))
assert len(pages)==506 and all(pages[i if i<482 else i+1]==baseline[i] for i in range(505) if i!=480)
body=zlib.decompress(pages[482][2]).decode("ascii")
ext=r'''
module FSR11
 TESTS=[
  ["L01_CENTER_RIGHT",[20,10],"right",[21,10],true],
  ["L02_CENTER_DOWN_BLOCK",[20,10],"down",[20,10],false],
  ["L03_EAST_UPPER_RIGHT",[30,10],"right",[31,10],true],
  ["L04_EAST_MID_DOWN",[32,12],"down",[32,13],true],
  ["L05_WEST_WALK",[5,16],"right",[6,16],true],
  ["L06_WEST_BLOCK",[6,16],"up",[6,15],true],
  ["L07_SOUTH_RIGHT",[32,23],"right",[33,23],true],
  ["L08_SOUTH_WALK",[22,27],"right",[23,27],true],
  ["L09_SOUTH_BLOCK",[23,27],"down",[23,28],true],
  ["L10_LEFT_BORDER",[0,25],"left",[0,25],false]
 ]
 def self.log(s);File.open("R11_GROUND3_NATIVE.log","a"){|f|f.puts(s)};end
end
class Scene_Map
 alias r11_previous_update update
 def update
  r11_previous_update
  return unless FileTest.exist?("ENABLE_R11_GROUND3.flag")
  @r11_frame ||= 0; @r11_frame+=1
  if @r11_frame==30
   FSR11.log("R11_NATIVE_MAP_INFO dim="+$game_map.width.to_s+"x"+$game_map.height.to_s+
    " par="+$game_map.parallax_name.to_s+" bg_file_ground3="+FileTest.exist?("Graphics/Parallaxes/ground3.png").to_s)
   FSR6.set_mode(@spriteset,"A_STATIC")
  end
  FSR11::TESTS.each_with_index do |row,i|
   tag,from,action,expected,should_move=row
   start=90+i*105
   if @r11_frame==start
    $game_player.moveto(from[0],from[1]);$game_player.refresh
    $game_map.events[900].moveto(1,1)
    FSR11.log("R11_SET "+tag+" from="+from.inspect+
      " camera_before="+[$game_map.display_x,$game_map.display_y].inspect)
   elsif @r11_frame==start+29
    prev=[$game_player.x,$game_player.y]
    case action
    when "up";$game_player.move_up
    when "down";$game_player.move_down
    when "left";$game_player.move_left
    when "right";$game_player.move_right
    end
    now=[$game_player.x,$game_player.y]
    FSR11.log("R11_MOVE "+tag+" from="+prev.inspect+" to="+now.inspect+
     " want="+expected.inspect+" same="+(now==expected).to_s+
     " destination_pass_tile="+$game_map.data[expected[0],expected[1],2].to_s)
   elsif @r11_frame==start+60
    now=[$game_player.x,$game_player.y]
    FSR11.log("R11_SHOT "+tag+" player="+now.inspect+
     " camera="+[$game_map.display_x,$game_map.display_y].inspect+
     " complete=true")
   end
  end
  if @r11_frame==90+FSR11::TESTS.size*105
   FSR11.log("R11_ALL_CASES_DONE count="+FSR11::TESTS.size.to_s)
  end
 end
end
'''
body+=ext
pages[482][2]=zlib.compress(body.encode("ascii"))
with script.open("wb") as f:write(f,pages)
again=load(script.open("rb"))
assert all(again[i if i<482 else i+1]==baseline[i] for i in range(505) if i!=480)
ini=dst/"Game.ini";x=ini.read_bytes()
assert b"Title=FS_R10_COLLISION_CANDIDATE" in x
ini.write_bytes(x.replace(b"Title=FS_R10_COLLISION_CANDIDATE",b"Title=FS_R11_GROUND3_40x29"))
(dst/"R11_GROUND3_NATIVE.log").write_text("R11_BOOT\n",encoding="ascii")
meta={"status":"R11_LARGE_ORIGINAL_MAP003_ISOLATED_READY_NOT_NATIVE",
 "ground3_original_size_px":[1280,928],"map":40,"map_original_tile_dims":[40,29],
 "original_map003_sha256":hashlib.sha256(m.read_bytes()).hexdigest(),
 "original_map_file_byte_identical_in_isolated":True,
 "all_original_25_map_events_loaded":False,"actual_original_events_discarded_by_existing_test_harness":True,
 "r10_artwork_active":"R8_SCENE21_OBJECT_LAYERS_NOT_SUITABLE_FOR_GROUND3; NO_FORMAL_PAR_ALIGNMENT_CLAIM",
 "script_original_504_preserved":True,"original_page480_disabled_in_isolation":True,
 "formal_project_untouched":True,"ten_player_one-step_camera_cases":10,
 "art_gate_F":False}
(dst.parent/"R11_GROUND3_BUILD.json").write_text(json.dumps(meta,indent=2),encoding="utf8")
print("R11_GROUND3_BUILD",json.dumps(meta,ensure_ascii=False),flush=True)