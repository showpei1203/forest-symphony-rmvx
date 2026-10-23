# -*- coding: utf-8 -*-
"""T15 Pixelorama shader CLI/GPU isolated validation. Never touches SEALED maps/scripts."""
from pathlib import Path
from PIL import Image, ImageChops
import subprocess, zipfile, json, time, hashlib, shutil, traceback, sys
ROOT=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_T15_20261024")
BASE=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
SRC=BASE/"inputs/pixelorama/official_animated_layer_effect.pxo"
APP=BASE.parent/"tools/Pixelorama/Pixelorama-Windows-64bit/Pixelorama.exe"
ROOT.mkdir(exist_ok=True,parents=True)
(INPUT:=ROOT/"inputs").mkdir(exist_ok=True)
(OUTPUT:=ROOT/"outputs").mkdir(exist_ok=True)
(LOGS:=ROOT/"logs").mkdir(exist_ok=True)
def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def make_variant(kind,driver):
    folder=OUTPUT/(driver+"_"+kind);folder.mkdir(exist_ok=True)
    for f in folder.glob("*.png"): f.unlink()
    target=INPUT/(driver+"_"+kind+".pxo")
    with zipfile.ZipFile(SRC) as zin, zipfile.ZipFile(target,"w") as zout:
        for info in zin.infolist():
            raw=zin.read(info.filename)
            if info.filename=="data.json":
                j=json.loads(raw)
                for fx in j["layers"][0]["effects"]:
                    fx["enabled"]=(kind=="both" or kind=="offset" and "Offset" in fx["name"] or kind=="outline" and "Outline" in fx["name"])
                j["export_profile"]["directory_path"]=json.dumps(folder.as_posix())
                j["export_profile"]["file_name"]=json.dumps(kind)
                j["export_profile"]["number_of_frames"]="6"
                raw=json.dumps(j,separators=(",",":"),ensure_ascii=False).encode("utf-8")
            zout.writestr(info,raw)
    return target, folder
def launch(kind,driver):
    pxo,folder=make_variant(kind,driver)
    opts=[] if driver=="default" else ["--rendering-driver","opengl3"]
    cmd=[str(APP),*opts,"--quit","--","--spritesheet","--export",str(pxo)]
    t=time.time()
    try:
        run=subprocess.run(cmd,capture_output=True,text=True,errors="replace",timeout=18,creationflags=0x08000000)
        exit_code=run.returncode;out=run.stdout+"\n"+run.stderr;timeout=False
    except subprocess.TimeoutExpired as e:
        exit_code=None;out="TIMEOUT 18 sec\n"+str(e);timeout=True
    (LOGS/(driver+"_"+kind+".log")).write_text(out,encoding="utf-8")
    images=[]
    for p in folder.glob("*.png"):
        try:
            with Image.open(p) as im:
                rgba=im.convert("RGBA")
                slots=[rgba.crop((i*64,0,(i+1)*64,64)) for i in range(6)] if rgba.size==(384,64) else []
                diff=[sum(1 for v in ImageChops.difference(slots[i],slots[0]).convert("RGBA").getdata() if v[:3]!=(0,0,0)) for i in range(1,6)] if slots else []
                images.append({"name":p.name,"size":list(rgba.size),"sha256":sha(p),"frame0_visible_diffs":diff})
        except Exception as e: images.append({"name":p.name,"error":str(e)})
    row={"variant":kind,"driver":driver,"exit":exit_code,"timeout":timeout,"seconds":round(time.time()-t,2),
         "command":cmd,"input_sha256":sha(pxo),"files":images,"log_tail":out[-2200:],
         "gpu_driver_indication":"Dummy" if "Dummy" in out else "real_or_unknown"}
    print(driver,kind,"rc=",exit_code,"secs=",row["seconds"],"png=",len(images),"render=",row["gpu_driver_indication"],flush=True)
    return row
rows=[]
for v in ["none","both","offset","outline"]:
    rows.append(launch(v,"default"))
# A real renderer candidate must export effect pixels unlike the disabled control.
def effect_pass(driver):
    by={x["variant"]:x for x in rows if x["driver"]==driver}
    control=by.get("none")
    if not control or control["exit"]!=0 or len(control["files"])!=1:return False
    ref=control["files"][0].get("sha256")
    return any(by.get(v,{}).get("exit")==0 and len(by[v]["files"])==1 and by[v]["files"][0].get("sha256")!=ref for v in ["both","offset","outline"])
if not effect_pass("default"):
    for v in ["none","both","offset","outline"]:
        rows.append(launch(v,"opengl3"))
gpu_ok=effect_pass("default") or effect_pass("opengl3")
failure_log=" | ".join(x["variant"]+":"+str(x["exit"]) for x in rows)
summary={"status":"T15_EFFECTS_RENDER_EXPORT_PASS" if gpu_ok else "T15_EFFECTS_RENDER_EXPORT_NOT_VERIFIED",
         "original_pxo_sha256":sha(SRC),"pixelorama_sha256":sha(APP),"runs":rows,
         "checks":{"effect_pixels_differ_clean_and_exit0":gpu_ok,"all_exports_have_fresh_files":all(bool(x["files"]) for x in rows)},
         "limits":"Effect export judged only by process exit + real pixel differences, no artistic approval. Native GUI manual clicking not automatically verified.",
         "map_sealed_scripts_changed":False}
(ROOT/"T15_PIXELORAMA_GPU_DIAGNOSTIC.json").write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding="utf-8")
print("FINAL",summary["status"],"RUNS",len(rows),flush=True)
sys.exit(0)
