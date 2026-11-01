from pathlib import Path
from PIL import Image,ImageDraw
import zipfile,hashlib,json,sys
ROOT=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
A25=Path(r"E:\GameAssetToolLab_20261023\A25_T1_PIXELLAB_CONCEPT_FROM_REAL_SOURCES_20261101")
sys.path.insert(0,str(A23))
from a23_one_paid_spritesheet_trial import api,key,balance
JOBS={
"PMD_IDLE":"3ff47218-0458-42e6-8f0d-e107b783a1b1",
"PMD_WALK":"c624f782-760a-42ac-9202-eb49f09e2f44",
"FS_EDIT_REFERENCE":"f40e6fc4-5be0-4848-9a83-52c700309716",
"FS_NATIVE_PIXEN":"0dec7a58-fcbc-44a2-a826-46a751a75daf"}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
jobs={}
k=key()
for label,j in JOBS.items():
 c,d=api(k,"/background-jobs/"+j)
 assert c==200
 last=d.get('last_response') or {}
 jobs[label]={'job_id':j,'status':d.get('status'),
 'usage':d.get('usage'),
 'billing_usage':last.get('billing_usage') if isinstance(last,dict) else None}
 print('JOB',label,jobs[label],flush=True)
balance_now=balance(k)
print('BALANCE_NOW',balance_now['generations'],flush=True)
# Source hash asserts
base=A25/"PMD0001"/"PIXELLAB_CONCEPT_64.png"
a25_lock=json.loads((A25/"PMD0001"/"PIXELLAB_SUBMISSION_LOCK.json").read_text(encoding='utf8'))
assert a25_lock['output_sha256']==sha(base)
fs_original=A23/"PIXELLAB_INPUTS"/"FS_ACTOR01_SOURCE_BASE_RIGHT_64.png"
for name,wh in [('IDLE',(32,40)),('WALK',(40,40))]:
 p=ROOT/("PMD_"+name)/(f"{name}_NATIVE_{wh[0]}x{wh[1]}_5F_CANDIDATE.png")
 im=Image.open(p)
 assert im.size==(wh[0]*5,wh[1]) and im.mode=="RGBA"
 frames=[Image.open(ROOT/("PMD_"+name)/f"REVIEW_CLEAN_FRAME_{n:02}.png").convert("RGBA") for n in range(5)]
 frames[0].save(ROOT/("PMD_"+name)/(name+"_5F_CANDIDATE.gif"),save_all=True,append_images=frames[1:],duration=165,loop=0,disposal=2,transparency=0)
# Compact user comparison (nearest enlargement)
page=Image.new("RGB",(1100,660),(237,240,244));d=ImageDraw.Draw(page)
def tile(img,x,y,sz=150):
 im=img.convert("RGBA")
 bg=Image.new("RGBA",im.size,(232,235,239,255));bg.alpha_composite(im)
 show=bg.convert("RGB").resize((sz,sz),Image.Resampling.NEAREST)
 page.paste(show,(x,y))
for row,act in enumerate(["IDLE","WALK"]):
 y=row*180
 d.text((12,y+12),"PMD0001 "+act+" / FIVE REAL PIXELLAB FRAMES"+(" (CLEANED)" if act=="IDLE" else ""),fill=(24,34,43))
 for i in range(5):
  p=ROOT/("PMD_"+act)/f"REVIEW_CLEAN_FRAME_{i:02}.png"
  tile(Image.open(p),i*215+15,y+30,150)
  d.text((i*215+20,y+183-12),"F"+str(i),fill=(33,35,44))
d.text((14,385),"FS CHIBI 1:1 RATIO REPAIR / UNAPPROVED CONCEPT",fill=(20,32,48))
fsimgs=[
("FS ORIGINAL",fs_original),
("A25 TALL / FAIL",A25/"FS_ACTOR01"/"PIXELLAB_CONCEPT_64.png"),
("A26 FIRST FIX / FAIL",ROOT/"FS_RATIO_REPAIR"/"FS_ACTOR01_RATIO1TO1_CONCEPT_64.png"),
("A26 NATIVE PIXEN",ROOT/"FS_NATIVE_PIXEN_RATIO_FIX"/"FS_NATIVE_RATIO_PIXEN_64_PREVIEW.png")]
for idx,(label,p) in enumerate(fsimgs):
 tile(Image.open(p),idx*270+30,420,176)
 d.text((idx*270+24,610),label,fill=(20,32,48))
