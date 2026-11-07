"""A36H R2 ground color correction from ORIGINAL approved Ground3, not a concept render.
- Exact ground3 vs R5 grass/dirt robust medians set target shift; preserve structure and pixel sharpness.
- Edit genuine AUTHORING_GROUND_ONLY, recomposite with 192 actual independent PAR from R1.
- Re-derive RUNTIME_OCCLUSION_PAR RGB from new master using unchanged semantic alpha of 5-source subset.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json, numpy as np, hashlib, shutil
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
R1=ROOT/"A36H_R1_TRUE_GROUND_PAR_RECOMPILE"
R2=ROOT/"A36H_R2_GROUND3_PALETTE_MATCH"
if R2.exists():raise RuntimeError("FAIL-CLOSED: output exists")
R2.mkdir(parents=True)
REF=Path(r"E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Parallaxes\ground3.png")
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
A=np.array(Image.open(REF).convert("RGB")).astype(np.int16)
old=np.array(Image.open(R1/"A36H_R1_AUTHORING_GROUND_ONLY.png").convert("RGB"))
ar=old.astype(np.int16)
r,g,b=[ar[:,:,i] for i in range(3)]
rr,gg,bb=[A[:,:,i] for i in range(3)]
gm=(g>r*1.12)&(g>b*1.7)&(r>50)&(g>80)&(b<80)
pm=(r>g*1.08)&(g>100)&(b>30)&(r>155)
refg=(gg>rr*1.12)&(gg>bb*1.7)&(rr>50)&(gg>80)&(bb<80)
refp=(rr>gg*1.08)&(gg>100)&(bb>30)&(rr>155)
med=lambda x,m:np.median(x[m],axis=0).astype(int)
d_g=med(A,refg)-med(ar,gm)
d_p=med(A,refp)-med(ar,pm)
print("REF_GRASS_MID",med(A,refg),"R1_GRASS_MID",med(ar,gm),"SHIFT",d_g,flush=True)
print("REF_PATH_MID",med(A,refp),"R1_PATH_MID",med(ar,pm),"SHIFT",d_p,flush=True)
# Guarantee disjoint class segmentation so no conflicting correction.
pm=pm&~gm
out=ar.copy()
# This is direct palette remap at 1x, not blur; output retains high frequency source texture and flower pixels.
out[gm]+=d_g[None,:]
out[pm]+=d_p[None,:]
# Spatial micro-variation is restricted to grass pixels, on a wide natural field. No periodic 32-grid texture.
yy,xx=np.indices(g.shape)
light=(np.sin(xx/119.0+yy/177.0)+np.sin(yy/73.0-xx/207.0))*1.25
out[gm,0]+=np.round(light[gm]).astype(np.int16)
out[gm,1]+=np.round(light[gm]).astype(np.int16)
out=np.clip(out,0,255).astype(np.uint8)
ground=R2/"A36H_R2_AUTHORING_GROUND_ONLY.png"
Image.fromarray(out,"RGB").save(ground,optimize=True)
complete=R2/"A36H_R2_AUTHORING_COMPLETE_PAR.png"
shutil.copy2(R1/"A36H_R1_AUTHORING_COMPLETE_PAR.png",complete)
scene=Image.fromarray(out,"RGB").convert("RGBA")
scene.alpha_composite(Image.open(complete).convert("RGBA"))
full=scene.convert("RGB")
f=R2/"A36H_R2_RUNTIME_FULL_SCENE_GROUND.png"
full.save(f,optimize=True)
# Runtime semantically identical alpha from R1, but recompute visual RGB from NEW final scene.
o=np.asarray(Image.open(R1/"A36H_R1_RUNTIME_SOURCE_OWNED_5_PAR.png").convert("RGBA"))
mask=o[:,:,3]>127
newrgba=np.zeros((928,1280,4),np.uint8)
newrgb=np.asarray(full)
newrgba[mask,:3]=newrgb[mask]
newrgba[mask,3]=255
p_runtime=R2/"A36H_R2_RUNTIME_SOURCE_OWNED_5_PAR.png"
Image.fromarray(newrgba,"RGBA").save(p_runtime,optimize=True)
assert np.all(newrgba[mask,:3]==newrgb[mask])
assert np.array_equal(newrgba[:,:,3],o[:,:,3])
m=json.loads((R1/"A36H_R1_SCENE_MANIFEST.json").read_text("utf8"))
m["stage"]="A36H_R2_CANONICAL_GROUND3_GRASS_PATH_PALETTE_REAL_LAYER_CANDIDATE"
m["source_stage"]="A36H_R1_ORIGINAL_FS_WOOD_ROOF_BLUEGREEN_FOREST_ART_DRAFT"
m["ground_sha256"]=sha(ground);m["par_sha256"]=sha(complete);m["composite_sha256"]=sha(f)
m["a36h_ground_palette_reference"]=sha(REF)
m["a36h_ground_palette_class_median_shift"]={"grass":d_g.tolist(),"path":d_p.tolist()}
m["a36h_art_gate"]="PENDING"
m["formal_seal"]="NO"
(R2/"A36H_R2_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
# side by side before-and-after in native 1x crop and full map.
oldfull=Image.open(R1/"A36H_R1_RUNTIME_FULL_SCENE_GROUND.png").convert("RGB")
newfull=full
for n,box in [("GROUND_CENTER",(290,335,920,750)),("PATH_NORTH",(120,0,700,430))]:
 o=oldfull.crop(box);new=newfull.crop(box)
 cmp=Image.new("RGB",(o.width*2,o.height+25),(27,29,32))
 cmp.paste(o,(0,25));cmp.paste(new,(o.width,25))
 d=ImageDraw.Draw(cmp);d.text((7,5),"A36H R1 COLOR",fill="white")
 d.text((o.width+7,5),"A36H R2 approved Ground3 palette",fill="white")
 cmp.save(R2/(n+"_R1_VS_R2_1X.png"))
cmp=Image.new("RGB",(1280,491),(23,27,30))
cmp.paste(oldfull.resize((640,464),Image.Resampling.NEAREST),(0,27))
cmp.paste(full.resize((640,464),Image.Resampling.NEAREST),(640,27))
d=ImageDraw.Draw(cmp);d.text((8,7),"R1 actual Ground/PAR wood roof",fill="white")
d.text((648,7),"R2 canonical grass/path colors and wood + forest",fill="white")
cmp.save(R2/"A36H_R2_FULL_SCENE_R1_BEFORE_AFTER_640.png")
orig_full=Image.open(Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104\A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png")).convert("RGB")
cmp2=Image.new("RGB",(1280,491),(23,27,30))
cmp2.paste(orig_full.resize((640,464),Image.Resampling.NEAREST),(0,27))
cmp2.paste(full.resize((640,464),Image.Resampling.NEAREST),(640,27))
d=ImageDraw.Draw(cmp2);d.text((8,7),"A36G R5 BEFORE: rejected art",fill="white")
d.text((648,7),"A36H R2 AFTER: real Ground+PAR candidate",fill="white")
cmp2.save(R2/"A36H_R2_FULL_SCENE_R5_BEFORE_AFTER_640.png")
stats={"style_target":"Approved original FS Graphics/Parallaxes/ground3.png","reference_SHA":sha(REF),
"stage":m["stage"],"full_canvas":[1280,928],
"ground_original_R5_to_approved_Ground3_grass_RGB_shift":d_g.tolist(),
"ground_original_R5_to_approved_Ground3_path_RGB_shift":d_p.tolist(),
"grass_pixels_modified":int(gm.sum()),"path_pixels_modified":int(pm.sum()),
"original_grass_median":med(A,refg).tolist(),"new_ground_grass_median_at_original_mask":med(out,gm).tolist(),
"original_path_median":med(A,refp).tolist(),"new_ground_path_median_at_original_mask":med(out,pm).tolist(),
"source_192_PAR_unchanged_from_R1":sha(complete)==sha(R1/"A36H_R1_AUTHORING_COMPLETE_PAR.png"),
"source_alpha_semantic_5mask_unchanged":True,"runtime_RGB_exact_registration":True,
"collision_unchanged":True,"R1_R2_GROUND_changed":sha(ground)!=sha(R1/"A36H_R1_AUTHORING_GROUND_ONLY.png"),
"native_VX":"NOT RUN","godot":"NOT RUN","art_user_review":"PENDING","formal_seal":"NO"}
(R2/"A36H_R2_PALETTE_AND_LAYER_QA.json").write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding="utf8")
print("FINAL",json.dumps(stats,ensure_ascii=False),flush=True)