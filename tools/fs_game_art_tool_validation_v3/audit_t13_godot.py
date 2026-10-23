from pathlib import Path
from PIL import Image
import json,hashlib,sys
ROOT=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
CAP=ROOT/"godot"/"NormalAnimation6"/"captures"
names=["t13_frame0_normal_left.png","t13_frame0_normal_right.png","t13_frame0_flat_left.png","t13_frame5_normal_left.png"]
ims=[Image.open(CAP/name).convert("RGBA") for name in names]
assert all(im.size==(224,224) for im in ims)
ROI=(80,64,144,160)
def count(a,b):
 x0,y0,x1,y1=ROI
 pa,pb=a.load(),b.load()
 return sum(pa[x,y]!=pb[x,y] for y in range(y0,y1) for x in range(x0,x1))
light_move=count(ims[0],ims[1]);normal_effect=count(ims[0],ims[2]);animation=count(ims[0],ims[3])
src=Image.open(ROOT/"inputs"/"tree_animation_6frames.png").convert("RGBA")
normal=Image.open(ROOT/"outputs"/"sprite_normals"/"tree_animation_6frames_n.png").convert("RGBA")
assert src.size==normal.size==(384,96)
alpha_ok=src.getchannel("A").tobytes()==normal.getchannel("A").tobytes()
frame_source_diff=sum(a!=b for a,b in zip(src.crop((0,0,64,96)).getdata(),src.crop((320,0,384,96)).getdata()))
capture_info=[{"file":n,"sha":hashlib.sha256((CAP/n).read_bytes()).hexdigest()} for n in names]
passed=light_move>70 and normal_effect>70 and animation>15 and alpha_ok and frame_source_diff>0
record={"status":"T13_NATIVE_GPU_NORMAL_ANIM_LIGHT_PASS" if passed else "T13_FAIL_CLOSED",
"renderer":"Godot 4.7.2 native AMD RX6700XT OpenGL (never headless capture)","ROI":ROI,
"light_position_change_pixels":light_move,"normal_on_off_changed_pixels":normal_effect,
"frame0_frame5_light_scene_changed_pixels":animation,"source_frame0_frame5_changed_pixels":frame_source_diff,
"6_frame_normal_alpha_exact":alpha_ok,"diffuse_size":src.size,"normal_size":normal.size,
"captures":capture_info,"formal_visual_acceptance":"PENDING",
"note":"Native renderer 4 PNGs, source frame region and normals are generated from same 6x64x96 sheet. Quantitative variation not a subjective art-quality pass."}
(ROOT/"reports"/"T13_GODOT_NATIVE_ANIMATION_LIGHT.json").write_text(json.dumps(record,indent=2,ensure_ascii=False),encoding="utf8")
print("T13",record["status"],"light_diff",light_move,"normal_diff",normal_effect,"frame_diff",animation,"source_frame_diff",frame_source_diff,flush=True)
if not passed:sys.exit(2)
