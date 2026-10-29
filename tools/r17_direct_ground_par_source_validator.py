#!/usr/bin/env python3
"""R17 direct Ground/PAR provenance and pixel checks. Never declares art/formal PASS.

Usage:
  python tools/r17_direct_ground_par_source_validator.py \
    --ground GROUND.png --par PAR.png --manifest pair_source_manifest.json \
    --report r17_pair_audit.json

Requires: pip install Pillow
The manifest is a *declaration*, not independent proof of how imagery was made.
No script can infer source-first provenance or artistic quality from pixel-diff=0.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    raise SystemExit("Pillow is required: python -m pip install Pillow")

ALLOWED_METHODS = {
    "ground": {"direct_ground", "godot_layer_source", "tiled_layer_source", "source_sprite_composition"},
    "par": {"direct_par", "godot_layer_source", "tiled_layer_source", "source_sprite_composition"},
}
KNOWN_CANVASES = {(544, 416), (1280, 928)}
BANNED_TERMS = ("master_first", "master-first", "prebaked", "pre_baked",
                "inpaint", "sam2", "grabcut", "segmentation", "extract_from_master")


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def check_pair(ground_path, par_path, manifest_path):
    errors, warnings = [], []
    values = {
        "ground_layer": "HOLD",
        "par_layer": "HOLD",
        "pair_alignment": "HOLD",
        "visual_art": "HOLD_REQUIRES_HUMAN",
        "source_provenance": "UNVERIFIED",
        "formal_seal": "NO",
    }
    report = {"schema": "R17_DIRECT_SOURCE_GATE_V1", "status": "FAIL_CLOSED",
              "checks": values, "errors": errors, "warnings": warnings,
              "metrics": {}, "source_paths": {
                  "ground": str(ground_path), "par": str(par_path),
                  "manifest": str(manifest_path)}}
    try:
        manifest = json.loads(Path(manifest_path).read_text(encoding="utf-8"))
        assert isinstance(manifest, dict), "Manifest must be an object"
    except (OSError, ValueError, AssertionError) as exc:
        errors.append("MISSING_OR_INVALID_MANIFEST: " + str(exc))
        return report

    if manifest.get("source_mode") != "independent_direct_layers":
        errors.append("PROVENANCE_FAIL: source_mode must be independent_direct_layers")
    refs = {}
    actual_hashes = {}
    for role, image_path in (("ground", ground_path), ("par", par_path)):
        source = manifest.get(role)
        if not isinstance(source, dict):
            errors.append("MISSING_SOURCE_RECORD: " + role)
            continue
        refs[role] = source
        source_id = source.get("source_artifact_id")
        if not isinstance(source_id, str) or not source_id.strip():
            errors.append("MISSING_SOURCE_ID: " + role)
        method = source.get("creation_method")
        if method not in ALLOWED_METHODS[role]:
            errors.append("UNACCEPTABLE_CREATION_METHOD: " + role + " " + str(method))
        lineage = json.dumps(source, ensure_ascii=False).lower()
        if any(term in lineage for term in BANNED_TERMS):
            errors.append("REVERSE_SPLIT_LINEAGE: " + role)
        for key in ("scene_blueprint_id", "style_lock_id", "world_origin_xy"):
            if key not in source:
                errors.append("MISSING_" + key.upper() + ": " + role)
        if source.get("world_origin_xy") != [0, 0]:
            errors.append("WORLD_ORIGIN_MUST_BE_0_0: " + role)
        try:
            actual_hashes[role] = sha256(image_path)
            if source.get("sha256") != actual_hashes[role]:
                errors.append("SOURCE_SHA256_MISMATCH: " + role)
        except OSError as exc:
            errors.append("IMAGE_READ_FAIL: " + role + " " + str(exc))

    if len(refs) == 2:
        if refs["ground"].get("source_artifact_id") == refs["par"].get("source_artifact_id"):
            errors.append("SAME_SOURCE_ARTIFACT_ID")
        for field in ("scene_blueprint_id", "style_lock_id", "world_origin_xy"):
            if refs["ground"].get(field) != refs["par"].get(field):
                errors.append("PAIR_METADATA_MISMATCH: " + field)
    if len(actual_hashes) == 2 and actual_hashes["ground"] == actual_hashes["par"]:
        errors.append("IDENTICAL_GROUND_AND_PAR_FILES")

    images = {}
    for role, image_path in (("ground", ground_path), ("par", par_path)):
        try:
            with Image.open(image_path) as im:
                if im.format != "PNG":
                    errors.append("NOT_PNG: " + role)
                if role == "par" and im.mode != "RGBA":
                    errors.append("PAR_NOT_NATIVE_RGBA: " + im.mode)
                if role == "ground" and im.mode not in ("RGB", "RGBA"):
                    errors.append("GROUND_NOT_RGB_OR_RGBA: " + im.mode)
                images[role] = im.copy()
        except (OSError, ValueError) as exc:
            errors.append("INVALID_IMAGE: " + role + " " + str(exc))
    if len(images) == 2:
        g, p = images["ground"], images["par"]
        gw, gh = g.size
        pw, ph = p.size
        report["metrics"]["ground_size"] = [gw, gh]
        report["metrics"]["par_size"] = [pw, ph]
        if (gw, gh) != (pw, ph):
            errors.append("DIMENSION_MISMATCH")
        if (gw, gh) not in KNOWN_CANVASES:
            errors.append("CANVAS_NOT_R17_BENCHMARK_OR_FINAL_SIZE")
        if g.mode in ("RGB", "RGBA"):
            if g.mode == "RGBA":
                g_min, _ = g.getchannel("A").getextrema()
                if g_min != 255:
                    errors.append("GROUND_MUST_BE_FULLY_OPAQUE")
        if p.mode == "RGBA":
            alpha_hist = p.getchannel("A").histogram()
            clear = alpha_hist[0]
            partial = sum(alpha_hist[1:255])
            nonzero = sum(alpha_hist[1:])
            report["metrics"].update({
                "par_alpha_zero_pixels": clear,
                "par_alpha_nonzero_pixels": nonzero,
                "par_alpha_partial_pixels": partial,
            })
            if clear == 0 or nonzero == 0:
                errors.append("PAR_MUST_HAVE_REAL_TRANSPARENT_AND_VISIBLE_PIXELS")
            if partial:
                warnings.append("PARTIAL_ALPHA_NEEDS_EDGE_REVIEW: " + str(partial))
        else:
            errors.append("PAR_CANNOT_BE_VALIDATED_WITHOUT_RGBA")

    warnings.extend([
        "PROVENANCE_DECLARATION_NOT_INDEPENDENTLY_AUTHENTICATED",
        "HUMAN_VISUAL_REVIEW_REQUIRED: Ground detail, objects, occlusion purity, foot contact, crisp edges",
        "ZERO_PIXEL_COMPOSITE_DIFF_IS_NOT_EVIDENCE_OF_SOURCE_INDEPENDENCE",
        "DO_NOT_USE_THIS_AS_VX_COLLISION_OR_FORMAL_SEAL",
    ])
    if not errors:
        values["ground_layer"] = "TECH_CHECKED_ART_HOLD"
        values["par_layer"] = "TECH_CHECKED_ART_HOLD"
        values["pair_alignment"] = "METADATA_AND_DIMENSIONS_CHECKED_VISUAL_HOLD"
        values["source_provenance"] = "DECLARED_UNVERIFIED"
        report["status"] = "TECH_CANDIDATE_ONLY_NO_ART_PASS"
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ground", type=Path, required=True)
    parser.add_argument("--par", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    report = check_pair(args.ground, args.par, args.manifest)
    rendered = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered, encoding="utf-8")
    print(rendered)
    return 2 if report["errors"] else 0


if __name__ == "__main__":
    sys.exit(main())
