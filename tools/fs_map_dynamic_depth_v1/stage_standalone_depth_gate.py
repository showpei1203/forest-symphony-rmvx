# -*- coding: utf-8 -*-
from pathlib import Path
import shutil
R=Path(__file__).resolve().parent
P=R.parent/"FS_ElfVillage_RichPilot_20261023"
fixture=R/"fixture"
assert not fixture.exists()
(fixture/"source/clean").mkdir(parents=True)
(fixture/"build").mkdir()
for f in (P/"source/clean").glob("*.png"):
 shutil.copyfile(f,fixture/"source/clean"/f.name)
for name in ["Ground","Par_BASE","Occlusion","Par_COMPLETE","Master","Collision"]:
 f=P/"build"/("FS_ELF_RICH_"+name+".png")
 assert f.is_file()
 shutil.copyfile(f,fixture/"build"/f.name)
shutil.copyfile(P/"scene_manifest.json",fixture/"scene_manifest.json")
shutil.copyfile(R.parent/"FS_ForestSplit_v3_2/build/TEST_ONLY_ACTOR.png",fixture/"actor.png")
for filename in ("audit_actor_depth_split.py","scan_depth_conflicts.py"):
 path=R/filename
 s=path.read_text(encoding="utf8")
 assert 'P=R.parent/"FS_ElfVillage_RichPilot_20261023"' in s
 s=s.replace('P=R.parent/"FS_ElfVillage_RichPilot_20261023"','P=R/"fixture"')
 s=s.replace('R.parent/"FS_ForestSplit_v3_2/build/TEST_ONLY_ACTOR.png"','R/"fixture/actor.png"')
 path.write_text(s,encoding="utf8")
engine=R.parent/"ToolValidation_T17D4_20261024/T17D4_EQUIPMENT_COVERAGE_CANDIDATE/Godot_v4.7.2-stable_win64.exe"
assert engine.is_file()
target=R/"godot_depth_probe/Godot_v4.7.2-stable_win64.exe"
assert not target.exists()
shutil.copyfile(engine,target)
readme="""# Forest Symphony: Dynamic Ground/PAR source-first validation V1
2026-10-24 | Private-source-only, Formal N5 unaffected.
One manifest, 48 scene objects, 864x640 world. Static Ground+PAR is exact when no actor appears, but fixed base/occlusion masks create errors after actor moves.
8px walkable grid sweep reveals 450 actor positions with depth mistakes and at most 193 wrong visible pixels in an actor. Actor depth ordering fixes source-geometry reference in four worst cases without redrawing the map. Four independent Godot4.7.2 real AMD RX6700XT OpenGL screenshots match compositor RGB exactly.
RUN_DEPTH_GATE.cmd: Requires Python+Pillow and signed-in desktop GPU session. Uses included Godot executable. It rebuilds scan, four before/after comparison PNGs, and four native engine captures. LOG and JSON are retained.
Outputs: DENSE_DEPTH_RESULT.json, DEPTH_PROBE_RESULT.json, DEPTH_GODOT_GPU_AUDIT.json, outputs/DEPTH_COMPARISON_0.png .. _3.png, godot_depth_probe/GPU_PROBES/*.png.
Important: The source images are PRIVATE TEST CANDIDATES with unresolved license, not approved production materials. Human Visual Gate F and complex art fidelity remain PENDING, and this run does not test RMVX runtime. Formal Forest Symphony N5 scripts=505 SEALED untouched.
Source-first architecture: signed asset hash+object transform+draw_order=single manifest. Actor-aware front/back sorting is required where two fixed PAR textures are insufficient.
"""
(R/"README_繁體中文.md").write_text(readme,encoding="utf8")
cmd="""@echo off
setlocal
cd /d "%~dp0"
where python >nul 2>nul
if errorlevel 1 exit /b 3
python -c "from PIL import Image"
if errorlevel 1 exit /b 4
python scan_depth_conflicts.py > SCAN.log 2>&1
if errorlevel 1 (type SCAN.log & exit /b 5)
python audit_actor_depth_split.py > PROBE.log 2>&1
if errorlevel 1 (type PROBE.log & exit /b 6)
set "ENGINE=%~dp0godot_depth_probe\Godot_v4.7.2-stable_win64.exe"
if not exist "%ENGINE%" exit /b 7
"%ENGINE%" --headless --path "godot_depth_probe" --editor --import --quit > IMPORT.log 2>&1
findstr /I /C:"SCRIPT ERROR" /C:"Parse Error" IMPORT.log >nul
if not errorlevel 1 (type IMPORT.log & exit /b 8)
"%ENGINE%" --path "godot_depth_probe" "res://depth_canary.tscn" --quit-after 350 > NATIVE_GPU.log 2>&1
if errorlevel 1 (type NATIVE_GPU.log & exit /b 9)
findstr /C:"FS_DYNAMIC_SOURCE_DEPTH_NATIVE_GPU_FOUR_PROBES_DONE" NATIVE_GPU.log >nul
if errorlevel 1 (type NATIVE_GPU.log & exit /b 10)
python audit_native_depth_gpu.py > GPU_AUDIT.log 2>&1
if errorlevel 1 (type GPU_AUDIT.log & exit /b 11)
echo [PASS] Dynamic source-first Ground/PAR depth gate
echo [PENDING] VX runtime / Human Visual / license
exit /b 0
"""
(R/"RUN_DEPTH_GATE.cmd").write_bytes(cmd.replace("\r\n","\n").replace("\n","\r\n").encode("ascii"))
print("STANDALONE_STAGED",len(list((fixture/"source/clean").glob("*.png"))),"Godot",target.stat().st_size,flush=True)
