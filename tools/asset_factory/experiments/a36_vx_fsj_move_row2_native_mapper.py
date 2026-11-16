from __future__ import annotations
import io, zipfile, json, hashlib, shutil
from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np
from scipy import ndimage

ROOT = Path('/mnt/data')
OUT = ROOT / 'FS_A36_FSJ_MOVE_ROW2_CANDIDATE_PRIVATE_20261114'
OUT.mkdir(parents=True, exist_ok=True)
z18 = zipfile.ZipFile(ROOT/'FS_A18_ACTOR01_RUN_PROVIDER_READY_PRIVATE_20261109.zip')
z35 = zipfile.ZipFile(ROOT/'FS_A35_V3_TWO_HALVES_FULL_RUN_8FRAME_PRIVATE_20261114.zip')
orig_path=ROOT/'$actor01_1.png'
assert orig_path.exists(), 'original native sheet unavailable'
native=Image.open(orig_path).convert('RGBA')
assert native.size==(96,128)

def imzip(z,path):
    return Image.open(io.BytesIO(z.read(path))).convert('RGBA')
run48=[imzip(z18,f'APPROVED_SOURCES/ACTOR01_A62_APPROVED_RUN_{i}.png') for i in (1,2,3)]
assert all(x.size==(48,48) for x in run48)
run64=[]
for im in run48:
    dest=Image.new('RGBA',(64,64))
    dest.paste(im,(8,8))
    run64.append(dest)
a35=imzip(z35,'A35_APPROVED_KEYFRAME_FULL_8FRAME_RUN_SHEET.png')
assert a35.size==(256,128)
full8=[a35.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64)) for i in range(8)]
# Experimental A35 F3/F7 are genuinely model-generated, not approved A62 keyframes.
exp48=[run48[0], full8[3].crop((8,8,56,56)), full8[7].crop((8,8,56,56))]

# Native-compatible 32px sampling is a deliberate scaled proof, not 48px exact art.
def resize_to_native32(frame48):
    assert frame48.size==(48,48)
    tmp=frame48.resize((38,38),Image.Resampling.NEAREST)
    result=tmp.crop((3,4,35,36))
    assert result.size==(32,32)
    return result

def make_row2_sheet(cells,case):
    assert len(cells)==3
    sheet=native.copy()
    for i,cell in enumerate(cells):
        assert cell.size==(32,32)
        sheet.paste(cell,(32*i,64))
    target=OUT/case
    target.mkdir(exist_ok=True)
    filename=target/'$actor01_1.png'
    sheet.save(filename)
    # Test unchanged 9 cells of the original sheet.
    ar=np.array(sheet)
    src=np.array(native)
    preserved=all(np.array_equal(ar[0:64,:,:],src[0:64,:,:]) for _ in range(1)) and np.array_equal(ar[96:128,:,:],src[96:128,:,:])
    assert preserved, 'non-RUN rows altered'
    return filename, preserved

baseline32=[resize_to_native32(f) for f in run48]
exp32=[resize_to_native32(f) for f in exp48]
baseline_path,pass_base=make_row2_sheet(baseline32,'A36_APPROVED_BASELINE_VX32')
experiment_path,pass_exp=make_row2_sheet(exp32,'A36_AI_FRAMES_EXPERIMENT_VX32_ART_HOLD')

# Bigger-cell experiment uses the original 48px A62/PixelLab art byte-exact in row 2.
# Other rows are nearest-neighbor magnified only for a prototype and NOT source-identical.
def make_hires_sheet(cells,case):
    sheet=native.resize((144,192),Image.Resampling.NEAREST)
    for i,f in enumerate(cells):
        assert f.size==(48,48)
        sheet.paste(f,(i*48,96))
    t=OUT/case;t.mkdir(exist_ok=True)
    target=t/'$actor01_1.png';sheet.save(target)
    for i,f in enumerate(cells):
        assert sheet.crop((i*48,96,i*48+48,144)).tobytes()==f.tobytes()
    return target
hires_base=make_hires_sheet(run48,'A36_APPROVED_BASELINE_VX48_CELL_EXPERIMENT')
hires_ai=make_hires_sheet(exp48,'A36_AI_FRAMES_VX48_CELL_EXPERIMENT_ART_HOLD')

