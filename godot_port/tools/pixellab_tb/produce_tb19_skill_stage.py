#!/usr/bin/env python3
"""FS T-B R19 | Exactly ONE source-locked paid PixelLab 12-frame quadruped SKILL.

Exclusively callable from an audited, fixed-stage GitHub PC Bridge wrapper on owner's
Windows runner. No Issue/user-supplied prompts, paths, URLs or commands. Source R18
private ZIP sha pinned. Checkpoint job ID BEFORE polling to avoid accidental rebill.
Private G: Drive owner folder is the sole persistent location; TEMP cleaned per run.
"""
from __future__ import annotations
import argparse, base64, hashlib, io, json, os, pathlib, shutil, sys, tempfile, time, urllib.error, urllib.request, zipfile
from PIL import Image

SRC_SHA='8cc85ea1ca326ce854b3432a46c63fb311aaba3ca5628d101e10a54fc03cae6c'
SRC_BYTES=12626646
SRC_NAME='FS_TB_R18_GLACIER_JACKAL_3RUN_12F_NATIVE_VERIFIED_PRIVATE_20261123.zip'
PARENT_ID='10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'
DRIVE=(pathlib.Path('G:/.shortcut-targets-by-id')/PARENT_ID/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE')
ROOT=('https://api.pixellab.ai/v2')
ACTIONS=('SKILL',)
STAGE_N={1:'Glacier Jackal Pup',2:'Crystal Wolf Guardian',3:'Ancient Glacier Fenrir'}
CELL={1:128,2:160,3:192}
MAX_SECONDS=248
COST_PER_JOB_MAX=16.0


def sha(b):return hashlib.sha256(b).hexdigest()
def encode(im):
    f=io.BytesIO();im.save(f,format='PNG')
    return {'type':'base64','format':'png','base64':base64.b64encode(f.getvalue()).decode('ascii')}
def decode(image):
    if isinstance(image,dict):return decode(image.get('image') or image.get('base64') or image.get('data'))
    if not isinstance(image,str):raise ValueError('Provider frame missing')
    return Image.open(io.BytesIO(base64.b64decode(image.split(',',1)[-1],validate=True))).convert('RGBA')
def dump(path,obj):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(obj,indent=2,ensure_ascii=False),encoding='utf-8')
def prompt(stage):
    s=(f'SAME four-legged silver-blue {STAGE_N[stage]} CASTS one ICE SKILL, 12 frames. '
       'Fixed southeast 3/4 JRPG battle camera; centered creature, static view. '
       'F0 original pose; F1-F3 lower head and brace all four attached paws. '
       'F4-F7 cyan frost crystal light grows on forehead and pushes forward in a short icy burst. '
       'F8-F10 glow fades, muzzle lifts; F11 return to EXACT original pose. '
       'Preserve icy eyes, navy muzzle, crystal crown, silver fur, four paws, ears and tail. '
       'NO duplicate wolf, extra legs, wings, weapons, scenery, camera turn, or edge clipping.')
    assert len(s)<=495,(stage,len(s))
    return s

def source_frame(z,stage):
    m=json.loads(z.read('godot/TB18_MONSTER_FAMILY_MANIFEST.json'))
    assert m['clip_count']==99 and m['total_frames']==898 and len(m['families'])==3
    f=next(x for x in m['families'] if x['kind']=='frost')
    st=f['stages'][stage-1]
    assert st['index']==stage and st['source_size']==[CELL[stage]]*2 and len(st['motions'])==7
    assert 'skill' not in st['motions']
    assert sha(z.read('godot/'+st['source_path']))==st['source_sha256']
    meta=st['motions']['idle']
    assert sha(z.read('godot/'+meta['path']))==meta['sha256']
    atlas=Image.open(io.BytesIO(z.read('godot/'+meta['path']))).convert('RGBA')
    n=CELL[stage]
    im=atlas.crop((0,0,n,n))
    assert im.getchannel('A').getbbox()
    return im,st

