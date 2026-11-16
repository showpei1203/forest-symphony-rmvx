"""Validate A41 actual Godot GPU readbacks against approved binary sources.
Contact/GIF are resized *from Godot actual 64px GPU frames* only.
"""
from pathlib import Path
from PIL import Image,ImageChops
import hashlib,json
r=Path(__file__).resolve().parent.parent
a=Image.open(r/'assets'/'actor01_attack_weighted_sword_12frames.png').convert('RGBA')
src_path=r/'assets'/'actor01_a62_approved_idle_source_64.png'
src=Image.open(src_path).convert('RGBA')
runpath=r/'assets'/'actor01_run_a35_8frames.png'
assert hashlib.sha256(src_path.read_bytes()).hexdigest()=='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
assert hashlib.sha256(runpath.read_bytes()).hexdigest()=='ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b'
assert a.size==(256,192)
unique=set(); allframes=[]
for i in range(12):
 f=Image.open(r/'qa'/'output'/('A41_REAL_GPU_ATTACK_F%02d.png'%i)).convert('RGBA')
 exact=a.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))
 diffs=sum(px!=py for px,py in zip(f.getdata(),exact.getdata()))
 assert diffs==0,(i,diffs)
 assert not any(f.getpixel((x,y))[3] for y in (0,63) for x in range(64)),i
 assert not any(f.getpixel((x,y))[3] for x in (0,63) for y in range(64)),i
 assert all(c[3] in (0,255) for c in set(f.getdata()))
 unique.add(f.tobytes())
 allframes.append(f)
 assert not any(f.getpixel((x,y)) != src.getpixel((x,y)) for y in range(15,34) for x in range(26,40)) if i in (0,11) else True
assert len(unique)==11,len(unique)
assert allframes[0].tobytes()==src.tobytes() and allframes[11].tobytes()==src.tobytes()
# F6 sword contact at native local x>48.
assert any(allframes[6].getpixel((x,y))[3] for y in range(29,51) for x in range(55,63))
contact=Image.new('RGB',(512*4,512*3),(39,51,61))
gif=[]
for i,f in enumerate(allframes):
 tile=Image.new('RGBA',(64,64),(39,51,61,255));tile.alpha_composite(f)
 pic=tile.convert('RGB').resize((512,512),Image.Resampling.NEAREST)
 contact.paste(pic,((i%4)*512,(i//4)*512))
 gif.append(tile.convert('RGB').resize((384,384),Image.Resampling.NEAREST))
contact.save(r/'qa'/'A41_NATIVE_GODOT_GPU_12FRAME_CONTACT.png')
gif[0].save(r/'qa'/'A41_NATIVE_GODOT_GPU_ATTACK.gif',save_all=True,append_images=gif[1:],duration=[85]*12,loop=0,optimize=False)
report={'stage':'A41','godot_gpu_frames':12,'unique_gpu_frames':11,'gpu_vs_original_rgba_changed_pixels_each':[0]*12,'alpha_mode':'binary','no_canvas_clip':True,'A62_sha256':hashlib.sha256(src_path.read_bytes()).hexdigest(),'A35_RUN_sha256':hashlib.sha256(runpath.read_bytes()).hexdigest(),'A41_ATLAS_sha256':hashlib.sha256((r/'assets'/'actor01_attack_weighted_sword_12frames.png').read_bytes()).hexdigest(),'engine_qa':'see A41_GPU_RUNTIME.log','status':'TECH PASS / ART HOLD / formal FS battle NOT_RUN'}
(r/'qa'/'A41_SOURCE_GPU_PIXEL_AUDIT.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('A41_GPU_PIXEL_AUDIT_PASS',json.dumps(report))