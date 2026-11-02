"""FS A63 W3B: reusable lateral Waiting animation from ONE approved character F0.
No new bone extraction, no model credits. Crisp per-row shifts with feet anchored.
For run use retarget_any_actor_offline.py and A62 run pose recipe.
python retarget_waiting_pixels_offline.py --target-png actor02_se_f0.png --out-dir actor02_Waiting
"""
from pathlib import Path
from hashlib import sha256
from PIL import Image
import argparse,json
def make_waiting(src:Image.Image):
 src=src.convert("RGBA")
 w,h=src.size
 if w!=h or w not in(32,40,48,64):raise ValueError("Expected transparent square native 32/40/48/64 chibi F0 reference")
 box=src.getbbox()
 if not box:raise ValueError("Empty reference image")
 physical_height=box[3]-box[1]
 if physical_height<18:raise ValueError("Figure too small; can't create natural pixel sway")
 scale=physical_height/35
 step1=max(1,round(1*scale));step2=max(step1+1,round(2*scale))
 waist_left=box[3]-max(1,round(6*scale))
 waist_upper=box[3]-max(2,round(9*scale))
 out=[]
 for phase in range(3):
  im=Image.new("RGBA",(w,h),(0,0,0,0))
  for y in range(h):
   if phase==0:offset=0
   elif phase==1:offset=step1 if y<=waist_left else 0
   else:offset=step2 if y<=waist_upper else (step1 if y<=waist_left else 0)
   for x in range(w):
    rgba=src.getpixel((x,y))
    if rgba[3]==0:continue
    new_x=x+offset
    if new_x>=w or new_x<0:raise ValueError("Motion would clip image border; add transparent padding and reverify")
    im.putpixel((new_x,y),rgba)
  if len(set(im.getdata()))!=len(set(src.getdata())):raise ValueError("Source color palette changed unexpectedly")
  if sorted(im.getdata())!=sorted(src.getdata()):raise ValueError("Source pixel identity altered")
  # Strict foot pixels anchored: y >= waist_left+1
  band=(0,waist_left+1,w,h)
  if im.crop(band).tobytes()!=src.crop(band).tobytes():raise ValueError("Foot-anchor region drift")
  bx=im.getbbox()
  if not bx or bx[0]==0 or bx[1]==0 or bx[2]==w or bx[3]==h:
   raise ValueError("No transparent margin or cropped result")
  out.append(im)
 if out[0].tobytes()!=src.tobytes():raise ValueError("Original F0 image changed")
 if out[1].tobytes()==out[2].tobytes():raise ValueError("F1 F2 collapse")
 return out,{"step1_px":step1,"step2_px":step2,"waist_upper_y":waist_upper,
             "waist_lower_y":waist_left,"foot_anchor_start_y":waist_left+1,
             "bbox":box,"silhouette_height":physical_height}
if __name__=="__main__":
 a=argparse.ArgumentParser()
 a.add_argument("--target-png",required=True,type=Path)
 a.add_argument("--out-dir",required=True,type=Path)
 args=a.parse_args()
 src=Image.open(args.target_png).convert("RGBA")
 output,info=make_waiting(src)
 args.out_dir.mkdir(parents=True,exist_ok=True)
 for i,im in enumerate(output):
  im.save(args.out_dir/f"WAITING_F{i}.png")
 strip=Image.new("RGBA",(len(output)*src.width,src.height))
 for i,im in enumerate(output):strip.alpha_composite(im,(i*src.width,0))
 strip.save(args.out_dir/"WAITING_3POSE_SHEET.png")
 seq=(0,1,2,1)
 frames=[output[i] for i in seq]
 frames[0].save(args.out_dir/"WAITING_LEFT_MID_RIGHT_MID.gif",save_all=True,
  append_images=frames[1:],duration=[175]*4,loop=0,disposal=2,optimize=False)
 info.update({"action":"Waiting","source_sha256":sha256(args.target_png.read_bytes()).hexdigest(),
 "frame_order":list(seq),"generated_using":"A63 W3B empirical original actor01 lateral pixel motion",
 "no_PixelLab_usage":True,"art_approval":"PENDING"} )
 (args.out_dir/"WAITING_REUSE_QA.json").write_text(json.dumps(info,indent=2,ensure_ascii=False),encoding="utf8")
 print("A63_WAITING_OFFLINE_PIXEL_REUSE_PASS",json.dumps(info,ensure_ascii=False),flush=True)
