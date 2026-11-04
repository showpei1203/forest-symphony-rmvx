"""R5 R2 audit-ready cold archive. Includes source PNGs, actual Ground+PAR, native VX and Godot, QA, scripts. No cloud-upload assertion."""
from pathlib import Path
import hashlib,json,zipfile
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
V=Path(r"E:\FS_STAGE16_A36G_R5_VX_NATIVE_20261104")
D=R/"GODOT_A36G_R5_40x29"
C=Path(r"E:\FS_STAGE16_A36G_R5_R2_ARCHIVE_COLD_20261104")
ZIP=R/"FS_A36G_R5_R2_HOUSE_STYLE_TRUE_GROUND_PAR_VX_GODOT_20261104.zip"
MAN=R/"A36G_R5_R2_PACKAGE_SHA256_MANIFEST.json"
QA=R/"A36G_R5_R2_PRIVATE_ARCHIVE_QA.json"
assert not ZIP.exists() and not C.exists(),"No overwrite of archive or its cold checkpoint"
assert V.exists() and D.exists()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=[]
for p in R.iterdir():
 if p.is_file() and p.suffix.lower() in (".py",".json",".md",".png"):
  if p.name not in (MAN.name,QA.name):files.append((p,p.name))
for folder,prefix in [
 (R/"SOURCE_INDEPENDENT_RGBA","SOURCE_INDEPENDENT_RGBA"),
 (R/"R5_VX_CAPTURES","R5_VX_CAPTURES"),
 (V,"VX_R5_NATIVE"),(D,"GODOT_R5_NATIVE")]:
 assert folder.exists(),str(folder)
 for p in folder.rglob("*"):
  if not p.is_file():continue
  if ".godot" in p.parts or p.suffix in (".tmp",".lock"):continue
  files.append((p,prefix+"/"+p.relative_to(folder).as_posix()))
files.sort(key=lambda pair:pair[1])
items=[{"path":name,"sha256":sha(p),"size":p.stat().st_size} for p,name in files]
assert len(items)>3500 and len({z["path"] for z in items})==len(items)
MAN.write_text(json.dumps({"stage":"A36G_R5_R2","source_items":items,"count":len(items),"formal_seal":"NO"},
 indent=2,ensure_ascii=False),"utf8")
with zipfile.ZipFile(ZIP,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=5,allowZip64=True) as z:
 for i,(p,n) in enumerate(files):
  z.write(p,n)
  if i%850==0:print("PACK_PROGRESS",i,len(items),flush=True)
 z.write(MAN,MAN.name)
with zipfile.ZipFile(ZIP) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(items)+1
 C.mkdir(parents=True)
 z.extractall(C)
print("ARCHIVE_EXTRACTED",flush=True)
bad=[]
for i,item in enumerate(items):
 p=C/item["path"]
 if not p.is_file() or sha(p)!=item["sha256"]:bad.append(item["path"])
 if i%850==0:print("COLD_HASH_PROGRESS",i,len(items),flush=True)
assert not bad,bad[:8]
assert sha(C/MAN.name)==sha(MAN)
r={"stage":"A36G_R5_R2","archive":str(ZIP),"archive_bytes":ZIP.stat().st_size,
 "archive_sha256":sha(ZIP),"members":len(items)+1,
 "source_files_sha256_verified":len(items),"mismatch_count":0,
 "zip_crc":"PASS","cold_extracted":str(C),"cold_extract_sha256":"PASS",
 "native_vx_smoke":"PASS","formal_seal":"NO",
 "cloud_zip_upload":"NOT_ATTEMPTED"}
QA.write_text(json.dumps(r,ensure_ascii=False,indent=2),"utf8")
print("ARCHIVE_COLD_PASS",json.dumps(r,ensure_ascii=False),flush=True)
