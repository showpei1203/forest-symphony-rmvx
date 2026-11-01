"""A26 approved PMD0001 6-action PixelLab trial; FS Actor01 1:1 chibi repair.
No changes to native sealed source; no autopost retry; every action one API job maximum.
"""
from pathlib import Path
from PIL import Image,ImageDraw
from io import BytesIO
import hashlib,json,time,base64,sys,shutil
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
A25=Path(r"E:\GameAssetToolLab_20261023\A25_T1_PIXELLAB_CONCEPT_FROM_REAL_SOURCES_20261101")
ROOT=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
ROOT.mkdir(exist_ok=True)
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,balance,api,unpack
fsbase=A23/"PIXELLAB_INPUTS"/"FS_ACTOR01_SOURCE_BASE_RIGHT_64.png"
pmdbase=A25/"PMD0001"/"PIXELLAB_CONCEPT_64.png"
fs_style=A25/"FS_ACTOR01"/"PIXELLAB_CONCEPT_64.png"
assert pmdbase.exists() and fsbase.exists() and fs_style.exists()
D={
"idle":("Idle","The same approved orange volcanic frog monster performs a seamless subtle idle loop in 3/4 southeast battle view: gentle breathing, slight eye blink, tiny back-rock bobbing. Feet stay anchored. Exactly the same compact round anatomical silhouette, attached basalt dorsal spikes and horns, consistent face, four little legs and orange body every frame. No new black shapes, detached fragments or floating particles. No extra limbs. No background."),
"walk":("Walk","The exact approved chibi volcanic frog walks four small steps toward southeast 45 degrees. Alternating small feet, body bobs and low settled center of gravity, natural squat frog posture. Identical basalt crest and connected gray back armor, warm orange skin, face, eyes, two horns in all frames. The entire single creature remains within the 64px frame with padding. No clones, melting body or black debris."),
"attack":("Attack","The exact approved orange lava frog does a short 3/4 southeast battle strike: crouch, open mouth slightly with a sharp forward head-butt and tiny molten spark, then recoil. Same identity and body proportions. Its basalt armor and dark rock horns stay firmly attached and do not split, no detached spikes, no giant explosion, no new anatomy, no black floating debris. Animate the character rather than changing species. Single isolated creature."),
"cast":("Charge","The exact approved volcanic frog channels heat magic: head lifts slightly, molten seams within its existing basalt dorsal ridge briefly brighten and dim, tiny deliberate mouth motion. Four small-frame animation. Preserve same squat proportions, four legs, orange hide, gray basalt hump and horns with no duplication. Minimal small controlled glow attached to body only, no detached fireball, no smoky background."),
"hurt":("Hurt","The same approved lava-frog monster reacts to a hit: a quick body jolt backward, small head dip, one brief eye squeeze, and recover. Keep orange body, back-attached charcoal basalt shell, all horns, short legs and face recognizably identical. No flashing black clouds, new object fragments, extra limbs or detached particles. Stay inside 64x64 canvas."),
"death":("Faint","The same approved orange rock-backed lava frog faints in 3/4 southeast RPG battle view: stunned low head droop, compact collapse onto ground, remaining visible lying on one side with eyes closed. Keep same orange body, fixed horns, gray dorsal shell and four small legs. No dissolve, body disintegration, magic disappearance, new monster or detached black blobs; 64x64 transparent canvas.")
}
PROMPT_FS="""Fix ONLY chibi body proportions of the original character and redesign his gear to the visual detail shown in the attached outfit reference. Hard requirement: EXACT ORIGINAL FOREST SYMPHONY 1:1 HEAD-TO-BODY PROPORTION. Head including hair occupies ~15-16 vertical source pixels; torso plus legs below chin occupies ~15-16 pixels, not a taller heroic 1:3 figure. Keep total full-body height 31-33 native pixels, as in the original input sprite. Preserve the ORIGINAL white spiky hairstyle, face, eyes, facial scale, foot anchor and 3/4 right-facing game camera, character remains within x=19..46, y=18..53 on a 64x64 transparent canvas. From the previous PixelLab candidate reference, transfer ONLY the refined teal leather layered costume detail, fitted shaded metal shoulder guard, dark belts, gloves, tiny cape, boots, and elegant SHORT SWORD. Miniature shoulder armor must be curved, small, precisely shaded with multiple colors and tiny details, never a flat-color block. The head must look as large as the entire body below the chin. Visually match the original artwork pixel density, shapes, outlines and palette depth. Do not enlarge legs, do not make a tall slender adult or change the head/body ratio. Show complete feet with several fully transparent pixels below, no cropping or contact with bottom edge. Keep one weapon, no unrelated particles, no background, no shadows, no blur. One static crisp 64x64 RGBA sprite only."""
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def js(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding="utf-8")
def enc(path):
 b=Path(path).read_bytes();im=Image.open(BytesIO(b)).convert("RGBA")
 assert im.size==(64,64)
 return {"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(b).decode("ascii"),"format":"png"}
def check_status(job,k,label,record,lock):
 for i in range(70):
  time.sleep(4)
  status,obj=api(k,"/background-jobs/"+job)
  if status!=200:
   if i%5==0:print(label,"poll HTTP",status,flush=True)
   continue
  st=obj.get("status")
  if i%5==0:print(label,"poll",i,st,flush=True)
  if st in ("failed","error","canceled"):
   record["status"]="FAILED_NO_RETRY";record["provider_status"]=st;js(lock,record)
   return None
  if st in ("completed","succeeded","success"):
   return obj
 record["status"]="POLL_LIMIT_NO_REPOST";js(lock,record)
 return None
def images_from_response(obj):
 objs=[obj]
 for key in ("last_response","response","result","data"):
  v=obj.get(key) if isinstance(obj,dict) else None
  if isinstance(v,dict):objs.append(v)
 for o in objs:
  for key in ("images","edited_images","output_images"):
   a=o.get(key) if isinstance(o,dict) else None
   if isinstance(a,list) and len(a)>0:return [unpack(z)[1] for z in a]
   if isinstance(a,dict):return [unpack(a)[1]]
  for key in ("image",):
   a=o.get(key) if isinstance(o,dict) else None
   if isinstance(a,(str,dict)):return [unpack(a)[1]]
 raise Exception("No provider output images; outer response keys "+str(list(obj)))
def run_pmd(action,k):
 name,desc=D[action]
 target=ROOT/("PMD_"+action.upper())
 target.mkdir(exist_ok=True)
 lock=target/"SUBMISSION_LOCK.json"
 if lock.exists():
  print(action,"EXISTING_LOCK_DO_NOT_REPOST",flush=True);return False
 before=balance(k)
 assert before["status"]=="active" and float(before["generations"])>=30
 assert len(desc)<=1000
 shutil.copy2(pmdbase,target/"A25_APPROVED_SOURCE_64.png")
 (target/"PROMPT.txt").write_text(desc,encoding="utf-8")
 request={"first_frame":enc(pmdbase),"action":desc,"frame_count":4,"no_background":True,
   "seed":26110100+list(D).index(action),"enhance_prompt":False}
 record={"stage":"A26","action":action,"native_action":name,"source_sha256":sha(pmdbase),
    "source_A25_user_approved":True,"status":"PREPOST_LOCK_NO_RETRY","attempts":1,
    "balance_before":before,"prompt":desc,"max_expected_generation":2}
 js(lock,record)
 print("SUBMIT",action,flush=True)
 code,resp=api(k,"/animate-with-text-v3",request)
 job=resp.get("background_job_id")
 record.update({"http":code,"job_id":job,"submit_status":resp.get("status"),"usage":resp.get("usage")})
 if code not in (200,201,202) or not job:
  record["status"]="REJECTED_OR_UNKNOWN_NO_REPOST";record["error"]=str(resp)[:500]
  js(lock,record);print("REJECT",action,code,flush=True);return False
 record["status"]="SUBMITTED";js(lock,record)
 print("ACCEPTED",action,job,flush=True)
 obj=check_status(job,k,action,record,lock)
 if obj is None:return False
 try:frames=images_from_response(obj)
 except Exception as ex:
  record["status"]="UNREADABLE_RESPONSE";record["error"]=str(ex);js(lock,record);return False
 if len(frames)<4 or any(im.size!=(64,64) for im in frames):
  record["status"]="BAD_FRAME_GEOMETRY";record["sizes"]=[im.size for im in frames];js(lock,record);return False
 source=Image.open(pmdbase).convert("RGBA")
 diffs=[];boxes=[]
 for i,im in enumerate(frames):
  im.save(target/f"PIXELLAB_FRAME_{i:02}.png")
  diffs.append(sum(a!=b for a,b in zip(source.getdata(),im.getdata())))
  boxes.append(im.getbbox())
 sprite=Image.new("RGBA",(64*len(frames),64))
 for i,im in enumerate(frames):sprite.alpha_composite(im,(i*64,0))
 sprite.save(target/"PIXELLAB_SPRITESHEET_64x5.png")
 # Create 5x crisp contact for review
 review=Image.new("RGB",(320*len(frames),320),(233,236,240))
 for i,im in enumerate(frames):
  bg=Image.new("RGBA",(64,64),(233,236,240,255));bg.alpha_composite(im)
  review.paste(bg.convert("RGB").resize((320,320),Image.Resampling.NEAREST),(i*320,0))
 review.save(target/"REVIEW_5X.png")
 after=balance(k);delta=float(before["generations"])-float(after["generations"])
 record.update({"status":"SHEET_RENDERED_ART_GATE_PENDING","actual_frames":len(frames),
   "output_sha256":sha(target/"PIXELLAB_SPRITESHEET_64x5.png"),
   "first_frame_exact":diffs[0]==0,"pixel_changes_per_frame":diffs,"boxes":boxes,
   "balance_after":after,"actual_generation_cost":delta,
   "native_pmd_xml":"NOT_YET_MAPPED","visual_gate":"UNREVIEWED"})
 js(lock,record)
 print("SHEET_DONE",action,"FRAMES",len(frames),"COST",delta,"DIFFS",diffs,flush=True)
 return 0<=delta<=3 and all(x is not None for x in boxes)
def extract_single(obj):
 ims=images_from_response(obj)
 assert ims and ims[0].size==(64,64)
 return ims[0]
def fix_fs(k):
 target=ROOT/"FS_RATIO_REPAIR"
 target.mkdir(exist_ok=True)
 lock=target/"SUBMISSION_LOCK.json"
 if lock.exists():
  print("FS_ALREADY_LOCKED",flush=True);return
 before=balance(k)
 assert before["status"]=="active" and float(before["generations"])>=20
 shutil.copy2(fsbase,target/"ORIGINAL_1_TO_1_64.png")
 shutil.copy2(fs_style,target/"A25_CLOTHING_STYLE_REFERENCE_64.png")
 (target/"PROMPT.txt").write_text(PROMPT_FS,encoding="utf-8")
 request={"method":"edit_with_reference",
 "edit_images":[{"image":enc(fsbase),"width":64,"height":64}],
 "reference_image":{"image":enc(fs_style),"width":64,"height":64},
 "image_size":{"width":64,"height":64},
 "description":PROMPT_FS,"seed":26110107,"no_background":True}
 record={"stage":"A26_FS_RATIO_FIX","status":"PREPOST_LOCK_NO_RETRY","attempts":1,
 "ratio_target":"head 15-16px, body 15-16px, full height ~32px, preserve original proportions",
 "source_sha256":sha(fsbase),"style_sha256":sha(fs_style),"before":before}
 js(lock,record)
 print("FS_FIX_POST_ONCE",flush=True)
 code,resp=api(k,"/edit-images-v2",request)
 job=resp.get("background_job_id")
 record.update({"http":code,"job_id":job,"usage":resp.get("usage")})
 if code not in (200,201,202) or not job:
  record["status"]="REJECTED_OR_UNKNOWN_NO_RETRY";record["error"]=str(resp)[:600];js(lock,record)
  print("FS_REJECTED",code,str(resp)[:400],flush=True);return
 record["status"]="SUBMITTED";js(lock,record)
 print("FS_FIX_ACCEPTED",job,flush=True)
 obj=check_status(job,k,"FS_FIX",record,lock)
 if obj is None:return
 try:im=extract_single(obj)
 except Exception as ex:
  record["status"]="UNREADABLE_RESPONSE";record["error"]=str(ex);js(lock,record);return
 im.save(target/"FS_ACTOR01_RATIO1TO1_CONCEPT_64.png")
 after=balance(k);delta=float(before["generations"])-float(after["generations"])
 box=im.getbbox()
 record.update({"status":"STATIC_CONCEPT_CREATED_VISUAL_GATE_PENDING","bbox":box,
   "bottom_edge_opaque_pixels":sum(im.getpixel((x,63))[3]>0 for x in range(64)),
   "bbox_height":box[3]-box[1] if box else None,
   "balance_after":after,"actual_generation_cost":delta,
   "source_original_unmodified":True,"animation_not_generated":True})
 js(lock,record)
 print("FS_FIX_OUTPUT",box,"COST",delta,"bottom_edge",record["bottom_edge_opaque_pixels"],flush=True)
def main():
 cmd=sys.argv[1]
 k=key();b=balance(k)
 print("A26_PREFLIGHT",cmd,"BALANCE",b["generations"],flush=True)
 if cmd=="PMD_FIRST":
  a=run_pmd("idle",k)
  if a:
   run_pmd("walk",k)
  else:print("STOP_AFTER_FIRST_FAIL",flush=True)
 elif cmd=="PMD_REMAINING":
  for n in ("attack","cast","hurt","death"):
   ok=run_pmd(n,k)
   if not ok:break
 elif cmd=="FS_FIX":fix_fs(k)
 else:raise ValueError("Choose PMD_FIRST, PMD_REMAINING or FS_FIX")
if __name__=="__main__":main()
