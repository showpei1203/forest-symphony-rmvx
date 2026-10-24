from pathlib import Path
from shutil import copytree,copy2
from rubymarshal.reader import load
from rubymarshal.writer import write
import zlib,hashlib,json,re
R=Path(__file__).resolve().parent.parent
P=R.parent

m=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
assert m["canvas"]==[544,416] and len(m["objects"])==9
for o in m["objects"]:
 src=R/o["authoritative_asset_path"]
 assert hashlib.sha256(src.read_bytes()).hexdigest()==o["source_sha256"]
BASE=R/"native_template"/"STYLE_V1_NATIVE_SEED"
assert BASE.is_dir(), "PACKAGED_NATIVE_TEMPLATE_IS_REQUIRED"
MAN=R/"VX_STYLE_FIRST_V2_GROVE_PLAYABLE"
AUTO=R/"VX_STYLE_FIRST_V2_GROVE_AUTOPROBE"
copytree(BASE,MAN,dirs_exist_ok=True)
pics=MAN/"Graphics"/"Pictures";pics.mkdir(parents=True,exist_ok=True)
ground=R/"build"/"Ground.png"
assert hashlib.sha256(ground.read_bytes()).hexdigest()==m["source_ground_sha256"]
copy2(ground,pics/"FS_ELF_RICH_Ground.png")
for o in m["objects"]:
 copy2(R/o["authoritative_asset_path"],pics/("FSOBJ_"+o["asset_id"]+".png"))
C=__import__("PIL.Image",fromlist=["open"]).open(R/"build"/"Collision.png").convert("L")
blocked=[]
for ty in range(13):
 for tx in range(17):
  cx,cy=tx*32+16,ty*32+16
  if any(C.getpixel((px,py)) for py in range(cy-8,cy+9) for px in range(cx-8,cx+9)):
   blocked.append([tx,ty])
