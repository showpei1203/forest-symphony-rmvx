"""FS A36B: artist-owned complete transparent tree species and ecological placement.
Fails closed on existing destination; does not modify A36, Ground, or sealed VX.
"""
from PIL import Image,ImageDraw
from pathlib import Path
import hashlib, shutil, json, re, os, math
from collections import Counter

BASE_ENV=os.environ.get('FS_A36B_BASE')
OUT_ENV=os.environ.get('FS_A36B_OUTPUT')
SHEET_ENV=os.environ.get('FS_A36B_SHEET')
if not (BASE_ENV and OUT_ENV and SHEET_ENV):
    raise RuntimeError('Set FS_A36B_BASE (existing A36 R2 owner-only project), FS_A36B_OUTPUT (new empty folder path), FS_A36B_SHEET (original 1536x1024 alpha source file)')
BASE=Path(BASE_ENV)
OUT=Path(OUT_ENV)
SHEET=Path(SHEET_ENV)
if OUT.exists() or OUT.resolve()==BASE.resolve() or BASE.resolve() in OUT.resolve().parents or not BASE.exists():
    raise RuntimeError('Refusing existing output, base overwrite or missing original A36')
shutil.copytree(BASE,OUT,ignore=shutil.ignore_patterns('.godot','*.import','qa_a36','qa_a30','qa_a31','qa_a32','qa_a33','qa_a34','qa_a35','qa_a36b','*.log','*.uid'))
(OUT/'qa_a36b').mkdir(parents=True)
(OUT/'tools'/'a36b').mkdir(parents=True)
shutil.copy2(__file__,OUT/'tools'/'a36b'/'build_a36b_tree_ecology.py')

sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
old=json.loads((BASE/'data/a36_large_verdant_forest_manifest.json').read_text())
new=json.loads(json.dumps(old))
assert old['source_ground']['sha256']=='020e8c8a7a84f43653ffc43fe660614525d13ee9e956fd7e27b5a18923315a38'
assert old['runtime_ground']['sha256']=='ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911'
assert len(old['objects'])==326 and len(old['assets'])==9
assert Image.open(SHEET).size==(1536,1024)
orig=OUT/'private_assets'/'a36b_tree_full_family_source_sheet_1536x1024.png'
shutil.copy2(SHEET,orig)
source=Image.open(orig).convert('RGBA')
assert source.getchannel('A').getextrema()[0]==0

