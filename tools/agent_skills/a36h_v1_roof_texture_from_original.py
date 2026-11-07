"""A36H visual experiment: replace moss/thatch roof COLOR/TEXTURE on both true independent R5 house PNGs,
using only roof-material pixels sampled from approved original FS Ground3 architecture.
No concept artwork; actual RGBA source edits preserving existing house silhouettes and alpha.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
O=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
MASK=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_R7_C1_FIVE_OBJECT_REAL_SOURCE_20261107")
REF=Path(r"E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png")
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
art=np.asarray(Image.open(REF).convert("RGB"),dtype=np.float32)
# Actually approved wood logs from the 4th/bottom original house, not R5 generated art.
lit=art[680:764,522:694]; dark=art[690:757,744:799]
items={}
for k,id in enumerate(["A36G_ELF_HOUSE_AND_WORKSHOP","A36G_R5_COTTAGE_B_SINGLE_ROOF"]):
 ob=next(o for o in m["objects"] if o["id"]==id)
 p=R5/"SOURCE_INDEPENDENT_RGBA"/ob["filename"]
 arr=np.asarray(Image.open(p).convert("RGBA")).copy()
 old=arr.copy()
 sel=np.asarray(Image.open(MASK/(id+"_SOURCE_SEMANTIC_RGBA.png")).convert("RGBA"))[:,:,3]>127
 h,w=sel.shape
 yy,xx=np.indices((h,w))
 # Material coordinates rotated into the original timber strips. 1:1 only; no interpolation/blurs.
 side=(xx > (194 + (yy-78)*.28)) if k==0 else (xx > (157+(yy-75)*.35))
 sy=np.mod((yy*.9 + xx*.22 + 10*k).astype(int),lit.shape[0])
 sx=np.mod((xx*.90 - yy*.14 + 19*k).astype(int),lit.shape[1])
 wood=lit[sy,sx].copy()
 dy=np.mod((yy*.84 +xx*.13+10*k).astype(int),dark.shape[0])
 dx=np.mod((xx*.83-yy*.09+11*k).astype(int),dark.shape[1])
 wood[side]=dark[dy[side],dx[side]]
 # wood reference is densely textured; suppress bright leaf-shaped patches from old thatch.
 source=old[:,:,:3].astype(np.float32)
 illum=(.2126*source[:,:,0]+.7152*source[:,:,1]+.0722*source[:,:,2])
 # Preserve real black borders, eaves, and major lighting; replace foliage-green pigment.
 scalar=np.clip(.75+(illum-92)/460,.53,1.15)
 wood*=scalar[:,:,None]
 # Build a coarse, continuous roof plank score in true 1x pixel coordinates.
 row=np.mod((yy-xx*.20),13.0)
 highlight=(row>=2.0)&(row<3.5);line=(row<1.1)
 wood[highlight]*=1.065
 wood[line]*=.76
 # Brick-like staggered end joins every 36px; rare straight dark connectors.
 join=(np.mod((xx+(np.floor((yy-xx*.20)/13).astype(int)%2)*17),43)<1.2)&(row<5)
 wood[join]*=.79
 # Ref sample is style authority: do not reuse R5 foliage-green as a base.
 wood=np.clip(wood,0,255).astype(np.uint8)
 arr[sel,:3]=wood[sel]
 # Ensure source alpha unchanged exactly.
 assert np.array_equal(arr[:,:,3],old[:,:,3])
 fn=O/(id+"_WOOD_ROOF_V1_RGBA.png")
 Image.fromarray(arr,"RGBA").save(fn)
 # Extract exact per-house 1x source before/after over neutral identical checker background.
 bg=Image.new("RGBA",(w,h),(85,88,88,255))
 a=bg.copy();a.alpha_composite(Image.fromarray(old,"RGBA"))
 b=bg.copy();b.alpha_composite(Image.fromarray(arr,"RGBA"))
 comparison=Image.new("RGB",(w*2,h+25),(25,29,32))
 comparison.paste(a.convert("RGB"),(0,25));comparison.paste(b.convert("RGB"),(w,25))
 dr=ImageDraw.Draw(comparison);dr.text((6,6),"R5 THATCH ORIGINAL",fill="white")
 dr.text((w+6,6),"A36H WOOD from ORIGINAL FS",fill="white")
 comparison.save(O/(id+"_SOURCE_BEFORE_AFTER_1X.png"))
 items[id]={"source_sha":sha(p),"edited_sha":sha(fn),"pixels_wood_material":int(sel.sum()),"alpha_unchanged":True,
            "source":ob["filename"],"candidate":fn.name}
print(json.dumps(items,ensure_ascii=False,indent=2))