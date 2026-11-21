#!/usr/bin/env python3
"""T-B TB02 leaf bat evolution using Pixen source-image edit, one job per stage.
Input must be authorized prior stage PNG; origin from P1E MIT semantics and
PixelLab stage1 in-house generated. Transient Windows %TEMP% only.
"""
import argparse,base64,hashlib,json,os,pathlib,urllib.request,urllib.error,io
from PIL import Image
p=argparse.ArgumentParser()
p.add_argument("--work",required=True);p.add_argument("--stage",required=True,type=int,choices=[2,3])
p.add_argument("--submit",action="store_true");p.add_argument("--poll-job")
args=p.parse_args();w=pathlib.Path(args.work);w.mkdir(parents=True,exist_ok=True)
token=os.getenv("PIXELLAB_API_TOKEN")
if not token:raise RuntimeError("PixelLab credential missing")
def api(path,payload=None):
 h={"Authorization":"Bearer "+token,"Content-Type":"application/json"}
 d=None if payload is None else json.dumps(payload).encode()
 try:
  with urllib.request.urlopen(urllib.request.Request("https://api.pixellab.ai/v2"+path,data=d,headers=h),timeout=80) as r:return json.load(r)
 except urllib.error.HTTPError as e:raise RuntimeError(str(e.code)+" "+e.read().decode("utf8","replace")[:1200])
def sha(path):return hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()
prompts={
2:"Evolve THIS EXACT purple leaf-wing bat into a clearly larger MEDIUM creature, still visibly the same family and face. Broad jagged emerald leaf-membrane wings spanning farther, physically bigger plum-purple furry torso, new angular shoulder-leaf collar, longer ears, two brighter amber eyes. Change body shape and wings, NOT only colors. Preserve 3/4 southeast view, crisp pixel art, transparent background, exact 96x96. No frog, no extra head, no text, no scenery.",
3:"Evolve THIS EXACT medium purple leaf-wing bat into an unmistakable GIANT ANCIENT final evolution: huge DOUBLE-LAYERED emerald leaf wings with thorned tips and dramatic wide silhouette, leaf-branch horn crown, powerful plum-purple torso with central luminous green chest crystal, same bat face and two amber eyes, recognizable same lineage. Structural evolution not recolor. Exact 96x96 transparent pixel art, 3/4 southeast view. Do not add a second creature, frog features, text, ground or sky."}
source=w/("BAT_STAGE%d.png"%(args.stage-1))
if not source.is_file():raise FileNotFoundError(source)
if args.submit:
 body={"image":{"type":"base64","format":"png","base64":base64.b64encode(source.read_bytes()).decode()},
      "description":prompts[args.stage],"width":96,"height":96,"seed":202611215+args.stage,"no_background":True}
 (w/("STAGE%d_REQUEST.json"%args.stage)).write_text(json.dumps({"stage":args.stage,"source_sha256":sha(source),"description":prompts[args.stage],"seed":body["seed"],"endpoint":"/edit-image-pixen"},ensure_ascii=False,indent=2),encoding="utf8")
 j=api("/edit-image-pixen",body)
 print("SUBMITTED",args.stage,"JOB",j.get("background_job_id"),"STATUS",j.get("status"),"USAGE",j.get("usage"))
if args.poll_job:
 j=api("/background-jobs/"+args.poll_job);out=j.get("last_response") or {}
 print("POLL",args.stage,args.poll_job,"STATUS",j.get("status"),"USAGE",j.get("usage"),"LAST_KEYS",list(out))
 if j.get("status")=="failed":raise RuntimeError("Provider failed "+str(out)[:900])
 if j.get("status")!="completed":raise SystemExit(3)
 def dec(x):
  if isinstance(x,dict):
   for k in ("base64","image","data"):
    if k in x:return dec(x[k])
  if isinstance(x,str):
   if x.startswith("data:"):x=x.split(",",1)[1]
   try:return Image.open(io.BytesIO(base64.b64decode(x))).convert("RGBA")
   except Exception:pass
  return None
 arr=[]
 for k in ("images","frames","output_images"):
  for x in out.get(k,[]) or []:
   a=dec(x)
   if a is not None:arr.append(a)
 for k in ("image","output_image","generated_image"):
  a=dec(out.get(k))
  if a is not None:arr.append(a)
 if not arr:raise RuntimeError("No images in "+str(list(out)))
 dest=w/("BAT_STAGE%d.png"%args.stage);arr[0].save(dest)
 (w/("STAGE%d_RESULT.json"%args.stage)).write_text(json.dumps({"stage":args.stage,"id":"TB02_LEAF_BAT","provider_job":args.poll_job,"generation_id":out.get("generation_id"),"usage":j.get("usage"),"image_size":arr[0].size,"candidates":len(arr),"sha256":sha(dest)},indent=2),encoding="utf8")
 print("COMPLETED",args.stage,"candidates",len(arr),"size",arr[0].size,"SHA",sha(dest),"USAGE",j.get("usage"))
