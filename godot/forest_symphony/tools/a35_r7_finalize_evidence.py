#!/usr/bin/env python3
"""A35 R7 owner-only *compact native evidence* ZIP.

The complete reconstructible map source remains in the R7 source ZIP on private
Drive and in the R6 base + GitHub builder; this lean evidence archive avoids
duplicating >170MB of historically sealed private PNGs. It embeds only actual
Godot GPU shadow OFF/ON images, source/physics/GPU logs and public-code snapshot.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
from PIL import Image

GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
BASE="FS_A35_R7_SHADOW_SOURCE_PRIVATE_20261115.zip"
FINAL="FS_A35_R7_SHADOW_NATIVE_EVIDENCE_PRIVATE_20261115.zip"
CAPTURES=["A35_R7_SHADOW_OFF_NATIVE.png","A35_R7_SHADOW_ON_NATIVE.png"]
LOGS={
"R7_SOURCE_STDOUT.log":"A35 R7 GODOT SOURCE PASS: 187 PAR unchanged, 175 real LightOccluder2D",
"R7_NAV_STDOUT.log":"A35 R7 NATIVE PHYSICAL NAV PASS 8/8",
"R7_GPU_STDOUT.log":"A35 R7 real Godot 2D LightOccluder2D GPU shadow ON/OFF CAPTURE 2/2 PASS"
}
def sha(b):return hashlib.sha256(b).hexdigest()
def readlog(p):
    raw=p.read_bytes()
    if raw.startswith((b"\xff\xfe",b"\xfe\xff")):return raw.decode("utf-16",errors="replace")
    return raw.decode("utf-8-sig",errors="replace")

def seal(root,work):
    project=work/"godot_project"
    source=root/BASE
    with zipfile.ZipFile(source) as z:
        if z.testzip() is not None:raise ValueError("Original R7 full source CRC failed")
        saved={
            "ground":sha(z.read("private_assets/ground_only.png")),
            "R6_scene":sha(z.read("scenes/a35_r6_conifer_hd2d_scene.tscn")),
            "R7_scene":sha(z.read("scenes/a35_r7_shadow_study_scene.tscn"))
        }
        if saved["ground"]!=GROUND:raise ValueError("R7 Ground changed")
        originals={path:z.read(path) for path in [
            "scenes/a35_r7_shadow_study_scene.tscn",
            "scripts/a35_r7_shadow_study.gd",
            "tests/test_a35_r7_native.gd",
            "tests/test_a35_r7_navigation.gd",
            "tests/capture_a35_r7_shadow_native.gd",
            "docs/A35_R7_HANDOFF.md",
            "docs/A35_R7_FAILURE_LOG.md",
            "qa_a35/A35_R7_SOURCE_QA.json"
        ]}
    entries=dict(originals)
    entries["README_ASSEMBLY.txt"]=(
      "Forest Symphony A35 R7 REAL LIGHT SHADOW QA\n"
      "This is a compact evidence package, NOT a standalone full Godot project.\n"
      "The complete reversible R7 project is built from the owner-only sealed R6 project archive\n"
      "using the public-source tools/a35_r7_shadow_build.py and scripts/a35_r7_shadow_study.gd.\n"
      "The full R7 source ZIP is also retained on owner-only Drive under name "+BASE+".\n"
      "This archive retains 2 ORIGINAL Godot GPU screenshots, complete source/nav/render logs,\n"
      "exact sha/CRC checks, QA report and sources. No private raw tree/Ground art exposed publicly.\n"
      "Original R6 scene SHA256: "+saved["R6_scene"]+"\n"
      "Original Ground SHA256: "+GROUND+"\n"
    ).encode()
    for name,expected in LOGS.items():
        message=readlog(work/name)
        if expected not in message:raise ValueError("Missing verified native output: "+name)
        entries["qa_original_godot/"+name]=message.encode("utf-8")
    report=json.loads((project/"qa_a35"/"A35_R7_SHADOW_GPU_PIXEL_QA.json").read_text())
    if (report["tree_light_occluders"]!=175 or report["changed_within_lamp_radius263"]!=17943
       or report["changed_outside_lamp_radius263"]!=0 or not report["shadow_switch_visible"]):
        raise ValueError("R7 shadow pixel proof mismatch")
    entries["qa_original_godot/A35_R7_SHADOW_GPU_PIXEL_QA.json"]=(
        json.dumps(report,indent=2)+"\n").encode()
    for name in CAPTURES:
        path=project/"qa_a35"/name
        with Image.open(path) as img:
            if img.size!=(1280,928):raise ValueError("Native GPU screenshot invalid")
        entries["qa_original_godot/"+name]=path.read_bytes()
    for src in ("a35_r7_shadow_build.py","a35_r7_shadow_qa.py"):
        entries["tools/"+src]=(work/src).read_bytes()
    fullsha=sha(source.read_bytes())
    meta={
        "phase":"A35 R7 real Godot shadow study",
        "source_project_zip":BASE,"source_project_SHA256":fullsha,
        "reference_R6_SHA256":"20411549004f0931517a1016e07e0511ed9c61916e6888999c40fa6bbd0ee2f2",
        "original_integrity":saved,
        "native":"PASS 175 occluders, 187 unchanged PAR, nav 8/8, roads 4/4",
        "original_Godot_GPU":"2/2 1280x928 PASS; 17943 changed pixels inside test light ROI, 0 outside",
        "art":"HOLD: trunks only, study lamp only, no real canopy/full-game HD-2D",
        "publication":"Owner-only Google Drive; no source private PNGs on GitHub"
    }
    entries["QA_RELEASE_MANIFEST.json"]=(json.dumps(meta,ensure_ascii=False,indent=2)+"\n").encode()
    out=root/FINAL
    with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n,b in entries.items():z.writestr(n,b)
    with zipfile.ZipFile(out) as z:
        if z.testzip() is not None:raise ValueError("R7 evidence ZIP CRC failed")
        if z.read("qa_original_godot/"+CAPTURES[0])!=entries["qa_original_godot/"+CAPTURES[0]]:
            raise ValueError("R7 original GPU evidence changed")
    print(json.dumps({"evidence_file":str(out),"members":len(entries),"bytes":out.stat().st_size,
                      "sha256":sha(out.read_bytes()),"reference_full_source_sha256":fullsha,"qa":meta},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--root",required=True);p.add_argument("--work",required=True)
    a=p.parse_args();seal(Path(a.root),Path(a.work))
