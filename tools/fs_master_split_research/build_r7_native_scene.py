#!/usr/bin/env python3
"""R7 generated source-pixel PAR registry attached to R6 isolated native VX A/B/A harness.
No edits to sealed 505 source scripts or other FS map development.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import subprocess,hashlib,zlib,json,re,shutil
R=Path(__file__).resolve().parent
reg=json.loads((R/"R7_SEMANTIC_MASK_CANDIDATES"/"R7_SAM2_PROMPT_REGISTRY_GATE.json").read_text())
assert len(reg["objects"])==12
SRC=R/"R6_SAME_SESSION_ISOLATED"/"FULL505"
DEST=R/"R7_NATIVE_FULL_MASTER"/"FULL505"
DEST.parent.mkdir(exist_ok=True)
res=subprocess.run(["robocopy",str(SRC),str(DEST),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert res.returncode<8,(res.returncode,res.stdout[-800:])
formal=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
official=load(formal.open("rb"))
p=DEST/"Data"/"Scripts.rvdata"
a=load(p.open("rb"));assert len(a)==506
assert all(a[i if i<482 else i+1]==official[i] for i in range(505) if i!=480)
s=zlib.decompress(a[482][2]).decode("ascii")
old='[["house",214],["left_tree",190],["right_tree",237]]'
assert old in s,"cannot find older 3-object loop"
new=json.dumps([[o["id"],o["foot"][1]] for o in reg["objects"]],separators=(",",":"))
s=s.replace(old,new,1)
pattern=r'CASES = \[\["PLAYER_FRONT_NPC_BEHIND",\[4,5\],\[4,3\]\],\s*\["PLAYER_BEHIND_NPC_FRONT",\[4,3\],\[4,5\]\],\s*\["BOTH_FRONT",\[4,5\],\[5,5\]\],\s*\["BOTH_BEHIND",\[4,3\],\[5,3\]\],\s*\["CLEAR",\[8,9\],\[9,9\]\]\]'
assert re.search(pattern,s),"cannot find R6 original 5 probes"
# Four real 17x13 candidate depth conflicts from R7 direct 4-dir scan, plus clear.
probes=[
 ["LEFT_CONIFER_FRONT",[3,6],[4,3]],
 ["HOUSE_FRONT_X8",[8,6],[10,4]],
 ["HOUSE_FRONT_X9",[9,6],[10,4]],
 ["RIGHT_MARKER_FRONT",[12,7],[12,5]],
 ["CLEAR",[8,9],[9,9]]
]
s=re.sub(pattern,"CASES = "+json.dumps(probes,separators=(",",":")),s,count=1)
a[482][2]=zlib.compress(s.encode("ascii"))
with p.open("wb") as f:write(f,a)
assert all(load(p.open("rb"))[i if i<482 else i+1]==official[i] for i in range(505) if i!=480)
# Ground identical original full image. Static mask one union PNG alpha; dynamic 12 independent source-pixel layers.
r7=R/"R7_SEMANTIC_MASK_CANDIDATES"
shutil.copy2(r7/"PAR_R7_PROPOSAL_SAME_SOURCE_RGBA.png",DEST/"Overlays"/"Par1.png")
for o in reg["objects"]:
 shutil.copy2(r7/(o["id"]+"_PAR_OCCLUSION_CANDIDATE.png"),DEST/"Graphics"/"Pictures"/("R5_OC_"+o["id"]+".png"))
ini=DEST/"Game.ini"
txt=ini.read_bytes()
assert b"Title=FS_R6_VX_SAME_SESSION" in txt
ini.write_bytes(txt.replace(b"Title=FS_R6_VX_SAME_SESSION",b"Title=FS_R7_PAR_SAME_SESSION"))
(DEST/"R5_ENABLE_AUTO_PROBE.flag").unlink(missing_ok=True)
(DEST/"ENABLE_R6_SAME_SESSION.flag").write_text("ISOLATED_R7_SAM2_MASKS",encoding="ascii")
(DEST/"R6_A_B_A_NATIVE.log").write_text("R7_TEST_BEGIN\n",encoding="ascii")
meta={"status":"R7_ISOLATED_VX_NATIVE_BUILD_DONE_NOT_RUN","objects":len(reg["objects"]),
 "static_union_alpha_par_source":str(r7/"PAR_R7_PROPOSAL_SAME_SOURCE_RGBA.png"),
 "actor_position_cases":probes,"formal_505_scripts_original_pages_identical":504,
 "disabled_formal_page_480":True,"added_test_adapter_page":482,
 "source_sha256":hashlib.sha256(formal.read_bytes()).hexdigest(),"formal_source_modified":False}
(DEST.parent/"R7_BUILD_MANIFEST.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding="utf8")
print("R7_NATIVE_BUILD_READY",json.dumps({"objects":len(probes),"masks":len(reg["objects"]),"title":"FS_R7_PAR_SAME_SESSION"}),flush=True)