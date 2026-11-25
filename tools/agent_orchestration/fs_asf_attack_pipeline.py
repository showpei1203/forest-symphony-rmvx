"""FS ACTOR01 ATTACK only: decode, review receipt, finish, isolated native playback.
No provider call, automatic picks, game edits, or art approval.
"""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
from PIL import Image
import fs_asf_video_intake as intake

HERE=Path(__file__).resolve().parent
JOB='bf770e6134401b95f776409dd7acd8875fb0847ae9bfa109e2332ded30cbec18'
MASTER='0102ccb70e31edfb0715b2560a8301dabea157fb5ef258dd4cc40c2a1cbfd9b4'
PINS={'pixel_motion.py':'b9405549195507e1d3a9a49b04c8e904c181c6110eb4d62e6240d313f72e325c','forge_core.py':'d51d790cf0ce9c649df90c501ab7ebd4c2946cecd4bfb9b7e99979c2e937b8b8','forge_pixelgrid.py':'fdb000dad20bf4d40723a95c51a6dbbd77f06375f27e82106f5d3ce937eb89a9'}

def req(ok,reason):
    if not ok:raise ValueError(reason)
def sha(p):return intake.sha(p)
def blob(p):
    b=p.read_bytes();return hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf8'))
def save(p,v):p.write_text(json.dumps(v,indent=2)+'\n',encoding='utf8')
def run(args,timeout=180):return subprocess.check_output([str(x) for x in args],stderr=subprocess.STDOUT,timeout=timeout,text=True)
def python(*args):return run([sys.executable,*args])
def hashes(folder,pattern):return {p.name:sha(p) for p in sorted(folder.glob(pattern))}
def base(a):
    req(blob(HERE/'fs_asf_video_intake.py')=='bb3360d30b375e789bc3af43425947a3fb168108','INTAKE_PIN')
    req(blob(HERE/'fs_asf_video_restore.py')=='385021a99cbeb957795523ff9e321ab072891b8f','RESTORE_PIN')
    req(sha(a.source)==intake.PIN and sha(a.job/'input.png')==intake.REFERENCE and sha(a.job/'registration_job.json')==JOB and sha(a.job/'master.png')==MASTER,'SOURCE_JOB_PIN')
    for name,pin in PINS.items():req(sha(a.asf/name)==pin,'ASF_PIN_'+name)
    req(a.clip.is_file() and 0<a.clip.stat().st_size<=100_000_000,'CLIP_SIZE')
    h=sha(a.clip);req((h in intake.FIXTURES)==a.fixture,'FIXTURE_CLASSIFICATION')
    if not a.fixture:req(a.provider_receipt is not None,'PROVIDER_RECEIPT_REQUIRED')
    return h

def decode(a):
    h=base(a);req(not a.out.exists(),'OUTPUT_EXISTS')
    cmd=[HERE/'fs_asf_video_intake.py','--source',a.source,'--reference',a.job/'input.png','--clip',a.clip,'--mode','fixture' if a.fixture else 'external']
    if not a.fixture:cmd+=['--receipt',a.provider_receipt]
    pre=json.loads(python(*cmd));req(pre['clip_sha256']==h,'INTAKE_CLIP_PIN')
    a.out.mkdir();save(a.out/'intake.json',pre)
    python(a.asf/'pixel_motion.py','frames','--clip',a.clip,'--job',a.job,'--output-dir',a.out/'decoded','--room','21,15,20,7')
    d=a.out/'decoded';meta=read(d/'frames.json');frames=hashes(d/'frames','frame_*.png')
    req(sha(a.clip)==h and meta['clip']['sha256']==h and meta['job']['sha256']==JOB,'DECODE_CHAIN')
    req(len(frames)==pre['decoded_frames'] and len(frames)==meta['clip']['frames'],'DECODE_COUNT')
    req(not meta['framesTouchingEdge'] and meta['firstFrameDiffers']<=0.1*23*35,'DECODE_VISUAL_HOLD')
    receipt=dict(status='REVIEW_REQUIRED',fixture=a.fixture,clip_sha256=h,job_sha256=JOB,frames_json_sha256=sha(d/'frames.json'),contact_sha256=sha(d/'frames-sheet.png'),frame_sha256=frames,provider_receipt_sha256=None if a.fixture else sha(a.provider_receipt))
    save(a.out/'decode_receipt.json',receipt)
    print('FS_ATTACK_DECODE_PASS review_required=True frames='+str(len(frames)))

