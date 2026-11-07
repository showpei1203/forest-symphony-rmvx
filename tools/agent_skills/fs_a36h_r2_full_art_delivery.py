"""A36H R2 real art + 192-source Ground/PAR full reproducible package.
Native actual screenshots, reference comparisons, authoritative manifest and SHA256.
Fail closed, keep protected R5/Ground3 and R7 source bytes unchanged.
"""
from pathlib import Path
import json,hashlib,zipfile,shutil
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
VIS=ROOT/"A36H_VISUAL_ART_REPAIR_20261107"
R1=VIS/"A36H_R1_TRUE_GROUND_PAR_RECOMPILE"
R2=VIS/"A36H_R2_GROUND3_PALETTE_MATCH"
NATIVE=ROOT/"A36H_R2_NATIVE_VISUAL_203_QA_20261107"
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
TARGET=ROOT/"FS_A36H_R2_VISUAL_ART_COMPLETE_DELIVERY_20261107"
if TARGET.exists():raise RuntimeError("FAIL CLOSED: full delivery exists")
TARGET.mkdir(parents=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r5=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
r2=json.loads((R2/"A36H_R2_SCENE_MANIFEST.json").read_text("utf8"))
assert len(r5["objects"])==len(r2["objects"])==192
copylist=[]
def cp(p,dest):
 assert p.is_file(),p
 q=TARGET/dest
 q.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(p,q)
 assert sha(q)==sha(p)
 copylist.append({"file":q.relative_to(TARGET).as_posix(),"bytes":q.stat().st_size,"sha256":sha(q)})
# Full collection of actually edited RGBA sources (not references to private local folders).
for ob in r2["objects"]:
 p=R1/"SOURCE_INDEPENDENT_RGBA"/ob["filename"]
 assert p.is_file() and sha(p)==ob["sha256"],ob["id"]
 cp(p,"SOURCE_INDEPENDENT_RGBA/"+p.name)
for p in R2.iterdir():
 if p.is_file():
  cp(p,"GROUND_PAR_R2/"+p.name)
# Source art actual 1x before / after, reject first take too.
for pattern in ["*_SOURCE_V2_BEFORE_AFTER_1X.png","*_SOURCE_BEFORE_AFTER_1X.png","APPROVED_*_1X.png"]:
 for p in VIS.glob(pattern):cp(p,"ART_PROOF/"+p.name)
for pattern in ["A36H_R1_LEFT_HOUSE_BEFORE_AFTER_1X.png","A36H_R1_RIGHT_HOUSE_BEFORE_AFTER_1X.png","A36H_R1_FOREST_BLUEGREEN_NORTH_BEFORE_AFTER_1X.png","A36H_R1_FULLSCENE_R5_BEFORE_AFTER_640.png","A36H_R1_PIXEL_SOURCE_QA.json","A36H_R1_SCENE_MANIFEST.json"]:
 cp(R1/pattern,"ART_PROOF/"+pattern)
for p in NATIVE.iterdir():
 if p.is_file() and p.suffix in (".png",".json"):
  cp(p,"NATIVE_VX_203/"+p.name)
# Actual A36G R5-native compiled Map050 from V12 was used in engine.
native_map=ROOT/"A36G_V7_R5_NATIVE_COLLISION_REAL_MAP50_20261107"/"VX_NATIVE_40x29_COLLISION_GRID_PROBE/Data/Map050.rvdata"
cp(native_map,"NATIVE_VX_203/Data/Map050.rvdata")
scripts=[
"a36h_reference_crops.py","a36h_v1_roof_texture_from_original.py",
"a36h_v2_roof_exact_reference.py","a36h_tree_palette_test.py",
"a36h_r1_compile_actual_ground_par.py","a36h_r2_canonical_ground_palette.py",
"fs_a36h_r2_native_vx203.py"]
for n in scripts:cp(ROOT/n,"SCRIPTS/"+n)
cp(ROOT/"CURRENT_HANDOFF_A36H_R2_VISUAL_GROUND_PAR_20261107.md","HANDOFF/CURRENT_HANDOFF_A36H_R2_VISUAL_GROUND_PAR_20261107.md")
# Independently check complete authoring full scene RGB recomposition.
from PIL import Image
import numpy as np
base=Image.open(R2/"A36H_R2_AUTHORING_GROUND_ONLY.png").convert("RGBA")
par=Image.open(R2/"A36H_R2_AUTHORING_COMPLETE_PAR.png").convert("RGBA")
base.alpha_composite(par)
full=np.asarray(base.convert("RGB"))
assert np.array_equal(full,np.asarray(Image.open(R2/"A36H_R2_RUNTIME_FULL_SCENE_GROUND.png").convert("RGB")))
mask=np.asarray(Image.open(R2/"A36H_R2_RUNTIME_SOURCE_OWNED_5_PAR.png").convert("RGBA"))
keep=mask[:,:,3]>0
assert np.array_equal(mask[keep,:3],full[keep])
assert sha(R2/"A36H_R2_AUTHORING_COMPLETE_PAR.png")==sha(R1/"A36H_R1_AUTHORING_COMPLETE_PAR.png")
assert r2["collision_map_29x40"]==r5["collision_map_29x40"]
# Verify ORIGINAL source 192 never touched
for obj in r5["objects"]:
 p=R5/"SOURCE_INDEPENDENT_RGBA"/obj["filename"]
 assert sha(p)==obj["sha256"],("R5 PROTECTION FAIL",obj["id"])
with open(NATIVE/"A36H_R2_NATIVE_203_REAL_R5_COLLISION_QA.json","r",encoding="utf8") as f:native=json.load(f)
assert native["sample_gate"]=="PASS" and len(native["cases"])==6
index={
 "stage":"A36H_R2_REAL_RPGVX_GROUND_PAR_ORIGINAL_STYLE_ART_CANDIDATE",
 "date":"2026-11-07","canvas":[1280,928],
 "sources_all_192_in_package":True,
 "prior_192_R5_sources_SHA_unmodified":True,
 "original_approved_FS_Ground3_sha":"ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13",
 "R5_source_exact_recompile_before_edit":True,
 "candidate_modified_source_count":105,
 "complete_authoring_par_true_recomposition":True,
 "runtime_5_object_PAR_RGB_exact":True,
 "R5_collision_unchanged":True,
 "true_native_VX_GAMEXE_203":"6/6 PASS",
 "native_movement_A36H_R2":"NOT TESTED (R7 previous 5/5 is different art build)",
 "godot_A36H_R2":"NOT RUN",
 "visual_acceptance":"PENDING (visible improvement, building silhouette / forest group shape unresolved)",
 "formal_seal":"NO",
 "file_entries":copylist
}
manifest=TARGET/"DELIVERY_SHA256_MANIFEST.json"
manifest.write_text(json.dumps(index,ensure_ascii=False,indent=2),encoding="utf8")
archive=ROOT/"FS_A36H_R2_ACTUAL_GROUND_PAR_ART_SOURCE_VX_QA_20261107.zip"
if archive.exists():raise RuntimeError("Refused existing zip")
files=[p for p in TARGET.rglob("*") if p.is_file()]
with zipfile.ZipFile(archive,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in files:z.write(p,p.relative_to(TARGET).as_posix())
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(files)
stage=Path(r"G:\我的雲端硬碟\FS_AGENT_SKILLS_UPLOAD_STAGING_20261107")
assert stage.is_dir()
uploads=[archive,manifest,ROOT/"CURRENT_HANDOFF_A36H_R2_VISUAL_GROUND_PAR_20261107.md",
 R2/"A36H_R2_FULL_SCENE_R5_BEFORE_AFTER_640.png",
 R2/"GROUND_CENTER_R1_VS_R2_1X.png",
 R2/"A36H_R2_RUNTIME_FULL_SCENE_GROUND.png",
 NATIVE/"A36H_R2_NATIVE_5OBJECTS_6CASES_OFF_ON_CONTACT.png",
 R2/"A36H_R2_PALETTE_AND_LAYER_QA.json",
 R1/"A36H_R1_LEFT_HOUSE_BEFORE_AFTER_1X.png",
 R1/"A36H_R1_RIGHT_HOUSE_BEFORE_AFTER_1X.png"]
copied=[]
for p in uploads:
 dest=stage/p.name
 shutil.copy2(p,dest)
 copied.append({"file":p.name,"bytes":p.stat().st_size,"synced_sha_match":sha(p)==sha(dest)})
assert all(x["synced_sha_match"] for x in copied)
print(json.dumps({"full_package_member_count":len(files),"bytes":archive.stat().st_size,
 "zip_crc":"PASS","original_192_src_SHA_unchanged":True,"R2_NATIVE_VX":native["sample_gate"],
 "sources_shipped":192,"staging_uploads":copied},ensure_ascii=False,indent=2),flush=True)