"""Make immutable private owner-only ZIP from isolated Godot A30 project.
Do NOT commit ZIP, original PNGs or native screenshots to public repo.
"""
import pathlib, zipfile,hashlib,json,os
ROOT=pathlib.Path(__file__).resolve().parent.parent
OUT=ROOT.parent/'FS_A30_GODOT_COLLISION_A62_NATIVE_PRIVATE_20261113.zip'
FILES=[]
for sub in ['assets','data','resources','scenes','scripts','tests','tools','private_assets','docs','qa']:
 for p in sorted((ROOT/sub).rglob('*')):
  if not p.is_file() or '/.godot/' in str(p):continue
  if p.suffix in ['.uid','.import'] or p.name.endswith('.log') or p.name.endswith('.pid'): continue
  if p.name.startswith('A29_') and sub=='qa':continue
  FILES.append(p)
for p in [ROOT/'project.godot',ROOT/'README.md',ROOT/'.gitignore',ROOT/'.gitattributes',ROOT/'.github/workflows/fs-godot-a29-smoke.yml']:
 if p.exists():FILES.append(p)
SOURCE={'full_ground.png':'091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530','actor_f0.png':'a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba','actor_run_1.png':'6b25abb1dd702701716844a2ad36dfb8bfb8e3eccaf87fe7b15b2b85a41d101d','actor_run_2.png':'a96d6d4df959f66cb5cc08aa78e7b8f7a22f9e37140584b0fb3c928bc5b37029','actor_run_3.png':'84a8edb267bea9608d40de9f3af9b20050d7e85ef2293f0cd4d4199045107b79'}
for n,sha in SOURCE.items():
 p=ROOT/'private_assets'/n
 assert hashlib.sha256(p.read_bytes()).hexdigest()==sha,n
candidate=json.loads((ROOT/'data/collision_candidate.json').read_text())
assert candidate['status']=='CANDIDATE_NOT_USER_COLLISION_APPROVED'
assert len(candidate['blocked_tiles'])==180
assert (ROOT/'qa/a30_real_runtime_after_external_tileset.log').read_text().count('A30 GODOT NATIVE PASS 221 checks')==1
assert (ROOT/'qa/a30_public_contract_cleanroom.log').read_text().count('A30 GODOT PUBLIC CI PASS: 389 checks')==1
all_files=sorted({p.relative_to(ROOT).as_posix():p for p in FILES}.items())
from PIL import Image
qa=[]
for name in ['GODOT_472_A30_A62_RUN2_TREE_BEHIND.png','GODOT_472_A30_A62_RUN3_BRIDGE_FRONT.png','GODOT_472_A30_PAINTED_COLLISION_1X.png','GODOT_472_A30_FULL_MAP_CENTER_PATH_1X.png']:
 p=ROOT/'qa'/name
 assert Image.open(p).size==(544,416)
 qa.append({'file':name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
manifest={
 'schema':'fs-a30-godot-first-private-native-qa/v1',
 'user_decision':'Godot primary engine; VX remains source/reference',
 'engine':'4.7.2.stable.official.ed1daf0bf',
 'scene_master_sha256':SOURCE['full_ground.png'],
 'source_asset_sha256':SOURCE,
 'collision':{'status':candidate['status'],'painted_tiles':180,'grid':[40,29],'tile_size':32,'candidate_free_connected':980,'native_physics_sweep':'PASS'},
 'animation':{'source':'approved A62 only','frames':3,'size':[48,48],'loop':'1,2,1,3','native_playback':'PASS','new_generated_motion':0},
 'map_par':{'preserved_four_witnesses':[197,0,29,0],'source_pixel_locked':'PASS','art':'HOLD'},
 'qa':{'private_native_godot_checks':221,'public_cleanroom_checks':389,'real_native_fb_captures':16,'godot_screenshots':qa,'user_art':'HOLD','full_walkable_grid':'NOT_APPROVED','windows_export':'NOT_RUN'},
 'files':[{'path':name,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for name,p in all_files],
 'formal_seal':'NO','user_pc_writes':0,'paid_calls':0}
(RootManifest:=ROOT/'A30_SHA_MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
all_files.append(('A30_SHA_MANIFEST.json',RootManifest))
with zipfile.ZipFile(OUT,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=7) as z:
 for name,p in sorted(all_files):z.write(p,arcname=name)
with zipfile.ZipFile(OUT) as z:
 assert z.testzip() is None
 assert len(z.namelist())==len(all_files)
print(json.dumps({'zip':str(OUT),'bytes':OUT.stat().st_size,'sha256':hashlib.sha256(OUT.read_bytes()).hexdigest(),'file_count':len(all_files),'public_code_only':False},indent=2))
