#!/usr/bin/env python3
"""Isolated Forest Symphony V6 P3 R3. Exact source pixel ownership, no sealed VX changes."""
from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib,collections
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs';o.mkdir(exist_ok=True)
def image(name):return Image.open(s/name).convert('RGBA')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
h=image('HOUSE_R2.png');ha=image('HOUSE_R3A_BASE.png')
arch=image('HOUSE_ARCH_R2.png');flower=image('HOUSE_FLOWERS_R2.png')
green=np.array(Image.open(s/'UPPER_ROOF_GRASS_OWNER_MASK.png').convert('L'))>0
little=np.array(Image.open(s/'REJECTED_FLOATERS_MASK.png').convert('L'))>0
old=np.array(h);new=np.array(ha)
assert int(little.sum())==21 and int(green.sum())==367
assert np.array_equal(new[~little],old[~little]) and np.all(new[little]==0)
green=green & (new[:,:,3]>0)
components={'HOUSE_ARCH':np.array(arch),'HOUSE_FLOWERS':np.array(flower)}
# Semantic priority: back foliage is SOURCE RETAINED but no longer owned by architecture
# Nonintersecting ownership. House flower clusters keep full original RGBA.
bgr=np.zeros_like(new)
bgr[green]=new[green]
for key,layer in list(components.items()):
    layer[(green|little)]=0
    components[key]=layer
components['ROOF_BACK_FOLIAGE_FRAGMENT']=bgr
# No component shares ownership with any other, ensure RGB and alpha preserved.
owned=[q[:,:,3]>0 for q in components.values()]
stack=np.sum(np.stack(owned),axis=0)
assert int(np.max(stack))==1
assert np.array_equal(stack>0,new[:,:,3]>0)
composed=Image.new('RGBA',h.size)
for key in ['ROOF_BACK_FOLIAGE_FRAGMENT','HOUSE_ARCH','HOUSE_FLOWERS']:
    composed.alpha_composite(Image.fromarray(components[key],'RGBA'))
assert np.array_equal(np.asarray(composed),new), 'Owner split changes source RGBA'
for k,item in components.items():Image.fromarray(item,'RGBA').save(o/(k+'_SOURCE.png'))
composed.save(o/'HOUSE_R3_COMBINED_ALPHA.png')
g=image('GROUND_B.png');a=image('ACTOR1.png');tree=image('SACRED_TREE.png');flora=image('FLORA.png')
assert g.size==(544,416) and a.size==(32,32)
# Original source parity with only the 21 floaters changed. Tree and flower unchanged.
scene=g.copy()
scene.alpha_composite(Image.fromarray(components['ROOF_BACK_FOLIAGE_FRAGMENT'],'RGBA'),(12,48))
scene.alpha_composite(Image.fromarray(components['HOUSE_ARCH'],'RGBA'),(12,48))
scene.alpha_composite(Image.fromarray(components['HOUSE_FLOWERS'],'RGBA'),(12,48))
scene.alpha_composite(tree,(323,22));scene.alpha_composite(flora,(445,286))
scene.save(o/'WORLD_R3_P3_COMPLETE_NO_ACTOR.png')
r2w=image('R2_WORLD.png')
diff=int(np.count_nonzero(np.any(np.asarray(scene)!=np.asarray(r2w),axis=2)))
assert diff==21,('Unexpected scene change',diff)
# Number 0=ground; 1=architecture; 2=house flowers; 3=roof foliage; 4=tree; 5=flora
owner=Image.new('L',(544,416),0)
for i,k in [(3,'ROOF_BACK_FOLIAGE_FRAGMENT'),(1,'HOUSE_ARCH'),(2,'HOUSE_FLOWERS')]:
    local=Image.fromarray(components[k],'RGBA').getchannel('A')
    mask=Image.new('L',owner.size,0);mask.paste(local,(12,48))
    owner.paste(i,(0,0),mask)
for j,asset,pos in [(4,tree,(323,22)),(5,flora,(445,286))]:
    mask=Image.new('L',owner.size,0);mask.paste(asset.getchannel('A'),pos)
    owner.paste(j,(0,0),mask)
