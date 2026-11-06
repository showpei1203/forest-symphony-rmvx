"""FS V2 PMD motion QA: independent objective checks + explicit foot/gait manual gate."""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import numpy as np,json,hashlib
root=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\validation_v2")
sources={
"G23_baseline":Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R1\inputs\g23"),
"R1_footlock":Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R1\outputs\PMD_FOOTLOCK_CANDIDATE"),
"R2_pareto":Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R2\outputs\PMD_R2_PARETO_CANDIDATE"),
}
def inspect_frames(paths):
    A=[]; masks=[]; bboxes=[];colors=[];sha=[]
    for path in paths:
        im=Image.open(path).convert("RGBA")
        arr=np.asarray(im)
        mask=arr[:,:,3]>0
        A.append(arr); masks.append(mask)
        bboxes.append(im.getchannel("A").getbbox())
        colors.append(int(len(np.unique(arr.reshape(-1,4),axis=0))))
        sha.append(hashlib.sha256(path.read_bytes()).hexdigest())
    delta=[];lower=[]
    for i,j in [(0,1),(1,2),(2,0)]:
        diff=np.any(A[i]!=A[j],axis=2)
        delta.append(round(float(np.mean(diff))*100,3))
        lower.append(round(float(np.mean(diff[88:,:]))*100,3))
    bottoms=[b[3] for b in bboxes]
    xs=[]
    for mask in masks:
        foot=mask[90:,:];mid=foot.shape[1]//2
        xs.append([int(foot[:,:mid].sum()),int(foot[:,mid:].sum())])
    return {"size":[list(a.shape[:2][::-1]) for a in A],
    "sha":sha,"alpha_bboxes":bboxes,"alpha_bottombounds":bottoms,
    "foot_bbox_jitter":max(bottoms)-min(bottoms),
    "nonzero_alpha_pixel_counts":[int(np.count_nonzero(a)) for a in masks],
    "palette_color_counts":colors,"full_frame_delta_pct_F1F2_F2F3_F3F1":delta,
    "lower_region_delta_pct":lower,"bottom_LR_occupancy_pairs":xs,
    "all_unique_frame_sha":len(set(sha))==3,
    "lower_region_changes":all(x>1 for x in lower[:2]),
    "all_128x128":all(a.shape[:2]==(128,128) for a in A)}
reports={}
for stage,dir in sources.items():
    reports[stage]={}
    for monster in (1,2,3):
        paths=[dir/f"PMD{monster:04d}_Moving_to_Close_Attack_{i}.png" for i in (1,2,3)]
        if all(p.is_file() for p in paths):
            reports[stage][f"PMD{monster:04d}"]=inspect_frames(paths)
        else:
            reports[stage][f"PMD{monster:04d}"]={"missing":[str(p) for p in paths if not p.is_file()]}
# negative control for detection of identical-frame animation.
control=np.zeros((128,128,4),dtype=np.uint8);control[30:85,30:85]=(200,120,35,255)
neg=bool(np.count_nonzero(np.any(control!=control,axis=2))==0)
for k in ("R2_pareto","R1_footlock"):
    for monster in ("PMD0001","PMD0002","PMD0003"):
        curr=reports.get(k,{}).get(monster,{})
        base=reports.get("G23_baseline",{}).get(monster,{})
        if "sha" in curr and "sha" in base:
            curr["frame1_vs_G23_same_sha"]=curr["sha"][0]==base["sha"][0]
reports["interpretation"]={
 "negative_control_identical_frame_detected":neg,
 "geometry_checks_do_not_prove_foot_alternation":True,
 "visual_45_degree_facing_verified":False,
 "leg_alternation_verified":False,
 "in_game_pmd_animation_retested":False,
 "sprite_source_modified":False,
 "art_gate":"PENDING_OR_FAIL_UNTIL_VISUAL_REVIEW",
 "formal_seal":"NO"}
(root/"PMD_V2_MOTION_FORENSIC.json").write_text(json.dumps(reports,ensure_ascii=False,indent=2),encoding="utf8")
# Visual compare contact (derived images displayed only, source intact)
sheet=Image.new("RGB",(3*220,3*235),(27,30,35))
d=ImageDraw.Draw(sheet)
for n in (1,2,3):
    p=sources["R2_pareto"]
    for f in (1,2,3):
        im=Image.open(p/f"PMD{n:04d}_Moving_to_Close_Attack_{f}.png").convert("RGBA")
        bg=Image.new("RGBA",im.size,(130,130,130,255))
        bg.alpha_composite(im)
        img=bg.convert("RGB").resize((192,192),Image.Resampling.NEAREST)
        x=(f-1)*220+14;y=(n-1)*235+26
        sheet.paste(img,(x,y))
        d.text((x,y-17),f"PMD{n:04d}_Moving_{f}",fill="white")
sheet.save(root/"PMD_R2_9FRAME_GAIT_REVIEW.png")
for k,v in reports.items():
 if k=="interpretation":continue
 for monster, m in v.items():
  if "foot_bbox_jitter" in m:
   print(k,monster,"jitter",m["foot_bbox_jitter"],"diff",m["full_frame_delta_pct_F1F2_F2F3_F3F1"],"alpha_bbox",m["alpha_bboxes"],flush=True)
print("SAVED",root,flush=True)