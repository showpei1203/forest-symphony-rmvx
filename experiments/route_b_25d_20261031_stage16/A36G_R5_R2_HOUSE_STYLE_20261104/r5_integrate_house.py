"""One original RIGHT house regenerated as a coherent full sprite with LEFT house locked. True Ground+PAR, no imported concept layer."""
from pathlib import Path
import json,hashlib,shutil
import numpy as np
from PIL import Image,ImageDraw
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((R/"R5_BASE_R4_SCENE_MANIFEST.json").read_text("utf8"))
assert base["stage"]=="A36G_R4_6REGIONS_R3_ROOT_ART_FIX_ENGINE_CANDIDATE"
a=next(o for o in base["objects"] if o["id"]=="A36G_ELF_HOUSE_AND_WORKSHOP")
b=next(o for o in base["objects"] if o["id"]=="A36F_ELF_COTTAGE_B")
left=S/a["filename"]
old=S/b["filename"]
new=S/"A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_RGBA.png"
assert new.exists(),f"No PixelLab original: {new}"
lock=R/"A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_SUBMISSION_LOCK.json"
z=json.loads(lock.read_text("utf8"))
assert z["status"]=="SOURCE_READY_UNREVIEWED" and z["output_sha"]==sha(new),z.get("status")
assert sha(left)==a["sha256"] and sha(old)==b["sha256"]
assert b["x"]==770 and b["y"]==360 and b["w"]==198 and b["h"]==236
im=Image.open(new).convert("RGBA")
assert im.size==(198,236),im.size
mask=np.array(im.getchannel("A"))
assert int((mask>0).sum())>=3000,"Source too empty"
assert all(im.getpixel(p)[3]==0 for p in [(0,0),(197,0),(0,235),(197,235)]),"No transparent corner"
m=json.loads(json.dumps(base))
o=next(x for x in m["objects"] if x["id"]==b["id"])
o["filename"]=new.name;o["sha256"]=sha(new)
o["id"]="A36G_R5_ELF_COTTAGE_B_MATCHED"
o["source_parent"]="ORIGINAL_LEFT_PIXELLAB_HOUSE_STYLE_AND_RIGHT_ORIGINAL_LAYOUT_REFERENCE"
o["design_variation"]="ONE_COMPLETE_NEW_RIGHT_COTTAGE_ARCHITECTURE_NO_PASTED_PARTS"
o["art_gate"]="PENDING_REFERENCE_COMPARISON"
m["objects"].sort(key=lambda q:(q["foot"][1],q["id"]))
m["stage"]="A36G_R5_BOTH_HOUSES_STYLE_MATCH_R1_CANDIDATE"
m["house_A_locked_sha256"]=a["sha256"]
m["house_B_new_sha256"]=sha(new)
m["house_B_old_sha256"]=sha(old)
m["source_R4_manifest_sha256"]=sha(R4/"A36G_R4_SCENE_MANIFEST.json")
m["house_B_footprint_status"]="UNCHANGED_FROM_R4_PENDING_NATIVE_TEST"
m["forest_source_integrity"]="ALL_ORIGINAL_UNCHANGED"
m["formal_seal"]="NO"
# Independent actual 1280x928 alpha PAR derived ONLY from each independent object.
par=Image.new("RGBA",(1280,928),(0,0,0,0))
for q in m["objects"]:
 p=S/q["filename"]
 assert p.exists() and sha(p)==q["sha256"],q["id"]
 t=Image.open(p).convert("RGBA")
 assert t.size==(q["w"],q["h"]),q["id"]
 par.alpha_composite(t,(q["x"],q["y"]))
parfile=R/"A36G_R5_PAR50_RGBA_1280x928.png"
par.save(parfile,optimize=True)
gp=R/"A36G_R5_GROUND_1280x928.png"
shutil.copy2(R/"A36G_R4_GROUND_1280x928.png",gp)
ground=Image.open(gp).convert("RGBA");ground.alpha_composite(par)
combined=R/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"
ground.convert("RGB").save(combined,optimize=True)
ground.convert("RGB").resize((640,464),Image.Resampling.NEAREST).save(R/"A36G_R5_PREVIEW_640.png",optimize=True)
# Original prior right house ground/par vs new right house in true 1:1 source pixels.
prev=Image.open(R/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
now=ground.convert("RGB")
crop=(742,328,1010,630)
side=Image.new("RGB",(536,329),(26,26,29));dr=ImageDraw.Draw(side)
side.paste(prev.crop(crop),(0,24));side.paste(now.crop(crop),(268,24))
dr.text((8,5),"R4 old cottage B / style mismatch",fill="white")
dr.text((275,5),"R5 new whole cottage B / PixelLab",fill="white")
side.save(R/"A36G_R4_VS_R5_RIGHT_HOUSE_NATIVE_1X.png",optimize=True)
# Before/after full map, from actual independent Ground/PAR.
large=Image.new("RGB",(1280,494),(27,29,31));dl=ImageDraw.Draw(large)
large.paste(prev.resize((640,464),Image.Resampling.NEAREST),(0,28))
large.paste(now.resize((640,464),Image.Resampling.NEAREST),(640,28))
dl.text((7,5),"R4 original right cottage (not coherent with left)",fill="white")
dl.text((649,5),"R5 single-source right cottage; left and forest unchanged",fill="white")
large.save(R/"A36G_R4_VS_R5_FULL_NATIVE_GROUND_PAR_COMPARISON.png",optimize=True)
# Source comparison for art judgement on neutral grey, both source images unchanged.
aimg=Image.open(left).convert("RGBA")
bg=Image.new("RGBA",(600,290),(213,217,206,255))
bg.alpha_composite(aimg,(15,14))
bg.alpha_composite(im,(354,25))
bg.convert("RGB").save(R/"A36G_R5_BOTH_ORIGINAL_RGBA_HOUSES_CONTACT.png",optimize=True)
m["ground_sha256"]=sha(gp);m["par_sha256"]=sha(parfile);m["composite_sha256"]=sha(combined)
(R/"A36G_R5_SCENE_MANIFEST.json").write_text(json.dumps(m,indent=2,ensure_ascii=False),"utf8")
# Only changed right cottage PNG, not ground, trees or collisions.
changed_ids=[q["id"] for q in base["objects"] if q["filename"]==o["filename"]]
assert not changed_ids,"New source file was used in prior R4 stage"
q={"stage":m["stage"],"scene_objects":len(m["objects"]),
"right_old_original_sha256":sha(old),"right_new_original_sha256":sha(new),
"left_locked_sha256":sha(left),"left_original_unchanged":sha(left)==a["sha256"],
"right_size":list(im.size),"alpha_bbox":im.getbbox(),
"source_alpha_pixels":int((mask>0).sum()),
"source_no_background_corners":True,
"right_house_geometry":[o["x"],o["y"],o["w"],o["h"]],"right_foot":o["foot"],
"source_house_B_colliding_footprint_px":o["blocking_footprint_px"],
"ground_sha256":sha(gp),"ground_unchanged":sha(gp)==sha(R4/"A36G_R4_GROUND_1280x928.png"),
"forest_source_hashes_unchanged":True,"par_sha256":sha(parfile),"composite_sha256":sha(combined),
"VX_NATIVE":"NOT_RUN","GODOT":"NOT_RUN","art_gate":"PENDING","formal_seal":"NO"}
(R/"A36G_R5_HOUSE_STYLE_INTEGRATION_QA.json").write_text(json.dumps(q,indent=2,ensure_ascii=False),"utf8")
print(json.dumps(q,indent=2,ensure_ascii=False),flush=True)
