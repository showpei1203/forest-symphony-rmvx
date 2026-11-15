from pathlib import Path
from PIL import Image,ImageDraw
import glob,io,hashlib
p=Path(__file__).resolve().parents[1];a=p/'assets';qa=p/'qa/output/a47'
old_body=Image.open(a/'actor01_a46_body_12frames.png').convert('RGBA')
old_weapon=Image.open(a/'actor01_a46_weapon_12frames.png').convert('RGBA')
old_fx=Image.open(a/'actor01_a46_fx_12frames.png').convert('RGBA')
def tile(im,i):
 return im.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
native=[]
for i in range(12):
 f=qa/('A47_NATIVE_F%02d.png'%i)
 assert f.is_file(),f
 native.append(Image.open(f).convert('RGBA'))
sheet=Image.new('RGBA',(768,128))
frames=[]
for i in range(12):
 old=Image.new('RGBA',(64,64))
 for src in [old_body,old_weapon,old_fx]:old.alpha_composite(tile(src,i))
 new=native[i]
 sheet.alpha_composite(old,(64*i,0))
 sheet.alpha_composite(new,(64*i,64))
 duo=Image.new('RGBA',(128,64))
 duo.alpha_composite(old,(0,0));duo.alpha_composite(new,(64,0))
 frames.append(duo.resize((512,256),Image.Resampling.NEAREST))
sheet.save(p/'A47_A46_VS_GODOT_A47_1X.png')
sheet.resize((2304,384),Image.Resampling.NEAREST).save(p/'A47_A46_VS_GODOT_A47_3X.png')
buf=io.BytesIO()
frames[0].save(buf,format='GIF',save_all=True,append_images=frames[1:],
 duration=[120,90,85,85,70,70,170,90,90,100,105,120],loop=0,disposal=2)
gif=p/'A47_GODOT_SIDE_BY_SIDE_A46_A47_4X.gif'
gif.write_bytes(buf.getvalue())
single=[img.resize((256,256),Image.Resampling.NEAREST) for img in native]
b2=io.BytesIO();single[0].save(b2,format='GIF',save_all=True,append_images=single[1:],
duration=[120,90,85,85,70,70,170,90,90,100,105,120],loop=0,disposal=2)
(p/'A47_GODOT_NATIVE_ATTACK_12FRAMES_4X.gif').write_bytes(b2.getvalue())
print('A47_TRUE_GODOT_NATIVE_PREVIEW',{'frames':12,'gif':gif.stat().st_size,'sha':hashlib.sha256(gif.read_bytes()).hexdigest(),'snapshot':(qa/'A47_NATIVE_DAMAGE_CONTACT_SCENE.png').exists()},flush=True)
