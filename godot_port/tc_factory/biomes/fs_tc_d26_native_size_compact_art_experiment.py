#!/usr/bin/env python3
"""D26 FS_04_MAZE: new source-authored native-width compact non-ground objects.

D17 Ground SHA frozen. Reuses seven D24 *entire alpha islands* at unchanged 1x
and paints FOUR *new* compact objects at final source pixel size: bridge,
forge, crane, shed. Ground is never reverse extracted. No object is resized.
This is an ART CANDIDATE, not production-approved artwork.
"""
import hashlib,json,random,math
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont
from scipy.ndimage import label,find_objects

OUT=Path('/mnt/data/TC_D26_ART_FIRST_WORK')
G=Path('/mnt/data/TC_D17_WORK/FINAL_PAIR/GROUND.png')
SRC=Path('/mnt/data/TC_D24_ART_FIRST_WORK/D24_NEW_INDEPENDENT_NATIVE_RGBA_SOURCE_1474x1067.png')
LOCK_G='2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e'
LOCK_SRC='69fcdc6602394ddc7ece3e73515fe657ab74976c20aaa1548b58b712cfcca407'
NAMES=['forge','ore_crane','iron_bridge','north_lamp','western_lamp','western_basalt','south_east_basalt','supply_workshop','east_lamp','flame_banner','southern_basalt']
R=random.Random(2626)
DARK='#251921';EDGE='#36222b';STONE='#51404f';STONE_HI='#826173';STONE_HIGHLIGHT='#a57c9b';WOOD_DARK='#492e2a';WOOD='#905439';WOOD_HI='#da8b4d';ROOF='#59455f';ROOF_HI='#a07593';BRONZE='#b56d35';GOLD='#efaa4f';GLOW='#ffb53d';HOT='#ff6725'

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def make(w,h):return Image.new('RGBA',(w,h),(0,0,0,0))
def poly(d,xy,fill,edge=DARK,width=3):d.polygon(xy,fill=fill);d.line([*xy,xy[0]],fill=edge,width=width,joint='curve')
def rect(d,xy,fill,outline=DARK,width=2):d.rectangle(xy,fill=fill,outline=outline,width=width)
def glow(d,x,y,r=10):
 for rr,c in [(r+5,'#5b292e'),(r+2,'#a73c24'),(r,'#e36d25'),(max(1,r-3),'#ffd46a')]:d.ellipse((x-rr,y-rr,x+rr,y+rr),fill=c)
 d.rectangle((x-2,y-2,x+1,y+1),fill='#fff6be')
def bricks(d,x0,y0,x1,y1,step=16):
 for iy,y in enumerate(range(y0,y1,step)):
  for x in range(x0+(-6 if iy%2 else 0),x1,step):
   xx=max(x,x0);yy=y;ex=min(x+step-2,x1-1);ey=min(y+step-2,y1-1)
   if ex<=xx or ey<=yy:continue
   p=R.choice(['#58424f','#684e5e','#74556c','#463747'])
   d.rectangle((xx,yy,ex,ey),fill=p)
   d.line((xx+1,ey,ex,ey),fill='#332834',width=2)
   d.line((xx+2,yy+1,ex-2,yy+1),fill='#a07d86',width=1)
   if R.random()<0.23:d.line((xx+5,yy+4,xx+8,yy+6),fill='#ab7774',width=1)
def woodplanks(d,x0,y0,x1,y1,step=14):
 d.rectangle((x0,y0,x1,y1),fill=WOOD_DARK)
 for i,x in enumerate(range(x0,x1,step)):
  
  if x+2<=min(x+step-2,x1):d.rectangle((x+2,y0+2,min(x+step-2,x1),y1-2),fill=('#955c3f' if i%2 else '#754633'))
  d.line((x+4,y0+3,x+4,y1-5),fill='#bb764c',width=2)
  if R.random()<0.85:
   y=R.randrange(y0+12,max(y0+13,y1-8));d.line((x+6,y,x+9,y+4),fill='#463128',width=2)
