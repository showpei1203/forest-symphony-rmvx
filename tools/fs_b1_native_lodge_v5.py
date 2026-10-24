from pathlib import Path
from shutil import copytree,copy2
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image,ImageGrab
from collections import Counter
import hashlib,zlib,json,subprocess,time,ctypes,re
ROOT=Path(__file__).resolve().parent.parent
V3=ROOT.parent/"FS_B1_OWNER_DEPTH_V3_20261024"
LOG=ROOT/"logs";OUT=ROOT/"outputs"
SCENE=ROOT/"scene_manifest.json"
sha=hashlib.sha256(SCENE.read_bytes()).hexdigest()
SRC=ROOT/"native_template"/"VX_B1_RICH_MANUAL_PLAYABLE"
MAN=ROOT/"VX_B1_V5_LODGE_MANUAL_PLAYABLE"
AUTO=ROOT/"VX_B1_V5_LODGE_NATIVE_AUTOPROBE"
copytree(SRC,MAN,dirs_exist_ok=True)
ground=ROOT/"build"/"FS_ELF_RICH_Ground.png"
assert ground.is_file()
copy2(ground,MAN/"Graphics"/"Pictures"/"FS_ELF_RICH_Ground.png")
scene=json.loads(SCENE.read_text(encoding="utf8"))
objdata=sorted(scene["instances"],key=lambda ob:(ob["draw_order"],ob["id"]))
assert len(objdata)==48
graphics=MAN/"Graphics"/"Pictures"
assets=sorted(set(ob["asset_id"] for ob in objdata))
for name in assets:
    original=ROOT/"source"/"clean"/(name+".png")
    assert original.is_file()
    copy2(original,graphics/("FSOBJ_"+name+".png"))
for ob in objdata:
    original=ROOT/"source"/"clean"/(ob["asset_id"]+".png")
    assert hashlib.sha256(original.read_bytes()).hexdigest()==ob["sha256"]
imported=Image.open(graphics/"FS_ELF_RICH_Ground.png").convert("RGBA")
assert imported.size==(864,640)
native_objects=[[o["id"],o["asset_id"],o["x"],o["y"],o["draw_order"],o["role"]] for o in objdata]
collision=Image.open(ROOT/"build"/"FS_ELF_RICH_Collision.png").convert("L")
blocked=[]
for ty in range(20):
 for tx in range(27):
  cx,cy=tx*32+16,ty*32+16
  if any(collision.getpixel((xx,yy))!=0 for yy in range(cy-8,cy+9) for xx in range(cx-8,cx+9)):
    blocked.append([tx,ty])
native_events=[[e["id"],e["x"],e["y"]] for e in scene["interactions"]]
hero=next(o for o in objdata if o["asset_id"]=="lodge_multiwing_v5")
assert hero["id"]=="house_wood_east" and hero["draw_order"]==268
# Validate legal walkable front/behind cells against native blocked tiles.
assert [19,5] not in blocked and [19,8] not in blocked,("HERO_PROBE_BLOCKED",blocked)
# Exact actor sprite overlap derives from owner atlas produced earlier.
pixel_owner=Image.open(ROOT/"outputs"/"PIXEL_OWNER_ID.png")
id_index=json.loads((ROOT/"outputs"/"INSTANCE_ID_INDEX.json").read_text(encoding="utf8"))
hero_owner=int(next(i for i,ob in id_index.items() if ob["id"]==hero["id"]))
def hero_overlap(tx,ty):
 foot=(ty+1)*32;wx=tx*32+16
 return sum(pixel_owner.getpixel((xx,yy))==hero_owner
   for yy in range(max(0,foot-32),min(640,foot))
   for xx in range(max(0,wx-16),min(864,wx+16)))
