from pathlib import Path
import glob,shutil,hashlib,json,subprocess,sys
p=Path(__file__).resolve().parents[1];a=p/'assets';qa=p/'qa'
src=qa/'a46_independent_kinetic_qa.py'
if src.is_file():
 t=src.read_text(encoding='utf8')
 old="body=Image.open(assets/'actor01_a46_body_12frames.png').convert('RGBA')"
 new="body=Image.open(assets/'actor01_a46_body_v1_12frames.png').convert('RGBA')"
 assert old in t
 t=t.replace(old,new)
 t=t.replace("qa/A46_INDEPENDENT_KINETIC_QA.json","qa/A46_V1_INDEPENDENT_KINETIC_QA.json")
 (qa/'a46_v1_independent_kinetic_qa.py').write_text(t,encoding='utf8')
 src.unlink()
def sha(b):return hashlib.sha256(b.read_bytes()).hexdigest()
preserved={n:sha(a/('actor01_a46_'+n+'_12frames.png')) for n in ['body','weapon','fx']}
tests=[
 ('V1',qa/'a46_body_v1_candidate.py','A46_RECONSTRUCT_V1_DONE'),
 ('V2',qa/'a46_coherent_spine_lean_candidate.py','A46_V2_LEAN_CANDIDATE'),
 ('V1_QA',qa/'a46_v1_independent_kinetic_qa.py','A46_INDEPENDENT_KINETIC_PASS'),
 ('V2_QA',qa/'a46_v2_motion_qa.py','A46_V2_MOTION_QA_PASS')]
results={}
for name,f,marker in tests:
 run=subprocess.run([sys.executable,str(f)],capture_output=True,text=True,errors='replace',timeout=30)
 okay=run.returncode==0 and marker in run.stdout
 results[name]={'exit':run.returncode,'pass':okay,'log':run.stdout[-550:]}
 if not okay:raise RuntimeError('REBUILD_FAIL_'+name+' '+str(run.stderr)[-900:])
for n in ['body','weapon','fx']:
 new=sha(a/('actor01_a46_'+n+'_v2_12frames.png'))
 assert preserved[n]==new,(n,preserved[n],new)
result={'stage':'A46','reproducible_v1_v2':True,'original_main_sha256':preserved,'checks':results,
 'pass':'PASS','caution':'Remains ART HOLD for human review; tests only prove reproducibility, geometry and known waist defect'}
(qa/'A46_REPRODUCTION_RESULT.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf8')
print('A46_SOURCE_REGEN_DETERMINISTIC_PASS',preserved,flush=True)
