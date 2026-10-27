#!/usr/bin/env python3
"""FS R7 Master-first Occlusion semantic proposals. SAM2 positive/negative prompts, no image regeneration.
Each object proposal retains source pixel color. ART-HOLD until human/scene QA.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,torch,hashlib,json,time,os
R=Path(__file__).resolve().parent
ROOT=R/"R7_SEMANTIC_MASK_CANDIDATES"
ROOT.mkdir(exist_ok=True)
SRC=R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png"
master=np.asarray(Image.open(SRC).convert("RGBA"),dtype=np.uint8).copy()
H,W=master.shape[:2];assert (W,H)==(544,416)
img=master[:,:,:3].copy()
# Scene21 manually authored prompts seed SAM2 semantic candidates; these labels are NOT proven objects.
# "foot" is approximate depth anchor used only for first-pass contact checking, not final walkability.
registry=[
 {"id":"house","kind":"building","box":[270,49,413,236],"pos":[[320,102],[344,145]],"neg":[[334,239],[421,238]],"foot":[340,223],"band":"static_candidate"},
 {"id":"left_deciduous","kind":"tree","box":[100,58,207,208],"pos":[[150,106],[148,143]],"neg":[[203,185],[197,229]],"foot":[151,194],"band":"dynamic_candidate"},
 {"id":"right_deciduous","kind":"tree","box":[414,103,524,262],"pos":[[465,157],[469,202]],"neg":[[479,265]],"foot":[474,240],"band":"dynamic_candidate"},
 {"id":"mid_conifer_A","kind":"tree","box":[197,32,254,176],"pos":[[231,79]],"neg":[[269,103],[192,145]],"foot":[232,161],"band":"collision_likely"},
 {"id":"mid_conifer_B","kind":"tree","box":[240,49,286,177],"pos":[[265,85]],"neg":[[230,83]],"foot":[267,162],"band":"collision_likely"},
 {"id":"upper_right_conifer","kind":"tree","box":[350,23,406,171],"pos":[[382,75]],"neg":[[412,87],[350,145]],"foot":[380,159],"band":"collision_likely"},
 {"id":"left_conifer","kind":"tree","box":[70,97,124,221],"pos":[[94,142]],"neg":[[144,139]],"foot":[95,206],"band":"collision_likely"},
 {"id":"left_front_bush","kind":"bush","box":[9,147,90,262],"pos":[[49,190]],"neg":[[103,217],[52,260]],"foot":[48,238],"band":"low_conf"},
 {"id":"left_shrine","kind":"structure","box":[90,195,145,271],"pos":[[112,225]],"neg":[[160,248],[91,253]],"foot":[113,257],"band":"low_conf"},
 {"id":"right_marker","kind":"stone","box":[363,184,412,254],"pos":[[392,211]],"neg":[[351,218],[411,250]],"foot":[393,241],"band":"low_conf"},
 {"id":"right_flower_bush","kind":"bush","box":[461,215,541,304],"pos":[[499,257]],"neg":[[446,284],[505,315]],"foot":[505,288],"band":"low_conf"},
 {"id":"front_edge_bush","kind":"bush","box":[93,294,163,376],"pos":[[124,333]],"neg":[[156,372],[102,376]],"foot":[126,357],"band":"low_conf"},
]
assert len(registry)>=12
torch.set_num_threads(min(8,os.cpu_count() or 8))
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
start=time.time()
model=build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml","checkpoints/sam2.1_hiera_small.pt",device="cpu")
predictor=SAM2ImagePredictor(model)
semantic=np.zeros((H,W),dtype=np.uint8)
confidence_rgba=master.copy();low=np.zeros((H,W),dtype=bool)
proposals=[]
with torch.inference_mode():
 predictor.set_image(img)
 for idx,ob in enumerate(registry,1):
  points=np.asarray(ob["pos"]+ob["neg"],dtype=np.float32)
  labels=np.asarray([1]*len(ob["pos"])+[0]*len(ob["neg"]),dtype=np.int32)
  box=np.asarray(ob["box"],dtype=np.float32)
  ms,scores,_=predictor.predict(box=box,point_coords=points,point_labels=labels,multimask_output=True)
  candidates=[]
  for variant,(m,score) in enumerate(zip(ms,scores)):
   m=np.asarray(m,dtype=bool)
   # only use connected components containing a positive point.
   n,lab,stats,cent=cv2.connectedComponentsWithStats(m.astype(np.uint8),8)
   positive_labels={int(lab[int(y),int(x)]) for x,y in ob["pos"] if m[int(y),int(x)]}
   positive_labels.discard(0)
   valid=np.isin(lab,list(positive_labels)) if positive_labels else np.zeros_like(m)
   missing=sum(not bool(valid[int(y),int(x)]) for x,y in ob["pos"])
   neg_hits=sum(bool(valid[int(y),int(x)]) for x,y in ob["neg"])
   # don't allow closed shape to grow into the entire visible floor
   bx1,by1,bx2,by2=ob["box"]
   outside=valid.copy();outside[max(0,by1-12):min(H,by2+12),max(0,bx1-12):min(W,bx2+12)]=False
   outside_rate=float(outside.sum())/max(1,int(valid.sum()))
   diagnostic_score=float(score)-.15*missing-.20*neg_hits-.35*outside_rate
   candidates.append((diagnostic_score,variant,float(score),valid,missing,neg_hits,outside_rate))
  sel=max(candidates,key=lambda c:c[0])
  _,variant,score,mask,missing,neg_hits,outside_rate=sel
  status="PROMPT_CANDIDATE" if missing==0 and neg_hits==0 and outside_rate<=.07 and mask.sum()>=40 else "REJECT_FOR_REVIEW"
  # Occlusion mask is cautiously limited ABOVE anchor foot (not all source non-ground).
  anchor_y=ob["foot"][1]
  oc=mask.copy()
  oc[anchor_y:,:]=False
  # do not create independent colors: always use SOURCE master pixels
  r7png=master.copy();r7png[:,:,3]=oc.astype(np.uint8)*255
  Image.fromarray(r7png,"RGBA").save(ROOT/f"{ob['id']}_PAR_OCCLUSION_CANDIDATE.png")
  Image.fromarray(mask.astype(np.uint8)*255).save(ROOT/f"{ob['id']}_SAM2_FULL_SEMANTIC_MASK.png")
  # potential conflicts are auditable, not considered PASS
  overlap=int(((semantic>0)&oc).sum())
  if status=="PROMPT_CANDIDATE":
   own=oc & (semantic==0)
   semantic[own]=idx
  else:low|=oc
  x,y=np.where(mask)[1],np.where(mask)[0]
  rect=[int(x.min()),int(y.min()),int(x.max()),int(y.max())] if len(x) else None
  item={k:v for k,v in ob.items()}
  item.update({"score":score,"variant":variant,"prompt_consistency":status,"full_semantic_px":int(mask.sum()),
   "occlusion_candidate_px":int(oc.sum()),"candidate_bbox":rect,
   "positive_missing":missing,"negative_mistaken_as_positive":neg_hits,
   "outside_box_plus12_ratio":round(outside_rate,5),"overlap_existing_px":overlap,
   "note":"SAM2 model probability is NOT proof of semantic category or correct PAR coverage."})
  proposals.append(item)
  print("R7_SAM",ob["id"],status,round(score,3),int(oc.sum()),"overlap",overlap,flush=True)
# Same-source Ground + same-source PAR; pixel owner ID keeps no duplicated ownership.
union=semantic>0
rgba=np.zeros_like(master);rgba[union]=master[union];rgba[:,:,3]=union.astype(np.uint8)*255
Image.fromarray(rgba,"RGBA").save(ROOT/"PAR_R7_PROPOSAL_SAME_SOURCE_RGBA.png")
Image.fromarray(semantic,"L").save(ROOT/"R7_OBJECT_PIXEL_OWNER.png")
Image.fromarray(union.astype(np.uint8)*255,"L").save(ROOT/"R7_UNION_OCCLUSION_MASK.png")
vis=master.copy()
vis[union,:3]=(vis[union,:3].astype(np.float32)*.55+np.array([255,55,165])*.45).astype(np.uint8)
vis[low,:3]=(vis[low,:3].astype(np.float32)*.5+np.array([255,175,35])*.5).astype(np.uint8)
Image.fromarray(vis,"RGBA").save(ROOT/"R7_SAM2_SEMANTIC_QA_MAGENTA_ACCEPTED_ORANGE_REVIEW.png")
d=Image.fromarray(master,"RGBA");draw=ImageDraw.Draw(d)
for ob in proposals:
 x1,y1,x2,y2=ob["box"];color=(245,60,150,255) if ob["prompt_consistency"]=="PROMPT_CANDIDATE" else (247,155,55,255)
 draw.rectangle((x1,y1,x2,y2),outline=color,width=2)
 fx,fy=ob["foot"];draw.ellipse((fx-3,fy-3,fx+3,fy+3),fill=(255,255,255,255))
 draw.text((x1+1,y1),ob["id"][:15],fill=color)
d.save(ROOT/"R7_OBJECT_PROMPT_REGISTRY_BOXES_AND_FOOT.png")
manifest={"status":"R7_SAM2_OBJECT_CANDIDATE_TECH_ONLY_ART_HOLD",
 "source_sha256":hashlib.sha256(SRC.read_bytes()).hexdigest(),"source_dims":[W,H],
 "ground_is_unchanged_full_source":True,
 "objects_requested":len(registry),"accepted_prompt_only":sum(x["prompt_consistency"]=="PROMPT_CANDIDATE" for x in proposals),
 "rejected_prompt":sum(x["prompt_consistency"]=="REJECT_FOR_REVIEW" for x in proposals),
 "total_occlusion_candidate_px":int(union.sum()),"partial_semantics_only":True,
 "elapsed_seconds":round(time.time()-start,3),
 "objects":proposals,"art_gate_F":False,"formal_runtime_tested":False}
(ROOT/"R7_SAM2_PROMPT_REGISTRY_GATE.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
print("R7_SAM2_PROPOSALS_DONE",json.dumps({k:manifest[k] for k in ["objects_requested","accepted_prompt_only","rejected_prompt","total_occlusion_candidate_px","elapsed_seconds"]}),flush=True)