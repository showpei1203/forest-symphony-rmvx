from pathlib import Path
import glob,shutil,hashlib,json,zipfile,subprocess,sys
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A46_INTEGRATED_TORSO_ATTACK_20261115'
zipfile_path=root/'FS_A46_GODOT_CONNECTED_TORSO_NATIVE_GPU_PASS_ART_HOLD_20261115.zip'
tmp=Path('C:/Users/Public/FS_A46_RELEASE_COLD_TMP')
bintmp=Path('C:/Users/Public/FS_A46_BIN_COLD_TMP')
result={'archive_sha256':hashlib.sha256(zipfile_path.read_bytes()).hexdigest(),
 'test':'A46 V2 clean archive extraction + source regeneration + native Godot GPU & contact'}
for folder in [tmp,bintmp]:
 if folder.exists():shutil.rmtree(folder)
 folder.mkdir(parents=True)
try:
 with zipfile.ZipFile(zipfile_path) as z:
  assert z.testzip() is None
  names=z.namelist()
  z.extractall(tmp)
  result['files']=len(names)
 m=json.loads((tmp/'A46_FULL_SHA256_MANIFEST.json').read_text(encoding='utf8'))
 mismatched=[n for n,sha in m['files'].items() if not (tmp/n).is_file() or hashlib.sha256((tmp/n).read_bytes()).hexdigest()!=sha]
 result['source_sha_mismatches']=len(mismatched)
 assert not mismatched
 print('A46_ZIP_MANIFEST_PASS',result['files'],len(m['files']),flush=True)
 original={n:hashlib.sha256((tmp/'assets'/('actor01_a46_'+n+'_12frames.png')).read_bytes()).hexdigest() for n in ['body','weapon','fx']}
 regen=subprocess.run([sys.executable,str(tmp/'qa/a46_rebuild_verify.py')],capture_output=True,encoding='utf8',errors='replace',timeout=35)
 (p/'qa/A46_ZIP_COLD_REGEN_LOG.txt').write_text(regen.stdout+'\n'+regen.stderr,encoding='utf8')
 assert regen.returncode==0 and 'A46_SOURCE_REGEN_DETERMINISTIC_PASS' in regen.stdout
 after={n:hashlib.sha256((tmp/'assets'/('actor01_a46_'+n+'_12frames.png')).read_bytes()).hexdigest() for n in ['body','weapon','fx']}
 assert original==after
 result['art_source_reproducible']=True
 sourcebin=Path(glob.glob('E:/Godot/4.7.2/*')[0])
 for bf in sourcebin.glob('*.exe'):shutil.copyfile(bf,bintmp/bf.name)
 exe=str(next(bintmp.glob('*console.exe')))
 for name,cmd,expected in [
  ('IMPORT',[exe,'--headless','--path',str(tmp),'--editor','--import'],None),
  ('GPU',[exe,'--path',str(tmp),'--rendering-method','gl_compatibility','--script','res://qa/a46_native_gpu_runtime_qa.gd'],'A46_QA_RESULT PASS'),
  ('CONTACT',[exe,'--path',str(tmp),'--rendering-method','gl_compatibility','--script','res://qa/a46_contact_damage_native_qa.gd'],'A46_CONTACT_QA_RESULT PASS')
 ]:
  print('A46_ZIP_'+name+'_START',flush=True)
  r=subprocess.run(cmd,capture_output=True,encoding='utf8',errors='replace',timeout=75)
  output=r.stdout+'\nSTDERR\n'+r.stderr
  (p/'qa'/('A46_ZIP_COLD_'+name+'_LOG.txt')).write_text(output,encoding='utf8')
  ok=r.returncode==0 and (expected is None or expected in output)
  result[name.lower()+'_exit']=r.returncode
  result[name.lower()+'_pass']=ok
  print('A46_ZIP_'+name+'_RESULT',ok,r.returncode,flush=True)
  if not ok:raise RuntimeError('zip cold '+name+' FAIL '+output[-800:].encode('ascii','replace').decode('ascii'))
 q=tmp/'qa/a46_waist_gate.py'
 for name,img,expected_exit,additional in [
  ('BASELINE',tmp/'assets/actor01_a62_approved_idle_source_64.png',0,[]),
  ('NEGATIVE',tmp/'assets/actor01_a45_body_12frames.png',1,[]),
  ('A46',tmp/'assets/actor01_a46_body_12frames.png',0,['--native-dir',str(tmp/'qa/output/a46')])
 ]:
  cmd=[sys.executable,str(q),'--reference',str(tmp/'assets/actor01_a62_approved_idle_source_64.png'),'--candidate',str(img)]+additional
  r=subprocess.run(cmd,capture_output=True,encoding='utf8',errors='replace',timeout=25)
  assert r.returncode==expected_exit,(name,r.returncode,r.stdout,r.stderr)
  result['waist_gate_'+name]=r.returncode
  print('A46_ZIP_WAIST_'+name, 'PASS-EXPECTED' if r.returncode==expected_exit else 'FAIL',flush=True)
 result['status']='PASS'
except Exception as exc:
 result['status']='FAIL'
 result['reason']=str(exc)
 print('A46_ZIP_FAILURE',str(exc).encode('ascii','replace').decode('ascii'),flush=True)
finally:
 (p/'qa/A46_ZIP_COLD_QA_RECEIPT.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf8')
 shutil.rmtree(tmp,ignore_errors=True)
 shutil.rmtree(bintmp,ignore_errors=True)
 print('A46_ZIP_COLD_RECEIPT',json.dumps(result),flush=True)
