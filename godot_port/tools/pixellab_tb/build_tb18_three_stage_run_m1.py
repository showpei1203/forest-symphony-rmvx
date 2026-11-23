#!/usr/bin/env python3
"""Forest Symphony T-B R18: offline 3 genuine source-locked 12F RUN atlas assembly.
Input 3 individually paid private PixelLab outputs + immutable R17 archive.
Output one complete art-only Godot 4.7.2 M1 project and private owner review.
NO network or PixelLab API; no Windows local game edits; no false native PASS.
"""
from __future__ import annotations
import copy,hashlib,io,json,math,os,pathlib,shutil,zipfile
from PIL import Image,ImageDraw,ImageFont
BASE=pathlib.Path('/mnt/data')
R17=BASE/'FS_TB_R17_GLACIER_JACKAL_3GUARD_NATIVE_VERIFIED_PRIVATE_20261123.zip'
R17_SHA='d7e8d8b168e8f4553ba735972d1fb573f1439d3850aedb1c2dd5bd30b6e581ad'
STAGING=BASE/'r18_build'/'m1_source_staging'
OUT=BASE/'FS_TB_R18_3STAGE_RUN_12F_M1_GODOT_NATIVE_HOLD_20261123.zip'
PROOF=BASE/'FS_TB_R18_3STAGE_RUN_12F_M1_PROOF.json'
STAGE_FILES={i:BASE/f'R18_RUN_STAGE{i}_TRUE_PIXELLAB_12F_PRIVATE.zip' for i in (1,2,3)}
M='FS_TB_R18_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=93 evolutions=6 clips=99 frames=898 frost_run=3'
sha=lambda b:hashlib.sha256(b).hexdigest()
def png(image):
    b=io.BytesIO();image.save(b,format='PNG');return b.getvalue()
