#!/usr/bin/env python3
"""FS T-B R15 private R14-preserving release: 6 anchor-locked REVIVE revisions + 3-stage new frost jackal family.
Art only, no main/T-A/T-C/Battle integration. NEVER equate Godot technical QA with owner art approval.
"""
import argparse,hashlib,json,zipfile,math,random,io,shutil,subprocess,os
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
P=argparse.ArgumentParser()
for k in ('r14_zip','provider_work','staging','private_drive','godot'):P.add_argument('--'+k.replace('_','-'),required=True)
A=P.parse_args()
W=Path(A.provider_work);O=Path(A.staging);DRIVE=Path(A.private_drive)
assert O.name=='fs_tb15_staging' and DRIVE.is_dir()
HASH14='07ade104008f376b077aaea2fdc7395986f7cf12ec023791e81169b0f3355575'
sha=lambda b:hashlib.sha256(b).hexdigest()
zpath=Path(A.r14_zip);assert sha(zpath.read_bytes())==HASH14
J=json.loads((W/'R15_PIXELLAB_PROVIDER_LEDGER.json').read_text(encoding='utf-8'))
assert all(J[f'frost:{s}:source']['status']=='completed' for s in (1,2,3))
assert all(J[f'{kind}:{stage}:{act}']['status']=='completed' and J[f'{kind}:{stage}:{act}']['qa']=='PASS'
  for kind in ('bat','frog') for stage in (1,2,3) for act in ('revive',))
assert all(J[f'frost:{stage}:{act}']['status']=='completed' and J[f'frost:{stage}:{act}']['qa']=='PASS'
  for stage in (1,2,3) for act in ('idle','attack','hurt','ko'))
O.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(zpath) as z:
    assert z.testzip() is None
    for m in z.infolist():
        f=(O/m.filename)
        assert f.resolve().is_relative_to(O.resolve()),'Unsafe ZIP member'
        if m.is_dir():f.mkdir(parents=True,exist_ok=True)
        else:
            f.parent.mkdir(exist_ok=True,parents=True)
            if not f.exists() or sha(f.read_bytes())!=sha(z.read(m)):
                f.write_bytes(z.read(m))
