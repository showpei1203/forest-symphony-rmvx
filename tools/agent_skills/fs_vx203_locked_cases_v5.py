"""FS Native VX ParSwitch203: single-location locked camera controlled cases.
Fresh isolated copies; writes only within FS_AGENT_SKILLS_PILOT_20261106/validation_v2.
"""
from pathlib import Path
from PIL import Image,ImageGrab,ImageChops
from rubymarshal.reader import loads
from rubymarshal.writer import writes
import ctypes,ctypes.wintypes as w,subprocess,time,re,json,hashlib,shutil,zlib
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\validation_v2")
SRC=Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST")
CASES=[4,6,8]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
keys=["Data/Scripts.rvdata","Data/Map050.rvdata","Overlays/Par50.png","Overlays/ground50.png"]
source_before={k:sha(SRC/k) for k in keys}
u=ctypes.windll.user32
CB=ctypes.WINFUNCTYPE(w.BOOL,w.HWND,w.LPARAM)
def windows(pid):
    found=[]
    def call(hwnd,lp):
        p=w.DWORD()
        u.GetWindowThreadProcessId(hwnd,ctypes.byref(p))
        if p.value==pid and u.IsWindowVisible(hwnd):
            c=ctypes.create_unicode_buffer(100)
            u.GetClassNameW(hwnd,c,99)
            found.append((int(hwnd),c.value))
        return True
    u.EnumWindows(CB(call),0)
    return found
stats={}
for slot in CASES:
    target=ROOT/f"VX203_LOCKED_CASE_{slot}"
    if target.exists():raise RuntimeError("FAIL CLOSED target already exists: "+str(target))
    print("CLONE_CASE",slot,flush=True)
    shutil.copytree(SRC,target)
    source=target/"Data/Scripts.rvdata"
    scripts=loads(source.read_bytes())
    ruby=zlib.decompress(scripts[483][2]).decode("utf8")
    a="frame_step=105"
    b="slot=(@a36f_frame-1)/frame_step"
    if ruby.count(a)!=1 or ruby.count(b)!=1:
        raise RuntimeError("UNEXPECTED SCRIPT SOURCE")
    ruby=ruby.replace(a,"frame_step=100000")
    ruby=ruby.replace(b,"slot="+str(slot))
    scripts[483][2]=zlib.compress(ruby.encode("utf8"))
    source.write_bytes(writes(scripts))
    log=target/"A36G_VX_ACTUAL_FULL_MAP.log"
    if log.exists():log.unlink()
    screenshots={}; events=[];errors=[];proc=None
    try:
        proc=subprocess.Popen([str(target/"Game.exe")],cwd=str(target))
        start=time.monotonic();seen=0
        while time.monotonic()-start<50:
            time.sleep(.17)
            ws=windows(proc.pid)
            if any(c=="#32770" for _,c in ws):
                errors=ws
                print("MODAL",slot,errors,flush=True)
                break
            if proc.poll() is not None:
                print("PROCESS_EXIT",slot,proc.returncode,flush=True);break
            if not log.exists():continue
            lines=log.read_text("utf8",errors="replace").splitlines()
            new=lines[seen:];seen=len(lines)
            for line in new:
                if "R2_RUNTIME_PAR" in line or "R2_CASE" in line or "CASE" in line:
                    events.append(line)
                m=re.search(r"R2_RUNTIME_PAR case=(\d+) frame=(58|86) sprite_present=(\w+) visible=(\w+) bitmap=(\w+)",line)
                if not m or int(m.group(1))!=slot:continue
                state="OFF" if m.group(2)=="58" else "ON"
                hwnd=next((h for h,cl in ws if cl=="RGSS Player"),None)
                status={"frame":int(m.group(2)),"sprite_present":m.group(3)=="true",
                        "par_visible":m.group(4)=="true","bitmap":m.group(5),"captured":False}
                if hwnd:
                    img=ImageGrab.grab(window=hwnd).convert("RGB")
                    if img.size==(544,416):
                        output=ROOT/f"VX203_LOCKED_CASE_{slot}_{state}.png"
                        img.save(output)
                        status.update({"captured":True,"sha256":sha(output),"path":str(output)})
                screenshots[state]=status
                print("CASE",slot,state,status["par_visible"],status["captured"],flush=True)
            if "OFF" in screenshots and "ON" in screenshots:break
    finally:
        if proc and proc.poll() is None:
            proc.terminate()
            try:proc.wait(timeout=4)
            except subprocess.TimeoutExpired:proc.kill()
    metric=None
    if screenshots.get("OFF",{}).get("captured") and screenshots.get("ON",{}).get("captured"):
        a=Image.open(screenshots["OFF"]["path"]).convert("RGB")
        b=Image.open(screenshots["ON"]["path"]).convert("RGB")
        diff=ImageChops.difference(a,b)
        box=diff.getbbox()
        pix=sum(1 for x in diff.getdata() if any(x))
        metric={"changed_pixels":pix,"bbox":list(box) if box else None,
         "within_actor_region":bool(box and box[2]-box[0]<64 and box[3]-box[1]<64)}
        comp=Image.new("RGB",(1088,416));comp.paste(a,(0,0));comp.paste(b,(544,0))
        comp.save(ROOT/f"VX203_LOCKED_CASE_{slot}_OFF_ON.png")
    valid=bool(metric and metric["changed_pixels"]>0 and metric["within_actor_region"] and
       screenshots["OFF"]["sprite_present"] and not screenshots["OFF"]["par_visible"] and
       screenshots["ON"]["sprite_present"] and screenshots["ON"]["par_visible"] and not errors)
    stats[str(slot)]={"controls":screenshots,"difference":metric,"errors":errors,
                      "events":events,"gate":"PASS" if valid else "FAIL"}
    print("CASE_RESULT",slot,"PASS" if valid else "FAIL",metric,flush=True)
source_after={k:sha(SRC/k) for k in keys}
report={"stage":"FS_AGENT_SKILLS_V5_NATIVE_SWITCH203_LOCKED_CASES",
"cases":stats,"original_sources_SHA_unchanged":source_before==source_after,
"source_sha256":source_after,
"primary_engine":"RPG Maker VX RGSS2 native Game.exe",
"candidate":"A36F_R2_CONSERVATIVE_PAR",
"mode":"one locked actor/camera position per process; actual switch203 OFF/ON",
"art_gate":"UNVERIFIED","formal_seal":"NO"}
report["native_gate"]="PASS" if all(x["gate"]=="PASS" for x in stats.values()) and report["original_sources_SHA_unchanged"] else "FAIL"
(ROOT/"VX203_LOCKED_CASES_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("FINAL",report["native_gate"],[(k,v["gate"]) for k,v in stats.items()],flush=True)