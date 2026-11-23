#!/usr/bin/env python3
"""FS T-B R18 | Promote 3 real 12F RUN from original owner-private M1 after
independent official Windows Godot 4.7.2 native QA; ZERO PixelLab API calls.
Preserve all real/original PNG and raw provider archives byte-for-byte.
"""
from pathlib import Path
import json,hashlib,zipfile,copy
B=Path('/mnt/data')
SRC=B/'FS_TB_R18_3STAGE_RUN_12F_M1_GODOT_NATIVE_HOLD_20261123.zip'
OLD=B/'FS_TB_R17_GLACIER_JACKAL_3GUARD_NATIVE_VERIFIED_PRIVATE_20261123.zip'
LOG=B/'R18_M2_WINDOWS_GODOT472_RUN_QA_20261123.log.txt'
OUT=B/'FS_TB_R18_GLACIER_JACKAL_3RUN_12F_NATIVE_VERIFIED_PRIVATE_20261123.zip'
PROOF=B/'FS_TB_R18_NATIVE_VERIFIED_RELEASE_PROOF_20261123.json'
SRC_SHA='7cecc170615a205c30ed28efa0c1d19887f8782aeb5d73784a4b52cbd200e40e'
R17_SHA='d7e8d8b168e8f4553ba735972d1fb573f1439d3850aedb1c2dd5bd30b6e581ad'
LOG_SHA='58ac2673eac5311d09f6fb9443ed5a13f418c5f853bb23ae3d35671be255afb3'
MARK='FS_TB_R18_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=93 evolutions=6 clips=99 frames=898 frost_run=3'
sha=lambda b:hashlib.sha256(b).hexdigest()
def main():
    assert SRC.stat().st_size==12625007 and sha(SRC.read_bytes())==SRC_SHA
    assert sha(OLD.read_bytes())==R17_SHA
    assert LOG.stat().st_size==585 and sha(LOG.read_bytes())==LOG_SHA
    assert not OUT.exists() and not PROOF.exists(),'Do not overwrite formal owner-private release'
    log=LOG.read_text(encoding='utf-8-sig')
    for required in (MARK,'Version=4.7.2.stable.official.ed1daf0bf','SourceSHA256='+SRC_SHA,
      'ArchiveEntries=446','EditorExitCode=0','ArtTestExitCode=0',
      'RealPixelLabRUNJobs=3','ActualPixelLabReportedGenerations=15.0; OriginalJobs=3',
      'VisualHumanArt=OWNER_REVIEW_PENDING','CombatIntegration=NOT_RUN_ART_ONLY'):
        assert required in log,('missing actual native attestation',required)
    assert 'SCRIPT ERROR:' not in log and 'PARSER ERROR:' not in log
    with zipfile.ZipFile(SRC) as z, zipfile.ZipFile(OLD) as prior:
        assert len(z.namelist())==446 and z.testzip() is None
        assert len(prior.namelist())==430 and prior.testzip() is None
        original={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
        manifest=json.loads(original['godot/TB18_MONSTER_FAMILY_MANIFEST.json'])
        assert (manifest['clip_count'],manifest['total_frames'],manifest['baseline_clip_count'])==(99,898,93)
        assert manifest['technical_qa']=='NATIVE_NOT_RUN'
        assert manifest['source_r17_zip_sha256']==R17_SHA
        assert manifest['new_provider_generations']==15.0
        assert manifest['new_pixel_lab_jobs']==3
        assert sum(len(st['motions']) for fm in manifest['families'] for st in fm['stages'])==93
        assert all(len(st['motions'])==7 for st in manifest['families'][2]['stages'])
        for name in prior.namelist():
            if name.lower().endswith('.png'):
                assert z.read(name)==prior.read(name),('original R17 PNG changed',name)
        for st in manifest['families'][2]['stages']:
            m=st['motions']['run']
            assert sha(z.read('godot/'+m['path']))==m['sha256']
            assert m['frames']==12 and m['columns']==4
        # Native proof must not mutate existing art. All raster preserved literally.
        manifest.update(technical_qa='NATIVE_4_7_2_WINDOWS_VERIFIED',
            official_windows_godot_version='4.7.2.stable.official.ed1daf0bf',
            native_m1_source_sha256=SRC_SHA,native_log_sha256=LOG_SHA,
            native_issue_url='https://github.com/showpei1203/chatgpt-pc-bridge/issues/98',
            native_actions_run='https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45116388305',
            human_art_gate='OWNER_ART_REVIEW_PENDING',integration_qa='NOT_RUN_ART_ONLY',
            storage_status='OWNER_PRIVATE_DRIVE_RELEASE_PENDING_AT_FINAL_ASSEMBLY')
        original['godot/TB18_MONSTER_FAMILY_MANIFEST.json']=json.dumps(manifest,ensure_ascii=False,indent=2).encode('utf8')
        original['reports/R18_M2_WINDOWS_GODOT472_RUN_QA_20261123.log']=LOG.read_bytes()
        official={
            'kind':'FS_TB_R18_OFFICIAL_REAL_PIXELLAB_3_STAGE_RUN_NATIVE_GODOT472',
            'original_r17_sha256':R17_SHA,'original_new_r18_m1_sha256':SRC_SHA,
            'true_windows_native_log_sha256':LOG_SHA,
            'true_native_issue':'https://github.com/showpei1203/chatgpt-pc-bridge/issues/98',
            'true_native_actions':'https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45116388305',
            'native_marker':MARK,'real_PixelLab_jobs':3,'real_provider_generations':15.0,
            'new_provider_jobs_during_promotion':0,'new_images_generated_during_promotion':0,
            'new_run_clips':3,'new_run_frames':36,'total_clips':99,'total_frame_slots':898,
            'native_editor_import':'PASS','native_independent_sprite_scene':'PASS',
            'owner_art_acceptance':'PENDING','gameplay_integration':'NOT_RUN_ART_ONLY',
            'preexisting_image_bytes_changed':False,
        }
        original['reports/R18_M2_OFFICIAL_NATIVE_EVIDENCE.json']=json.dumps(official,ensure_ascii=False,indent=2).encode('utf8')
    with zipfile.ZipFile(OUT,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n in sorted(original):z.writestr(n,original[n])
    with zipfile.ZipFile(OUT) as z,zipfile.ZipFile(SRC) as m1:
        assert z.testzip() is None and len(z.namelist())==448
        assert z.read('reports/R18_M2_WINDOWS_GODOT472_RUN_QA_20261123.log')==LOG.read_bytes()
        after=json.loads(z.read('godot/TB18_MONSTER_FAMILY_MANIFEST.json'))
        assert after['technical_qa']=='NATIVE_4_7_2_WINDOWS_VERIFIED' and after['native_log_sha256']==LOG_SHA
        for n in m1.namelist():
            if n.lower().endswith('.png') or n.startswith('reports/r18_provider_raw/'):
                assert z.read(n)==m1.read(n),('original paid art/raw archive changed',n)
    proof={
        'artifact':OUT.name,'sha256':sha(OUT.read_bytes()),'bytes':OUT.stat().st_size,'entries':448,
        'ZIP_CRC':'PASS','native_log_sha256':LOG_SHA,'M1_SHA256':SRC_SHA,
        'pixelLab_jobs':3,'generations_reported':15.0,'promotion_provider_jobs':0,
        'new_run_clips':3,'new_frames':36,'total_clips':99,'total_frames':898,
        'Godot_4_7_2_native':'PASS','owner_visual_art':'PENDING','combat_integration':'NOT_RUN',
        'original_r17_and_new_r18_source_image_bytes_preserved':True}
    PROOF.write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf8')
    print('FS_TB_R18_NATIVE_FORMAL_PRIVATE_PROMOTION_PASS',json.dumps(proof,ensure_ascii=False))
if __name__=='__main__':main()