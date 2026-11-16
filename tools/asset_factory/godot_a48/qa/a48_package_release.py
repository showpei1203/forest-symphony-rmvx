from pathlib import Path
import glob,hashlib,json,zipfile
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A48_CONNECTED_ARM_PIXEL_POSES_20261115'
qa=p/'qa';a=p/'assets'
assert json.loads((qa/'A48_FINAL_QA_SUMMARY.json').read_text(encoding='utf8'))['art_structural']=='PASS'
assert json.loads((qa/'A48_NATIVE_COLD_QA_RESULT.json').read_text(encoding='utf8'))['status']=='PASS'
archive=root/'FS_A48_CONNECTED_SWORD_ARM_NATIVE_GODOT_ART_HOLD_20261115.zip'
manifest_name='A48_RELEASE_SHA_MANIFEST.json'
def include(path):
 return not(path.startswith('.godot/') or path.endswith('.import') or path.endswith('.zip')
    or path.startswith('qa/output/a47/') or path.startswith('qa/output/a46/')
    or path.startswith('qa/output/a45/') or path.startswith('qa/output/a44/')
    or path in [manifest_name,'A48_RELEASE_METADATA.json']
    or path.startswith('qa/output/A42') or path.startswith('qa/output/A41'))
names=sorted(f.relative_to(p).as_posix() for f in p.rglob('*') if f.is_file() and include(f.relative_to(p).as_posix()))
m={'stage':'A48 R1','project_engine':'Godot 4.7.2','source_files':len(names),
  'sha256':{name:hashlib.sha256((p/name).read_bytes()).hexdigest() for name in names}}
(p/manifest_name).write_text(json.dumps(m,indent=2),encoding='utf8')
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for name in names+[manifest_name]:z.write(p/name,name)
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(names)+1
meta={'stage':'A48','zip_name':archive.name,'zip_bytes':archive.stat().st_size,
 'zip_sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),
 'files_in_zip':len(names)+1,'manifest_source_count':len(names),
 'A47_source_archive_sha256':'e48cd680edd63a888deb2b370df4686a289253383fdbd7dc770df271df793ee5',
 'native_engine':'PASS','body_structure':'PASS','human_art_approval':'HOLD',
 'formal_FS_ATB':'NOT RUN','PixelLab_calls':0}
(p/'A48_RELEASE_METADATA.json').write_text(json.dumps(meta,indent=2),encoding='utf8')
print('A48_CRC_ZIP_PASS',json.dumps(meta),flush=True)
