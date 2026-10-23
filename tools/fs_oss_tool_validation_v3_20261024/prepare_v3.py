from pathlib import Path
from PIL import Image,ImageDraw
from shutil import copy2
import hashlib,json
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
b=Path(r"E:\GameAssetToolLab_20261023\FS_B0_SCENE04_HEIGHT_20261023\source")
for sub in ["inputs","outputs/spritenormals","outputs/laigter","outputs/libresprite","reports","logs"]:
 (r/sub).mkdir(parents=True,exist_ok=True)
srcs={}
for name in ["tree","rock","sign"]:
 p=b/(name+".png")
 t=r/"inputs"/p.name
 copy2(p,t)
 im=Image.open(t).convert("RGBA")
 srcs[name]={"sha256":hashlib.sha256(t.read_bytes()).hexdigest(),"size":list(im.size),"alpha0":sum(1 for a in im.getchannel("A").getdata() if a==0)}
# Generate independent 4-frame 32x32 animation from source rock WITHOUT scaling.
base=Image.open(r/"inputs"/"rock.png").convert("RGBA")
assert base.size==(32,24)
sheet=Image.new("RGBA",(128,32),(0,0,0,0))
frames=[]
for i in range(4):
 frame=Image.new("RGBA",(32,32),(0,0,0,0))
 frame.alpha_composite(base,(0,[4,3,2,1][i]))
 target=r/"inputs"/f"rock_frame_{i:02d}.png"
 frame.save(target)
 sheet.alpha_composite(frame,(32*i,0))
 frames.append(target.name)
sheet.save(r/"inputs"/"rock_animation_4x32.png")
# 1 pixel intentional mutant for negative detector
mut=sheet.copy()
alpha=Image.new("RGBA",(32,32),(0,0,0,0))
alpha.alpha_composite(Image.open(r/"inputs"/"rock_frame_02.png").convert("RGBA"),(0,0))
mut.paste(Image.new("RGBA",(32,32),(0,0,0,0)),(64,0))
shift=Image.new("RGBA",(32,32))
shift.alpha_composite(Image.open(r/"inputs"/"rock_frame_02.png").convert("RGBA"),(1,0))
mut.alpha_composite(shift,(64,0))
mut.save(r/"inputs"/"rock_animation_shifted_frame2.png")
summary={"input_source":"B0 source-first procedurally created project-owned, no Hanzo/licensed third party sources",
"asset_sources":srcs,"animation_frames":frames,"animation_format":"4 x 32x32; Y offsets (4,3,2,1) integer pixels, no resampling",
"manifest_sha256":hashlib.sha256((Path(r"E:\GameAssetToolLab_20261023\FS_B0_SCENE04_HEIGHT_20261023")/"SCENE_MANIFEST_B0.json").read_bytes()).hexdigest()}
(r/"reports"/"T09_T10_INPUTS.json").write_text(json.dumps(summary,indent=2,ensure_ascii=False),encoding="utf8")
print("V3_INPUTS_PREPARED",srcs,flush=True)
