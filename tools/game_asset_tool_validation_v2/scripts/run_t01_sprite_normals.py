from pathlib import Path
from shutil import copy2
from PIL import Image
import subprocess,hashlib,json,time
root=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
lab=root.parent
exe=lab/"tools"/"SpriteNormalsSource"/"spritefusion-sprite-normals-main"/"target"/"release"/"spritefusion-sprite-normals.exe"
srcs=root/"inputs"/"sprite_normals";srcs.mkdir(parents=True,exist_ok=True)
out=root/"outputs"/"sprite_normals";out.mkdir(parents=True,exist_ok=True)
for p in (lab/"benchmarks"/"monster_sheet_4frames.png",lab/"FS_ForestSplit_v3_2"/"sources"/"tree_A.png",lab/"FS_ForestSplit_v3_2"/"sources"/"tree_B.png"):
 copy2(p,srcs/p.name)
sheet=Image.open(srcs/"monster_sheet_4frames.png").convert("RGBA")
for i in range(4):sheet.crop((32*i,0,32*(i+1),32)).save(srcs/(f"frame_{i:02d}.png"))
runs=[]
def run(tag,args):
 t=time.perf_counter();p=subprocess.run([str(exe),*map(str,args)],capture_output=True,text=True,errors="replace",timeout=25)
 x={"tag":tag,"cmd":list(map(str,args)),"exit":p.returncode,"elapsed_ms":round((time.perf_counter()-t)*1000),"stdout":p.stdout[-900:],"stderr":p.stderr[-900:]}
 runs.append(x);print("RUN",tag,p.returncode,x["elapsed_ms"],flush=True)
 return p.returncode==0
good1=run("sheet_4frame",[srcs/"monster_sheet_4frames.png","--output-dir",out,"--frame-size","32x32","--normal-format","opengl","--force"])
good2=run("2tree_batch",[srcs/"tree_A.png",srcs/"tree_B.png","--output-dir",out,"--normal-format","opengl","--force"])
for i in range(4):
 run(f"frame_{i:02d}",[srcs/(f"frame_{i:02d}.png"),"-o",out/(f"frame_{i:02d}_n.png"),"--normal-format","opengl","--force"])
entries=[]
for p in [srcs/"monster_sheet_4frames.png",srcs/"tree_A.png",srcs/"tree_B.png",*(srcs/(f"frame_{i:02d}.png") for i in range(4))]:
 target=out/(p.stem+"_n.png")
 e={"name":p.name,"exists":target.exists()}
 if target.exists():
  a=Image.open(p).convert("RGBA");b=Image.open(target).convert("RGBA")
  e.update({"dims":b.size,"size_match":a.size==b.size,"alpha_match":a.getchannel("A").tobytes()==b.getchannel("A").tobytes(),
            "normal_rgb_varies":len(set(b.convert("RGB").getdata()))>1,
            "normal_map_sha256":hashlib.sha256(target.read_bytes()).hexdigest()})
 entries.append(e)
assembled=Image.new("RGBA",(128,32))
for i in range(4):
 f=Image.open(out/(f"frame_{i:02d}_n.png")).convert("RGBA")
 assembled.alpha_composite(f,(i*32,0))
actual=Image.open(out/"monster_sheet_4frames_n.png").convert("RGBA")
# Different RGB under fully transparent pixels is visually irrelevant and must be normalized for sprite-normal comparisons.
raw_sheet_equal = assembled.tobytes()==actual.tobytes()
raw_different_pixels = sum(1 for a,b in zip(actual.getdata(),assembled.getdata()) if a!=b)
visible_different_pixels = sum(1 for a,b in zip(actual.getdata(),assembled.getdata()) if a[3]>0 and a!=b)
def canonical(im):
 out=im.copy();p=out.load()
 for yy in range(out.height):
  for xx in range(out.width):
   if p[xx,yy][3]==0:p[xx,yy]=(0,0,0,0)
 return out
sheet_cell_exact=canonical(assembled).tobytes()==canonical(actual).tobytes()

pass1=good1 and good2 and all(z["exit"]==0 for z in runs) and all(e.get("size_match",False) and e.get("alpha_match",False) and e.get("normal_rgb_varies",False) for e in entries) and sheet_cell_exact
rep={"tool":"Sprite Fusion Sprite Normals v0.1.0","rust":"portable stable-msvc 1.99.1","exe":str(exe),"exe_sha256":hashlib.sha256(exe.read_bytes()).hexdigest(),
 "status":"CLI_SMOKE_PASS" if pass1 else "FAIL","frames":4,"sheet_cells_equal_per_frame_normals_after_transparent_RGB_normalization":sheet_cell_exact,"raw_rgba_bytes_equal":raw_sheet_equal,"raw_diff_pixels":raw_different_pixels,"visible_diff_pixels":visible_different_pixels,"outputs":entries,"runs":runs,
 "note":"CLI native Rust compiler with Visual Studio vcvars64; outputs are optional material maps, not Ground/PAR masks. Visual style/normal direction still human review."}
(root/"reports"/"T01_SPRITE_NORMALS_NATIVE_CLI.json").write_text(json.dumps(rep,indent=2,ensure_ascii=False),encoding="utf8")
print("T01_SPRITE_NORMALS",rep["status"],"individual_outputs",len(entries),"sheets_exact",sheet_cell_exact,flush=True)
if not pass1:raise SystemExit(2)
