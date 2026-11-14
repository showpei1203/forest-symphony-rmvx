"""A42 native Godot GPU evidence derived exclusively from SubViewport screenshots.
Validate source/layer pixel roundtrips, original SHA, and make QA contact/GIF on private Drive.
"""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
import json, hashlib
ROOT=Path(__file__).resolve().parent.parent
src=Image.open(ROOT/'assets/actor01_attack_weighted_sword_12frames.png').convert('RGBA')
layers={name:Image.open(ROOT/'assets'/f'actor01_a42_{name}_12frames.png').convert('RGBA') for name in ('body','weapon','fx')}
assert src.size== (256,192)
original_sha=hashlib.sha256((ROOT/'assets/actor01_attack_weighted_sword_12frames.png').read_bytes()).hexdigest()
assert original_sha=='2621b31f53abdca251049f8d9dc740971e3d610f3de860e26ca2998ddd987746'
source_sha=hashlib.sha256((ROOT/'assets/actor01_a62_approved_idle_source_64.png').read_bytes()).hexdigest()
assert source_sha=='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
def cell(atlas,i):
    return atlas.crop(((i%4)*64,int(i/4)*64,(i%4+1)*64,(int(i/4)+1)*64))
def changed(a,b):
    return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
frames=[]; results=[]
for i in range(12):
    img=Image.open(ROOT/'qa'/'output'/f'A42_NATIVE_GPU_ALL_LAYERS_F{i:02d}.png').convert('RGBA')
    expect=cell(src,i)
    comp=Image.alpha_composite(Image.alpha_composite(cell(layers['body'],i),cell(layers['weapon'],i)),cell(layers['fx'],i))
    err=changed(img,expect)
    assert err==0 and changed(img,comp)==0,(i,err)
    frames.append(img)
    results.append(err)
f6=6
body6=cell(layers['body'],f6)
weapon6=cell(layers['weapon'],f6)
fx6=cell(layers['fx'],f6)
no_fx=Image.open(ROOT/'qa/output/A42_GPU_NO_FX_F06.png').convert('RGBA')
body_only=Image.open(ROOT/'qa/output/A42_GPU_BODY_ONLY_F06.png').convert('RGBA')
assert changed(body_only,body6)==0
assert changed(no_fx,Image.alpha_composite(body6,weapon6))==0
assert changed(frames[6],Image.alpha_composite(no_fx,fx6))==0
bg=(39,51,61,255)
contact=Image.new('RGB',(4*64*8,3*64*8),bg[:3])
gif=[]
for i,img in enumerate(frames):
    art=Image.new('RGBA',(64,64),bg)
    art.alpha_composite(img)
    tile=art.convert('RGB')
    contact.paste(tile.resize((512,512),Image.Resampling.NEAREST),((i%4)*512,(i//4)*512))
    gif.append(tile.resize((384,384),Image.Resampling.NEAREST))
contact.save(ROOT/'qa/A42_REAL_GPU_12_FRAME_CONTACT.png')
gif[0].save(ROOT/'qa/A42_REAL_GPU_BODY_WEAPON_FX.gif',save_all=True,append_images=gif[1:],duration=[83]*12,loop=0,optimize=False)
# 1x comparison plus enlarged pixel-perfect version
labels=['Body only','Body + weapon','All three layers']
images=[body_only,no_fx,frames[6]]
panel=Image.new('RGB',(3*64*8,64*8+48),(35,47,56))
for i,(label,img) in enumerate(zip(labels,images)):
    art=Image.new('RGBA',(64,64),bg);art.alpha_composite(img)
    panel.paste(art.convert('RGB').resize((512,512),Image.Resampling.NEAREST),(i*512,48))
    ImageDraw.Draw(panel).text((i*512+16,16),label,fill=(255,255,255))
panel.save(ROOT/'qa/A42_NATIVE_GPU_LAYER_TOGGLE_AB.png')
report={'stage':'A42','source_A62_SHA':source_sha,'reference_A41_SHA':original_sha,'frames':12,
        'native_gpu_composite_vs_A41_RGBA_pixel_diffs':results,
        'native_GPU_body_only_vs_source_pixel_diffs':0,
        'native_GPU_body_weapon_vs_source_pixel_diffs':0,
        'native_GPU_three_layers_vs_source_pixel_diffs':0,
        'unique_composite_frames':len({im.tobytes() for im in frames}),
        'godot_gpu_pass':True,'art_gate':'HOLD','FS_battle_real_damage_gate':'NOT_RUN'}
(ROOT/'qa/A42_GPU_PIXEL_AUDIT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('A42_NATIVE_LAYER_GPU_AUDIT_PASS',json.dumps(report,ensure_ascii=False))