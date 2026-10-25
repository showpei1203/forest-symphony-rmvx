from pathlib import Path
import requests,json,hashlib,xml.etree.ElementTree as ET,concurrent.futures,time
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
O=R/"outputs/P3_R2_0001_UPSTREAM_PMD_20261026"
assert not O.exists(),"Avoid overwriting other work"
O.mkdir(parents=True)
U="https://api.github.com/repos/PMDCollab/SpriteCollab/contents/sprite/0001?ref=master"
response=requests.get(U,timeout=28,headers={"User-Agent":"FS-P3-R2-Research"})
response.raise_for_status()
items=[x for x in response.json() if x.get("download_url") and (x["name"]=="AnimData.xml" or x["name"].endswith(("-Anim.png","-Offsets.png","-Shadow.png")))]
assert len(items)>90,len(items)
sub=O/"official_0001";sub.mkdir()
def fetch(item):
 name=item["name"];res=requests.get(item["download_url"],timeout=35)
 res.raise_for_status()
 assert len(res.content)>50 and len(res.content)==item["size"],name
 path=sub/name;path.write_bytes(res.content)
 return {"file":name,"bytes":len(res.content),"sha256":hashlib.sha256(res.content).hexdigest(),"source_url":item["download_url"]}
with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
 manifest=list(pool.map(fetch,items))
xml=sub/"AnimData.xml"
root=ET.parse(xml).getroot()
anims=[]
for a in root.findall(".//Anim"):
 get=lambda k:a.findtext(k)
 durations=a.find("Durations")
 anims.append({"name":get("Name"),"copyOf":get("CopyOf"),"width":get("FrameWidth"),"height":get("FrameHeight"),"durations":[int(d.text) for d in durations.findall("Duration")] if durations is not None else []})
(O/"DOWNLOAD_MANIFEST.json").write_text(json.dumps({"remote":"PMDCollab/SpriteCollab master sprite/0001","sources":manifest,"animation_count":len(anims),"animation_defs":anims},indent=2),encoding="utf-8")
print(json.dumps({"file_count":len(manifest),"xml_actions":len(anims),"total_bytes":sum(x["bytes"] for x in manifest),"sample_actions":anims[:5]},ensure_ascii=False))
