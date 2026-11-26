#!/usr/bin/env python3
"""FS T-C D29: one-pass entire PAR, exact 1280x928 canvas, native RGBA.

DEFAULT IS OFFLINE DRY-RUN. A paid model call requires the owner to explicitly approve it,
and is protected by BOTH --execute --owner-approved-paid plus a specific env gate.
No object-level extraction, cropping, resizing, compositing into a production PAR.
Never commit image payloads or credentials to public GitHub.
"""
from __future__ import annotations
import argparse
import base64
import hashlib
import io
import json
import os
from pathlib import Path

from PIL import Image
import numpy as np

CANVAS = (1280, 928)
GROUND_SHA = '2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e'
MODEL = 'gpt-image-2.5-sunburst'
MODEL_FALLBACK = 'gpt-image-2.5-flare'
PAID_GATE_VALUE = 'EXPLICIT_D29_ONE_PASS_SINGLE_REQUEST'
API_URL = 'https://api.openai.com/v1/images/edits'

SCENE_PROMPT = '''
Produce ONE unified, complete, original game-art image: the all-non-ground
PAR foreground layer for Forest Symphony FS_04_MAZE. This is a standalone
1280x928 RGBA sprite layer with REAL transparent alpha background, NOT a
mock-up, grid, report, asset board, sheet, or a Ground+objects composite.
Image 1 is the locked 1280x928 Ground reference: use it ONLY as a pixel/world
coordinate map, to match light, perspective, and palette; do NOT paint, copy,
repeat, or preserve ANY of its lava, paving, terrain, roads, ground textures or
background pixels in output. The entire output must be transparent except for
non-ground objects. Do not render a checkerboard or any explanatory text.
Paint ALL non-ground objects in ONE continuous composition at fixed world
locations, not individual separated drawings: one compact upper-left forge
with bronze/purple slate roofing and hot orange furnace, a mine crane above
right-center, compact store shed at lower left, a short approximately 5–6
32px-tile-wide stone and bronze bridge spanning the right-side vertical lava
fissure on solid basalt banks, all relevant railings, banners, lamps, fences,
posts, signs, rock spires, crates, mine carts, ore and buildings. The bridge
must connect ground landmarks correctly; leave major Ground pathways open.
Single coherent pixel-art author, 3/4 top-down view, consistent object scale,
rich detailed violet basalt and bronze machinery, unified orange forge glow,
crisp 1x game-world pixel edges, no UI, no letters, no character sprites.
The forge exterior should not exceed about nine 32px tiles in width.
No isolated objects to be recombined afterwards: author the entire PAR scene
at once directly in the source canvas. If visual completeness, composition or
alpha cannot be achieved, output will be rejected rather than postprocessed.
'''.strip()


def digest(path: Path) -> str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for buf in iter(lambda:f.read(1024*1024),b''):h.update(buf)
    return h.hexdigest()


def verify_ground(path: Path) -> dict:
    if not path.is_file(): raise FileNotFoundError(path)
    with Image.open(path) as image:
        if image.size!=CANVAS or image.mode not in ('RGB','RGBA'):
            raise ValueError('FROZEN_GROUND_INVALID_CANVAS_OR_MODE')
        if image.mode=='RGBA' and np.any(np.asarray(image)[:,:,3]!=255):
            raise ValueError('FROZEN_GROUND_NOT_OPAQUE')
    h=digest(path)
    if h!=GROUND_SHA:raise ValueError('FROZEN_GROUND_SHA_MISMATCH')
    return {'path_name':path.name,'sha256':h,'size':list(CANVAS),'valid':True}


def build_request_spec(ground:Path, model:str=MODEL) -> dict:
    v=verify_ground(ground)
    if model not in (MODEL,MODEL_FALLBACK):raise ValueError('UNVERIFIED_MODEL_BLOCKED')
    w,h=CANVAS
    assert w%16==0 and h%16==0 and 1/3<=w/h<=3
    return {'api':API_URL,'model':model,'size':'1280x928',
            'background':'transparent','output_format':'png','quality':'high',
            'n':1,'prompt':SCENE_PROMPT,'reference_image':'LOCKED_D17_GROUND_ONLY',
            'ground':v,'no_component_operations':True,
            'paid_execution_authorized':False,'production_art_pass':False}


