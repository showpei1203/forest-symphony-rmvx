"""A42 cloud-only private ZIP cold rebuild and real GPU QA. Never uses E: as artifact output."""
from pathlib import Path
import hashlib, shutil, zipfile, json, subprocess
ROOT=Path(__file__).resolve().parent.parent
PARENT=ROOT.parent
COLD=PARENT/"FS_A42_COLD_VERIFY_TEMP"
TEMPZIP=PARENT/"FS_A42_COLD_SOURCE_TEMP.zip"
FINAL=PARENT/"FS_A42_GODOT_LAYERS_HITSTOP_FINAL_20261114.zip"
GODOT=Path("E:/Godot/4.7.2/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe")
assert ROOT.drive.lower()=="g:" and GODOT.is_file()
assert not COLD.exists(),"Do not reuse or delete other cold-test folders"
def archive(dst):
    entries=[]
    with zipfile.ZipFile(dst,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for p in sorted(ROOT.rglob("*")):
            if not p.is_file():continue
            relative=p.relative_to(ROOT)
            if ".godot" in relative.parts or "__pycache__" in relative.parts:continue
            if p.suffix in (".import",".uid"):continue
            if relative.as_posix()=="qa/A42_FINAL_PACKAGING_QA.json":continue
            z.write(p,relative.as_posix())
            entries.append(relative.as_posix())
    with zipfile.ZipFile(dst) as z:
        assert z.testzip() is None
        assert set(z.namelist())==set(entries)
    return entries
members=archive(TEMPZIP)
imported=None;gpu=None
try:
    COLD.mkdir()
    with zipfile.ZipFile(TEMPZIP) as z:z.extractall(COLD)
    for rel in members:
        a=hashlib.sha256((ROOT/rel).read_bytes()).digest()
        b=hashlib.sha256((COLD/rel).read_bytes()).digest()
        assert a==b,rel
    imported=subprocess.run([str(GODOT),"--headless","--path",str(COLD),"--editor","--import","--quit"],
                            capture_output=True,text=True,errors="replace",timeout=120)
    (ROOT/"qa/A42_COLD_EDITOR_IMPORT.log").write_text(imported.stdout+"\n"+imported.stderr+"\nEXIT="+str(imported.returncode),"utf-8")
    assert imported.returncode==0,"COLD GODOT EDITOR FAILED"
    gpu=subprocess.run([str(GODOT),"--path",str(COLD),"--script","res://qa/a42_native_gpu_runtime_qa.gd",
                        "--rendering-method","gl_compatibility","--resolution","1024x720"],
                       capture_output=True,text=True,errors="replace",timeout=120)
    (ROOT/"qa/A42_COLD_REAL_GPU.log").write_text(gpu.stdout+"\n"+gpu.stderr+"\nEXIT="+str(gpu.returncode),"utf-8")
    assert gpu.returncode==0 and "A42_REAL_GPU_RUNTIME_PASS" in gpu.stdout,"COLD GODOT GPU FAILED"
    assert "A42_GPU_RGBA_DIFFS=[0,0,0,0,0,0,0,0,0,0,0,0]" in gpu.stdout
    print("A42_COLD_EDITOR_EXIT",imported.returncode)
    print("A42_COLD_GPU_EXIT",gpu.returncode)
finally:
    if COLD.exists():shutil.rmtree(COLD)
    if TEMPZIP.exists():TEMPZIP.unlink()
entries=archive(FINAL)
result={"stage":"A42","date":"2026-11-14","final_zip":FINAL.name,
        "file_count":len(entries),"size_bytes":FINAL.stat().st_size,
        "sha256":hashlib.sha256(FINAL.read_bytes()).hexdigest(),
        "crc":"PASS","cold_each_file_sha256":"PASS",
        "cold_godot_editor_exit":imported.returncode if imported else -1,
        "cold_native_gpu_exit":gpu.returncode if gpu else -1,
        "gpu_12_frames_rgba_changed_pixels":[0]*12,
        "art_gate":"HOLD","formal_FS_combat_gate":"NOT_RUN"}
(ROOT/"qa/A42_FINAL_PACKAGING_QA.json").write_text(json.dumps(result,indent=2,ensure_ascii=False),"utf-8")
print("A42_PRIVATE_CLOUD_FINAL",json.dumps(result,ensure_ascii=False))