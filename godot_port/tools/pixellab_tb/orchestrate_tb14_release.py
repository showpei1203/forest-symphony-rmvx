#!/usr/bin/env python3
"""R14 source-controlled local orchestration for true PixelLab jobs -> Godot 4.7.2 -> private Drive.
Run after tb14_three_motion_provider.py has started, from same authorized TEMP runtime.
"""
import os,sys,time,subprocess,urllib.request,json,traceback
from pathlib import Path
P=Path(os.environ['TEMP'])
WORK=P/'fs_tb14_provider'
LED=WORK/'R14_PROVIDER_JOB_LEDGER.json'
R13=Path('G:/')/'.shortcut-targets-by-id'/'10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'/'FS_TB_R13_TWO_FAMILIES_9_ACTION_ART_FACTORY_PRIVATE_20261122.zip'
DRIVE=R13.parent
GODOT=Path('E:/Godot/4.7.2/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe')
assert R13.is_file() and DRIVE.is_dir() and GODOT.is_file()
deadline=time.monotonic()+37*60
done=False
while time.monotonic()<deadline:
    if LED.is_file():
        j=json.loads(LED.read_text(encoding='utf-8'))
        failure=[k for k,x in j.items() if x.get('status') in ('failed','submit_failed','qa_failed') or x.get('qa')=='HOLD']
        if failure:raise RuntimeError(f'Provider failures: {failure}')
        n=sum(x.get('status')=='completed' and x.get('qa')=='PASS' for x in j.values())
        if n==18 and len(j)==18:
            done=True
            break
        if n%3==0:print('TB14_RELEASE_WATCH',n,'of18',flush=True)
    time.sleep(9)
assert done,'No fake release: PixelLab work incomplete'
URL='https://raw.githubusercontent.com/showpei1203/forest-symphony-rmvx/e2649b9d43215ff11d0a4f21695858732586f487/godot_port/tools/pixellab_tb/build_tb14_art_release.py'
PY=P/'fs_tb14_release.py'
PY.write_bytes(urllib.request.urlopen(URL,timeout=50).read())
compile(PY.read_text(encoding='utf-8'),str(PY),'exec')
print('TB14_RELEASE_SOURCE_VERIFIED',len(PY.read_bytes()),flush=True)
cmd=[sys.executable,str(PY),'--r13-zip',str(R13),'--provider-work',str(WORK),
     '--staging',str(P/'fs_tb14_staging'),'--private-drive',str(DRIVE),'--godot',str(GODOT)]
with open(P/'fs_tb14_release_native.log','w',encoding='utf-8') as log:
    proc=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
        encoding='utf-8',errors='replace',bufsize=1)
    for line in proc.stdout:
        log.write(line);log.flush()
        print(line.rstrip(),flush=True)
    rc=proc.wait()
if rc!=0:
    print('TB14_RELEASE_FAILED',rc,flush=True)
    raise SystemExit(rc)
proof=json.loads((DRIVE/'R14_RELEASE_PROOF.json').read_text(encoding='utf-8'))
assert proof['total_clips']==76 and proof['total_frames']==680
print('TB14_RELEASE_WRITTEN_PRIVATE_DRIVE',json.dumps(proof,ensure_ascii=False),flush=True)
