from pathlib import Path
from PIL import Image
from collections import deque
import json,hashlib,zipfile
ROOT=Path(r"E:\GameAssetToolLab_20261023\A24_SOURCE_FIRST_ART_APPROVAL")
MAN=json.loads((ROOT/"A24_ART_APPROVAL_MANIFEST.json").read_text(encoding="utf-8"))
files=sorted(ROOT.glob("A24_*.png"))
report=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for p in files:
 im=Image.open(p)
 report.append({"file":p.name,"dim":im.size,"mode":im.mode,"sha256":sha(p)})
for k in ("A","B"):
 p=Image.open(ROOT/f"A24_PMD0001_{k}_NATIVE_IDLE_32x40.png").convert("RGBA")
 c=Image.open(ROOT/("A24_PMD0001_VOLCANIC_TOAD_A_64.png" if k=="A" else "A24_PMD0001_HORNED_LAVAFROG_B_64.png")).convert("RGBA")
 assert p.size==(32,40)
 assert p.tobytes()==c.crop((16,12,48,52)).tobytes()
 assert c.getbbox()[0]>=16 and c.getbbox()[2]<=48
 assert c.getbbox()[1]>=12 and c.getbbox()[3]<=52
for k in ("AETHER","EMBER"):
 sheet=Image.open(ROOT/f"A24_FS_ACTOR01_{k}_NATIVE_WALK_96x128.png").convert("RGBA")
 battle=Image.open(ROOT/f"A24_FS_ACTOR01_{k}_BATTLE_SOURCE_64.png").convert("RGBA")
 assert sheet.size==(96,128) and battle.size==(64,64)
 # Battle uses the newly outfitted native frame, with intentional new weapon pixels.
 srcpixels=list(sheet.crop((32,64,64,96)).getdata())
 battlepixels=list(battle.crop((16,19,48,51)).getdata())
 identical=sum(a==b for a,b in zip(srcpixels,battlepixels))
 assert identical>=930,(k,"battle identity drift",identical)
 for row in range(4):
  for col in range(3):
   assert sheet.crop((col*32,row*32,(col+1)*32,(row+1)*32)).getbbox(),(k,row,col)
 assert battle.getbbox()[0]>=0 and battle.getbbox()[2]<=64
assert sha(Path(MAN["source_paths"]["pmd"]))==MAN["source_sha256"]["pmd"]
assert sha(Path(MAN["source_paths"]["fs"]))==MAN["source_sha256"]["fs"]
extra={
 "stage":"A24",
 "qa_geometry":"PASS",
 "qa_unmodified_original_sha256":"PASS",
 "qa_source_based":"PASS, all designs are pixel edits from exact A23 source",
 "qa_visual":"VISUAL CANDIDATE, AWAITING USER, NOT FORMAL G7 PASS",
 "qa_frame_animation":"NOT GENERATED: FS walk is a redressed native 3x4 existing animation; PMD is one edited idle reference only",
 "qa_pmd_34_actions":"NOT UPDATED: A24 design changes must be propagated after user approves concept",
 "qa_pmd_xml":"UNCHANGED IN A23, not modified A24",
 "qa_skeleton_rotated_45":"NOT TESTED",
 "qa_pixelLab":"ZERO CALLS; blocked until user approves",
 "qa_quota_used":0,
 "source_hashes":MAN["source_sha256"],
 "outputs":report
}
(ROOT/"A24_QA_READBACK.json").write_text(json.dumps(extra,ensure_ascii=False,indent=2),encoding="utf-8")
note="""# A24 User Art Gate (2026-11-01)
Derived from real A23 PMD0001 G9 lava-frog reference and real Forest Symphony $actor01, not invented art.

- PMD A: armored volcanic toad, visible volcano chimney, lava cracks, basalt shell/cheeks/feet.
- PMD B: horned lava frog with prominent forked obsidian spines, armor and heated edge.
- FS A: blue-haired aether sword fighter, blue plate armor and cape, energy sword.
- FS B: red-haired ember fighter, red/black armor and cape, molten blade.
- Both FS have full recolored and composited native 96x128 3x4 four-direction walk-sheet candidates, not merely a sword on old clothes.
- Source PMD frame for BOTH edited reference sprites remains native 32x40. AnimData.xml, offsets and shadows unmodified.
- FS battle references still use A23 right facing row2; true 45-degree angle, animation/frame cleanup, and Kaduki _1/_2/_3 require separate validation.
- Candidate PNGs in same local directory. User must select design or demand revision before any PixelLab API POST or credits.
- PMD 34 native action atlases are NOT redrawn in A24. This is the planned design gate, not an attempt to claim all actions complete.
- No original source or sealed game artwork modified. Do not upload third-party licensed sprite images to public GitHub.
"""
(ROOT/"A24_CURRENT_HANDOFF.md").write_text(note,encoding="utf-8")
p=ROOT/"A24_PRIVATE_ART_APPROVAL_CONCEPTS.zip"
with zipfile.ZipFile(p,"w",zipfile.ZIP_DEFLATED) as z:
 for f in sorted(ROOT.iterdir()):
  if f.is_file() and f!=p and f.name not in ("source_stats.json",):
   z.write(f,f.name)
with zipfile.ZipFile(p) as z:
 assert z.testzip() is None
 print("ZIP_CONTENT_COUNT",len(z.namelist()))
print(json.dumps({"qa":"PASS source/geometry/CRC, artistic user gate pending","zip":str(p),"zip_bytes":p.stat().st_size,"zip_sha256":sha(p),"pngs":len(files)},ensure_ascii=False))
