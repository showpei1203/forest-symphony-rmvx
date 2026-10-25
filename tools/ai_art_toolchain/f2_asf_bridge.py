from __future__ import annotations
from pathlib import Path
from PIL import Image,ImageChops
import numpy as np,json,hashlib,subprocess,shutil,sys
ROOT=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
F1=ROOT/"outputs/FS_F2_COTTAGE_SOURCE_FIRST_20261025"
OUT=ROOT/"outputs/FS_F2_ASF_HOUSE_BRIDGE_20261025"
SHA=(ROOT/"reports/agent_sprite_forge_commit.txt").read_text().strip()
TOOLS=ROOT/"sources"/("agent-sprite-forge-"+SHA)/"skills/generate2dmap/scripts"
PY=ROOT/".venv/Scripts/python.exe"
REPORT=ROOT/"reports"
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def ensure(p):p.parent.mkdir(parents=True,exist_ok=True);return p
def exec_cmd(label,commands):
 p=subprocess.run([str(x) for x in commands],capture_output=True,text=True,errors="replace",timeout=110)
 ensure(REPORT/("F2_"+label+".log")).write_text(p.stdout+"\nSTDERR\n"+p.stderr,encoding="utf-8")
 print(label,p.returncode,(p.stdout+" "+p.stderr)[-360:])
 return p.returncode==0
def diff(a,b):
 a=np.asarray(a.convert("RGBA"))
 b=np.asarray(b.convert("RGBA"))
 if a.shape!=b.shape:return -1
 return int(np.count_nonzero(np.any(a!=b,axis=2)))
def build():
 if OUT.exists():raise RuntimeError("Fail-closed: output already exists, no mutation of candidate")
 OUT.mkdir(parents=True)
 m=json.loads((F1/"scene_manifest.json").read_text(encoding="utf-8"))
 w,h=m["canvas"];assert (w,h)==(544,416)
 src=F1/"build/Ground.png";dst=ensure(OUT/"bundle/art/ground.png")
 shutil.copy2(src,dst)
 assert digest(src)==digest(dst)
 assets={};obj=[];ledger=[]
 for o in m["objects"]:
  item=F1/o["source"];target=ensure(OUT/"bundle/props"/(o["id"]+".png"))
  shutil.copy2(item,target)
  assert digest(target)==o["source_sha256"]
  local=o["foot_local"]
  assets[o["id"]]={"image":"props/"+o["id"]+".png","sha256":digest(target),
                  "anchor_px":local,"solid":False,
                  "occlusion_class":"tall" if o["kind"] in ("tree","well","sign","house") else "low"}
  obj.append({"id":o["id"],"prop":o["id"],"x":o["foot_anchor"][0],"y":o["foot_anchor"][1],
              "anchor_px":local,"sortY":o["foot_anchor"][1]})
  ledger.append({"id":o["id"],"original_source":o["source"],"source_sha256":digest(target),
                 "new_position":[o["x"],o["y"]],"local_foot":local,"collision_local":o["contact_local"]})
 assert len(obj)==9
 tiles=m["collision"]["blocked_tiles"]
 rects=[[int(x)*32,int(y)*32,32,32] for x,y in tiles]
 spawn=m["spawn_world"]
 bundle={"schema":"generate2dmap.map_bundle.v2","id":"FS_F2_Independent_House_Source_Scene",
         "world":{"width":w,"height":h,"unit":"px"},"tile_size":[32,32],
         "layers":[{"name":"ground","kind":"image","image":"art/ground.png","sha256":digest(dst)},
                   {"name":"props","kind":"objects"}],
         "props":assets,"objects":obj,
         "collision":{"actorRadius":0,"ySquash":1.0,"solids":[],"rects":rects},
         "spawns":[{"id":"start","x":spawn[0],"y":spawn[1],"facing":"north"}],
         "camera":{"bounds":[0,0,w,h]},"art_source":"mixed"}
 path=ensure(OUT/"bundle/map-bundle.json")
 path.write_text(json.dumps(bundle,indent=2),encoding="utf-8")
 ensure(OUT/"F1_source_ledger.json").write_text(json.dumps(
  {"source_sha256":digest(F1/"scene_manifest.json"),"ground_sha256":digest(src),
   "source_ground_was_rebuilt":True,"parts":ledger,"rights":"PRIVATE_TEST_ONLY","source":"FS-F1 sourced Quilt textures; no previous Ground.png copied"},indent=2),encoding="utf-8")
 shutil.copy2(F1/"build/Recomposed.png",ensure(OUT/"fs_reference/Recomposed.png"))
 shutil.copy2(F1/"build/Ground.png",ensure(OUT/"fs_reference/Ground.png"))
 shutil.copy2(F1/"build/PAR_COMPLETE.png",ensure(OUT/"fs_reference/PAR_COMPLETE.png"))
 shutil.copy2(F1/"scene_manifest.json",ensure(OUT/"fs_reference/scene_manifest.json"))
 return path
def main():
 bundle=build();report={}
 report["validate"]=exec_cmd("BUNDLE",[PY,TOOLS/"map_bundle.py","validate","--bundle",bundle,"--require-sha256"])
 if not report["validate"]:raise SystemExit("New bundle fails schema")
 sys.path.insert(0,str(TOOLS));import map_bundle
 scene=map_bundle.render_map(map_bundle.load_bundle(bundle))
 generated=ensure(OUT/"asf_reference_render.png");Image.fromarray(scene).save(generated)
 diffpx=diff(Image.open(generated),Image.open(OUT/"fs_reference/Recomposed.png"))
 report["asf_full_scene_rgba_diff"]=diffpx
 report["render"]=diffpx==0
 report["navigation"]=exec_cmd("NAV",[PY,TOOLS/"map_nav.py","check","--bundle",bundle,"--output-dir",OUT/"nav","--publish-on-fail"])
 report["tiled"]=exec_cmd("TILED",[PY,TOOLS/"export_tiled.py","export","--bundle",bundle,"--output-dir",OUT/"tiled","--embedded-variant"])
 if report["tiled"]:
  report["tiled_verify"]=exec_cmd("TILED_VERIFY",[PY,TOOLS/"export_tiled.py","verify","--map",OUT/"tiled/map.tmj","--bundle",bundle])
 else:report["tiled_verify"]=False
 report["godot"]=exec_cmd("GODOT_EXPORT",[PY,TOOLS/"export_godot.py","--bundle",bundle,"--output-dir",OUT/"godot_export","--name","f2_cottage_forest","--texture-filter","nearest"])
 report["pass"]=all(v is True for k,v in report.items() if k!="asf_full_scene_rgba_diff")
 ensure(REPORT/"F2_BRIDGE_RESULT.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
 print("F1_BRIDGE",json.dumps(report))
 if not report["pass"]:raise SystemExit(1)
if __name__=="__main__":main()
