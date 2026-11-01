from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import zipfile,hashlib,json
R=Path(r"E:\GameAssetToolLab_20261023\A29_FS45_UNARMED_PIXELLAB_LOOP_20261101")
names=["IDLE","WALK"]
frames={}
for n in names:
 files=sorted((R/n).glob("PROVIDER_FRAME_*.png"))
 if len(files)<5:
  print("NOT_READY",n,len(files));raise SystemExit(3)
 frames[n]=[Image.open(f).convert("RGBA") for f in files]
def load(n):return json.loads((R/n/"SUBMISSION_LOCK.json").read_text(encoding="utf8"))
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",16)
except:font=ImageFont.load_default()
page=Image.new("RGB",(990,440),(240,243,246));d=ImageDraw.Draw(page)
for j,n in enumerate(names):
 y=25+j*200;d.text((15,y+75),n,font=font,fill=(18,25,36))
 for i,fr in enumerate(frames[n][:5]):
  bg=Image.new("RGBA",(40,40),(240,243,246,255));bg.alpha_composite(fr)
  page.paste(bg.convert("RGB").resize((174,174),Image.Resampling.NEAREST),(110+i*175,y))
  d.text((165+i*175,y+176),"F"+str(i),font=font,fill=(37,48,61))
page.save(R/"A29_REAL_IDLE_WALK_CONTACT.png",optimize=True)
cycle=[]
for i in range(5):
 view=Image.new("RGB",(620,370),(240,243,246));d=ImageDraw.Draw(view)
 d.text((12,10),"REAL PixelLab 45deg unarmed visual candidate - LOOP",font=font,fill=(18,31,45))
 for j,n in enumerate(names):
  y=39+j*155
  d.text((12,y+60),n,font=font,fill=(18,31,45))
  fr=frames[n][i]
  bg=Image.new("RGBA",(40,40),(240,243,246,255));bg.alpha_composite(fr)
  view.paste(bg.convert("RGB").resize((152,152),Image.Resampling.NEAREST),(120,y))
  d.text((350,y+64),f"Frame {i+1}/5",font=font,fill=(45,63,80))
 cycle.append(view)
cycle[0].save(R/"A29_BOTH_ORIGINAL_LOOPS.gif",save_all=True,append_images=cycle[1:],
 duration=165,loop=0,optimize=True)
m={n:load(n) for n in names}
report={"stage":"A29","user_requirements":{"view":"45-degree southeast visually provisional, NOT ACCEPTED","weapons":"EMPTY fists, separate SBS paper-doll","native_chibi_ratio":"1:1","loop":"actual GIF playback + quantitative seam comparison"},
 "source":"A26 approved 40px -> A29 Pixen -> PixelLab 8 rotations v3 -> visually selected 40px lossless crop",
 "source_visual_approval":"PENDING","sbs_engine_test":"NOT DONE","no_official_FS_file_overwrite":True,
 "jobs":{n:{"job_id":m[n]["job_id"],"usage":m[n].get("provider_bill"),"metrics":m[n]["metrics"]} for n in names}}
(R/"A29_LOOP_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
(R/"A29_CURRENT_HANDOFF.md").write_text(
 "# A29 genuine PixelLab 45 degree UNARMED sprite-loop trial\n"
 "User rejected self-generated illustration as rule breach; no ImageGen illustration used as an input.\n"
 "A26 approved Forest Symphony actor01 Q 1:1 used as only master.\n"
 "A29 Pixen removes sword & sheath; the initial Rotate direct result is too front-facing and FAIL.\n"
 "8-rotation V3 output direction order is ambiguous if copied from Pro API. Preserve all 8 raw images; use a visibly diagonal candidate, pending user art approval.\n"
 "Two real PixelLab 40x40 actions IDLE and WALK 5 frames are submitted from one exact selected candidate.\n"
 "Source PNGs unmodified. No original FS SBS layers or offsets changed. Keep weapon as separate paper-doll sprite.\n"
 "Two GIF loop types per action: original five frames and diagnostic ping-pong. Seam metrics are in A29_LOOP_QA.json.\n"
 "Important: technical GIF playback != art approval and != native game integration.\n",encoding="utf8")
zipf=R/"A29_REAL_PIXELLAB_45_UNARMED_LOOP_PRIVATE.zip"
with zipfile.ZipFile(zipf,"w",zipfile.ZIP_DEFLATED) as z:
 for p in sorted(R.rglob("*")):
  if p.is_file() and p!=zipf:z.write(p,p.relative_to(R))
with zipfile.ZipFile(zipf) as z:
 assert z.testzip() is None
 print("ZIP_FILES",len(z.namelist()))
print("REPORT",json.dumps({n:{"seam":m[n]["metrics"]["seam_gate"],"ratio":m[n]["metrics"]["seam_to_median_ratio"],
"bottom":m[n]["metrics"]["bottom_gate"]} for n in names}))
print("ZIP_SHA",hashlib.sha256(zipf.read_bytes()).hexdigest())
for p in ["A29_BOTH_ORIGINAL_LOOPS.gif","A29_REAL_IDLE_WALK_CONTACT.png"]:
 q=R/p;print("OUTPUT",p,q.stat().st_size)
