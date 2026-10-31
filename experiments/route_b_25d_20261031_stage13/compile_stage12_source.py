from PIL import Image,ImageDraw
from pathlib import Path
import hashlib,json,numpy as np
root=Path(__file__).resolve().parent
W,H=544,416
scenes={
 'A_BLUE_COTTAGE':{'ground_roi':[0,0,544,416],'items':[
  {'id':'house_blue','source':'house_blue.png','xy':[34,94],'layer':'PAR'},
  {'id':'tree_moss','source':'tree_moss.png','xy':[346,30],'layer':'SPLIT_TREE32'},
  {'id':'well','source':'well.png','xy':[392,290],'layer':'PAR'},
  {'id':'sign','source':'sign.png','xy':[268,344],'layer':'PAR'},
  {'id':'hedge','source':'hedge.png','xy':[8,333],'layer':'PAR'}]},
 'B_OCHRE_GROVE':{'ground_roi':[0,160,544,576],'items':[
  {'id':'house_ochre','source':'house_ochre.png','xy':[20,153],'layer':'PAR'},
  {'id':'sacred_tree','source':'sacred_tree.png','xy':[294,32],'layer':'SPLIT_TREE32'},
  {'id':'well','source':'well.png','xy':[326,310],'layer':'PAR'},
  {'id':'sign','source':'sign.png','xy':[241,321],'layer':'PAR'},
  {'id':'hedge','source':'hedge.png','xy':[14,333],'layer':'PAR'}]}
}
tree_parts={}
for name in ['tree_moss.png','sacred_tree.png']:
 src=Image.open(root/'source'/name).convert('RGBA')
 arr=np.asarray(src).copy()
 mask=np.zeros((src.height,src.width),dtype=bool)
 x0=src.width//2-16;y0=src.height-32
 mask[y0:y0+32,x0:x0+32]=True
 bottom=np.zeros((src.height,src.width),dtype=bool)
 bottom[y0:src.height,:]=True
 decorative=bottom & ~mask
 base=arr.copy();base[~mask,:]=0
 decal=arr.copy();decal[~decorative,:]=0
 upper=arr.copy();upper[bottom,:]=0
 parts=root/'parts'/name.replace('.png','')
 parts.mkdir(parents=True,exist_ok=True)
 Image.fromarray(base,'RGBA').save(parts/'BASE_32.png')
 Image.fromarray(decal,'RGBA').save(parts/'ROOT_DECAL_GROUND.png')
 Image.fromarray(upper,'RGBA').save(parts/'PAR_UPPER.png')
 result=Image.alpha_composite(Image.alpha_composite(Image.fromarray(base),Image.fromarray(decal)),Image.fromarray(upper))
 assert np.array_equal(np.asarray(result),arr)
 tree_parts[name]={'base_local_roi':[x0,y0,x0+32,y0+32],'source_sha256':hashlib.sha256((root/'source'/name).read_bytes()).hexdigest(),
 'base_alpha_pixels':int(np.sum(base[:,:,3]>0)), 'root_decal_alpha_pixels':int(np.sum(decal[:,:,3]>0)), 'upper_alpha_pixels':int(np.sum(upper[:,:,3]>0))}
(root/'parts'/'TREE_SPLIT_LEDGER.json').write_text(json.dumps(tree_parts,indent=2),encoding='utf-8')
manifest={}
for sid,scene in scenes.items():
 d=root/'build'/sid;d.mkdir(parents=True,exist_ok=True)
 ground=Image.open(root/'source'/'ground_long.png').convert('RGB').crop(scene['ground_roi']).convert('RGBA')
 assert ground.size==(W,H)
 ground.putalpha(255)
 par=Image.new('RGBA',(W,H))
 contact=Image.new('RGBA',(W,H))
 objs=[]
 for obj in scene['items']:
  src=root/'source'/obj['source']
  full=Image.open(src).convert('RGBA')
  x,y=obj['xy']
  assert x>=0 and y>=0 and x+full.width<=W and y+full.height<=H,(sid,obj)
  if obj['layer']=='SPLIT_TREE32':
   base=Image.open(root/'parts'/obj['source'].replace('.png','')/'BASE_32.png').convert('RGBA')
   upper=Image.open(root/'parts'/obj['source'].replace('.png','')/'PAR_UPPER.png').convert('RGBA')
   decal=Image.open(root/'parts'/obj['source'].replace('.png','')/'ROOT_DECAL_GROUND.png').convert('RGBA')
   ground.alpha_composite(base,(x,y))
   ground.alpha_composite(decal,(x,y))
   contact.alpha_composite(base,(x,y))
   par.alpha_composite(upper,(x,y))
   bx0,by0,bx1,by1=tree_parts[obj['source']]['base_local_roi']
   actor=[x+(bx0+bx1)//2,y+by1-1]
   rect=[x+bx0,y+by0,x+bx1,y+by1]
   assert rect[0]//32==(rect[2]-1)//32 and rect[1]//32==(rect[3]-1)//32,('tile cross',rect)
   obj.update({'root_tile':[rect[0]//32,rect[1]//32],'contact_rect':rect,'actor_foot':actor,'split_source':obj['source']})
  else:par.alpha_composite(full,(x,y))
  objs.append({**obj,'sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'size':[full.width,full.height],
    'alpha_zero':int(np.sum(np.asarray(full.getchannel('A'))==0)),
    'alpha_semi':int(np.sum((np.asarray(full.getchannel('A'))>0)&(np.asarray(full.getchannel('A'))<255)))})
 full=Image.alpha_composite(ground,par)
 for name,im in [('GROUND.png',ground.convert('RGB')),('PAR.png',par),('TREE_CONTACT_MASK.png',contact),('COMPOSITE.png',full.convert('RGB'))]:
  im.save(d/name)
 meta={'scene':sid,'size':[W,H],'ground_source':'ground_long.png','ground_original_roi':scene['ground_roi'],
    'source_type':'Original AI generated independent ground and separate source sprites from PRIVATE pre-existing FS Style-first project, no cut from completed master','objects':objs,
    'render_order':'GROUND -> 32x32 ACTOR -> PAR','approved_for_public_distribution':False,'art_pass':None,'formal_seal':False}
 (d/'SCENE_MANIFEST.json').write_text(json.dumps(meta,indent=2,ensure_ascii=False),encoding='utf-8')
 manifest[sid]=meta
print(json.dumps({'scenes':{k:{'count':len(v['objects']), 'size':v['size'],'ground_roi':v['ground_original_roi']} for k,v in manifest.items()},'trees':tree_parts},indent=2,ensure_ascii=False))