"""Native source terrain texture for Stage4 Godot PlaneMesh.
No full-scene reverse cut, independent underlay; all image pixels are generated
from painted landscape masks and clustered grass/leaf/flower details."""
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,math,json,random,pathlib
root=pathlib.Path(__file__).resolve().parent
N=1024
seed=31012026
rng=np.random.default_rng(seed)
rr=random.Random(seed)
def noise_grid(sz):
 a=(rng.random((sz,sz))*255).astype('uint8')
 im=Image.fromarray(a,"L").resize((N,N),Image.Resampling.BICUBIC)
 return np.asarray(im,dtype=np.float32)/255.0
coarse=noise_grid(13)
medium=noise_grid(69)
fine=noise_grid(251)
# Dense, differentiated palette without purple confetti or visible tile seams.
lum=0.48*coarse+0.39*medium+0.13*fine
r=(110+25*lum+4*(coarse-.5)).clip(0,255)
g=(151+29*lum+3*(medium-.5)).clip(0,255)
b=(84+23*lum+3*(fine-.5)).clip(0,255)
rgb=np.stack([r,g,b],axis=-1).astype(np.uint8)
land=Image.fromarray(rgb,"RGB").convert("RGBA")
mask=Image.new("L",(N,N),0)
md=ImageDraw.Draw(mask)
PX=N/18.0
def pt(x,z):
 return int(round((x+9.0)*PX)), int(round((z+9.0)*PX))
