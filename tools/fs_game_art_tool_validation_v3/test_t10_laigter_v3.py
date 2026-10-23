from pathlib import Path
from shutil import copy2
from PIL import Image
import hashlib,json,subprocess,time,sys
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
EXE=R.parent/"tools"/"Laigter"/"laigter-windows"/"laigter.exe"
folder=R/"inputs"/"laigter";folder.mkdir(parents=True,exist_ok=True)
output=R/"outputs"/"laigter";output.mkdir(parents=True,exist_ok=True)
names=["tree","rock","sign","tree_animation_6frames"]+[f"tree_frame_{i:02d}" for i in range(6)]
for name in names:copy2(R/"inputs"/(name+".png"),folder/(name+".png"))
arg=[str(EXE),"--no-gui","--diffuse",str(folder),"--normal","--specular","--occlusion","--parallax","--location",str(output)]
t=time.perf_counter()
p=subprocess.run(arg,capture_output=True,text=True,errors="replace",timeout=90)
report={"exe":str(EXE),"exe_sha256":hashlib.sha256(EXE.read_bytes()).hexdigest(),
"cmd":arg,"exit":p.returncode,"duration_ms":int((time.perf_counter()-t)*1000),"stderr":p.stderr[-1000:],"stdout":p.stdout[-1000:],"tests":[]}
for name in names:
 src=Image.open(folder/(name+".png")).convert("RGBA")
 for suffix in ("n","s","o","p"):
  q=output/(name+"_"+suffix+".png")
  item={"source":name,"map":suffix,"present":q.exists()}
  if q.exists():
   im=Image.open(q).convert("RGBA")
   item["size_match"]=im.size==src.size
   item["raw_alpha_match"]=im.getchannel("A").tobytes()==src.getchannel("A").tobytes()
   item["raw_sha"]=hashlib.sha256(q.read_bytes()).hexdigest()
   if im.size==src.size:
    im.putalpha(src.getchannel("A"))
    im.save(q)
   item["repaired_alpha_match"]=im.getchannel("A").tobytes()==src.getchannel("A").tobytes()
   item["rgb_distinct_visible"]=len(set(px[:3] for px in im.getdata() if px[3]>0))
   item["final_sha"]=hashlib.sha256(q.read_bytes()).hexdigest()
  report["tests"].append(item)
# Six-frame atlas vs six independently derived maps; a seam leak means use isolated-frame inputs.
all_img=Image.open(output/"tree_animation_6frames_n.png").convert("RGBA")
other=Image.new("RGBA",all_img.size,(0,0,0,0))
for i in range(6):
 frame=Image.open(output/(f"tree_frame_{i:02d}_n.png")).convert("RGBA")
 other.paste(frame,(i*64,0))
diff=0;visible=0;seam=0
for y in range(all_img.height):
 for x in range(all_img.width):
  a=all_img.getpixel((x,y));b=other.getpixel((x,y))
  if a[3]==0 and b[3]==0:continue
  visible+=1
  if a!=b:
   diff+=1
   if (x%64)<4 or (x%64)>59:seam+=1
report["sheet_vs_individual_visible_diff"]=diff
report["seam_band_diff"]=seam
report["visible_pixels"]=visible
report["output_count"]=len(report["tests"])
allpass=p.returncode==0 and len(report["tests"])==40 and all(t.get("size_match") and t.get("repaired_alpha_match") for t in report["tests"])
report["status"]="T10_LAIGTER_B0_BATCH_PASS_SHEET_EQUIVALENCE_NOT_ASSUMED" if allpass else "T10_FAIL_CLOSED"
report["recommendation"]="Generate animation frame normal maps individually if sheet differences appear. Different alpha must be repaired from canonical source. Never use Laigter parallax output as an RMVX Ground/PAR semantic mask."
(R/"reports"/"T10_LAIGTER_B0_BATCH.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf8")
print("T10",report["status"],"maps",len(report["tests"]),"sheet_v_frame_diff",diff,"seam_band_diff",seam,"raw_alpha_mismatch",sum(not t.get("raw_alpha_match",True) for t in report["tests"]),flush=True)
if not allpass:sys.exit(2)
