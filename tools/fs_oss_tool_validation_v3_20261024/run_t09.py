from pathlib import Path
from PIL import Image
import subprocess,hashlib,json,time
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
exe=Path(r"E:\GameAssetToolLab_20261023\tools\SpriteNormalsSource\spritefusion-sprite-normals-main\target\release\spritefusion-sprite-normals.exe")
assert exe.is_file()
inp=r/"inputs";out=r/"outputs"/"spritenormals"
out.mkdir(parents=True,exist_ok=True)
runs=[]
def run(name,arguments):
 cmd=[str(exe),*map(str,arguments)]
 t=time.monotonic();p=subprocess.run(cmd,capture_output=True,text=True,errors="replace",timeout=35)
 record={"name":name,"argv":cmd,"exit":p.returncode,"ms":round((time.monotonic()-t)*1000),
 "stdout":p.stdout[-300:],"stderr":p.stderr[-700:]}
 runs.append(record)
 print(name,"exit",p.returncode,flush=True)
 if p.returncode!=0:raise RuntimeError(name+" failed "+p.stderr[-450:])
for name in ["tree","rock","sign"]:
 run(name,[inp/(name+".png"),"-o",out/(name+"_n.png"),"--normal-format","opengl","--force"])
run("animation_sheet",[inp/"rock_animation_4x32.png","--output-dir",out,"--frame-size","32x32","--normal-format","opengl","--force"])
for i in range(4):
 run(f"rock_frame_{i:02d}",[inp/f"rock_frame_{i:02d}.png","-o",out/f"rock_frame_{i:02d}_n.png","--normal-format","opengl","--force"])
run("negative_shifted_sheet",[inp/"rock_animation_shifted_frame2.png","-o",out/"rock_animation_shifted_frame2_n.png","--frame-size","32x32","--normal-format","opengl","--force"])
def canonical(im):
 im=im.copy();p=im.load()
 for y in range(im.height):
  for x in range(im.width):
   if p[x,y][3]==0:p[x,y]=(0,0,0,0)
 return im
details={}
for name in ["tree","rock","sign"]:
 a=Image.open(inp/(name+".png")).convert("RGBA")
 b=Image.open(out/(name+"_n.png")).convert("RGBA")
 details[name]={"source_sha256":hashlib.sha256((inp/(name+".png")).read_bytes()).hexdigest(),
 "normal_sha256":hashlib.sha256((out/(name+"_n.png")).read_bytes()).hexdigest(),
 "source_size":list(a.size),"normal_size":list(b.size),"alpha_equal":a.getchannel("A").tobytes()==b.getchannel("A").tobytes(),
 "visible_rgb_variety":len({b.getpixel((x,y))[:3] for y in range(b.height) for x in range(b.width) if b.getpixel((x,y))[3]>0})}
assembled=Image.new("RGBA",(128,32))
for i in range(4):assembled.alpha_composite(Image.open(out/f"rock_frame_{i:02d}_n.png").convert("RGBA"),(32*i,0))
sheet=Image.open(out/"rock_animation_4x32_n.png").convert("RGBA")
negative=Image.open(out/"rock_animation_shifted_frame2_n.png").convert("RGBA")
source_sheet=Image.open(inp/"rock_animation_4x32.png").convert("RGBA")
clean_equal=canonical(assembled).tobytes()==canonical(sheet).tobytes()
negative_diff=sum(a!=b for a,b in zip(canonical(negative).getdata(),canonical(sheet).getdata()))
alpha_match=source_sheet.getchannel("A").tobytes()==sheet.getchannel("A").tobytes()
status="T09_SPRITENORMALS_B0_4FRAME_PASS" if all(e["alpha_equal"] and e["visible_rgb_variety"]>1 and e["source_size"]==e["normal_size"] for e in details.values()) and clean_equal and alpha_match and negative_diff>0 else "FAIL_CLOSED"
report={"status":status,"engine":"Sprite Fusion Sprite Normals Rust CLI","test":"real B0 owned tree/rock/sign and 4 frame animation",
 "license":"tool MIT / inputs owned procedural B0","binary_sha256":hashlib.sha256(exe.read_bytes()).hexdigest(),
 "details":details,"four_frames_sheet_equals_individual_after_transparent_canonicalization":clean_equal,
 "sheet_alpha_exact":alpha_match,"1px_frame2_negative_detected_pixels":negative_diff,"runs":runs}
(r/"reports"/"T09_SPRITENORMALS_B0.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf8")
print("T09_B0_TEST",status,"seam_negative_pixels",negative_diff,flush=True)
if status=="FAIL_CLOSED":raise SystemExit(2)
