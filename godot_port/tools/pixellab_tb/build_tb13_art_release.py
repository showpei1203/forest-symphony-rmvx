#!/usr/bin/env python3
"""R13 T-B original PixelLab art packaging. Art-only; no combat code, no local permanent output."""
import argparse,hashlib,json,math,shutil,zipfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

P=argparse.ArgumentParser()
for x in ('base_zip','bat_dir','frog_dir','staging','drive_dir'):P.add_argument('--'+x,required=True)
a=P.parse_args()
root=Path(a.staging); root.mkdir(parents=True,exist_ok=True)
assert root.name=='fs_tb13_staging',root
source=Path(a.base_zip); assert source.is_file()
with zipfile.ZipFile(source) as z:
    assert z.testzip() is None
    assert 'godot/TB12_MONSTER_FAMILY_MANIFEST.json' in z.namelist()
    z.extractall(root)
g=root/'godot'; report=root/'reports';report.mkdir(exist_ok=True)
m12=json.loads((g/'TB12_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
manifest=json.loads(json.dumps(m12))
bat=json.loads((Path(a.bat_dir)/'R13_BAT_PROVIDER_JOBS.json').read_text())
frog=json.loads((Path(a.frog_dir)/'R13_FROG_PROVIDER_JOBS.json').read_text())
assert len(bat)==6 and len(frog)==6,(len(bat),len(frog))
rows=[]
for fi,(kind,ledger,parent,sub) in enumerate((('bat',bat,Path(a.bat_dir),'tb02'),('frog',frog,Path(a.frog_dir),'pmd'))):
    family=manifest['families'][fi]
    assert family['kind']==kind
    for stage in family['stages']:
        st=int(stage['index'])
        for action in ('stun','taunt'):
            key=f'{st}_{action}';rec=ledger[key]
            assert rec['status']=='completed' and rec.get('job_id') and rec.get('generation_id'),rec
            assert float(rec['usage']['generations'])==3.0
            assert rec['source_sha256']==stage['source_sha256'],(key,'source sha mismatch')
            assert rec.get('technical_qa',rec.get('qa'))=='PASS',key
            src=parent/rec['atlas_name'];assert src.is_file(),src
            assert hashlib.sha256(src.read_bytes()).hexdigest()==rec['sheet_sha256']
            dst=g/'assets'/'monsters'/sub/src.name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
            assert hashlib.sha256(dst.read_bytes()).hexdigest()==rec['sheet_sha256']
            cell=int(rec['cell'][0]) if kind=='bat' else 128
            frames=int(rec.get('expected_frames',rec.get('frames',8)))
            assert frames==8
            im=Image.open(dst).convert('RGBA')
            assert im.size==(cell*4,cell*2),(src.name,im.size)
            borders=[];unique=[];occupied=[]
            for k in range(frames):
                f=im.crop(((k%4)*cell,(k//4)*cell,(k%4+1)*cell,(k//4+1)*cell))
                alpha=f.getchannel('A');bbox=alpha.getbbox()
                assert bbox is not None,(key,k)
                edge=sum(alpha.getpixel((x,y))>0 for x in range(cell) for y in (0,cell-1))
                edge+=sum(alpha.getpixel((x,y))>0 for y in range(1,cell-1) for x in (0,cell-1))
                borders.append(edge)
                unique.append(hashlib.sha256(f.tobytes()).hexdigest())
                occupied.append(sum(v>0 for v in alpha.getdata()))
            assert max(borders)==0 and len(set(unique))>=3,(key,borders)
            meta=dict(path=f'assets/monsters/{sub}/{src.name}',frames=8,columns=4,cell=[cell,cell],fps=8,loop=False,
                      sha256=rec['sheet_sha256'],source_sha256=stage['source_sha256'],
                      provider_job_id=rec['job_id'],generation_id=rec['generation_id'],usage=rec['usage'],
                      border_counts=borders,unique_frames=len(set(unique)),opaque_area=occupied,
                      technical_qa='PASS',art_status='OWNER_ART_REVIEW_PENDING')
            stage['motions'][action]=meta
            rows.append(dict(family=family['family_id'],stage=st,action=action,frames=8,
                             sheet_sha256=rec['sheet_sha256'],source_sha256=stage['source_sha256'],
                             job_id=rec['job_id'],generation_id=rec['generation_id'],
                             usage=rec['usage'],frame_unique=len(set(unique)),borders=borders))
assert len(rows)==12
assert sum(len(stage['motions']) for f in manifest['families'] for stage in f['stages'])==54
assert sum(int(m['frames']) for f in manifest['families'] for s in f['stages'] for m in s['motions'].values())==436
manifest.update(schema='FS_TB_R13_TWO_FAMILIES_NINE_ACTIONS',clip_count=54,total_frames=436,
                new_pixel_lab_jobs=12,new_provider_generations=36,
                unapproved_new_art=12,technical_qa='PASS',human_art_gate='OWNER_REVIEW_PENDING',
                control_note='R13 STUN and TAUNT only, original R12 42 atlases byte-identical; independent ART gallery, no battle code.')
(g/'TB13_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
(report/'R13_NEW_CLIP_TECH_QA.json').write_text(json.dumps({'count':12,'new_frames':96,'results':rows},ensure_ascii=False,indent=2),encoding='utf-8')
(report/'R13_PROVIDER_JOB_LEDGER.json').write_text(json.dumps({'bat':bat,'frog':frog},ensure_ascii=False,indent=2),encoding='utf-8')

old=(g/'tb12_gallery.gd').read_text(encoding='utf-8')
new=old.replace('TB12_MONSTER_FAMILY_MANIFEST.json','TB13_MONSTER_FAMILY_MANIFEST.json')
new=new.replace('"locomotion"]','"locomotion", "stun", "taunt"]')
new=new.replace('T-B R12 MONSTER','T-B R13 MONSTER')
new=new.replace('6 FORMS / 42 CLIPS / 340 FRAMES','6 FORMS / 54 CLIPS / 436 FRAMES')
new=new.replace('7 Fly/Hop   Space Replay','7 Fly/Hop   8 Stun   9 Taunt   Space Replay')
new=new.replace('show_action("guard")','show_action("stun")')
new=new.replace('KEY_7:"locomotion"','KEY_7:"locomotion",KEY_8:"stun",KEY_9:"taunt"')
assert 'KEY_9:"taunt"' in new and '54 CLIPS' in new
(g/'tb13_gallery.gd').write_text(new,encoding='utf-8')
tscn=(g/'tb12_gallery.tscn').read_text(encoding='utf-8').replace('tb12_gallery.gd','tb13_gallery.gd')
(g/'tb13_gallery.tscn').write_text(tscn,encoding='utf-8')
proj=g/'project.godot';p=proj.read_text(encoding='utf-8').replace('tb12_gallery.tscn','tb13_gallery.tscn');proj.write_text(p,encoding='utf-8')

test='''extends SceneTree
func _initialize()->void:
    call_deferred("check")
func check()->void:
    root.size=Vector2i(1280,900)
    var d=JSON.parse_string(FileAccess.get_file_as_string("res://TB13_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(d["stage_count"]==6 and d["clip_count"]==54 and d["total_frames"]==436)
    var scene=load("res://tb13_gallery.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    var n=0
    var slots=0
    for action in ["idle","attack","hurt","ko","guard","skill","locomotion","stun","taunt"]:
        scene.show_action(action)
        for family in range(2):
            for stage in range(3):
                var key=("fly" if family==0 else "hop") if action=="locomotion" else action
                var m: Dictionary=d["families"][family]["stages"][stage]["motions"][key]
                var spr=scene.sprites[family*3+stage]
                assert(spr.sprite_frames.get_frame_count("play")==int(m["frames"]))
                assert(spr.sprite_frames.get_frame_texture("play",0)!=null)
                n+=1
                slots+=int(m["frames"])
    assert(n==54 and slots==436)
    print("FS_TB_R13_GODOT472_NATIVE_ART_ONLY_PASS clips=54 frames=436 stages=6 actions=9")
    quit(0)
'''
tests=g/'tests';tests.mkdir(exist_ok=True)
(tests/'test_tb13_gallery_native.gd').write_text(test,encoding='utf-8')
capture='''extends SceneTree
func _initialize()->void:
    call_deferred("capture")
func capture()->void:
    root.size=Vector2i(1280,900)
    var scene=load("res://tb13_gallery.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    for action in ["stun","taunt"]:
        scene.show_action(action)
        for spr in scene.sprites:
            spr.stop()
            spr.set_frame_and_progress(4,0.0)
        await RenderingServer.frame_post_draw
        var img=root.get_texture().get_image()
        var path="res://out/TB13_GODOT472_NATIVE_%s.png" % action.to_upper()
        assert(img.save_png(path)==OK)
        print("FS_TB_R13_GODOT472_NATIVE_CAPTURE_PASS ",action," ",img.get_size())
    quit(0)
'''
(tests/'capture_tb13_gallery_native.gd').write_text(capture,encoding='utf-8')
(g/'out').mkdir(exist_ok=True)

fontfile=Path('C:/Windows/Fonts/arial.ttf')
font=ImageFont.truetype(str(fontfile),22) if fontfile.exists() else ImageFont.load_default()
for fi,kind in enumerate(('bat','frog')):
    panel=Image.new('RGB',(1350,750),(20,37,48));draw=ImageDraw.Draw(panel)
    draw.text((22,20),f'FS T-B R13 | {kind.upper()} | THREE FORMS x STUN / TAUNT',font=font,fill=(226,236,211))
    for st in range(1,4):
        draw.text((80+(st-1)*410,65),f'STAGE {st}',font=font,fill=(242,214,158))
        for j,act in enumerate(('stun','taunt')):
            mm=manifest['families'][fi]['stages'][st-1]['motions'][act]
            c=mm['cell'][0];im=Image.open(g/mm['path']).convert('RGBA')
            tile=im.crop(((4%4)*c,(4//4)*c,((4%4)+1)*c,((4//4)+1)*c))
            tile.thumbnail((310,275),Image.Resampling.NEAREST)
            dst=Image.new('RGBA',tile.size,(35,56,67,255));dst.alpha_composite(tile)
            x=85+(st-1)*410; y=110+j*310
            panel.paste(dst.convert('RGB'),(x,y))
            draw.text((x,y+270),f'{act.upper()} 8F  |  {c}px source-locked',font=font,fill=(177,233,196))
    panel.save(report/f'R13_{kind.upper()}_3STAGE_STUN_TAUNT_CONTACT.png')

print('R13_RELEASE_STAGE_READY clips=54 frames=436 new_jobs=12 new_frames=96 quota=36',flush=True)
print('STAGING',root,flush=True)
