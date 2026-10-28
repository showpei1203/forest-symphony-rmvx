#!/usr/bin/env python3
"""Read-only match Scene21 544x416 to actual FS formal map parallax images and map records.
Map with closest IMAGE fingerprint isn't sufficient to claim authority; flags explicit conditions.
"""
from pathlib import Path
from PIL import Image,ImageOps,ImageChops,ImageStat
from rubymarshal.reader import load
from collections import Counter
import hashlib,struct,json,math
R=Path(__file__).resolve().parent
SRC=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
M=R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png"
OUT=R/"R10_FORMAL_MAP_AUTHORITY";OUT.mkdir(exist_ok=True)
master=Image.open(M).convert("RGB")
def thumb(im):
 return ImageOps.grayscale(im.convert("RGB").resize((32,24),Image.Resampling.BOX)).tobytes()
def dist(a,b):
 return sum(abs(x-y) for x,y in zip(a,b))/len(a)/255.
srcT=thumb(master)
maps=[]
images=[]
par_dir=SRC/"Graphics"/"Parallaxes"
for p in par_dir.glob("*"):
 if p.suffix.lower() not in [".png",".jpg",".jpeg",".bmp"]:continue
 try:
  with Image.open(p) as im:
   dims=list(im.size)
   sample=thumb(im)
   images.append({"name":p.name,"width":dims[0],"height":dims[1],"rough_grayscale_distance":round(dist(srcT,sample),5),
    "aspect_distance":round(abs(im.width/im.height - master.width/master.height),5),
    "same_544_416":im.size==master.size})
 except Exception as e: images.append({"name":p.name,"error":str(e)})
for p in sorted((SRC/"Data").glob("Map[0-9][0-9][0-9].rvdata")):
 try:
  d=load(p.open("rb"))
  w=int(d.attributes["@width"]);h=int(d.attributes["@height"])
  v=d.attributes.get("@parallax_name")
  if isinstance(v,bytes):v=v.decode("utf8","replace")
  b=d.attributes["@data"]._private_data
  dim,x,y,z,n=struct.unpack_from("<5i",b,0)
  ids=struct.unpack_from("<"+str(n)+"H",b,20)
  top=Counter(ids[w*h*2:w*h*3])
  passa=sum(x for key,x in top.items() if 768<=key<=799)
  maps.append({"map_id":int(p.stem[3:]),"name":p.stem,
    "size_tiles":[w,h],"parallax_name":v,"parallax_loop_x":d.attributes.get("@parallax_loop_x"),
    "third_layer_parapassa_count":passa,"third_layer_768_block":top.get(768,0),
    "third_layer_769_pass":top.get(769,0),
    "screen_pixel_dims":[w*32,h*32]})
 except Exception as e:maps.append({"file":p.name,"error":str(e)})
ref_names={str(d.get("parallax_name","")).lower().strip() for d in maps}
images.sort(key=lambda x:x.get("rough_grayscale_distance",999))
match=[x for x in images if x["name"].lower() in ref_names or Path(x["name"]).stem.lower() in ref_names]
exact=[x for x in images if x.get("same_544_416")]
report={"status":"R10_FORMAL_MAP_IMAGE_READONLY_AUDIT_MATCH_NOT_DEMONSTRATED",
 "source_folder":str(SRC),"master_544x416_sha256":hashlib.sha256(M.read_bytes()).hexdigest(),
 "formal_maps_count":len(maps),"formal_parallax_files_count":len(images),
 "formal_maps":maps,"closest_image_fingerprint_candidates":images[:16],
 "same_pixel_size_images":exact[:25],"parallax_name_matches":match[:25],
 "semantic_authority_confirmed":False,"formal_scene21_map_id":None,
 "notes":["Grayscale-distance downsample is a coarse resemblance diagnostic, not map identity or provenance proof",
          "Source SCENE21 master may be a research artifact not saved in K4 baseline formal project",
          "No confirmed formal matching MapXXX => do not reuse formal map passage for this scene"]}
(OUT/"R10_FORMAL_MAP_IDENTITY_AUDIT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2,default=str),encoding="utf8")
print("R10_FORMAL_MAP_SCAN",json.dumps({"maps":len(maps),"parallaxes":len(images),
 "top_closest":images[:5],"same_size_images":exact[:4],"matched_formal_names":match[:5],
 "formal_map_ids_544x416":[x["map_id"] for x in maps if x.get("size_tiles")==[17,13]]},ensure_ascii=False),flush=True)