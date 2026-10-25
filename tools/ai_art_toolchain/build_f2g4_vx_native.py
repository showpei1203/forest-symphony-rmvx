from pathlib import Path
import json,zipfile,hashlib,re,shutil,zlib
from rubymarshal.reader import load
from rubymarshal.writer import write
BASE=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
drive=next(p for p in Path("G:/").iterdir() if p.is_dir() and not p.name.startswith("."))
ZIP=drive/"AI_ART_TOOLCHAIN_PILOT_20261025/F2_R3_G4_20261026/F2_R3_G4_DOOR_NATIVE_COLLISION_20261026.zip"
SOURCE=BASE/"outputs/F2_R3_G4_INPUT_20261026"
DEST=BASE/"outputs/F2_R3_G4_VX_REAL_GAME_20261026"
TEMPLATE=Path(r"E:\GameAssetToolLab_20261023\FS_STYLE_FIRST_V21_WELL_CROP_COLLISION_20261024\native_template\STYLE_V1_NATIVE_SEED")
assert ZIP.exists() and TEMPLATE.exists()
assert not SOURCE.exists() and not DEST.exists()
with zipfile.ZipFile(ZIP) as z:
 assert z.testzip() is None
 z.extractall(SOURCE)
m=json.loads((SOURCE/"SCENE_MANIFEST.json").read_text(encoding="utf-8"))
assert m["canvas"]==[1440,1088] and m["native_tile_size"]==32
assert len(m["object_owners"])==9 and len(m["blocked_tiles"])==711
assert m["door_blocked_tile"]==[26,14] and m["doorfront_open_tile"]==[26,15]
shutil.copytree(TEMPLATE,DEST)
pics=DEST/"Graphics/Pictures"
shutil.copy2(SOURCE/"GROUND_PROVISIONAL_UNDERPAINT.png",pics/"FS_ELF_RICH_Ground.png")
objs=[]
for ob in sorted(m["object_owners"],key=lambda z:(z["foot_anchor"][1],z["id"])):
 p=SOURCE/ob["source_png"]
 assert p.is_file()
 ext=ob["id"]
 shutil.copy2(p,pics/("FSOBJ_"+ext+".png"))
 x0,y0,x1,y1=ob["bbox"]
 objs.append([ext,ext,int(x0),int(y0),int(ob["foot_anchor"][1]),ob["category"]])
# only nine active sprites in this isolated candidate.
want={"FSOBJ_"+r["id"]+".png" for r in m["object_owners"]}
removed=[]
for item in pics.glob("FSOBJ_*.png"):
 if item.name not in want:
  removed.append(item.name)
  item.unlink()
assert len(list(pics.glob("FSOBJ_*.png")))==9
rs_path=DEST/"Data/Scripts.rvdata"
rs=load(rs_path.open("rb"))
i=next(i for i,s in enumerate(rs) if s[1]==b"B1 OWNER NATIVE V3")
ruby=zlib.decompress(rs[i][2]).decode("ascii")
basehash=hashlib.sha256((SOURCE/"SCENE_MANIFEST.json").read_bytes()).hexdigest()
repl={
 r"(?m)^  WIDTH = 17$":"  WIDTH = 45",
 r"(?m)^  HEIGHT = 13$":"  HEIGHT = 34",
 r'(?m)^  SOURCE_SHA = ".*"$':'  SOURCE_SHA = "'+basehash+'"',
 r"(?m)^  OBJECTS = .*$":"  OBJECTS = "+json.dumps(objs,separators=(",",":")),
 r"(?m)^  BLOCKED = .*$":"  BLOCKED = "+json.dumps(m["blocked_tiles"],separators=(",",":")),
 r"(?m)^  EVENTS = .*$":"  EVENTS = []",
 r"(?m)^  SPAWN = .*$":"  SPAWN = "+json.dumps(m["spawn_tile"])}
for pat,new in repl.items():
 ruby,k=re.subn(pat,lambda _:new,ruby,count=1)
 assert k==1,pat
ruby=ruby.replace("ground=544x416 props=","ground=1440x1088 props=")
ruby=ruby.replace("world=544x416","world=1440x1088")
ruby=ruby.replace('$game_map.set_display_pos(3*256,7*256)','$game_map.set_display_pos(16*256,17*256)')
ruby+='''
module FSRich
 def self.run_test_logic
  mismatch=[]
  found_blocked=0
  found_free=0
  (0...HEIGHT).each do |y|
   (0...WIDTH).each do |x|
    exp=!BLOCKED.include?([x,y])
    got=$game_player.passable?(x,y)
    mismatch.push([x,y,got,exp]) if got!=exp
    got ? found_free+=1 : found_blocked+=1
   end
  end
  $game_player.moveto(26,16)
  $game_player.refresh
  $game_player.move_up
  front_ok=($game_player.x==26 && $game_player.y==15)
  $game_player.move_up
  door_block_ok=($game_player.x==26 && $game_player.y==15)
  $game_player.moveto(SPAWN[0],SPAWN[1])
  $game_player.refresh
  $game_map.set_display_pos(28*256,20*256)
  right_camera_ok=($game_map.display_x==28*256 && $game_map.display_y==20*256)
  $game_map.set_display_pos(16*256,17*256)
  centered_camera_ok=($game_map.display_x==16*256 && $game_map.display_y==17*256)
  assets_ok=OBJECTS.size==9
  log("F2G4_VX_TILEGRID wrong="+mismatch.size.to_s+" blocked="+found_blocked.to_s+" free="+found_free.to_s)
  log("F2G4_VX_DOOR adjacent_front="+front_ok.to_s+" closed_door_denies="+door_block_ok.to_s)
  log("F2G4_VX_CAMERA long_right="+right_camera_ok.to_s+" center="+centered_camera_ok.to_s+" props="+assets_ok.to_s)
  passed=mismatch.empty? && found_blocked==711 && found_free==819 &&
    front_ok && door_block_ok && right_camera_ok && centered_camera_ok && assets_ok
  log(passed ? "F2G4_VX_NATIVE_1530_1530_PASS" : "F2G4_VX_NATIVE_1530_1530_FAIL")
 end
end
'''
rs[i][2]=zlib.compress(ruby.encode("ascii"))
with rs_path.open("wb") as f:write(f,rs)
check=zlib.decompress(load(rs_path.open("rb"))[i][2]).decode("ascii")
assert check==ruby
(DEST/"FS_RICH_VX_LOG.txt").write_text("F2G4_VX_CANDIDATE_BOOT\n",encoding="ascii")
(DEST/"Game.ini").write_text(re.sub(r'(?m)^Title=.*$',"Title=F2G4_NATIVE_COLLISION_ONLY_GROUND_ART_FAIL",(DEST/"Game.ini").read_text(errors="replace")),encoding="ascii")
flag=DEST/"ENABLE_AUTO_PROBE.flag"
if flag.exists():flag.unlink()
result={"source":"G4 user Drive zip","sha256":hashlib.sha256(ZIP.read_bytes()).hexdigest(),
"grid":[45,34],"blocked":711,"free":819,"objects":9,"front":[26,15],"closed_door":[26,14],
"native_status":"BUILD_ONLY","ground_art":"FAIL"}
(BASE/"reports/F2G4_NATIVE_VX_BUILD.json").write_text(json.dumps(result,indent=2),encoding="utf-8")
print("VX_ISOLATED_BUILT",json.dumps(result),flush=True)