def lantern(d,x,y,s=1):
 # x center, y lantern flame center, including suspension rim, 30x55
 d.line((x,y-28,x,y-17),fill=DARK,width=5);d.line((x,y-28,x,y-17),fill=GOLD,width=2)
 poly(d,[(x-12,y-16),(x+12,y-16),(x+16,y),(x+10,y+16),(x-10,y+16),(x-16,y)],WOOD_DARK,width=2)
 glow(d,x,y,8)
 d.line((x-10,y-13,x-8,y+13),fill=GOLD,width=3);d.line((x+10,y-13,x+8,y+13),fill=GOLD,width=3)
 d.line((x-10,y+15,x+10,y+15),fill='#d48a4d',width=4)

def forge():
 im=make(282,356);d=ImageDraw.Draw(im)
 # smoke continuous with chimney, freehand 1x, semi-transparent clusters
 d.line((56,103,55,48,40,27),fill=(117,103,113,165),width=14,joint='curve')
 for x,y,r in [(39,22,12),(31,15,17),(40,8,19),(56,20,18),(59,40,15),(64,52,12)]:
  d.ellipse((x-r,y-r,x+r,y+r),fill=(160,140,150,158),outline=(203,180,186,180),width=2)
 # base of cottage in volcanic rock
 poly(d,[(20,287),(237,279),(271,306),(259,337),(24,345),(10,316)],'#352730',width=4)
 poly(d,[(19,309),(258,302),(259,337),(25,344)],'#624651')
 bricks(d,29,306,255,338,17)
 # back undercroft / wall
 poly(d,[(37,153),(180,120),(259,161),(259,302),(39,318)],'#56363a',width=5)
 woodplanks(d,51,184,233,307,17)
 # left side 3/4 dark gable
 poly(d,[(28,177),(87,188),(85,306),(28,316)],'#45313a')
 for x in range(37,84,15):d.line((x,196,x,303),fill='#84604a',width=6);d.line((x+2,198,x+2,301),fill='#b16e46',width=2)
 # tall chimney behind roof
 poly(d,[(41,91),(69,91),(73,174),(35,181)],'#40303a')
 for y in range(103,171,10):d.line((42,y,70,y-1),fill='#8b6178',width=2)
 poly(d,[(33,86),(71,83),(76,105),(33,109)],'#59434e')
 poly(d,[(33,85),(70,81),(70,88),(33,92)],'#ba7147',width=3)
 d.rectangle((50,93,57,97),fill='#ffd16b')
 # roof ridge and two planes (non-ground building)
 poly(d,[(35,162),(123,103),(220,114),(271,174),(166,186),(75,200)],ROOF,width=5)
 poly(d,[(35,163),(123,103),(161,173),(75,199)],'#433249',width=4)
 poly(d,[(123,104),(218,113),(268,173),(160,178)],ROOF_HI,width=4)
 # regular roof tile pattern local perspective
 for y in range(130,178,13):
  for x in range(123,247,17):
   # shape inside roof only based on diagonal x/y envelope
   if x<140+(y-133)//3 or x>260-(175-y)//3:continue
   d.line((x,y,x+12,y+2),fill='#523b55',width=2)
   d.line((x+2,y-3,x+11,y-2),fill='#c08cab',width=1)
 for x in [66,87,108]:d.line((x,171,x+12,144),fill='#765a7c',width=3)
 # eaves and pillars
 d.line((69,200,164,185,264,187),fill=DARK,width=10,joint='curve')
 d.line((75,196,164,181,261,184),fill='#cf935d',width=5,joint='curve')
 for x,y in [(89,199),(248,193)]:
  d.line((x,y,x,305),fill='#462c2a',width=14);d.line((x-2,y+3,x-2,301),fill='#bd7648',width=7)
  for yy in [215,277]:d.rectangle((x-8,yy-3,x+8,yy+3),fill='#e2a35c',outline=DARK,width=2)
 # glowing furnace opening, arch shape
 poly(d,[(111,236),(119,213),(181,204),(198,222),(195,299),(111,306)],'#1c141d',width=5)
 poly(d,[(121,244),(127,222),(180,219),(188,246),(186,296),(122,300)],'#792e27',width=3)
 for i in range(6):
  xx=145+R.randrange(-29,30); yy=264+R.randrange(-10,18)
  poly(d,[(xx-8,yy+13),(xx,yy-17),(xx+6,yy+4),(xx+13,yy+12)],R.choice(['#ff501e','#ff8f25','#ffd45a']),width=1)
 d.ellipse((125,282,183,301),fill='#ff7e29')
 # anvil
 poly(d,[(134,293),(168,284),(186,291),(163,302),(146,302)],'#322a32')
 poly(d,[(146,302),(165,299),(163,316),(146,316)],'#5a4550')
 # orange-paned windows
 for x,y in [(54,239),(205,232)]:
  rect(d,(x-13,y-17,x+13,y+16),'#312330',DARK,3)
  glow(d,x,y,10)
  d.line((x,y-14,x,y+14),fill='#633f37',width=3)
  d.line((x-13,y,x+13,y),fill='#633f37',width=3)
 # beam detail, crates
 for xx,yy in [(32,296),(68,310),(207,306)]:
  rect(d,(xx,yy,xx+19,yy+25),'#7e563c',DARK,2)
  d.line((xx+2,yy+4,xx+17,yy+22),fill='#bd8555',width=2)
  d.line((xx+17,yy+4,xx+2,yy+22),fill='#a77b52',width=2)
 # entry wood sign and hanging glowing lamp
 lantern(d,258,251)
 return im

