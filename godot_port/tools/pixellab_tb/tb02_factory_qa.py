#!/usr/bin/env python3
"""Shared T-B sprite QA: procedural and PixelLab outputs; not an ART approval.
Check formats, frame identity, border touches, stage silhouettes and cost metadata.
"""
import argparse,json,hashlib
from pathlib import Path
from PIL import Image
import numpy as np
P=argparse.ArgumentParser();P.add_argument('--project',required=True);P.add_argument('--output',required=True);a=P.parse_args()
root=Path(a.project);asset=root/'assets/monsters/tb02';m=json.loads((root/'TB02_LEAF_BAT_MANIFEST.json').read_text())
report={'schema':'fs-tb02-bat-technical-qa-v1','source_id':'TB02_LEAF_BAT','engine':'Godot 4.7.2','results':{},'warnings':[],'features':{}}
def status(name,ok,details):report['results'][name]={'pass':bool(ok),'details':details}
images=[]
for idx,s in enumerate(m['stages'],1):
 path=root/s['path'];image=Image.open(path).convert('RGBA');images.append(image)
 arr=np.asarray(image.getchannel('A'))>0
 status('stage%d_dims'%idx,list(image.size)==s['size'],{'expected':s['size'],'actual':list(image.size)})
 status('stage%d_nonempty'%idx,arr.sum()>300,{'visible_pixels':int(arr.sum()),'bbox':image.getbbox()})
 edge=int(arr[0].sum()+arr[-1].sum()+arr[:,0].sum()+arr[:,-1].sum())
 if edge:report['warnings'].append({'kind':'STAGE_EDGE_TOUCH','stage':idx,'pixels':edge})
for i in range(2):
 a0,b0=images[i],images[i+1];sz=max(a0.width,b0.width,160)
 canvas_a=Image.new('RGBA',(sz,sz));canvas_b=Image.new('RGBA',(sz,sz))
 canvas_a.alpha_composite(a0,((sz-a0.width)//2,(sz-a0.height)//2))
 canvas_b.alpha_composite(b0,((sz-b0.width)//2,(sz-b0.height)//2))
 A=np.asarray(canvas_a.getchannel('A'))>0;B=np.asarray(canvas_b.getchannel('A'))>0
 iou=float(np.logical_and(A,B).sum()/np.logical_or(A,B).sum())
 status('stage%d_%d_morphology'%(i+1,i+2),iou<.75,{'silhouette_iou':round(iou,5),'threshold':.75,'opaque_area_ratio':round(B.sum()/A.sum(),4)})
for motion,expected in [('idle',8),('attack',11)]:
 cfg=m[motion];tex=Image.open(root/cfg['path']).convert('RGBA');w,h=cfg['cell'];n=cfg['frames'];columns=cfg['columns']
 status(motion+'_atlas_dimensions',tex.size==(w*columns,h*((n+columns-1)//columns)),{'actual':list(tex.size),'expected':[w*columns,h*((n+columns-1)//columns)]})
 seen=set();edges=[];frame_boxes=[]
 for i in range(n):
  f=tex.crop(((i%columns)*w,(i//columns)*h,(i%columns+1)*w,(i//columns+1)*h))
  seen.add(hashlib.sha256(f.tobytes()).hexdigest())
  mask=np.asarray(f.getchannel('A'))>0
  edges.append(int(mask[0].sum()+mask[-1].sum()+mask[:,0].sum()+mask[:,-1].sum()))
  frame_boxes.append(f.getbbox())
 status(motion+'_distinct_frames',len(seen)==expected,{'expected':expected,'distinct':len(seen)})
 status(motion+'_nonempty_frames',all(x is not None for x in frame_boxes),{'nonempty':sum(x is not None for x in frame_boxes)})
 report['features'][motion+'_edge_contact_by_frame']=edges
 if any(edges):report['warnings'].append({'kind':'MOTION_EDGE_TOUCH','motion':motion,'frames':[i for i,e in enumerate(edges) if e],'counts':edges})
status('event_compatibility',m['attack']['rush']==2 and m['attack']['hit']==5 and m['attack']['return']==7,{'event_indices':[m['attack']['rush'],m['attack']['hit'],m['attack']['return']]})
spent=sum(x['generations'] for x in m['provider_jobs'])
status('documented_cost',spent==m['cost_this_family_generations'],{'sum':spent,'declared':m['cost_this_family_generations']})
report['checked_total']=len(report['results']);report['passed_total']=sum(x['pass'] for x in report['results'].values());report['technical_pass']=report['checked_total']==report['passed_total'];report['art_approved']=False
Path(a.output).write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
print('TB02_PYTHON_QA',report['passed_total'],'/',report['checked_total'],'TECH',report['technical_pass'],'WARN',report['warnings'])
if not report['technical_pass']:raise SystemExit(1)
