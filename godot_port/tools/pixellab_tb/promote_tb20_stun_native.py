#!/usr/bin/env python3
"""Promote already paid original 3-stage R20 PixelLab STUN only after exact official
Windows Godot 4.7.2 independent test; no new provider calls or raster mutations.
"""
from pathlib import Path
import argparse,hashlib,json,zipfile
MARK='FS_TB_R20_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=99 evolutions=6 clips=105 frames=958 frost_stun=3'
ENGINE='4.7.2.stable.official.ed1daf0bf'
SRC_SHA='c2e9dd7a05a8d4027eebc506693c3931c1566ac963efdfb900300cb286b42f0a'
ISSUE='https://github.com/showpei1203/chatgpt-pc-bridge/issues/REPLACE_ME_WITH_NATIVE_ISSUE'
RUN='https://github.com/showpei1203/chatgpt-pc-bridge/actions/runs/REPLACE_ME_WITH_NATIVE_RUN'
def sha(x):return hashlib.sha256(x).hexdigest()
def js(x):return json.dumps(x,ensure_ascii=False,indent=2).encode()
def promote(m1,log,out,proof,issue,run):
 assert not out.exists() and not proof.exists()
 base=m1.read_bytes();lograw=log.read_bytes();txt=lograw.decode('utf-8-sig');hashbase=sha(base)
 with zipfile.ZipFile(m1) as z:
  assert z.testzip() is None and len(z.namelist())==482
  original={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
  man=json.loads(original['godot/TB20_MONSTER_FAMILY_MANIFEST.json'])
  assert man['technical_qa']=='NATIVE_NOT_RUN'
  assert (man['clip_count'],man['total_frames'],man['baseline_clip_count'])==(105,958,99)
  assert man['source_r19_zip_sha256']==SRC_SHA and man['new_pixel_lab_jobs']==3
  assert sum(len(s['motions']) for f in man['families'] for s in f['stages'])==99
  cost=float(man['new_provider_generations'])
  assert cost>0
  for st in next(f for f in man['families'] if f['kind']=='frost')['stages']:
   assert len(st['motions'])==9
   m=st['motions']['stun']
   assert m['frames']==8 and m['columns']==4 and m['loop'] is False
   assert sha(original['godot/'+m['path']])==m['sha256']
  script=original['godot/tests/test_tb20_frost_stun_native.gd'].decode()
  assert 'get_animation_loop("stun")' in script and MARK in script
  for required in [MARK,'Version='+ENGINE,'SourceSHA256='+hashbase,'ArchiveEntries=482',
       'EditorExitCode=0','ArtTestExitCode=0','RealPixelLabSTUNJobs=3',
       'ActualPixelLabReportedGenerations='+str(cost),
       'VisualHumanArt=OWNER_REVIEW_PENDING','CombatIntegration=NOT_RUN_ART_ONLY']:
   assert required in txt,('Native evidence did not match',required)
  assert not any(s in txt for s in ['SCRIPT ERROR:','PARSER ERROR:','ERROR:'])
  man.update(technical_qa='NATIVE_4_7_2_WINDOWS_VERIFIED',
       official_windows_godot_version=ENGINE,native_m1_source_sha256=hashbase,
       native_log_sha256=sha(lograw),native_issue_url=issue,native_actions_run=run,
       human_art_gate='OWNER_ART_REVIEW_PENDING',integration_qa='NOT_RUN_ART_ONLY')
  original['godot/TB20_MONSTER_FAMILY_MANIFEST.json']=js(man)
  original['reports/R20_M2_WINDOWS_GODOT472_STUN_QA_20261124.log']=lograw
  original['reports/R20_M2_OFFICIAL_NATIVE_EVIDENCE.json']=js({
       'kind':'R20_THREE_STAGE_REAL_PIXELLAB_UPRIGHT_STUN_NATIVE_GODOT472',
       'm1_sha256':hashbase,'native_log_sha256':sha(lograw),
       'godot_version':ENGINE,'native_marker':MARK,'issue_url':issue,'actions_url':run,
       'actual_provider_jobs':3,'actual_generations':cost,'promotion_provider_jobs':0,
       'new_stun_clips':3,'new_stun_frames':24,'total_clips':105,'total_slots':958,
       'source_and_raw_png_bytes_unchanged':True,'native_qa':'PASS',
       'owner_art':'OWNER_ART_REVIEW_PENDING','gameplay_integration':'NOT_RUN_ART_ONLY'})
 with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  for n in sorted(original):z.writestr(n,original[n])
 with zipfile.ZipFile(out) as z,zipfile.ZipFile(m1) as old:
  assert z.testzip() is None and len(z.namelist())==484
  for n in old.namelist():
   if n.lower().endswith(('.png','.gif')) or n.startswith('reports/r20_provider_raw/'):
    assert z.read(n)==old.read(n),('pixel mutation',n)
  assert z.read('reports/R20_M2_WINDOWS_GODOT472_STUN_QA_20261124.log')==lograw
 evid={'name':out.name,'sha256':sha(out.read_bytes()),'bytes':out.stat().st_size,'entries':484,
       'zip_crc':'PASS','m1_sha256':hashbase,'native_log_sha256':sha(lograw),
       'native_engine':ENGINE,'provider_jobs':3,'provider_generations':cost,'extra_jobs':0,
       'total_clips':105,'total_frames':958,'native_qa':'PASS','art':'OWNER_ART_REVIEW_PENDING',
       'game_integration':'NOT_RUN_ART_ONLY','original_pngs_unchanged':True,
       'issue':issue,'actions':run}
 proof.write_bytes(js(evid));print('FS_TB_R20_FINAL_NATIVE_PRIVATE_PROMOTION_PASS',json.dumps(evid))
 return evid
if __name__=='__main__':
 ap=argparse.ArgumentParser()
 for k in ('m1','log','out','proof'):ap.add_argument('--'+k,required=True,type=Path)
 for k in ('issue','run'):ap.add_argument('--'+k,required=True)
 a=ap.parse_args();promote(a.m1,a.log,a.out,a.proof,a.issue,a.run)