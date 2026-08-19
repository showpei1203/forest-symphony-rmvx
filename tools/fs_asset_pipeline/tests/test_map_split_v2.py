#!/usr/bin/env python3
from __future__ import annotations
import json, sys, tempfile
from pathlib import Path
from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "validator"))
import validate_map_split_v2 as v


def make_scene(root: Path, missing_par: bool = False):
    size = (32, 32)
    ground = Image.new("RGBA", size, (60, 120, 60, 255))
    master = ground.copy()
    ImageDraw.Draw(master).rectangle((10, 8, 21, 23), fill=(180, 80, 60, 255))
    par = Image.new("RGBA", size, (0, 0, 0, 0))
    if not missing_par:
        ImageDraw.Draw(par).rectangle((10, 8, 21, 23), fill=(180, 80, 60, 255))
    master.save(root / "master.png"); ground.save(root / "ground.png"); par.save(root / "par.png")
    manifest = {
      "schema":"fs_map_par_witness_v2", "canvas":[32,32],
      "defaults":{"require_visual_confirmation":True,"radius":2,"min_coverage_ratio":0.08},
      "thresholds":{"recomposition_bad_ratio_max":0.02,"recomposition_mean_abs_rgb_max":4.0},
      "objects":[{"id":"K01","label":"Synthetic Structure","visual_confirmed":True,
                  "witnesses":[{"x":15,"y":15,"role":"wall","visual_confirmed":True}]}]
    }
    w = root / "witness.json"; w.write_text(json.dumps(manifest), encoding="utf-8")
    return root/"master.png", root/"ground.png", root/"par.png", w


def test_pass_exact_recomposition_and_witness():
    with tempfile.TemporaryDirectory() as td:
        root=Path(td); m,g,p,w=make_scene(root)
        report=v.validate(m,g,p,w,root/"out")
        assert report["status"] in (v.STATUS_PASS,v.STATUS_WARN),report
        assert report["metrics"]["witness"]["object_fail"]==0
        assert report["metrics"]["recomposition"]["bad_ratio"]==0


def test_missing_par_fails_witness_and_recomposition():
    with tempfile.TemporaryDirectory() as td:
        root=Path(td); m,g,p,w=make_scene(root,True)
        report=v.validate(m,g,p,w,root/"out")
        codes={x["code"] for x in report["failures"]}
        assert report["status"]==v.STATUS_FAIL
        assert "FAIL_PAR_WITNESS_MISSING" in codes
        assert "FAIL_RECOMPOSITION_DIVERGENCE" in codes


def test_unconfirmed_witness_cannot_formal_pass():
    with tempfile.TemporaryDirectory() as td:
        root=Path(td); m,g,p,w=make_scene(root)
        manifest=json.loads(w.read_text()); manifest["objects"][0]["visual_confirmed"]=False
        manifest["objects"][0]["witnesses"][0]["visual_confirmed"]=False
        w.write_text(json.dumps(manifest))
        report=v.validate(m,g,p,w,root/"out")
        assert report["status"]==v.STATUS_FAIL
        assert any(x["code"]=="FAIL_WITNESS_NOT_VISUAL_CONFIRMED" for x in report["failures"])


def test_low_whole_sam2_overlap_is_evidence_only_not_gate():
    with tempfile.TemporaryDirectory() as td:
        root=Path(td); m,g,p,w=make_scene(root)
        md=root/"masks"; md.mkdir(); Image.new("RGBA",(32,32),(255,255,255,255)).save(md/"K01.png")
        audit={"asset_id":"synthetic","width":32,"height":32,"objects":[{"id":"K01","label":"Synthetic","box":[0,0,32,32],"mask_file":"K01.png","mask_pixels":1024}]}
        ap=root/"audit.json"; ap.write_text(json.dumps(audit))
        report=v.validate(m,g,p,w,root/"out",ap,md)
        assert report["status"] in (v.STATUS_PASS,v.STATUS_WARN),report
        ratio=report["sam2_evidence"]["objects"][0]["par_overlap_ratio_evidence_only"]
        assert ratio < 0.80
        assert not any(x["code"].startswith("FAIL") and "SAM2" in x["code"] for x in report["failures"])


def test_canvas_mismatch_fails():
    with tempfile.TemporaryDirectory() as td:
        root=Path(td); m,g,p,w=make_scene(root)
        Image.new("RGBA",(31,32),(0,0,0,0)).save(p)
        report=v.validate(m,g,p,w,root/"out")
        assert report["status"]==v.STATUS_FAIL
        assert any(x["code"]=="FAIL_PAR_CANVAS_MISMATCH" for x in report["failures"])

if __name__ == "__main__":
    tests=[name for name in globals() if name.startswith("test_")]
    for name in sorted(tests): globals()[name](); print("PASS",name)
    print(f"SUMMARY {len(tests)}/{len(tests)} PASS")
