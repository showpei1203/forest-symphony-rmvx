#!/usr/bin/env python3
"""R10 exact ORIGINAL FS Map050.rvd layer data, isolated under Map001 harness ID.
THIS IS NOT formal event gameplay: R5 test harness replaces map events with NPC900.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import zlib,hashlib,subprocess,shutil,json
R=Path(__file__).resolve().parent
OFFICIAL=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
formal_script=OFFICIAL/"Data"/"Scripts.rvdata"
assert hashlib.sha256(formal_script.read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
src=R/"R9_NATIVE_WALKING_ISOLATED"/"FULL505"
dst=R/"R10_ORIGINAL_MAP050_NATIVE"/"FULL505";dst.parent.mkdir(exist_ok=True)
res=subprocess.run(["robocopy",str(src),str(dst),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert res.returncode<8,res.stdout[-800:]
map_src=OFFICIAL/"Data"/"Map050.rvdata"
map_tgt=dst/"Data"/"Map001.rvdata"
shutil.copy2(map_src,map_tgt)
assert hashlib.sha256(map_src.read_bytes()).hexdigest()==hashlib.sha256(map_tgt.read_bytes()).hexdigest()
a=load((dst/"Data"/"Scripts.rvdata").open("rb"));b=load(formal_script.open("rb"))
assert len(a)==506 and all(a[i if i<482 else i+1]==b[i] for i in range(505) if i!=480)
s=zlib.decompress(a[482][2]).decode("ascii")
# R10 extension only enabled by flag, original R9 extension flag explicitly removed.
ex=r'''
# R10 read-only formal Map050 data copied byte-exact as Map001 isolated harness map.
module FSR10
 TESTS=[
  ["F01_MAP050_TREE_DOWN",[13,3],"down",[13,3],false],
  ["F02_MAP050_TREE_FRONT",[13,4],"down",[13,4],false],
  ["F03_MAP050_BUSH_LEFT",[3,8],"left",[3,8],false],
  ["F04_MAP050_BUSH_RIGHT",[2,8],"right",[2,8],false],
  ["F05_MAP050_STEPS_DOWN",[9,5],"down",[9,5],false],
  ["F06_MAP050_PREVIOUS_BLOCK_UP",[5,7],"up",[5,7],false],
  ["F07_MAP050_PREVIOUS_BLOCK_LEFT",[6,6],"left",[6,6],false],
  ["F08_MAP050_BOUNDARY_LEFT",[0,4],"left",[0,4],false],
  ["F09_MAP050_BOUNDARY_UP",[1,0],"up",[1,0],false],
  ["F10_MAP050_NPC_MOVE",[12,7],"npc_down",[12,7],false]
 ]
 def self.log(s)
  File.open("R10_FORMAL_MAP050_NATIVE.log","a"){|f|f.puts(s)}
 end
end
class Scene_Map
 alias r10_previous_update update
 def update
   r10_previous_update
   return unless FileTest.exist?("ENABLE_R10_FORMAL_MAP050.flag")
   @r10_count ||= 0
   @r10_count+=1
   if @r10_count==30
     FSR6.set_mode(@spriteset,"B_DYNAMIC")
     FSR10.log("R10_MAP_INFO mapid="+$game_map.map_id.to_s+
       " dims="+$game_map.width.to_s+"x"+$game_map.height.to_s+
       " par="+$game_map.parallax_name.to_s+
       " tiles_5_6="+$game_map.data[5,6,2].to_s+
       " tiles_9_6="+$game_map.data[9,6,2].to_s+
       " mapPass_5_6="+$game_map.passable?(5,6).to_s+
       " mapPass_9_6="+$game_map.passable?(9,6).to_s)
   end
   FSR10::TESTS.each_with_index do |r,i|
     tag,from,act,want,shouldmove=r
     start=95+i*110
     npc=$game_map.events[900]
     if @r10_count==start
       $game_player.moveto(from[0],from[1]);$game_player.refresh
       npc.moveto(12,6);npc.refresh
       npc.instance_variable_set(:@through,false)
       $game_map.set_display_pos(0,0)
       FSR10.log("R10_START "+tag+" from="+from.inspect+" npc="+[npc.x,npc.y].inspect)
     elsif @r10_count==start+25
       subject=(act=="npc_down") ? npc : $game_player
       prev=[subject.x,subject.y]
       if act=="up";subject.move_up
       elsif act=="down";subject.move_down
       elsif act=="left";subject.move_left
       elsif act=="right";subject.move_right
       elsif act=="npc_down";subject.move_down
       end
       result=[subject.x,subject.y]
       expected=(act=="npc_down") ? [12,6] : want
       valid=(result==expected)
       @r10_results ||= {}
       @r10_results[tag]=valid
       FSR10.log("R10_ACTUAL "+tag+" action="+act+
         " from="+prev.inspect+" to="+result.inspect+
         " expected="+expected.inspect+" pass="+valid.to_s+
         " originalMap050Tile="+$game_map.data[prev[0],prev[1],2].to_s)
     elsif @r10_count==start+55
       subject=(act=="npc_down") ? npc : $game_player
       result=[subject.x,subject.y]
       expected=(act=="npc_down") ? [12,6] : want
       verified=(result==expected && @r10_results && @r10_results[tag])
       FSR10.log("R10_SHOT "+tag+" verified="+verified.to_s+
         " actor="+result.inspect+" npc="+[npc.x,npc.y].inspect+
         " sceneMapName="+$game_map.parallax_name.to_s)
     end
   end
   if @r10_count==95+FSR10::TESTS.size*110
     complete=(FSR10::TESTS.all?{|q| @r10_results && @r10_results[q[0]]})
     FSR10.log("R10_NATIVE_ALL_DONE "+complete.to_s+" cases="+FSR10::TESTS.size.to_s)
   end
 end
end
'''
a[482][2]=zlib.compress((s+ex).encode("ascii"))
script_tgt=dst/"Data"/"Scripts.rvdata"
with script_tgt.open("wb") as f:write(f,a)
after=load(script_tgt.open("rb"))
assert all(after[i if i<482 else i+1]==b[i] for i in range(505) if i!=480)
ini=dst/"Game.ini";x=ini.read_bytes()
assert b"Title=FS_R9_VX_WALK_TEST" in x
ini.write_bytes(x.replace(b"Title=FS_R9_VX_WALK_TEST",b"Title=FS_R10_FORMAL_MAP050"))
(dst/"ENABLE_R9_WALK_TEST.flag").unlink(missing_ok=True)
(dst/"ENABLE_R10_FORMAL_MAP050.flag").write_text("ORIGINAL_MAP050_SOURCE_BYTE_EXACT",encoding="ascii")
(dst/"R10_FORMAL_MAP050_NATIVE.log").write_text("R10_BOOT\n",encoding="ascii")
meta={"status":"R10_ORIGINAL_MAP050_RAW_SOURCE_MAP_COPIED_AS_MAP001_IN_ISOLATED_HARNESS",
      "original_map_source_id":50,"runtime_harness_map_id":1,
      "original_map_file_sha256":hashlib.sha256(map_src.read_bytes()).hexdigest(),
      "same_file_bytes":True,
      "formal_events_preserved_during_scene":"NO: R5 test harness clears events, adds event900",
      "original_505_scripts_original_pages_unchanged":504,"original_page480_disabled":True,
      "formal_k4_unchanged":True,"not_passability_generation":True,
      "test_count":10,"no_parapassa_768_799":True}
(dst.parent/"R10_BUILD.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf8")
print("R10_FORMAL_MAP050_NATIVE_BUILD",json.dumps(meta,ensure_ascii=False),flush=True)