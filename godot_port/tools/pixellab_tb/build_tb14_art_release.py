#!/usr/bin/env python3
"""FS T-B R14: 12 base actions × 6 genuine monster forms + 4 provenance-locked evolution transitions.
Private raster only to owner's Google Drive. Separate source-authentic provider from transparent procedural FX.
No battle/ATB/UI/gameplay integration.
"""
import argparse,json,hashlib,zipfile,math,random,shutil,io,os,sys,subprocess
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

ap=argparse.ArgumentParser()
for arg in ('r13_zip','provider_work','staging','private_drive','godot'):ap.add_argument('--'+arg.replace('_','-'),required=True)
a=ap.parse_args()
R13=Path(a.r13_zip);WORK=Path(a.provider_work);R=Path(a.staging);DRIVE=Path(a.private_drive);G=R/'godot';REPORT=R/'reports'
OLD_SHA='eebd4d0e1bb12252d8ae1bea8fef87227ce7b9719a71f0da1539b19ea79492d7'
def sha(b):return hashlib.sha256(b).hexdigest()
def readj(path):return json.loads(path.read_text(encoding='utf-8'))
assert R13.is_file() and sha(R13.read_bytes())==OLD_SHA
assert R.name=='fs_tb14_staging',R
assert DRIVE.is_dir()
LEDGER=readj(WORK/'R14_PROVIDER_JOB_LEDGER.json')
assert len(LEDGER)==18 and all(x['status']=='completed' and x['qa']=='PASS' for x in LEDGER.values())
assert sum(float(v.get('usage',{}).get('generations',0)) for v in LEDGER.values())==54.0
R.mkdir(parents=True,exist_ok=True);REPORT.mkdir(exist_ok=True)
with zipfile.ZipFile(R13) as z:
    assert z.testzip() is None
    # Extract archive files only, retaining R13 existing original assets exactly.
    for info in z.infolist():
        p=R/info.filename
        assert p.resolve().is_relative_to(R.resolve()),'Unsafe ZIP member'
        if info.is_dir():p.mkdir(parents=True,exist_ok=True)
        else:
            p.parent.mkdir(parents=True,exist_ok=True)
            if not p.exists() or sha(p.read_bytes())!=sha(z.read(info)):
                p.write_bytes(z.read(info))
M=readj(G/'TB13_MONSTER_FAMILY_MANIFEST.json')
assert M['clip_count']==54 and M['total_frames']==436 and len(M['families'])==2
for family in M['families']:
    for stage in family['stages']:
        src=G/stage['source_path'];assert src.is_file() and sha(src.read_bytes())==stage['source_sha256']
        for name,rec in stage['motions'].items():
            p=G/rec['path'];assert p.is_file() and sha(p.read_bytes())==rec['sha256'],('R13 old atlas modified',p)
ORIGINAL_META=json.loads(json.dumps(M))
new_rows=[]
for fi,kind in enumerate(('bat','frog')):
    family=M['families'][fi];assert family['kind']==kind
    for stage in family['stages']:
        st=int(stage['index'])
        for action,expected in (('charge',10),('release',9),('revive',11)):
            key=f'{kind}:{st}:{action}';rec=LEDGER[key];assert rec['frames']==expected
            src=WORK/kind/rec['atlas_name']
            assert src.is_file() and sha(src.read_bytes())==rec['sheet_sha256']
            folder='tb02' if kind=='bat' else 'pmd'
            path=f'assets/monsters/{folder}/{rec["atlas_name"]}'
            dst=G/path;dst.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(src,dst)
            assert sha(dst.read_bytes())==rec['sheet_sha256']
            cell=int(rec['cell'])
            atlas=Image.open(dst).convert('RGBA')
            assert atlas.size==(4*cell,math.ceil(expected/4)*cell)
            assert max(rec['border_counts'])==0 and rec['unique_frames']>=3
            stage['motions'][action]={
              'path':path,'frames':expected,'columns':4,'cell':[cell,cell],
              'fps':9 if action=='charge' else 11 if action=='release' else 8,'loop':False,
              'sha256':rec['sheet_sha256'],'source_sha256':stage['source_sha256'],
              'provider_job_id':rec['job_id'],'generation_id':rec['generation_id'],
              'usage':rec['usage'],'first_frame_lineage_sha256':rec['first_frame_lineage_sha256'],
              'first_frame_png_sha256':rec['first_frame_png_sha256'],
              'border_counts':rec['border_counts'],'unique_frames':rec['unique_frames'],
              'technical_qa':'PASS','art_status':'OWNER_ART_REVIEW_PENDING'
            }
            new_rows.append({'family':family['family_id'],'stage':st,'action':action,'frames':expected,
                             'source_sha256':stage['source_sha256'],'atlas_sha256':rec['sheet_sha256'],
                             'provider_job_id':rec['job_id'],'usage':rec['usage'],'qa':'PASS'})
