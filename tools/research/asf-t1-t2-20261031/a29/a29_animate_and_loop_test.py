"""A29 PixelLab actual animation trial based ONLY on Pixen-rendered 45deg unarmed concept.
Run after human/assistant has inspected concept. No imagegen; no source overwrites.
"""
from pathlib import Path
from PIL import Image
import sys,io,base64,time,hashlib,shutil,json,statistics
BASE=Path(r"E:\GameAssetToolLab_20261023")
A23=BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"
ROOT=BASE/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"
SOURCE=ROOT/"A29_SELECTED_SE_VISUAL_45_UNARMED_40.png"
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,api,balance
ACTION={
 "IDLE":"Exactly same approved 45-degree southeast 3/4-facing unarmed white-haired 1:1 chibi hero, 40x40 pixel art. LOOPING idle breath: feet anchored and slight 1px chest and head rise and return, cape reacts subtly. Both hands remain EMPTY fists for separate paper-doll weapons. No swords, scabbards, handles, shields or any weapons in ANY frame. No head-size drift, no turn to a side-facing profile. Same highly detailed teal armor and short legs, stable pixel alignment.",
 "WALK":"Exactly same approved 45-degree southeast 3/4-facing UNARMED white-haired 1:1 chibi, transparent 40x40 game sprite. A seamless cyclic IN-PLACE walk: alternate near and far leg, footstep A, passing pose, footstep B, passing, weight returns. Head/chest/feet retain diagonal southeast orientation; same big head, tiny legs, cape, gold-trimmed teal armor. Empty clenched fists: NO sword, sheath, weapon, shield, scabbard or hilt in any frame. Stable feet baseline, no extra limbs, no character drift."
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def js(p,obj):p.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding="utf8")
def raw(obj):
 l=obj.get("last_response") or {}
 arr=l.get("images") or obj.get("images")
 if not isinstance(arr,list) or len(arr)<4:raise RuntimeError("No 4+ frames: "+str(list(l)))
 frames=[]
 for e in arr:
  dat=e.get("image",e) if isinstance(e,dict) else e
  if isinstance(dat,dict):dat=dat.get("base64")
  if dat.startswith("data:"):dat=dat.split(",",1)[1]
  frames.append(Image.open(io.BytesIO(base64.b64decode(dat))).convert('RGBA'))
 return frames
def diffs(a,b):
 return sum(p!=q for p,q in zip(a.getdata(),b.getdata()))
