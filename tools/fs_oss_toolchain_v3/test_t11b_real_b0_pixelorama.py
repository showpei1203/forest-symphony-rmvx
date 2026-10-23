from pathlib import Path
from PIL import Image
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib,io,subprocess,time,sys
ROOT=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
TEMPLATE=ROOT.parent/"ToolValidation_v2_20261023"/"pixelorama"/"animated_6_unique_test.pxo"
OUT=ROOT/"outputs"/"pixelorama"/"b0_tree_distinct";OUT.mkdir(parents=True,exist_ok=True)
PNG=OUT/"b0_tree_6.png"
PXO=ROOT/"inputs"/"pixelorama"/"b0_tree_six_unique.pxo"
TOOL=ROOT.parent/"tools"/"Pixelorama"/"Pixelorama-Windows-64bit"/"Pixelorama.exe"
frames=[Image.open(ROOT/"inputs"/f"tree_frame_{i:02d}.png").convert("RGBA") for i in range(6)]
assert all(im.size==(64,96) for im in frames)
data=None
with ZipFile(TEMPLATE) as original,ZipFile(PXO,"w",ZIP_DEFLATED,compresslevel=6) as dest:
 for obj in original.infolist():
  raw=original.read(obj.filename)
  if obj.filename=="data.json":
   data=json.loads(raw)
   data["size_x"]=64;data["size_y"]=96
   data["tile_mode_x_basis_x"]=64;data["tile_mode_y_basis_y"]=96
   data["symmetry_points"]="[63.0, 95.0]"
   data["author_company"]="Forest Symphony independent test asset"
   data["author_display_name"]="B0 pipeline"
   data["license"]="PROJECT_OWNED_TEST_DATA"
   data["export_profile"]["directory_path"]=json.dumps(OUT.as_posix())
   data["export_profile"]["file_name"]=json.dumps("b0_tree_6")
   data["export_profile"]["number_of_frames"]="6"
   raw=json.dumps(data,ensure_ascii=False,separators=(",",":")).encode("utf8")
  elif obj.filename=="preview.png":
   f=io.BytesIO();frames[0].save(f,format="PNG");raw=f.getvalue()
  else:
   for i in range(6):
    if obj.filename==f"image_data/frames/{i+1}/layer_1":
     raw=frames[i].tobytes()
  dest.writestr(obj.filename,raw)
args=[str(TOOL),"--headless","--quit","--","--spritesheet","--export",str(PXO)]
start=time.perf_counter()
p=subprocess.run(args,capture_output=True,text=True,errors="replace",timeout=25)
log=p.stdout+"\n"+p.stderr
(ROOT/"reports"/"T11B_REAL_SPRITE_PXO.log").write_text(log,encoding="utf8")
report={"source":"B0 six distinct tree PNG frames (64x96), true .pxo native project","input_sha256":[hashlib.sha256((ROOT/"inputs"/f"tree_frame_{i:02d}.png").read_bytes()).hexdigest() for i in range(6)],
"project_sha256":hashlib.sha256(PXO.read_bytes()).hexdigest(),"cmd":args,"exit":p.returncode,"ms":round((time.perf_counter()-start)*1000)}
if PNG.is_file():
 out=Image.open(PNG).convert("RGBA")
 report["export_size"]=list(out.size)
 report["output_sha256"]=hashlib.sha256(PNG.read_bytes()).hexdigest()
 if out.size==(384,96):
  parts=[out.crop((64*i,0,64*(i+1),96)) for i in range(6)]
  report["unique_frames"]=len({x.tobytes() for x in parts})
  report["pixel_exact_6_of_6"]=[parts[i].tobytes()==frames[i].tobytes() for i in range(6)]
ok=p.returncode==0 and report.get("unique_frames")==6 and all(report.get("pixel_exact_6_of_6",[]))
report["status"]="T11B_PXO_REAL_B0_SIXFRAME_PASS" if ok else "T11B_PXO_FAIL_CLOSED"
(ROOT/"reports"/"T11B_PIXELORAMA_REAL_B0_ANIMATION.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("T11B",report["status"],"image",report.get("export_size"),"unique",report.get("unique_frames"),"exact",report.get("pixel_exact_6_of_6"),"exit",p.returncode,flush=True)
if not ok:print(log[-1600:]);sys.exit(2)
