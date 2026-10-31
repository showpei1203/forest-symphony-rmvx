from pathlib import Path
import json,urllib.request,time,hashlib,traceback,shutil
root=Path(r'E:\FS_ROUTE_B_STAGE16_A09_TEXTURE_SCALE_20261031')
base=Path(r'E:\FS_ROUTE_B_STAGE16_A08_COMBINED_CONTROL_20261031')
ui=Path(r'E:\FS_ROUTE_B_STAGE16_A03_REFERENCE_CONDITIONING_20261031\ComfyUI_v0340')
graph=json.loads((base/'A08_CONTROLLED_COMBINED_WORKFLOW.json').read_text())
assert graph['5']['inputs']['latent_image']==['14',0]
graph['12']['inputs']['image']='A09_SYNTHETIC_MATERIAL_PRIOR_384.png'
graph['21']={'class_type':'VAEEncode','inputs':{'pixels':['12',0],'vae':['1',2]}}
graph['22']={'class_type':'SetLatentNoiseMask','inputs':{'samples':['21',0],'mask':['13',0]}}
graph['5']['inputs']['latent_image']=['22',0]
graph['5']['inputs']['denoise']=.28
graph['7']['inputs']['filename_prefix']='A09_R2_VALID_LATENT_MASK_RAW'
graph['17']['inputs']['filename_prefix']='A09_R2_VALID_LATENT_MASK_FINAL'
(root/'A09_R2_CORRECT_MASKED_LATENT_GRAPH.json').write_text(json.dumps(graph,indent=2))
report={'stage':'A09_R2','difference_to_A08':'Synthesized ground3-statistical sand prior replaces old image, VAEEncode+SetLatentNoiseMask replaces VAEEncodeForInpaint, denoise .28 instead of1.0; other model parameters same. Multi-factor process experiment, not isolated causal effect.','source':'statistical original-scale prior; no donor patch collage','seed':160406,'steps':14,'cfg':6.0,'controlnet_strength':.85,'ipadapter_strength':.65,'denoise':.28,'status':'NOT_SUBMITTED','formal_seal':'NO'}
def save():(root/'A09_R2_MODEL_EXECUTION_REPORT.json').write_text(json.dumps(report,indent=2),encoding='utf8')
save()
try:
 api='http://127.0.0.1:8230'
 req=urllib.request.Request(api+'/prompt',data=json.dumps({'prompt':graph,'client_id':'stage16-a09-R2-correct-latent-mask'}).encode(),headers={'Content-Type':'application/json'},method='POST')
 result=json.load(urllib.request.urlopen(req,timeout=30));assert result.get('prompt_id') and not result.get('node_errors'),result
 report['prompt_id']=result['prompt_id'];report['status']='QUEUED';save();print('A09_R2_QUEUED',result,flush=True)
 start=time.monotonic()
 while time.monotonic()-start<220:
  hist=json.load(urllib.request.urlopen(api+'/history/'+result['prompt_id'],timeout=12))
  if result['prompt_id'] in hist:
   rec=hist[result['prompt_id']];outs=rec.get('outputs',{})
   if outs.get('7',{}).get('images') and outs.get('17',{}).get('images'):
    report['status']='PASS_REAL_COMBINED_MODEL_OUTPUT'
    for node in ('7','17'):
     n=outs[node]['images'][0]['filename'];p=ui/'output'/n
     shutil.copy2(p,root/('A09_R2_COMFY_NATIVE_'+n))
     report['image_'+node]={'filename':n,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'size':p.stat().st_size}
    break
   if rec.get('status',{}).get('status_str')=='error':
    report['status']='FAIL_MODEL';report['server_status']=rec['status'];break
  time.sleep(1)
 if report['status']=='QUEUED':report['status']='TIMEOUT'
 report['elapsed_s']=round(time.monotonic()-start,2)
except Exception as e:
 report['status']='FAIL_NATIVE_OR_CONNECTION';report['error']=repr(e);report['traceback']=traceback.format_exc()[-2000:]
save()
print('A09_R2_RESULT',json.dumps(report)[:3000],flush=True)
