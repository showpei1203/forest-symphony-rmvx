from pathlib import Path
from PIL import Image
import struct,zlib,json,hashlib,subprocess,time,sys
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
out=R/"outputs"/"libresprite";out.mkdir(parents=True,exist_ok=True)
exe=R.parent/"tools"/"LibreSprite"/"libresprite.exe"
frames=[Image.open(R/"inputs"/f"tree_frame_{i:02d}.png").convert("RGBA") for i in range(6)]
assert all(i.size==(64,96) for i in frames)
durations=[70,90,110,130,150,170]
def shortstr(s):
 b=s.encode("utf8");return struct.pack("<H",len(b))+b
def chunk(typ,data):
 return struct.pack("<IH",len(data)+6,typ)+data
def frame_chunk(i):
 chunks=[]
 if i==0:
  layer=struct.pack("<HHHHHHB3s",1,0,0,0,0,0,255,b"\0"*3)+shortstr("Main")
  chunks.append(chunk(0x2004,layer))
  # Aseprite animation tags chunk; loop six frames, direction forward.
  tag=struct.pack("<H",1)+b"\0"*8
  tag+=struct.pack("<HHB",0,5,0)+struct.pack("<H",0)+b"\0"*6+bytes([58,189,116,0])+shortstr("idle")
  chunks.append(chunk(0x2018,tag))
 pixels=frames[i].tobytes()
 cel=struct.pack("<HhhBH",0,0,0,255,2)+b"\0"*7+struct.pack("<HH",64,96)+zlib.compress(pixels,9)
 chunks.append(chunk(0x2005,cel))
 data=b"".join(chunks)
 return struct.pack("<IHHH2sI",16+len(data),0xF1FA,len(chunks),durations[i],b"\0\0",0)+data
payload=b"".join(frame_chunk(i) for i in range(6))
header=bytearray(128)
struct.pack_into("<IHHHHH",header,0,128+len(payload),0xA5E0,6,64,96,32)
struct.pack_into("<I",header,14,1)
struct.pack_into("<H",header,18,100)
struct.pack_into("<H",header,32,0)
header[34]=1;header[35]=1
struct.pack_into("<HH",header,40,16,16)
ase=R/"inputs"/"libresprite"/"tree_6frame_native.ase"
ase.parent.mkdir(exist_ok=True)
ase.write_bytes(bytes(header)+payload)
cmd=[str(exe),"-b","--list-tags","--sheet-type","horizontal","--data",str(out/"T12_6FRAME.json"),"--sheet",str(out/"T12_6FRAME.png"),str(ase)]
start=time.perf_counter()
run=subprocess.run(cmd,capture_output=True,text=True,errors="replace",timeout=25)
logs=run.stdout+"\n"+run.stderr
(R/"reports"/"T12_LIBRESPRITE_NATIVE.log").write_text(logs,encoding="utf8")
print("T12_NATIVE_CLI",run.returncode,"time_ms",int((time.perf_counter()-start)*1000),"exists",[(x.name,x.exists()) for x in [out/"T12_6FRAME.json",out/"T12_6FRAME.png"]],flush=True)
if run.returncode!=0 or not (out/"T12_6FRAME.json").exists():print(logs[-2000:]);sys.exit(2)
data=json.loads((out/"T12_6FRAME.json").read_text(encoding="utf8"))
print("T12_JSON_KEYS",list(data),"META",str(data.get("meta"))[:450],flush=True)
entries=list(data["frames"].values()) if isinstance(data["frames"],dict) else data["frames"]
sheet=Image.open(out/"T12_6FRAME.png").convert("RGBA")
actual=[]
for row in entries:
 rec=row["frame"];a=sheet.crop((rec["x"],rec["y"],rec["x"]+rec["w"],rec["y"]+rec["h"]))
 actual.append(a.tobytes())
assert len(actual)==6,(len(actual),data)
rgba_ok=[actual[i]==frames[i].tobytes() for i in range(6)]
duration_out=[int(v["duration"]) for v in entries]
tags=data["meta"].get("frameTags",[])
result={"status":"T12_NATIVE_ASE_SIXFRAME_PASS" if all(rgba_ok) and duration_out==durations and sheet.size==(384,96) else "T12_FAIL_CLOSED",
 "source":"native authored ASE 6 real distinct frames, not one PNG auto-inferred",
 "native_ase_sha256":hashlib.sha256(ase.read_bytes()).hexdigest(),
 "libresprite_exe_sha256":hashlib.sha256(exe.read_bytes()).hexdigest(),
 "input_frames_sha256":[hashlib.sha256(v.tobytes()).hexdigest() for v in frames],
 "sheet_sha256":hashlib.sha256((out/"T12_6FRAME.png").read_bytes()).hexdigest(),
 "sheet_size":list(sheet.size),"frame_count":len(entries),"frames_rgba_exact":rgba_ok,
 "durations_expected":durations,"durations_exported":duration_out,"tags_exported":tags,
 "log":str(R/"reports"/"T12_LIBRESPRITE_NATIVE.log"),"command":cmd,"exit":run.returncode}
(R/"reports"/"T12_LIBRESPRITE_NATIVE_METADATA.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("T12_RESULT",result["status"],"frames",result["frame_count"],"durations",duration_out,"tags",tags,flush=True)
if result["status"]!="T12_NATIVE_ASE_SIXFRAME_PASS":sys.exit(2)
