"""A27 readback/report/package for PMD six Southeast action candidates and FS 1:1 action trials."""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,zipfile,shutil,sys
R=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
A25=Path(r"E:\GameAssetToolLab_20261023\A25_T1_PIXELLAB_CONCEPT_FROM_REAL_SOURCES_20261101")
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
G9=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025\outputs\P3_G9_FULL_0001_0002_0003_EVOLUTION_20261027\0001")
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,data):p.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf-8")
PMD=["idle","walk","attack","cast","hurt","death"]
native=json.loads((R/"PMD_XML_SE_ONLY_CANDIDATES"/"A27_XML_SE_ONLY_COMPILE_QA.json").read_text(encoding="utf8"))
assert set(native)==set(PMD)
report={"stage":"A27","date":"2026-11-01","approval_gate":{
"A25_PMD0001_character":"USER_APPROVED",
"A26_PMD_IDLE_AND_WALK":"USER_APPROVED",
"A26_FS_ACTOR01_1TO1_NATIVE_CHARACTER":"USER_APPROVED",
"A27_new_actions":"USER_REVIEW_PENDING"},
"warnings":["A27 native XML image candidate modifies ONLY Southeast row; other seven rows are previous G9 sprites, NOT matching newly approved A25 evolution",
"Native PMD action durations do NOT equal new five-frame PixelLab playback durations; retiming repeats/skips frames",
"Faint last generated frame needs width33 pixels in native width32, 1 pixel clipping presently fails lossless gate",
"All originals, native PMD AnimData.xml, Offsets, Shadow and sealed FS game assets untouched"],
"pmd_actions":{},"fs_actions":{}}
approved=A25/"PMD0001"/"PIXELLAB_CONCEPT_64.png"
fs_approved=A26/"FS_NATIVE_PIXEN_RATIO_FIX"/"PIXEL_LAB_FS_NATIVE_RATIO_CANDIDATE_40.png"
assert approved.exists() and fs_approved.exists()
for src,name in [(approved,"A25_USER_APPROVED_PMD0001_64.png"),(fs_approved,"A26_USER_APPROVED_FS_ACTOR01_40.png")]:
 shutil.copy2(src,R/name)
for idx,a in enumerate(PMD):
 name={"idle":"Idle","walk":"Walk","attack":"Attack","cast":"Charge","hurt":"Hurt","death":"Faint"}[a]
 d=A26/("PMD_"+a.upper())
 lock=json.loads((d/"SUBMISSION_LOCK.json").read_text(encoding="utf8"))
 assert lock["status"]=="SHEET_RENDERED_ART_GATE_PENDING"
 assert lock["source_sha256"]==sha(approved)
 atlas=R/"PMD_XML_SE_ONLY_CANDIDATES"/(name+"_8ROW_SE_ONLY_XML_GEOMETRY_CANDIDATE.png")
 assert atlas.exists()
 assert native[a]["unchanged_other_seven_directions"]
 report["pmd_actions"][a]={"native_action":name,"provider_job_id":lock.get("job_id"),
 "actual_provider_frames":lock.get("actual_frames"),"native_action_frames":native[a]["native_frame_count"],
 "source_sha256":lock["source_sha256"],"native_cell":native[a]["cell"],
 "atlas_sha256":sha(atlas),"clipped_pixels":native[a]["total_clipped_pixels"],
 "disconnected_components_removed":native[a]["provider_disconnected_removed"],
 "status":"ART_CANDIDATE" if native[a]["total_clipped_pixels"]==0 else "FAIL_CLOSED_CLIPPED_PIXEL"}
 # copy raw and corrected 5-frame strips into A27 to make standalone handoff
 origin=d/"PIXELLAB_SPRITESHEET_64x5.png"
 target=R/f"PMD_{name}_A27_PROVIDER_RAW_5F.png";shutil.copy2(origin,target)
 clean=R/"PMD_XML_SE_ONLY_CANDIDATES"/(name+"_SE45_CLEAN_64x5.png")
 # Frame-level 5 x 64
 if clean.exists():
  frames=[Image.open(clean).crop((i*64,0,(i+1)*64,64)).convert("RGBA") for i in range(5)]
  frames[0].save(R/f"PMD_{name}_A27_REVIEW.gif",save_all=True,append_images=frames[1:],
   duration=180,loop=0,disposal=2)
