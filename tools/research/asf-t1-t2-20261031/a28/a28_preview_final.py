"""Build A28 phone-friendly combined PMD six + FS six, using only real PixelLab frames.
This script does NOT generate art. Await all 4 new FS actions and sword skeleton padded64.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import hashlib,json,zipfile,shutil
A27=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
A28=Path(r"E:\GameAssetToolLab_20261023\A28_FS_SKELETON_BATTLE_AND_FOUR_ACTIONS_20261101")
A26=Path(r"E:\GameAssetToolLab_20261023\A26_PMD0001_APPROVED_SHEETS_FS_RATIO_REPAIR_20261101")
P=A27/"PMD_XML_SE_ONLY_CANDIDATES"
fontpath=r"C:\Windows\Fonts\arial.ttf"
def font(n):
 try:return ImageFont.truetype(fontpath,n)
 except:return ImageFont.load_default()
f20=font(19);f13=font(13);f22=font(23)
RATIO={n:40 for n in ("IDLE","WALK","CAST","HURT","DEATH")}
def frames_pmd(name):
 p=P/(name+"_SE45_CLEAN_64x5.png")
 s=Image.open(p).convert("RGBA")
 assert s.size==(320,64),(name,s.size)
 return [s.crop((i*64,0,(i+1)*64,64)) for i in range(5)]
def frames_fs(name):
 if name=="IDLE":p=A27/"FS_IDLE"/"ACTUAL_NATIVE_40_SPRITESHEET.png"
 elif name=="ATTACK":p=A28/"FS_SKELETON_ATTACK_64_PAD"/"FS_SKELETON_SWORD64_SHEET.png"
 else:p=A28/("FS_"+name)/"PIXELLAB_SPRITESHEET_40x5.png"
 s=Image.open(p).convert('RGBA');w=64 if name=="ATTACK" else 40
 assert s.height==w and s.width//w>=5,(name,s.size)
 return [s.crop((i*w,0,(i+1)*w,w)) for i in range(s.width//w)]
def build(title,names,fn,output,section):
 width=835;head=78;rh=137;footer=35
 page=Image.new('RGB',(width,head+len(names)*rh+footer),(243,245,247))
 d=ImageDraw.Draw(page)
 d.rectangle((0,0,width,head),fill=(25,35,52))
 d.text((19,11),title,font=f22,fill=(250,250,250))
 d.text((19,46),"A25/A26 approved base | Real PixelLab frames | Art review candidates",font=f13,fill=(202,214,227))
 allstat={}
 for j,name in enumerate(names):
  y=head+j*rh
  d.rectangle((0,y,width,y+rh),fill=((232,237,241) if j%2==0 else (246,248,249)))
  fr=fn(name)
  allstat[name]={"frame_count":len(fr),"frame_dimensions":[fr[0].width,fr[0].height],
    "bboxes":[x.getbbox() for x in fr]}
  status="APPROVED" if section=="PMD" and name in ("Idle","Walk") else "NEW REVIEW"
  if section=="FS" and name=="ATTACK":status="SKELETON v2"
  label=(("PMD " if section=="PMD" else "FS ")+name)
  d.text((12,y+25),label,font=f20,fill=(30,42,54))
  d.text((12,y+53),status,font=f13,fill=(73,89,105))
  for i,im in enumerate(fr[:6]):
   x=161+i*110
   bg=Image.new("RGBA",im.size,(244,246,249,255));bg.alpha_composite(im)
   preview=bg.convert("RGB").resize((96,96),Image.Resampling.NEAREST)
   page.paste(preview,(x,y+15))
   d.text((x+40,y+115),"F"+str(i),font=f13,fill=(105,120,135))
  d.line((0,y+rh-1,width,y+rh-1),fill=(200,207,217),width=1)
 d.text((13,head+len(names)*rh+10),"Source art retained unmodified. QA != official engine integration.",font=f13,fill=(80,95,110))
 page.save(output,optimize=True)
 return allstat
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 pnames=["Idle","Walk","Attack","Charge","Hurt","Faint"]
 fnames=["IDLE","WALK","ATTACK","CAST","HURT","DEATH"]
 p=build("PMD0001 | Lava creature - Six motions",pnames,frames_pmd,A28/"A28_PMD_SIX_ACTIONS_MOBILE.png","PMD")
 f=build("FS actor01 | 1:1 chibi swordsman - Six motions",fnames,frames_fs,A28/"A28_FS_SIX_ACTIONS_MOBILE.png","FS")
 top=Image.open(A28/"A28_PMD_SIX_ACTIONS_MOBILE.png").convert('RGB')
 bot=Image.open(A28/"A28_FS_SIX_ACTIONS_MOBILE.png").convert('RGB')
 combined=Image.new('RGB',(max(top.width,bot.width),top.height+bot.height+12),(230,233,238))
 combined.paste(top,(0,0));combined.paste(bot,(0,top.height+12))
 combined.save(A28/"A28_PMD_AND_FS_ALL_ACTIONS_COMBINED.png",optimize=True)
 # Save PNG & GIF per action, keep original raw frames and scripts and QA.
 for name in fnames:
  fr=frames_fs(name);fr[0].save(A28/f"FS_{name}_REAL_PIXEL_LAB.gif",save_all=True,append_images=fr[1:],duration=175,loop=0,disposal=2)
 stat={"pmd":p,"fs":f,"images":{
 "pmd":"A28_PMD_SIX_ACTIONS_MOBILE.png",
 "fs":"A28_FS_SIX_ACTIONS_MOBILE.png",
 "combined":"A28_PMD_AND_FS_ALL_ACTIONS_COMBINED.png"}}
 (A28/"A28_IMAGE_QA.json").write_text(json.dumps(stat,ensure_ascii=False,indent=2),encoding="utf8")
 print("RENDERED",[(str(x),x.stat().st_size) for x in [A28/"A28_PMD_SIX_ACTIONS_MOBILE.png",A28/"A28_FS_SIX_ACTIONS_MOBILE.png",A28/"A28_PMD_AND_FS_ALL_ACTIONS_COMBINED.png"]])
if __name__=="__main__":main()