def provider(token,route,body=None):
    req=urllib.request.Request(ROOT+route,
        data=json.dumps(body,separators=(',',':')).encode() if body is not None else None,
        headers={'Authorization':'Bearer '+token,'Content-Type':'application/json'})
    # Billable POST must NEVER be auto-retried: response loss could duplicate charges.
    attempts=1 if body is not None else 3
    for i in range(attempts):
        try:
            with urllib.request.urlopen(req,timeout=45) as r:return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code in (429,502,503,504) and i<attempts-1:
                time.sleep(5*(i+1));continue
            raise SkilltimeError(f'PixelLab fixed endpoint HTTP {e.code}') from None
        except urllib.error.URLError:
            if i<attempts-1:time.sleep(5*(i+1));continue
            raise SkilltimeError('PixelLab fixed endpoint unreachable') from None

def parse_frames(result,source):
    resp=result.get('last_response') or {}
    originals=[decode(x) for x in (resp.get('images') or resp.get('frames') or resp.get('output_images') or [])]
    assert len(originals) in (12,13),('provider raw frames',len(originals))
    assert all(x.size==source.size for x in originals),'provider changed pixel canvas dimensions'
    chosen=[round(i*(len(originals)-1)/11) for i in range(12)] if len(originals)==13 else list(range(12))
    assert len(set(chosen))==12
    out=[originals[i].copy() for i in chosen]
    out[0]=source.copy();out[-1]=source.copy()  # exact source anchors, intentionally nonprovider
    boxes=[]
    for i,f in enumerate(out):
        box=f.getchannel('A').getbbox();assert box,'blank animation frame'
        assert min(box[0],box[1],f.width-box[2],f.height-box[3])>=2,('clipped frame',i,box)
        boxes.append(box)
    hashes=[sha(x.tobytes()) for x in out]
    assert len(set(hashes))>=8,'too few unique real in-between frames'
    assert out[0].tobytes()==out[-1].tobytes()==source.tobytes()
    # Evidence of changing connected paws/silhouette, not artistic guarantee of plausible gait.
    feet=[];alpha=[]
    b0=source.getchannel('A').getbbox(); foot_start=round(b0[1]+0.62*(b0[3]-b0[1]))
    for f in out:
        a=f.getchannel('A').crop((0,foot_start,f.width,f.height))
        alpha.append(a.tobytes())
        feet.append(sha(a.tobytes()))
    assert len(set(feet))>=5,'lower-body silhouette does not articulate sufficiently'
    return originals,out,{'frame_qa':'PASS','frame_rgba_shas':hashes,'alpha_boxes':boxes,
                           'raw_returned':len(originals),'selected_raw_indices':chosen,
                           'foot_region_start_y':foot_start,'foot_alpha_unique_frames':len(set(feet)),
                           'first_last_exact_idle_source':True,
                           'semantic_gait_visual':'ART_REVIEW_PENDING_NOT_PROVED_BY_ALPHA'}

