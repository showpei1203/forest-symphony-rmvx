#!/usr/bin/env python3
"""R21 three genuine source-locked PixelLab TAUNT 8F official Godot 4.7.2 promoter.
No paid provider calls, no changes to prior or current real PNG/GIF/source zip bytes.
"""
from pathlib import Path
import argparse,hashlib,json,zipfile
MARK='FS_TB_R21_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=102 evolutions=6 clips=108 frames=982 frost_taunt=3'
ENGINE='4.7.2.stable.official.ed1daf0bf'
BASE_SHA='99ef8ab4e12239f32dfbf9573035b149834ac0bcd48243c09ff4b15b69a34b2a'
ISSUE_BASE='https://github.com/showpei1203/chatgpt-pc-bridge/issues/'
RUN_BASE='https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/'
def sha(b):return hashlib.sha256(b).hexdigest()
def js(x):return json.dumps(x,indent=2,ensure_ascii=False).encode('utf-8')
def promote(m1,log,out,proof,expected_m1_sha,issue,run):
 assert not out.exists() and not proof.exists(),'Refuse final existing/overwrite'
 assert len(expected_m1_sha)==64 and issue.startswith(ISSUE_BASE) and run.startswith(RUN_BASE)
 base=m1.read_bytes();raw=log.read_bytes();txt=raw.decode('utf-8-sig')
 assert sha(base)==expected_m1_sha and len(base)>14871599,'M1 source SHA/size mismatch'
 with zipfile.ZipFile(m1) as z:
  assert z.testzip() is None and len(z.namelist())==500
  source={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
  m=json.loads(source['godot/TB21_MONSTER_FAMILY_MANIFEST.json'])
  assert (m['clip_count'],m['total_frames'],m['baseline_clip_count'])==(108,982,102)
  assert m['source_r20_zip_sha256']==BASE_SHA and m['technical_qa']=='NATIVE_NOT_RUN'
  assert m['new_pixel_lab_jobs']==3 and m['integration_qa']=='NOT_RUN_ART_ONLY'
  assert sum(len(s['motions']) for f in m['families'] for s in f['stages'])==102
  cost=float(m['new_provider_generations']);assert 0<cost<=36
  f=next(f for f in m['families'] if f['kind']=='frost')
  assert len(f['stages'])==3
  for st in f['stages']:
   assert len(st['motions'])==10
   action=st['motions']['taunt'];assert action['frames']==8 and action['columns']==4 and action['loop'] is False
   assert sha(source['godot/'+action['path']])==action['sha256']
  code=source['godot/tests/test_tb21_frost_taunt_native.gd'].decode('utf-8')
  assert 'get_animation_loop("taunt")' in code and MARK in code
  for term in (MARK,'Version='+ENGINE,'SourceSHA256='+expected_m1_sha,'ArchiveEntries=500',
    'EditorExitCode=0','ArtTestExitCode=0','RealPixelLabTAUNTJobs=3',
    'ActualPixelLabReportedGenerations='+str(cost),'VisualHumanArt=OWNER_REVIEW_PENDING',
    'CombatIntegration=NOT_RUN_ART_ONLY'):
   assert term in txt,('Actual native evidence missing',term)
  assert not any(t in txt for t in ('SCRIPT ERROR:','PARSER ERROR:','ERROR:'))
  m.update(technical_qa='NATIVE_4_7_2_WINDOWS_VERIFIED',official_windows_godot_version=ENGINE,
    native_m1_source_sha256=expected_m1_sha,native_log_sha256=sha(raw),native_issue_url=issue,
    native_actions_run=run,human_art_gate='OWNER_ART_REVIEW_PENDING',integration_qa='NOT_RUN_ART_ONLY')
  source['godot/TB21_MONSTER_FAMILY_MANIFEST.json']=js(m)
  source['reports/R21_M2_WINDOWS_GODOT472_TAUNT_QA_20261124.log']=raw
  source['reports/R21_M2_OFFICIAL_NATIVE_EVIDENCE.json']=js({
    'kind':'R21_THREE_STAGE_GENUINE_PIXEL_LAB_TAUNT_NATIVE_GODOT472',
    'm1_source_sha256':expected_m1_sha,'native_log_sha256':sha(raw),'engine':ENGINE,
    'native_marker':MARK,'native_issue':issue,'native_actions':run,
    'provider_jobs':3,'actual_reported_generations':cost,'promotion_new_paid_jobs':0,
    'new_taunt_clips':3,'new_taunt_frames':24,'total_clips':108,'total_slots':982,
    'native_test':'PASS','owner_visual_art':'OWNER_ART_REVIEW_PENDING',
    'main_gameplay_integration':'NOT_RUN_ART_ONLY'})
 with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  for n in sorted(source):z.writestr(n,source[n])
 with zipfile.ZipFile(out) as z,zipfile.ZipFile(m1) as prior:
  assert z.testzip() is None and len(z.namelist())==502
  for n in prior.namelist():
   if n.lower().endswith(('.png','.gif')) or n.startswith('reports/r21_provider_raw/'):
    assert z.read(n)==prior.read(n),('source image/raw mutation',n)
  assert z.read('reports/R21_M2_WINDOWS_GODOT472_TAUNT_QA_20261124.log')==raw
  final_manifest=json.loads(z.read('godot/TB21_MONSTER_FAMILY_MANIFEST.json'))
  assert final_manifest['technical_qa']=='NATIVE_4_7_2_WINDOWS_VERIFIED'
 final={'name':out.name,'sha256':sha(out.read_bytes()),'bytes':out.stat().st_size,
   'entries':502,'zip_crc':'PASS','m1_sha256':expected_m1_sha,'native_log_sha256':sha(raw),
   'native_engine':ENGINE,'provider_jobs':3,'provider_generations':cost,'promotion_extra_jobs':0,
   'total_clips':108,'total_frames':982,'new_taunt_clips':3,'new_taunt_frames':24,
   'native_qa':'PASS','owner_art':'OWNER_ART_REVIEW_PENDING','game_integration':'NOT_RUN_ART_ONLY',
   'all_png_gif_provider_bytes_preserved':True,'issue':issue,'actions':run}
 proof.write_bytes(js(final))
 print('FS_TB_R21_FINAL_NATIVE_PRIVATE_PROMOTION_PASS',json.dumps(final,ensure_ascii=False))
 return final
if __name__=='__main__':
 p=argparse.ArgumentParser()
 for k in ('m1','log','out','proof'):p.add_argument('--'+k,required=True,type=Path)
 for k in ('m1-sha','issue','run'):p.add_argument('--'+k,required=True)
 a=p.parse_args();promote(a.m1,a.log,a.out,a.proof,a.m1_sha,a.issue,a.run)