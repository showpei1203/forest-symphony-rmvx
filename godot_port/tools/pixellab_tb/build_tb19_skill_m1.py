#!/usr/bin/env python3
"""Forest Symphony T-B R19 source-locked ICE SKILL art-only native-ready M1.

Offline only. Three already-paid R19 provider source ZIPs; immutable R18 private
native official ZIP. This NEVER invokes PixelLab. Native Godot remains NOT_RUN.
Output to isolated local sandbox before owner-private Drive upload.
"""
from __future__ import annotations
import argparse,copy,hashlib,io,json,math,shutil,tempfile,zipfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

R18_SHA='8cc85ea1ca326ce854b3432a46c63fb311aaba3ca5628d101e10a54fc03cae6c'
R18_BYTES=12626646
OLD_MARK='FS_TB_R18_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=93 evolutions=6 clips=99 frames=898 frost_run=3'
NEW_MARK='FS_TB_R19_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=96 evolutions=6 clips=102 frames=934 frost_skill=3'

def sha(b:bytes)->str:return hashlib.sha256(b).hexdigest()
def dump(p:Path,v):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding='utf-8')
def image(b):return Image.open(io.BytesIO(b)).convert('RGBA')
def frames_from_atlas(b:bytes,n:int):
    atlas=image(b)
    assert atlas.size==(n*4,n*3)
    return [atlas.crop(((i%4)*n,(i//4)*n,((i%4)+1)*n,(i//4+1)*n)) for i in range(12)]
def parse_stage(p:Path,st:dict,stage:int,mock:bool=False):
    assert p.exists(),('R19 stage provider ZIP missing',stage)
    with zipfile.ZipFile(p) as z:
        assert z.testzip() is None and len(z.namelist())==len(set(z.namelist()))
        d=json.loads(z.read('R19_JOB_LEDGER.json'))
        assert d['stage']==stage and d['source_r18_sha256']==R18_SHA
        assert d['source_stage_sha256']==st['source_sha256']
        assert d['idle_atlas_sha256']==st['motions']['idle']['sha256']
        assert d['requested_frames']==d['selected_frame_count']==12
        assert d['status']=='COMPLETED_SOURCE_QA_PASS'
        assert d['qa']['frame_qa']=='PASS' and d['qa']['first_last_exact_idle_source'] is True
        assert float(d['reported_usage']['generations'])>0
        assert d.get('job_id') and d.get('generation_id')
        raw_atlas=z.read('R19_SKILL_12F_ATLAS.png')
        assert sha(raw_atlas)==d['atlas_png_sha256']
        size=st['source_size'][0]
        frames=frames_from_atlas(raw_atlas,size)
        assert [sha(x.tobytes()) for x in frames]==d['qa']['frame_rgba_shas']
        source=image(z.read('R19_IDLE_SOURCE_F0.png'))
        assert source.size==(size,size)
        assert frames[0].tobytes()==frames[-1].tobytes()==source.tobytes()
        assert len(set(sha(x.tobytes()) for x in frames))>=8
        bb=[x.getchannel('A').getbbox() for x in frames]
        assert all(x is not None and min(x[0],x[1],size-x[2],size-x[3])>=2 for x in bb)
        originals=sorted(x for x in z.namelist() if x.startswith('raw_frames/F') and x.endswith('.png'))
        assert len(originals) in (12,13) and len(originals)==d['raw_returned_frames']
        assert [sha(z.read(x)) for x in originals]==d['raw_frame_sha256']
        if not mock:assert d.get('task')=='FS_TB_R19_TRUE_GAIT_STAGE' or 'SKILL' in d.get('task','')
        return d,raw_atlas,frames

def build(r18:Path,stagepaths:list[Path],out:Path,staging:Path,proof:Path,mock=False):
    assert r18.stat().st_size==R18_BYTES and sha(r18.read_bytes())==R18_SHA
    assert not out.exists() and not proof.exists() and not staging.exists(),'Refuse overwrite or staging collision'
    with zipfile.ZipFile(r18) as z:
        assert z.testzip() is None and len(z.namelist())==448
        baseline=json.loads(z.read('godot/TB18_MONSTER_FAMILY_MANIFEST.json'))
        assert baseline['clip_count']==99 and baseline['total_frames']==898
        frost=next(f for f in baseline['families'] if f['kind']=='frost')
        assert all(len(s['motions'])==7 and 'skill' not in s['motions'] for s in frost['stages'])
        parsed={i:parse_stage(stagepaths[i-1],frost['stages'][i-1],i,mock=mock) for i in (1,2,3)}
        staging.mkdir(parents=True)
        for name in z.namelist():
            parts=Path(name)
            assert not parts.is_absolute() and '..' not in parts.parts and not name.startswith(('\\','/'))
            dst=staging/name
            if name.endswith('/'):dst.mkdir(parents=True,exist_ok=True)
            else:dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(z.read(name))
    G=staging/'godot';R=staging/'reports'
    now=copy.deepcopy(baseline)
    now['source_r18_previous_native_log_sha256']=baseline.get('native_log_sha256')
    for key in list(now):
        if key.startswith(('native_','official_windows_godot_')):now.pop(key,None)
    now['technical_qa']='NATIVE_NOT_RUN'
    now['storage_status']='M1_OWNER_PRIVATE_UPLOAD_PENDING'
    stages=next(f for f in now['families'] if f['kind']=='frost')['stages']
    ledger=[];qa=[];images={};total_cost=0.
    for stage in (1,2,3):
        detail,atlas,frames=parsed[stage]
        st=stages[stage-1];size=st['source_size'][0]
        name=f'FROST_STAGE{stage}_SKILL_R19_TRUE_PIXELLAB_12F_{size}px.png'
        rel='assets/monsters/tb03/'+name;dst=G/rel
        assert not dst.exists();dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(atlas)
        cost=float(detail['reported_usage']['generations']);total_cost+=cost
        st['motions']['skill']={
          'path':rel,'frames':12,'columns':4,'cell':[size,size],'fps':9,'loop':False,
          'sha256':sha(atlas),'source_sha256':st['source_sha256'],
          'source_idle_sha256':detail['idle_atlas_sha256'],'endpoint':'animate-with-text-v3',
          'provider_job_id':detail['job_id'],'generation_id':detail['generation_id'],
          'provider_usage':detail['reported_usage'],'raw_returned_frames':detail['raw_returned_frames'],
          'raw_original_source_zip_sha256':sha(stagepaths[stage-1].read_bytes()),
          'exact_source_frames':[0,11],'technical_qa':'PASS','art_status':'OWNER_ART_REVIEW_PENDING'}
        ledger.append({'stage':stage,'job_id':detail['job_id'],'generations':cost,'source_zip_sha256':sha(stagepaths[stage-1].read_bytes()),'atlas_sha256':sha(atlas)})
        qa.append({'stage':stage,'cell':size,'source_exact':True,'unique_frames':len(set(sha(f.tobytes()) for f in frames)),
                   'visual_ice_cast_art':'OWNER_ART_REVIEW_PENDING','provider_reported_usage':detail['reported_usage']})
        images[stage]=frames
        priv=R/'r19_provider_raw'/stagepaths[stage-1].name
        priv.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(stagepaths[stage-1],priv)
    assert all(len(st['motions'])==8 for st in stages)
    now.update(schema='FS_TB_R19_TRUE_PIXELLAB_ICE_SKILL_12F_THREE_STAGE',clip_count=102,total_frames=934,
        baseline_clip_count=96,actions_per_family={'bat':12,'frog':12,'frost':8},third_family_motions=24,
        new_pixel_lab_jobs=3,new_provider_generations=total_cost,new_true_provider_frame_slots=36,
        source_r18_zip_sha256=R18_SHA,technical_qa='NATIVE_NOT_RUN',human_art_gate='OWNER_ART_REVIEW_PENDING',
        integration_qa='NOT_RUN_ART_ONLY',visual_gate_note='Original PixelLab frost cast, visible ice skill semantics require owner 1x ART signoff')
    dump(G/'TB19_MONSTER_FAMILY_MANIFEST.json',now)
    dump(R/'R19_THREE_STAGE_PROVIDER_LEDGER.json',ledger)
    dump(R/'R19_THREE_STAGE_SOURCE_AND_SKILL_QA.json',qa)
    g=(G/'tb18_frost_run_gallery.gd').read_text(encoding='utf-8')
    g=g.replace('TB18_MONSTER_FAMILY_MANIFEST.json','TB19_MONSTER_FAMILY_MANIFEST.json')
    g=g.replace('R18: 3 ORIGINAL PIXELLAB RUN 12F ANIMATIONS','R19: 3 ORIGINAL PIXELLAB ICE SKILL 12F ANIMATIONS')
    g=g.replace('"run"','"skill"')
    g=g.replace('ani.set_animation_loop("skill",true)','ani.set_animation_loop("skill",false)')
    assert 'ani.set_animation_loop("skill",false)' in g
    assert '"skill"' in g and '"run"' not in g
    (G/'tb19_frost_skill_gallery.gd').write_text(g,encoding='utf-8')
    sc=(G/'tb18_frost_run_gallery.tscn').read_text(encoding='utf-8')
    sc=sc.replace('tb18_frost_run_gallery.gd','tb19_frost_skill_gallery.gd').replace('TB18FrostRun','TB19FrostSkill')
    (G/'tb19_frost_skill_gallery.tscn').write_text(sc,encoding='utf-8')
    t=(G/'tests/test_tb18_frost_run_native.gd').read_text(encoding='utf-8')
    for old,new in [
      ('TB18_MONSTER_FAMILY_MANIFEST.json','TB19_MONSTER_FAMILY_MANIFEST.json'),
      ('int(doc["clip_count"])==99','int(doc["clip_count"])==102'),
      ('int(doc["total_frames"])==898','int(doc["total_frames"])==934'),
      ('int(doc["baseline_clip_count"])==93','int(doc["baseline_clip_count"])==96'),
      ('assert(count==93 and slots==802)','assert(count==96 and slots==838)'),
      ('tb18_frost_run_gallery.tscn','tb19_frost_skill_gallery.tscn'),
      ('"run"','"skill"'),(OLD_MARK,NEW_MARK)]:
        assert old in t,('native source marker missing',old)
        t=t.replace(old,new)
    t=t.replace('assert(spr.sprite_frames.get_frame_count("skill")==12)',
      'assert(spr.sprite_frames.get_frame_count("skill")==12)\\n        assert(not spr.sprite_frames.get_animation_loop("skill"))')
    assert 'get_animation_loop("skill")' in t
    assert NEW_MARK in t and 'count==96 and slots==838' in t
    (G/'tests/test_tb19_frost_skill_native.gd').write_text(t,encoding='utf-8')
    # Actual provider frame samples only, nearest-neighbor contact/GIF.
    contact=Image.new('RGB',(1600,3*435+40),(26,42,60));d=ImageDraw.Draw(contact)
    for stage,frames in images.items():
        y0=35+(stage-1)*435
        d.text((18,y0),f'R19 STAGE {stage} | PIXELLAB ICE SKILL 12F | ART GATE OWNER PENDING',fill=(233,218,182))
        for i,f in enumerate(frames):
            col=i%6;row=i//6;x=130+col*230;y=y0+45+row*170
            tile=f.copy();tile.thumbnail((140,145),Image.Resampling.NEAREST)
            bg=Image.new('RGBA',tile.size,(39,59,78,255));bg.alpha_composite(tile)
            contact.paste(bg.convert('RGB'),(x,y))
            d.text((x,y-13),f'F{i}',fill=(235,239,222))
        arr=[]
        for f in frames:
            bg=Image.new('RGBA',f.size,(30,46,64,255));bg.alpha_composite(f)
            arr.append(bg.resize((f.width*2,f.height*2),Image.Resampling.NEAREST).convert('RGB'))
        arr[0].save(R/f'R19_FROST_STAGE{stage}_SKILL_TRUE_PIXEL_LAB_12F.gif',save_all=True,
                   append_images=arr[1:],duration=110,loop=0,disposal=2)
    contact.save(R/'R19_FROST_3STAGE_SKILL_36F_CONTACT.png')
    with zipfile.ZipFile(r18) as z:
        for item in z.namelist():
            if item.lower().endswith('.png'):
                assert (staging/item).read_bytes()==z.read(item),('R18 PNG mutated',item)
    assert not (G/'.godot').exists()
    with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p in sorted(staging.rglob('*')):
            if p.is_file() and '.godot' not in p.parts:z.write(p,p.relative_to(staging).as_posix())
    with zipfile.ZipFile(out) as z:
        assert z.testzip() is None
        assert len(z.namelist())==464,(len(z.namelist()),'R18 448 + 16 R19')
        final=json.loads(z.read('godot/TB19_MONSTER_FAMILY_MANIFEST.json'))
        assert final['technical_qa']=='NATIVE_NOT_RUN' and (final['clip_count'],final['total_frames'])==(102,934)
        assert NEW_MARK in z.read('godot/tests/test_tb19_frost_skill_native.gd').decode('utf-8')
    result={'artifact':out.name,'source_r18_sha256':R18_SHA,'sha256':sha(out.read_bytes()),'bytes':out.stat().st_size,
            'entries':464,'crc':'PASS','new_true_provider_jobs':3,'real_reported_generations':total_cost,
            'new_frames':36,'total_clips':102,'total_slots':934,'native_godot':'NOT_RUN','art_gate':'OWNER_REVIEW_PENDING',
            'combat_integration':'NOT_RUN','source_png_untouched':True,'synthetic_offline_mock':mock}
    dump(proof,result)
    print('FS_TB_R19_M1_3STAGE_SKILL_SOURCE_QA_PASS',json.dumps({k:result[k] for k in ('sha256','bytes','entries','real_reported_generations','total_clips','total_slots')}),flush=True)
    return result

def main():
    a=argparse.ArgumentParser()
    a.add_argument('--r18-zip',type=Path,required=True)
    a.add_argument('--stage1',type=Path,required=True)
    a.add_argument('--stage2',type=Path,required=True)
    a.add_argument('--stage3',type=Path,required=True)
    a.add_argument('--out',type=Path,required=True)
    a.add_argument('--staging',type=Path,required=True)
    a.add_argument('--proof',type=Path,required=True)
    args=a.parse_args()
    build(args.r18_zip,[args.stage1,args.stage2,args.stage3],args.out,args.staging,args.proof)
if __name__=='__main__':main()