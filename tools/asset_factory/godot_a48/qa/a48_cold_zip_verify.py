from pathlib import Path
import glob,shutil,hashlib,json,zipfile,subprocess,sys
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A48_CONNECTED_ARM_PIXEL_POSES_20261115'
archive=root/'FS_A48_CONNECTED_SWORD_ARM_NATIVE_GODOT_ART_HOLD_20261115.zip'
temp=Path('C:/Users/Public/FS_A48_ZIP_COLD_TEMP')
bintmp=Path('C:/Users/Public/FS_A48_BIN_COLD_TEMP')
result={'stage':'A48','zip_sha256':hashlib.sha256(archive.read_bytes()).hexdigest()}
for path in [temp,bintmp]:
 if path.exists():shutil.rmtree(path,ignore_errors=True)
 path.mkdir(parents=True)
try:
 with zipfile.ZipFile(archive) as z:
  assert z.testzip() is None
  z.extractall(temp)
  result['zip_files']=len(z.namelist())
 manifest=json.loads((temp/'A48_RELEASE_SHA_MANIFEST.json').read_text(encoding='utf8'))
 errors=[name for name,expected in manifest['sha256'].items()
        if not(temp/name).is_file() or hashlib.sha256((temp/name).read_bytes()).hexdigest()!=expected]
 result['sha_mismatches']=len(errors)
 assert not errors
 print('A48_COLD_SHA_PASS',len(manifest['sha256']),flush=True)
 for script,marker in [
  ('a48_connected_arm_generator.py','A48_R1_BUILT'),
  ('a48_joint_connectivity_qa.py','A48_R1_CONNECTION_QA True'),
  ('a48_anatomical_bone_qa.py','A48_BONE_COVERAGE_QA True A47_negative True')]:
  r=subprocess.run([sys.executable,str(temp/'qa'/script)],capture_output=True,text=True,errors='replace',timeout=40)
  correct=r.returncode==0 and marker in r.stdout
  print('A48_COLD_SCRIPT',script,correct,flush=True)
  if not correct:raise RuntimeError(script+' '+r.stdout[-450:]+' '+r.stderr[-250:])
 raw_sha=hashlib.sha256((temp/'assets/actor01_a48_body_R1_12frames.png').read_bytes()).hexdigest()
 final_sha=hashlib.sha256((temp/'assets/actor01_a48_body_12frames.png').read_bytes()).hexdigest()
 result['rebuild_sha_match']=raw_sha==final_sha
 assert result['rebuild_sha_match']
 binroot=Path(glob.glob('E:/Godot/4.7.2/*')[0])
 for file in binroot.glob('*.exe'):shutil.copyfile(file,bintmp/file.name)
 exe=str(next(bintmp.glob('*console.exe')))
 for name,cmd,expected in [
  ('IMPORT',[exe,'--headless','--path',str(temp),'--editor','--import'],None),
  ('GPU',[exe,'--path',str(temp),'--rendering-method','gl_compatibility','--script','res://qa/a48_native_gpu_runtime_qa.gd'],'A48_QA_RESULT PASS'),
  ('CONTACT',[exe,'--path',str(temp),'--rendering-method','gl_compatibility','--script','res://qa/a48_contact_damage_native_qa.gd'],'A48_CONTACT_QA_RESULT PASS')]:
  print('A48_COLD_GODOT_'+name+'_START',flush=True)
  r=subprocess.run(cmd,capture_output=True,text=True,errors='replace',timeout=90)
  output=r.stdout+'\nSTDERR\n'+r.stderr
  (p/'qa'/('A48_COLD_'+name+'_LOG.txt')).write_text(output,encoding='utf8')
  correct=r.returncode==0 and (expected is None or expected in output)
  result[name.lower()+'_exit']=r.returncode
  if not correct:raise RuntimeError(name+': '+output[-1000:].encode('ascii','replace').decode('ascii'))
  print('A48_COLD_GODOT_'+name+'_PASS',flush=True)
 gate=temp/'qa/a48_waist_gate.py'
 ref=temp/'assets/actor01_a62_approved_idle_source_64.png'
 for name,candidate,expected,extra in [
  ('A62',ref,0,[]),
  ('A45',temp/'assets/actor01_a45_body_12frames.png',1,[]),
  ('A48',temp/'assets/actor01_a48_body_12frames.png',0,['--native-dir',str(temp/'qa/output/a48')])]:
  r=subprocess.run([sys.executable,str(gate),'--candidate',str(candidate),'--reference',str(ref)]+extra,
    capture_output=True,text=True,errors='replace',timeout=30)
  result['waist_'+name+'_exit']=r.returncode
  assert r.returncode==expected,(name,r.stdout,r.stderr)
  print('A48_COLD_WAIST_'+name+'_EXPECTED',expected,flush=True)
 result['status']='PASS'
except Exception as ex:
 result['status']='FAIL'
 result['failure']=str(ex)
 print('A48_COLD_FAILURE',str(ex).encode('ascii','replace').decode('ascii'),flush=True)
finally:
 (p/'qa/A48_COLD_ZIP_QA_RECEIPT.json').write_text(json.dumps(result,indent=2),encoding='utf8')
 shutil.rmtree(temp,ignore_errors=True)
 shutil.rmtree(bintmp,ignore_errors=True)
 print('A48_COLD_FINISHED',json.dumps(result),flush=True)
