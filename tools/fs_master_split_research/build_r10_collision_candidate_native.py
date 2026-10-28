#!/usr/bin/env python3
"""FS R10 compile 17x13 source-derived COLLISION CANDIDATE into another isolated actual VX.
Preserve K4 formal Map050 and 505 scripts. Native actual movement validates generated passage.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import subprocess,zlib,hashlib,json,re,shutil
R=Path(__file__).resolve().parent
AUTH=R/"R10_FORMAL_MAP_AUTHORITY"
C=AUTH/"Map050_SCENE21_COLLISION_CANDIDATE.rvdata"
META=json.loads((AUTH/"R10_COLLISION_POLICY_CANDIDATE.json").read_text(encoding="utf8"))
assert C.is_file() and META["candidate_blocked_768_count"]==17 and META["ground_default_walkable_769_count"]==204
SRC=R/"R10_ORIGINAL_MAP050_NATIVE"/"FULL505";DST=R/"R10_COLLISION_NATIVE_CANDIDATE"/"FULL505";DST.parent.mkdir(exist_ok=True)
res=subprocess.run(["robocopy",str(SRC),str(DST),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert res.returncode<8,res.stdout[-500:]
K4=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
formal=load((K4/"Data"/"Scripts.rvdata").open("rb"))
sfile=DST/"Data"/"Scripts.rvdata"
pages=load(sfile.open("rb"))
assert len(pages)==506 and all(pages[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
old=zlib.decompress(pages[482][2]).decode("ascii")
p1=old.index("module FSR10")
p2=old.index("\n def self.log(s)",p1)
old_tests=old[p1:p2]
new_tests='''module FSR10
 TESTS=[
  ["F01_MAP050_TREE_DOWN",[13,3],"down",[13,4],true],
  ["F02_MAP050_TREE_FRONT",[13,4],"down",[13,4],false],
  ["F03_MAP050_BUSH_LEFT",[2,8],"left",[1,8],true],
  ["F04_MAP050_BUSH_RIGHT",[2,8],"right",[2,8],false],
  ["F05_MAP050_STEPS_DOWN",[9,5],"down",[9,6],true],
  ["F06_MAP050_PREVIOUS_BLOCK_UP",[5,7],"up",[5,6],true],
  ["F07_MAP050_PREVIOUS_BLOCK_LEFT",[6,6],"left",[5,6],true],
  ["F08_MAP050_BOUNDARY_LEFT",[0,4],"left",[0,4],false],
  ["F09_MAP050_BOUNDARY_UP",[1,0],"up",[1,0],false],
  ["F10_MAP050_NPC_MOVE",[12,8],"npc_down",[12,8],false],
  ["F11_MAP050_NPC_FREE",[12,8],"npc_down",[12,8],true]
 ]'''
s=old[:p1]+old[p1:].replace(old_tests,new_tests,1)
# NPC move with one real movement success and one obstacle-blocked.
assert "npc.moveto(12,6);npc.refresh" in s
s=s.replace("npc.moveto(12,6);npc.refresh",
'''npcstart=(tag=="F11_MAP050_NPC_FREE") ? [10,7] : [12,6]
       npc.moveto(npcstart[0],npcstart[1]);npc.refresh''',1)
assert '(act=="npc_down") ? [12,6] : want' in s
s=s.replace('(act=="npc_down") ? [12,6] : want',
'''(act=="npc_down") ? ((tag=="F11_MAP050_NPC_FREE") ? [10,8] : [12,6]) : want''')
s=s.replace("R10_FORMAL_MAP050_NATIVE.log","R10_COMPILED_MAP050_NATIVE.log")
pages[482][2]=zlib.compress(s.encode("ascii"))
with sfile.open("wb") as f:write(f,pages)
actual=load(sfile.open("rb"));assert all(actual[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
shutil.copy2(C,DST/"Data"/"Map001.rvdata")
assert hashlib.sha256((DST/"Data"/"Map001.rvdata").read_bytes()).hexdigest()==META["test_candidate_map_sha256"]
ini=DST/"Game.ini";s=ini.read_bytes()
assert b"Title=FS_R10_FORMAL_MAP050" in s
ini.write_bytes(s.replace(b"Title=FS_R10_FORMAL_MAP050",b"Title=FS_R10_COLLISION_CANDIDATE"))
(DST/"R10_COMPILED_MAP050_NATIVE.log").write_text("R10_CANDIDATE_BEGIN\n",encoding="ascii")
(DST/"ENABLE_R10_FORMAL_MAP050.flag").write_text("R10_CANDIDATE_FROM_SCENE21_PAR_ANCHORS",encoding="ascii")
report={"status":"R10_COLLISION_NATIVE_CANDIDATE_BUILT_NOT_RUN",
"original_formal_Map050_unmodified":True,"formal_505_scripts_unmodified":True,
"isolated_original_504_pages_byte_identical":True,"isolated_480_boot_regression_disabled":True,
"scene21_source_master_unchanged":True,"map_parallax_name":"SCENE21",
"test_candidate_Passa_768_block":17,"test_candidate_Passa_769_walk":204,
"blue_stair_tile":[9,6],"native_move_testcases":11,
"semantic_collision_full_footprint_approved":False}
(DST.parent/"R10_CANDIDATE_BUILD.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R10_CANDIDATE_BUILD",json.dumps(report,ensure_ascii=False),flush=True)