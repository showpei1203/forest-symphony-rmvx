#!/usr/bin/env python3
"""Create R5 self-documenting clone staging from exact original sealed baseline. Never mutate baseline."""
from pathlib import Path
import subprocess,hashlib,json
R=Path(__file__).resolve().parent
SOURCE=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
DEST=R/"R5_FORMAL_ADAPTER_ISOLATED"/"FULL505"
S=SOURCE/"Data"/"Scripts.rvdata"
# Actual hash observed and maintained in R5 report, guard against stale or modified source.
correct="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256(S.read_bytes()).hexdigest()==correct
DEST.mkdir(exist_ok=True,parents=True)
result=subprocess.run(["robocopy",str(SOURCE),str(DEST),"/E","/R:0","/W:0","/XD","Saves","/XF","*.log","*.txt","temp.png"],capture_output=True,text=True,errors="replace")
if result.returncode>=8:
 raise RuntimeError("FAIL CLOSED robocopy rc="+str(result.returncode)+" tail "+result.stdout[-800:])
for rel in ["Game.exe","Game.ini","Data/Scripts.rvdata","Data/Map001.rvdata","Graphics/Characters/$002.png"]:
 assert (DEST/rel).is_file(),rel
assert hashlib.sha256((DEST/"Data"/"Scripts.rvdata").read_bytes()).hexdigest()==correct
print("R5_STAGE_FULL505_CLONE_PASS",{"files":sum(1 for _ in DEST.rglob("*") if _.is_file()),"sha256":correct},flush=True)