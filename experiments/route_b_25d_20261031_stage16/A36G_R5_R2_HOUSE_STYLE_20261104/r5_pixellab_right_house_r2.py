"""R5 ONE single complete right cottage source using actual LEFT house's native PixelLab visual style. Avoid repetitive paid submits."""
from pathlib import Path
import sys,io,json,time,hashlib,base64
from PIL import Image
A=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
sys.path.insert(0,str(A))
from a23_one_paid_spritesheet_trial import key,balance,api
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
left=S/"A36G_R5_LEFT_HOUSE_MATERIAL_STYLE_PATCH_RGBA.png"
old=S/"A36F_ELF_COTTAGE_B_MOSS_ROOF_RGBA.png"
out=S/"A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png"
lock=R/"A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_SUBMISSION_LOCK.json"
assert left.exists() and old.exists()
assert Image.open(left).size==(135,190)
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
PROMPT="""Create a completely new ORIGINAL small fantasy ELF VILLAGE COTTAGE as ONE WHOLE NON-CROPPED isolated RPG Maker VX pixel-art environmental building sprite. Exactly match the visual MATERIAL language of the reference STYLE PATCH: soft golden olive moss and leaf-thatch individual hand-pixeled highlights, natural uneven eaves, warm brown half-timber framing, visible cream plaster sections, stone moss foundation, inviting amber wooden door and sunlit shadowed 3/4 top-down southeast-facing perspective. The STYLE PATCH is ONLY for artistic texture, color grading, and shading. It is NOT a complete house, and you MUST NOT try to extend or reproduce its architecture! The SUBJECT reference old right cottage is ONLY for centered front door position and compact standalone single-house proportions; replace all its flat green conical roof and low detail. DISTINCT ARCHITECTURE from the separate large left house: one narrow unified volume with ONE SIMPLE STEEP GABLE ROOF and one ridge line, no attached side wing, no workroom, NO SECOND ROOF, NO roof valley. Attractive rustic stone-and-timber elf dwelling with one roof, front door near lower center, one small square window, subtle timber wood cross bracing, tiny short chimney optional. Crisp detailed 1-3 pixel clusters and natural shading. Full building entirely contained within source image with 15-22 PIXELS TRANSPARENT EMPTY MARGIN ON ALL FOUR SIDES, including entire roof, any chimney and BOTH SIDE WALLS, so NOTHING is cut off at left, right, top or bottom edges. Compose a single unique full-body house at approximately 214 pixels wide and 232 pixels tall INSIDE a 256x272 transparent canvas. Roof slopes show depth and real overlap with wall, not a flat triangle. No humans, no grass, no scenery, no duplicated buildings, no isolated objects, no lettering. ONE independent single-source transparent RGBA coherent sprite; do not assemble or paste multiple pieces."""
assert len(PROMPT)<=2000,len(PROMPT)
k=key();before=balance(k)
assert before["status"]=="active" and float(before["generations"])>=40,"LOW_QUOTA_NO_POST"
print("BEFORE",before,flush=True)
body={"description":PROMPT,"image_size":{"width":256,"height":272},
      "seed":360722,
      "style_image":{**embed(left),"usage_description":"Only material texture of left house: moss-gold detailed pixels, carved timber frame, cream plaster, moss stone, 3/4 perspective, shading. No architecture copying, it is cropped patch."},
      "reference_images":[{**embed(old),"usage_description":"Very rough one-volume right cottage composition and near-center front door reference. Generate distinct new gabled roof perspective, do not copy flat green old roof."}],
      "style_options":{"color_palette":True,"outline":True,"detail":True,"shading":True},
      "no_background":True}
state={"stage":"A36G_R5_STYLE_UNIFIED_RIGHT_R2","status":"PRE_SUBMITTED_DO_NOT_RETRY","attempts":1,
  "left_style_SHA256":sha(left),"old_right_layout_SHA256":sha(old),"target_size":[256,272],
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
if im.size!=(256,272):
 state.update(status="UNEXPECTED_SIZE",provider_size=list(im.size))
 lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8");sys.exit(6)
im.save(out,optimize=True)
state.update(status="SOURCE_READY_UNREVIEWED",pixel_size=list(im.size),alpha_bbox=im.getbbox(),output_sha=sha(out),
  alpha_zero_count=sum(1 for x in im.getchannel("A").getdata() if x==0),
  balance_after=balance(k))
lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
print("PIXELLAB_SOURCE_SAVED",str(out),im.size,"bbox",im.getbbox(),"SHA",sha(out),flush=True)
print("BALANCE_AFTER",state["balance_after"],flush=True)
