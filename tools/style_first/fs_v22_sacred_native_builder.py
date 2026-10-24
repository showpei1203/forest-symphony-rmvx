from pathlib import Path
from shutil import copytree,copy2
from rubymarshal.reader import load
from rubymarshal.writer import write
import hashlib,json,zlib,re
R=Path(__file__).resolve().parent.parent
manifest=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
assert manifest["canvas"]==[544,416] and len(manifest["objects"])==9
srcpath=R/"native_template"/"STYLE_V1_NATIVE_SEED"
assert (srcpath/"Game.exe").is_file()
manual=R/"VX_V22_SACRED_GROVE_MANUAL_PLAYABLE"
auto=R/"VX_V22_SACRED_GROVE_AUTOPROBE"
copytree(srcpath,manual,dirs_exist_ok=True)
pics=manual/"Graphics"/"Pictures";pics.mkdir(exist_ok=True,parents=True)
ground=R/"build"/"Ground.png"
assert hashlib.sha256(ground.read_bytes()).hexdigest()==manifest["source_ground_sha256"]
copy2(ground,pics/"FS_ELF_RICH_Ground.png")
for o in manifest["objects"]:
 src=R/o["authoritative_asset_path"]
 assert hashlib.sha256(src.read_bytes()).hexdigest()==o["source_sha256"],o["instance_id"]
 copy2(src,pics/("FSOBJ_"+o["asset_id"]+".png"))
