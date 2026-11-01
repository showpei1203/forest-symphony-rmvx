"""A31 final native motion handoff, preserve PixelLab raw first+second pass and FS originals.
Four exact Forest Symphony walk poses and static idle, 45deg is visual candidate only.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import zipfile,json,hashlib,shutil
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A31_FS_ORIGINAL_MOTION_TRANSFER_20261101"
A30=B/"A30_FS_SOURCE_MOTION_RIG_LOOP_20261101"
A29=B/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"
FS=Path(r"E:\RPG MAKER\260724桌面\rpg maker 2024\RPG MAKER\綠曲-V2.9\Graphics\Characters")
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
logs=[json.loads((R/f).read_text(encoding="utf8")) for f in ["TRANSFER_OUTFIT_SUBMISSION_LOCK.json","A31_SE45_EDIT_ANIMATION_SUBMISSION_LOCK.json"]]
qa=json.loads((R/"A31_SE45_SECOND_PASS_QA.json").read_text(encoding="utf8"))
assert all(l["status"].startswith(("ACTUAL_OUTFIT_TRANSFER","SECOND_PASS")) for l in logs)
assert qa["second_pass_final_footline_pass"]
assert qa["second_pass_final_cycle"]["neutral_duplicate_delta"]==0
assert qa["second_pass_final_cycle"]["bottoms"]==[38,38,38,38]
assert qa["orig"]["neutral_duplicate_delta"]==0
assert len(list(R.glob("A31_PROVIDER_TRANSFER_FRAME_*.png")))==4
assert len(list(R.glob("A31_SECOND_PASS_SE45_FRAME_*.png")))==4
source_hashes={}
for name in ["$actor01.png","$actor01_1.png","$actor01_2.png","$actor01_3.png"]:
 p=FS/name
 assert p.exists()
 source_hashes[name]=sha(p)
 if name=="$actor01.png":shutil.copy2(p,R/"FS_ORIGINAL_ACTOR01_NO_MODIFICATIONS.png")
# A30 vs A31 actual output comparison to review smoothness
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",17)
except:font=ImageFont.load_default()
oldstrip=Image.open(A30/"A30_WALK_SOURCE_RIG_FINAL_SHEET_40.png").convert("RGBA")
newstrip=Image.open(R/"A31_SE45_NATIVE_4FRAME_CYCLE_CANDIDATE.png").convert("RGBA")
original=Image.open(R/"A31_FS_ORIGINAL_TRUE_WALK_4F.png").convert("RGBA")
def loadstrip(strip,idx):w=40;return strip.crop((w*idx,0,w*(idx+1),40))
def render(idx):
 scene=Image.new("RGB",(1080,425),(234,238,242));d=ImageDraw.Draw(scene)
 d.text((10,10),"FS actor01 WALK: ORIGINAL / A30 rigid skeleton FAIL / A31 real native pose + outfit",font=font,fill=(21,35,49))
 for col,(title,fr) in enumerate([
  ("FS original walk",loadstrip(original,idx%4)),
  ("A30 joint movement (FAIL)",loadstrip(oldstrip,idx%5)),
  ("A31 source pose transfer",loadstrip(newstrip,idx%4))
 ]):
  base=Image.new("RGBA",(40,40),(234,238,242,255));base.alpha_composite(fr)
  scene.paste(base.convert("RGB").resize((322,322),Image.Resampling.NEAREST),(col*360+8,48))
  d.text((col*360+18,382),title,font=font,fill=(25,40,53))
 return scene
# 20-frame comparison, loop covers both natural durations, note time alignment is phase approximate
cycle=[render(i) for i in range(20)]
cycle[0].save(R/"A31_A30_FAILURE_VS_REAL_ORIGINAL_WALK.gif",save_all=True,
 append_images=cycle[1:],duration=150,loop=0,optimize=True)
# Static idle triple compare original, current, A30 movement F1
idle_qa=Image.new("RGB",(900,350),(236,240,244));di=ImageDraw.Draw(idle_qa)
for col,(title,p) in enumerate([
 ("ORIGINAL CENTER IDLE",R/"ORIGINAL_NATIVE_STATIC_IDLE.png"),
 ("A30 tremble candidate",A30/"A30_IDLE_SKELETON"/"RAW_FRAME_01.png"),
 ("A31 NEW STATIC IDLE",R/"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png")
]):
 im=Image.open(p).convert("RGBA")
 base=Image.new("RGBA",(40,40),(236,240,244,255));base.alpha_composite(im)
 idle_qa.paste(base.convert("RGB").resize((275,275),Image.Resampling.NEAREST),(col*300+10,25))
 di.text((col*300+12,5),title,fill=(29,44,59),font=font)
idle_qa.save(R/"A31_IDLE_ORIGINAL_A30_FAIL_A31_STATIC_COMPARISON.png")
report={
"stage":"A31","date":"2026-11-01",
"source_hashes":source_hashes,
"source_motion_geometry":"true original 32x32 FS row2 c0-c1-c2-c1; original idle static c1",
"why_A30_failed":"A30 estimated 18 joint poses replacing actual original full-body pixel motion; Idle generated unnecessary shoulder jitter and Walk looked stiff",
"method":"4 exact original FS walk pose pixel refs -> PixelLab transfer-outfit-v2 with A29 approved 40x40 unarmed teal reference -> edit-animation-v2 coherent southeast view edit",
"provider_jobs":[{"stage":("outfit_transfer" if j==0 else "direction_edit"),
   "job_id":l.get("job_id"),"billing":l.get("billing"),"status":l["status"],
   "source_sha256":l.get("source_sha256") or l.get("input_transferred_strip_sha256")} for j,l in enumerate(logs)],
"native_walk_source_diffs":qa["orig"]["adjacent_deltas"],
"after_transfer_diffs":qa["outfit_only"]["adjacent_deltas"],
"se45_final_diffs":qa["second_pass_final_cycle"]["adjacent_deltas"],
"se45_loop_seam":qa["second_pass_final_cycle"]["loop_closure_delta"],
"se45_floor_line":[38,38,38,38],
"se45_head_top":qa["second_pass_final_cycle"]["tops"],
"neutral_center_identical":True,
"source_visual_gate":"USER REVIEW PENDING, do not claim exact 45-degree pass",
"unarmed_visual_gate":"USER REVIEW PENDING",
"natural_motion_gate":"Exact poses originated from source; user needs final visual approval",
"original_$actor01_and_all_SBS_unchanged":True,
"formal_engine_test":"NOT RUN",
"pixelLab_balance":{"prior_A30":1832.8,"used_A31":20.0,"end":1812.8},
"file_montage":"A31_THREE_WALK_METHODS_NATIVE_VS_OUTFIT_VS_45.png",
"file_gif_source_vs_45":"A31_NATIVE_ORIGINAL_VS_GENERATED_WALK.gif",
"file_gif_A30_vs_A31":"A31_A30_FAILURE_VS_REAL_ORIGINAL_WALK.gif",
"file_idle":"A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png",
"file_walk":"A31_SE45_NATIVE_MOTION_WALK_LOOP.gif"
}
(R/"A31_FINAL_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
handoff=f"""# A31 Handoff — Source-motion-preserving actor01 walk / native static idle, 2026-11-01

