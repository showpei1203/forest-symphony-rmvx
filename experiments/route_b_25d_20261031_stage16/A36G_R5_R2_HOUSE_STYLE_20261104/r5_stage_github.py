from pathlib import Path
import json,hashlib,shutil
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
repo=Path(r"E:\FS_STAGE16_A36G_R4_GITHUB_SYNC_20261104")
target=repo/"experiments"/"route_b_25d_20261031_stage16"/"A36G_R5_R2_HOUSE_STYLE_20261104"
assert (repo/".git").exists() and not target.exists()
m=json.loads((R/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_R5_R2_BOTH_HOUSES_STYLE_UNIFIED_ENGINE_CANDIDATE"
target.mkdir(parents=True)
def copy(p,rel):
 dest=target/rel
 dest.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(p,dest)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
# Independent source house files and first failed variation for fully auditable provenance.
for name in ["A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png",
             "A36G_R5_LEFT_HOUSE_MATERIAL_STYLE_PATCH_RGBA.png",
             "A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png",
             "A36F_ELF_COTTAGE_B_MOSS_ROOF_RGBA.png"]:
 copy(R/"SOURCE_INDEPENDENT_RGBA"/name,"SOURCE_INDEPENDENT_RGBA/"+name)
copy(R/"SOURCE_INDEPENDENT_RGBA"/"A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_RGBA.png",
     "FAILED_CANDIDATES/A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_RGBA.png")
# All R5 stage scripts, original Ground/PAR, scene manifest, QA, visual proofs, native traces.
for p in R.iterdir():
 if not p.is_file():continue
 if p.suffix.lower() not in (".py",".md",".json",".png"):continue
 if "SUBMISSION_LOCK" in p.name:continue
 if p.name=="A36G_R4_PAR50_RGBA_1280x928.png" or p.name=="A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png":continue
 if p.name=="A36G_R4_PREVIEW_640.png" or p.name=="A36F_NATURAL_PATH_MASK.png":continue
 copy(p,p.name)
for p in (R/"R5_VX_CAPTURES").glob("A36G_VX_NATIVE_CASE_*.png"):
 copy(p,"R5_VX_CAPTURES/"+p.name)
for p in (R/"R5_VX_CAPTURES").glob("*.json"):
 copy(p,"R5_VX_CAPTURES/"+p.name)
godot=R/"GODOT_A36G_R5_40x29"
for name in ("project.godot","a36g_r5_godot_native_render.gd"):
 copy(godot/name,"GODOT_R5_NATIVE/"+name)
for p in (godot/"out").glob("*.json"):
 copy(p,"GODOT_R5_NATIVE/out/"+p.name)
manifest=[{"name":p.relative_to(target).as_posix(),"size":p.stat().st_size,"sha256":sha(p)} for p in sorted(target.rglob("*")) if p.is_file()]
(target/"R5_R2_GITHUB_FILES_SHA256.json").write_text(json.dumps({"stage":m["stage"],"files":manifest},indent=2,ensure_ascii=False),"utf8")
print(json.dumps({"stage":m["stage"],"git_folder":target.relative_to(repo).as_posix(),
 "files":len(manifest)+1,"bytes":sum(x["size"] for x in manifest),"scene_objects":len(m["objects"]),
 "left_style_locked_sha":m["house_left_locked_sha256"],
 "right_new_sha":m["house_right_new_sha256"],"formal_seal":"NO"},ensure_ascii=False,indent=2))
