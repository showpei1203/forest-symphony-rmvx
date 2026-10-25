from pathlib import Path
from shutil import copytree,copy2
from rubymarshal.reader import load
from rubymarshal.writer import write
import zlib,hashlib,json,re
ROOT=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
F1=ROOT/"outputs/FS_F2_COTTAGE_SOURCE_FIRST_20261025"
BASE=Path(r"E:\GameAssetToolLab_20261023\FS_STYLE_FIRST_V21_WELL_CROP_COLLISION_20261024\native_template\STYLE_V1_NATIVE_SEED")
DEST=ROOT/"outputs/FS_F2_NATIVE_VX_COTTAGE_20261025"
assert BASE.is_dir()
if DEST.exists():raise RuntimeError("Do not overwrite isolated VX native test")
copytree(BASE,DEST)
m=json.loads((F1/"scene_manifest.json").read_text(encoding="utf-8"))
assert m["canvas"]==[544,416] and len(m["objects"])==9
assert m["tile_size"]==32
for o in m["objects"]:
 f=F1/o["source"]
 assert f.is_file() and hashlib.sha256(f.read_bytes()).hexdigest()==o["source_sha256"]
pics=DEST/"Graphics/Pictures";pics.mkdir(exist_ok=True,parents=True)
copy2(F1/"build/Ground.png",pics/"FS_ELF_RICH_Ground.png")
data=[]
for ob in sorted(m["objects"],key=lambda q:(q["foot_anchor"][1],q["id"])):
 p=F1/ob["source"]
 copy2(p,pics/("FSOBJ_"+ob["id"]+".png"))
 data.append([ob["id"],ob["id"],ob["x"],ob["y"],ob["foot_anchor"][1],ob["kind"]])
blocked=m["collision"]["blocked_tiles"]
assert len(blocked)==25
spawn=[int(m["spawn_world"][0]//32),int(m["spawn_world"][1]//32)]
assert spawn==[8,11] and spawn not in blocked
# Concrete independent source, no original project overwritten.
source=DEST/"Data/Scripts.rvdata"
rs=load(source.open("rb"))
idx=next(i for i,s in enumerate(rs) if s[1]==b"B1 OWNER NATIVE V3")
ruby=zlib.decompress(rs[idx][2]).decode("ascii")
changes=[
(r'(?m)^  SOURCE_SHA = ".*"$','  SOURCE_SHA = "'+hashlib.sha256((F1/"scene_manifest.json").read_bytes()).hexdigest()+'"'),
(r"(?m)^  OBJECTS = .*$","  OBJECTS = "+json.dumps(data,separators=(",",":"))),
(r"(?m)^  BLOCKED = .*$","  BLOCKED = "+json.dumps(blocked,separators=(",",":"))),
(r"(?m)^  EVENTS = .*$","  EVENTS = "+json.dumps([["sign",299,197],["well",368,344]],separators=(",",":"))),
(r"(?m)^  SPAWN = .*$","  SPAWN = "+json.dumps(spawn,separators=(",",":")))]
for pat,value in changes:
 ruby,count=re.subn(pat,lambda _:value,ruby,count=1)
 assert count==1,pat
assert "pass_assets=(OBJECTS.size==6" in ruby
ruby=ruby.replace("pass_assets=(OBJECTS.size==6","pass_assets=(OBJECTS.size==8")
assert "$game_player.moveto(8,3)" in ruby
ruby=ruby.replace("$game_player.moveto(8,3)","$game_player.moveto(6,6)")
# Define definitive test module after all prior overrides. Frame22 calls FSRich.run_test_logic.
ruby+='''
module FSRich
 def self.run_test_logic
  errors=[]
  blocked=0
  walkable=0
  (0...HEIGHT).each do |y|
   (0...WIDTH).each do |x|
    expected=!BLOCKED.include?([x,y])
    actual=$game_player.passable?(x,y)
    if actual!=expected
     errors.push([x,y,actual,expected])
    end
    if actual
     walkable+=1
    else
     blocked+=1
    end
   end
  end
  log("F2_VX_TILE_GRID result="+errors.size.to_s+" blocked="+blocked.to_s+" walkable="+walkable.to_s)
  $game_player.moveto(SPAWN[0],SPAWN[1])
  $game_player.refresh
  $game_player.move_up
  step_ok=($game_player.y==SPAWN[1]-1)
  $game_player.moveto(6,6)
  $game_player.refresh
  $game_player.move_up
  block_ok=($game_player.y==6)
  $game_player.moveto(SPAWN[0],SPAWN[1])
  $game_player.refresh
  $game_map.set_display_pos(0,0)
  camera_ok=($game_map.display_x==0 && $game_map.display_y==0)
  prop_ok=(OBJECTS.size==9)
  signed=(errors.empty? && blocked==25 && walkable==196 && step_ok && block_ok && camera_ok && prop_ok)
  log("F2_VX_NATIVE_GATE steps="+step_ok.to_s+" denied="+block_ok.to_s+
      " props="+prop_ok.to_s+" camera="+camera_ok.to_s)
  log(signed ? "F2_VX_NATIVE_221_221_PASS" : "F2_VX_NATIVE_221_221_FAIL")
 end
end
'''
rs[idx][2]=zlib.compress(ruby.encode("ascii"))
with source.open("wb") as f:write(f,rs)
check=zlib.decompress(load(source.open("rb"))[idx][2]).decode("ascii")
assert check==ruby
(DEST/"Game.ini").write_text(re.sub(r'(?m)^Title=.*$',"Title=FS_F2_NEW_GROUND_ISOLATED_NATIVE", (DEST/"Game.ini").read_text(errors="replace")),encoding="ascii")
(DEST/"FS_RICH_VX_LOG.txt").write_text("F2_NATIVE_CANDIDATE_START\n",encoding="ascii")
flag=DEST/"ENABLE_AUTO_PROBE.flag"
if flag.exists():flag.unlink()
info={"schema":"FS_F2_VX_NATIVE_CANDIDATE","size":[544,416],"props":len(data),"blocked":len(blocked),
      "source_ground_sha256":hashlib.sha256((F1/"build/Ground.png").read_bytes()).hexdigest(),
      "script_sha256":hashlib.sha256(source.read_bytes()).hexdigest(),"source_manifest_sha256":hashlib.sha256((F1/"scene_manifest.json").read_bytes()).hexdigest(),
      "status":"BUILD_ONLY_NOT_NATIVE_TESTED","base":"V21 native test template, not formal sealed", "game_exe":"Game.exe"}
(DEST/"F2_VX_NATIVE_MANIFEST.json").write_text(json.dumps(info,indent=2),encoding="utf-8")
(ROOT/"reports/F2_VX_NATIVE_BUILD.json").write_text(json.dumps(info,indent=2),encoding="utf-8")
print("F2_VX_BUILD_OK",json.dumps({"candidate":str(DEST),"objects":len(data),"blocked":len(blocked),"spawn":spawn}))
