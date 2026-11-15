#!/usr/bin/env python3
"""Owner-only cloud delivery, source-proof hashes. Never publish this package to public GitHub."""
import hashlib,json,zipfile,argparse
from pathlib import Path
parser=argparse.ArgumentParser()
parser.add_argument('--project',type=Path,required=True)
parser.add_argument('--zip',type=Path,required=True)
a=parser.parse_args()
root=a.project.resolve();out=a.zip.resolve()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=[]
for p in sorted(root.rglob('*')):
 if not p.is_file():continue
 rel=p.relative_to(root).as_posix()
 if rel.startswith('.godot/') or rel.endswith(('.import','.uid','.tmp')) or rel=='A34_PRIVATE_MEMBER_SHA256_MANIFEST.json':continue
 files.append((rel,p))
manifest={'schema':'fs-a34-owner-only-private-zip-manifest/v1','production':'Ground-first then full independent transparent PAR; no flat Master slicing','art_status':'HOLD','files':{rel:{'size':p.stat().st_size,'sha256':sha(p)} for rel,p in files}}
m=root/'A34_PRIVATE_MEMBER_SHA256_MANIFEST.json';m.write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
files.append(('A34_PRIVATE_MEMBER_SHA256_MANIFEST.json',m))
with zipfile.ZipFile(out,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6,allowZip64=True) as z:
 for rel,p in files:z.write(p,rel)
with zipfile.ZipFile(out) as z:
 assert z.testzip() is None
 assert len(z.infolist())==len(files)
 assert set(z.namelist())==set(f[0] for f in files)
 print(json.dumps({'zip':str(out),'size_bytes':out.stat().st_size,'sha256':sha(out),'members':len(files),'member_hashes':len(manifest['files']),'ground_sha256':sha(root/'private_assets/ground_only.png')},indent=2))