def source_gate_png_bytes(payload:bytes) -> dict:
    with Image.open(io.BytesIO(payload)) as im:
        im.load()
        mode,size=im.mode,im.size
        pix=np.asarray(im.convert('RGBA'))
    a=pix[:,:,3]
    reasons=[]
    if size!=CANVAS:reasons.append('SOURCE_NATIVE_CANVAS_FAIL')
    if mode!='RGBA':reasons.append('SOURCE_NOT_TRUE_RGBA')
    if not np.any(a==0):reasons.append('SOURCE_NO_ALPHA_ZERO')
    if (np.count_nonzero(a==0)/a.size)<0.25:reasons.append('SOURCE_TRANSPARENCY_TOO_SPARSE_FOR_PAR')
    if not np.any(a>32):reasons.append('SOURCE_NO_VISIBLE_FOREGROUND')
    return {'size':list(size),'mode':mode,
            'alpha0_pixels':int(np.count_nonzero(a==0)),
            'visible_gt32_pixels':int(np.count_nonzero(a>32)),
            'source_gate':'PASS' if not reasons else 'FAIL','errors':reasons,
            'ground_contamination':'NOT_MACHINE_PROVEN',
            'world_footpoints':'NOT_MACHINE_PROVEN','whole_scene_art':'HUMAN_HOLD',
            'approved_production_par':False}


def enforce_paid_authorization(args):
    if not args.execute:return False
    if not args.owner_approved_paid or os.getenv('FS_TC_D29_PAID_RUN')!=PAID_GATE_VALUE:
        raise PermissionError('PAID_API_CALL_BLOCKED: explicit owner flag and single-use environment authorization required')
    if not os.getenv('OPENAI_API_KEY'):
        raise PermissionError('OPENAI_API_KEY_NOT_CONFIGURED: ChatGPT subscription is not API authorization')
    return True


def execute_once(args,spec:dict):
    enforce_paid_authorization(args)
    # The external model request happens once here; no hidden automatic retry, queue or loops.
    from openai import OpenAI
    client=OpenAI(max_retries=0, timeout=180)
    with args.ground.open('rb') as ground_image:
        result=client.images.edit(model=spec['model'],image=ground_image,
                                  prompt=spec['prompt'],size=spec['size'],
                                  background=spec['background'],
                                  output_format=spec['output_format'],quality=spec['quality'],n=1)
    if len(result.data)!=1 or not result.data[0].b64_json:
        raise RuntimeError('NO_SINGLE_RETURNED_IMAGE')
    payload=base64.b64decode(result.data[0].b64_json,validate=True)
    gate=source_gate_png_bytes(payload)
    args.output.parent.mkdir(parents=True,exist_ok=True)
    if args.output.exists():raise FileExistsError('REFUSE_OVERWRITE_EXISTING_ART')
    # Preserve original returned PNG bytes exactly, even on failure, then quarantine via Drive.
    args.output.write_bytes(payload)
    return {'result_sha256':digest(args.output),'original_png':str(args.output),
            'source_gate':gate,'paid_call_count':1,
            'human_ART':'HOLD','Godot_native':'NOT_RUN',
            'private_drive_upload_status':'REQUIRED_NOT_YET_DONE'}


def cli(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ground',type=Path,required=True)
    parser.add_argument('--model',choices=[MODEL,MODEL_FALLBACK],default=MODEL)
    parser.add_argument('--manifest',type=Path,required=True)
    parser.add_argument('--output',type=Path)
    parser.add_argument('--execute',action='store_true',default=False)
    parser.add_argument('--owner-approved-paid',action='store_true',default=False)
    args=parser.parse_args(argv)
    spec=build_request_spec(args.ground,args.model)
    if args.execute:
        enforce_paid_authorization(args)
        if args.output is None:raise ValueError('--output required for explicit paid execution')
        result=execute_once(args,spec)
    else:
        result={'state':'DRY_RUN_OFFLINE_VALIDATED','paid_api_calls':0,
                'model_availability_in_owner_account':'NOT_AUTHENTICATED',
                'exact_1280x928_native_source':'NOT_GENERATED',
                'request':spec}
    args.manifest.parent.mkdir(parents=True,exist_ok=True)
    args.manifest.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k!='request'},ensure_ascii=False))
    return result

if __name__=='__main__':cli()
