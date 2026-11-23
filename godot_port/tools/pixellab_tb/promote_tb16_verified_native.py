#!/usr/bin/env python3
"""Promote Forest Symphony T-B R16 exact, already-tested M1v2 sprites to formal Drive ZIP.

Requires byte-for-byte official Windows Bridge Godot 4.7.2 log and the exact SHA-locked
M1v2 ZIP; does NOT claim this container ran Godot. No raster recomposition in promotion.
"""
from __future__ import annotations
import argparse,hashlib,json,zipfile,io,sys
from pathlib import Path

M1_SHA='6491d333bc4a56c89a542849074e5054df4ff22b9e1b39c1fd0a2324cfdd31d1'
LOG_SHA='65b50d830d2430678c7f92c4c26bb62690091021bb303a3fa5a5dd0810239ce7'
MARKER='FS_TB_R16_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=87 evolutions=6 clips=93 frames=838 frost_revive=3'
OUT_NAME='FS_TB_R16_FROST_KO_REVIVE_NATIVE_VERIFIED_PRIVATE_20261123.zip'

def sha(data:bytes)->str:return hashlib.sha256(data).hexdigest()

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--m1-zip',required=True)
    p.add_argument('--native-log',required=True)
    p.add_argument('--out-zip',required=True)
    p.add_argument('--proof',required=True)
    a=p.parse_args()
    source=Path(a.m1_zip)
    official=Path(a.native_log)
    final=Path(a.out_zip)
    proof_path=Path(a.proof)
    assert source.exists() and sha(source.read_bytes())==M1_SHA
    data=official.read_bytes()
    assert sha(data)==LOG_SHA and len(data)==539
    log=data.decode('utf-8-sig')
    for match in (MARKER,'EditorExitCode=0','ArtTestExitCode=0',
                  'Version=4.7.2.stable.official.ed1daf0bf',
                  'SourceSHA256='+M1_SHA,
                  'ArchiveEntries=385',
                  'VisualHumanArt=OWNER_REVIEW_PENDING',
                  'CombatIntegration=NOT_RUN_ART_ONLY'):
        assert match in log,('Native Windows Bridge log missing exact success attestation',match)
    assert not final.exists(),'Never overwrite an existing formal Drive release artifact.'
    with zipfile.ZipFile(source) as z:
        assert z.testzip() is None and len(z.namelist())==385
        keys=z.namelist()
        record={k:z.read(k) for k in keys if not k.endswith('/')}
        # original manifest and source assets must remain byte-identical except the new
        # current R16 manifest, to which official independent native evidence is attached.
        prev=json.loads(record['godot/TB16_MONSTER_FAMILY_MANIFEST.json'])
        assert prev['technical_qa']=='NATIVE_NOT_RUN'
        assert prev['clip_count']==93 and prev['total_frames']==838
        prev['technical_qa']='NATIVE_4_7_2_WINDOWS_VERIFIED'
        prev['official_windows_godot_version']='4.7.2.stable.official.ed1daf0bf'
        prev['native_proof_source_m1_zip_sha256']=M1_SHA
        prev['native_proof_log_sha256']=LOG_SHA
        prev['native_issue_url']='https://github.com/showpei1203/chatgpt-pc-bridge/issues/80'
        prev['native_actions_run']='https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45101707739'
        prev['human_art_gate']='OWNER_ART_REVIEW_PENDING'
        prev['integration_qa']='NOT_RUN_ART_ONLY'
        prev['storage_status']='DRIVE_PUBLICATION_PENDING_AT_PROMOTION_BUILD'
        record['godot/TB16_MONSTER_FAMILY_MANIFEST.json']=json.dumps(prev,ensure_ascii=False,indent=2).encode('utf-8')
        record['reports/R16_M2_WINDOWS_GODOT472_NATIVE_QA_20261123.log']=data
        result={
            'kind':'FS_TB_R16_NATIVE_GODOT_ATTESTATION',
            'original_M1v2_zip_sha256':M1_SHA,
            'source_immutable_r15p_zip_sha256':'a8088f4e76e3f63d7b9a58857213d138ecb2e43a5af92547f4b2222f77fd04f7',
            'Windows_Godot_native_log_sha256':LOG_SHA,
            'official_version':'4.7.2.stable.official.ed1daf0bf',
            'source_stages':3,'source_original_ko_clips':3,'new_source_retimed_revive_clips':3,
            'new_actual_PixelLab_provider_jobs':0,'new_generation_usage':0,
            'frame_total':838,'motion_atlas_total':87,'evolution_atlas_total':6,'total_clips':93,
            'native_test_marker':MARKER,
            'bridge_issue':'https://github.com/showpei1203/chatgpt-pc-bridge/issues/80',
            'bridge_actions':'https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45101707739',
            'security_negative_issue':'https://github.com/showpei1203/chatgpt-pc-bridge/issues/79',
            'source':'PASS','structure':'PASS','Godot_native':'PASS',
            'visual_art':'OWNER_ART_REVIEW_PENDING','combat_integration':'NOT_RUN',
            'archive_promotion_no_sprite_pixel_changes':True
        }
        record['reports/R16_M2_SOURCE_AND_NATIVE_VERIFIED_RELEASE.json']=json.dumps(result,ensure_ascii=False,indent=2).encode('utf-8')
    # Confirm no prior PNG raster changed and no prior original sprites were removed.
    original_images={n:b for n,b in record.items() if n.lower().endswith('.png')}
    assert len(original_images)>80
    with zipfile.ZipFile(source) as src:
        for name,b in original_images.items():
            assert sha(src.read(name))==sha(b),('private original pixel mutation',name)
    with zipfile.ZipFile(final,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as out:
        for name in sorted(record):out.writestr(name,record[name])
    with zipfile.ZipFile(final) as z:
        assert z.testzip() is None
        assert len(z.namelist())==387
        now=json.loads(z.read('godot/TB16_MONSTER_FAMILY_MANIFEST.json'))
        assert now['technical_qa']=='NATIVE_4_7_2_WINDOWS_VERIFIED'
        assert z.read('reports/R16_M2_WINDOWS_GODOT472_NATIVE_QA_20261123.log')==data
        for name in original_images:
            assert sha(z.read(name))==sha(original_images[name])
    proof={
        'file_name':OUT_NAME,'bytes':final.stat().st_size,'sha256':sha(final.read_bytes()),
        'entry_count':387,'CRC':'PASS','original_M1v2_sha256':M1_SHA,
        'official_Windows_Godot_proof_SHA256':LOG_SHA,'native':'PASS',
        'M1_source':'PASS','M2_native':'PASS','M3_art_blocker':'KO_F7_VERIFIED_ORIGINAL_F0_F7',
        'M4_other_stages':'STAGE1_STAGE2_STAGE3_ALL_PRODUCED',
        'visual_owner_approval':'PENDING','combat':'NOT_RUN_ART_ONLY',
        'PixelLab_generation_new':0,'three_frost_revives':3,'total_clips':93,'total_frames':838,
        'PC_Bridge_security_negative':'https://github.com/showpei1203/chatgpt-pc-bridge/issues/79',
        'PC_Bridge_native_positive':'https://github.com/showpei1203/chatgpt-pc-bridge/issues/80'
    }
    proof_path.write_text(json.dumps(proof,ensure_ascii=False,indent=2),encoding='utf-8')
    assert json.loads(proof_path.read_text(encoding='utf-8'))==proof
    print('FS_TB_R16_PROMOTED_NATIVE_VERIFIED_ARCHIVE_PASS',json.dumps(proof,ensure_ascii=False))
    return 0
if __name__=='__main__':sys.exit(main())