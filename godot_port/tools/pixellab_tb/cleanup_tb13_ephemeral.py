#!/usr/bin/env python3
"""Cleanup ONLY ephemeral R13 produced files after private Drive R13 ZIP hash readback."""
import os,hashlib,zipfile,shutil
from pathlib import Path
T=Path(os.environ['TEMP'])
D=Path('G:/')/'.shortcut-targets-by-id'/'10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'
ZIP=D/'FS_TB_R13_TWO_FAMILIES_9_ACTION_ART_FACTORY_PRIVATE_20261122.zip'
EXPECTED='eebd4d0e1bb12252d8ae1bea8fef87227ce7b9719a71f0da1539b19ea79492d7'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert ZIP.is_file() and ZIP.stat().st_size==3984990 and sha(ZIP)==EXPECTED
with zipfile.ZipFile(ZIP) as z: assert len(z.namelist())==190 and z.testzip() is None
for basename in ('R13_BAT_3STAGE_STUN_TAUNT_ANIMATED_REVIEW.gif','R13_FROG_3STAGE_STUN_TAUNT_ANIMATED_REVIEW.gif','R13_PROVIDER_JOB_LEDGER.json','R13_GODOT472_NATIVE_QA.log','R13_NEW_CLIP_TECH_QA.json','R13_ZIP_RELEASE_PROOF.json'):
    assert (D/basename).is_file() and (D/basename).stat().st_size>50,basename
assert (T/'fs_tb13_staging').is_dir()
removed=[]
for dirname in ('fs_tb13_staging',):
    p=T/dirname
    if p.is_dir():shutil.rmtree(p);removed.append(dirname)
for filename in ('fs_tb13_release_pending.zip','tb13_build.py','tb13_release_finalize.py','tb13_animated_review.py'):
    p=T/filename
    if p.is_file():p.unlink();removed.append(filename)
for root,slug,stem in ((T/'fs_tb_r10_tmp','bat','BAT_STAGE'),(T/'fs_tb11_tmp','frog','PMD000')):
    assert root.is_dir() and root.name in ('fs_tb_r10_tmp','fs_tb11_tmp')
    for fn in root.iterdir():
        name=fn.name.upper()
        if fn.is_file() and ((name.startswith('BAT_STAGE') or name.startswith('PMD000')) and ('_STUN_' in name or '_TAUNT_' in name)):
            fn.unlink();removed.append(fn.name)
    fn=root/('tb13_bat_stun_taunt_provider.py' if slug=='bat' else 'tb13_frog_stun_taunt_provider.py')
    if fn.is_file():fn.unlink();removed.append(fn.name)
    fn=root/('R13_BAT_PROVIDER_JOBS.json' if slug=='bat' else 'R13_FROG_PROVIDER_JOBS.json')
    if fn.is_file():fn.unlink();removed.append(fn.name)
assert not (T/'fs_tb13_staging').exists()
assert (D/'FS_TB_R13_TWO_FAMILIES_9_ACTION_ART_FACTORY_PRIVATE_20261122.zip').is_file()
print('R13_CLEANUP_COMPLETE ephemeral_files_removed=',len(removed),'cloud_sha256=',sha(ZIP),'drive_folder_preserved=True')