G=O/'godot';REPORT=O/'reports';REPORT.mkdir(exist_ok=True)
OLD=json.loads((G/'TB14_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
import copy
M=copy.deepcopy(OLD)
assert M['clip_count']==76 and M['total_frames']==680
unchanged={}
for f in OLD['families']:
    for stage in f['stages']:
        for action,meta in stage['motions'].items():
            key=(f['kind'],stage['index'],action)
            v=(G/meta['path']).read_bytes()
            assert sha(v)==meta['sha256']
            unchanged[key]=meta['sha256']
REVLOG=[]
for fam in M['families']:
    kind=fam['kind']
    for stage in fam['stages']:
        st=stage['index']
        key=f'{kind}:{st}:revive';r=J[key]
        src=W/kind/r['atlas']
        assert src.is_file() and sha(src.read_bytes())==r['sheet_sha256']
        previous=stage['motions']['revive']
        dest=('assets/monsters/tb02/' if kind=='bat' else 'assets/monsters/pmd/')+r['atlas']
        target=G/dest;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,target)
        assert sha(target.read_bytes())==r['sheet_sha256']
        stage['r14_revive_history']=copy.deepcopy(previous)
        stage['motions']['revive']={
            'path':dest,'frames':10,'columns':4,'cell':[r['cell'],r['cell']],'fps':9,
            'loop':False,'sha256':r['sheet_sha256'],'source_sha256':stage['source_sha256'],
            'endpoint':'animate-with-text-v3','provider_job_id':r['job_id'],
            'generation_id':r['generation_id'],'usage':r['usage'],
            'first_frame_exact_original_KO_last':True,'last_frame_exact_original_IDLE_first':True,
            'first_original_frame_sha256':r['first_source_sha256'],
            'last_original_frame_sha256':r['last_source_sha256'],
            'frame_count_raw_ai':10,'atlas_boundary_rgba_source_adjustments':2,
            'border_counts':r['border_counts'],'unique_frames':r['unique_frames'],
            'tech_qa':'PASS','art_status':'OWNER_ART_REVIEW_PENDING'}
        REVLOG.append({'kind':kind,'stage':st,'old_revive_sha256':previous['sha256'],
                       'new_revive_sha256':r['sheet_sha256'],'provider_job_id':r['job_id'],
                       'first_last_original_pixel_lock':True})
        for action,meta in stage['motions'].items():
            if action=='revive':continue
            assert meta['sha256']==unchanged[(kind,st,action)]
assert len(REVLOG)==6
WOLFFAMILY={'family_id':'TB03_GLACIER_JACKAL','kind':'frost','stages':[]}
WOLFNAMES=['Glacier Jackal Pup','Crystal Wolf Guardian','Ancient Glacier Fenrir']
NEW_MOTION=[]
for st in (1,2,3):
    rec=J[f'frost:{st}:source'];cell=rec['padded_cell']
    src=W/'frost'/f'FROST_JACKAL_STAGE{st}_SOURCE_{cell}.png'
    assert src.is_file() and sha(src.read_bytes())==rec['source_sha256']
    dst=f'assets/monsters/tb03/{src.name}'
    p=G/dst;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,p)
    stage={'index':st,'name':WOLFNAMES[st-1],'source_path':dst,'source_size':[cell,cell],
           'source_sha256':rec['source_sha256'],'source_provider':rec['endpoint'],
           'source_provider_job_id':rec.get('job_id'),'source_provider_usage':rec.get('provider_usage'),
           'source_derivation_sha256':rec.get('input_source_sha256'),
           'art_status':'OWNER_ART_REVIEW_PENDING','motions':{}}
    for act in ('idle','attack','hurt','ko'):
        q=J[f'frost:{st}:{act}'];n=q['frames']
        assert n==8 and q['cell']==cell
        asset=f'assets/monsters/tb03/{q["atlas"]}'
        raster=W/'frost'/q['atlas'];assert sha(raster.read_bytes())==q['sheet_sha256']
        shutil.copyfile(raster,G/asset)
        stage['motions'][act]={
            'path':asset,'frames':n,'columns':4,'cell':[cell,cell],
            'fps':8 if act=='idle' else 11 if act=='attack' else 9 if act=='hurt' else 7,
            'loop':act=='idle','sha256':q['sheet_sha256'],'source_sha256':rec['source_sha256'],
            'endpoint':q['endpoint'],'provider_job_id':q['job_id'],'generation_id':q['generation_id'],
            'provider_usage':q.get('usage'),'first_frame_exact_original_source':True,
            'last_frame_exact_original_source':q['last_frame_exact_source'],
            'unique_frames':q['unique_frames'],'border_counts':q['border_counts'],
            'technical_qa':'PASS','art_status':'OWNER_ART_REVIEW_PENDING'
        }
        NEW_MOTION.append({'stage':st,'action':act,'frames':n,'source_sha256':rec['source_sha256'],
                           'atlas_sha256':q['sheet_sha256'],'job_id':q['job_id'],'tech_qa':'PASS'})
    WOLFFAMILY['stages'].append(stage)
