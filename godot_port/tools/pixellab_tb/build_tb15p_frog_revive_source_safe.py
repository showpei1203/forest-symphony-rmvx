#!/usr/bin/env python3
"""Forest Symphony T-B R15P: actual art QA-driven frog revive repair.
Generates 3 true-source retimed KO->IDLE 11F sequences with ZERO new AI cost,
preserving all original PixelLab art and manifest from original R15 as separate release.
Native Godot 4.7.2 art-only QA; never battle or T-A/T-C.
"""
import argparse,io,json,hashlib,zipfile,math,os,shutil,subprocess
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ap=argparse.ArgumentParser()
for k in ('r15_zip','staging','drive','godot'):ap.add_argument('--'+k.replace('_','-'),required=True)
A=ap.parse_args()
Z=Path(A.r15_zip);W=Path(A.staging);DRIVE=Path(A.drive);ENGINE=Path(A.godot)
assert W.name=='fs_tb15p_staging' and DRIVE.is_dir() and ENGINE.is_file()
HASH15='5cd880690a13181ae9a5cb4b1a82ab453263d1969ca9f991c550c9bdcd968f6c'
sha=lambda data:hashlib.sha256(data).hexdigest()
assert sha(Z.read_bytes())==HASH15,'R15 source archive changed'
W.mkdir(exist_ok=True,parents=True)
with zipfile.ZipFile(Z) as z:
    assert z.testzip() is None
    for info in z.infolist():
        p=W/info.filename
        assert p.resolve().is_relative_to(W.resolve()),'Unsafe ZIP path'
        if info.is_dir():p.mkdir(exist_ok=True,parents=True)
        else:
            p.parent.mkdir(exist_ok=True,parents=True)
            if not p.exists() or sha(p.read_bytes())!=sha(z.read(info)):
                p.write_bytes(z.read(info))
