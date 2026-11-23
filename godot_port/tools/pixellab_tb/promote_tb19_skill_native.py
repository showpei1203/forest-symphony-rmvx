#!/usr/bin/env python3
"""Promote verified R19 three authentic PixelLab 12F ICE SKILL animations.
No API calls; only exact already tested R19 M1v2 and official Windows Godot 4.7.2 log.
Preserves every image/raw original byte and marks non-loop skill semantics.
"""
from __future__ import annotations
import argparse,hashlib,zipfile,json
from pathlib import Path
M1_SHA='bbabc2d4b2c39513f2b014d59916923892c78c34c23707fbf0b47e9b425c6108'
R18_SHA='8cc85ea1ca326ce854b3432a46c63fb311aaba3ca5628d101e10a54fc03cae6c'
MARK='FS_TB_R19_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=96 evolutions=6 clips=102 frames=934 frost_skill=3'
ENGINE='4.7.2.stable.official.ed1daf0bf'
ISSUE='https://github.com/showpei1203/chatgpt-pc-bridge/issues/106'
RUN='https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/45130577116'
def sha(b):return hashlib.sha256(b).hexdigest()
def write_json(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf-8')
def promote(m1:Path,logfile:Path,final:Path,proof:Path):
    assert not final.exists() and not proof.exists(),'Refuse release overwrite'
    assert m1.stat().st_size==13922230 and sha(m1.read_bytes())==M1_SHA
    raw=logfile.read_bytes();log=raw.decode('utf-8-sig');logsha=sha(raw)
    for word in (MARK,'Version='+ENGINE,'SourceSHA256='+M1_SHA,'ArchiveEntries=464',
                 'EditorExitCode=0','ArtTestExitCode=0','RealPixelLabSKILLJobs=3',
                 'ActualPixelLabReportedGenerations=15.0; OriginalJobs=3',
                 'VisualHumanArt=OWNER_REVIEW_PENDING','CombatIntegration=NOT_RUN_ART_ONLY'):
        assert word in log,('real Windows native attestation absent',word)
    assert not any(x in log for x in ('SCRIPT ERROR:','PARSER ERROR:','ERROR:'))
    with zipfile.ZipFile(m1) as z:
        assert z.testzip() is None and len(z.namelist())==464
        records={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
        old=json.loads(records['godot/TB19_MONSTER_FAMILY_MANIFEST.json'])
        assert old['technical_qa']=='NATIVE_NOT_RUN'
        assert (old['clip_count'],old['total_frames'],old['baseline_clip_count'])==(102,934,96)
        assert old['source_r18_zip_sha256']==R18_SHA and old['new_provider_generations']==15.0
        assert old['new_pixel_lab_jobs']==3
        assert sum(len(s['motions']) for f in old['families'] for s in f['stages'])==96
        frost=next(f for f in old['families'] if f['kind']=='frost')
        assert all(len(st['motions'])==8 and 'skill' in st['motions'] for st in frost['stages'])
        for st in frost['stages']:
            m=st['motions']['skill']
            assert not m['loop'] and m['frames']==12 and m['columns']==4
            assert sha(records['godot/'+m['path']])==m['sha256']
        # Assert the independent Godot script really asserts non-loop semantics.
        script=records['godot/tests/test_tb19_frost_skill_native.gd'].decode('utf-8')
        assert 'get_animation_loop("skill")' in script and MARK in script
        for n in z.namelist():
            if n.lower().endswith('.png') or n.lower().endswith('.gif') or n.startswith('reports/r19_provider_raw/'):
                assert records[n]==z.read(n)
        old.update(technical_qa='NATIVE_4_7_2_WINDOWS_VERIFIED',
            official_windows_godot_version=ENGINE,
            native_m1_source_sha256=M1_SHA,native_log_sha256=logsha,
            native_issue_url=ISSUE,native_actions_run=RUN,
            human_art_gate='OWNER_ART_REVIEW_PENDING',
            integration_qa='NOT_RUN_ART_ONLY')
        records['godot/TB19_MONSTER_FAMILY_MANIFEST.json']=json.dumps(old,ensure_ascii=False,indent=2).encode('utf-8')
        records['reports/R19_M2_WINDOWS_GODOT472_SKILL_QA_20261123.log']=raw
        records['reports/R19_M2_OFFICIAL_NATIVE_EVIDENCE.json']=json.dumps({
            'kind':'FS_TB_R19_ORIGINAL_3STAGE_SKILL_OFFICIAL_WINDOWS_GODOT472',
            'm1_source_sha256':M1_SHA,'native_log_sha256':logsha,'native_marker':MARK,
            'godot_version':ENGINE,'native_issue':ISSUE,'native_actions':RUN,
            'true_PixelLab_jobs':3,'true_provider_generations':15.0,
            'new_paid_jobs_during_native_promotion':0,'new_skill_clips':3,'new_exported_frames':36,
            'total_clips':102,'total_frame_slots':934,
            'source_and_atlas_preservation':'PASS','editor_import':'PASS','native_skill_test':'PASS',
            'human_visual_art':'OWNER_ART_REVIEW_PENDING','combat_integration':'NOT_RUN_ART_ONLY'
        },ensure_ascii=False,indent=2).encode('utf-8')
    with zipfile.ZipFile(final,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n in sorted(records):z.writestr(n,records[n])
    with zipfile.ZipFile(final) as z,zipfile.ZipFile(m1) as origin:
        assert z.testzip() is None and len(z.namelist())==466
        assert z.read('reports/R19_M2_WINDOWS_GODOT472_SKILL_QA_20261123.log')==raw
        for name in origin.namelist():
            if name.lower().endswith(('.png','.gif')) or name.startswith('reports/r19_provider_raw/'):
                assert z.read(name)==origin.read(name),('provider/older image mutation',name)
        current=json.loads(z.read('godot/TB19_MONSTER_FAMILY_MANIFEST.json'))
        assert current['native_log_sha256']==logsha and current['technical_qa']=='NATIVE_4_7_2_WINDOWS_VERIFIED'
    evidence={'name':final.name,'sha256':sha(final.read_bytes()),'bytes':final.stat().st_size,
              'entries':466,'crc':'PASS','m1_source_sha256':M1_SHA,'native_log_sha256':logsha,
              'engine':ENGINE,'native_issue':ISSUE,'native_actions':RUN,'PixelLab_jobs':3,
              'reported_generations':15.0,'promote_new_jobs':0,'new_ice_skill_clips':3,
              'new_exported_frames':36,'total_clips':102,'total_frames':934,
              'godot_native':'PASS','owner_art':'PENDING','battle_integration':'NOT_RUN',
              'original_r18_and_new_r19_png_bytes_preserved':True}
    write_json(proof,evidence)
    print('FS_TB_R19_SKILL_NATIVE_FORMAL_PRIVATE_PROMOTION_PASS',json.dumps(evidence,ensure_ascii=False))
    return evidence

def main():
    p=argparse.ArgumentParser()
    for a in ('m1','native-log','out','proof'):p.add_argument('--'+a,required=True,type=Path)
    a=p.parse_args();promote(a.m1,a.native_log,a.out,a.proof)
if __name__=='__main__':main()