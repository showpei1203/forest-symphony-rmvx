#!/usr/bin/env python3
"""FS T-B R17 recovery: promote 3 already paid source-locked PixelLab Guard clips
from owner-private hold ZIP into a runnable art-only M1, ZERO new API jobs.
No battle systems, no original sprite edits, no fake native PASS.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import hashlib,zipfile,json,io,shutil,copy,math
BASE=Path('/mnt/data')
HOLD=BASE/'FS_TB_R17_GUARD_PAID_ART_HOLD_45111349220_20261123.zip'
ORIGINAL=BASE/'FS_TB_R16_FROST_KO_REVIVE_NATIVE_VERIFIED_PRIVATE_20261123.zip'
ROOT=BASE/'fs_tb17_m1_recovery_staging'
OUT=BASE/'FS_TB_R17_GUARD_M1_RECOVERED_NATIVE_HOLD_20261123.zip'
PROOF=BASE/'FS_TB_R17_GUARD_M1_RECOVERY_PROOF.json'
sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha(HOLD.read_bytes())=='4845398136e7f11202af6b059a85f1dc7f68450d5d8eb229fdbe8177aa61baa0'
assert sha(ORIGINAL.read_bytes())=='a3292f8e9ce94648f8a9d61bb22271a4d3d3f92fc02f132fb18c5278e92d9efe'
assert not OUT.exists(), 'Never silently overwrite an M1 publication'
with zipfile.ZipFile(HOLD) as z:
    assert len(z.namelist())==419 and z.testzip() is None
    for member in z.namelist():
        p=Path(member)
        assert not p.is_absolute() and '..' not in p.parts
    if ROOT.exists():shutil.rmtree(ROOT)
    ROOT.mkdir(parents=True)
    z.extractall(ROOT)
G=ROOT/'godot';R=ROOT/'reports'
orig_manifest=json.loads((G/'TB16_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
assert orig_manifest['clip_count']==93 and orig_manifest['total_frames']==838
ledger=json.loads((R/'R17_PIXEL_LAB_THREE_STAGE_GUARD_LEDGER.json').read_text(encoding='utf-8'))
assert len(ledger)==3 and [x['stage'] for x in ledger]==[1,2,3]
assert all(x['technical_qa']=='PASS' for x in ledger)
assert [float(x['reported_usage']['generations']) for x in ledger]==[2.0,4.0,5.0]
M=copy.deepcopy(orig_manifest)
frost=next(f for f in M['families'] if f['kind']=='frost')
qa=[];images={}
for st,rec in zip(frost['stages'],ledger):
    index=st['index'];c=st['source_size'][0]
    assert c==[128,160,192][index-1]
    assert rec['source_sha256']==st['source_sha256']
    idle=st['motions']['idle']
    assert rec['source_idle_sha256']==idle['sha256']
    asset=f'assets/monsters/tb03/FROST_STAGE{index}_GUARD_R17_TRUE_PIXEL_LAB_8F_{c}px.png'
    raw=(G/asset).read_bytes();assert sha(raw)==rec['exported_sha256']
    atlas=Image.open(io.BytesIO(raw)).convert('RGBA')
    assert atlas.size==(4*c,2*c)
    idle_im=Image.open(G/idle['path']).convert('RGBA')
    source=idle_im.crop((0,0,c,c))
    raw_frames=[]
    import_dir=R/'ORIGINAL_PIXEL_LAB_RAW_FRAMES'/f'stage{index}'
    for file in sorted(import_dir.glob('RAW_F*.png')):
        raw_frames.append(Image.open(file).convert('RGBA'))
    assert len(raw_frames) in (8,9),len(raw_frames)
    assert len(raw_frames)==rec['raw_returned_frames']
    assert [sha(x.tobytes()) for x in raw_frames]==rec['raw_frame_pixel_sha256']
    frames=[];rects=[]
    for i in range(8):
        f=atlas.crop(((i%4)*c,(i//4)*c,((i%4)+1)*c,((i//4)+1)*c))
        bbox=f.getchannel('A').getbbox()
        assert bbox and min(bbox[0],bbox[1],c-bbox[2],c-bbox[3])>=2
        frames.append(f);rects.append(bbox)
    assert frames[0].tobytes()==source.tobytes()==frames[7].tobytes()
    assert len(set(sha(x.tobytes()) for x in frames))>=6
    assert 'guard' not in st['motions']
    st['motions']['guard']={
       'path':asset,'frames':8,'columns':4,'cell':[c,c],'fps':8,'loop':True,
       'sha256':sha(raw),'source_sha256':st['source_sha256'],
       'source_idle_sha256':idle['sha256'],
       'endpoint':'animate-with-text-v3',
       'provider_job_id':rec['job_id'],'generation_id':rec['generation_id'],
       'provider_usage':rec['reported_usage'],
       'raw_returned_frames':rec['raw_returned_frames'],
       'raw_provider_pixels_retained':True,
       'exact_first_and_last_original_source':True,
       'unique_frames':len(set(sha(x.tobytes()) for x in frames)),
       'technical_qa':'PASS','art_status':'OWNER_ART_REVIEW_PENDING'}
    qa.append({'stage':index,'source_sha256':st['source_sha256'],'provider_job_id':rec['job_id'],
      'provider_usage':rec['reported_usage'],'raw_returned_frames':len(raw_frames),
      'export_frames':8,'alpha_bounds':rects,'source_exact_endpoint':True,
      'source_png_sha256':sha(raw),'unique_frames':st['motions']['guard']['unique_frames']})
    images[index]=frames
M.update(schema='FS_TB_R17_GENUINE_PIXEL_LAB_GUARD_THREE_STAGE_RECOVERED',
   baseline_clip_count=90,clip_count=96,total_frames=862,
   actions_per_family={'bat':12,'frog':12,'frost':6},
   third_family_motions=18,new_pixel_lab_jobs=3,
   new_provider_generations=11.0,new_true_provider_frame_slots=24,
   technical_qa='NATIVE_NOT_RUN',human_art_gate='OWNER_ART_REVIEW_PENDING',
   visual_gate_note='Three real 8F Guard clips recovered from actual source-locked paid PixelLab hold; owner art approval pending.',
   source_r16_zip_sha256=sha(ORIGINAL.read_bytes()),
   source_r17_paid_hold_sha256=sha(HOLD.read_bytes()),
   integration_qa='NOT_RUN_ART_ONLY',new_generation_cost='11 provider generations paid in Issue #89; recovery cost 0',
   recovery_route='NO_PROVIDER_REGENERATION_AFTER_RUNTIME_LEDGER_KEY_ERROR')
(G/'TB17_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(M,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'R17_GUARD_SOURCE_RECOVERY_QA.json').write_text(json.dumps({
 'source_original_r16_sha256':sha(ORIGINAL.read_bytes()),
 'actual_paid_hold_sha256':sha(HOLD.read_bytes()),'original_pixel_lab_paid_jobs':3,
 'recovery_new_provider_jobs':0,'actual_paid_provider_generations':11.0,
 'recovery_generations':0,'three_stage_frame_checks':qa,
 'native_status':'NOT_RUN', 'art_review_status':'OWNER_REVIEW_PENDING',
 'blocking_original_error':"KeyError 'usage' after three complete real provider jobs",
 'fixed_field':'reported_usage','clip_count':96,'frame_slots':862},ensure_ascii=False,indent=2),encoding='utf-8')
# Build dynamic Godot 4.7.2 independent gallery and deterministic native test.
(G/'tb17_frost_guard_gallery.gd').write_text('''extends Node2D
var sprites:Array[AnimatedSprite2D]=[]
func _ready()->void:
    var d=JSON.parse_string(FileAccess.get_file_as_string("res://TB17_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(d["families"].size()==3)
    var bg=ColorRect.new()
    bg.color=Color("1d2b3d")
    bg.size=Vector2(1280,850)
    add_child(bg)
    var l=Label.new()
    l.text="R17: 3 ORIGINAL PIXELLAB GUARD ANIMATIONS - OWNER ART REVIEW PENDING"
    l.position=Vector2(25,20)
    l.add_theme_font_size_override("font_size",22)
    add_child(l)
    for k in range(3):
        var stage:Dictionary=d["families"][2]["stages"][k]
        var m:Dictionary=stage["motions"]["guard"]
        var texture=load("res://"+str(m["path"])) as Texture2D
        assert(texture!=null)
        var ani=SpriteFrames.new()
        ani.remove_animation("default")
        ani.add_animation("guard")
        ani.set_animation_speed("guard",float(m["fps"]))
        ani.set_animation_loop("guard",true)
        var c=int(m["cell"][0])
        for i in range(8):
            var frame=AtlasTexture.new()
            frame.atlas=texture
            frame.region=Rect2((i%4)*c,int(i/4)*c,c,c)
            frame.filter_clip=true
            ani.add_frame("guard",frame)
        var spr=AnimatedSprite2D.new()
        spr.sprite_frames=ani
        spr.position=Vector2(240+k*400,410)
        spr.scale=Vector2(2.1,2.1)
        spr.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(spr)
        spr.play("guard")
        sprites.append(spr)
''',encoding='utf-8')
(G/'tb17_frost_guard_gallery.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tb17_frost_guard_gallery.gd" id="1"]\n[node name="TB17FrostGuard" type="Node2D"]\nscript = ExtResource("1")\n',encoding='utf-8')
(G/'tests/test_tb17_frost_guard_native.gd').write_text('''extends SceneTree
func _initialize()->void:call_deferred("check")
func check()->void:
    root.size=Vector2i(1280,850)
    var doc=JSON.parse_string(FileAccess.get_file_as_string("res://TB17_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(doc["families"].size()==3 and int(doc["stage_count"])==9)
    assert(int(doc["clip_count"])==96 and int(doc["total_frames"])==862)
    assert(int(doc["baseline_clip_count"])==90 and int(doc["evolution_transition_clip_count"])==6)
    var count=0
    var slots=0
    for family in doc["families"]:
        for stage in family["stages"]:
            for action in stage["motions"].keys():
                var m:Dictionary=stage["motions"][action]
                var texture=load("res://"+str(m["path"])) as Texture2D
                assert(texture!=null)
                var c=int(m["cell"][0])
                var cols=int(m["columns"])
                assert(texture.get_width()==cols*c)
                assert(texture.get_height()==int(ceil(float(m["frames"])/float(cols)))*c)
                count+=1
                slots+=int(m["frames"])
    assert(count==90 and slots==766)
    var s=load("res://tb17_frost_guard_gallery.tscn").instantiate()
    root.add_child(s)
    await process_frame
    assert(s.sprites.size()==3)
    for spr in s.sprites:
        assert(spr.is_playing())
        assert(spr.sprite_frames.get_frame_count("guard")==8)
        assert(spr.sprite_frames.get_frame_texture("guard",7)!=null)
    print("FS_TB_R17_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=90 evolutions=6 clips=96 frames=862 frost_guard=3")
    quit(0)
''',encoding='utf-8')
# Private raster review contact and GIFs based exclusively on genuine provider sprites.
out=Image.new('RGB',(1440,650),(26,42,58));d=ImageDraw.Draw(out)
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',15)
d.text((22,14),'R17 FROST JACKET / THREE DISTINCT STAGES | REAL PIXELLAB GUARD F0-F7 | USER ART PENDING',font=font,fill=(225,240,232))
for s,frames in images.items():
    y=30+200*(s-1);d.text((12,y+35),f'STAGE {s}',font=font,fill=(232,198,145))
    for i,im in enumerate(frames):
        tile=im.copy();tile.thumbnail((132,160),Image.Resampling.NEAREST)
        bg=Image.new('RGBA',tile.size,(43,64,84,255));bg.alpha_composite(tile)
        x=115+i*155
        out.paste(bg.convert('RGB'),(x,y+26))
        d.text((x+6,y+3),f'F{i}',font=font,fill=(238,242,225))
    frames2=[]
    for im in frames:
        p=Image.new('RGBA',im.size,(40,59,77,255));p.alpha_composite(im)
        frames2.append(p.resize((im.width*2,im.height*2),Image.Resampling.NEAREST).convert('RGB'))
    frames2[0].save(R/f'R17_FROST_STAGE{s}_TRUE_PIXEL_LAB_GUARD_8F.gif',save_all=True,
                   append_images=frames2[1:],duration=150,loop=0,disposal=2)
out.save(R/'R17_FROST_GUARD_3STAGE_24F_PROVIDER_CONTACT.png')
# Verify EVERYTHING preserved from original R16 user-private ZIP, no Sprite edits.
with zipfile.ZipFile(ORIGINAL) as oz:
    for name in oz.namelist():
        if name.endswith('/') or not name.lower().endswith('.png'):continue
        assert sha((ROOT/name).read_bytes())==sha(oz.read(name)),('old PNG mutated',name)
# No stale proof inside source zip, no false Godot PASS.
assert 'NATIVE_NOT_RUN'==M['technical_qa']
with zipfile.ZipFile(OUT,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as out_zip:
    for p in sorted(ROOT.rglob('*')):
        if p.is_file() and '.godot' not in p.parts:
            out_zip.write(p,p.relative_to(ROOT).as_posix())
with zipfile.ZipFile(OUT) as z:
    assert z.testzip() is None
    assert json.loads(z.read('godot/TB17_MONSTER_FAMILY_MANIFEST.json'))['clip_count']==96
    total=len(z.namelist())
record={'m1_file':OUT.name,'m1_sha256':sha(OUT.read_bytes()),'bytes':OUT.stat().st_size,
 'entries':total,'crc':'PASS','source_original_r16_sha256':sha(ORIGINAL.read_bytes()),
 'source_paid_hold_sha256':sha(HOLD.read_bytes()),'real_provider_jobs':3,
 'real_provider_generations':11.0,'recovery_new_provider_jobs':0,
 'new_motion_clips':3,'new_frames':24,'total_clips':96,'total_frames':862,
 'native_godot_status':'NOT_RUN','user_visual_art':'PENDING',
 'combat_integration':'NOT_RUN'}
PROOF.write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding='utf-8')
print('FS_TB_R17_M1_SOURCE_RECOVERED_PASS',json.dumps(record,ensure_ascii=False))