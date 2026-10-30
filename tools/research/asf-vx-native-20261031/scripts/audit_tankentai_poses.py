from pathlib import Path
from PIL import Image
import json,re,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
base=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
scripts=base/"All_Scripts_Export.txt"
s=scripts.read_text(encoding="utf-8",errors="replace")
marker=s.find("# ANIME Key         FileNo.")
assert marker!=-1,"No Tankentai Source Table"
# Stop before the next explicitly defined table; collect only the dedicated Pose table.
end=s.find("# * Battler Motions",marker)
if end<0: end=marker+50000
chunk=s[marker:end]
pattern=re.compile(r'(?m)^\s*"([^"\n]+)"\s*=>\s*\[\s*(\d+)\s*,\s*(\d+)\s*,\s*(-?\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(true|false)\s*,\s*"([^"\n]*)"\s*\]')
matches=list(pattern.finditer(chunk))
assets={}
for n in [0]+list(range(1,9)):
 filename="$actor01.png" if n==0 else f"$actor01_{n}.png"
 p=base/"Graphics"/"Characters"/filename
 if p.exists():
  im=Image.open(p).convert("RGBA")
  assert im.size==(96,128)
  assets[n]={"filename":filename,"sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
             "valid_cells":[[bool(im.crop((c*32,r*32,c*32+32,r*32+32)).getchannel("A").getbbox()) for c in range(3)] for r in range(4)]}
rows=[];risks=[]
for m in matches:
 name,num,row,spd,loop,wait,fixed,z,shadow,weapon=m.groups()
 num,row,fixed,spd,loop=int(num),int(row),int(fixed),int(spd),int(loop)
 asset=assets.get(num)
 required=[fixed] if fixed in (0,1,2) else [0,1,2]
 cells=asset["valid_cells"][row] if asset is not None else None
 missing=required if cells is None else [k for k in required if not cells[k]]
 rec={"name":name,"file_no":num,"row":row,"speed":spd,"loop":loop,"fixed":fixed,
      "weapon":weapon,"source":asset["filename"] if asset else None,
      "row_cells":cells,"required_columns":required,"missing_columns":missing,
      "conditional_status":"MISSING_SOURCE_OR_CELLS" if missing else "ART_CELLS_PRESENT"}
 rows.append(rec)
 if missing:risks.append(rec)
result={"scope":"Conditional asset coverage ONLY for $actor01; table includes many actors and these actions MAY NOT be invoked by this actor",
 "source_scripts_sha256":hashlib.sha256(scripts.read_bytes()).hexdigest(),
 "matched_poses":len(rows),"missing_conditionally":len(risks),"missing_records":risks,
 "poses":rows,"method":"explicit Tankentai FileNo/Row/Fixed fields vs actual $actor01_n PNG 3x4 alpha presence",
 "not_proven":"This cannot establish that every named actor action is used by $actor01. Only inspecting actual actor action sequence, battle runtime and 1:1 VX screenshots can do that."}
(root/"tankentai_pose_coverage_conditional.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"pose_count":len(rows),"conditional_missing":len(risks),
 "risk_summaries":[{"name":x["name"],"file":x["file_no"],"row":x["row"],"fixed":x["fixed"],"missing":x["missing_columns"]} for x in risks[:30]]},ensure_ascii=True,indent=2))