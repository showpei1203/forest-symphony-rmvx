#!/usr/bin/env python3
"""A35 R8 R3 D1: seal six original Godot day/dusk/night frames in private Drive.

Evidence-only ZIP; full playable Godot project remains immutable in earlier
FS_A35_R8_R3_GROVE_NATIVE_QA_PRIVATE_20261116.zip on owner-only Drive.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image
FULL="FS_A35_R8_R3_GROVE_NATIVE_QA_PRIVATE_20261116.zip"
FINAL="FS_A35_R8_R3_D1_DAYCYCLE_NATIVE_EVIDENCE_PRIVATE_20261116.zip"
PHASES=("DAY","DUSK","NIGHT")
def sha(b):return hashlib.sha256(b).hexdigest()
def readlog(p):
    raw=p.read_bytes()
    if raw.startswith((b"\xff\xfe",b"\xfe\xff")):
        return raw.decode("utf-16",errors="replace")
    return raw.decode("utf-8-sig",errors="replace")
def build(root:Path,work:Path):
    full=root/FULL
    fullsha=sha(full.read_bytes())
    if fullsha!="1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830":
        raise ValueError("Previous sealed R8 R3 full project SHA mismatch")
    qa_path=work/"godot_project"/"qa_a35"/"A35_R8_R3_D1_DAYCYCLE_GPU_QA.json"
    report=json.loads(qa_path.read_text(encoding="utf-8"))
    if report["phase_gate"]!="PASS" or any(report["phase_results"][p]["GATE"]!="PASS" for p in PHASES):
        raise RuntimeError("Not all 3 phases passed GPU QA")
    log=readlog(work/"R3_D1_GPU_STDOUT.log")
    if "A35 R8 R3 D1 all 6 original Godot day/dusk/night OFF/ON GPU frames PASS" not in log:
        raise RuntimeError("Official Godot D1 original frames not verified")
    files={
      "README.md":(
        "# FS A35 R8 R3 D1 | Original Godot day/dusk/night evidence\n\n"
        "Evidence only, NOT a standalone Godot project. Full original R8 R3 native ZIP stays in private Google Drive.\n"
        "References exact full source archive SHA256 "+fullsha+". Six ORIGINAL Godot 4.7.2 GPU frames included.\n"
        "Derived six-way illustration is a CONTACT SHEET, not one original game frame.\n"
        "No private PNG assets committed to public GitHub.\n"
      ).encode(),
      "qa/A35_R8_R3_D1_DAYCYCLE_GPU_QA.json":qa_path.read_bytes(),
      "qa/R3_D1_GODOT_GPU_STDOUT.log":log.encode("utf-8"),
      "source/capture_a35_r8_r3_daycycle_native.gd":(work/"godot_project"/"tests"/"capture_a35_r8_r3_daycycle_native.gd").read_bytes(),
      "source/a35_r8_r3_daycycle_qa.py":(work/"a35_r8_r3_daycycle_qa.py").read_bytes()
    }
    names=[]
    for phase in PHASES:
        for state in ("GROVE_OFF","GROVE_ON"):
            name="A35_R8_R3_D1_"+phase+"_"+state+"_NATIVE.png"
            file=work/"godot_project"/"qa_a35"/name
            with Image.open(file) as img:
                if img.size!=(1280,928):raise ValueError("Not native frame size "+name)
            files["original_Godot_GPU/"+name]=file.read_bytes()
            names.append(name)
    contact=work/"A35_R8_R3_D1_DERIVED_DAYCYCLE_6WAY.png"
    files["DERIVED_not_original/"+contact.name]=contact.read_bytes()
    manifest={
      "engine":"Godot 4.7.2 official RX 6700 XT OpenGL 3.3",
      "full_project_archive":FULL,
      "full_project_sha256":fullsha,
      "native_screenshots":names,
      "phase_results":report["phase_results"],
      "art":"HOLD; only tested fixed scene day/dusk/night no rain",
      "cloud":"owner-only Google Drive, private"
    }
    files["EVIDENCE_MANIFEST.json"]=(json.dumps(manifest,indent=2)+"\n").encode()
    out=root/FINAL
    with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p,b in files.items():z.writestr(p,b)
    with zipfile.ZipFile(out) as z:
        if z.testzip() is not None:raise ValueError("D1 final evidence ZIP CRC FAIL")
    print(json.dumps({
       "file":str(out),"members":len(files),"bytes":out.stat().st_size,
       "sha256":sha(out.read_bytes()),"phase_results":report["phase_results"]},
       ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--root",required=True);p.add_argument("--work",required=True)
    a=p.parse_args();build(Path(a.root),Path(a.work))