def atlas_of(frames):
    c=frames[0].width
    atlas=Image.new('RGBA',(4*c,3*c))
    for i,f in enumerate(frames):atlas.alpha_composite(f,((i%4)*c,(i//4)*c))
    return atlas

def verify_pack(raw:bytes,source:bytes,stage:int):
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        assert z.testzip() is None
        n=z.namelist();assert len(n)>=15 and len(n)==len(set(n))
        ledger=json.loads(z.read('R19_JOB_LEDGER.json'))
        assert ledger['stage']==stage and ledger['status']=='COMPLETED_SOURCE_QA_PASS'
        assert ledger['source_r18_sha256']==SRC_SHA
        assert ledger['reported_usage']['generations']>0
        assert sha(z.read('R19_IDLE_SOURCE_F0.png'))==sha(source)
        assert sha(z.read('R19_SKILL_12F_ATLAS.png'))==ledger['atlas_png_sha256']
        assert len([x for x in n if x.startswith('raw_frames/F') and x.endswith('.png')]) in (12,13)
        return ledger

def selftest():
    # Fully offline! Validate all stage prompts, actual R18 ZIP source contracts,
    # ledger contract and atlas packing BEFORE any paid provider job.
    src=pathlib.Path('/mnt/data')/SRC_NAME
    if not src.exists():src=DRIVE/SRC_NAME
    assert src.exists() and src.stat().st_size==SRC_BYTES and sha(src.read_bytes())==SRC_SHA
    with zipfile.ZipFile(src) as z:
        assert z.testzip() is None and len(z.namelist())==448
        for st in (1,2,3):
            f,meta=source_frame(z,st)
            frames=[f.copy() for _ in range(12)]
            a=atlas_of(frames)
            assert a.size==(CELL[st]*4,CELL[st]*3)
            assert len(prompt(st))<=495
            report={'stage':st,'source_r18_sha256':SRC_SHA,
                'status':'COMPLETED_SOURCE_QA_PASS',
                'reported_usage':{'type':'generations','generations':4.0},
                'atlas_png_sha256':'placeholder'}
            buf=io.BytesIO();a.save(buf,format='PNG')
            report['atlas_png_sha256']=sha(buf.getvalue())
            tmp=io.BytesIO()
            with zipfile.ZipFile(tmp,'w',zipfile.ZIP_DEFLATED) as out:
                out.writestr('R19_JOB_LEDGER.json',json.dumps(report))
                out.writestr('R19_IDLE_SOURCE_F0.png',_png(f))
                out.writestr('R19_SKILL_12F_ATLAS.png',buf.getvalue())
                for k in range(12):out.writestr(f'raw_frames/F{k:02d}.png',_png(f))
            assert verify_pack(tmp.getvalue(),_png(f),st)['reported_usage']['generations']==4.0
    print('FS_TB_R19_OFFLINE_FULL_SCHEMA_AND_3STAGE_ATLAS_PASS prompts='+','.join(str(len(prompt(x))) for x in (1,2,3))+' paid_api_jobs=0')
def _png(im):
    b=io.BytesIO();im.save(b,format='PNG');return b.getvalue()

def run_stage(stage):
    skillid=os.getenv('GITHUB_SKILL_ID','')
    assert skillid.isdigit() and 6<=len(skillid)<=20,'Fixed owner Windows runner only'
    assert DRIVE.is_dir(),'No original private Drive mount; stop before paid request'
    tok=os.getenv('PIXELLAB_API_TOKEN')
    assert tok and len(tok)>20,'PixelLab auth HOLD, no token contents logged'
    source_zip=DRIVE/SRC_NAME
    assert source_zip.is_file() and source_zip.stat().st_size==SRC_BYTES and sha(source_zip.read_bytes())==SRC_SHA
    ledger_path=DRIVE/f'R19_SKILL_STAGE{stage}_JOB_JOURNAL_PRIVATE.json'
    output_path=DRIVE/f'R19_SKILL_STAGE{stage}_TRUE_PIXELLAB_12F_PRIVATE.zip'
    if output_path.exists():
        raise SkilltimeError('R19 stage source ZIP already exists; REFUSE NEW PAID JOB')
    prompt_txt=prompt(stage)  # validates BEFORE submission
    with zipfile.ZipFile(source_zip) as z:
        im,st=source_frame(z,stage)
    raw_path=DRIVE/f'R19_SKILL_STAGE{stage}_RAW_PROVIDER_RESPONSE_PRIVATE.json'
    if ledger_path.exists():
        l=json.loads(ledger_path.read_text(encoding='utf-8'))
        assert l['source_r18_sha256']==SRC_SHA and l['stage']==stage
        assert l['prompt']==prompt_txt and isinstance(l['job_id'],str)
        assert l['status'] in ('SUBMITTED','POLLING','COMPLETED_PROVIDER_HOLD','COMPLETED_SOURCE_QA_PASS'),'Cannot resubmit prior stage'
        jid=l['job_id']; print('R19_RESUMING_EXISTING_PROVIDER_JOB stage='+str(stage),flush=True)
    else:
        body={'first_frame':encode(im),'last_frame':encode(im),
              'frame_count':12,'action':prompt_txt,'no_background':True,'seed':202619403+stage*307}
        res=provider(tok,'/animate-with-text-v3',body)
        jid=res.get('background_job_id')
        assert isinstance(jid,str) and len(jid)>16,'Provider did not return real job ID; do not retry blindly'
        l={'task':'FS_TB_R19_TRUE_GAIT_STAGE','stage':stage,'source_r18_sha256':SRC_SHA,
           'source_stage_sha256':st['source_sha256'],'idle_atlas_sha256':st['motions']['idle']['sha256'],
           'prompt':prompt_txt,'seed':body['seed'],'endpoint':'animate-with-text-v3',
           'job_id':jid,'requested_frames':12,'status':'SUBMITTED',
           'reported_usage':None,'new_native_godot':'NOT_SKILL_ART_ONLY',
           'art_gate':'OWNER_ART_REVIEW_PENDING'}
        # Critical durable journal BEFORE first poll, prevents duplicate paid submission.
        dump(ledger_path,l)
        assert json.loads(ledger_path.read_text())['job_id']==jid
        print('R19_PAID_JOB_SUBMITTED stage='+str(stage)+' job_journal_private=YES',flush=True)
    t=time.monotonic();result=None
    while time.monotonic()-t<MAX_SECONDS:
        result=provider(tok,'/background-jobs/'+jid)
        state=result.get('status')
        if state=='completed':break
        if state=='failed':raise SkilltimeError('Provider reported failed; source journal retained, no resubmit')
        time.sleep(6)
    else:raise TimeoutError('R19 provider polling limit; job journal survives; NO REBILL')
    usage=result.get('usage') or {}
    cost=float(usage.get('generations',0))
    # Record actual reported generations BEFORE any images/QA parsing.
    l.update(status='COMPLETED_PROVIDER_HOLD',reported_usage=usage)
    dump(ledger_path,l)
    # Persist complete provider frames BEFORE semantic/format QA; this is a recoverable
    # paid source even when downstream frame validation or ZIP construction fails.
    immutable_raw={'job_id':jid,'stage':stage,'provider_status':'completed',
                   'last_response':result.get('last_response') or {},'usage':usage}
    if raw_path.exists():
        previous=json.loads(raw_path.read_text(encoding='utf-8'))
        assert previous['job_id']==jid and previous['stage']==stage, 'existing raw source collision'
    else:
        dump(raw_path,immutable_raw)
        assert json.loads(raw_path.read_text(encoding='utf-8'))['job_id']==jid
    assert 0<cost<=COST_PER_JOB_MAX,'Provider usage exceeds pre-approved guard; preserve journal'
    raw,frames,qa=parse_frames(result,im)
    atlas=atlas_of(frames)
    raw_bytes=_png(atlas)
    l.update(status='COMPLETED_SOURCE_QA_PASS',generation_id=(result.get('last_response') or {}).get('generation_id'),
             raw_returned_frames=len(raw),atlas_png_sha256=sha(raw_bytes),
             raw_frame_sha256=[sha(_png(x)) for x in raw],
             selected_frame_count=12,qa=qa)
    # Build complete archival artifact ENTIRELY in owner TEMP before cloud move.
    root=pathlib.Path(tempfile.gettempdir())/('fs_tb_r19_stage'+str(stage)+'_'+skillid)
    assert not root.exists(),'R19 source staging temp already exists'
    root.mkdir()
    try:
        dump(root/'R19_JOB_LEDGER.json',l)
        (root/'R19_IDLE_SOURCE_F0.png').write_bytes(_png(im))
        (root/'R19_SKILL_12F_ATLAS.png').write_bytes(raw_bytes)
        for i,f in enumerate(raw):
            dst=root/'raw_frames'/f'F{i:02d}.png';dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(_png(f))
        tmp=root.with_suffix('.zip')
        with zipfile.ZipFile(tmp,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
            for file in sorted(root.rglob('*')):
                if file.is_file():z.write(file,file.relative_to(root).as_posix())
        cloud=tmp.read_bytes()
        verify_pack(cloud,_png(im),stage)
        assert not output_path.exists(),'R19 prior stage artifact collision; never overwrite'
        shutil.copyfile(tmp,output_path)
        assert output_path.is_file() and sha(output_path.read_bytes())==sha(cloud)
        dump(ledger_path,l)
        print('FS_TB_R19_STAGE_PROVIDER_ARCHIVE_PASS stage='+str(stage)+' generations='+str(cost)
            +' zip_sha256='+sha(cloud)+' bytes='+str(len(cloud))+' raw_frames='+str(len(raw))
            +' foot_alpha_unique='+str(qa['foot_alpha_unique_frames'])+' source_private=YES',flush=True)
    finally:
        if root.exists() and root.name=='fs_tb_r19_stage'+str(stage)+'_'+skillid:shutil.rmtree(root)
        tmp=root.with_suffix('.zip')
        if tmp.exists() and tmp.name=='fs_tb_r19_stage'+str(stage)+'_'+skillid+'.zip':tmp.unlink()
        assert not root.exists(),'Temp cleanup failed'

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--selftest',action='store_true')
    p.add_argument('--stage',type=int,choices=(1,2,3))
    args=p.parse_args()
    if args.selftest:
        assert args.stage is None
        selftest()
    else:
        assert args.stage in (1,2,3)
        run_stage(args.stage)