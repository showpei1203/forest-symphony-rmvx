#!/usr/bin/env python3
"""FS A34. ImageGen-produced ISOLATED FULL building art -> original complete house RGBA.
NOT allowed: deriving any house pixels by slicing a finished scene / Ground.
Rebuilds only a fresh A34 project from the verified A33 project, and preserves both baselines.
"""
from pathlib import Path
from PIL import Image
import json, hashlib, shutil, re, numpy as np, argparse

parser=argparse.ArgumentParser(description='Rebuild FS A34 from sealed A33 and 2 full separate house PNGs; no flattened Master crops')
parser.add_argument('--a33',type=Path,required=True,help='Owner-only verified A33 Godot source directory')
parser.add_argument('--output',type=Path,required=True,help='Fresh A34 output directory; must not equal A33')
parser.add_argument('--workshop-png',type=Path,required=True,help='High-resolution independent transparent complete house A source')
parser.add_argument('--residence-png',type=Path,required=True,help='High-resolution independent transparent complete house B source')
args=parser.parse_args()
source=args.a33.expanduser().resolve()
target=args.output.expanduser().resolve()
assert source!=target and source.is_dir() and (source/'scenes/a33_groundfirst_lantern_scene.tscn').exists()
inputs = [
    ('obj_001_a36f_elf_cottage_a','a36f_elf_cottage_a_annex_rgba','a34_elf_workshop_house_complete',str(args.workshop_png),(288,282), (285,406), 'left_workshop_complete'),
    ('obj_002_a36f_elf_cottage_b','a36f_elf_cottage_b_moss_roof_rgba','a34_elf_residence_atelier_complete',str(args.residence_png),(252,252), (1046,419), 'right_residence_atelier'),
]
sha=lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
if target.exists(): shutil.rmtree(target)
shutil.copytree(source,target,ignore=shutil.ignore_patterns('.godot','*.import','*.uid','qa_*_old.log'))
(original_path:=target/'private_assets').mkdir(exist_ok=True)
ARTDIR=original_path/'independent_par'
sceneText=(target/'scenes/a33_groundfirst_lantern_scene.tscn').read_text()
manifest=json.loads((target/'data/a33_groundfirst_lantern_manifest.json').read_text())
artData=[]
for node,oldid,newid,original_name,dim,foot,semantic in inputs:
    original = Path(original_name).expanduser().resolve()
    assert original.is_file()
    high=original_path/('a34_source_'+semantic+'.png')
    shutil.copyfile(original,high)
    raw=Image.open(high).convert('RGBA')
    rgba=np.array(raw)
    alpha=rgba[:,:,3]
    yy,xx=np.where(alpha>=32)
    assert xx.size>40000 and xx.min()>3 and xx.max()<raw.width-2,(xx.min(),xx.max(),raw.size)
    box=(max(0,int(xx.min())-8),max(0,int(yy.min())-8),min(raw.width,int(xx.max())+9),min(raw.height,int(yy.max())+9))
    cropped=raw.crop(box)
    margin=8
    target_size=(dim[0]-margin*2,dim[1]-margin*2)
    # preserve aspect ratio and avoid distortions; scale until fully within the locked product canvas
    fac=min(target_size[0]/cropped.width,target_size[1]/cropped.height)
    size=(max(1,round(cropped.width*fac)),max(1,round(cropped.height*fac)))
    img=cropped.resize(size,Image.Resampling.LANCZOS)
    # Keep original 1x color sophistication while eliminating isolated 1px chroma speckle.
    # No palette dithering or separate partial sprite patchwork.
    gray=np.asarray(img,dtype=np.uint8).copy()
    # Adaptive alpha stepped to 4 states, sharpen edge without deleting actual full object pixels.
    aa=gray[:,:,3]
    aa = np.select([aa<32,aa<96,aa<180,aa<235],[0,85,170,225],default=255).astype('uint8')
    gray[:,:,3]=aa
    gray[aa==0,:3]=0
    img=Image.fromarray(gray,mode='RGBA')
    # Canvas transparent; ensure full roof and full base WITH margins
    out=Image.new('RGBA',dim,(0,0,0,0))
    pos=((dim[0]-size[0])//2,(dim[1]-size[1])//2)
    out.alpha_composite(img,pos)
    file=ARTDIR/(newid+'_'+str(dim[0])+'x'+str(dim[1])+'.png')
    out.save(file,optimize=True)
    bbox=out.getbbox()
    assert bbox and bbox[0]>=5 and bbox[1]>=5 and bbox[2]<=dim[0]-5 and bbox[3]<=dim[1]-5,(file,bbox)
    digest=sha(file)
    print('CREATE',file.name,'source',raw.size,'target',dim,'bbox',bbox,'sha',digest)
    oldentry=manifest['assets'].pop(oldid)
    manifest['assets'][newid]={
      'id':newid, 'file':'private_assets/independent_par/'+file.name, 'sha256':digest,
      'original_generator_file':'private_assets/'+high.name,
      'original_generator_sha256':sha(high),
      'source_type':'AI_GENERATED_INDEPENDENT_COMPLETE_PNG_NOT_MASTER_CROP',
      'transformation':'transparent_bbox_only_crop; aspect_preserved LANCZOS; 4-state alpha; no composition source',
      'size':list(dim),'opaque_bbox':list(bbox),'semantic':'house','full_independent_art':True,
      'art_status':'CANDIDATE_NEEDS_USER_1X','previous_house_sha':oldentry['sha256'],
      'style':'moss slate shingle roof, carved timber, warm amber glass, stone foundation, ivy and flowers',
      'foot_world':list(foot), 'semantic_subtype':semantic
    }
    count=0
    for obj in manifest['objects']:
        if obj['id'] != node:continue
        assert obj['asset_id']==oldid and obj['foot']==list(foot)
        obj['asset_id']=newid
        obj['w'],obj['h']=dim
        obj['x']=foot[0]-dim[0]//2
        obj['y']=foot[1]-dim[1]+1
        obj['source_sha256']=digest
        obj['art_status']='CANDIDATE_WHOLE_HOUSE_NO_SOURCE_CROP'
        obj['old_house_sha256']=oldentry['sha256']
        count+=1
    assert count==1
    # Update only the source path and SHA in exact target Node2D, preserve old scene untouched.
    pat=r'(\[node name="'+re.escape(node)+r'" type="Node2D" parent="YSort"\]\n)(.*?)(?=\[node name=|\Z)'
    def repl(m):
        s=m.group(2)
        assert oldentry['sha256'] in s and oldentry['file'] in s
        s=s.replace(oldentry['file'],manifest['assets'][newid]['file'])
        s=s.replace(oldentry['sha256'],digest)
        return m.group(1)+s
    sceneText,n=re.subn(pat,repl,sceneText,flags=re.S)
    assert n==1,(node,n)
    artData.append({'oldid':oldid,'newid':newid,'node':node,'new_sha':digest,'old_sha':oldentry['sha256'],
                    'size':dim,'foot':foot,'bbox':bbox,'src':high.name,'src_sha':sha(high)})
assert len(manifest['objects'])==146 and len(manifest['assets'])==27
assert all(any(o['asset_id']==a['newid'] for o in manifest['objects']) for a in artData)
assert sha(target/'private_assets/ground_only.png')=='3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000'
new_scene=target/'scenes/a34_groundfirst_full_houses_scene.tscn'
# New versioned world script to make diagnostics unambiguous; A33 scene remains untouched.
world_src = (target/'scripts/a33_world.gd').read_text()
world_src = world_src.replace('A33 Ground-only source missing','A34 Ground-only source missing').replace('A33 object count mismatch','A34 object count mismatch').replace('FS A33 GROUND-FIRST GODOT:','FS A34 GROUND-FIRST GODOT:').replace('full-height lanterns','full-height lanterns and 2 separate complete house assets')
(target/'scripts/a34_world.gd').write_text(world_src)
sceneText=sceneText.replace('res://scripts/a33_world.gd','res://scripts/a34_world.gd').replace('[node name="FS_A33_GroundFirst"','[node name="FS_A34_GroundFirst"')
new_scene.write_text(sceneText)
manifest.update({'schema':'fs-a34-ground-first-independent-full-house-family/v1','status':'ART_CANDIDATE_NOT_USER_APPROVED','origin_scene':'A33 four full lanterns preserved unchanged; replaces only 2 complete independent house sprites'})
manifest['a34_house_gate']={'ground_sha256':manifest['ground']['sha256'],'before':'A33 old moss house family','houses':artData,'source_method':'isolated original transparent full RGBA, never flat Master crop','lantern_count':4,'collider_count':140,'scene_instance_count':146,'source_family_count':27,'art_gate':'HOLD','door_region_gate':'HOLD: exact entrance openings and walkable footpoints not mapped'}
manifest_file=target/'data/a34_groundfirst_full_houses_manifest.json'
manifest_file.write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
proj=target/'project.godot'; p=proj.read_text();p=p.replace('Godot-first A33 full-height independent lantern','Godot-first A34 full independent house family').replace('res://scenes/a33_groundfirst_lantern_scene.tscn','res://scenes/a34_groundfirst_full_houses_scene.tscn');proj.write_text(p)
print('A34 SCENE',new_scene,'manifest',manifest_file, 'source families',len(manifest['assets']))
