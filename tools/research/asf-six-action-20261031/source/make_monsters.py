from pathlib import Path
import json
from PIL import Image,ImageDraw
out=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\monster-specs")
out.mkdir(parents=True,exist_ok=True)
pal={"k":"#1a1c2c","b":"#82552c","B":"#523821","g":"#38b764","G":"#257179","l":"#a7f070","H":"#fff7bd","e":"#ffcd75"}
rev={tuple(bytes.fromhex(c[1:])):k for k,c in pal.items()}
def render(form,idx):
 im=Image.new("RGB",(32,32),(255,0,255));d=ImageDraw.Draw(im);dy=[0,-1,0,1][idx]
 E=lambda bb,c:d.ellipse([bb[0],bb[1]+dy,bb[2],bb[3]+dy],fill=pal[c])
 P=lambda pts,c:d.polygon([(x,y+dy) for x,y in pts],fill=pal[c])
 L=lambda pts,c,w=1:d.line([(x,y+dy) for x,y in pts],fill=pal[c],width=w)
 if form=="seedling":
  E([11,15,21,27],"B");E([12,15,20,25],"g")
  P([(14,17),(11,10),(14,8),(17,13)],"G")
  P([(16,15),(17,7),(23,5),(22,12)],"g")
  P([(17,14),(22,10),(24,8),(20,8)],"l")
  E([13,24,15,29],"B");E([18,24,20,29],"B")
  d.point((17,18+dy),fill=pal["k"])
  d.point((19,21+dy),fill=pal["e"])
  if idx==2:L([(17,18),(18,18)],"k")
  E([13,17,15,18],"l")
 else:
  P([(12,13),(9,9),(8,4),(10,2),(12,9),(14,10)],"B")
  L([(10,8),(5,6),(4,3)],"B",2)
  P([(20,13),(23,9),(24,3),(22,2),(19,9),(18,10)],"B")
  L([(23,8),(27,5)],"B",2)
  P([(8,20),(5,18),(2,19),(6,24),(11,25)],"G")
  E([10,10,23,25],"B");E([12,11,21,21],"g")
  P([(11,12),(18,10),(17,21),(11,20)],"G")
  P([(13,10),(18,9),(21,13),(18,15)],"l")
  P([(11,15),(7,15),(5,20),(8,23),(11,20)],"B")
  P([(22,15),(25,17),(27,22),(25,24),(21,21)],"B")
  P([(4,21),(6,25),(8,23),(9,25)],"g")
  P([(25,23),(27,26),(28,24),(29,26)],"g")
  P([(12,23),(15,23),(14,29),(10,29)],"B")
  P([(19,23),(22,22),(24,28),(20,29)],"B")
  d.point((19,15+dy),fill=pal["e"])
  d.point((20,15+dy),fill=pal["k"])
  if idx==2:L([(18,15),(20,15)],"k")
  E([16,20,19,21],"l")
 pix=im.load()
 return ["".join(rev.get(pix[x,y],".") for x in range(32)) for y in range(32)]
for form in ("seedling","guardian"):
 poses={f"idle_{i}":render(form,i) for i in range(4)}
 spec={"schema":"codeart2d.pixelspec.v1","name":"thornkin-"+form,"canvas":[32,32],"anchor_px":[16,31],"palette":pal,"outline":{"mode":"solid","color":"k"},"poses":poses,"layers":[{"name":"body","z":0,"origin":[0,0],"rows":"idle_0"}],"frames":[{"name":f"idle-{i}","layers":{"body":{"rows":f"idle_{i}"}}} for i in range(4)],"clips":{"idle":{"frames":[f"idle-{i}" for i in range(4)],"duration_ms":[180,140,180,160],"loop":True}}}
 (out/f"thornkin-{form}.pixelspec.json").write_text(json.dumps(spec,indent=2),encoding="utf-8")
 print("WROTE",form)
