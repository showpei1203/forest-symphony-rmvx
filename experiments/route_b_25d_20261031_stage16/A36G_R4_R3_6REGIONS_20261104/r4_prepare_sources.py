from pathlib import Path
import json,shutil,hashlib
F=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103")
R3=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
R4.mkdir(parents=True,exist_ok=True)
src=R4/"SOURCE_INDEPENDENT_RGBA";src.mkdir(exist_ok=True)
m=json.loads((R3/"A36G_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_PIXELLAB_HOUSE_R2_WEST_FOREST_R3B_CANDIDATE"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for o in m["objects"]:
 a=R3/"SOURCE_INDEPENDENT_RGBA"/o["filename"]
 assert sha(a)==o["sha256"],o["id"]
 b=src/o["filename"]
 if not b.exists():shutil.copy2(a,b)
for n in ("A36G_PIXELLAB_WEST_FOREST_CONTIGUOUS_FULL_R3B_RGBA.png",
          "A36G_PIXELLAB_WEST_FOREST_R3B_ROAD_SAFE_RGBA.png",
          "A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png"):
 a=R3/"SOURCE_INDEPENDENT_RGBA"/n
 if not (src/n).exists():shutil.copy2(a,src/n)
for a,b in [
 ("A36G_GROUND_1280x928.png","A36G_R4_GROUND_1280x928.png"),
 ("A36G_PAR50_RGBA_1280x928.png","A36G_R3B_BASE_PAR50_RGBA_1280x928.png"),
 ("A36G_TRUE_GROUND_PLUS_PAR_1280x928.png","A36G_R3B_BASE_COMPOSITE_1280x928.png"),
 ("A36F_NATURAL_PATH_MASK.png","A36F_NATURAL_PATH_MASK.png"),
 ("A36G_PREVIEW_640.png","A36G_R3B_BASE_PREVIEW_640.png")]:
 p=R4/b
 if not p.exists():shutil.copy2(R3/a,p)
(R4/"R4_BASE_SCENE_MANIFEST.json").write_text(json.dumps(m,indent=2,ensure_ascii=False),"utf8")
regions=[
 {"id":"NORTH_WEST","x":310,"y":-145,"w":464,"h":432,
  "description":"North edge deep green woodland curtain. Irregular lower border descending into northwest corner; west edge crowns overlap an existing forest. Trunks visible at the south fringe."},
 {"id":"NORTH_EAST","x":714,"y":-140,"w":464,"h":432,
  "description":"North-eastern deep woods continuous canopy, dense varied leaf clusters, subtle old conifers among oaks, irregular south fringe."},
 {"id":"EAST","x":976,"y":260,"w":464,"h":564,
  "description":"Tall vertical eastern woodland; foliage continues off right edge; ragged WEST margin showing many distinct crowns and trunks near clearing, irregular bottom."},
 {"id":"SOUTH_WEST","x":-86,"y":435,"w":464,"h":552,
  "description":"Deep southwest forest and lower map edge, abundant layered crowns of oak and narrow conifer, ragged northeast edge, roots near the border."},
 {"id":"SOUTH_CENTRE","x":322,"y":535,"w":464,"h":552,
  "description":"Dense deep southern woods spanning bottom edge, irregular upper border opening to village clearing. Rich natural overlapping 3/4 tree crowns, trunks toward clearings."},
 {"id":"SOUTH_EAST","x":754,"y":545,"w":464,"h":552,
  "description":"Dense south east forest and bottom-right edge, contiguous mature trees with tall conifers and hardwoods, staggered upper border, sunlit leafy fringes."}
]
(R4/"R4_FOREST_REGION_BLUEPRINT.json").write_text(json.dumps({"stage":"A36G_R4_SOURCE_FIRST","canvas":[1280,928],"tile":32,
 "regions":regions,
 "immutable_source_paths":[str(R3),str(F)],
 "rule":"one provider-source independent RGBA per region; road and house cutouts; never conflate art and engine QA",
 "art_gate":"PENDING","seal":"NO"},ensure_ascii=False,indent=2),"utf8")
print(json.dumps({"R4":str(R4),"source_objects":len(m["objects"]),"region_count":len(regions),
"seed_stage":m["stage"],"source_manifest_sha256":sha(R3/"A36G_SCENE_MANIFEST.json")},indent=2),flush=True)
