#!/usr/bin/env python3
"""R17 honest controlled 544x416 scene art-first benchmark:
B: actual R12 master high-fidelity crop and native source masks.
C: attempt editable independent-object plate via candidate object removal+reuse, fail/hold when baked visual remnants remain.
A: genuine paired-output gen model NOT available, do not synthesize an impostor.
No edits to original K4/R12-R16.
"""
from pathlib import Path
from PIL import Image, ImageDraw,ImageFont
import numpy as np,cv2,json,hashlib
R=Path(__file__).resolve().parent
D=R/"R17_ELF_CORNER_TRIPLE_PATH_20261029";D.mkdir(exist_ok=True)
A=R/"R12_NEW_ELF_VILLAGE_001"
R16=R/"R16_MODEL_TOOL_EVAL_20261028"
source=A/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
actual_sha=hashlib.sha256(source.read_bytes()).hexdigest()
assert actual_sha=="eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80"
S=np.asarray(Image.open(source).convert("RGB"))
H,W=S.shape[:2];assert (W,H)==(1280,928)
x0,y0=155,175;w,h=544,416;x1,y1=x0+w,y0+h
assert x1<=W and y1<=H
scene=S[y0:y1,x0:x1].copy()
scene_img=Image.fromarray(scene,"RGB")
scene_img.save(D/"R17_REFERENCE_R12_HIGH_DETAIL_CROP.png")
B=D/"B_MASTER_FIRST";B.mkdir(exist_ok=True)
scene_img.save(B/"GROUND_FULL.png")
scene_img.save(B/"MASTER_PREVIEW.png")
# All B masks use sourceRGB exact. No tile snapping, no re-generated pixel colors.
candidates=[
 ("TREE_LEFT_MAJOR","tree",(290,534),R16/"TREE_LEFT_MAJOR_R16_SELECTED_SOURCE_RGBA.png",True),
 ("LAMP_FOUNTAIN_NW","lamp",(453,488),R16/"LAMP_FOUNTAIN_NW_R16_SELECTED_SOURCE_RGBA.png",True),
 ("A04_CENTER_BLUE_INN","house",(527,405),A/"A04_CENTER_BLUE_INN_PAR.png",False),
 ("A12_FOUNTAIN_STATUE","stone_prop",(548,594),A/"A12_FOUNTAIN_STATUE_PAR.png",False),
 ("A16_LEFT_GARDEN","raised_bush",(133,592),A/"A16_LEFT_GARDEN_PAR.png",False),
]
# No model has verified which ground pixels belong to objects, so this is PROPOSAL, not gold.
bmask=np.zeros((h,w),bool)
objects=[]
for name,kind,foot,file,refined in candidates:
 assert file.exists(),file
 a=np.asarray(Image.open(file).convert("RGBA"))[:,:,3]>0
 assert a.shape==(H,W)
 roi=a[y0:y1,x0:x1].copy()
 root_exclusion=None
 if kind=="tree":
  # per-user bottom tree contact tile: only SOURCE world grid tile (not relative crop tile)
  tilex=int(foot[0]//32);tiley=int(foot[1]//32)
  xx0=max(0,tilex*32-x0);yy0=max(0,tiley*32-y0)
  xx1=min(w,(tilex+1)*32-x0);yy1=min(h,(tiley+1)*32-y0)
  if xx1>xx0 and yy1>yy0:roi[yy0:yy1,xx0:xx1]=False
  root_exclusion=[tilex,tiley]
 if not roi.any():
  raise RuntimeError("Empty pilot object "+name)
 objrgba=np.zeros((h,w,4),np.uint8)
 objrgba[roi,:3]=scene[roi];objrgba[roi,3]=255
 Image.fromarray(objrgba,"RGBA").save(B/("PAR_OBJECT_"+name+".png"))
 bmask |= roi
 objects.append({"id":name,"type":kind,"foot_world":list(foot),"foot_benchmark":[foot[0]-x0,foot[1]-y0],
  "alpha_visible_in_crop_px":int(roi.sum()),"source_file":str(file.relative_to(R)),
  "root_tile_ignored_world":root_exclusion,"human_contour_approved":False,
  "source_rgb_exact":True,"refined_R16":refined})
par=np.zeros((h,w,4),np.uint8);par[bmask,:3]=scene[bmask];par[bmask,3]=255
Image.fromarray(par,"RGBA").save(B/"PAR_TRANSPARENT.png")
Image.fromarray(par,"RGBA").save(B/"PAR_SOURCE_EXACT_CANDIDATE.png")
bqa=scene.copy();bqa[bmask]=(bqa[bmask].astype(np.float32)*.58+np.array([248,25,150])*.42).astype(np.uint8)
Image.fromarray(bqa,"RGB").save(B/"PAR_PINK_COVERAGE_QA.png")
tiles=[]
for yy in range(13):
 for xx in range(17):
  n=int(bmask[yy*32:(yy+1)*32,xx*32:(xx+1)*32].sum())
  if n:tiles.append({"tile_xy":[xx,yy],"par_alpha_px":n})
# Mask on ground-only negative zones drawn from R12's authored polygons; not user gold.
r12col=json.loads((A/"R12_SELECTED14_AND_COLLISION_GATE.json").read_text(encoding="utf8"))
bad=np.zeros((H,W),np.uint8)
for name,poly in r12col["ground_stairs_bridge_exclusions"]:
 cv2.fillPoly(bad,[np.array(poly,np.int32)],255)
ground=bad[y0:y1,x0:x1]>0
conflict=int((ground&bmask).sum())
qa=scene_img.convert("RGBA");d=ImageDraw.Draw(qa)
for name,poly in r12col["ground_stairs_bridge_exclusions"]:
 points=[(x-x0,y-y0) for x,y in poly]
 if not any(-100<px<w+100 and -100<py<h+100 for px,py in points):continue
 d.line(points+[points[0]],fill=(255,210,12,255),width=2)
qa.convert("RGB").save(B/"GROUND_NEGATIVE_REGIONS_QA.png")
# Actor source 32x32 from FS, preview no claims native VX
actor=Image.open(R/"R14_GODOT_LAYER_AUTHORING_20261028"/"godot_project"/"assets"/"actor32.png").convert("RGBA")
assert actor.size==(32,32)
def actor_frame(pos):
 full=scene_img.convert("RGBA");x,y=pos
 full.alpha_composite(actor,(int(x),int(y)))
 return full
actor_frame((286,335)).save(B/"ACTOR_FRONT_PREVIEW.png")
actor_frame((124,270)).save(B/"ACTOR_REAR_PREVIEW.png")
Bmanifest={"path":"B_MASTER_FIRST","status":"REAL_R12_HIGH_DETAIL_MASTER_PLUS_MASKS_ART_GATE_HOLD",
"master_source_sha256":actual_sha,"crop_rect_xywh":[x0,y0,w,h],
"canvas_px":[w,h],"original_artist_master_unchanged":True,
"PAR_source_rgb_exact":True,"number_of_registered_objects":len(objects),
"required_objects_full_house_1_trees_3_lamp_1_fence_1":"NOT_ALL_PRESENT",
"manual_semantic_contours_verified":False,"positive_needed_separate_actor_gold":True,
"ground_only_reference_pixels":int(ground.sum()),
"PAR_false_positive_on_R12_ground_only_candidate_px":conflict,
"par_alpha_pixels":int(bmask.sum()),"object_registry":objects,
"occlusion_tiles":[*tiles],"art_gate":"HOLD","semantic_PAR_gate":"HOLD"}
(B/"OBJECT_REGISTER.json").write_text(json.dumps(Bmanifest,ensure_ascii=False,indent=2),encoding="utf8")
# C TEST: recover "continuous ground plate" by removing same objects from a baked full Master via inpainting
# This is *not* a clean true ground source, expect art loss and remnant objects outside five registered ROIs.
C=D/"C_OBJECT_FIRST_CONTINUOUS_PLATE";C.mkdir(exist_ok=True)
mask=(bmask.astype(np.uint8)*255)
grown=cv2.dilate(mask,np.ones((5,5),np.uint8),iterations=2)
# Protect representative image scale; inpainting candidate only, no full background artist truth.
inpaint=cv2.inpaint(cv2.cvtColor(scene,cv2.COLOR_RGB2BGR),grown,3,cv2.INPAINT_TELEA)
plate=cv2.cvtColor(inpaint,cv2.COLOR_BGR2RGB)
Image.fromarray(plate,"RGB").save(C/"CONTINUOUS_PLATE_PROPOSAL.png")
# place SAME source object layers, at SAME coords. C source plate still has baked 3D elements outside masks -> not valid solved method!
srccomp=np.dstack((plate,np.full((h,w),255,np.uint8))).astype(np.uint8)
base=Image.fromarray(srccomp,"RGBA")
overlay=Image.fromarray(par,"RGBA")
composite=Image.alpha_composite(base,overlay)
composite.convert("RGB").save(C/"GROUND_FULL.png")
overlay.save(C/"PAR_TRANSPARENT.png")
composite.convert("RGB").save(C/"MASTER_PREVIEW.png")
# show artist can inspect repaired plate artifacts: color differences from B's original reference
difference=np.abs(np.asarray(composite.convert("RGB")).astype(np.int16)-scene.astype(np.int16))
n=int((difference.max(axis=2)>0).sum())
plate_delta=np.abs(plate.astype(np.int16)-scene.astype(np.int16))
nplate=int((plate_delta.max(axis=2)>0).sum())
diffvis=np.asarray(composite.convert("RGB")).copy()
changed=difference.max(axis=2)>0
diffvis[changed]=(diffvis[changed].astype(np.float32)*.55+np.array([255,225,20])*.45).astype(np.uint8)
Image.fromarray(diffvis,"RGB").save(C/"C_VS_B_COLOR_DIFFERENCE_QA.png")
Cmanifest={"path":"C_OBJECT_FIRST_CONTINUOUS_PLATE","status":"TEST_RERENDER_SOURCE_PLATE_RECONSTRUCTION_ART_HOLD",
"same_semantic_scene":True,"master_reference_path":"../R17_REFERENCE_R12_HIGH_DETAIL_CROP.png",
"continuous_source_plate":"OpenCV Telea inpaint source R12 art 5 candidate masks",
"no_tile_grid_painting":True,"source_asset_object_count":len(objects),
"all_object_source_png_are_transparent":True,"PAR_RGB_source_exact_reference":True,
"plate_changed_pixels":nplate,"C_composite_differs_from_B_reference_pixels":n,
"critical_confound":"Baked unsegmented architecture/trees remained in source plate; cannot call fully independent object-first art.",
"art_gate":"HOLD","semantic_PAR_gate":"HOLD","level_of_fidelity":"UNACCEPTED"}
(C/"OBJECT_REGISTER.json").write_text(json.dumps(Cmanifest,ensure_ascii=False,indent=2),encoding="utf8")
# A must not be invented; only interface spec and NOT_RUN record.
Aout=D/"A_PAIR_GENERATION";Aout.mkdir(exist_ok=True)
Astatus={"path":"A_PAIR_GENERATION","status":"NOT_RUN_NO_VERIFIED_GENERATOR_PAIR_TRANSPARENT_OUTPUT",
"original_master_MUST_NOT_be_named_as_independent_generation":True,
"same_scene_contract":{"canvas":[544,416],"camera":"top down 3/4","actors":"RPG Maker VX 32px",
"objects":["large_house","tree_broadleaf","tree_conifer","tree_umbrella","street_lamp","railing","winding_road","small_props"],
"background":"Continuous organically detailed grass/stone/dirt, not a repeated 2-tile floor",
"pair_alignment_requirement":"Master and PAR share exact pixels and object coords"},
"expected_files":["GROUND_FULL.png","PAR_TRANSPARENT.png"],"actual_generated_files":[],
"art_gate":"NOT_RUN","semantic_PAR_gate":"NOT_RUN"}
(Aout/"PAIR_GENERATION_CONTRACT.json").write_text(json.dumps(Astatus,ensure_ascii=False,indent=2),encoding="utf8")
# Report self evidence, no fake equivalence.
report={"status":"R17_STAGE1_REAL_B_AND_C_CANDIDATES_A_NOT_RUN","canvas":[544,416],
"B":{k:Bmanifest[k] for k in ["status","par_alpha_pixels","PAR_false_positive_on_R12_ground_only_candidate_px","number_of_registered_objects","art_gate","semantic_PAR_gate"]},
"C":{k:Cmanifest[k] for k in ["status","plate_changed_pixels","C_composite_differs_from_B_reference_pixels","art_gate","semantic_PAR_gate"]},
"A":Astatus["status"],
"truthful_limitation":"Only 5 overlapping source objects, 3 trees and rail/完整 house unmet, not valid 85pt compare or production",
"source_master_K4_untouched":True}
(D/"R17_STAGE1_EVIDENCE_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_STAGE1",json.dumps(report,ensure_ascii=False),flush=True)