def curve(points,steps=220):
 res=[]
 for i in range(len(points)-1):
  p0=points[max(0,i-1)]
  p1=points[i];p2=points[i+1];p3=points[min(len(points)-1,i+2)]
  for j in range(steps//(len(points)-1)):
   t=j/(steps//(len(points)-1));t2=t*t;t3=t*t2
   out=[]
   for k in [0,1]:
    v=.5*(2*p1[k]+(-p0[k]+p2[k])*t+(2*p0[k]-5*p1[k]+4*p2[k]-p3[k])*t2+(-p0[k]+3*p1[k]-3*p2[k]+p3[k])*t3)
    out.append(v)
   res.append(pt(*out))
 return res+[pt(*points[-1])]
route=curve([(0,1.45),(-.09,2.0),(-.22,2.75),(-.48,3.8),(-.85,5.5),(-1.3,8.8)])
# Varied natural path width, several offset spline strokes.
md.line(route,fill=255,width=int(PX*1.30),joint="curve")
for i in range(6):
 xx,zz=rr.choice(route)
 rad=rr.randrange(13,37)
 md.ellipse((xx-rad,zz-rad//2,xx+rad,zz+rad//2),fill=255)
road_mask=mask.filter(ImageFilter.GaussianBlur(2))
m=np.asarray(road_mask,dtype=np.float32)/255.0
a=np.asarray(land,dtype=np.float32)
# Underlying earth with granular texture, not a flat beige ribbon.
earth=np.stack([185+27*lum,160+30*lum,124+33*lum,np.full((N,N),255)],axis=2)
a[:,:,:3]=a[:,:,:3]*(1-m[:,:,None])+earth[:,:,:3]*m[:,:,None]
land=Image.fromarray(np.uint8(np.clip(a,0,255)),"RGBA")
draw=ImageDraw.Draw(land,"RGBA")
def no_road(x,z,pad=4):
 xx,zz=pt(x,z)
 if xx<0 or zz<0 or xx>=N or zz>=N:return False
 return mask.getpixel((xx,zz))<30
# A/B hand-painted biome zones using clusters, not repetitive tile scatter.
biomes=[
 (-6.7,-5.1,2.8,2.0,160),
 (-6.1,2.5,2.6,2.1,140),
 (5.8,-4.0,2.2,2.1,145),
 (6.2,4.7,2.7,2.2,150),
 (-2.4,-4.9,1.9,1.6,90),
 (3.1,3.4,1.7,1.5,110),
]
for cx,cz,wx,wz,cnt in biomes:
 for j in range(cnt):
  x=cx+rr.gauss(0,wx/2)
  z=cz+rr.gauss(0,wz/2)
  if not no_road(x,z):continue
  u,v=pt(x,z)
  l=rr.randrange(3,10)
  shade=rr.choice([(63,112,62,180),(88,132,70,170),(163,186,103,170),(192,198,120,150)])
  draw.polygon([(u-2,v+2),(u,v-l),(u+1,v+3)],fill=shade)
  if j%2==0:
   draw.line((u-3,v,u+4,v-2),fill=(93,149,76,175),width=1)
  if j%11==0:
   tint=rr.choice([(241,219,153,220),(225,164,182,210),(238,235,205,220)])
   rad=rr.randrange(2,4)
   draw.ellipse((u-rad,v-rad,u+rad,v+rad),fill=tint)
# tiny leaves near shrubs; organic grouping
for x,z in [(-3.2,1.3),(3.3,1.0),(-3.2,-1.7),(3.2,-1.2),(-4.2,3.3),(4.1,3.5)]:
 u0,v0=pt(x,z)
 for j in range(36):
  u=u0+rr.gauss(0,22)
  v=v0+rr.gauss(0,15)
  if 0<=u<N and 0<=v<N and mask.getpixel((int(u),int(v)))<30:
   c=rr.choice([(183,161,101,170),(228,203,127,160),(97,116,60,190),(142,163,74,165)])
   draw.ellipse((u,v,u+rr.randrange(2,6),v+rr.randrange(1,3)),fill=c)
# stones are smaller and their clusters follow route; all ground-native.
for i in range(310):
 t=rr.randrange(20,len(route)-10)
 x,y=route[t]
 x+=rr.gauss(0,PX*.45)
 y+=rr.gauss(0,PX*.25)
 if 0<=x<N-5 and 0<=y<N-5 and mask.getpixel((int(x),int(y)))>150:
  w=rr.randrange(2,11)
  h=rr.randrange(2,7)
  col=rr.choice([(207,192,153,175),(227,208,171,155),(156,141,112,170)])
  draw.polygon([(x-w/2,y),(x,y-h/2),(x+w/2,y),(x+w/3,y+h/2),(x-w/3,y+h/3)],fill=col)
# Stage5 hand-authored native grass motifs. Hard silhouettes and coherent
# clusters are source art, never a filter over full composed Ground+PAR.
tuft_seeds=[
 (-6.6,-4.0,1.7,1.0,95),(-6.2,3.25,1.8,1.3,105),
 (6.2,-4.3,1.5,1.1,82),(6.0,4.55,1.6,1.25,103),
 (-2.7,-5.0,1.4,1.2,68),(3.0,3.4,1.1,.95,64),
 (-4.1,1.35,.85,.63,32),(4.12,1.25,.8,.60,30)]
for x0,z0,rx,rz,count in tuft_seeds:
 for i in range(count):
  x=x0+rr.gauss(0,rx*.46)
  z=z0+rr.gauss(0,rz*.46)
  if not no_road(x,z):continue
  u,v=pt(x,z)
  if not (17<u<N-17 and 17<v<N-17):continue
  height=rr.randint(6,12)
  width=rr.randint(2,4)
  tint=rr.choice([
   (65,117,69,185),(84,135,74,170),
   (139,178,100,165),(166,195,113,153),
   (105,151,84,180)])
  draw.polygon([(u-width,v+2),(u-1,v-height),(u+width,v+2)],fill=tint)
  if i%3==0:
   draw.polygon([(u+2,v+1),(u+8,v-height//2),(u+9,v+1)],fill=(174,191,104,175))
  if i%13==0:
   petal=rr.choice([(238,214,152,245),(239,177,191,233),(223,223,194,240)])
   draw.ellipse((u-3,v-height-4,u+4,v-height+3),fill=petal)
  if i%5==0:
   draw.line([(u-6,v+3),(u-2,v-2),(u+2,v+1)],fill=(52,92,53,150),width=1)
# Edge vegetation and stone clusters are mapped to walkable Ground rather than PAR.
for x0,z0 in [(-2.3,2.4),(2.2,2.3),(-1.7,4.8),(1.45,5.4)]:
 for i in range(26):
  x=x0+rr.gauss(0,.27)
  z=z0+rr.gauss(0,.34)
  if not no_road(x,z):continue
  u,v=pt(x,z)
  if 0<u<N-4 and 0<v<N-6:
   draw.polygon([(u-2,v+2),(u,v-rr.randint(5,12)),(u+3,v+3)],fill=rr.choice([(81,138,76,220),(168,189,97,220)]))
# Native authored soft ground shadows as a physical-world projection, not a crop from PAR.
shadows=Image.new("RGBA",(N,N),(0,0,0,0))
shadowdraw=ImageDraw.Draw(shadows,"RGBA")
def elliptic_shadow(x,z,wx,wz,opacity):
 u,v=pt(x,z);w=wx*PX;h=wz*PX
 shadowdraw.ellipse((int(u-w),int(v-h),int(u+w),int(v+h)),fill=(29,51,40,opacity))
# Cottage footprint and trees: shadow is part of source Ground only.
elliptic_shadow(0,-.35,2.48,2.00,87)
elliptic_shadow(-4.35,-2.98,1.05,.55,70)
elliptic_shadow(4.51,-3.12,.95,.50,70)
shadows=shadows.filter(ImageFilter.GaussianBlur(21))
land=Image.alpha_composite(land,shadows)
p=root/"assets"/"terrain_stage5.png"
p.parent.mkdir(exist_ok=True)
land.convert("RGB").save(p,optimize=True)
(root/"TERRAIN_STAGE5_SOURCE.json").write_text(json.dumps({"type":"native_terrain_texture","seed":seed,"world_extent_meters":[18,18],"size_px":[N,N],"layers":["base biomes with coarse+medium noise","curved mask-authored dirt path","wildflower clusters","leaf/grass strokes","ground-only cottage tree contact shadows"],"not":"a master-scene extraction"},ensure_ascii=False,indent=2),encoding="utf-8")
print("TERRAIN_PNG",p,p.stat().st_size,"UNIQUE_COLORS",len(np.unique(np.asarray(land.convert('RGB')).reshape(-1,3),axis=0)),flush=True)