from pathlib import Path
from PIL import Image,ImageDraw
import os,json,hashlib,math,random
from collections import Counter, deque
BASE=Path(os.environ.get('FS_A36_PROJECT','/mnt/data/fs_godot_a36'))
m=json.loads((BASE/'data/a36_large_verdant_forest_manifest.json').read_text())
c=json.loads((BASE/'data/a36_terrain_semantic_candidates.json').read_text())
def sh(fp):return hashlib.sha256(fp.read_bytes()).hexdigest()
checks=0
fail=[]
def gate(ok,what):
 global checks
 if ok:checks+=1
 else:fail.append(what)
 return ok
src=BASE/'private_assets'/m['source_ground']['file']; ground=BASE/'private_assets'/m['runtime_ground']['file'];shade=BASE/'private_assets'/m['shadow']['file']
gate(src.exists() and sh(src)==m['source_ground']['sha256'],'source Ground SHA')
gate(ground.exists() and sh(ground)==m['runtime_ground']['sha256'],'runtime Ground SHA')
gate(shade.exists() and sh(shade)==m['shadow']['sha256'],'shadow independent SHA')
gate(Image.open(src).size==(1478,1064),'real source native dimensions (non-32)')
gate(Image.open(ground).size==(2560,1856),'actual runtime map dimensions')
gate(Image.open(shade).mode=='RGBA','shadow separate alpha')
gate(m['world_px']==[2560,1856] and m['logical_grid']==[80,58],'world semantics')
gate(len(m['objects'])==326 and m['object_count']==326,'326 real independent objects')
gate(len(m['assets'])==9,'9 original complete PAR asset families')
old=BASE/'private_assets/ground_only.png'
gate(sh(ground)!=sh(old),'A36 not recycled A34 Ground')
sourceimg=Image.open(src).convert('RGB')
runtimeimg=Image.open(ground).convert('RGB')
# Exact closest-neighbor mapping and not bilinear. This proves derivation, not native 32x authored origin.
samples=random.Random(360058)
for i in range(300):
 x=samples.randrange(2560);y=samples.randrange(1856)
 sx=min(1477,int((x+.5)*1478/2560));sy=min(1063,int((y+.5)*1064/1856))
 gate(runtimeimg.getpixel((x,y))==sourceimg.getpixel((sx,sy)),f'nearest-source parity #{i}')
for name,a in m['assets'].items():
 p=BASE/a['file'].replace('res://','')
 gate(p.exists() and sh(p)==a['sha'],'real complete independent '+name)
 im=Image.open(p)
 gate(im.mode=='RGBA' and im.size==(a['w'],a['h']),'alpha & dimension '+name)
for o in m['objects']:
 gate(o['family'] in m['assets'],'complete source membership '+o['id'])
 gate(o['asset_sha256']==m['assets'][o['family']]['sha'],'provenance source SHA '+o['id'])
 gate(len(o['foot'])==2,'foot coordinate '+o['id'])
 gate(o['footprint'][0]<m['assets'][o['family']]['w'],'root less than canopy '+o['id'])
# Semantic water is only a candidate at 32px. Approximate feet vs water BFS must be logged, not art claim.
W,H=80,58
blocked=set(tuple(x) for x in c['river_blocked_cells'])
for o in m['objects']:
 x,y=o['foot'];fx,fy=o['footprint']
 for cy in range(max(0,int((y-fy)/32)),min(H,int((y+fy)/32)+1)):
  for cx in range(max(0,int((x-fx*.5)/32)),min(W,int((x+fx*.5)/32)+1)):
   xx=(cx+.5)*32;yy=(cy+.5)*32
   if x-fx/2<=xx<=x+fx/2 and y-fy<=yy<=y:blocked.add((cx,cy))
# Even if topology is connected, it is not an approved gameplay-collision map.
free={(x,y) for y in range(H) for x in range(W)}-blocked
components=[]
while free:
 start=next(iter(free));free.remove(start);q=deque([start]);n=0
 while q:
  x,y=q.popleft();n+=1
  for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
   if (nx,ny) in free:free.remove((nx,ny));q.append((nx,ny))
 components.append(n)
components.sort(reverse=True)
# Export visual candidate collision alpha OVER Ground for designer inspection (no modification to Ground file)
img=runtimeimg.copy().convert('RGBA');overlay=Image.new('RGBA',img.size,(0,0,0,0));d=ImageDraw.Draw(overlay)
river=set(tuple(x) for x in c['river_blocked_cells'])
for x,y in blocked:
 fill=(255,63,68,90) if (x,y) not in river else (48,105,255,120)
 d.rectangle([x*32,y*32,x*32+31,y*32+31],fill=fill)
for x in range(0,2561,32):
 if x%256==0:d.line((x,0,x,1856),fill=(255,255,255,25))
for y in range(0,1857,32):
 if y%256==0:d.line((0,y,2560,y),fill=(255,255,255,25))
merged=Image.alpha_composite(img,overlay)
merged.save(BASE/'qa_a36/A36_TERRAIN_SEMANTICS_CANDIDATE_NOT_ART.png',optimize=True)
# True full image has different individual large-scale quadrants; this is NOT a formal image originality certification.
quarters=[runtimeimg.crop((i*1280,j*928,(i+1)*1280,(j+1)*928)).resize((40,29),Image.Resampling.BILINEAR) for j in range(2) for i in range(2)]
mae=[]
import numpy as np
for i in range(4):
 for j in range(i+1,4):
  a=np.asarray(quarters[i],dtype=np.int16);b=np.asarray(quarters[j],dtype=np.int16)
  mae.append(round(float(np.abs(a-b).mean()),2))
gate(min(mae)>8.0,'unique quadrant large-scale appearances not identical')
report={"status":"TECH_QA_PASS_ART_HOLD" if not fail else "FAIL", "checks":checks,"fails":fail,"objects":m['counts'],"water_only_candidate_cells":len(river),"total_candidate_blocked_cells":len(blocked),"candidate_free_cells":80*58-len(blocked),"largest_connected_candidate_free_component":components[0],"candidate_components":len(components),"quadrant_pair_mae":mae,"original_image_dimensions":[1478,1064],"runtime_dimensions":[2560,1856],"pixel_scale":{"x":2560/1478,"y":1856/1064},"native_godot_verified_separately":True,"art":"HOLD","collision":"CANDIDATE_NOT_APPROVED"}
(BASE/'qa_a36/A36_SOURCE_AND_TOPOLOGY_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print(json.dumps(report,ensure_ascii=False,indent=2))
if fail:exit(2)
