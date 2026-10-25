#!/usr/bin/env python3
"""FS V21 (Human PASS) -> Agent Sprite Forge map_bundle.v2 read-only bridge.

Must never touch sealed source. Explicit collision uses FS's authoritative tile grid,
already tested with its actor footbox, so ASF nav actor radius is 0 (no double inflation).
Image output and all authored assets remain PRIVATE to user.
"""
from __future__ import annotations
import json,hashlib,sys,shutil,subprocess
from pathlib import Path
from PIL import Image,ImageChops
ROOT=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
FS=Path(r"E:\GameAssetToolLab_20261023\FS_STYLE_FIRST_V21_WELL_CROP_COLLISION_20261024")
SHA=(ROOT/"reports/agent_sprite_forge_commit.txt").read_text().strip()
ASF=ROOT/"sources"/("agent-sprite-forge-"+SHA)
OUT=ROOT/"outputs"/"FS_V21_ASF_NATIVE32_BRIDGE_A03"
def sha(p:Path)->str:return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(path,destination):
 destination.parent.mkdir(parents=True,exist_ok=True)
 shutil.copyfile(path,destination)
 assert sha(path)==sha(destination)
def cmd(stage,argv):
 x=subprocess.run([str(z) for z in argv],capture_output=True,text=True,errors="replace",timeout=140)
 (ROOT/"reports"/("A03_"+stage+".log")).write_text(x.stdout+"\nSTDERR:\n"+x.stderr,encoding="utf-8")
 print(stage,"EXIT",x.returncode,(x.stdout+" "+x.stderr)[-300:])
 return x.returncode
def count_diff(a,b):
 a=Image.open(a).convert("RGBA") if isinstance(a,Path) else a
 b=Image.open(b).convert("RGBA") if isinstance(b,Path) else b
 if a.size!=b.size:return -1
 return sum(1 for x in ImageChops.difference(a,b).getdata() if x!=(0,0,0,0))
