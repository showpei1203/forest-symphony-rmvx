from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from hashlib import sha256
import shutil,json
r=Path(__file__).resolve().parent
dest=r/'FS_ROUTE_B_STAGE7_NATIVE_ART_SOURCE_20261031.zip'
required=[
 'project.godot','render_scene.gd','render_stage2.gd','render_terrain_stage4.gd',
 'render_tree_stage5.gd','render_stage7_cottage.gd','FS_Elf_Cottage.tscn',
 'cottage_prefab.gd','author_ground_stage5.py','author_roof_material.py',
 'fetch_stage7_assets.py','package_stage7.py','compare_houses_stage7.py','compare_material_stage7.py',
 'compare_fixed_stage7.py','qa.py','audit_tree_contact.py','test_actor_occlusion.py',
 'STAGE7_SOURCE_PROVENANCE.json','STAGE7_ROOF_TEXTURE_MANIFEST.json',
 'ASSET_MANIFEST.json','FANTASY_LICENSE.txt','TERRAIN_STAGE5_SOURCE.json',
 'CURRENT_HANDOFF_ROUTE_B_STAGE7_20261031.md'
]
paths=[r/n for n in required]
paths+=list((r/'assets').rglob('*.glb'))
paths+=list((r/'assets').rglob('*.png'))
paths+=list((r/'source_raw').rglob('*.glb'))
paths.append(r/'source_raw'/'.gdignore')
paths+=list((r/'out').rglob('*.png'))
paths+=list((r/'out').rglob('*.json'))
paths+=list((r/'candidates').rglob('*.png'))
paths+=list((r/'candidates').rglob('*.json'))
missing=[str(p.relative_to(r)) for p in paths if not p.exists()]
assert not missing,missing
with ZipFile(dest,'w',ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(paths):z.write(p,p.relative_to(r).as_posix())
with ZipFile(dest) as z:
 assert z.testzip() is None
 for name in ['source_raw/witch_cottage.glb','assets/witch_cottage_std.glb','assets/roof_thatch_stage7.png','out/GROUND.png','out/PAR.png','out/COMPOSITE_PREVIEW.png','out/STAGE7_THREE_HOUSE_COMPARISON.png','out/STAGE7_FIXED_ROOF_COMPARE.png','out/STAGE6_ACTOR_OCCLUSION_6PANEL.png','render_stage7_cottage.gd']:
  assert name in z.namelist(),name
 cold=Path('E:/FS_ROUTE_B_STAGE7_COLD_CHECK')
 if cold.exists():shutil.rmtree(cold)
 cold.mkdir()
 z.extractall(cold)
 print('PACKAGE',dest.name,'FILE_COUNT',len(z.namelist()),'BYTES',dest.stat().st_size,'SHA256',sha256(dest.read_bytes()).hexdigest(),flush=True)
 print('COLD_EXTRACTED',cold)