def bridge():
 im=make(192,156);d=ImageDraw.Draw(im)
 # rear plinths and wall shadows
 for cx in [32,160]:
  poly(d,[(cx-20,107),(cx+16,103),(cx+22,117),(cx+21,147),(cx-19,147),(cx-22,131)],'#2a1f2c',width=2)
  for y in [114,129,141]:d.line((cx-16,y,cx+17,y-2),fill='#88617d',width=2)
 # arch under structure behind deck, an arch y 84-141
 poly(d,[(29,85),(163,85),(166,99),(155,123),(144,138),(135,139),(130,120),(111,108),(80,107),(60,123),(50,140),(40,134),(28,103)],'#6b4549',width=3)
 # negative arch opening is actual alpha0, use transparent hole by mask paste
 # draw arch ribs along opening sides, keep actual center transparent
 mask=Image.new('L',(192,156),0);md=ImageDraw.Draw(mask)
 md.polygon([(53,142),(63,122),(73,112),(94,108),(113,110),(128,119),(138,140)],fill=255)
 a=np.array(im);m=np.array(mask);a[m>0]=0;im=Image.fromarray(a,'RGBA');d=ImageDraw.Draw(im)
 # gold arch rim half-circle underneath deck
 d.arc((43,101,149,187),start=183,end=357,fill='#d58f4e',width=5)
 d.arc((48,105,144,185),start=184,end=356,fill='#3f252c',width=4)
 for x in [47,57,70,83,109,123,135,147]:
  y=111+int(31*math.sin(max(0,(x-46)/102)*math.pi))
  d.rectangle((x-1,y-1,x+1,y+2),fill='#d59a5c')
 # entire deck top / bannister top
 poly(d,[(17,72),(173,69),(181,86),(166,105),(23,109),(10,86)],'#322635',width=4)
 poly(d,[(18,70),(167,68),(177,81),(25,86)],'#856279',width=3)
 for x in range(27,170,16):
  d.line((x,73,x+3,82),fill='#3b2c3c',width=2)
  d.line((x+4,73,x+10,74),fill='#c09ca3',width=1)
 # rear railing and posts
 d.line((32,55,160,53),fill='#34212a',width=8)
 d.line((32,52,160,50),fill='#e2a45d',width=4)
 for x in range(37,164,19):
  d.line((x,55,x,83),fill='#482c2e',width=6)
  d.line((x-2,58,x-2,81),fill='#d18a4b',width=2)
  d.ellipse((x-5,45,x+5,55),fill='#f7be67',outline=DARK,width=2)
  if x<150:d.line((x+4,79,x+19,57),fill='#ab6e47',width=2)
 # front railing under deck
 d.line((20,97,172,93),fill='#201821',width=7)
 d.line((22,95,170,91),fill='#ce925b',width=3)
 for x in range(34,169,18):
  d.line((x,84,x,103),fill=DARK,width=5)
  d.line((x,85,x,101),fill='#cc8750',width=2)
  d.ellipse((x-4,81,x+4,88),fill=GOLD,outline=DARK,width=1)
 # two end pier masonry and warm lantern panels (bridge world anchors)
 for cx in [32,160]:
  poly(d,[(cx-18,71),(cx+16,69),(cx+22,86),(cx+21,136),(cx+12,150),(cx-18,149),(cx-23,131),(cx-22,86)],'#5b4353',width=3)
  for y in [83,102,115,133]:d.line((cx-18,y,cx+17,y-1),fill=('#b38b98' if y%2 else '#302232'),width=2)
  for xx in [cx-15,cx+2]:d.line((xx,107,xx,130),fill='#3d2937',width=1)
  poly(d,[(cx-13,94),(cx+11,93),(cx+12,132),(cx-12,133)],'#34252d',width=2)
  poly(d,[(cx-8,99),(cx+7,98),(cx+7,126),(cx-8,127)],'#9a432b',width=1)
  glow(d,cx,113,8)
  d.line((cx-7,100,cx-7,127),fill='#ecab59',width=2)
  d.line((cx+7,100,cx+7,127),fill='#ecab59',width=2)
  # capstone and top lamp posts (connected)
  poly(d,[(cx-22,71),(cx-15,63),(cx+17,62),(cx+24,71),(cx+17,77),(cx-17,78)],'#74576d',width=3)
  poly(d,[(cx-10,45),(cx+10,45),(cx+13,65),(cx-13,65)],'#a37553')
  lantern(d,cx,37)
 # little basalt footing detail
 for x,y in [(17,136),(39,137),(149,138),(174,136)]:
  poly(d,[(x-7,y),(x+3,y-3),(x+9,y+2),(x+3,y+6),(x-8,y+6)],R.choice(['#76576b','#493747','#674858']),width=1)
 return im

