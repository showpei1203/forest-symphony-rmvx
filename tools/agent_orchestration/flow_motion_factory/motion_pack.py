"""Build a body-only motion bundle from reviewed, normalized 64px PNGs. No art generation."""
from pathlib import Path
from PIL import Image
import argparse, hashlib, json, shutil, tempfile

MODES={'attack':False,'run':True,'damage':False,'dodge':False,'cast':False}

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def check(ok, code):
    if not ok: raise ValueError(code)
def validate(action, source, frames, durations, expected_source=None, expected_frames=None, airborne=()):
    check(action in MODES,'ACTION')
    n=len(frames)
    check(4<=n<=16 and len(durations)==n,'COUNT')
    check(all(type(x) is int and 20<=x<=500 for x in durations) and 200<=sum(durations)<=4000,'TIMING')
    check(source.is_file() and 0<source.stat().st_size<=25_000_000,'SOURCE')
    if expected_source is not None: check(sha(source)==expected_source,'SOURCE_HASH')
    if expected_frames is not None: check(len(expected_frames)==n,'FRAME_HASH_COUNT')
    check(all(type(i) is int and 0<=i<n for i in airborne) and len(set(airborne))==len(airborne),'AIRBORNE')
    check(not airborne or action in ('run','dodge'),'AIRBORNE_ACTION')
    atlas=Image.new('RGBA',(256,64*((n+3)//4))); seen=set(); records=[]
    for i,p in enumerate(frames):
        check(p.is_file(),'FRAME_MISSING')
        h=sha(p)
        if expected_frames is not None: check(h==expected_frames[i],'FRAME_HASH')
        with Image.open(p) as im:
            check(im.format=='PNG' and im.mode=='RGBA' and im.size==(64,64),'FRAME_FORMAT')
            b=im.getbbox(); a=im.getchannel('A')
            check(set(a.getdata())=={0,255},'BINARY_ALPHA')
            check(b and b[0]>0 and b[1]>0 and b[2]<64 and b[3]<=50,'BOUNDS')
            check((b[3]<50) if i in airborne else (b[3]==50),'FOOTLINE')
            raw=im.tobytes();check(raw not in seen,'DUPLICATE');seen.add(raw)
            atlas.paste(im,(i%4*64,i//4*64))
            records.append({'index':i,'sha256':h,'bbox':list(b),'duration_ms':durations[i],'airborne':i in airborne})
    return atlas,records

def build(action,source,frames,durations,out,expected_source=None,expected_frames=None,airborne=(),source_class="OWNER_SUPPLIED_UNAUTHENTICATED"):
    check(source_class in ("OWNER_SUPPLIED_UNAUTHENTICATED","SYNTHETIC_TEST_ONLY"),"SOURCE_CLASS")
    check(not out.exists(),'OUTPUT_EXISTS')
    atlas,records=validate(action,source,frames,durations,expected_source,expected_frames,airborne)
    out.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(dir=out.parent) as tmp:
        root=Path(tmp)/'bundle';root.mkdir()
        atlas.save(root/'body.png');shutil.copyfile(source,root/'source.bin')
        for i,p in enumerate(frames): shutil.copyfile(p,root/f'F{i+1:02d}.png')
        # Re-read staged bytes and enforce exact atlas parity.
        for i,rec in enumerate(records):
            p=root/f'F{i+1:02d}.png';check(sha(p)==rec['sha256'],'STAGED_HASH')
            with Image.open(p) as im: check(atlas.crop((i%4*64,i//4*64,i%4*64+64,i//4*64+64)).tobytes()==im.tobytes(),'ATLAS_PARITY')
        check(sha(root/'source.bin')==sha(source),'STAGED_SOURCE')
        manifest={'schema':1,'action':action,'body_only':True,'source_class':source_class,'source_sha256':sha(source),'atlas_sha256':sha(root/'body.png'),'frame_count':len(frames),'cell':64,'columns':4,'atlas_size':list(atlas.size),'anchor':[32,50],'loop':MODES[action],'durations_ms':durations,'airborne_frames':list(airborne),'frames':records,'events':[],'art':'HOLD','gameplay':'NOT_RUN'}
        (root/'motion.json').write_text(json.dumps(manifest,indent=2)+'\n')
        root.rename(out)
    return manifest

def main():
    p=argparse.ArgumentParser();p.add_argument('--action',required=True);p.add_argument('--source',type=Path,required=True);p.add_argument('--frames',type=Path,nargs='+',required=True);p.add_argument('--durations',type=int,nargs='+',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--pins',type=Path,required=True);p.add_argument('--airborne',type=int,nargs='*',default=[]);a=p.parse_args();pins=json.loads(a.pins.read_text());print(json.dumps(build(a.action,a.source,a.frames,a.durations,a.out,pins['source_sha256'],pins['frame_sha256'],a.airborne),indent=2))
if __name__=='__main__': main()