def run_one(name,k):
 folder=ROOT/name;folder.mkdir(exist_ok=True)
 lock=folder/"SUBMISSION_LOCK.json"
 if lock.exists():
  print("LOCK_ALREADY_EXISTS_SKIP",name,flush=True);return False
 source=Image.open(SOURCE).convert("RGBA")
 assert source.size==(40,40) and source.getbbox() is not None
 shutil.copy2(SOURCE,folder/"SOURCE_45_UNARMED_40.png")
 (folder/"PIXELLAB_PROMPT.txt").write_text(ACTION[name],encoding="utf8")
 before=balance(k)
 assert before["status"]=="active" and float(before["generations"])>=10
 payload={"first_frame":{"type":"base64","base64":base64.b64encode(SOURCE.read_bytes()).decode(),"format":"png"},
   "action":ACTION[name],"frame_count":4,"seed":29110160+(0 if name=="IDLE" else 1),
   "no_background":True,"enhance_prompt":False}
 log={"stage":"A29","action":name,"status":"PREPOST_LOCK","source_sha256":sha(SOURCE),
 "source_candidate":"A29 PixelLab Pixen southeast unarmed still art-review candidate",
 "native_frame_size":[40,40],"before":before,"attempts":1}
 js(lock,log)
 status,resp=api(k,"/animate-with-text-v3",payload)
 job=resp.get("background_job_id")
 log.update({"http":status,"job_id":job,"submit_usage":resp.get("usage")})
 if status not in (200,201,202) or not job:
  log.update({"status":"REJECTED_UNCERTAIN_NO_RETRY","error":str(resp)[:450]});js(lock,log)
  print(name,"POST_REJECT",status,flush=True);return False
 log["status"]="JOB_ACCEPTED";js(lock,log)
 print(name,"ACTUAL_PIXEL_LAB_JOB",job,flush=True)
 for n in range(100):
  time.sleep(4)
  st,data=api(k,"/background-jobs/"+job)
  if st!=200:continue
  if n%5==0:print(name,"POLL",n,data.get("status"),flush=True)
  if data.get("status") in ("error","failed","canceled"):
   log.update({"status":"PROVIDER_FAILED_NO_RETRY"});js(lock,log);return False
  if data.get("status") not in ("completed","success","succeeded"):continue
  try:frames=raw(data)
  except Exception as ex:
   log.update({"status":"OUTPUT_UNREADABLE_NO_RETRY","error":str(ex)});js(lock,log);return False
  if any(im.size!=(40,40) for im in frames):
   log.update({"status":"FRAME_GEOMETRY_FAILED","sizes":[list(x.size) for x in frames]});js(lock,log);return False
  for idx,im in enumerate(frames):im.save(folder/f"PROVIDER_FRAME_{idx:02}.png")
  sheet=Image.new("RGBA",(40*len(frames),40))
  for i,im in enumerate(frames):sheet.alpha_composite(im,(40*i,0))
  sheet.save(folder/"PIXELLAB_RAW_SPRITESHEET.png")
  # GIF exact sequence and pingpong alternative for seam comparison.
  for tag,indices in (("ORIGINAL_LOOP",list(range(len(frames)))),("PINGPONG_LOOP",list(range(len(frames)))+list(range(len(frames)-2,0,-1)))):
   sequence=[frames[i] for i in indices]
   sequence[0].save(folder/f"{name}_{tag}_160MS.gif",save_all=True,append_images=sequence[1:],loop=0,
                    duration=160,disposal=2,optimize=False)
  frame_diff=[diffs(frames[i],frames[i+1]) for i in range(len(frames)-1)]
  seam=diffs(frames[-1],frames[0])
  ratio=round(seam/max(1,statistics.median(frame_diff)),3)
  boxes=[im.getbbox() for im in frames]
  bottoms=[sum(im.getpixel((x,39))[3]>0 for x in range(40)) for im in frames]
  # Both loops with boundaries are included, but only RAW_LOOP qualifies as seamless if seam passes.
  rule={"frame_count":len(frames),"source_frame0_exact":diffs(frames[0],source)==0,
  "pair_diffs":frame_diff,"last_to_first_diff":seam,"seam_to_median_ratio":ratio,
  "original_loop_seam_threshold":2.0,
  "seam_gate":"PASS" if ratio<=2 else "FAIL","bboxes":boxes,"bottom_edge_opaque":bottoms,
  "bottom_gate":"PASS" if max(bottoms)==0 else "FAIL",
  "pingpong_loop":"FOR_DIAGNOSTICS_NOT_A_PROOF_OF_NATIVE_CYCLE",
  "orientation_45":"NEEDS_ART_REVIEW","unarmed_consistency":"NEEDS_ART_REVIEW"}
  after=balance(k)
  log.update({"status":"REAL_PIXEL_LAB_FRAMES_LOOP_TEST_DONE_PENDING_ART_GATE",
    "after":after,"provider_bill":(data.get("last_response") or {}).get("billing_usage"),
    "sheet_sha256":sha(folder/"PIXELLAB_RAW_SPRITESHEET.png"),"metrics":rule})
  js(lock,log)
  print(name,"DONE",json.dumps(rule),"BALANCE",after["generations"],flush=True)
  return True
 log["status"]="POLL_LIMIT_NO_RETRY";js(lock,log)
 return False
if __name__=="__main__":
 if len(sys.argv)!=2 or sys.argv[1] not in ACTION:raise ValueError("pass IDLE or WALK")
 run_one(sys.argv[1],key())
