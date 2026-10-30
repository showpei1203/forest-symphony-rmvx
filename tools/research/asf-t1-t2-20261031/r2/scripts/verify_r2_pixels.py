from pathlib import Path
from PIL import Image
import numpy as np,hashlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\T1T2_NEW_PIPELINE")
report=json.loads((root/"R2_GODOT_NATIVE_EVIDENCE.json").read_text(encoding="utf-8"))
names=[("T1_hero",n) for n in ("idle","walk","run","attack","hurt","jump")]
names += [("T2_monster",n) for n in ("idle","walk","attack","hurt","faint")]
shots={i:Image.open(root/f"R2_NATIVE_GODOT_{i}.png").convert("RGB") for i in ("A","B")}
bg=shots["A"].getpixel((0,0))
details=[]
for j,(case,act) in enumerate(names):
    x=(60+j*130) if j<6 else (62+(j-6)*155)
    y=100 if j<6 else 275
    w,h=(48,64) if j<6 else (48,48)
    anchor=(24,61) if j<6 else (24,45)
    masks=[]
    for cap,shot in shots.items():
        k=0 if cap=="A" else 1
        recorded=report["captures"][k]["state"][j]
        assert recorded["clip"]==act
        index=recorded["frame"]
        png=root/case/"r2"/"frames"/f"{act}_{index:02d}.png"
        src=Image.open(png).convert("RGBA")
        exp=Image.new("RGBA",src.size,(*bg,255));exp.alpha_composite(src)
        crop=shot.crop((x-anchor[0],y-anchor[1],x-anchor[0]+w,y-anchor[1]+h))
        a=np.asarray(exp.convert("RGB"),dtype=np.int16)
        b=np.asarray(crop.convert("RGB"),dtype=np.int16)
        dif=np.abs(a-b)
        details.append({"case":case,"action":act,"capture":cap,"source_frame":index,
                        "mae_rgb":round(float(dif.mean()),6),"max_delta":int(dif.max()),
                        "changed_pixels":int(np.any(dif!=0,axis=2).sum())})
        masks.append(np.asarray(crop).copy())
    change=int(np.any(masks[0]!=masks[1],axis=2).sum())
    details[-2]["temporal_changes_to_B"]=change
if any(x["changed_pixels"]!=0 for x in details):
    print("NONZERO_PIXEL_DIFFERENCE",[(x["case"],x["action"],x["capture"],x["changed_pixels"]) for x in details if x["changed_pixels"]])
result={"pairs":len(details),"actions":len(names),"pixel_exact_count":sum(x["changed_pixels"]==0 for x in details),
        "all_pixel_exact":all(x["changed_pixels"]==0 for x in details),
        "native_godot":"4.7.2 OpenGL Radeon RX 6700 XT",
        "known_limitation":"palette32 frames extracted from previously AI-painted poster, NOT AI video generation, human FS art approval missing",
        "details":details}
(root/"R2_NATIVE_PIXEL_PARITY_QA.json").write_text(json.dumps(result,indent=2),encoding="utf-8")
print(json.dumps({"comparisons":result["pairs"],"all_zero":result["all_pixel_exact"],
"actions_changed":[{"case":x["case"],"action":x["action"],"pixels":x.get("temporal_changes_to_B")} for x in details if x["capture"]=="A"]},indent=2))