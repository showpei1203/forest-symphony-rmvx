#!/usr/bin/env python3
"""Forest Symphony T-C D16 FS_04_MAZE Ground-first, original 1x CompletePAR TECH candidate.

Input A: D11 Ground-only privately held RGB 1280x928 (the source of new maze terrain).
Input B: D15 independently authored ALL-non-ground RGBA 1474x1067 (existing prop family).

Output A is created and locked before Output B. Output B is a newly staged 1280x928
canvas from 1x copied non-ground pixels, NOT a reverse segmented Master and NEVER
from the Ground. No resizing, generation cost, or Godot/ART PASS claims.

This is a technical second biome sample; visible matte/placement flaws remain
ART HOLD pending an independently approved full map. Original sources untouched.
"""
from __future__ import annotations
import argparse, hashlib, json, tempfile
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy.ndimage import distance_transform_edt

GROUND_SHA='ebc6b0f5ad5e5a853e4a470c77c7a2e080609add78d44eb705bc7b51d021fc8d'
D15_PAR_SHA='1063c9bd0180e771da32ffffbcc5c00b6e409bffbc603524c17001010ae0c3a9'
W,H=1280,928
SCENE='FS_04_MAZE'

def sha(p:Path):
    h=hashlib.sha256()
    with Path(p).open('rb') as f:
        for chunk in iter(lambda:f.read(1<<20),b''):h.update(chunk)
    return h.hexdigest()

