#!/usr/bin/env python3
"""R11 large 1280x928 source-derived 5-object PAR inside isolated true Map003 VX 40x29.
Original ground3 untouched; source-aligned masks are candidates. No claims of full art or full formal events.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image
import subprocess,zlib,json,hashlib,shutil
R=Path(__file__).resolve().parent
O=R/"R11_GROUND3_40x29_NATIVE"/"FULL505"
D=R/"R11_GROUND3_5OBJECT_NATIVE"/"FULL505";D.parent.mkdir(exist_ok=True)
rr=subprocess.run(["robocopy",str(O),str(D),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert rr.returncode<8
art=R/"R11_VILLAGE_SIZE_TECH"
meta=json.loads((art/"R11_GROUND3_5OBJECT_SAM2_GATE.json").read_text(encoding="utf8"))
assert meta["sam2_objects"]==5 and meta["prompt_consistent_count"]==5 and meta["rgb_from_source_exact"]
for ob in meta["objects"]:
 f=art/(ob["id"]+"_SOURCE_PAR.png")
 assert Image.open(f).size==(1280,928)
 shutil.copy2(f,D/"Graphics"/"Pictures"/("R5_OC_"+ob["id"]+".png"))
shutil.copy2(art/"R11_GROUND3_5OBJECT_SOURCE_PAR_CANDIDATE.png",D/"Overlays"/"Par1.png")
source=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
formal=load((source/"Data"/"Scripts.rvdata").open("rb"))
p=D/"Data"/"Scripts.rvdata";pages=load(p.open("rb"))
assert len(pages)==506 and all(pages[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
code=zlib.decompress(pages[482][2]).decode("ascii")
begin=code.index('     [["house",223]')
end=code.index(".each do |pair|",begin)
new='     '+json.dumps([[x["id"],x["anchor"][1]] for x in meta["objects"]],separators=(",",":"))
code=code[:begin]+new+code[end:]
assert 'FSR6.set_mode(@spriteset,"A_STATIC")' in code
code=code.replace('FSR6.set_mode(@spriteset,"A_STATIC")','FSR6.set_mode(@spriteset,"B_DYNAMIC")',1)
pattern='''" camera="+[$game_map.display_x,$game_map.display_y].inspect+
     " complete=true")'''
assert pattern in code
replacement='''" camera="+[$game_map.display_x,$game_map.display_y].inspect+
     " objectCount="+@spriteset.instance_variable_get(:@r5_depth_objects).size.to_s+
     " firstObjXY="+@spriteset.instance_variable_get(:@r5_depth_objects)[0].x.to_s+","+@spriteset.instance_variable_get(:@r5_depth_objects)[0].y.to_s+
     " complete=true")'''
code=code.replace(pattern,replacement,1)
pages[482][2]=zlib.compress(code.encode("ascii"))
with p.open("wb") as f:write(f,pages)
read=load(p.open("rb"));assert all(read[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
ini=D/"Game.ini";a=ini.read_bytes()
assert b"Title=FS_R11_GROUND3_40x29" in a
ini.write_bytes(a.replace(b"Title=FS_R11_GROUND3_40x29",b"Title=FS_R11_GROUND3_PAR5"))
(D/"R11_GROUND3_NATIVE.log").write_text("R11_PAR5_BOOT\n",encoding="ascii")
report={"status":"R11_LARGE_5PAR_SAM2_TEST_BUILD_READY","ground3_40x29_source_unmodified":True,
"object_count":5,"PAR_RGB_source_exact":True,
"sprites_current_scroll_updated_each_frame":True,"only_isolated_adapter_modified":True,
"original_505_source_files_modified":False,"original_Map003_source_modified":False,
"art_complete":False,"full_semantic_truth":False}
(D.parent/"R11_5PAR_BUILD.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R11_LARGE_PAR5_NATIVE_BUILD",json.dumps(report,ensure_ascii=False),flush=True)