from pathlib import Path
from PIL import Image,ImageDraw
import xml.etree.ElementTree as ET,json
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
UP=R/"outputs/P3_G5_0003_OFFICIAL_SOURCE_20261026"
SRC=UP/"SOURCE_0003"
D=R/"outputs/P3_G5R1_0003_RUPTURED_LAVA_CORE_20261026"
T=D/"VOLCANIC_0003"
xml=ET.parse(SRC/"AnimData.xml").getroot()
for name in ("Idle","Walk","Attack"):
 a=next(x for x in xml.findall(".//Anim") if x.findtext("Name")==name)
 fw=int(a.findtext("FrameWidth"));fh=int(a.findtext("FrameHeight"))
 duration=[int(x.text) for x in a.find("Durations").findall("Duration")]
 original=Image.open(SRC/(name+"-Anim.png")).convert("RGBA")
 edited=Image.open(T/(name+"-Anim.png")).convert("RGBA")
 assert original.size==edited.size and original.width==fw*len(duration)
 canvas=[]
 for k,n in enumerate(duration):
  v=Image.new("RGB",(574,534),(31,38,45));d=ImageDraw.Draw(v)
  d.text((8,8),f"PMD0003 {name}: frame {k+1}/{len(duration)}, XML={n} ticks",fill=(242,233,216))
  d.text((8,28),"UPSTREAM 0003",fill=(187,235,163))
  d.text((293,28),"EVOLVED ROCK+FIRE 0003",fill=(255,199,139))
  for facing in range(8):
   t0=original.crop((k*fw,facing*fh,(k+1)*fw,(facing+1)*fh))
   t1=edited.crop((k*fw,facing*fh,(k+1)*fw,(facing+1)*fh))
   scale=1 if max(fw,fh)>52 else 2
   t0=t0.resize((fw*scale,fh*scale),Image.Resampling.NEAREST)
   t1=t1.resize((fw*scale,fh*scale),Image.Resampling.NEAREST)
   y=54+facing*59
   v.paste(t0,(100,y),t0)
   v.paste(t1,(387,y),t1)
   d.text((8,y+12),str(facing),fill=(169,194,221))
  canvas.append(v)
 dest=D/(name+"_SOURCE_VS_EVOLUTION_XML.gif")
 canvas[0].save(dest,save_all=True,append_images=canvas[1:],
                duration=[max(40,round(q*1000/60)) for q in duration],loop=0,disposal=2,optimize=False)
 with Image.open(dest) as g:assert g.n_frames==len(duration)
# Authentic art comparison, actual original per-species frame positions (no mockups).
ids=[
  ("0001 | small magma fissure",R/"outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026/rock_0001/Idle-Anim.png",32,40),
  ("0002 | split basalt",R/"outputs/P3_G4R1_0002_VOLCANIC_EVOLUTION_20261026/VOLCANIC_0002/Idle-Anim.png",32,32),
  ("0003 | exposed molten core",T/"Idle-Anim.png",32,32),
]
board=Image.new("RGB",(1200,660),(28,34,40));d=ImageDraw.Draw(board)
d.text((20,12),"PMD SOURCE-DERIVED EVOLUTION CHAIN | ORANGE/GRAY ROCK + FIRE",fill=(248,233,214))
for ix,(label,file,w,h) in enumerate(ids):
 im=Image.open(file).convert("RGBA")
 x=20+ix*392
 d.text((x,50),label,fill=(255,209,155))
 for j,direction in enumerate((0,2,4,6)):
  f=im.crop((0,direction*h,w,(direction+1)*h)).resize((w*3,h*3),Image.Resampling.NEAREST)
  board.paste(f,(x+25+j%2*175,95+j//2*198),f)
  d.text((x+25+j%2*175,217+j//2*198),f"PMD facing {direction}",fill=(190,205,217))
d.text((20,578),"AUTHENTIC SOURCE XML/ANIM FRAME POSITION PER SPECIES; ALL FRAMES STAY IN THEIR ORIGINAL CELLS.",fill=(195,214,221))
board.save(D/"P3_0001_0002_0003_AUTHENTIC_EVOLUTION_CHAIN.png")
print("PREVIEWS_0003",[(x.name,x.stat().st_size) for x in D.glob("*.gif")],flush=True)