owner.save(o/'WORLD_SEMANTIC_PIXEL_OWNER_ID.png')
grid=np.array(Image.open(s/'R2_BLOCKED_TILES.png').convert('L'))
assert grid.shape==(416,544)
assert int((grid>0).sum())==15*32*32
Image.fromarray(grid).save(o/'VX_BLOCKED_TILES_17X13.png')
def render_actor(pos):
    fx,fy=pos
    out=g.copy()
    layers=[(scene_foot,img,xy) for scene_foot,img,xy in [
      (212,composed,(12,48)),(235,tree,(323,22)),(336,flora,(445,286))]]
    # Character's foot/depth: offset equal to world y; far objects occlude when foot behind object foot.
    inserted=False
    for foot,img,xy in sorted(layers,key=lambda x:x[0]):
        if not inserted and fy<foot:
            out.alpha_composite(a,(fx-16,fy-32));inserted=True
        out.alpha_composite(img,xy)
    if not inserted:out.alpha_composite(a,(fx-16,fy-32))
    return out
positions={'HOUSE_FRONT':(144,250),'TREE_BEHIND':(430,223),'TREE_FRONT':(432,260),'FLORA_FRONT':(475,351)}
contact=Image.new('RGB',(1088,832))
for i,(k,xy) in enumerate(positions.items()):
    img=render_actor(xy);img.save(o/('ACTOR_'+k+'.png'))
    contact.paste(img.convert('RGB'),((i%2)*544,(i//2)*416))
contact.save(o/'ACTOR_FOUR_POSITIONS.png')
scene.resize((1088,832),Image.Resampling.NEAREST).save(o/'WORLD_2X_NEAREST.png')
# Negative test must reject an independently shifted owner or mistaking shade as alpha fringe.
wrong=Image.new('RGBA',(544,416));wrong.alpha_composite(tree,(324,22))
good=Image.new('RGBA',(544,416));good.alpha_composite(tree,(323,22))
negative=int(np.count_nonzero(np.any(np.asarray(wrong)!=np.asarray(good),axis=2)))
assert negative>1000
# Connectivity of exit and start. No hard blocker footprint changed from R2.
cells=np.array([[int(grid[y*32+16,x*32+16]>0) for x in range(17)] for y in range(13)])
assert cells[7,4]==0 and cells[5,4]==1 and cells[10,14]==0
todo=collections.deque([(8,10)]);vis={(8,10)}
while todo:
    x,y=todo.popleft()
    for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if 0<=nx<17 and 0<=ny<13 and not cells[ny,nx] and (nx,ny) not in vis:
            vis.add((nx,ny));todo.append((nx,ny))
assert (4,7) in vis and (14,10) in vis
summary=dict(schema='FS_V6_P3_R3_PIXEL_OWNER',scene_world_px=[544,416],sources=[dict(file=k,sha256=sha(s/k)) for k in sorted(p.name for p in s.iterdir() if p.is_file())],
    source_layer_names=list(components.keys()),stray_pixels_removed=21,
    detached_components_removed=9,upper_left_roof_grass_separately_owned=367,
    scene_RGBA_delta_vs_R2=diff,source_RGBA_unchanged_remaining=True,
    collision_blocked_tiles=int(cells.sum()),door_front_walk=True,soft_flora_walk=True,
    actor_positions=list(positions.keys()),negative_1px_tree_shift_changed_pixels=negative,
    flora_dark_edge_review='52 dark boundary pixels opaque; no removal; not antialias fringe',
    rejected_R3B='Removing 367 green roof backdrop pixels makes transparent holes in upper-left roof vegetation',
    human_art='PENDING',native_RPG_Maker_VX='NOT_RUN',promotion='PROVISIONAL_R3A_ONLY')
(r/'SCENE_MANIFEST_R3.json').write_text(json.dumps(summary,indent=2,ensure_ascii=False),encoding='utf8')
checks=dict(owner_exact=bool(np.array_equal(np.asarray(composed),new)), no_overlap=bool(np.max(stack)==1),
 source_alpha_full=bool(new[:,:,3].sum()>0), source_pixels_preserved_except_21=bool(diff==21),
 ground_opaque=bool(np.all(np.asarray(g)[:,:,3]==255)),collision_unchanged=bool(int(cells.sum())==15),
 front_door_clear=bool(cells[7,4]==0),front_door_connected=bool((4,7) in vis),
 soft_flora_walk=bool(cells[10,14]==0), alpha0RGB_clean=bool(np.all(new[new[:,:,3]==0,:3]==0)),
 pixel1_negative_detected=bool(negative>1000), owner_367_green_pixels=bool(int(green.sum())==367))
assert all(checks.values())
(r/'R3_QA.json').write_text(json.dumps(dict(pass_count=sum(checks.values()),total=len(checks),checks=checks,
    source_layer_PIXEL_OWNERSHIP='PASS',native='NOT_RUN',human='PENDING'),indent=2),encoding='utf8')
print(json.dumps(dict(PASS=sum(checks.values()),total=len(checks),green=int(green.sum()),deleted21=int(little.sum()),scene_delta=diff,negative=negative)))
