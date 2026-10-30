from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
import numpy as np,json
root=Path(__file__).resolve().parent
out=root/'out'
ground=Image.open(out/'GROUND.png').convert('RGBA')
par=Image.open(out/'PAR.png').convert('RGBA')
contact=json.loads((out/'CONTACT_32_GRID_AUDIT.json').read_text(encoding='utf-8'))
W,H=ground.size
assert (W,H)==(544,416)==par.size
# Prototype actor, 32x32 full-resolution, alpha 0 outside.
actor=Image.new('RGBA',(32,32),(0,0,0,0))
d=ImageDraw.Draw(actor)
# Simple top-down 3/4 archetype: shadow, backpack, silhouette, legs and head.
d.ellipse((9,27,25,31),fill=(29,47,45,75))
d.rectangle((11,23,16,29),fill=(63,63,74,255))
d.rectangle((19,23,24,29),fill=(63,63,74,255))
d.rectangle((9,14,25,24),fill=(44,104,144,255))
d.rectangle((12,11,23,15),fill=(239,189,139,255))
d.ellipse((9,3,25,17),fill=(236,191,152,255))
d.polygon([(9,7),(10,2),(22,2),(26,7),(23,9),(12,8)],fill=(74,54,45,255))
d.rectangle((7,15,10,22),fill=(231,174,130,255))
d.rectangle((25,15,27,22),fill=(231,174,130,255))
actor.save(out/'ACTOR_TEST_32.png')
actor_alpha=np.asarray(actor.getchannel('A'))>0
par_arr=np.asarray(par.getchannel('A'))
rows=[]
states=[('BEHIND',-16),('AT_BASE',0),('FRONT',16)]
scenes=[]
for tree in contact['trees']:
 x0,y0,x1,y1=tree['rect']
 x=(x0+x1)//2
 base_y=y1
 for state,offset in states:
  feet=base_y+offset
  left=x-16
  top=feet-32
  mask=np.zeros((H,W),dtype=bool)
  mask[top:top+32,left:left+32]=actor_alpha
  overlaps=mask & (par_arr>0)
  act_px=int(mask.sum())
  occ_px=int(overlaps.sum())
  visible=act_px-occ_px
  # Head is the upper 15 of 32 px, most salient for character readability
  head=np.zeros((H,W),bool)
  head[top:top+15,left:left+32]=actor_alpha[:15,:]
  head_px=int(head.sum())
  head_occ=int(np.count_nonzero(head & (par_arr>0)))
  temp=ground.copy()
  temp.alpha_composite(actor,(left,top))
  temp.alpha_composite(par)
  pic=temp.convert('RGB')
  # Save actual engine-facing 2D layered result for each state.
  pic.save(out/f'ACTOR_{tree["name"]}_{state}.png')
  scenes.append((tree['name'],state, pic))
  rows.append({'tree':tree['name'],'state':state,'actor_foot_xy':[x,feet],
   'actor_canvas_xy':[left,top],'actor_opaque_px':act_px,
   'occluded_actor_px':occ_px,'actor_coverage_occluded_pct':round(100*occ_px/act_px,3),
   'head_opaque_px':head_px,'head_occluded_px':head_occ,
   'head_occluded_pct':round(100*head_occ/head_px,3),
   'actor_visible_pct':round(100*visible/act_px,3),
   'rendered_file':f'ACTOR_{tree["name"]}_{state}.png'})
# Native presentation: no scaling the underlying render
panel=Image.new('RGB',(W*3,(H+40)*2),(26,32,38))
D=ImageDraw.Draw(panel)
for index,(tree,state,im) in enumerate(scenes):
 col=index%3;row=index//3
 px=col*W;py=row*(H+40)
 R=next(a for a in rows if a['tree']==tree and a['state']==state)
 D.text((px+10,py+11),f'{tree}: {state} | occluded actor {R["actor_coverage_occluded_pct"]}%',fill=(252,248,222))
 panel.paste(im,(px,py+40))
panel.save(out/'STAGE6_ACTOR_OCCLUSION_6PANEL.png')
# A harsher example: compare two alternate drawing orders at the SAME foot location,
# showing what must not be confused with a single fixed PAR compositing rule.
ex=next(x for x in rows if x['tree']=='WEST' and x['state']=='AT_BASE')
left,top=ex['actor_canvas_xy']
front=Image.alpha_composite(ground,par)
front.alpha_composite(actor,(left,top))
front.convert('RGB').save(out/'DEPTH_ALTERNATE_ACTOR_OVER_PAR.png')
assert np.array_equal(np.array(ground.getchannel('A')),np.full((H,W),255))
assert np.count_nonzero(np.asarray(par.getchannel('A'))==0)>0, 'PAR must be genuinely transparent'
# Strict deterministic sanity checks for contextual placements on both trees.
for tree in ('WEST','EAST'):
 vals={x['state']:x for x in rows if x['tree']==tree}
 assert vals['BEHIND']['head_occluded_pct']>80,tree+' rear head uncovered'
 assert vals['FRONT']['actor_coverage_occluded_pct']==0,tree+' front overlaid by PAR'
 assert 0<vals['AT_BASE']['actor_coverage_occluded_pct']<50,tree+' contact not transitional'
report={
 'authority':'R17 direct native ground+transparent PAR, prototype actor between Ground and PAR',
 'fixed_render_order':'GROUND -> 32x32 ACTOR -> PAR',
 'actor_is_original_generated_test_sprite':True,
 'actor_movement_offsets_px_from_contact_ymax':{'behind':-16,'at_base':0,'front':16},
 'tree_mask_from':'CONTACT_32_GRID_AUDIT.json',
 'scenario_rows':rows,
 'gate_behind_head_occluded_gt_80pct':True,
 'gate_front_actor_occluded_eq_0pct':True,
 'gate_at_base_transition_range':True,
 'scope_limits':['Two tree locations and one 32x32 actor silhouette only','No executable RPG Maker VX integration','Character draw order may require separate depth logic in production','Art reference still FAIL'],
 'formal_seal':False
}
(out/'STAGE6_ACTOR_OCCLUSION_QA.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
for a in rows:print(a['tree'],a['state'],'actor occlusion',a['actor_coverage_occluded_pct'],'head',a['head_occluded_pct'])
print('QA_PASS',True)