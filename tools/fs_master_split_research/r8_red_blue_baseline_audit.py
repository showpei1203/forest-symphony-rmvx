#!/usr/bin/env python3
"""Read user override labels; audit R7 alpha gaps/blue violation without accepting semantics as proved.
Requires only PIL; original sealed FS untouched.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib
ROOT=Path(__file__).resolve().parent
D=ROOT/"R8_USER_ANNOTATION_20261028";D.mkdir(exist_ok=True)
auth=json.loads((D/"R8_USER_ANNOTATION_AUTHORITY.json").read_text(encoding="utf8"))
src=Image.open(ROOT/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGBA")
old=Image.open(ROOT/"R7_SEMANTIC_MASK_CANDIDATES"/"PAR_R7_PROPOSAL_SAME_SOURCE_RGBA.png").convert("RGBA")
assert src.size==old.size==(544,416)
# Estimate 10x10 seed mask coverage, robust to antialiasing but still not semantic ground-truth.
d=Image.new("RGBA",src.size,(0,0,0,0));d.paste(src)
draw=ImageDraw.Draw(d)
detail=[]
for o in auth["user_red"]+auth["user_blue"]:
  x1,y1,x2,y2=o["box"]
  core=o["core"] if o["id"].startswith("BLUE") else [max(x1,o["positives"][0][0]-6),max(y1,o["positives"][0][1]-6),min(x2,o["positives"][0][0]+7),min(y2,o["positives"][0][1]+7)]
  a=[old.getpixel((x,y))[3] for y in range(core[1],core[3]) for x in range(core[0],core[2])]
  filled=sum(v>0 for v in a)
  ratio=filled/max(1,len(a))
  expected=o["priority"]
  meets=(ratio>=.12) if expected=="MUST_INCLUDE" else (filled==0)
  result={"id":o["id"],"name":o["name"],"class":o["kind"],"seed_test_rect":core,
     "r7_alpha_pixels_in_seed_rect":filled,"seed_pixels":len(a),"r7_coverage_fraction":round(ratio,4),
     "rule":"RED_coverage>=12pct (candidate only)" if expected=="MUST_INCLUDE" else "BLUE_alpha_zero",
     "meets_coarse_rule":meets}
  detail.append(result)
  color=(255,40,60,255) if expected=="MUST_INCLUDE" else (52,80,255,255)
  draw.rectangle((x1,y1,x2,y2),outline=color,width=2)
  label=o["id"]+":"+("R7_PRESENT" if meets else "R7_FAIL")
  draw.text((x1,max(0,y1-11)),label,fill=color)
d.save(D/"R8_PRE_R7_LABELLED_RED_BLUE_COVERAGE.png")
blue=[x for x in detail if x["id"].startswith("BLUE")]
red=[x for x in detail if x["id"].startswith("RED")]
report={"status":"R8_R7_BASELINE_ANNOTATED_LABEL_AUDIT","original_master_sha256":hashlib.sha256((ROOT/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").read_bytes()).hexdigest(),
        "user_red_count":len(red),"user_blue_count":len(blue),"red_seed_coarse_present":sum(x["meets_coarse_rule"] for x in red),
        "red_seed_coarse_missing":[x["id"] for x in red if not x["meets_coarse_rule"]],
        "blue_exclusion_violations":[x["id"] for x in blue if not x["meets_coarse_rule"]],
        "warning":"User annotated image 548x400 while master 544x416. Boxes are initially visually mapped by manual approximate landmarks; this is not precise per-pixel registration.",
        "independent_semantic_truth_tested":False,"real_native_vx_tested":False,"details":detail}
(D/"R8_BASELINE_RED_BLUE_COVERAGE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R8_BASELINE",json.dumps({k:report[k] for k in ["user_red_count","user_blue_count","red_seed_coarse_present","red_seed_coarse_missing","blue_exclusion_violations"]},ensure_ascii=False),flush=True)