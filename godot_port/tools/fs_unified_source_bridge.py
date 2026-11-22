#!/usr/bin/env python3
"""One-pass private integration of ORIGINAL FS Scripts.rvdata and all 11 RVData.

The complete original Ruby is archived privately, never executed by Godot.
The generated metadata index is a source/provenance bridge, not proof of
effective Ruby aliases, post-Apply database, or executable combat parity.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import zipfile
import zlib
from rvdata_to_json import RubyMarshal48

SCRIPTS_SHA="d398178135c5b41622b0e6da763d58af1fbf770c9d24a360a23508800015809a"
TABLE_SHA={
 "Actors":"dfbac672c9e2a6d893a58c7513c8fbb e9087426f7ed53c3e26aaea1774d9eb59".replace(" ",""),
 "Classes":"d88d3d267e3c23f93f8e9968ac43172d3b608537f64dda e4a759f68bfb153c0e".replace(" ",""),
 "Skills":"679a9ba8c88a9bc901bcb98d1818fabe006cbbbc7c658e67a9ce53e3f57f436c",
 "Items":"9b72b0d38407a0b31f7639cae39d936004920629f9dee86f635af0608966b93",
 "Weapons":"e81246d798493abb97b46ae06dea77eb68eaa9e0335ec754c8f2778e50c68ad2",
 "Armors":"c296e608f1176e706e600df185fa668622f6124b69205169f82ff25b807cb2a",
 "Enemies":"f11fa05ced0ef7724166457216ba68986b58f4808d5736003ebba8f4421ec625",
 "States":"55eb136cfb616313d804cdbd0a221de46121acdcda098ef11e24c554d6fb00dc",
 "Troops":"07423a3e24e30b473e4c46b332e469b03d52cc46e843eb1750c9884a981754a3",
 "System":"76cf4fd3eddbfa6009682e46eea736e6a180182d4b99a0cec27f6a24d5fe6c82",
 "Animations":"781a1a2c04eea8a0809cade7fdfa fdf3561d310d8058a2807199b7597116ad4d".replace(" ",""),
}
SCHEMA="fs-unified-original-source-index-v1"
CLASS_RX=re.compile(r"^\s*(?:class|module)\s+([A-Za-z_]\w*(?:::[A-Za-z_]\w*)*)")
DEF_RX=re.compile(r"^\s*def\s+(?:(self)\.)?([A-Za-z_]\w*[!?=]?)(?=\s|\(|$)")
ALIAS_RX=re.compile(r"^\s*alias(?:_method)?(?:\s|\()")
RES_RX=re.compile(r"""Cache\.(system|menu|parallax|picture|battler|character)\s*\(\s*['"]([^'"]+)['"]""")

def sha(data):
 return hashlib.sha256(data).hexdigest()

def decode_source(data):
 for encoding in ("utf-8","cp950","cp932"):
  try:return data.decode(encoding)
  except UnicodeDecodeError:pass
 return data.decode("latin1")

def index_source(scripts, source_hash, data_hash, expected=505):
 if len(scripts)!=expected or set(data_hash)!=set(TABLE_SHA):
  raise ValueError("Original load order or 11 data tables incomplete")
 result={"schema":SCHEMA,"source_scripts_rvdata_sha256":source_hash,
   "source_script_sections":len(scripts),"original_data_sha256":data_hash,
   "sections":[],"method_candidates":{},"static_resource_literals":[],
   "unresolved":{"effective_alias_chain":True,"boot_final_apply_all":True,
     "original_window_position_runtime":True,"native_godot_execution_parity":True}}
 total_bytes=0
 for i,row in enumerate(scripts,1):
  if len(row)!=3 or not isinstance(row[2],bytes):
   raise ValueError("Malformed original RGSS2 source section")
  ident,name,raw=row
  total_bytes+=len(raw)
  if total_bytes>32_000_000 or len(raw)>3_000_000:
   raise ValueError("RGSS2 decompression limit exceeded")
  lines=decode_source(raw).splitlines()
  klass="(unknown)";decl=[];aliases=[];classes=[]
  for n,line in enumerate(lines,1):
   if line.lstrip().startswith("#"):continue
   group=CLASS_RX.match(line)
   if group:
    klass=group.group(1)
    classes.append({"line":n,"lexical_class_hint":klass})
   m=DEF_RX.match(line)
   if m:
    key=("self" if m.group(1) else klass)+"#"+m.group(2)
    loc={"section":i,"line":n}
    result["method_candidates"].setdefault(key,[]).append(loc)
    decl.append({"line":n,"lexical_class_hint":klass,"method":m.group(2)})
   if ALIAS_RX.match(line):aliases.append(n)
   for r in RES_RX.finditer(line):
    result["static_resource_literals"].append({"section":i,"line":n,
      "kind":r.group(1),"name":r.group(2)})
  result["sections"].append({"section":i,"ruby_id":ident,"name":name,
    "source_sha256":sha(raw),"source_bytes":len(raw),"source_lines":len(lines),
    "relative_source_path":"rgss2/%03d.rb"%i,
    "classes":classes,"methods":decl,"alias_lines":aliases})
 return result

def load_source(project):
 scripts_path=project/"Data"/"Scripts.rvdata"
 binary=scripts_path.read_bytes()
 if sha(binary)!=SCRIPTS_SHA:
  raise ValueError("Original FS Scripts.rvdata SHA mismatch")
 parsed=RubyMarshal48(binary).parse()
 if not isinstance(parsed,list) or len(parsed)!=505:
  raise ValueError("Original Scripts.rvdata must contain all 505 ordered sections")
 entries=[]
 for row in parsed:
  if not isinstance(row,list) or len(row)!=3 or not isinstance(row[2],str):
   raise ValueError("Original compressed Ruby section format mismatch")
  entries.append((row[0],row[1],zlib.decompress(row[2].encode("latin1"))))
 files={"Scripts":binary}
 for name,wanted in TABLE_SHA.items():
  raw=(project/"Data"/(name+".rvdata")).read_bytes()
  if sha(raw)!=wanted:raise ValueError("Original source DB hash mismatch: "+name)
  files[name]=raw
 return entries,files

def run(project, output):
 # Only G: cloud workspace is authorized to hold private source bytes.
 path=str(output.resolve()).replace("\\","/")
 if not path.startswith("G:/") or "/FS_" not in path:
  raise ValueError("Private unified FS source may be written only to G: Drive")
 output.mkdir(parents=True,exist_ok=True)
 dest=output/"FS_UNIFIED_ORIGINAL_505_SCRIPTS_11_TABLES_PRIVATE.zip"
 manifest=output/"fs_unified_source_registry.json"
 if dest.exists() or manifest.exists():raise FileExistsError("Refuse private source overwrite")
 scripts,files=load_source(project)
 index=index_source(scripts,sha(files["Scripts"]),
                    {n:sha(blob) for n,blob in files.items() if n!="Scripts"})
 payload=(json.dumps(index,ensure_ascii=False,indent=2)+"\n").encode()
 tmp=output/"FS_UNIFIED_ORIGINAL_505_SCRIPTS_11_TABLES_PRIVATE.partial.zip"
 try:
  with zipfile.ZipFile(tmp,"x",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
   for i,entry in enumerate(scripts,1):
    z.writestr("rgss2/%03d.rb"%i,entry[2])
   for name,b in files.items():z.writestr("Data/"+name+".rvdata",b)
   z.writestr("fs_unified_source_registry.json",payload)
  with zipfile.ZipFile(tmp) as z:
   if z.testzip() is not None or len(z.namelist())!=518:
    raise ValueError("Private original ZIP CRC/count failed")
   if sha(z.read("Data/Scripts.rvdata"))!=SCRIPTS_SHA:
    raise ValueError("Source integrity lost during archive")
  os.replace(tmp,dest)
  manifest.write_bytes(payload)
 finally:
  if tmp.exists():tmp.unlink()
 return {"scripts":len(scripts),"tables":11,
   "raw_script_bytes":sum(len(s[2]) for s in scripts),
   "method_declarations":sum(len(r["methods"]) for r in index["sections"]),
   "alias_declarations":sum(len(r["alias_lines"]) for r in index["sections"]),
   "resource_literals":len(index["static_resource_literals"]),
   "private_zip_bytes":dest.stat().st_size,
   "private_zip_sha256":sha(dest.read_bytes()),"manifest_bytes":len(payload),
   "manifest_sha256":sha(payload),"output":str(output)}

if __name__=="__main__":
 ap=argparse.ArgumentParser(description=__doc__)
 ap.add_argument("--project",type=Path,required=True)
 ap.add_argument("--output-dir",type=Path,required=True)
 args=ap.parse_args()
 print(json.dumps(run(args.project,args.output_dir),ensure_ascii=False,indent=2))
