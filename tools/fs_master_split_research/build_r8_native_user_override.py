#!/usr/bin/env python3
"""R8 FULL Ground + RED mandatory occluders / BLUE stairs exclusion in actual isolated FS VX.
Uses sealed 504 byte-identical script pages, #480 only test-disabled, never alters K4.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image
import json,subprocess,shutil,zlib,hashlib,re
R=Path(__file__).resolve().parent
D=R/"R8_USER_ANNOTATION_20261028"
OBJ=json.loads((D/"R8_USER_ANNOTATION_AUTHORITY.json").read_text(encoding="utf8"))
SAM=json.loads((D/"R8_SAM2_USER_ANNOTATION_RESULT.json").read_text(encoding="utf8"))
assert len(OBJ["user_red"])==8
assert SAM["sam2_prompt_consistent_count"]==8 and SAM["red_individual_seed_test_pass"]==8
assert SAM["blue_step_core_alpha"]==0
src=R/"R7_NATIVE_FULL_MASTER"/"FULL505"
out=R/"R8_NATIVE_FULL_MASTER"/"FULL505";out.parent.mkdir(exist_ok=True)
rc=subprocess.run(["robocopy",str(src),str(out),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert rc.returncode<8,(rc.returncode,rc.stdout[-800:])
official=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
ref=load(official.open("rb"));assert len(ref)==505
p=out/"Data"/"Scripts.rvdata"
pages=load(p.open("rb"))
assert len(pages)==506
assert all(pages[i if i<482 else i+1]==ref[i] for i in range(505) if i!=480)
txt=zlib.decompress(pages[482][2]).decode("ascii")
old_objs=json.loads((R/"R7_SEMANTIC_MASK_CANDIDATES"/"R7_SAM2_PROMPT_REGISTRY_GATE.json").read_text(encoding="utf8"))["objects"]
old_expr=json.dumps([[o["id"],o["foot"][1]] for o in old_objs],separators=(",",":"))
assert old_expr in txt,old_expr
new_objs=[[o["id"],o["foot"][1]] for o in old_objs]+[[o["id"],o["foot"][1]] for o in OBJ["user_red"]]
new_expr=json.dumps(new_objs,separators=(",",":"))
txt=txt.replace(old_expr,new_expr,1)
probe_current=[["LEFT_CONIFER_FRONT",[3,6],[4,3]],["HOUSE_FRONT_X8",[8,6],[10,4]],["HOUSE_FRONT_X9",[9,6],[10,4]],["RIGHT_MARKER_FRONT",[12,7],[12,5]],["CLEAR",[8,9],[9,9]]]
probe_next=[
 ["RED_HOUSE_CONIFER",[13,5],[13,3]],
 ["RED_FAR_RIGHT_CONIFER",[15,7],[15,4]],
 ["RED_LEFT_INNER_MICRO",[3,8],[3,6]],
 ["RED_BOTTOM_MICRO",[12,10],[12,8]],
 ["BLUE_STEPS",[9,6],[9,4]],
 ["CLEAR",[8,9],[9,9]]
]
current_expr=json.dumps(probe_current,separators=(",",":"))
assert "CASES = "+current_expr in txt
txt=txt.replace("CASES = "+current_expr,"CASES = "+json.dumps(probe_next,separators=(",",":")),1)
pages[482][2]=zlib.compress(txt.encode("ascii"))
with p.open("wb") as f:write(f,pages)
v=load(p.open("rb"))
assert all(v[i if i<482 else i+1]==ref[i] for i in range(505) if i!=480)
for i in [145,146,342]:assert v[i]==ref[i]
# Source-aligned single union Ground/Par. Ground is untouched original complete scene.
shutil.copy2(D/"PAR_R8_USER_RED_BLUE_SOURCE_ALIGNED.png",out/"Overlays"/"Par1.png")
# Strict BLUE exclusion applied to every dynamic image, not just static composite:
blue=Image.open(D/"R8_BLUE_STEPS_HARD_EXCLUSION_MASK.png").convert("L")
mask=blue.point(lambda x:255 if x else 0)
all_assets={}
for o in old_objs+OBJ["user_red"]:
 if "priority" in o:
  f=D/(o["id"]+"_"+o["name"]+"_SAM2_SOURCE_PAR.png")
 else:
  f=R/"R7_SEMANTIC_MASK_CANDIDATES"/(o["id"]+"_PAR_OCCLUSION_CANDIDATE.png")
 png=Image.open(f).convert("RGBA")
 # Keep all original source RGB, only set alpha zero in user excluded ellipse.
 a=png.getchannel("A")
 import PIL.ImageChops
 a=PIL.ImageChops.subtract(a,mask)
 png.putalpha(a)
 path=out/"Graphics"/"Pictures"/("R5_OC_"+o["id"]+".png")
 png.save(path)
 all_assets[o["id"]]=str(path)
# Blue must have zero alpha in all 20 extracted sprites, regardless of camera or actor movement.
x1,y1,x2,y2=OBJ["user_blue"][0]["core"]
assert all(max(Image.open(out/"Graphics"/"Pictures"/("R5_OC_"+o["id"]+".png")).getchannel("A").crop((x1,y1,x2,y2)).getdata())==0 for o in old_objs+OBJ["user_red"])
ini=out/"Game.ini";text=ini.read_bytes()
assert b"Title=FS_R7_PAR_SAME_SESSION" in text
ini.write_bytes(text.replace(b"Title=FS_R7_PAR_SAME_SESSION",b"Title=FS_R8_PAR_RED_BLUE_VX"))
(out/"ENABLE_R6_SAME_SESSION.flag").write_text("R8_ANNOTATED_PRIVATE_ISOLATED",encoding="ascii")
(out/"R6_A_B_A_NATIVE.log").write_text("R8_NATIVE_START\n",encoding="ascii")
report={"status":"R8_TEST_BUILD_PASS_NOT_NATIVE_TESTED","object_count":len(new_objs),"red_user_instances":8,"blue_user_stair_exclusion":True,
 "source_ground_unchanged":True,"all_20_depth_sprites_blue_excluded":True,"source_505_original_pages_preserved_except_disabled_480":504,
 "formal_505_full_boot_passed":False,"probe_scenarios":probe_next,
 "source_505_sha256":hashlib.sha256(official.read_bytes()).hexdigest(),
 "source_sam2_meta":SAM["status"],"art_gate_f":False}
(out.parent/"R8_BUILD_MANIFEST.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R8_NATIVE_BUILD",json.dumps({"objects":len(new_objs),"probes":len(probe_next),"excluded_blue":True,"screens_expected":len(probe_next)*3}),flush=True)