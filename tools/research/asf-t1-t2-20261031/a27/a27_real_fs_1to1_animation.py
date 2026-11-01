"""A27 Source-locked approved Forest Symphony actor01 1:1 chibi animation trial.
Native 40x40 Pixen user-approved concept, two action trials, each once, no duplicate API submission.
"""
from pathlib import Path
import sys,base64,io,hashlib,json,time,shutil
from PIL import Image,ImageDraw
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
ROOT=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,api,balance
SOURCE=A26/"FS_NATIVE_PIXEN_RATIO_FIX"/"PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png"
assert SOURCE.exists()
ART=Image.open(SOURCE).convert("RGBA")
assert ART.size==(40,40) and ART.getbbox()==(9,4,32,38)
prompts={
"IDLE": "A subtle 4-frame seamless idle loop of the EXACT SAME tiny Forest Symphony white-haired chibi swordsman. Native 1:1 HEAD-TO-BODY ratio, giant 16px spiky white head, tiny 16px armor-clothed torso plus legs, unchanged face and costume. Gentle breathing and 1-pixel shoulder shift, tiny eye blink, feet planted in same place. Preserve fine teal armor trims, tiny cape, one small sword. No elongated body, no shrinking head, no changing outfit, no extra sword, no blurring or detached artifacts. Transparent 40x40 pixel canvas.",
"ATTACK": "A short 4-frame southeast-facing chibi swordsman battle attack: the exact SAME Forest Symphony tiny white-haired hero (head to body 1:1, 16px head and 16px body) with teal armor, small steel shoulder plates, one short sword. He pulls his right sword arm back, makes one compact diagonal slash, and resets. Keep head size identical each frame, feet and torso compact, no stretched legs, no giant sword, no duplicate arms, blade never disappears. Same 40x40 transparent native sprite, cohesive hand-pixelated shading and colors."
}
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save(p,record):p.write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf-8")
def encode(p):
 data=Path(p).read_bytes()
 assert Image.open(io.BytesIO(data)).size==(40,40)
 return {"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(data).decode(),"format":"png"}
def result_images(data):
 last=data.get("last_response",{})
 seq=last.get("images") or data.get("images")
 assert isinstance(seq,list) and len(seq)>=4,str(list(last))
 out=[]
 for v in seq:
  if isinstance(v,dict):v=v.get("image",v)
  if isinstance(v,dict):v=v.get("base64")
  assert isinstance(v,str)
  if v.startswith("data:"):v=v.split(",",1)[1]
  im=Image.open(io.BytesIO(base64.b64decode(v))).convert("RGBA")
  out.append(im)
 return out
def action_run(act,k):
 out=ROOT/("FS_"+act)
 out.mkdir(parents=True,exist_ok=True)
 lock=out/"SUBMISSION_LOCK.json"
 if lock.exists():
  print("SKIP_EXISTING_LOCK",act,flush=True);return False
 b=balance(k)
 if b["status"]!="active" or float(b["generations"])<25:
  print("BALANCE_UNAVAILABLE_STOP",b,flush=True);return False
 prompt=prompts[act]
 assert len(prompt)<1000
 shutil.copy2(SOURCE,out/"APPROVED_FS_1TO1_SOURCE_40.png")
 (out/"PROMPT.txt").write_text(prompt,encoding="utf-8")
 req={"first_frame":encode(SOURCE),"action":prompt,"frame_count":4,
   "no_background":True,"seed":27110101 if act=="IDLE" else 27110102,"enhance_prompt":False}
 log={"stage":"A27","action":act,"status":"PREPOST_LOCK_NO_DUPLICATE",
 "user_approved_input":True,"approved_source_sha256":sha(SOURCE),"request_route":"/animate-with-text-v3",
 "starting_balance":b,"attempts":1,"max_expected_generation_charge":2}
 save(lock,log)
 status,data=api(k,"/animate-with-text-v3",req)
 job=data.get("background_job_id")
 log.update({"http":status,"job_id":job,"usage":data.get("usage")})
 if status not in (200,201,202) or not job:
  log.update({"status":"API_REJECTED_OR_UNCERTAIN_NO_RETRY","short_error":str(data)[:450]})
  save(lock,log);print(act,"REJECTED",status,flush=True);return False
 log["status"]="ACCEPTED"
 save(lock,log)
 print(act,"ACCEPTED_JOB",job,flush=True)
 for idx in range(65):
  time.sleep(4)
  c,d=api(k,"/background-jobs/"+job)
  if c!=200:continue
  remote=d.get("status")
  if idx%5==0:print(act,"POLL",idx,remote,flush=True)
  if remote in ("failed","error","canceled"):
   log.update({"status":"FAILED_NO_RETRY","provider_status":remote});save(lock,log);return False
  if remote in ("completed","success","succeeded"):
   try:frames=result_images(d)
   except Exception as exc:
    log.update({"status":"OUTPUT_PARSE_FAIL_NO_RETRY","error":str(exc)[:300]})
    save(lock,log);return False
   if any(x.size!=(40,40) for x in frames):
    log.update({"status":"WRONG_FRAME_SIZE","sizes":[x.size for x in frames]})
    save(lock,log);return False
   diffs=[];boxes=[];bottoms=[]
   for n,im in enumerate(frames):
    im.save(out/f"ACTUAL_FRAME_{n:02}.png")
    diffs.append(sum(a!=c for a,c in zip(ART.getdata(),im.getdata())))
    boxes.append(im.getbbox())
    bottoms.append(sum(im.getpixel((x,39))[3]>0 for x in range(40)))
   sheet=Image.new("RGBA",(40*len(frames),40))
   for i,f in enumerate(frames):sheet.alpha_composite(f,(i*40,0))
   sheet.save(out/"ACTUAL_NATIVE_40_SPRITESHEET.png")
   scaled=Image.new("RGB",(240*len(frames),240),(233,237,240))
   for i,im in enumerate(frames):
    bg=Image.new("RGBA",(40,40),(233,237,240,255));bg.alpha_composite(im)
    scaled.paste(bg.convert("RGB").resize((240,240),Image.Resampling.NEAREST),(i*240,0))
   scaled.save(out/"ACTUAL_FRAMES_6X_REVIEW.png")
   after=balance(k)
   cost=float(b["generations"])-float(after["generations"])
   log.update({"status":"REAL_FRAMES_CREATED_ART_GATE_PENDING","frames":len(frames),"bbox_by_frame":boxes,
       "bottom_edge_opaque_by_frame":bottoms,"diff_pixels_vs_approved_source":diffs,
       "first_frame_exact":diffs[0]==0,"provider_reported_usage":d.get("usage"),
       "after":after,"observed_cost":cost,"sheet_sha256":sha(out/"ACTUAL_NATIVE_40_SPRITESHEET.png"),
       "native_sbs_integration":"NOT DONE","user_visual_gate":"NOT_YET_REVIEWED"})
   save(lock,log)
   print(act,"GENERATED",len(frames),"DIFF",diffs,"BBOX",boxes,"BOTTOM",bottoms,"COST",cost,flush=True)
   return 0<=cost<=3 and all(z==0 for z in bottoms)
 log["status"]="POLL_LIMIT_NO_RETRY"
 save(lock,log)
 return False
def main():
 k=key()
 for a in ["IDLE","ATTACK"]:
  success=action_run(a,k)
  if not success:
   print("FAIL_CLOSED_STOP_FURTHER_ACTIONS",a,flush=True)
   break
if __name__=="__main__":main()
