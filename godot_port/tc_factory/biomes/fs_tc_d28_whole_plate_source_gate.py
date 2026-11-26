#!/usr/bin/env python3
"""FS T-C D28: source-level QA for ONE complete independently generated PAR.

No object segmentation, white-key, mixing, alpha-island rearrangement, inpainting,
upscaling/downscaling of any production output, or fake ART PASS.
Optional QA preview scales the WHOLE SOURCE only, and is labeled NOT PRODUCTION.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image
import numpy as np

GROUND_SHA = '2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e'
CANVAS = (1280, 928)

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        while block := f.read(1024 * 1024):
            h.update(block)
    return h.hexdigest()

def inspect_ground(ground_path: Path) -> dict:
    with Image.open(ground_path) as im:
        size, mode = im.size, im.mode
        a = np.asarray(im.convert('RGBA'), dtype=np.uint8)[:,:,3]
    errors = []
    if size != CANVAS: errors.append('FROZEN_GROUND_CANVAS_MISMATCH')
    if mode not in ('RGB', 'RGBA'): errors.append('GROUND_INVALID_MODE')
    if np.any(a != 255): errors.append('GROUND_NOT_OPAQUE')
    digest = sha256(ground_path)
    if digest != GROUND_SHA: errors.append('FROZEN_GROUND_SHA_MISMATCH')
    return dict(file=ground_path.name, size=size, mode=mode, sha256=digest, errors=errors, valid=(not errors))

def inspect_par(path: Path, *, canvas: tuple[int,int] = CANVAS) -> dict:
    """Fail closed on exact format. Never claim world or art correctness automatically."""
    with Image.open(path) as im:
        mode, size = im.mode, im.size
        rgba = np.asarray(im.convert('RGBA'), dtype=np.uint8)
    a = rgba[:,:,3]
    h,w = a.shape
    target_w,target_h=canvas
    src_visible = a > 32
    x,y = np.where(src_visible)[1],np.where(src_visible)[0]
    bbox = (int(x.min()),int(y.min()),int(x.max()+1),int(y.max()+1)) if len(x) else None
    out_of_frame = int(src_visible[target_h:,:].sum()) if h>target_h else 0
    out_of_frame += int(src_visible[:min(h,target_h),target_w:].sum()) if w>target_w else 0
    errors=[]
    if mode != 'RGBA':errors.append('SOURCE_NOT_TRUE_RGBA_MODE')
    if not (a==0).any():errors.append('SOURCE_NO_TRUE_TRANSPARENT_PIXELS')
    if not src_visible.any():errors.append('SOURCE_NO_VISIBLE_FOREGROUND')
    if size != canvas:errors.append('SOURCE_NOT_EXACT_NATIVE_CANVAS')
    if out_of_frame:errors.append('VISIBLE_PIXELS_OUTSIDE_NATIVE_CANVAS')
    # A PNG cannot prove independent authorship, complete scene content, or visual world coordinates.
    return dict(filename=path.name,sha256=sha256(path),file_bytes=path.stat().st_size,
        source_size=list(size),mode=mode,alpha_zero=int((a==0).sum()),
        alpha_gt32=int(src_visible.sum()),visible_bbox=bbox,
        visible_outside_native_canvas=out_of_frame,
        source_format_gate='PASS' if mode=='RGBA' and (a==0).any() and src_visible.any() else 'FAIL',
        exact_native_canvas_gate='PASS' if not errors else 'FAIL',
        human_authorship_complete_scene_gate='NOT_AUTOMATICALLY_PROVABLE',
        human_ground_alignment_gate='NOT_VERIFIED',human_visual_art_gate='HOLD',
        errors=errors,approved_production_par=False)

def qa_only_whole_canvas_preview(ground: Path,source: Path,output: Path):
    """Diagnostic only. Scale one complete source image (never parts) to Ground size."""
    with Image.open(source) as fg, Image.open(ground) as gg:
        whole = fg.convert('RGBA').resize(CANVAS,Image.Resampling.LANCZOS)
        out = Image.alpha_composite(gg.convert('RGBA'),whole)
        out.convert('RGB').save(output)
    return sha256(output)

def run(ground:Path, par_paths:list[Path], report_path:Path, preview_dir:Path|None=None):
    g=inspect_ground(ground)
    if not g['valid']:raise ValueError('FROZEN_GROUND_REJECTED: '+','.join(g['errors']))
    report={'phase':'D28_ONE_PASS_WHOLE_PAR_ONLY','ground':g,'canvas_required':list(CANVAS),
      'never_use_component_splitting':True,'no_production_resampling':True,
      'one_pass_authorship_must_be_proven_by_generation_log_not_pixels':True,
      'sources':[],'formal_art_pass':'0/12','real_private_godot_native':'NOT_RUN_SOURCE_FAIL'}
    if preview_dir:preview_dir.mkdir(parents=True,exist_ok=True)
    for p in par_paths:
        result=inspect_par(p)
        if preview_dir:
            preview=preview_dir/(p.stem+'_WHOLE_RESAMPLE_QA_ONLY_NOT_A_PAR.png')
            result['qa_only_preview_sha256']=qa_only_whole_canvas_preview(ground,p,preview)
            result['qa_only_preview_name']=preview.name
        report['sources'].append(result)
    report_path.parent.mkdir(parents=True,exist_ok=True)
    report_path.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--ground',type=Path,required=True)
    p.add_argument('--source',type=Path,action='append',required=True)
    p.add_argument('--report',type=Path,required=True)
    p.add_argument('--preview-dir',type=Path)
    a=p.parse_args()
    r=run(a.ground,a.source,a.report,a.preview_dir)
    print(json.dumps({'ground_sha':r['ground']['sha256'],'sources':[
        {'name':s['filename'],'size':s['source_size'],'alpha0':s['alpha_zero'],
         'outside':s['visible_outside_native_canvas'],'native':s['exact_native_canvas_gate']}
        for s in r['sources']],'art':r['formal_art_pass']},ensure_ascii=False,indent=2))
