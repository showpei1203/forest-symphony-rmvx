from pathlib import Path
from hashlib import sha256
from zipfile import ZipFile,ZIP_DEFLATED
import shutil,json
root=Path(__file__).resolve().parent
out=root/'FS_ROUTE_B_STAGE12_STYLEFIRST_2D_20261031_PRIVATE.zip'
req=['project.godot','compile_stage12_source.py','render_2d_stage12.gd',
'audit_stage12.py','actor_sweep_stage12.py','make_stage12_evidence.py',
'RUN_STAGE12_ALL_CHECKS.ps1','package_stage12.py',
'CURRENT_HANDOFF_ROUTE_B_STAGE12_20261031.md','SOURCE_LEDGER.json']
files=[root/x for x in req]
for folder in ['source','parts','build','gpu','evidence','baseline_stage11']:
 for p in (root/folder).rglob('*'):
  if p.is_file() and p.suffix.lower() in ['.png','.json','.txt','.md']:
   files.append(p)
missing=[str(p) for p in files if not p.is_file()]
assert not missing,missing
with ZipFile(out,'w',ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(set(files)):
  z.write(p,p.relative_to(root).as_posix())
with ZipFile(out) as z:
 assert z.testzip() is None
 for x in ['source/ground_long.png','source/house_blue.png','parts/tree_moss/ROOT_DECAL_GROUND.png','parts/sacred_tree/BASE_32.png','build/A_BLUE_COTTAGE/SCENE_MANIFEST.json','build/B_OCHRE_GROVE/PAR.png','gpu/A_BLUE_COTTAGE/FULL_GPU.png','gpu/B_OCHRE_GROVE/FULL_GPU.png','evidence/STAGE11_3D_VS_STAGE12_2D.png','evidence/STAGE12_FINAL_QA.json','RUN_STAGE12_ALL_CHECKS.ps1']:
  assert x in z.namelist(),x
 cold=Path('E:/FS_ROUTE_B_STAGE12_COLD_CHECK')
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir()
 z.extractall(cold)
 print('ZIP',out.name,'BYTES',out.stat().st_size,'FILES',len(z.namelist()),'SHA256',sha256(out.read_bytes()).hexdigest())
 print('COLD_EXTRACT',cold)