#!/usr/bin/env python3
"""FS A35 – produce complete independently generated RGBA tree-family sources.

No sprite is cut from flattened Master. Input is two AI-rendered *isolated tree family* sheets
with two non-touching individual complete source sprites each. Those are art-source sheets,
not maps. Preserve original generated files, crop only empty transparency between individual
complete objects, retain old A34 scene, Ground, and all unrelated independent PAR SHA.
"""
from pathlib import Path
import hashlib, json, shutil, re, argparse
from PIL import Image
import numpy as np

ROOT=Path('/mnt/data')
BASE=ROOT/'fs_godot_a34'
DST=ROOT/'fs_godot_a35'
RAW_FILES=[ROOT/'two_highly_detailed_pixel_art_fantasy_trees_on_a_t.png', ROOT/'two_high_quality_pixel_art_fantasy_rpg_tree_assets.png']
SHA=lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
GROUND_SHA='3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000'
# Each complete object source is within one half of an AI-generated pair, not a scene.
STYLES=[('a35_oak_summer',0,'L',(176,174)),('a35_birch_blush',0,'R',(122,170)),
        ('a35_oak_golden',1,'L',(176,174)),('a35_birch_cream',1,'R',(122,170))]
# Existing positions all around borders; no interior path obstruction.
PLACEMENTS=[
('obj_014_a36f_dense_tree_10','a35_oak_summer'),
('obj_039_a36f_dense_tree_06','a35_birch_blush'),
('obj_050_a36f_dense_tree_09','a35_oak_golden'),
('obj_058_a36f_dense_tree_02','a35_birch_cream'),
('obj_021_a36f_dense_tree_09','a35_oak_summer'),
('obj_064_a36f_dense_tree_08','a35_birch_blush'),
('obj_068_a36f_dense_tree_03','a35_oak_golden'),
('obj_065_a36f_dense_tree_04','a35_birch_cream'),
]


