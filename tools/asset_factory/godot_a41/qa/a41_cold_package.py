"""FS A41 final private Drive ZIP and real Godot cold-extract GPU regression.
No persistent artifacts on local E:; E: is used only for preinstalled Godot executable.
"""
from pathlib import Path
import hashlib,json,zipfile,shutil,subprocess
root=Path(__file__).resolve().parent.parent
private_parent=root.parent
cold=private_parent/'FS_A41_COLD_TMP_VERIFY'
candidate=private_parent/'FS_A41_COLD_STAGE_TMP.zip'
final=private_parent/'FS_A41_GODOT_WEIGHTED_SWORD_FINAL_20261114.zip'
godot=Path('E:/Godot/4.7.2/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe')
assert root.drive.lower()=='g:' and godot.is_file()
assert not cold.exists(), 'Cold dir already exists; no overwrite permitted'
def package(destination):
 paths=[]
 with zipfile.ZipFile(destination,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
  for p in sorted(root.rglob('*')):
   if not p.is_file(): continue
   rel=p.relative_to(root)
   if '.godot' in rel.parts or '__pycache__' in rel.parts: continue
   if p.suffix in ('.uid','.import'): continue
   if rel.as_posix()=='qa/A41_PACKAGE_FINAL_QA.json': continue
   if p.name in ('Thumbs.db',): continue
   z.write(p,rel.as_posix())
   paths.append(rel.as_posix())
 with zipfile.ZipFile(destination) as z:
  assert z.testzip() is None
  assert set(z.namelist())==set(paths)
 return paths
entries=package(candidate)
import_result=None
gpu_result=None
try:
 cold.mkdir()
 with zipfile.ZipFile(candidate) as z:z.extractall(cold)
 for rel in entries:
  assert hashlib.sha256((root/rel).read_bytes()).digest()==hashlib.sha256((cold/rel).read_bytes()).digest(),rel
 import_result=subprocess.run([str(godot),'--headless','--path',str(cold),'--editor','--import','--quit'],capture_output=True,text=True,errors='replace',timeout=120)
 (root/'qa'/'A41_COLD_IMPORT.log').write_text(import_result.stdout+'\n'+import_result.stderr+'\nEXIT='+str(import_result.returncode)+'\n','utf-8')
 assert import_result.returncode==0,('Godot cold import failed',import_result.returncode)
 gpu_result=subprocess.run([str(godot),'--path',str(cold),'--script','res://qa/a41_weighted_runtime_gpu_qa.gd','--rendering-method','gl_compatibility','--resolution','1024x720'],capture_output=True,text=True,errors='replace',timeout=120)
 (root/'qa'/'A41_COLD_GPU_RUNTIME.log').write_text(gpu_result.stdout+'\n'+gpu_result.stderr+'\nEXIT='+str(gpu_result.returncode)+'\n','utf-8')
 assert gpu_result.returncode==0 and 'A41_GODOT_GPU_QA_PASS' in gpu_result.stdout,('A41 cold GPU failed',gpu_result.returncode,gpu_result.stdout[-800:])
 assert 'A41_GPU_DISTINCT=11' in gpu_result.stdout
 print('A41_COLD_GPU_PASS',gpu_result.returncode)
finally:
 if cold.exists():shutil.rmtree(cold)
 if candidate.exists():candidate.unlink()
files=package(final)
report={'stage':'A41','zip_file':final.name,'zip_bytes':final.stat().st_size,'sha256':hashlib.sha256(final.read_bytes()).hexdigest(),'files':len(files),'crc':'PASS','cold_original_sha_each_file':'PASS','cold_editor_import_exit':import_result.returncode if import_result else -1,'cold_real_gpu_exit':gpu_result.returncode if gpu_result else -1,'gpu_distinct':11,'art_gate':'HOLD','official_fs_battle':'NOT_RUN'}
(root/'qa'/'A41_PACKAGE_FINAL_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf-8')
print('A41_CLOUD_PRIVATE_FINAL',json.dumps(report,ensure_ascii=False))