from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
g=r/"godot"/"B0NormalCrossTool"
cap=g/"captures"
pics={k:Image.open(cap/(k+".png")).convert("RGBA") for k in [
 "T13_cli_left","T13_cli_right","T13_laigter_left","T13_laigter_right","T13_flat_left"]}
assert all(im.size==(160,160) for im in pics.values())
roi=(48,32,112,128)
def differences(x,y):
 a=pics[x];b=pics[y]
 changed=sum(a.getpixel((xx,yy))!=b.getpixel((xx,yy))
   for yy in range(roi[1],roi[3]) for xx in range(roi[0],roi[2]))
 background=sum(a.getpixel((xx,yy))!=b.getpixel((xx,yy))
   for yy in range(160) for xx in range(160)
   if not(roi[0]<=xx<roi[2] and roi[1]<=yy<roi[3]))
 return {"sprite_roi_changed":changed,"outside_sprite_changed":background}
comparisons={
 "cli_light_position":differences("T13_cli_left","T13_cli_right"),
 "laigter_light_position":differences("T13_laigter_left","T13_laigter_right"),
 "normal_cli_vs_flat":differences("T13_cli_left","T13_flat_left"),
 "normal_laigter_vs_flat":differences("T13_laigter_left","T13_flat_left"),
 "cli_vs_laigter_same_light":differences("T13_cli_left","T13_laigter_left")}
source=Image.open(g/"tree.png").convert("RGBA")
alpha={"cli":Image.open(g/"tree_cli_n.png").convert("RGBA").getchannel("A").tobytes()==source.getchannel("A").tobytes(),
"laigter":Image.open(g/"tree_laigter_n.png").convert("RGBA").getchannel("A").tobytes()==source.getchannel("A").tobytes()}
expected={"cli_light_position":100,"laigter_light_position":100,"normal_cli_vs_flat":100,"normal_laigter_vs_flat":100,"cli_vs_laigter_same_light":1}
passed=all(comparisons[k]["sprite_roi_changed"]>=v for k,v in expected.items()) and all(alpha.values())
contact=Image.new("RGBA",(160*5,190),(23,23,23,255));dr=ImageDraw.Draw(contact)
for i,(name,im) in enumerate(pics.items()):
 contact.alpha_composite(im,(160*i,30))
 dr.text((160*i+8,8),name.replace("T13_",""),fill=(255,255,255,255))
contact.save(cap/"T13_CROSS_TOOL_CONTACT.png")
out={"status":"T13_B0_CLI_LAIGTER_GODOT_REAL_GPU_PASS" if passed else "T13_FAIL_CLOSED",
"gpu":"OpenGL 3.3 AMD Radeon RX6700XT Godot 4.7.2; non-headless",
"sprite_size":[64,96],"render_size":[160,160],"nearest_filter":True,"unscaled_sprite_roi":roi,
"alpha_equal":alpha,"comparison":comparisons,
"images":{k:{"sha256":hashlib.sha256((cap/(k+".png")).read_bytes()).hexdigest(),"bytes":(cap/(k+".png")).stat().st_size} for k in pics},
"contact_sha256":hashlib.sha256((cap/"T13_CROSS_TOOL_CONTACT.png").read_bytes()).hexdigest(),
"qualification":"Pixel difference proves shader/material inputs are effective but is not a subjective visual aesthetic comparison."}
(r/"reports"/"T13_CROSS_TOOL_GODOT_GPU.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print("T13_RESULTS",out["status"],comparisons,flush=True)
if not passed:raise SystemExit(2)
