from pathlib import Path
import json,hashlib,zipfile,sys
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A39_CRITICAL_DAMAGE_NATIVE45_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
load=lambda p:json.loads(p.read_text(encoding="utf8"))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding="utf8")
lock=load(R/"A39_F1_EDIT_SUBMISSION_LOCK.json")
assert lock["status"]=="ONE_REAL_FRAME_READY_ART_CAMERA_GATE_PENDING"
c,dat=api(key(),"/background-jobs/"+lock["job_id"])
assert c==200 and dat.get("status")=="completed",(c,dat.get("status"))
bill=(dat.get("last_response") or {}).get("billing_usage")
assert bill.get("generations")==10
now=balance(key())
assert abs(float(now["generations"])-1701.8)<0.01,now
qa=load(R/"A39_CRITICAL_DAMAGE_QA.json")
qa.update({"job_id":lock["job_id"],"provider_bill":bill,
"balance_before":1711.8,"balance_after":1701.8,
"art_camera_observation":"F1 keeps same front/side face planes as A34 source and A38 normal; exact user angle PASS still PENDING",
"art_motion_observation":"Facial pain and mouth visibly more intense than A38, but torso/hip/knee silhouette changes are NOT adequately larger; CRITICAL_DAMAGE_SEMANTIC_FAIL",
"critical_damage_gate":"FAIL weak distinct body recoil despite face expression",
"promote_to_game":False})
save(R/"A39_FINAL_QA.json",qa)
handoff=f"""# A39 Critic Damaged 3-frame native-view trial | 2026-11-01

A38 succeeded as new NORMAL DAMAGE source-first F1 40px camera candidate, more 45 than A37 C, but its body recoil remained moderate. A39 seeks CRITICAL DAMAGED (severe impact) distinctly larger body stagger, using the same A34 genuine $actor01_1-derived 45-degree master directly, not wrong A37 side profile.

True PixelLab /edit-images-v2 job {lock['job_id']}, method edit_with_text, real 40x40 RGBA output, 10 generations billed. Before 1711.8, after {now['generations']}/2000, confirmed provider completed. Lock written pre-call; 1 accepted paid submission, no retries.
A39_PIXELLAB_NATIVE_BATTLE_DAMAGE_F1_REAL_40.png contains genuine PixelLab F1 critical pose.
A39_CRITICAL_DAMAGE_3FRAME_120x40.png exact 3 actual 40px cells: exact A34 native battle F0, real generated A39 critical F1, exact A34 F2. GIF is one-shot and exactly 3 frames.
A39_NORMAL_VS_CRITICAL_VISUAL_COMPARE.png visually compares A34 original, A38 normal damage F1 and A39 critical damage F1 plus sequence.
OBSERVED: camera and 1:1 chibi somewhat preserved, F1 critical has larger mouth and arms held defensively. However torso tilt/knee sink/silhouette NOT sufficiently more dramatic than A38 normal: severity motion semantic GATE FAIL. Do NOT add to game or call it official artwork PASS.
Next method must be REAL distinct 45° battle pose image/rig control for heavy hit, not another slight change of edit-images text. Zero source modifications; no weapon embedded; SBS weapon system still untested.
T4 user-selected Dodging remains locked under A37, never replaced with the old T3.
"""
(R/"A39_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
z=R/"A39_CRITICAL_DAMAGE_NATIVE45_PRIVATE.zip"
with zipfile.ZipFile(z,"w",zipfile.ZIP_DEFLATED) as arc:
 for p in sorted(R.rglob("*")):
  if p.is_file() and p!=z:arc.write(p,p.relative_to(R))
with zipfile.ZipFile(z) as arc:assert arc.testzip() is None;print("ZIP_FILE_COUNT",len(arc.namelist()))
print("ZIP_BYTES",z.stat().st_size,"ZIP_SHA",sha(z))
print("PROVIDER_VERIFIED",lock["job_id"],bill,now["generations"])
