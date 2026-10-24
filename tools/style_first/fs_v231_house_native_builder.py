from pathlib import Path
from shutil import copytree,copy2
from rubymarshal.reader import load
from rubymarshal.writer import write
import json,zlib,re,hashlib
R=Path(__file__).resolve().parent.parent
m=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
route=json.loads((R/"input"/"V231_HOUSE_REAL_WALK_ROUTES.json").read_text(encoding="utf8"))
assert m["canvas"]==[544,416] and len(m["objects"])==7 and len(route["routes"])==26
template=R/"native_template"/"STYLE_V1_NATIVE_SEED"
assert (template/"Game.exe").is_file()
MAN=R/"VX_V231_COTTAGE_MANUAL_PLAYABLE"
AUTO=R/"VX_V231_COTTAGE_AUTOPROBE"
copytree(template,MAN,dirs_exist_ok=True)
pics=MAN/"Graphics"/"Pictures";pics.mkdir(parents=True,exist_ok=True)
g=R/"build"/"Ground.png"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(g)==m["source_ground_sha256"]
copy2(g,pics/"FS_ELF_RICH_Ground.png")
ordered=sorted(m["objects"],key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
for o in ordered:
 src=R/o["authoritative_asset_path"]
 assert sha(src)==o["source_sha256"]
 copy2(src,pics/("FSOBJ_"+o["asset_id"]+".png"))
blocked=json.loads((R/"build"/"BlockedTiles.json").read_text(encoding="utf8"))["blocked_tiles"]
assert len(blocked)==42 and [8,11] not in blocked
objdata=[[o["instance_id"],o["asset_id"],o["x"],o["y"],o["foot_anchor"][1],o["kind"]] for o in ordered]
script=MAN/"Data"/"Scripts.rvdata";data=load(script.open("rb"))
i=next(i for i,e in enumerate(data) if e[1]==b"B1 OWNER NATIVE V3")
ruby=zlib.decompress(data[i][2]).decode("ascii")
need={
 r'(?m)^  SOURCE_SHA = ".*"$':'  SOURCE_SHA = "'+sha(R/"scene_manifest.json")+'"',
 r"(?m)^  OBJECTS = .*$":"  OBJECTS = "+json.dumps(objdata,separators=(",",":")),
 r"(?m)^  BLOCKED = .*$":"  BLOCKED = "+json.dumps(blocked,separators=(",",":")),
 r"(?m)^  EVENTS = .*$":"  EVENTS = "+json.dumps([
 ["new_style_sign",309,329],["well",283,303],["blue_door",215,195],["ochre_door",123,390]
 ],separators=(",",":"))}
for pat,repl in need.items():
 ruby,n=re.subn(pat,lambda _:repl,ruby,count=1)
 assert n==1,("NATIVE_SOURCE_SCHEMA_CHANGED",pat)
assert "pass_assets=(OBJECTS.size==6" in ruby
ruby=ruby.replace("pass_assets=(OBJECTS.size==6","pass_assets=(OBJECTS.size==7")
ruby=ruby.replace("STYLE_NATIVE_4_GATES_PASS","V231_COTTAGES_NATIVE_BASE_GATES_PASS")
ruby=ruby.replace("STYLE_NATIVE_4_GATES_FAIL","V231_COTTAGES_NATIVE_BASE_GATES_FAIL")

# Use a real adjacent valid stand (6,2) and attempt to step into blocked house wall (6,3).
# Original seed expected 8,3 blocked; that tile is now inside the larger house wall.
old_probe="  $game_player.moveto(8,3)\n  $game_player.move_up\n  pass_block=($game_player.y==3)"
new_probe="  $game_player.moveto(6,2)\n  $game_player.move_down\n  pass_block=($game_player.y==2)"
assert old_probe in ruby,"MISSING_OLD_NATIVE_HARDCODED_TEST"
ruby=ruby.replace(old_probe,new_probe)
assert [6,3] in blocked and [6,2] not in blocked

routes=[[o["name"],o["tile"][0],o["tile"][1],o["moves"],
         o.get("deny_move",0),o.get("deny_tile",[])] for o in route["routes"]]
extra=r'''
module FSV23
 ROUTES = __ROUTES__
 def self.apply(d)
  case d
  when 2;$game_player.move_down
  when 4;$game_player.move_left
  when 6;$game_player.move_right
  when 8;$game_player.move_up
  else FSRich.log("V231_BAD_DIRECTION")
  end
 end
 def self.next(x,y,d)
  return [x,y+1] if d==2
  return [x-1,y] if d==4
  return [x+1,y] if d==6
  return [x,y-1] if d==8
  [x,y]
 end
end
class Spriteset_Map
 alias v23_pilot_prev_update update
 def update
  v23_pilot_prev_update
  return unless @fs_objects && File.exist?("ENABLE_AUTO_PROBE.flag")
  @v23_frame||=0
  @v23_frame+=1
  f=@v23_frame
  if f==535
   $game_player.moveto(FSRich::SPAWN[0],FSRich::SPAWN[1])
   $game_player.refresh
   @v23_index=0
   @v23_step=0
   @v23_delay=20
   FSRich.log("V231_REAL_WALK_START spawn="+FSRich::SPAWN.join(","))
  end
  return unless f>535 && @v23_index
  if @v23_index>=FSV23::ROUTES.size
   if !@v23_done
    @v23_done=true
    FSRich.log("V231_COTTAGES_ALL_16_STANDS_8_INTRUSIONS_2_REGRESSIONS_DONE")
   end
   return
  end
  if @v23_delay>0
   @v23_delay-=1
   return
  end
  name,tx,ty,steps,deny,deny_tile=FSV23::ROUTES[@v23_index]
  if @v23_step<steps.size
   dir=steps[@v23_step]
   ox,oy=$game_player.x,$game_player.y
   FSV23.apply(dir)
   ok=([$game_player.x,$game_player.y]==FSV23.next(ox,oy,dir))
   FSRich.log("V231_STEP_"+(ok ? "PASS" : "FAIL")+" id="+name+
       " step="+@v23_step.to_s+" tile="+[$game_player.x,$game_player.y].join(","))
   @v23_step+=1
   @v23_delay=8
   return
  end
  pos=[$game_player.x,$game_player.y]
  ok=(pos==[tx,ty])
  if deny!=0
   ox,oy=pos
   FSV23.apply(deny)
   ok=ok && [$game_player.x,$game_player.y]==[ox,oy]
   FSRich.log("V231_"+name+"_"+(ok ? "PASS" : "FAIL")+
       " forbidden="+deny_tile.join(","))
  else
   FSRich.log("V231_STAND_"+name+"_"+(ok ? "PASS" : "FAIL")+" tile="+pos.join(","))
   FSRich.log("V231_SCREEN_"+name+" camera="+
       ($game_map.display_x/8).to_s+","+
       ($game_map.display_y/8).to_s+
       " foot="+(($game_player.y+1)*32).to_s)
  end
  @v23_index+=1
  @v23_step=0
  @v23_delay=18
 end
end
'''
ruby+="\n"+extra.replace("__ROUTES__",json.dumps(routes,separators=(",",":")))
assert "__ROUTES__" not in ruby
data[i][2]=zlib.compress(ruby.encode("ascii"))
with script.open("wb") as f:write(f,data)
assert zlib.decompress(load(script.open("rb"))[i][2]).decode("ascii")==ruby
ini=MAN/"Game.ini"
ini.write_text(re.sub(r"(?m)^Title=.*$","Title=FS_STYLE_FIRST_V2311_COTTAGE_PILOT",ini.read_text(errors="replace")),encoding="ascii")
(MAN/"FS_RICH_VX_LOG.txt").write_text("V231_MANUAL_READY\n",encoding="ascii")
flag=MAN/"ENABLE_AUTO_PROBE.flag"
if flag.exists():flag.unlink()
copytree(MAN,AUTO,dirs_exist_ok=True)
(AUTO/"ENABLE_AUTO_PROBE.flag").write_text("Native architecture V23 test only\n",encoding="ascii")
(AUTO/"FS_RICH_VX_LOG.txt").write_text("V231_AUTOPROBE_READY\n",encoding="ascii")
(R/"logs"/"V231_NATIVE_BUILD.json").write_text(json.dumps({
 "status":"V231_ARCHITECTURE_NATIVE_BUILT_TEST_PENDING",
 "objects":len(objdata),"blocked":len(blocked),"real_routes":len(routes),
 "source_sha256":sha(R/"scene_manifest.json"),"native_exe":str(MAN/"Game.exe"),
 "parent_v22":"PRESERVED","formal_FS":"NOT_TOUCHED"
},indent=2),encoding="utf8")
print("V231_NATIVE_VX_BUILT",json.dumps({"objects":len(objdata),"blocked":len(blocked),
 "route_stands":16,"denials":10,"real_steps":route["total_real_move_count"],
 "gameexe":str(MAN/"Game.exe")},ensure_ascii=False),flush=True)
