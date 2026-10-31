from pathlib import Path
from PIL import Image
import numpy as np, subprocess,json,hashlib,zipfile
b=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_KEYPOSE_REDRAW")
exe=r"E:\GameAssetToolLab_20261023\tools\LibreSprite\libresprite.exe"
entries=[("T1_forest_scout",2),("T1_forest_scout",5),("T2_moss_antler",3),("T2_moss_antler",5)]
results={}
for name,frame in entries:
    key=f"{name}_attack_{frame:02}"
    src=b/name/f"attack_{frame:02}_A16_KEY_R2.png"
    native=b/name/f"attack_{frame:02}_A16_KEY_R2.ase"
    out=b/name/f"attack_{frame:02}_R2_LIBRESPRITE_ROUNDTRIP.png"
    if not native.exists() or native.stat().st_size==0:
        cmd=[exe,"-b",str(src),"--save-as",str(native)]
        p=subprocess.run(cmd,timeout=30,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        print(key,"create native",p.returncode,p.stdout.decode(errors="replace")[:250])
    p=subprocess.run([exe,"-b",str(native),"--save-as",str(out)],timeout=30,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    print(key,"convert back",p.returncode,p.stdout.decode(errors="replace")[:250])
    diff=None
    if out.exists():
        a=np.asarray(Image.open(src).convert("RGBA"));q=np.asarray(Image.open(out).convert("RGBA"))
        diff=int(np.count_nonzero(np.any(a!=q,axis=2))) if a.shape==q.shape else -1
    results[key]={"original_exists":src.exists(),"native_exists":native.exists(),"native_bytes":native.stat().st_size if native.exists() else 0,
      "roundtrip_exists":out.exists(),"rgba_pixel_diff":diff,"pixel_parity_pass":diff==0,
      "native_sha256":hashlib.sha256(native.read_bytes()).hexdigest() if native.exists() else None}
    print(key,"DIFF",diff)
(b/"A16_R2_LIBRESPRITE_QA.json").write_text(json.dumps(results,indent=2,ensure_ascii=False),encoding="utf-8")
names=["a16_keypose_redraw_r2.py","verify_a16_libresprite.py","A16_R2_QA.json","A16_R2_LIBRESPRITE_QA.json","A16_R2_HANDOFF.md","A16_R2_COMPARE_1X.png","A16_R2_COMPARE_3X.png","A16_R2_COMPARE_6X.png"]
files=[b/x for x in names]
for name,frame in entries:
    files.extend([b/name/f"attack_{frame:02}_A16_KEY_R2.png",b/name/f"attack_{frame:02}_A16_KEY_R2.ase"])
archive=b/"A16_R2_PRIVATE_KEYPOSE_CANDIDATE.zip"
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
    for f in files: z.write(f,f.relative_to(b))
with zipfile.ZipFile(archive) as z:
    bad=z.testzip();members=len(z.namelist())
print("ZIP",archive,archive.stat().st_size,members,"CRC_BAD",bad,"SHA256",hashlib.sha256(archive.read_bytes()).hexdigest())
print("ALL PARITY",all(v["pixel_parity_pass"] for v in results.values()))
