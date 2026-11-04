from pathlib import Path
import json,hashlib,shutil
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
S=R5/"SOURCE_INDEPENDENT_RGBA"
S.mkdir(parents=True,exist_ok=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R4/"A36G_R4_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_R4_6REGIONS_R3_ROOT_ART_FIX_ENGINE_CANDIDATE"
for o in m["objects"]:
 a=R4/"SOURCE_INDEPENDENT_RGBA"/o["filename"]
 assert sha(a)==o["sha256"],o["id"]
 t=S/o["filename"]
 if not t.exists():shutil.copy2(a,t)
for n in ("A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png",
 "A36F_ELF_COTTAGE_B_MOSS_ROOF_RGBA.png",
 "A36G_PIXELLAB_WEST_FOREST_CONTIGUOUS_FULL_R3B_RGBA.png"):
 a=R4/"SOURCE_INDEPENDENT_RGBA"/n
 if not (S/n).exists():shutil.copy2(a,S/n)
for n in ("A36G_R4_GROUND_1280x928.png","A36G_R4_PAR50_RGBA_1280x928.png",
 "A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png","A36G_R4_PREVIEW_640.png",
 "A36F_NATURAL_PATH_MASK.png"):
 if not (R5/n).exists():shutil.copy2(R4/n,R5/n)
(R5/"R5_BASE_R4_SCENE_MANIFEST.json").write_text(json.dumps(m,indent=2,ensure_ascii=False),"utf8")
houses=[o for o in m["objects"] if o["type"]=="house"]
assert len(houses)==2
(R5/"R5_HOUSE_STYLE_BLUEPRINT.json").write_text(json.dumps({
 "source_stage":m["stage"],
 "base_scene_manifest_sha256":sha(R4/"A36G_R4_SCENE_MANIFEST.json"),
 "house_A_left":{"id":houses[0]["id"],"sha256":houses[0]["sha256"],"native_png":houses[0]["filename"],"status":"LOCKED_STABLE_REFERENCE"},
 "house_B_right":{"id":houses[1]["id"],"old_sha256":houses[1]["sha256"],"geometry":[houses[1]["x"],houses[1]["y"],houses[1]["w"],houses[1]["h"]],"foot":houses[1]["foot"],"status":"REPLACE_WHOLE_ONE_PIECE_RGBA"},
 "requested_unification":"same three-quarter view, mossy golden olive thatch textured roof, warm timber frame and sandstone foundation, detailed pixel clusters, architecture unity; preserve door entry relative to ground path",
 "scope":"right house source replacement only. No generated concept accepted as finished. Ground and forest layers locked.",
 "engine_gate":"NOT_RUN","art_gate":"PENDING","formal_seal":"NO"
},indent=2,ensure_ascii=False),"utf8")
print(json.dumps({"r5":str(R5),"r4_source_sha":sha(R4/"A36G_R4_SCENE_MANIFEST.json"),"r5_objects":len(m["objects"]),"house_A_sha":houses[0]["sha256"],"house_B_old_sha":houses[1]["sha256"]},indent=2))