def crane():
 im=make(236,288);d=ImageDraw.Draw(im)
 # black floor support piles not ground
 poly(d,[(13,233),(173,230),(220,249),(207,273),(23,271)],'#43313b')
 # supporting wooden tower
 woodplanks(d,64,86,115,254,10)
 d.line((63,82,113,252),fill=DARK,width=10);d.line((67,85,116,254),fill='#cf8b50',width=5)
 d.line((114,83,66,248),fill=DARK,width=9);d.line((110,89,71,247),fill='#d7a05f',width=4)
 for y in [100,144,189,232]:
  poly(d,[(55,y),(124,y-3),(121,y+8),(59,y+11)],'#b27445',width=2)
 for x in [64,110]:
  d.line((x,68,x,252),fill=DARK,width=11);d.line((x-3,71,x-3,244),fill='#d18a52',width=6)
 # boom frame
 poly(d,[(54,57),(196,34),(219,45),(208,65),(56,82)],'#5d3730',width=5)
 d.line((64,57,211,42),fill='#e8a85a',width=6)
 d.line((66,74,204,59),fill='#714534',width=5)
 for x in range(86,203,19):
  y=int(54-(x-64)*0.105)
  d.line((x,y+4,x+8,y+16),fill='#b67a47',width=4)
  d.rectangle((x-2,y-2,x+2,y+3),fill=GOLD)
 # pulley / chain
 d.ellipse((198,34,222,59),fill='#70463c',outline=DARK,width=4)
 d.ellipse((204,40,218,53),fill='#dd9854',outline='#3d292b',width=2)
 for y in range(58,112,7):d.ellipse((206,y,213,y+6),outline='#d8a05f',width=2)
 # suspended ore crate
 poly(d,[(180,118),(205,108),(228,118),(224,150),(183,150)],'#6a493a',width=3)
 for x,y in [(193,123),(209,121),(214,130),(196,135)]:d.ellipse((x-4,y-3,x+5,y+5),fill='#343d58',outline='#8196b0',width=1)
 d.line((182,150,224,151),fill='#e3a153',width=4)
 # wheelbarrow and crates on lower platform
 rect(d,(18,221,75,244),'#9b5c35',DARK,3)
 for x in [27,63]:d.ellipse((x-7,242,x+7,257),fill='#3b2a2b',outline='#dca15d',width=2)
 for x,y in [(31,215),(55,210),(48,230)]:d.ellipse((x-7,y-5,x+7,y+5),fill='#323e5c',outline='#7486b4',width=1)
 for x,y in [(129,227),(160,228),(137,253)]:
  rect(d,(x,y,x+24,y+24),'#795139',DARK,2);d.line((x,y,x+24,y+24),fill='#c18b58',width=2)
 lantern(d,133,126)
 return im

