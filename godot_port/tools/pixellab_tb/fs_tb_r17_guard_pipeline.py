#!/usr/bin/env python3
"""Forest Symphony T-B R17: 3 genuine PixelLab GUARD clips; owner-private native Godot gate.

Bounded, reviewed PC Bridge entrypoint only. Exactly 3 source-locked v3 provider jobs.
Inputs: pinned full original R16 ZIP in owner-private mounted Google Drive, runner's
existing PIXELLAB_API_TOKEN. No CLI/Issue supplied paths, URL, prompts or commands.
Outputs: private G: owner Drive, only after source+Godot native validation.
Public repo gets this reusable source logic, never secret assets.
"""
from __future__ import annotations
import base64,copy,hashlib,io,json,math,os,shutil,sys,tempfile,time,urllib.request,urllib.error,zipfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

ROOT_ID='10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'
ROOT_NAME='FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'
GDRIVE=Path('G:/.shortcut-targets-by-id')/ROOT_ID/ROOT_NAME
SOURCE='FS_TB_R16_FROST_KO_REVIVE_NATIVE_VERIFIED_PRIVATE_20261123.zip'
SRC_SHA='a3292f8e9ce94648f8a9d61bb22271a4d3d3f92fc02f132fb18c5278e92d9efe'
SRC_BYTES=10547433
SRC_ENTRIES=387
TARGET='FS_TB_R17_GLACIER_JACKAL_GUARD_3STAGE_NATIVE_20261123_PRIVATE.zip'
NATIVE_MARKER='FS_TB_R17_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=90 evolutions=6 clips=96 frames=862 frost_guard=3'
MAX_JOBS=3
MAX_REPORTED_GENERATIONS=18.0
MAX_RUNTIME_SECONDS=225
def sha(b:bytes)->str:return hashlib.sha256(b).hexdigest()
def write_text(path:Path,value:object)->None:
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(value,indent=2,ensure_ascii=False),encoding='utf-8')
def check_r16(path:Path):
    assert path.is_file() and path.stat().st_size==SRC_BYTES,'R16 private original ZIP missing or wrong size'
    assert sha(path.read_bytes())==SRC_SHA,'R16 source ZIP SHA mismatch'
    with zipfile.ZipFile(path) as z:
        assert len(z.namelist())==SRC_ENTRIES and z.testzip() is None,'R16 source ZIP CRC/entries mismatch'
        for n in z.namelist():
            p=Path(n)
            assert not p.is_absolute() and '..' not in p.parts and not n.startswith(('/','\\')),'unsafe ZIP member'
        d=json.loads(z.read('godot/TB16_MONSTER_FAMILY_MANIFEST.json'))
        assert d['clip_count']==93 and d['total_frames']==838 and d['baseline_clip_count']==87
        fs=next(f for f in d['families'] if f['kind']=='frost')
        assert len(fs['stages'])==3
        for st in fs['stages']:
            assert st['index'] in (1,2,3) and len(st['motions'])==5
            source=z.read('godot/'+st['source_path'])
            assert sha(source)==st['source_sha256']
            assert st['source_size']==[128+32*(st['index']-1)]*2
            for act in ('idle','attack','hurt','ko','revive'):
                meta=st['motions'][act]
                assert sha(z.read('godot/'+meta['path']))==meta['sha256']
    return d
def frame0(z:zipfile.ZipFile,st):
    m=st['motions']['idle']
    c=m['cell'][0]
    atlas=Image.open(io.BytesIO(z.read('godot/'+m['path']))).convert('RGBA')
    return atlas.crop((0,0,c,c))
def encoded(image:Image.Image):
    raw=io.BytesIO();image.save(raw,format='PNG')
    return {'type':'base64','format':'png','base64':base64.b64encode(raw.getvalue()).decode('ascii')}
def decode_image(v):
    if isinstance(v,dict):
        return decode_image(v.get('image') or v.get('base64') or v.get('data'))
    assert isinstance(v,str)
    raw=base64.b64decode(v.split(',',1)[-1],validate=True)
    return Image.open(io.BytesIO(raw)).convert('RGBA')
