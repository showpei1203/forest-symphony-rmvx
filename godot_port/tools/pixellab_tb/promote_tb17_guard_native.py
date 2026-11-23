#!/usr/bin/env python3
"""Promote already paid and restored 3 Guard v3 PixelLab assets only after exact
independent Windows Godot 4.7.2 native test. ZERO provider calls, immutable raster.
"""
import hashlib,zipfile,json
from pathlib import Path
B=Path('/mnt/data')
SRC=B/'FS_TB_R17_GUARD_M1_RECOVERED_NATIVE_HOLD_20261123.zip'
LOG=B/'R17_M2_WINDOWS_GODOT472_GUARD_QA_20261123.log.txt'
OUT=B/'FS_TB_R17_GLACIER_JACKAL_3GUARD_NATIVE_VERIFIED_PRIVATE_20261123.zip'
PROOF=B/'FS_TB_R17_NATIVE_VERIFIED_RELEASE_PROOF_20261123.json'
EXPECTED_SOURCE='649632b8f384a34c8053bb66ad13a9644017dc3806c74b7a8460037a853ad693'
EXPECTED_LOG='e3e350e5e66ad7df9d494f6552ed02ccac67851dbd6852df14e725669f8ec368'
MARK='FS_TB_R17_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=90 evolutions=6 clips=96 frames=862 frost_guard=3'
sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha(SRC.read_bytes())==EXPECTED_SOURCE
assert sha(LOG.read_bytes())==EXPECTED_LOG and LOG.stat().st_size==599
text=LOG.read_text(encoding='utf-8-sig')
for word in (MARK,'Version=4.7.2.stable.official.ed1daf0bf','SourceSHA256='+EXPECTED_SOURCE,
             'ArchiveEntries=428','EditorExitCode=0','ArtTestExitCode=0',
             'RealPixelLabGuardJobs=3','ActualPixelLabReportedGenerations=11.0',
             'VisualHumanArt=OWNER_REVIEW_PENDING','CombatIntegration=NOT_RUN_ART_ONLY'):
    assert word in text,word
assert not OUT.exists()
with zipfile.ZipFile(SRC) as z:
    assert z.testzip() is None and len(z.namelist())==428
    record={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
    M=json.loads(record['godot/TB17_MONSTER_FAMILY_MANIFEST.json'])
    assert M['technical_qa']=='NATIVE_NOT_RUN'
    assert (M['clip_count'],M['total_frames'],M['baseline_clip_count'])==(96,862,90)
    assert M['source_r16_zip_sha256']=='a3292f8e9ce94648f8a9d61bb22271a4d3d3f92fc02f132fb18c5278e92d9efe'
    M.update(technical_qa='NATIVE_4_7_2_WINDOWS_VERIFIED',
        official_windows_godot_version='4.7.2.stable.official.ed1daf0bf',
        native_source_m1_zip_sha256=EXPECTED_SOURCE,
        native_log_sha256=EXPECTED_LOG,
        native_issue_url='https://github.com/showpei1203/chatgpt-pc-bridge/issues/91',
        native_actions_run='https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45112146277',
        human_art_gate='OWNER_ART_REVIEW_PENDING',
        integration_qa='NOT_RUN_ART_ONLY')
    record['godot/TB17_MONSTER_FAMILY_MANIFEST.json']=json.dumps(M,ensure_ascii=False,indent=2).encode('utf-8')
    record['reports/R17_M2_WINDOWS_GODOT472_GUARD_QA_20261123.log']=LOG.read_bytes()
    witness={'artifact':'R17_RECOVERED_GENUINE_PIXEL_LAB_THREE_STAGE_GUARD_NATIVE',
      'source_original_m1_sha256':EXPECTED_SOURCE,
      'source_real_paid_hold_sha256':'4845398136e7f11202af6b059a85f1dc7f68450d5d8eb229fdbe8177aa61baa0',
      'native_log_sha256':EXPECTED_LOG,'engine':'4.7.2.stable.official.ed1daf0bf',
      'positive_issue':'https://github.com/showpei1203/chatgpt-pc-bridge/issues/91',
      'positive_actions':'https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45112146277',
      'negative_security_issue':'https://github.com/showpei1203/chatgpt-pc-bridge/issues/90',
      'real_pixel_lab_jobs':3,'real_pixel_lab_generations':11.0,
      'provider_jobs_during_recovery':0,'provider_cost_during_recovery':0,
      'new_guards':3,'new_guard_frames':24,
      'total_clips':96,'total_frame_slots':862,
      'source':'PASS','native_engine':'PASS','art':'OWNER_REVIEW_PENDING',
      'gameplay_integration':'NOT_RUN_ART_ONLY','source_png_bytes_modified':False}
    record['reports/R17_OFFICIAL_NATIVE_PASS_EVIDENCE.json']=json.dumps(witness,ensure_ascii=False,indent=2).encode('utf-8')
with zipfile.ZipFile(OUT,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for n in sorted(record):z.writestr(n,record[n])
with zipfile.ZipFile(OUT) as final,zipfile.ZipFile(SRC) as original:
    assert final.testzip() is None and len(final.namelist())==430
    assert final.read('reports/R17_M2_WINDOWS_GODOT472_GUARD_QA_20261123.log')==LOG.read_bytes()
    for name in original.namelist():
        if name.lower().endswith('.png'):
            assert sha(original.read(name))==sha(final.read(name)),name
    old=json.loads(final.read('godot/TB17_MONSTER_FAMILY_MANIFEST.json'))
    assert old['native_log_sha256']==EXPECTED_LOG and old['clip_count']==96 and old['total_frames']==862
proof={'name':OUT.name,'sha256':sha(OUT.read_bytes()),'bytes':OUT.stat().st_size,'entries':430,
       'zip_crc':'PASS','native_marker':MARK,'native_log_sha256':EXPECTED_LOG,
       'source_m1_sha256':EXPECTED_SOURCE,'pixel_png_unmodified':True,
       'genuine_pixel_lab_jobs':3,'generations':11.0,'recovery_new_generations':0,
       'new_guards':3,'total_clips':96,'total_frames':862,
       'godot_native':'PASS','owner_art':'PENDING','battle_integration':'NOT_RUN'}
PROOF.write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf-8')
print('FS_TB_R17_OFFICIAL_NATIVE_PRIVATE_PROMOTION_PASS',json.dumps(proof,ensure_ascii=False))