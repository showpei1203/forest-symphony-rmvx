from pathlib import Path
from PIL import Image
import zipfile,json,subprocess,hashlib,time
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
src=r/"pixelorama"/"animated_no_effects.pxo"
dst=r/"pixelorama"/"animated_6_unique_test.pxo"
folder=r/"outputs"/"pixelorama_animated_unique";folder.mkdir(parents=True,exist_ok=True)
colors=[(240,20,30,255),(235,135,10,255),(235,220,15,255),(20,240,35,255),(25,135,245,255),(220,20,215,255)]
with zipfile.ZipFile(src) as original,zipfile.ZipFile(dst,"w") as target:
 for item in original.infolist():
  buf=original.read(item.filename)
  if item.filename=="data.json":
   meta=json.loads(buf)
   meta["export_profile"]["directory_path"]=json.dumps(str(folder).replace("\\","/"))
   meta["export_profile"]["file_name"]=json.dumps("six_unique_frames")
   buf=json.dumps(meta,separators=(",",":"),ensure_ascii=False).encode("utf8")
  else:
   for k in range(1,7):
    if item.filename==f"image_data/frames/{k}/layer_1":
     assert len(buf)==64*64*4
     raw=bytearray(buf)
     for yy in range(4,8):
      for xx in range(4,8):
       z=(yy*64+xx)*4
       raw[z:z+4]=bytes(colors[k-1])
     buf=bytes(raw)
  target.writestr(item,buf)
exe=r.parent/"tools"/"Pixelorama"/"Pixelorama-Windows-64bit"/"Pixelorama.exe"
p=subprocess.run([str(exe),"--headless","--quit","--","--spritesheet","--export",str(dst)],capture_output=True,text=True,errors="replace",timeout=45)
(r/"logs"/"T03_UNIQUE_FRAME_EXPORT.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf8")
outputs=list(folder.glob("*.png"))
outcome=[]
for f in outputs:
 im=Image.open(f).convert("RGBA")
 frame_colors=[im.getpixel((i*64+5,5)) for i in range(6)] if im.size==(384,64) else []
 distinct=len({im.crop((i*64,0,(i+1)*64,64)).tobytes() for i in range(6)}) if im.size==(384,64) else 0
 outcome.append({"file":f.name,"dimensions":im.size,"unique_frames":distinct,"marker_colors":frame_colors,"marker_exact":frame_colors==colors,"sha256":hashlib.sha256(f.read_bytes()).hexdigest()})
passed=p.returncode==0 and any(x["unique_frames"]==6 and x["marker_exact"] for x in outcome)
result={"tool":"Pixelorama 1.2.3","status":"SIX_UNIQUE_FRAME_SHEET_PASS" if passed else "FAIL","frames":6,"method":"modified raw 64x64 RGBA per-frame cels in official six-frame PXO; stripped shader-only layer effects; exported with -s -e and preset profile; no --output","cli_exit":p.returncode,"outputs":outcome,"test_project":str(dst)}
(r/"reports"/"T03_PIXELORAMA_SIX_UNIQUE_FRAMES.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("T03_UNIQUE_FRAMES",result["status"],outcome,flush=True)
if not passed:raise SystemExit(2)
