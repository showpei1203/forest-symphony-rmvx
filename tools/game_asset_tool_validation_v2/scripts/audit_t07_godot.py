from pathlib import Path
from PIL import Image
import json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
p=r/"godot"/"NormalLightVisual"/"captures"
names=("T07_normal_left.png","T07_normal_right.png","T07_without_normal_left.png")
images=[Image.open(p/n).convert("RGBA") for n in names]
assert all(im.size==(160,160) for im in images)
def count(a,b,rect=(48,48,112,112)):
 x0,y0,x1,y1=rect;pa=a.load();pb=b.load()
 diffs=[(x,y) for y in range(y0,y1) for x in range(x0,x1) if pa[x,y]!=pb[x,y]]
 return len(diffs)
left_right=count(images[0],images[1])
normal_effect=count(images[0],images[2])
rgba_source=Image.open(r.parent/"FS_ForestSplit_v3_2"/"sources"/"tree_A.png").convert("RGBA")
normal=Image.open(r/"outputs"/"laigter_real"/"tree_A_n.png").convert("RGBA")
assert rgba_source.size==normal.size
alpha_match=rgba_source.getchannel("A").tobytes()==normal.getchannel("A").tobytes()
rep={"tool":"Godot 4.7.2 OpenGL Renderer Radeon RX6700XT","status":"ENGINE_VISUAL_SMOKE_PASS" if (left_right>25 and normal_effect>25 and alpha_match) else "FAIL","output_sizes":[im.size for im in images],"light_movement_changed_sprite_pixels":left_right,"normal_vs_flat_changed_sprite_pixels":normal_effect,"normal_source_alpha_equal":alpha_match,"captures":[str(p/n) for n in names],"limitations":"automated image variation only; art quality, normal direction and human visual approval pending"}
(r/"reports"/"T07_GODOT_NORMAL_VISUAL.json").write_text(json.dumps(rep,ensure_ascii=False,indent=2),encoding="utf8")
print("T07_GODOT",rep["status"],"light_pixels",left_right,"normal_effect_pixels",normal_effect,"alpha_ok",alpha_match)
if rep["status"]=="FAIL":raise SystemExit(2)
