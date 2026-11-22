#!/usr/bin/env python3
"""Forest Symphony T-B R15: genuine PixelLab KO->Idle anchored revive, plus third 3-stage ice-jackal family.
All raster only under TEMP until PRIVATE Google Drive release; never touch main/T-A/T-C or battle systems.
Auth comes from device environment only; no tokens in code/ledger.
"""
import argparse,base64,hashlib,io,json,math,os,sys,time,urllib.request,urllib.error,zipfile
from pathlib import Path
from PIL import Image

p=argparse.ArgumentParser()
p.add_argument('--r14-zip',required=True);p.add_argument('--work',required=True)
p.add_argument('--deadline-minutes',type=int,default=44)
a=p.parse_args()
ZPATH=Path(a.r14_zip);W=Path(a.work);W.mkdir(exist_ok=True,parents=True)
assert ZPATH.is_file()
sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha(ZPATH.read_bytes())=='07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575'
Z=zipfile.ZipFile(ZPATH);M=json.loads(Z.read('godot/TB14_MONSTER_FAMILY_MANIFEST.json'))
TOKEN=os.getenv('PIXELLAB_API_TOKEN')
assert TOKEN and len(TOKEN)>20,'Authorized device PixelLab API token is unavailable'
JPATH=W/'R15_PIXELLAB_PROVIDER_LEDGER.json';J=json.loads(JPATH.read_text(encoding='utf-8')) if JPATH.exists() else {}
def persist():JPATH.write_text(json.dumps(J,ensure_ascii=False,indent=2),encoding='utf-8')
def request(route,body=None,timeout=145):
    req=urllib.request.Request('https://api.pixellab.ai/v2'+route,data=json.dumps(body).encode() if body is not None else None,headers={'Authorization':'Bearer '+TOKEN,'Content-Type':'application/json'})
    with urllib.request.urlopen(req,timeout=timeout) as r:return json.load(r)
def retry(route,body=None):
    for k in range(3):
        try:return request(route,body)
        except urllib.error.HTTPError as ex:
            issue=ex.read().decode('utf-8','replace')[:550]
            if ex.code in (429,502,503,504) and k<2:
                time.sleep(12*(k+1));continue
            raise RuntimeError(f'HTTP {ex.code} {route} {issue}')
def imagedecode(obj):
    if isinstance(obj,dict):
        if 'image' in obj:return imagedecode(obj['image'])
        if 'base64' in obj:return imagedecode(obj['base64'])
    if isinstance(obj,str):
        try:
            return Image.open(io.BytesIO(base64.b64decode(obj.split(',',1)[-1]))).convert('RGBA')
        except Exception:return None
    return None
def imgdata(im):
    v=io.BytesIO();im.save(v,format='PNG')
    return {'type':'base64','format':'png','base64':base64.b64encode(v.getvalue()).decode()}
