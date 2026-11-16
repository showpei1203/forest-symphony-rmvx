from PIL import Image, ImageDraw
import glob,json,math,os,hashlib
p=glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries/FS_A43_SWING_ART_WIP_20261115')[0]
a=p+'/assets/'
load=lambda n:Image.open(a+n).convert('RGBA')
src_body=load('actor01_a42_body_12frames.png')
src_weap=load('actor01_a42_weapon_12frames.png')
src_fx=load('actor01_a42_fx_12frames.png')
new_body=Image.new('RGBA',(256,192))
new_weapon=Image.new('RGBA',(256,192))
new_fx=Image.new('RGBA',(256,192))
outline=(18,29,31,255)
sleeve=(22,67,61,255)
sleeve_lite=(37,98,82,255)
shadow=(14,44,42,255)
gold=(233,185,60,255)
gold_shadow=(128,91,38,255)
skin=(184,142,108,255)
steel_edge=(71,92,103,255)
steel=(190,208,207,255)
silver=(250,246,230,255)
# Retargeted 45 degree Actor01 attack: overhead windup -> full contact -> downward followthrough.
# F6 blade is deliberately inside the 64px cell; original A42 resembled a bent arrow.
hand={1:(42,42),2:(43,39),3:(44,36),4:(45,37),5:(47,37),6:(47,41),
      7:(46,44),8:(45,45),9:(43,44),10:(42,43)}
tip={1:(44,26),2:(46,22),3:(49,19),4:(53,17),5:(59,24),
     6:(61,41),7:(58,54),8:(54,58),9:(49,57),10:(44,56)}
elbow={1:(41,43),2:(42,40),3:(43,38),4:(43,39),5:(45,38),6:(44,41),
       7:(43,44),8:(42,46),9:(41,45),10:(41,43)}
