# -*- coding: utf-8 -*-
"""T17D replay: source composition -> isolated Godot import -> real GPU -> pixel audit. Fail-closed."""
from pathlib import Path
import subprocess,sys,hashlib,json,time
ROOT=Path(__file__).resolve().parent
GODOT=Path(r"E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
PROJ=ROOT/"godot"/"LPC128_24frame"
SEAL=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\N5_RUNTIME_CLONE\Data\Scripts.rvdata")
BASELINE="3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9"
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(SEAL)==BASELINE,"Sealed clone scripts unexpectedly changed BEFORE test"
stages=[
 ("T17D1_build", [sys.executable,ROOT/"run_t17d1.py"], "T17D1_MODULAR_HEAD_HAIR_WEAPON_24FRAME_STRUCTURAL_PASS_HUMAN_RUNTIME_PENDING",30),
 ("T17D2_prepare", [sys.executable,ROOT/"prepare_t17d2_godot.py"], "T17D2_PREPARED",20),
 ("T17D2_import", [GODOT,"--headless","--path",PROJ,"--editor","--import","--quit"],None,35),
 ("T17D2_real_gpu", [GODOT,"--path",PROJ,"--quit-after","300"],"T17D2_NATIVE_GPU_24_CAPTURES_PASS",35),
 ("T17D2_audit", [sys.executable,ROOT/"audit_t17d2_gpu.py"],"T17D2_NATIVE_GODOT_GPU_24_CAPTURE_PASS",20),
]
captures=PROJ/"captures"
log_list=[];exit_status="T17D1_T17D2_FAIL_CLOSED"
try:
    assert GODOT.is_file(),"Godot executable missing"
    for p in captures.glob("T17D2_?_?.png"):p.unlink()
    for name,argv,marker,limit in stages:
        started=time.perf_counter()
        cp=subprocess.run(list(map(str,argv)),cwd=ROOT,timeout=limit,creationflags=0x08000000,
                          capture_output=True,text=True,errors="replace")
        log=cp.stdout+"\n"+cp.stderr
        (ROOT/(name+".log")).write_text(log,encoding="utf-8")
        check=(cp.returncode==0 and (marker is None or marker in log))
        log_list.append({"stage":name,"exit":cp.returncode,"pass":check,
                         "seconds":round(time.perf_counter()-started,2),"log":name+".log"})
        print(("PASS" if check else "FAIL"),name,flush=True)
        if not check:raise RuntimeError(name+" failed "+log[-1100:])
    report=json.loads((ROOT/"T17D2_GODOT_GPU_RENDER_AUDIT.json").read_text(encoding="utf8"))
    assert report["captured_frames"]==24 and report["distinct_screenshot_hashes"]==24
    assert report["max_rgb_channel_error_vs_expected_blend"]==0 and report["outside_drawregion_total_changed"]==0
    assert sha(SEAL)==BASELINE,"Sealed clone Scripts changed AFTER test"
    exit_status="T17D1_T17D2_REAL_GPU_5_OF_5_PASS"
except Exception as e:
    log_list.append({"error":repr(e),"pass":False})
manifest={"status":exit_status,"stages":log_list,"sealed_scripts_unchanged":sha(SEAL)==BASELINE,
          "sealed_scripts_sha256":BASELINE,"FS_MAP":"PAUSED N5 B0 HUMAN GATE F PENDING",
          "TANKENTAI_SBS":"NOT TESTED/SEALED","HUMAN_ART":"PENDING"}
(ROOT/"T17D_INCREMENTAL_REGRESSION.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
print(exit_status,flush=True)
sys.exit(0 if exit_status=="T17D1_T17D2_REAL_GPU_5_OF_5_PASS" else 2)
