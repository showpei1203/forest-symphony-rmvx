from pathlib import Path
import zipfile,hashlib,json,shutil,subprocess,sys
R=Path(__file__).resolve().parent
files=[
 'a18_native_trial.py','test_a18_offline.py','README_A18_RUNBOOK.md',
 'STAGE16_A18_HANDOFF_20261031.md','STAGE16_A18_FAILURE_REGISTER_20261031.md',
 'A10_GROUND3_GRASS_SOURCE_64.png','A10_GROUND3_SAND_SOURCE_48.png',
 'A17_GROUND3_CROP16_FOR_STYLE_AUDIT.png',
 'A18_PIXELLAB_PRO_DRY_RUN.json','A18_PIXELLAB_PIXEN_DRY_RUN.json','A18_RETRO_PRO_DRY_RUN.json',
 'A18_MOCK_FIXTURE_NOT_GENERATED.png','A18_MOCK_32PX_VISUAL_AUDIT.png','A18_MOCK_FORMAT_QA.json',
 'A18_UNIT_TEST_LOG.txt'
]
assert len(set(files))==len(files)
sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
for n in files:assert (R/n).is_file(),n
# Test fixture must never be mistaken for a completed provider generation.
for n in ('A18_PIXELLAB_PRO_DRY_RUN.json','A18_PIXELLAB_PIXEN_DRY_RUN.json','A18_RETRO_PRO_DRY_RUN.json'):
 j=json.loads((R/n).read_text(encoding='utf8'))
 assert j['mode']=='DRY_RUN_NO_CHARGE_NO_NETWORK' and j['new_model_png']=='NOT_CREATED' and j['formal_seal']=='NO'
manifest={'stage':'A18','date':'2026-10-31','gates':{'ground3_original_inputs':'PASS_HASHES','three_provider_dryruns':'PASS_NO_NETWORK','offline_client_unit_tests':'5_OF_5_PASS','genuine_provider_png':'NOT_RUN_AUTH','ground3_art':'NOT_TESTED','godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO'},'files_sha256':{n:sha(R/n) for n in files}}
zpath=R/'FS_STAGE16_A18_NATIVE_PROVIDER_PREFLIGHT_PRIVATE_20261031.zip'
with zipfile.ZipFile(zpath,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=7) as z:
 for name in files:z.write(R/name,arcname=name)
 z.writestr('A18_SHA256_MANIFEST.json',json.dumps(manifest,ensure_ascii=False,indent=2))
cold=Path('/mnt/data/FS_STAGE16_A18_COLD_RETEST_20261031')
if cold.exists():shutil.rmtree(cold)
cold.mkdir(parents=True)
with zipfile.ZipFile(zpath) as z:
 assert z.testzip() is None
 z.extractall(cold)
 assert json.loads((cold/'A18_SHA256_MANIFEST.json').read_text(encoding='utf8'))==manifest
 for n,v in manifest['files_sha256'].items():assert sha(cold/n)==v,n
p=subprocess.run([sys.executable,'test_a18_offline.py'],cwd=cold,capture_output=True,text=True,timeout=60)
assert p.returncode==0,(p.stdout,p.stderr)
assert 'Ran 5 tests' in p.stderr and 'OK' in p.stderr
for n,v in manifest['files_sha256'].items():assert sha(cold/n)==v,'cold output drift '+n
receipt={'stage':'A18','zip':zpath.name,'bytes':zpath.stat().st_size,'zip_sha256':sha(zpath),'entries':len(files)+1,'source_files_verified':len(files),'zip_crc':'PASS','cold_source_hashes':'PASS','cold_offline_unit_tests':'5/5 PASS','billable_api_calls':0,'authenticated_provider_outputs':0,'art':'NOT_TESTED','godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO'}
(R/'A18_DELIVERY_RECEIPT.json').write_text(json.dumps(receipt,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
print(json.dumps(receipt,indent=2,ensure_ascii=False))
