#!/usr/bin/env python3
"""Build isolated A34 pair candidate from immutable A33/R3. Does not falsely claim a Godot native run.

Inputs: Private FS A34 R3 archive, right-house original full image (magenta chroma background).
Outputs: Portable candidate project with source-locked independent PAR and 1x QA scene PNG.
"""
import argparse, hashlib, io, json, math, os, re, zipfile
import numpy as np
from scipy import ndimage
from PIL import Image,ImageDraw

def sha(data):return hashlib.sha256(data).hexdigest()
def png(im):
 f=io.BytesIO();im.save(f,'PNG',optimize=True);return f.getvalue()
def keyed_house(src,target=(214,252)):
 """Edge-connected variable-magenta removal, content-fit, crisp RGBA and nearest-source based viewport constraints."""
 rgb=np.array(Image.open(src).convert('RGB'))
 r,g,b=[rgb[:,:,i].astype(np.int16) for i in range(3)]
 # Generated image background shades: saturated magenta with moderately variable color.
 bg=(r>145)&(b>135)&(g<125)&((r-g)>86)&((b-g)>80)&(np.abs(r-b)<75)
 seeds=np.zeros(bg.shape,dtype=bool)
 seeds[0,:]=bg[0,:];seeds[-1,:]=bg[-1,:];seeds[:,0]|=bg[:,0];seeds[:,-1]|=bg[:,-1]
 outer=ndimage.binary_propagation(seeds,mask=bg)
 # small interior slots are intentionally kept unless explicitly magenta and connected
 keep=~outer
 ys,xs=np.where(keep)
 assert len(xs)>10000,'empty house after key'
 x0,x1=max(0,int(xs.min())-3),min(rgb.shape[1],int(xs.max())+4)
 y0,y1=max(0,int(ys.min())-3),min(rgb.shape[0],int(ys.max())+4)
 part=rgb[y0:y1,x0:x1]
 foreground=keep[y0:y1,x0:x1]
 part=np.concatenate([part, (foreground*255).astype(np.uint8)[:,:,None]],axis=2)
 im=Image.fromarray(part,'RGBA')
 w,h=target
 max_w,max_h=w-10,h-14
 scale=min(max_w/im.width,max_h/im.height)
 new_size=(max(1,int(im.width*scale)),max(1,int(im.height*scale)))
 im=im.resize(new_size,Image.Resampling.LANCZOS)
 # avoid antialiased low-alpha magenta halos after downsampling
 arr=np.array(im)
 arr[arr[:,:,3]<88,3]=0
 for c in range(3):arr[:,:,c][arr[:,:,3]==0]=0
 im=Image.fromarray(arr,'RGBA')
 out=Image.new('RGBA',(w,h),(0,0,0,0))
 xpos=(w-im.width)//2
 ypos=min(h-im.height-7, max(2,h-im.height-8))
 out.alpha_composite(im,(xpos,ypos))
 assert out.getbbox()[0]>=0 and out.getbbox()[2]<=w and out.getbbox()[3]<h
 return out, {'raw_size':list(rgb.shape[1::-1]),'content_bbox_raw':[x0,y0,x1,y1],'output_size':[w,h], 'output_bbox':list(out.getbbox()), 'target_scale':round(scale,6), 'key_strategy':'edge_connected_variable_magenta'}

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--base-zip',required=True,help='Private R3 candidate archive with left-house PNG')
 ap.add_argument('--a33-zip',required=True,help='Immutable original private A33 owner archive')
 ap.add_argument('--right-raw',required=True,help='Right cottage original generated PNG')
 ap.add_argument('--left-raw',help='Optional left cottage original generated PNG')
 ap.add_argument('--test-script',required=True,help='A34 native GDScript test')
 ap.add_argument('--capture-script',required=True,help='A34 native GDScript frame capture')
 ap.add_argument('--out',required=True)
 args=ap.parse_args()
 with zipfile.ZipFile(args.base_zip) as z:
  candidate={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
  assert z.testzip() is None
 # A34 R3 incorrectly dropped A33 scene: restore the immutable A33 archive as authority.
 with zipfile.ZipFile(args.a33_zip) as baseline:
  assert baseline.testzip() is None
  old={**candidate,**{n:baseline.read(n) for n in baseline.namelist() if not n.endswith('/')}}
  old['private_assets/independent_par/a34_cottage_a_full_rebuild_candidate.png']=candidate['private_assets/independent_par/a34_cottage_a_full_rebuild_candidate.png']
 base_scene=old['scenes/a33_groundfirst_lantern_scene.tscn'].decode()
 old_a='res://private_assets/independent_par/a36f_elf_cottage_a_annex_rgba.png'
 old_b='res://private_assets/independent_par/a36f_elf_cottage_b_moss_roof_rgba.png'
 new_a='res://private_assets/independent_par/a34_cottage_a_full_rebuild_candidate.png'
 new_b='res://private_assets/independent_par/a34_r4_cottage_b_full_rebuild_candidate.png'
 right_im,info=keyed_house(args.right_raw)
 right_png=png(right_im)
 right_sha=sha(right_png)
 left_png=old['private_assets/independent_par/a34_cottage_a_full_rebuild_candidate.png']
 left_sha=sha(left_png)
 assert left_sha == '17025ce677dbe1ae18ad59acfa33b0cce6136eaf3d2ad2098ce65ca680709456'
 house_b_sha=sha(old[old_b.replace('res://','')])
 house_a_sha=sha(old[old_a.replace('res://','')])
 assert base_scene.count(old_a)==1 and base_scene.count(old_b)==1
 assert base_scene.count(house_b_sha)==1 and base_scene.count(house_a_sha)==1
 scene=base_scene.replace(old_a,new_a).replace(house_a_sha,left_sha).replace(old_b,new_b).replace(house_b_sha,right_sha)
 assert 'source_file = "'+new_b+'"\nsource_sha256 = "'+right_sha+'"' in scene
 assert 'source_file = "'+new_a+'"\nsource_sha256 = "'+left_sha+'"' in scene
 scene=scene.replace('FS_A33_GroundFirst','FS_A34_R4_HousePair',1)
 scene=scene.replace('res://scripts/a33_world.gd','res://scripts/a34_r4_world.gd',1)
 root_script=old['scripts/a33_world.gd'].decode().replace('FS A33 GROUND-FIRST GODOT:', 'FS A34 R4 GROUND-FIRST GODOT:').replace('Private A33 Ground-only', 'Private A34 R4 Ground-only')
 root_script=root_script.replace('ART HOLD / COLLISION CANDIDATE / ORIGINAL MASTER CUTTING FORBIDDEN','ART HOLD / 2 INDEPENDENT HOUSE CANDIDATES / ORIGINAL GROUND AND A33 SEALED')
 project=old['project.godot'].decode().replace('Godot-first A33 full-height independent lantern','Godot-first A34 R4 two independent houses').replace('run/main_scene="res://scenes/a33_groundfirst_lantern_scene.tscn"','run/main_scene="res://scenes/a34_r4_house_pair_scene.tscn"')
 assert 'a34_r4_house_pair_scene.tscn' in project
 mf=json.loads(old['data/a33_groundfirst_lantern_manifest.json']);
 rawpath='private_assets/a34_right_generated_original_full.png'
 files={
    'scenes/a34_r4_house_pair_scene.tscn':scene.encode(),
    'scripts/a34_r4_world.gd':root_script.encode(),
    'private_assets/independent_par/a34_r4_cottage_b_full_rebuild_candidate.png':right_png,
    rawpath:open(args.right_raw,'rb').read(),
 }
 if args.left_raw:files['private_assets/a34_left_generated_original_full.png']=open(args.left_raw,'rb').read()
 for k in ['a36f_elf_cottage_a_annex_rgba','a36f_elf_cottage_b_moss_roof_rgba']:
  assert k in mf['assets']
 mf['schema']='fs-a34-r4-house-pair-independent-par/v1'
 mf['status']='ART_HOLD_NATIVE_NOT_RUN'
 mf['origin_scene']='scenes/a33_groundfirst_lantern_scene.tscn'
 mf['art_gate']='HOLD: whole-house concept image -> native pixel art review required'
 mf['assets']['a34_cottage_a_full_rebuild_candidate']={'id':'a34_cottage_a_full_rebuild_candidate','file':new_a.replace('res://',''),'size':[254,252],'semantic':'house','sha256':left_sha,'full_independent_art':True,'source_generation':'magenta_chroma_rebuild_candidate'}
 mf['assets']['a34_r4_cottage_b_full_rebuild_candidate']={'id':'a34_r4_cottage_b_full_rebuild_candidate','file':new_b.replace('res://',''),'size':[214,252],'semantic':'house','sha256':right_sha,'full_independent_art':True,'source_generation':'magenta_chroma_rebuild_candidate','build_info':info}
 for obj in mf['objects']:
  if obj['id']=='obj_001_a36f_elf_cottage_a':obj.update(asset_id='a34_cottage_a_full_rebuild_candidate',source_sha256=left_sha,art_status='A34_R4_CANDIDATE')
  if obj['id']=='obj_002_a36f_elf_cottage_b':obj.update(asset_id='a34_r4_cottage_b_full_rebuild_candidate',source_sha256=right_sha,art_status='A34_R4_CANDIDATE')
 assert len(mf['objects'])==146
 assert sum(o['semantic']=='house' for o in mf['objects'])==2
 mf['a34_gate']={'right_source_sha256':right_sha,'left_source_sha256':left_sha,'zip_crc':'pass_on_rebuild','native':'not_run_at_packaging','ground_sha256':mf['ground']['sha256']}
 files['data/a34_r4_house_pair_manifest.json']=(json.dumps(mf,ensure_ascii=False,indent=2)+'\n').encode()
 files['project.godot']=project.encode()
 # native smoke test and capture with independent scenes
 files['tests/test_a34_r4_real.gd']=open(args.test_script,'rb').read()
 files['tests/capture_a34_r4_native.gd']=open(args.capture_script,'rb').read()
 # create PIL (not Godot) composited QA previews for honest visual review
 d=json.loads(old['data/a33_groundfirst_lantern_manifest.json'])
 def comp(new):
  c=Image.open(io.BytesIO(old['private_assets/ground_only.png'])).convert('RGBA')
  for obj in sorted(d['objects'],key=lambda x:x['foot'][1]):
   a=d['assets'][obj['asset_id']]['file']
   if new and obj['id']=='obj_001_a36f_elf_cottage_a': a=new_a.replace('res://','')
   if new and obj['id']=='obj_002_a36f_elf_cottage_b': a=new_b.replace('res://','')
   b=files.get(a,old.get(a))
   assert b is not None,a
   sprite=Image.open(io.BytesIO(b)).convert('RGBA')
   x=round(obj['foot'][0]-sprite.width/2)
   y=round(obj['foot'][1]-sprite.height+1)
   c.alpha_composite(sprite,(x,y))
  return c
 old_map=comp(False);new_map=comp(True)
 files['qa_a34/A34_R4_TWO_HOUSES_COMPOSITE_PREVIEW_NOT_NATIVE.png']=png(new_map)
 qa=Image.new('RGB',(1280,928*2+32),'white')
 qa.paste(old_map.convert('RGB'),(0,24));qa.paste(new_map.convert('RGB'),(0,928+32))
 draw=ImageDraw.Draw(qa);draw.text((15,4),'TOP A33 baseline - PIL PREVIEW, NOT NATIVE',fill='black');draw.text((15,928+12),'BOTTOM A34 R4 pair - PIL PREVIEW, NOT NATIVE',fill='black')
 files['qa_a34/A34_R4_TWO_HOUSES_AB_2UP_NOT_NATIVE.png']=png(qa)
 orig=np.asarray(old_map.convert('RGB'));cand=np.asarray(new_map.convert('RGB'));diff=(orig!=cand).any(2)
 mask=np.zeros(diff.shape,dtype=bool)
 for obj in d['objects'][:2]:
  x,y=obj['x'],obj['y'];w,h=obj['w'],obj['h'];mask[max(0,y):min(928,y+h),max(0,x):min(1280,x+w)]=True
 outside=int((diff&(~mask)).sum()); inside=int((diff&mask).sum())
 assert outside==0,f'PIL preview changed pixels outside 2-house ROIs: {outside}'
 assert inside>0
 info_report={'schema':'fs-a34-r4-pre-native-source-qa/v1','baseline':'A33','project_main_scene':'scenes/a34_r4_house_pair_scene.tscn','total_par_owners':146,'house_sources':{'left':left_sha,'right':right_sha},'ground_sha256':mf['ground']['sha256'],'ground_unchanged':sha(old['private_assets/ground_only.png'])==mf['ground']['sha256'],'pil_preview_only':True,'pil_changed_inside_house_roi':inside,'pil_changed_outside_house_roi':outside,'native_godot':'NOT_RUN','art_approval':'HOLD','right_source_processing':info}
 files['qa_a34/A34_R4_PACKAGING_QA.json']=(json.dumps(info_report,indent=2)+'\n').encode()
 # preserve A33, R2, R3 files: only change new project default scene (baseline archived as scenes)
 os.makedirs(os.path.dirname(args.out),exist_ok=True)
 with zipfile.ZipFile(args.out,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as target:
  for name,data in {**old,**files}.items():target.writestr(name,data)
 with zipfile.ZipFile(args.out) as result:
  assert result.testzip() is None
  assert result.read('private_assets/ground_only.png')==old['private_assets/ground_only.png']
  assert result.read('scenes/a33_groundfirst_lantern_scene.tscn')==old['scenes/a33_groundfirst_lantern_scene.tscn']
  print(json.dumps(dict(info_report,zip_size=os.path.getsize(args.out),zip_sha256=sha(open(args.out,'rb').read()),zip_members=len(result.namelist())),indent=2))

if __name__=='__main__':main()
