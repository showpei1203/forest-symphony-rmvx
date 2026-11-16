from PIL import Image,ImageDraw
from pathlib import Path
import hashlib,json,zipfile
root=Path(__file__).resolve().parent
assets=root/'assets'
prov=root/'provider'
orig_sheet=Image.open(prov/'A38_PIXELLAB_ORIGINAL_3X2_SHEET.png').convert('RGBA')
gif=Image.open(prov/'A38_PIXELLAB_ORIGINAL_5FRAME.gif')
assert orig_sheet.size==(192,128),orig_sheet.size
assert gif.size==(64,64) and gif.n_frames==5
frames=[orig_sheet.crop(((i%3)*64,(i//3)*64,(i%3+1)*64,(i//3+1)*64)) for i in range(5)]
rest=Image.open(assets/'A38_IDLE_REST_APPROVED_64.png').convert('RGBA')
inhale=Image.open(assets/'A38_IDLE_INHALE_A23_MECHANICAL_64.png').convert('RGBA')
pixel=lambda a,b:sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
diff_rest=pixel(frames[0],rest)
diff_end=pixel(frames[4],inhale)
h=lambda b:hashlib.sha256(b).hexdigest()
shas=[h(f.tobytes()) for f in frames]
count=[len({p[:3] for p in f.getdata() if p[3]>0}) for f in frames]
alphas=[sorted(set(f.getchannel('A').getdata())) for f in frames]
bbox=[f.getchannel('A').getbbox() for f in frames]
adj=[pixel(frames[i],frames[i+1]) for i in range(4)]
head=(20,12,48,35)
head_diff=[pixel(rest.crop(head),f.crop(head)) for f in frames]
# Real breathing motion legitimately reverses the inhale sequence for exhale.
# Exactly five independently generated poses; F5-F7 use exact reverse phase reuse.
loopids=[0,1,2,3,4,3,2,1]
loopframes=[frames[i] for i in loopids]
loop_sheet=Image.new('RGBA',(4*64,2*64),(0,0,0,0))
for i,f in enumerate(loopframes):loop_sheet.paste(f,((i%4)*64,(i//4)*64))
loop_sheet.save(assets/'actor01_idle_a38_8phases.png')
thumb=Image.new('RGB',(4*448,2*474),(24,32,45))
draw=ImageDraw.Draw(thumb)
for i,f in enumerate(loopframes):
  x=(i%4)*448;y=(i//4)*474
  draw.text((x+12,y+8),f'IDLE F{i} | source G{loopids[i]}',fill=(242,246,241))
  bg=Image.new('RGBA',(64,64),(46,56,68,255))
  bg.alpha_composite(f)
  thumb.paste(bg.convert('RGB').resize((448,448),Image.Resampling.NEAREST),(x,y+26))
thumb.save(root/'A38_IDLE_REAL_8PHASE_CONTACT_7X.png')
# No automatic palette blending of the native sheet. GIF is preview only.
palette=[f.convert('P',palette=Image.Palette.ADAPTIVE,colors=64) for f in loopframes]
palette[0].save(root/'A38_IDLE_LOOP_8PHASE_PREVIEW.gif',save_all=True,append_images=palette[1:],duration=[130,130,130,130,180,130,130,130],loop=0,optimize=False,disposal=2,transparency=0)
qa={
 'stage':'A38',
 'provider':'PixelLab Creator Interpolate V3',
 'first':'A62 approved RUN1 neutral 64x64',
 'last':'A23 mechanical breath phase 2 64x64, ART_HOLD legacy',
 'model_generations_consumed':1,
 'request_new_frames':4,
 'provider_actual_frames':gif.n_frames,
 'original_sheet_size':[192,128],
 'source_frame0_RGBA_diff':diff_rest,
 'provider_final_vs_mechanical_inhale_RGBA_diff':diff_end,
 'provider_unique_frames':len(set(shas)),
 'provider_color_counts':count,'provider_alpha_values':alphas,
 'provider_bboxes':bbox,'provider_adjacent_pixel_diffs':adj,
 'head_bbox':head,'head_diff_vs_source':head_diff,
 'runtime_loop_frame_indices':loopids,
 'runtime_loop_frames_total':len(loopframes),
 'runtime_loop_distinct_source_poses':len(set(loopids)),
 'exhale':'exact time reversal of inhale frames; legitimate symmetric breathing motion; NOT eight AI-distinct poses',
 'full_loop_edge_diffs':[pixel(loopframes[i],loopframes[(i+1)%8]) for i in range(8)],
 'art_gate':'HOLD pending style/face/body stability and human motion quality',
 'integration':'NOT_RUN',
 'main_untouched':True
}
(root/'A38_PROVIDER_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf-8')
for k,v in qa.items():print('A38_QA',k,v)
