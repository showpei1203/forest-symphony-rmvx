"""A30 original actor01 referenced 18-joint Skeleton V3 for UNARMED SE chibi.
Original right-facing row2, 3 phases determine anchored feet / restrained head bob.
PixelLab calls one per action, preflight source original sha and approval; no resubmits.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import sys,json,time,io,base64,hashlib,shutil
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A30_FS_SOURCE_MOTION_RIG_LOOP_20261101"
A29=BASE/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"
SRC=A29/"A29_SELECTED_SE_VISUAL_45_UNARMED_40.png"
SKELETON=R/"A30_ACTUAL_UNARMED_18_BONES.json"
assert SRC.exists() and SKELETON.exists()
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(f):return hashlib.sha256(Path(f).read_bytes()).hexdigest()
def logwrite(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding="utf8")
original=json.loads((R/"A30_SOURCE_KINEMATICS.json").read_text(encoding="utf8"))["$actor01.png"]["rows"][2]
assert [v["feet"]["bbox"][3] for v in original]==[32,32,32]
base=json.loads(SKELETON.read_text(encoding="utf8"))
assert len(base)==18 and set(x["label"] for x in base)=={
 "NOSE","LEFT EYE","RIGHT EYE","LEFT EAR","RIGHT EAR","LEFT SHOULDER","RIGHT SHOULDER",
 "LEFT ELBOW","RIGHT ELBOW","LEFT ARM","RIGHT ARM","LEFT HIP","RIGHT HIP",
 "LEFT KNEE","RIGHT KNEE","LEFT LEG","RIGHT LEG","NECK"}
# Source motion guide: native head y=0..1 across 3 walk frames, feet bottoms ALWAYS 32.
# Use /40 fractional pixel shifts; weight shift is mostly leg/arm movement, never body translation.
def pose(shiftpx):
 out=[]
 for b in base:
  dx,dy=shiftpx.get(b["label"],(0,0))
  out.append({"label":b["label"],"x":round(max(0,min(1,b["x"]+dx/40)),5),
    "y":round(max(0,min(1,b["y"]+dy/40)),5),"z_index":round(b.get("z_index",0))})
 return out
# Keyframes cycle: center -> subtle chest breathing -> neutral -> gentle chest reset -> neutral.
# Eyes/face, neck, hips, knees, ankles/feet are LOCKED across all idle frames.
idle_shifts=[
 {},
 {"LEFT SHOULDER":(0,-1),"RIGHT SHOULDER":(0,-1),"LEFT ELBOW":(0,-1),"RIGHT ELBOW":(0,-1)},
 {"LEFT SHOULDER":(0,-1),"RIGHT SHOULDER":(0,-1),"LEFT ELBOW":(0,-1),"RIGHT ELBOW":(0,-1)},
 {},
 {},
 {}
]
walk_shifts=[
 {},
 {"LEFT KNEE":(-1,-1),"LEFT LEG":(-2,-1),"RIGHT KNEE":(1,0),"LEFT ARM":(1,0),"RIGHT ARM":(-1,0)},
 {},
 {"RIGHT KNEE":(1,-1),"RIGHT LEG":(2,-1),"LEFT KNEE":(-1,0),"LEFT ARM":(-1,0),"RIGHT ARM":(1,0)},
 {},
 {}
]
PROMPTS={
"IDLE":"Static grounded idle of the EXACT same unarmed 1:1 white-haired chibi in teal armor facing diagonal southeast 45 degrees. Native Forest Symphony original Idle uses one centered stationary stance: feet, hips, torso root, neck, face and head remain IN EXACT SAME PIXEL POSITION in every frame. NO overall bouncing, no vertical translation, no weight lifting, no walking. Very tiny one-pixel SHOULDER/CHEST breathing only. Both fists empty, no weapons, no scabbard, no shields. Do not redraw the head or make the character taller. Transparent 40x40.",
"WALK":"Source-guided Forest Symphony 3-pose right-facing walk with 1:1 oversized head and tiny legs, same precise unarmed white-haired teal armored character at southeast 45 degrees. Stance cycle: center neutral -> near leg takes short step forward, far leg supports -> neutral -> far leg takes short step, near leg supports -> neutral. HIPS AND HEAD VERTICALLY LOCKED, foot plant stays on same invisible ground line (no hopping), alternating knees and small reverse arm swing, step span only 1-2 native pixels, unarmed empty fists. Same face/cape/clothing and fully transparent 40x40. No sword or weapon."
}
def img_parse(data):
 arr=(data.get("last_response") or {}).get("images") or data.get("images") or []
 if not isinstance(arr,list) or len(arr)<6:raise ValueError("not 6 provider images")
 imgs=[]
 for x in arr:
  v=x.get("image",x) if isinstance(x,dict) else x
  if isinstance(v,dict):v=v.get("base64")
  if v.startswith("data:"):v=v.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  imgs.append(im)
 return imgs
def one(which):
 folder=R/("A30_"+which+"_SKELETON")
 folder.mkdir(exist_ok=True)
 lock=folder/"SUBMISSION_LOCK.json"
 if lock.exists():print(which,"SKIP_EXISTING_LOCK");return
 shifts=idle_shifts if which=="IDLE" else walk_shifts
 guidance={"original_actor01_source_sha256":original[1]["bbox"],
  "original_movement_skeleton":"head shift<=1 native px, feet bottom stays y32 across r2 c0 c1 c2",
  "A29_failure":"idle bottom bob 2px, walk missing 3 pose alternating cadence",
  "desired_bone_phases_px":shifts}
 logwrite(folder/"SOURCE_GUIDE.json",guidance)
 shutil.copy2(SRC,folder/"A29_UNARMED_45_VIEW_SOURCE_40.png")
 keyframes=[pose(z) for z in shifts]
 logwrite(folder/"SKELETON_POSES_6.json",{"base":base,"poses":keyframes})
 (folder/"PIXELLAB_PROMPT.txt").write_text(PROMPTS[which],encoding="utf8")
 before=balance(key());assert before["status"]=="active" and before["generations"]>12
 payload={"description":"white-haired 1:1 big-head chibi from genuine Forest Symphony source, teal bronze layered armor, empty bare fists no swords, diagonal southeast 3/4 view, same native silhouette",
  "action":PROMPTS[which],"direction":"south-east","view":"low top-down",
  "first_frame":{"type":"base64","base64":base64.b64encode(SRC.read_bytes()).decode(),"format":"png"},
  "first_frame_keypoints":pose({}),"keypoints":keyframes,"template_id":"mannequin",
  "seed":30110141 if which=="IDLE" else 30110142,"no_background":True}
 rec={"stage":"A30","action":which,"status":"PREPOST_LOCK_NO_DUPLICATE",
 "source_hash":sha(SRC),"method":"animate-with-skeleton-v3",
 "source_32_skeleton_analysis":str(R/"A30_SOURCE_KINEMATICS.json"),
 "before":before,"attempts":1,"frames_requested":6}
 logwrite(lock,rec)
 s,d=api(key(),"/animate-with-skeleton-v3",payload)
 job=d.get("background_job_id")
 rec.update({"http":s,"job_id":job,"usage":d.get("usage")})
 if s not in (200,201,202) or not job:
  rec.update({"status":"REJECTED_NO_RETRY","error":str(d)[:600]});logwrite(lock,rec)
  print(which,"REJECT",s,str(d)[:350],flush=True);return
 rec["status"]="ACCEPTED";logwrite(lock,rec)
 print(which,"PIXELLAB_JOB",job,flush=True)
 for i in range(100):
  time.sleep(4)
  rc,r=api(key(),"/background-jobs/"+job)
  if rc!=200:continue
  st=r.get("status")
  if i%5==0:print(which,"POLL",i,st,flush=True)
  if st in ("failed","error","canceled"):
   rec.update({"status":"FAILED_NO_RETRY","provider_status":st});logwrite(lock,rec);return
  if st not in ("completed","succeeded","success"):continue
  try:frames=img_parse(r)
  except Exception as e:
   rec.update({"status":"OUTPUT_READ_FAILED_NO_RETRY","error":str(e)});logwrite(lock,rec);return
  if any(f.size!=(40,40) for f in frames):
   rec.update({"status":"BAD_GEOMETRY","sizes":[f.size for f in frames]});logwrite(lock,rec);return
  strip=Image.new("RGBA",(40*len(frames),40))
  for k,f in enumerate(frames):f.save(folder/f"RAW_FRAME_{k:02}.png");strip.alpha_composite(f,(40*k,0))
  strip.save(folder/"A30_PIXELLAB_ORIGINAL_6F_40.png")
  boxes=[x.getbbox() for x in frames]
  after=balance(key())
  rec.update({"status":"RAW_GENERATED_REVIEW_PENDING","provider_usage":(r.get("last_response") or {}).get("billing_usage"),
  "source_frame_exact":frames[0].tobytes()==Image.open(SRC).convert("RGBA").tobytes(),
  "bbox_by_frame":boxes,"after":after,"raw_sheet_sha256":sha(folder/"A30_PIXELLAB_ORIGINAL_6F_40.png")})
  logwrite(lock,rec)
  print(which,"DONE","BBOX",boxes,"BALANCE",after["generations"],flush=True);return
 rec["status"]="POLL_LIMIT_NO_REPOST";logwrite(lock,rec)
if __name__=="__main__":
 if len(sys.argv)!=2 or sys.argv[1] not in PROMPTS:raise SystemExit("Pass IDLE or WALK")
 one(sys.argv[1])
