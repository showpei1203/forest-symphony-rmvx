from PIL import Image,ImageDraw
from pathlib import Path
import glob
p=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries/FS_A46_INTEGRATED_TORSO_ATTACK_20261115')[0])
a=p/'assets';native=p/'qa/output/a46'
frames=[]
for i in range(12):
 f=native/('A46_NATIVE_F%02d.png'%i)
 assert f.is_file(),f
 frames.append(Image.open(f).convert('RGBA'))
zoom=[im.resize((256,256),Image.Resampling.NEAREST) for im in frames]
gif=p/'A46_GODOT_NATIVE_SLASH_12FRAMES_4X.gif'
from io import BytesIO
b=BytesIO()
zoom[0].save(b,format='GIF',save_all=True,append_images=zoom[1:],duration=[110,90,90,85,75,65,165,85,95,95,100,110],loop=0,disposal=2)
gif.write_bytes(b.getvalue())
a45=[Image.open(a/'actor01_a45_body_12frames.png').convert('RGBA'),Image.open(a/'actor01_a45_weapon_12frames.png').convert('RGBA'),Image.open(a/'actor01_a45_fx_12frames.png').convert('RGBA')]
a46=[Image.open(a/'actor01_a46_body_12frames.png').convert('RGBA'),Image.open(a/'actor01_a46_weapon_12frames.png').convert('RGBA'),Image.open(a/'actor01_a46_fx_12frames.png').convert('RGBA')]
def crop(im,i):
 x=i%4*64;y=i//4*64;return im.crop((x,y,x+64,y+64))
out=Image.new('RGBA',(768,128))
for i in range(12):
 old=Image.new('RGBA',(64,64))
 for layer in a45:old.alpha_composite(crop(layer,i))
 out.alpha_composite(old,(i*64,0))
 out.alpha_composite(frames[i],(i*64,64))
out.resize((2304,384),Image.Resampling.NEAREST).save(p/'A46_A45_VS_A46_NATIVE_12FRAMES_3X.png')
print('A46_NATIVE_GIF_COMPARE_PASS',gif.stat().st_size,len(frames),flush=True)
