from pathlib import Path
import glob,hashlib,json,zipfile,subprocess,sys
root=Path(glob.glob('G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries')[0])
p=root/'FS_A47_MOTION_LINKED_ATTACK_20261115';a=p/'assets';q=p/'qa'
original={x:hashlib.sha256((a/('actor01_a47_'+x+'_12frames.png')).read_bytes()).hexdigest() for x in ['body','weapon','fx']}
run=subprocess.run([sys.executable,str(q/'a47_joint_warp_generation.py')],capture_output=True,text=True,encoding='utf8',errors='replace',timeout=50)
assert run.returncode==0,(run.stdout,run.stderr)
checks={x:hashlib.sha256((a/('actor01_a47_'+x+'_12frames.png')).read_bytes()).hexdigest() for x in ['body','weapon','fx']}
assert original==checks,(original,checks)
assert hashlib.sha256((a/'actor01_a47_body_R3_12frames.png').read_bytes()).hexdigest()==original['body']
print('A47_GENERATOR_DETERMINISM_PASS',original,flush=True)
meta={'archive':'FS_A47_R3_JOINT_KINEMATIC_NATIVE_COLDPASS_20261115.zip',
'stage':'A47','derived_from_A46_sha256':'7134ccaeb719cc198abd589fae67fbfe86e15cfd07fd61f66ceff397801f14c9',
'Godot_engine':'4.7.2','live_art_candidate':'R3','engine':'PASS','human_art':'HOLD','formal_FS_ATB':'NOT RUN',
'paid_pixellab_calls':0,'source_regeneration':True,'positive_negative_waist':True}
(p/'A47_RELEASE_METADATA.json').write_text(json.dumps(meta,indent=2),encoding='utf8')
def exclude(rel):
 return (rel.startswith('.godot/') or rel.endswith('.import') or rel.endswith('.tmp') or rel.endswith('.zip')
         or rel in ('A47_FULL_SHA256_MANIFEST.json','qa/A47_ZIP_COLD_RECEIPT.json','qa/a47_promoter_fix.py','qa/a47_add_stronger_variant.py') or rel.startswith('qa/A47_ZIP_COLD_')
         or rel.startswith('qa/output/a45/') or rel.startswith('qa/output/a46/')
         or rel.startswith('qa/output/A42') or rel.startswith('qa/output/A41'))
paths=sorted(f.relative_to(p).as_posix() for f in p.rglob('*') if f.is_file() and not exclude(f.relative_to(p).as_posix()))
manifest={'stage':'A47','source_count':len(paths),'files':{rel:hashlib.sha256((p/rel).read_bytes()).hexdigest() for rel in paths}}
(p/'A47_FULL_SHA256_MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf8')
z=root/meta['archive']
with zipfile.ZipFile(z,'w',compression=zipfile.ZIP_DEFLATED) as a:
 for rel in paths+['A47_FULL_SHA256_MANIFEST.json']:
  a.write(p/rel,rel)
with zipfile.ZipFile(z) as a:
 assert a.testzip() is None
 assert len(a.namelist())==len(paths)+1
meta.update({'zip_sha256':hashlib.sha256(z.read_bytes()).hexdigest(),'zip_bytes':z.stat().st_size,'zip_files':len(paths)+1,'manifest_sources':len(paths)})
(p/'A47_RELEASE_METADATA.json').write_text(json.dumps(meta,indent=2),encoding='utf8')
# Note manifest contains the pre-final metadata, because zip sha cannot be
# embedded inside ZIP without circular checksum. Store canonical ZIP SHA sidecar.
print('A47_ZIP_CRC_PASS',json.dumps(meta),flush=True)
