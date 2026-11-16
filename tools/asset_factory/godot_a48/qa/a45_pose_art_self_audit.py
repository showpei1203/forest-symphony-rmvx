from pathlib import Path
from PIL import Image,ImageDraw
import glob, math, json,hashlib
p=Path(__file__).resolve().parents[1]
a=p/'assets'
sbody=Image.open(a/'actor01_a44_body_12frames.png').convert('RGBA')
sweapon=Image.open(a/'actor01_a44_weapon_12frames.png').convert('RGBA')
sfx=Image.open(a/'actor01_a44_fx_12frames.png').convert('RGBA')
assert sbody.size==sweapon.size==sfx.size==(256,192)
body=Image.new('RGBA',(256,192))
weapon=sweapon.copy()
fx=Image.new('RGBA',(256,192))
# All coordinate pairs are the *actual* boot-pivot centers, not independent
# interpolated fake walk offsets. Each hold phase plants at least one foot.
STANCE={
 1:((30,49),(40,49)),2:((30,49),(40,49)),
 3:((30,49),(40,49)),4:((30,49),(40,49)),
 5:((30,49),(42,49)),6:((30,49),(44,49)),
 7:((30,49),(44,49)),8:((30,49),(43,49)),
 9:((30,49),(41,49)),10:((30,49),(40,49))
}
HIP={
 1:(34,43),2:(34,43),3:(34,43),4:(34,43),
 5:(35,43),6:(37,43),7:(37,43),8:(36,43),9:(35,43),10:(35,43)}
