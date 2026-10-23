from pathlib import Path
from PIL import Image
import subprocess,hashlib,json,time
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
exe=Path(r"E:\GameAssetToolLab_20261023\tools\Laigter\laigter-windows\laigter.exe")
assert exe.exists()
inp=r/"inputs";out=r/"outputs"/"laigter";out.mkdir(parents=True,exist_ok=True)
# Isolate only chosen four files, no duplicate input names or transient invalids.
actual_inputs=r/"outputs"/"laigter_inputs"
actual_inputs.mkdir(parents=True,exist_ok=True)
from shutil import copy2
names=["tree","rock","sign","rock_animation_4x32"]
for name in names:copy2(inp/(name+".png"),actual_inputs/(name+".png"))
cmd=[str(exe),"--no-gui","--diffuse",str(actual_inputs),"--normal","--specular","--occlusion","--parallax","--location",str(out)]
t=time.monotonic();proc=subprocess.run(cmd,capture_output=True,text=True,errors="replace",timeout=65)
execution={"argv":cmd,"exit":proc.returncode,"elapsed_ms":round(1000*(time.monotonic()-t)),"stdout":proc.stdout[-600:],"stderr":proc.stderr[-1200:]}
if proc.returncode!=0:
 (r/"reports"/"T10_LAIGTER_B0.json").write_text(json.dumps({"status":"FAIL_COMMAND","execution":execution},indent=2),encoding="utf8")
 raise RuntimeError(proc.stderr[-500:])
entries=[]
for name in names:
 before=Image.open(actual_inputs/(name+".png")).convert("RGBA")
 for suffix in "nsop":
  target=out/(name+"_"+suffix+".png")
  assert target.is_file(),"No Laigter output "+str(target)
  img=Image.open(target).convert("RGBA")
  original_alpha=before.getchannel("A").tobytes()
  raw_alpha_equal=img.getchannel("A").tobytes()==original_alpha
  rgb_variety=len({img.getpixel((x,y))[:3] for y in range(img.height) for x in range(img.width) if before.getpixel((x,y))[3]>0})
  assert img.size==before.size
  img.putalpha(before.getchannel("A"))
  img.save(target)
  corrected=Image.open(target).convert("RGBA")
  entries.append({"source":name,"map":suffix,"size":list(img.size),"raw_alpha_equal":raw_alpha_equal,
  "fixed_alpha_equal":corrected.getchannel("A").tobytes()==original_alpha,
  "visible_rgb_unique":rgb_variety,"sha256":hashlib.sha256(target.read_bytes()).hexdigest()})
nfiles=sum(z["map"]=="n" for z in entries)
# Only normal maps must show direction variation; parallax map may legitimately be flat for source shapes.
# Keep flat source/object diagnostics visible and never silently claim an interesting 3D parallax field.
status="T10_LAIGTER_B0_16MAPS_ALPHA_PASS_WITH_PARALLAX_WARNINGS" if len(entries)==16 and nfiles==4 and all(x["fixed_alpha_equal"] for x in entries) and all(x["visible_rgb_unique"]>1 for x in entries if x["map"]=="n") else "FAIL_CLOSED"
report={"status":status,"binary_sha256":hashlib.sha256(exe.read_bytes()).hexdigest(),"execution":execution,"test_sources":names,
 "total_maps":len(entries),"raw_alpha_mismatch_count":sum(not x["raw_alpha_equal"] for x in entries),
 "all_corrected_alpha_exact":all(x["fixed_alpha_equal"] for x in entries),
 "notes":["alpha repair is an explicit postprocessing step, not native CLI correctness","normal/specular/occlusion/parallax maps are materials, not semantic Ground/PAR layers"],
 "files":entries}
(r/"reports"/"T10_LAIGTER_B0.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("T10_B0",status,"alpha_native_fail",report["raw_alpha_mismatch_count"],"/",len(entries),flush=True)
if status=="FAIL_CLOSED":raise SystemExit(2)
