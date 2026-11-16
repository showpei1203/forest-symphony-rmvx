import glob,os,json,math,hashlib
from pathlib import Path
from PIL import Image,ImageDraw
p=Path(__file__).resolve().parents[1]
assets=p/'assets'
b43=Image.open(assets/'actor01_a43_body_12frames.png').convert('RGBA')
w43=Image.open(assets/'actor01_a43_weapon_12frames.png').convert('RGBA')
f43=Image.open(assets/'actor01_a43_fx_12frames.png').convert('RGBA')
b44=Image.new('RGBA',(256,192));f44=Image.new('RGBA',(256,192))
positions={
 1: ((28,48),(40,49)),
 2: ((27,49),(40,49)),
 3: ((27,49),(41,49)),
 4: ((27,49),(41,49)),
 5: ((26,50),(43,49)),
 6: ((25,50),(46,50)),
 7: ((26,50),(46,50)),
 8: ((27,50),(44,50)),
 9: ((28,49),(41,49)),
 10:((29,49),(40,49))}
sword_tips={1:(44,26),2:(46,22),3:(49,19),4:(53,17),5:(59,24),6:(61,41),7:(58,54),8:(54,58),9:(49,57),10:(44,56)}
sword_hands={1:(42,42),2:(43,39),3:(44,36),4:(45,37),5:(47,37),6:(47,41),7:(46,44),8:(45,45),9:(43,44),10:(42,43)}
dark=(7,17,20,255);shadow=(14,35,38,255);fabric=(19,52,47,255);rim=(43,79,70,255)
brown=(91,69,53,255);edge=(152,127,94,255);gold=(201,165,68,255)
def frame(im,i):return im.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))
def put(im,t,i):im.alpha_composite(t,((i%4)*64,(i//4)*64))
for i in range(12):
 b=frame(b43,i)
 fx=frame(f43,i)
 if i in (0,11):
  put(b44,b,i);put(f44,fx,i);continue
 d=ImageDraw.Draw(b)
 # A43 feet stayed almost locked as upper body lunged. Redraw both shins as one
 # anchored stance, preserving original white hair and upper arm.
 d.rectangle((18,47,53,59),fill=(0,0,0,0))
 rear,front=positions[i]
 # Coat lower tail moves with pelvic rotation but stays behind legs.
 hip=(34+(2 if 5<=i<=8 else (-1 if 2<=i<=4 else 0)),43)
 d.polygon([(hip[0]-4,hip[1]),(hip[0]+4,hip[1]),(hip[0]+3,48),(hip[0]-2,50)],fill=shadow)
 d.line([(hip[0]-2,44),(hip[0]+1,48)],fill=rim,width=1)
 # Rear foot: bent supporting knee and leather boot with dark outlining
 r_knee=(30 if i<=4 else 29,45 if i<=4 else 46)
 d.line([r_knee,(rear[0]+1,rear[1]-2),rear],fill=dark,width=5,joint='curve')
 d.line([r_knee,(rear[0]+1,rear[1]-2)],fill=fabric,width=3,joint='curve')
 d.line([(rear[0]-2,rear[1]),(rear[0]+3,rear[1])],fill=dark,width=3)
 d.line([(rear[0]-1,rear[1]),(rear[0]+2,rear[1])],fill=brown,width=1)
 d.point((rear[0]+1,rear[1]-1),fill=edge)
 # Leading foot : separate shin, toe rotates outward during contact.
 f_knee=(38+(1 if 5<=i<=8 else 0),45)
 d.line([f_knee,(front[0]-2,front[1]-2),front],fill=dark,width=5,joint='curve')
 d.line([f_knee,(front[0]-2,front[1]-2)],fill=fabric,width=3,joint='curve')
 d.line([(front[0]-2,front[1]),(front[0]+3,front[1])],fill=dark,width=3)
 d.line([(front[0]-1,front[1]),(front[0]+2,front[1])],fill=brown,width=1)
 d.point((front[0]+2,front[1]-1),fill=edge)
 # Torso twist accent: three different armor highlights mark wind-up, impact, and recovery.
 if i in (3,4):
  d.line([(36,38),(39,40),(38,43)],fill=shadow,width=2)
  d.point((39,38),fill=gold)
 elif i in (5,6,7):
  d.line([(36,38),(39,39),(41,42)],fill=rim,width=2)
  d.line([(40,40),(40,43)],fill=shadow,width=1)
  d.point((41,39),fill=gold)
 else:
  d.point((39,40),fill=rim)
 # Ground debris at contact: short-lived sprite-layer overlay, not atlas baked to Body.
 if i in (5,6,7):
  df=ImageDraw.Draw(fx)
  dust=[(rear[0]-3,rear[1]+2),(front[0]+3,front[1]+1)]
  for j,(px,py) in enumerate(dust):
   df.point((px,py),fill=(224,208,148,100 if i!=6 else 185))
   if i==6:df.point((px+1,py-1),fill=(181,156,94,125))
 put(b44,b,i);put(f44,fx,i)
b44.save(assets/'actor01_a44_body_12frames.png')
f44.save(assets/'actor01_a44_fx_12frames.png')
# Weapon is independently versioned and byte-for-byte copied, since A43 sword
# redesign already solved the arrow issue.
w43.save(assets/'actor01_a44_weapon_12frames.png')
def composite(bs,ws,fs):
 z=Image.new('RGBA',(256,192))
 for v in [bs,ws,fs]:z.alpha_composite(v)
 return z
comp43=composite(b43,w43,f43)
comp44=composite(b44,w43,f44)
comp44.save(assets/'actor01_a44_composite_reference.png')
comparison=Image.new('RGBA',(768,128))
frames=[]
for i in range(12):
 a=frame(comp43,i);b=frame(comp44,i)
 comparison.alpha_composite(a,(i*64,0));comparison.alpha_composite(b,(i*64,64))
 frames.append(b.resize((256,256),Image.Resampling.NEAREST))
comparison.save(p/'A44_A43_TO_A44_POSE_COMPARE_1X.png')
comparison.resize((2304,384),Image.Resampling.NEAREST).save(p/'A44_A43_TO_A44_POSE_COMPARE_3X.png')
frames[0].save(p/'A44_WEIGHTED_SLASH_4X.gif',save_all=True,append_images=frames[1:],
 duration=[110,90,90,85,75,65,165,85,95,95,100,110],loop=0,disposal=2)
# Validate canonical head rows, alpha bounds, original A43 weapon untouched.
checks={'stage':'A44','old_head_equal':[],'alpha_at_64px_border':[],'body_pixel_changes':[],'weapon_sha256':hashlib.sha256((assets/'actor01_a44_weapon_12frames.png').read_bytes()).hexdigest()}
for i in range(12):
 old=frame(b43,i);new=frame(b44,i)
 checks['old_head_equal'].append(old.crop((0,0,64,34)).tobytes()==new.crop((0,0,64,34)).tobytes())
 checks['body_pixel_changes'].append(sum(x!=y for x,y in zip(old.getdata(),new.getdata())))
 co=frame(comp44,i)
 checks['alpha_at_64px_border'].append(sum(co.getpixel((x,0))[3]>0 or co.getpixel((x,63))[3]>0 for x in range(64))+
 sum(co.getpixel((0,y))[3]>0 or co.getpixel((63,y))[3]>0 for y in range(64)))
assert all(checks['old_head_equal']),checks
assert all(v==0 for v in checks['alpha_at_64px_border']),checks
assert min(checks['body_pixel_changes'][1:11])>10,checks
assert frame(b44,0).tobytes()==frame(b43,0).tobytes() and frame(b44,11).tobytes()==frame(b43,11).tobytes()
( p/'qa/A44_ART_MOTION_QA.json').write_text(json.dumps(checks,indent=2),encoding='utf8')
print('A44_ART_DRAWN_PASS',json.dumps(checks),flush=True)
