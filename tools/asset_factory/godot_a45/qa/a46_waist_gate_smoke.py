from pathlib import Path
import subprocess,sys,json
p=Path(__file__).resolve().parents[1]
qa=p/'qa'
gate=qa/'a46_waist_gate.py'
assert gate.is_file(),gate
ref=p/'assets/actor01_a62_approved_idle_source_64.png'
base=['--reference',str(ref)]
def run(label,candidate,expected_exit,native_dir=None):
 cmd=[sys.executable,str(gate),'--candidate',str(candidate)]+base
 if native_dir:cmd+=['--native-dir',str(native_dir)]
 cmd+=['--report',str(qa/('A46_'+label+'_GATE_RESULT.json'))]
 r=subprocess.run(cmd,capture_output=True,text=True,errors='replace',timeout=30)
 print('A46_CHECK',label,'exit',r.returncode,'expected',expected_exit,r.stdout[-800:],flush=True)
 assert r.returncode==expected_exit,(label,r.stderr,r.stdout)
 result=json.loads((qa/('A46_'+label+'_GATE_RESULT.json')).read_text(encoding='utf8'))
 return {'exit':r.returncode,'gate':result['gate'],
  'fail_frames':result['failing_frames'],
  'native_fail_frames':result.get('native_gpu_crosscheck',{}).get('fail_frames',[])}
results={
 'A62_approved_positive':run('A62_BASELINE',ref,0),
 'A44_known_bad':run('A44_EXPECTED_FAIL',p/'assets/actor01_a44_body_12frames.png',1),
 'A45_known_bad':run('A45_EXPECTED_FAIL',p/'assets/actor01_a45_body_12frames.png',1,qa/'output/a45')
}
assert results['A45_known_bad']['fail_frames']==['F06','F07','F08']
assert results['A45_known_bad']['native_fail_frames']==['F06','F07','F08']
(qa/'A46_KNOWN_BAD_GATE_SMOKE.json').write_text(json.dumps({'validation':'PASS','results':results},indent=2),encoding='utf8')
print('A46_GATE_KNOWN_GOOD_BAD_VALIDATION_PASS',json.dumps(results),flush=True)
