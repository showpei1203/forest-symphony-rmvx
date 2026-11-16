from pathlib import Path
import os, glob,shutil,subprocess,json,hashlib
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
source=root/'FS_A47_MOTION_LINKED_ATTACK_20261115'
temp=Path('C:/Users/Public/FS_A47_NATIVE_QA_TEMP')
# Godot 4.7.2 executable on E: stalls during process startup.
# Copy BOTH GUI binary and 198KB console wrapper to ephemeral C: first.
source_exe_dir=Path(glob.glob('E:/Godot/4.7.2/*')[0])
exec_tmp=Path('C:/Users/Public/FS_A47_GODOT_TEMP_BIN')
exec_tmp.mkdir(exist_ok=True)
for original in source_exe_dir.glob('*.exe'):
 shutil.copyfile(original,exec_tmp/original.name)
exe=str(next(exec_tmp.glob('*console.exe')))
reports=source/'qa'
result={'stage':'A47','source':'private Drive integrated torso candidate','native_Godot':'4.7.2',
 'candidate_body_sha256':hashlib.sha256((source/'assets/actor01_a47_body_12frames.png').read_bytes()).hexdigest()}
if temp.exists():shutil.rmtree(temp)
temp.mkdir()
def ignore(d,names):
 return [n for n in names if n in {'.godot','__pycache__'} or n.endswith('.import') or n.endswith('.zip') or n.startswith('A44_') or n.startswith('A43_')]
shutil.copytree(source,temp,dirs_exist_ok=True,ignore=ignore)
print('A47_TEMP_COPIED',len([f for f in temp.rglob('*') if f.is_file()]),flush=True)
try:
 for label,cmd,tout,mark in [
  ('IMPORT',[exe,'--headless','--path',str(temp),'--editor','--import'],90,None),
  ('GPU',[exe,'--path',str(temp),'--rendering-method','gl_compatibility','--script','res://qa/a47_native_gpu_runtime_qa.gd'],75,'A47_QA_RESULT PASS'),
  ('CONTACT',[exe,'--path',str(temp),'--rendering-method','gl_compatibility','--script','res://qa/a47_contact_damage_native_qa.gd'],75,'A47_CONTACT_QA_RESULT PASS')
 ]:
  print('A47_'+label+'_START',flush=True)
  r=subprocess.run(cmd,capture_output=True,encoding='utf8',errors='replace',timeout=tout)
  output=r.stdout+'\nSTDERR\n'+r.stderr
  (reports/('A47_'+label+'_NATIVE_LOG.txt')).write_text(output,encoding='utf8')
  valid=r.returncode==0 and (mark is None or mark in output)
  result[label.lower()+'_exit']=r.returncode
  result[label.lower()+'_pass']=valid
  print('A47_'+label+'_RESULT',valid,'EXIT',r.returncode,'TAIL',output[-1350:].encode('ascii','replace').decode('ascii'),flush=True)
  if not valid: raise RuntimeError(label+' exit='+str(r.returncode)+':'+output[-1600:].encode('ascii','replace').decode('ascii'))
 native=temp/'qa/output/a47'
 source_native=source/'qa/output/a47'
 source_native.mkdir(parents=True,exist_ok=True)
 for f in native.glob('A47_NATIVE_*.png'):shutil.copyfile(f,source_native/f.name)
 result['native_screenshot_count']=len(list(source_native.glob('A47_NATIVE_F??.png')))
 result['contact_screenshot']=bool((source_native/'A47_NATIVE_DAMAGE_CONTACT_SCENE.png').exists())
 assert result['native_screenshot_count']==12
 assert result['contact_screenshot']
 import sys
 gate=temp/'qa/a47_waist_gate.py'
 canonical=temp/'assets/actor01_a62_approved_idle_source_64.png'
 cases=[('A62',temp/'assets/actor01_a62_approved_idle_source_64.png',0),
        ('A45',temp/'assets/actor01_a45_body_12frames.png',1),
        ('A47',temp/'assets/actor01_a47_body_12frames.png',0)]
 for name,candidate,expected in cases:
  cmd=[sys.executable,str(gate),'--candidate',str(candidate),'--reference',str(canonical)]
  if name=='A47':cmd+=['--native-dir',str(native)]
  run=subprocess.run(cmd,capture_output=True,encoding='utf8',errors='replace',timeout=20)
  print('A47_WAIST_GATE_'+name,run.returncode,run.stdout.strip(),flush=True)
  result['waist_'+name+'_exit']=run.returncode
  if run.returncode!=expected:raise RuntimeError(name+' was expected exit '+str(expected))
 result['status']='PASS'
except Exception as e:
 result['status']='FAIL'
 result['reason']=str(e)
 print('A47_NATIVE_FAIL',str(e).encode('ascii','replace').decode('ascii'),flush=True)
finally:
 (reports/'A47_NATIVE_COLD_QA_RESULT.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf8')
 shutil.rmtree(temp,ignore_errors=True)
 shutil.rmtree(exec_tmp,ignore_errors=True)
 print('A47_COLD_NATIVE_RECEIPT',json.dumps(result),flush=True)
