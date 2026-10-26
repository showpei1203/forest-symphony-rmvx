from pathlib import Path
import requests,json,concurrent.futures,hashlib,xml.etree.ElementTree as ET
from PIL import Image
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
O=R/"outputs/P3_G5_0003_OFFICIAL_SOURCE_20261026"
assert not O.exists()
O.mkdir(parents=True)
url="https://api.github.com/repos/PMDCollab/SpriteCollab/contents/sprite/0003?ref=master"
r=requests.get(url,timeout=22,headers={"User-Agent":"FS PMD 0003 evolution source verification"})
print("INDEX",r.status_code,len(r.content),flush=True)
r.raise_for_status()
items=r.json()
assert isinstance(items,list)
targets=[x for x in items if x.get("download_url") and (x["name"]=="AnimData.xml" or x["name"].endswith(("-Anim.png","-Offsets.png","-Shadow.png")))]
print("ALL",len(items),"FILES",len(targets),flush=True)
assert len(targets)>=25
files=O/"SOURCE_0003";files.mkdir()
def dl(x):
 b=requests.get(x["download_url"],timeout=35).content
 assert len(b)==x["size"],(x["name"],len(b),x["size"])
 path=files/x["name"];path.write_bytes(b)
 return {"name":x["name"],"bytes":len(b),"sha256":hashlib.sha256(b).hexdigest(),"url":x["download_url"]}
with concurrent.futures.ThreadPoolExecutor(max_workers=12) as ex:
 manifest=list(ex.map(dl,targets))
root=ET.parse(files/"AnimData.xml").getroot()
acts=[]
for a in root.findall(".//Anim"):
 name=a.findtext("Name");cp=a.findtext("CopyOf")
 if cp:
  acts.append({"name":name,"copyOf":cp})
  continue
 fw,fh=int(a.findtext("FrameWidth")),int(a.findtext("FrameHeight"))
 durations=[int(d.text) for d in a.find("Durations").findall("Duration")]
 p=files/(name+"-Anim.png")
 assert p.is_file()
 im=Image.open(p)
 assert im.width==fw*len(durations) and im.height%fh==0,(name,im.size,fw,fh)
 acts.append({"name":name,"cell":[fw,fh],"frames":len(durations),"rows":im.height//fh,"pixels":im.size,"durations":durations})
report={"source_repo":"PMDCollab/SpriteCollab","source_path":"sprite/0003","branch":"master",
 "source_file_count":len(manifest),"action_count":len(acts),
 "real_action_count":sum("copyOf" not in a for a in acts),
 "frame_cells":sum(a.get("frames",0)*a.get("rows",0) for a in acts),
 "actions":acts,"files":manifest}
(O/"SOURCE_0003_MANIFEST.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print("RESULT",json.dumps({k:v for k,v in report.items() if k not in ("actions","files")},ensure_ascii=False),flush=True)
print("SAMPLES",[(a["name"],a.get("cell"),a.get("frames"),a.get("rows")) for a in acts[:15]],flush=True)
