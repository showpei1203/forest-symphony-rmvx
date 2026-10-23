from pathlib import Path
from PIL import Image
import hashlib,subprocess,time,json,sys
ROOT=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
INPUT=ROOT/"inputs"
OUT=ROOT/"outputs"/"sprite_normals";OUT.mkdir(exist_ok=True,parents=True)
TOOL=ROOT.parent/"tools"/"SpriteNormalsSource"/"spritefusion-sprite-normals-main"/"target"/"release"/"spritefusion-sprite-normals.exe"
assert TOOL.exists()
def run(tag,args):
 t=time.perf_counter()
 p=subprocess.run([str(TOOL),*list(map(str,args))],capture_output=True,text=True,errors="replace",timeout=60)
 row={"tag":tag,"argv":[str(TOOL),*map(str,args)],"exit":p.returncode,"ms":round(1000*(time.perf_counter()-t)),"stdout":p.stdout[-400:],"stderr":p.stderr[-400:]}
 commands.append(row)
 print(tag,p.returncode,flush=True)
 assert p.returncode==0,row
def image(p):return Image.open(p).convert("RGBA")
def canon(im):
 z=im.copy();pix=z.load()
 for yy in range(z.height):
  for xx in range(z.width):
   if pix[xx,yy][3]==0:pix[xx,yy]=(0,0,0,0)
 return z
commands=[]
run("B0_5_objects_OpenGL",[INPUT/(n+".png") for n in ("tree","rock","sign","cliff_face","stair_face")]+["--output-dir",OUT,"--normal-format","opengl","--force"])
run("B0_6_frame_sheet_OpenGL",[INPUT/"tree_animation_6frames.png","--output-dir",OUT,"--frame-size","64x96","--normal-format","opengl","--force"])
for i in range(6):
 run(f"B0_individual_frame_{i}",[INPUT/(f"tree_frame_{i:02d}.png"),"-o",OUT/(f"frame_{i:02d}_n.png"),"--normal-format","opengl","--force"])
run("B0_tree_DirectX",[INPUT/"tree.png","-o",OUT/"tree_directx.png","--normal-format","directx","--force"])
results=[]
for n in ("tree","rock","sign","cliff_face","stair_face","tree_animation_6frames"):
 p=INPUT/(n+".png");q=OUT/(n+"_n.png")
 a,b=image(p),image(q)
 report={"name":n,"size":list(b.size),"size_match":a.size==b.size,
 "alpha_exact":a.getchannel("A").tobytes()==b.getchannel("A").tobytes(),
 "normal_rgb_nonflat":len(set((c[0],c[1],c[2]) for c in b.getdata() if c[3]>0))>3,
 "source_sha":hashlib.sha256(p.read_bytes()).hexdigest(),"normal_sha":hashlib.sha256(q.read_bytes()).hexdigest()}
 results.append(report)
actual=canon(image(OUT/"tree_animation_6frames_n.png"))
separate=Image.new("RGBA",actual.size,(0,0,0,0))
for i in range(6):
 c=canon(image(OUT/(f"frame_{i:02d}_n.png")))
 separate.paste(c,(i*64,0))
single=canon(separate)
diff=sum(1 for a,b in zip(actual.getdata(),single.getdata()) if a!=b)
a=image(OUT/"tree_n.png");b=image(OUT/"tree_directx.png")
dx={"alpha_exact":a.getchannel("A").tobytes()==b.getchannel("A").tobytes(),
    "red_blue_equal":all((x[0],x[2])==(y[0],y[2]) for x,y in zip(a.getdata(),b.getdata())),
    "green_opposite":sum(1 for x,y in zip(a.getdata(),b.getdata()) if x[3]>0 and abs(x[1]+y[1]-255)<=1),
    "visible_count":sum(1 for x in a.getdata() if x[3]>0),
    "wrong_normal_format_negative_test":"FAIL_EXPECTED_DIFFERENCE" if canon(a).tobytes()!=canon(b).tobytes() else "DID_NOT_DETECT"}
result={"status":"T09_B0_SPRITENORMALS_EXTENDED_PASS" if all(z["size_match"] and z["alpha_exact"] and z["normal_rgb_nonflat"] for z in results) and diff==0 and dx["alpha_exact"] and dx["red_blue_equal"] and dx["green_opposite"]==dx["visible_count"] and dx["wrong_normal_format_negative_test"]=="FAIL_EXPECTED_DIFFERENCE" else "T09_FAIL_CLOSED",
 "results":results,"6_frame_visible_canonical_diff":diff,"format_conversion":dx,"runs":commands,
 "exe_sha":hashlib.sha256(TOOL.read_bytes()).hexdigest(),
 "rights":"project-owned B0 technical sprites; no Hanzo source"}
(ROOT/"reports"/"T09_SPRITENORMALS_B0_ANIMATION.json").write_text(json.dumps(result,indent=2),encoding="utf8")
print("T09",result["status"],"sheet_frame_diff",diff,"normal_diff_pixels",dx["visible_count"],flush=True)
if result["status"]!="T09_B0_SPRITENORMALS_EXTENDED_PASS":sys.exit(2)
