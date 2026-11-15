from PIL import Image
from pathlib import Path
import json,io,hashlib
p=Path(__file__).resolve().parents[1]
a=p/'assets'
before=[Image.open(a/('actor01_a47_'+layer+'_12frames.png')).convert('RGBA') for layer in ['body','weapon','fx']]
now=[Image.open(a/('actor01_a48_'+layer+'_12frames.png')).convert('RGBA') for layer in ['body','weapon','fx']]
def t(im,i):return im.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
native=[]
for i in range(12):
 f=p/'qa/output/a48'/('A48_NATIVE_F%02d.png'%i)
 assert f.is_file(),f
 native.append(Image.open(f).convert('RGBA'))
sheet=Image.new('RGBA',(12*64,128))
frames=[]
for i in range(12):
 old=Image.new('RGBA',(64,64))
 for src in before:old.alpha_composite(t(src,i))
 sheet.alpha_composite(old,(i*64,0));sheet.alpha_composite(native[i],(i*64,64))
 duo=Image.new('RGBA',(128,64))
 duo.alpha_composite(old,(0,0));duo.alpha_composite(native[i],(64,0))
 frames.append(duo.resize((512,256),Image.Resampling.NEAREST))
sheet.save(p/'A48_A47_VS_A48_GODOT_1X.png')
sheet.resize((2304,384),Image.Resampling.NEAREST).save(p/'A48_A47_VS_A48_GODOT_3X.png')
b=io.BytesIO();frames[0].save(b,format='GIF',save_all=True,append_images=frames[1:],
 duration=[120,100,85,85,75,70,160,95,100,100,110,120],loop=0,disposal=2)
(p/'A48_A47_VS_A48_GODOT_NATIVE_GIF.gif').write_bytes(b.getvalue())
single=[x.resize((256,256),Image.Resampling.NEAREST) for x in native]
b2=io.BytesIO();single[0].save(b2,format='GIF',save_all=True,append_images=single[1:],
 duration=[120,100,85,85,75,70,160,95,100,100,110,120],loop=0,disposal=2)
(p/'A48_GODOT_NATIVE_ATTACK_12FRAMES.gif').write_bytes(b2.getvalue())
print('A48_REAL_NATIVE_GIFS',len(native),len(b.getvalue()),len(b2.getvalue()),flush=True)
