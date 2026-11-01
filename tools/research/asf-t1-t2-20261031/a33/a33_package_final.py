"""A33 R1 final QA and private handoff, no asset substitution. All paid provider refs read-only verified."""
from pathlib import Path
from PIL import Image
import json,hashlib,zipfile,sys,shutil
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A33_HUMANOID_DIRECT_POSE_20261101"
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def get(p):return json.loads(p.read_text(encoding='utf8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf8')
logs={}
for name,path in [("Dodge_B",R/"B_DODGING_DIRECT_POSES"/"SUBMISSION_LOCK.json"),
  ("Dodge_C",R/"C_DODGE_45_CORRECTION"/"SUBMISSION_LOCK.json"),
  ("Damage_B",R/"B_DAMAGE_DIRECT_POSES"/"SUBMISSION_LOCK.json")]:
 d=get(path)
 assert d.get('job_id'),(name,d)
 s,response=api(key(),"/background-jobs/"+d["job_id"])
 assert s==200 and response.get("status")=="completed",(name,s,response.get('status'))
 logs[name]={"job_id":d["job_id"],"charge":(response.get("last_response") or {}).get('billing_usage'),
  "status":d["status"],"sha256":d.get("spritesheet_sha256") or d.get("sha256")}
 print("CONFIRMED",name,logs[name],flush=True)
now=balance(key())
assert round(float(now["generations"]),1)==1781.8,now
assert (R/"A33_B_DAMAGE_USER_POSES_VS_PIXEL_LAB.png").exists()
assert (R/"A33_POSE_SOURCE_B_VS_C_LARGE.png").exists()
# No all-green bias. First two visually judged candidates, C added little/fails to prove 45°.
qa={
"project":"FS A33 16 human action direct reference pose research",
"date":"2026-11-01",
"approval_baseline":{"A26_character":"user PASS; unarmed FS white-haired teal 1:1",
 "A31_walk":"user PASS; real actor01 original walk steps",
 "A32_dodge_text":"FAIL - insufficient lateral evasion","A32_reference_16":"reference taxonomy only, no exact rig"},
"phases":{"Waiting":"STATIC SOURCE BASELINE, no paid provider (avoids arbitrary shoulder tremor)",
 "Dodging A":"A32 text FAIL, NOT RESUBMITTED",
 "Dodging B":"3 user screenshots actual 32x32 pixels first → real PixelLab transfer-outfit-v2 →3 real 40x40 frames, readable crouch/recovery, user art review pending",
 "Dodging C":"Same 3 B frames → edit-animation-v2, small appearance changes but 45° not proven improved; do not claim C PASS, no retry",
 "Damage B":"3 user screenshots actual 32x32 pixels → real transfer-outfit-v2 →3 real 40x40 frames, head/shoulders reaction recognizable, user art review pending",
 "Damage C":"NOT RUN: Dodge C showed little 45° improvement and would spend extra 10 generations without clear reason"},
"verified_jobs":logs,
"before_quota":1811.8,"after_quota":now["generations"],"actual_generations_spent":round(1811.8-now["generations"],1),
"all_output_sources":"user screenshot pose pixels directly provided as each frame; ONLY 40x40 padding, no resized poses",
"new_actions_full_engine_gate":"NOT PASSED: No Tankentai SBS imported, no paper doll anchor tested, no full 45° accepted",
"source_files_untouched":"true; original FS and PMD game files not overwritten",
"paid_safe_limit":"all jobs locked before API submission, 1 provider job per group, 3 groups total",
"best_current_candidates":{"Dodge":"B raw (C only marginal visual changes)","Damage":"B raw","Waiting":"A31 original static neutral"},
"next":"A33-R2 after user art review, use direct pose control for Critic Damaged and Jump; fix viewing angle by requiring real FS $actor01_1/_2/_3 view-reference pixels, not text-only C redo",
"files":{"rules":"A33_TEST_RULES_AND_STEPS.md",
 "comparison_dodge":"A33_POSE_SOURCE_B_VS_C_LARGE.png",
 "comparison_damage":"A33_B_DAMAGE_USER_POSES_VS_PIXEL_LAB.png",
 "character_wait":"A33_WAITING_STATIC_BASELINE/FS_WAITING_NATIVE_40.png"}}
put(R/"A33_R1_FINAL_QA.json",qa)
handoff=f"""# A33 R1 Handoff: human 16 actions direct pose control real PixelLab — 2026-11-01

## User instruction and authoritative source
Continue A32 rules and PixelLab testing; upload rules; start immediately, no user reconfirmation.
Google Docs formal rules: https://docs.google.com/document/d/1qGJi0QhDrGZC3P_AzVWakEwUpSHjNmKSkvZlToGLh7E/edit
GitHub branch test/asf-a33-humanoid-pose-direct-control-20261101, rules and source scripts.
Original 16 action screenshot reference was split into four private 96x128 transparent PNGs in the chat. EXACT row09 Dodging and row05 Damage original 32x32 poses were palette-losslessly transferred into PC via base64 zip. Each native pose padded exactly (x4, y6) into 40x40 transparent. No pose painted, re-illustrated or interpolated.

## REAL outputs
Waiting: A31 real native neutral Idle copy, one static frame, 0 paid generations, no artificial shoulder tremor.
Dodging A: old A32 text baseline e1d05e30-8541-4c94-8bce-a1e89f18405f FAIL, no repeat.
Dodging B /transfer-outfit-v2 job {logs['Dodge_B']['job_id']} generated 3 real frames directly from screenshot pose images + approved white-haired unarmed FS character identity. 10 generations. Visual: whole body ducks, recovers, clearly more distinct than A32 text-only dodge; 45° and exact character/style user art review pending.
Dodging C /edit-animation-v2 job {logs['Dodge_C']['job_id']} adjusted the B 3 actual frames jointly to southeast 45. 10 generations. Compared to B, only subtle changes; cannot confirm actual more accurate 45°, NOT PASS.
Damage B /transfer-outfit-v2 job {logs['Damage_B']['job_id']} generated 3 real frames from screenshot Damage row exact poses, 10 generations. No weapons embedded. Visual candidate pending user review.
Damage C intentionally STOPPED after C Dodge marginal benefit: don't waste generations on identical text-only revision.

## QA and safe gates
B/C generated sprites are native 40x40 transparent; original screenshot reference poses are exact 32x32 palette/alpha images.
One shot frames, not seamless loops. PixelLab provider job success is NOT aesthetic success; actual 45° is pending; SBS paper doll weapon overlay, FS VX/Godot rendering not tested.
Original FS $actor01/$actor01_1/_2/_3, A26 approved character, PMD XML/source, SBS _1/_2/_3 all unchanged.
Start balance 1811.8, end balance {now['generations']} /2000. Exact {qa['actual_generations_spent']} generations, 3 jobs with locked submissions, no uncertain retries.
Private project E:\\GameAssetToolLab_20261023\\A33_HUMANOID_DIRECT_POSE_20261101

## Next stage
Direct pose conditioning is preferable to description-only. Fix 45° via actual native battle-view image source (actor01_1/_2/_3) instead of repeating text prompt on C. After art approval, benchmark Critic Damaged and Jump; no nonhuman PMD anatomy copying.
"""
(R/"A33_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
archive=R/"A33_R1_HUMANOID_DIRECT_REFERENCE_TESTS_PRIVATE.zip"
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
 for file in sorted(R.rglob('*')):
  if file.is_file() and file!=archive:z.write(file,file.relative_to(R))
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 count=len(z.namelist())
print("ZIP",str(archive),"FILES",count,"BYTES",archive.stat().st_size,"SHA256",sha(archive))
print("BALANCE",now["generations"],"SPENT",qa["actual_generations_spent"])
