from pathlib import Path
import subprocess,sys,json,datetime
root=Path(__file__).resolve().parent
lab=root.parent
godot=Path(r"E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
tiled=lab/"tools"/"Tiled"/"tmxrasterizer.exe"
commands=[
 ("normalize_sources",[sys.executable,str(root/"normalize_sources.py")]),
 ("create_manifest",[sys.executable,str(root/"make_manifest.py")]),
 ("compile_scene",[sys.executable,str(root/"compile_scene.py")]),
 ("tiled_independent_renderer",[str(tiled),str(root/"work"/"FS_FOREST_V32_scene.tmx"),str(root/"build"/"FS_FOREST_V32_TiledIndependentRender.png")]),
 ("gate_A_to_E",[sys.executable,str(root/"validate_scene.py")]),
 ("negative_regression",[sys.executable,str(root/"negative_tests.py")]),
 ("godot_adapter",[sys.executable,str(root/"create_godot_test.py")]),
 ("godot_import",[str(godot),"--headless","--path",str(root/"godot_test"),"--editor","--import","--quit"]),
 ("godot_runtime",[str(godot),"--headless","--path",str(root/"godot_test"),"--quit-after","120"])
]
report={"project":"FS_MAP_V3_2_Forest_544x416","date":"2026-10-23","checks":[]}
ok=True
for name,cmd in commands:
    print("START",name,flush=True)
    try:
        proc=subprocess.run(cmd,timeout=100,capture_output=True,text=True,errors="replace",cwd=root)
        stdout=proc.stdout[-4000:];stderr=proc.stderr[-4000:]
        valid=proc.returncode==0
        if name=="godot_runtime":
            valid=valid and "GODOT_GATE_F_LOGIC_PASS" in stdout and "SCRIPT ERROR" not in (stdout+stderr)
            (root/"logs"/"GODOT_SMOKE.log").write_text(stdout+"\n"+stderr,encoding="utf8")
        if name=="gate_A_to_E":valid=valid and "GATES {'A': True, 'B': True, 'C': True, 'D': True, 'E': True}" in stdout
        if name=="negative_regression":valid=valid and '"accepted": 9' in stdout
        print(("PASS " if valid else "FAIL ")+name)
        report["checks"].append({"name":name,"pass":valid,"returncode":proc.returncode,"stdout_tail":stdout[-1200:],"stderr_tail":stderr[-500:]})
        if not valid:ok=False;break
    except Exception as e:
        report["checks"].append({"name":name,"pass":False,"error":str(e)});ok=False;break
report["smoke_status"]="PASS" if ok else "FAIL"
report["formal_status"]="COMPILED CANDIDATE / GODOT HEADLESS TEST LOGIC PASS; VX + HUMAN VISUAL PENDING" if ok else "FAIL_CLOSED"
(root/"logs"/"RUN_ALL_SUMMARY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(report["smoke_status"],len(report["checks"]),"tasks")
sys.exit(0 if ok else 2)
