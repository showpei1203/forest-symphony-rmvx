from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil
r=Path(__file__).resolve().parent
z=r/'FS_ROUTE_B_STAGE15_SEAM_QUILTING_PRIVATE_20261031.zip'
required=['project.godot','author_ground15.py','compile_stage12_source.py','render_2d_stage12.gd','audit_stage12.py','actor_sweep_stage12.py','compare_stage15.py','RUN_STAGE15_ALL_CHECKS.ps1','package_stage15.py','CURRENT_HANDOFF_STAGE15_20261031.md']
files=[r/x for x in required]
for folder in ('source','parts','build','gpu','evidence','baseline_stage14'):
 for p in (r/folder).rglob('*'):
  if p.is_file() and p.suffix.lower() in ('.png','.json','.txt','.md'):
   files.append(p)
assert all(p.is_file() for p in files)
with ZipFile(z,'w',ZIP_DEFLATED,compresslevel=6) as zip:
 for p in sorted(set(files)):zip.write(p,p.relative_to(r).as_posix())
with ZipFile(z) as zip:
 assert zip.testzip() is None
 for x in ['source/ground_long.png','source/ground_stage12_source.png','source/PATH_SEMANTIC_MASK.png','baseline_stage14/ground_long.png','gpu/A_BLUE_COTTAGE/FULL_GPU.png','gpu/B_OCHRE_GROVE/FULL_GPU.png','evidence/STAGE15_QA.json','evidence/STAGE14B_VS_STAGE15_GROUND_1X.png','RUN_STAGE15_ALL_CHECKS.ps1']:
  assert x in zip.namelist(),x
 cold=Path('E:/FS_ROUTE_B_STAGE15_COLD_CHECK')
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir()
 zip.extractall(cold)
 print('ZIP',z.name,'FILE_COUNT',len(zip.namelist()),'BYTES',z.stat().st_size,'SHA256',sha256(z.read_bytes()).hexdigest(),flush=True)
 print('EXTRACTED',cold,flush=True)