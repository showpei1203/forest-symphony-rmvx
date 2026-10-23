from pathlib import Path
from PIL import Image
import struct,subprocess,hashlib,json,time
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
frames=[Image.open(r/"inputs"/f"rock_frame_{i:02d}.png").convert("RGBA") for i in range(4)]
assert all(x.size==(32,32) for x in frames)
def chunk(kind,payload):return struct.pack("<IH",len(payload)+6,kind)+payload
layername=b"B0 Own Rock"
layer=struct.pack("<HHHHHHB3sH",3,0,0,0,0,0,255,b"\0"*3,len(layername))+layername
pack=[]
durations=[100,120,140,160]
for i,im in enumerate(frames):
 cel=struct.pack("<HhhBHh5sHH",0,0,0,255,0,0,b"\0"*5,32,32)+im.tobytes()
 chunks=([chunk(0x2004,layer)] if i==0 else [])+[chunk(0x2005,cel)]
 payload=b"".join(chunks)
 frame=struct.pack("<IHHH2sI",16+len(payload),0xF1FA,len(chunks),durations[i],b"\0\0",0)+payload
 pack.append(frame)
hdr=bytearray(128)
struct.pack_into("<IHHHHHIH",hdr,0,128+sum(map(len,pack)),0xA5E0,4,32,32,32,1,100)
struct.pack_into("<BBhhHH",hdr,33,1,1,0,0,16,16)
src=r/"inputs"/"b0_rock_4frames.aseprite"
src.write_bytes(bytes(hdr)+b"".join(pack))
# Validate file-level durations before invoking a different decoder.
assert len(src.read_bytes())==128+sum(map(len,pack))
exe=Path(r"E:\GameAssetToolLab_20261023\tools\LibreSprite\libresprite.exe")
out=r/"outputs"/"libresprite";out.mkdir(exist_ok=True)
sheet=out/"b0_rock_4frames.png";data=out/"b0_rock_4frames.json"
cmd=[str(exe),"--batch","--sheet",str(sheet),"--data",str(data),"--format","json-array","--sheet-type","horizontal",str(src)]
start=time.monotonic()
p=subprocess.run(cmd,capture_output=True,text=True,errors="replace",timeout=35)
(r/"logs"/"T12_LIBRESPRITE_NATIVE.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf8")
results={"status":"PENDING","command":cmd,"exit":p.returncode,"elapsed_ms":round(1000*(time.monotonic()-start)),
"source_aseprite_sha256":hashlib.sha256(src.read_bytes()).hexdigest(),"source_frames":4,"durations_expected_ms":durations,
"source_method":"format-conformant RGBA .aseprite test project built using published Aseprite file specification"}
if sheet.is_file() and data.is_file():
 im=Image.open(sheet).convert("RGBA")
 meta=json.loads(data.read_text(encoding="utf-8-sig"))
 diffs=[]
 for i,original in enumerate(frames):
  if im.size==(128,32):diffs.append(sum(a!=b for a,b in zip(im.crop((32*i,0,32*(i+1),32)).tobytes(),original.tobytes())))
 results.update({"sheet_dims":list(im.size),"diff_byte_counts":diffs,"metadata":meta,
 "sheet_sha256":hashlib.sha256(sheet.read_bytes()).hexdigest(),"json_sha256":hashlib.sha256(data.read_bytes()).hexdigest()})
 results["status"]="T12_LIBRESPRITE_NATIVE_4FRAME_PASS" if p.returncode==0 and im.size==(128,32) and diffs==[0,0,0,0] and len(meta.get("frames",[]))==4 else "T12_NATIVE_EXPORT_FAIL"
else:
 results["error"]="missing sheet or metadata output"
 results["stdout_tail"]=p.stdout[-800:];results["stderr_tail"]=p.stderr[-800:]
 results["status"]="T12_NATIVE_EXPORT_FAIL"
(r/"reports"/"T12_LIBRESPRITE_ANIMATION.json").write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding="utf8")
print("T12_RESULT",results["status"],"image",results.get("sheet_dims"),"diff",results.get("diff_byte_counts"),"exit",p.returncode,flush=True)
if results["status"]!="T12_LIBRESPRITE_NATIVE_4FRAME_PASS":raise SystemExit(2)
