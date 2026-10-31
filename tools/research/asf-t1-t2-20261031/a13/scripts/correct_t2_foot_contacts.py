from pathlib import Path
import json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A13_KEYPOSE_RIG")
p=root/"T2_moss_antler"/"rig_authority.json"
cfg=json.loads(p.read_text(encoding="utf8"))
names=cfg["leg_names"]
origin=cfg["limb_origins_master_coords"]
baseY=75 # 15 origin plus original master bottom hoof y60
# Every contact hoof is assigned fixed absolute foot coordinates across contiguous
# contact frames (0-2 and 4-5); swing hooves are lifted and free to change target.
states=[
 ("stance", [1,1,1,1], {}, 0),
 ("compression", [1,1,1,1], {}, 0),
 ("push",[0,1,0,1],{"front_far":(-2,-3),"back_far":(2,-3)},0),
 ("flight",[0,0,0,0],{n:(-3,-6) for n in names},0),
 ("contact",[1,1,0,0],{n:(-8,0) for n in ("front_far","front_near")}|{"back_far":(-4,-5),"back_near":(-4,-5)},0),
 ("brake",[1,1,0,0],{n:(-8,0) for n in ("front_far","front_near")}|{"back_far":(-3,-4),"back_near":(-3,-3)},0),
 ("recover",[0,0,1,1],{"front_far":(-4,-4),"front_near":(-4,-4)},0),
 ("rest",[1,1,1,1],{},0)
]
assert len(states)==8
for row,(_,vals,drift,_) in zip(cfg["semantic_frames"],states):
 row["contacts"]=dict(zip(names,vals))
 ft={}
 for name in names:
  x,y=origin[name]; sx,sy=drift.get(name,(0,0))
  ft[name]=[16+x+sx,baseY+sy]
 row["foot_targets"]=ft
cfg["revision"]="A13_T2_R3_SEMANTIC_GROUND_CONTACT_LOCK"
cfg["contact_definition"]="1=planted hoof at an explicitly world-locked x/y for consecutive stance frames; 0=free hoof (swing/flight)"
errors=[]
for name in names:
 last=None
 for row in cfg["semantic_frames"]:
  if row["contacts"][name]:
   pt=row["foot_targets"][name]
   if last is not None and last!=pt:errors.append({"foot":name,"frame":row["frame"],"before":last,"after":pt})
   last=pt
  else:last=None
assert not errors,errors
p.write_text(json.dumps(cfg,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"status":"SOURCE_3D_LOCK_PASS_KEYPOSE_ONLY","continuous_stance_slip":errors,"ground_y":baseY},ensure_ascii=False))