#!/usr/bin/env python3
"""R15/R15P safe owner device cleanup, AFTER private Drive complete metadata verification.
Exact allowlist of R15/R15P %TEMP% only. Preserve all R10-R14 originals and private G: Drive.
"""
import json,zipfile,hashlib,shutil,os
from pathlib import Path
T=Path(os.environ['TEMP'])
D=Path('G:/')/'.shortcut-targets-by-id'/'10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'
assert D.is_dir(), 'Private Drive not mounted'
ZIP=[
 ('FS_TB_R15_REVIVE_REPAIRS_AND_THIRD_FROST_JACKAL_PRIVATE_20261122.zip',
  '5cd880690a13181ae9a5cb4b1a82ab453263d1969ca9f991c550c9bdcd968f6c',9302874,354),
 ('FS_TB_R15P_FROG_REVIVE_SOURCE_SAFE_ART_REVIEW_PRIVATE_20261122.zip',
  'a8088f4e76e3f63d7b9a58857213d138ecb2e43a5af92547f4b2222f77fd04f7',9643175,373),
]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for name,h,size,n in ZIP:
    f=D/name
    assert f.is_file() and f.stat().st_size==size and sha(f)==h
    with zipfile.ZipFile(f) as z:
        assert z.testzip() is None and len(z.namelist())==n,(name,len(z.namelist()))
        if 'R15_REVIVE' in name:
            # Ensure original rejected PixelLab art and actual billed usage saved before temp delete.
            assert 'reports/R15_REJECTED_PROVIDER_QA.json' in z.namelist()
            assert any(x.startswith('reports/R15_REJECTED_ART/') and x.endswith('.png') for x in z.namelist())
        if 'R15P_FROG' in name:
            assert 'godot/TB15P_MONSTER_FAMILY_MANIFEST.json' in z.namelist()
            assert 'reports/R15P_SOURCE_RETIMED_FROG_QA.json' in z.namelist()
for proof in ('R15_RELEASE_PROOF.json','R15P_RELEASE_PROOF.json'):
    p=D/proof
    assert p.is_file(),proof
    report=json.loads(p.read_text(encoding='utf-8'))
    if proof.startswith('R15P'):
        assert report['clips']==90 and report['frames']==805
    else:
        assert report['total_clips']==90 and report['total_slots']==802
for n in ('R15_FROST_JACKAL_3STAGE_FOUR_ACTIONS_CONTACT.png',
          'R15_BAT_REVIVE_R14_VS_R15_CONTACT.png','R15_FROG_REVIVE_R14_VS_R15_CONTACT.png',
          'R15P_FROG_3STAGE_SOURCE_SAFE_VS_R15_FLAME_CONTACT.png',
          'R15_GODOT_NATIVE_TEST.log','R15P_GODOT_NATIVE_TEST.log'):
    f=D/n
    assert f.is_file() and f.stat().st_size>70,n
# exact allowed paths only; never wildcard delete an unknown directory, never remove Drive.
directories=['fs_tb15_provider','fs_tb15_staging','fs_tb15p_staging']
files=['fs_tb15_pending_upload.zip','fs_tb15p_upload_tmp.zip',
       'fs_tb15_provider.py','fs_tb15_builder.py','fs_tb15p_frog_safe.py',
       'fs_tb15_native_orchestrator.py','fs_tb15_release_process.log']
removed=[]
for name in directories:
    f=T/name
    assert f.parent.resolve()==T.resolve() and f.name==name
    if f.is_dir():shutil.rmtree(f);removed.append(name)
for name in files:
    f=T/name
    assert f.parent.resolve()==T.resolve() and f.name==name
    if f.is_file():f.unlink();removed.append(name)
# An actual read-back AFTER cleanup is the P0 evidence gate.
for name,h,size,n in ZIP:
    assert sha(D/name)==h
    with zipfile.ZipFile(D/name) as z:assert z.testzip() is None and len(z.namelist())==n
print('FS_TB_R15_R15P_P0_TEMP_CLEANUP_VERIFIED removed_items=',len(removed),
      'names=',removed,'source_R10_R14_PRESERVED=TRUE owner_private_ZIP_SHA_CRC_RECHECK=PASS',flush=True)
