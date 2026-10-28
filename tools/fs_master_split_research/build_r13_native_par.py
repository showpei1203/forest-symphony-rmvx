#!/usr/bin/env python3
"""R13 isolate R12 working test and replace source-only PAR 52 objects with bbox cropped sprites.
Correct actor depth and scroll by compensated source coords, preserving original K4 script pages.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import json,zlib,subprocess,shutil,hashlib
R=Path(__file__).resolve().parent
SRC=R/"R12_NEW_ELF_VILLAGE_NATIVE"/"FULL505"
DEST=R/"R13_NEW_ELF_VILLAGE_NATIVE"/"FULL505";DEST.parent.mkdir(exist_ok=True)
objects=json.loads((R/"R13_TILE_OCCLUSION_PAR_20261028"/"R13_OPTIMIZED_SPRITE_MANIFEST.json").read_text(encoding="utf8"))["objects"]
assert len(objects)==52
copy=subprocess.run(["robocopy",str(SRC),str(DEST),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert copy.returncode<8,copy.stdout[-800:]
D=R/"R13_TILE_OCCLUSION_PAR_20261028"
shutil.copy2(D/"PAR_R13_GRID_FIRST_SOURCE_CANDIDATE.png",DEST/"Overlays"/"Par1.png")
for o in objects:
 shutil.copy2(D/o["crop_filename"],DEST/"Graphics"/"Pictures"/("R5_OC_"+o["id"]+".png"))
root=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
formal_file=root/"Data"/"Scripts.rvdata"
assert hashlib.sha256(formal_file.read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
baseline=load(formal_file.open("rb"))
p=DEST/"Data"/"Scripts.rvdata";pages=load(p.open("rb"))
assert len(pages)==506 and all(pages[i if i<482 else i+1]==baseline[i] for i in range(505) if i!=480)
script=zlib.decompress(pages[482][2]).decode("ascii")
selected=json.loads((R/"R12_NEW_ELF_VILLAGE_001"/"R12_SELECTED14_AND_COLLISION_GATE.json").read_text())["selected_objects"]
old=json.dumps([[o["id"],o["foot_anchor"][1]] for o in selected],separators=(",",":"))
new=json.dumps([[o["id"],o["foot_z"],o["xy"][0],o["xy"][1]] for o in objects],separators=(",",":"))
assert old in script
script=script.replace(old,new,1)
a='''   @r5_depth_objects=[]
   if FSR5::MODE=="DYNAMIC_ADAPTER"'''
b='''   @r5_depth_objects=[]
   @r13_offsets=[]
   if FSR5::MODE=="DYNAMIC_ADAPTER"'''
assert a in script;script=script.replace(a,b,1)
oldblock='''       @r5_depth_objects.push(sp)'''
newblock='''       @r5_depth_objects.push(sp)
       @r13_offsets.push([pair[2],pair[3]])'''
assert oldblock in script;script=script.replace(oldblock,newblock,1)
oldscroll='''     @r5_depth_objects.each {|sp|sp.x=-offx;sp.y=-offy}'''
newscroll='''     @r5_depth_objects.each_with_index do |sp,i|
       pos=@r13_offsets[i]
       sp.x=pos[0]-offx
       sp.y=pos[1]-offy
     end'''
assert oldscroll in script;script=script.replace(oldscroll,newscroll,1)
# Native test will inherit R12 existing 14 moves, but R12 log first sprite should now track its origin.
oldlog='''     " parObjXY="+[firstobj.x,firstobj.y].inspect+'''
newlog='''     " parObjXY="+[firstobj.x,firstobj.y].inspect+
     " parObjWorldBase="+@spriteset.instance_variable_get(:@r13_offsets)[0].inspect+'''
assert oldlog in script;script=script.replace(oldlog,newlog,1)
script=script.replace("R12_NEW_VILLAGE_NATIVE.log","R13_NEW_TILE_PAR_NATIVE.log")
pages[482][2]=zlib.compress(script.encode("ascii"))
with p.open("wb") as f:write(f,pages)
v=load(p.open("rb"))
assert all(v[i if i<482 else i+1]==baseline[i] for i in range(505) if i!=480)
assert len(v)==506
cfg=DEST/"Game.ini";raw=cfg.read_bytes()
assert b"Title=FS_R12_ELF_VILLAGE_001" in raw
cfg.write_bytes(raw.replace(b"Title=FS_R12_ELF_VILLAGE_001",b"Title=FS_R13_GRID_PAR52"))
(DEST/"R13_NEW_TILE_PAR_NATIVE.log").write_text("R13_NATIVE_BOOT\n",encoding="ascii")
out={"status":"R13_NATIVE_CROPPED_52_SAME_SOURCE_OBJECTS_TEST_READY",
"object_count":52,"source_RGBA_master_unmodified":True,
"formal_original_Scripts_504_tuples_exact":True,
"official_505_page_480_alias_issue_only_disabled_in_isolation":True,
"original_Map003_binary_untouched":True,
"native_A_B_A_depth_test_new":False,"human_PAR_art_gate":"HOLD"}
(DEST.parent/"R13_NATIVE_BUILD.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print("R13_NATIVE_BUILD",json.dumps(out,ensure_ascii=False),flush=True)