blocked=json.loads((R/"build"/"BlockedTiles.json").read_text())["blocked_tiles"]
assert len(blocked)==25 and [8,11] not in blocked
assert {(12,5),(13,5),(12,6),(13,6)}<=set(map(tuple,blocked))
instances=sorted(manifest["objects"],key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
objects=[[o["instance_id"],o["asset_id"],o["x"],o["y"],o["foot_anchor"][1],o["kind"]] for o in instances]
script=manual/"Data"/"Scripts.rvdata"
data=load(script.open("rb"))
i=next(i for i,x in enumerate(data) if x[1]==b"B1 OWNER NATIVE V3")
ruby=zlib.decompress(data[i][2]).decode("ascii")
schema={
 r'(?m)^  SOURCE_SHA = ".*"$':'  SOURCE_SHA = "'+hashlib.sha256((R/"scene_manifest.json").read_bytes()).hexdigest()+'"',
 r"(?m)^  OBJECTS = .*$":"  OBJECTS = "+json.dumps(objects,separators=(",",":")),
 r"(?m)^  BLOCKED = .*$":"  BLOCKED = "+json.dumps(blocked,separators=(",",":")),
 r"(?m)^  EVENTS = .*$":"  EVENTS = "+json.dumps([["new_style_sign",309,329],["well",203,269],["noticeboard",62,238]],separators=(",",":"))}
for pattern,replacement in schema.items():
 ruby,n=re.subn(pattern,lambda _:replacement,ruby,count=1)
 assert n==1,("SOURCE_BINDING_MISSING",pattern)
assert "pass_assets=(OBJECTS.size==6" in ruby
ruby=ruby.replace("pass_assets=(OBJECTS.size==6","pass_assets=(OBJECTS.size==9")
ruby=ruby.replace("STYLE_NATIVE_4_GATES_PASS","STYLE_V22_NATIVE_4_GATES_PASS")
ruby=ruby.replace("STYLE_NATIVE_4_GATES_FAIL","STYLE_V22_NATIVE_4_GATES_FAIL")
steps=json.loads((R/"input"/"V22_SACRED_8WAY_ROUTES.json").read_text())["routes"]
route_data=[[r["name"],r["tile"][0],r["tile"][1],r["moves"],r.get("deny_move",0),
             r.get("deny_tile",[])] for r in steps]
jsroutes=json.dumps(route_data,separators=(",",":"))
extra=r'''
module FSSacredV22
 ROUTES = __ROUTES__
 def self.move(d)
  case d
  when 2; $game_player.move_down
  when 4; $game_player.move_left
  when 6; $game_player.move_right
  when 8; $game_player.move_up
  else FSRich.log("V22_BAD_MOVE_DIRECTION "+d.to_s)
  end
 end
 def self.next_pos(x,y,d)
  return [x,y+1] if d==2
  return [x-1,y] if d==4
  return [x+1,y] if d==6
  return [x,y-1] if d==8
  [x,y]
 end
end
class Spriteset_Map
 alias fs_v22_prev_update update
 def update
  fs_v22_prev_update
  return unless @fs_objects && File.exist?("ENABLE_AUTO_PROBE.flag")
  @v22_frame||=0
  @v22_frame+=1
  f=@v22_frame
  if f==535
   $game_player.moveto(6,6)
   $game_player.refresh
  elsif f==565
   FSRich.log("V22_WELL_BEHIND camera="+($game_map.display_x/8).to_s+","+
    ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif f==595
   $game_player.moveto(6,9)
   $game_player.refresh
  elsif f==625
   FSRich.log("V22_WELL_FRONT camera="+($game_map.display_x/8).to_s+","+
    ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif f==660
   $game_player.moveto(4,8)
   $game_player.refresh
  elsif f==680
   $game_player.move_right
   FSRich.log(([$game_player.x,$game_player.y]==[4,8]) ?
    "V22_WELL_BODY_BLOCKED_PASS" : "V22_WELL_BODY_BLOCKED_FAIL")
  elsif f==900
   $game_player.moveto(FSRich::SPAWN[0],FSRich::SPAWN[1])
   $game_player.refresh
   @v22_route_index=0
   @v22_step_index=0
   @v22_cooldown=48
   FSRich.log("V22_SACRED_TRUE_WALK_START spawn="+FSRich::SPAWN.join(","))
  end
  return unless f>900 && @v22_route_index
  if @v22_route_index>=FSSacredV22::ROUTES.size
   if !@v22_done
    @v22_done=true
    FSRich.log("V22_SACRED_8_DIRECTIONS_4_DENIALS_DONE")
   end
   return
  end
  if @v22_cooldown>0
   @v22_cooldown-=1
   return
  end
  name,xgoal,ygoal,moves,denied,deny_tile=FSSacredV22::ROUTES[@v22_route_index]
  if @v22_step_index<moves.size
   step=moves[@v22_step_index]
   px,py=$game_player.x,$game_player.y
   FSSacredV22.move(step)
   expected=FSSacredV22.next_pos(px,py,step)
   ok=([$game_player.x,$game_player.y]==expected)
   FSRich.log("V22_ROUTE_MOVE_"+(ok ? "PASS":"FAIL")+
    " step="+step.to_s+" pos="+[$game_player.x,$game_player.y].join(","))
   @v22_step_index+=1
   @v22_cooldown=14
   return
  end
  got=[$game_player.x,$game_player.y]
  ok=got==[xgoal,ygoal]
  if denied!=0
   px,py=got
   FSSacredV22.move(denied)
   ok=ok && [$game_player.x,$game_player.y]==[px,py]
   FSRich.log("V22_SACRED_"+name+"_"+(ok ? "PASS":"FAIL")+
    " target="+deny_tile.join(","))
  else
   FSRich.log("V22_SACRED_RING_"+name+"_ARRIVED_"+(ok ? "PASS":"FAIL")+
    " tile="+got.join(","))
   FSRich.log("V22_SACRED_RING_"+name+"_SCREEN camera="+
    ($game_map.display_x/8).to_s+","+
    ($game_map.display_y/8).to_s+" foot="+
    (($game_player.y+1)*32).to_s)
  end
  @v22_route_index+=1
  @v22_step_index=0
  @v22_cooldown=48
 end
end
'''
ruby+="\n"+extra.replace("__ROUTES__",jsroutes)
assert "__ROUTES__" not in ruby
data[i][2]=zlib.compress(ruby.encode("ascii"))
with script.open("wb") as f:write(f,data)
assert zlib.decompress(load(script.open("rb"))[i][2]).decode("ascii")==ruby
ini=manual/"Game.ini"
ini.write_text(re.sub(r"(?m)^Title=.*$","Title=FS_STYLE_FIRST_V22_SACRED_GROVE",ini.read_text(errors="replace")),encoding="ascii")
(manual/"FS_RICH_VX_LOG.txt").write_text("V22_MANUAL_READY\n",encoding="ascii")
flag=manual/"ENABLE_AUTO_PROBE.flag"
if flag.exists():flag.unlink()
copytree(manual,auto,dirs_exist_ok=True)
(auto/"ENABLE_AUTO_PROBE.flag").write_text("V22 source-native capture only\n",encoding="ascii")
(auto/"FS_RICH_VX_LOG.txt").write_text("V22_AUTOPROBE_READY\n",encoding="ascii")
(R/"logs"/"V22_NATIVE_BUILD.json").write_text(json.dumps({
 "status":"V22_NATIVE_VX_BUILT_PENDING_ORACLE",
 "source_manifest_sha256":hashlib.sha256((R/"scene_manifest.json").read_bytes()).hexdigest(),
 "new_sacred_sprite_sha256":next(o["source_sha256"] for o in instances if o["kind"]=="sacred_tree"),
 "rpg_maker_vx_real_gameexe":True,
 "ground_actual_loaded":str(pics/"FS_ELF_RICH_Ground.png"),
 "objects_loaded":len(objects),"blocked_tiles":len(blocked),
 "route_paths":len(steps),"native_original_v21":"UNCHANGED",
 "sealed_fs_runtime":"NOT_TOUCHED"
},indent=2),encoding="utf8")
print("V22_NATIVE_REAL_VX_BUILT",json.dumps({"objects":len(objects),
 "blocked_tiles":len(blocked),"routes":len(steps),
 "manual_game":str(manual/"Game.exe")},ensure_ascii=False),flush=True)
