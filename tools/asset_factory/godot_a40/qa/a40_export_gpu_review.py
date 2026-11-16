from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import hashlib,json
root=Path(__file__).resolve().parent.parent
sheet=Image.open(root/'assets'/'actor01_attack_lunge_8frames.png').convert('RGBA')
src=Image.open(root/'assets'/'actor01_a62_approved_idle_source_64.png').convert('RGBA')
frames=[]
for i in range(8):
    gpu=Image.open(root/'qa'/'output'/('A40_NATIVE_GPU_ATTACK_F%02d.png'%i)).convert('RGBA')
    expected=sheet.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))
    assert gpu.size==expected.size==(64,64)
    diff=ImageChops.difference(gpu,expected)
    bbox=diff.getbbox()
    print('A40_FRAME_PIXEL_GPU_VS_SHEET',i,'BBOX',bbox,'DIFF_PIXELS',sum(a!=b for a,b in zip(gpu.getdata(),expected.getdata())))
    # Check no source face/head repaint, feet remain the source in actual GPU.
    for y in list(range(15,34))+list(range(47,50)):
        for x in range(22,44):
            assert gpu.getpixel((x,y))==src.getpixel((x,y)),(i,x,y,'actual GPU face/feet differs')
    frames.append(gpu)
bg=(39,51,60,255)
contact=Image.new('RGB',(64*8*4,64*8*2),(39,51,60))
for i,f in enumerate(frames):
    fg=Image.new('RGBA',(64,64),bg)
    fg.alpha_composite(f)
    contact.paste(fg.convert('RGB').resize((512,512),Image.Resampling.NEAREST),((i%4)*512,(i//4)*512))
contact.save(root/'qa'/'A40_REAL_GODOT_GPU_ATTACK_CONTACT.png')
# Preview GIF is assembled from REAL GPU screenshots, not generated composition.
duration=[100]*8
gifframes=[]
for i,f in enumerate(frames):
    fg=Image.new('RGBA',(64,64),bg)
    fg.alpha_composite(f)
    gifframes.append(fg.convert('RGB').resize((384,384),Image.Resampling.NEAREST))
gifframes[0].save(root/'qa'/'A40_REAL_GODOT_GPU_ATTACK_LOOP.gif',save_all=True,append_images=gifframes[1:],duration=duration,loop=0,optimize=False)
print('A40_GPU_CONTACT_AND_GIF_GENERATED',len(frames))