G=W/'godot';R=W/'reports';R.mkdir(exist_ok=True)
old=json.loads((G/'TB15_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
assert old['clip_count']==90 and old['total_frames']==802
import copy
M=copy.deepcopy(old)
frog=next(f for f in M['families'] if f['kind']=='frog')
def frames(meta):
    source=G/meta['path']
    raw=source.read_bytes()
    assert sha(raw)==meta['sha256']
    texture=Image.open(io.BytesIO(raw)).convert('RGBA')
    cols=int(meta['columns']);n=int(meta['frames']);c=int(meta['cell'][0])
    assert texture.width==cols*c
    return [texture.crop(((i%cols)*c,(i//cols)*c,(i%cols+1)*c,(i//cols+1)*c)) for i in range(n)]
def cell_on(source,c):
    assert source.width<=c and source.height<=c
    out=Image.new('RGBA',(c,c))
    out.alpha_composite(source,((c-source.width)//2,(c-source.height)//2))
    return out
def bboxclear(image):
    rect=image.getchannel('A').getbbox()
    return rect and min(rect[0],rect[1],image.width-rect[2],image.height-rect[3])>=1
proof=[]
save_images=[]
for st in frog['stages']:
    ko=st['motions']['ko'];idle=st['motions']['idle'];ko_frames=frames(ko);idle_frames=frames(idle)
    cell=ko['cell'][0]
    assert ko['frames']==8 and len(idle_frames)>=3
    # Exact source-boundary KO last image F7 and idle F0; no art hallucination or detached magic.
    source=[cell_on(x,cell) for x in ko_frames[::-1]]+[cell_on(x,cell) for x in idle_frames[:3]]
    assert len(source)==11
    assert source[0].tobytes()==ko_frames[-1].tobytes()
    assert source[-3].tobytes()==cell_on(idle_frames[0],cell).tobytes()
    assert all(bboxclear(im) for im in source),'Clipped input source; do not falsely release'
    assert len(set(sha(x.tobytes()) for x in source))>=8
    atlas=Image.new('RGBA',(cell*4,cell*3))
    for n,f in enumerate(source):atlas.alpha_composite(f,((n%4)*cell,(n//4)*cell))
    path=f'assets/monsters/pmd/PMD000{st["index"]}_REVIVE_SAFE_RETIME_R15P_11F_{cell}px.png'
    target=G/path;target.parent.mkdir(exist_ok=True,parents=True);atlas.save(target)
    old_revision=copy.deepcopy(st['motions']['revive'])
    st['r15_text_v3_revive_art_hold']=old_revision
    st['motions']['revive']={
      'path':path,'frames':11,'columns':4,'cell':[cell,cell],'fps':8,'loop':False,
      'sha256':sha(target.read_bytes()),'source_sha256':st['source_sha256'],
      'source_method':'REVERSAL_OF_EXISTING_AUTHENTIC_PIXEL_LAB_KO_8F_PLUS_3_EXISTING_IDLE_FRAMES',
      'new_provider_jobs':0,'new_generation_cost':0,
      'first_frame_matches_KO_final_RGBA':True,'final_three_exact_original_idle_frames':True,
      'ko_original_sha256':ko['sha256'],'idle_original_sha256':idle['sha256'],
      'original_r15_rejected_sha256':old_revision['sha256'],
      'original_frame_provenance':[{'source_action':'ko','source_index':j,'sha256':sha(x.tobytes())} for j,x in zip(range(7,-1,-1),source[:8])]
        +[{'source_action':'idle','source_index':j,'sha256':sha(x.tobytes())} for j,x in zip(range(3),source[8:])],
      'technical_qa':'PASS','art_status':'CANDIDATE_ART_REVIEW_PENDING'}
    proof.append({'stage':st['index'],'new_atlas_sha256':sha(target.read_bytes()),
                  'old_R15_revive_sha256':old_revision['sha256'],
                  'ko_original_sha256':ko['sha256'],'idle_original_sha256':idle['sha256'],
                  'genuine_existing_source_frames_retained':11,'new_provider_frames':0,'qa':'PASS'})
    save_images.append(source)
M['schema']='FS_TB_R15P_THREE_FAMILY_FROG_SAFE_SOURCE_RETIME_20261122'
M['total_frames']=805
M['technical_qa']='PENDING_NATIVE'
M['frog_revive_art_repair']='KO_REVERSE_8F_PLUS_IDLE_3F_NO_FLAME_NO_NEW_PIXEL_LAB'
M['source_note']='R15 original 90 clips/802 slots immutable archive retained. This R15P uses EXACT original PixelLab KO reversed 8 frames plus 3 unchanged Idle frames per Frog stage; 3x11 frames, zero new AI jobs, no flame bursts, no fabricated models. Third family KO still ART HOLD awaiting new true collapsed KO art.'
(G/'TB15P_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(M,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'R15P_SOURCE_RETIMED_FROG_QA.json').write_text(json.dumps({'baseline_R15_SHA256':HASH15,'zero_new_AI_generation':True,'original_R15_frog_art_issue':'Hallucinated oversized flame projectiles within Revive','source_true_pixel_retime':proof,'total_clips':90,'total_frames':805,'wolf_ko_gate':'OWNER_ART_HOLD_UNCONVINCING_COLLAPSE'},ensure_ascii=False,indent=2),encoding='utf-8')
# Compare all eleven actual frames to previous AI fire frames in one 3-stage contact.
pic=Image.new('RGB',(1450,890),(24,39,52));d=ImageDraw.Draw(pic)
fontpath=Path('C:/Windows/Fonts/arial.ttf');ft=ImageFont.truetype(str(fontpath),19) if fontpath.exists() else ImageFont.load_default()
d.text((25,20),'FS R15P | AUTHENTIC SOURCE PIXEL FROG REVIVE | NO HALLUCINATED FIRE',font=ft,fill=(230,241,216))
for si,st in enumerate(frog['stages']):
    x=30+si*475
    d.text((x,70),f'FROG STAGE {si+1}  KO F7 -> IDLE F0',font=ft,fill=(230,199,139))
    prev=frames(st['r15_text_v3_revive_art_hold'])
    for row,series in enumerate((prev,save_images[si])):
        y=125+row*335
        d.text((x,y),'R15 AI CANDIDATE / ART HOLD' if row==0 else 'R15P ORIGINAL-SOURCE RETIMED',font=ft,fill=(193,228,211))
        inds=[0,2,4,6,8,9] if row==0 else [0,2,4,6,8,10]
        for j,ix in enumerate(inds):
            f=series[ix]
            f=f.resize((68,68),Image.Resampling.NEAREST)
            bg=Image.new('RGBA',f.size,(33,51,66,255));bg.alpha_composite(f)
            pic.paste(bg.convert('RGB'),(x+j*71,y+65))
pic.save(R/'R15P_FROG_3STAGE_SOURCE_SAFE_VS_R15_FLAME_CONTACT.png')
GIF=R/'R15P_TRUE_PIXEL_REVIEW_GIF';GIF.mkdir(exist_ok=True)
for si,series in enumerate(save_images):
    frames2=[]
    for im in series:
        b=Image.new('RGBA',im.size,(31,48,60,255));b.alpha_composite(im)
        frames2.append(b.convert('RGB').resize((im.width*3,im.height*3),Image.Resampling.NEAREST))
    frames2[0].save(GIF/f'FROG_STAGE{si+1}_REVIVE_SOURCE_SAFE_11F.gif',save_all=True,
                    append_images=frames2[1:],loop=0,duration=115,disposal=2)
# New gallery only to review three safe frog revives, original R15 wolf gallery remains intact.
gallery='''extends Node2D
const MANIFEST:="res://TB15P_MONSTER_FAMILY_MANIFEST.json"
var sprites:Array[AnimatedSprite2D]=[]
func label_at(t:String,p:Vector2)->void:
    var l=Label.new()
    l.text=t
    l.position=p
    l.add_theme_font_size_override("font_size",22)
    l.add_theme_color_override("font_color",Color("d5ecdf"))
    add_child(l)
func _ready()->void:
    var bg=ColorRect.new()
    bg.color=Color("192a3b")
    bg.size=Vector2(1280,900)
    add_child(bg)
    var m=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST)) as Dictionary
    label_at("FS R15P | ORIGINAL PIXEL KO REVERSE + IDLE, FROG REVIVE ART",Vector2(30,22))
    label_at("Source-locked PixelLab frames; NO NEW AI, NO flame VFX. SPACE replay.",Vector2(30,66))
    for i in range(3):
        var stage:Dictionary=m["families"][1]["stages"][i]
        var r:Dictionary=stage["motions"]["revive"]
        var im=load("res://"+str(r["path"])) as Texture2D
        assert(im!=null)
        var f=SpriteFrames.new()
        f.remove_animation("default")
        f.add_animation("revive")
        f.set_animation_loop("revive",false)
        f.set_animation_speed("revive",float(r["fps"]))
        var c=int(r["cell"][0])
        for n in range(int(r["frames"])):
            var at=AtlasTexture.new()
            at.atlas=im
            at.region=Rect2((n%4)*c,int(n/4)*c,c,c)
            at.filter_clip=true
            f.add_frame("revive",at)
        var a=AnimatedSprite2D.new()
        a.sprite_frames=f
        a.position=Vector2(240+i*400,430)
        a.scale=Vector2(2.35,2.35)
        a.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(a)
        a.play("revive")
        sprites.append(a)
        label_at("FROG STAGE "+str(i+1)+" 11 FRAMES",Vector2(120+i*400,680))
func _input(event:InputEvent)->void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_SPACE:
        for a in sprites:
            a.stop()
            a.play("revive")
'''
(G/'tb15p_frog_revive_gallery.gd').write_text(gallery,encoding='utf-8')
(G/'tb15p_frog_revive_gallery.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tb15p_frog_revive_gallery.gd" id="1"]\n[node name="TB15PFrogRevive" type="Node2D"]\nscript = ExtResource("1")\n',encoding='utf-8')
test='''extends SceneTree
func _initialize()->void:call_deferred("check")
func check()->void:
    root.size=Vector2i(1280,900)
    var m=JSON.parse_string(FileAccess.get_file_as_string("res://TB15P_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(int(m["stage_count"])==9 and int(m["clip_count"])==90 and int(m["total_frames"])==805)
    assert(int(m["baseline_clip_count"])==84 and int(m["evolution_transition_clip_count"])==6)
    var total=0
    var motioncount=0
    for fam in m["families"]:
        for stage in fam["stages"]:
            for key in stage["motions"].keys():
                var art:Dictionary=stage["motions"][key]
                var tex=load("res://"+str(art["path"])) as Texture2D
                assert(tex!=null)
                assert(tex.get_width()==int(art["columns"])*int(art["cell"][0]))
                total+=int(art["frames"])
                motioncount+=1
    assert(total==709 and motioncount==84)
    var scene=load("res://tb15p_frog_revive_gallery.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    assert(scene.sprites.size()==3)
    for sprite in scene.sprites:
        assert(sprite.sprite_frames.get_frame_count("revive")==11)
        assert(sprite.sprite_frames.get_frame_texture("revive",10)!=null)
    print("FS_TB_R15P_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=805 frog_source_retime=3")
    quit(0)
'''
(G/'tests/test_tb15p_art_native.gd').write_text(test,encoding='utf-8')
# preserve historical R15 exact manifest; new TB15P is a non-destructive overlay.
native_ver=subprocess.run([str(ENGINE),'--version'],capture_output=True,encoding='utf-8',errors='replace',text=True,timeout=25)
assert '4.7.2' in native_ver.stdout
edit=subprocess.run([str(ENGINE),'--headless','--editor','--path',str(G),'--quit'],capture_output=True,encoding='utf-8',errors='replace',text=True,timeout=180)
(R/'R15P_GODOT_EDITOR_IMPORT.log').write_text(edit.stdout+'\n'+edit.stderr,encoding='utf-8')
assert edit.returncode==0
testcall=subprocess.run([str(ENGINE),'--headless','--path',str(G),'--script','res://tests/test_tb15p_art_native.gd'],
                        capture_output=True,encoding='utf-8',errors='replace',text=True,timeout=125)
native=testcall.stdout+'\nSTDERR\n'+testcall.stderr
(R/'R15P_GODOT_NATIVE_TEST.log').write_text(native,encoding='utf-8')
marker='FS_TB_R15P_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=84 evolutions=6 clips=90 frames=805 frog_source_retime=3'
print('R15P_NATIVE',testcall.returncode,native[-1700:],flush=True)
assert testcall.returncode==0 and marker in native
M['technical_qa']='PASS'
(G/'TB15P_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(M,ensure_ascii=False,indent=2),encoding='utf-8')
if (G/'.godot').is_dir():shutil.rmtree(G/'.godot')
zipname='FS_TB_R15P_FROG_REVIVE_SOURCE_SAFE_ART_REVIEW_PRIVATE_20261122.zip'
output=W.parent/'fs_tb15p_upload_tmp.zip'
files=[x for x in W.rglob('*') if x.is_file() and '.godot' not in x.parts]
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in sorted(files):z.write(file,file.relative_to(W).as_posix())
with zipfile.ZipFile(output) as z:
    assert z.testzip() is None
    entries=len(z.namelist())
assert entries>=360
target=DRIVE/zipname
shutil.copyfile(output,target)
assert sha(output.read_bytes())==sha(target.read_bytes())
p={'zip':zipname,'sha256':sha(target.read_bytes()),'bytes':target.stat().st_size,
   'crc':'PASS','count':entries,'r15_immutable_sha256':HASH15,'native_version':native_ver.stdout.strip(),
   'native_marker':marker,'families':3,'stages':9,'clips':90,'frames':805,
   'frog_original_pixel_retuned_clips':3,'new_provider_jobs':0,'new_provider_generations':0,
   'owner_art_gate':'OWNER_REVIEW_PENDING','wolf_ko_gate':'ART_HOLD_NOT_VISIBLY_COLLAPSED'}
(DRIVE/'R15P_RELEASE_PROOF.json').write_text(json.dumps(p,ensure_ascii=False,indent=2),encoding='utf-8')
for path in (R/'R15P_FROG_3STAGE_SOURCE_SAFE_VS_R15_FLAME_CONTACT.png',
             R/'R15P_SOURCE_RETIMED_FROG_QA.json',
             R/'R15P_GODOT_NATIVE_TEST.log',
             G/'TB15P_MONSTER_FAMILY_MANIFEST.json'):
    shutil.copyfile(path,DRIVE/path.name)
for path in GIF.glob('*.gif'):
    shutil.copyfile(path,DRIVE/path.name)
print('FS_TB_R15P_SOURCE_RETIME_PRIVATE_RELEASE_PASS',json.dumps(p,ensure_ascii=False),flush=True)
