"""A41 two real PixelLab jobs, formal 3-frame normal Damage art-gate and handoff.
Original game and A37 T4 sealed/selected sprite untouched.
"""
from pathlib import Path
import json,hashlib,zipfile,sys
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A41_NORMAL_DAMAGE_SKELETON_3F_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def load(p):return json.loads(p.read_text(encoding='utf8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf8')
L1=load(R/"A41_DAMAGE_SKELETON_V3_SUBMISSION_LOCK.json")
L2=load(R/"R2_HANDS_IN_GUARD"/"SUBMISSION_LOCK.json")
qa=load(R/"A41_R2_COMPARE_QA.json")
jobs=[]
for stage,lk in [("R1",L1),("R2",L2)]:
 assert lk.get("job_id"),(stage,lk)
 s,obj=api(key(),"/background-jobs/"+lk["job_id"])
 assert s==200 and obj.get("status")=="completed",(stage,s,obj.get("status"))
 bill=(obj.get("last_response") or {}).get("billing_usage")
 assert bill.get("generations")==2,bill
 jobs.append({"name":stage,"job_id":lk["job_id"],"generations":bill["generations"],"status":obj["status"]})
 print("JOB_READBACK",stage,lk["job_id"],bill,flush=True)
after=L2["balance_after"]
assert abs(float(after["generations"])-1695.7)<.01
status={
"stage":"A41","date":"2026-11-01","action":"Damage normal 3-frame 18-joint",
"rule":"3 frames ONLY. F0 and F2 from exact real FS battle-view source; F1 actual PixelLab skeleton-controlled image",
"user_selected_dodging_T4":"UNTOUCHED",
"jobs":jobs,"budget":{"before":1699.7,"after":1695.7,"spent":4.0},
"R1_visual":"FAIL, F1 arms outstretched left and right, reads attack not hit",
"R2_visual":"IMPROVED arm close to torso, short hit flinch with chin/shoulder sinking, visibly distinct from A40 terminal critical collapse",
"R2_source_sheet":"A41_R2_NORMAL_DAMAGE_NATIVE_SOURCE_ANCHORED_3F.png",
"R2_visual_preview":"A41_R1_FAIL_R2_VS_A40_CRITICAL_COMPARISON.png",
"raw_provider_frames":"R1 raw files + R2_HANDS_IN_GUARD/PIXELLAB_R2_DAMAGE_F0..F2",
"raw_vs_selected":"Raw provider retains 3 returned PixelLab images. Selected candidate uses unchanged native F0/F2 with actual PixelLab R2 F1. Not falsely called raw provider sheet.",
"technical":{"40px_native":"PASS","120x40_sheet":"PASS","exact_three_frame":"PASS","right_bottom_clip":"PASS","F0_eq_F2":"PASS","provider_jobs":2},
"art":{"natural_hit":"VISUAL CANDIDATE, user formal art review pending",
"true_45_all_frames":"PENDING human view gate","character_consistency":"PENDING human art",
"no_embedded_weapon":"PENDING art; source unarmed",
"SBS_engine":"NOT RUN","formal_pass":False},
"source_originals_FS_PM_T4_untouched":True
}
save(R/"A41_FINAL_QA.json",status)
handoff=f"""# A41 Handoff | Normal Damage 3F real PixelLab skeleton and severity comparison

## User instruction
Continue FS action production after A40 real skeleton succeeded. Preserve A37 user-selected Dodging T4. A40 critical severe retains deeper slump; normal Damage should be a brief, milder flinch, not critical kneel. All are exactly three 40px sprites, 120x40 sheet and entirely unarmed.

## Two real PixelLab trials, verified
Use genuine A34 actor01_1 battle-view-derived teal/white-haired original as F0 source, and A40 real /estimate-skeleton 18 joints (do NOT charge another estimate). Both /animate-with-skeleton-v3 with south-east and low top-down camera, three target frames:
- R1 job {jobs[0]['job_id']}, charged 2 generations; F1 raises and spreads arms horizontally, reads *attack* instead of damage -> ART SEMANTIC FAIL.
- R2 job {jobs[1]['job_id']}, charged 2 generations. Guard wrists constrained inside shoulder span, limited neck/back shift, hips slightly lower, and source F2 identical F0. F1 now more like short defensive flinch, still subject to user art & exact camera 45 gate.
A41 total spent 4 generations; quota after R2 1695.7/2000. Both provider jobs API-readback completed; no retries or duplicate charges.

## True outputs
A41_R1_FAIL_R2_VS_A40_CRITICAL_COMPARISON.png: four lines A40 crit, failed A41 R1, raw successful A41 R2, exact source-anchored R2 candidate.
A41_R2_NORMAL_DAMAGE_NATIVE_SOURCE_ANCHORED_3F.png: exactly 120x40 original F0, PixelLab R2 F1, original F2, no raster repaint.
A41_R2_NORMAL_DAMAGE_3F_ONESHOT.gif: three-frame one-shot no infinite loop.
Both R1 and R2 provider raw frames preserved separately. R2 keypoint changes stored R2_HANDS_IN_GUARD/A41_R2_RESTRICTED_GUARD_18JOINT.json. Detailed QA A41_R2_COMPARE_QA.json and A41_FINAL_QA.json.

## Gates and next
Normal vs critical now distinct motion duration/severity: A41 normal returns to exact guard by F2; A40 severe remains collapsed F2. Technical frame counts/geometry/no cropping pass. No formal art camera/weapon overlay/VX SBS run yet; never claim final PASS without tests. Original FS sources, A37 Dodging T4 and other baselines untouched.
Next A42 tests Moving to Close Attack with same skeletal source but SBS engine handles actual forward displacement; sprite art is in-place three steps only.
"""
(R/"A41_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
zipPath=R/"A41_NORMAL_DAMAGE_SKELETON_R1_R2_PRIVATE.zip"
with zipfile.ZipFile(zipPath,"w",zipfile.ZIP_DEFLATED) as z:
 for p in sorted(R.rglob('*')):
  if p.is_file() and p!=zipPath:z.write(p,p.relative_to(R))
with zipfile.ZipFile(zipPath) as z:
 assert z.testzip() is None
 print("ZIP_FILES",len(z.namelist()))
print("ZIP_BYTES",zipPath.stat().st_size,"ZIP_SHA",sha(zipPath))
