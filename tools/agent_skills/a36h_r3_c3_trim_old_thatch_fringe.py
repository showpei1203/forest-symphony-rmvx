from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np
R=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36H_VISUAL_ART_REPAIR_20261107")
orig=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104\SOURCE_INDEPENDENT_RGBA")
new=R/"A36H_R3_C3_CLEAN_EAVE_SILHOUETTE"
if new.exists():raise RuntimeError("exists")
new.mkdir(parents=True)
def cut(id,source,kind):
 p=R/"A36H_R3_C2_RAKE_AND_EAVE_ONLY"/(id+"_WOOD_GEOMETRY_R3_RGBA.png")
 arr=np.asarray(Image.open(p).convert("RGBA")).copy()
 old=np.asarray(Image.open(orig/source).convert("RGBA"))
 h,w=arr.shape[:2]; yy,xx=np.indices((h,w))
 hue,sat,val=[np.asarray(Image.fromarray(old,"RGBA").convert("HSV"))[:,:,i] for i in range(3)]
 natural=(hue>37)&(hue<103)&(sat>68)&(val>23)&(old[:,:,3]>0)
 if kind=="right":
  yedge=117+(.29*(xx-22))
  zone=(xx>=17)&(xx<145)&(yy>yedge+5)&(yy<yedge+26)&(yy>117)&(yy<179)
 else:
  yedge=150+.22*(xx-18)
  zone=(xx>=11)&(xx<160)&(yy>yedge+5)&(yy<yedge+23)&(yy>144)&(yy<201)
 trim=zone&natural&(arr[:,:,3]>0)
 before=int((arr[:,:,3]>0).sum())
 arr[trim]=0
 removed=int(trim.sum())
 output=new/(id+"_WOOD_ROOF_CLEAN_EAVE_RGBA.png")
 Image.fromarray(arr,"RGBA").save(output)
 bg=Image.new("RGBA",(w,h),(83,88,89,255))
 a=bg.copy();a.alpha_composite(Image.open(p).convert("RGBA"))
 b=bg.copy();b.alpha_composite(Image.fromarray(arr,"RGBA"))
 sheet=Image.new("RGB",(w*2,h+25),(28,30,33));sheet.paste(a.convert("RGB"),(0,25));sheet.paste(b.convert("RGB"),(w,25))
 d=ImageDraw.Draw(sheet);d.text((5,6),"R3 C2 / no fringe trim",fill="white");d.text((w+5,6),"R3 C3 / source alpha trim",fill="white")
 sheet.save(new/(id+"_R3C2_VS_R3C3_1X.png"))
 return {"removed_fringe_pixels":removed,"total_alpha_before":before,"remaining":int((arr[:,:,3]>0).sum()),"source":source}
m={}
m["left"]=cut("A36G_ELF_HOUSE_AND_WORKSHOP","A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png","left")
m["right"]=cut("A36G_R5_COTTAGE_B_SINGLE_ROOF","A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png","right")
(new/"R3C3_FRINGE_QA.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(m,ensure_ascii=False))