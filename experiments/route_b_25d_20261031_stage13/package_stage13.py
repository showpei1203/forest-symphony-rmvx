from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil
r=Path(__file__).resolve().parent
z=r/'FS_ROUTE_B_STAGE13_NEW_GROUND_20261031_PRIVATE.zip'
names=['project.godot','author_stage13_ground.py','compile_stage12_source.py',
       'render_2d_stage12.gd','audit_stage12.py','actor_sweep_stage12.py',
       'compare_stage13.py','RUN_STAGE13_ALL_CHECKS.ps1','package_stage13.py',
       'STAGE13_SOURCE_LEDGER.json','CURRENT_HANDOFF_ROUTE_B_STAGE13_20261031.md']
files=[r/n for n in names]
for fold in ['source','parts','build','gpu','evidence','baseline_stage12']:
 files.extend(p for p in (r/fold).rglob('*') if p.is_file() and p.suffix.lower() in ('.png','.json','.txt','.md'))
assert all(p.is_file() for p in files)
with ZipFile(z,'w',ZIP_DEFLATED,compresslevel=6) as archive:
 for p in sorted(set(files)):archive.write(p,p.relative_to(r).as_posix())
with ZipFile(z) as archive:
 assert archive.testzip() is None
 for n in ['source/ground_long.png','source/PATH_SEMANTIC_MASK.png','source/WALKABLE_MASK.png','baseline_stage12/ground_long.png',
  'gpu/A_BLUE_COTTAGE/FULL_GPU.png','gpu/B_OCHRE_GROVE/FULL_GPU.png','evidence/STAGE12_VS_STAGE13_SOURCE_COMPARE.png',
  'evidence/STAGE13_ART_AND_SOURCE_QA.json','CURRENT_HANDOFF_ROUTE_B_STAGE13_20261031.md']:
  assert n in archive.namelist(),n
 cold=Path('E:/FS_ROUTE_B_STAGE13_COLD_CHECK')
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir()
 archive.extractall(cold)
 print('ZIP',z.name,'BYTES',z.stat().st_size,'FILES',len(archive.namelist()),'SHA256',sha256(z.read_bytes()).hexdigest())
 print('COLD_ROOT',cold)