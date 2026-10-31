from pathlib import Path
import json,urllib.request,time,hashlib,traceback,shutil
root=Path(r'E:\FS_ROUTE_B_STAGE16_A09_TEXTURE_SCALE_20261031')
a05=Path(r'E:\FS_ROUTE_B_STAGE16_A05_MASKED_INPAINT_20261031')
ui=Path(r'E:\FS_ROUTE_B_STAGE16_A03_REFERENCE_CONDITIONING_20261031\ComfyUI_v0340')
w=json.loads((a05/'A05_R3_ROAD_NO_IPADAPTER_WORKFLOW.json').read_text())
w['12']['inputs']['image']='A09_SYNTHETIC_MATERIAL_PRIOR_384.png'
w['5']['inputs'].update({'steps':6,'denoise':.28,'seed':160406})
w['7']['inputs']['filename_prefix']='A09_BASE_SAMPLER_MINIMAL_RAW'
w['17']['inputs']['filename_prefix']='A09_BASE_SAMPLER_MINIMAL_COMPOSITE'
(root/'A09_ISOLATED_MINIMAL_SAMPLER_GRAPH.json').write_text(json.dumps(w,indent=2))
report={'test':'A09 isolated SD15 KSampler low-denoise 6steps no active IPAdapter or ControlNet','result':'NOT_RUN','denoise':.28,'steps':6,'seed':160406,'formal_seal':'NO'}
try:
 api='http://127.0.0.1:8230'
 req=urllib.request.Request(api+'/prompt',data=json.dumps({'prompt':w,'client_id':'a09-lowdenoise-sampler-isolation'}).encode(),headers={'Content-Type':'application/json'},method='POST')
 p=json.load(urllib.request.urlopen(req,timeout=20));assert p.get('prompt_id') and not p.get('node_errors'),p
 report['result']='QUEUED';report['prompt_id']=p['prompt_id'];print('A09_MIN_KSAMPLER_QUEUED',p,flush=True)
 start=time.monotonic()
 while time.monotonic()-start<140:
  hist=json.load(urllib.request.urlopen(api+'/history/'+p['prompt_id'],timeout=12))
  if p['prompt_id'] in hist:
   rec=hist[p['prompt_id']]
   outputs=rec.get('outputs',{}).get('17',{}).get('images',[])
   if outputs:
    report['result']='PASS_BASE_SAMPLER_PNG'
    name=outputs[0]['filename'];src=ui/'output'/name;shutil.copy2(src,root/'A09_MINIMAL_SAMPLER_OUTPUT.png')
    report['sha256']=hashlib.sha256(src.read_bytes()).hexdigest()
    break
   if rec.get('status',{}).get('status_str')=='error':
    report['result']='FAIL_MODEL';report['server_error']=rec['status'];break
  time.sleep(.8)
 if report['result']=='QUEUED':report['result']='TIMEOUT'
 report['elapsed_s']=round(time.monotonic()-start,2)
except Exception as e:
 report['result']='FAIL_CONNECTION_OR_NATIVE_CRASH';report['error']=repr(e);report['traceback']=traceback.format_exc()[-1800:]
(root/'A09_MINIMAL_SAMPLER_QA.json').write_text(json.dumps(report,indent=2))
print('A09_MIN_KSAMPLER_FINAL',json.dumps(report)[:2000],flush=True)