assert len(new_rows)==18

# Four artistic evolution FX clips: exactly connect STAGE1->2 and STAGE2->3 without invented 'stage4'.
# Source pixels retain exact original approved stage identity on F0 and F15.
def centered(p,size):
    im=Image.open(p).convert('RGBA')
    assert im.width==im.height and im.width<size
    dst=Image.new('RGBA',(size,size))
    dst.alpha_composite(im,((size-im.width)//2,(size-im.height)//2))
    return dst
def hash01(x,y,seed):
    k=(x*73856093)^(y*19349663)^(seed*83492791)
    k^=(k<<13)&0xffffffff
    k^=(k>>17)
    k^=(k<<5)&0xffffffff
    return (k&0xffff)/65535.0
def transition_frames(a,b,cell,kind,seed):
    old=centered(a,cell);new=centered(b,cell)
    assert old.size==new.size==(cell,cell)
    co=(244,123,40,220) if kind=='frog' else (95,245,164,220)
    bright=(255,222,140,235) if kind=='frog' else (196,255,190,235)
    frames=[]
    for f in range(16):
        if f==0: frames.append(old.copy());continue
        if f==15:frames.append(new.copy());continue
        frame=Image.new('RGBA',(cell,cell))
        src1=old.load();src2=new.load();dst=frame.load()
        p_old=max(0.0,min(1.0,(9.2-f)/7.6))
        p_new=max(0.0,min(1.0,(f-5.0)/8.4))
        for y in range(cell):
            for x in range(cell):
                pa=src1[x,y];pb=src2[x,y]
                n=hash01(x,y,seed)
                if pa[3] and n<=p_old:dst[x,y]=pa
                if pb[3] and (1.0-n)<=p_new:dst[x,y]=pb
        d=ImageDraw.Draw(frame,'RGBA')
        # Tiny pixel sprites as an animation effect, NOT a new invented source monster.
        intensity=min(f,15-f)
        count=int(11*intensity)
        radius=int(cell*0.35)
        for j in range(count):
            rng=random.Random(seed*1759+f*977+j*31)
            x=cell//2+rng.randint(-radius,radius)
            y=cell//2+rng.randint(-radius,radius)
            if not 3<=x<cell-4 or not 3<=y<cell-4:continue
            c=bright if j%5==0 else co
            sz=1+(j%3==0)
            d.rectangle((x,y,x+int(sz),y+int(sz)),fill=c)
        frames.append(frame)
    assert frames[0].tobytes()==old.tobytes()
    assert frames[-1].tobytes()==new.tobytes()
    return frames
EVOS=[]
for fi,kind in enumerate(('bat','frog')):
    stages=M['families'][fi]['stages']
    for source_i in (0,1):
        src_stage=stages[source_i];dst_stage=stages[source_i+1]
        cell=224 if kind=='bat' else 128
        frames=transition_frames(G/src_stage['source_path'],G/dst_stage['source_path'],cell,kind,seed=202614500+fi*100+source_i)
        atlas=Image.new('RGBA',(4*cell,4*cell))
        bounds=[];uniques=[]
        for i,fr in enumerate(frames):
            al=fr.getchannel('A')
            edge=sum(al.getpixel((x,y))>0 for x in range(cell) for y in (0,cell-1))
            edge+=sum(al.getpixel((x,y))>0 for y in range(1,cell-1) for x in (0,cell-1))
            bounds.append(edge);uniques.append(sha(fr.tobytes()))
            atlas.alpha_composite(fr,((i%4)*cell,(i//4)*cell))
        assert len(set(uniques))>=12 and max(bounds)==0
        name=(f'BAT_EVOLVE_STAGE{source_i+1}_TO_{source_i+2}_16F_{cell}px.png' if kind=='bat' else
              f'PMD_EVOLVE_STAGE{source_i+1}_TO_{source_i+2}_16F_{cell}px.png')
        folder='tb02' if kind=='bat' else 'pmd';p=G/'assets'/'monsters'/folder/name
        atlas.save(p)
        EVOS.append({'family_id':M['families'][fi]['family_id'],'kind':kind,
                     'from_stage':source_i+1,'to_stage':source_i+2,'path':f'assets/monsters/{folder}/{name}',
                     'frames':16,'columns':4,'cell':[cell,cell],'fps':12,'loop':False,'sha256':sha(p.read_bytes()),
                     'from_source_sha256':src_stage['source_sha256'],'to_source_sha256':dst_stage['source_sha256'],
                     'first_and_last_exact_original_source_rgba':True,
                     'render_method':'PROCEDURAL_SOURCE_LOCKED_TRANSITION_FX_NOT_PIXEL_LAB',
                     'border_counts':bounds,'unique_frames':len(set(uniques)),'technical_qa':'PASS',
                     'art_status':'OWNER_ART_REVIEW_PENDING'})
assert len(EVOS)==4
for f in M['families']:
    assert all(len(s['motions'])==12 for s in f['stages'])
clips=sum(len(s['motions']) for f in M['families'] for s in f['stages'])
slots=sum(v['frames'] for f in M['families'] for s in f['stages'] for v in s['motions'].values())
assert clips==72 and slots==616,(clips,slots)
assert slots+sum(e['frames'] for e in EVOS)==680
M.update(schema='FS_TB_R14_TWO_SOURCE_LOCKED_FAMILIES_TWELVE_ACTIONS_PLUS_EVOLUTION',
         mode='ART_ONLY_NO_BATTLE_INTEGRATION',stage_count=6,actions_per_stage=12,baseline_clip_count=72,
         evolution_transition_clip_count=4,clip_count=76,total_frames=680,evolutions=EVOS,
         new_pixel_lab_jobs=18,new_provider_generations=54.0,
         new_true_provider_frame_slots=180,new_procedural_evolution_frame_slots=64,
         technical_qa='PASS',human_art_gate='OWNER_REVIEW_PENDING',
         source_note='Existing 54 R13 clips byte-identical. Each of 18 new motion clips is actual PixelLab skeleton output. Four 16F transitions deterministic pixel FX: original approved source form F0 and exact successor source form F15. No claims of AI-generated morphing.')
(G/'TB14_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(M,ensure_ascii=False,indent=2),encoding='utf-8')
(REPORT/'R14_PROVIDER_JOB_LEDGER.json').write_text(json.dumps(LEDGER,ensure_ascii=False,indent=2),encoding='utf-8')
(REPORT/'R14_NEW_MOTION_AND_EVOLUTION_QA.json').write_text(json.dumps({'source_release_sha256':OLD_SHA,'new_provider_motion_rows':new_rows,'evolution_qa':EVOS,
 'total_baseline_motions':72,'total_evolution_clips':4,'total_frame_slots':680},ensure_ascii=False,indent=2),encoding='utf-8')
def frames_of(meta):
    c=int(meta['cell'][0]);cols=int(meta['columns']);n=int(meta['frames'])
    sheet=Image.open(G/meta['path']).convert('RGBA')
    return [sheet.crop(((i%cols)*c,(i//cols)*c,(i%cols+1)*c,(i//cols+1)*c)) for i in range(n)]
GIF=REPORT/'R14_NEW_MOTION_AND_EVOLVE_GIFS';GIF.mkdir(exist_ok=True)
def savegif(meta,filebase):
    frs=frames_of(meta);out=[]
    for im in frs:
        x=Image.new('RGBA',im.size,(28,45,56,255));x.alpha_composite(im)
        out.append(x.convert('RGB').resize((im.width*2,im.height*2),Image.Resampling.NEAREST))
    out[0].save(GIF/(filebase+'.gif'),save_all=True,append_images=out[1:],duration=round(1000/int(meta['fps'])),loop=0,disposal=2,optimize=False)
for f in M['families']:
    for stage in f['stages']:
        for act in ('charge','release','revive'):
            savegif(stage['motions'][act],f"{f['kind'].upper()}_STAGE{stage['index']}_{act.upper()}")
for e in EVOS:savegif(e,f"{e['kind'].upper()}_EVOLVE_{e['from_stage']}_TO_{e['to_stage']}")
assert len(list(GIF.glob('*.gif')))==22
fontfile=Path('C:/Windows/Fonts/arial.ttf')
font=ImageFont.truetype(str(fontfile),20) if fontfile.exists() else ImageFont.load_default()
for f in M['families']:
    pic=Image.new('RGB',(1420,1230),(18,34,45));draw=ImageDraw.Draw(pic)
    draw.text((22,24),f"FOREST SYMPHONY R14 | {f['family_id']} | CHARGE / RELEASE / REVIVE",font=font,fill=(220,236,213))
    for i,s in enumerate(f['stages']):
        x=80+i*443
        draw.text((x,75),f"STAGE {s['index']} : {s['name']}",font=font,fill=(241,205,140))
        for row,act in enumerate(('charge','release','revive')):
            meta=s['motions'][act];frames=frames_of(meta)
            moment={'charge':7,'release':4,'revive':7}[act];frame=frames[moment]
            target=min(300,frame.width*2)
            frame=frame.resize((target,target),Image.Resampling.NEAREST)
            bg=Image.new('RGBA',frame.size,(29,53,62,255));bg.alpha_composite(frame)
            y=135+row*340
            pic.paste(bg.convert('RGB'),(x,y))
            draw.text((x,y+304),f"{act.upper()} {meta['frames']}F ({meta['cell'][0]}px)",font=font,fill=(180,230,198))
    pic.save(REPORT/f"R14_{f['kind'].upper()}_3STAGE_3NEW_ACTION_CONTACT.png")

# New gallery retains original 54 source PNGs, simply exposes 3 NEW actions.
old=(G/'tb13_gallery.gd').read_text(encoding='utf-8')
new=old.replace('TB13_MONSTER_FAMILY_MANIFEST.json','TB14_MONSTER_FAMILY_MANIFEST.json')
new=new.replace('"locomotion", "stun", "taunt"]','"locomotion", "stun", "taunt", "charge", "release", "revive"]')
new=new.replace('T-B R13 MONSTER','T-B R14 MONSTER')
new=new.replace('6 FORMS / 54 CLIPS / 436 FRAMES','6 FORMS / 72 MOTIONS / 616 FRAMES + 4 EVOLVE CLIPS')
new=new.replace('7 Fly/Hop   8 Stun   9 Taunt   Space Replay','7 Fly/Hop   8 Stun   9 Taunt    Q Charge   W Release   E Revive   Space Replay')
new=new.replace('KEY_9:"taunt"','KEY_9:"taunt",KEY_Q:"charge",KEY_W:"release",KEY_E:"revive"')
assert 'KEY_E:"revive"' in new and 'TB14_MONSTER_FAMILY_MANIFEST.json' in new
(G/'tb14_gallery.gd').write_text(new,encoding='utf-8')
tscn=(G/'tb13_gallery.tscn').read_text(encoding='utf-8').replace('tb13_gallery.gd','tb14_gallery.gd')
(G/'tb14_gallery.tscn').write_text(tscn,encoding='utf-8')
proj=(G/'project.godot').read_text(encoding='utf-8').replace('tb13_gallery.tscn','tb14_gallery.tscn').replace('T-B R12 Monster ART Factory','T-B R14 Monster ART Factory')
(G/'project.godot').write_text(proj,encoding='utf-8')
EVOGD='''extends Node2D
# Evolution gallery: source-authentic F0/F15; deterministic intermediate FX only.
const DATA := "res://TB14_MONSTER_FAMILY_MANIFEST.json"
var sprites: Array[AnimatedSprite2D] = []
var all_data: Dictionary = {}
func caption(words:String,pos:Vector2,size:int=19) -> void:
    var l=Label.new()
    l.text=words
    l.position=pos
    l.add_theme_font_size_override("font_size",size)
    l.add_theme_color_override("font_color",Color("e5efd9"))
    add_child(l)
func _ready()->void:
    all_data=JSON.parse_string(FileAccess.get_file_as_string(DATA)) as Dictionary
    assert(all_data["evolutions"].size()==4)
    var bg=ColorRect.new()
    bg.color=Color("172939")
    bg.size=Vector2(1280,900)
    add_child(bg)
    caption("FOREST SYMPHONY | R14 ORIGINAL STAGE EVOLUTION GALLERY",Vector2(22,22),25)
    caption("F0 original source form  |  F15 original successor source  |  intermediate PIXEL FX  |  NOT AI generated morph",Vector2(22,61),16)
    caption("Two evolution boundaries per family  |  Space = replay all",Vector2(22,92),17)
    for i in range(4):
        var t:Dictionary=all_data["evolutions"][i]
        var sprite=AnimatedSprite2D.new()
        sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.position=Vector2(344+(i%2)*575,315+int(i/2)*390)
        add_child(sprite)
        sprites.append(sprite)
        var data=load("res://"+str(t["path"])) as Texture2D
        assert(data!=null)
        var frames=SpriteFrames.new()
        frames.remove_animation("default")
        frames.add_animation("evolve")
        frames.set_animation_speed("evolve",float(t["fps"]))
        frames.set_animation_loop("evolve",false)
        var c=int(t["cell"][0])
        for f in range(int(t["frames"])):
            var region=AtlasTexture.new()
            region.atlas=data
            region.region=Rect2((f%4)*c,int(f/4)*c,c,c)
            region.filter_clip=true
            frames.add_frame("evolve",region)
        sprite.sprite_frames=frames
        sprite.scale=Vector2(1.35,1.35)
        sprite.play("evolve")
        var yy=140+int(i/2)*390
        caption(("%s  STAGE %d  >  %d" % [t["kind"].to_upper(),t["from_stage"],t["to_stage"]]),Vector2(187+(i%2)*575,yy),18)
func _input(event:InputEvent)->void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_SPACE:
        for s in sprites:
            s.stop()
            s.play("evolve")
'''
(G/'tb14_evolution_gallery.gd').write_text(EVOGD,encoding='utf-8')
(G/'tb14_evolution_gallery.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tb14_evolution_gallery.gd" id="1"]\n[node name="TB14EvolutionGallery" type="Node2D"]\nscript = ExtResource("1")\n',encoding='utf-8')
tests=G/'tests';tests.mkdir(exist_ok=True)
TEST='''extends SceneTree
func _initialize()->void:
    call_deferred("check")
func check()->void:
    root.size=Vector2i(1280,900)
    var data=JSON.parse_string(FileAccess.get_file_as_string("res://TB14_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(int(data["stage_count"])==6)
    assert(int(data["baseline_clip_count"])==72)
    assert(int(data["evolution_transition_clip_count"])==4)
    assert(int(data["clip_count"])==76 and int(data["total_frames"])==680)
    var gallery=load("res://tb14_gallery.tscn").instantiate()
    root.add_child(gallery)
    await process_frame
    assert(gallery.sprites.size()==6)
    var n=0
    var slots=0
    for action in ["idle","attack","hurt","ko","guard","skill","locomotion","stun","taunt","charge","release","revive"]:
        gallery.show_action(action)
        for family in range(2):
            for stage in range(3):
                var key=("fly" if family==0 else "hop") if action=="locomotion" else action
                var m:Dictionary=data["families"][family]["stages"][stage]["motions"][key]
                var s=gallery.sprites[family*3+stage]
                assert(s.sprite_frames.get_frame_count("play")==int(m["frames"]))
                assert(s.sprite_frames.get_frame_texture("play",0)!=null)
                n+=1
                slots+=int(m["frames"])
    assert(n==72 and slots==616)
    gallery.queue_free()
    await process_frame
    var evo=load("res://tb14_evolution_gallery.tscn").instantiate()
    root.add_child(evo)
    await process_frame
    assert(evo.sprites.size()==4)
    for s in evo.sprites:
        assert(s.sprite_frames.get_frame_count("evolve")==16)
        assert(s.sprite_frames.get_frame_texture("evolve",15)!=null)
    print("FS_TB_R14_GODOT472_NATIVE_ART_ONLY_PASS baseline=72 evolved=4 clips=76 frames=680 stages=6 actions=12")
    quit(0)
'''
(tests/'test_tb14_art_native.gd').write_text(TEST,encoding='utf-8')
(G/'out').mkdir(exist_ok=True)
godot=Path(a.godot);assert godot.is_file()
ver=subprocess.run([str(godot),'--version'],capture_output=True,encoding='utf-8',errors='replace',text=True,timeout=30)
version=(ver.stdout+ver.stderr).strip()
assert '4.7.2' in version,version
imp=subprocess.run([str(godot),'--headless','--editor','--path',str(G),'--quit'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=200)
(REPORT/'R14_GODOT_IMPORT.log').write_text(imp.stdout+'\nSTDERR\n'+imp.stderr,encoding='utf-8')
print('R14_NATIVE_EDITOR_IMPORT',imp.returncode,flush=True)
assert imp.returncode==0
run=subprocess.run([str(godot),'--headless','--path',str(G),'--script','res://tests/test_tb14_art_native.gd'],
                   capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=130)
log=run.stdout+'\nSTDERR\n'+run.stderr
(REPORT/'R14_GODOT_NATIVE_QA.log').write_text(log,encoding='utf-8')
print('R14_GODOT_NATIVE_TEST',run.returncode,log[-1200:],flush=True)
assert run.returncode==0 and 'FS_TB_R14_GODOT472_NATIVE_ART_ONLY_PASS baseline=72 evolved=4 clips=76 frames=680 stages=6 actions=12' in log
(REPORT/'R14_RELEASE_HANDOFF.txt').write_text('Forest Symphony T-B R14 ART ONLY. Six source-locked creature forms, 12 PixelLab actions per form (72 genuine motion sprite atlases), plus four deterministic source-to-source 16F evolution FX atlases. Total 76 clips / 680 frame slots. New provider: 18 completed jobs, 180 actual provider frame slots, 54 provider-reported generations. Exact legacy R13 54 atlases preserved. Two original Stage1 V6/R8 mouth attacks remain owner accepted. All R14 new 22 clips art REVIEW PENDING. Windows Godot 4.7.2 official headless import and independent art galleries PASS. No battle engine modifications. Raster remains PRIVATE Drive only.\n',encoding='utf-8')
# Remove Godot editor runtime caches but preserve old immutable artwork, all new authentic atlases and portable scenes.
for p in R.rglob('.godot'):
    if p.is_dir():shutil.rmtree(p)
PRIVATE_NAME='FS_TB_R14_TWO_FAMILIES_12_ACTIONS_PLUS_EVOLUTIONS_PRIVATE_20261122.zip'
pending=R.parent/'fs_tb14_upload_pending.zip'
files=[p for p in R.rglob('*') if p.is_file() and '.godot' not in p.parts]
with zipfile.ZipFile(pending,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for p in sorted(files):z.write(p,p.relative_to(R).as_posix())
with zipfile.ZipFile(pending) as z:
    assert z.testzip() is None
    entries=len(z.namelist())
assert entries>205,(entries,'private bundle incomplete')
dst=DRIVE/PRIVATE_NAME
shutil.copyfile(pending,dst)
assert sha(pending.read_bytes())==sha(dst.read_bytes())
proof={'release_name':PRIVATE_NAME,'sha256':sha(dst.read_bytes()),'bytes':dst.stat().st_size,
       'zip_file_count':entries,'zip_crc':'PASS','godot_version':version,
       'native_qa':'FS_TB_R14_GODOT472_NATIVE_ART_ONLY_PASS baseline=72 evolved=4 clips=76 frames=680 stages=6 actions=12',
       'families':2,'forms':6,'baseline_actions_per_form':12,'baseline_clips':72,'evolution_clips':4,
       'total_clips':76,'total_frames':680,'new_pixel_lab_jobs':18,'new_pixel_lab_frames':180,
       'procedural_evolution_clips':4,'procedural_evolution_frames':64,
       'new_provider_generations':54.0,'human_art_gate':'OWNER_REVIEW_PENDING',
       'note':'24 R14? No, precisely 18 new actual provider motion jobs plus 4 procedural source-locked evolution FX clips; no invented PixelLab morphing.'}
(DRIVE/'R14_RELEASE_PROOF.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf-8')
for name in ('R14_MONSTER_FAMILY_MANIFEST.json',):
    shutil.copyfile(G/'TB14_MONSTER_FAMILY_MANIFEST.json',DRIVE/'TB14_MONSTER_FAMILY_MANIFEST.json')
for name in ('R14_PROVIDER_JOB_LEDGER.json','R14_NEW_MOTION_AND_EVOLUTION_QA.json','R14_GODOT_NATIVE_QA.log'):
    shutil.copyfile(REPORT/name,DRIVE/name)
for p in REPORT.glob('R14_*CONTACT.png'):
    shutil.copyfile(p,DRIVE/p.name)
# Separate lightweight animations to view without downloading whole ZIP.
for p in GIF.glob('*EVOLVE*.gif'):shutil.copyfile(p,DRIVE/p.name)
print('FS_TB_R14_PRIVATE_DRIVE_RELEASE_PASS',json.dumps(proof,ensure_ascii=False),flush=True)