# The loop uses F0 neutral for the too-wide F6 but *does not* pretend F7 is repaired.
# This tests selection as a correction, preserving exact original RGBA for all others.
conservative=[x.copy() for x in full8]
conservative[6]=run64[0]
loop_dir=OUT/'A36_CONSERVATIVE_8FRAME_F6_NEUTRAL_ART_HOLD'
loop_dir.mkdir(exist_ok=True)
sheet8=Image.new('RGBA',(256,128))
for i,f in enumerate(conservative):sheet8.paste(f,((i%4)*64,(i//4)*64))
sheet8.save(loop_dir/'A36_CONSERVATIVE_8FRAME_SHEET_256x128.png')
# Produce GIF for human assessment; PNG is the pixel authority.
preview_pal=[f.convert('P',palette=Image.Palette.ADAPTIVE,colors=64) for f in conservative]
preview_pal[0].save(loop_dir/'A36_CONSERVATIVE_8FRAME_LOOP.gif',save_all=True,append_images=preview_pal[1:],duration=125,loop=0,disposal=2,optimize=False,transparency=0)

# Correct 3-frame indexed VX animation semantic: C0 = neutral; C1/C2 = opposite stride.
# For a loop, playback [C0,C1,C0,C2], not [C0,C1,C2].
def formal_gif(seq,name):
    frames=[seq[i] for i in (0,1,0,2)]
    palette=[f.convert('P',palette=Image.Palette.ADAPTIVE,colors=64) for f in frames]
    fn=OUT/name
    palette[0].save(fn,save_all=True,append_images=palette[1:],duration=145,loop=0,disposal=2,optimize=False,transparency=0)
    assert Image.open(fn).n_frames==4
    return fn
formal_gif(baseline32,'A36_VX32_APPROVED_3FRAME_RUN_LOOP_0102.gif')
formal_gif(exp32,'A36_VX32_AI_CANDIDATE_RUN_LOOP_0102.gif')

# Visual QA: original 3x4 sheet, native-approved candidate, AI-row2 candidate,
# native 48px cell candidate. Only valid engine replacement is experimentally tested.
scaled=6
cellW=96*scaled;cellH=128*scaled
contact=Image.new('RGB',(3*cellW,cellH+52),(33,43,57))
d=ImageDraw.Draw(contact)
for i,(name,im) in enumerate([
 ('SOURCE 96x128 (original)',native),
 ('A36 96x128 APPROVED RUN',Image.open(baseline_path).convert('RGBA')),
 ('A36 96x128 AI F3 F7',Image.open(experiment_path).convert('RGBA'))]):
    x=i*cellW
    d.text((x+12,11),name,fill=(246,246,238))
    bg=Image.new('RGBA',im.size,(40,48,60,255));bg.alpha_composite(im)
    contact.paste(bg.convert('RGB').resize((cellW,cellH),Image.Resampling.NEAREST),(x,52))
contact.save(OUT/'A36_NATIVE_96x128_ROW2_VISUAL_QA_6X.png')

# Compare true 48px sprites versus sampling to 32px to expose lost detail.
W=480;H=510
compare=Image.new('RGB',(W*3,H*2),(30,38,52));d=ImageDraw.Draw(compare)
for row,(lab,seq,dim) in enumerate([('48PX EXACT',exp48,48),('32PX SCALE',exp32,32)]):
    for i,f in enumerate(seq):
        x=i*W;y=row*H
        label=f'{lab} frame {i} (A62 neutral / A35 F3 / A35 F7)'
        d.text((x+9,y+9),label,fill=(250,249,242))
        back=Image.new('RGBA',f.size,(46,56,71,255));back.alpha_composite(f)
        # expand image at a native pixel-integer scale. Native 48→9x; 32→13x
        mult=9 if dim==48 else 13
        tile=back.convert('RGB').resize((f.width*mult,f.height*mult),Image.Resampling.NEAREST)
        compare.paste(tile,(x+(W-tile.width)//2,y+40))
compare.save(OUT/'A36_NATIVE48_VS_VX32_SCALELOSS_6PANEL.png')

# Before/after 8frame F6 neutral comparison. (Only F6 differs)
pre=[full8[i] for i in [4,5,6,7]]
post=[conservative[i] for i in [4,5,6,7]]
pair=Image.new('RGB',(4*64*8,2*(64*8+31)),(34,43,57));pd=ImageDraw.Draw(pair)
for r,group in enumerate([pre,post]):
    for c,f in enumerate(group):
        tx=c*64*8;ty=r*(64*8+31)
        pd.text((tx+9,ty+7),f'{"A35 ORIGINAL" if r==0 else "A36 CONSERVATIVE"} F{c+4}',(245,246,240))
        back=Image.new('RGBA',(64,64),(47,56,69,255));back.alpha_composite(f)
        pair.paste(back.convert('RGB').resize((512,512),Image.Resampling.NEAREST),(tx,ty+31))
pair.save(OUT/'A36_F6_REPLACEMENT_8X_BEFORE_AFTER.png')

# QA
bboxes=[[int(c) for c in f.getchannel('A').getbbox()] for f in full8]
frame_counts=[]
for seq in [baseline32,exp32]:
    frame_counts.append([sum(1 for p in f.getdata() if p[3]>0) for f in seq])
qa={
    'stage':'A36', 'date':'2026-11-14',
    'source_rmvx_path':r'E:\遊戲專案開發\三大項目現行專案\FS project\Graphics\Characters\$actor01_1.png',
    'original_layout':{'width':96,'height':128,'cell':[32,32],'columns':3,'rows':4},
    'script_reference':{'action':'FSJ_MOVE','file_no':1,'row_index_zero_based':2,'script_line':'FSJ_MOVE => [1,2,12,0,0,-1,0,true,"\"]'},
    'original_sha256':hashlib.sha256(orig_path.read_bytes()).hexdigest(),
    'non_run_rows_unchanged_32px':pass_base and pass_exp,
    'baseline_frames':['A62 approved RUN1','A62 approved RUN2','A62 approved RUN3'],
    'experimental_frames':['A62 approved RUN1','A35 genuine Pixellab new F3','A35 genuine Pixellab new F7'],
    '32px_downscale_transformation':'48px source -> nearest-neighbor 38x38 -> crop (3,4,35,36); no color synthesis; silhouette details reduced',
    'native48_alternate_layout':{'size':[144,192],'cell':[48,48],'caveat':'All nine other original cells upscaled nearest; game sprite bounding-box compatibility not verified'},
    '32px_baseline_nontransparent_pixel_counts':frame_counts[0],
    '32px_ai_nontransparent_pixel_counts':frame_counts[1],
    '8frame_source_bboxes':bboxes,
    '8frame_conservative_patch':{'changed_indices':[6],'F6_from':'A62 approved RUN1 exact RGBA padded 64px','F7_unmodified':'A35 F7 still ART HOLD'},
    'formal_run_semantics':'Three slots; loop playback [0,1,0,2]. Must not reverse all 8 into VX 3 columns.',
    'native_vx_engine_test':'NOT_RUN',
    'godot_engine_test':'NOT_RUN',
    'art_gate':'HOLD for style mismatch in 3x4 sheet, F7 hand, and unverified stride naturalness',
    'original_rmvx_project_modified':False,
}
(OUT/'A36_QA_PRE_ENGINE.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf-8')
manifest={}
for p in sorted(OUT.rglob('*.png')):
    manifest[str(p.relative_to(OUT))]={'size':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
(OUT/'A36_PNG_SHA256_MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
archive=ROOT/'FS_A36_FSJ_MOVE_ROW2_NATIVE_AND_HIRES_ART_HOLD_PRIVATE_20261114.zip'
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in sorted(OUT.rglob('*')):
        if p.is_file(): z.write(p,p.relative_to(OUT))
with zipfile.ZipFile(archive) as z: assert z.testzip() is None
print('OUT',OUT)
print('ZIP',archive,'bytes',archive.stat().st_size,'sha256',hashlib.sha256(archive.read_bytes()).hexdigest())
print('preserved_rows',pass_base,pass_exp)
print('frame_counts',frame_counts)
print('QA',qa['native_vx_engine_test'])
