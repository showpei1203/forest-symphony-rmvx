"""A27 private A21 source replay (run only in isolated private environment)."""
from __future__ import annotations
import argparse
import hashlib
import io
import json
from pathlib import Path
import zipfile

import numpy as np
from PIL import Image, ImageDraw, ImageFont

try:
    from .a27_semantic_depth_occlusion import DepthOwner, render_actor_case, png_bytes
except ImportError:
    from a27_semantic_depth_occlusion import DepthOwner, render_actor_case, png_bytes

A21_SHA = '35a4268baf874c94ac8bd903f362410a8081933fa2d91a324f086908f2008981'
A18_SHA = 'f7a8f83bf30a6d9e1b2d0395c484f3f138b440b086dd1cae68a07ff8e1d3160c'
MASTER_SHA = '091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530'
F0_SHA = 'a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba'


def verify_archive(path: Path, expected: str) -> zipfile.ZipFile:
    if hashlib.sha256(path.read_bytes()).hexdigest() != expected:
        raise ValueError(f'Private input checksum mismatch: {path.name}')
    z = zipfile.ZipFile(path)
    failed = z.testzip()
    if failed:
        raise ValueError(f'ZIP CRC mismatch: {failed}')
    return z


def img(data):
    return Image.open(io.BytesIO(data)).convert('RGBA')


def masked_alpha(data):
    return np.asarray(img(data).getchannel('A')) > 0


def build_owner(object_id, semantic, mask, x_min, x_max, far, near):
    mask_png = png_bytes(Image.fromarray((mask * 255).astype(np.uint8),'L'))
    return DepthOwner(object_id,semantic,mask_png,hashlib.sha256(mask_png).hexdigest(),
        x_min,x_max,far,near,'reconstructed_from_A21_conditional_PAR_alpha_ART_PENDING')


