from pathlib import Path
import json,urllib.request,time,hashlib,shutil
import numpy as np
from PIL import Image,ImageDraw
r=Path(r"E:\FS_ROUTE_B_STAGE16_A09_TEXTURE_SCALE_20261031")
ui=Path(r"E:\FS_ROUTE_B_STAGE16_A03_REFERENCE_CONDITIONING_20261031\ComfyUI_v0340")
old=Path(r"E:\FS_ROUTE_B_STAGE16_A06_SAND_MATERIAL_20261031\A06_GROUND3_SAND_MATERIAL_REF_48.png")
assert hashlib.sha256(old.read_bytes()).hexdigest()=="ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb"
shutil.copy2(old,r/"A09_GROUND3_ORIGINAL_48.png")
shutil.copy2(old,ui/"input"/"A09_GROUND3_ORIGINAL_48.png")
graph={
 "1":{"class_type":"CheckpointLoaderSimple","inputs":{"ckpt_name":"v1-5-pruned-emaonly-fp16.safetensors"}},
 "2":{"class_type":"LoadImage","inputs":{"image":"A09_GROUND3_ORIGINAL_48.png"}},
 "3":{"class_type":"VAEEncode","inputs":{"pixels":["2",0],"vae":["1",2]}},
 "4":{"class_type":"VAEDecode","inputs":{"samples":["3",0],"vae":["1",2]}},
 "5":{"class_type":"SaveImage","inputs":{"images":["4",0],"filename_prefix":"A09_VAE_ROUNDTRIP_48"}}
}
(r/"A09_VAE_ROUNDTRIP_GRAPH.json").write_text(json.dumps(graph,indent=2))
api="http://127.0.0.1:8229"
report={"gate":"A09_ORIGINAL_GROUND3_48_VAE_ROUNDTRIP","status":"NOT_RUN","original_sha256":hashlib.sha256(old.read_bytes()).hexdigest(),"model":"SD15 fp16 VAE CPU FP32","art_approval":"NO","formal_seal":"NO"}
req=urllib.request.Request(api+"/prompt",data=json.dumps({"prompt":graph,"client_id":"a09-original-texture-frequency"}).encode(),headers={"Content-Type":"application/json"},method="POST")
response=json.load(urllib.request.urlopen(req,timeout=45))
assert response.get("prompt_id") and not response.get("node_errors"),response
print("A09_VAE_QUEUED",response,flush=True)
start=time.monotonic()
for _ in range(120):
 h=json.load(urllib.request.urlopen(api+"/history/"+response["prompt_id"],timeout=8))
 if response["prompt_id"] in h:
  record=h[response["prompt_id"]]
  outs=record.get("outputs",{}).get("5",{}).get("images",[])
  if outs:
   path=ui/"output"/outs[0]["filename"]
   shutil.copy2(path,r/"A09_VAE_RECONSTRUCTED_48.png")
   report["status"]="PASS_MODEL_VAE_ROUNDTRIP"
   report["png_sha256"]=hashlib.sha256(path.read_bytes()).hexdigest()
   break
  if record.get("status",{}).get("status_str")=="error":raise RuntimeError(str(record.get("status")))
 time.sleep(.5)
assert report["status"]=="PASS_MODEL_VAE_ROUNDTRIP","No VAE output"
orig=np.asarray(Image.open(r/"A09_GROUND3_ORIGINAL_48.png").convert("RGB"),dtype=np.float64)
out=np.asarray(Image.open(r/"A09_VAE_RECONSTRUCTED_48.png").convert("RGB"),dtype=np.float64)
assert orig.shape==out.shape==(48,48,3)
def metrics(a):
 dx=np.abs(a[:,1:,:]-a[:,:-1,:])
 dy=np.abs(a[1:,:,:]-a[:-1,:,:])
 return {"mean_RGB":np.round(a.mean(axis=(0,1)),3).tolist(),"neighbor_gradient_L1":round(float((dx.mean()+dy.mean())/2),4),"rgb_unique":len(np.unique(a.astype("uint8").reshape((-1,3)),axis=0))}
a,b=metrics(orig),metrics(out)
report.update({"input_stats":a,"vae_output_stats":b,"gradient_retention_ratio":round(b["neighbor_gradient_L1"]/a["neighbor_gradient_L1"],4),"MAE_RGB":round(float(np.abs(orig-out).mean()),4),"RMSE_RGB":round(float(np.sqrt(np.mean((orig-out)**2))),4),"PSNR_dB":round(float(20*np.log10(255/np.sqrt(np.mean((orig-out)**2)))),4),"latency_s":round(time.monotonic()-start,2),"warning":"VAE loss in original native texture is not an overall art-quality score. Pairwise pixel error includes VAE reconstruction effects."})
(r/"A09_VAE_FREQUENCY_QA.json").write_text(json.dumps(report,indent=2))
sheet=Image.new("RGB",(520,290),(20,22,23));draw=ImageDraw.Draw(sheet)
for j,(title,data) in enumerate([("Ground3 actual 48px",orig),("SD1.5 VAE encoded/decoded",out)]):
 x=2+j*260
 im=Image.fromarray(np.uint8(data))
 sheet.paste(im.resize((256,256),Image.Resampling.NEAREST),(x,29))
 draw.text((x,7),title,fill="white")
sheet.save(r/"A09_SOURCE_VAE_5X_COMPARISON.png")
print("A09_VAE_QA",json.dumps(report,indent=2),flush=True)
