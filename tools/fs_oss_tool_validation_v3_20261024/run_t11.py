from pathlib import Path
from PIL import Image
import zipfile,json,subprocess,hashlib,time
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
base=r/"inputs"/"animated_no_effects_private_test_template.pxo"
assert base.is_file()
dst=r/"inputs"/"b0_rock_6frames.pxo"
output=r/"outputs"/"pixelorama";output.mkdir(parents=True,exist_ok=True)
rock=Image.open(r/"inputs"/"rock.png").convert("RGBA")
assert rock.size==(32,24)
expected=[]
with zipfile.ZipFile(base) as z,zipfile.ZipFile(dst,"w") as target:
 meta=json.loads(z.read("data.json"))
 meta["export_profile"]["directory_path"]=json.dumps(str(output).replace("\\","/"))
 meta["export_profile"]["file_name"]=json.dumps("b0_rock_6frames")
 meta["export_profile"]["number_of_frames"]="6"
 meta["export_profile"]["orientation"]="0"
 for it in z.infolist():
  chunk=z.read(it.filename)
  if it.filename=="data.json":
   chunk=json.dumps(meta,ensure_ascii=False,separators=(",",":")).encode("utf8")
  else:
   for i in range(1,7):
    if it.filename==f"image_data/frames/{i}/layer_1":
     assert len(chunk)==64*64*4
     frame=Image.new("RGBA",(64,64))
     frame.alpha_composite(rock,(16,16+i))
     pixels=frame.load()
     # Per-frame authored test markers in the top-left, not optional upstream artwork.
     marker=(10*i,240-20*i,18*i,255)
     for y in range(3,7):
      for x in range(3,7):pixels[x,y]=marker
     expected.append({"frame":i-1,"marker":marker,"rock_anchor":[16,16+i]})
     chunk=frame.tobytes()
  target.writestr(it,chunk)
exe=Path(r"E:\GameAssetToolLab_20261023\tools\Pixelorama\Pixelorama-Windows-64bit\Pixelorama.exe")
cmd=[str(exe),"--headless","--quit","--","--spritesheet","--export",str(dst)]
started=time.monotonic();p=subprocess.run(cmd,capture_output=True,text=True,errors="replace",timeout=65)
(r/"logs"/"T11_PIXELORAMA_NATIVE.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf8")
sheet=output/"b0_rock_6frames.png"
details={"command":cmd,"exit":p.returncode,"ms":round(1000*(time.monotonic()-started)),
 "scaffold":"local clean Pixelorama official example PXO, shader effects already stripped; image cels layer_1 replaced with B0-owned rock pixels",
 "source_rock_sha256":hashlib.sha256((r/"inputs"/"rock.png").read_bytes()).hexdigest(),"pxo_sha256":hashlib.sha256(dst.read_bytes()).hexdigest(),"expected_frames":expected}
if sheet.exists():
 im=Image.open(sheet).convert("RGBA")
 details["output_sha256"]=hashlib.sha256(sheet.read_bytes()).hexdigest()
 details["size"]=list(im.size)
 details["marker_actual"]=[list(im.getpixel((64*i+4,4))) for i in range(6)] if im.size==(384,64) else []
 details["distinct_frames"]=len({im.crop((64*i,0,64*(i+1),64)).tobytes() for i in range(6)}) if im.size==(384,64) else 0
 details["markers_match"]=[tuple(z)==e["marker"] for z,e in zip(details["marker_actual"],expected)] if len(details["marker_actual"])==6 else []
else:details["error"]="no exported PNG"
passed=p.returncode==0 and details.get("size")==[384,64] and details.get("distinct_frames")==6 and all(details.get("markers_match",[])) and len(details.get("markers_match",[]))==6
details["status"]="T11_PIXELORAMA_B0_SIX_FRAMES_PASS_SHADER_FREE" if passed else "T11_FAIL_CLOSED"
(r/"reports"/"T11_PIXELORAMA_B0.json").write_text(json.dumps(details,ensure_ascii=False,indent=2),encoding="utf8")
print("T11_RESULT",details["status"],"markers",details.get("markers_match"),flush=True)
if not passed:raise SystemExit(2)
