#!/usr/bin/env python3
"""R12 controlled NEW original full 1280x928 MASTER plus 14 valid sam2-source masks,
candidate collision world. Isolated FS original 505 sealed pages unchanged.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image
import json,subprocess,shutil,struct,zlib,hashlib,math,collections
R=Path(__file__).resolve().parent;D=R/"R12_NEW_ELF_VILLAGE_001"
K4=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
formal_script=K4/"Data"/"Scripts.rvdata";formal_map=K4/"Data"/"Map003.rvdata"
assert hashlib.sha256(formal_script.read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256(formal_map.read_bytes()).hexdigest()=="118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4"
sel=json.loads((D/"R12_SELECTED14_AND_COLLISION_GATE.json").read_text(encoding="utf8"))
grid=json.loads((D/"R12_TILE_GRID_40x29.json").read_text(encoding="utf8"))["third_layer_values"]
assert len(grid)==40*29 and set(grid)=={768,769}
g=[grid[k*40:(k+1)*40] for k in range(29)]
# Non-invented tests: find actual pass/block target tiles close to intended feature reference.
used=set()
specs=[
 ("R12_PLAZA_EAST","walk",(20,18)),
 ("R12_PLAZA_WEST","walk",(13,17)),
 ("R12_TOP_CHAPEL_STAIRS","walk",(7,6)),
 ("R12_EAST_BRIDGE","walk",(35,7)),
 ("R12_BOTTOM_STEPS","walk",(31,25)),
 ("R12_GARDEN_NW","walk",(12,12)),
 ("R12_CHAPEL_WALL","block",(6,3)),
 ("R12_CENTER_INN_WALL","block",(16,10)),
 ("R12_SOUTH_COTTAGE_WALL","block",(31,20)),
 ("R12_EAST_LAKE","block",(37,5)),
 ("R12_CENTRAL_CANAL","block",(23,25)),
 ("R12_WEST_CLIFF","block",(3,6)),
 ("R12_NPC_WALK","npc_walk",(24,18)),
 ("R12_NPC_BLOCK","npc_block",(10,4))]
move_dirs=[(-1,0,"left"),(1,0,"right"),(0,-1,"up"),(0,1,"down")]
def testcase(name,policy,pos):
 px,py=pos;block=policy.endswith("block")
 opts=[]
 for x in range(40):
  for y in range(29):
   if int(g[y][x])!=(768 if block else 769):continue
   for dx,dy,verb in move_dirs:
    bx=x-dx;by=y-dy
    if not (0<=bx<40 and 0<=by<29) or g[by][bx]!=769:continue
    # Allow one-step actual movement; destination blocked => remains on pass tile.
    target=(bx,by) if block else (x,y)
    if (bx,by,verb) in used:continue
    dd=(x-px)**2+(y-py)**2
    opts.append((dd,bx,by,verb,target,[x,y]))
 opts.sort()
 assert opts,name
 _,bx,by,verb,target,tile=opts[0]
 used.add((bx,by,verb))
 return {"id":name,"kind":policy,"from":[bx,by],"direction":verb,"destination_cell":tile,"expected":list(target),
         "expected_moved":not block,"target_original_grid_id":int(g[tile[1]][tile[0]])}
cases=[testcase(*s) for s in specs]
assert len(cases)==14
(D/"R12_NATIVE_TEST_CASES.json").write_text(json.dumps(cases,ensure_ascii=False,indent=2),encoding="utf8")
# Keep original Map003 RVA as raw binary: rubymarshal can't re-serialize its 25-event object graph.
# Inject candidate third-layer 769/768 and new parallax_name in Game_Map#setup test-only.
src_original=K4/"Data"/"Map003.rvdata"
(D/"R12_MAP_COMPILER_RUNTIME_MANIFEST.json").write_text(json.dumps({
 "status":"R12_TEST_ONLY_RUNTIME_TILE_INJECTION",
 "source_Map003_sha256":hashlib.sha256(src_original.read_bytes()).hexdigest(),
 "source_Map003_unmodified":True,"candidate_tiles":len(grid),
 "native_map_file_exported":False,"original_25_events_in_data_remain":True,
 "test_event_adapter_may_clear_original_events":True},indent=2),encoding="utf8")
SRC=R/"R11_GROUND3_5OBJECT_NATIVE"/"FULL505"
DST=R/"R12_NEW_ELF_VILLAGE_NATIVE"/"FULL505";DST.parent.mkdir(exist_ok=True)
copy=subprocess.run(["robocopy",str(SRC),str(DST),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert copy.returncode<8,copy.stdout[-1000:]
shutil.copy2(formal_map,DST/"Data"/"Map001.rvdata")
shutil.copy2(D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png",DST/"Graphics"/"Parallaxes"/"R12_ELF_VILLAGE_001.png")
# FS original overlay reads cached Map003 parallax name ground3. Isolated ONLY overwrite that runtime asset.
# Formal K4/Graphics/Parallaxes/ground3.png stays sealed untouched.
shutil.copy2(D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png",DST/"Graphics"/"Parallaxes"/"ground3.png")
assert hashlib.sha256((DST/"Graphics"/"Parallaxes"/"ground3.png").read_bytes()).hexdigest()==sel["master_sha256"]
shutil.copy2(D/"PAR_R12_VX_SELECTED14_SOURCE_ONLY.png",DST/"Overlays"/"Par1.png")
for ob in sel["selected_objects"]:
 shutil.copy2(D/(ob["id"]+"_PAR.png"),DST/"Graphics"/"Pictures"/("R5_OC_"+ob["id"]+".png"))
mfile=DST/"Data"/"Scripts.rvdata"
pages=load(mfile.open("rb"));off=load(formal_script.open("rb"))
assert len(pages)==506 and all(pages[i if i<482 else i+1]==off[i] for i in range(505) if i!=480)
txt=zlib.decompress(pages[482][2]).decode("ascii")
start=txt.index('     [["house_left_north"')
end=txt.index(".each do |pair|",start)
pairs=[[ob["id"],ob["foot_anchor"][1]] for ob in sel["selected_objects"]]
txt=txt[:start]+'     '+json.dumps(pairs,separators=(",",":"))+txt[end:]
# R11 flag should not be enabled, R12 new code acts alone; keep its other legacy test disabled.
txt+='''

# R12 source-only runtime passability injection; formal original Map003 binary stays byte-for-byte.
class Game_Map
 alias r12_original_map_setup setup
 def setup(map_id)
  r12_original_map_setup(map_id)
  if FileTest.exist?("ENABLE_R12_VILLAGE.flag")
   @map.instance_variable_set(:@parallax_name,"ground3")
   r12_tile_ids=R12_TILE_IDS_INSERTED
   (0...29).each do |y|
    (0...40).each do |x|
     @map.data[x,y,0]=0
     @map.data[x,y,1]=0
     @map.data[x,y,2]=r12_tile_ids[y*40+x]
    end
   end
  end
 end
end
# R12 NEW generated village, strictly isolated test. Real Game_Player and Game_Event movement.
module FSR12
 TESTS=TESTS_INSERTED
 def self.log(s);File.open("R12_NEW_VILLAGE_NATIVE.log","a"){|f|f.puts(s)};end
end
class Scene_Map
 alias r12_previous_update update
 def update
  r12_previous_update
  return unless FileTest.exist?("ENABLE_R12_VILLAGE.flag")
  @r12_frame ||= 0; @r12_frame+=1
  if @r12_frame==30
   FSR6.set_mode(@spriteset,"B_DYNAMIC")
   FSR12.log("R12_WORLD name="+$game_map.parallax_name.to_s+
    " size="+$game_map.width.to_s+"x"+$game_map.height.to_s+
    " objects="+@spriteset.instance_variable_get(:@r5_depth_objects).size.to_s+
    " mapPass="+$game_map.passable?(20,18).to_s+
    " source_sample="+[Cache.parallax("ground3").get_pixel(100,100).red.to_i,Cache.parallax("ground3").get_pixel(100,100).green.to_i,Cache.parallax("ground3").get_pixel(100,100).blue.to_i].inspect)
  end
  FSR12::TESTS.each_with_index do |ob,i|
   tag,from,act,expected,kind=ob
   first=100+i*90
   if @r12_frame==first
    $game_player.moveto(from[0],from[1]);$game_player.refresh
    npc=$game_map.events[900];npc.moveto(from[0],from[1]);npc.refresh
    npc.instance_variable_set(:@through,false)
    # Move NPC out of player path on player tests
    npc.moveto(0,0) unless kind=="npc_walk" || kind=="npc_block"
    FSR12.log("R12_START "+tag+" from="+from.inspect+" act="+act)
   elsif @r12_frame==first+28
    npc=$game_map.events[900]
    actor=(kind=="npc_walk" || kind=="npc_block") ? npc : $game_player
    before=[actor.x,actor.y]
    case act
    when "up";actor.move_up
    when "down";actor.move_down
    when "left";actor.move_left
    when "right";actor.move_right
    end
    now=[actor.x,actor.y]
    @r12_move_status ||= {}
    @r12_move_status[tag]=(now==expected)
    FSR12.log("R12_REAL_MOVE "+tag+" kind="+kind+" from="+before.inspect+
       " to="+now.inspect+" expected="+expected.inspect+
       " pass="+(now==expected).to_s)
   elsif @r12_frame==first+57
    npc=$game_map.events[900]
    actor=(kind=="npc_walk" || kind=="npc_block") ? npc : $game_player
    valid=([actor.x,actor.y]==expected && @r12_move_status && @r12_move_status[tag])
    off=[$game_map.display_x,$game_map.display_y]
    obx=@spriteset.instance_variable_get(:@r5_depth_objects)
    firstobj=obx[0]
    FSR12.log("R12_SCREEN "+tag+" verified="+valid.to_s+
     " player="+[$game_player.x,$game_player.y].inspect+
     " npc="+[npc.x,npc.y].inspect+
     " camera="+off.inspect+
     " parObjXY="+[firstobj.x,firstobj.y].inspect+
     " sourceObjCount="+obx.size.to_s)
   end
  end
  if @r12_frame==100+FSR12::TESTS.size*90
   done=FSR12::TESTS.all?{|q|@r12_move_status && @r12_move_status[q[0]]}
   FSR12.log("R12_ALL_CASES_COMPLETE "+done.to_s+" cases="+FSR12::TESTS.size.to_s)
  end
 end
end
'''.replace('TESTS_INSERTED',json.dumps([[x["id"],x["from"],x["direction"],x["expected"],x["kind"]] for x in cases],separators=(",",":"))).replace('R12_TILE_IDS_INSERTED',json.dumps(grid,separators=(",",":")))
pages[482][2]=zlib.compress(txt.encode("ascii"))
with mfile.open("wb") as f:write(f,pages)
a=load(mfile.open("rb"));assert all(a[i if i<482 else i+1]==off[i] for i in range(505) if i!=480)
ini=DST/"Game.ini";cfg=ini.read_bytes()
assert b"Title=FS_R11_GROUND3_PAR5" in cfg
ini.write_bytes(cfg.replace(b"Title=FS_R11_GROUND3_PAR5",b"Title=FS_R12_ELF_VILLAGE_001"))
for flag in ["ENABLE_R9_WALK_TEST.flag","ENABLE_R10_FORMAL_MAP050.flag","ENABLE_R11_GROUND3.flag","ENABLE_R6_SAME_SESSION.flag","R5_ENABLE_AUTO_PROBE.flag"]:
 (DST/flag).unlink(missing_ok=True)
(DST/"ENABLE_R12_VILLAGE.flag").write_text("NEW_SOURCE_MASTER_AND_SOURCE_PAR_CANDIDATE",encoding="ascii")
(DST/"R12_NEW_VILLAGE_NATIVE.log").write_text("R12_NATIVE_BOOT\n",encoding="ascii")
log={"status":"R12_NEW_MASTER_PAR14_SOURCE_NATIVE_TEST_BUILD_READY","native_map":[40,29],
"unique_artwork":True,"actual_new_master_sha256":sel["master_sha256"],
"compiled_collision_grid_769":sel["passable_769_tile_count"],"compiled_collision_grid_768":sel["blocked_768_tile_count"],
"source_objects":len(pairs),"native_tests":len(cases),"script_official_pages_unchanged":504,
"original_formal_K4_untouched":True,"user_art_gate_F":"HOLD","original_25_events_not_tested":True}
(DST.parent/"R12_BUILD_MANIFEST.json").write_text(json.dumps(log,ensure_ascii=False,indent=2),encoding="utf8")
print("R12_BUILD",json.dumps(log,ensure_ascii=False),flush=True)