def grounded_patch(base,reference,srcbox,dstbox,feather):
    ax,ay,bx,by=dstbox
    patch=reference.crop(srcbox)
    if patch.size != (bx-ax,by-ay):raise ValueError('Ground patch cannot be resampled')
    mask=Image.new('L',patch.size,0)
    ImageDraw.Draw(mask).ellipse((feather//2,feather//2,patch.width-feather//2,patch.height-feather//2),fill=255)
    mask=mask.filter(ImageFilter.GaussianBlur(feather))
    field=np.asarray(mask,dtype=np.float32)
    hh,ww=field.shape
    yy,xx=np.indices((hh,ww))
    edge=np.minimum.reduce((xx,yy,ww-1-xx,hh-1-yy)).astype(np.float32)
    field*=np.clip(edge/max(1,feather//3),0,1)
    base.paste(patch,(ax,ay),Image.fromarray(np.uint8(field),'L'))


def make_ground(source_ground:Image.Image)->Image.Image:
    if source_ground.size!=(W,H) or source_ground.mode!='RGB':
        raise ValueError('D11 Ground must be exactly RGB 1280x928')
    out=source_ground.copy()
    # Three broad intentional zones; these are exclusively terrain surfaces.
    # Every output pixel is native 1x; no image.resize()/PIL interpolation.
    for src, dst, feather in [
        ((40,450,620,850),(335,245,915,645),70),
        ((725,100,1175,465),(20,80,470,445),70),
        ((165,50,625,390),(795,460,1255,800),65),
    ]:
        grounded_patch(out,source_ground,src,dst,feather)
    return out

# Fixed regions copied from independently-generated D15 CompletePAR; excludes
# any Ground material, actor logic, data access or licensed third-party sprites.
# Polygon masks prevent rectangular black/white seams; whether whole buildings
# are semantically intact remains HUMAN ART HOLD (never inferred from alpha).
PROP_PLACEMENTS=[
 ('smithy_hut',(65,332,412,561),(45,75),[(73,385),(112,343),(202,339),(296,363),(378,399),(407,418),(404,513),(364,541),(77,561),(68,506)]),
 ('iron_chasm_bridge',(970,424,1474,646),(740,327),[(970,442),(1380,434),(1474,442),(1474,621),(1385,644),(1320,629),(1005,620),(970,592)]),
 ('southern_foundry',(760,618,1430,1049),(610,494),[(760,735),(840,704),(952,633),(1050,622),(1178,644),(1282,615),(1330,667),(1400,674),(1430,816),(1430,962),(1150,1049),(878,1035),(763,954)]),
 ('lava_crane',(147,826,399,1066),(18,650),[(148,852),(207,829),(324,832),(392,858),(399,1034),(361,1066),(161,1066),(148,1042)]),
 ('metal_lamp',(404,341,502,482),(492,363),[(417,460),(411,409),(432,393),(437,360),(455,342),(481,354),(490,387),(499,441),(483,476),(428,480)]),
 ('forgebanner',(587,648,676,831),(522,628),[(597,831),(590,739),(605,671),(628,649),(654,660),(669,699),(676,823)]),
]

def make_par(independent_source:Image.Image):
    if independent_source.mode!='RGBA' or independent_source.size!=(1474,1067):
        raise ValueError('Independent D15 source must be RGBA 1474x1067')
    out=Image.new('RGBA',(W,H),(0,0,0,0));ledger=[]
    for name,roi,(tx,ty),polygon in PROP_PLACEMENTS:
        x0,y0,x1,y1=roi
        crop=independent_source.crop(roi)
        mat=Image.new('L',crop.size,0)
        ImageDraw.Draw(mat).polygon([(x-x0,y-y0) for x,y in polygon],fill=255)
        mat=mat.filter(ImageFilter.GaussianBlur(2))
        src_alpha=np.asarray(crop.getchannel('A'),dtype=np.float32)
        alpha=np.uint8(np.clip(np.round(src_alpha*np.asarray(mat,dtype=np.float32)/255.),0,255))
        crop.putalpha(Image.fromarray(alpha,'L'))
        if tx<0 or ty<0 or tx+crop.width>W or ty+crop.height>H:
            raise ValueError('Clipped output stage: '+name)
        prev=np.asarray(out.crop((tx,ty,tx+crop.width,ty+crop.height)).getchannel('A'))
        overlap=int(((prev>127)&(alpha>127)).sum())
        stage=Image.new('RGBA',(W,H),(0,0,0,0));stage.paste(crop,(tx,ty))
        out=Image.alpha_composite(out,stage)
        ledger.append({
            'name':name,'source_roi':list(roi),'target_xy':[tx,ty],
            'source_pixel_scale_1x':True,
            'alpha_positive_in_source_roi':int((src_alpha>0).sum()),
            'alpha_positive_after_polygon_trim':int((alpha>0).sum()),
            'trimmed_pixels':int(((src_alpha>0)&(alpha==0)).sum()),
            'overlap_opaque_with_prior':overlap,
            'unsealed_art_risk':'HOLD_POLYGON_TRIM_OR_FOOTPOINT'
        })
    return out,ledger


def generate(ground_src:Path, par_src:Path, output_dir:Path,
             expected_ground:str=GROUND_SHA,expected_par:str=D15_PAR_SHA):
    ground_src,par_src,output_dir=map(Path,(ground_src,par_src,output_dir))
    if not ground_src.is_file() or not par_src.is_file(): raise FileNotFoundError('Both private sources required')
    if ground_src.resolve()==par_src.resolve(): raise ValueError('Ground/CompletePAR source files must differ')
    if sha(ground_src)!=expected_ground or sha(par_src)!=expected_par:
        raise ValueError('Independent original source SHA mismatch; fail closed')
    if output_dir.exists() and list(output_dir.iterdir()):
        raise ValueError('Output folder must be empty; never overwrite user art')
    output_dir.mkdir(parents=True,exist_ok=True)
    with Image.open(ground_src) as source_ground:
        ground=make_ground(source_ground)
    gn=output_dir/'GROUND.png';ground.save(gn,optimize=True)
    lock={
        'stage':'GROUND_FIRST_SHA_LOCKED','scene_id':SCENE,'canvas':[W,H],
        'grid_32px':[40,29],'source_D11_ground_sha256':sha(ground_src),
        'authored_terrain_sha256':sha(gn),
        'par_status':'NOT_GENERATED_AT_GROUND_STAGE',
        'non_ground_in_ground':'NONE_INTENDED_REVIEW_REQUIRED',
        'art_gate':'HOLD'
    }
    (output_dir/'01_GROUND_LOCK.json').write_text(json.dumps(lock,ensure_ascii=False,indent=2)+'\n')
    if (output_dir/'PAR.png').exists(): raise AssertionError('PAR must not preexist Ground lock')
    with Image.open(par_src) as independent_source:
        par,ledger=make_par(independent_source)
    pn=output_dir/'PAR.png';par.save(pn,optimize=True)
    cn=output_dir/'COMPOSITE_QA.png'
    Image.alpha_composite(ground.convert('RGBA'),par).save(cn,optimize=True)
    a=np.asarray(par.getchannel('A'));h=np.bincount(a.ravel(),minlength=256)
    report={
        'scene_id':SCENE,'scene_name':'熔脈裂橋','biome':'CRIMSON_VOLCANO',
        'method':'GROUND_FIRST_SOURCE_RECOMPOSITION_THEN_INDEPENDENT_ALL_NON_GROUND_PAR_1X',
        'source_D11_SHA256':sha(ground_src),'source_D15_independent_PAR_SHA256':sha(par_src),
        'ground_SHA256':sha(gn),'par_SHA256':sha(pn),'preview_SHA256':sha(cn),
        'output_px':[W,H],'output_grid':[40,29],'output_ground_mode':ground.mode,
        'output_PAR_mode':par.mode,'no_mixed_master_reverse_extraction':True,
        'par_all_non_ground_object_classes':len(ledger),'objects':ledger,
        'alpha':{'zero':int(h[0]),'1_to_8':int(sum(h[1:9])),
                 '9_to_239':int(sum(h[9:240])), '240_to_254':int(sum(h[240:255])),
                 '255':int(h[255])},
        'native_1x_raster_output':True,'no_resampling_1x_props':True,
        'visual_structure':'ART_HOLD_VISIBLE_SOURCE_MATTE_TRIMS_AND_WORLD_XY_APPROVAL',
        'private_art_Godot_4_7_2_native':'NOT_RUN',
        'battle_quest_integration':'NOT_RUN', 'formal_ART_PASS':'HOLD_0_OF_12',
        'risk_summary':'Ground uses re-composed source material, PAR polygon trimming may cut original connected props, bridge anchors do not coincide clearly with lava, no actual Godot test.',
    }
    (output_dir/'D16_PAIR_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--ground-source',type=Path,required=True)
    p.add_argument('--par-source',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--ground-sha256',default=GROUND_SHA)
    p.add_argument('--par-sha256',default=D15_PAR_SHA)
    x=p.parse_args()
    report=generate(x.ground_source,x.par_source,x.out,x.ground_sha256,x.par_sha256)
    print(json.dumps({'scene':report['scene_id'],'size':report['output_px'],
      'ground_sha':report['ground_SHA256'],'par_sha':report['par_SHA256'],
      'alpha_zero':report['alpha']['zero'],'art':'HOLD','godot':'NOT_RUN'},ensure_ascii=False))
