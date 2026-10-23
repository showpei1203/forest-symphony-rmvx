from pathlib import Path
from PIL import Image
import json
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
m=json.loads((r/"scene_manifest.json").read_text(encoding="utf8"))
W,H=m["canvas"]["width"],m["canvas"]["height"]
src=r/"source"/"clean";build=r/"build"
complete=Image.open(build/"FS_ELF_RICH_Par_COMPLETE.png").convert("RGBA")
owner=Image.new("L",(W,H),0);q=owner.load()
for ob in sorted(m["instances"],key=lambda z:(z["draw_order"],z["id"])):
 image=Image.open(src/(ob["asset_id"]+".png")).convert("RGBA")
 aa=image.getchannel("A").load()
 for y in range(image.height):
  flag=255 if y<ob["base_cut_y"] else 0
  for x in range(image.width):
   if aa[x,y]>0:q[ob["x"]+x,ob["y"]+y]=flag
base=Image.new("RGBA",(W,H))
occlusion=Image.new("RGBA",(W,H))
p=complete.load();b=base.load();o=occlusion.load()
for y in range(H):
 for x in range(W):
  if q[x,y]:o[x,y]=p[x,y]
  else:b[x,y]=p[x,y]
test=base.copy();test.alpha_composite(occlusion)
assert test.tobytes()==complete.tobytes()
base.save(build/"FS_ELF_RICH_Par_BASE.png")
occlusion.save(build/"FS_ELF_RICH_Occlusion.png")
owner.save(build/"FS_ELF_RICH_VISIBLE_OWNER_MASK.png")
print("PIXEL_OWNER_PARTITION_PASS")
