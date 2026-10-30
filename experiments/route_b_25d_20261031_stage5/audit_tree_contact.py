from PIL import Image,ImageDraw
import numpy as np,json,pathlib
r=pathlib.Path(__file__).resolve().parent/'out'
p=Image.open(r/'TREE_CONTACT_MASK.png').convert('RGBA')
a=np.asarray(p.getchannel('A'))
m=(a>0)
parts=[]
for name,xlo,xhi in [('WEST',0,272),('EAST',272,544)]:
 yy,xx=np.where(m[:,xlo:xhi])
 xx=xx+xlo
 if len(xx)==0:
  parts.append({'name':name,'result':'FAIL_EMPTY'})
  continue
 xmin,xmax,ymin,ymax=int(xx.min()),int(xx.max()),int(yy.min()),int(yy.max())
 rect=[xmin,ymin,xmax,ymax]
 tilex=np.unique(xx//32).tolist()
 tiley=np.unique(yy//32).tolist()
 passed=(len(tilex)==1 and len(tiley)==1)
 parts.append(dict(name=name,rect=rect,width_px=xmax-xmin+1,height_px=ymax-ymin+1,opaque_pixel_count=int(len(xx)),tiles_x=tilex,tiles_y=tiley,within_one_32px_tile=passed))
# Create transparent tree-contact preview over preview with 32x32 grid.
im=Image.open(r/'GROUND.png').convert('RGB')
dr=ImageDraw.Draw(im,'RGBA')
for x in range(0,544,32):dr.line((x,0,x,415),fill=(50,44,64,115),width=1)
for y in range(0,416,32):dr.line((0,y,543,y),fill=(50,44,64,115),width=1)
for row in parts:
 if 'rect' in row:
  x0,y0,x1,y1=row['rect']
  dr.rectangle((x0-2,y0-2,x1+2,y1+2),outline=(229,65,91,255) if not row['within_one_32px_tile'] else (245,236,96,255),width=2)
im.save(r/'CONTACT_32_GRID_AUDIT.png')
summary={'contact_image_mode':p.mode,'alpha_zero':int(np.sum(a==0)),'source_is_separate_layer':True,'cut_world_y':0.56,'trees':parts,'one_tile_pass':all(x.get('within_one_32px_tile') for x in parts),'formal_seal':False}
(r/'CONTACT_32_GRID_AUDIT.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,indent=2),flush=True)