#!/usr/bin/env python3
"""Forest Symphony R14: whole-source PAR forest canopy color ecology candidate.
R13 stays immutable. Generates independent complete transparent tree assets and a
separate Godot candidate scene. No crops from the composited map, no gameplay edits.
"""
from pathlib import Path
import numpy as np
from PIL import Image
import re,hashlib,collections,json
ROOT=(Path(__file__).resolve().parents[2] if Path(__file__).resolve().parent.name=='r14' else Path(__file__).resolve().parent/'base')
SOURCE=ROOT/'scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn'
OUTPUT=ROOT/'scenes/fs_01_maze_r14_canopy_ecology_80x58.tscn'
ASSETS=ROOT/'private_assets/independent_par'
GROUND=ROOT/'private_assets/a36_ground_only_2560x1856.png'
SHA=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
# V: foliage luminance scale, hue displacement around hue's 0..255 circular range, saturation factor.
VARIANTS={
'a35_oak_summer_176x174.png': [('mist_emerald',8,0.93,0.96),('shade_fern',13,1.08,0.88),('sun_gold',-7,1.06,1.06),('new_leaf',6,0.89,1.07),('wind_left',2,1.00,0.99),('wind_right',-3,1.02,1.01),('crown_broad',6,1.04,0.95),('crown_tall',-4,0.96,1.03)],
'a35_oak_golden_176x174.png': [('light_olive',7,0.94,1.00),('deep_amber',-7,1.08,0.94)],
'a36b_moss_pine_148x194.png': [('pine_cool',9,1.05,0.94),('pine_sunlit',-7,0.98,1.08)],
'a36b_river_willow_208x190.png': [('river_silver',8,0.82,1.06),('river_deep',5,1.09,0.88)],
'a35_birch_blush_122x170.png': [('birch_spring',8,0.96,1.04)],
'a35_birch_cream_122x170.png': [('birch_bright',-5,0.91,1.05)]}

def shape_variant(image, shape):
    if shape not in ('wind_left','wind_right','crown_broad','crown_tall'):
        return image
    rgba=np.array(image.convert('RGBA'))
    out=np.zeros_like(rgba)
    h,w=rgba.shape[:2]
    for y in range(h):
        # Keep the tree root, lower trunk, and footpoint unchanged. Only crown diverges.
        t=float(np.clip((0.78*h-y)/(0.57*h),0,1))
        if shape=='wind_left':
            shift=-5.7*t*t; scale=1.0
        elif shape=='wind_right':
            shift=5.7*t*t; scale=1.0
        elif shape=='crown_broad':
            shift=0; scale=1.0+0.060*t
        else:
            shift=0; scale=1.0-0.085*t
        source_x=np.rint((np.arange(w)-w/2-shift)/scale+w/2).astype(int)
        valid=(source_x>=0)&(source_x<w)
        out[y,valid]=rgba[y,source_x[valid]]
    assert np.array_equal(out[round(h*.79):],rgba[round(h*.79):])
    assert np.max(out[:,0,3])==0 and np.max(out[:,-1,3])==0, 'Crown cropped: expand canvas'
    return Image.fromarray(out,'RGBA')

def variant_image(original, hue, sat, value):
    rgba=np.array(original.convert('RGBA'))
    hsv=np.array(original.convert('RGB').convert('HSV')).astype(np.float32)
    yy=np.arange(rgba.shape[0])[:,None]
    # Tint the foliage, not the roots/trunk. Original artwork's semantic tree crown
    # occupies upper 68%; restrict changes primarily to green/yellow living leaves.
    hsv_source=hsv.copy()
    top=np.clip((0.76*rgba.shape[0]-yy)/(0.21*rgba.shape[0]),0,1)
    rgb=rgba[:,:,:3].astype(np.float32)
    leafy=np.maximum(rgb[:,:,1]-rgb[:,:,2]*0.73,0)/110.0
    leafy=np.clip(leafy,0,1)
    strength=top*leafy*(rgba[:,:,3]/255.0)
    hsv[:,:,0]=np.mod(hsv[:,:,0]+strength*hue,256)
    hsv[:,:,1]=np.clip(hsv[:,:,1]*(1+(sat-1)*strength),0,255)
    hsv[:,:,2]=np.clip(hsv[:,:,2]*(1+(value-1)*strength),0,255)
    out=Image.fromarray(hsv.astype(np.uint8),'HSV').convert('RGB')
    a=Image.fromarray(rgba[:,:,3], 'L')
    out.putalpha(a)
    return out

