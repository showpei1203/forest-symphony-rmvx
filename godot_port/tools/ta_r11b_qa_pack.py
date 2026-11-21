# FS T-A R11B owner-authorized local E:\ full real Godot QA finalizer
from PIL import Image,ImageDraw,ImageChops
from pathlib import Path
import json,hashlib,zipfile,io
ROOT=Path(r"E:\LPC_Original_20261121")
BASE=ROOT/"FS_R11B_ACTOR01_UNARMED_45_STUDY"
NATIVE=BASE/"native_godot472_60Hz"
assert all((NATIVE/("%03d.png"%i)).exists() for i in range(73))
data=json.loads((NATIVE/"R11B_NATIVE_QA.json").read_text(encoding="utf-8"))
assert data["frames"]==73 and data["visited"]==list(range(12)) and data["contact_events"]==1
for p in ["R11B_WEAPON_EMPTY_ZERO_ALPHA.png","R11B_FX_EMPTY_ZERO_ALPHA.png"]:
  im=Image.open(BASE/p).convert("RGBA")
  assert im.getbbox() is None
src=Image.open(BASE/"R11B_ACTOR01_UNARMED_BODY_12x64.png").convert("RGBA")

from collections import deque
src_components=[]
for frame_id in range(12):
  img=src.crop((frame_id%4*64,frame_id//4*64,frame_id%4*64+64,frame_id//4*64+64))
  pix=img.load()
  rem={(x,y) for y in range(64) for x in range(64) if pix[x,y][3]>0}
  sizes=[]
  while rem:
    start=rem.pop()
    pending=deque([start])
    amount=1
    while pending:
      x,y=pending.popleft()
      for dx in (-1,0,1):
        for dy in (-1,0,1):
          v=(x+dx,y+dy)
          if v in rem:
            rem.remove(v);pending.append(v);amount+=1
    sizes.append(amount)
  assert len(sizes)==1,f"R11B F{frame_id} ISOLATED PIXELS {sizes}"
  src_components.append(sizes[0])

first={}
for item in data["timeline"]:
  first.setdefault(item["frame"],item["tick"])
mismatch=[]
alpha_mismatch=[]
poses=[]
for frame in range(12):
  native=Image.open(NATIVE/("%03d.png"%first[frame])).convert("RGBA")
  expect=src.crop((frame%4*64,frame//4*64,frame%4*64+64,frame//4*64+64))
  a=list(native.getdata());b=list(expect.getdata())
  mismatch.append(sum(x!=y for x,y in zip(a,b)))
  alpha_mismatch.append(sum(x[3]!=y[3] for x,y in zip(a,b)))
  poses.append(native)
def draw_page(scale):
  cell=64*scale
  page=Image.new("RGBA",(4*cell,3*(cell+20)),(20,27,32,255))
  draw=ImageDraw.Draw(page)
  for i,im in enumerate(poses):
    xx=(i%4)*cell;yy=(i//4)*(cell+20)
    page.alpha_composite(im.resize((cell,cell),Image.Resampling.NEAREST),(xx,yy+20))
    draw.text((xx+4,yy+3),f"R11B F{i:02d} | Godot",fill=(242,243,240,255))
  return page.convert("RGB")
draw_page(4).save(BASE/"R11B_GODOT472_NATIVE_12KEY_CONTACT_4X.png")
draw_page(1).save(BASE/"R11B_GODOT472_NATIVE_12KEY_CONTACT_1X.png")
gif=[]
for i in range(73):
  frame=Image.open(NATIVE/("%03d.png"%i)).convert("RGBA").resize((256,256),Image.Resampling.NEAREST)
  backing=Image.new("RGBA",(256,256),(20,27,32,255));backing.alpha_composite(frame)
  gif.append(backing.convert("RGB"))
gif[0].save(BASE/"R11B_GODOT472_TRUE_NATIVE_60HZ.gif",save_all=True,append_images=gif[1:],loop=0,duration=17,optimize=True)
# Compare existing R10 in same authorized source archive; R10 is CPU source preview, NOT Godot.
r10=Image.open(ROOT/"FS_R10_ACTOR01_UNARMED_SOURCE_STUDY"/"R10_ACTOR01_UNARMED_BODY_12x64.png").convert("RGBA")
comparison=Image.new("RGBA",(4*512,3*276),(20,27,32,255))
draw=ImageDraw.Draw(comparison)
for i in range(12):
    xx=(i%4)*512;yy=(i//4)*276
    old=r10.crop((i%4*64,i//4*64,i%4*64+64,i//4*64+64)).resize((256,256),Image.Resampling.NEAREST)
    new=poses[i].resize((256,256),Image.Resampling.NEAREST)
    comparison.alpha_composite(old,(xx,yy+20));comparison.alpha_composite(new,(xx+256,yy+20))
    draw.text((xx+3,yy+3),f"F{i:02d} R10 CPU",fill=(242,243,240,255))
    draw.text((xx+260,yy+3),"R11B GODOT",fill=(242,243,240,255))
comparison.convert("RGB").save(BASE/"R10_SOURCE_VS_R11B_GODOT_REAL_12KEY_4X.png")
def sha(p):
 h=hashlib.sha256()
 with open(p,"rb") as f:
  for b in iter(lambda:f.read(1<<20),b""):h.update(b)
 return h.hexdigest()
report={
  "fs_ta":"R11B weaponless LPC wholebody source study",
  "engine":data["engine"],"real_native_frames":73,"all_12_poses_single_connected_body":True,"body_component_sizes":src_components,"native_viewport":[64,64],
  "60hz":True,"visited":data["visited"],"contact_events":1,
  "source_vs_gpu_exact_RGBA_mismatches_per_pose":mismatch,
  "source_vs_gpu_alpha_mismatches_per_pose":alpha_mismatch,
  "native_source_image_sha256":sha(BASE/"R11B_ACTOR01_UNARMED_BODY_12x64.png"),
  "weapon_rgba_opaque_count":0,"fx_rgba_opaque_count":0,
  "natural_pose_status":"ART HOLD - dual-cardinal pixel composite, not artist finished 45 degree",
  "runtime":"Godot 4.7.2 Windows true GPU visible rendering on owner PC",
  "real_live_FS_battle":"NOT RUN",
  "original_A52_R8_R9":"UNMODIFIED"
}
(BASE/"R11B_FINAL_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
readme="""# Forest Symphony T-A R11B 空手動作交接
已以官方 LPC 2026-11-20 commit 86a3719ee4a7e2e9fb27c7c152e29a741d3e930a 真實來源重建。
來源完整 ZIP：E:\\LPC_Original_20261121\\Universal_LPC_FULL_86a3719e.zip
正式原檔 SHA256：C3E73FAFE062A80DCABA6CEF3DCA367B988F6E09D983AA5C9AB3FF05673185DC
R11B 12x64 Body、Weapon 和 FX 三層256x192。Weapon/FX 全透明、零武器、零外來標誌。
R11B 另外清除共15個腳部孤立像素，12幀全部要求8鄰接完整角色輪廓。\nR11B 重點是來源完整的 LPC backslash 13格+正、側向像素的3/4取捨，以及A62核准白髮身分。
這不是官方原生45°，也不是逐格手繪完成版。肩線、腿部深度、臉部表情仍待藝術驗收，ART HOLD。
本機 Godot 4.7.2 Windows 原生 SubViewport OpenGL，73/73張 60 Hz PNG輸出，12幀全覆蓋、0.63秒命中事件1次。
每格CPU來源對Godot GPU輸出像素差異見 R11B_FINAL_QA.json，技術成功不等於美術通過。
尚未合併正式FS戰鬥；原版A52/R8/R9未覆寫。
私有官方LPC美術源混合授權，原版授權作者署名請參見上游 LICENSE/CREDITS.csv。公開GitHub僅含製作程式、規則與測試指令，不含原始LPC PNG。
"""
(BASE/"README_R11B_繁體中文.md").write_text(readme,encoding="utf-8")
include=[
 "R11B_ACTOR01_UNARMED_BODY_12x64.png",
 "R11B_WEAPON_EMPTY_ZERO_ALPHA.png",
 "R11B_FX_EMPTY_ZERO_ALPHA.png",
 "R11B_MANIFEST_SOURCE_LOCKED.json",
 "R11B_FINAL_QA.json",
 "R11B_UNARMED_3Q_12KEY_4X.png",
 "R11B_UNARMED_3Q_12KEY_LOOP.gif",
 "R11B_GODOT472_NATIVE_12KEY_CONTACT_1X.png",
 "R11B_GODOT472_NATIVE_12KEY_CONTACT_4X.png",
 "R11B_GODOT472_TRUE_NATIVE_60HZ.gif",
 "R10_SOURCE_VS_R11B_GODOT_REAL_12KEY_4X.png",
 "README_R11B_繁體中文.md",
 "godot_project/project.godot",
 "godot_project/tests/capture_r11b_unarmed.gd",
 "native_godot472_60Hz/R11B_NATIVE_QA.json",
 "native_godot472_60Hz/godot_log.txt"
]
archive=BASE/"FS_TA_ACTOR01_R11B_UNARMED_LPC_GODOT472_73FRAME_QA.zip"
with zipfile.ZipFile(archive,"w",compression=zipfile.ZIP_DEFLATED) as z:
 for n in include: z.write(BASE/n,n)
 for n in range(73):z.write(NATIVE/("%03d.png"%n),"native/"+("%03d.png"%n))
 z.write(ROOT/"FS_R11B_ACTOR01_WEAPONLESS_DIAGONAL.py","reproducer/FS_R11B_ACTOR01_WEAPONLESS_DIAGONAL.py")
 z.write(ROOT/"FS_R11_LPC_MOTION_SOURCE_AUDIT.py","reproducer/FS_R11_LPC_MOTION_SOURCE_AUDIT.py")
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 number=len(z.namelist())
assert number==91,(number,archive)
print("R11B_PACKED_QA",json.dumps({"zip":str(archive),"size":archive.stat().st_size,"sha256":sha(archive),"files":number,"gpu_pose_rgba_mismatch":mismatch,"gpu_pose_alpha_mismatch":alpha_mismatch,"native_73":True},ensure_ascii=False))
