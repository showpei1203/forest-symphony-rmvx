from pathlib import Path
from PIL import Image
import numpy as np,json
r=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A11_LAYERED_RIG")
record=json.loads((r/"A11_NATIVE_GPU_QA.json").read_text(encoding="utf8"))
cases={"T1":{"dir":"T1_forest_scout","sz":[96,112],"anchor":[48,104]},"T2":{"dir":"T2_moss_antler","sz":[96,96],"anchor":[48,88]}}
qa=[]
for snap in record["captures"]:
 shot=Image.open(r/(snap["file"].split("/")[-1])).convert("RGB")
 bg=shot.getpixel((0,0))
 for i,item in enumerate(snap["states"]):
  case=item["case"];act=str(item["action"]);frame=int(item["frame"]); x=int(item["x"]);y=int(item["y"])
  info=cases[case];W,H=info["sz"];ax,ay=info["anchor"]
  manifest=json.loads((r/info["dir"]/"clips.json").read_text(encoding="utf8"))
  source_index=manifest["clips"][act]["frames"][frame]
  source_file=manifest["frames"][source_index]["file"]
  p=r/info["dir"]/source_file
  assert p.exists(),(case,act,frame,source_file)
  src=Image.open(p).convert("RGBA")
  expected=Image.new("RGBA",(W,H),(*bg,255))
  expected.alpha_composite(src)
  actual=shot.crop((x-ax,y-ay,x-ax+W,y-ay+H))
  delta=np.abs(np.asarray(expected.convert("RGB"),dtype=np.int16)-np.asarray(actual,dtype=np.int16))
  qa.append({"case":case,"action":act,"capture":snap["file"],"frame":frame,
  "max_RGB_delta":int(delta.max()),"different_pixels":int(np.any(delta!=0,axis=2).sum())})
result={"status":"TECH_PASS" if len(qa)==22 and all(x["different_pixels"]==0 for x in qa) else "FAIL",
 "samples":len(qa),"exact_pixels":sum(x["different_pixels"]==0 for x in qa),
 "source":"A11 layered attack source frames vs real Godot GPU screenshot, 1x", "details":qa}
(r/"A11_GODOT_PIXEL_PARITY.json").write_text(json.dumps(result,indent=2),encoding="utf8")
print(json.dumps({"status":result["status"],"samples":result["samples"],"exact":result["exact_pixels"],"issues":[x for x in qa if x["different_pixels"]]},indent=2))