M['families'].append(WOLFFAMILY)
assert len(M['families'])==3 and len(NEW_MOTION)==12
# Exact original-source F0/F15 deterministic ice crystallization transition; not generative.
def bigcenter(image_path,cell=224):
    src=Image.open(image_path).convert('RGBA')
    assert src.width<=cell and src.height<=cell
    out=Image.new('RGBA',(cell,cell))
    out.alpha_composite(src,((cell-src.width)//2,(cell-src.height)//2))
    return out
EVO=[]
def noise(x,y,seed):
    k=x*13877+y*94811+seed*12123
    k=(k^(k>>13))*1327832189
    return (k&65535)/65535
for si in (0,1):
    fr=WOLFFAMILY['stages'][si];to=WOLFFAMILY['stages'][si+1]
    a=bigcenter(G/fr['source_path']);b=bigcenter(G/to['source_path'])
    seq=[]
    for i in range(16):
        if i==0:seq.append(a.copy());continue
        if i==15:seq.append(b.copy());continue
        out=Image.new('RGBA',(224,224))
        al=a.load();bl=b.load();pix=out.load()
        pa=max(0,min(1,(9-i)/7.5));pb=max(0,min(1,(i-5)/8.5))
        for y in range(224):
            for x in range(224):
                g=noise(x,y,1401+si*10)
                if al[x,y][3] and g<pa:pix[x,y]=al[x,y]
                if bl[x,y][3] and 1-g<pb:pix[x,y]=bl[x,y]
        d=ImageDraw.Draw(out,'RGBA')
        for j in range(max(0,min(i,15-i)*12)):
            rg=random.Random(90128+si*1000+i*617+j*199)
            x=112+rg.randint(-78,78);y=112+rg.randint(-78,78)
            if x<3 or x>219 or y<3 or y>219:continue
            size=1 if j%4 else 2
            d.rectangle((x,y,x+size,y+size),fill=((162,255,252,200) if j%5 else (222,254,255,240)))
        seq.append(out)
    assert seq[0].tobytes()==a.tobytes() and seq[-1].tobytes()==b.tobytes()
    atl=Image.new('RGBA',(896,896));borders=[];hashes=[]
    for i,f in enumerate(seq):
        bbox=f.getchannel('A').getbbox()
        assert bbox is not None and bbox[0]>0 and bbox[1]>0 and bbox[2]<224 and bbox[3]<224
        borders.append(0);hashes.append(sha(f.tobytes()))
        atl.alpha_composite(f,((i%4)*224,(i//4)*224))
    assert len(set(hashes))>=12
    name=f'FROST_EVOLVE_STAGE{si+1}_TO_{si+2}_16F_224px.png'
    path=f'assets/monsters/tb03/{name}';atl.save(G/path)
    EVO.append({'family_id':'TB03_GLACIER_JACKAL','kind':'frost','from_stage':si+1,'to_stage':si+2,
            'path':path,'frames':16,'columns':4,'cell':[224,224],'fps':12,'loop':False,
            'sha256':sha((G/path).read_bytes()),
            'from_source_sha256':fr['source_sha256'],'to_source_sha256':to['source_sha256'],
            'first_and_last_exact_original_source_rgba':True,'render_method':'PROCEDURAL_CRYSTAL_FX_NOT_PIXELLAB',
            'border_counts':borders,'unique_frames':len(set(hashes)),'technical_qa':'PASS',
            'art_status':'OWNER_ART_REVIEW_PENDING'})
assert len(EVO)==2
M['evolutions']+=EVO
baseclips=sum(len(stage['motions']) for family in M['families'] for stage in family['stages'])
baseslots=sum(int(q['frames']) for family in M['families'] for st in family['stages'] for q in st['motions'].values())
eclips=len(M['evolutions']);eslots=sum(x['frames'] for x in M['evolutions'])
assert (baseclips,baseslots,eclips,eslots)==(84,706,6,96),(baseclips,baseslots,eclips,eslots)
assert baseclips+eclips==90 and baseslots+eslots==802
M['actions_per_stage']=None  # Third family currently 4 actions, earlier two families 12 each
M.update(schema='FS_TB_R15_THREE_FAMILIES_9_EVOLUTION_FORMS_84_MOTIONS_PLUS_6_TRANSITIONS',
         stage_count=9,baseline_clip_count=84,evolution_transition_clip_count=6,clip_count=90,total_frames=802,
         actions_per_family={'bat':12,'frog':12,'frost':4},
         new_pixel_lab_jobs=18,new_pixel_lab_exported_frame_slots=156,
         third_family_stages=3,third_family_motions=12,new_revive_corrections=6,
         new_procedural_evolution_clips=2,new_procedural_evolution_frames=32,
         technical_qa='PENDING_NATIVE','human_art_gate':'OWNER_ART_REVIEW_PENDING',
         source_note='Exact historical R14 original atlases retained. Six revised 10F KO->Idle anchored PixelLab revives replace old 11F manifest pointers without deleting original atlas. Third Ice Jackal lineage PixelLab Pixen stage1 then exact source-chained Edit Image stages2/3. Six-stage R15 animation output has F0/F(last) exact user source anchor images. Third family currently 4 genuine action types per form, not yet full 12. Two further transitions are deterministic pixel effects, not AI morphs.')
(G/'TB15_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(M,ensure_ascii=False,indent=2),encoding='utf-8')
(REPORT/'R15_PROVIDER_LEDGER.json').write_text(json.dumps(J,ensure_ascii=False,indent=2),encoding='utf-8')
# Retain real rejected PixelLab response art and billed usage, NEVER throw it away with TEMP.
rejected=W/'R15_REJECTED_PROVIDER_QA.json'
if rejected.is_file():
    shutil.copyfile(rejected,REPORT/'R15_REJECTED_PROVIDER_QA.json')
    rejected_dir=W/'REJECTED_ART'
    if rejected_dir.is_dir():
        qdir=REPORT/'R15_REJECTED_ART'
        qdir.mkdir(exist_ok=True,parents=True)
        for pp in rejected_dir.glob('*.png'):
            shutil.copyfile(pp,qdir/pp.name)

(REPORT/'R15_SOURCE_AND_REVIVE_QA.json').write_text(json.dumps({'R14_zip_sha256':HASH14,
    'revive_corrections':REVLOG,'third_stage_motions':NEW_MOTION,'third_stage_source_lock':[
      {'stage':s['index'],'source_sha256':s['source_sha256'],'parent_source_sha256':s.get('source_derivation_sha256')} for s in WOLFFAMILY['stages']],
    'new_evolution_qa':EVO,'total_clips':90,'total_frames':802},ensure_ascii=False,indent=2),encoding='utf-8')

# GIF previews and contact sheets assembled directly from real-provider frames.
def allframes(m):
    pic=Image.open(G/m['path']).convert('RGBA')
    c=int(m['cell'][0]);cols=int(m['columns'])
    return [pic.crop(((i%cols)*c,(i//cols)*c,(i%cols+1)*c,(i//cols+1)*c)) for i in range(int(m['frames']))]
GIF=REPORT/'R15_REVIEW_GIF';GIF.mkdir(exist_ok=True)
def gif(m,name):
    fs=allframes(m);res=[]
    for frame in fs:
        b=Image.new('RGBA',frame.size,(32,46,60,255));b.alpha_composite(frame)
        res.append(b.convert('RGB').resize((frame.width*2,frame.height*2),Image.Resampling.NEAREST))
    res[0].save(GIF/name,save_all=True,append_images=res[1:],duration=round(1000/m['fps']),loop=0,disposal=2)
for fam in M['families']:
    for st in fam['stages']:
        newactions=['revive'] if fam['kind']!='frost' else ('idle','attack','hurt','ko')
        for act in newactions:gif(st['motions'][act],f"{fam['kind'].upper()}_{st['index']}_{act.upper()}_R15.gif")
for e in EVO:gif(e,f"FROST_EVOLVE_{e['from_stage']}_TO_{e['to_stage']}.gif")
assert len(list(GIF.glob('*.gif')))==20
fontpath=Path('C:/Windows/Fonts/arial.ttf')
font=ImageFont.truetype(str(fontpath),22) if fontpath.exists() else ImageFont.load_default()
# For side-by-side old and new REVIVE per stage, make a readable 3x2 contact.
for fi in (0,1):
    fam=M['families'][fi];pic=Image.new('RGB',(1450,760),(23,36,51));d=ImageDraw.Draw(pic)
    d.text((24,20),f"R15 NEW KO>REVIVE>IDLE  |  {fam['family_id']}  |  ORIGINAL R14 KEPT",font=font,fill=(229,239,226))
    for si,stage in enumerate(fam['stages']):
        d.text((60+si*470,65),f"STAGE {si+1}",font=font,fill=(238,202,144))
        for row,old in enumerate((True,False)):
            m=stage['r14_revive_history'] if old else stage['motions']['revive']
            frames=allframes(m)
            y=110+row*320
            sample=(0,2,4,6,8,10) if old else (0,2,4,6,8,9)
            d.text((30,y), 'R14' if old else 'R15',font=font,fill=(170,233,217))
            for n,i in enumerate(sample):
                src=frames[i];sz=min(73,src.width)
                src.thumbnail((sz,sz),Image.Resampling.NEAREST)
                bg=Image.new('RGBA',src.size,(31,54,64,255));bg.alpha_composite(src)
                pic.paste(bg.convert('RGB'),(75+si*470+n*74,y+42))
    pic.save(REPORT/f"R15_{fam['kind'].upper()}_REVIVE_R14_VS_R15_CONTACT.png")
pic=Image.new('RGB',(1450,760),(23,37,50));d=ImageDraw.Draw(pic)
d.text((24,20),'FS R15 | NEW THIRD FAMILY | GLACIER JACKAL EVOLUTION | 4 GENUINE PIXELLAB ACTIONS PER STAGE',font=font,fill=(225,236,228))
for si,stage in enumerate(WOLFFAMILY['stages']):
    x=40+si*470
    d.text((x,65),WOLFNAMES[si],font=font,fill=(225,217,174))
    for ri,act in enumerate(('idle','attack','hurt','ko')):
        fr=allframes(stage['motions'][act])[3]
        fr=fr.resize((160,160),Image.Resampling.NEAREST)
        bg=Image.new('RGBA',(160,160),(30,52,69,255));bg.alpha_composite(fr)
        ox=x+(ri%2)*205;oy=110+(ri//2)*300
        pic.paste(bg.convert('RGB'),(ox,oy))
        d.text((ox,oy+180),act.upper()+' 8F',font=font,fill=(190,234,224))
pic.save(REPORT/'R15_FROST_JACKAL_3STAGE_FOUR_ACTIONS_CONTACT.png')

# Separate R15 art gallery; keep legacy R14 galleries fully functional.
gallery='''extends Node2D
const FILE:="res://TB15_MONSTER_FAMILY_MANIFEST.json"
var sprites:Array[AnimatedSprite2D]=[]
var stage_labels:Array[Label]=[]
var data:Dictionary={}
const ACTIONS:=["idle","attack","hurt","ko"]
var active:int=0
func caption(t:String,pos:Vector2,sz:int=18)->Label:
    var l=Label.new()
    l.text=t
    l.position=pos
    l.add_theme_font_size_override("font_size",sz)
    l.add_theme_color_override("font_color",Color("ddeef1"))
    add_child(l)
    return l
func _ready()->void:
    data=JSON.parse_string(FileAccess.get_file_as_string(FILE)) as Dictionary
    assert(data["families"].size()==3)
    var back=ColorRect.new()
    back.color=Color("192b3a")
    back.size=Vector2(1280,900)
    add_child(back)
    caption("FS R15 | NEW 3-STAGE GLACIER JACKAL ART FACTORY",Vector2(32,24),25)
    caption("1 IDLE   2 ATTACK   3 HURT   4 KO   SPACE REPLAY  |  GODOT ART ONLY",Vector2(32,66),19)
    caption("Separate source-locked third species. User art approval PENDING.",Vector2(32,105),15)
    for i in range(3):
        var s=AnimatedSprite2D.new()
        s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        s.position=Vector2(246+i*401,450)
        add_child(s)
        sprites.append(s)
        stage_labels.append(caption("",Vector2(80+i*400,725)))
    show_action(0)
func show_action(k:int)->void:
    assert(k>=0 and k<ACTIONS.size())
    active=k
    var stages: Array=data["families"][2]["stages"]
    for i in range(3):
        var stage:Dictionary=stages[i]
        var m:Dictionary=stage["motions"][ACTIONS[k]]
        var texture=load("res://"+str(m["path"])) as Texture2D
        assert(texture!=null)
        var frames=SpriteFrames.new()
        frames.remove_animation("default")
        frames.add_animation("play")
        frames.set_animation_speed("play",float(m["fps"]))
        frames.set_animation_loop("play",bool(m["loop"]))
        var c=int(m["cell"][0])
        for j in range(int(m["frames"])):
            var t=AtlasTexture.new()
            t.atlas=texture
            t.region=Rect2((j%4)*c,int(j/4)*c,c,c)
            t.filter_clip=true
            frames.add_frame("play",t)
        sprites[i].stop()
        sprites[i].sprite_frames=frames
        sprites[i].scale=Vector2(2.15,2.15)
        sprites[i].play("play")
        stage_labels[i].text="STAGE %d   %s   %s 8F" % [i+1,stage["name"],ACTIONS[k].to_upper()]
func _input(ev:InputEvent)->void:
    if ev is InputEventKey and ev.pressed and not ev.echo:
        if ev.keycode==KEY_SPACE:show_action(active)
        elif ev.keycode>=KEY_1 and ev.keycode<=KEY_4:show_action(int(ev.keycode-KEY_1))
'''
(G/'tb15_frost_gallery.gd').write_text(gallery,encoding='utf-8')
(G/'tb15_frost_gallery.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tb15_frost_gallery.gd" id="1"]\n[node name="TB15FrostGallery" type="Node2D"]\nscript = ExtResource("1")\n',encoding='utf-8')
oldproject=(G/'project.godot').read_text(encoding='utf-8')
newproject=oldproject.replace('T-B R14 Monster ART Factory','T-B R15 Monster ART Factory').replace('tb14_gallery.tscn','tb15_frost_gallery.tscn')
(G/'project.godot').write_text(newproject,encoding='utf-8')
# Godot scene/counter test uses ALL genuine PNG clips, including original R14 and new R15.
test='''extends SceneTree
func _initialize()->void:call_deferred("check")
func check()->void:
    root.size=Vector2i(1280,900)
    var m=JSON.parse_string(FileAccess.get_file_as_string("res://TB15_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(m["families"].size()==3 and int(m["stage_count"])==9)
    assert(int(m["baseline_clip_count"])==84 and int(m["evolution_transition_clip_count"])==6)
    assert(int(m["clip_count"])==90 and int(m["total_frames"])==802)
    var cnt=0
    var slots=0
    for family in m["families"]:
        for stage in family["stages"]:
            for k in stage["motions"].keys():
                var motion:Dictionary=stage["motions"][k]
                var path="res://"+str(motion["path"])
                var a=load(path) as Texture2D
                assert(a!=null,"missing "+path)
                var c=int(motion["cell"][0])
                var n=int(motion["frames"])
                assert(a.get_width()==int(motion["columns"])*c)
                assert(a.get_height()==int(ceil(float(n)/float(motion["columns"])))*c)
                cnt+=1
                slots+=n
    assert(cnt==84 and slots==706)
    for fx in m["evolutions"]:
        var t=load("res://"+str(fx["path"])) as Texture2D
        assert(t!=null)
        assert(t.get_width()==int(fx["cell"][0])*int(fx["columns"]))
        assert(int(fx["frames"])==16)
    var gallery=load("res://tb15_frost_gallery.tscn").instantiate()
    root.add_child(gallery)
    await process_frame
    assert(gallery.sprites.size()==3)
    for action in range(4):
        gallery.show_action(action)
        for spr in gallery.sprites:
            assert(spr.sprite_frames.get_frame_count("play")==8)
            assert(spr.sprite_frames.get_frame_texture("play",7)!=null)
    print("FS_TB_R15_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=802 third_species_actions=4 revised_revives=6")
    quit(0)
'''
(G/'tests/test_tb15_art_native.gd').write_text(test,encoding='utf-8')
godot=Path(A.godot);assert godot.is_file()
ver=subprocess.run([str(godot),'--version'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=30)
assert '4.7.2' in ver.stdout
editor=subprocess.run([str(godot),'--headless','--editor','--path',str(G),'--quit'],
                      capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=220)
(REPORT/'R15_GODOT_EDITOR_IMPORT.log').write_text(editor.stdout+'\nSTDERR\n'+editor.stderr,encoding='utf-8')
assert editor.returncode==0,editor.stderr[-1300:]
r=subprocess.run([str(godot),'--headless','--path',str(G),'--script','res://tests/test_tb15_art_native.gd'],
                  capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=165)
native=r.stdout+'\nSTDERR\n'+r.stderr
(REPORT/'R15_GODOT_NATIVE_TEST.log').write_text(native,encoding='utf-8')
marker='FS_TB_R15_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=802 third_species_actions=4 revised_revives=6'
print('R15_NATIVE',r.returncode,native[-2000:],flush=True)
assert r.returncode==0 and marker in native
M['technical_qa']='PASS'
(G/'TB15_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(M,ensure_ascii=False,indent=2),encoding='utf-8')
# All R14 original file hashes still exactly retained.
for key,h in unchanged.items():
    family=next(f for f in OLD['families'] if f['kind']==key[0])
    stage=family['stages'][key[1]-1]
    meta=stage['motions'][key[2]]
    assert sha((G/meta['path']).read_bytes())==h,'Unexpected R14 PNG mutation'
(REPORT/'R15_TECHNICAL_HANDOFF.txt').write_text(
    'ART ONLY. Historical R14 original 272 source-package members preserved as files. Six new KO-last to Idle-first endpoint-anchored 10-frame revives (genuine PixelLab v3 interior, two exact source endpoints). Third new original Glacier Jackal family PixelLab Pixen stage1 -> real image edits stage2 and 3 with chained source SHA, 12 genuine PixelLab v3 first actions (Idle/Attack/Hurt/KO), two new deterministic ice progression pixel FX transitions. Total 3 families, 9 forms, 84 base clips, 6 evo clips, 802 slots. 18 genuine PixelLab animation jobs; owner art review PENDING; third family 4/12 actions only, not fully complete. Native Godot 4.7.2 actual engine import PASS and native art gallery test PASS. All PNG and logs PRIVATE Drive. Battle system/ATB/UI untouched.\\n',
    encoding='utf-8')
if (G/'.godot').exists():shutil.rmtree(G/'.godot')
zipname='FS_TB_R15_REVIVE_REPAIRS_AND_THIRD_FROST_JACKAL_PRIVATE_20261122.zip'
archive=O.parent/'fs_tb15_pending_upload.zip'
files=[x for x in O.rglob('*') if x.is_file() and '.godot' not in x.parts]
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for f in sorted(files):z.write(f,f.relative_to(O).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    entries=len(z.namelist())
assert entries>=310,entries
target=DRIVE/zipname
shutil.copyfile(archive,target)
assert sha(archive.read_bytes())==sha(target.read_bytes())
proof={'release_name':zipname,'sha256':sha(target.read_bytes()),'bytes':target.stat().st_size,
       'zip_entries':entries,'zip_crc':'PASS','baseline_r14_sha256':HASH14,'native_godot_version':ver.stdout.strip(),
       'marker':marker,'new_pixel_lab_animation_jobs':18,
       'new_exported_animation_frames':156,
       'real_provider_raw_frames_returned':sum(int(J[f'{k}:{st}:{act}']['frame_count_original_ai'])
           for k,st,act in ([(k,st,'revive') for k in ('bat','frog') for st in (1,2,3)]+
                            [('frost',st,act) for st in (1,2,3) for act in ('idle','attack','hurt','ko')]),
       'new_original_species':'TB03_GLACIER_JACKAL','new_source_images':3,
       'new_frost_motions':12,'new_revive_ko_to_idle_revisions':6,
       'new_procedural_evolutions':2,'new_procedural_evolution_frames':32,
       'three_families':True,'nine_forms':True,'total_motions':84,
       'total_evolution_clips':6,'total_clips':90,'total_slots':802,
       'frost_actions_per_form':4,'frost_remaining_actions_per_form':8,
       'art_status':'OWNER_ART_REVIEW_PENDING'}
(DRIVE/'R15_RELEASE_PROOF.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf-8')
for file in ('R15_SOURCE_AND_REVIVE_QA.json','R15_PROVIDER_LEDGER.json','R15_GODOT_NATIVE_TEST.log',
             'R15_BAT_REVIVE_R14_VS_R15_CONTACT.png','R15_FROG_REVIVE_R14_VS_R15_CONTACT.png',
             'R15_FROST_JACKAL_3STAGE_FOUR_ACTIONS_CONTACT.png'):
    assert (REPORT/file).is_file()
    shutil.copyfile(REPORT/file,DRIVE/file)
shutil.copyfile(G/'TB15_MONSTER_FAMILY_MANIFEST.json',DRIVE/'TB15_MONSTER_FAMILY_MANIFEST.json')
for giffile in GIF.glob('FROST_EVOLVE_*.gif'):
    shutil.copyfile(giffile,DRIVE/giffile.name)
print('FS_TB_R15_PRIVATE_RELEASE_PASS',json.dumps(proof,ensure_ascii=False),flush=True)