def shed():
 im=make(225,209);d=ImageDraw.Draw(im)
 poly(d,[(8,161),(183,161),(217,185),(202,198),(15,198)],'#382c37')
 for x in [29,181]:
  d.line((x,95,x,181),fill=DARK,width=13)
  d.line((x-3,99,x-3,176),fill='#b2784a',width=5)
 poly(d,[(11,98),(80,42),(192,55),(215,105),(80,121)],'#4b3951',width=5)
 poly(d,[(11,99),(80,43),(89,111),(75,123)],'#6a4d68',width=3)
 poly(d,[(80,44),(192,55),(214,107),(89,111)],'#8e6683',width=3)
 for y in [67,80,95]:
  for x in range(95,200,20):
   d.line((x,y,x+14,y+3),fill='#4e3b58',width=2)
   d.line((x+3,y-3,x+16,y-1),fill='#c38da8',width=1)
 d.line((19,118,80,119,206,113),fill='#d99754',width=7,joint='curve')
 d.line((27,118,27,177),fill='#b17a4b',width=6)
 d.line((191,112,191,179),fill='#c68d54',width=6)
 for x,y in [(43,141),(84,154),(139,149),(163,164),(51,176),(109,174)]:
  rect(d,(x,y,x+27,y+24),R.choice(['#8d5e3e','#7b4d37','#9c6f47']),DARK,2)
  d.line((x+3,y+4,x+23,y+20),fill='#cf9862',width=2)
 glow(d,164,136,7)
 return im

