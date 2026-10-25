from pathlib import Path
import zipfile,shutil,hashlib,json,xml.etree.ElementTree as ET,subprocess,sys
from PIL import Image
import numpy as np
ROOT=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
B=ROOT/"outputs/P3_R2_0001_UPSTREAM_PMD_20261026"
SRC=B/"official_0001";DRV=B/"STONEBACK_DERIVATIVE_0001"
TREE=ROOT/"deliveries/P3_R2_0001_STONEBACK_SOURCE_XML_20261026"
ZIP=ROOT/"deliveries/P3_R2_0001_STONEBACK_SOURCE_XML_20261026.zip"
if TREE.exists() or ZIP.exists():raise RuntimeError("Never overwrite candidate deliveries")
TREE.mkdir(parents=True)
shutil.copytree(SRC,TREE/"SOURCE_0001",dirs_exist_ok=False)
shutil.copytree(DRV,TREE/"STONEBACK_0001",dirs_exist_ok=False)
for f in ("P3_R2_STONEBACK_COMPARE_ACTIONS.png","P3_R2_SOURCE_FRAME_AUDIT.json","DOWNLOAD_MANIFEST.json"):
 shutil.copy2(B/f,TREE/f)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
# Real animated previews at explicit frame timings from unchanged XML, direction 2 (right-facing).
root=ET.parse(DRV/"AnimData.xml").getroot()
for name in ("Idle","Walk","Attack"):
 e=next(x for x in root.findall(".//Anim") if x.findtext("Name")==name)
 fw,fh=int(e.findtext("FrameWidth")),int(e.findtext("FrameHeight"))
 ticks=[int(x.text) for x in e.find("Durations").findall("Duration")]
 im=Image.open(DRV/(name+"-Anim.png")).convert("RGBA")
 assert im.size==(fw*len(ticks),fh*8)
 frames=[im.crop((j*fw,2*fh,(j+1)*fw,3*fh)).resize((fw*4,fh*4),Image.Resampling.NEAREST) for j in range(len(ticks))]
 # transparent indexed GIF palette via RGBA quantize to RGB on neutral background
 gifs=[]
 for f in frames:
  bg=Image.new("RGBA",f.size,(35,39,50,255))
  bg.alpha_composite(f)
  gifs.append(bg.convert("RGB").quantize(colors=64,method=Image.Quantize.FASTOCTREE))
 gifs[0].save(TREE/(name+"_STONEBACK_ANIM_PREVIEW.gif"),save_all=True,append_images=gifs[1:],
              duration=[max(60,int(n*1000/60)) for n in ticks],loop=0,disposal=2,optimize=False)
# Full fail-closed source and derivative record: per action exact XML dimensions, cell alpha, original offsets.
defs=[]
for a in root.findall(".//Anim"):
 n=a.findtext("Name");cp=a.findtext("CopyOf")
 if cp:
  defs.append({"name":n,"copy_of":cp})
  continue
 fw,fh=int(a.findtext("FrameWidth")),int(a.findtext("FrameHeight"))
 count=len(a.find("Durations").findall("Duration"))
 a0=np.asarray(Image.open(SRC/(n+"-Anim.png")).convert("RGBA"))
 a1=np.asarray(Image.open(DRV/(n+"-Anim.png")).convert("RGBA"))
 if a0.shape!=a1.shape or a0.shape[1]!=fw*count or a0.shape[0]%fh!=0:raise AssertionError(n)
 if not np.array_equal(a0[:,:,3],a1[:,:,3]):raise AssertionError("alpha drift "+n)
 if not np.any(a0[:,:,:3]!=a1[:,:,:3]):raise AssertionError("No species change "+n)
 for ending in ("Offsets","Shadow"):
  f=n+"-"+ending+".png"
  if sha(SRC/f)!=sha(DRV/f):raise AssertionError("xml geometry metadata changed "+f)
 defs.append({"name":n,"cell":[fw,fh],"frames":count,"facing_rows":a0.shape[0]//fh,
              "atlas":[a0.shape[1],a0.shape[0]],"alpha_exact":True,"offsets_exact":True,"shadow_exact":True})
if sha(SRC/"AnimData.xml")!=sha(DRV/"AnimData.xml"):raise AssertionError("Original XML differs")
report={"XML_UNCHANGED":True,"XML_ACTIONS":len(defs),"ANIMATION_FILES":len(list(DRV.glob("*-Anim.png"))),
        "PALETTE_AND_FACETS":"GRAY_ROCK_MINERAL_BACK + AMBER_EYES","SOURCE_AND_DERIVATIVE_ALPHA_EXACT":True,
        "XML_OFFSETS_SHADOW_BITWISE_UNCHANGED":True,
        "FRAME_GRID_AND_FRAME_ANCHORS_UNCHANGED":True,"OFFICIAL_RUNTIME_IMPORT":"NOT_TESTED",
        "USER_VISUAL":"PENDING","ACTION_DEFINITIONS":defs}
