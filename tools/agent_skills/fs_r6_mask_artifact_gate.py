"""Fail-closed R6 occlusion mask QA compared with true original FS ground3/par3.
No asset mutation. Analyze recurring 32-grid rasterization and original-style RGB provenance.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
src=Path(r"E:\遊戲專案開發\三大項目現行專案\FS project")
root=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
out=root/"FS_STYLE_AND_OCCLUSION_BENCHMARK_V4_20261107"
out.mkdir(exist_ok=True)
a=src/"Graphics/Parallaxes/ground3.png";p=src/"Overlays/par3.png"
r5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"
c1=root/"A36G_R6_SOURCE_REGISTERED_RUNTIME_20261107/R6_RUNTIME_SOURCE_REGISTERED_PAR50.png"
c2=root/"A36G_R6_C2_CONTINUOUS_OCCLUSION_20261107/R6_RUNTIME_SOURCE_REGISTERED_PAR50.png"
full=[a,r5]
maskfiles={"approved_original":p,"r6_c1_sampling_lattice":c1,"r6_c2_smoothed_field":c2}
def stat(p):
 with Image.open(p) as im:
  A=np.asarray(im.convert("RGBA"))
 mask=A[:,:,3]>127
 xchange=np.sum(mask[:,1:]!=mask[:,:-1],axis=0)
 ychange=np.sum(mask[1:,:]!=mask[:-1,:],axis=1)
 xpos=np.arange(1,1280)%32
 ypos=np.arange(1,928)%32
 edge_x=[int(xchange[xpos==j].sum()) for j in range(32)]
 edge_y=[int(ychange[ypos==j].sum()) for j in range(32)]
 val=lambda x:round(x,5)
 x_total=sum(edge_x); y_total=sum(edge_y)
 # x=4,28 are 24px-wide, 32px periodic actor body rectangle boundaries.
 special=sum(edge_x[i] for i in [4,28])
 # all four values compared after accounting for population are diagnosed, not arbitrary thresholds
 ratios={"x_4_28_ratio":val(special/max(x_total,1)),
         "x_0_ratio":val(edge_x[0]/max(x_total,1)),
         "y_0_ratio":val(edge_y[0]/max(y_total,1)),
         "x_peak_ratio":val(max(edge_x)/max(x_total,1)),
         "y_peak_ratio":val(max(edge_y)/max(y_total,1))}
 return mask,{"alpha_coverage":val(float(mask.mean())),"edge_counts_x_mod32":edge_x,
  "edge_counts_y_mod32":edge_y,"x_edge_total":x_total,"y_edge_total":y_total,**ratios}
st={}
for name,f in maskfiles.items():
 mm,metrics=stat(f);st[name]=metrics
 print(name,json.dumps({k:v for k,v in metrics.items() if not k.startswith("edge_counts_")},ensure_ascii=False))
# compare in original scale, scaled for contact only
contact=Image.new("RGB",(640*3,464*2),(20,24,28))
source_images={"approved_original":a,"r6_c1_sampling_lattice":r5,"r6_c2_smoothed_field":r5}
dd=ImageDraw.Draw(contact)
for i,(name,maskfile) in enumerate(maskfiles.items()):
 mm,_=stat(maskfile)
 with Image.open(source_images[name]) as im:
  rgb=im.convert("RGBA")
 heat=np.zeros((928,1280,4),dtype=np.uint8);heat[mm]=[255,64,28,105]
 merged=Image.alpha_composite(rgb,Image.fromarray(heat)).convert("RGB").resize((640,464),Image.Resampling.NEAREST)
 contact.paste(merged,(i*640,40))
 dd.text((i*640+6,12),name+" mask="+str(round(float(mm.mean())*100,2))+"%",fill=(255,255,255))
contact=contact.crop((0,0,1920,504))
contact.save(out/"ORIGINAL_VS_R6_C1_C2_OCCLUSION_WITNESS.png")
# Direct x-pixel artifact metric for source aesthetics, no false numerical aesthetic PASS
for n,fp in [("original_ground3",a),("a36g_r5_master",r5)]:
 with Image.open(fp) as im:
  rgb=np.asarray(im.convert("RGB"))
  coarse=np.mean(np.abs(np.diff(rgb.astype(np.int16),axis=1)))
  palette=np.unique(rgb.reshape(-1,3),axis=0)
  st[n]={"sha256":hashlib.sha256(fp.read_bytes()).hexdigest(),"unique_RGB_colors":int(len(palette)),
         "mean_horizontal_neighbor_RGB_absdiff":round(float(coarse),4)}
# Explicit art decisions are human-grounded, never inferred from stats.
st["decisions"]={
 "r6_c1":"FAIL: visible actor-station lattice and grid bands in entire forest, 32px sampled field.",
 "r6_c2":"FAIL: smoothed field removes some narrow lines but reveals large rectangular block masks and 52% coverage; semantic tree/roof depth is not solved.",
 "original_reference":"Approved visual authority is the EXISTING ground3/par3, not R5 generated sources.",
 "R5_master":"ART_FAIL inherited; no new art generated.",
 "native_VX_for_c1_c2":"NOT_RUN: failed visual QA gate",
 "formal_seal":"NO",
 "recommended_next":"Use actual original style source objects and guided per-object occlusion mask authorship. Do not approximate every object from global footpoints, especially forest_group depth slices."
}
(out/"FS_R6_MASK_ARTIFACT_GATE.json").write_text(json.dumps(st,ensure_ascii=False,indent=2),encoding="utf8")
print("FINISHED",out)