def main():
 OUT.mkdir(parents=True,exist_ok=True)
 assert sha(G)==LOCK_G and sha(SRC)==LOCK_SRC
 ground=Image.open(G);raw=Image.open(SRC)
 assert ground.size==(1280,928) and ground.mode=='RGB'
 assert raw.size==(1474,1067) and raw.mode=='RGBA'
 aa=np.asarray(raw.getchannel('A'));labels,num=label(aa>32,np.ones((3,3),np.uint8));counts=np.bincount(labels.ravel());bb=find_objects(labels)
 coords=[]
 for i,s in enumerate(bb,1):
  if s and counts[i]>=1000:
   y,x=s;coords.append((x.start,y.start,x.stop,y.stop))
 assert len(coords)==11,coords
 parts={}
 for key,bbox in zip(NAMES,coords):
  x0,y0,x1,y1=bbox;part=raw.crop((x0,y0,x1,y1))
  a=np.array(part);a[a[:,:,3]<=8]=[0,0,0,0];parts[key]=Image.fromarray(a,'RGBA')
 # Four newly hand-painted source-authoring objects, not cropped/rescaled from D24.
 fresh={'forge':forge(),'ore_crane':crane(),'iron_bridge':bridge(),'supply_workshop':shed()}
 for key,part in fresh.items():
  parts[key]=part
  part.save(OUT/f'D26_SOURCE_NEW_{key.upper()}_1X_RGBA.png')
 placements={'forge':(64,96),'ore_crane':(605,65),'iron_bridge':(944,464),
             'north_lamp':(762,402),'western_lamp':(344,480),'western_basalt':(1108,147),
             'south_east_basalt':(1138,752),'supply_workshop':(96,648),'east_lamp':(859,671),
             'flame_banner':(509,663),'southern_basalt':(20,525)}
 par=make(1280,928);occ=np.zeros((928,1280),dtype=bool);qaobjects=[];overlap=0
 for k in NAMES:
  x,y=placements[k];part=parts[k];w,h=part.size
  assert x>=0 and y>=0 and x+w<=1280 and y+h<=928,(k,part.size,(x,y))
  al=np.asarray(part.getchannel('A'))>8
  overlap+=int(np.sum(occ[y:y+h,x:x+w]&al));occ[y:y+h,x:x+w]|=al
  par.alpha_composite(part,(x,y))
  qaobjects.append({'name':k,'origin_xy':[x,y],'bbox_xyxy':[x,y,x+w,y+h],
                    'source_dimensions':[w,h],'source_kind':'NEW_MANUAL_1X_RGBA' if k in fresh else 'PRESERVED_D24_INTACT_ALPHA_ISLAND_1X',
                    'alpha_visible_gt8':int(np.count_nonzero(al)),
                    'source_sha256':sha(OUT/f'D26_SOURCE_NEW_{k.upper()}_1X_RGBA.png') if k in fresh else LOCK_SRC})
 parpath=OUT/'D26_COMPLETE_PAR_1280x928_RGBA.png';par.save(parpath)
 comppath=OUT/'D26_GROUND_PAR_STATIC_COMPOSITE_1280x928.png'
 Image.alpha_composite(ground.convert('RGBA'),par).save(comppath)
 source_contact=Image.new('RGBA',(1180,720),(0,0,0,0));
 for k,(x,y) in zip(['forge','ore_crane','iron_bridge','supply_workshop'],[(3,9),(330,2),(695,85),(730,370)]):source_contact.alpha_composite(fresh[k],(x,y))
 source_contact.save(OUT/'D26_NEW_FOUR_ORIGINAL_ART_SOURCES_RGBA.png')
 bridgea=fresh['iron_bridge']; forges=fresh['forge'];
 assert bridgea.width==192 and forges.width<=288 and forges.height<=360
 assert np.count_nonzero(np.asarray(par.getchannel('A'))==0)>500000
 a=np.asarray(par.getchannel('A'))
 border=int(np.count_nonzero(a[:5,:]>224)+np.count_nonzero(a[-5:,:]>224)+np.count_nonzero(a[5:-5,:5]>224)+np.count_nonzero(a[5:-5,-5:]>224))
 # compare with D24 static visual but don't change D24 in any way
 d24=Image.open('/mnt/data/TC_D24_ART_FIRST_WORK/D24_B_GROUND_PAR_COMPOSITE_1280x928.png').convert('RGB')
 comp=Image.open(comppath).convert('RGB')
 panel=Image.new('RGB',(2560,990),(21,24,31));p=ImageDraw.Draw(panel)
 p.text((14,12),'D24 OLD 388PX BRIDGE / 495PX FORGE -- ART HOLD',fill='#ffd48b')
 p.text((1294,12),'D26 NEW 192PX BRIDGE / 282PX FORGE -- ART CANDIDATE, HOLD',fill='#a3edb5')
 panel.paste(d24,(0,50));panel.paste(comp,(1280,50));panel.save(OUT/'D26_D24_D26_FULL_SCENE_COMPARISON.png')
 qa={'phase':'D26_INDEPENDENT_SHORT_BRIDGE_NATIVE_1X_COMPACT_OBJECT_REAUTHOR',
 'source_types':'FOUR_NEW_HAND_PAINTED_PIXEL_ART_RGBA_ASSETS+SEVEN_COMPLETE_1X_INDEPENDENT_D24_RGBA_ISLANDS',
 'scene':'FS_04_MAZE','ground_SHA256':LOCK_G,'D24_independent_source_SHA256':LOCK_SRC,
 'ground_untouched':True,'pixel_scale_for_all_assets':1,'bridge_width_px':bridgea.width,'bridge_height_px':bridgea.height,
 'forge_width_px':forges.width,'forge_height_px':forges.height,'new_bridge_landing_reference_xy':[[970,603],[1110,603]],
 'new_bridge_world_xy':[944,464], 'source_objects':qaobjects,'PAR_RGBA_sha256':sha(parpath),
 'COMPOSITE_sha256':sha(comppath),'PAR_true_alpha0_pixels':int((a==0).sum()),
 'PAR_object_overlap_pixels':overlap,'outer_5px_alpha_gt224':border,
 'actual_Godot_4_7_2_NATIVE':'NOT_RUN','human_ART':'HOLD_OWNER_NOT_APPROVED',
 'formal_12_map_ART_PASS':'0/12','limitations':'New procedural/manual compact pixels may not match AI authored D24 source style; some D24 parts preserved and no original object resized. Art visual acceptance is distinct from source geometry.'}
 (OUT/'D26_ART_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
 print(json.dumps({k:qa[k] for k in ['bridge_width_px','forge_width_px','forge_height_px','PAR_object_overlap_pixels','outer_5px_alpha_gt224','PAR_true_alpha0_pixels','PAR_RGBA_sha256','COMPOSITE_sha256']},indent=2))

if __name__=='__main__':main()
