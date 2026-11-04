"""Stage ONLY A36G R4 R3 files into a new GitHub clone checkout. No changes to other branches/files."""
from pathlib import Path
import json,shutil,hashlib
R=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
repo=Path(r"E:\FS_STAGE16_A36G_R4_GITHUB_SYNC_20261104")
target=repo/"experiments"/"route_b_25d_20261031_stage16"/"A36G_R4_R3_6REGIONS_20261104"
assert (repo/".git").exists()
assert not target.exists(),"Do not overwrite previously staged checkpoint"
target.mkdir(parents=True)
m=json.loads((R/"A36G_R4_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_R4_6REGIONS_R3_ROOT_ART_FIX_ENGINE_CANDIDATE"
src=target/"SOURCE_INDEPENDENT_RGBA";src.mkdir()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
sources={o["filename"] for o in m["objects"]}
# Preserve original whole forest regions independently of the compiled crops/alpha operations.
for rid in ("NORTH_WEST","NORTH_EAST","EAST","SOUTH_WEST","SOUTH_CENTRE","SOUTH_EAST"):
 sources.add(f"A36G_R4_{rid}_PIXELLAB_CONTIGUOUS_RGBA.png")
 sources.add(f"A36G_R4_{rid}_COMPILED_CLEARING_SAFE_RGBA.png")
 sources.add(f"A36G_R4_{rid}_COMPILED_SEAM_TAPER_R2_RGBA.png")
sources.update(("A36G_PIXELLAB_WEST_FOREST_CONTIGUOUS_FULL_R3B_RGBA.png",
 "A36G_PIXELLAB_WEST_FOREST_R3B_ROAD_SAFE_RGBA.png",
 "A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png"))
for n in sorted(sources):
 p=R/"SOURCE_INDEPENDENT_RGBA"/n
 assert p.exists(),str(p)
 shutil.copy2(p,src/n)
# Every tool and meaningful independent QA record, no credentials.
for p in R.iterdir():
 if not p.is_file():continue
 if p.suffix.lower() not in (".py",".md",".json",".png"):continue
 if "_PROVIDER_LOCK.json" in p.name:continue
 if p.name.endswith("_PACKAGE_SHA256_MANIFEST.json"):continue
 if p.name.endswith("_PRIVATE_ARCHIVE_QA.json"):continue
 if p.name.startswith("A36G_R3B_BASE_"):continue
 if p.name in ("R4_NORTH_EAST_THREE_SOURCE_QA.png",):continue
 shutil.copy2(p,target/p.name)
for p in (R/"R4_R3_VX_CAPTURES").glob("A36G_VX_NATIVE_CASE_*.png"):
 (target/"R4_R3_VX_CAPTURES").mkdir(exist_ok=True)
 shutil.copy2(p,target/"R4_R3_VX_CAPTURES"/p.name)
for n in ("A36G_VX_NATIVE_11_CASES_SCREEN_QA.json",):
 shutil.copy2(R/"R4_R3_VX_CAPTURES"/n,target/"R4_R3_VX_CAPTURES"/n)
# Minimal Godot source and GPU evidence, NOT the Godot runtime cache.
GD=R/"GODOT_A36G_R4_R3_40x29"
(target/"GODOT_R4_R3").mkdir(exist_ok=True)
for n in ("project.godot","a36g_r4_r3_godot_native_render.gd"):
 shutil.copy2(GD/n,target/"GODOT_R4_R3"/n)
for p in (GD/"out").glob("*.json"):
 (target/"GODOT_R4_R3"/"out").mkdir(exist_ok=True)
 shutil.copy2(p,target/"GODOT_R4_R3"/"out"/p.name)
sha_list=[]
for f in sorted(target.rglob("*")):
 if f.is_file():sha_list.append({"path":f.relative_to(target).as_posix(),"bytes":f.stat().st_size,"sha":sha(f)})
(target/"R4_R3_GITHUB_SOURCE_FILE_HASHES.json").write_text(json.dumps({"source_stage":m["stage"],"items":sha_list},indent=2),"utf8")
print(json.dumps({"repo":str(repo),"checkpoint_folder":target.relative_to(repo).as_posix(),
 "scene_objects":len(m["objects"]),"source_assets_copied":len(sources),
 "all_files":len(sha_list)+1,"bytes":sum(z["bytes"] for z in sha_list),
 "formal_seal":"NO"},indent=2),flush=True)
