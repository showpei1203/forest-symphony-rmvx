from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,zipfile,hashlib,sys
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101"
A34=BASE/"A34_FS_BATTLE45_F0_CORRECTION_20261101"
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import key,api,balance
def ld(p):return json.loads(p.read_text(encoding="utf8"))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding="utf8")
paths={
 "guard_to_roll":R/"SEGMENT_A2_GUARD_TO_ROLL"/"SUBMISSION_LOCK.json",
 "roll_to_guard":R/"SEGMENT_B_ROLL_TO_GUARD"/"SUBMISSION_LOCK.json"}
jobs={}
for name,p in paths.items():
 o=ld(p)
 assert o["status"]=="PROVIDER_FRAMES_RETURNED_ART_QA_PENDING",o
 s,r=api(key(),"/background-jobs/"+o["job_id"])
 assert s==200 and r.get("status")=="completed",name
 bill=(r.get("last_response") or {}).get("billing_usage")
 assert bill.get("generations")==10,(name,bill)
 jobs[name]={"job_id":o["job_id"],"billing":bill,"frame_count":o["frame_count"],
             "raw_sha256":o["sheet_sha256"]}
 print("PROVIDER_VERIFIED",name,jobs[name],flush=True)
bal=balance(key());assert abs(float(bal["generations"])-1741.8)<.01,bal
qa=ld(R/"A35_INTERPOLATION_FULL_QA.json")
cur=ld(R/"A35_CURATED_18FRAME_QA.json")
assert qa["true_provider_frames_A"]==qa["true_provider_frames_B"]==14
assert cur["source_battle_F0_equals_F2"] and cur["real_pixelLab_frames_only"]
# Side-by-side GIF: 3-frame A34 original vs 18 frame A35 semantic selection (not exact tempo in A34).
src=Image.open(A34/"A34_NATIVE_F0_EXACT_VIEW_LOCK_CANDIDATE_3FRAMES.png").convert("RGBA")
dst=Image.open(R/"A35_SEMANTIC_SELECTED_PROVIDER_ONLY_18FRAME.png").convert("RGBA")
frames=[]
try:F=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",18)
except:F=ImageFont.load_default()
for i in range(18):
 box=Image.new("RGB",(700,340),(238,242,246));d=ImageDraw.Draw(box)
 d.text((20,8),"A34: 3 key poses | A35: native-view source + 28 real PixelLab in-betweens",font=F,fill=(20,32,48))
 left=src.crop((((i//6)%3)*40,0,((i//6)%3+1)*40,40))
 right=dst.crop((i*40,0,(i+1)*40,40))
 for j,im in enumerate([left,right]):
  bg=Image.new("RGBA",(40,40),(238,242,246,255));bg.alpha_composite(im)
  box.paste(bg.convert("RGB").resize((272,272),Image.Resampling.NEAREST),(j*350+40,43))
  d.text((j*350+90,315),"A34 original" if j==0 else f"A35 frame {i+1}/18",font=F,fill=(30,43,58))
 frames.append(box)
frames[0].save(R/"A35_A34_3FRAME_VS_A35_18FRAME.gif",save_all=True,append_images=frames[1:],
 duration=85,loop=1,disposal=2,optimize=True)
notes={
 "stage":"A35","date":"2026-11-01",
 "source":"A34 true native FS $actor01_1 battle-view PixelLab teal unarmed master F0/F2 and exact screenshot-driven PixelLab dodge F1",
 "goal":"Physical/pose continuity instead of 3-to-3 abrupt frame flip",
 "first_rejected_http422":"action exceeded PixelLab maximum 500 char string; rejected by schema, no accepted job",
 "real_paid_jobs":jobs,
 "generation_budget":{"before":1761.8,"spent":20.0,"after":bal["generations"],"plan":2000},
 "provider_raw_frames":28,
 "candidate_assemblies":{
  "dense":"31 frames: original F0 + provider14 + exact F1 + provider14 + exact F2",
  "sparse":"17 frames: original F0 + 7x providerA + exact F1 + 7x providerB + exact F2",
  "semantic":"18 frames: exact F0, 8 source-derived A progression, exact real F1, 7 source-derived B progression, exact F2",
 },
 "verifications":{
  "raw_40x40_transparent":"PASS","no_right_bottom_clipping":"PASS","original_key_F0_F2_pixel_identical":"PASS",
  "human_motion_naturalness":"PENDING","per_frame_45degree":"PENDING","paper_doll_sbs_overlay":"NOT TESTED",
  "full_vx_godot_engine":"NOT TESTED","art_status":"CANDIDATE, not formal PASS"},
 "technical_issues":{
  "AI_interpolated_endpoints_not_pixel_identical":"Start↔providerA[0] diff602, providerA[-1]↔key F1 diff558, providerB[-1]↔exact F2 diff550",
  "nonmonotonic_A":"Frames A8-A13 show prone pause after upside-down goal; omit from semantic candidate",
  "nonmonotonic_B":"B5-B6 briefly flip upside down after recovery posture achieved; omit from semantic candidate",
  "seam_discontinuity":"Curated candidate max adjacent pixel difference648; requires visual timing review"},
 "all_orig_file_unmodified":True,
 "raw_outputs_preserved":True,
 "next":"Visual art review of 18-frame real-source one-shot, confirm 45degree for every frame and weapon separation, adjust semantic frame selection / timing without paid calls; then if needed battle animation normalization, no blind rerolls."}
save(R/"A35_FINAL_QA.json",notes)
handoff=f"""# A35 Forest Symphony native 45-degree Dodging interpolation / Handoff

## Source provenance
A34 real PixelLab battle-view teal unarmed F0/F2, built from original FS $actor01_1 r1/r2 c1 actual native pixel poses. F1 is A34 source-checked user Dodging pose reference controlled REAL PixelLab generated head-down/tumble. NO A33 wrong-facing F0 source used.
The original images are preserved; only new files under E:\\GameAssetToolLab_20261023\\A35_DODGE_NATIVE45_MOTION_CONTINUITY_20261101.

## API findings and actual work
PixelLab /interpolation-v2 accepts start_image + end_image + action (MAX 500 chars) and image_size.
A35 first overlong action HTTP422, not accepted, no credits. Short action accepted as true source F0→F1: job {jobs['guard_to_roll']['job_id']}, 14 genuine PixelLab 40x40 transparent PNGs, billed10 generations.
Second source F1→F0: job {jobs['roll_to_guard']['job_id']}, 14 more genuine PNGs, billed10 generations.
API endpoints redraw original keyframes, so do NOT automatically trust generated endpoints. Anchor originals exact, no manual painting.
Source F0 and F2 are byte identical. 40x40 geometry and border check PASS, meaning no right/bottom edge cropping.

## Visual analysis
A full 31-frame assembly is too long. Provider A8-A13 lingers prone AFTER inversion, B5-B6 temporarily return upside down AFTER standing. These are genuine generation FAIL artifacts, not animation creativity.
A curated semantic 18-frame demonstration selects provider indices A0..A7 and B0..B4,B7,B8 and inserts exact source F0/F1/F2. No painting/retouching, no invented animation frames; all provider raw 28 frames saved. Since interpolation still morphs head orientation/body, technical asset provenance PASS but art & camera angle still USER REVIEW PENDING, SBS engine NOT RUN.
- A35_SEMANTIC_SELECTED_DODGING_ONESHOT.gif (18-frame candidate, one-shot).
- A35_A34_3FRAME_VS_A35_18FRAME.gif (A34 crude pose vs A35 real inbetweens).
- A35_ALL_INTERPOLATED_REAL_FRAMES_QA_MONTAGE.png (30 frames incl exact source keys).
- A35_18FRAME_CURATED_REAL_PROVIDER_REVIEW.png (18 actual selected frames).
- A35_INTERPOLATION_FULL_QA.json and A35_FINAL_QA.json.
Last and first frame of 18 are an exact same 45 battle sprite from A34. The full action is ONE SHOT, no requirement to animate endlessly.

## Balance
From 1761.8 to {bal['generations']} / 2000, exactly 20 generations charged (10 per accepted interpolation job). Both job IDs and provider bills read back. Previous 422 rejected call not charged. No duplicate accepted jobs.

## Formal gates
Native source/SHA and real provider generation PASS. 40px sprite and no border crop PASS.
Dodge motion naturalness, exact per-frame southeast 45° view and visible character identity/weapon-free details still need art review. Full Tankentai SBS weapon paper-doll layer and VX engine not tested. No official FS/PMD/SBS file overwritten.
"""
(R/"A35_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
zipfile_path=R/"A35_NATIVE45_DODGE_INTERPOLATION_PRIVATE.zip"
with zipfile.ZipFile(zipfile_path,"w",zipfile.ZIP_DEFLATED) as z:
 for p in sorted(R.rglob("*")):
  if p.is_file() and p!=zipfile_path:z.write(p,p.relative_to(R))
with zipfile.ZipFile(zipfile_path) as z:
 assert z.testzip() is None
 print("ZIP_COUNT",len(z.namelist()))
print("ZIP_BYTES",zipfile_path.stat().st_size,"ZIP_SHA256",sha(zipfile_path))
print("A35_QUOTA",notes["generation_budget"])
