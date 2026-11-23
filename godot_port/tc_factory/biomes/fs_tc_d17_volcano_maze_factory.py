#!/usr/bin/env python3
"""FS T-C D17: original 1x Ground-only scene -> separate CompletePAR stage.

Actual art: Ground generated independently with no 3-D scenery and cropped
without interpolation at the SAME 1x scale. PAR uses D15 independently drawn
non-ground source and existing D16 make_par compositor with fixed repositioned
placements. Its pre-existing polygon trims remain an ART HOLD, not hidden.
No source is reverse-extracted from a mixed Master. No files overwritten.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image
from scipy.ndimage import label
import numpy as np

import fs_tc_d16_volcano_maze_factory as legacy

SCENE='FS_04_MAZE'
ORIGINAL_SIZE=(1474,1067)
TARGET_SIZE=(1280,928)
CROP=(90,70,1370,998)
PAR_SOURCE_SIZE=(1474,1067)
DEFAULT_D15_SHA=legacy.D15_PAR_SHA

# Objects are moved as one 1x group each. No object is resized to fit.
POSITIONS={
 'smithy_hut':(45,65),
 'iron_chasm_bridge':(740,320),
 'southern_foundry':(200,490),
 'lava_crane':(475,60),
 'metal_lamp':(530,355),
 'forgebanner':(690,90),
}
# Visual-only footpoint probes, used as a coarse warning, not art certification.
ANCHORS={
 'smithy_hut':(230,265), 'iron_chasm_bridge':(800,465),
 'southern_foundry':(450,825),'lava_crane':(570,270),
 'metal_lamp':(588,480), 'forgebanner':(726,276),
}


def digest(path:Path)->str:
    h=hashlib.sha256()
    with Path(path).open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
    return h.hexdigest()


def generate(ground_source:Path,independent_par_source:Path,out:Path,
             ground_sha:str,par_sha:str=DEFAULT_D15_SHA)->dict:
    ground_source,independent_par_source,out=map(Path,(ground_source,independent_par_source,out))
    if ground_source.resolve()==independent_par_source.resolve():
        raise ValueError('Must use independent Ground-only and non-ground PAR source files')
    if not ground_source.is_file() or not independent_par_source.is_file():
        raise FileNotFoundError('Source images must be present')
    if digest(ground_source)!=ground_sha.lower() or digest(independent_par_source)!=par_sha.lower():
        raise ValueError('SOURCE_SHA_LOCK_FAILURE')
    if out.exists() and any(out.iterdir()):
        raise ValueError('Output must be a NEW empty directory: originals immutable')
    with Image.open(ground_source) as src:
        if src.size!=ORIGINAL_SIZE or src.mode!='RGB':
            raise ValueError('Original Ground-only must be opaque RGB 1474x1067')
        # One-to-one crop, not interpolation, resizing or a mix with Master.
        g=src.crop(CROP)
        if g.size!=TARGET_SIZE or not np.array_equal(
            np.asarray(g),np.asarray(src)[CROP[1]:CROP[3],CROP[0]:CROP[2]]):
            raise ValueError('GROUND_PIXEL_IDENTITY_FAILURE')
    out.mkdir(parents=True,exist_ok=True)
    gp=out/'GROUND.png';g.save(gp,optimize=True)
    lock={
       'scene_id':SCENE,'stage':'GROUND_FIRST_LOCK_BEFORE_PAR',
       'source_ground_only_sha256':digest(ground_source),
       'source_ground_size':list(ORIGINAL_SIZE),'crop_same_1x_pixel_coordinates':list(CROP),
       'target_native_40x29':[1280,928],'output_ground_sha256':digest(gp),
       'resampling':'NONE','par_at_this_stage':'NOT_BUILT',
       'ground_authored_only_ground_surfaces':'VISUAL_INSPECTION_REQUIRED',
       'formal_ART_GATE':'HOLD'}
    (out/'01_GROUND_LOCK.json').write_text(json.dumps(lock,ensure_ascii=False,indent=2)+'\n')
    if (out/'PAR.png').exists():raise AssertionError('PAR may not predate Ground lock')
    with Image.open(independent_par_source) as src:
        if src.size!=PAR_SOURCE_SIZE or src.mode!='RGBA':
            raise ValueError('Independent D15 PAR source needs exact RGBA 1474x1067')
        old=legacy.PROP_PLACEMENTS
        try:
            legacy.PROP_PLACEMENTS=[(n,roi,POSITIONS[n],polygon)
                for n,roi,_,polygon in old]
            par,ledger=legacy.make_par(src)
        finally:
            legacy.PROP_PLACEMENTS=old
    if par.size!=TARGET_SIZE or par.mode!='RGBA':
        raise ValueError('CompletePAR wrong world size or alpha format')
    if sorted(x['name'] for x in ledger)!=sorted(POSITIONS):
        raise ValueError('PAR missing scene object families')
    pp=out/'PAR.png';par.save(pp,optimize=True)
    cp=out/'COMPOSITE_QA.png'
    Image.alpha_composite(g.convert('RGBA'),par).save(cp,optimize=True)
    ah=np.bincount(np.asarray(par.getchannel('A')).ravel(),minlength=256)
    # This flag reports any candidate obvious lava under an anchor, but cannot
    # establish game walkability or physically correct art contact points.
    ground_rgb=np.asarray(g)
    anchors=[]
    for name,(x,y) in ANCHORS.items():
        r,green,b=(int(c) for c in ground_rgb[y,x]);lava=(r>170 and r>green*1.55 and b<115)
        anchors.append({'name':name,'world_pixel':[x,y],
            'ground_rgb':[r,green,b],'lava_color_warning_only':lava})
    report={
      'scene_id':SCENE,'biome':'CRIMSON_VOLCANO','scene_name':'熔脈裂橋',
      'source_Ground_only_sha256':digest(ground_source),
      'source_D15_independent_non_ground_sha256':digest(independent_par_source),
      'ground_sha256':digest(gp),'PAR_sha256':digest(pp),
      'composite_sha256':digest(cp),'native_world':[1280,928],'tiles':[40,29],
      'ground_mode':'RGB','par_mode':'RGBA',
      'source_ground_cropped_without_scaling':True,
      'PAR_staged_1x_without_scaling':True,'mixed_master_reverse_extraction':False,
      'ground_locked_before_par':True,
      'par_object_groups':ledger,'ground_anchor_coarse_checks':anchors,
      'alpha':{'zero':int(ah[0]),'low_1_to_8':int(ah[1:9].sum()),
               'mid_9_to_239':int(ah[9:240].sum()),
               'high_240_to_254':int(ah[240:255].sum()),'full_255':int(ah[255])},
      'object_polygon_trims_remain':int(sum(x['trimmed_pixels'] for x in ledger)),
      'art_gate':'HOLD_VISIBLE_SOURCE_POLYGON_CLIPS_AND_FOOTPOINT_ALIGNMENT',
      'godot_4_7_2_private_native':'NOT_RUN',
      'integration':'NOT_RUN', 'formal_art_pass':'0_OF_12_HOLD',
      'contract_result':'STRUCTURE_PASS_NOT_ART_PASS',
    }
    (out/'D17_PAIR_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--ground-source',type=Path,required=True)
    p.add_argument('--par-source',type=Path,required=True)
    p.add_argument('--ground-sha256',required=True)
    p.add_argument('--par-sha256',default=DEFAULT_D15_SHA)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    x=generate(a.ground_source,a.par_source,a.out,a.ground_sha256,a.par_sha256)
    print(json.dumps({'scene_id':x['scene_id'],'ground':x['ground_sha256'],
         'par':x['PAR_sha256'],'transparent':x['alpha']['zero'],
         'art':'HOLD','godot':'NOT_RUN'}))
