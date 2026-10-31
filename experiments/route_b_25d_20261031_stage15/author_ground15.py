#!/usr/bin/env python3
"""Stage15 quilting: sample old independent Style-first Ground pixels, minimum-error 2D overlap cut.
This derives NEW ROAD LAYOUT from prior private artwork; it is NOT brand-new AI painting.
"""
from pathlib import Path
from PIL import Image
import numpy as np, hashlib, json
R=Path(__file__).resolve().parent
S=R/'source';E=R/'evidence';E.mkdir(exist_ok=True)
src=S/'ground_stage12_source.png'
im=np.asarray(Image.open(src).convert('RGB'),dtype=np.uint8)
H,W=im.shape[:2];assert (W,H)==(544,576)
r,g,b=np.moveaxis(im.astype(np.float32),-1,0)
soil=(r>g*1.14)&(r>b*1.8)&(r>105)&(g>70)
PATCH=80;STEP=56;OVERLAP=PATCH-STEP
rng=np.random.default_rng(15147)
candidates={'grass':[],'earth':[]}
for y in range(0,H-PATCH+1,5):
 for x in range(0,W-PATCH+1,5):
  frac=float(soil[y:y+PATCH,x:x+PATCH].mean())
  if frac<.018:candidates['grass'].append((x,y))
  if frac>.95:candidates['earth'].append((x,y))
assert len(candidates['grass'])>40 and len(candidates['earth'])>20,(len(candidates['grass']),len(candidates['earth']))

def min_cut(cost):
    """Top-to-bottom seam through an overlap array. Monotonic path, +/- 1 pixel/row."""
    h,w=cost.shape
    dp=cost.copy().astype(np.float64)
    back=np.zeros((h,w),np.int16)
    for y in range(1,h):
        p=dp[y-1]
        for x in range(w):
            x1=max(0,x-1);x2=min(w,x+2)
            k=x1+np.argmin(p[x1:x2])
            dp[y,x]+=p[k]
            back[y,x]=k
    path=np.zeros(h,np.int16)
    path[-1]=int(np.argmin(dp[-1]))
    for y in range(h-2,-1,-1):path[y]=back[y+1,path[y+1]]
    return path

def seam_quilt(kind,seed):
    rg=np.random.default_rng(seed)
    out=np.zeros_like(im);covered=np.zeros((H,W),bool)
    selections=[];recent=[]
    for oy in range(0,H,STEP):
     for ox in range(0,W,STEP):
      height=min(PATCH,H-oy);width=min(PATCH,W-ox)
      arr=out[oy:oy+height,ox:ox+width];seen=covered[oy:oy+height,ox:ox+width]
      left=0 if ox==0 else min(OVERLAP,width)
      top=0 if oy==0 else min(OVERLAP,height)
      avail=candidates[kind]
      ids=rg.choice(len(avail),size=min(26,len(avail)),replace=False)
      scores=[]
      for t in ids:
       sx,sy=avail[int(t)]
       candidate=im[sy:sy+height,sx:sx+width]
       if seen.any():
        # Search similar edges to minimize repeat and abrupt hard joins.
        cost=np.abs(candidate.astype(np.int16)-arr.astype(np.int16)).mean(axis=2)
        first=cost[:,:left].mean() if left else 0
        second=cost[:top,:].mean() if top else 0
        err=(first+second)/(int(bool(left))+int(bool(top)))
       else:err=0
       repeat=sum(1 for old in recent[-15:] if np.hypot(old[0]-sx,old[1]-sy)<70)
       scores.append(float(err)+repeat*5.5+rg.random()*3.0)
      best=int(ids[int(np.argmin(scores))])
      sx,sy=avail[best]
      patch=im[sy:sy+height,sx:sx+width]
      accepted=np.ones((height,width),bool)
      if left:
       difference=np.abs(arr[:,:left].astype(np.int16)-patch[:,:left].astype(np.int16)).mean(axis=2)
       vertical=min_cut(difference)
       for row,k in enumerate(vertical):accepted[row,:int(k)+1]=False
      if top:
       diff=np.abs(arr[:top].astype(np.int16)-patch[:top].astype(np.int16)).mean(axis=2)
       horizontal=min_cut(diff.T)
       for col,k in enumerate(horizontal):accepted[:int(k)+1,col]=False
      accepted|=~seen
      arr[accepted]=patch[accepted]
      seen[:]=True
      recent.append((sx,sy))
      selections.append({'target':[ox,oy],'donor':[sx,sy],'type':kind})
    assert covered.all()
    return out,selections

grass,g_meta=seam_quilt('grass',15153)
earth,e_meta=seam_quilt('earth',15179)
ys,xs=np.indices((H,W),dtype=np.float32)
# New road plan, deliberately distinct from both Stage12 and Stage14.
center=183+57*np.sin(ys/101+0.31)+11*np.sin(ys/34+.74)
width=38+7*np.sin(ys/76)+3*np.cos(ys/29)
jitter=np.random.default_rng(15195).normal(0,1.2,(H,W))
main=np.abs(xs-center)<width+jitter
branch=(ys>240)&(ys<495)&(np.abs(xs-(center+(ys-240)*.64))<13+2.2*jitter)
road=main|branch
# Sparse isolated edge pebbles remain in Ground. No tall objects generated.
out=np.where(road[...,None],earth,grass).astype(np.uint8)
Image.fromarray(out,'RGB').save(S/'ground_long.png')
Image.fromarray((road*255).astype(np.uint8),'L').save(S/'PATH_SEMANTIC_MASK.png')
Image.fromarray(np.full((H,W),255,dtype=np.uint8),'L').save(S/'WALKABLE_MASK.png')
data={
 'artifact':'stage15 independent ground from Stage12 private source texture, original road geometry',
 'source_type':'DERIVED_FROM_USER_PRIVATE_2D_SOURCE_NOT_NEW_AI_IMAGE',
 'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),
 'output_sha256':hashlib.sha256((S/'ground_long.png').read_bytes()).hexdigest(),
 'source_size':[W,H],'patch_size':PATCH,'stride':STEP,'overlap':OVERLAP,
 'quilt':'min-error dynamic-programmed left/top overlap cuts; candidate selection balances color seam and donor repetition',
 'donor_candidates':{k:len(v) for k,v in candidates.items()},
 'placements':{'grass':len(g_meta),'earth':len(e_meta)},
 'path_pct':round(100*float(road.mean()),3),
 'visual':'RESEARCH CANDIDATE - repetitive object-free texture under inspection',
 'high_objects':0,'tree_trunks':0,'houses':0,'full_scene_reverse_crops':0,
 'formal_seal':False,'license':'Private R&D only'
}
(E/'STAGE15_SOURCE_LEDGER.json').write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps(data,indent=2,ensure_ascii=False),flush=True)