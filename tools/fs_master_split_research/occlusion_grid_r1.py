#!/usr/bin/env python3
"""FS R1: Compare user's 32px grid overdraw vs mask-assisted grid; no ground decomposition.
Outputs RESEARCH ONLY, not native VX integration.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,math
ROOT=Path(__file__).resolve().parent
SRC=ROOT/"SCENE21_GUIDED_SAM2_CANDIDATE"
OUT=ROOT/"OCCLUSION_GRID_R1_20261027"; OUT.mkdir(exist_ok=True,parents=True)
M=np.asarray(Image.open(SRC/"MASTER_RGBA.png").convert("RGBA")).copy(); H,W=M.shape[:2]
T=32; nx=W//T; ny=H//T
O=[
("house",SRC/"house_SAM2_RAW.png",196,(338,214)),
("left_tree",SRC/"left_tree_SAM2_RAW.png",187,(160,190)),
("right_tree_refined",SRC/"right_tree_prompt_v2_variant1.png",217,(475,237)),
]
objects=[]
objmasks=[]
for name,path,maxy,foot in O:
 mask=np.asarray(Image.open(path).convert("L"))>0
 yy=np.arange(H)[:,None]
 occ=(mask&(yy<maxy))
 objmasks.append(occ)
 objects.append({"name":name,"source_mask":path.name,"foot_estimate":list(foot),"upper_occlusion_y_exclusive":maxy,
                  "candidate_pixels":int(mask.sum()),"occlusion_pixels":int(occ.sum()),"note":"heuristic top cutoff for BENCHMARK only"})
mask=np.logical_or.reduce(objmasks)
occupied=[]
for ty in range(ny):
 for tx in range(nx):
  p=mask[ty*T:(ty+1)*T,tx*T:(tx+1)*T]
  pix=int(p.sum())
  if pix:
   occupied.append({"x":tx,"y":ty,"occ_px":pix,"cell_fill_ratio":pix/(T*T)})
def form(threshold):
 cells=np.zeros((H,W),dtype=bool)
 selected=[]
 for tile in occupied:
  if tile["cell_fill_ratio"]>=threshold:
   tx,ty=tile["x"],tile["y"];cells[ty*T:(ty+1)*T,tx*T:(tx+1)*T]=True
   selected.append([tx,ty])
 return cells,selected
full,allcells=form(.0001)
full20,cells20=form(.20)
fg25=mask&full20
# largest high-conf mask parts selection; loose static mask
fg=mask.copy()
def png_mask(fn,m):
 arr=M.copy()
 arr[:,:,3]=m.astype(np.uint8)*255
 Image.fromarray(arr,"RGBA").save(OUT/fn)
def showmask(fn,m):
 p=M.copy()
 p[m,:3]=(p[m,:3]*.50+np.array([251,50,142])*.50).astype(np.uint8)
 Image.fromarray(p,"RGBA").save(OUT/fn)
png_mask("PAR_32PIXEL_FULL_TILE_OVERDRAW.png",full)
png_mask("PAR_32PIXEL_GRID_SEMANTIC_MASK.png",fg)
png_mask("PAR_TILES_OVER20pct_COVERAGE.png",full20)
png_mask("PAR_MASK_OVER20pct_ONLY.png",fg25)
showmask("QA_TILE_OVERDRAW_MASK.png",full)
showmask("QA_SEMANTIC_MASK.png",fg)
savebase=Image.fromarray(M,"RGBA")
# 32x32 grid candidate sheet
p=savebase.copy();d=ImageDraw.Draw(p)
for x in range(0,W+1,32):d.line((x,0,x,H),fill=(105,240,250,155),width=1)
for y in range(0,H+1,32):d.line((0,y,W,y),fill=(105,240,250,155),width=1)
for tile in occupied:
 x,y=tile["x"],tile["y"]
 if tile["cell_fill_ratio"]>=.20:
  d.rectangle((x*T,y*T,x*T+31,y*T+31),outline=(255,30,90,255),width=2)
p.save(OUT/"QA_32PX_GRID_TILE_SELECTION.png")
# Actual FS character sprite file (read only). Do not alter game.
char_dir=Path("/mnt/e/GameAssetToolLab_20261023/FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE/Graphics/Characters")
assets=sorted([x for x in char_dir.glob("*.png") if x.name.startswith("$") and x.stem[1:4].isdigit()])
char_file=assets[0] if assets else None
C=None
if char_file:
 im=Image.open(char_file).convert("RGBA")
 if im.width%3==0 and im.height%4==0 and 20<=im.width//3<=64:
  fw,fh=im.width//3,im.height//4
  C=np.asarray(im.crop((fw,0,fw*2,fh))).copy()
else: fw=fh=0
# render character at position; scene screen foot-y, centered x (not collision probe)
feet=[(155,168),(160,197),(160,222),(341,186),(342,214),(339,252),(470,202),(471,240),(472,277)]
actor_probe=[]
for idx,(fx,fy) in enumerate(feet):
 if C is None:break
 fh,fw=C.shape[:2]; xx=fx-fw//2; yy=fy-fh
 if xx<0 or yy<0 or xx+fw>W or yy+fh>H:continue
 alpha=C[:,:,3]!=0
 def composite(parmask):
  bg=Image.fromarray(M,"RGBA").copy()
  bg.alpha_composite(Image.fromarray(C,"RGBA"),(xx,yy))
  a=np.zeros_like(M);a[parmask]=M[parmask];a[:,:,3]=parmask.astype(np.uint8)*255
  bg.alpha_composite(Image.fromarray(a,"RGBA"))
  return np.asarray(bg)
 xfull=composite(full)
 xfg=composite(fg)
 xnopar=np.asarray(savebase.copy()); xnop=Image.fromarray(xnopar,"RGBA"); xnop.alpha_composite(Image.fromarray(C,"RGBA"),(xx,yy))
 xnopar=np.asarray(xnop)
 # actor pixels lost when copied scene overlies character (irrespective of whether it *should* be occluded)
 overlap_full=int(np.logical_and(alpha,full[yy:yy+fh,xx:xx+fw]).sum())
 overlap_fg=int(np.logical_and(alpha,fg[yy:yy+fh,xx:xx+fw]).sum())
 actor_probe.append({"foot":[fx,fy],"alpha_actor_pixels":int(alpha.sum()),"occluded_by_full_grid_px":overlap_full,"occluded_by_mask_px":overlap_fg,
                     "extra_actor_pixels_occluded_by_full_grid":overlap_full-overlap_fg})
 Image.fromarray(xfull).save(OUT/f"ACTOR_{idx}_FULL_TILE.png")
 Image.fromarray(xfg).save(OUT/f"ACTOR_{idx}_SEMANTIC.png")
 # 2 up at native resolution, side by side for visual comparison
 duo=Image.new("RGBA",(2*W,H));duo.paste(Image.fromarray(xfull),(0,0));duo.paste(Image.fromarray(xfg),(W,0))
 duo.save(OUT/f"ACTOR_{idx}_COMPARE.png")
diag={
 "version":"FS_OCCLUSION_GRID_R1","status":"RESEARCH_ONLY_ART_HOLD_NOT_NATIVE_VX",
 "source_dimensions":[W,H],"tile_size":32,"grid":[nx,ny],"selected_objects":objects,
 "opaque_tile_coverage_full_px":int(full.sum()),"semantic_mask_coverage_px":int(mask.sum()),
 "full_tile_background_overdraw_px":int((full&~mask).sum()),
 "overdraw_fraction_of_full_tile_pixels":float((full&~mask).sum()/max(1,full.sum())),
 "full_tile_mask_coverage_pct":float(100*(full&mask).sum()/max(1,mask.sum())),
 "above20pct_tile_count":len(cells20),"any_tile_count":len(allcells),
 "above20pct_coverage_of_semantic_pixels":float((full20&mask).sum()/max(1,mask.sum())),
 "actor_png_reference":char_file.name if char_file else None,"actor_frame_dimensions":[fw,fh] if C is not None else None,
 "actor_positions":actor_probe,
 "interpretation":"Extra occlusion is NOT always technically wrong; depends on foot contact and layer z. Counts show risk from copying non-object ground as full opaque tiles.",
 "source_lock":"Ground is byte-exact original MASTER; no inpainting",
 "gates":{"full_scene_unchanged":True,"complete_par_coverage":False,"semantic_mask_independently_validated":False,"actor_foot_geometry_tested":False,"native_vx_tested":False}
}
(OUT/"OCCLUSION_GRID_R1_METRICS.json").write_text(json.dumps(diag,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({k:diag[k] for k in ["grid","opaque_tile_coverage_full_px","semantic_mask_coverage_px","full_tile_background_overdraw_px","overdraw_fraction_of_full_tile_pixels","above20pct_tile_count","any_tile_count","actor_png_reference","actor_frame_dimensions","actor_positions"]},ensure_ascii=False))