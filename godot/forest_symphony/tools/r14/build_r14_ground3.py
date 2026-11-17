#!/usr/bin/env python3
"""R14 Ground3 independent hi-frequency reconstruction from ORIGINAL continuous Ground.
No road/stroke drawing, edits to ground semantics, PAR, collisions, or R13 sealed files.
This is a visual CANDIDATE, not native 32px-authored pixel art.
"""
from pathlib import Path
from PIL import Image,ImageFilter
import hashlib,json
P=(Path(__file__).resolve().parents[2] if Path(__file__).resolve().parent.name=='r14' else Path(__file__).resolve().parent/'base')
AS=P/'private_assets'
BASE=AS/'a36_ground_only_2560x1856.png'
ORIGINAL=AS/'a36_ground_original_1478x1064.png'
SHA=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert SHA(BASE)=='ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911'
assert SHA(ORIGINAL)=='020e8c8a7a84f43653ffc43fe660614525d13ee9e956fd7e27b5a18923315a38'
base=Image.open(BASE).convert('RGB')
source=Image.open(ORIGINAL).convert('RGB')
sharper=source.resize(base.size,Image.Resampling.LANCZOS)
# Keep pixel-art edge substance, reduce nearest neighbor staircase, avoid blown-out flowers.
art=Image.blend(base,sharper,0.65)
art=art.filter(ImageFilter.UnsharpMask(radius=0.85,percent=85,threshold=4))
out=AS/'a36_ground3_r14_2560x1856.png'
art.save(out,optimize=True)
script_orig=(P/'scripts/a36b_world.gd').read_text('utf-8')
script_new=script_orig.replace('res://private_assets/a36_ground_only_2560x1856.png','res://private_assets/a36_ground3_r14_2560x1856.png').replace(SHA(BASE),SHA(out))
assert script_new!=script_orig
(P/'scripts/a36b_world_r14_ground3.gd').write_text(script_new,'utf-8')
scene=(P/'scenes/fs_01_maze_r14_canopy_ecology_80x58.tscn').read_text('utf-8')
assert scene.count('res://scripts/a36b_world.gd')==1
scene=scene.replace('res://scripts/a36b_world.gd','res://scripts/a36b_world_r14_ground3.gd')
scene=scene.replace('FS_01_MAZE_R14_CanopyEcology','FS_01_MAZE_R14_Ground3Canopy',1)
scenepath=P/'scenes/fs_01_maze_r14_ground3_canopy_80x58.tscn'
scenepath.write_text(scene,'utf-8')
import numpy as np
A=np.asarray(base).astype('int16');B=np.asarray(art).astype('int16');D=np.abs(A-B)
print(json.dumps({'ground_sha256_original':SHA(BASE),'ground3_sha256':SHA(out),'R14_scene':scenepath.name,'R14_scene_sha256':SHA(scenepath),'ground_changed_pixels':int(np.any(D>0,axis=2).sum()),'mean_abs_channel_delta':round(float(D.mean()),3),'max_abs_channel_delta':int(D.max())},indent=2))