for act in ("IDLE","ATTACK"):
 d=R/("FS_"+act)
 f=d/"SUBMISSION_LOCK.json"
 if not f.exists():
  report["fs_actions"][act]={"status":"MISSING_SUBMISSION"};continue
 rec=json.loads(f.read_text(encoding="utf8"))
 if rec.get("approved_source_sha256")!=sha(fs_approved):
  raise RuntimeError("FS source mismatch, cannot package")
 report["fs_actions"][act]={"status":rec["status"],"job_id":rec.get("job_id"),
   "size":[40,40],"frames":rec.get("frames"),"bbox_by_frame":rec.get("bbox_by_frame"),
   "bottom_alpha":rec.get("bottom_edge_opaque_by_frame"),
   "pixel_diffs":rec.get("diff_pixels_vs_approved_source"),
   "source_sha256":rec.get("approved_source_sha256"),
   "sheet_sha256":rec.get("sheet_sha256")}
 sheet=d/"ACTUAL_NATIVE_40_SPRITESHEET.png"
 if sheet.exists():
  src=Image.open(sheet).convert("RGBA")
  tiles=[src.crop((i*40,0,(i+1)*40,40)) for i in range(src.width//40)]
  tiles[0].save(R/f"FS_{act}_A27_REVIEW.gif",save_all=True,append_images=tiles[1:],duration=170,loop=0,disposal=2)
# A27 mobile review: compact rows
page=Image.new("RGB",(760,1200),(236,239,242));draw=ImageDraw.Draw(page)
for row,a in enumerate(PMD):
 name={"idle":"Idle","walk":"Walk","attack":"Attack","cast":"Charge","hurt":"Hurt","death":"Faint"}[a]
 title=f"PMD {name}: 5 actual frames (A27 cleaned if needed)"
 if a in ("idle","walk"):title+=" | A26 USER APPROVED"
 draw.text((12,row*130+5),title,fill=(26,35,47))
 strip=Image.open(R/"PMD_XML_SE_ONLY_CANDIDATES"/(name+"_SE45_CLEAN_64x5.png")).convert("RGBA")
 for i in range(5):
  frame=strip.crop((i*64,0,i*64+64,64))
  bg=Image.new("RGBA",(64,64),(236,239,242,255));bg.alpha_composite(frame)
  disp=bg.convert("RGB").resize((118,118),Image.Resampling.NEAREST)
  page.paste(disp,(i*149+10,row*130+15))
for j,act in enumerate(("IDLE","ATTACK")):
 y=780+j*188
 draw.text((12,y+2),f"FS {act}: native 40x40 chibi head/body 1:1 | NEW ANIMATION REVIEW",fill=(26,35,47))
 f=R/("FS_"+act)/"ACTUAL_NATIVE_40_SPRITESHEET.png"
 if f.exists():
  strip=Image.open(f).convert("RGBA")
  for i in range(min(5,strip.width//40)):
   tile=strip.crop((i*40,0,(i+1)*40,40))
   bg=Image.new("RGBA",(40,40),(236,239,242,255));bg.alpha_composite(tile)
   page.paste(bg.convert("RGB").resize((136,136),Image.Resampling.NEAREST),(i*149+10,y+19))
contact=R/"A27_PMD_6_ACTIONS_FS_TWO_ACTIONS_MOBILE_REVIEW.png"
page.save(contact,optimize=True)
report["contact_sha256"]=sha(contact)
# Verify native first dimension; 7 unchanged rows already asserted by compiler.
report["native_technical_check"]="SE_ONLY_6_OF_6; NOT FULL ART COMPLETE; 7 OTHER FACINGS OUTDATED"
report["approved_pmd_source_sha256"]=sha(approved)
report["approved_fs_source_sha256"]=sha(fs_approved)
report["credit_cost"]="To be verified from provider job billing before claiming totals"
save(R/"A27_CURRENT_QA.json",report)
(R/"A27_CURRENT_HANDOFF.md").write_text("""# A27 Pmd 6 action SE trial + FS actor01 1:1 animation
2026-11-01. A25 PMD volcanic design, A26 PMD Idle/Walk animations and A26 FS native 1:1 swordsman visual ACCEPTED BY USER.
A27 followed this approval: generated PixelLab Attack, Charge, Hurt, Faint 5-frame PNGs, source A25 approved PMD one-frame PNG, no original asset overwrite.
Idle & Walk approved from A26. NEW four generated actions await user art review. Detached rock blobs from Attack/Hurt automatically filtered by largest connected animal component; raw provider strips preserved untouched.
Created 6 full native-format PMD action PNG atlas candidates with only row1 Southeast replaced, re-timing 5 provider frames to native frame counts Idle3 Walk6 Attack11 Charge10 Hurt2 Faint4. Other seven directions unchanged from legacy G9 and do not match current approved new PMD character. XML/Offsets/Shadow NOT overwritten, so formal PMD engine integration DOES NOT PASS. Faint last frame needs 33px vs native 32px width and loses one pixel: FAIL pixel-crisp gate.
A27 FS both Idle and Attack are native 40x40 PixelLab animation tests using EXACT A26 user-approved Pixen chibi 1:1 frame. Their action and clipping QA in A27_CURRENT_QA.json. These new animations are not yet user approved. FS SBS sheet _1/_2/_3 not modified or integrated.
Preview A27_PMD_6_ACTIONS_FS_TWO_ACTIONS_MOBILE_REVIEW.png; private ZIP available locally.
No third party PNG uploaded to public GitHub. Only code, QA and handoff docs. More complete work requires real eight-direction visual mapping, and proportion stability over full attack/cast/hurt/death FS.
""",encoding="utf8")
archive=R/"A27_PRIVATE_PMD6_FS2_AND_XML_GEOMETRY.zip"
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
 for item in sorted(R.rglob("*")):
  if item.is_file() and item!=archive:
   z.write(item,item.relative_to(R))
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 count=len(z.namelist())
print(json.dumps({"stage":"A27","new_pmd":list(PMD[2:]),"fs_status":report["fs_actions"],
  "faint_clipped":native["death"]["total_clipped_pixels"],"pack_files":count,
  "zip":str(archive),"bytes":archive.stat().st_size,"sha256":sha(archive)},ensure_ascii=False,indent=2))
