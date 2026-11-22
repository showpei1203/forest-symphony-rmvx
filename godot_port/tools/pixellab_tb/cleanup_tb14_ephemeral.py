#!/usr/bin/env python3
"""Remove only the explicitly R14-generated Windows TEMP files, after private Drive readback.
Original R10/R11/R12/R13 sources and private G: folder are preserved.
"""
import json,hashlib,zipfile,shutil,os
from pathlib import Path
T=Path(os.environ['TEMP'])
D=Path('G:/')/'.shortcut-targets-by-id'/'10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'
proof=D/'R14_RELEASE_PROOF.json'
assert proof.is_file(),'Not yet synced to Drive'
m=json.loads(proof.read_text(encoding='utf-8'))
assert m['total_clips']==76 and m['total_frames']==680 and m['new_pixel_lab_jobs']==18 and m['new_provider_generations']==54
zpath=D/m['release_name']
assert zpath.is_file() and zpath.stat().st_size==m['bytes']
sha=lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(zpath)==m['sha256']
with zipfile.ZipFile(zpath) as z:
    assert z.testzip() is None and len(z.namelist())==m['zip_file_count']
for n in ('R14_PROVIDER_JOB_LEDGER.json','R14_GODOT_NATIVE_QA.log','R14_NEW_MOTION_AND_EVOLUTION_QA.json','TB14_MONSTER_FAMILY_MANIFEST.json'):
    assert (D/n).is_file() and (D/n).stat().st_size>80
removed=[]
for d in ('fs_tb14_provider','fs_tb14_staging'):
    p=T/d
    assert p.name in ('fs_tb14_provider','fs_tb14_staging')
    if p.is_dir():shutil.rmtree(p);removed.append(d)
for name in ('fs_tb14_upload_pending.zip','fs_tb14_provider.py','fs_tb14_release.py','fs_tb14_finalize.py','fs_tb14_release_native.log'):
    p=T/name
    if p.is_file():p.unlink();removed.append(name)
assert sha(zpath)==m['sha256']
print('FS_TB_R14_P0_EPHEMERAL_CLEANUP_PASS',len(removed),'named outputs; R10-R13 preserved; private ZIP SHA256',m['sha256'],flush=True)