lungex={1:-1,2:-1,3:-2,4:-2,5:1,6:4,7:3,8:2,9:1,10:0}
def tile(im,i):
 x=(i%4)*64;y=(i//4)*64
 return im.crop((x,y,x+64,y+64))
def put(sheet,img,i):
 sheet.alpha_composite(img,((i%4)*64,(i//4)*64))
def blade(draw,w,t):
 vx=t[0]-w[0];vy=t[1]-w[1];norm=max(1,(vx*vx+vy*vy)**0.5)
 ux,uy=vx/norm,vy/norm
 px,py=-uy,ux
 # hilt behind wrist, short dark handle; gold crossguard and pommel
 butt=(round(w[0]-ux*4),round(w[1]-uy*4))
 draw.line([butt,w], fill=outline,width=3)
 draw.line([butt,w], fill=gold_shadow,width=1)
 cross1=(round(w[0]+px*3),round(w[1]+py*3))
 cross2=(round(w[0]-px*3),round(w[1]-py*3))
 draw.line([cross1,cross2],fill=outline,width=3)
 draw.line([cross1,cross2],fill=gold,width=1)
 # broad blade with tapered last ~4px and thin dark silhouette
 base=(w[0]+ux*2,w[1]+uy*2)
 far=(t[0]-ux*2,t[1]-uy*2)
 polygon=[(round(base[0]+px*2),round(base[1]+py*2)),
 (round(far[0]+px),round(far[1]+py)),t,
 (round(far[0]-px),round(far[1]-py)),
 (round(base[0]-px*2),round(base[1]-py*2))]
 draw.polygon(polygon,fill=steel_edge)
 draw.line([(round(base[0]+px),round(base[1]+py)),(round(far[0]+px*0.5),round(far[1]+py*0.5)),t],fill=silver,width=1)
 draw.line([(round(base[0]-px),round(base[1]-py)),(round(far[0]-px*0.4),round(far[1]-py*0.4))],fill=steel,width=1)
 draw.point(tuple(t),fill=silver)
for i in range(12):
 b=tile(src_body,i)
 w=Image.new('RGBA',(64,64))
 fx=Image.new('RGBA',(64,64))
 if i in (0,11):
  put(new_body,b,i);put(new_weapon,tile(src_weap,i),i);put(new_fx,tile(src_fx,i),i)
  continue
 dx=lungex[i]
 # Keep canonical A62 head and face pixels EXACT; translate only lower torso/legs.
 original=b.copy()
 d_body=ImageDraw.Draw(b)
 d_body.rectangle((17,40,52,62),fill=(0,0,0,0))
 lower=original.crop((17,40,53,63))
 b.alpha_composite(lower,(17+dx,40))
 # remove old sword arm pixels in the upper-right quadrant.
 d_body=ImageDraw.Draw(b)
 d_body.rectangle((41,36,54,51),fill=(0,0,0,0))
 # protect face and white hair (all rows < 36 untouched)
 shoulder=(40+int(dx*0.35),40)
 e=elbow[i];h=hand[i]
 # Sprite arm built with dark contour, teal sleeve, gold wrist cuff, visible hand.
 d_body.line([shoulder,e,h],fill=outline,width=6,joint='curve')
 d_body.line([shoulder,e,h],fill=sleeve,width=4,joint='curve')
 d_body.line([shoulder,e,h],fill=sleeve_lite,width=2,joint='curve')
 cuff=(round(h[0]-(h[0]-e[0])*.25),round(h[1]-(h[1]-e[1])*.25))
 d_body.line([cuff,h],fill=gold_shadow,width=3)
 d_body.line([cuff,h],fill=gold,width=1)
 d_body.ellipse((h[0]-1,h[1]-1,h[0]+1,h[1]+1),fill=skin)
 # Manual forward-thrust shoulder rotation: armored shoulder cap moves with lunge.
 d_body.polygon([(shoulder[0]-2,shoulder[1]-2),(shoulder[0]+2,shoulder[1]-3),
                 (shoulder[0]+4,shoulder[1]),(shoulder[0]+1,shoulder[1]+3)],
                 fill=outline)
 d_body.line([(shoulder[0]-1,shoulder[1]-1),(shoulder[0]+2,shoulder[1]-2)],
             fill=sleeve_lite,width=2)
 # Sword never baked into Body; independent Weapon layer remains separately toggleable.
 dw=ImageDraw.Draw(w)
 blade(dw,h,tip[i])
 # Swept motion FX attaches to the moving sword tip, not an extra blade.
 if i in (4,5,6,7,8):
  df=ImageDraw.Draw(fx)
  if i==4:
   df.point((55,18),fill=(254,216,135,100))
  elif i==5:
   df.line([(55,18),(59,21),(60,23)],fill=(251,219,153,115),width=1)
   df.point((60,25),fill=(255,250,224,180))
  elif i==6:
   df.line([(59,27),(61,31),(61,35),(61,39)],fill=(251,201,113,110),width=2)
   df.line([(60,30),(60,35),(60,39)],fill=(255,246,212,200),width=1)
   df.point((59,43),fill=(255,252,234,245))
   df.point((61,44),fill=(255,213,110,165))
  elif i==7:
   df.line([(61,43),(60,47),(58,51)],fill=(255,237,187,135),width=2)
   df.point((57,55),fill=(255,251,233,160))
  elif i==8:
   df.line([(57,55),(55,57)],fill=(255,213,110,80),width=1)
 put(new_body,b,i);put(new_weapon,w,i);put(new_fx,fx,i)
for name,img in [('actor01_a43_body_12frames.png',new_body),
                 ('actor01_a43_weapon_12frames.png',new_weapon),
                 ('actor01_a43_fx_12frames.png',new_fx)]:
 img.save(a+name)
# Collision/silhouette sheets, with original on top and candidate below, nearest neighbor 4x.
old=Image.new('RGBA',(768,64))
updated=Image.new('RGBA',(768,64))
for i in range(12):
 for layer in [src_body,src_weap,src_fx]:old.alpha_composite(tile(layer,i),(i*64,0))
 for layer in [new_body,new_weapon,new_fx]:updated.alpha_composite(tile(layer,i),(i*64,0))
compare=Image.new('RGBA',(768,128));compare.alpha_composite(old);compare.alpha_composite(updated,(0,64))
compare.save(p+'/A43_BODY_WEAPON_FX_12FRAME_BEFORE_AFTER.png')
compare.resize((2304,384),Image.Resampling.NEAREST).save(p+'/A43_BODY_WEAPON_FX_12FRAME_ZOOM3X.png')
scenes=[]
for i in range(12):scenes.append(updated.crop((i*64,0,i*64+64,64)).resize((256,256),Image.Resampling.NEAREST))
scenes[0].save(p+'/A43_BODY_WEAPON_FX_ATTACK_PREVIEW_4X.gif',save_all=True,append_images=scenes[1:],
               duration=[110,90,90,85,75,65,165,85,95,95,100,110],loop=0,disposal=2)
m_path=a+'actor01_animation_manifest.json'
manifest=json.load(open(m_path,encoding='utf8'))
profile=manifest['animation_profiles']['attack_weighted']
assert profile['sprite_sheet'] in ('res://assets/actor01_a42_body_12frames.png','res://assets/actor01_a43_body_12frames.png')
profile['sprite_sheet']='res://assets/actor01_a43_body_12frames.png'
profile['art_gate']='HOLD: A43 manually retargeted shoulder/body, sword and FX candidate requiring native QA and artistic inspection'
profile['provenance']='A42 12 poses, A43 separated manually revised Body/Weapon/FX'
open(m_path,'w',encoding='utf8').write(json.dumps(manifest,indent=2,ensure_ascii=False))
gd=p+'/scripts/fs_actor_animator.gd'
code=open(gd,encoding='utf8').read()
oldref='else "res://assets/actor01_a42_weapon_12frames.png"'
assert code.count(oldref) in (0,1)
code=code.replace(oldref,'else "res://assets/actor01_a43_weapon_12frames.png"')
open(gd,'w',encoding='utf8').write(code)
checks={'frames':12,'size':[256,192],'head_rgba_equal_0_to_34':[],
        'max_diff_body':[],'min_brightness_sword':[],'border_alpha_counts':[]}
for i in range(12):
 ob=tile(src_body,i); nb=tile(new_body,i); nw=tile(new_weapon,i); nf=tile(new_fx,i)
 checks['head_rgba_equal_0_to_34'].append(ob.crop((0,0,64,34)).tobytes()==nb.crop((0,0,64,34)).tobytes())
 checks['max_diff_body'].append(sum(x!=y for x,y in zip(ob.getdata(),nb.getdata())))
 comp=updated.crop((i*64,0,(i+1)*64,64))
 border=[comp.getpixel((x,0))[3] for x in range(64)]+[comp.getpixel((x,63))[3] for x in range(64)]+[comp.getpixel((0,y))[3] for y in range(64)]+[comp.getpixel((63,y))[3] for y in range(64)]
 checks['border_alpha_counts'].append(sum(v>0 for v in border))
 checks['min_brightness_sword'].append(sum(1 for x in nw.getdata() if x[3]>0))
assert all(checks['head_rgba_equal_0_to_34']),checks
assert max(checks['border_alpha_counts'])==0,checks
assert min(checks['min_brightness_sword'][1:11])>=20,checks
assert any(n>50 for n in checks['max_diff_body'][1:11]),checks
open(p+'/A43_ART_REWRITE_QA.json','w').write(json.dumps(checks,indent=2))
print('A43_BODY_WEAPON_FX_REWRITE_PASS',checks)
print('A43_PREVIEW_BYTES',os.path.getsize(p+'/A43_BODY_WEAPON_FX_ATTACK_PREVIEW_4X.gif'))
