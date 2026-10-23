from pathlib import Path
from PIL import Image
import json,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
P=R/"godot"/"NormalLightB0"
runs=[]
for name in ("tree","rock"):
 source=Image.open(P/(name+".png")).convert("RGBA")
 normals={provider:Image.open(P/(name+"_"+provider+"_normal.png")).convert("RGBA") for provider in ("spritefusion","laigter")}
 assert all(im.size==source.size for im in normals.values())
 alpha={k:im.getchannel("A").tobytes()==source.getchannel("A").tobytes() for k,im in normals.items()}
 images={}
 for kind in ("spritefusion","laigter","none"):
  for side in ("left","right"):
   f=P/"captures"/f"T13_{name}_{kind}_{side}.png"
   assert f.is_file(),str(f)
   im=Image.open(f).convert("RGB")
   assert im.size==(160,160)
   images[(kind,side)]=im
 w,h=source.size
 sx,sy=80-w//2,80-h//2
 alpha_px=source.getchannel("A").load()
 visible={(x+sx,y+sy) for y in range(h) for x in range(w) if alpha_px[x,y]>0}
 def compare(k1,k2):
  a=images[k1].load();b=images[k2].load()
  count_visible=0;count_background=0;sum_abs=0;max_abs=0
  for y in range(160):
   for x in range(160):
    aa=a[x,y];bb=b[x,y]
    differences=[abs(aa[k]-bb[k]) for k in range(3)]
    if max(differences)>0:
     if (x,y) in visible:count_visible+=1
     else:count_background+=1
    if (x,y) in visible:
     sum_abs+=sum(differences)
     max_abs=max(max_abs,max(differences))
  return {"changed_visible_pixels":count_visible,"changed_background_pixels":count_background,
   "max_channel_difference_visible":max_abs,"mean_abs_diff_visible":round(sum_abs/(max(1,len(visible))*3),4)}
 comps={
  "spritefusion_light_left_vs_right":compare(("spritefusion","left"),("spritefusion","right")),
  "laigter_light_left_vs_right":compare(("laigter","left"),("laigter","right")),
  "no_normal_light_left_vs_right":compare(("none","left"),("none","right")),
  "spritefusion_vs_no_normal_same_light":compare(("spritefusion","left"),("none","left")),
  "laigter_vs_no_normal_same_light":compare(("laigter","left"),("none","left")),
  "laigter_vs_spritefusion_same_light":compare(("laigter","left"),("spritefusion","left"))}
 valid=all(c["changed_visible_pixels"]>0 for c in comps.values()) and all(c["changed_background_pixels"]==0 for c in comps.values())
 runs.append({"source":name,"size":list(source.size),"normal_alpha":alpha,"comparisons":comps,"pass":valid,
 "source_sha256":hashlib.sha256((P/(name+".png")).read_bytes()).hexdigest()})
 print("T13",name,"visible counts",[(k,v["changed_visible_pixels"]) for k,v in comps.items()],"background",[(k,v["changed_background_pixels"]) for k,v in comps.items()],flush=True)
status="T13_REAL_GPU_B0_TWO_TOOLS_PASS" if all(x["pass"] for x in runs) else "T13_FAIL_CLOSED"
data={"status":status,"renderer":"Godot 4.7.2 Compatibility OpenGL3.3 AMD Radeon RX6700XT non-headless","capture_count":12,"size":[160,160],
 "pipeline":"CanvasTexture + PointLight2D + nearest","comparisons":runs,"artistic_fidelity":"HUMAN_NOT_APPROVED"}
(R/"reports"/"T13_GODOT_B0_NORMAL_COMPARE.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf8")
print("T13_RESULT",status,flush=True)
if status!="T13_REAL_GPU_B0_TWO_TOOLS_PASS":raise SystemExit(2)