def writej(p,data):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8')
def verify_stage(stage,p,src):
    assert p.is_file(),('missing stage',stage)
    with zipfile.ZipFile(p) as z:
        assert z.testzip() is None
        ledger=json.loads(z.read('R18_JOB_LEDGER.json'))
        assert ledger['stage']==stage and ledger['status']=='COMPLETED_SOURCE_QA_PASS'
        assert ledger['source_r17_sha256']==R17_SHA and ledger['source_stage_sha256']==src['source_sha256']
        assert ledger['idle_atlas_sha256']==src['motions']['idle']['sha256']
        assert ledger['requested_frames']==12
        assert ledger['selected_frame_count']==12 and ledger['qa']['frame_qa']=='PASS'
        assert ledger['qa']['first_last_exact_idle_source'] is True
        assert ledger['qa']['foot_alpha_unique_frames']>=5
        assert 0<float(ledger['reported_usage']['generations'])<=16
        atlas_raw=z.read('R18_RUN_12F_ATLAS.png')
        assert sha(atlas_raw)==ledger['atlas_png_sha256']
        size=src['source_size'][0]
        atlas=Image.open(io.BytesIO(atlas_raw)).convert('RGBA')
        assert atlas.size==(size*4,size*3)
        frames=[atlas.crop(((n%4)*size,(n//4)*size,((n%4)+1)*size,((n//4)+1)*size)) for n in range(12)]
        assert [sha(f.tobytes()) for f in frames]==ledger['qa']['frame_rgba_shas']
        original=Image.open(io.BytesIO(z.read('R18_IDLE_SOURCE_F0.png'))).convert('RGBA')
        assert frames[0].tobytes()==frames[11].tobytes()==original.tobytes()
        assert min(len(set(sha(f.tobytes()) for f in frames)),ledger['qa']['foot_alpha_unique_frames'])>=5
        raws=[f for f in z.namelist() if f.startswith('raw_frames/F') and f.endswith('.png')]
        assert len(raws) in (12,13)
        assert len(raws)==ledger['raw_returned_frames']
        assert sorted(sha(z.read(f)) for f in raws)==sorted(ledger['raw_frame_sha256'])
        return ledger,atlas_raw,frames

def build():
    assert R17.stat().st_size==11295309 and sha(R17.read_bytes())==R17_SHA
    assert not OUT.exists() and not PROOF.exists(),'Never overwrite another M1 run'
    with zipfile.ZipFile(R17) as original:
        assert original.testzip() is None and len(original.namelist())==430
        old=json.loads(original.read('godot/TB17_MONSTER_FAMILY_MANIFEST.json'))
        assert old['clip_count']==96 and old['total_frames']==862
        frost=next(x for x in old['families'] if x['kind']=='frost')
        assert all(len(x['motions'])==6 for x in frost['stages'])
        parsed={i:verify_stage(i,STAGE_FILES[i],frost['stages'][i-1]) for i in (1,2,3)}
        assert not STAGING.exists(),'Existing staging collision'
        STAGING.mkdir(parents=True)
        for f in original.infolist():
            path=pathlib.PurePosixPath(f.filename)
            assert '..' not in path.parts and not f.filename.startswith('/')
            dst=STAGING.joinpath(*path.parts)
            if f.is_dir():dst.mkdir(parents=True,exist_ok=True)
            else:dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(original.read(f))
    G=STAGING/'godot';R=STAGING/'reports'
    now=copy.deepcopy(old)
    # Native R17 attestation must not falsely imply NEW R18 Godot native success.
    now['source_r17_previous_native_log_sha256']=old.get('native_log_sha256')
    for key in list(now):
        if key.startswith(('native_','official_windows_godot_')):
            now.pop(key)
    now['storage_status']='DRIVE_PUBLICATION_PENDING_R18_M1'
    variants=next(x for x in now['families'] if x['kind']=='frost')
    ledger=[];qa=[];images={};cost=0.0
    for i in (1,2,3):
        status,atlas_raw,frames=parsed[i]
        st=variants['stages'][i-1]
        name=f'FROST_STAGE{i}_RUN_R18_TRUE_PIXELLAB_12F_{st["source_size"][0]}px.png'
        rel='assets/monsters/tb03/'+name
        dst=G/rel;assert not dst.exists()
        dst.parent.mkdir(exist_ok=True,parents=True);dst.write_bytes(atlas_raw)
        cc=float(status['reported_usage']['generations']);cost+=cc
        st['motions']['run']={
            'path':rel,'frames':12,'columns':4,'cell':st['source_size'],
            'fps':10,'loop':True,'sha256':sha(atlas_raw),'source_sha256':st['source_sha256'],
            'source_idle_sha256':status['idle_atlas_sha256'],'endpoint':'animate-with-text-v3',
            'provider_job_id':status['job_id'],'generation_id':status.get('generation_id'),
            'provider_usage':status['reported_usage'],
            'raw_returned_frames':status['raw_returned_frames'],
            'raw_original_source_zip_sha256':sha(STAGE_FILES[i].read_bytes()),
            'exact_source_frames':[0,11],
            'foot_alpha_unique_frames':status['qa']['foot_alpha_unique_frames'],
            'technical_qa':'PASS','art_status':'OWNER_ART_REVIEW_PENDING'}
        ledger.append({'stage':i,'job_id':status['job_id'],'generations':cc,
                       'stage_zip_sha256':sha(STAGE_FILES[i].read_bytes()),'stage_atlas_sha256':sha(atlas_raw),
                       'source_sha256':st['source_sha256']})
        qa.append({'stage':i,'cell':st['source_size'][0],'frames':12,'source_locked':True,
                   'foot_alpha_unique_frames':status['qa']['foot_alpha_unique_frames'],
                   'unique_rgba_frames':len(set(status['qa']['frame_rgba_shas'])),
                   'needs_human_gait_art_review':True})
        images[i]=frames
        target=R/'r18_provider_raw'/STAGE_FILES[i].name
        target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(STAGE_FILES[i],target)
    assert all(len(st['motions'])==7 for st in variants['stages'])
    now.update(schema='FS_TB_R18_GENUINE_PIXEL_LAB_RUN_12F_THREE_STAGE',
        clip_count=99,total_frames=898,baseline_clip_count=93,
        actions_per_family={'bat':12,'frog':12,'frost':7},
        third_family_motions=21,new_pixel_lab_jobs=3,
        new_provider_generations=cost,new_true_provider_frame_slots=36,
        source_r17_zip_sha256=R17_SHA,
        technical_qa='NATIVE_NOT_RUN',human_art_gate='OWNER_ART_REVIEW_PENDING',
        integration_qa='NOT_RUN_ART_ONLY',
        visual_gate_note='Real provider 12F locomotion footage, foot alpha structure checks only; complete gait artistic acceptance PENDING')
    writej(G/'TB18_MONSTER_FAMILY_MANIFEST.json',now)
    writej(R/'R18_THREE_STAGE_PROVIDER_LEDGER.json',ledger)
    writej(R/'R18_THREE_STAGE_SOURCE_AND_FOOT_QA.json',qa)
    # Tested R17 native scene and test are a stable implementation basis; preserve them and derive new R18 only.
    g=(G/'tb17_frost_guard_gallery.gd').read_text(encoding='utf8')
    g=g.replace('TB17_MONSTER_FAMILY_MANIFEST.json','TB18_MONSTER_FAMILY_MANIFEST.json')
    g=g.replace('R17: 3 ORIGINAL PIXELLAB GUARD ANIMATIONS','R18: 3 ORIGINAL PIXELLAB RUN 12F ANIMATIONS')
    g=g.replace('"guard"','"run"').replace('range(8)','range(12)')
    assert 'range(12)' in g and '"guard"' not in g
    (G/'tb18_frost_run_gallery.gd').write_text(g,encoding='utf8')
    sc=(G/'tb17_frost_guard_gallery.tscn').read_text(encoding='utf8')
    sc=sc.replace('tb17_frost_guard_gallery.gd','tb18_frost_run_gallery.gd').replace('TB17FrostGuard','TB18FrostRun')
    (G/'tb18_frost_run_gallery.tscn').write_text(sc,encoding='utf8')
    t=(G/'tests/test_tb17_frost_guard_native.gd').read_text(encoding='utf8')
    t=t.replace('TB17_MONSTER_FAMILY_MANIFEST.json','TB18_MONSTER_FAMILY_MANIFEST.json')
    t=t.replace('int(doc["clip_count"])==96','int(doc["clip_count"])==99')
    t=t.replace('int(doc["total_frames"])==862','int(doc["total_frames"])==898')
    t=t.replace('int(doc["baseline_clip_count"])==90','int(doc["baseline_clip_count"])==93')
    t=t.replace('assert(count==90 and slots==766)','assert(count==93 and slots==802)')
    t=t.replace('tb17_frost_guard_gallery.tscn','tb18_frost_run_gallery.tscn')
    t=t.replace('"guard"','"run"').replace('get_frame_count("run")==8','get_frame_count("run")==12')
    t=t.replace('get_frame_texture("run",7)','get_frame_texture("run",11)')
    t=t.replace('FS_TB_R17_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=90 evolutions=6 clips=96 frames=862 frost_guard=3',M)
    assert M in t and 'count==93' in t and '"guard"' not in t
    (G/'tests/test_tb18_frost_run_native.gd').write_text(t,encoding='utf8')
    # Contact sheet preserves original raster, uses nearest-neighbor only for independent review rendering.
    boxw=164;boxh=157
    view=Image.new('RGB',(1600,3*(boxh*3+55)+40),(26,41,59));dr=ImageDraw.Draw(view);font=ImageFont.load_default()
    dr.text((22,14),'R18 3-STAGE GENUINE PIXELLAB RUN/LOCOMOTION 12FRAMES | HUMAN ART REVIEW PENDING',fill=(228,236,227),font=font)
    for stage,frames in images.items():
        y0=38+(stage-1)*(boxh*3+55)
        dr.text((22,y0),f'STAGE {stage} / 12F / {frames[0].width}px',fill=(241,212,163),font=font)
        for n,f in enumerate(frames):
            col=n%6;row=n//6;x=135+col*230;y=y0+30+row*180
            frm=f.copy();frm.thumbnail((155,152),Image.Resampling.NEAREST)
            bg=Image.new('RGBA',frm.size,(39,58,75,255));bg.alpha_composite(frm)
            view.paste(bg.convert('RGB'),(x,y))
            dr.text((x+5,y-12),f'F{n}',fill=(237,238,228),font=font)
        animation=[]
        for f in frames:
            canvas=Image.new('RGBA',f.size,(28,45,66,255));canvas.alpha_composite(f)
            animation.append(canvas.resize((f.width*2,f.height*2),Image.Resampling.NEAREST).convert('RGB'))
        animation[0].save(R/f'R18_FROST_STAGE{stage}_RUN_TRUE_PIXEL_LAB_12F.gif',save_all=True,
            append_images=animation[1:],duration=100,loop=0,disposal=2)
    view.save(R/'R18_FROST_3STAGE_RUN_36F_CONTACT.png')
    # Every historical original source sprite remains byte identical.
    with zipfile.ZipFile(R17) as z:
        for n in z.namelist():
            if n.lower().endswith('.png'):
                assert sha((STAGING/n).read_bytes())==sha(z.read(n)),('original pixel edited',n)
    assert not (G/'.godot').exists()
    with zipfile.ZipFile(OUT,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for f in sorted(STAGING.rglob('*')):
            if f.is_file() and '.godot' not in f.parts:
                z.write(f,f.relative_to(STAGING).as_posix())
    with zipfile.ZipFile(OUT) as z:
        assert z.testzip() is None and len(z.namelist())>430
        stat=json.loads(z.read('godot/TB18_MONSTER_FAMILY_MANIFEST.json'))
        assert stat['clip_count']==99 and stat['total_frames']==898
        assert stat['technical_qa']=='NATIVE_NOT_RUN'
        assert M in z.read('godot/tests/test_tb18_frost_run_native.gd').decode('utf8')
        count=len(z.namelist())
    proof={'kind':'FS_TB_R18_ORIGINAL_3STAGE_12F_RUN_M1',
           'source_r17_sha256':R17_SHA,'sha256':sha(OUT.read_bytes()),
           'size':OUT.stat().st_size,'entries':count,'crc':'PASS',
           'new_source_locked_pixel_lab_jobs':3,'new_frames':36,
           'real_reported_generations':cost,'new_clips':3,'total_clips':99,'total_frame_slots':898,
           'native_Godot':'NOT_RUN','human_animated_art':'OWNER_REVIEW_PENDING',
           'gameplay_integration':'NOT_RUN_ART_ONLY',
           'three_stage_foot_qa':qa}
    writej(PROOF,proof)
    print('FS_TB_R18_M1_THREE_STAGE_SOURCE_QA_PASS',json.dumps({k:proof[k] for k in ('sha256','size','entries','real_reported_generations','total_clips','total_frame_slots')},ensure_ascii=False))
if __name__=='__main__':build()