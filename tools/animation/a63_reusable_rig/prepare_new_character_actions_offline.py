"""A63 reusable rig intake: ONE APPROVED new character + ONE manually checked 18-joint SE skeleton,
prepare two action poses at once. No repeated original $actor01 analysis, no paid calls.
Examples:
 python prepare_new_character_actions_offline.py --character-id knight02 --target-png ./knight02_se_f0.png \
   --target-skeleton ./knight02_skeleton.json --out ../CHARACTERS
Outputs cache manifest with stable SHA key + two action-specific pose JSONs, no GPU/PixelLab needed.
"""
from pathlib import Path
from hashlib import sha256
from datetime import datetime,timezone
import argparse,json,re
from retarget_any_actor_offline import load_points,retarget
p=argparse.ArgumentParser()
p.add_argument("--character-id",required=True)
p.add_argument("--target-png",required=True,type=Path)
p.add_argument("--target-skeleton",required=True,type=Path)
p.add_argument("--out",required=True,type=Path)
args=p.parse_args()
if not re.fullmatch(r"[a-zA-Z0-9_-]{2,60}",args.character_id):
 raise ValueError("Provide a safe stable actor id, letters/digits/_/- only")
pts=load_points(args.target_skeleton)
if not args.target_png.exists():raise FileNotFoundError(args.target_png)
H=lambda f:sha256(f.read_bytes()).hexdigest()
charhash=H(args.target_png)
skhash=H(args.target_skeleton)
db=args.out/args.character_id
db.mkdir(parents=True,exist_ok=True)
reg=db/"CHARACTER_ONCE_REGISTRY.json"
if reg.exists():
 existing=json.loads(reg.read_text("utf8"))
 if existing.get("reference_sha256")!=charhash or existing.get("skeleton_sha256")!=skhash:
  raise RuntimeError("Character ID already registered with different reference/skeleton. Use a new ID or deliberate version; never silently regenerate.")
 else:
  existing={}
template_dir=Path(__file__).resolve().parent
recipe_hashes={action:H(template_dir/filename)for action,filename in {
 "run":"A62_APPROVED_RUN_MOTION_RECIPE.json",
 "waiting":"A63_WAITING_SIDE_SWAY_MOTION_RECIPE.json"}.items()}
tasks=[]
for act in("run","waiting"):
 spec=retarget(act,args.target_png,pts)
 spec["character_id"]=args.character_id
 spec["template_sha256"]=recipe_hashes[act]
 spec["character_png_reference_sha256"]=charhash
 spec["skeleton_reference_sha256"]=skhash
 spec["cache_key"]=sha256((charhash+skhash+recipe_hashes[act]).encode("ascii")).hexdigest()
 name=f"{args.character_id}_{act.upper()}_OFFLINE_POSES.json"
 dest=db/name
 if dest.exists():
  old=json.loads(dest.read_text("utf8"))
  if old["cache_key"]!=spec["cache_key"]:
   raise RuntimeError(f"Existing {dest} cannot be overwritten with different rig inputs")
 else:dest.write_text(json.dumps(spec,ensure_ascii=False,indent=2),encoding="utf8")
 tasks.append({"action":act,"pose_file":name,"cache_key":spec["cache_key"],
 "needs_before_paid":"human visual pose review + check view angle/identity/anatomical feet",
 "status":"OFFLINE_READY_API_NOT_SUBMITTED"})
registry={"character_id":args.character_id,"reference_png":str(args.target_png),
 "reference_sha256":charhash,"baseline_skeleton":str(args.target_skeleton),
 "skeleton_sha256":skhash,"approved_image_and_view_by_human":"MUST BE REVIEWED FOR EACH DISTINCT CHARACTER",
 "actions":tasks,"source_motion":"A62 user-approved reusable; original $actor01 refs analyzed ONCE",
 "pixelLab_original_reference_bone_reanalysis_required":False,
 "pixelLab_new_character_one_time_18joint_estimate_required_if_not_provided":True,
 "pixelLab_animation_generation_for_new_actor_not_yet_submitted":True}
# Waiting is now a reusable, pixel-perfect original-action lateral cycle:
# generate finished transparent GIF immediately without any new paid model call.
from retarget_waiting_pixels_offline import make_waiting
from PIL import Image
raw_actor=Image.open(args.target_png).convert("RGBA")
waiting_images,waiting_checks=make_waiting(raw_actor)
for i,im in enumerate(waiting_images):
 filename=db/f"{args.character_id}_WAITING_F{i}.png"
 im.save(filename)
gif=db/f"{args.character_id}_WAITING_LEFT_MID_RIGHT_MID.gif"
waiting_seq=[waiting_images[i]for i in (0,1,2,1)]
waiting_seq[0].save(gif,save_all=True,append_images=waiting_seq[1:],
  duration=[175]*4,loop=0,disposal=2,optimize=False)
registry["waiting_pixel_motion"]={
 "mode":"A63 W3B ORIGINAL FS left-mid-right-mid source-pixel animation",
 "gif_filename":gif.name,"frames":[f"{args.character_id}_WAITING_F{i}.png"for i in range(3)],
 "dimensions":raw_actor.size,"pixels_per_phase":waiting_checks,
 "source_identity_preserved":True,"ai_generation_required":False,
 "human_art_review_still_required":True}
reg.write_text(json.dumps(registry,ensure_ascii=False,indent=2),encoding="utf8")
print("REGISTERED_REUSABLE_CHARACTER_ONCE",args.character_id,len(tasks),"actions","API_CALLS=0",flush=True)
