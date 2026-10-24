# -*- coding: utf-8 -*-
"""Forest Symphony B1 V9 sacred grove art SOURCE CANDIDATE only.
Build original transparent trunk and provenance-locked old broadleaf canopy.
Do NOT rewrite v8 manifest/game; private visual prototype to review.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,random
R=Path(__file__).resolve().parent
V8=R/"fixture"
OUT=R/"output";OUT.mkdir(exist_ok=True)
seed=241024
rng=random.Random(seed)
W,H=224,224
trunk=Image.new("RGBA",(W,H))
d=ImageDraw.Draw(trunk)
# Main ancient trunk and broad spreading side roots, native 1px hard-edge strokes.
d.polygon([(78,223),(89,212),(99,193),(97,176),(101,157),(91,133),(96,111),(105,119),
 (111,151),(124,149),(127,116),(136,100),(140,120),(134,152),(138,180),(146,210),(158,223)],fill=(88,57,34,255))
d.polygon([(91,218),(99,185),(106,160),(113,158),(119,175),(130,202),(136,222)],fill=(139,91,53,255))
d.polygon([(75,220),(90,211),(100,211),(117,222)],fill=(72,46,30,255))
d.polygon([(132,218),(146,208),(167,218),(174,223)],fill=(75,49,31,255))
# Twist branches and vein-like growth rings underneath the canopy.
d.line([(108,164),(93,127),(70,98),(43,89)],fill=(96,62,38,255),width=10,joint="curve")
d.line([(128,156),(143,120),(173,101),(195,90)],fill=(104,68,43,255),width=11,joint="curve")
d.line([(116,158),(118,111),(119,67)],fill=(122,75,43,255),width=12)
d.line([(109,201),(105,170),(103,157)],fill=(193,131,71,255),width=3)
d.line([(121,212),(115,191),(120,177)],fill=(62,43,29,255),width=3)
for i in range(30):
 x=rng.randrange(90,136);y=rng.randrange(153,219)
 if trunk.getpixel((x,y))[3]:
  d.line((x,y,x+rng.choice([-2,-1,1,2]),y+rng.randrange(2,7)),
         fill=rng.choice([(60,44,31,255),(166,113,61,255),(114,73,42,255)]),width=1)
# Scattered golden bark carvings, small enough to remain readable pixel art.
for px,py in [(113,170),(124,190),(103,203)]:
 d.rectangle((px,py,px+1,py+5),fill=(210,171,79,255))
 d.point((px-2,py+3),fill=(238,199,93,255))
leaf_source=V8/"source/clean/broadleaf_oak.png"
raw=leaf_source.read_bytes()
leaf_sha=hashlib.sha256(raw).hexdigest()
leaf=Image.open(leaf_source).convert("RGBA")
assert leaf.size==(60,61)
crown=leaf.crop((0,0,60,52))
assert crown.getchannel("A").getextrema()[0]==0
canopy=Image.new("RGBA",(W,H))
placements=[(8,43), (44,19), (83,6), (122,14), (156,41),
            (9,79),(44,60),(83,48),(123,61),(166,81),
            (30,106),(70,93),(110,99),(146,107)]
for i,(x,y) in enumerate(placements):
 patch=crown.copy()
 # Discrete RGB 1:1 pixel remap to existing source greens, preserving alpha.
 factor=[.90,1.0,1.04,.96,1.08][i%5]
 pix=[(min(255,int(r*factor)),min(255,int(g*factor)),min(255,int(b*factor)),a)
        if a else (0,0,0,0) for r,g,b,a in patch.get_flattened_data()]
 patch.putdata(pix)
 canopy.alpha_composite(patch,(x,y))
# A few luminous rune-leaves, no blurry glow or fake semi-transparent halo.
c=ImageDraw.Draw(canopy)
for k in range(27):
 x=rng.randrange(24,200);y=rng.randrange(37,143)
 if canopy.getpixel((x,y))[3]:
  c.point((x,y),fill=rng.choice([(193,213,90,255),(238,225,109,255),(109,189,153,255)]))
composite=trunk.copy();composite.alpha_composite(canopy)
assert composite.size==(W,H)
assert composite.getchannel("A").getextrema()==(0,255)
for name,img in [("sacred_trunk_v9.png",trunk),("sacred_canopy_v9.png",canopy),
                 ("sacred_tree_v9.png",composite)]:
 img.save(OUT/name)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
# Integrate without editing sealed source manifests: candidate ledger placement
m=json.loads((V8/"scene_manifest.json").read_text(encoding="utf8"))
candidate={
 "id":"sacred_grove_tree_v9",
 "asset_id":"sacred_tree_v9",
 "source":"output/sacred_tree_v9.png",
 "sha256":sha(OUT/"sacred_tree_v9.png"),
 "dimensions":[W,H],"x":337,"y":108,"anchor":"top_left",
 "z":332,"draw_order":332,"role":"landmark",
 "base_cut_y":153,
 "collision_local":[],
 "interact_id":None,
 "semantic_masks":{"par_complete":"source_alpha","base":"source_alpha_including_lower_part",
                   "occlusion":"source_alpha_including_upper_part"},
 "transform":{"scale":1,"rotation":0,"flip_x":False,"flip_y":False}
}
assert candidate["y"]+H==candidate["draw_order"]
img=Image.open(V8/"build/FS_ELF_RICH_Ground.png").convert("RGBA")
instances=sorted(m["instances"]+[candidate],key=lambda a:(a["draw_order"],a["id"]))
for ob in instances:
 if ob["id"]==candidate["id"]:art=composite
 else:
  p=V8/"source/clean"/(ob["asset_id"]+".png")
  assert sha(p)==ob["sha256"]
  art=Image.open(p).convert("RGBA")
 img.alpha_composite(art,(ob["x"],ob["y"]))
old=Image.open(V8/"build/FS_ELF_RICH_Master.png").convert("RGBA")
diff=sum(a!=b for a,b in zip(img.get_flattened_data(),old.get_flattened_data()))
img.save(OUT/"FS_B1_V9_SACRED_TREE_PREVIEW.png")
comparison=Image.new("RGBA",(1728,680),(31,39,46,255))
comparison.alpha_composite(old,(0,40));comparison.alpha_composite(img,(864,40))
d=ImageDraw.Draw(comparison)
d.text((14,12),"B1 V8 — ORIGINAL SEALED TEST CANDIDATE",fill="white")
d.text((878,12),"B1 V9 — SACRED GROVE SOURCE-FIRST ART CANDIDATE",fill="white")
comparison.save(OUT/"V8_V9_SACRED_TREE_SIDE_BY_SIDE.png")
report={"status":"V9_SACRED_TREE_PRIVATE_SOURCE_ART_CANDIDATE_NOT_RELEASE",
 "source_asset_sha256":leaf_sha,"derived_composite_sha256":candidate["sha256"],
 "original_source_rights":"UNVERIFIED_PRIVATE_TEST","composition":"source-first native pixel, layer trunk+canopy",
 "pixel_dimensions":[W,H],"placement":[337,108],"z":332,"cut_y":153,
 "changed_display_pixels":diff,"relative_to_v8_only_visual":True,
 "original_v8_manifest_unchanged":True,"actor_collision_runtime":"NOT_TESTED",
 "human_visual":"PENDING","schema":"FS SOURCE MANIFEST V3.2"
}
(R/"V9_SACRED_TREE_ART_REPORT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
(R/"V9_NEW_INSTANCE_FRAGMENT.json").write_text(json.dumps(candidate,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(report,ensure_ascii=False,indent=2),flush=True)
