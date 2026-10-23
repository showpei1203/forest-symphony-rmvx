# -*- coding: utf-8 -*-
"""T15B real B0 distinct 6 frames + Pixelorama GPU shader end-to-end."""
import json,zipfile,hashlib,subprocess,sys,time
from pathlib import Path
from PIL import Image,ImageChops
base=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
root=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_T15_20261024")
app=base.parent/"tools/Pixelorama/Pixelorama-Windows-64bit/Pixelorama.exe"
src=base/"inputs/pixelorama/b0_tree_six_unique.pxo"
ex=base/"inputs/pixelorama/official_animated_layer_effect.pxo"
with zipfile.ZipFile(ex) as zin:
    effects=json.loads(zin.read("data.json"))["layers"][0]["effects"]
def file_sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def variant(name,enable):
    dst=root/"inputs"/("b0_"+name+".pxo")
    out=root/"outputs"/("b0_"+name);out.mkdir(parents=True,exist_ok=True)
    for p in out.glob("*.png"):p.unlink()
    with zipfile.ZipFile(src) as z,zipfile.ZipFile(dst,"w") as w:
        for info in z.infolist():
            data=z.read(info.filename)
            if info.filename=="data.json":
                j=json.loads(data)
                j["layers"][0]["effects"]=[dict(fx,enabled=enable) for fx in effects]
                j["export_profile"]["directory_path"]=json.dumps(out.as_posix())
                j["export_profile"]["file_name"]=json.dumps("b0_"+name)
                j["export_profile"]["number_of_frames"]="6"
                data=json.dumps(j,ensure_ascii=False,separators=(",",":")).encode("utf-8")
            w.writestr(info,data)
    t=time.time()
    cp=subprocess.run([str(app),"--quit","--","--spritesheet","--export",str(dst)],capture_output=True,text=True,errors="replace",timeout=16,creationflags=0x08000000)
    log=cp.stdout+"\n"+cp.stderr
    (root/"logs"/("b0_"+name+".log")).write_text(log,encoding="utf-8")
    files=list(out.glob("*.png"))
    return {"variant":name,"exit":cp.returncode,"duration_s":round(time.time()-t,2),"files":[str(p) for p in files],
            "output_sha256":file_sha(files[0]) if len(files)==1 else None,
            "gpu_real":("AMD Radeon RX 6700 XT" in log and "Dummy" not in log),"log_tail":log[-800:]}
runs=[variant("clean",False),variant("effects",True)]
result={"test":"T15B real B0 six distinct frames GPU effects","runs":runs}
try:
    assert all(r["exit"]==0 and r["gpu_real"] and len(r["files"])==1 for r in runs)
    a=Image.open(runs[0]["files"][0]).convert("RGBA")
    b=Image.open(runs[1]["files"][0]).convert("RGBA")
    source=Image.open(base/"inputs/tree_animation_6frames.png").convert("RGBA")
    assert a.size==b.size==source.size==(384,96),(a.size,b.size,source.size)
    result["clean_source_exact"]=a.tobytes()==source.tobytes()
    assert result["clean_source_exact"],"unmodified control not exact source"
    diffs=[]; interframes=[]
    for i in range(6):
        crop_a=a.crop((i*64,0,(i+1)*64,96))
        crop_b=b.crop((i*64,0,(i+1)*64,96))
        pixels_a=list(crop_a.getdata());pixels_b=list(crop_b.getdata())
        diffs.append(sum(pa!=pb for pa,pb in zip(pixels_a,pixels_b)))
        if i: interframes.append(sum(p!=q for p,q in zip(pixels_a,prior)))
        prior=pixels_a
    result["per_frame_effect_changed_rgba_pixels"]=diffs
    result["successive_clean_unique_frame_diffs"]=interframes
    assert min(diffs)>0 and min(interframes)>0
    # No resampling, side by side B0 visual QA contact (nearest only).
    preview=Image.new("RGBA",(768,96),(0,0,0,0))
    preview.paste(a,(0,0));preview.paste(b,(384,0))
    preview.save(root/"outputs/T15B_B0_CLEAN_VS_EFFECTS.png")
    result["status"]="T15B_B0_SIX_UNIQUE_FRAMES_EFFECT_GPU_PASS"
except Exception as e:
    result["status"]="T15B_FAIL_CLOSED";result["error"]=repr(e)
(root/"T15B_PIXELORAMA_B0_SHADER.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps(result,ensure_ascii=False,indent=2),flush=True)
sys.exit(0 if result["status"].endswith("_PASS") else 2)
