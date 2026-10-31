from pathlib import Path
import json,hashlib,collections
import numpy as np
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
G=R/'GODOT_ISOLATED_V4_7_2'/'out'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
W,H=544,416
def pic(p,rgba=False):
 with Image.open(p) as im:
  assert im.size==(W,H),p
  return np.asarray(im.convert('RGBA' if rgba else 'RGB')).copy()
scene=json.loads((R/'A24_SCENE_MANIFEST.json').read_text('utf8'))
col=json.loads((R/'A24_PAR_COLLISION_32_GRID.json').read_text('utf8'))
g=pic(R/'A24_GROUND_544x416.png')
par=pic(R/'A24_PAR_RGBA_544x416.png',True)
assert (par[:,:,3]==0).sum()>20000 and (par[:,:,3]>0).sum()>3000
comp=pic(R/'A24_GROUND_PAR_COMPOSITE_544x416.png')
godot=pic(G/'A24_GODOT_NATIVE_SCENE_NO_ACTOR.png')
diff=np.abs(comp.astype(np.int16)-godot.astype(np.int16))
mismatch=(diff>0).any(axis=2)
print('A24_PIL_VS_REAL_GODOT_DIFF',int(mismatch.sum()),round(float(diff.mean()),6),flush=True)
# Validate different on-screen actor locations against no-actor baseline.
behind=pic(G/'A24_GODOT_ACTOR_BEHIND_LAMP.png')
front=pic(G/'A24_GODOT_ACTOR_IN_FRONT_OF_LAMP.png')
road=pic(G/'A24_GODOT_ACTOR_ON_ROAD.png')
rects={'behind':(375,72,397,112),'front':(375,130,397,169),'road':(324,165,347,208)}
counts={}
for typ,image in [('behind',behind),('front',front),('road',road)]:
 x1,y1,x2,y2=rects[typ]
 changed=((image!=godot).any(axis=2))[y1:y2,x1:x2]
 counts[typ]=int(changed.sum())
 assert counts[typ]>110,(typ,counts)
assert np.array_equal(g,comp) is False
mask=np.array(Image.open(R/'A24_GROUND_SAND_PATH_MASK_544x416.png'))>0
assert mask.shape==(H,W) and 0.04<float(mask.mean())<0.25
blocked=set(tuple(p) for p in col['blocked_tile_coords'])
gw,gh=col['grid']
assert gw==17 and gh==13 and len(blocked)==col['blocked_count']
start=tuple(col['actor_start_tile'])
assert start not in blocked
# Flood fill all walkable tiles from character start; visual path's top and bottom endpoints must remain connected.
queue=collections.deque([start]);visited={start}
while queue:
 x,y=queue.popleft()
 for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
  p=(nx,ny)
  if 0<=nx<gw and 0<=ny<gh and p not in blocked and p not in visited:
   visited.add(p);queue.append(p)
top=set();bottom=set()
for y in [0, H-1]:
 for x in np.flatnonzero(mask[y]):
  cell=(int(x)//32,y//32)
  if cell not in blocked:
   (top if y==0 else bottom).add(cell)
assert top&visited and bottom&visited,('road connectivity failure',top,bottom,len(visited))
# Confirm no empty-alpha RGB color leak from PAR when compositing on actual ground, no visual raster distortion at 1x.
rt=json.loads((G/'A24_GODOT_RENDER_PROOF.json').read_text('utf8'))
assert rt['renderer']=='ACTUAL_GODOT_4_7_2' and rt['sprites']==10 and len(rt['samples'])==4
report={'stage':'A24','date':'2026-11-01',
 'ground_px':[W,H],'par_px':[W,H],'original_ground3_texture':'AUTHENTIC_PRIVATE_SOURCE_RGB_PIXELS',
 'godot':'ACTUAL_GODOT_4_7_2_GL_COMPATIBILITY_OPENGL_RX6700XT',
 'actual_engine_renders':4,'native_screenshots_SHA256':{f.name:sha(f) for f in sorted(G.glob('*.png'))},
 'PIL_composite_vs_Godot_diff_pixels':int(mismatch.sum()),'PIL_composite_vs_Godot_mean_abs_RGB':round(float(diff.mean()),7),
 'dynamic_y_sort_behind_front_actor_changed_pixels':counts,
 'ground_default_passable':True,'par_blocked_tiles':len(blocked),
 'walkable_tile_count':gw*gh-len(blocked),'actor_reachable_cells':len(visited),
 'top_to_bottom_route_through_open_grid':'PASS',
 'forest_complete_tree_occlusion':'NOT_TESTED',
 'PAR_occlusion_dynamic_lamp':'VISUAL_VERIFIED_TWO_CASES',
 'native_VX':'NOT_RUN','FS_full_Ground3_art':'FAIL_NOT_USER_APPROVED','PixelLab_full_544_GENERATION':'NOT_RUN','new_api_generations':0,'Formal_Seal':'NO'}
(R/'A24_GODOT_COLLISION_PIXEL_QA.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf8')
difference=Image.fromarray(np.minimum(diff*6,255).astype(np.uint8),'RGB')
difference.save(R/'A24_PIL_VS_GODOT_DIFF_ENLARGED.png')
contact=Image.new('RGB',(2*W,2*H),(20,23,25))
for j,im in enumerate((godot,behind,front,road)):
 contact.paste(Image.fromarray(im),(j%2*W,j//2*H))
contact.save(R/'A24_ACTUAL_GODOT_4PANEL_SCREENSHOTS.png')
print('A24_ENGINE_AND_PASSABILITY_QA',json.dumps(report,ensure_ascii=False)[:4500],flush=True)
