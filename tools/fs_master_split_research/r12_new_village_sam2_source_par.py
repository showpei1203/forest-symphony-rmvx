#!/usr/bin/env python3
"""R12 exploratory SAME SOURCE RGBA transparent PAR from NEW_GENERATED Master 1280x928.
No claim of automatic whole-scene semantics or art Gate F. Every mask is manually prompted.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,torch,json,hashlib,os,time
R=Path(__file__).resolve().parent
D=R/"R12_NEW_ELF_VILLAGE_001";D.mkdir(exist_ok=True)
S=D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
src=np.asarray(Image.open(S).convert("RGB")).copy()
H,W=src.shape[:2];assert (W,H)==(1280,928)
REG=[
 ("A01_CHAPEL","major_house",[80,0,350,230],[[226,70],[210,145]],[[367,272],[64,249]],[224,201]),
 ("A02_TOP_RED_HOUSE","major_house",[402,8,641,180],[[512,70],[516,124]],[[650,200],[395,187]],[519,160]),
 ("A03_NE_WORKSHOP","major_house",[679,42,918,280],[[796,115],[808,201]],[[657,274],[921,280]],[800,248]),
 ("A04_CENTER_BLUE_INN","major_house",[400,188,664,426],[[506,273],[530,346]],[[394,428],[679,439]],[527,405]),
 ("A05_RED_CAFE","major_house",[661,275,898,530],[[769,340],[792,431]],[[659,528],[897,533]],[775,492]),
 ("A06_LEFT_ROUND_HOUSE","major_house",[0,296,249,547],[[118,390],[120,465]],[[259,548],[2,557]],[117,505]),
 ("A07_WATERMILL","major_house",[1056,335,1279,645],[[1167,442],[1191,549]],[[1036,647],[1258,672]],[1190,613]),
 ("A08_SW_COTTAGE","major_house",[112,625,361,823],[[228,687],[226,751]],[[379,837],[105,822]],[230,796]),
 ("A09_SE_COTTAGE","major_house",[892,558,1150,804],[[1015,632],[1012,727]],[[1150,807],[877,811]],[1020,774]),
 ("A10_LARGE_LEFT_TREE","major_tree",[173,318,440,570],[[283,383],[289,474]],[[155,581],[452,585]],[289,532]),
 ("A11_SE_TREES","major_tree",[1066,501,1279,795],[[1183,577],[1187,679]],[[1052,795],[1267,812]],[1189,742]),
 ("A12_FOUNTAIN_STATUE","stone_prop",[470,452,639,623],[[544,496],[539,530]],[[463,625],[658,631]],[548,594]),
 ("A13_NORTH_MID_TREE","major_tree",[320,0,498,174],[[393,54],[401,102]],[[500,183],[308,172]],[401,155]),
 ("A14_NORTH_EAST_TREE","major_tree",[988,0,1205,218],[[1099,63],[1095,113]],[[1200,232],[981,239]],[1090,190]),
 ("A15_SOUTH_GARDEN_BUSH","micro_bush",[721,745,887,916],[[801,826],[817,860]],[[716,923],[903,913]],[809,898]),
 ("A16_LEFT_GARDEN","micro_bush",[64,480,204,634],[[129,538],[120,560]],[[207,650],[59,642]],[133,592]),
 ("A17_MILL_SHRUB","micro_bush",[1097,565,1240,723],[[1168,620],[1171,652]],[[1255,733],[1089,724]],[1178,683]),
 ("A18_SW_BORDER_TREE","major_tree",[0,785,239,927],[[116,856],[123,897]],[[247,920],[226,788]],[120,915])
]
# deterministic per-object registered human-guided prompt seeds (not automatic proposals)
torch.set_num_threads(min(8,os.cpu_count() or 8))
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
model=build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml","checkpoints/sam2.1_hiera_small.pt",device="cpu")
predictor=SAM2ImagePredictor(model)
start=time.time();registry=[]
union=np.zeros((H,W),np.uint8);owner=np.zeros((H,W),np.uint8)
with torch.inference_mode():
 predictor.set_image(src)
 for idx,(oid,kind,box,positive,negative,foot) in enumerate(REG,1):
  pts=np.asarray(positive+negative,np.float32)
  labs=np.asarray([1]*len(positive)+[0]*len(negative),np.int32)
  masks,scores,_=predictor.predict(box=np.asarray(box,np.float32),point_coords=pts,point_labels=labs,multimask_output=True)
  cs=[]
  for i,(m,score) in enumerate(zip(masks,scores)):
   m=np.asarray(m,bool)
   n,l,stats,c=cv2.connectedComponentsWithStats(m.astype(np.uint8),8)
   posids={int(l[y,x]) for x,y in positive if m[y,x]};posids.discard(0)
   selected=np.isin(l,list(posids)) if posids else np.zeros_like(m)
   posfail=sum(not selected[y,x] for x,y in positive)
   negfail=sum(selected[y,x] for x,y in negative)
   bx,by,br,bb=box;within=np.zeros_like(m);within[max(0,by-8):min(H,bb+9),max(0,bx-8):min(W,br+9)]=True
   escaping=int((selected&~within).sum())/max(1,int(selected.sum()))
   rank=float(score)-.25*posfail-.20*negfail-.6*escaping
   cs.append((rank,i,float(score),selected,posfail,negfail,escaping))
  _,variant,confidence,mask,missing,negative_hits,escaping=max(cs,key=lambda x:x[0])
  prompt_pass=(missing==0 and negative_hits==0 and escaping<=.04 and int(mask.sum())>16)
  opaque=np.zeros((H,W,4),np.uint8);opaque[mask,:3]=src[mask];opaque[mask,3]=255
  Image.fromarray(opaque,"RGBA").save(D/(oid+"_PAR.png"))
  overlap=int(((owner>0)&mask).sum())
  # user review will revisit ownership and cut boundaries; no invented validation.
  take=mask & (owner==0)
  union[take]=255;owner[take]=idx
  row={"id":oid,"kind":kind,"bbox":box,"positive_points":positive,"negative_points":negative,"foot_anchor":foot,
       "source_alpha_pixels":int(mask.sum()),"confidence":confidence,"mask_variant":variant,
       "missing_positive":int(missing),"negative_hits":int(negative_hits),"box_escape_frac":round(float(escaping),5),
       "prompt_gate":bool(prompt_pass),"overlap_owner_conflict_pixels":overlap,
       "PAR_required":True,"collision_footprint_verified":False,
       "semantic_art_human_approved":False,"provisional_file":oid+"_PAR.png"}
  registry.append(row)
  print("R12_SAM2",oid,"px",row["source_alpha_pixels"],"prompt_pass",row["prompt_gate"],"overlap",overlap,flush=True)
par=np.zeros((H,W,4),np.uint8);use=union>0
par[use,:3]=src[use];par[use,3]=255
Image.fromarray(par,"RGBA").save(D/"PAR_R12_NEW_ELF_VILLAGE_001_CANDIDATE.png")
Image.fromarray(owner,"L").save(D/"R12_OBJECT_OWNER_MAP.png")
preview=src.copy()
preview[use]=(preview[use].astype(np.float32)*.60+np.array([245,20,170])*.40).astype(np.uint8)
Image.fromarray(preview).save(D/"R12_PAR_PINK_COVERAGE_QA.png")
bboxview=Image.fromarray(src,"RGB");draw=ImageDraw.Draw(bboxview)
for ob in registry:
 draw.rectangle(ob["bbox"],outline=(255,12,171),width=3)
 x,y=ob["foot_anchor"];draw.ellipse((x-6,y-6,x+6,y+6),fill="white")
 draw.text((ob["bbox"][0],max(0,ob["bbox"][1]-13)),ob["id"],fill="white")
bboxview.save(D/"R12_OBJECTS_BBOX_FOOT_QA.png")
assert np.array_equal(par[use,:3],src[use,:3])
result={"status":"R12_NEW_MASTER_SAM2_18_GUIDED_SOURCE_PAR_CANDIDATE_ART_HOLD",
 "new_source_generated_art":True,"dims":[W,H],"master_sha256":hashlib.sha256(S.read_bytes()).hexdigest(),
 "par_object_count":len(registry),"prompt_gate_pass":sum(x["prompt_gate"] for x in registry),
 "red_user_micro_semantic_policy_applied":True,"full_scene_exhaustive_detection":False,
 "source_rgb_exact_px":int(use.sum()),"source_rgb_mismatch":0,
 "elapsed_cpu_sec":round(time.time()-start,2),"master_art_gate_A":"HOLD",
 "independent_semantic_mask_truth":"NOT_TESTED",
 "human_PAR_approval":"PENDING_USER_REVIEW",
 "note":"New image generated, but output scaled to 1280x928 by nearest; preserve image source. Do not claim native pixel artist quality passed just from nearest resampling.",
 "objects":registry}
(D/"R12_SAM2_18OBJECT_GATE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2,default=lambda v:int(v) if isinstance(v,np.integer) else float(v) if isinstance(v,np.floating) else str(v)),encoding="utf8")
print("R12_SAM2_FINAL",json.dumps({k:result[k] for k in ["par_object_count","prompt_gate_pass","source_rgb_exact_px","elapsed_cpu_sec"]}),flush=True)