"""FS video-to-sprite candidate guard. No generation, no gameplay promotion."""
import argparse, hashlib, json
from pathlib import Path
import numpy as np
from PIL import Image

PIN_SOURCE='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def rgba(p):
    with Image.open(p) as im: return np.array(im.convert('RGBA'))
def restore(a, anchor, target=(32,50)):
    if a.ndim!=3 or a.shape[2]!=4 or not np.isin(a[:,:,3],[0,255]).all(): raise ValueError('BINARY_RGBA_REQUIRED')
    if len(anchor)!=2 or any(int(v)!=v for v in anchor): raise ValueError('FRACTIONAL_ANCHOR')
    dx,dy=target[0]-int(anchor[0]),target[1]-int(anchor[1]); ys,xs=np.where(a[:,:,3]>0)
    if not len(xs): raise ValueError('EMPTY_BODY')
    if min(xs+dx)<0 or min(ys+dy)<0 or max(xs+dx)>=64 or max(ys+dy)>=64: raise ValueError('OPAQUE_CLIP_64')
    out=np.zeros((64,64,4),np.uint8);out[ys+dy,xs+dx]=a[ys,xs];return out

def selftest():
    a=np.zeros((64,57,4),np.uint8); a[10:45,15:35]=[10,20,30,255]; b=restore(a,(20,45)); assert b[15,27,3]==255
    checks=[(a,(20.5,45),'FRACTIONAL_ANCHOR'),(a,(100,45),'OPAQUE_CLIP_64'),(np.zeros_like(a),(20,45),'EMPTY_BODY')]; c=a.copy();c[10,15,3]=128;checks.append((c,(20,45),'BINARY_RGBA_REQUIRED'))
    for x,y,reason in checks:
        try: restore(x,y)
        except ValueError as e: assert str(e)==reason
        else: raise AssertionError(reason)
    print('FS_ASF_VIDEO_RESTORE_SELFTEST_PASS positive=1 negative=4')

def main():
    p=argparse.ArgumentParser();p.add_argument('--self-test',action='store_true');p.add_argument('--source',type=Path);p.add_argument('--clip',type=Path);p.add_argument('--job',type=Path);p.add_argument('--decoded',type=Path);p.add_argument('--finished',type=Path);p.add_argument('--out',type=Path);p.add_argument('--fixture',action='store_true');p.add_argument('--action',choices=['idle','run','attack']);a=p.parse_args()
    if a.self_test: selftest();return
    if not all([a.source,a.clip,a.job,a.decoded,a.finished,a.out,a.action]): p.error('source/clip/job/decoded/finished/out/action required')
    if sha(a.source)!=PIN_SOURCE: raise ValueError('SOURCE_SHA_MISMATCH')
    src=rgba(a.source);j=json.loads((a.job/'registration_job.json').read_text());d=json.loads((a.decoded/'frames.json').read_text());m=json.loads((a.finished/'motion.json').read_text())
    if j['sourceSize']!=[23,35] or j['sourceAnchor']!=[11.0,35.0] or j['referenceScale']!=12 or j['action']!=a.action: raise ValueError('JOB_GEOMETRY_MISMATCH')
    if not np.array_equal(rgba(a.job/j['master']['path']),src[15:50,21:44]): raise ValueError('SOURCE_CROP_MISMATCH')
    if d['job']['sha256']!=sha(a.job/'registration_job.json') or m['frames']['sha256']!=sha(a.decoded/'frames.json'): raise ValueError('RECEIPT_CHAIN_MISMATCH')
    if d['clip']['sha256']!=sha(a.clip): raise ValueError('CLIP_SHA_MISMATCH')
    if d['framesTouchingEdge']: raise ValueError('DECODED_ROOM_EDGE_TOUCH')
    if d['firstFrameDiffers']>0.1*23*35: raise ValueError('REFERENCE_DRIFT')
    if m['headRows'] or m['headBox'] or m['flipped'] or m['closedOutline'] or m['trimmedTo'] is not None: raise ValueError('UNAPPROVED_GEOMETRY_EDIT')
    indices=m['videoFrames']; durations=m['durationsMs']; files=sorted((a.finished/'clean').glob('frame_*.png'))
    if len(files)!=12 or len(indices)!=12 or len(durations)!=12 or sorted(set(indices))!=indices or min(durations)<1: raise ValueError('12F_CONTRACT')
    sel=json.loads((a.finished/'selection.json').read_text())
    if sel['sourceHashes']!=[sha(f) for f in files] or sel['durations_ms']!=durations or sel['loopPolicy']!=m['loopPolicy']: raise ValueError('SELECTION_HASH_MISMATCH')
    if min(indices)<0 or max(indices)>=d['clip']['frames']: raise ValueError('FRAME_INDEX_OUT_OF_RANGE')
    if m['loopPolicy']!=('oneshot' if a.action=='attack' else 'cycle'): raise ValueError('LOOP_CONTRACT')
    colors={tuple(v) for v in src[src[:,:,3]>0,:3]}; out=[]; frame_report=[]
    for i,f in enumerate(files):
        b=restore(rgba(f),m['anchor']);mask=b[:,:,3]>0; palette={tuple(v) for v in b[mask,:3]}; foreign=len(palette-colors)
        if foreign: raise ValueError('FOREIGN_PALETTE')
        if mask[0].any() or mask[-1].any() or mask[:,0].any() or mask[:,-1].any(): raise ValueError('FS_BORDER_TOUCH')
        ys,xs=np.where(mask); frame_report.append({'frame':i,'video_frame':indices[i],'bbox':[int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)],'opaque':int(mask.sum()),'colors':len(palette),'source_file_sha256':sha(f)})
        out.append(b)
    unique=len({hashlib.sha256(b.tobytes()).hexdigest() for b in out})
    if unique<4: raise ValueError('INSUFFICIENT_DISTINCT_MOTION')
    a.out.mkdir(parents=True,exist_ok=False);atlas=Image.new('RGBA',(256,192));
    for i,b in enumerate(out):
        im=Image.fromarray(b); im.save(a.out/f'F{i:02}.png'); atlas.paste(im,(i%4*64,i//4*64))
    atlas.save(a.out/'body.png');report={'status':'TECH_CANDIDATE_ONLY','fixture':a.fixture,'art_source':'EXISTING_A52_VIDEO_FIXTURE_NOT_NEW_ART' if a.fixture else 'SUPPLIED_VIDEO_UNVERIFIED_PROVIDER','art_gate':'HOLD','gameplay':'NOT_RUN','source_sha256':PIN_SOURCE,'clip_sha256':d['clip']['sha256'],'anchor':[32,50],'canvas':[64,64],'durations_ms':durations,'events':m['events'],'unique_rgba':unique,'first_frame_differs':d['firstFrameDiffers'],'frames':frame_report,'atlas_sha256':sha(a.out/'body.png')};(a.out/'qa.json').write_text(json.dumps(report,indent=2));print('FS_ASF_VIDEO_RESTORE_CANDIDATE',unique,report['atlas_sha256'])
if __name__=='__main__': main()
