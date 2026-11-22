#!/usr/bin/env python3
"""FS T-B R14. REAL source-locked PixelLab Skeleton v3 charge/release/revive.
Six source-locked forms; each action gets its own provider job. No combat work.
Only temporary owner-device execution; final PNGs and ledgers belong in private Drive.
"""
import os,sys,json,io,base64,time,runpy,hashlib,urllib.request,urllib.error,zipfile,shutil,argparse,math
from pathlib import Path
from PIL import Image

AP=argparse.ArgumentParser()
AP.add_argument('--work',required=True)
AP.add_argument('--r13-zip',required=True)
AP.add_argument('--max-active',type=int,default=6)
AP.add_argument('--max-minutes',type=int,default=38)
A=AP.parse_args()
W=Path(A.work);W.mkdir(parents=True,exist_ok=True)
R13=Path(A.r13_zip)
assert R13.is_file()
def sha(b):return hashlib.sha256(b).hexdigest()
assert sha(R13.read_bytes())=='eebd4d0e1bb12252d8ae1bea8fef87227ce7b9719a71f0da1539b19ea79492d7'
Z=zipfile.ZipFile(R13)
MAN=json.loads(Z.read('godot/TB13_MONSTER_FAMILY_MANIFEST.json'))
FAMS={f['kind']:f for f in MAN['families']}
assert set(FAMS)=={'bat','frog'}
TOKEN=os.getenv('PIXELLAB_API_TOKEN')
assert TOKEN,'PixelLab credential not available in authorized runtime'
SCRIPT_ROOT='https://raw.githubusercontent.com/showpei1203/forest-symphony-rmvx/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/'
CODES={'bat':'tb13_bat_stun_taunt_provider.py','frog':'tb13_frog_stun_taunt_provider.py'}
M={}
for kind in ('bat','frog'):
    wr=W/kind;wr.mkdir(exist_ok=True)
    for stage in FAMS[kind]['stages']:
        idx=stage['index'];base=Z.read('godot/'+stage['source_path'])
        assert sha(base)==stage['source_sha256']
        source=wr/(f'BAT_STAGE{idx}.png' if kind=='bat' else f'PMD000{idx}_STATIC_64.png')
        if not source.exists():source.write_bytes(base)
        assert sha(source.read_bytes())==stage['source_sha256']
    script=wr/CODES[kind]
    if not script.exists():script.write_bytes(urllib.request.urlopen(SCRIPT_ROOT+CODES[kind],timeout=40).read())
    old=sys.argv;sys.argv=[str(script),'--work',str(wr),'--tasks','1:stun']
    try:M[kind]=runpy.run_path(str(script),run_name=f'__tb14_{kind}__')
    finally:sys.argv=old

def B(dx=0,dy=0,hx=0,hy=0,lower=0,upper=0,wing=0,fold=0,tail=0):
    return M['bat']['P'](dx,dy,hx,hy,lower,upper,wing,fold,tail)
def F(dx=0,dy=0,gape=0,rpa=(0,0),npa=(0,0),fpa=(0,0),head=(0,0),leg=0):
    return M['frog']['P'](dx,dy,gape,rpa,npa,fpa,head,leg)
BCH=[B(),B(dy=1,wing=3),B(dy=-1,hy=-2,wing=-5),B(dy=-3,hy=-3,wing=-9,fold=-2),
     B(dy=-5,hy=-5,wing=-13,fold=-5),B(dy=-7,hy=-5,wing=-15,fold=-5,tail=3),
     B(dy=-7,hy=-5,wing=-17,fold=-6,tail=4),B(dy=-7,hy=-5,wing=-17,fold=-6,tail=4),
     B(dy=-7,hy=-5,wing=-17,fold=-6,tail=4),B(dy=-7,hy=-5,wing=-17,fold=-6,tail=4)]