assert hero_overlap(19,5)>=200 and hero_overlap(19,8)>=100,("MISSING_HERO_OVERLAP",hero_overlap(19,5),hero_overlap(19,8))
exe=MAN/"Game.exe"
assert exe.is_file()
scripts=MAN/"Data"/"Scripts.rvdata"
records=load(scripts.open("rb"))
idx=next(i for i,x in enumerate(records) if x[1]==b"B1 OWNER NATIVE V3")
rb=zlib.decompress(records[idx][2]).decode("ascii")
found=re.search(r'SOURCE_SHA = "([0-9a-f]{64})"',rb)
assert found, "SOURCE_SHA_MARKER_NOT_FOUND"
oldsha=found.group(1)
rb=rb.replace(oldsha,sha)
assert 'return unless File.exist?("ENABLE_AUTO_PROBE.flag")' in rb
# Replace inherited V3 placeholder sprites and blocked table with v5 source-validated manifest.
rb=re.sub(r"(?m)^  OBJECTS = .*$","  OBJECTS = "+json.dumps(native_objects,separators=(",",":")),rb,count=1)
rb=re.sub(r"(?m)^  BLOCKED = .*$","  BLOCKED = "+json.dumps(blocked,separators=(",",":")),rb,count=1)
rb=re.sub(r"(?m)^  EVENTS = .*$","  EVENTS = "+json.dumps(native_events,separators=(",",":")),rb,count=1)
assert "lodge_multiwing_v5" in rb
# This extra adapter is only active when the isolated native autoprobe flag exists.
rb+=r"""
class Spriteset_Map
 alias fs_b1_v5_prev_update update
 def update
  fs_b1_v5_prev_update
  return unless @fs_objects && File.exist?("ENABLE_AUTO_PROBE.flag")
  @fs_b1_v5_frame ||= 0
  @fs_b1_v5_frame += 1
  if @fs_b1_v5_frame == 340
   $game_player.moveto(19,5)
   $game_player.refresh
   $game_map.set_display_pos(10*256,0)
   FSRich.log("B1_V5_LODGE_BEHIND_PLACED tile=19,5")
  elsif @fs_b1_v5_frame == 365
   FSRich.log("B1_V5_LODGE_BEHIND_CAPTURE camera="+($game_map.display_x/8).to_s+","+($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif @fs_b1_v5_frame == 390
   $game_player.moveto(19,8)
   $game_player.refresh
   $game_map.set_display_pos(10*256,0)
   FSRich.log("B1_V5_LODGE_FRONT_PLACED tile=19,8")
  elsif @fs_b1_v5_frame == 415
   FSRich.log("B1_V5_LODGE_FRONT_CAPTURE camera="+($game_map.display_x/8).to_s+","+($game_map.display_y/8).to_s+" foot="+(($game_player.y+1)*32).to_s)
  elsif @fs_b1_v5_frame == 440
   FSRich.log("B1_V5_LODGE_PROBES_DONE")
  end
 end
end
"""

records[idx][2]=zlib.compress(rb.encode("ascii"))
with scripts.open("wb") as f:write(f,records)
check=load(scripts.open("rb"))
assert zlib.decompress(check[idx][2]).decode("ascii")==rb
ini=MAN/"Game.ini"
ini.write_text(ini.read_text(errors="replace").replace("Title=FS_B1_RICH_MANUAL_PLAYABLE","Title=FS_B1_V5_LODGE_PLAYABLE").replace("Title=FS_B1_OWNER_V3_NATIVE_TEST","Title=FS_B1_V5_LODGE_PLAYABLE"),encoding="ascii")
(MAN/"START_B1_V5.cmd").write_text("@echo off\r\ncd /d %~dp0\r\nstart \"\" Game.exe\r\n",encoding="ascii")
(MAN/"FS_RICH_VX_LOG.txt").write_text("V5_MANUAL_READY\n",encoding="ascii")
assert not (MAN/"ENABLE_AUTO_PROBE.flag").exists()
copytree(MAN,AUTO,dirs_exist_ok=True)
(AUTO/"ENABLE_AUTO_PROBE.flag").write_text("Native capture probe only, do not add to manual project.\n")
(AUTO/"FS_RICH_VX_LOG.txt").write_text("V5_AUTO_BEGIN\n",encoding="ascii")
copy2(MAN/"Graphics"/"Pictures"/"FS_ELF_RICH_Ground.png",OUT/"VX_IMPORTED_GROUND.png")
assert (MAN/"Graphics"/"Pictures"/"FS_ELF_RICH_Ground.png").read_bytes()==ground.read_bytes()
print("V5_NATIVE_ADAPTER_BUILD",sha[:12],flush=True)

