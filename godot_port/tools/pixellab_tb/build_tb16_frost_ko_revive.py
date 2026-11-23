#!/usr/bin/env python3
"""Forest Symphony T-B R16: exact original-source Frost KO + Revive.

Derives wolf KO semantic proof from *every* existing genuine PixelLab KO frame.
Derives 11-frame revive with KO F7..F0 and existing Idle F1/F2 (no new AI).
Original R15P ZIP and every source sprite remain immutable. No battle integration.

Authoring mode: --staging, --source-zip; --godot is required for a NATIVE PASS.
If --private-drive supplied, upload only AFTER official native Godot passes.
"""
from __future__ import annotations
import argparse, copy, hashlib, io, json, math, os, shutil, subprocess, sys, zipfile
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

EXPECTED_ZIP_SHA = 'a8088f4e76e3f63d7b9a58857213d138ecb2e43a5af92547f4b2222f77fd04f7'
ZIP_NAME = 'FS_TB_R16_FROST_KO_REVIVE_SOURCE_LOCKED_PRIVATE_20261123.zip'
NATIVE_MARK = 'FS_TB_R16_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=87 evolutions=6 clips=93 frames=838 frost_revive=3'

def sha(data:bytes)->str: return hashlib.sha256(data).hexdigest()
def dump(obj)->str: return json.dumps(obj, ensure_ascii=False, indent=2)
def get_frame(atlas:Image.Image, index:int, c:int, cols:int)->Image.Image:
    return atlas.crop(((index%cols)*c, (index//cols)*c, ((index%cols)+1)*c, ((index//cols)+1)*c))
def unchanged_sources(z:zipfile.ZipFile, root:Path):
    for entry in z.infolist():
        if entry.is_dir(): continue
        p=root/entry.filename
        assert p.resolve().is_relative_to(root.resolve()),'unsafe ZIP entry'
        assert p.is_file() and sha(p.read_bytes()) == sha(z.read(entry)),('historical source mutated',entry.filename)

def main():
    arg=argparse.ArgumentParser()
    arg.add_argument('--source-zip', required=True)
    arg.add_argument('--staging', required=True)
    arg.add_argument('--godot')
    arg.add_argument('--private-drive')
    arg.add_argument('--out-zip')
    a=arg.parse_args()
    source=Path(a.source_zip);root=Path(a.staging)
    assert source.is_file() and sha(source.read_bytes())==EXPECTED_ZIP_SHA
    assert root.name in ('fs_tb_r16_staging','fs_tb_r16_local_staging'),root
    root.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(source) as z:
        assert z.testzip() is None and len(z.namelist())==373
        for e in z.infolist():
            dst=(root/e.filename)
            assert dst.resolve().is_relative_to(root.resolve()),'ZIP traversal'
            if e.is_dir():dst.mkdir(parents=True,exist_ok=True)
            else:
                dst.parent.mkdir(parents=True,exist_ok=True)
                if not dst.is_file() or sha(dst.read_bytes())!=sha(z.read(e)):
                    dst.write_bytes(z.read(e))
    G=root/'godot'; R=root/'reports';R.mkdir(exist_ok=True)
    old=json.loads((G/'TB15P_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
    assert old['clip_count']==90 and old['total_frames']==805 and len(old['families'])==3
    M=copy.deepcopy(old)
    frost=next(f for f in M['families'] if f['kind']=='frost')
    assert len(frost['stages'])==3
    checks=[]
    movies=[]
    for st in frost['stages']:
        stage=int(st['index']);ko=st['motions']['ko'];idle=st['motions']['idle']
        for motion in (ko,idle):
            raw=(G/motion['path']).read_bytes()
            assert sha(raw)==motion['sha256'],('source sha mismatch',stage)
        assert ko['frames']==idle['frames']==8 and int(ko['columns'])==int(idle['columns'])==4
        cell=int(ko['cell'][0]);assert 128<=cell<=192 and idle['cell']==ko['cell']
        a_ko=Image.open(G/ko['path']).convert('RGBA')
        a_idle=Image.open(G/idle['path']).convert('RGBA')
        dead=[get_frame(a_ko,i,cell,4) for i in range(8)]
        alive=[get_frame(a_idle,i,cell,4) for i in range(8)]
        assert dead[0].tobytes()==alive[0].tobytes(),('KO F0 must equal Idle F0',stage)
        geom=[]
        for i,f in enumerate(dead):
            bbox=f.getchannel('A').getbbox()
            assert bbox is not None and min(bbox[0],bbox[1],cell-bbox[2],cell-bbox[3])>=2,('KO clipping',stage,i)
            geom.append({'frame':i,'bbox':bbox,'height':bbox[3]-bbox[1],
                         'width':bbox[2]-bbox[0],'frame_rgba_sha256':sha(f.tobytes())})
        height_ratio=geom[7]['height']/geom[0]['height']
        y_shift=geom[7]['bbox'][1]-geom[0]['bbox'][1]
        # This catches cases where a misleading middle-frame preview appears upright,
        # and requires visible completed collapse in the FINAL actual PNG.
        assert height_ratio<=0.80 and y_shift>=8,(stage,height_ratio,y_shift)
        # All original frames are genuine PixelLab output. Reversal is explicitly
        # procedural source retiming, NOT new AI generated imagery.
        output=[dead[j].copy() for j in range(7,-1,-1)]+[alive[1].copy(),alive[2].copy(),alive[3].copy()]
        assert len(output)==11
        assert output[0].tobytes()==dead[-1].tobytes()
        assert output[7].tobytes()==alive[0].tobytes()
        assert all(x.getchannel('A').getbbox() is not None for x in output)
        atlas=Image.new('RGBA',(4*cell,3*cell))
        for i,frame in enumerate(output):atlas.alpha_composite(frame,((i%4)*cell,(i//4)*cell))
        fname=f'FROST_STAGE{stage}_REVIVE_R16_SOURCE_LOCKED_11F_{cell}px.png'
        rel='assets/monsters/tb03/'+fname
        dest=G/rel;dest.parent.mkdir(exist_ok=True,parents=True);atlas.save(dest)
        st['motions']['revive']={
            'path':rel,'frames':11,'columns':4,'cell':[cell,cell],
            'fps':8,'loop':False,'sha256':sha(dest.read_bytes()),
            'source_sha256':st['source_sha256'],'origin_ko_sha256':ko['sha256'],
            'origin_idle_sha256':idle['sha256'],'technical_qa':'PASS',
            'art_status':'OWNER_ART_REVIEW_PENDING',
            'render_method':'SOURCE_EXACT_KO_REVERSE_F7_TO_F0_THEN_IDLE_F1_F3_NO_AI_COST',
            'ai_new_jobs':0,'ai_generations':0,
            'source_frames':[{'frame':j,'source_action':('ko' if j<8 else 'idle'),
                              'source_index':(7-j if j<8 else j-7),
                              'source_rgba_sha256':sha(output[j].tobytes())} for j in range(11)]
        }
        checks.append({'stage':stage,'name':st['name'],'source_sha256':st['source_sha256'],
                       'ko_source_sha256':ko['sha256'],'idle_source_sha256':idle['sha256'],
                       'KO_frame0_bbox':geom[0]['bbox'],'KO_final_bbox':geom[7]['bbox'],
                       'KO_height_ratio':round(height_ratio,4),'KO_head_to_ground_dy':y_shift,
                       'KO_final_collapsed_structural_gate':'PASS',
                       'KO_all_8_frames':geom,
                       'revive_new_sheet_sha256':sha(dest.read_bytes()),
                       'revive_slots':11,'source_identities_exact':True,
                       'reused_original_KO_8_frames':8,'reused_original_IDLE_3_frames':3,
                       'new_ai_provider_jobs':0,'new_ai_generation_cost':0,
                       'owner_visual_approval':'PENDING'})
        # Full KO and REVIVE review, not F3 thumbnails. 2 rows × 11 samples per stage.
        movies.append((stage,dead,output))
    M.update(schema='FS_TB_R16_THREE_FAMILY_COMPLETE_SOURCE_LOCKED_FROST_KO_REVIVE',
             stage_count=9,baseline_clip_count=87,evolution_transition_clip_count=6,
             clip_count=93,total_frames=838,
             actions_per_family={'bat':12,'frog':12,'frost':5},
             frost_new_source_retained_revives=3,source_r15p_zip_sha256=EXPECTED_ZIP_SHA,
             new_pixel_lab_jobs=0,new_generation_cost=0,
             technical_qa='NATIVE_PENDING',human_art_gate='OWNER_ART_REVIEW_PENDING',
             visual_gate_note='Three true original KO F7 frames are collapsed by bbox metrics; human ART approval for style is still PENDING. Third wolf family has only 5/12 actions per stage; seven remain.')
    manifest=G/'TB16_MONSTER_FAMILY_MANIFEST.json'
    manifest.write_text(dump(M),encoding='utf-8')
    (R/'R16_FROST_KO_SEMANTIC_AND_REVIVE_SOURCE_QA.json').write_text(dump({'baseline_zip_sha256':EXPECTED_ZIP_SHA,
       'new_source_timed_actions':3,'new_ai_jobs':0,'new_frame_slots':33,
       'ko_extracted_full_frames':24,'stage_qa':checks}),encoding='utf-8')
    glyph=Path('C:/Windows/Fonts/arial.ttf')
    font=ImageFont.truetype(str(glyph),18) if glyph.exists() else ImageFont.load_default()
    board=Image.new('RGB',(1670,850),(24,42,58));draw=ImageDraw.Draw(board)
    draw.text((24,14),'FS R16 | REAL ORIGINAL PIXEL LAB KO F0-F7 + SOURCE RETIMED REVIVE F0-F10 | 3 FROST STAGES',font=font,fill=(230,243,233))
    for idx,(stage,dead,output) in enumerate(movies):
        x=22+idx*547
        draw.text((x,54),f'GLACIER JACKAL STAGE {stage}',font=font,fill=(211,239,246))
        draw.text((x,100),'KO SOURCE ORIGINAL 8 FRAMES',font=font,fill=(216,194,142))
        draw.text((x,391),'REVIVE SOURCE KO REVERSED + IDLE',font=font,fill=(216,194,142))
        for row,samples in enumerate((dead,output)):
            for i,img in enumerate(samples):
                width=112
                w=112;h=112
                preview=Image.new('RGBA',(img.width,img.height),(34,56,71,255));preview.alpha_composite(img)
                preview=preview.convert('RGB').resize((w,h),Image.Resampling.NEAREST)
                xx=x+(i%4)*133;yy=(135 if row==0 else 432)+(i//4)*127
                board.paste(preview,(xx,yy))
                draw.text((xx,yy+113),f'F{i}',font=font,fill=(197,212,224))
    board.save(R/'R16_FROST_THREE_STAGE_KO_FULL_AND_REVIVE_REVIEW.png')
    for st,dead,output in movies:
        gif=[]
        for image in output:
            bg=Image.new('RGBA',image.size,(28,49,65,255));bg.alpha_composite(image)
            gif.append(bg.convert('RGB').resize((image.width*3,image.height*3),Image.Resampling.NEAREST))
        gif[0].save(R/f'R16_FROST_STAGE{st}_REVIVE_11F.gif',save_all=True,
                    append_images=gif[1:],loop=0,duration=120,disposal=2,optimize=False)
    scene_gd='''extends Node2D
const DATA := "res://TB16_MONSTER_FAMILY_MANIFEST.json"
var sprites: Array[AnimatedSprite2D]=[]
var mode := "ko"
func caption(s:String,p:Vector2)->void:
    var x=Label.new()
    x.text=s
    x.position=p
    x.add_theme_font_size_override("font_size",19)
    x.add_theme_color_override("font_color",Color("e8f5ee"))
    add_child(x)
func _ready()->void:
    var back=ColorRect.new()
    back.color=Color("192c3e")
    back.size=Vector2(1280,900)
    add_child(back)
    caption("FS R16 SOURCE AUTHENTIC FROST KO / REVIVE GALLERY",Vector2(20,25))
    caption("1 = KO, 2 = REVIVE, Space = replay  |  Art-only, no battle code",Vector2(20,65))
    var m: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(DATA)) as Dictionary
    for i in range(3):
        var a=AnimatedSprite2D.new()
        a.position=Vector2(220+i*414,450)
        a.scale=Vector2(2.5,2.5)
        a.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(a)
        sprites.append(a)
        caption("FROST STAGE "+str(i+1),Vector2(100+i*414,690))
    show_motion("ko")
func show_motion(which:String)->void:
    mode=which
    var m:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(DATA)) as Dictionary
    for i in range(3):
        var stage:Dictionary=m["families"][2]["stages"][i]
        var act:Dictionary=stage["motions"][which]
        var img=load("res://"+str(act["path"])) as Texture2D
        assert(img!=null)
        var frames=SpriteFrames.new()
        frames.remove_animation("default")
        frames.add_animation("play")
        frames.set_animation_loop("play",false)
        frames.set_animation_speed("play",float(act["fps"]))
        var c=int(act["cell"][0])
        for k in range(int(act["frames"])):
            var at=AtlasTexture.new()
            at.atlas=img
            at.region=Rect2((k%4)*c,int(k/4)*c,c,c)
            at.filter_clip=true
            frames.add_frame("play",at)
        sprites[i].stop()
        sprites[i].sprite_frames=frames
        sprites[i].play("play")
func _input(event:InputEvent)->void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_1:show_motion("ko")
        elif event.keycode==KEY_2:show_motion("revive")
        elif event.keycode==KEY_SPACE:show_motion(mode)
'''
    (G/'tb16_frost_gallery.gd').write_text(scene_gd,encoding='utf-8')
    (G/'tb16_frost_gallery.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tb16_frost_gallery.gd" id="1"]\n[node name="TB16FrostGallery" type="Node2D"]\nscript = ExtResource("1")\n',encoding='utf-8')
    (G/'tests').mkdir(exist_ok=True)
    test='''extends SceneTree
func _initialize()->void:call_deferred("run_native_test")
func run_native_test()->void:
    root.size=Vector2i(1280,900)
    var m:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://TB16_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(m["families"].size()==3)
    assert(int(m["stage_count"])==9)
    assert(int(m["baseline_clip_count"])==87)
    assert(int(m["evolution_transition_clip_count"])==6)
    assert(int(m["clip_count"])==93)
    assert(int(m["total_frames"])==838)
    var count=0
    var frames=0
    for family in m["families"]:
        for stage in family["stages"]:
            for key in stage["motions"].keys():
                var motion:Dictionary=stage["motions"][key]
                var tex=load("res://"+str(motion["path"])) as Texture2D
                assert(tex!=null)
                var c=int(motion["cell"][0])
                var cols=int(motion["columns"])
                assert(tex.get_width()==c*cols)
                assert(tex.get_height()==int(ceil(float(motion["frames"])/float(cols)))*c)
                count+=1
                frames+=int(motion["frames"])
    assert(count==87 and frames==742)
    var gallery=load("res://tb16_frost_gallery.tscn").instantiate()
    root.add_child(gallery)
    await process_frame
    assert(gallery.sprites.size()==3)
    for action in ["ko","revive"]:
        gallery.show_motion(action)
        for sp in gallery.sprites:
            assert(sp.sprite_frames.get_frame_count("play")== (8 if action=="ko" else 11))
            assert(sp.sprite_frames.get_frame_texture("play",0)!=null)
            assert(sp.sprite_frames.get_frame_texture("play",(7 if action=="ko" else 10))!=null)
    print("FS_TB_R16_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=87 evolutions=6 clips=93 frames=838 frost_revive=3")
    quit(0)
'''
    (G/'tests'/'test_tb16_frost_art_native.gd').write_text(test,encoding='utf-8')
    historical=(G/'TB15P_MONSTER_FAMILY_MANIFEST.json').read_bytes()
    assert sha(historical)==sha((root/'godot'/'TB15P_MONSTER_FAMILY_MANIFEST.json').read_bytes())
    with zipfile.ZipFile(source) as z: unchanged_sources(z,root)
    # Current source freezes exact R15P original PNGs. R16 only adds 3 new wolf revives.
    godot_result='NOT_RUN'
    if a.godot:
        g=Path(a.godot);assert g.is_file(),str(g)
        version=subprocess.run([str(g),'--version'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=35)
        assert version.returncode==0 and '4.7.2' in version.stdout,version.stdout+version.stderr
        editor=subprocess.run([str(g),'--headless','--editor','--path',str(G),'--quit'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=220)
        (R/'R16_GODOT_EDITOR_IMPORT.log').write_text(editor.stdout+'\nSTDERR\n'+editor.stderr,encoding='utf-8')
        assert editor.returncode==0,editor.stderr[-1000:]
        runtime=subprocess.run([str(g),'--headless','--path',str(G),'--script','res://tests/test_tb16_frost_art_native.gd'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=170)
        log=runtime.stdout+'\nSTDERR\n'+runtime.stderr
        (R/'R16_GODOT_NATIVE_ART_QA.log').write_text(log,encoding='utf-8')
        assert runtime.returncode==0 and NATIVE_MARK in log,log[-2200:]
        godot_result='PASS'
    M['technical_qa']='PASS' if godot_result=='PASS' else 'NATIVE_NOT_RUN'
    manifest.write_text(dump(M),encoding='utf-8')
    if (G/'.godot').is_dir():shutil.rmtree(G/'.godot')
    output=Path(a.out_zip) if a.out_zip else root.parent/ZIP_NAME
    # Do not embed a stale prior run's ZIP hash evidence into a new archive.
    stale_proof=R/'R16_PACKAGE_PROOF.json'
    if stale_proof.exists():stale_proof.unlink()
    paths=[x for x in root.rglob('*') if x.is_file() and '.godot' not in x.parts]
    with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for path in sorted(paths):z.write(path,path.relative_to(root).as_posix())
    with zipfile.ZipFile(output) as z:
        assert z.testzip() is None
        entries=len(z.namelist())
    assert entries>=382,entries
    proof={'package_name':ZIP_NAME,'bytes':output.stat().st_size,'sha256':sha(output.read_bytes()),
           'zip_files':entries,'CRC':'PASS','r15p_immutable_source_zip_SHA256':EXPECTED_ZIP_SHA,
           'source_QA':'PASS','ko_semantic_structural_QA':'PASS','godot_native':godot_result,
           'visual_art':'OWNER_ART_REVIEW_PENDING','integration':'NOT_RUN_ART_ONLY',
           'families':3,'forms':9,'base_animations':87,'evolutions':6,'clips':93,'frames':838,
           'wolf_stages_passed':3,'wolf_ko_original_8F_verified':3,
           'wolf_revive_source_retimed_11F':3,'new_real_PixelLab_jobs':0,'new_generations':0,
           'wolf_remaining_actions_per_stage':7}
    (R/'R16_PACKAGE_PROOF.json').write_text(dump(proof),encoding='utf-8')
    if a.private_drive:
        assert godot_result=='PASS','Cannot publish private formal release without real Godot native QA'
        drive=Path(a.private_drive);assert drive.is_dir()
        dst=drive/ZIP_NAME
        assert not dst.exists(),('Existing Drive release must not be overwritten',dst)
        shutil.copyfile(output,dst)
        assert sha(dst.read_bytes())==proof['sha256']
        with zipfile.ZipFile(dst) as z:
            assert z.testzip() is None and len(z.namelist())==entries
        for p in [R/'R16_FROST_THREE_STAGE_KO_FULL_AND_REVIVE_REVIEW.png',
                  R/'R16_FROST_KO_SEMANTIC_AND_REVIVE_SOURCE_QA.json',
                  R/'R16_GODOT_NATIVE_ART_QA.log']+[R/f'R16_FROST_STAGE{i}_REVIVE_11F.gif' for i in (1,2,3)]:
            dst2=drive/p.name
            assert not dst2.exists(),str(dst2)
            shutil.copyfile(p,dst2)
            assert sha(dst2.read_bytes())==sha(p.read_bytes())
        proofpath=drive/'R16_PACKAGE_PROOF.json'
        assert not proofpath.exists(),str(proofpath)
        proofpath.write_text(dump(proof),encoding='utf-8')
        assert json.loads(proofpath.read_text(encoding='utf-8'))==proof
        print('FS_TB_R16_DRIVE_PRIVATE_WRITE_READBACK_PASS',json.dumps(proof,ensure_ascii=False),flush=True)
    else:
        print('FS_TB_R16_LOCAL_CANDIDATE_NATIVE_NOT_RUN',json.dumps(proof,ensure_ascii=False),flush=True)
    return 0
if __name__=='__main__':sys.exit(main())