#!/usr/bin/env python3
"""FS T-B second-species pilot. No persistent user-PC output; only %TEMP%.
PixelLab jobs explicitly ID'd; origin semantic reference P1E MIT 16px bat;
frog image style reference only, not a shared character identity.
"""
import argparse,base64,hashlib,io,json,os,pathlib,urllib.request,urllib.error
from PIL import Image
P=argparse.ArgumentParser()
P.add_argument("--frog",required=True)
P.add_argument("--work",required=True)
P.add_argument("--stage",type=int,choices=[1,2,3],required=True)
P.add_argument("--submit",action="store_true")
P.add_argument("--poll-job")
args=P.parse_args()
W=pathlib.Path(args.work);W.mkdir(exist_ok=True,parents=True)
API="https://api.pixellab.ai/v2"
TOKEN=os.getenv("PIXELLAB_API_TOKEN")
if not TOKEN:raise RuntimeError("Authorized PixelLab token unavailable")
FROG_SHA="e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72"
if hashlib.sha256(pathlib.Path(args.frog).read_bytes()).hexdigest()!=FROG_SHA:raise ValueError("source style reference SHA differs")
DESC={
1:"A single small forest bat monster, unmistakably bat not a frog, soft round dark plum-violet furry body, two big separate dark emerald leaf-shaped membrane wings with visible green leaf veins, large pointed ears, two amber eyes, tiny curved claws, facing southeast 3/4 low top-down, hovering; short wings, no weapons, no sky, no ground, pixel sprite",
2:"An evolved middle-stage of the exact same plum-violet leaf-winged forest bat, wider stronger paired emerald leaf-veined wings with jagged outer tips, distinct upright feather-like shoulder collar, longer elegant ears and larger torso, same amber eyes and face, strongly different overall silhouette, southeast 3/4 hovering monster; not a recolor, not a frog",
3:"A high-stage ancient evolution of the exact same plum-violet forest leaf-wing bat family: huge layered double leaf-veined emerald wings with thorn-spur wingtips, majestic hornlike leaf crown and large chest emerald gem, muscular torso, same face large amber eyes, obvious grand silhouette change, southeast 3/4 low top down; not a recolor, not a frog"
}
def api(path,data=None):
 payload=None if data is None else json.dumps(data).encode()
 h={"Authorization":"Bearer "+TOKEN,"Content-Type":"application/json"}
 try:
  with urllib.request.urlopen(urllib.request.Request(API+path,headers=h,data=payload),timeout=75) as response:return json.load(response)
 except urllib.error.HTTPError as e:raise RuntimeError("Provider HTTP "+str(e.code)+" "+e.read().decode("utf8","replace")[:900])
def b64(p):return base64.b64encode(pathlib.Path(p).read_bytes()).decode()
def ref(p):
 im=Image.open(p);return {"image":{"type":"base64","format":"png","base64":b64(p)},"width":im.width,"height":im.height}
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
if args.submit:
 styles=[ref(args.frog)]
 if args.stage>1:
  prev=W/("BAT_STAGE%d.png"%(args.stage-1))
  if not prev.is_file():raise FileNotFoundError("previous family stage must exist before generation")
  styles.insert(0,ref(prev))
 if args.stage==3:
  styles.insert(1,ref(W/"BAT_STAGE1.png"))
 body={"style_images":styles,"description":DESC[args.stage],"style_description":"Match the supplied approved FS lava-frog pixel art technique ONLY: dark outlined small monster sprite, controlled textured highlights, crisp nearest-neighbor pixel edges, low top-down three-quarter southeast view. The subject MUST remain bat with wings, not frog.","no_background":True,"seed":202611210+args.stage}
 request_log={"endpoint":"/generate-with-style-v2","stage":args.stage,"bat_source":"P1E OSS pixel-asset-gen (MIT) generated bat.png, 96x16 6-frame strip; semantic design only","prompt":body["description"],"styles_sha256":[FROG_SHA]+([] if args.stage==1 else [sha(W/("BAT_STAGE%d.png"%(args.stage-1)))]),"seed":body["seed"]}
 (W/("STAGE%d_REQUEST.json"%args.stage)).write_text(json.dumps(request_log,ensure_ascii=False,indent=2),encoding="utf8")
 resp=api("/generate-with-style-v2",body)
 print("SUBMITTED",args.stage,"JOB",resp.get("background_job_id"),"STATUS",resp.get("status"),"USAGE",resp.get("usage"))
if args.poll_job:
 resp=api("/background-jobs/"+args.poll_job);last=resp.get("last_response") or {}
 print("POLL",args.stage,args.poll_job,resp.get("status"),"usage",resp.get("usage"),"last_keys",list(last.keys()),"progress",last.get("progress"))
 if resp.get("status")=="failed":raise RuntimeError("PIXELLAB_FAILED "+str({k:v for k,v in last.items() if k not in ("image","images")})[:1000])
 if resp.get("status")!="completed":raise SystemExit(3)
 def parse(obj):
  if isinstance(obj,dict):
   for k in ("base64","image","data"): 
    if k in obj:return parse(obj[k])
  if isinstance(obj,str):
   try:
    if obj.startswith("data:"):obj=obj.split(",",1)[1]
    return Image.open(io.BytesIO(base64.b64decode(obj))).convert("RGBA")
   except Exception:pass
  return None
 images=[]
 for k in ("images","frames","output_images"):
  for v in last.get(k,[]) or []:
   im=parse(v)
   if im:images.append(im)
 for k in ("image","output_image","generated_image","sprite"):
  im=parse(last.get(k))
  if im:images.append(im)
 if not images:raise RuntimeError("No image found in completed response. Available keys: "+str(list(last)))
 out=W/("BAT_STAGE%d.png"%args.stage)
 images[0].save(out)
 report={"stage":args.stage,"id":"TB02_LEAF_BAT","job":args.poll_job,"generation_id":last.get("generation_id"),"usage":resp.get("usage"),"frame_count":len(images),"image_size":images[0].size,"png_sha256":sha(out),"source_style_sha256":FROG_SHA}
 (W/("STAGE%d_RESULT.json"%args.stage)).write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
 print("COMPLETE",json.dumps(report))