def check_selection(a,r,h):
    d=a.decoded/'decoded';s=read(a.selection)
    req(r['status']=='REVIEW_REQUIRED' and r['fixture']==a.fixture and r['clip_sha256']==h and r['job_sha256']==JOB,'REVIEW_CHAIN')
    req(r['provider_receipt_sha256']==(None if a.fixture else sha(a.provider_receipt)),'PROVIDER_RECEIPT_CHANGED')
    req(sha(d/'frames.json')==r['frames_json_sha256'] and sha(d/'frames-sheet.png')==r['contact_sha256'] and hashes(d/'frames','frame_*.png')==r['frame_sha256'],'DECODE_TAMPER')
    req(s.get('decode_receipt_sha256')==sha(a.decoded/'decode_receipt.json') and s.get('review_kind')==('KNOWN_FIXTURE_ONLY' if a.fixture else 'REVIEWED_TECH_CANDIDATE'),'SELECTION_RECEIPT')
    picks=s.get('indices');ms=s.get('durations_ms')
    req(isinstance(picks,list) and len(picks)==12 and all(type(i)is int for i in picks) and sorted(set(picks))==picks and all(f'frame_{i:03d}.png' in r['frame_sha256'] for i in picks),'PICK_CONTRACT')
    req(isinstance(ms,list) and len(ms)==12 and all(type(i)is int and 20<=i<=500 for i in ms) and 200<=sum(ms)<=3000,'TIMING_CONTRACT')
    req('events' not in s,'NO_AUTOMATIC_GAMEPLAY_EVENTS')
    return picks,ms

def finish(a):
    h=base(a);req(not a.out.exists(),'OUTPUT_EXISTS')
    r=read(a.decoded/'decode_receipt.json');picks,ms=check_selection(a,r,h)
    a.out.mkdir();d=a.decoded/'decoded';f=a.out/'finished';c=a.out/'candidate'
    python(a.asf/'pixel_motion.py','finish','--frames-dir',d,'--name','actor01_attack','--output-dir',f,'--pick',','.join(map(str,picks)),'--ms-list',','.join(map(str,ms)),'--loop','oneshot','--no-trim','--no-package')
    cmd=[HERE/'fs_asf_video_restore.py','--source',a.source,'--clip',a.clip,'--job',a.job,'--decoded',d,'--finished',f,'--out',c,'--action','attack']
    if a.fixture:cmd+=['--fixture']
    python(*cmd)
    q=read(c/'qa.json');req(q['events']==[] and q['durations_ms']==ms and q['anchor']==[32,50] and q['art_gate']=='HOLD','RESTORE_CONTRACT')
    with Image.open(c/'body.png') as atlas:
        req(atlas.size==(256,192),'ATLAS_SIZE')
        for i in range(12):
            x,y=i%4*64,i//4*64
            with Image.open(c/f'F{i:02d}.png') as im:req(im.size==(64,64) and im.convert('RGBA').tobytes()==atlas.crop((x,y,x+64,y+64)).convert('RGBA').tobytes(),'ATLAS_PARITY')
    native=a.out/'native';native.mkdir();(native/'project.godot').write_text('config_version=5\n[application]\nconfig/name="FS ATTACK technical QA"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',encoding='utf8')
    (native/'test.gd').write_bytes((HERE/'fs_asf_attack_native.gd').read_bytes())
    for p in [c/'body.png',c/'qa.json',*sorted(c.glob('F*.png'))]:(native/p.name).write_bytes(p.read_bytes())
    req(run([a.godot,'--version'],15).strip()=='4.7.2.stable.official.ed1daf0bf','GODOT_VERSION')
    log=run([a.godot,'--headless','--path',native,'--fixed-fps','240','--script','res://test.gd'],30)
    req('FS_ATTACK_ATLAS_NATIVE_PASS frames=12 events=11 one_shot=true' in log,'NATIVE_MARKER')
    (a.out/'native.log').write_text(log,encoding='utf8')
    save(a.out/'result.json',dict(status='TECH_PASS_OWNER_ART_HOLD',fixture=a.fixture,source_sha256=intake.PIN,clip_sha256=h,decode_receipt_sha256=sha(a.decoded/'decode_receipt.json'),selection_sha256=sha(a.selection),atlas_sha256=sha(c/'body.png'),durations_ms=ms,frames=12,gameplay='NOT_RUN',native='ISOLATED_ATLAS_PLAYBACK_PASS',provider_generation=False,events=[]))
    print('FS_ATTACK_FINISH_PASS fixture='+str(a.fixture)+' owner_art=HOLD gameplay=NOT_RUN')

def main():
    p=argparse.ArgumentParser();p.add_argument('mode',choices=['decode','finish']);p.add_argument('--source',type=Path,required=True);p.add_argument('--job',type=Path,required=True);p.add_argument('--clip',type=Path,required=True);p.add_argument('--asf',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--fixture',action='store_true');p.add_argument('--provider-receipt',type=Path);p.add_argument('--decoded',type=Path);p.add_argument('--selection',type=Path);p.add_argument('--godot',type=Path);a=p.parse_args()
    if a.mode=='decode':decode(a)
    else:req(all((a.decoded,a.selection,a.godot)),'FINISH_ARGS');finish(a)
if __name__=='__main__':main()
