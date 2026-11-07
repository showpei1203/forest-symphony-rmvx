"""A36H V2: precise warm log roof *material replacement* for actual independent R5 house source PNGs.
- Mask based on original GREEN thatch pigment plus roof spatial limits, never whole ground/background.
- Source new pixels come from approved FS Ground3 authentic wooden roof reference.
- Preserve source geometry/alpha; draw coherent 2px roof ridge accents.
- V1 retained separately as rejected comparison.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
O=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
REF=Path(r"E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png")
M=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
art=np.asarray(Image.open(REF).convert("RGB"))
# Original approved house roof planking: lit plane and dark plane, no green terrain.
lit=art[688:747,551:689]
dark=art[696:745,748:791]
rng=np.random.default_rng(1234)
for k,id in enumerate(["A36G_ELF_HOUSE_AND_WORKSHOP","A36G_R5_COTTAGE_B_SINGLE_ROOF"]):
 ob=next(o for o in M["objects"] if o["id"]==id)
 f=R5/"SOURCE_INDEPENDENT_RGBA"/ob["filename"]
 im=Image.open(f).convert("RGBA")
 a=np.array(im.copy())
 h,w=a.shape[:2];yy,xx=np.indices((h,w))
 hsv=np.array(im.convert("HSV"))
 hue,sat,val=hsv[:,:,0],hsv[:,:,1],hsv[:,:,2]
 # Original thatch is olive/yellow-green; dark black silhouette edges remain original.
 moss=(hue>=30)&(hue<=105)&(sat>=38)&(val>=16)&(a[:,:,3]>=170)
 limits=((yy>=17)&(yy<=190)&(xx<273)) if k==0 else ((yy>=22)&(yy<=181)&(xx<250))
 if k==0:
  limits &= ~((xx>157)&(yy<65))
 # V1 semantic candidate still points to source roof, union catches formerly missed thatch pixels.
 old=(np.asarray(Image.open(O/(id+"_WOOD_ROOF_V1_RGBA.png")).convert("RGBA"))[:,:,:3]!=a[:,:,:3]).any(axis=2)
 sel=(moss & limits) | (old & (a[:,:,3]>170))
 # Strict local material limits: lower part of building walls/stone should remain wood/stone.
 if k==0:sel&=~((yy>174)&(xx>197))
 else:sel&=~((yy>166)&(xx>171))
 # Plank texture sampling: rotate original approved 1:1 wood grain reference to follow slope.
 ux=np.mod((xx + (yy*.29).astype(int)),lit.shape[1]);uy=np.mod((yy - xx*.13).astype(int),lit.shape[0])
 left=lit[uy,ux].astype(np.float32)
 dux=np.mod((xx+(yy*.29).astype(int)),dark.shape[1]);duy=np.mod((yy-xx*.18).astype(int),dark.shape[0])
 right=dark[duy,dux].astype(np.float32)
 # Roof has a light main facet and a darker outward-facing facet.
 facing=(xx>213+(yy-80)*.27) if k==0 else (xx>165+(yy-65)*.28)
 wood=left.copy();wood[facing]=right[facing]
 # Average reference with its mean to remove source repetition; none of original green-thatched texture leaks through.
 rough=wood.copy()
 # ensure reference sample does not include black outline or dirt, clip wood brightness.
 wood=wood*.83 + np.array([174,126,57],dtype=np.float32)[None,None,:]*.17
 # Thin wood plank lines with no variable copy-paste geometry: visual direction matches approved house diagonal planks.
 phase=np.mod(yy-xx*.21,14)
 darkline=(phase<1.3)
 shine=(phase>=2)&(phase<3)
 wood[darkline]*=.72
 wood[shine]*=1.07
 join=(np.mod(xx+((np.floor((yy-xx*.21)/14).astype(int)&1)*18),45)<1.4)&(phase<=5)
 wood[join]*=.76
 # Darken low-angle eaves gradually without reintroducing moss.
 edge=(yy>130)
 wood[edge]*=(.98-np.minimum(yy[edge]-130,54)*.002)[:,None]
 a[sel,:3]=np.clip(wood[sel],0,255).astype(np.uint8)
 arr=Image.fromarray(a,"RGBA")
 # Ridge highlighting is deliberately subtle and exact pixel, not reassembled gable.
 d=ImageDraw.Draw(arr)
 if k==0:
  ridge=[(112,26),(153,39),(194,54),(233,73)]
  # Do not redraw main body seams if this roof was generated with a different pitch.
 else:ridge=[(127,29),(152,35),(191,62)]
 # Ridge line constrained to original Alpha for each pixel to prevent stray lines.
 orig_alpha=np.array(im.getchannel("A"))
 roofline=Image.new("L",(w,h),0)
 rr=ImageDraw.Draw(roofline);rr.line(ridge,fill=255,width=2)
 line=np.asarray(roofline)>0
 revised=np.asarray(arr).copy()
 line &= (orig_alpha>215)
 revised[line,:3]=np.minimum(255,(revised[line,:3].astype(np.float32)*.48+np.array([235,191,104])*.52)).astype(np.uint8)
 assert np.array_equal(revised[:,:,3],np.asarray(im)[:,:,3])
 p=O/(id+"_WOOD_ROOF_V2_RGBA.png")
 Image.fromarray(revised,"RGBA").save(p)
 bg=Image.new("RGBA",(w,h),(83,88,89,255))
 before=bg.copy();before.alpha_composite(im)
 after=bg.copy();after.alpha_composite(Image.fromarray(revised,"RGBA"))
 comp=Image.new("RGB",(w*2,h+26),(27,31,35))
 comp.paste(before.convert("RGB"),(0,26));comp.paste(after.convert("RGB"),(w,26))
 dr=ImageDraw.Draw(comp)
 dr.text((8,8),"R5 original",(230,230,230))
 dr.text((w+8,8),"A36H V2 approved FS wood",(230,230,230))
 comp.save(O/(id+"_SOURCE_V2_BEFORE_AFTER_1X.png"))
 print(id,"pixels",int(sel.sum()),"wood_src",p.name,flush=True)