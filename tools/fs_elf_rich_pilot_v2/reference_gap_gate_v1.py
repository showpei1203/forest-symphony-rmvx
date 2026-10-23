from pathlib import Path
from PIL import Image,ImageChops
import json,hashlib
from collections import Counter
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
m=json.loads((r/"scene_manifest.json").read_text(encoding="utf8"))
objects=m["instances"]; roles=Counter(z["role"] for z in objects)
names={str(z["id"]).lower() for z in objects}
assets={str(z["asset_id"]).lower() for z in objects}
event_ids={str(z["id"]).lower() for z in m["interactions"]}
a=Image.open(r/"source"/"clean"/"house_A.png").convert("RGBA")
b=Image.open(r/"source"/"clean"/"house_shop.png").convert("RGBA")
alpha_a=a.getchannel("A");alpha_b=b.getchannel("A")
same_alpha_pixels=sum(1 for x,y in zip(alpha_a.getdata(),alpha_b.getdata()) if x==y)
alpha_similarity=round(same_alpha_pixels/(a.width*a.height),4)
def tags_present(words):
 return any(any(t in v for t in words) for v in assets | names)
targets={
 "house_silhouette_variation": {"pass":alpha_similarity<0.93,"detail":{"house_shop_vs_house_A_alpha_similarity":alpha_similarity,"target":"substantially different roof/building silhouette; hue variant insufficient"}},
 "inn_asset_and_event": {"pass":tags_present(("inn","hotel","lodge")),"detail":"inn building distinct from house/shop"},
 "raised_treehouse": {"pass":tags_present(("treehouse","tree_house","platform_house")),"detail":"a raised building with supporting trunk/ladder"},
 "river_water_terrain": {"pass":tags_present(("river","water","stream")) or bool(m.get("water_zones")),"detail":"real river/stream semantic source, not painted blue path"},
 "bridge_over_water": {"pass":tags_present(("bridge",)) and (tags_present(("river","water","stream")) or bool(m.get("water_zones"))),"detail":"crossing integrated with actual water and dual height/passability"},
 "central_sacred_tree": {"pass":tags_present(("sacred","worldtree","ancient_tree")),"detail":"a uniquely scaled focal sacred tree with special occlusion"},
 "terrain_height_transitions": {"pass":bool(m.get("height_regions")) or tags_present(("cliff","elevation","terrace")),"detail":"positive elevation transitions with collision and sidewall PAR"},
 "five_functional_triggers": {"pass":len(event_ids)>=5,"detail":"current test validates proximity IDs only, not text event commands"},
 "native_dual_engine_smoke": {"pass":(r/"logs"/"RICH_V2_FINAL_REGRESSION.json").exists() and json.loads((r/"logs"/"RICH_V2_FINAL_REGRESSION.json").read_text(encoding="utf8")).get("status","").startswith("DUAL_ENGINE_NATIVE_SMOKE_PASS"),"detail":"isolated native engine smoke, not sealed FS compatibility"},
}
report={"reference_kit":"FS_REFERENCE_BENCHMARK_20261023","input_scene":"FS Elf Village Rich Pilot V2.1","status":"STYLE_REFERENCE_GAP_FOUND","check_kind":"reference-driven readiness, NOT a rollback of existing smoke PASS",
"props":len(objects),"roles":dict(roles),"checks":targets,
"met":sum(v["pass"] for v in targets.values()),"planned":len(targets),
"next_actions":["Source-first, artistically distinct inn and treehouse sprites","Terrain source atlas for cliff heights/river/bridge","Unique sacred tree landmark with per-object collision/occlusion","Recompile from one Manifest","dual-engine formal FS baseline adapter and human Gate F"]}
(r/"logs"/"RICH_REFERENCE_STYLE_GAP_V1.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("REFERENCE_STYLE_GATE",report["met"],"/",report["planned"],"met")
for k,v in targets.items():print(("PASS " if v["pass"] else "GAP ")+k)
