"""Read-only external video preflight. No generation, resampling, or art approval."""
import argparse, hashlib, json, subprocess, math
from pathlib import Path
from fractions import Fraction

PIN='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
FIXTURES={'69d499bc7a396dd309ac76d04264004e5100993d7a100124a123ad4fca9f1796','913c5a5043ea6f4baa3c96a1221da30183cf811558e43baeef2e8ca471ce2009'}
REFERENCE='a4eb78924a712c18d6d404710bbc137536e9383302025870753afc1637c0dfdc'

def sha(p):
    with p.open('rb') as f: return hashlib.file_digest(f,'sha256').hexdigest()

def require(ok, reason):
    if not ok: raise ValueError(reason)

def validate(meta, clip_hash, receipt, mode):
    require(mode in ('fixture','external'),'MODE')
    if mode=='external':
        require(clip_hash not in FIXTURES,'KNOWN_FIXTURE_NOT_NEW_ART')
        require(receipt.get('clip_sha256')==clip_hash,'RECEIPT_CLIP_HASH')
        require(receipt.get('reference_sha256')==REFERENCE,'RECEIPT_REFERENCE_HASH')
        require(receipt.get('provider') in ('Google Flow','Gemini','Runway','xAI','BytePlus','fal.ai','other'),'PROVIDER_LABEL')
        require(receipt.get('action')=='attack','ACTION_MISMATCH')
        require(isinstance(receipt.get('generation_id'),str) and bool(receipt['generation_id'].strip()),'GENERATION_REFERENCE_REQUIRED')
    streams=[s for s in meta['streams'] if s.get('codec_type')=='video' and not s.get('disposition',{}).get('attached_pic')]
    require(len(streams)==1,'VIDEO_STREAM_COUNT'); s=streams[0]
    require((s.get('width'),s.get('height'))==(1280,720),'CANVAS_MISMATCH_NO_AUTO_RESIZE')
    require(s.get('sample_aspect_ratio','1:1') in ('1:1','N/A'),'NON_SQUARE_PIXELS')
    require(str(s.get('tags',{}).get('rotate','0'))=='0' and all(float(x.get('rotation',0))==0 for x in s.get('side_data_list',[])),'ROTATION')
    fps=Fraction(s['avg_frame_rate']); require(12<=fps<=60,'FPS_RANGE')
    duration=float(s.get('duration',meta.get('format',{}).get('duration',0))); require(math.isfinite(duration) and 0<duration<=12,'DURATION_RANGE')
    if mode=='external': require(duration>=3,'EXTERNAL_TOO_SHORT')
    count=int(s.get('nb_read_frames','0')); require(12<=count<=720,'DECODED_FRAME_COUNT')
    return dict(status='PREFLIGHT_PASS_NOT_ART_APPROVAL',mode=mode,clip_sha256=clip_hash,canvas=[1280,720],fps=str(fps),decoded_frames=count,duration_s=duration,codec=s.get('codec_name'),audio_streams=sum(x.get('codec_type')=='audio' for x in meta['streams']),provider_provenance='OWNER_SUPPLIED_NOT_AUTHENTICATED' if mode=='external' else 'FIXTURE_NOT_NEW_ART',next='ASF frames + visual contact sheet + explicit frame picks; no automatic hit event')

def selftest():
    from copy import deepcopy
    s={'codec_type':'video','width':1280,'height':720,'avg_frame_rate':'24/1','duration':'6','nb_read_frames':'144','sample_aspect_ratio':'1:1'}; m={'streams':[s]}; h='a'*64; r={'clip_sha256':h,'reference_sha256':REFERENCE,'provider':'Google Flow','action':'attack','generation_id':'synthetic-test-only'}
    validate(m,h,r,'external'); validate(m,next(iter(FIXTURES)),{},'fixture')
    cases=[]
    for field,value,reason in [('width',1920,'CANVAS_MISMATCH_NO_AUTO_RESIZE'),('sample_aspect_ratio','4:3','NON_SQUARE_PIXELS'),('avg_frame_rate','10/1','FPS_RANGE'),('duration','2','EXTERNAL_TOO_SHORT'),('nb_read_frames','11','DECODED_FRAME_COUNT'),('side_data_list',[{'rotation':90}],'ROTATION')]:
        b=deepcopy(m);b['streams'][0][field]=value;cases.append((b,h,r,reason))
    cases.extend([(m,next(iter(FIXTURES)),r,'KNOWN_FIXTURE_NOT_NEW_ART'),(m,h,{**r,'clip_sha256':'wrong'},'RECEIPT_CLIP_HASH'),(m,h,{**r,'reference_sha256':'wrong'},'RECEIPT_REFERENCE_HASH'),(m,h,{**r,'generation_id':''},'GENERATION_REFERENCE_REQUIRED'),(m,h,{**r,'action':'run'},'ACTION_MISMATCH'),({'streams':[s,s]},h,r,'VIDEO_STREAM_COUNT')])
    for b,c,d,e in cases:
        try: validate(b,c,d,'external')
        except ValueError as err: assert str(err)==e,(str(err),e)
        else: raise AssertionError(e)
    print('FS_ASF_INTAKE_SELFTEST_PASS positive=2 negative=12 SYNTHETIC_ONLY')

def main():
    p=argparse.ArgumentParser();p.add_argument('--self-test',action='store_true');p.add_argument('--source',type=Path);p.add_argument('--reference',type=Path);p.add_argument('--clip',type=Path);p.add_argument('--receipt',type=Path);p.add_argument('--mode',choices=['fixture','external'],default='external');a=p.parse_args()
    if a.self_test: selftest();return
    require(all((a.source,a.reference,a.clip)),'INPUT_REQUIRED'); require(sha(a.source)==PIN,'SOURCE_HASH'); require(sha(a.reference)==REFERENCE,'REFERENCE_HASH'); require(a.clip.stat().st_size<=100_000_000,'FILE_SIZE_LIMIT')
    h=sha(a.clip); require(a.mode=='fixture' or h not in FIXTURES,'KNOWN_FIXTURE_NOT_NEW_ART'); require(a.mode=='fixture' or a.receipt is not None,'RECEIPT_REQUIRED')
    r=json.loads(a.receipt.read_text()) if a.receipt else {}
    cmd=['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(a.clip.resolve())]; data=json.loads(subprocess.check_output(cmd,timeout=60)); require(sha(a.clip)==h,'CLIP_CHANGED_DURING_READ')
    print(json.dumps(validate(data,h,r,a.mode),indent=2))
if __name__=='__main__': main()
