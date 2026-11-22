#!/usr/bin/env python3
"""R15 deterministic authorized owner-device cloud-release handoff.
Wait for exact 3 original frost sources+18 successful PixelLab motion jobs, then native Godot and upload.
If ANY QA/work fails: stop and preserve private uncommitted TEMP assets, do not claim success.
"""
import os,time,json,urllib.request,subprocess,sys,hashlib
from pathlib import Path
W=Path(os.environ['TEMP'])/'fs_tb15_provider'
LED=W/'R15_PIXELLAB_PROVIDER_LEDGER.json'
HOME=Path('G:/')/'.shortcut-targets-by-id'/'10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'
Z=HOME/'FS_TB_R14_TWO_FAMILIES_12_ACTIONS_PLUS_EVOLUTIONS_PRIVATE_20261122.zip'
GODOT=Path('E:/Godot/4.7.2/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe')
assert Z.is_file() and GODOT.is_file() and HOME.is_dir()
task=[f'{k}:{s}:revive' for k in ('bat','frog') for s in (1,2,3)]
task+=[f'frost:{s}:{a}' for s in (1,2,3) for a in ('idle','attack','hurt','ko')]
limit=time.monotonic()+40*60
last=None
while time.monotonic()<limit:
    if LED.is_file():
        rows=json.loads(LED.read_text(encoding='utf-8'))
        fail={k:v.get('status') for k,v in rows.items() if v.get('status') in ('failed','submit_failed','qa_failed') or v.get('qa')=='ART_TECH_HOLD'}
        if fail:raise RuntimeError('Source/provider failed; no release: '+str(fail))
        complete=sum(rows.get(k,{}).get('status')=='completed' and rows[k].get('qa')=='PASS' for k in task)
        sources=sum(rows.get(f'frost:{i}:source',{}).get('status')=='completed' for i in (1,2,3))
        now=(complete,sources)
        if now!=last:print('FS_TB15_WATCH',complete,'of18',sources,'of3 SOURCE',flush=True);last=now
        if complete==18 and sources==3:break
    time.sleep(8)
else:raise RuntimeError('R15 timed out with evidence retained in TEMP, no fake Drive upload')
BUILDER=Path(os.environ['TEMP'])/'fs_tb15_builder.py'
BUILDER.write_bytes(urllib.request.urlopen('https://raw.githubusercontent.com/showpei1203/forest-symphony-rmvx/d5ba693d83f4e820e9616756117577e70d0b5356/godot_port/tools/pixellab_tb/build_tb15_art_release.py',timeout=60).read())
compile(BUILDER.read_text(encoding='utf-8'),str(BUILDER),'exec')
print('FS_TB15_BUILDER_SOURCE_READY',len(BUILDER.read_bytes()),flush=True)
run=[sys.executable,str(BUILDER),
    '--r14-zip',str(Z),'--provider-work',str(W),
    '--staging',str(Path(os.environ['TEMP'])/'fs_tb15_staging'),
    '--private-drive',str(HOME),'--godot',str(GODOT)]
logpath=Path(os.environ['TEMP'])/'fs_tb15_release_process.log'
with logpath.open('w',encoding='utf-8') as output:
    p=subprocess.Popen(run,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
        encoding='utf-8',errors='replace',bufsize=1)
    for line in p.stdout:
        output.write(line);output.flush();print(line.rstrip(),flush=True)
    ret=p.wait()
assert ret==0,'R15 private builder failed; raw images remain in TEMP for recovery'
proof=json.loads((HOME/'R15_RELEASE_PROOF.json').read_text(encoding='utf-8'))
assert proof['total_clips']==90 and proof['total_slots']==802
print('FS_TB_R15_FINAL_FULL_NATIVE_PRIVATE_RELEASE_PASS',proof['release_name'],proof['sha256'],flush=True)
