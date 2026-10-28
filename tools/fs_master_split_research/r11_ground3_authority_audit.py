from pathlib import Path
from rubymarshal.reader import load
from collections import Counter
from PIL import Image
import struct,json,hashlib
R=Path(__file__).resolve().parent;OUT=R/"R11_VILLAGE_SIZE_TECH";OUT.mkdir(exist_ok=True)
SRC=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
p=SRC/"Data"/"Map003.rvdata";m=load(p.open("rb"))
b=m.attributes["@data"]._private_data;header=struct.unpack_from("<5i",b,0);dim,w,h,depth,n=header
assert (w,h,depth)==(40,29,3)
ids=list(struct.unpack_from("<"+str(n)+"H",b,20))
c=[dict(Counter(ids[k*w*h:(k+1)*w*h])) for k in range(3)]
image=Image.open(SRC/"Graphics"/"Parallaxes"/"ground3.png")
assert image.size==(w*32,h*32)
events={str(id):{"name":str(e.attributes.get("@name")),"x":e.attributes.get("@x"),"y":e.attributes.get("@y")} for id,e in m.attributes["@events"].items()}
result={"formal_map":"Map003.rvdata","formal_source_sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
 "formal_ground3_sha256":hashlib.sha256((SRC/"Graphics"/"Parallaxes"/"ground3.png").read_bytes()).hexdigest(),
 "map_dims":[w,h],"parallax_name":m.attributes.get("@parallax_name").decode(),
 "ground3_image_dims":image.size,"three_original_layer_tile_histograms":c,
 "events_count":len(events),"events":events,
 "original_map_unmodified":True,"art_visual_quality":"REFERENCE_TARGET_NOT_GENERATED",
 "formal_script_boot_full_505":"KNOWN_HOLD"}
(OUT/"R11_GROUND3_FORMAL_AUTHORITY.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("R11_GROUND3_AUTHORITY",json.dumps({"size":[w,h],"layers":c,"events_count":len(events),"map_sha":result["formal_source_sha256"]},ensure_ascii=False),flush=True)