assert len(blocked)==19 and [8,11] not in blocked
ordered=sorted(m["objects"],key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
object_data=[[o["instance_id"],o["asset_id"],o["x"],o["y"],o["foot_anchor"][1],o["kind"]] for o in ordered]
script=MAN/"Data"/"Scripts.rvdata"
rs=load(script.open("rb"))
idx=next(i for i,t in enumerate(rs) if t[1]==b"B1 OWNER NATIVE V3")
ruby=zlib.decompress(rs[idx][2]).decode("ascii")
checks=[
 (r'(?m)^  SOURCE_SHA = ".*"$','  SOURCE_SHA = "'+hashlib.sha256((R/"scene_manifest.json").read_bytes()).hexdigest()+'"'),
 (r"(?m)^  OBJECTS = .*$","  OBJECTS = "+json.dumps(object_data,separators=(",",":"))),
 (r"(?m)^  BLOCKED = .*$","  BLOCKED = "+json.dumps(blocked,separators=(",",":"))),
 (r"(?m)^  EVENTS = .*$","  EVENTS = "+json.dumps([["new_style_sign",309,329],["well",203,270],["noticeboard",382,247]],separators=(",",":")))]
for pat,repl in checks:
 ruby,n=re.subn(pat,lambda match:repl,ruby,count=1)
 assert n==1,pat
assert "pass_assets=(OBJECTS.size==6" in ruby
ruby=ruby.replace("pass_assets=(OBJECTS.size==6","pass_assets=(OBJECTS.size==9")
ruby=ruby.replace("STYLE_NATIVE_4_GATES_PASS","STYLE_V2_NATIVE_4_GATES_PASS")
ruby=ruby.replace("STYLE_NATIVE_4_GATES_FAIL","STYLE_V2_NATIVE_4_GATES_FAIL")
ruby+=r'''
class Spriteset_Map
 alias fs_style_v2_previous_update update
 def update
  fs_style_v2_previous_update
  return unless @fs_objects && File.exist?("ENABLE_AUTO_PROBE.flag")
  @fs_v2_frame||=0
  @fs_v2_frame+=1
  if @fs_v2_frame==535
   $game_player.moveto(6,6)
   $game_player.refresh
  elsif @fs_v2_frame==565
   FSRich.log("STYLE_V2_CAPTURE_WELL_BEHIND camera="+($game_map.display_x/8).to_s+","+
     ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif @fs_v2_frame==595
   $game_player.moveto(5,8)
   $game_player.refresh
  elsif @fs_v2_frame==625
   FSRich.log("STYLE_V2_CAPTURE_WELL_FRONT camera="+($game_map.display_x/8).to_s+","+
     ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif @fs_v2_frame==642
   $game_player.move_right
   FSRich.log(([$game_player.x,$game_player.y]==[5,8]) ?
     "STYLE_V2_WELL_COLLISION_BLOCKED_PASS" : "STYLE_V2_WELL_COLLISION_BLOCKED_FAIL")
  elsif @fs_v2_frame==655
   $game_player.moveto(11,5)
   $game_player.refresh
  elsif @fs_v2_frame==685
   FSRich.log("STYLE_V2_CAPTURE_BOARD_BEHIND camera="+($game_map.display_x/8).to_s+","+
     ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif @fs_v2_frame==715
   $game_player.moveto(11,8)
   $game_player.refresh
  elsif @fs_v2_frame==745
   FSRich.log("STYLE_V2_CAPTURE_BOARD_FRONT camera="+($game_map.display_x/8).to_s+","+
     ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif @fs_v2_frame==775
   $game_player.moveto(5,10)
   $game_player.refresh
  elsif @fs_v2_frame==805
   FSRich.log("STYLE_V2_CAPTURE_HEDGE_BEHIND camera="+($game_map.display_x/8).to_s+","+
     ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif @fs_v2_frame==835
   $game_player.moveto(5,12)
   $game_player.refresh
  elsif @fs_v2_frame==865
   FSRich.log("STYLE_V2_CAPTURE_HEDGE_FRONT camera="+($game_map.display_x/8).to_s+","+
     ($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
   FSRich.log("STYLE_V2_NATIVE_PROBES_DONE")
  end
 end
end
'''
rs[idx][2]=zlib.compress(ruby.encode("ascii"))
with script.open("wb") as f:write(f,rs)
assert zlib.decompress(load(script.open("rb"))[idx][2]).decode("ascii")==ruby
ini=MAN/"Game.ini"
ini.write_text(re.sub(r"(?m)^Title=.*$","Title=FS_STYLE_FIRST_V2_GROVE_PLAYABLE",ini.read_text(errors="replace")),encoding="ascii")
(MAN/"FS_RICH_VX_LOG.txt").write_text("STYLE_V2_MANUAL_START\n",encoding="ascii")
flag=MAN/"ENABLE_AUTO_PROBE.flag"
if flag.exists():flag.unlink()
copytree(MAN,AUTO,dirs_exist_ok=True)
(AUTO/"ENABLE_AUTO_PROBE.flag").write_text("Automated VX image QA, not for user play\n",encoding="ascii")
(AUTO/"FS_RICH_VX_LOG.txt").write_text("STYLE_V2_AUTO_START\n",encoding="ascii")
(R/"logs"/"V2_NATIVE_BUILD.json").write_text(json.dumps({
 "status":"STYLE_V2_NATIVE_BUILT_NOT_YET_TESTED",
 "scene_manifest_sha":hashlib.sha256((R/"scene_manifest.json").read_bytes()).hexdigest(),
 "ground_sha":hashlib.sha256(ground.read_bytes()).hexdigest(),
 "new_ground_actual_import_path":"Graphics/Pictures/FS_ELF_RICH_Ground.png",
 "native_object_count":9,"blocked_tiles":blocked,
 "runtime":"RPG_MAKER_VX_ISOLATED_PROJECT1",
 "formal_fs_sealed":"NOT_TOUCHED"},indent=2),encoding="utf8")
print("STYLE_V2_NATIVE_BUILT",json.dumps({"objects":len(object_data),"blocked":len(blocked),
 "gameexe":str(MAN/"Game.exe")},ensure_ascii=False),flush=True)