(TREE/"VERIFY_RESULTS.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
(TREE/"README.md").write_text("""# P3_R2_STONEBACK 0001: Authentic original PMD format derivative
Based on PMDCollab/SpriteCollab/sprite/0001 (original fan sprite repository, with mandatory contributor credits). Source remains untouched in SOURCE_0001; every original animation and metadata file exists in STONEBACK_0001 with exactly the same filenames and directory layout.
- Actual new species treatment: original green seed body turned gray/rock, dark mineral stone facets across original bulb region on each source frame, bright amber eyes. Not a merely subtle green color shift.
- Full **AnimData.xml byte-identical**, full -Offsets.png and -Shadow.png byte-identical; every animation atlas and per-cell RGB/alpha position audited. This is **structurally XML-compatible**, but an import into the real target PMD/VX runtime has not yet been executed and remains pending.
- 34 actual action sheets, 36 XML action names including 2 CopyOf, varying per-action frame counts/directions. No guessed equal global frame grid. Three XML-timed GIF previews Idle, Walk and Attack.
- Previous FAIL from assuming every action has eight facing rows: Sleep contains one; the mistaken partial output is archived outside this ZIP.
- This sample intentionally does not alter sprite footprint or anchors; source rock retains largely the same silhouette. Visually judge whether the mineral replacement is sufficiently distinct before producing the next creature.
- Rights: PMDCollab is an independent resource mixing official and fan sprites. Attribution is required, commercial publication rights NOT established by this pipeline.
- No PixelLab, SpriteCook, other paid credits, or copyrighted asset redistribution to public GitHub. Private ZIP only.
""",encoding="utf-8")
(TREE/"CURRENT_HANDOFF.md").write_text("""# Handoff: P3_R2_0001 Stoneback, 2026-10-26
Previous P3 change too subtle and imagegen mock atlas not canonical. Real source now found from PMDCollab/SpriteCollab master sprite/0001, 103 files and native AnimData.xml, 36 named XML motions (34 real files, two CopyOf). Source and derivative are separate full folders, every XML/Offsets/Shadow checksum matches. Geometry/per-frame alpha unchanged while every action RGB edited to slate rock / eye amber / bulb mineral highlights. First pipeline mistakenly treated Sleep as 8 rows and failed; original error saved. New one reads exact source row count (not global assumptions).
Human visuals NOT APPROVED yet; PMD and VX runtime XML parser imports NOT TESTED. Next: user review of stone vs original; inspect actual frame playback and original XML import into supported engine. F2_R3 concept map separately pending Human Art style acceptance and has not been layered into Ground/PAR engine.
Update rules on GitHub/Drive/Linear. Keep F1R1 reference user-accepted, F2/P2R1 rejected styles permanently FAIL. Do not run paid generators.
""",encoding="utf-8")
(TREE/"RULES_UPDATE.md").write_text("""# P3 New Authority Update 2026-10-26
- For official-format 0001 use actual PMDCollab source AnimData.xml + action PNG/Offset/Shadow triplets, not the 864×1920 CG_PMD native sheet as substitute for exact XML compatibility.
- Each XML animation may have different frame size, direction row count, frame counts, and CopyOf references. Infer no universal atlas grid.
- Keep XML, Offset, Shadow files byte-for-byte; preserve action names, frame cell rectangles and alpha. Edit all image actions, not a subset. Distinct species requires noticeable body/seed-to-rock morphology/color at readable scale.
- Any parser/import test not run is NOT PASS, even when XML hash matches.
- Private fan sprite derivative with attribution required; commercial rights need separate permission.
- Keep all prior FAIL logs; no user Human Visual PASS before explicit approval.
""",encoding="utf-8")
(TREE/"NEXT_CHAT_PROMPT.txt").write_text("接續 P3_R2 PMD 0001 石背蛙：已下載官方SpriteCollab 103檔、XML36名稱34真動作，STONEBACK_0001每格α位置一致、源XML/Offsets/Shadow檔位元組相同；不是擅自編排的864x1920轉接圖。需要人眼確認岩石外觀，再測真正PMD/VX XML parser實機。F2_R3高精緻度精靈村概念靜態圖仍需分層工程，不要視作已完成VX Ground+PAR。所有版本含handoff/ZIP/LOG同步Drive/GitHub/Linear，F1R1保持已驗收凍結。",encoding="utf-8")
checks=[]
for f in sorted(TREE.rglob("*")):
 if f.is_file() and f.name!="CHECKSUMS.json":
  checks.append({"name":f.relative_to(TREE).as_posix(),"sha256":sha(f),"bytes":f.stat().st_size})
(TREE/"CHECKSUMS.json").write_text(json.dumps(checks,indent=2),encoding="utf-8")
with zipfile.ZipFile(ZIP,"w",zipfile.ZIP_DEFLATED,compresslevel=7) as z:
 for f in sorted(TREE.rglob("*")):
  if f.is_file():z.write(f,f.relative_to(TREE).as_posix())
with zipfile.ZipFile(ZIP) as z:
 assert z.testzip() is None
 n=len(z.infolist())
C=ROOT/"outputs/P3_R2_COLD_EXTRACT_20261026"
assert not C.exists()
with zipfile.ZipFile(ZIP) as z:z.extractall(C)
for item in checks:
 assert sha(C/item["name"])==item["sha256"],item["name"]
print(json.dumps({"zip":str(ZIP),"size":ZIP.stat().st_size,"sha256":sha(ZIP),"files":n,"cold_sha":"PASS",
                  "xml_unchanged":True,"action_sheets":34,"action_names":36}))