def query(token:str,path:str,body=None):
    endpoint='https://api.pixellab.ai/v2'+path
    data=json.dumps(body,separators=(',',':')).encode('utf-8') if body is not None else None
    req=urllib.request.Request(endpoint,data=data,headers={'Authorization':'Bearer '+token,'Content-Type':'application/json'})
    for i in range(3):
        try:
            with urllib.request.urlopen(req,timeout=35) as response:return json.load(response)
        except urllib.error.HTTPError as ex:
            if ex.code in (429,502,503,504) and i<2:
                time.sleep(5*(i+1));continue
            raise RuntimeError(f'PixelLab request failed: HTTP {ex.code} on reviewed {path}') from None
        except urllib.error.URLError:
            if i<2:time.sleep(5*(i+1));continue
            raise RuntimeError('PixelLab network request unavailable') from None
def prompt(stage:int)->str:
    names={1:'Glacier Jackal pup',2:'Crystal Wolf Guardian',3:'Ancient Glacier Fenrir'}
    out=(f'The SAME four-legged silver-blue {names[stage]} takes a GUARD stance, not attack. '
         'Fixed southeast 3/4 JRPG pixel battle camera. F0 original pose; F1-F3 duck head '
         'and bend all four connected legs low. F4-F5 hold defensive crouch, ears alert. '
         'F6-F7 rise to SAME original pose. Preserve navy muzzle, cyan ice crystal, blue eyes, '
         'ears, paws, thick tail and same identity. Keep inside margins. '
         'No shield, extra limbs, other wolf, magic, projectiles, camera turn, or background.')
    assert len(out)<=495,(stage,len(out))
    return out

def provider_frames(done:dict,frames:int):
    response=done.get('last_response') or {}
    raw=response.get('images') or response.get('frames') or response.get('output_images') or []
    assert len(raw) in (frames,frames+1),'PixelLab unexpected raw frame count'
    originals=[decode_image(x) for x in raw]
    selected=[round(i*(len(originals)-1)/(frames-1)) for i in range(frames)] if len(raw)==frames+1 else list(range(frames))
    assert len(set(selected))==frames
    return originals,[originals[k].copy() for k in selected],response.get('generation_id')