BRE=[BCH[6],B(dy=-8,hy=-5,wing=-18,fold=-8,lower=2),B(dx=2,dy=-5,hy=-4,wing=-7,lower=5),
     B(dx=4,dy=-3,hy=-3,wing=9,lower=8),B(dx=5,dy=-1,wing=14,lower=9),
     B(dx=5,dy=1,wing=12,lower=6),B(dx=3,wing=4,lower=2),B(dx=1,wing=-2),B()]
BRV=[B(dx=-7,dy=24,hx=-8,hy=12,wing=18,fold=18),B(dx=-7,dy=24,hx=-7,hy=11,wing=18,fold=17),
     B(dx=-7,dy=23,hx=-6,hy=11,wing=14,fold=14),B(dx=-6,dy=21,hx=-5,hy=9,wing=13,fold=13),
     B(dx=-5,dy=18,hx=-4,hy=8,wing=12,fold=10),B(dx=-4,dy=15,hx=-3,hy=6,wing=8,fold=8),
     B(dx=-3,dy=11,hx=-2,hy=5,wing=6,fold=5),B(dx=-2,dy=7,hx=-1,hy=4,wing=4,fold=3),
     B(dx=-1,dy=4,hy=2,wing=1),B(dy=1,wing=-3),B()]
FCH=[F(),F(dy=2,leg=2),F(dy=1,leg=3,head=(0,-1)),F(dy=-2,leg=1,head=(1,-3)),
     F(dy=-4,head=(1,-4),gape=1,npa=(1,-1),fpa=(1,-1)),
     F(dy=-5,head=(2,-5),gape=2,npa=(2,-2),fpa=(2,-2)),
     F(dy=-6,head=(2,-5),gape=3,npa=(2,-2),fpa=(2,-2)),
     F(dy=-6,head=(2,-5),gape=3,npa=(2,-2),fpa=(2,-2)),
     F(dy=-6,head=(2,-5),gape=3,npa=(2,-2),fpa=(2,-2)),
     F(dy=-6,head=(2,-5),gape=3,npa=(2,-2),fpa=(2,-2))]
FRE=[FCH[6],F(dx=1,dy=-8,head=(3,-6),gape=6),F(dx=3,dy=-6,head=(4,-4),gape=9,npa=(3,-3),fpa=(3,-2)),
     F(dx=6,dy=-3,head=(5,-1),gape=9,npa=(4,-2),fpa=(4,-1)),
     F(dx=6,dy=-1,head=(3,0),gape=7,npa=(3,-1),fpa=(3,-1)),
     F(dx=4,dy=1,head=(2,0),gape=4),F(dx=2,dy=1,gape=2),F(dx=1),F()]
FRV=[F(dx=-9,dy=12,head=(-7,8),leg=7),F(dx=-9,dy=12,head=(-7,8),leg=7),
     F(dx=-8,dy=11,head=(-6,8),leg=7),F(dx=-7,dy=10,head=(-6,7),leg=6),
     F(dx=-6,dy=9,head=(-5,6),leg=5),F(dx=-5,dy=8,head=(-4,5),leg=5),
     F(dx=-4,dy=6,head=(-3,4),leg=4),F(dx=-3,dy=4,head=(-2,3),leg=3),
     F(dx=-2,dy=3,head=(-1,2),leg=2),F(dx=-1,dy=1,leg=1),F()]
POSES={'bat':{'charge':BCH,'release':BRE,'revive':BRV},'frog':{'charge':FCH,'release':FRE,'revive':FRV}}
assert [len(POSES['bat'][i]) for i in ('charge','release','revive')]==[10,9,11]
assert [len(POSES['frog'][i]) for i in ('charge','release','revive')]==[10,9,11]