def main(a21_path: Path, a18_path: Path, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    a21 = verify_archive(a21_path,A21_SHA)
    a18 = verify_archive(a18_path,A18_SHA)
    master = a21.read('Runtime_FullGround_UNCHANGED.png')
    actor = a18.read('APPROVED_SOURCES/APPROVED_F0_EXACT_48_PRIVATE.png')
    assert hashlib.sha256(master).hexdigest() == MASTER_SHA
    assert hashlib.sha256(actor).hexdigest() == F0_SHA
    left = masked_alpha(a21.read('TREE_BEHIND_ACTOR_CONDITIONAL_PAR.png'))
    bridge = masked_alpha(a21.read('BRIDGE_BEHIND_ACTOR_CONDITIONAL_PAR.png'))
    full = masked_alpha(a21.read('Runtime_OcclusionPAR_ALL_CANDIDATE.png'))
    if not np.all(full | ~left) or not np.all(full | ~bridge):
        raise ValueError('A21 union does not contain provenance masks')
    if np.any(left & bridge):
        raise ValueError('Overlap between two recovered A21 masks')
    right = full & ~left & ~bridge
    if (int(left.sum()),int(bridge.sum()),int(right.sum())) != (33600,1421,55055):
        raise ValueError('A21 pixel counts did not reconcile')
    owner_layers = [
      build_owner('left_tree_canopy','tree_canopy',left,75,435,440,575),
      build_owner('right_lower_canopy','tree_canopy',right,1039,1280,700,927),
      build_owner('bridge_near_rail','bridge_near_rail',bridge,667,773,610,641),
    ]
    scenarios = [
      ('TREE_BEHIND',(208,509),(232,556)),
      ('TREE_FRONT',(208,549),(232,596)),
      ('BRIDGE_BEHIND',(711,574),(735,621)),
      ('BRIDGE_FRONT',(711,623),(735,670)),
    ]
    report = {'schema':'FS_A27_REAL_A21_ART_HOLD', 'input_a21_zip_sha256':A21_SHA,
      'input_a18_zip_sha256':A18_SHA,'master_png_sha256':MASTER_SHA,
      'actor_f0_sha256':F0_SHA,'reconstruction':{'left':int(left.sum()),
      'bridge':int(bridge.sum()),'right':int(right.sum())},'cases':[],
      'depth_hint_parameters':'provisional manual screen-row thresholds; not inferred 3D',
      'semantic_approval':'ART_HOLD','roof_real_source':'NOT_PRESENT_IN_A21_PRIVATE_ZIP',
      'native_vx':'NOT_RUN','switch203':'NOT_RUN','formal_seal':'NO'}
    scenes=[]
    for name,top,foot in scenarios:
        ground,par,preview,qa = render_actor_case(master,MASTER_SHA,actor,top,foot,owner_layers)
        if ground != master:
            raise ValueError('Master changed!')
        (output_dir / f'{name}_A27_PAR.png').write_bytes(par)
        (output_dir / f'{name}_A27_PREVIEW_NOT_VX.png').write_bytes(preview)
        baseline_img = img(a21.read(f'{name}_SIMULATION_NOT_VX.png'))
        old_par = masked_alpha(a21.read(f'{name}_ACTOR_CONDITIONAL_PAR.png'))
        actor_world = np.zeros(full.shape,bool)
        actor_world[top[1]:top[1]+48,top[0]:top[0]+48] = np.asarray(img(actor).getchannel('A')) > 0
        qa['a21_old_occluded_actor_pixels'] = int((old_par & actor_world).sum())
        qa['a27_delta_occluded_pixels'] = qa['occlusion_pixels'] - qa['a21_old_occluded_actor_pixels']
        report['cases'].append({'case':name, **qa})
        scenes.append((name,baseline_img,img(preview),top))
    # Precise 1x same-XY comparison, no rescaling of private source artwork.
    panel_w,panel_h=320,255
    board = Image.new('RGB',(2*panel_w+30,4*panel_h+12),(22,24,24))
    draw=ImageDraw.Draw(board)
    for i,(name,old,new,top) in enumerate(scenes):
        crop=(max(0,min(old.width-300, top[0]-125)),max(0,min(old.height-210,top[1]-85)))
        region=(crop[0],crop[1],crop[0]+300,crop[1]+210)
        y=i*panel_h+18
        for j,im in enumerate((old,new)):
            board.paste(im.crop(region).convert('RGB'),(j*(panel_w+10),y))
            draw.text((j*(panel_w+10)+4,i*panel_h+2),
                f'{name} | {"A21 BASELINE" if j==0 else "A27 DEPTH PREVIEW"}',fill=(240,240,240))
    visual_png=png_bytes(board)
    (output_dir/'A27_A21_SIDE_BY_SIDE_REAL_INPUT_NOT_VX.png').write_bytes(visual_png)
    (output_dir/'A27_REAL_QA.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
    fail_log = ('A27 FAILURE LOG / REAL SOURCE REPLAY\n'
                'A21 tree-behind covers substantial actor pixels; actor silhouette + source-row depth hints reduce that coverage.\n'
                'Depth hint calibration is manually chosen and not a certified front/back 3D reconstruction.\n'
                'The map in A21 is ART PENDING; its tree/bridge object masks were draft and have not been user-approved.\n'
                'A21 provided no roof mask: native roof validation NOT_RUN.\n'
                'Pillow preview is NOT native VX Game.exe, and no Switch203 logic is implemented.\n'
                'Per-character dynamic PAR requires explicit engine integration; do not drop these conditional files as static global PAR.\n'
                'No paid generation. No changes to sealed Ground or source work.\n')
    (output_dir/'A27_FAILURE_LOG.txt').write_text(fail_log,encoding='utf-8')
    output_zip = output_dir.parent/'FS_A27_REAL_A21_GEOMETRY_DEPTH_PRIVATE_20261113.zip'
    with zipfile.ZipFile(output_zip,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for f in sorted(output_dir.iterdir()):
            z.write(f,f.name)
    print(json.dumps({'zip':str(output_zip),'zip_size':output_zip.stat().st_size,
      'zip_sha256':hashlib.sha256(output_zip.read_bytes()).hexdigest(),
      'cases':[{k:v for k,v in x.items() if k in ('case','a21_old_occluded_actor_pixels','occlusion_pixels','a27_delta_occluded_pixels','source_same_xy_rgba_mismatch_pixels')} for x in report['cases']],
      'scene_size':[board.width,board.height]},indent=2))
    return output_zip

if __name__ == '__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--a21',type=Path,required=True)
    p.add_argument('--a18',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    main(a.a21,a.a18,a.output)
