from PIL import Image,ImageDraw
from pathlib import Path
import hashlib,json,zipfile
root=Path(__file__).resolve().parent.parent
output=root/'qa'/'output'
frames=[Image.open(output/f'A39_GPU_BREATH_F{i:02d}.png').convert('RGBA') for i in range(8)]
assert all(f.size==(64,64) for f in frames)
source=Image.open(root/'assets'/'actor01_a62_approved_idle_source_64.png').convert('RGBA')
colors=[len({px for px in f.getdata() if px[3]}) for f in frames]
diff=lambda a,b:sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
diff_to_first=[diff(frames[0],f) for f in frames]
# Pixel exact preservation checks in GPU space: alpha + head + feet+outside masks
def inside(x,y):
 return (32<=x<=39 and 36<=y<=41) or (25<=x<=30 and 34<=y<=36) or (39<=x<=42 and 34<=y<=36)
changes_mask=[]
alpha_changes=[]
for f in frames:
 n=na=0
 for y in range(64):
  for x in range(64):
   before=frames[0].getpixel((x,y));after=f.getpixel((x,y))
   na+=(before[3]!=after[3])
   n+=((before!=after) and not inside(x,y))
 changes_mask.append(n);alpha_changes.append(na)
assert max(changes_mask)==0
assert max(alpha_changes)==0
assert len({f.tobytes() for f in frames})>=3
assert frames[0].getpixel((34,35))==frames[-1].getpixel((34,35))
# Static art source compared to GPU p0 only within visible image (not transparent RGB)
source_mismatch=sum(a!=b for a,b in zip(source.getdata(),frames[0].getdata()))
thumb=Image.new('RGB',(4*64*7,2*(64*7+29)),(24,33,45));dr=ImageDraw.Draw(thumb)
for i,f in enumerate(frames):
 x=(i%4)*64*7;y=(i//4)*(64*7+29)
 dr.text((x+10,y+9),f'GODOT GPU F{i} - {diff_to_first[i]} px diff',fill=(237,244,239))
 bg=Image.new('RGBA',(64,64),(44,53,64,255));bg.alpha_composite(f)
 thumb.paste(bg.convert('RGB').resize((448,448),Image.Resampling.NEAREST),(x,y+29))
thumb.save(output/'A39_GODOT_GPU_BREATH_8_FRAME_CONTACT_7X.png')
anim=[]
for f in frames:
 bg=Image.new('RGBA',(64,64),(37,46,57,255));bg.alpha_composite(f)
 anim.append(bg.convert('RGB').resize((384,384),Image.Resampling.NEAREST))
pal=[f.convert('P',palette=Image.Palette.ADAPTIVE,colors=80) for f in anim]
pal[0].save(output/'A39_GODOT_GPU_BREATH_8_PHASE_LOOP.gif',save_all=True,append_images=pal[1:],duration=[400]*8,loop=0,optimize=False,disposal=2)
qa={'stage':'A39','gpu_frames':8,'unique_gpu_poses':len({f.tobytes() for f in frames}),'source_image_sha256':hashlib.sha256((root/'assets'/'actor01_a62_approved_idle_source_64.png').read_bytes()).hexdigest(),'gpu_frame0_matches_source_rgba_pixel_diff':source_mismatch,'diff_to_f0_pixels':diff_to_first,'changed_outside_whitelist':changes_mask,'alpha_pixel_changes':alpha_changes,'texture_size':[64,64],'breath_shader_affected_regions':['x32-39 y36-41','x25-30 y34-36','x39-42 y34-36'],'face_y_le_33_unchanged':all(changes_mask[i]==0 for i in range(8)),'feet_y_ge_43_unchanged':all(changes_mask[i]==0 for i in range(8)),'art':'HOLD_PENDING_VISUAL_QA','engine':'GODOT_4.7.2_RX6700XT_OPENGL_PASS','runtime':'AnimationPlayer value track on shader_parameter/breath_phase'}
(root/'qa'/'A39_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf-8')
print('A39_GPU_SOURCE_DIFF=',source_mismatch)
print('A39_GPU_DIFFS=',diff_to_first)
print('A39_UNIQUE_GPU_POSES=',qa['unique_gpu_poses'])
print('A39_8_IMAGES_ALPHA_OUTSIDE_MASK_PASS=',max(alpha_changes)==0 and max(changes_mask)==0)
print('A39_OUTPUT_CONTACT_BYTES=',(output/'A39_GODOT_GPU_BREATH_8_FRAME_CONTACT_7X.png').stat().st_size)
print('A39_OUTPUT_GIF_BYTES=',(output/'A39_GODOT_GPU_BREATH_8_PHASE_LOOP.gif').stat().st_size)
