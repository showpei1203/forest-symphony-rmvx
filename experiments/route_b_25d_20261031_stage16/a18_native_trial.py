#!/usr/bin/env python3
"""Stage 16 A18: native-pixel model experiment, fail closed.

Default commands NEVER submit charged generations. Sensitive tokens never logged.
Official public docs: https://api.pixellab.ai/v2/llms.txt and
https://github.com/Retro-Diffusion/api-examples

Live submission is a capability gated by explicit consent, env credentials and
USD cap; it is NOT automatically exercised by running preflight/validate.
"""
from __future__ import annotations

import argparse, base64, hashlib, io, json, os, sys, time
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError

from PIL import Image, ImageDraw
import numpy as np

ROOT = Path(__file__).resolve().parent
IMG_SIZE = (128, 128)
PIXEL_BASE = 'https://api.pixellab.ai/v2'
RETRO_BASE = 'https://api.retrodiffusion.ai/v2'
PROMPT = ('Top-down orthographic natural forest ground texture for a detailed 2D fantasy JRPG: '
          'soft fine-grain grass with rich small pixel leaf clusters, subtle warm sandy soil '
          'and a naturally feathered dirt footpath, tiny ground-level wildflowers, coherent '
          'pixel-art silhouettes, handcrafted selective outlines, low-contrast botanical '
          'detail, full opaque background, seamless visual language. GROUND ONLY: '
          'absolutely no buildings, trees, trunks, standing bushes, rocks, bridges, '
          'people, shadows from tall objects, text, UI or borders.')
REFERENCE = {
    'grass': ('A10_GROUND3_GRASS_SOURCE_64.png', (64, 64),
              'b185fbbccd5f84a58f12144b906d7a5fe71809b59a8f75ac385c92b2c5543407'),
    'sand': ('A10_GROUND3_SAND_SOURCE_48.png', (48, 48),
             'ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb'),
}

def sha_bytes(b:bytes)->str:return hashlib.sha256(b).hexdigest()
def sha_file(p:Path)->str:return sha_bytes(p.read_bytes())
def write_json(p:Path,obj:dict)->None:p.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf8')

def verify_reference()->dict:
    checks={}
    for k,(name,size,expected) in REFERENCE.items():
        p=ROOT/name
        assert p.exists(),f'missing private input {name}'
        assert sha_file(p)==expected,f'changed authentic Ground3 reference {name}'
        with Image.open(p) as im:
            assert im.format=='PNG' and im.size==size and im.mode in ('RGB','RGBA'),name
        checks[k]={'filename':name,'size':list(size),'sha256':expected}
    return checks

def encode_image(name:str):
    name,size,_=REFERENCE[name]
    b=(ROOT/name).read_bytes()
    return {'image':{'type':'base64','base64':'data:image/png;base64,'+base64.b64encode(b).decode('ascii')},'size':{'width':size[0],'height':size[1]}}

def request_bundle(provider='pixellab_pro'):
    if provider=='pixellab_pixen':
        return PIXEL_BASE+'/create-image-pixen',{'description':PROMPT,'image_size':{'width':128,'height':128},'no_background':False,'seed':161801}
    if provider=='pixellab_pro':
        # official docs generate-image-v2 accepts style_image: {image,size}; test live schema before claiming API PASS.
        return PIXEL_BASE+'/generate-image-v2',{
            'description':PROMPT,'image_size':{'width':128,'height':128},
            'no_background':False,'seed':161801,'style_image':encode_image('grass')}
    if provider=='retro_pro':
        return RETRO_BASE+'/inferences',{
            'prompt':PROMPT,'prompt_style':'rd_pro__topdown',
            'width':128,'height':128,'num_images':1,'seed':161801}
    raise ValueError(provider)

def dryrun(provider='pixellab_pro'):
    refs=verify_reference()
    url,payload=request_bundle(provider)
    # Never save raw base64 references in the public or diagnostic request manifest.
    safe={k:({'reference_sha256':refs['grass']['sha256'],'kind':'Ground3 64x64 private style input'} if k=='style_image' else v)
          for k,v in payload.items()}
    status={'stage':'A18','provider':provider,'mode':'DRY_RUN_NO_CHARGE_NO_NETWORK',
            'endpoint':url,'payload_no_private_bytes':safe,
            'source_reference_sha256':refs,'authorization_present':bool(os.getenv('PIXELLAB_API_KEY' if provider.startswith('pixellab') else 'RD_API_KEY')),
            'explicit_paid_consent_received':False,'provider_response':'NOT_SUBMITTED',
            'new_model_png':'NOT_CREATED', 'ground3_art':'NOT_TESTED',
            'godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO',
            'schema_status':'DRAFT_FROM_PUBLIC_DOCUMENTATION_NOT_LIVE_VALIDATED'}
    write_json(ROOT/('A18_'+provider.upper()+'_DRY_RUN.json'),status)
    return status

