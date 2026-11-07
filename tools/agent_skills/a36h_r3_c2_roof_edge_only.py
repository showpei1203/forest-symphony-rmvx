"""A36H R3 tangible architecture detail work (single-source 1x pixel art):
trace deliberate timber fascia and ridge beams over old thatch overhangs,
draw original Ground3-derived timber structural shadow/light bands, preserve same-source alpha exactly.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np,json,hashlib
BASE=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
OUT=BASE/"A36H_R3_C2_RAKE_AND_EAVE_ONLY"
if OUT.exists():raise RuntimeError("R3 roof geometry candidate exists")
OUT.mkdir(parents=True)
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
manifest=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
configs={
"A36G_ELF_HOUSE_AND_WORKSHOP":{
 "main_ridge":[(99,24),(116,22),(151,36),(193,50),(220,65)],
 "main_rake":[(216,67),(246,94),(271,118)],
 "front_eave":[(14,152),(69,150),(111,166),(141,179)],

 "workshop_rake":[(16,152),(51,126),(75,116)],
},
"A36G_R5_COTTAGE_B_SINGLE_ROOF":{
 "main_ridge":[(64,19),(87,21),(118,26),(153,36),(171,48)],
 "main_rake":[(169,52),(194,75),(221,102),(237,121)],
 "front_eave":[(19,117),(53,124),(83,136),(113,146)],

}}
dark=(57,34,14,255);medium=(110,70,29,255);light=(197,151,79,255)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
results={}
for id,cfg in configs.items():
 ob=next(o for o in manifest["objects"] if o["id"]==id)
 old=BASE/(id+"_WOOD_ROOF_V2_RGBA.png")
 im=Image.open(old).convert("RGBA")
 src=np.asarray(im)
 # Three-pixel structural fascia with inner reflective lip, limited to original opaque pixels.
 m=Image.new("L",im.size,0);dd=ImageDraw.Draw(m)
 for kind,pts in cfg.items():
  if kind=="main_ridge":continue
  dd.line(pts,fill=255,width=6 if "eave" in kind else 5,joint="curve")
 cover=(np.asarray(m)>0)&(src[:,:,3]>185)
 changed=np.asarray(im).copy()
 changed[cover,:3]=np.array(dark[:3],np.uint8)
 # medium timber beam inset / highlight offsets (same shape).
 m2=Image.new("L",im.size,0);d2=ImageDraw.Draw(m2)
 for kind,pts in cfg.items():
  if kind=="main_ridge":continue
  off=[(x,y-1) for x,y in pts]
  d2.line(off,fill=255,width=3,joint="curve")
 highlight=(np.asarray(m2)>0)&cover
 changed[highlight,:3]=medium[:3]
 m3=Image.new("L",im.size,0);d3=ImageDraw.Draw(m3)
 for kind,pts in cfg.items():
  if kind=="main_ridge":continue
  off=[(x,y-2) for x,y in pts]
  d3.line(off,fill=255,width=1,joint="curve")
 shade=(np.asarray(m3)>0)&cover
 changed[shade,:3]=light[:3]
 # Defined linear roof ridge (natural pixel line, preserve original chimney).
 ridge=Image.new("L",im.size,0)
 rd=ImageDraw.Draw(ridge);rd.line(cfg["main_ridge"],fill=255,width=2,joint="curve")
 rmask=(np.asarray(ridge)>0)&(src[:,:,3]>240)
 changed[rmask,:3]=[188,149,82]
 # Original alpha unchanged: no hanging roof pixel replacement outside source or invented disconnected shape.
 assert np.array_equal(changed[:,:,3],src[:,:,3])
 p=OUT/(id+"_WOOD_GEOMETRY_R3_RGBA.png")
 Image.fromarray(changed,"RGBA").save(p)
 bg=Image.new("RGBA",im.size,(77,79,81,255))
 ab=bg.copy();ab.alpha_composite(im)
 bb=bg.copy();bb.alpha_composite(Image.fromarray(changed,"RGBA"))
 cmp=Image.new("RGB",(im.width*2,im.height+25),(29,31,34))
 cmp.paste(ab.convert("RGB"),(0,25));cmp.paste(bb.convert("RGB"),(im.width,25))
 txt=ImageDraw.Draw(cmp);txt.text((5,5),"R2 roof",fill="white")
 txt.text((im.width+5,5),"R3 C2 edge-only fascia",fill="white")
 cmp.save(OUT/(id+"_R2_VS_R3_1X.png"))
 results[id]={"changed_pixels":int(np.any(changed[:,:,:3]!=src[:,:,:3],axis=2).sum()),"alpha_unchanged":True,
 "source_SHA":sha(old),"candidate_SHA":sha(p),"image":p.name}
(OUT/"R3_HOUSE_ROOF_QA.json").write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(results,ensure_ascii=False))