def atlas_frames(images:list[Image.Image],size:int):
    assert len(images)==8 and all(a.size==(size,size) for a in images)
    result=Image.new('RGBA',(4*size,2*size))
    for i,f in enumerate(images):
        result.alpha_composite(f,((i%4)*size,(i//4)*size))
    return result
def qa_frames(images:list[Image.Image],source:Image.Image,stage:int):
    cell=source.width;assert source.size==(cell,cell)
    bounds=[];hashes=[]
    for i,f in enumerate(images):
        assert f.size==(cell,cell),('frame size mismatch',stage,i)
        box=f.getchannel('A').getbbox()
        assert box is not None,('empty frame',stage,i)
        if min(box[0],box[1],cell-box[2],cell-box[3])<2:raise RuntimeError(f'R17 GUARD STAGE{stage} F{i} alpha clipped')
        bounds.append(box);hashes.append(sha(f.tobytes()))
    assert len(set(hashes))>=6,('non-moving guard',stage)
    assert images[0].tobytes()==source.tobytes() and images[-1].tobytes()==source.tobytes(),'not exact source keyframe endpoints'
    return {'bounds':bounds,'unique_frames':len(set(hashes)),'source_exact_first_last':True,'frame_sha256':hashes}
def source_immutability(original:Path,dest:Path):
    with zipfile.ZipFile(original) as z:
        for entry in z.namelist():
            if entry.endswith('/') or not entry.lower().endswith('.png'):continue
            p=dest/entry
            assert p.is_file() and sha(p.read_bytes())==sha(z.read(entry)),('original PNG changed',entry)
def create_project(root:Path,records:list[dict],ledger:list[dict]):
    G=root/'godot';R=root/'reports';R.mkdir(exist_ok=True)
    d=json.loads((G/'TB16_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
    assert d['clip_count']==93 and d['total_frames']==838
    nd=copy.deepcopy(d)
    f=next(x for x in nd['families'] if x['kind']=='frost')
    for rec in records:
        st=f['stages'][rec['stage']-1]
        assert 'guard' not in st['motions']
        st['motions']['guard']=copy.deepcopy(rec['motion'])
    assert all(len(st['motions'])==6 for st in f['stages'])
    nd.update(schema='FS_TB_R17_FROST_GUARD_3STAGE_REAL_PIXEL_LAB_V3',
              clip_count=96,total_frames=862,baseline_clip_count=90,
              third_family_motions=18,actions_per_family={'bat':12,'frog':12,'frost':6},
              new_pixel_lab_jobs=3,new_provider_generations=sum(float(x['reported_usage'].get('generations',0)) for x in ledger),
              new_true_provider_frame_slots=24,technical_qa='NATIVE_NOT_RUN',
              human_art_gate='OWNER_ART_REVIEW_PENDING',integration_qa='NOT_RUN_ART_ONLY',
              source_r16_zip_sha256=SRC_SHA)
    write_text(G/'TB17_MONSTER_FAMILY_MANIFEST.json',nd)
    write_text(R/'R17_PIXEL_LAB_THREE_STAGE_GUARD_LEDGER.json',ledger)
    write_text(R/'R17_SOURCE_SHA_AND_FRAME_QA.json',records)
    # Source import + a real animated gallery for three distinctly authored stages.
    scene='''extends Node2D
var sprites:Array[AnimatedSprite2D]=[]
func _ready()->void:
    var doc=JSON.parse_string(FileAccess.get_file_as_string("res://TB17_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(doc["families"].size()==3)
    var bg=ColorRect.new()
    bg.size=Vector2(1280,850)
    bg.color=Color("203040")
    add_child(bg)
    var header=Label.new()
    header.text="FS R17 TRUE PIXELLAB | THREE-STAGE GLACIER JACKAL GUARD | ART REVIEW PENDING"
    header.position=Vector2(25,20)
    header.add_theme_font_size_override("font_size",23)
    add_child(header)
    for i in range(3):
        var st:Dictionary=doc["families"][2]["stages"][i]
        var motion:Dictionary=st["motions"]["guard"]
        var original=load("res://"+str(motion["path"])) as Texture2D
        assert(original!=null)
        var anim=SpriteFrames.new()
        anim.remove_animation("default")
        anim.add_animation("guard")
        anim.set_animation_speed("guard",float(motion["fps"]))
        anim.set_animation_loop("guard",true)
        var cell=int(motion["cell"][0])
        for k in range(int(motion["frames"])):
            var part=AtlasTexture.new()
            part.atlas=original
            part.region=Rect2((k%4)*cell,int(k/4)*cell,cell,cell)
            part.filter_clip=true
            anim.add_frame("guard",part)
        var sprite=AnimatedSprite2D.new()
        sprite.sprite_frames=anim
        sprite.position=Vector2(230+i*410,410)
        sprite.scale=Vector2(2.25,2.25)
        sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(sprite)
        sprite.play("guard")
        sprites.append(sprite)
'''
    (G/'tb17_frost_guard_gallery.gd').write_text(scene,encoding='utf-8')
    (G/'tb17_frost_guard_gallery.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tb17_frost_guard_gallery.gd" id="1"]\n[node name="TB17Guard" type="Node2D"]\nscript = ExtResource("1")\n',encoding='utf-8')
    native='''extends SceneTree
func _initialize()->void:call_deferred("check")
func check()->void:
    root.size=Vector2i(1280,850)
    var doc=JSON.parse_string(FileAccess.get_file_as_string("res://TB17_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(doc["families"].size()==3 and int(doc["stage_count"])==9)
    assert(int(doc["clip_count"])==96 and int(doc["total_frames"])==862)
    assert(int(doc["baseline_clip_count"])==90 and int(doc["evolution_transition_clip_count"])==6)
    var motion_count=0
    var frames=0
    for family in doc["families"]:
        for stage in family["stages"]:
            for action in stage["motions"].keys():
                var meta:Dictionary=stage["motions"][action]
                var texture=load("res://"+str(meta["path"])) as Texture2D
                assert(texture!=null)
                var cell=int(meta["cell"][0])
                var col=int(meta["columns"])
                assert(texture.get_width()==cell*col)
                assert(texture.get_height()==cell*int(ceil(float(meta["frames"])/float(col))))
                frames+=int(meta["frames"])
                motion_count+=1
    assert(motion_count==90 and frames==766)
    var a=load("res://tb17_frost_guard_gallery.tscn").instantiate()
    root.add_child(a)
    await process_frame
    assert(a.sprites.size()==3)
    for spr in a.sprites:
        assert(spr.is_playing())
        assert(spr.sprite_frames.get_frame_count("guard")==8)
        assert(spr.sprite_frames.get_frame_texture("guard",7)!=null)
    print("FS_TB_R17_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=90 evolutions=6 clips=96 frames=862 frost_guard=3")
    quit(0)
'''
    (G/'tests/test_tb17_guard_native.gd').write_text(native,encoding='utf-8')
    return nd
def previews(root:Path,frames_by_stage:dict[int,list[Image.Image]]):
    output=root/'reports';font=ImageFont.load_default()
    sheet=Image.new('RGB',(1260,660),(26,40,56))
    d=ImageDraw.Draw(sheet)
    d.text((20,18),'R17 TRUE PIXELLAB | GLACIER JACKAL THREE STAGES | GUARD 8 FRAMES EACH | OWNER ART REVIEW PENDING',
           fill=(227,238,232),font=font)
    for stage,frames in frames_by_stage.items():
        y=40+(stage-1)*205
        d.text((16,y+20),f'STAGE {stage}',fill=(224,196,153),font=font)
        for i,frame in enumerate(frames):
            thumb=frame.copy()
            thumb.thumbnail((125,160),Image.Resampling.NEAREST)
            canvas=Image.new('RGBA',thumb.size,(42,57,72,255));canvas.alpha_composite(thumb)
            x=110+i*142
            sheet.paste(canvas.convert('RGB'),(x,y+12))
            d.text((x,y),f'F{i}',fill=(226,238,227))
    sheet.save(output/'R17_FROST_GUARD_THREE_STAGE_8F_CONTACT.png')
    for stage,frames in frames_by_stage.items():
        sequence=[]
        for frame in frames:
            b=Image.new('RGBA',frame.size,(26,42,59,255));b.alpha_composite(frame)
            sequence.append(b.resize((frame.width*2,frame.height*2),Image.Resampling.NEAREST).convert('RGB'))
        sequence[0].save(output/f'R17_FROST_STAGE{stage}_GUARD_8F.gif',save_all=True,
                         append_images=sequence[1:],duration=135,loop=0,disposal=2)
def godot_native(root:Path):
    from subprocess import run
    base=Path('E:/Godot/4.7.2/Godot_v4.7.2-stable_win64.exe')
    eng=base/'Godot_v4.7.2-stable_win64_console.exe'
    if not eng.is_file():eng=base/'Godot_v4.7.2-stable_win64.exe'
    assert eng.is_file(),'official installed Godot missing'
    engine=run([str(eng),'--version'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=25)
    assert engine.returncode==0 and '4.7.2.stable.official' in engine.stdout
    G=root/'godot';R=root/'reports'
    editor=run([str(eng),'--headless','--editor','--path',str(G),'--quit'],
             capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=100)
    assert editor.returncode==0,'Godot editor import failed'
    assert not any(x in (editor.stdout+editor.stderr) for x in ('SCRIPT ERROR:','PARSER ERROR:','ERROR:'))
    native=run([str(eng),'--headless','--path',str(G),'--script','res://tests/test_tb17_guard_native.gd'],
             capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=100)
    line='Godot '+engine.stdout.strip()+'\n'+editor.stdout+'\n'+editor.stderr+'\n'+native.stdout+'\n'+native.stderr
    (R/'R17_M2_WINDOWS_GODOT_NATIVE_TEST.log').write_text(line,encoding='utf-8')
    assert native.returncode==0 and NATIVE_MARKER in native.stdout,'Native Guard art QA failed'
    assert not any(x in line for x in ('SCRIPT ERROR:','PARSER ERROR:','ERROR:'))
    return engine.stdout.strip()
def archive_private(root:Path,name:str,baseline:Path):
    # Private persistence first, then runner temp delete. No public GH ZIP.
    output=root.parent/(root.name+'_candidate.zip')
    if (root/'godot/.godot').is_dir():shutil.rmtree(root/'godot/.godot')
    with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for file in sorted(root.rglob('*')):
            if file.is_file():z.write(file,file.relative_to(root).as_posix())
    with zipfile.ZipFile(output) as z:
        assert z.testzip() is None and len(z.namelist())>=395
    assert not (GDRIVE/name).exists(),'No silent private artifact overwrite'
    shutil.copyfile(output,GDRIVE/name)
    assert sha(output.read_bytes())==sha((GDRIVE/name).read_bytes())
    result={'file_name':name,'sha256':sha(output.read_bytes()),'bytes':output.stat().st_size,
            'zip_entries':len(zipfile.ZipFile(output).namelist()),'private_parent_id':ROOT_ID,
            'source_r16_immutable_sha256':SRC_SHA,'godot_native_test_marker':NATIVE_MARKER,
            'new_genuine_provider_jobs':3,'new_exported_frames':24,
            'owner_art_gate':'OWNER_ART_REVIEW_PENDING','combat_integration':'NOT_RUN_ART_ONLY'}
    proof=GDRIVE/'R17_GUARD_RELEASE_PROOF_20261123.json'
    if proof.exists():raise RuntimeError('R17 private proof already exists; no overwrite')
    write_text(proof,result)
    for name in ('R17_FROST_GUARD_THREE_STAGE_8F_CONTACT.png',
                 'R17_M2_WINDOWS_GODOT_NATIVE_TEST.log','R17_PIXEL_LAB_THREE_STAGE_GUARD_LEDGER.json'):
        f=root/'reports'/name
        target=GDRIVE/name
        assert not target.exists(),'R17 duplicate private standalone file'
        shutil.copyfile(f,target)
        assert sha(f.read_bytes())==sha(target.read_bytes())
    return result
def main():
    uid=os.getenv('GITHUB_RUN_ID','')
    assert uid.isdigit() and 6<=len(uid)<=20,'R17 requires fixed-owner GitHub Actions runner'
    assert GDRIVE.is_dir(),'owner private Drive mount unavailable'
    token=os.getenv('PIXELLAB_API_TOKEN')
    if not token or len(token)<=20:raise RuntimeError('PIXELLAB_AUTH_HOLD in runner (token value is never logged)')
    baseline=GDRIVE/SOURCE
    d=check_r16(baseline)
    root=Path(tempfile.gettempdir())/('fs_tb_r17_guard_'+uid)
    assert not root.exists(),'never use an existing local temp project'
    root.mkdir(parents=True)
    # Validate ALL three prompts before authorizing the very first paid job.
    checked_prompts={i:prompt(i) for i in (1,2,3)}
    jobs=[];frames_by_stage={};records=[];submitted=0
    budget=0.0
    start=time.monotonic()
    try:
        with zipfile.ZipFile(baseline) as src:
            src.extractall(root)
            frost=next(x for x in d['families'] if x['kind']=='frost')
            sources={i+1:frame0(src,frost['stages'][i]) for i in range(3)}
        for stage in (1,2,3):
            if submitted>=MAX_JOBS or time.monotonic()-start>MAX_RUNTIME_SECONDS:
                raise RuntimeError('R17 bounded three-job/time limit reached')
            if budget>14.0:
                raise RuntimeError('R17 generation budget hold before additional provider job')
            st=frost['stages'][stage-1]
            source=sources[stage]
            body={'first_frame':encoded(source),'last_frame':encoded(source),
                  'frame_count':8,'action':checked_prompts[stage],
                  'no_background':True,'seed':202617021+stage*211}
            job=query(token,'/animate-with-text-v3',body)
            jid=job.get('background_job_id')
            assert isinstance(jid,str) and len(jid)>16,'No real PixelLab background job id'
            submitted+=1
            record={'stage':stage,'job_id':jid,'endpoint':'animate-with-text-v3',
                    'source_sha256':st['source_sha256'],'source_idle_sha256':st['motions']['idle']['sha256'],
                    'first_last_source_rgba_sha256':sha(source.tobytes()),
                    'action':body['action'],'seed':body['seed'],'requested_frames':8,
                    'technical_qa':'PENDING','human_art_gate':'OWNER_ART_REVIEW_PENDING'}
            jobs.append(record);write_text(root/'reports/R17_PIXEL_LAB_THREE_STAGE_GUARD_LEDGER.json',jobs)
            after=time.monotonic()
            while True:
                if time.monotonic()-after>125 or time.monotonic()-start>MAX_RUNTIME_SECONDS:
                    raise RuntimeError('PixelLab job polling timed out; preserve as paid ART HOLD')
                result=query(token,'/background-jobs/'+jid)
                if result.get('status')=='failed':raise RuntimeError('PixelLab real job failed; preserve job id')
                if result.get('status')=='completed':break
                time.sleep(5)
            originals,frames,gid=provider_frames(result,8)
            assert len(originals) in (8,9)
            if any(im.size!=source.size for im in originals):
                raise RuntimeError('PixelLab output cell dimensions mismatch')
            rawdir=root/'reports/ORIGINAL_PIXEL_LAB_RAW_FRAMES'/f'stage{stage}'
            rawdir.mkdir(parents=True,exist_ok=True)
            for i,im in enumerate(originals):im.save(rawdir/f'RAW_F{i:02d}.png')
            # Preserve provider output frames 1..6 unchanged, strictly source-lock endpoints.
            frames[0]=source.copy()
            frames[-1]=source.copy()
            gate=qa_frames(frames,source,stage)
            atlas=atlas_frames(frames,source.width)
            name=f'FROST_STAGE{stage}_GUARD_R17_TRUE_PIXEL_LAB_8F_{source.width}px.png'
            asset='assets/monsters/tb03/'+name
            dst=root/'godot'/asset
            dst.parent.mkdir(exist_ok=True,parents=True)
            atlas.save(dst)
            rawsha=sha(dst.read_bytes())
            provider_cost=result.get('usage') or {}
            units=float(provider_cost.get('generations',0))
            assert 0<units<=12,'PixelLab returned impossible per-clip actual usage'
            budget+=units
            record.update(technical_qa='PASS',reported_usage=provider_cost,
                          generation_id=gid,raw_returned_frames=len(originals),
                          raw_frame_pixel_sha256=[sha(im.tobytes()) for im in originals],
                          selected_export_frames=8,source_endpoint_exact_pixel=True,
                          exported_sha256=rawsha,source_locked_frames=gate)
            rec={'stage':stage,'motion':{
                  'path':asset,'frames':8,'columns':4,'cell':[source.width,source.height],
                  'fps':8,'loop':True,'sha256':rawsha,
                  'source_sha256':st['source_sha256'],'endpoint':'animate-with-text-v3',
                  'provider_job_id':jid,'generation_id':gid,'provider_usage':provider_cost,
                  'first_frame_exact_original_source':True,'last_frame_exact_original_source':True,
                  'unique_frames':gate['unique_frames'],'technical_qa':'PASS',
                  'art_status':'OWNER_ART_REVIEW_PENDING'}}
            records.append(rec);frames_by_stage[stage]=frames
            write_text(root/'reports/R17_PIXEL_LAB_THREE_STAGE_GUARD_LEDGER.json',jobs)
            print(f'FS_TB_R17_GUARD_STAGE{stage}_PROVIDER_QA_PASS frames=8 raw={len(originals)} usage={units:g}',flush=True)
        assert len(records)==3 and 0<budget<=MAX_REPORTED_GENERATIONS,'R17 bounded generation cap failure'
        source_immutability(baseline,root)
        create_project(root,records,jobs)
        previews(root,frames_by_stage)
        version=godot_native(root)
        source_immutability(baseline,root)
        result=archive_private(root,TARGET,baseline)
        print('FS_TB_R17_GUARD_PRIVATE_NATIVE_RELEASE_PASS',json.dumps(
            {**result,'native_version':version,'provider_reported_generation_usage':budget},ensure_ascii=False),flush=True)
    except Exception as exc:
        # Save paid provider results even on error, without claiming they passed QA.
        if submitted and not (GDRIVE/TARGET).exists():
            hold=f'FS_TB_R17_GUARD_PAID_ART_HOLD_{uid}_20261123.zip'
            report={'failure_type':type(exc).__name__,'failure_summary':str(exc)[:220],
                    'submitted_jobs':submitted,'completed_ledger':jobs,
                    'status':'ART_OR_NATIVE_HOLD_NO_PASS'}
            write_text(root/'reports/R17_REJECTED_PRODUCTION_RECORD.json',report)
            out=root.parent/(root.name+'_hold.zip')
            with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED) as f:
                for p in root.rglob('*'):
                    if p.is_file() and '.godot' not in p.parts:
                        f.write(p,p.relative_to(root).as_posix())
            shutil.copyfile(out,GDRIVE/hold)
            assert sha(out.read_bytes())==sha((GDRIVE/hold).read_bytes())
            out.unlink()
            print(f'FS_TB_R17_PAID_ART_HOLD_ARCHIVED jobs={submitted} private_file={hold}',flush=True)
        raise
    finally:
        # Exact run-specific temp deletion, no user's personal E: sources touched.
        if root.is_dir() and root.name=='fs_tb_r17_guard_'+uid:shutil.rmtree(root)
        p=root.parent/(root.name+'_candidate.zip')
        if p.is_file():p.unlink()
        assert not root.exists(),'R17 temporary project cleanup failed'
if __name__=='__main__':main()
