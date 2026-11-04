"""R5 ONE single complete right cottage source using actual LEFT house's native PixelLab visual style. Avoid repetitive paid submits."""
from pathlib import Path
import sys,io,json,time,hashlib,base64
from PIL import Image
A=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
sys.path.insert(0,str(A))
from a23_one_paid_spritesheet_trial import key,balance,api
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
left=S/"A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png"
old=S/"A36F_ELF_COTTAGE_B_MOSS_ROOF_RGBA.png"
out=S/"A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_RGBA.png"
lock=R/"A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_SUBMISSION_LOCK.json"
assert left.exists() and old.exists()
assert Image.open(left).size==(284,259)
assert Image.open(old).size==(198,236)
assert not lock.exists() and not out.exists(),"EXISTING_JOB_OR_SOURCE_DO_NOT_CHARGE_AGAIN"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def embed(p):
 i=Image.open(p).convert("RGBA")
 return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode("ascii"),"format":"png"},
         "size":{"width":i.width,"height":i.height}}
def as_image(x):
 if isinstance(x,dict):
  for k in ("image","base64","data"):
   if k in x:return as_image(x[k])
 if isinstance(x,str):
  if x.startswith("data:"):x=x.split(",",1)[1]
  raw=base64.b64decode(x)
  if raw.startswith(b"\x89PNG\r\n\x1a\n"):return Image.open(io.BytesIO(raw)).convert("RGBA")
 raise RuntimeError("No valid PNG from provider")
def extract(d):
 stack=[d]
 for _ in range(3):
  stack +=[v for q in list(stack) if isinstance(q,dict) for k,v in q.items() if k in ("last_response","data","response","result") and isinstance(v,dict)]
 for q in stack:
  if not isinstance(q,dict):continue
  for k in ("images","image","edited_images","output_images"):
   v=q.get(k)
   if isinstance(v,list) and v:return as_image(v[0])
   if isinstance(v,(str,dict)):return as_image(v)
 raise RuntimeError("Provider contains no PNG")
PROMPT="""ONE WHOLE coherent sprite of a smaller sister cottage for a fantasy ELF VILLAGE, matching EXACTLY the provided LEFT workshop house's professional hand-pixelled RPG Maker VX 3/4 TOP-DOWN CAMERA (look down from upper left toward southeast / front and right side), native pixel texture, warm browns, material density, lighting and roof shape language. This is a distinct cottage, NOT another workshop, NOT a second image pasted to the first. Structure: tall steep yet organic dual-sloping MOSS-GOLD OLIVE LEAF-THATCH GABLE roof matching supplied LEFT cottage's hand-crafted golden green layered thatch and irregular fringe; beautifully detailed rich golden-olive hand-pixel clusters across the roof with 3D cast shade, NOTHING like a geometric green cone or triangle. Exposed dark chestnut half-timber beams and infill walls, same brown wood framing and mossy warm-gray stone base as supplied left house. A warm illuminated rustic wood entry door at middle of the FRONT base facing the village path, one small square framed window to right of door, little front step. Short natural side wall visible at left side, showing perspective; narrow compact roof silhouette rather than symmetrical front-on flat facade. A couple of charming asymmetrical timber joints and roofline details, no added annex. Precisely same 1px crisp pixel-grid aesthetic, color hierarchy and art direction as the LEFT reference, equivalent highlights and foliage thatch clusters. Completely isolated house building sprite with fully transparent outside alpha, full building visible and grounded near bottom, no outdoor grass, no people, no other buildings, no title, no backgrounds, no effects. Match the OLD RIGHT reference ONLY for narrow approximate 198x236 geometry and front door entry position; IGNORE its old geometric flat green thatch and cruder look. Generate an original integrated full architectural sprite, NOT a pasted assembly."""
assert len(PROMPT)<=2000,len(PROMPT)
k=key();before=balance(k)
assert before["status"]=="active" and float(before["generations"])>=40,"LOW_QUOTA_NO_POST"
print("BEFORE",before,flush=True)
body={"description":PROMPT,"image_size":{"width":198,"height":236},
      "seed":360721,
      "style_image":{**embed(left),"usage_description":"ABSOLUTE visual art direction: exact golden moss leafy gable, warm timber, stone blocks, 3/4 perspective, expressive high detail and clean pixel clusters of LEFT newly approved house. Generate a smaller unique sister house."},
      "reference_images":[{**embed(old),"usage_description":"ONLY approximate source 198x236 frame, proportions and middle front DOOR location so the new structure remains on the original path. DO NOT copy old shape, palette, flat cone roof or weak art."}],
      "style_options":{"color_palette":True,"outline":True,"detail":True,"shading":True},
      "no_background":True}
state={"stage":"A36G_R5_STYLE_UNIFIED_RIGHT_R1","status":"PRE_SUBMITTED_DO_NOT_RETRY","attempts":1,
  "left_style_SHA256":sha(left),"old_right_layout_SHA256":sha(old),"target_size":[198,236],
  "source_family":"PixelLab generate-image-v2 same style", "prompt":PROMPT,
  "balance_before":before,"art_gate":"PENDING_VISUAL_REVIEW","formal_seal":"NO"}
lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
code,r=api(k,"/generate-image-v2",body)
state.update(http_status=code,provider_keys=list(r) if isinstance(r,dict) else [])
if code not in (200,201,202):
 state.update(status="REJECTED_NO_RETRY",error_excerpt=str(r)[:500])
 lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
 print("REJECTED_NO_RETRY",code,state["error_excerpt"],flush=True);sys.exit(3)
job=r.get("background_job_id")
if job:
 state.update(status="JOB_ACCEPTED",job_id=job)
 lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
 print("JOB_ACCEPTED",job,flush=True)
 fin=None
 for i in range(65):
  time.sleep(4)
  rc,data=api(k,"/background-jobs/"+job)
  if rc!=200:continue
  if i%8==0:print("POLL",i,data.get("status"),flush=True)
  if data.get("status") in ("failed","canceled","error"):
   state.update(status="JOB_FAILED_NO_RETRY",provider_status=data.get("status"))
   lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8");sys.exit(4)
  if data.get("status") in ("completed","success","succeeded"):fin=data;break
 if fin is None:
  state.update(status="POLL_TIMEOUT_NO_RETRY")
  lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8");sys.exit(5)
 im=extract(fin)
else:im=extract(r)
if im.size!=(198,236):
 state.update(status="UNEXPECTED_SIZE",provider_size=list(im.size))
 lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8");sys.exit(6)
im.save(out,optimize=True)
state.update(status="SOURCE_READY_UNREVIEWED",pixel_size=list(im.size),alpha_bbox=im.getbbox(),output_sha=sha(out),
  alpha_zero_count=sum(1 for x in im.getchannel("A").getdata() if x==0),
  balance_after=balance(k))
lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
print("PIXELLAB_SOURCE_SAVED",str(out),im.size,"bbox",im.getbbox(),"SHA",sha(out),flush=True)
print("BALANCE_AFTER",state["balance_after"],flush=True)
