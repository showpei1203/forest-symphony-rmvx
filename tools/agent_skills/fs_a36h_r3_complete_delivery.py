"""Archive FS A36H R3 real 197 source art + Ground/PAR + native proof + mistakes.
Private study only: approved original FS Ground3 and Source Registry's Hanzo assets may be license-restricted.
Do not upload raw art to public GitHub.
"""
from pathlib import Path
from PIL import Image
import json,hashlib,shutil,zipfile,numpy as np
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
ART=ROOT/"A36H_VISUAL_ART_REPAIR_20261107"
R1=ART/"A36H_R1_TRUE_GROUND_PAR_RECOMPILE"
R2=ART/"A36H_R2_GROUND3_PALETTE_MATCH"
R3=ART/"A36H_R3_C1_FULL_TRUE_SCENE_197_OBJECTS"
FOREST=ART/"A36H_R3_FOREST_WHOLE_GROUP_TEST"
ROOF=ART/"A36H_R3_C2_RAKE_AND_EAVE_ONLY"
NATIVE=ROOT/"A36H_R3_NATIVE_VISUAL_203_QA_20261107"
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
D=ROOT/"FS_A36H_R3_SOURCE_LAYER_NATIVE_ART_DELIVERY_20261107"
if D.exists():raise RuntimeError("FAIL CLOSED: delivery exists")
D.mkdir()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((R3/"A36H_R3_SCENE_MANIFEST.json").read_text("utf8"))
assert len(manifest["objects"])==197
for ob in manifest["objects"]:
 src=R3/"SOURCE_INDEPENDENT_RGBA"/ob["filename"]
 assert src.is_file() and sha(src)==ob["sha256"],ob["id"]
