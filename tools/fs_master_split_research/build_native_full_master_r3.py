#!/usr/bin/env python3
"""Test-only native RPG Maker VX: same full master Ground, per-object source-pixel PAR.
Creates isolated R3 STATIC and DEPTH variations. Never touches source template/formal FS.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image
import zlib,re,shutil,hashlib,json
ROOT=Path(__file__).resolve().parent
SRC=ROOT/"SCENE21_GUIDED_SAM2_CANDIDATE"
SRCSCENE=SRC/"MASTER_RGBA.png"
M=Image.open(SRCSCENE).convert("RGBA"); assert M.size==(544,416)
# SCENE21 exterior is transparent. VX otherwise leaks native tilemap under alpha=0.
# Compose a fixed black matte without modifying the original Master source pixels.
MATTE=ROOT/"MASTER_OPAQUE_BLACK_MATTE.png"
matte=Image.alpha_composite(Image.new("RGBA",M.size,(0,0,0,255)),M)
matte.save(MATTE)
MET=json.loads((ROOT/"OCCLUSION_GRID_R1_20261027"/"OCCLUSION_GRID_R1_METRICS.json").read_text())
template=Path(r"E:\GameAssetToolLab_20261023\FS_STYLE_FIRST_VX_EXTRACTED_REGRESSION_20261024\native_template\VX_B1_RICH_MANUAL_PLAYABLE")
assert template.is_dir()
objs=[
  {"id":"house","mask":SRC/"house_SAM2_RAW.png","cutoff":196,"foot_y":214,"asset":"r3_house","kind":"building"},
  {"id":"left_tree","mask":SRC/"left_tree_SAM2_RAW.png","cutoff":187,"foot_y":190,"asset":"r3_left_tree","kind":"tree"},
  {"id":"right_tree","mask":SRC/"right_tree_prompt_v2_variant1.png","cutoff":217,"foot_y":237,"asset":"r3_right_tree","kind":"tree"},
]
for o in objs:
 assert o["mask"].is_file(),o["mask"]
 mask=Image.open(o["mask"]).convert("L")
 # Source exact pixels, just adjust alpha. Only occluding upper pixels, not full objects.
 alpha=mask.point(lambda v: 255 if v>=128 else 0)
 from PIL import ImageDraw
 ImageDraw.Draw(alpha).rectangle((0,o["cutoff"],544,416),fill=0)
 im=M.copy();im.putalpha(alpha)
 o["png"]=im
 o["mask_pixels"]=alpha.histogram()[255]
# Generate scripts by adapting verified isolated RGSS2 template; no original FS Scripts.rvdata changes
srcscript=template/"Data"/"Scripts.rvdata"
with srcscript.open("rb") as f:a=load(f)
ix=next(i for i,k in enumerate(a) if k[1]==b"B1 OWNER NATIVE V3")
base=zlib.decompress(a[ix][2]).decode("ascii")
def replace_const(name,val):
 global base
 s=rf"(?m)^  {re.escape(name)} = .*$"
 base,n=re.subn(s,"  "+name+" = "+val,base,count=1);assert n==1,name
replace_const("WIDTH","17");replace_const("HEIGHT","13")
replace_const("SOURCE_SHA",'"'+hashlib.sha256(SRCSCENE.read_bytes()).hexdigest()+'"')
ordered=sorted(objs,key=lambda x:x["foot_y"])
record=[[o["id"],o["asset"],0,0,o["foot_y"],o["kind"]] for o in ordered]
replace_const("OBJECTS",json.dumps(record,separators=(",",":")))
replace_const("BLOCKED",json.dumps([[5,6],[10,7],[14,8]],separators=(",",":")))
replace_const("EVENTS","[]")
replace_const("SPAWN","[8,10]")
# Dynamic baseline script draws source-identical occlusion objects at world(0,0), z=foot_y.
# Different 32x32 patches in static mode are intentionally *not* dynamic depth sorted.
base=base.replace("RICH_VX_LAYERS ground=864x640", "R3_FULL_MASTER_LAYERS ground=544x416")
base=base.replace("RICH_CAMERA offset=", "R3_CAMERA offset=")
base=base.replace(" world=864x640", " world=544x416")
base=base[:base.index("\nclass Spriteset_Map\n alias b1_v3_native_previous_update update")]
# Native auto screenshot probe at selected 32x32 tile feet.
spots=[
 ("TREE_BEHIND",4,3),("TREE_FRONT",4,5),
 ("HOUSE_BEHIND",10,4),("HOUSE_FRONT",10,6),
 ("RIGHT_BEHIND",14,4),("RIGHT_FRONT",14,7),
 ("CLEAR",8,9)
]
logprobes=json.dumps(spots,separators=(",",":"))
suffix=r'''
module FSRich
  def self.run_test_logic
    $game_player.moveto(8,10)
    $game_player.refresh
    $game_player.move_up
    moved=($game_player.y==9)
    $game_player.moveto(5,7)
    $game_player.move_up
    blocked=($game_player.y==7)
    $game_player.moveto(8,10)
    $game_map.set_display_pos(0,0)
    valid=(WIDTH==17 && HEIGHT==13 && OBJECTS.size==3 && moved && blocked)
    log("R3_NATIVE_MOVE moved="+moved.to_s+" blocked="+blocked.to_s)
    log(valid ? "R3_NATIVE_BASIC_PASS" : "R3_NATIVE_BASIC_FAIL")
  end
end
class Spriteset_Map
  alias r3_native_prev_update update
  def update
    r3_native_prev_update
    return unless @fs_objects && File.exist?("ENABLE_R3_PROBE.flag")
    @r3_frame ||= 0
    @r3_frame+=1
    spots = __SPOTS__
    spots.each_with_index do |item,i|
      tag,xx,yy=item
      if @r3_frame==75+i*62
        $game_player.moveto(xx,yy)
        $game_player.refresh
        $game_map.set_display_pos(0,0)
        FSRich.log("R3_POSITION "+tag+" at="+xx.to_s+","+yy.to_s)
      elsif @r3_frame==105+i*62
        FSRich.log("R3_CAPTURE "+tag+" foot="+(($game_player.y+1)*32).to_s+" camera="+($game_map.display_x/8).to_s+","+($game_map.display_y/8).to_s)
      end
    end
    if @r3_frame==105+spots.size*62
      FSRich.log("R3_CAPTURE_DONE")
    end
  end
end
'''
suffix=suffix.replace("__SPOTS__",logprobes)
reports=[]
for mode in ["STATIC","DEPTH"]:
 work=ROOT/"R3_NATIVE_VX"/mode
 if work.is_dir():shutil.rmtree(work)
 shutil.copytree(template,work)
 assets=work/"Graphics"/"Pictures";assets.mkdir(parents=True,exist_ok=True)
 # The source full scene is the ground: no deletion or inpainting, regardless of masked objects.
 shutil.copy2(MATTE,assets/"FS_ELF_RICH_Ground.png")
 for o in objs:o["png"].save(assets/("FSOBJ_"+o["asset"]+".png"))
 script=base+suffix
 if mode=="STATIC":
  # static PAR simulates the HK-UOM higher-than-all-actors viewport behaviour
  script=script.replace("sp.z = ob[4]","sp.z = 900")
 else:
  assert "sp.z = ob[4]" in script
 script=script.replace('FSRich.log("R3_NATIVE_BASIC_PASS")','FSRich.log("R3_NATIVE_BASIC_PASS")')
 assert "R3_CAPTURE TREE_FRONT" not in script # spot labels dynamic, not separate code
 a2=load(srcscript.open("rb"))
 a2[ix][2]=zlib.compress(script.encode("ascii"))
 with (work/"Data"/"Scripts.rvdata").open("wb") as f:write(f,a2)
 assert zlib.decompress(load((work/"Data"/"Scripts.rvdata").open("rb"))[ix][2]).decode("ascii")==script
 ini=work/"Game.ini"
 ini.write_text(re.sub(r"(?m)^Title=.*$",f"Title=FS_PAR_R3_{mode}_20261027",ini.read_text(errors="replace")),encoding="ascii")
 (work/"ENABLE_R3_PROBE.flag").write_text("ISOLATED_R3_ONLY",encoding="ascii")
 (work/"FS_RICH_VX_LOG.txt").write_text("R3_TEST_READY\n",encoding="ascii")
 report={"mode":mode,"build":"ISOLATED_NATIVE_VX_TEST_ONLY","objects":record,"masks":[{k:v for k,v in o.items() if k not in ("mask","png")} for o in objs],
         "scene_sha256":hashlib.sha256(SRCSCENE.read_bytes()).hexdigest(),
         "runtime_scripts_source":"B1 OWNER NATIVE V3 isolated, NOT sealed FS Scripts.rvdata"}
 report["masks"]=[{"id":o["id"],"mask_sha":hashlib.sha256(o["mask"].read_bytes()).hexdigest(),"occlusion_px":o["mask_pixels"],"foot_y":o["foot_y"],"cutoff":o["cutoff"]} for o in objs]
 reports.append(report)
out=ROOT/"R3_NATIVE_VX";(out/"R3_BUILD_REPORT.json").write_text(json.dumps(reports,ensure_ascii=False,indent=2),encoding="utf8")
print("R3_BUILD_SUCCESS",json.dumps([{"mode":x["mode"],"source_sha":x["scene_sha256"][:12],"assets":len(x["objects"])} for x in reports]))