def cropbox(im):return im.getchannel('A').getbbox()
def pad(im,cell,margin=7):
    box=cropbox(im)
    assert box is not None,'transparent empty source'
    content=im.crop(box)
    mw=cell-2*margin
    if max(content.size)>mw:
        sf=min(mw/content.width,mw/content.height)
        sz=(max(1,round(content.width*sf)),max(1,round(content.height*sf)))
        content=content.resize(sz,Image.Resampling.NEAREST)
    result=Image.new('RGBA',(cell,cell))
    result.alpha_composite(content,((cell-content.width)//2,(cell-content.height)//2))
    return result
def alpha_qa(im):
    a=im.getchannel('A')
    rect=a.getbbox()
    if rect is None:return False
    return rect[0]>=3 and rect[1]>=3 and rect[2]<=im.width-3 and rect[3]<=im.height-3
def save_raw(path,im):
    im.save(path);return sha(path.read_bytes())
def path_of(kind,st):
    if kind=='bat':return f'BAT_STAGE{st}_REVIVE_R15_10F_{[128,160,224][st-1]}px.png'
    return f'PMD000{st}_REVIVE_R15_10F_128px.png'
def zframe(m,index):
    raw=Z.read('godot/'+m['path'])
    assert sha(raw)==m['sha256']
    im=Image.open(io.BytesIO(raw)).convert('RGBA')
    w,h=m['cell'];ncol=int(m['columns'])
    return im.crop(((index%ncol)*w,(index//ncol)*h,((index%ncol)+1)*w,((index//ncol)+1)*h))
def locked_revive_sources(kind,st):
    family=next(f for f in M['families'] if f['kind']==kind)
    s=family['stages'][st-1]
    start=zframe(s['motions']['ko'],s['motions']['ko']['frames']-1)
    end=zframe(s['motions']['idle'],0)
    assert start.size==end.size and start.size[0]==start.size[1]
    return start,end,s
def poll_one(jobid,limit=260):
    t=time.monotonic()
    while time.monotonic()-t<limit:
        result=retry('/background-jobs/'+jobid)
        status=result.get('status')
        if status=='completed':return result
        if status=='failed':raise RuntimeError('Provider job '+jobid+' failed: '+str(result.get('last_response'))[:400])
        time.sleep(7)
    raise TimeoutError('Provider job timeout '+jobid)
def get_frames(resp,n):
    obj=resp.get('last_response') or {}
    for field in ('images','frames','output_images'):
        images=[imagedecode(v) for v in (obj.get(field) or [])]
        if images and all(im is not None for im in images):
            if len(images)!=n:raise RuntimeError(f'Expected {n} frames, returned {len(images)}')
            return images,obj.get('generation_id')
    raise RuntimeError('No authentic animation frames in provider response')
start=time.monotonic()
def milestone(*msg):print('FS_R15',*msg,flush=True);persist()

# 1. NEW third family. Do not pretend generated from previous frogs or bats.
base_prompt=('One and only ONE young mystical GLACIER JACKAL PUP, an original four-legged canine ice monster. '
 'Compact athletic body, strong visible FOUR attached paws, triangular upright ears, narrow dark navy muzzle, '
 'large icy-blue eyes, pale silver-blue fur, one short translucent cyan crystal growing from the forehead, '
 'thick dark-tipped expressive tail. Distinctly canine, NOT frog, NOT bat, NOT horned deer, no wings, '
 'no hands, no armor plate, no clothing, no environment or floor shadow. '
 '16-color crisp old-school Japanese RPG 32-bit pixel art with selective outlining and subtle cold-blue shading, '
 'fixed southeast-facing 3/4 battle sprite, entire creature isolated and fully visible.')
FROST=W/'frost';FROST.mkdir(exist_ok=True)
if 'frost:1:source' not in J or J['frost:1:source']['status']!='completed':
    body={'description':base_prompt,'image_size':{'width':96,'height':96},
          'no_background':True,'background_removal_task':'remove_complex_background',
          'detail':'highly detailed','outline':'selective outline',
          'view':'low top-down','direction':'south-east','enhance_prompt':False,'seed':202615501}
    obj=retry('/create-image-pixen',body)
    raw=imagedecode(obj)
    assert raw and raw.size==(96,96)
    base=pad(raw,128)
    assert alpha_qa(base)
    pic=FROST/'FROST_JACKAL_STAGE1_SOURCE_128.png'
    J['frost:1:source']={'status':'completed','endpoint':'create-image-pixen','source_sha256':save_raw(pic,base),
                         'raw_source_sha256':sha(raw.tobytes()),'padded_cell':128,
                         'description':base_prompt,'seed':body['seed'],'provider_usage':obj.get('usage'),
                         'art_gate':'OWNER_REVIEW_PENDING'}
    milestone('STAGE1_SOURCE',obj.get('usage'),pic.name)
# Each later form DERIVES from the exact previous source; not three unrelated AI generations.
DESCRIPTIONS={
 2:('EVOLVE this SAME exact ice-jackal puppy to a visibly mature muscular mid-stage CRYSTAL WOLF: '
    'keep the SAME icy blue eyes, navy muzzle, distinctive silver-blue fur, triangular ears and thick dark-tipped tail, '
    'SAME four canine legs and same southeast facing 3/4 camera. Broader torso and long limbs, larger translucent cyan '
    'forehead crystal plus two new icy shoulder shards, brighter cold-blue chest mane. One complete animal, not two wolves, '
    'no bat wings, no frog, no extra legs, no forest floor, no shadow; transparent background. Crisp 16-color JRPG pixels.'),
 3:('EVOLVE this SAME mid-stage Crystal Wolf into enormous legendary GLACIER FENRIR elder wolf: '
    'distinct SAME blue eyes, dark navy muzzle, silver blue fur, four canine paws and signature thick tail, '
    'southeast 3/4 battle sprite. Dramatic larger mane, giant stepped icy crystal crown horn rising from forehead, '
    'three crystalline shards protrude from BOTH shoulders, broad wolf-like chest, frosty turquoise markings '
    'along the original spine. Make unmistakably final stage without species change. '
    'No antlers, no wings, no humanoid anatomy, no additional paws, one creature only, transparent BG, 16-color crisp pixels.')
}
for st in (2,3):
    key=f'frost:{st}:source';prior=FROST/f'FROST_JACKAL_STAGE{st-1}_SOURCE_{[128,160][st-2]}.png'
    assert prior.exists();prior_sha=sha(prior.read_bytes())
    if J.get(key,{}).get('status')=='completed':
        assert J[key]['input_source_sha256']==prior_sha
        continue
    raw=Image.open(prior).convert('RGBA')
    target=[160,192][st-2]
    body={'description':DESCRIPTIONS[st],'image':imgdata(raw),'image_size':{'width':raw.width,'height':raw.height},
          'width':target,'height':target,'no_background':True,'seed':202615501+st*17,
          'text_guidance_scale':7.0}
    result=retry('/edit-image',body)
    jid=result.get('background_job_id');assert jid
    J[key]={'status':'submitted','endpoint':'edit-image','job_id':jid,
            'input_source_sha256':prior_sha,'requested_description':DESCRIPTIONS[st],'seed':body['seed']}
    milestone(f'STAGE{st}_EDIT_SUBMITTED',jid)
    done=poll_one(jid,limit=410)
    rawobj=done.get('last_response') or {}
    ims=[imagedecode(x) for x in rawobj.get('images',[]) or []]
    cand=next((x for x in ims if x),None)
    if cand is None:cand=imagedecode(rawobj)
    assert cand is not None and cand.width==target and cand.height==target
    cell=target
    source=pad(cand,cell,margin=6)
    assert alpha_qa(source)
    out=FROST/f'FROST_JACKAL_STAGE{st}_SOURCE_{cell}.png'
    J[key].update(status='completed',source_sha256=save_raw(out,source),raw_source_sha256=sha(cand.tobytes()),
                  padded_cell=cell,provider_usage=done.get('usage'),generation_id=rawobj.get('generation_id'),
                  art_gate='OWNER_REVIEW_PENDING')
    milestone(f'STAGE{st}_SOURCE',str(out),str(done.get('usage')))
# 2. R15 all six revives anchored KO last to Idle first, plus 12 new third-family actions.
TASKS=[(f,st,'revive') for f in ('bat','frog') for st in (1,2,3)]
TASKS +=[('frost',st,act) for st in (1,2,3) for act in ('idle','attack','hurt','ko')]
ACTIONS={
 'idle':'FOUR PAWS anchored, breathe gently with slight chest and tail movement, head tilts up subtly and ears twitch, stay in place and return precisely to SAME identical southeast 3/4 first-frame pose; no travel, no duplicates.',
 'attack':'QUICK canine physical lunge and jaw bite: start on four attached feet, lower forequarters, lunge muzzle forward and OPEN canine jaw, close jaws with emphatic bite, recoil back to original four-pawed southeast three-quarter battle pose; no added wolves or ice blasts.',
 'hurt':'HIT REACTION: shoulders tighten, head recoils, four paws stagger back a tiny amount, eyes squeeze shut briefly, then regain original stable same-direction stance, no extra limbs.',
 'ko':'DEFEATED COLLAPSE: the SAME canine staggers, crystal head lowers, four limbs buckle naturally, rests weakly on the ground and remains still in visibly defeated pose in final frame. No blood, no separate body.',
}
def first_last(kind,st,act):
    if kind=='frost':
        source=FROST/f'FROST_JACKAL_STAGE{st}_SOURCE_{[128,160,192][st-1]}.png'
        first=Image.open(source).convert('RGBA')
        assert sha(source.read_bytes())==J[f'frost:{st}:source']['source_sha256']
        last=first if act!='ko' else None
        return first,last,sha(source.read_bytes()),source.name
    first,last,s=locked_revive_sources(kind,st)
    return first,last,s['source_sha256'],s['name']
def action_desc(kind,st,act):
    if kind=='bat':
        return ('FIX FACE LOCK: SAME single original leaf-vein BAT revival. Frame0 exactly KO last-frame slumped '
        'bat with lowered head and folded two attached wings. Slowly regain consciousness, unfold both '
        'existing emerald wings and face original SOUTHEAST 3/4 camera, reveal front gold eyes and '
        'species-identifying fangs. Last frame MUST match supplied live IDLE pose exactly. '
        'NEVER rotate further to show back or rear neck. DO NOT replace creature, no extra limbs, no BG.')
    if kind=='frog':
        return ('FIX FACE LOCK: SAME single four-legged MAGMA FROG REVIVE: starts exactly as original defeated KO F7 '
         'with four attached paws and basalt shell, opens original eyes, uses hind and front legs to push up, '
         'lifts head into same SOUTHEAST 3/4 camera and ends at supplied original IDLE sprite. '
         'No spinning, no second frog, no armor replacement, no external flame.')
    d='same original stage '+str(st)+' of THREE ICE JACKAL / CRYSTAL WOLF family. '
    return d+ACTIONS[act]+(' Keep ALL four legs connected, unique navy snout, silver-blue coat, ice-blue eyes, crystal features and thick tail. No background.' )
def b64(m):return imgdata(m)
def submit(kind,st,act):
    key=f'{kind}:{st}:{act}'
    first,last,sourcehash,source_name=first_last(kind,st,act)
    n=10 if act=='revive' else 8
    if max(first.size)**2*n>524288:raise RuntimeError('PixelLab requested clip violates image budget')
    payload={'first_frame':b64(first),'frame_count':n,'action':action_desc(kind,st,act),
             'no_background':True,'seed':202615600+(0 if kind=='bat' else 100 if kind=='frog' else 300)+st*20+
             {'revive':1,'idle':2,'attack':3,'hurt':4,'ko':5}[act]}
    if last is not None:payload['last_frame']=b64(last)
    req=retry('/animate-with-text-v3',payload)
    jid=req.get('background_job_id');assert jid,req
    J[key]={'status':'submitted','kind':kind,'stage':st,'action':act,
            'first_source_sha256':sha(first.tobytes()),'last_source_sha256':sha(last.tobytes()) if last else None,
            'source_stage_sha256':sourcehash,'source_identity':source_name,
            'frames':n,'cell':first.size[0],'job_id':jid,'seed':payload['seed'],
            'endpoint':'animate-with-text-v3','prompt':payload['action'],'art_gate':'OWNER_REVIEW_PENDING'}
    milestone('ANIM_SUBMIT',key,jid)
def accept(key,resp):
    rec=J[key];n=rec['frames'];kind=rec['kind'];st=rec['stage'];act=rec['action']
    images,gid=get_frames(resp,n)
    cell=rec['cell']
    if any(i.size!=(cell,cell) for i in images):raise RuntimeError('provider violated output dimension '+key)
    original=images[:]
    # PixelLab does not guarantee EXACT source endpoint; enforce true source pixels only at anchors.
    first,last,_,_=first_last(kind,st,act)
    assert first.size==(cell,cell)
    images[0]=first
    if last is not None:
        assert last.size==(cell,cell)
        images[-1]=last
    # Preserve genuine provider intermediate frames unmodified. Edge clipping => QA HOLD, no false PASS.
    area=[];edges=[];hashes=[]
    out=Image.new('RGBA',(cell*4,cell*math.ceil(n/4)))
    for i,img in enumerate(images):
        alpha=img.getchannel('A');bbox=alpha.getbbox()
        area.append(sum(v>0 for v in alpha.getdata()))
        edge=not (bbox is not None and bbox[0]>=1 and bbox[1]>=1 and bbox[2]<=cell-1 and bbox[3]<=cell-1)
        edges.append(int(edge));hashes.append(sha(img.tobytes()))
        out.alpha_composite(img,((i%4)*cell,(i//4)*cell))
    if kind=='frost':
        name=f'FROST_STAGE{st}_{act.upper()}_R15_{n}F_{cell}px.png'
    else:name=path_of(kind,st)
    dest=(W/kind);dest.mkdir(exist_ok=True)
    filename=dest/name
    atlas_sha=save_raw(filename,out)
    qa='PASS' if len(set(hashes))>=4 and min(area)>0 and max(edges)==0 else 'ART_TECH_HOLD'
    rec.update(status='completed',qa=qa,atlas=name,sheet_sha256=atlas_sha,
               generation_id=gid,usage=resp.get('usage'),first_frame_exact_source=True,
               last_frame_exact_source=last is not None,
               unique_frames=len(set(hashes)),border_counts=edges,
               frame_count_original_ai=n,provider_frame_sha256=[sha(im.tobytes()) for im in original])
    milestone('ANIM_COMPLETE',key,qa,len(set(hashes)),str(resp.get('usage')))
    if qa!='PASS':
        raise RuntimeError('Provider result failed sprite technical QA '+key+' '+str(edges))
deadline=start+a.deadline_minutes*60
for kind,st,act in TASKS:
    key=f'{kind}:{st}:{act}'
    if J.get(key,{}).get('status')=='completed':
        assert J[key]['qa']=='PASS' and (W/kind/J[key]['atlas']).is_file()
        continue
    if time.monotonic()>deadline:raise TimeoutError('Provider deadline; ledger preserved')
    # Sequential per family is deliberately bounded to avoid shared remote subscription's HTTP 429 cap
    if J.get(key,{}).get('status')!='submitted':submit(kind,st,act)
    done=poll_one(J[key]['job_id'],limit=400)
    accept(key,done)
assert len([1 for kind,st,act in TASKS if J[f'{kind}:{st}:{act}']['status']=='completed' and J[f'{kind}:{st}:{act}']['qa']=='PASS'])==18
assert len([1 for i in (1,2,3) if J[f'frost:{i}:source']['status']=='completed'])==3
print('FS_TB_R15_REAL_PIXEL_LAB_ALL_PASS clips=18 provider_animated_slots=156 new_species_sources=3',flush=True)