def _transport(url:str, data:dict|None, key:str, provider:str, timeout=45):
    headers={'Accept':'application/json'}
    if data is not None:headers['Content-Type']='application/json'
    if provider.startswith('pixellab'):headers['Authorization']='Bearer '+key
    else:headers['X-RD-Token']=key
    req=Request(url,data=json.dumps(data).encode('utf8') if data is not None else None,headers=headers,method='POST' if data is not None else 'GET')
    try:
        with urlopen(req,timeout=timeout) as resp:
            b=resp.read(10000000)
            return resp.status,json.loads(b)
    except HTTPError as e:
        # Truncate diagnostics, never echo credentials or untrusted giant responses.
        return e.code,{'error_http_status':e.code,'response_excerpt':e.read(2000).decode('utf8','replace')}

def decode_model_result(obj,provider):
    """Only parse actual provider fields; never synthesize a replacement image."""
    if isinstance(obj,dict) and 'images' in obj and obj['images']:
        obj=obj['images'][0]
    if isinstance(obj,dict) and 'image' in obj:obj=obj['image']
    if isinstance(obj,dict):obj=obj.get('base64')
    if not isinstance(obj,str):raise ValueError('No raw encoded image found; preserve provider response as unresolved instead of guessing')
    if obj.startswith('data:'):obj=obj.split(',',1)[1]
    b=base64.b64decode(obj,validate=True)
    # Only PNG is accepted as authentic native model artifact.
    with Image.open(io.BytesIO(b)) as im:
        if im.format!='PNG':raise ValueError('Provider returned non-PNG; NOT direct native PNG PASS')
        if im.size!=IMG_SIZE:raise ValueError(f'Returned {im.size}, requested {IMG_SIZE}: size FAIL')
        if im.mode not in ('RGB','RGBA','P'):raise ValueError(f'unsupported model pixel format {im.mode}')
        px=im.convert('RGBA')
    return b,px

def run_paid(provider:str,approve:bool,max_cost_usd:float):
    if not approve or max_cost_usd<=0:
        raise PermissionError('FAIL CLOSED: --approve-paid and positive --max-cost-usd are mandatory')
    # This is a LOCAL ESTIMATE GUARD, not a real provider-enforced USD spending cap.
    # User must separately authorize vendor spend; pricing may change.
    # Public budget examples; never claim these are authoritative realtime invoice quotes.
    estimated={'pixellab_pixen':0.01,'pixellab_pro':0.19,'retro_pro':0.18}[provider]
    if max_cost_usd < estimated:
        raise PermissionError(f'cap {max_cost_usd} is below public conservative cost estimate {estimated}')
    key=os.getenv('PIXELLAB_API_KEY' if provider.startswith('pixellab') else 'RD_API_KEY')
    if not key:raise PermissionError('API token not connected in environment; no paid request made')
    # Deliberate stop for Retro until price estimation succeeds with authenticated service.
    if provider=='retro_pro':
        raise PermissionError('Retro paid call disabled pending live style selection and free cost estimate; no paid request')
    # PixelLab: balance check is read-only, but no automatic charges until the above explicit gate.
    status,balance=_transport(PIXEL_BASE+'/balance',None,key,provider)
    if status!=200:raise RuntimeError(f'Account balance preflight returned HTTP {status}; no paid generation')
    url,payload=request_bundle(provider)
    job_status,result=_transport(url,payload,key,provider,timeout=55)
    safe_log={'provider':provider,'submitted_at_utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),
              'HTTP':job_status,'raw_response_without_image':{k:v for k,v in result.items() if k not in ('image','images','last_response')} if isinstance(result,dict) else str(result),
              'status':'SUBMITTED_NOT_ART_APPROVED','formal_seal':'NO'}
    write_json(ROOT/'A18_LIVE_SUBMISSION_RECEIPT.json',safe_log)
    if job_status not in (200,202):raise RuntimeError(f'Provider HTTP {job_status}; no accepted output')
    job=result.get('background_job_id') or result.get('job_id') if isinstance(result,dict) else None
    if job:
        for _ in range(40):
            time.sleep(3)
            sc,res=_transport(PIXEL_BASE+f'/background-jobs/{job}',None,key,provider,timeout=20)
            if sc!=200:raise RuntimeError(f'Job poll HTTP {sc}')
            if res.get('status')=='completed':
                result=res.get('last_response') or res
                break
            if res.get('status') in ('failed','cancelled'):raise RuntimeError('Model job failed; see provider, no art claimed')
        else:raise TimeoutError('Job not completed during polling; job ID preserved; no PNG claimed')
    b,px=decode_model_result(result,provider)
    original=ROOT/f'A18_ACTUAL_{provider}_NATIVE128_MODEL_ORIGINAL.png'
    original.write_bytes(b)
    proof={'provider':provider,'source_native_png':original.name,'sha256':sha_file(original),
           'size':[128,128],'image_origin':'ACTUAL_AUTHENTICATED_PROVIDER_BYTES',
           'art_approved':False,'formal_seal':'NO'}
    write_json(ROOT/'A18_LIVE_IMAGE_PROVENANCE.json',proof)
    return proof

