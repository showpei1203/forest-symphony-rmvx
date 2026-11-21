#!/usr/bin/env python3
"""Offline rigorous QA for source-locked T-B V4 palette + event contract.
Does NOT substitute for Godot 4.7.2 native rendering or human art approval.
"""
from PIL import Image
from pathlib import Path
import numpy as np
import json
import hashlib

HERE=Path(__file__).resolve().parent
SRC=HERE/'assets/monsters/tb/PMD0001_STATIC_64.png'
RAW=HERE/'assets/monsters/tb/PMD0001_ATTACK_V4_11F_384x288.png'
PAL=HERE/'assets/monsters/tb/ATTACK_V4_SHARED_PALETTE_32.png'
EXPECTED_SHA='fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c'
DURATIONS=[4,2,4,2,2,2,2,2,2,2,4]
EVENTS={2:'rush',5:'hit',7:'return'}

class Timeline:
    def __init__(self): self.reset()
    def reset(self):
        self.t=0.;self.frame=0;self.active=False;self.events=[]
    def start(self):
        if self.active:return False
        self.reset();self.active=True;return True
    def cancel(self):self.reset()
    def tick(self,dt):
        if not self.active or dt<=0:return
        end=min(sum(DURATIONS),self.t+dt*60)
        boundaries=np.cumsum([0]+DURATIONS[:-1]).tolist()
        for i in range(self.frame+1,11):
            if boundaries[i]<=end+1e-5:
                self.frame=i
                if i in EVENTS:self.events.append(EVENTS[i])
            else:break
        self.t=end
        if self.active and self.t>=sum(DURATIONS)-1e-5:
            self.active=False;self.events.append('finished')

def build_result():
    tests={}
    tests['source_sha_lock']=hashlib.sha256(SRC.read_bytes()).hexdigest()==EXPECTED_SHA
    s=np.asarray(Image.open(SRC).convert('RGBA'))
    r=np.asarray(Image.open(RAW).convert('RGBA'))
    q=np.asarray(Image.open(PAL).convert('RGBA'))
    tests['atlas_size']=r.shape==q.shape==(288,384,4)
    tests['palette_has_exact_alpha']=np.array_equal(r[:,:,3],q[:,:,3])
    colors={tuple(px) for px in q[q[:,:,3]>0,:3]}
    tests['palette_max32']=len(colors)<=32
    base=np.zeros((96,96,4),dtype=np.uint8);base[24:88,16:80]=s
    cells=[r[(i//4)*96:((i//4)+1)*96,(i%4)*96:((i%4)+1)*96] for i in range(11)]
    palcells=[q[(i//4)*96:((i//4)+1)*96,(i%4)*96:((i%4)+1)*96] for i in range(11)]
    tests['frame0_source_locked']=np.array_equal(cells[0],base)
    tests['frame10_source_locked']=np.array_equal(cells[-1],base)
    tests['frame_count']=len(cells)==len(palcells)==11
    tests['all_sprites_nonempty']=all(np.any(c[:,:,3]>0) for c in cells)
    tests['transparent_border']=all((np.count_nonzero(c[0,:,3]) + np.count_nonzero(c[-1,:,3]) + np.count_nonzero(c[:,0,3])+np.count_nonzero(c[:,-1,3]))==0 for c in cells)
    tests['unique_inner_poses']=len({c.tobytes() for c in cells})==10
    tests['no_palette_geometry_regression']=all(np.array_equal(a[:,:,3],b[:,:,3]) for a,b in zip(cells,palcells))
    tests['durations_28_ticks']=sum(DURATIONS)==28
    tests['native_events_f2_f5_f7']=EVENTS=={2:'rush',5:'hit',7:'return'}
    t=Timeline();t.start();t.tick(1.)
    tests['low_fps_cannot_skip_hit']=t.events==['rush','hit','return','finished']
    t=Timeline();t.start()
    for i in range(30):t.tick(1/60)
    tests['60fps_same_event_order']=t.events==['rush','hit','return','finished']
    t=Timeline();t.start();t.tick(.09);t.cancel();t.tick(1.0)
    tests['cancel_before_rush_no_events']=not t.events
    t=Timeline();t.start();t.tick(.26); t.cancel();t.tick(1.)
    tests['cancel_after_hit_no_return']=not t.events
    t=Timeline();t.start()
    tests['active_start_does_not_restart']=not t.start()
    t.tick(1.); t.start();t.tick(1.)
    tests['repeat_attack_delivers_hit_once_per_run']=t.events==['rush','hit','return','finished']
    return tests,{'source_original_colors':len({tuple(px) for px in s[s[:,:,3]>0,:3]}),'palette_atlas_colors':len(colors)}

if __name__=='__main__':
    t,meta=build_result();result={'tests':t,'passed':sum(t.values()),'total':len(t),'measurements':meta,'visual_art':'HOLD','godot_native':'NOT_RUN'}
    print(json.dumps(result,indent=2))
    (HERE/'TB_ATTACK_TIMELINE_QA.json').write_text(json.dumps(result,indent=2))
    assert all(t.values()),'Regression gates failed'