PROMPT={
 'bat':{
  'charge':'CHARGE ENERGY: single hovering leaf bat braces, raises its crowned head, slowly opens the SAME two leaf-vein wings as green bioluminescent leaf veins intensify near the original chest. Keep body stable, attached wing joints and natural fangs. Hold visibly charged posture in final frames; NO external projectile, orb spawn, hands, extra wings.',
  'release':'MAGICAL CAST RELEASE: FROM the immediately preceding fully charged bat pose, sharply beat BOTH attached leaf wings together in one expressive outward release, lean head forward and open ORIGINAL fanged mouth briefly, then recover. This is a distinct decisive release gesture, not idle hovering or projectile magic; no third wing, no detached limbs.',
  'revive':'RISE FROM KNOCKOUT: from the SAME leaf bat actual defeated 8-frame KO FINAL pose, wings drooped and body slumped; slowly regain consciousness, eyes blink open, head lifts, both wings unfold and flap to regain stable hovering. Do not generate a new species, ghost, detached body, hands or external effects.'
 },
 'frog':{
  'charge':'MAGMA CHARGE: same four-legged basalt lava frog lowers on original FOUR attached feet and draws glowing lava into its ORIGINAL cracked back shell, chest rises and jaw opens slightly while heat accumulates inside torso. Hold fully charged final posture, never produce external fireball, separate rock, or new limbs.',
  'release':'MAGMA CAST RELEASE: FROM the preceding charged frog frame, push off with original four feet and thrust the SAME head up and forward, open dark mouth WIDE with visible lower jaw, chest and original magma seams flash then cool; return to original quadruped stance. This is NOT physical bite and NO separate projectile or extra legs.',
  'revive':'REVIVE FROM KO: from real defeated original magma frog final KO frame, originally collapsed on FOUR feet; shudder, reopen golden amber eyes, push up with original front and hind feet, lift head under basalt shell and rise to the same alive four-legged stance. Must not duplicate frog, separate shell, or spawn detached flames.'
 }
}
LEDGER=W/'R14_PROVIDER_JOB_LEDGER.json'
J=json.loads(LEDGER.read_text(encoding='utf-8')) if LEDGER.exists() else {}
PLAN=[(f,st,ac) for f in ('bat','frog') for st in (1,2,3) for ac in ('charge','revive','release')]
def write():LEDGER.write_text(json.dumps(J,ensure_ascii=False,indent=2),encoding='utf-8')
def atlas_frame(path,n,cell,cols=4):
    im=Image.open(path).convert('RGBA')
    return im.crop(((n%cols)*cell,(n//cols)*cell,(n%cols+1)*cell,(n//cols+1)*cell))
def input_image(kind,stage,action):
    meta=FAMS[kind]['stages'][stage-1]
    if action=='revive':
        ko=meta['motions']['ko']
        raw=Z.read('godot/'+ko['path'])
        assert sha(raw)==ko['sha256']
        im=Image.open(io.BytesIO(raw)).convert('RGBA')
        idx=int(ko['frames'])-1;cell=int(ko['cell'][0]);cols=int(ko['columns'])
        return im.crop(((idx%cols)*cell,(idx//cols)*cell,((idx%cols)+1)*cell,((idx//cols)+1)*cell)),ko['sha256']
    if action=='release':
        dep=J[f'{kind}:{stage}:charge']
        assert dep['status']=='completed' and dep['qa']=='PASS'
        raw=(W/kind/dep['atlas_name']).read_bytes();assert sha(raw)==dep['sheet_sha256']
        cell=int(dep['cell']);im=Image.open(io.BytesIO(raw)).convert('RGBA')
        return im.crop((2*cell,cell,3*cell,2*cell)),dep['sheet_sha256'] # charged F6 (row1 col2)
    if kind=='bat': im,p=M[kind]['source'](stage)
    else:p=M[kind]['load_source'](stage);im=Image.open(p).convert('RGBA')
    return im,meta['source_sha256']
def img_b64(im):
    v=io.BytesIO();im.save(v,format='PNG');return base64.b64encode(v.getvalue()).decode('ascii')
def submit(kind,stage,action):
    key=f'{kind}:{stage}:{action}'; poses=POSES[kind][action]
    src,lineage=input_image(kind,stage,action)
    cell=src.width;assert src.height==cell
    meta=FAMS[kind]['stages'][stage-1]
    kp=(M[kind]['rig_keypoints'] if kind=='bat' else lambda st,p: M[kind]['joints'](p))
    rig=[{'name':n,'parent':par,'side':side} for n,par,side in M[kind]['RIG']]
    base=(f'SAME SINGLE stage {stage} of three LEAF BAT, plum purple body, paired green leaf-vein wings, golden eyes, two leaf-like ears, two tucked feet, southeast three-quarter battle view. '
          if kind=='bat' else
          f'SAME SINGLE stage {stage} of three LAVA FROG, red skin, black volcanic basalt armor plates, molten orange fissures, four attached clawed feet, amber eyes, southeast three-quarter battle view. ')
    if kind=='bat' and stage==2:base+='Preserve green leaf crest, curled tail and distinct stage-two silhouette. '
    if kind=='bat' and stage==3:base+='Preserve crown horns and bright original emerald chest crystal. '
    if kind=='frog' and stage==3:base+='Preserve exposed molten core and distinctly enlarged basalt plates. '
    req={'description':base[:390],'action':PROMPT[kind][action],
         'direction':'south-east','view':'low top-down','template_id':'mannequin' if kind=='bat' else 'dog',
         'no_background':True,'seed':202614000+(0 if kind=='bat' else 1000)+stage*20+{'charge':1,'release':2,'revive':3}[action],
         'first_frame':{'type':'base64','format':'png','base64':img_b64(src)},
         'rig':rig,'first_frame_keypoints':kp(stage,poses[0]),
         'keypoints':[kp(stage,p) for p in poses]}
    rec={'key':key,'species':kind,'stage':stage,'action':action,'status':'submitting',
         'cell':cell,'frames':len(poses),'columns':4,'source_sha256':meta['source_sha256'],
         'first_frame_lineage_sha256':lineage,
         'first_frame_png_sha256':sha(base64.b64decode(req['first_frame']['base64'])),
         'seed':req['seed'],'prompt':PROMPT[kind][action],'endpoint':'animate-with-skeleton-v3'}
    J[key]=rec;write()
    try:
        ret=api('/animate-with-skeleton-v3',req)
        jid=ret.get('background_job_id')
        if not jid:raise RuntimeError('missing provider job id')
        rec.update(status='submitted',job_id=jid,submit_usage=ret.get('usage'))
        print('R14_SUBMITTED',key,jid,flush=True)
    except Exception as exc:
        rec.update(status='submit_failed',error=str(exc)[:480])
        print('R14_SUBMIT_FAILED',key,str(exc)[:120],flush=True)
    write()
def api(path,payload=None):
    headers={'Authorization':'Bearer '+TOKEN,'Content-Type':'application/json'}
    req=urllib.request.Request('https://api.pixellab.ai/v2'+path,
         data=json.dumps(payload).encode() if payload is not None else None,headers=headers)
    with urllib.request.urlopen(req,timeout=120) as response:return json.load(response)
def unpack(v):
    if isinstance(v,dict):
        for fld in ('base64','image','data'):
            if fld in v:return unpack(v[fld])
    if isinstance(v,str):
        if v.startswith('data:'):v=v.split(',',1)[1]
        try:return Image.open(io.BytesIO(base64.b64decode(v))).convert('RGBA')
        except Exception:return None
    return None
def poll(key,rec):
    jid=rec['job_id']
    try:res=api('/background-jobs/'+jid)
    except Exception as e:
        print('R14_POLL_RETRY',key,str(e)[:100],flush=True);return
    status=res.get('status');last=res.get('last_response') or {}
    if status=='failed':
        rec.update(status='failed',usage=res.get('usage'),error=str({k:v for k,v in last.items() if k not in ('images','frames','output_images')})[:450])
        write();print('R14_JOB_FAILED',key,rec['error'],flush=True);return
    if status!='completed':return
    imgs=[]
    for col in ('images','frames','output_images'):
        for item in last.get(col,[]) or []:
            i=unpack(item)
            if i is not None:imgs.append(i)
    n=int(rec['frames']);cell=int(rec['cell'])
    if len(imgs)!=n or any(im.size!=(cell,cell) for im in imgs):
        rec.update(status='qa_failed',received_frames=len(imgs),size_mismatch=True,usage=res.get('usage'))
        write();print('R14_WRONG_FRAMES',key,len(imgs),n,flush=True);return
    atlas=Image.new('RGBA',(cell*4,cell*math.ceil(n/4)))
    edges=[];raw_sha=[];areas=[]
    for i,im in enumerate(imgs):
        al=im.getchannel('A')
        border=sum(al.getpixel((x,y))>0 for x in range(cell) for y in (0,cell-1))
        border+=sum(al.getpixel((x,y))>0 for y in range(1,cell-1) for x in (0,cell-1))
        edges.append(border)
        areas.append(sum(1 for aa in al.getdata() if aa>0))
        raw_sha.append(sha(im.tobytes()))
        atlas.alpha_composite(im,((i%4)*cell,(i//4)*cell))
    name=(f'BAT_STAGE{rec["stage"]}_{rec["action"].upper()}_{n}F_{cell}px.png'
         if rec['species']=='bat' else f'PMD000{rec["stage"]}_{rec["action"].upper()}_{n}F_{cell}px.png')
    out=W/rec['species']/name
    atlas.save(out)
    q='PASS' if max(edges)==0 and all(a>0 for a in areas) and len(set(raw_sha))>=3 else 'HOLD'
    rec.update(status='completed',atlas_name=name,sheet_sha256=sha(out.read_bytes()),
               generation_id=last.get('generation_id'),usage=res.get('usage'),
               border_counts=edges,opaque_area=areas,unique_frames=len(set(raw_sha)),qa=q)
    write()
    print('R14_COMPLETED',key,'QA',q,'DIM',cell,'FRAMES',n,'UNIQUES',len(set(raw_sha)),'EDGE_MAX',max(edges),'USAGE',rec['usage'],flush=True)
    if q!='PASS':raise RuntimeError(f'Human/technical HOLD {key}: {rec["border_counts"]}')
def done_all():
    return all(J.get(f'{kind}:{st}:{ac}',{}).get('status')=='completed' and J[f'{kind}:{st}:{ac}']['qa']=='PASS'
               for kind,st,ac in PLAN)
start=time.monotonic()
deadline=start+A.max_minutes*60
while time.monotonic()<deadline:
    if done_all():break
    for key,rec in list(J.items()):
        if rec.get('status') in ('submitted','processing'):
            poll(key,rec)
    failed=[(k,v.get('status')) for k,v in J.items() if v.get('status') in ('failed','submit_failed','qa_failed')]
    if failed:raise RuntimeError(f'PixelLab pipeline stopped on hard failure; no false release: {failed}')
    active=sum(v.get('status') in ('submitted','processing') for v in J.values())
    for kind,stage,action in PLAN:
        if active>=A.max_active:break
        key=f'{kind}:{stage}:{action}'
        if key in J:continue
        if action=='release' and not (J.get(f'{kind}:{stage}:charge',{}).get('status')=='completed' and J[f'{kind}:{stage}:charge'].get('qa')=='PASS'):continue
        submit(kind,stage,action)
        active+=int(J[key]['status']=='submitted')
    if done_all():break
    print('R14_PROGRESS',sum(v.get('status')=='completed' and v.get('qa')=='PASS' for v in J.values()),'of',len(PLAN),'ACTIVE',active,flush=True)
    time.sleep(8)
assert done_all(), 'Provider jobs unfinished; retained TEMP ledger and sprites, no fake finished release.'
assert len(J)==18 and all(v.get('job_id') and v.get('generation_id') for v in J.values())
used=sum(float(v.get('usage',{}).get('generations',0)) for v in J.values())
assert used==54.0,('provider charge report unexpected',used)
print('FS_TB_R14_PROVIDER_ALL_18_PASS total_new_frames=180 provider_generations=54.0',flush=True)