TAIL={4:1,5:1,6:2,7:2,8:1}
dark=(7,15,18,255)
deep=(12,31,30,255)
cloth=(24,64,57,255)
rim=(47,81,70,255)
boot=(91,68,53,255)
boot_light=(151,117,85,255)
edge=(53,46,38,255)
def tile(img,i):
 x=(i%4)*64;y=(i//4)*64
 return img.crop((x,y,x+64,y+64))
def place(sheet,cell,i):
 sheet.alpha_composite(cell,((i%4)*64,(i//4)*64))
def remove_isolated(im,threshold=14):
 pixels={(x,y) for y in range(64) for x in range(64) if im.getpixel((x,y))[3]>0}
 groups=[]
 while pixels:
  start=pixels.pop()
  group=[start]
  q=[start]
  while q:
   x,y=q.pop()
   for xx in range(x-1,x+2):
    for yy in range(y-1,y+2):
     if (xx,yy) in pixels:
      pixels.remove((xx,yy));q.append((xx,yy));group.append((xx,yy))
  groups.append(group)
 groups.sort(key=len,reverse=True)
 removed=[]
 for g in groups[1:]:
  if len(g)<=threshold:
   for xy in g:im.putpixel(xy,(0,0,0,0))
   removed.append({'px':len(g),'bbox':[min(x for x,y in g),min(y for x,y in g),max(x for x,y in g),max(y for x,y in g)]})
 return removed
def draw_boot(d,center,left):
 x,y=center
 # Short beveled, organic leather boot copied from A62 color family:
 # no full-width black rectangular shoes.
 if left:
  outline=[(x-3,y-1),(x-2,y-3),(x+1,y-3),(x+2,y-1),(x+2,y),(x-3,y)]
  inside=[(x-2,y-2),(x+1,y-2),(x+1,y-1),(x-2,y-1)]
  d.polygon(outline,fill=dark)
  d.polygon(inside,fill=boot)
  d.line([(x-3,y-1),(x,y-1)],fill=boot_light,width=1)
  d.point((x+1,y-2),fill=edge)
 else:
  outline=[(x-2,y-2),(x+1,y-3),(x+2,y-2),(x+3,y-1),(x+3,y),(x-2,y)]
  inside=[(x-1,y-2),(x+1,y-2),(x+2,y-1),(x+1,y-1),(x-1,y-1)]
  d.polygon(outline,fill=dark)
  d.polygon(inside,fill=boot)
  d.point((x+2,y-1),fill=boot_light)
  d.point((x,y-2),fill=edge)
isolations={}
for i in range(12):
 b=tile(sbody,i)
 if i in (0,11):
  place(body,b,i)
  continue
 d=ImageDraw.Draw(b)
 # Erase ONLY old independent lower legs and shoes. Hand/weapon at y<=45
 # is preserved, unlike the first A44 wide-foot generator.
 d.rectangle((22,46,51,55),fill=(0,0,0,0))
 rear,front=STANCE[i]
 hx,hy=HIP[i]
 # pelvis and coat lower flap: short and close to original A62 proportions.
 sway=TAIL.get(i,0)
 d.polygon([(hx-4,42),(hx+3,42),(hx+3+sway,45),
            (hx+1+sway,47),(hx-2,47),(hx-4,45)],fill=deep)
 d.line([(hx-3,43),(hx-3,45),(hx-1,46)],fill=cloth,width=2)
 d.line([(hx+1,44),(hx+2+sway,46)],fill=rim,width=1)
 # Rear leg loads weight, main knee bends slightly when sword swings.
 rKnee=(round((hx+rear[0])/2)-1,45)
 fKnee=(round((hx+front[0])/2)+1,45)
 d.line([(hx-2,43),rKnee,(rear[0],rear[1]-3)],fill=dark,width=4,joint='curve')
 d.line([(hx-2,44),rKnee],fill=cloth,width=2,joint='curve')
 d.line([rKnee,(rear[0],rear[1]-3)],fill=rim,width=1)
 d.line([(hx+1,43),fKnee,(front[0],front[1]-3)],fill=dark,width=4,joint='curve')
 d.line([(hx+1,44),fKnee],fill=cloth,width=2,joint='curve')
 d.line([fKnee,(front[0],front[1]-3)],fill=rim,width=1)
 draw_boot(d,rear,True)
 draw_boot(d,front,False)
 # Face/head and attack arm remain sourced from A44, do not fake a new person.
 removed=remove_isolated(b)
 if removed:isolations[i]=removed
 place(body,b,i)
 # FX: retain small movement glints but remove old isolated "L"/hook
 # artifact that could look like a second rigid weapon.
 f=Image.new('RGBA',(64,64))
 df=ImageDraw.Draw(f)
 if i==4: df.point((51,18),fill=(253,214,143,75))
 if i==5:
  df.line([(56,20),(58,22)],fill=(253,216,139,85),width=1)
  df.point((59,23),fill=(255,246,205,110))
 if i==6:
  df.line([(60,35),(61,38),(61,40)],fill=(252,211,120,100),width=1)
  df.point((61,41),fill=(255,247,220,130))
 if i==7:
  df.line([(59,50),(58,52)],fill=(254,222,147,92),width=1)
  df.point((57,54),fill=(255,246,208,100))
 if i==8:
  df.point((55,57),fill=(251,213,143,60))
 if i in (5,6,7):
  for x,y in [rear,front]:
   if i==6:
    df.point((x-2,y+1),fill=(171,145,102,110))
    df.point((x+2,y+1),fill=(175,149,105,95))
   else:
    df.point((x+2,y+1),fill=(168,146,106,52))
 place(fx,f,i)
# F0 / F11 have no A44 FX at idle/return, which is required by the switch-off contract.
body.save(a/'actor01_a45_body_12frames.png')
weapon.save(a/'actor01_a45_weapon_12frames.png')
fx.save(a/'actor01_a45_fx_12frames.png')
comp=Image.new('RGBA',(256,192))
for layer in [body,weapon,fx]:comp.alpha_composite(layer)
comp.save(a/'actor01_a45_composite_reference.png')
oldcomp=Image.new('RGBA',(256,192))
for layer in [sbody,sweapon,sfx]:oldcomp.alpha_composite(layer)
montage=Image.new('RGBA',(768,128))
for i in range(12):
 montage.alpha_composite(tile(oldcomp,i),(64*i,0))
 montage.alpha_composite(tile(comp,i),(64*i,64))
montage.save(p/'A45_A44_VS_A45_12FRAMES_1X.png')
montage.resize((2304,384),Image.Resampling.NEAREST).save(p/'A45_A44_VS_A45_12FRAMES_3X.png')
frames=[tile(comp,i).resize((256,256),Image.Resampling.NEAREST) for i in range(12)]
frames[0].save(p/'A45_ATTACK_SELF_REVIEW_4X.gif',
 save_all=True,append_images=frames[1:],duration=[110,90,90,85,75,65,165,85,95,95,100,110],loop=0,disposal=2)
# Structural/art QA catches the old F6 floating 7px fragment, not just "PNG valid".
def components(cell):
 pixels={(x,y) for y in range(64) for x in range(64) if cell.getpixel((x,y))[3]>0}
 allgroups=[]
 while pixels:
  group={pixels.pop()}
  q=list(group)
  while q:
   x,y=q.pop()
   for xx in range(x-1,x+2):
    for yy in range(y-1,y+2):
     if (xx,yy) in pixels:
      pixels.remove((xx,yy));q.append((xx,yy));group.add((xx,yy))
  allgroups.append(group)
 return sorted([len(g) for g in allgroups],reverse=True)
qa={'stage':'A45','reference':'A44 Body/Weapon/FX','head_rows_original_unchanged':[],
'body_connected_component_sizes':[],'crop_boundaries':[],'body_changed_pixels':[],
'foot_centers':{},'feet_span':{},'removed_islands':isolations,
'fx_alpha_max':max(fx.getchannel('A').get_flattened_data()),
'weapon_unchanged':sweapon.tobytes()==weapon.tobytes()}
for i in range(12):
 old=tile(sbody,i); b=tile(body,i); full=tile(comp,i)
 qa['head_rows_original_unchanged'].append(old.crop((0,0,64,34)).tobytes()==b.crop((0,0,64,34)).tobytes())
 qa['body_connected_component_sizes'].append(components(b))
 qa['body_changed_pixels'].append(sum(z!=w for z,w in zip(old.get_flattened_data(),b.get_flattened_data())))
 qa['crop_boundaries'].append(sum(full.getpixel((x,y))[3]>0 for x,y in [(u,0) for u in range(64)]+[(u,63) for u in range(64)]+[(0,u) for u in range(64)]+[(63,u) for u in range(64)]))
 if i in STANCE:
  qa['foot_centers'][i]=STANCE[i]
  qa['feet_span'][i]=STANCE[i][1][0]-STANCE[i][0][0]
assert all(qa['head_rows_original_unchanged'])
assert all(len(v)==1 for v in qa['body_connected_component_sizes']),qa['body_connected_component_sizes']
assert max(qa['crop_boundaries'])==0,qa['crop_boundaries']
assert qa['fx_alpha_max']<=140
assert qa['weapon_unchanged']
assert max(qa['feet_span'].values())<=15 and min(qa['feet_span'].values())>=10
assert STANCE[3]==STANCE[4] and STANCE[6]==STANCE[7]
assert len(qa['removed_islands'].get(6,[]))>=1
assert all(v>=30 for v in qa['body_changed_pixels'][1:11])
(p/'qa/A45_ART_SELF_AUDIT.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf8')
print('A45_ART_SELF_AUDIT_PASS',json.dumps({'components':qa['body_connected_component_sizes'],'leg_span':qa['feet_span'],'F6_removed':qa['removed_islands'].get(6),'alpha_max':qa['fx_alpha_max']}))