contact=ROOT/"A26_USER_REVIEW_IDLE_WALK_FS_CONTACT.png"
page.save(contact)
report={
"stage":"A26", "date":"2026-11-01",
"pmd": "user approved A25 volcanic creature, full native 6-action generation not complete",
"pmd_actual_pixelLab_actions":["Idle","Walk"],
"pmd_art_gate":{"Idle":"RAW FAIL: spurious tail & black dots, processed clean candidate not yet human-approved",
"Walk":"CANDIDATE, details vary, user review pending"},
"pmd_native_cell_sheets":{"Idle":"32x40 5F","Walk":"40x40 5F"},
"pmd_xml_native_integration":"NOT DONE, 8-direction species consistent reconstruction required",
"fs_first_64x64_reference_based_fix":"FAIL: still 45px high and touches bottom",
"fs_native_40x40_pixen":"CANDIDATE: 1:1 chibi head-to-body emphasis, 34px bbox high in padded 40x40, no bottom clipping; user review",
"other_pmd_actions":"Attack, Charge, Hurt, Faint NOT YET SUBMITTED",
"pixellab_job_usage":jobs,
"post_read_balance":balance_now,
"approved_source_sha":sha(base),
"fs_original_source_sha":sha(fs_original),
"contact_sha":sha(contact),
"no_original_assets_overwritten":True}
(ROOT/"A26_QA_AND_USAGE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
handoff="""# A26 — Real PMD approved concept Sprite Sheets + FS proportional repair (2026-11-01)

PMD A25 user approved approved design used as immutable first frame for PixelLab native animation.
Generated ACTUAL 5-frame Idle and Walk using /v2/animate-with-text-v3, no repeats.
PMD Idle RAW animation includes unacceptable invented tail/black particles. FAIL. A deterministic source-locked cleanup masks all non-source silhouette pixels beyond 2px, exporting corrected first candidate; still requires user art review.
PMD Walk real five-frame animation has mild leg motion, no mask cleanup; requires user art review.
Native cell candidate frames exported Idle 32x40 x5 and Walk 40x40 x5. XML NOT modified; PMD 8 orientations and native original durations NOT verified, Attack/Cast/Hurt/Death remain ungenerated.
FS first reference-based 64x64 attempt failed to restore 1:1 proportions and clipped feet; job f40e6fc4-5be0-4848-9a83-52c700309716.
FS SECOND Pixen test uses REAL 32x32 actor frame padded inside 40x40 and exact 1:1 head/body prompt; job 0dec7a58-fcbc-44a2-a826-46a751a75daf, completed. Output 40x40 bbox (9,4,32,38) no bottom-edge alpha, and 64x64 centered preview. USER ART GATE REQUIRED.
Technical integration is NOT formal PASS. Do not treat any candidate as approved 6-action sheets. Credits and job cost in A26_QA_AND_USAGE.json.
Authoritative source originals and all PMD XML/Offsets/Shadow and FS existing sealed files remain untouched.
Private PNG and GIF stay on user's E drive. GitHub/Drive contain only text, QA and source scripts, avoiding publication of 3rd party sprites.
"""
(ROOT/"A26_CURRENT_HANDOFF.md").write_text(handoff,encoding='utf8')
zip_path=ROOT/"A26_PMD_TWO_ACTIONS_FS_RATIO_PRIVATE.zip"
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as z:
 for p in sorted(ROOT.rglob('*')):
  if p.is_file() and p!=zip_path:
   z.write(p,p.relative_to(ROOT))
with zipfile.ZipFile(zip_path) as z:
 assert z.testzip() is None
 print("ZIP_UNIQUE_FILES",len(z.namelist()),flush=True)
print("ZIP_BYTES",zip_path.stat().st_size,"ZIP_SHA256",sha(zip_path),flush=True)
print("CONTACT",contact,contact.stat().st_size,flush=True)
