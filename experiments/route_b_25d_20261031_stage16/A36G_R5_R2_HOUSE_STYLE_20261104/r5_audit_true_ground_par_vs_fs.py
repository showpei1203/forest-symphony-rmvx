from pathlib import Path
from PIL import Image
import hashlib,json,numpy as np
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
O=Path("E:/遊戲專案開發/三大項目現行專案/FS project")
files={
 "FS_original_Ground3":O/"Graphics/Parallaxes/ground3.png",
 "FS_original_PAR3":O/"Overlays/par3.png",
 "FS_effect_not_Ground3":O/"Overlays/ground3.png",
 "R5_ground":R/"A36G_R5_GROUND_1280x928.png",
 "R5_PAR":R/"A36G_R5_PAR50_RGBA_1280x928.png",
 "R5_composite":R/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"
}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
data={}
for n,p in files.items():
 if not p.exists():data[n]={"missing":str(p)};continue
 im=Image.open(p)
 v=np.asarray(im.convert("RGBA"),np.uint8)
 alpha=v[:,:,3]
 data[n]={"path":str(p),"sha256":sha(p),"size":im.size,"mode":im.mode,
 "alpha_nonzero_ratio":round(float(np.mean(alpha>0)),6),
 "alpha_full_ratio":round(float(np.mean(alpha==255)),6),
 "alpha_colors":[int(alpha.min()),int(alpha.max())]}
def relate(gkey,pkey):
 if not all(k in data and not data[k].get("missing") for k in (gkey,pkey)):return
 g=np.asarray(Image.open(files[gkey]).convert("RGBA"),np.uint8)
 p=np.asarray(Image.open(files[pkey]).convert("RGBA"),np.uint8)
 strong=p[:,:,3]>=200
 exact=int(np.all(g[:,:,:3][strong]==p[:,:,:3][strong],axis=1).sum())
 number=int(strong.sum())
 data["RELATION_"+gkey+"_"+pkey]={"alpha_gt200_px":number,"same_RGB_px":exact,
 "match_pct":round(100*exact/max(number,1),4)}
relate("FS_original_Ground3","FS_original_PAR3")
relate("FS_effect_not_Ground3","FS_original_PAR3")
relate("R5_ground","R5_PAR")
relate("R5_composite","R5_PAR")
if all(k in data and not data[k].get("missing") for k in ("R5_ground","R5_composite")):
 g=np.asarray(Image.open(files["R5_ground"]).convert("RGB"),np.uint8)
 c=np.asarray(Image.open(files["R5_composite"]).convert("RGB"),np.uint8)
 diff=np.any(g!=c,axis=2)
 data["R5_ground_vs_full_scene"]={"changed_pixels":int(diff.sum()),
 "changed_pct":round(100*float(diff.mean()),4),
 "unchanged_pct":round(100*(1-float(diff.mean())),4)}
 for name,rect in {"left_house":(353,209,637,468),"right_house":(743,376,999,648),"west_forest":(0,0,398,520)}.items():
  x0,y0,x1,y1=rect
  data["R5_ground_vs_full_scene"][name+"_changed_pct"]=round(100*float(diff[y0:y1,x0:x1].mean()),3)
src=R/"A36G_R5_SCENE_MANIFEST.json"
if src.exists():
 m=json.loads(src.read_text("utf8"))
 data["R5_SceneManifest"]={"stage":m["stage"],"object_count":len(m["objects"]),
 "sprite_category_counts":{v:sum(o["type"]==v for o in m["objects"]) for v in sorted({o["type"] for o in m["objects"]})}}
(R/"A36G_R5_GROUND_PAR_LEGACY_FORENSIC.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),"utf8")
print(json.dumps(data,ensure_ascii=False,indent=2),flush=True)
