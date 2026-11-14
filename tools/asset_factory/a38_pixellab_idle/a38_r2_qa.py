from PIL import Image,ImageDraw
from pathlib import Path
import json,hashlib
root=Path(__file__).resolve().parent
asset=root/'assets'
source=Image.open(asset/'A38_IDLE_REST_APPROVED_64.png').convert('RGBA')
target=Image.open(asset/'A38_R2_SUBTLE_INHALE_TARGET_G3.png').convert('RGBA')
folder=root/'provider_r2'
sheet=Image.open(folder/'A38_R2_PIXELLAB_ORIGINAL_3X2_SHEET.png').convert('RGBA')
gif=Image.open(folder/'A38_R2_PIXELLAB_ORIGINAL_5FRAME.gif')
assert sheet.size==(192,128) and gif.size==(64,64) and gif.n_frames==5
frames=[sheet.crop(((i%3)*64,(i//3)*64,(i%3+1)*64,(i//3+1)*64)) for i in range(5)]
d=lambda a,b:sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
head=(20,12,48,35)
head_diffs=[d(source.crop(head),f.crop(head)) for f in frames]
shas=[hashlib.sha256(f.tobytes()).hexdigest() for f in frames]
colors=[len({p[:3] for p in f.getdata() if p[3]>0}) for f in frames]
bbox=[f.getchannel('A').getbbox() for f in frames]
adj=[d(frames[i],frames[i+1]) for i in range(4)]
idx=[0,1,2,3,4,3,2,1]
sheet8=Image.new('RGBA',(256,128),(0,0,0,0))
for i,j in enumerate(idx):sheet8.paste(frames[j],((i%4)*64,(i//4)*64))
sheet8.save(asset/'actor01_idle_a38_r2_8phases.png')
contact=Image.new('RGB',(4*64*7,2*(64*7+26)),(25,33,45));dr=ImageDraw.Draw(contact)
for i,j in enumerate(idx):
 x=(i%4)*448;y=(i//4)*(448+26);f=frames[j]
 dr.text((x+12,y+7),f'A38 R2 F{i} -> Provider G{j}',fill=(241,245,242))
 bg=Image.new('RGBA',(64,64),(46,56,68,255));bg.alpha_composite(f)
 contact.paste(bg.convert('RGB').resize((448,448),Image.Resampling.NEAREST),(x,y+26))
contact.save(root/'A38_R2_IDLE_8PHASE_CONTACT_7X.png')
palette=[frames[j].convert('P',palette=Image.Palette.ADAPTIVE,colors=64) for j in idx]
palette[0].save(root/'A38_R2_IDLE_8PHASE_PREVIEW.gif',save_all=True,append_images=palette[1:],duration=[130,130,130,130,180,130,130,130],loop=0,optimize=False,disposal=2,transparency=0)
qa={'stage':'A38_R2','provider':'PixelLab Creator Interpolate V3','provider_sheet_size':list(sheet.size),
 'gif_frames':gif.n_frames,'rest_f0_diff':d(source,frames[0]),'end_target_G3_diff':d(target,frames[4]),
 'five_source_unique':len(set(shas)),'head_roi':head,'head_diff_vs_approved':head_diffs,
 'frame_bbox':bbox,'frame_rgb_colors':colors,'adjacent_pixel_diff':adj,
 'eight_phase_source_indices':idx,'exhale':'mirror reuse no distinct AI poses','art_status':'HOLD pending comparison with R1, no face or arm drift PASS claimed',
 'generation_count':1}
(root/'A38_R2_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf-8')
for k,v in qa.items():print('R2_QA',k,v)