def convert(src_path:Path,side:str,canvas_size:tuple[int,int])->tuple[Image.Image,dict]:
    raw=Image.open(src_path).convert('RGBA')
    assert raw.size==(1774,887), f'Unexpected source sheet {raw.size}'
    # gap 900..1030 is transparent, splitting does not delete any actual object pixel.
    region=raw.crop((0,0,927,raw.height)) if side=='L' else raw.crop((950,0,raw.width,raw.height))
    A=np.array(region.getchannel('A'))
    ys,xs=np.where(A>=36)
    assert len(xs)>40000,(src_path,side,len(xs))
    rect=(max(0,int(xs.min())-7),max(0,int(ys.min())-7),min(region.width,int(xs.max())+8),min(region.height,int(ys.max())+8))
    cropped=region.crop(rect)
    # Remove only visually erroneous high-saturation red hot pixels in supplied source, not object geometry.
    ar=np.asarray(cropped).copy()
    r,g,b,alpha=[ar[:,:,i].astype('int16') for i in range(4)]
    red_noise=(r>145)&(r>g*1.5)&(r>b*1.5)&(g<125)&(alpha>0)
    # Nearby unrelated petals are pink/white, not bright primary red; transparent hot stray pixels only.
    ar[red_noise,3]=0
    clean=Image.fromarray(ar,'RGBA')
    cw,ch=canvas_size; margin=7
    fac=min((cw-2*margin)/clean.width,(ch-2*margin)/clean.height)
    size=(max(1,round(clean.width*fac)),max(1,round(clean.height*fac)))
    resized=clean.resize(size,Image.Resampling.LANCZOS)
    arr=np.array(resized).copy()
    a=arr[:,:,3]
    arr[:,:,3]=np.select([a<26,a<82,a<155,a<230],[0,85,170,230],default=255).astype('uint8')
    arr[arr[:,:,3]==0,:3]=0
    obj=Image.fromarray(arr,'RGBA')
    out=Image.new('RGBA',canvas_size,(0,0,0,0))
    pos=((cw-size[0])//2,(ch-size[1])//2)
    out.alpha_composite(obj,pos)
    box=out.getbbox()
    assert box is not None and box[0]>=4 and box[1]>=4 and box[2]<=cw-4 and box[3]<=ch-4,(src_path,side,box)
    return out,{'raw_cropped_bbox':rect,'raw_size':raw.size,'output_size':canvas_size,'alpha_bbox':box,
                'raw_red_artifacts_removed':int(np.count_nonzero(red_noise)), 'transparent_edge':True,
                'transformation':'split_at_proven_empty_art_sheet_gap; isolate_complete_sprite_alpha_bbox; aspect_preserved downscale; stepped edge alpha'}


def main():
    global BASE, DST, RAW_FILES
    parser=argparse.ArgumentParser(description='Build Godot independent complete-tree art from A34 baseline and 2 isolated full-tree source sheets; no Master crop')
    parser.add_argument('--base',required=True,help='Existing A34 complete Godot project (never edited)')
    parser.add_argument('--dest',required=True,help='New A35 output directory')
    parser.add_argument('--pair1',required=True,help='Original isolated 2-tree transparent artwork (pair #1)')
    parser.add_argument('--pair2',required=True,help='Original isolated 2-tree transparent artwork (pair #2)')
    args=parser.parse_args()
    BASE=Path(args.base)
    DST=Path(args.dest)
    RAW_FILES=[Path(args.pair1),Path(args.pair2)]
    assert BASE.is_dir() and all(p.is_file() for p in RAW_FILES)
    assert SHA(BASE/'private_assets/ground_only.png')==GROUND_SHA
    if DST.exists():shutil.rmtree(DST)
    shutil.copytree(BASE,DST,ignore=shutil.ignore_patterns('.godot','*.import','*.uid','qa','qa_a33','qa_a34'))
    (DST/'qa_a35').mkdir(exist_ok=True)
    private=DST/'private_assets'
    for i,p in enumerate(RAW_FILES,1):shutil.copyfile(p,private/f'a35_original_complete_tree_pair_{i}.png')
    manifest=json.loads((DST/'data/a34_groundfirst_full_houses_manifest.json').read_text())
    scene=(DST/'scenes/a34_groundfirst_full_houses_scene.tscn').read_text()
    assets={}
    for id,fi,side,dim in STYLES:
        out,info=convert(RAW_FILES[fi],side,dim)
        asset_name=f'{id}_{dim[0]}x{dim[1]}.png'
        target=private/'independent_par'/asset_name
        out.save(target,optimize=True)
        digest=SHA(target)
        assets[id]={'id':id,'file':'private_assets/independent_par/'+asset_name,'sha256':digest,
            'source_type':'AI_GENERATED_INDEPENDENT_COMPLETE_RGBA_TREE_FAMILY_NOT_SCENE_CROP',
            'original_pair_file':f'private_assets/a35_original_complete_tree_pair_{fi+1}.png',
            'original_pair_sha256':SHA(RAW_FILES[fi]),'original_pair_slot':side,
            'full_independent_art':True,'art_status':'CANDIDATE_REQUIRES_USER_1X',
            'semantic':'tree','size':list(dim),**info}
        manifest['assets'][id]=assets[id]
    changed=[]
    # Allow match via node name prefix (actual user project names are authoritative).
    for prefix,newid in PLACEMENTS:
        matched=[o for o in manifest['objects'] if o['id']==prefix]
        assert len(matched)==1,(prefix,len(matched))
        obj=matched[0]
        old_asset=obj['asset_id']
        oldsha=obj['source_sha256']
        foot=obj['foot'][:]
        newasset=assets[newid]
        obj.update({'asset_id':newid,'source_sha256':newasset['sha256'],
                    'w':newasset['size'][0],'h':newasset['size'][1],
                    'x':foot[0]-newasset['size'][0]//2,'y':foot[1]-newasset['size'][1]+1,
                    'art_status':'A35_NEW_TREE_ART_CANDIDATE_FULL_SPRITE',
                    'old_tree_asset_id':old_asset,'old_tree_sha256':oldsha})
        # Replace only this full separate object Scene node's source reference, no partial map cut.
        pat=r'(\[node name="'+re.escape(prefix)+r'" type="Node2D" parent="YSort"\]\n)(.*?)(?=\[node name=|\Z)'
        def replace(m):
            s=m.group(2)
            assert oldsha in s and manifest['assets'][old_asset]['file'] in s,(prefix,oldsha)
            return m.group(1)+s.replace(oldsha,newasset['sha256']).replace(manifest['assets'][old_asset]['file'],newasset['file'])
        scene,n=re.subn(pat,replace,scene,flags=re.S)
        assert n==1,(prefix,n)
        changed.append({'instance_id':prefix,'foot':foot,'old_sha':oldsha,'new_sha':newasset['sha256'],
                        'new_family':newid,'previous_family':old_asset})
    assert len(changed)==8
    assert len(manifest['objects'])==146 and len(manifest['assets'])==31
    assert SHA(DST/'private_assets/ground_only.png')==GROUND_SHA
    manifest.update({'schema':'fs-a35-artist-owned-complete-tree-family/v1',
                     'status':'NEW_INDEPENDENT_TREE_CANDIDATE_NOT_VISUAL_APPROVED',
                     'origin_scene':'A34 unchanged Ground, houses, lamps, 138 instance sources; 8 selected trees new independent full sprites',
                     'a35_tree_gate':{'families':[{'id':x,'sha':assets[x]['sha256'],'size':assets[x]['size']} for x,_,_,_ in STYLES],
                         'replacements':changed,'original_ground_sha256':GROUND_SHA,
                         'baseline':'A34 Ground/PAR/house/lamps preserve; 8 tree instances only',
                         'art_status':'HOLD','collision_status':'CANDIDATE_AND_UNCHANGED'}})
    (DST/'data/a35_independent_tree_family_manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
    (DST/'scenes/a35_independent_tree_family_scene.tscn').write_text(scene.replace('a34_world.gd','a35_world.gd'))
    s=(DST/'scripts/a34_world.gd').read_text().replace('A34','A35').replace('Ground-first A34','Ground-first A35')
    (DST/'scripts/a35_world.gd').write_text(s)
    p=DST/'project.godot'
    t=p.read_text().replace('a34_groundfirst_full_houses_scene.tscn','a35_independent_tree_family_scene.tscn').replace('Godot-first A34','Godot-first A35')
    p.write_text(t)
    out={'stage':'A35','ground_sha256':GROUND_SHA,'new_families':assets,'placements':changed,
         'previous_houses_source_SHA_unchanged':[manifest['assets'][i]['sha256'] for i in ['a34_elf_workshop_house_complete','a34_elf_residence_atelier_complete']],
         'lamp_source_SHA_unchanged':manifest['assets']['a33_ornate_lantern_complete']['sha256']}
    (DST/'qa_a35/A35_SOURCE_BUILD_QA.json').write_text(json.dumps(out,indent=2,ensure_ascii=False)+'\n')
    print(json.dumps({'status':'A35 BUILT','new_family_count':len(assets),'new_tree_replacements':len(changed),'ground_sha':GROUND_SHA,'objects':len(manifest['objects']),'asset_families':len(manifest['assets'])},indent=2))

if __name__=='__main__':main()
