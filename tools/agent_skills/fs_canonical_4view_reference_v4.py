"""Forest Symphony original-approved Ground3/Par3 reference benchmark kit.
Creates registered 544x416 reference pairs only from unchanged canonical FS source.
These are NOT a new map, not source-isolated objects, not a new formal seal.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,zipfile
origin=Path(r"E:\遊戲專案開發\三大項目現行專案\FS project")
root=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\FS_GROUND3_PAR3_REGISTERED_BENCHMARK_V4_20261107")
if root.exists():raise SystemExit("FAIL-CLOSED: reference output already exists")
root.mkdir(parents=True)
g=origin/"Graphics/Parallaxes/ground3.png"
p=origin/"Overlays/par3.png"
sha=lambda fp:hashlib.sha256(fp.read_bytes()).hexdigest()
with Image.open(g) as im:ground=im.convert("RGB").copy()
with Image.open(p) as im:par=im.convert("RGBA").copy()
assert ground.size==par.size==(1280,928)
regions={
 "NW_COTTAGE_AND_TREES":(0,0),
 "CENTER_MAIN_HOUSE":(352,192),
 "EAST_HOUSES_CANOPY":(736,0),
 "WEST_FOREST_CLIFF":(0,448),
}
out=[]
preview=Image.new("RGB",(1088,416*4+44*4),(23,27,31))
dr=ImageDraw.Draw(preview)
for idx,(name,(x,y)) in enumerate(regions.items()):
 assert x%32==y%32==0
 box=(x,y,x+544,y+416)
 G=ground.crop(box)
 P=par.crop(box)
 assert G.size==P.size==(544,416)
 gf=root/(name+"_GROUND_544x416.png")
 pf=root/(name+"_PAR_544x416.png")
 G.save(gf);P.save(pf)
 ga=np.asarray(G.convert("RGB"))
 pa=np.asarray(P.convert("RGBA"))
 mask=pa[:,:,3]>0
 strong=pa[:,:,3]>=200
 agreement=int(np.all(ga[strong]==pa[:,:,:3][strong],axis=1).sum())
 nb=int(strong.sum())
 rgba=G.convert("RGBA")
 comp=Image.alpha_composite(rgba,P)
 diff=np.any(np.asarray(comp.convert("RGB"))!=ga,axis=2)
 # Only images from canonical ORIGINAL ground3/par3; overlays used as heatmap witness
 heat=np.zeros((416,544,4),dtype=np.uint8)
 heat[mask]=[255,100,28,110]
 withmask=Image.alpha_composite(G.convert("RGBA"),Image.fromarray(heat))
 af=root/(name+"_PAR_WITNESS_HEATMAP.png")
 withmask.save(af)
 y0=idx*(416+44)
 preview.paste(G,(0,y0+44))
 preview.paste(withmask.convert("RGB"),(544,y0+44))
 dr.text((12,y0+8),name+" | exact canonical FS pixels | 544x416",fill=(240,240,240))
 result={"region":name,"source_crop_origin":[x,y],"ground_sha256":sha(gf),"par_sha256":sha(pf),
         "alpha_coverage":round(float(mask.mean()),6),
         "opaque_par_ground_rgb_agreement":round(agreement/max(nb,1),6),
         "opaque_par_pixels":nb,"rgb_changed_pixels_on_recomposition":int(diff.sum()),
         "registration_verified_by_same_source_crop":True}
 out.append(result)
preview=preview.crop((0,0,1088,(416+44)*4))
preview.save(root/"ORIGINAL_FS_4_REGISTERED_VIEWS_AND_PAR_WITNESSES.png")
meta={"name":"FS_CANONICAL_GROUND3_PAR3_REGISTERED_544x416_BENCHMARK_V4",
      "status":"REFERENCE_ONLY_NOT_NEW_RUNTIME_MAP",
      "source_ground":"Graphics/Parallaxes/ground3.png","source_par":"Overlays/par3.png",
      "source_ground_sha256":sha(g),"source_par_sha256":sha(p),
      "pixel_grid":32,"viewport":[544,416],
      "regions":out,
      "why":"Original art and real HK UOM source 203 overlay benchmark. Require every new source/occlusion pipeline to compare against these paired screenshots, not last generated version.",
      "runtime_VX_import_executed_in_this_reference_export":False,
      "source_modified":False,
      "formal_seal":"NO"}
(root/"REFERENCE_MANIFEST.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf8")
pkg=root.parent/"FS_CANONICAL_GROUND3_PAR3_4VIEW_REFERENCE_V4_20261107.zip"
if pkg.exists():raise SystemExit("ZIP exists; no overwrite")
with zipfile.ZipFile(pkg,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in sorted(root.iterdir()):
  if f.is_file():z.write(f,f.relative_to(root.parent).as_posix())
with zipfile.ZipFile(pkg) as z:
 assert z.testzip() is None
print(json.dumps({"cases":out,"zip":str(pkg),"zip_bytes":pkg.stat().st_size},ensure_ascii=False,indent=2))