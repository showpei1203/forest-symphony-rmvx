"""A28 final fail-closed QA + provider billing + private artifact bundle and handoff."""
from pathlib import Path
from PIL import Image
import sys,json,zipfile,hashlib,shutil
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
A27=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
A28=Path(r"E:\GameAssetToolLab_20261023\A28_FS_SKELETON_BATTLE_AND_FOUR_ACTIONS_20261101")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import key,balance,api
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf8'))
def save(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf8')
jobs={}
for name,lock in [
 ("FS_SKELETON40",A28/"FS_SKELETON_ATTACK"/"SUBMISSION_LOCK.json"),
 ("FS_SKELETON64",A28/"FS_SKELETON_ATTACK_64_PAD"/"SUBMISSION_LOCK.json"),
 ("FS_WALK",A28/"FS_WALK"/"SUBMISSION_LOCK.json"),
 ("FS_CAST",A28/"FS_CAST"/"SUBMISSION_LOCK.json"),
 ("FS_HURT",A28/"FS_HURT"/"SUBMISSION_LOCK.json"),
 ("FS_DEATH",A28/"FS_DEATH"/"SUBMISSION_LOCK.json")
]:
 l=read(lock);job=l.get('job_id');assert job,(name,l)
 status,obj=api(key(),"/background-jobs/"+job)
 assert status==200 and obj.get('status')=='completed'
 use=obj.get('usage') or (obj.get('last_response') or {}).get('billing_usage')
 jobs[name]={"job_id":job,"usage":use,"local_status":l.get('status'),"source_sha256":l.get('source_sha256') or l.get('sha256') or l.get('source_original_sha256')}
 print("VERIFIED",name,job,use,flush=True)
approved=A26/"FS_NATIVE_PIXEN_RATIO_FIX"/"PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png"
assert approved.exists()
approvedhash=sha(approved)
for name in ["WALK","CAST","HURT","DEATH"]:
 stat=read(A28/("FS_"+name)/"SUBMISSION_LOCK.json")
 assert stat['source_sha256']==approvedhash and stat['status']=='RENDERED_ART_REVIEW_PENDING'
 assert all(x==0 for x in stat['stats']['bottom_opaque'])
 assert stat['stats']['diffs'][0]==0
s64=read(A28/"FS_SKELETON_ATTACK_64_PAD"/"SUBMISSION_LOCK.json")
assert s64["status"]=="REAL_64_PADDED_SWORD_FRAMES"
assert all(x==0 for x in s64["right_edges"]) and all(x==0 for x in s64["edges"])
pmd_fix=read(A28/"A28_FAINT_1PX_FIX_QA.json")
assert pmd_fix["native_clipped_pixels"]==0 and pmd_fix["changed_source_pixels"]==1
quota=balance(key())
# 40x40 skeleton 3, 64x64 skeleton 3, walk/cast/hurt/death 1 each, skeleton estimate 0.1
total=round(1854.0-float(quota['generations']),2)
report={
"project":"Forest Symphony A28",
"date":"2026-11-01",
"approved_character_art":{"PMD0001_A25":"USER PASS","PMD_Idle_Walk_A26":"USER PASS","FS_actor01_A26_1to1":"USER PASS"},
"new_art_status":{"PMD_Attack_Cast_Hurt_Death":"A27 candidates, USER REVIEW PENDING","FS_Idle":"A27 candidate USER REVIEW PENDING",
"FS_Walk_Cast_Hurt_Death":"A28 candidates USER REVIEW PENDING",
"FS_Attack":"A28 skeleton 64px padded candidate, visible sword slash, no canvas-edge contact, USER REVIEW PENDING",
"FS_skeleton40_failed":"A28 stage raw pose-driven 40px touches right edge; 64px padded improved and should be user review candidate"},
"source_sha256":{"FS_approved":approvedhash},
"job_logs":jobs,
"quota":{"before":1854.0,"after":quota['generations'],"gen_spent_this_round":total,
"estimate_skeleton_approx":0.1,"skeleton40_approx":3,"skeleton64_approx":3,"four_animations_approx":4},
"technical_gates":{"FS_1_to_1_artwork":"source approved and unresized",
"FS_Idle_Walk_Attack_Cast_Hurt_Death_frames":"YES",
"FS_64pad_attack_clipping":"ZERO boundary pixels",
"FS_native_32x32_compatible":"NOT PROVEN for dynamic attack full range. SBS needs variable frame/camera offsets",
"PMD_SE_6_actions":"YES, A27 finished",
"PMD_eight_facings":"FAIL/UNFINISHED, only SE row updated",
"PMD_faint_1px":"A28 fixed 1 tail-tip pixel in a COPY, native 32x24 fits; user art approval pending",
"original_PMD_XML_offsets_shadow":"UNCHANGED",
"original_FS_files":"UNCHANGED",
"visual_pass":"NOT CLAIMED; user requested batch approval"},
"previews":{"full":"A28_PMD_AND_FS_ALL_ACTIONS_COMBINED.png",
"PMD":"A28_PMD_SIX_ACTIONS_MOBILE.png",
"FS":"A28_FS_SIX_ACTIONS_MOBILE.png",
"compact":"A28_PREVIEW_LL.webp"}
}
save(A28/"A28_FINAL_QA.json",report)
handoff=f"""# A28 FINAL HANDOFF - Real PixelLab six action review (2026-11-01)

## Approved baseline
- A25 PMD0001 orange volcanic monster concept = USER PASS.
- A26 PMD0001 Idle and Walk native candidate sheets = USER PASS.
- A26 FS $actor01 white-haired short teal-armored swordsman original 1:1 head/body, native 40x40 Pixen = USER PASS.
- Never overwrite originals nor return to A24 flat one-color shoulders/black floating species.

## Completed new animation work
- PMD 6 action Southeast-facing generated from approved source by A27, four new actions (Attack Charge Hurt Faint) remain for batch review.
- FS A27 Idle + A28 Walk, Cast, Hurt, Death, and **Attack via pose-driven animate-with-skeleton-v3** all generated.
- A28 first 40x40 skeleton Attack has sword at right edge. Superseded by 64x64 transparent padded 40px approved art, **no rescaling**, 18 joints estimated and hand skeleton animated. 6 real returned frames; sword visible F2/F3/F4; no right/bottom touching. User visual gate pending.
- FS other four actions each 5 real PixelLab frames, from same exact approved 40x40 character.
- A28 PMD Faint source width33 was repaired in a copy by removing one distal tail pixel (15,43) in final generated 64px frame; native 32x24 cell now fits with 0 clipped pixels. Other seven direction rows unchanged.
- PMD XML eight-direction full art not ready. FS original SBS _1/_2/_3 not updated. No sealed originals overwritten. Not a formal engine PASS.

## Provider IDs and quota
- FS estimate-skeleton completed: charged ~0.1 generations.
- FS skeleton40 job {jobs['FS_SKELETON40']['job_id']} charged ~3, quality had right-edge clipping.
- FS skeleton64 padded job {jobs['FS_SKELETON64']['job_id']} charged ~3, preferred Attack candidate.
- FS Walk job {jobs['FS_WALK']['job_id']} 1 gen.
- FS Cast job {jobs['FS_CAST']['job_id']} 1 gen.
- FS Hurt job {jobs['FS_HURT']['job_id']} 1 gen.
- FS Death job {jobs['FS_DEATH']['job_id']} 1 gen.
- Live balance {quota['generations']}/2000, A28 spent ~{total} gens (1854 prior).
No repeated payment on transient parser error; recovered the previously completed 40px skeleton job by ID.

## Preview for user on mobile
- A28_PMD_AND_FS_ALL_ACTIONS_COMBINED.png: all six PMD and six FS actions; original 1:1 pixel nearest scaling.
- A28_PMD_SIX_ACTIONS_MOBILE.png and A28_FS_SIX_ACTIONS_MOBILE.png: separate larger previews.
- A28_PREVIEW_LL.webp: compact lossless preview to transfer into this chat.
- Per-action FS_*.gif, source PNG and provider logs in private ZIP.

## Next handoff requirements
Wait for batch art acceptance. After acceptance, continue PMD eight-direction 34-action XML-compatible source-consistent conversion and FS Tankentai SBS action frame integration. Explicitly review generated off-axis action and 1:1 head/body stability. Never claim engine PASS before VX/Godot visual test. Third party PMD sprite files stay private on E drive, not public GitHub.
"""
(A28/"A28_CURRENT_HANDOFF.md").write_text(handoff,encoding='utf8')
archive=A28/"A28_SIX_ACTIONS_PMD_FS_PRIVATE.zip"
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for path in sorted(A28.rglob('*')):
  if path.is_file() and path!=archive:z.write(path,path.relative_to(A28))
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 print('ARCHIVE_COUNT',len(z.namelist()))
print('PACKAGE',archive,'BYTES',archive.stat().st_size,'SHA256',sha(archive),'BALANCE',quota['generations'])
