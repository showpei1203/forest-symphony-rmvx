from pathlib import Path
import hashlib,zipfile,json,shutil,sys
R=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
V=Path(r"E:\FS_STAGE16_A36G_R4_R3_VX_NATIVE_20261104")
GD=R/"GODOT_A36G_R4_R3_40x29"
C=Path(r"E:\FS_STAGE16_A36G_R4_R3_ARCHIVE_COLD_EXTRACT_20261104")
out=R/"FS_A36G_R4_R3_6REGIONS_TRUE_GROUND_PAR_VX_GODOT_20261104.zip"
SHA=R/"A36G_R4_R3_PACKAGE_SHA256_MANIFEST.json"
QA=R/"A36G_R4_R3_PRIVATE_ARCHIVE_QA.json"
assert not out.exists() and not C.exists(),"Do not overwrite sealed/archive evidence"
assert V.exists() and GD.exists()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=[]
# Reconstructable source + all experiment records, unlike a mere composite preview.
for p in R.iterdir():
 if p.is_file() and p.suffix.lower() in (".py",".json",".md",".png"):
  if p.name not in (SHA.name,QA.name): files.append((p,p.name))
for folder,tag in ((R/"SOURCE_INDEPENDENT_RGBA","SOURCE_INDEPENDENT_RGBA"),
  (R/"R4_R3_VX_CAPTURES","R4_R3_VX_CAPTURES"),
  (R/"R4_R1_BEFORE_SEAM_REWORK","R4_R1_BEFORE_SEAM_REWORK"),
  (R/"R4_R2_PRE_ROOT_REPAIR","R4_R2_PRE_ROOT_REPAIR"),
  (GD,"GODOT_R4_R3_NATIVE"),
  (V,"VX_R4_R3_NATIVE")):
 assert folder.exists(),str(folder)
 for p in folder.rglob("*"):
  if not p.is_file():continue
  if ".godot" in p.parts or p.suffix in (".tmp",".lock"):continue
  files.append((p,tag+"/"+p.relative_to(folder).as_posix()))
keys=[n for p,n in files]
assert len(keys)==len(set(keys)),[n for n in keys if keys.count(n)>1][:10]
assert len(files)>3900,len(files)
files.sort(key=lambda x:x[1])
entries=[]
for i,(p,rel) in enumerate(files):
 entries.append({"name":rel,"bytes":p.stat().st_size,"sha256":sha(p)})
manifest={"stage":"A36G_R4_R3","root":str(R),"files":entries,
 "count":len(entries),"authority":{"R3B":"read_only","A36F":"read_only"},
 "formal_seal":"NO"}
SHA.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),"utf8")
with zipfile.ZipFile(out,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=5,allowZip64=True) as z:
 for i,(p,rel) in enumerate(files):
  z.write(p,rel)
  if i%700==0:print("PACK_PROGRESS",i,len(files),flush=True)
 z.write(SHA,SHA.name)
print("PACK_FILE_COUNT",len(files)+1,"ZIP_SIZE",out.stat().st_size,flush=True)
with zipfile.ZipFile(out) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(files)+1
 print("CRC_PASS",flush=True)
 C.mkdir(parents=True)
 z.extractall(C)
print("COLD_EXTRACT_FINISHED",flush=True)
mismatch=[]
for i,e in enumerate(entries):
 p=C/e["name"]
 if not p.exists() or sha(p)!=e["sha256"]:mismatch.append(e["name"])
 if i%700==0:print("COLD_HASH_PROGRESS",i,len(entries),flush=True)
assert not mismatch,mismatch[:25]
assert sha(C/SHA.name)==sha(SHA)
q={"stage":"A36G_R4_R3","archive":str(out),"archive_bytes":out.stat().st_size,
 "archive_sha256":sha(out),"members":len(files)+1,"source_file_sha_verified":len(files),
 "mismatch_count":len(mismatch),"zip_crc":"PASS","cold_extracted":str(C),
 "cold_extract_manifest_match":True,"formal_seal":"NO"}
QA.write_text(json.dumps(q,ensure_ascii=False,indent=2),"utf8")
print("PACKAGE_COLD_PASS",json.dumps(q,ensure_ascii=False),flush=True)
