from pathlib import Path
import hashlib,json,shutil
from PIL import Image,ImageDraw
import numpy as np
R=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R/"A36G_R4_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_R4_6REGIONS_SEAM_R2_ENGINE_CANDIDATE"
q=json.loads((R/"A36G_R4_ROOT_COVERAGE_QA.json").read_text("utf8"))
base=json.loads((R/"R4_BASE_SCENE_MANIFEST.json").read_text("utf8"))
bad={x["id"] for x in q["bad_cases"]}
assert len(bad)==3,bad
old={o["id"]:o for o in base["objects"]}
R2=R/"R4_R2_PRE_ROOT_REPAIR";R2.mkdir(exist_ok=True)
for n in ("A36G_R4_SCENE_MANIFEST.json","A36G_R4_PAR50_RGBA_1280x928.png",
          "A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png","A36G_R4_PREVIEW_640.png"):
 if not (R2/n).exists():shutil.copy2(R/n,R2/n)
present={o["id"] for o in m["objects"]}
for id in sorted(bad):
 obj=dict(old[id])
 assert id not in present and obj["type"]=="tree" and obj["blocking"]
 p=S/obj["filename"]
 assert p.exists() and sha(p)==obj["sha256"]
 m["objects"].append(obj)
m["objects"].sort(key=lambda o:(o["foot"][1],o["id"]))
m["restored_legacy_tree_ids_after_seam_audit"]=sorted(bad)
m["stage"]="A36G_R4_6REGIONS_R3_ROOT_ART_FIX_ENGINE_CANDIDATE"
m["root_coverage_stage"]="restored 3 original root-anchored tree sources visible at former alpha gaps"
m["forest_art_gate"]="CANDIDATE_UNREVIEWED"
m["collision_gate"]="STATIC_BFS_PASS_FULL_ROOT_ART_AUDIT_PENDING"
m["formal_seal"]="NO"
par=Image.new("RGBA",(1280,928),(0,0,0,0))
for o in m["objects"]:
 p=S/o["filename"]
 assert sha(p)==o["sha256"],o["id"]
 img=Image.open(p).convert("RGBA")
 assert img.size==(o["w"],o["h"]),o["id"]
 par.alpha_composite(img,(o["x"],o["y"]))
pf=R/"A36G_R4_PAR50_RGBA_1280x928.png"
par.save(pf,optimize=True)
ground=Image.open(R/"A36G_R4_GROUND_1280x928.png").convert("RGBA")
ground.alpha_composite(par)
cf=R/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png"
ground.convert("RGB").save(cf,optimize=True)
ground.convert("RGB").resize((640,464),Image.Resampling.NEAREST).save(R/"A36G_R4_PREVIEW_640.png",optimize=True)
m.update(par_sha256=sha(pf),composite_sha256=sha(cf))
(R/"A36G_R4_SCENE_MANIFEST.json").write_text(json.dumps(m,indent=2,ensure_ascii=False),"utf8")
before=Image.open(R2/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
side=Image.new("RGB",(1280,492),(25,26,28));d=ImageDraw.Draw(side)
side.paste(before.resize((640,464),Image.Resampling.NEAREST),(0,28))
side.paste(ground.convert("RGB").resize((640,464),Image.Resampling.NEAREST),(640,28))
d.text((8,6),"R4 R2 - three potentially invisible root blockers",fill="white")
d.text((648,6),"R4 R3 - three native root tree sources restored",fill="white")
side.save(R/"A36G_R4_R2_VS_R3_ROOT_REPAIR_COMPARISON.png",optimize=True)
report={"stage":m["stage"],"restored_source_ids":sorted(bad),"total_sprites":len(m["objects"]),
 "par_sha256":sha(pf),"composite_sha256":sha(cf),"native_engine":"REBUILD_REQUIRED",
 "full_collision_semantic":"PENDING","art_gate":"PENDING","formal_seal":"NO"}
(R/"A36G_R4_R3_ROOT_REPAIR_QA.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),"utf8")
print(json.dumps(report,indent=2,ensure_ascii=False),flush=True)
