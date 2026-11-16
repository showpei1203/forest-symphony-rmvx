from pathlib import Path
from PIL import Image,ImageDraw
import shutil,glob,json,hashlib,math
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A51_ATTACK_ANTICIPATION_TRUE_PIXELLAB_20261116'
base=p/'godot_a51';proj=p/'godot_a51_swordtrail'
assert base.exists()
if proj.exists():
 old_result=p/'qa_native_swordtrail/A51_GODOT_NATIVE_RESULT.json'
 assert not old_result.exists() or json.loads(old_result.read_text(encoding='utf8')).get('status')!='PASS', 'Do not overwrite a PASS candidate'
 shutil.rmtree(proj)
shutil.copytree(base,proj,ignore=shutil.ignore_patterns('.godot','*.import','__pycache__'))
assets=proj/'assets'
body=Image.open(assets/'actor01_a51_body_12frames.png').convert('RGBA')
weapon=Image.open(assets/'actor01_a51_weapon_12frames.png').convert('RGBA')
old_fx=Image.open(assets/'actor01_a51_fx_12frames.png').convert('RGBA')
reference_src=p/'model_outputs/A51_REAL_PIXELLAB_BODY_12FRAME_256x192.png'
assert body.tobytes()==Image.open(reference_src).convert('RGBA').tobytes()
def curve(points,steps=36):
 p0,p1,p2=points
 return [(round((1-t)**2*p0[0]+2*(1-t)*t*p1[0]+t*t*p2[0]),
          round((1-t)**2*p0[1]+2*(1-t)*t*p1[1]+t*t*p2[1]))
   for i in range(steps+1) for t in [i/steps]]
def stamp(target,loc,color):
 x,y=loc
 if 1<=x<=62 and 1<=y<=62:target.putpixel((x,y),color)
raw=Image.new('RGBA',(256,192))
palette={'aura':(87,180,181,95),'mint':(155,224,210,165),
 'edge':(235,250,233,215),'gold':(254,223,157,180),'faint':(98,173,162,72)}
