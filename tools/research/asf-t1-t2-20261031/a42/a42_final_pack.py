"""A42 source-first approach attack QA and private handoff. One real job, 3 frames.
No weapon sprite, no engine displacement: Tankentai SBS controls world-space travel.
"""
from pathlib import Path
import sys,json,zipfile,hashlib
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A42_APPROACH_CLOSE_ATTACK_SKELETON_3F_20261101"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def load(p):return json.loads(p.read_text(encoding='utf8'))
def save(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
lk=load(R/"A42_PROVIDER_SUBMISSION_LOCK.json")
qa=load(R/"A42_APPROACH_TECHNICAL_QA.json")
assert lk["status"]=="THREE_REAL_FRAMES_RETURNED_ART_QA_PENDING"
s,r=api(key(),"/background-jobs/"+lk["job_id"])
assert s==200 and r.get("status")=="completed"
bill=(r.get("last_response") or {}).get("billing_usage")
assert bill.get("generations")==2,bill
after=balance(key());assert abs(float(after["generations"])-1693.7)<.01
record={"stage":"A42","date":"2026-11-01",
"action":"Moving to Close Attack","strictly_3_frames":"PASS",
"purpose":"SBS actor approaches enemy: sprite run-in-place only, actual world-space displacement later by Tankentai SBS engine",
"source":"A34 FS original actor01_1 45-degree battle sprite derived real PixelLab master, A40 real 18-joint skeleton",
"real_PixelLab_job":lk["job_id"],"provider_billing":bill,
"quota":{"before":1695.7,"after":1693.7,"spent":2},
"three_phase_definition":["ready guard in-place","lead leg step and torso lean","landing foot/ready close-range"],
"raw_provider_sheet":"A42_PROVIDER_REAL_3F_APPROACH_120x40.png",
"source_F0_anchored_sheet":"A42_SOURCE_ANCHORED_APPROACH_3F_CANDIDATE.png",
"preview":"A42_APPROACH_ALL_FRAMES_LARGE_PREVIEW.png",
"GIF":"A42_APPROACH_3FRAME_ONESHOT.gif",
"QA":qa,
"visual_observation":"The last two frames show slight staggered boots and lowered center, but overall movement amplitude is SMALL. Could be read as in-place shifting rather than sprint; user art review needed.",
"gates":{"source_SHA":"PASS","pixel_40x40":"PASS","120x40_3_frame":"PASS",
"no_border_clipping":"PASS","south_east_45_frame_angles":"PENDING human",
"semantic_moving_to_close_attack":"CANDIDATE, modest stride; not user approved",
"no_weapon":"PENDING visual","Tankentai_movement":"NOT IMPLEMENTED","game_formal_pass":False},
"original_FS_PM_SBS_A37_T4_UNTOUCHED":True}
save(R/"A42_FINAL_QA.json",record)
handoff=f"""# A42 Handoff: 3-frame approach to close attack via PixelLab real 18-joint control

Continue action list after A41 normal damage. User approved Dodging T4 stays unchanged. Original FS actor01_1 battle-view 45-degree source A34 remains visual authority; reuse real 18 humanoid joints from A40.
Actual PixelLab /animate-with-skeleton-v3 job {lk['job_id']}, provider completed; 3 true 40x40 transparent PNG returned, provider billed 2 generations. A42 balance 1695.7 -> 1693.7/2000. Source SHA, job lock, frame prompts, 18 joints each, output SHA recorded; no retry or duplicate generation.

ACTION semantics: Moving to Close Attack means F0 neutral -> F1 lead boot lifted and body leans southeast -> F2 planted boot/ready to attack. All EMPTY HANDS, weapon only SBS paper doll. **No actual movement of actor coordinates in this sprite sheet.** The Tankentai SBS battle script must control travel toward the target; not yet tested or modified.

Images:
- A42_PROVIDER_REAL_3F_APPROACH_120x40.png = genuine PixelLab raw three frames, no edits.
- A42_SOURCE_ANCHORED_APPROACH_3F_CANDIDATE.png = exact native A34 F0 + real v3 F1/F2.
- A42_APPROACH_3FRAME_ONESHOT.gif = 3 frames only, no infinite loop.
- A42_APPROACH_ALL_FRAMES_LARGE_PREVIEW.png = raw vs source anchored enlarged.
- A42_APPROACH_TECHNICAL_QA.json and A42_FINAL_QA.json complete checks.
The walking approach is visually subtle and needs user judgement, not claimed art PASS. Every frame south-east 45/1:1/head/legs, collision with SBS overlays, source anchor/layer/engine still require visual and runtime QA. Original FS, PMD and A37 T4 remain untouched.
"""
(R/"A42_CURRENT_HANDOFF.md").write_text(handoff,encoding='utf8')
z=R/"A42_APPROACH_CLOSE_ATTACK_3F_PRIVATE.zip"
with zipfile.ZipFile(z,'w',zipfile.ZIP_DEFLATED) as arc:
 for f in sorted(R.rglob('*')):
  if f.is_file() and f!=z:arc.write(f,f.relative_to(R))
with zipfile.ZipFile(z) as arc:
 assert arc.testzip() is None
 print("ZIP_FILES",len(arc.namelist()))
print("ZIP_SIZE",z.stat().st_size,"ZIP_SHA",sha(z),"BAL",after["generations"])
