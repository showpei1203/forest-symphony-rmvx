from pathlib import Path
from shutil import copy2
from PIL import Image,ImageChops
import subprocess,hashlib,json,time
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
lab=r.parent
inputs=r/"inputs";outputs=r/"outputs";logs=r/"logs";reports=r/"reports"
srcassets=lab/"FS_ForestSplit_v3_2"/"sources"
exes={"laigter":lab/"tools"/"Laigter"/"laigter-windows"/"laigter.exe","libre":lab/"tools"/"LibreSprite"/"libresprite.exe"}
lf=inputs/"laigter_real";lf.mkdir(exist_ok=True)
orig_files=[srcassets/"tree_A.png",srcassets/"tree_B.png",lab/"benchmarks"/"monster_sheet_4frames.png"]
for p in orig_files:copy2(p,lf/p.name)
def psha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def use(cmd,timeout=75):
 t=time.perf_counter();p=subprocess.run([str(x) for x in cmd],capture_output=True,text=True,errors="replace",timeout=timeout)
 return {"cmd":" ".join(map(str,cmd)),"exit":p.returncode,"elapsed_ms":int((time.perf_counter()-t)*1000),"stdout_tail":p.stdout[-1800:],"stderr_tail":p.stderr[-1800:]}
out=outputs/"laigter_real";out.mkdir(exist_ok=True)
lr=use([exes["laigter"],"--no-gui","--diffuse",lf,"--normal","--specular","--occlusion","--parallax","--location",out])
exam=[]
nonflat=0
for p in orig_files:
 source=Image.open(p).convert("RGBA")
 for suf in "nsop":
  dest=out/(p.stem+"_"+suf+".png")
  d={"origin":p.name,"target":dest.name,"exists":dest.exists()}
  if dest.exists():
   img=Image.open(dest).convert("RGBA")
   d["size_ok"]=img.size==source.size
   d["alpha_initial_equal"]=img.getchannel("A").tobytes()==source.getchannel("A").tobytes()
   rgb=img.convert("RGB")
   d["unique_rgb"]=len(set(rgb.getdata()))
   if suf=="n" and d["unique_rgb"]>1:nonflat+=1
   img.putalpha(source.getchannel("A"))
   img.save(dest)
   d["alpha_fixed_equal"]=Image.open(dest).convert("RGBA").getchannel("A").tobytes()==source.getchannel("A").tobytes()
   d["sha256"]=psha(dest)
  exam.append(d)
pass2=lr["exit"]==0 and all(z.get("alpha_fixed_equal",False) and z.get("size_ok",False) for z in exam) and nonflat==3 and len(exam)==12
(report2:=reports/"T02_LAIGTER_REAL_ASSETS.json").write_text(json.dumps({"tool":"Laigter 1.14","status":"SMOKE_PASS" if pass2 else "FAIL","runs":[lr],"files":exam,"normal_nonflat_count":nonflat,"visual": "UNVERIFIED"},indent=2,ensure_ascii=False),encoding="utf8")
print("T02_LAIGTER", "PASS" if pass2 else "FAIL","files",len(exam),"normal_variation",nonflat,flush=True)
# LibreSprite image conversion and per-frame from 128x32 sheet; slicer is our deterministic helper not a native split feature.
libreout=outputs/"libresprite";libreout.mkdir(exist_ok=True)
sheet=Image.open(lab/"benchmarks"/"monster_sheet_4frames.png").convert("RGBA")
libre_in=inputs/"libresprite";libre_in.mkdir(exist_ok=True)
sheet.save(libre_in/"sheet.png")
fr=[]
for i in range(4):
 s=sheet.crop((32*i,0,32*(i+1),32))
 s.save(libre_in/f"frame_{i:02d}.png")
runs=[];matches=[]
for f in [libre_in/"sheet.png",*(libre_in/f"frame_{i:02d}.png" for i in range(4))]:
 target=libreout/(f.stem+".png")
 rr=use([exes["libre"],"-b",f,"--save-as",target],timeout=35)
 runs.append(rr)
 if target.exists():
  a=Image.open(f).convert("RGBA");b=Image.open(target).convert("RGBA")
  matches.append({"name":f.name,"size":a.size,"rgba_exact":a.tobytes()==b.tobytes(),"source_sha256":psha(f),"output_sha256":psha(target)})
 else:matches.append({"name":f.name,"exists":False})
rep5={"tool":"LibreSprite 1.3","status":"SMOKE_PASS" if all(x.get("rgba_exact",False) for x in matches) else "FAIL",
 "tests":matches,"runs":runs,
 "note":"4 frame sheet slicing was performed deterministically by Pillow, not LibreSprite automatic timeline import; must not claim LibreSprite auto-inferred four frames."}
(reports/"T05_LIBRESPRITE_SHEET.json").write_text(json.dumps(rep5,indent=2,ensure_ascii=False),encoding="utf8")
print("T05_LIBRESPRITE",rep5["status"],"RGBA_EXACT",sum(x.get("rgba_exact",False) for x in matches),"/",len(matches),flush=True)
if not pass2 or rep5["status"]=="FAIL":raise SystemExit(2)
