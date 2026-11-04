"""One PixelLab paid source asset per named forest region. No duplicate requests or hidden retry."""
import sys,io,time,hashlib,json,base64
from pathlib import Path
from PIL import Image
A=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
sys.path.insert(0,str(A))
from a23_one_paid_spritesheet_trial import key,balance,api
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
S=R4/"SOURCE_INDEPENDENT_RGBA"
regions=json.loads((R4/"R4_FOREST_REGION_BLUEPRINT.json").read_text("utf8"))["regions"]
target=sys.argv[1] if len(sys.argv)>1 else "NORTH_WEST"
reg=next(r for r in regions if r["id"]==target)
assert 16<=reg["w"]<=464 and 16<=reg["h"]<=576
out=S/f"A36G_R4_{target}_PIXELLAB_CONTIGUOUS_RGBA.png"
lock=R4/f"A36G_R4_{target}_PROVIDER_LOCK.json"
assert not out.exists() and not lock.exists(),f"NO_DUPLICATE_SUBMIT_{target}"
style=S/"A36G_PIXELLAB_WEST_FOREST_CONTIGUOUS_FULL_R3B_RGBA.png"
assert style.exists() and Image.open(style).size==(464,576)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def embed(p):
 im=Image.open(p).convert("RGBA")
 return {"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(p.read_bytes()).decode("ascii"),"format":"png"},
 "size":{"width":im.width,"height":im.height}}
def pngval(x):
 if isinstance(x,dict):
  for k in ("image","base64","data"):
   if k in x:return pngval(x[k])
 if isinstance(x,str):
  if x.startswith("data:"):x=x.split(",",1)[1]
  b=base64.b64decode(x)
  if b[:8]==b"\x89PNG\r\n\x1a\n":return Image.open(io.BytesIO(b)).convert("RGBA")
 raise RuntimeError("NO_PNG")
def extract(obj):
 a=[obj]
 for _ in range(3):
  a.extend(v for d in list(a) if isinstance(d,dict) for k,v in d.items() if k in ("last_response","response","result","data") and isinstance(v,dict))
 for d in a:
  if not isinstance(d,dict):continue
  for k in ("images","image","edited_images","output_images"):
   v=d.get(k)
   if isinstance(v,list) and v:return pngval(v[0])
   if isinstance(v,(dict,str)):return pngval(v)
 raise RuntimeError("NO_IMAGE")
prom=f"""Generate ONE SINGLE INTEGRATED CONTIGUOUS FOREST REGION pixel-art environmental source asset, in EXACTLY the same native art style, tree species, 3/4 top-down perspective, scale, lighting, and beautifully detailed leafy pixel clusters as the supplied original Forest Symphony western forest RGBA reference. AREA TYPE: {reg['description']} This forest volume is a COLLECTIVE INTERCONNECTED canopy mass of richly 3D individual identifiable trees (not flat green carpet, not abstract noise or pattern), with naturally overlapping round broadleaf crowns and scattered narrow conifers, individual deep-shadow branches and trunks, darker understory, foliage silhouette irregular and organic. Tree canopy lobes in multiple sizes, asymmetrical old trees, practical 32x32 map tile scale, tiny 1-3px crisp deliberate leaf highlights, visible trunks near irregular clearing edge, subtle root shapes, fine detail without blur. This is one COMPLETE forest GROUP sprite, NOT individual pasted tree sprites, NOT entire landscape. Entire forest group image should fill its top/side border where canopy continues off the world and use natural bough contours toward remaining edges. Isolated ALPHA-TRANSPARENT source, no background terrain, no lawn, no road, no houses, no people, no captions, no UI. Match source reference professionally with equivalent density, depth and visual richness. Actual output target {reg['w']}x{reg['h']} transparent pixel art PNG, no fake border, no cast shadow outside the canopy."""
assert len(prom)<=2000,len(prom)
k=key()
before=balance(k)
assert before["status"]=="active" and float(before["generations"])>=50,"STOP_NO_CREDITS"
print("PRE",target,"generations",before["generations"],flush=True)
payload={"description":prom,"image_size":{"width":reg["w"],"height":reg["h"]},
         "style_image":{**embed(style),"usage_description":"Native pixelated woodland style image. Copy rich actual tree canopy shape, depth, tiny crisp leaf clusters, green palette, believable overlap and 3/4 game perspective."},
         "style_options":{"color_palette":True,"outline":True,"detail":True,"shading":True},
         "no_background":True,"seed":360710+regions.index(reg)}
state={"region":target,"canvas":[reg["w"],reg["h"]],"world_origin":[reg["x"],reg["y"]],
       "status":"PRE_SUBMISSION_NO_RETRY","attempt_count":1,"style_source_sha":sha(style),
       "balance_before":before,"prompt":prom,"source":"PixelLab v2 generate-image",
       "art_gate":"PENDING","formal_seal":"NO"}
lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
code,res=api(k,"/generate-image-v2",payload)
state.update(http=code,provider_keys=list(res) if isinstance(res,dict) else [])
if code not in (200,201,202):
 state.update(status="REJECTED_DO_NOT_RETRY",provider_error=str(res)[:450])
 lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
 print(target,"REJECTED",code,state["provider_error"],flush=True);sys.exit(2)
job=res.get("background_job_id")
if job:
 state.update(status="JOB_ACCEPTED",job_id=job)
 lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
 print(target,"JOB_ACCEPTED",job,flush=True)
 completed=None
 for i in range(65):
  time.sleep(4)
  sc,data=api(k,"/background-jobs/"+job)
  if sc!=200:continue
  if i%8==0:print(target,"POLL",i,data.get("status"),flush=True)
  if data.get("status") in ("failed","error","canceled"):
   state.update(status="PROVIDER_FAILED_DO_NOT_RETRY",provider_status=data.get("status"))
   lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8");sys.exit(3)
  if data.get("status") in ("completed","succeeded","success"):completed=data;break
 if completed is None:
  state["status"]="POLL_TIMEOUT_NO_RESUBMIT"
  lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8");sys.exit(4)
 im=extract(completed)
else:im=extract(res)
if im.size!=(reg["w"],reg["h"]):
 state.update(status="BAD_GEOMETRY",actual_size=im.size)
 lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8");sys.exit(5)
im.save(out,optimize=True)
state.update(status="SOURCE_READY_ART_UNREVIEWED",output_file=out.name,
 output_sha=sha(out),alpha_bbox=im.getbbox(),
 alpha_zero_count=sum(1 for a in im.getchannel("A").getdata() if a==0),
 balance_after=balance(k))
lock.write_text(json.dumps(state,ensure_ascii=False,indent=2),"utf8")
print(target,"READY_RGBA",im.size,"bbox",im.getbbox(),"sha",sha(out),flush=True)
