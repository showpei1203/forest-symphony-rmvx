from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,shutil
src=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
out=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
out.mkdir(parents=True,exist_ok=True)
frame_dir=out/"frames";frame_dir.mkdir(exist_ok=True)
master_file=src/"Graphics"/"Characters"/"$actor01.png"
master=Image.open(master_file).convert("RGBA")
assert master.size==(96,128),f"unexpected {master.size}"
dirnames=["down","left","right","up"]
manifest={"schema":"generate2dsprite.animation_clips.v2","frames":[],"anchor_px":[16,21],"clips":{},"states":{"idle":"idle_down","moving":"walk_down"},"sampling":"nearest","pixel_art":True,"art_source":"existing","placeholder":False,"role":"player"}
checks=[]
for row,direction in enumerate(dirnames):
 for col in range(3):
  name=f"{direction}-{col}"
  frame=master.crop((32*col,32*row,32*(col+1),32*(row+1)))
  assert frame.mode=="RGBA" and frame.size==(32,32)
  p=frame_dir/(name+".png");frame.save(p)
  reread=Image.open(p).convert("RGBA")
  assert reread.tobytes()==frame.tobytes()
  manifest["frames"].append({"name":name,"file":f"frames/{name}.png"})
  checks.append({"id":name,"rgba_sha256":hashlib.sha256(frame.tobytes()).hexdigest(),"alpha_nonzero":sum(frame.getchannel("A").histogram()[1:])})
 ids=[3*row+i for i in range(3)]
 manifest["clips"][f"idle_{direction}"]={"frames":[ids[1]],"duration_ms":400,"loop":True}
 # Preserve authored VX 3 physical frames with pattern order 1,0,1,2.
 manifest["clips"][f"walk_{direction}"]={"frames":[ids[1],ids[0],ids[1],ids[2]],"duration_ms":150,"loop":True}
(out/"clips.v2.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
iconfile=src/"Graphics"/"System"/"IconSet.png"
icon=Image.open(iconfile).convert("RGBA")
weapon=icon.crop((48,0,72,24));weapon.save(out/"weapon_icon_2.png")
assert weapon.size==(24,24)
nonempty={}
for i in (5,7):
 s=Image.open(src/"Graphics"/"Characters"/f"$actor01_{i}.png").convert("RGBA")
 assert s.size==(96,128)
 statuses=[]
 for row in range(4):
  statuses.append([int(s.crop((col*32,row*32,(col+1)*32,(row+1)*32)).getchannel("A").getbbox() is not None) for col in range(3)])
 nonempty[f"actor01_{i}"]={"coverage":sum(map(sum,statuses)),"cells":statuses,"grid":"3x4","safe_all_direction":sum(map(sum,statuses))==12}
assert nonempty["actor01_5"]["coverage"]==5
assert nonempty["actor01_7"]["coverage"]==6
report={
 "source_asset":"K4_BASELINE/Graphics/Characters/$actor01.png",
 "source_sha256":hashlib.sha256(master_file.read_bytes()).hexdigest(),
 "icon_sha256":hashlib.sha256(iconfile.read_bytes()).hexdigest(),
 "actual_body_size":list(master.size),"frame_size":[32,32],
 "direction_row_order":dirnames,"anchor_px":[16,21],
 "weapon_icon":2,"weapon_crop_px":[48,0,24,24],
 "rgss_angle_sequence_visible":[-75,-15,45],"godot_rotation_expected":[75,15,-45],
 "no_custom_weapon_xy_offsets":True,
 "frames":checks,"sparse_numbered_sources":nonempty
}
(out/"fs_source_authority_test.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps({"source_sha256":report["source_sha256"],"frames":len(checks),"clips":len(manifest["clips"]),"weapon":list(weapon.size),"sparse":nonempty},indent=2))