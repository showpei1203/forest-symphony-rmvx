from pathlib import Path
from PIL import Image
import hashlib,json,zlib,base64,shutil
ROOT=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
OLD=ROOT/"A10_ONE_MASTER_RIG"
DST=ROOT/"A11_LAYERED_RIG"
pack=json.loads((DST/"A11_TRANSFER.json").read_text(encoding="utf-8"))
qc={}
for case in ("T1_forest_scout","T2_moss_antler"):
 source=OLD/case/"rig"
 target=DST/case
 assert source.exists() and not target.exists()
 target.mkdir()
 shutil.copytree(source/"frames",target/"frames")
 srcman=source/"clips_nodup.json"
 assert srcman.exists(),srcman
 man=json.loads(srcman.read_text(encoding="utf8"))
 remap={f["name"]:i for i,f in enumerate(man["frames"])}
 inp=pack[case]
 assert len(inp)==8 and "attack" in man["clips"]
 used=[]
 for entry in inp:
  w,h=entry["size"]
  raw=zlib.decompress(base64.b64decode(entry["data"]))
  assert len(raw)==w*h*4
  assert hashlib.sha256(raw).hexdigest()==entry["sha256"]
  im=Image.frombytes("RGBA",(w,h),raw)
  assert im.getbbox() is not None and min(im.getchannel("A").getextrema())==0
  path=target/"frames"/entry["name"]
  assert path.exists()
  im.save(path)
  assert Image.open(path).tobytes()==raw
  assert entry["name"].replace(".png","") in remap
  used.append(remap[entry["name"].replace(".png","")])
 assert len(used)==8
 # Source pose indices have all existed since A10. Remove any A10 attack dedup because new rigid sword poses are distinct.
 man["clips"]["attack"]["frames"]=used
 man["clips"]["attack"]["ticks"]=[8]*8
 (target/"clips.json").write_text(json.dumps(man,ensure_ascii=False,indent=2),encoding="utf8")
 qc[case]={"input_frames":8,"input_pixelsha_all_match":True,
 "manifest_source_count":len(man["frames"]),"manifest_playback_attack":len(man["clips"]["attack"]["frames"]),
 "all_other_actions_preserved":sorted([x for x in man["clips"] if x!="attack"]),
 "source_reference":str(srcman)}
(DST/"A11_PREBUILD_QA.json").write_text(json.dumps(qc,indent=2),encoding="utf8")
print(json.dumps(qc,indent=2))