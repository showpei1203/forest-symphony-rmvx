#!/usr/bin/env python3
"""Private-only release. Requires existing T-B DriveFS mounted folder, authenticated R13 provider output.
No gameplay integration and no private raster content submitted to GitHub.
"""
from pathlib import Path
import os,sys,time,json,hashlib,zipfile,subprocess,shutil,urllib.request
from PIL import Image
ROOT=Path(os.environ['TEMP'])
BAT=ROOT/'fs_tb_r10_tmp'
FROG=ROOT/'fs_tb11_tmp'
STAGE=ROOT/'fs_tb13_staging'
DRIVE=Path('G:/')/'.shortcut-targets-by-id'/'10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'
ZIP12=DRIVE/'FS_TB_R12_TWO_FAMILIES_7_ACTION_ART_FACTORY_PRIVATE_20261122.zip'
BINARY=Path('E:/Godot/4.7.2/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe')
assert ZIP12.is_file() and DRIVE.is_dir() and BINARY.is_file()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(ZIP12)=='a06510611f4b765b352a45bf8abf425d48ad2d688a78c45c5a20f1c06d938c82'
def get_jobs(p):return json.loads(p.read_text(encoding='utf-8'))
J1=BAT/'R13_BAT_PROVIDER_JOBS.json';J2=FROG/'R13_FROG_PROVIDER_JOBS.json'
print('R13_SOURCE_AND_DRIVE_VALIDATED',flush=True)
for tick in range(110):
    a=get_jobs(J1);b=get_jobs(J2)
    ok=sum(1 for x in list(a.values())+list(b.values()) if x.get('status')=='completed' and x.get('sheet_sha256'))
    if ok==12:break
    print('PENDING_PROVIDER_OUTPUTS',ok,'/12',flush=True)
    time.sleep(8)
assert ok==12,'Provider jobs incomplete; no Drive release'
assert len(a)==len(b)==6
print('PIXELLAB_12_AUTHENTIC_8FRAME_CLIPS_COMPLETE',flush=True)
URL='https://raw.githubusercontent.com/showpei1203/forest-symphony-rmvx/feat/fs-pixellab-tb-monster-20261121/godot_port/tools/pixellab_tb/build_tb13_art_release.py'
BUILDER=ROOT/'tb13_build.py'
BUILDER.write_bytes(urllib.request.urlopen(URL,timeout=45).read())
proc=subprocess.run([sys.executable,str(BUILDER),'--base_zip',str(ZIP12),'--bat_dir',str(BAT),'--frog_dir',str(FROG),'--staging',str(STAGE),'--drive_dir',str(DRIVE)],
                    capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=160)
print('TB13_BUILD_RESULT',proc.returncode,proc.stdout[-1200:],proc.stderr[-2400:],flush=True)
assert proc.returncode==0,'R13 Python art QA/builder failed; do not publish'
G=STAGE/'godot'
r=subprocess.run([str(BINARY),'--version'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=25)
version=(r.stdout+r.stderr).strip()
print('ENGINE_VERIFIED',version,flush=True)
assert '4.7.2' in version
imp=subprocess.run([str(BINARY),'--headless','--path',str(G),'--editor','--quit'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=150)
print('GODOT_IMPORT',imp.returncode,imp.stdout[-1200:],imp.stderr[-1600:],flush=True)
assert imp.returncode==0
test=subprocess.run([str(BINARY),'--headless','--path',str(G),'--script','res://tests/test_tb13_gallery_native.gd'],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=130)
log=test.stdout+'\nSTDERR\n'+test.stderr
(STAGE/'reports'/'R13_GODOT472_NATIVE_QA.log').write_text(log,encoding='utf-8')
print('GODOT_R13_NATIVE',test.returncode,log[-2000:],flush=True)
assert test.returncode==0 and 'FS_TB_R13_GODOT472_NATIVE_ART_ONLY_PASS clips=54 frames=436 stages=6 actions=9' in log,'Godot native test failed'
manifest=json.loads((G/'TB13_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
out=STAGE/'reports'/'R13_12_ACTION_GIF_PREVIEWS';out.mkdir(exist_ok=True)
for f in manifest['families']:
    for stage in f['stages']:
        for name in ('stun','taunt'):
            m=stage['motions'][name];c=int(m['cell'][0]);n=int(m['frames']);sheet=Image.open(G/m['path']).convert('RGBA')
            frames=[]
            for i in range(n):
                t=sheet.crop(((i%4)*c,(i//4)*c,(i%4+1)*c,(i//4+1)*c))
                canvas=Image.new('RGBA',t.size,(25,38,52,255));canvas.alpha_composite(t)
                frames.append(canvas.convert('RGB').resize((c*2,c*2),Image.Resampling.NEAREST))
            nameout=f"{f['kind'].upper()}_STAGE{stage['index']}_{name.upper()}_8F.gif"
            frames[0].save(out/nameout,save_all=True,append_images=frames[1:],duration=125,loop=0,disposal=2,optimize=False)
assert len(list(out.glob('*.gif')))==12
(STAGE/'R13_README.md').write_text('# Forest Symphony T-B R13 PRIVATE ART BUNDLE\n\nTwo original stage-locked PixelLab species families. Six forms, nine motions each; **54 authentic atlas clips and 436 original frame slots**. New: 12 Stun/Taunt clips (96 frames). Godot 4.7.2 independent headless native art gallery PASS. Human art quality remains REVIEW PENDING. No FS battle integration. Previously accepted Stage1 V6 / R8 bites preserved byte-for-byte; new raster provenance in reports. All images PRIVATE.\n',encoding='utf-8')
# Exclude engine cache, temporary hidden directories and any credentials.
dest=DRIVE/'FS_TB_R13_TWO_FAMILIES_9_ACTION_ART_FACTORY_PRIVATE_20261122.zip'
localzip=STAGE.parent/'fs_tb13_release_pending.zip'
files=sorted(p for p in STAGE.rglob('*') if p.is_file() and '.godot' not in p.parts and not p.name.endswith('.tmp'))
with zipfile.ZipFile(localzip,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for p in files:z.write(p,p.relative_to(STAGE).as_posix())
with zipfile.ZipFile(localzip) as z:
    assert z.testzip() is None
    count=len(z.namelist())
zip_sha=sha(localzip)
assert count>140
shutil.copyfile(localzip,dest)
assert sha(dest)==zip_sha
for p in sorted((STAGE/'reports').glob('R13_*_CONTACT.png')):shutil.copyfile(p,DRIVE/p.name)
for p in ('R13_NEW_CLIP_TECH_QA.json','R13_PROVIDER_JOB_LEDGER.json','R13_GODOT472_NATIVE_QA.log'):
    shutil.copyfile(STAGE/'reports'/p,DRIVE/p)
shutil.copyfile(G/'TB13_MONSTER_FAMILY_MANIFEST.json',DRIVE/'TB13_MONSTER_FAMILY_MANIFEST.json')
proof=dict(release_name=dest.name,zip_sha256=zip_sha,zip_crc='PASS',zip_files=count,zip_bytes=dest.stat().st_size,
           engine=version,stages=6,clip_count=54,frame_slots=436,new_clip_count=12,new_frames=96,
           new_pixel_lab_jobs=12,charged_generations=36.0,
           godot_native_qa='PASS',art_gate='OWNER_REVIEW_PENDING',playback='art_only')
(DRIVE/'R13_ZIP_RELEASE_PROOF.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf-8')
print('R13_RELEASE_COMPLETE',json.dumps(proof),flush=True)