## User rejected A30
A30 Idle shoulder wobble and A30 Walk stiff/unnatural. No more free-form skeleton animation. A30 is ART FAIL.
Authoritative original E:\\RPG MAKER\\260724桌面\\rpg maker 2024\\RPG MAKER\\綠曲-V2.9\\Graphics\\Characters\\$actor01.png and _1/_2/_3; original SHA-256 verified. 96x128 base sheet is 32x32 native cells in 3 columns and 4 direction rows.

## Exact original motion evidence
Right-facing row2 c0,c1,c2. In frame positions native feet bottom always y32, head top y1/y0/y1 and entire body moves coherently. Loop = c0-c1-c2-c1. Idle is SINGLE STATIC center c1 pose, NOT a breathing animation; A31 Idle purposely static. Original four normalized 40px source frames exist separately (copy offset x4/y6), every pixel retained from original.
Original exact source step adjacent changed pixels: {qa['orig']['adjacent_deltas']}. Exact repeated center difference 0.

## Real PixelLab executed
A31 source animation outfit transfer using A29 unarmed approved-look candidate as outfit image and four REAL original source frames: job {logs[0]['job_id']}, 10 generations; all four 40px PNG returned. This recreates clothing teal/gold while retaining ORIGINAL leg, arm, head-body pose structures.
Second pass /edit-animation-v2 on same FOUR coherently generated frames to correct sideways camera to diagonal southeast: job {logs[1]['job_id']}, 10 generations. All four 40px PNG returned. It is a visually more diagonal candidate but not mathematically verified exact 45°.
Provider sometimes renders duplicated neutral twice with small differences. Final loop selects indices (0,1,2,1); source neutral frame1 reused byte-for-byte. No new poses invented. No per-frame pixel painting; all source motions originate from actual original source. No alignment required (all four feet naturally y38).
Final 4-frame SE45 candidate step changed pixels {qa['second_pass_final_cycle']['adjacent_deltas']}, last-to-first {qa['second_pass_final_cycle']['loop_closure_delta']}; ground line [38,38,38,38].
Idle = exact NEW center frame, no shoulder/body jumps. No weapon in costume source and poses; visual approval pending.
Both original provider raw streams stored. A30/A29 preserved. Original official actor01 files unchanged.

## User preview
A31_A30_FAILURE_VS_REAL_ORIGINAL_WALK.gif | original vs A30 fail vs A31 new
A31_NATIVE_ORIGINAL_VS_GENERATED_WALK.gif | original, transferred costume, diagonal edit
A31_FS_OUTFIT_TRANSFER_REAL_SOURCE_WALK.gif | first pass genuine 4 frames
A31_SE45_NATIVE_MOTION_WALK_LOOP.gif | final genuine provider + exact neutral repeat
A31_THREE_WALK_METHODS_NATIVE_VS_OUTFIT_VS_45.png | all phase strips
A31_IDLE_ORIGINAL_A30_FAIL_A31_STATIC_COMPARISON.png | idle static difference
A31_SE45_ORIGINAL_POLICY_STATIC_IDLE.png | one 40x40 PNG
A31_FINAL_QA.json | hashes/job IDs/art gates

## Gate
Real source provenance PASS, original motion phases PASS, four-frame geometry PASS, no vertical ground drift PASS.
User visual naturalness and TRUE 45-degree southeast ART PENDING. Full Tankentai SBS paper-doll overlay NOT RUN.
Credits A31 20 generations; ending 1812.8/2000. No retries.
"""
(R/"A31_CURRENT_HANDOFF.md").write_text(handoff,encoding="utf8")
archive=R/"A31_SOURCE_MOTION_TRANSFER_PRIVATE.zip"
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
 for p in sorted(R.rglob("*")):
  if p.is_file() and p!=archive:z.write(p,p.relative_to(R))
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 print("ZIP_COUNT",len(z.namelist()))
print("ZIP_SHA256",sha(archive),"ZIP_BYTES",archive.stat().st_size)
print("ART_GATES",report["source_visual_gate"],report["formal_engine_test"])
