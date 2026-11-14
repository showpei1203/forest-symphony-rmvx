#!/usr/bin/env python3
"""FS six biome maze-village art contract. Source-only metadata validation, not rendering QA."""
import json,sys
from pathlib import Path
p=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parents[1]/'data/fs_six_biomes_world_catalog.json'
d=json.loads(p.read_text())
assert d['schema']=='fs-six-biomes-maze-village-world-art/v1'
assert d['owner']=='FS_GODOT_ART_PIPELINE_ONLY_EVENTS_MANAGED_EXTERNALLY'
assert d['large_map_technical_pilot']['logical_grid']==[80,58]
assert d['large_map_technical_pilot']['image_pixels']==[2560,1856]
assert d['layering']['authoring_order']==['GROUND_ONLY','INDEPENDENT_COMPLETE_PAR','SHADOW','LIGHT','ANIMATED_WATER_OR_EFFECTS','COLLISION_32','GODOT_RUNTIME']
assert len(d['biomes'])==6
ids=set(); scene_ids=set()
for b in d['biomes']:
    assert b['id'] not in ids;ids.add(b['id'])
    assert len(b['base_palette'])>=5
    for scene_type in ('maze','village'):
        s=b[scene_type]; assert s['scene_id'] not in scene_ids;scene_ids.add(s['scene_id'])
        assert len(s['ground_materials'])>=3
        assert len(s['par_families'])>=3
        assert len(s['visual_navigation_cues'])>=2
        assert s['ground_only_first'] and s['par_full_independent']
        assert s['size_class']=='LARGE_80x58_TARGET_NOT_YET_BUILT'
assert len(scene_ids)==12
assert d['status']=='PLANNED_NO_LARGE_MAP_ART_APPROVED'
print('A35 SIX BIOME SOURCE CATALOG PASS: 6 terrain types / 12 scenes / 80x58 size pilot / no fake artwork claims')
