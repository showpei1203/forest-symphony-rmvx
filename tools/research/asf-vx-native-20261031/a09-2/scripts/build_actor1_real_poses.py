from pathlib import Path
from PIL import Image
import hashlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
base=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
out=root/"a09_2_actor_poses"; out.mkdir(exist_ok=True)
frames=out/"frames";frames.mkdir(exist_ok=True)
data=json.loads((root/"actor1_binding_a09_2.json").read_text(encoding="utf-8"))
poses=data["actor_specific_pose_details"]
full=json.loads((root/"tankentai_pose_coverage_conditional.json").read_text(encoding="utf-8"))
lookup={p["name"]:p for p in full["poses"]}
manifest={"schema":"generate2dsprite.animation_clips.v2","frames":[],"anchor_px":[16,21],
"clips":{},"states":{},"sampling":"nearest","pixel_art":True,"art_source":"existing","placeholder":False,
"role":"player"}
author=[]
idx={}
for n,v in enumerate(poses):
 p=lookup[v["name"]];number=p["file_no"];row=p["row"];fixed=p["fixed"]
 src=base/"Graphics"/"Characters"/(f"$actor01_{number}.png" if number else "$actor01.png")
 assert src.exists(),f"missing actual image: {src}"
 im=Image.open(src).convert("RGBA")
 assert im.size==(96,128)
 needed=[fixed] if fixed in (0,1,2) else [0,1,2]
 tids=[]
 for col in needed:
  tile=im.crop((col*32,row*32,(col+1)*32,(row+1)*32))
  assert tile.getchannel("A").getbbox(),f"MISSING ORIGINAL POSE: {v['name']} FileNo={number} Row={row} col={col}"
  f=f"pose{n:02d}-f{col}.png"; tile.save(frames/f)
  key=f"p{n:02d}c{col}"
  idx[key]=len(manifest["frames"])
  tids.append(idx[key]);manifest["frames"].append({"name":key,"file":"frames/"+f})
 if p["loop"]==0 and len(tids)==3: tids=[tids[0],tids[1],tids[2],tids[1]]
 if p["loop"]==1: loop_policy="cycle"
 elif p["loop"]==0:loop_policy="cycle"
 else:loop_policy="oneshot"
 ticks=int(p["speed"])+1
 clip=f"p{n:02d}"
 manifest["clips"][clip]={"frames":tids,"ticks":[ticks]*len(tids),"loop_policy":loop_policy,
 "role":"player"}
 author.append({"clip_id":clip,"pose_key":v["name"],"filename":src.name,"file_no":number,
 "row":row,"fixed":fixed,"speed":p["speed"],"tick_hz":60,"ticks_per_cell":ticks,
 "loop":p["loop"],"clip_frames":tids,"original_image_sha256":hashlib.sha256(src.read_bytes()).hexdigest(),
 "no_regeneration":True})
manifest["states"]={"idle":"p05","attacking":"p01"}
(out/"clips.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
(out/"native_pose_lineage.json").write_text(json.dumps(author,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"unique_frame_count":len(manifest["frames"]),"clip_count":len(manifest["clips"]),"lineage":[{"clip":p["clip_id"],"key":p["pose_key"],"file":p["filename"],"row":p["row"],"fixed":p["fixed"],"ticks":p["ticks_per_cell"]} for p in author]},ensure_ascii=True,indent=2))