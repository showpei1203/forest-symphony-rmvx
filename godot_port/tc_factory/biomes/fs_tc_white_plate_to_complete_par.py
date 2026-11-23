#!/usr/bin/env python3
"""T-C D14: deterministic connected-white matte from an INDEPENDENT all-PAR plate.

Contract: Source must depict the whole collection of non-ground objects only,
on a white canvas. This is NOT extraction from Ground+objects Master and may
never be used as such. It cannot create objects or align to Ground for the artist.

Outputs the *original-sized* RGBA first. Any resampled 40x29 composite is
technical preview ONLY, not an approved native 1x authoring file.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import numpy as np
from PIL import Image
from scipy.ndimage import binary_propagation, binary_dilation, label


def sha(path: Path) -> str:
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def alpha_counts(alpha: Image.Image) -> dict:
    h = alpha.histogram()
    return {
        "alpha_zero": h[0], "alpha_1_to_8": sum(h[1:9]),
        "alpha_9_to_239": sum(h[9:240]),
        "alpha_240_to_254": sum(h[240:255]), "alpha_255": h[255],
    }


def convert(
    ground_path: Path, plate_path: Path, out: Path, expected_ground_sha: str,
    scene_id: str="FS_04_VILLAGE", make_technical_preview: bool=False,
    repair_large_enclosed_background: bool=False,
) -> dict:
    ground_path, plate_path, out = map(Path, (ground_path, plate_path, out))
    if ground_path.resolve() == plate_path.resolve():
        raise ValueError("Ground and non-ground plate cannot share a source file")
    if sha(ground_path) != expected_ground_sha.lower():
        raise ValueError("Ground source SHA lock mismatch")
    with Image.open(ground_path) as gsrc, Image.open(plate_path) as source:
        if gsrc.mode != "RGB" or source.mode != "RGB":
            raise ValueError("Opaque Ground and independent RGB white plate required")
        ground, rgb = gsrc.convert("RGBA"), np.asarray(source).copy()
        gs, ps = gsrc.size, source.size
    if gs != (1280,928):
        raise ValueError("FS_04_VILLAGE Ground must remain 1280x928")
    low = rgb.min(axis=2).astype("int16")
    high = rgb.max(axis=2).astype("int16")
    near_white = (low>=231) & ((high-low)<=30)
    if float(near_white.mean()) < 0.25:
        raise ValueError("REJECT full opaque Master / nonwhite background")
    edge = np.zeros(near_white.shape, dtype=bool)
    edge[0,:] = near_white[0,:]
    edge[-1,:] = near_white[-1,:]
    edge[:,0] = near_white[:,0]
    edge[:,-1] = near_white[:,-1]
    for y,x in ((0,0),(0,-1),(-1,0),(-1,-1)):
        if not near_white[y,x]:
            raise ValueError("REJECT plate with opaque corner; no reliably white outside")
    connected_white = binary_propagation(edge, mask=near_white)
    # D15: large all-white islands enclosed by railings or arch supports
    # are still BACKGROUND. Keep small enclosed white highlights unchanged.
    # This operates ONLY on independent non-ground RGB plates, never Masters.
    removed_islands = []
    enclosed_white = np.zeros(low.shape, dtype=bool)
    repaired_fringe = np.zeros(low.shape, dtype=bool)
    if repair_large_enclosed_background:
        islands, count = label(near_white & ~connected_white)
        sizes = np.bincount(islands.ravel())
        weights = np.bincount(islands.ravel(), weights=low.ravel())
        chosen = [i for i in range(1, count + 1)
                  if sizes[i] >= 800 and weights[i] / sizes[i] >= 247]
        enclosed_white = np.isin(islands, chosen)
        removed_islands = [int(sizes[i]) for i in chosen]
        # The few surrounding white antialias fringe pixels are not props.
        # Unmatte these only when directly neighboring a large white void.
        repaired_fringe = (binary_dilation(enclosed_white, iterations=3)
                           & ~enclosed_white & (low >= 215)
                           & ((high - low) <= 38))
    alpha = np.full(low.shape, 255, dtype=np.uint8)
    fraction = np.clip((245-low)/14.0,0.0,1.0)
    alpha[connected_white] = np.round(255*fraction[connected_white]).astype(np.uint8)
    alpha[connected_white & (low>=245)] = 0
    if repair_large_enclosed_background:
        alpha[enclosed_white] = 0
        ramp = np.clip((245.0 - low.astype(np.float32)) / 22.0, 0, 1)
        alpha[repaired_fringe] = np.minimum(
            alpha[repaired_fringe],
            np.round(255.0 * ramp[repaired_fringe]).astype(np.uint8))
    visible = int(np.count_nonzero(alpha>224))
    zeros = int(np.count_nonzero(alpha==0))
    if zeros < alpha.size // 4 or visible < alpha.size // 100:
        raise ValueError("REJECT almost blank/full Master: not a genuine foreground plate")
    rgba = np.empty((rgb.shape[0],rgb.shape[1],4),dtype=np.uint8)
    rgba[:,:,:3] = rgb
    rgba[:,:,3] = alpha
    # Decontaminate antialias fringes of known white background, never props.
    a = alpha.astype(np.float32)/255.0
    fringe = (connected_white | repaired_fringe) & (a>0.0) & (a<1.0)
    if np.any(fringe):
        af = a[fringe,None]
        colors = np.asarray(rgb[fringe],dtype=np.float32)
        premult = np.clip((colors - (1.0-af)*254.0)/af,0,255)
        rgba[:,:,:3][fringe] = np.uint8(np.round(premult))
    result = Image.fromarray(rgba, "RGBA")
    out.mkdir(parents=True, exist_ok=True)
    dest = out / "PAR_ALL_NON_GROUND_WHITE_KEY_SOURCE_NATIVE_SIZE.png"
    if dest.resolve() in (ground_path.resolve(),plate_path.resolve()):
        raise ValueError("Never overwrite locked original inputs")
    result.save(dest)
    report = {
        "scene_id":scene_id, "pipeline":"independent_white_foreground_plate_to_RGBA",
        "source_RGB_sha256":sha(plate_path), "ground_RGB_SHA_LOCK":sha(ground_path),
        "source_size":[ps[0],ps[1]],"ground_size":[gs[0],gs[1]],
        "output_par_native_source_size":[ps[0],ps[1]],
        "par_sha256":sha(dest),"alpha":alpha_counts(result.getchannel("A")),
        "original_native_1280x928": ps == gs,
        "matte_only_border_connected_white":not repair_large_enclosed_background,
        "D15_large_enclosed_white_background_repair": repair_large_enclosed_background,
        "D15_enclosed_background_islands_removed": len(removed_islands),
        "D15_enclosed_island_area_pixels": removed_islands,
        "D15_guard_small_enclosed_white_details": True,
        "ground_not_subtracted_or_reverse_cut":True,
        "semantic_world_registration":"HUMAN_REVIEW_REQUIRED",
        "Godot_4_7_2_native":"NOT_RUN",
        "formal_ART_GATE":"HOLD",
    }
    if make_technical_preview:
        if ps != gs:
            scaled = result.resize(gs, Image.Resampling.LANCZOS)
            assert scaled.size == gs
            preview_par = out / "PAR_RESAMPLED_TECH_ONLY_NOT_NATIVE_1X.png"
            scaled.save(preview_par)
            report["resampled_source_not_native_1x"] = True
            report["resampled_par_sha256"] = sha(preview_par)
        else:
            scaled = result
            report["resampled_source_not_native_1x"] = False
        preview = out / "GROUND_PLUS_PAR_PREVIEW_ONLY.png"
        Image.alpha_composite(ground, scaled).save(preview)
        report["preview_sha256"] = sha(preview)
    (out/"D14_WHITE_PLATE_QA.json").write_text(
        json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    return report


if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--ground",type=Path,required=True)
    ap.add_argument("--plate",type=Path,required=True)
    ap.add_argument("--out",type=Path,required=True)
    ap.add_argument("--ground-sha256",required=True)
    ap.add_argument("--scene-id",default="FS_04_VILLAGE")
    ap.add_argument("--technical-preview",action="store_true")
    ap.add_argument("--repair-large-enclosed-background", action="store_true")
    a=ap.parse_args()
    print(json.dumps(convert(
        a.ground,a.plate,a.out,a.ground_sha256,
        scene_id=a.scene_id,make_technical_preview=a.technical_preview,
        repair_large_enclosed_background=a.repair_large_enclosed_background),ensure_ascii=False))