def build():
 if OUT.exists():raise RuntimeError("Output already exists, fail closed; never overwrite candidate "+str(OUT))
 OUT.mkdir(parents=True)
 m=json.loads((FS/"scene_manifest.json").read_text(encoding="utf-8-sig"))
 blocked=json.loads((FS/"build/BlockedTiles.json").read_text(encoding="utf-8-sig"))
 w,h=m["canvas"];tile=m["tile_size"]
 assert (w,h,tile)==(544,416,32)
 assert len(blocked["all_blocked_tiles"])==23
 ground=FS/"build/Ground.png"
 par=FS/"build/PAR_COMPLETE.png"
 master=FS/"build/Recomposed.png"
 assert count_diff(Image.alpha_composite(Image.open(ground).convert("RGBA"),Image.open(par).convert("RGBA")),master)==0
 cp(ground,OUT/"bundle/art/ground.png")
 props={}
 objects=[]
 source=[]
 for n,item in enumerate(m["objects"]):
  f=FS/item["authoritative_asset_path"]
  assert f.exists() and sha(f)==item["source_sha256"],f"source tamper {f}"
  im=Image.open(f).convert("RGBA")
  assert list(im.size)==[item["width"],item["height"]]
  local=[item["foot_anchor"][0]-item["x"],item["foot_anchor"][1]-item["y"]]
  assert 0<=local[0]<=im.width and 0<=local[1]<=im.height
  asset_id=item["instance_id"] # unique prop IDs to preserve exact instances
  path="props/"+asset_id+".png"
  cp(f,OUT/"bundle"/path)
  props[asset_id]={"image":path,"sha256":sha(f),"anchor_px":local,"solid":False,
                   "occlusion_class":"tall" if item["kind"] in ("tree","board") else "low"}
  objects.append({"id":asset_id,"prop":asset_id,"x":item["foot_anchor"][0],
                  "y":item["foot_anchor"][1],"anchor_px":local,"sortY":item["z_order"]})
  source.append({"id":asset_id,"source_sha256":sha(f),"position":[item["x"],item["y"]],
                 "foot_anchor":item["foot_anchor"],"local_contact":item.get("collision_local"),
                 "local_occlusion":item.get("occlusion_local"),"classification":item["kind"]})
 assert [o["sortY"] for o in objects]==sorted(o["sortY"] for o in objects)
 # Keep default Ground walkable, use exactly FS blocked-tile after footbox sampling.
 rects=[[int(c)*tile,int(r)*tile,tile,tile] for c,r in blocked["all_blocked_tiles"]]
 assert all(0<=r[0]<w and 0<=r[1]<h for r in rects)
 spawn=m["spawn_world"]
 bundle={
  "schema":"generate2dmap.map_bundle.v2",
  "id":"fs_v21_style_human_approved_bridge",
  "tile_size":[tile,tile],
  "world":{"width":w,"height":h,"unit":"px"},
  "layers":[{"name":"ground","kind":"image","image":"art/ground.png"},
            {"name":"props","kind":"objects"}],
  "props":props,"objects":objects,
  "collision":{"actorRadius":0,"ySquash":1.0,"solids":[],"rects":rects},
  "spawns":[{"id":"start","x":int(spawn[0]),"y":int(spawn[1]),"facing":"south"}],
  "camera":{"bounds":[0,0,w,h]},
  "art_source":"existing"
 }
 # Add sha256 for all linked files at map bundle schema's supported key.
 bundle["layers"][0]["sha256"]=sha(OUT/"bundle/art/ground.png")
 path=OUT/"bundle/map-bundle.json"
 path.write_text(json.dumps(bundle,ensure_ascii=False,indent=2),encoding="utf-8")
 (OUT/"fs_source_ledger.json").write_text(json.dumps({"source":"FS V21 approved real scene",
     "manifest_sha256":sha(FS/"scene_manifest.json"),"ground_sha":sha(ground),
     "par_sha":sha(par),"recomposed_sha":sha(master),"blocked_grid_sha256":sha(FS/"build/BlockedTiles.json"),
     "owner_sha256":sha(FS/"build/PixelOwner16.png"),
     "occlusion_sha256":sha(FS/"build/Occlusion.png"),"objects":source,
     "read_only":True,"rights":"PRIVATE TEST ONLY",
     "collision_note":"FS blocked tile footprint already samples 16x12 footbox; ASF actorRadius=0 prevents double expansion."},
     ensure_ascii=False,indent=2),encoding="utf-8")
 cp(FS/"build/Collision.png",OUT/"fs_reference/Collision.png")
 cp(FS/"build/Occlusion.png",OUT/"fs_reference/Occlusion.png")
 cp(FS/"build/PixelOwner16.png",OUT/"fs_reference/PixelOwner16.png")
 cp(par,OUT/"fs_reference/PAR_COMPLETE.png")
 cp(master,OUT/"fs_reference/Recomposed.png")
 return path
def main():
 bundle=build(); tool=ASF/"skills/generate2dmap/scripts"
 python=ROOT/".venv/Scripts/python.exe"
 status={}
 status["valid"]=cmd("BUNDLE_VALIDATE",[python,tool/"map_bundle.py","validate","--bundle",bundle,"--require-sha256"])==0
 # Render directly to reject false PASS if any source prop reordered/incomplete
 sys.path.insert(0,str(tool));import map_bundle
 try:
  im=map_bundle.render_map(map_bundle.load_bundle(bundle))
  Image.fromarray(im).save(OUT/"asf_render.png")
  diff=count_diff(OUT/"asf_render.png",OUT/"fs_reference/Recomposed.png")
 except Exception as ex:diff=-1;print("render_error",repr(ex))
 status["pixel_diff"]=diff
 status["pixel_recompose_pass"]=diff==0
 status["nav"]=cmd("NAV",[python,tool/"map_nav.py","check","--bundle",bundle,"--output-dir",OUT/"nav","--publish-on-fail"])==0
 status["tiled_export"]=cmd("TILED_EXPORT",[python,tool/"export_tiled.py","export","--bundle",bundle,"--output-dir",OUT/"tiled"])==0
 if status["tiled_export"]:
  status["tiled_verify"]=cmd("TILED_VERIFY",[python,tool/"export_tiled.py","verify","--map",OUT/"tiled/map.tmj","--bundle",bundle])==0
 else:status["tiled_verify"]=False
 status["pass"]=all((status["valid"],status["nav"],status["tiled_export"],status["tiled_verify"],status["pixel_recompose_pass"]))
 (ROOT/"reports/A03_BRIDGE_RESULT.json").write_text(json.dumps(status,indent=2),encoding="utf-8")
 print("FINAL:",json.dumps(status))
 if not status["pass"]:sys.exit(1)
if __name__=="__main__":main()