# Only the two wholly separated TOP ROW trees are accepted from this art sheet;
# bottom row spills across cell borders and is deliberately rejected as an incomplete source.
specs=[
 ('a36b_moss_pine_148x194.png',(0,0,768,512),(148,194),[26,16],'pine_highlands'),
 ('a36b_river_willow_208x190.png',(768,0,1536,512),(208,190),[36,19],'willow_riverbank'),
]
added=[]
for name,rect,dims,feet,ecology in specs:
    im=source.crop(rect)
    alpha=im.getchannel('A')
    # Background alpha very faint; retain all tree contours >12 and discard original generation halo.
    mask=alpha.point(lambda a:0 if a<16 else a)
    box=mask.getbbox()
    assert box and box[0]>15 and box[1]<=16 and box[2]<rect[2]-rect[0]-15 and box[3]<rect[3]-rect[1]-3,(name,box)
    im.putalpha(mask)
    # Source bounds include the FULL silhouette; pad transparent after crop, not to conceal clipped art.
    im=im.crop((max(0,box[0]-8),max(0,box[1]-8),min(768,box[2]+8),min(512,box[3]+7)))
    # Reduce to half output resolution, then nearest upsample (explicit pixel-art downsample filter).
    small=im.resize((dims[0]//2,dims[1]//2),Image.Resampling.LANCZOS)
    reduced=small.resize(dims,Image.Resampling.NEAREST)
    # Keep foreground alpha and prevent low-alpha matted halos.
    pix=reduced.load()
    for yy in range(reduced.height):
        for xx in range(reduced.width):
            r,g,b,a=pix[xx,yy]
            if a<16:pix[xx,yy]=(0,0,0,0)
    aa=reduced.getchannel('A')
    assert aa.getbbox() and all(aa.getpixel(pt)==0 for pt in [(0,0),(dims[0]-1,0),(0,dims[1]-1),(dims[0]-1,dims[1]-1)])
    output=OUT/'private_assets'/'independent_par'/name
    reduced.save(output,optimize=True)
    added.append({'name':name,'sha':sha(output),'w':dims[0],'h':dims[1],'file':'res://private_assets/independent_par/'+name,'footprint':feet,'ecology':ecology,'source_sheet_sha':sha(orig),'quadrant':rect})
    new['assets'][name]={k:v for k,v in added[-1].items() if k in ('name','sha','w','h','file')}

objects=new['objects']; trees=[o for o in objects if o['semantic']=='tree']
# Coordinates stable: choose replacements using ecological zone + index salt, NOT editing paths or footpoints.
def spread_select(candidates,count,min_d,origin):
    chosen=[]
    for o in sorted(candidates,key=lambda t: ((t['foot'][0]*17+t['foot'][1]*29+int(t['id'][-3:])*31+origin)%8999)):
        x,y=o['foot']
        if all((x-a['foot'][0])**2+(y-a['foot'][1])**2>=min_d**2 for a in chosen):
            chosen.append(o)
            if len(chosen)==count:break
    return chosen
pine_candidates=[o for o in trees if (o['foot'][0]>700 and (o['foot'][1]<650 or o['foot'][1]>1450)) or (o['foot'][0]>1880 and o['foot'][1]<950)]
willow_candidates=[o for o in trees if o['foot'][0]<660 and o['foot'][1]>100 and o['foot'][1]<1780]
pines=spread_select(pine_candidates,40,115,241)
willows=spread_select(willow_candidates,22,160,457)
assert len(pines)==40 and len(willows)==22,(len(pines),len(willows))
changed={o['id']:specs[0] for o in pines}
changed.update({o['id']:specs[1] for o in willows})
assert len(changed)==len(pines)+len(willows)
for o in objects:
 if o['id'] in changed:
    name,_,dims,feet,ecology=changed[o['id']]
    o.update(family=name,asset_sha256=new['assets'][name]['sha'],width=dims[0],height=dims[1],footprint=feet)
new.update(schema='fs-a36b-ground-first-ecological-complete-tree-family/v1',scene_id='FS_A36B_LARGE_FOREST_TREE_ECOLOGY',object_count=326,art_gate='HOLD_1X_FOREST_FAMILY_AND_GROUND_UPSCALE')
new['ecological_tree_upgrade']={
 'mode':'TWO_NEW_COMPLETE_TRANSPARENT_SPRITE_FAMILIES_NOT_MAP_CROPS',
 'pine_highland_count':len(pines),'willow_riverbank_count':len(willows),
 'replacements_total':len(changed),'unchanged_object_owners':326-len(changed),
 'all_footpoints_identical':True,'base_A36_ground_sha256':old['runtime_ground']['sha256'],
 'complete_sprite_sources':added,'other_two_bottom_sheet_candidates':'REJECTED_OVERLAP_ALPHA_EDGE',
 'manual_art_approval':'HOLD','river_animated_water':'NOT_IMPLEMENTED','events':'OTHER_CONVERSATION'
}
manifest_file=OUT/'data/a36b_ecological_tree_manifest.json'
manifest_file.write_text(json.dumps(new,ensure_ascii=False,indent=2)+'\n')

# Full material is independent; rebuilding shadows from object footprints does not change the RGB Ground.
world_w,world_h=2560,1856
shadows=Image.new('RGBA',(world_w,world_h),(0,0,0,0));draw=ImageDraw.Draw(shadows,'RGBA')
for o in objects:
 if o['semantic'] not in ('tree','house','lamp'):continue
 x,y=o['foot'];fx,fy=o['footprint'];a=52 if o['semantic']=='tree' else 42
 draw.ellipse((x-fx*1.3,y-fy*.85,x+fx*1.3,y+fy*.75),fill=(18,38,16,a))
shadow_file=OUT/'private_assets'/'a36b_contact_shadows_2560x1856.png'
shadows.save(shadow_file,optimize=True)
new['shadow'].update(file='a36b_contact_shadows_2560x1856.png',sha256=sha(shadow_file))
manifest_file.write_text(json.dumps(new,ensure_ascii=False,indent=2)+'\n')

world_script=(BASE/'scripts/a36_world.gd').read_text()
world_script=world_script.replace('a36_contact_shadows_2560x1856.png','a36b_contact_shadows_2560x1856.png')
world_script=world_script.replace(old['shadow']['sha256'],sha(shadow_file))
world_script=world_script.replace('FS A36 GODOT REAL GROUND-FIRST','FS A36B GODOT REAL GROUND-FIRST')
world_script=world_script.replace('A36 continuous Ground-first','A36B ecological Ground-first')
(OUT/'scripts/a36b_world.gd').write_text(world_script)

scene=(BASE/'scenes/a36_large_verdant_forest_80x58.tscn').read_text()
scene=scene.replace('res://scripts/a36_world.gd','res://scripts/a36b_world.gd',1)
scene=scene.replace('[node name="FS_A36_LargeForest_GroundFirst"','[node name="FS_A36B_LargeForest_EcologicalTrees"',1)
for o in new['objects']:
 if o['id'] not in changed:continue
 # Replace only the editable owner metadata between that object's declaration and its Sprite child.
 rid=o['id']
 pattern=r'(\[node name="'+re.escape(rid)+r'" type="Node2D" parent="YSort"\]\n)(.*?)(?=\[node name="Sprite" type="Sprite2D" parent="YSort/'+re.escape(rid)+r'"\])'
 found=re.search(pattern,scene,re.S)
 assert found,rid
 section=found.group(2)
 for key,val in {'source_file':new['assets'][o['family']]['file'],'source_sha256':o['asset_sha256']}.items():
    section,count=re.subn(r'^'+key+r' = ".*?"$',f'{key} = "{val}"',section,count=1,flags=re.M)
    assert count==1,(rid,key)
 for key,value in [('footprint_width_px',o['footprint'][0]),('footprint_height_px',o['footprint'][1])]:
    section,count=re.subn(r'^'+key+r' = .*$',f'{key} = {float(value):.1f}',section,count=1,flags=re.M)
    assert count==1,(rid,key)
 scene=scene[:found.start(2)]+section+scene[found.end(2):]
scene_file=OUT/'scenes/a36b_large_forest_tree_ecology_80x58.tscn'
scene_file.write_text(scene)
p=OUT/'project.godot'
project=p.read_text().replace('res://scenes/a36_large_verdant_forest_80x58.tscn','res://scenes/a36b_large_forest_tree_ecology_80x58.tscn').replace('A36 80x58','A36B 80x58')
p.write_text(project)

assert sha(BASE/'private_assets/a36_ground_only_2560x1856.png')==sha(OUT/'private_assets/a36_ground_only_2560x1856.png')
assert len(re.findall(r'\[node name="a36_tree_\d+" type="Node2D" parent="YSort"\]',scene))==310
assert len(re.findall(r'^source_file = ',scene,flags=re.M))==326
assert len(re.findall(r'^position = Vector2\(',scene,flags=re.M))>=326

qa={
 'stage':'A36B','status':'ART_HOLD','scene_file':'scenes/a36b_large_forest_tree_ecology_80x58.tscn',
 'source_sheet_sha':sha(orig),'added_full_independent_tree_families':added,
 'pine_replacements':len(pines),'willow_replacements':len(willows),'changed_instance_ids':sorted(changed),
 'total_objects':326,'unchanged_objects':326-len(changed),
 'original_Ground_sha':old['runtime_ground']['sha256'],
 'A36B_Ground_sha':sha(OUT/'private_assets/a36_ground_only_2560x1856.png'),
 'sha_scene':sha(scene_file),'sha_manifest':sha(manifest_file),'sha_shadow':sha(shadow_file),
 'original_tree_shadows_sha':old['shadow']['sha256'],
 'no_events_implemented':True,'terrain_collision':'HOLD','user_art':'HOLD'
}
(OUT/'qa_a36b'/'A36B_SOURCE_TREE_ECOLOGY_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:qa[k] for k in ('stage','pine_replacements','willow_replacements','total_objects','unchanged_objects','original_Ground_sha','A36B_Ground_sha','sha_scene','sha_manifest','sha_shadow')},indent=2))
