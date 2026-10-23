from pathlib import Path
import zipfile,json,subprocess,time,hashlib
from PIL import Image
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
orig=r/"pixelorama"/"animated_layer_effect.pxo"
dest=r/"pixelorama"/"animated_no_effects.pxo"
out=r/"outputs"/"pixelorama_animated_clean";out.mkdir(exist_ok=True)
with zipfile.ZipFile(orig) as z,zipfile.ZipFile(dest,"w") as new:
 o=json.loads(z.read("data.json"))
 o["layers"][0]["effects"]=[]
 if "export_profile" in o:
  o["export_profile"]["directory_path"]=json.dumps(str(out).replace("\\","/"))
  o["export_profile"]["file_name"]=json.dumps("6frames_clean")
  o["export_profile"]["number_of_frames"]="6"
  o["export_profile"]["orientation"]="0"
 for item in z.infolist():
  blob=json.dumps(o,separators=(",",":"),ensure_ascii=False).encode("utf8") if item.filename=="data.json" else z.read(item.filename)
  new.writestr(item,blob)
e=r.parent/"tools"/"Pixelorama"/"Pixelorama-Windows-64bit"/"Pixelorama.exe"
runs=[]
def test(name,args):
 start=time.perf_counter()
 p=subprocess.run([str(e),"--headless","--quit","--",*map(str,args)],capture_output=True,text=True,errors="replace",timeout=45)
 (r/"logs"/(name+".log")).write_text(p.stdout+"\n"+p.stderr,encoding="utf8")
 runs.append({"test":name,"exit":p.returncode,"elapsed_ms":int((time.perf_counter()-start)*1000),"stdout_tail":p.stdout[-800:],"stderr_tail":p.stderr[-800:]})
 print(name,p.returncode,p.stdout[-100:],flush=True)
test("T03_CLEAN_SIZE",["--size",dest])
test("T03_CLEAN_FRAMECOUNT",["--framecount",dest])
test("T03_CLEAN_SPRITESHEET",["--spritesheet","--export",dest])
images=[]
for f in out.glob("*.png"):
 im=Image.open(f).convert("RGBA")
 images.append({"file":f.name,"dimensions":im.size,"alpha":im.getchannel("A").getextrema(),
  "sha256":hashlib.sha256(f.read_bytes()).hexdigest()})
passed=all(x["exit"]==0 for x in runs) and any(z["dimensions"][0]>=64*6 and z["dimensions"][1]>=64 for z in images)
rep={"tool":"Pixelorama v1.2.3","status":"CLEAN_PXO_SPRITESHEET_PASS" if passed else "BLOCKED","source":str(orig),"modified":str(dest),"preprocess":"removed shader layer effects from official six-frame sample; modified only test PXO","frames":6,"images":images,"runs":runs}
(r/"reports"/"T03_PIXELORAMA_NO_EFFECTS.json").write_text(json.dumps(rep,ensure_ascii=False,indent=2),encoding="utf8")
print("T03_CLEAN",rep["status"],images,flush=True)
if not passed:raise SystemExit(2)