orig=json.loads((R5/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
for ob in orig["objects"]:
 assert sha(R5/"SOURCE_INDEPENDENT_RGBA"/ob["filename"])==ob["sha256"],ob["id"]
assert manifest["collision_map_29x40"]==orig["collision_map_29x40"]
# Verify actual same-source recomposition of all 197 new source RGBA in original z-order.
p=Image.new("RGBA",(1280,928),(0,0,0,0))
for ob in manifest["objects"]:
 p.alpha_composite(Image.open(R3/"SOURCE_INDEPENDENT_RGBA"/ob["filename"]).convert("RGBA"),(ob["x"],ob["y"]))
assert np.array_equal(np.asarray(p),np.asarray(Image.open(R3/"A36H_R3_AUTHORING_COMPLETE_PAR_197.png").convert("RGBA")))
ground=Image.open(R3/"A36H_R3_AUTHORING_GROUND_ONLY.png").convert("RGBA")
ground.alpha_composite(p)
master=np.asarray(Image.open(R3/"A36H_R3_RUNTIME_FULL_SCENE_GROUND.png").convert("RGB"))
assert np.array_equal(np.asarray(ground.convert("RGB")),master)
par=np.asarray(Image.open(R3/"A36H_R3_RUNTIME_10SOURCE_PARTIAL_PAR.png").convert("RGBA"))
occ=par[:,:,3]>0
assert np.array_equal(par[occ,:3],master[occ,:3])
n=json.loads((NATIVE/"A36H_R3_NATIVE_203_REAL_R5_COLLISION_QA.json").read_text("utf8"))
assert n["sample_gate"]=="PASS" and len(n["cases"])==6
records=[]
def cp(p,dest):
 assert p.is_file(),str(p)
 target=D/dest;target.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(p,target)
 assert sha(target)==sha(p)
 records.append({"path":target.relative_to(D).as_posix(),"bytes":target.stat().st_size,"sha256":sha(target)})
# All 197 final source objects
for f in sorted((R3/"SOURCE_INDEPENDENT_RGBA").iterdir()):
 if f.is_file():cp(f,"SOURCE_INDEPENDENT_RGBA/"+f.name)
# Complete authoring and real renderer artifacts
for f in R3.iterdir():
 if f.is_file():cp(f,"ART_R3_GROUND_PAR/"+f.name)
# Seven full forest groups and corrected re-sliced sources (final sources included above)
for f in (FOREST/"GROUP_FULL_SOURCE").glob("*.png"):
 cp(f,"FOREST_7_WHOLE_GROUPS/"+f.name)
cp(FOREST/"R3_7FOREST_GROUP_QA.json","FOREST_7_WHOLE_GROUPS/R3_7FOREST_GROUP_QA.json")
# Build/failed art candidates
for file in (ROOF/"R3_HOUSE_ROOF_QA.json",):
 cp(file,"HOUSE_ROOF_ART/"+file.name)
for f in ROOF.glob("*_R2_VS_R3_1X.png"):
 cp(f,"HOUSE_ROOF_ART/"+f.name)
for f in (ART/"A36H_R3_ARCHITECTURAL_GEOMETRY_TEST").glob("*_R2_VS_R3_1X.png"):
 cp(f,"FAILURES_FLOATING_FASCIA/"+f.name)
for f in (ART/"A36H_R3_C3_CLEAN_EAVE_SILHOUETTE").glob("*_R3C2_VS_R3C3_1X.png"):
 cp(f,"FAILURES_GREY_ROOF_HOLES/"+f.name)
for f in (ART/"A36H_R3_FIVE_FOREST_EDGE_TREES_TEST").iterdir():
 if f.is_file() and f.suffix.lower() in (".png",".json"):
  cp(f,"FIVE_NEW_TREES/"+f.name)
# Native evidence no Game.exe exe in ZIP, but native Map050 can use authorized engine clone
for f in NATIVE.iterdir():
 if f.is_file() and f.suffix in (".json",".png"):
  cp(f,"VX_NATIVE_203/"+f.name)
mapfile=ROOT/"A36G_V7_R5_NATIVE_COLLISION_REAL_MAP50_20261107"/"VX_NATIVE_40x29_COLLISION_GRID_PROBE/Data/Map050.rvdata"
cp(mapfile,"VX_NATIVE_203/Data/Map050.rvdata")
for name in [
 "a36h_r3_c2_roof_edge_only.py","a36h_r3_restore_whole_forests.py",
 "a36h_r3_forest_edge_tree_trial.py","a36h_r3_true_scene_compiler.py",
 "fs_a36h_r3_native203.py",
 "a36h_r3_fascia_test.py","a36h_r3_c3_trim_old_thatch_fringe.py",
 "a36h_r3_tree_edge_probe.py"
]:
 cp(ROOT/name,"REBUILD_SCRIPTS/"+name)
cp(ROOT/"CURRENT_HANDOFF_A36H_R3_ROOFS_FOREST_SOURCE_20261107.md","HANDOFF/CURRENT_HANDOFF_A36H_R3_ROOFS_FOREST_SOURCE_20261107.md")
index={
 "stage":"A36H_R3_197_SOURCE_LAYERED_NATIVE_ART_REPAIR_PRIVATE_STUDY",
 "date":"2026-11-07","canvas":[1280,928],
 "count_source_png":197,"original_192_R5_protected_shas_unchanged":True,
 "forest_group_authoring_whole_groups":7,"original_slices_reexported":44,"minor_void_fill_source_pixels":9040,
 "house_edge_roof_C2_only":"selected; floating fascia C1 FAIL; alpha removal C3 FAIL",
 "new_native_tree_source_count":5,"new_tree_roots_on_existing_blocked_cells":True,
 "full_par_197_image_exact_recompose":True,"runtime_full_image_exact_ground_plus_complete_par":True,
 "native_occlusion_par_RGB_pixel_exact":True,"native_map050":"R5 A36G original collision",
 "native_203_old_five_samples_plus_negative":"6/6 PASS",
 "new_five_tree_individual_203":"NOT_RUN",
 "full_197_object_occlusion":"NOT_RUN",
 "visual_art_acceptance":"PENDING: architecture + forest overall style not approved",
 "source_license":"PRIVATE STUDY ONLY; Hanzo original and reference textures LICENSE_UNVERIFIED",
 "formal_seal":"NO","files":records
}
indexfile=D/"DELIVERY_R3_SHA256_COMPLETE_MANIFEST.json"
indexfile.write_text(json.dumps(index,ensure_ascii=False,indent=2),encoding="utf8")
zipf=ROOT/"FS_A36H_R3_REAL_197_SOURCE_GROUND_PAR_ART_VX_20261107.zip"
if zipf.exists():raise RuntimeError("archive exists")
allfiles=sorted([x for x in D.rglob("*") if x.is_file()])
with zipfile.ZipFile(zipf,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in allfiles:z.write(f,f.relative_to(D).as_posix())
with zipfile.ZipFile(zipf) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(allfiles)
stage=Path("G:/我的雲端硬碟/FS_AGENT_SKILLS_UPLOAD_STAGING_20261107")
assert stage.is_dir()
upload=[
 zipf,indexfile,
 ROOT/"CURRENT_HANDOFF_A36H_R3_ROOFS_FOREST_SOURCE_20261107.md",
 R3/"A36H_R3_FULLSCENE_R2_VS_R3_640.png",
 R3/"A36H_R3_RUNTIME_FULL_SCENE_GROUND.png",
 R3/"A36H_R3_LEFT_HOUSE_R2_VS_R3_1X.png",
 R3/"A36H_R3_FOREST_NORTH_R2_VS_R3_1X.png",
 R3/"A36H_R3_C1_PIXEL_QA.json",
 NATIVE/"A36H_R3_NATIVE_5OBJECTS_6CASES_OFF_ON_CONTACT.png"]
up=[]
for f in upload:
 to=stage/f.name;shutil.copy2(f,to)
 up.append({"title":f.name,"bytes":f.stat().st_size,"sha_matches_staging":sha(f)==sha(to)})
assert all(x["sha_matches_staging"] for x in up)
print(json.dumps({"archive_file_count":len(allfiles),"zip_bytes":zipf.stat().st_size,
"CRC":"PASS","old_r5_shas":"PASS","native_203":n["sample_gate"],
"all_197_sources_recomposed":True,"uploads":up},ensure_ascii=False,indent=2),flush=True)