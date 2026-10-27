#!/usr/bin/env python3
"""Isolate a NEW FS-native RGSS2 four-direction actual-movement test from R8 20 objects.
No formal FS edits, no fake movement success based on teleportation.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import subprocess,hashlib,zlib,json
R=Path(__file__).resolve().parent
OFFICIAL=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
s_hash="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256(OFFICIAL.read_bytes()).hexdigest()==s_hash
BASE=R/"R8_NATIVE_FULL_MASTER"/"FULL505";DEST=R/"R9_NATIVE_WALKING_ISOLATED"/"FULL505"
DEST.parent.mkdir(exist_ok=True)
r=subprocess.run(["robocopy",str(BASE),str(DEST),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert r.returncode<8, r.stdout[-1000:]
p=DEST/"Data"/"Scripts.rvdata";base=load(OFFICIAL.open("rb"));a=load(p.open("rb"))
assert len(a)==506 and all(a[i if i<482 else i+1]==base[i] for i in range(505) if i!=480)
s=zlib.decompress(a[482][2]).decode("ascii")
ext=r'''
# R9 test-only extension. Only for isolated clone. Real Game_Player#move_* and map 3rd layer.
module FSR9
 TESTS=[
  ["T01_TREE_DOWN_BACK",[13,3],"down",[13,4],true],
  ["T02_TREE_DOWN_FRONT",[13,4],"down",[13,5],true],
  ["T03_TREE_UP",[13,5],"up",[13,4],true],
  ["T04_BUSH_LEFT",[3,8],"left",[2,8],true],
  ["T05_BUSH_RIGHT",[2,8],"right",[3,8],true],
  ["T06_FAR_CONIFER_DOWN",[15,6],"down",[15,7],true],
  ["T07_FAR_CONIFER_UP",[15,7],"up",[15,6],true],
  ["T08_STEPS_DOWN",[9,5],"down",[9,6],true],
  ["T09_BLOCKED_UP",[5,7],"up",[5,7],false],
  ["T10_BLOCKED_LEFT",[6,6],"left",[6,6],false]
 ]
 def self.log(str)
  File.open("R9_NATIVE_MOVEMENT.log","a"){|f| f.puts(str)}
 end
end
class Scene_Map
 alias r9_before_update update
 def update
   r9_before_update
   return unless FileTest.exist?("ENABLE_R9_WALK_TEST.flag")
   @r9_frame ||= 0
   @r9_frame+=1
   @r9_results ||= {}
   if @r9_frame==30
     FSR9.log("R9_NATIVE_READY map1="+$game_map.map_id.to_s+
       " par="+$game_map.parallax_name.to_s+
       " third_769="+$game_map.data[13,4,2].to_s+
       " third_768="+$game_map.data[5,6,2].to_s+
       " hkEnabled="+$game_switches[203].to_s+
       " depthObjects="+@spriteset.instance_variable_get(:@r5_depth_objects).size.to_s)
     FSR6.set_mode(@spriteset,"B_DYNAMIC")
   end
   FSR9::TESTS.each_with_index do |r,i|
     tag,src,method,dst,should_move=r
     first=95+i*100
     if @r9_frame==first
       $game_player.moveto(src[0],src[1])
       $game_player.refresh
       $game_map.set_display_pos(0,0)
       FSR9.log("R9_SET_START "+tag+" "+src.inspect)
     elsif @r9_frame==first+26
       px=$game_player.x;py=$game_player.y
       case method
       when "up";$game_player.move_up
       when "down";$game_player.move_down
       when "left";$game_player.move_left
       when "right";$game_player.move_right
       end
       observed=[$game_player.x,$game_player.y]
       target_pass=($game_map.data[dst[0],dst[1],2] rescue -1)
       valid=(observed==dst)
       @r9_results[tag]=valid
       FSR9.log("R9_ACTUAL_MOVE "+tag+" action="+method+
        " from="+[px,py].inspect+" to="+observed.inspect+
        " expected="+dst.inspect+" pass="+valid.to_s+
        " expectedMove="+should_move.to_s+
        " targetTile="+target_pass.to_s)
     elsif @r9_frame==first+53
       after=[$game_player.x,$game_player.y]
       ok=(after==dst && @r9_results[tag])
       FSR9.log("R9_WALK_CAPTURE "+tag+" position="+after.inspect+
           " expected="+dst.inspect+" verified="+ok.to_s+
           " playerFootPx="+(($game_player.y+1)*32).to_s+
           " npcFootPx="+(($game_map.events[900].y+1)*32).to_s)
     end
   end
   if @r9_frame==95+FSR9::TESTS.size*100
     valid=FSR9::TESTS.all?{|q|@r9_results[q[0]]}
     FSR9.log("R9_WALK_GATES_COMPLETE "+valid.to_s+" cases="+FSR9::TESTS.size.to_s)
   end
 end
end
'''
a[482][2]=zlib.compress((s+ext).encode("ascii"))
with p.open("wb") as f:write(f,a)
again=load(p.open("rb"));assert len(again)==506 and all(again[i if i<482 else i+1]==base[i] for i in range(505) if i!=480)
ini=DEST/"Game.ini";b=ini.read_bytes();assert b"Title=FS_R8_PAR_RED_BLUE_VX" in b
ini.write_bytes(b.replace(b"Title=FS_R8_PAR_RED_BLUE_VX",b"Title=FS_R9_VX_WALK_TEST"))
(DEST/"ENABLE_R6_SAME_SESSION.flag").unlink(missing_ok=True)
(DEST/"R5_ENABLE_AUTO_PROBE.flag").unlink(missing_ok=True)
(DEST/"ENABLE_R9_WALK_TEST.flag").write_text("R9_WALK_ONLY")
(DEST/"R9_NATIVE_MOVEMENT.log").write_text("R9_ISOLATED_BEGIN\n",encoding="ascii")
(DES:=DEST.parent/"R9_WALK_BUILD.json").write_text(json.dumps({"status":"BUILT_NOT_RUN","test_cases":10,
"four_directions":True,"blocked_controls":2,"real_move_methods":True,
"formal_505_original_pages_unchanged":504,"isolated_page480_disabled":True,
"formal_source_sha256":s_hash},indent=2),encoding="utf8")
print("R9_NATIVE_WALK_BUILD_OK",DEST,flush=True)