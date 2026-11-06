"""FS V5 native RPG Maker VX original-style roof/tree occlusion validation.
Fresh isolated 3 Game.exe clones; exact ORIGINAL ground3 source RGB + two original-par3 semantic source ROIs,
normalizing only overlay RGB to same underlying pixels for clean OFF/ON actor diff.
Not A36G art approval, not a new full map.
"""
from pathlib import Path
from PIL import Image,ImageGrab,ImageChops,ImageDraw
from rubymarshal.reader import loads
from rubymarshal.writer import writes
import ctypes,ctypes.wintypes as w,subprocess,time,re,json,hashlib,shutil,zlib
import numpy as np
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_V6_C2_2OBJECT_NATIVE_203_20261107")
SRC=Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST")
CANON=Path(r"E:\A36G_V6_C2_REFINED_ROOF_MASK_20261107")
CANON=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_V6_C2_REFINED_ROOF_MASK_20261107")
if ROOT.exists():raise SystemExit("REFUSED preexisting native benchmark output")
ROOT.mkdir(parents=True)
m=json.loads((CANON/"V6_2OBJECT_SEMANTIC_QA.json").read_text("utf8"))
samples=dict(m["actor_test_targets"])
samples["CLEAR_NEGATIVE_CONTROL"]={"tile":[20,14],"actor_mask_overlap":0.0}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
keys=["Data/Scripts.rvdata","Data/Map050.rvdata","Overlays/Par50.png","Overlays/ground50.png"]
before={k:sha(SRC/k) for k in keys}
orig_par=CANON/"RUNTIME_PAR50_ROOF_TREE_ONLY.png"
orig_full=CANON/"RUNTIME_FULL_SCENE_GROUND50.png"
assert Image.open(orig_par).size==Image.open(orig_full).size==(1280,928)
assert Image.open(orig_par).mode=="RGBA"
u=ctypes.windll.user32
CB=ctypes.WINFUNCTYPE(w.BOOL,w.HWND,w.LPARAM)
def windows(pid):
    found=[]
    def cb(hwnd,lp):
        proc=w.DWORD();u.GetWindowThreadProcessId(hwnd,ctypes.byref(proc))
        if proc.value==pid and u.IsWindowVisible(hwnd):
            name=ctypes.create_unicode_buffer(120);u.GetClassNameW(hwnd,name,119)
            found.append((int(hwnd),name.value))
        return True
    u.EnumWindows(CB(cb),0)
    return found
