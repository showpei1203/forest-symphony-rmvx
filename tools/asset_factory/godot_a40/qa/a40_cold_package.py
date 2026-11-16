"""A40 cloud-only cold rebuild, real GPU QA, private final packaging."""
from pathlib import Path
import hashlib,json,shutil,subprocess,zipfile,os
root=Path(__file__).resolve().parent.parent
parent=root.parent
cold=parent/'FS_A40_COLD_VERIFY_TMP'
tempzip=parent/'FS_A40_COLD_SOURCE_TEMP.zip'
final=parent/'FS_A40_GODOT_ATTACK_FINAL_20261114.zip'
exe=Path('E:/Godot/4.7.2/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe')
assert exe.is_file(),exe
assert root.is_dir() and root.drive.lower()=='g:'
assert not cold.exists(), 'Cold directory already exists: fail closed'
def make_zip(dst):
    entries=[]
    with zipfile.ZipFile(dst,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for p in sorted(root.rglob('*')):
            if not p.is_file(): continue
            rel=p.relative_to(root)
            parts=rel.parts
            if '.godot' in parts or '__pycache__' in parts: continue
            if p.suffix in ('.import',) and 'qa' not in parts: continue
            # Avoid a circular artifact hash embedded in its own ZIP.
            if rel.as_posix()=='qa/A40_FINAL_PACKAGING_QA.json': continue
            if p.name in ('Thumbs.db',): continue
            z.write(p,rel.as_posix())
            entries.append(rel.as_posix())
    with zipfile.ZipFile(dst) as z:
        assert z.testzip() is None
        assert set(z.namelist())==set(entries)
    return entries
entries=make_zip(tempzip)
try:
    cold.mkdir(parents=True)
    with zipfile.ZipFile(tempzip) as z: z.extractall(cold)
    for name in entries:
        a=(root/name).read_bytes()
        b=(cold/name).read_bytes()
        assert hashlib.sha256(a).digest()==hashlib.sha256(b).digest(),name
    editor=subprocess.run([str(exe),'--headless','--path',str(cold),'--editor','--import','--quit'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,errors='replace',timeout=120)
    (root/'qa'/'A40_COLD_IMPORT.log').write_text(editor.stdout+'\nEXIT='+str(editor.returncode)+'\n',encoding='utf-8')
    assert editor.returncode==0,'Godot cold editor failed'
    gpu=subprocess.run([str(exe),'--path',str(cold),'--script','res://qa/a40_attack_runtime_gpu_qa.gd','--rendering-method','gl_compatibility','--resolution','1024x720'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,errors='replace',timeout=120)
    (root/'qa'/'A40_COLD_GPU_QA.log').write_text(gpu.stdout+'\nEXIT='+str(gpu.returncode)+'\n',encoding='utf-8')
    assert gpu.returncode==0 and 'A40_GODOT_GPU_QA_PASS' in gpu.stdout,'Godot cold GPU QA failed'
    print('A40_COLD_IMPORT_EXIT',editor.returncode)
    print('A40_COLD_GPU_QA_EXIT',gpu.returncode)
    print('A40_COLD_GPU_DISTINCT_7', 'A40_GPU_DISTINCT=7' in gpu.stdout)
finally:
    if cold.exists():shutil.rmtree(cold)
    if tempzip.exists():tempzip.unlink()
entries=make_zip(final)
digest=hashlib.sha256(final.read_bytes()).hexdigest()
report={'stage':'A40','date':'2026-11-14','private_zip':final.name,'zip_sha256':digest,'zip_bytes':final.stat().st_size,'entries':len(entries),'integrity_test':'ZIP CRC PASS and cold SHA for all entries','cold_editor_exit':editor.returncode,'cold_gpu_qa_exit':gpu.returncode,'cold_gpu_pass':'A40_GODOT_GPU_QA_PASS' in gpu.stdout,'art_gate':'HOLD','migration_battle_gate':'NOT_RUN'}
(root/'qa'/'A40_FINAL_PACKAGING_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
# External manifest is deliberately excluded from zip to avoid self-hash recursion.
print('A40_FINAL_PRIVATE_ZIP',json.dumps(report,ensure_ascii=False))