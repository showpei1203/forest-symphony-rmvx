from pathlib import Path
import glob,json,hashlib,zipfile,shutil,subprocess,sys
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A47_MOTION_LINKED_ATTACK_20261115'
z=root/'FS_A47_R3_JOINT_KINEMATIC_NATIVE_COLDPASS_20261115.zip'
work=Path('C:/Users/Public/FS_A47_ZIP_COLD_TEMP')
bindir=Path('C:/Users/Public/FS_A47_GODOT_BIN_TEMP')
rec={'stage':'A47','zip_sha':hashlib.sha256(z.read_bytes()).hexdigest()}
for x in [work,bindir]:
 if x.exists():shutil.rmtree(x)
 x.mkdir(parents=True)
try:
 with zipfile.ZipFile(z) as arc:
  assert arc.testzip() is None
  arc.extractall(work)
  rec['file_count']=len(arc.namelist())
 manifest=json.loads((work/'A47_FULL_SHA256_MANIFEST.json').read_text(encoding='utf8'))
 errors=[name for name,expected in manifest['files'].items()
         if not (work/name).is_file() or hashlib.sha256((work/name).read_bytes()).hexdigest()!=expected]
 rec['source_SHA_mismatch_count']=len(errors)
 assert not errors,errors
 print('A47_ARCHIVE_SHA_PASS',rec['file_count'],len(manifest['files']),flush=True)
 original={layer:hashlib.sha256((work/'assets'/('actor01_a47_'+layer+'_12frames.png')).read_bytes()).hexdigest()
  for layer in ['body','weapon','fx']}
 for label,py,marker in [
  ('GENERATE','a47_joint_warp_generation.py','A47_2_VARIANTS_RENDERED'),
  ('CANDIDATES','a47_independent_variant_qa.py','A47_VARIANT_QA R3 PASS True'),
  ('PROMOTE','a47_promote_winner.py','A47_R3_PROMOTED_AS_CANDIDATE')]:
  run=subprocess.run([sys.executable,str(work/'qa'/py)],capture_output=True,text=True,errors='replace',timeout=50)
  assert run.returncode==0 and marker in run.stdout,(label,run.stdout[-300:],run.stderr[-300:])
  print('A47_ARCHIVE_'+label+'_PASS',flush=True)
 after={layer:hashlib.sha256((work/'assets'/('actor01_a47_'+layer+'_12frames.png')).read_bytes()).hexdigest()
  for layer in ['body','weapon','fx']}
 rec['image_rebuild_SHA_equal']=original==after
 assert rec['image_rebuild_SHA_equal']
 src_bin=Path(glob.glob('E:/Godot/4.7.2/*')[0])
 for binary in src_bin.glob('*.exe'):shutil.copyfile(binary,bindir/binary.name)
 exe=str(next(bindir.glob('*console.exe')))
 for label,args,marker in [
  ('EDITOR',[exe,'--headless','--path',str(work),'--editor','--import'],None),
  ('GPU',[exe,'--path',str(work),'--rendering-method','gl_compatibility','--script','res://qa/a47_native_gpu_runtime_qa.gd'],'A47_QA_RESULT PASS'),
  ('CONTACT',[exe,'--path',str(work),'--rendering-method','gl_compatibility','--script','res://qa/a47_contact_damage_native_qa.gd'],'A47_CONTACT_QA_RESULT PASS')]:
  print('A47_COLD_'+label+'_START',flush=True)
  run=subprocess.run(args,capture_output=True,text=True,errors='replace',timeout=90)
  output=run.stdout+'\nSTDERR\n'+run.stderr
  (p/'qa'/('A47_ZIP_COLD_'+label+'_LOG.txt')).write_text(output,encoding='utf8')
  passed=run.returncode==0 and (marker is None or marker in output)
  rec['native_'+label.lower()+'_exit']=run.returncode
  print('A47_COLD_'+label+'_PASS',passed,'EXIT',run.returncode,flush=True)
  if not passed:raise RuntimeError(label+' test failed: '+output[-750:].encode('ascii','replace').decode('ascii'))
 ref=work/'assets/actor01_a62_approved_idle_source_64.png'
 checks=[('A62',ref,0,[]),('A45',work/'assets/actor01_a45_body_12frames.png',1,[]),
 ('A47',work/'assets/actor01_a47_body_12frames.png',0,['--native-dir',str(work/'qa/output/a47')])]
 for label,candidate,expected,extra in checks:
  run=subprocess.run([sys.executable,str(work/'qa/a47_waist_gate.py'),'--reference',str(ref),'--candidate',str(candidate)]+extra,
  capture_output=True,text=True,errors='replace',timeout=20)
  assert run.returncode==expected,(label,run.stdout,run.stderr)
  rec['waist_'+label]=run.returncode
  print('A47_COLD_WAIST_'+label+'_EXPECTED',run.returncode,flush=True)
 rec['status']='PASS'
except Exception as err:
 rec['status']='FAIL'
 rec['error']=str(err)
 print('A47_COLD_ERROR',str(err).encode('ascii','replace').decode('ascii'),flush=True)
finally:
 (p/'qa/A47_ZIP_COLD_RECEIPT.json').write_text(json.dumps(rec,indent=2),encoding='utf8')
 shutil.rmtree(work,ignore_errors=True)
 shutil.rmtree(bindir,ignore_errors=True)
 print('A47_COLD_RECEIPT',json.dumps(rec),flush=True)
