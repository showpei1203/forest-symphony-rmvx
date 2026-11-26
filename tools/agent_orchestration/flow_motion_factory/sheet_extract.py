"""Extract a calibrated magenta-background pose sheet; no interpolation or new art.
Calibration is explicit per sheet: never assume gutters or grid are identical across generations.
"""
from pathlib import Path
from PIL import Image
import numpy as np
import argparse, hashlib, json, tempfile

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,reason):
    if not ok: raise ValueError(reason)
def grid(profile,offset,lo,hi):
    t=np.arange(len(profile))+offset
    f=np.linspace(1/hi,1/lo,500);v=np.exp(-2j*np.pi*f[:,None]*t)@profile
    k=np.argmax(abs(v));p=1/f[k]
    require(np.isfinite(p) and abs(v[k])>0,'GRID_NO_SIGNAL')
    return p,(-np.angle(v[k])*p/(2*np.pi))%p

def extract(src,plan,out):
    require(not out.exists(),'OUTPUT_EXISTS')
    require(sha(src)==plan['source_sha256'],'SOURCE_HASH')
    with Image.open(src) as im:
        require(im.format in ('JPEG','PNG') and list(im.size)==plan['dimensions'] and max(im.size)<=4096,'SOURCE_FORMAT')
        a=np.asarray(im.convert('RGB')).astype(float)
    h,w=a.shape[:2];n=len(plan['roots_x']);require(4<=n<=16 and len(plan['cuts'])==n+1 and len(plan['target_bottom_y'])==n,'PLAN_COUNT')
    lo,hi=plan['pitch_range'];require(2<=lo<hi<=30,'PITCH_RANGE')
    reference_y=plan['reference_y'];require(0<=reference_y<h,'REF_Y')
    y,x=np.indices((h,w));bounds=[]
    for c in plan['cuts']:
        if type(c)is int: bounds.append(np.full((h,1),c))
        else:
            require(set(c)=={'y','above','below'} and all(type(v)is int for v in c.values()) and 0<c['y']<h,'CUT_FORMAT')
            bounds.append(np.where(y[:,:1]<c['y'],c['above'],c['below']))
    require(np.all(bounds[0]==0) and np.all(bounds[-1]==w) and all(np.all(b>a) for a,b in zip(bounds,bounds[1:])),'CUT_ORDER')
    for i,root in enumerate(plan['roots_x']):
        require(type(root)is int and np.all(bounds[i]<root) and np.all(root<bounds[i+1]),'ROOT_OUTSIDE_SLOT')
    require(all(type(v)is int and 20<=v<=49 for v in plan['target_bottom_y']),'TARGET_BOTTOM')
    r,g,b=a.transpose(2,0,1);mask=~((r>140)&(b>110)&(g<110)&(r-g>70)&(b-g>60))
    require(np.count_nonzero(mask)<w*h*0.65,'NOT_MAGENTA_SHEET')
    frames=[];stats=[]
    for i in range(n):
        m=mask&(x>=bounds[i])&(x<bounds[i+1]);ys,xs=np.where(m)
        require(len(xs)>0,'EMPTY_POSE')
        x0,x1=xs.min(),xs.max()+1;y0,y1=ys.min(),ys.max()+1
        dx=np.linalg.norm(np.diff(a,axis=1),axis=2)*(m[:,1:]&m[:,:-1]);dy=np.linalg.norm(np.diff(a,axis=0),axis=2)*(m[1:]&m[:-1]);px,phx=grid(dx.sum(0),.5,lo,hi);py,phy=grid(dy.sum(1),.5,lo,hi)
        xx=np.arange(np.floor((x0-phx)/px)-1,np.ceil((x1-phx)/px)+1)*px+phx+px/2
        yy=np.arange(np.floor((y0-phy)/py)-1,np.ceil((y1-phy)/py)+1)*py+phy+py/2
        xi=np.rint(xx).astype(int);yi=np.rint(yy).astype(int);frame=np.zeros((64,64,4),np.uint8)
        for j,cy in enumerate(yi):
            for k,cx in enumerate(xi):
                if not(0<=cx<w and 0<=cy<h):continue
                yy0,yy1=max(0,cy-1),min(h,cy+2);xx0,xx1=max(0,cx-1),min(w,cx+2);sub=m[yy0:yy1,xx0:xx1]
                if sub.mean()<.6:continue
                rgb=np.median(a[yy0:yy1,xx0:xx1][sub],axis=0).astype(np.uint8)
                tx=32+int(np.floor((xx[k]-plan['roots_x'][i])/px+.5));ty=49+int(np.floor((yy[j]-reference_y)/py+.5))
                require(0<=tx<64 and 0<=ty<64,'CELL_CLIP')
                frame[ty,tx]=[*rgb,255]
        rgb=frame[:,:,:3].astype(float);excess=np.minimum(rgb[:,:,0]-rgb[:,:,1],rgb[:,:,2]-rgb[:,:,1]);pink=(frame[:,:,3]>0)&(excess>15)
        t=np.clip(excess[pink]/255,0,.70)[:,None];rgb[pink]=np.clip((rgb[pink]-t*np.array([255,0,255]))/(1-t),0,255);frame[:,:,:3]=np.rint(rgb).astype(np.uint8)
        rows=np.where(frame[:,:,3]>0)[0];require(len(rows)>0,'EMPTY_RESTORE');shift=plan['target_bottom_y'][i]-int(rows.max())
        require(rows.min()+shift>0 and rows.max()+shift<64,'SHIFT_CLIP')
        if shift>0: frame[shift:]=frame[:-shift].copy();frame[:shift]=0
        elif shift<0: frame[:shift]=frame[-shift:].copy();frame[shift:]=0
        im=Image.fromarray(frame);bb=im.getbbox();require(bb and bb[0]>0 and bb[2]<64 and bb[3]==plan['target_bottom_y'][i]+1,'BBOX')
        frames.append(im);stats.append({'source_bbox':[int(x0),int(y0),int(x1),int(y1)],'grid_pitch':[round(px,3),round(py,3)],'bbox':list(bb),'decontaminated':int(pink.sum()),'vertical_alignment_px':shift})
    require(len({im.tobytes() for im in frames})==n,'DUPLICATE_POSE')
    out.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(dir=out.parent) as tmp:
        d=Path(tmp)/'output';d.mkdir()
        for i,im in enumerate(frames):
            p=d/f'F{i+1:02d}.png';im.save(p);stats[i]['sha256']=sha(p)
        result={'source_sha256':sha(src),'frames':stats,'frame_sha256':[x['sha256'] for x in stats],'method':'CALIBRATED_LATTICE_NO_INTERPOLATION','art':'HOLD'}
        (d/'pins.json').write_text(json.dumps(result,indent=2)+'\n');d.rename(out)
    return result

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('plan',type=Path);p.add_argument('out',type=Path);a=p.parse_args();print(json.dumps(extract(a.source,json.loads(a.plan.read_text()),a.out),indent=2))
