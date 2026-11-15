from pathlib import Path
from PIL import Image
import json,glob,math,collections
p=Path(__file__).resolve().parents[1]
a=p/'assets'
body=Image.open(a/'actor01_a45_body_12frames.png').convert('RGBA')
weapon=Image.open(a/'actor01_a45_weapon_12frames.png').convert('RGBA')
fx=Image.open(a/'actor01_a45_fx_12frames.png').convert('RGBA')
anchors=json.loads((a/'actor01_a45_attack_anchors.json').read_text(encoding='utf8'))['pose_anchors']
def tile(im,i):
 x=i%4*64;y=i//4*64
 return im.crop((x,y,x+64,y+64))
def nearest(im,x,y):
 pts=[math.hypot(xx-x,yy-y) for yy in range(max(0,y-5),min(64,y+6)) for xx in range(max(0,x-5),min(64,x+6)) if im.getpixel((xx,yy))[3]>0]
 return min(pts) if pts else 999
boot_rgb={(91,68,53),(151,117,85),(53,46,38)}
metrics={'wrist_body_nearest':{},'wrist_weapon_nearest':{},'tip_weapon_nearest':{},
'boot_measured_centers':{},'boot_y_max':{},'fx_hot_pixels_distance_to_tip':{},'source':'A45 rendered texture & F6 contact geometry'}
for i in range(1,11):
 b=tile(body,i);w=tile(weapon,i);f=tile(fx,i)
 tip=anchors[i]['sword_tip_px'];hand=anchors[i]['wrist_px']
 metrics['wrist_body_nearest'][i]=round(nearest(b,*hand),3)
 metrics['wrist_weapon_nearest'][i]=round(nearest(w,*hand),3)
 metrics['tip_weapon_nearest'][i]=round(nearest(w,*tip),3)
 centers=[]
 for low,high in [(22,36),(37,50)]:
  pixels=[(x,y) for y in range(46,51) for x in range(low,high+1) if b.getpixel((x,y))[:3] in boot_rgb and b.getpixel((x,y))[3]>0]
  if not pixels:
   centers.append(None)
  else:
   centers.append([round(sum(x for x,y in pixels)/len(pixels),2),round(sum(y for x,y in pixels)/len(pixels),2)])
 metrics['boot_measured_centers'][i]=centers
 metrics['boot_y_max'][i]=max([y for y in range(46,51) for x in range(20,53) if b.getpixel((x,y))[:3] in boot_rgb and b.getpixel((x,y))[3]>0],default=-1)
 # FX hot glints only above the feet, must remain attached to actual sword tip.
 hot=[math.hypot(x-tip[0],y-tip[1]) for y in range(0,46) for x in range(0,64) if f.getpixel((x,y))[3]>=90]
 metrics['fx_hot_pixels_distance_to_tip'][i]=round(max(hot),2) if hot else 0
assert all(d<=2.3 for d in metrics['wrist_body_nearest'].values()),metrics['wrist_body_nearest']
assert all(d<=3 for d in metrics['wrist_weapon_nearest'].values()),metrics['wrist_weapon_nearest']
assert all(d<=1.5 for d in metrics['tip_weapon_nearest'].values()),metrics['tip_weapon_nearest']
assert all(cs[0] is not None and cs[1] is not None for cs in metrics['boot_measured_centers'].values()),metrics['boot_measured_centers']
assert all(y==48 for y in metrics['boot_y_max'].values()),metrics['boot_y_max']
assert max(metrics['fx_hot_pixels_distance_to_tip'].values())<=7.5,metrics['fx_hot_pixels_distance_to_tip']
# Structural pose hold 3-4 and impact 6-7; physically planted feet measured
for i,j in [(3,4),(6,7)]:
 for foot in range(2):
  a0=metrics['boot_measured_centers'][i][foot];a1=metrics['boot_measured_centers'][j][foot]
  assert math.hypot(a0[0]-a1[0],a0[1]-a1[1])<=1.25,(i,j,foot,a0,a1)
metrics['status']='PASS'
(p/'qa/A45_INDEPENDENT_VISUAL_GEOMETRY_QA.json').write_text(json.dumps(metrics,indent=2,ensure_ascii=False),encoding='utf8')
print('A45_INDEPENDENT_VISUAL_GEOMETRY_PASS',json.dumps(metrics,ensure_ascii=False))