def validate_png(path:Path,provider='external',allow_mock=False):
    refs=verify_reference()
    b=path.read_bytes()
    assert b[:8]==b'\x89PNG\r\n\x1a\n','Not raw PNG'
    with Image.open(io.BytesIO(b)) as im:
        assert im.format=='PNG'
        assert im.size==IMG_SIZE,f'Expected native 128x128, got {im.size}'
        assert im.mode in ('RGB','RGBA','P'),f'Expected native RGB(A) or indexed P, got {im.mode}'
        rgba=np.asarray(im.convert('RGBA'),dtype=np.uint8)
    # Format engineering checks: geometry native and no transparent / no alpha holes.
    alpha=rgba[:,:,3]
    nalpha=int((alpha!=255).sum())
    ref=Image.open(ROOT/REFERENCE['grass'][0]).convert('RGB')
    sample=Image.fromarray(rgba[:,:,:3],'RGB')
    canvas=Image.new('RGB',(3*262,314),(24,26,28));draw=ImageDraw.Draw(canvas)
    for i,(lab,tile) in enumerate([('Ground3 grass INPUT 32px',ref.crop((16,16,48,48))),
                                   ('OUTPUT native 32px A',sample.crop((24,24,56,56))),
                                   ('OUTPUT native 32px B',sample.crop((72,64,104,96)))]):
        x=i*262+2;draw.text((x,9),lab,fill='white');canvas.paste(tile.resize((256,256),Image.Resampling.NEAREST),(x,30))
    out=ROOT/('A18_'+provider.upper()+'_32PX_VISUAL_AUDIT.png')
    canvas.save(out)
    scores={'stage':'A18','file':path.name,'file_sha256':sha_bytes(b),'provider':provider,
            'actual_model_provenance':'NOT_VERIFIED' if not (ROOT/'A18_LIVE_IMAGE_PROVENANCE.json').exists() else 'PROVENANCE_FILE_EXISTS_CHECK_SIGNATURE_MANUALLY',
            'is_mock_fixture':bool(allow_mock), 'source_size':[128,128],
            'color_count':len(np.unique(rgba[:,:,:3].reshape(-1,3),axis=0)),
            'nonopaque_pixels':nalpha,'ground_opaque_format_gate':nalpha==0,'format_png':True,'source_direct_native_not_resized':'NOT_PROVABLE_FROM_PNG_ONLY',
            'pixel_crisp_1x':'REQUIRES_HUMAN','ground3_style':'REQUIRES_HUMAN','standing_PAR_objects_absent':'REQUIRES_HUMAN',
            'formal_seal':'NO','godot':'NOT_RUN','vx':'NOT_RUN'}
    write_json(ROOT/('A18_'+provider.upper()+'_FORMAT_QA.json'),scores)
    return scores

if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('mode',choices=('preflight','run','validate'))
    ap.add_argument('--provider',choices=('pixellab_pixen','pixellab_pro','retro_pro'),default='pixellab_pro')
    ap.add_argument('--file',type=Path)
    ap.add_argument('--approve-paid',action='store_true')
    ap.add_argument('--max-cost-usd',type=float,default=0.0)
    ap.add_argument('--mock-fixture',action='store_true')
    args=ap.parse_args()
    try:
        if args.mode=='preflight':result=dryrun(args.provider)
        elif args.mode=='run':result=run_paid(args.provider,args.approve_paid,args.max_cost_usd)
        else:
            if not args.file:ap.error('--file required')
            result=validate_png(args.file,args.provider,args.mock_fixture)
        print(json.dumps(result,ensure_ascii=False,indent=2))
    except Exception as e:
        print(f'BLOCKED_OR_FAILED: {type(e).__name__}: {e}',file=sys.stderr)
        sys.exit(2)
