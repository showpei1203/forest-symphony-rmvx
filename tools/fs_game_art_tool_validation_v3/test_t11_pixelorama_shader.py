from pathlib import Path
from PIL import Image
import zipfile,json,hashlib,subprocess,time,sys
ROOT=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
SOURCE=ROOT/"inputs"/"pixelorama"/"official_animated_layer_effect.pxo"
TOOL=ROOT.parent/"tools"/"Pixelorama"/"Pixelorama-Windows-64bit"/"Pixelorama.exe"
work=ROOT/"inputs"/"pixelorama";work.mkdir(parents=True,exist_ok=True)
base=ROOT/"outputs"/"pixelorama";base.mkdir(parents=True,exist_ok=True)
kinds={
 "original_effects":lambda e:e,
 "disabled_both":lambda e:[dict(item,enabled=False) for item in e],
 "disabled_offset":lambda e:[dict(item,enabled=False) if "Offset" in item.get("name","") else item for item in e],
 "disabled_outline":lambda e:[dict(item,enabled=False) if "Outline" in item.get("name","") else item for item in e],
 "strip_shader_effects":lambda e:[],
}
results=[]
for kind,fn in kinds.items():
 out=base/kind;out.mkdir(exist_ok=True)
 for prior in out.glob("*.png"):prior.unlink()
 pxo=work/(kind+".pxo")
 with zipfile.ZipFile(SOURCE) as zin,zipfile.ZipFile(pxo,"w") as zout:
  for info in zin.infolist():
   payload=zin.read(info.filename)
   if info.filename=="data.json":
    js=json.loads(payload)
    js["layers"][0]["effects"]=fn(js["layers"][0]["effects"])
    js["export_profile"]["directory_path"]=json.dumps(out.as_posix())
    js["export_profile"]["file_name"]=json.dumps(kind)
    js["export_profile"]["number_of_frames"]="6"
    payload=json.dumps(js,ensure_ascii=False,separators=(",",":")).encode("utf8")
   zout.writestr(info,payload)
 t=time.perf_counter()
 args=[str(TOOL),"--headless","--quit","--","--spritesheet","--export",str(pxo)]
 try:
  run=subprocess.run(args,capture_output=True,text=True,errors="replace",timeout=22)
  rc=run.returncode;logs=run.stdout+"\n"+run.stderr;timed_out=False
 except subprocess.TimeoutExpired as e:
  rc=None;logs=str(e);timed_out=True
 image_files=[]
 for p in out.glob("*.png"):
  try:
   im=Image.open(p); image_files.append({"file":p.name,"size":im.size,"sha":hashlib.sha256(p.read_bytes()).hexdigest()})
  except Exception as e:image_files.append({"file":p.name,"error":str(e)})
 row={"variant":kind,"effects":[(x.get("name"),x.get("enabled")) for x in fn(json.loads(zipfile.ZipFile(SOURCE).read("data.json"))["layers"][0]["effects"])],
 "exit":rc,"elapsed_ms":round((time.perf_counter()-t)*1000),"timeout":timed_out,"outputs":image_files,"pxo_sha":hashlib.sha256(pxo.read_bytes()).hexdigest(),"log_tail":logs[-1100:]}
 results.append(row)
 (ROOT/"reports"/("T11_"+kind+".log")).write_text(logs,encoding="utf8")
 print("T11",kind,"exit",rc,"outputs",len(image_files),"ms",row["elapsed_ms"],flush=True)
# Test records genuine outcome. One valid clean exported 6frame control required; shaders may crash; do not hide.
clean=next(i for i in results if i["variant"]=="strip_shader_effects")
rows={x["variant"]:x for x in results}
passed=clean["exit"]==0 and rows["disabled_both"]["exit"]==0 and all(rows[k]["exit"] not in (None,0) for k in ("original_effects","disabled_offset","disabled_outline")) and all(any(q.get("size")==[384,64] or q.get("size")==(384,64) for q in rows[k]["outputs"]) for k in ("disabled_both","strip_shader_effects"))
status="T11_SHADER_VARIANTS_DIAGNOSED_CLEAN_ANIMATION_PASS" if passed else "T11_FAIL_CLOSED_CLEAN_EXPORT"
result={"status":status,"tool":"Pixelorama 1.2.3","original_official_test_pxo_sha":hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
 "results":results,"claim":"These samples isolate shader effect headless behavior only; per-variant output reported, never infer full shader support from clean export."}
(ROOT/"reports"/"T11_PIXELORAMA_SHADER_VARIANTS.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("T11_RESULT",status,flush=True)
if not passed:sys.exit(2)