def main():
 assert SHA(GROUND)=='ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911'
 data=SOURCE.read_text('utf-8')
 assert data.count('source_file = "res://private_assets/independent_par/')==326
 paths={}
 for name,variants in VARIANTS.items():
    original=Image.open(ASSETS/name).convert('RGBA'); assert original.getchannel('A').getextrema()[0]==0
    for vn,h,s,v in variants:
     dest=ASSETS/('r14_'+name.replace('.png','')+'_'+vn+'.png')
     pic=shape_variant(variant_image(original,h,s,v),vn)
     assert pic.size==original.size
     if vn not in ('wind_left','wind_right','crown_broad','crown_tall'):
      assert pic.getchannel('A').tobytes()==original.getchannel('A').tobytes()
     pic.save(dest,optimize=True)
     paths[(name,vn)]=('r14_'+name.replace('.png','')+'_'+vn+'.png', SHA(dest))
 # Scene regex only edits PAR display asset refs and mirrors rooted objects, not footpoint positions/collision.
 pattern=re.compile(r'(\[node name="(a36_tree_\d+)" type="Node2D" parent="YSort"\]\n)(position = Vector2\(([\d.\-]+), ([\d.\-]+)\)\n)(script = ExtResource\("2_object"\)\n)(source_file = "res://private_assets/independent_par/([^"\n]+)"\n)(source_sha256 = "([a-f0-9]+)"\n)')
 changed=collections.Counter();mirrored=0;total=0
 def repl(m):
  nonlocal mirrored,total
  total+=1; node=m.group(2); ix=int(node.rsplit('_',1)[-1]); x=int(float(m.group(4)));y=int(float(m.group(5))); old=m.group(8)
  local_seed=(ix*109 + (x//280)*23 + (y//290)*71)%101
  # roughly 2/3 of oak species receive living foliage tone, dispersed by forest sub-groves
  spec=VARIANTS.get(old)
  if spec and local_seed<72:
    index=(ix//5 + x//340 + y//460)%len(spec)
    vn=spec[index][0]
    dest,sh=paths[(old,vn)]
    leaf=m.group(7).replace(old,dest)
    sha=f'source_sha256 = "{sh}"\n'
    changed[dest]+=1
  else:leaf=m.group(7);sha=m.group(9)
  flip=(ix*31+x//15+y//35)%7 in (1,3,4)
  if flip: mirrored+=1
  transform='scale = Vector2(-1, 1)\n' if flip else ''
  return m.group(1)+m.group(3)+transform+m.group(6)+leaf+sha
 result,n=pattern.subn(repl,data)
 assert n==310,(n, 'not all tree objects parsed')
 assert result.count('source_file = "res://private_assets/independent_par/')==326
 assert len(changed)>0
 # Scene root renaming is cosmetic and does not overwrite R13
 result=result.replace('FS_01_MAZE_R13_PlayableTopology','FS_01_MAZE_R14_CanopyEcology',1)
 OUTPUT.write_text(result,encoding='utf-8')
 manifest={'phase':'R14-CANOPY-ART-CANDIDATE','source_scene_sha256':SHA(SOURCE),'candidate_scene_sha256':SHA(OUTPUT),'ground_sha256_immutable':SHA(GROUND),'candidate_scene':OUTPUT.name,'source_object_count':326,'tree_objects':310,'tree_art_variant_assignments':sum(changed.values()),'mirrored_tree_objects':mirrored,'variants_count':len(paths),'variant_use_counts':dict(changed),'status':'ART HOLD / NATIVE GPU NOT YET VALIDATED'}
 f=ROOT/'data/fs_01_maze_r14_canopy_art_manifest.json';f.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
 print(json.dumps(manifest,ensure_ascii=False,indent=2))
if __name__=='__main__':main()