fxcounts={}
for i in range(12):
 c=Image.new('RGBA',(64,64))
 d=ImageDraw.Draw(c)
 if i==5:
  stamp(c,(57,25),palette['faint'])
  stamp(c,(58,26),palette['aura'])
 if i==6:
  for pt,col in [((50,25),palette['mint']),((50,26),palette['edge']),
                 ((49,25),palette['aura']),((51,26),palette['aura'])]:
   stamp(c,pt,col)
 if i==7:
  # True PixelLab R2 sword tip path F6 (50,26) -> F7 (61,39).
  # 64px hard-edged Bezier with a 1-2px dual-tone trail, never touching head/face.
  arc=curve([(50,26),(61,25),(62,39)],44)
  for x,y in arc:
   stamp(c,(x,y),palette['mint'])
   stamp(c,(x+1,y),palette['aura'])
  for x,y in arc[::3]:
   stamp(c,(x,y),palette['edge'])
  for x,y in [(59,33),(60,35),(61,37)]:
   stamp(c,(x,y),palette['edge'])
  stamp(c,(62,38),palette['gold'])
 if i==8:
  trail=curve([(62,39),(62,46),(56,49)],20)
  for x,y in trail:
   stamp(c,(x,y),palette['aura'])
  for x,y in trail[::4]:stamp(c,(x,y),palette['mint'])
  stamp(c,(57,48),palette['gold'])
 if i==9:
  stamp(c,(54,49),palette['faint'])
 if i in [5,6,7,8,9]:
  for y in range(64):
   for x in range(64):
    alpha=c.getpixel((x,y))[3]
    if not alpha:continue
    assert 46<=x<=63 and 21<=y<=51,('FX out of right-side blade corridor',i,x,y)
    assert not(21<=x<=45 and 15<=y<=35),'FX over character face'
  fxcounts[str(i)]=sum(px[3]>0 for px in c.get_flattened_data())
 raw.alpha_composite(c,(i%4*64,i//4*64))
assert fxcounts['7']>fxcounts['6']*3,(fxcounts,'F7 effect should peak')
assert fxcounts['8']<fxcounts['7'],'F8 afterimage should decay'
assert fxcounts['7']<=70,'avoid giant FX overpowering 64px hero'
# preserve A50 small sparks as a trace only; use NEW effect without stale positions.
fxdest=assets/'actor01_a51_fx_swordtrail_12frames.png'
raw.save(fxdest)
combined=body.copy();combined.alpha_composite(weapon);combined.alpha_composite(raw)
combined.save(assets/'actor01_a51_swordtrail_composite_reference.png')
# GDScript runtime asset path and engine native test path updated.
anim=proj/'scripts/fs_actor_animator.gd'
code=anim.read_text(encoding='utf8')
assert code.count('actor01_a51_fx_12frames.png')==1
code=code.replace('actor01_a51_fx_12frames.png','actor01_a51_fx_swordtrail_12frames.png')
anim.write_text(code,encoding='utf8')
manifest=assets/'actor01_animation_manifest.json'
j=json.loads(manifest.read_text(encoding='utf8'))
j['layering']['fx']='res://assets/actor01_a51_fx_swordtrail_12frames.png'
j['animation_profiles']['attack_weighted']['provenance']='True A51 PixelLab fullbody unedited, true model isolated sword; original custom source palette blade-trajectory FX generated only on FX layer'
manifest.write_text(json.dumps(j,indent=2),encoding='utf8')
gputest=proj/'qa/a51_native_gpu_runtime_qa.gd'
text=gputest.read_text(encoding='utf8')
assert 'actor01_a51_fx_12frames.png' in text and 'actor01_a51_composite_reference.png' in text
text=text.replace('actor01_a51_fx_12frames.png','actor01_a51_fx_swordtrail_12frames.png')
text=text.replace('actor01_a51_composite_reference.png','actor01_a51_swordtrail_composite_reference.png')
gputest.write_text(text,encoding='utf8')
# Separate visual contact sheet for original and new FX at gameplay size.
strip=Image.new('RGBA',(768,128),(34,38,44,255))
for i in range(12):
 x=i%4*64;y=i//4*64
 def fr(im):return im.crop((x,y,x+64,y+64))
 before=fr(body);before.alpha_composite(fr(weapon));before.alpha_composite(fr(old_fx))
 after=fr(body);after.alpha_composite(fr(weapon));after.alpha_composite(fr(raw))
 strip.alpha_composite(before,(64*i,0));strip.alpha_composite(after,(64*i,64))
strip.resize((2304,384),Image.Resampling.NEAREST).save(p/'A51_OLD_VS_SWORDTRAIL_12FRAME_3X.png')
data={'stage':'A51 swordtrail','PixelLab_real_full_body_untouched':True,
 'old_Body_sha256':hashlib.sha256((base/'assets/actor01_a51_body_12frames.png').read_bytes()).hexdigest(),
 'new_Body_SHA256':hashlib.sha256((proj/'assets/actor01_a51_body_12frames.png').read_bytes()).hexdigest(),
 'effect_frame_counts':fxcounts,'palette':palette,
 'stroke_follows_actual_PixelLab_tip_F6':[50,26],
 'stroke_follows_actual_PixelLab_tip_F7':[61,39],
 'source_R2_provider_real_sword':True,
 'FX_only_new_layer':True,
 'all_sparks_right_of_face':True,'style':'hard-edged 64px pixel, five-color max, no antialias',
 'ENGINE':'PENDING','ART':'HOLD'}
assert data['old_Body_sha256']==data['new_Body_SHA256']
(p/'A51_SWORDTRAIL_FX_QA.json').write_text(json.dumps(data,indent=2),encoding='utf8')
print('A51_VFX_PHYSICAL_BLADE_CORRIDOR_PASS','counts',fxcounts,
 'body_unchanged',True,'palette',len(palette),'FX_RGBA_SHA',hashlib.sha256(fxdest.read_bytes()).hexdigest(),flush=True)