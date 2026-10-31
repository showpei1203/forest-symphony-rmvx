from PIL import Image,ImageDraw
from pathlib import Path
import numpy as np,json
r=Path(__file__).resolve().parent
body=Image.new('L',(32,32),0)
p=ImageDraw.Draw(body)
for (x,y,w,h) in [(9,14,17,13),(12,5,12,12),(9,4,15,6),(11,25,6,6),(20,25,6,6)]:
 p.rectangle((x,y,x+w-1,y+h-1),fill=255)
bm=np.asarray(body)>0
result={}
for sid in ('A_BLUE_COTTAGE','B_OCHRE_GROVE'):
 p=r/'build'/sid
 mani=json.loads((p/'SCENE_MANIFEST.json').read_text())
 obj=next(x for x in mani['objects'] if x['layer']=='SPLIT_TREE32')
 par=np.asarray(Image.open(p/'PAR.png').getchannel('A'))>0
 foot=obj['actor_foot']
 rows=[]
 for dy in (-48,-32,-16,0,16,32,48):
  for dx in (-24,-12,0,12,24):
   x=foot[0]+dx-16;y=foot[1]+dy-31
   mask=np.zeros_like(par)
   if x>=0 and y>=0 and x+32<=544 and y+32<=416:
    mask[y:y+32,x:x+32]=bm
   pixels=int(mask.sum())
   obscured=int(np.sum(mask&par))
   rows.append({'dx':dx,'dy':dy,'covered_pct':round(obscured/max(1,pixels)*100,2),'covered_px':obscured})
 front=[x for x in rows if x['dy'] in (16,32)]
 result[sid]={'sample_count':len(rows),'foot_xy':foot,'front_nonzero':sum(x['covered_px']>0 for x in front),'front_max_pct':max(x['covered_pct'] for x in front),'front_failures':[x for x in front if x['covered_px']>0],'fixed_position':{str(k):next(x['covered_pct'] for x in rows if x['dy']==k and x['dx']==0) for k in (-16,0,16)},'rows':rows}
print(json.dumps({k:{x:y for x,y in v.items() if x!='rows'} for k,v in result.items()},indent=2))
(r/'evidence'/'STAGE12_ACTOR_SWEEP.json').write_text(json.dumps(result,indent=2),encoding='utf8')