# First prove manual Game.exe actually starts and never auto-teleports.
def launch(where,need,timeout=22,captures=False):
    f=where/"FS_RICH_VX_LOG.txt"
    proc=subprocess.Popen([str(where/"Game.exe")],cwd=where,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    images={}
    hwnd=0
    try:
        deadline=time.monotonic()+timeout
        contents=""
        while time.monotonic()<deadline:
            time.sleep(.07)
            contents=f.read_text(encoding="ascii",errors="replace")
            if captures:
                if not hwnd:hwnd=ctypes.windll.user32.FindWindowW(None,"FS_B1_V5_LODGE_PLAYABLE")
                for key,mark in {"MIXED":"B1_V3_CAPTURE_MIXED","FRONT":"B1_V3_CAPTURE_FRONT",
                "LODGE_BEHIND":"B1_V5_LODGE_BEHIND_CAPTURE","LODGE_FRONT":"B1_V5_LODGE_FRONT_CAPTURE"}.items():
                    if key not in images and mark in contents and hwnd:
                        p=LOG/("V5_NATIVE_"+key+".png")
                        ImageGrab.grab(window=hwnd).save(p)
                        images[key]=p
                        print("V4_NATIVE_FRAME_CAPTURED",key,flush=True)
            if all(mark in contents for mark in need) and (not captures or len(images)==4):
                break
            if proc.poll() is not None:break
        assert all(mark in contents for mark in need),("NATIVE_MISSING_LOG",where.name,contents[-1600:])
        if captures:assert len(images)==4,("MISSING_CAPTURES",list(images))
        return contents,images
    finally:
        if proc.poll() is None:
            proc.terminate()
            try:proc.wait(timeout=3)
            except subprocess.TimeoutExpired:proc.kill()

s1,_=launch(MAN,["RICH_VX_RUNTIME_GATE_PASS","RICH_RUNTIME_100_FRAMES"],timeout=12)
assert "B1_V3_CAPTURE_MIXED" not in s1,"UNWANTED_AUTOPROBE_IN_MANUAL"
copy2(MAN/"FS_RICH_VX_LOG.txt",LOG/"V5_MANUAL_NATIVE_SMOKE.log")
print("V5_MANUAL_NATIVE_SMOKE_PASS",flush=True)
s2,caps=launch(AUTO,["RICH_VX_RUNTIME_GATE_PASS","B1_V5_LODGE_PROBES_DONE"],timeout=35,captures=True)
copy2(AUTO/"FS_RICH_VX_LOG.txt",LOG/"V5_NATIVE_AUTOPROBE.log")
master=Image.open(ROOT/"build"/"FS_ELF_RICH_Master.png").convert("RGB")
owner=Image.open(OUT/"PIXEL_OWNER_ID.png")
objs=json.loads((OUT/"INSTANCE_ID_INDEX.json").read_text(encoding="utf8"))
results={}
for key,(tx,ty) in {"MIXED":(8,2),"FRONT":(4,2),"LODGE_BEHIND":(19,5),"LODGE_FRONT":(19,8)}.items():
    actual=Image.open(caps[key]).convert("RGB")
    assert actual.size==(544,416)
    pattern=("B1_V5_"+key+"_CAPTURE" if key.startswith("LODGE") else "B1_V3_CAPTURE_"+key)
    found=re.search(pattern+r" camera=(\d+),(\d+) foot=(\d+)",s2)
    assert found,"MISSING_FRAME_LOCATION"
    ox,oy,foot=map(int,found.groups())
    expected=master.crop((ox,oy,ox+544,oy+416))
    op=owner.load();a=actual.load();b=expected.load()
    outside=0;badforeground=0;changed=0;foreground=0
    for sy in range(416):
        wy=sy+oy
        for sx in range(544):
            wx=sx+ox
            pix=a[sx,sy];ref=b[sx,sy]
            actor_region=(tx*32+16-32<=wx<tx*32+16+32 and foot-72<=wy<foot+8)
            if pix!=ref:
                changed+=1
                if not actor_region:outside+=1
            if actor_region and 0<=wx<864 and 0<=wy<640:
                idx=op[wx,wy]
                if idx and foot<=objs[str(idx)]["draw_order"]:
                    foreground+=1
                    if pix!=ref:badforeground+=1
    assert outside==0,("NATIVE_BACKGROUND_NOT_MATCH",key,outside)
    assert badforeground==0,("FOREGROUND_OWNER_OCCLUSION_FAIL",key,badforeground)
    if key=="LODGE_BEHIND":
        assert changed==0,("LODGE_BEHIND_SHOULD_FULLY_OCCLUDE_NATIVE_ACTOR",changed)
        assert foreground>=500,("LODGE_BEHIND_NOT_OWNED_FOREGROUND",foreground)
    else:
        assert changed>0,("ACTOR_NOT_RENDERED",key)
    if key.startswith("LODGE"):
        assert (ox,oy)==(320,0),("HERO_CAMERA_WRONG",key,ox,oy)
        assert hero_overlap(tx,ty)>100,("HERO_OVERLAP_LOST",key)
        assert (foot<=hero["draw_order"])==(key=="LODGE_BEHIND"),("HERO_DEPTH_WRONG",key,foot)
    results[key]={"tile":[tx,ty],"camera":[ox,oy],"foot_y":foot,"changed_pixels_actor":changed,
                  "outside_actor_mismatches":outside,"occluding_object_pixels_in_actor_bbox":foreground,
                  "wrongly_overdrawn_occlusion_pixels":badforeground}
report={"status":"B1_V5_ISOLATED_NATIVE_LODGE_DEPTH_PASS_NOT_SEALED_FS",
        "candidate_manifest_sha256":sha,"manual_smoke":"PASS_NO_AUTO_TELEPORT",
        "automated_native_screen_audit":results,
        "object_sprite_count":len(objdata),"blocked_tiles":len(blocked),"behind_actor_fully_occluded_is_valid":True,"hero_front_tile":[19,8],"hero_behind_tile":[19,5],"sealed_fs_runtime":"NOT_RUN","human_gate_f":"NOT_RUN",
        "art_reference_quality":"NOT_PASS_QUALITY_GAP"}
(LOG/"V5_NATIVE_LODGE_AUDIT.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf8")
print("V5_NATIVE_LODGE_AUDIT",json.dumps(report,ensure_ascii=False),flush=True)