records={}
for case,coords in samples.items():
    x,y=coords["tile"]
    test=ROOT/("VX_NATIVE_"+case)
    print("COPY",case,x,y,flush=True)
    shutil.copytree(SRC,test)
    shutil.copy2(orig_full,test/"Overlays/ground50.png")
    shutil.copy2(orig_par,test/"Overlays/Par50.png")
    assert sha(test/"Overlays/ground50.png")==sha(orig_full)
    assert sha(test/"Overlays/Par50.png")==sha(orig_par)
    sfile=test/"Data/Scripts.rvdata"
    scripts=loads(sfile.read_bytes())
    ruby=zlib.decompress(scripts[483][2]).decode("utf8")
    a="slot=(@a36f_frame-1)/frame_step"
    inject_line="    @a36f_frame+=1"
    assert ruby.count(a)==ruby.count(inject_line)==1
    ruby=ruby.replace(a,"slot=999")
    inject=f'''
    # Original canonical Ground3/Par3 witness from same-source pixels; test-only.
    if @a36f_frame==280
      $game_player.moveto({x},{y})
      $game_player.transparent=false
      $game_switches[203]=false
      A36G_MAP.log("V6_OBJECT_INIT case={case} actor={x},{y}")
    elsif @a36f_frame==350 || @a36f_frame==450
      sp=$OverlayMap.instance_variable_get(:@par)
      st=(@a36f_frame==350 ? "OFF" : "ON")
      A36G_MAP.log("V6_OBJECT_SHOT case={case} state="+st+" pos="+$game_player.x.to_s+","+$game_player.y.to_s+
        " display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s+
        " par_visible="+(sp && sp.visible).to_s+
        " sprite_present="+(!sp.nil?).to_s+" par_bitmap="+(sp && sp.bitmap && sp.bitmap.width).to_s)
    elsif @a36f_frame==395
      $game_switches[203]=true
      A36G_MAP.log("V6_OBJECT_TOGGLE case={case} switch203=true")
    end
'''
    ruby=ruby.replace(inject_line,inject_line+"\n"+inject)
    scripts[483][2]=zlib.compress(ruby.encode("utf8"))
    sfile.write_bytes(writes(scripts))
    events=[];shots={};errors=[];proc=None
    log=test/"A36G_VX_ACTUAL_FULL_MAP.log"
    if log.exists():log.unlink()
    try:
        proc=subprocess.Popen([str(test/"Game.exe")],cwd=str(test))
        start=time.monotonic();seen=0
        while time.monotonic()-start<60:
            time.sleep(.15)
            ws=windows(proc.pid)
            if any(cl=="#32770" for _,cl in ws):
                errors=ws;print("ERROR_MODAL",case,errors,flush=True);break
            if proc.poll() is not None:
                print("PROCESS_EXIT",case,proc.returncode,flush=True);break
            if not log.exists():continue
            lines=log.read_text(encoding="utf8",errors="replace").splitlines()
            new=lines[seen:];seen=len(lines)
            for line in new:
                if not line.startswith("V6_OBJECT"):continue
                events.append(line)
                mm=re.search(r"V6_OBJECT_SHOT case=(\S+) state=(OFF|ON) pos=(\d+),(\d+) display=(\d+),(\d+) par_visible=(\w+) sprite_present=(\w+) par_bitmap=(\S+)",line)
                if not mm:continue
                label,state,px,py,cx,cy,vis,present,bmp=mm.groups()
                info={"actor_tile":[int(px),int(py)],"display_raw":[int(cx),int(cy)],
                      "par_visible":vis=="true","sprite_present":present=="true",
                      "par_bitmap":bmp,"captured":False}
                hwnd=next((h for h,cl in ws if cl=="RGSS Player"),None)
                if hwnd:
                    screenshot=ImageGrab.grab(window=hwnd).convert("RGB")
                    if screenshot.size==(544,416):
                        path=ROOT/f"V6_OBJECT_{case}_{state}.png"
                        screenshot.save(path)
                        info.update({"captured":True,"image":path.name,"sha256":sha(path)})
                shots[state]=info
                print("SHOOT",case,state,vis,info["captured"],flush=True)
            if "OFF" in shots and "ON" in shots:break
    finally:
        if proc and proc.poll() is None:
            proc.terminate()
            try:proc.wait(timeout=5)
            except subprocess.TimeoutExpired:proc.kill()
    off,on=shots.get("OFF",{}),shots.get("ON",{})
    diff=None
    if off.get("captured") and on.get("captured"):
        a=Image.open(ROOT/off["image"]).convert("RGB");b=Image.open(ROOT/on["image"]).convert("RGB")
        delta=ImageChops.difference(a,b);box=delta.getbbox()
        count=int(np.any(np.asarray(delta)!=0,axis=2).sum())
        diff={"changed_pixels":count,"bbox":list(box) if box else None,
              "actor_local_bbox":bool(box and box[2]-box[0]<=70 and box[3]-box[1]<=70)}
        output=Image.new("RGB",(1088,416),(30,30,30));output.paste(a,(0,0));output.paste(b,(544,0))
        output.save(ROOT/f"V6_OBJECT_{case}_OFF_ON.png")
    expected_nonzero=case!="CLEAR_NEGATIVE_CONTROL"
    diff_correct=bool(diff and diff["changed_pixels"]>=150 and diff["actor_local_bbox"]) if expected_nonzero else bool(diff and diff["changed_pixels"]<=12)
    case_pass=bool(not errors and off.get("actor_tile")==[x,y] and on.get("actor_tile")==[x,y] and
                   off.get("display_raw")==on.get("display_raw") and off.get("sprite_present") and
                   on.get("sprite_present") and off.get("par_visible") is False and
                   on.get("par_visible") is True and diff_correct)
    records[case]={"sample":coords,"shots":shots,"delta":diff,"raw_events":events,
                   "errors":errors,"native_gate":"PASS" if case_pass else "FAIL"}
    print("CASE_FINAL",case,records[case]["native_gate"],diff,flush=True)
after={k:sha(SRC/k) for k in keys}
result={"stage":"A36G_V6_C2_TWO_SOURCE_ASSETS_NATIVE_SEMANTIC_203",
        "source_r5_master_full_scene":str(orig_full),"source_two_object_roof_and_tree_mask":str(orig_par),
        "source_r5_master_sha":m["source_r5_master_sha256"],
        "source_legacy_map50_collision_warning":"Map50 collision remains A36F, while scene is A36G R5; do NOT claim correct collisions; this is ONLY a stationary switch203 occlusion test.",
        "no_source_files_modified":before==after,
        "cases":records,"all_native_cases_pass":all(v["native_gate"]=="PASS" for v in records.values()) and before==after,
        "art_status":"A36G R5 ART FAIL; V6 per-source roof polygon art DRAFT",
        "new_art_generated":False,
        "source_rgb_registration_verified":True,
        "full_map_pathfinding_validated":False,"formal_seal":"NO"}
(ROOT/"V6_OBJECT_ROOF_TREE_NATIVE_203_QA.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
# Simple evidence contact
sheet=Image.new("RGB",(1088,456*len(records)),(26,29,32));dr=ImageDraw.Draw(sheet)
for i,(key,val) in enumerate(records.items()):
    photo=ROOT/f"V6_OBJECT_{key}_OFF_ON.png"
    if photo.exists():
        sheet.paste(Image.open(photo).convert("RGB"),(0,i*456+40))
    dr.text((10,i*456+13),key+" | V5 "+val["native_gate"],fill=(255,255,255))
sheet.save(ROOT/"V6_A36G_TWO_OBJECT_3_TESTS_OFF_ON_CONTACT.png")
print("GLOBAL",json.dumps({"all_native_cases_pass":result["all_native_cases_pass"],
"cases":{k:{"gate":v["native_gate"],"changed":v["delta"]["changed_pixels"] if v["delta"] else None} for k,v in records.items()},
"source_unchanged":result["no_source_files_modified"]},ensure_ascii=False),flush=True)