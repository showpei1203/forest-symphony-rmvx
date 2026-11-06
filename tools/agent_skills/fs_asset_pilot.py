#!/usr/bin/env python3
"""FS Agent Skills isolated onboarding + baseline QA (never edits source art)."""
from __future__ import annotations
import argparse, hashlib, json, shutil, subprocess, sys
from datetime import datetime, timezone
from pathlib import Path
from PIL import Image, ImageChops, ImageStat

SKILLS = {
    "router": "router",
    "create-game-assets": "skills/disciplines/create-game-assets",
    "procedural-gen": "skills/disciplines/procedural-gen",
    "level-design": "skills/disciplines/level-design",
    "godot-tilemap": "skills/godot/godot-tilemap",
    "godot-gdscript-headless-testing": "skills/godot/godot-gdscript-headless-testing",
    "rpg": "skills/genres/rpg",
}
A36F_NAMES = [
    "A36F_GROUND_GRASS_FLOWERS_ROAD_1280x928.png",
    "A36F_PAR50_RGBA_1280x928.png",
    "A36F_TRUE_GROUND_PLUS_PAR_1280x928.png",
    "A36F_SCENE_MANIFEST.json",
]

def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024*1024), b""):
            h.update(chunk)
    return h.hexdigest()

def call(args: list[str]) -> dict:
    proc = subprocess.run(args, text=True, capture_output=True, check=False, encoding="utf-8", errors="replace")
    return {"command": args, "code": proc.returncode, "stdout": proc.stdout[-18000:], "stderr": proc.stderr[-3000:]}

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--upstream", type=Path, required=True)
    ap.add_argument("--pilot", type=Path, required=True)
    ap.add_argument("--fs-skill", type=Path, required=True)
    ap.add_argument("--a36f", type=Path, required=True)
    ap.add_argument("--pmd", type=Path, required=True)
    args = ap.parse_args()
    upstream, pilot, a36f, pmd = [p.resolve() for p in (args.upstream,args.pilot,args.a36f,args.pmd)]
    if (pilot == a36f or pilot == pmd or a36f in pilot.parents or pmd in pilot.parents
            or pilot in a36f.parents or pilot in pmd.parents):
        raise SystemExit("REFUSED: pilot and protected source directories overlap.")
    if not (upstream/"router"/"SKILL.md").is_file():
        raise SystemExit("REFUSED: upstream skill folders missing.")
    installed = pilot/".agents"/"skills"
    installed.mkdir(parents=True, exist_ok=True)
    outputs = pilot/"outputs"
    outputs.mkdir(exist_ok=True)
    for name, relative in SKILLS.items():
        src = upstream/relative
        if not (src/"SKILL.md").is_file():
            raise SystemExit(f"REFUSED: {name} source missing")
        shutil.copytree(src, installed/name, dirs_exist_ok=True)
    shutil.copy2(args.fs_skill, installed/"fs-rmvx-router"/"SKILL.md") if (installed/"fs-rmvx-router").is_dir() else None
    (installed/"fs-rmvx-router").mkdir(exist_ok=True)
    shutil.copy2(args.fs_skill, installed/"fs-rmvx-router"/"SKILL.md")
    shutil.copy2(upstream/"LICENSE", pilot/"UPSTREAM_APACHE2_LICENSE.txt")
    pin = call(["git","-C",str(upstream),"rev-parse","HEAD"])
    expected_commit="19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9"
    cases: dict[str,dict] = {}
    source_paths = [a36f/n for n in A36F_NAMES]
    pmd_paths = [pmd/f"PMD{monster:04d}_Moving_to_Close_Attack_{frame}.png" for monster in range(1,4) for frame in range(1,4)]
    source_paths.extend(pmd_paths)
    missing = [str(p) for p in source_paths if not p.is_file()]
    if missing:
        raise SystemExit("REFUSED: missing protected source files: " + repr(missing))
    before = {str(p):sha256(p) for p in source_paths}
    reporter=installed/"create-game-assets"/"scripts"/"asset_report.py"
    previewer=installed/"create-game-assets"/"scripts"/"build_preview_sheet.py"
    cases["a36f_ground_size"]=call([sys.executable,str(reporter),str(a36f/A36F_NAMES[0]),"--expect-size","1280x928","--json"])
    cases["a36f_par_alpha_size"]=call([sys.executable,str(reporter),str(a36f/A36F_NAMES[1]),"--expect-size","1280x928","--require-alpha","--json"])
    cases["a36f_master_size"]=call([sys.executable,str(reporter),str(a36f/A36F_NAMES[2]),"--expect-size","1280x928","--json"])
    cases["pmd_frame_alpha"]=call([sys.executable,str(reporter),*[str(p) for p in pmd_paths],"--require-alpha","--json"])
    cases["pmd_contact_sheet"]=call([sys.executable,str(previewer),*[str(p) for p in pmd_paths],"--out",str(outputs/"PMD0001_0003_3FRAME_CONTACT.png"),"--columns","3","--cell-size","192"])
    opaque=outputs/"QA_NEGATIVE_FULLY_OPAQUE_RGBA.png"
    Image.new("RGBA",(16,16),(23,44,55,255)).save(opaque)
    cases["negative_opaque_must_fail"]=call([sys.executable,str(reporter),str(opaque),"--require-alpha","--json"])
    with Image.open(a36f/A36F_NAMES[0]) as a, Image.open(a36f/A36F_NAMES[1]) as b, Image.open(a36f/A36F_NAMES[2]) as c:
        ground, par, master = a.convert("RGBA"), b.convert("RGBA"), c.convert("RGBA")
        recomposed=Image.alpha_composite(ground,par)
        rgb_diff=ImageChops.difference(recomposed.convert("RGB"),master.convert("RGB"))
        stat=ImageStat.Stat(rgb_diff)
        bounds=rgb_diff.getbbox()
        exact=bounds is None
        layers={"ground_mode":a.mode,"par_mode":b.mode,"master_mode":c.mode,
                "canvas_equal":ground.size==par.size==master.size,
                "recompose_exact_RGB":exact,"recompose_mismatch_bbox":list(bounds) if bounds else None,
                "recompose_mean_abs_diff_per_R_G_B":stat.mean}
    pmd_frames: dict[str,dict] = {}
    with_images=[]
    for p in pmd_paths:
        with Image.open(p) as im:
            alpha=im.convert("RGBA").getchannel("A")
            pmd_frames[p.name]={"size":list(im.size),"mode":im.mode,"alpha_extrema":list(alpha.getextrema())}
    for m in range(1,4):
        ident=f"PMD{m:04d}_"
        sizes={tuple(v["size"]) for k,v in pmd_frames.items() if k.startswith(ident)}
        with_images.append({"id":f"PMD{m:04d}","three_frames_found":True,"sizes_match":len(sizes)==1,"frame_sizes":[list(x) for x in sorted(sizes)]})
    with (a36f/A36F_NAMES[3]).open(encoding="utf-8") as f:
        manifest=json.load(f)
    after={str(p):sha256(p) for p in source_paths}
    checks={
        "upstream_pin_matches":pin["code"]==0 and pin["stdout"].strip()==expected_commit,
        "seven_upstream_skills_installed":all((installed/name/"SKILL.md").is_file() for name in SKILLS),
        "fs_override_skill_installed":(installed/"fs-rmvx-router"/"SKILL.md").is_file(),
        "A36F_canvas_size_pass":all(cases[x]["code"]==0 for x in ("a36f_ground_size","a36f_par_alpha_size","a36f_master_size")) and layers["canvas_equal"],
        "A36F_layer_recomposition_exact_RGB":layers["recompose_exact_RGB"],
        "PMD_upstream_asset_report_pass":cases["pmd_frame_alpha"]["code"]==0,
        "PMD_three_frame_geometry_consistent":all(g["sizes_match"] for g in with_images),
        "PMD_contact_sheet_created":cases["pmd_contact_sheet"]["code"]==0 and (outputs/"PMD0001_0003_3FRAME_CONTACT.png").is_file(),
        "negative_full_opaque_rejected":cases["negative_opaque_must_fail"]["code"]!=0,
        "protected_source_SHA_unchanged":before==after,
    }
    result={
      "name":"FS_AGENT_SKILLS_PILOT_20261106",
      "timestamp_utc":datetime.now(timezone.utc).isoformat(),
      "upstream_repository":"https://github.com/gamedev-skills/awesome-gamedev-agent-skills",
      "upstream_commit":pin["stdout"].strip(),"upstream_pinned":expected_commit,
      "installed_skills":list(SKILLS)+["fs-rmvx-router"],
      "protected_baseline":"A36F R1 | ENGINEERING PASS (historical), ART FAIL (historical)",
      "a36f_read_only":True,"pmd_read_only":True,
      "manifest_top_level_keys":list(manifest),
      "layer_recomposition":layers,"pmd_frame_geometry":with_images,"pmd_frames":pmd_frames,
      "checks":checks,
      "technical_metadata_gate":"PASS" if all(checks.values()) else "FAIL",
      "native_vx_executed_in_this_pilot":False,
      "native_godot_executed_in_this_pilot":False,
      "visual_art_approval":"UNVERIFIED",
      "formal_seal":"NO",
      "source_sha256":after,
      "upstream_tool_outputs":cases,
    }
    report=outputs/"FS_AGENT_SKILLS_PILOT_QA.json"
    report.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
    concise={k:v for k,v in result.items() if k in ("technical_metadata_gate","checks","layer_recomposition","pmd_frame_geometry","visual_art_approval","formal_seal")}
    print(json.dumps(concise,ensure_ascii=False,indent=2))
    print("REPORT:",report)
    return 0 if result["technical_metadata_gate"]=="PASS" else 2

if __name__=="__main__":
    raise SystemExit(main())