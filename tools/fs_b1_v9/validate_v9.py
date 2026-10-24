# -*- coding: utf-8 -*-
from pathlib import Path
from PIL import Image,ImageChops
import json,hashlib,sys
R=Path(__file__).resolve().parent
O=R/"output"
m=json.loads((R/"V9_NEW_INSTANCE_FRAGMENT.json").read_text(encoding="utf8"))
p=json.loads((R/"V9_SACRED_TREE_ART_REPORT.json").read_text(encoding="utf8"))
src=Image.open(O/"sacred_tree_v9.png").convert("RGBA")
trunk=Image.open(O/"sacred_trunk_v9.png").convert("RGBA")
leaves=Image.open(O/"sacred_canopy_v9.png").convert("RGBA")
assert src.size==trunk.size==leaves.size==(224,224)
sha=lambda file:hashlib.sha256(file.read_bytes()).hexdigest()
checks={}
def gate(name,passed):
 checks[name]=bool(passed)
 if not passed:raise AssertionError(name)
gate("source_sha",sha(O/"sacred_tree_v9.png")=="4c3f4225308793a5618abd076892ebe0d20126d77caa3340e4633a8b1e824df1")
gate("original_leaf_provenance",sha(R/"fixture/source/clean/broadleaf_oak.png")=="4ad9d97f2ac4aad5ec4cd4892938ac6977fa42da615b560915b6b8eabafd92fa")
for name,img in [("trunk",trunk),("canopy",leaves),("composite",src)]:
 hist=img.getchannel("A").histogram()
 gate("alpha_binary_"+name,sum(hist[1:255])==0)
reb=trunk.copy();reb.alpha_composite(leaves)
gate("layer_composite_exact",reb.tobytes()==src.tobytes())
gate("manifest_anchor_and_z",(m["x"],m["y"],m["dimensions"],m["draw_order"])==(337,108,[224,224],332))
gate("manifest_sha",m["sha256"]==sha(O/"sacred_tree_v9.png"))
bottom=src.copy();occ=src.copy()
cut=m["base_cut_y"]
bmask=Image.new("L",src.size,0);omask=Image.new("L",src.size,0)
a=src.getchannel("A")
bmask.paste(a.crop((0,cut,src.width,src.height)),(0,cut))
omask.paste(a.crop((0,0,src.width,cut)),(0,0))
bottom.putalpha(bmask);occ.putalpha(omask)
mix=bottom.copy();mix.alpha_composite(occ)
gate("semantic_base_occ_exact",mix.tobytes()==src.tobytes())
bottom.save(O/"sacred_par_base_v9.png")
occ.save(O/"sacred_par_occlusion_v9.png")
old=Image.open(R/"fixture/build/FS_ELF_RICH_Master.png").convert("RGBA")
new=Image.open(O/"FS_B1_V9_SACRED_TREE_PREVIEW.png").convert("RGBA")
diff=sum(x!=y for x,y in zip(old.get_flattened_data(),new.get_flattened_data()))
gate("visible_edit_not_empty",diff==11475)
# One-pixel displacement in composite causes source-level regression, not just metadata.
moved=Image.new("RGBA",src.size)
moved.alpha_composite(src,(1,0)) if src.getchannel("A").getbbox()[2]<src.width else None
if moved.getbbox() is None:
 # Use 225px frame to prove shift without discarding pixels.
 moved=Image.new("RGBA",(225,224))
 moved.alpha_composite(src,(1,0))
 original=Image.new("RGBA",(225,224));original.alpha_composite(src)
else:
 original=src
mismatch=sum(x!=y for x,y in zip(original.get_flattened_data(),moved.get_flattened_data()))
gate("negative_1px_detected",mismatch>500)
report={"status":"B1_V9_NEW_SACRED_TREE_LAYER_SOURCE_GATE_PASS_VISUAL_PENDING",
 "checks":checks,"changed_scene_visible_pixels":diff,"shift_1px_source_diff":mismatch,
 "v8_full_VX_project":"PRESERVED_UNCHANGED",
 "new_VX_project":"NOT_BUILT","visual_ref_quality":"NOT_APPROVED","license":"PRIVATE_TEST_ONLY_UNVERIFIED"}
(R/"V9_GATE_RESULT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(report,ensure_ascii=False,indent=2),flush=True)
