from pathlib import Path
import struct,zlib,hashlib,json,subprocess,time,sys
from PIL import Image
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
TOOL=R.parent/"tools"/"LibreSprite"/"libresprite.exe"
SRC=R/"inputs";DST=R/"outputs"/"libresprite_native";DST.mkdir(exist_ok=True,parents=True)
W,H=64,96
durations=[80,95,110,125,100,70]
def chunk(kind,body):return struct.pack("<IH",len(body)+6,kind)+body
def utf8(s):
 b=s.encode("utf8")
 return struct.pack("<H",len(b))+b
# Single transparent editable image layer, one distinct RGBA cel per frame.
layer=struct.pack("<HHHHHHB",3,0,0,0,0,0,255)+bytes(3)+utf8("B0 Animated Tree")
tag=struct.pack("<H",1)+bytes(8)+struct.pack("<HHBH",0,5,0,0)+bytes(6)+bytes((132,211,97,0))+utf8("idle_sway")
frames=[]
for i in range(6):
 im=Image.open(SRC/(f"tree_frame_{i:02d}.png")).convert("RGBA")
 assert im.size==(W,H)
 data=struct.pack("<HhhBHh",0,0,0,255,2,0)+bytes(5)+struct.pack("<HH",W,H)+zlib.compress(im.tobytes(),9)
 components=[]
 if i==0:components=[chunk(0x2004,layer),chunk(0x2018,tag)]
 components.append(chunk(0x2005,data))
 payload=b"".join(components)
 frames.append(struct.pack("<IHHH",len(payload)+16,0xF1FA,len(components),durations[i])+bytes(2)+struct.pack("<I",len(components))+payload)
header=bytearray(128)
packed=b"".join(frames)
struct.pack_into("<IHHHHHIH",header,0,128+len(packed),0xA5E0,6,W,H,32,1,100)
header[34]=1;header[35]=1
ase=SRC/"B0_TREE_6FRAME_EDITABLE.ase"
ase.write_bytes(bytes(header)+packed)
assert len(ase.read_bytes())==128+sum(len(fr) for fr in frames)
cmd=[str(TOOL),"-b","--list-tags","--sheet-type","horizontal","--format","json-array",
"--sheet",str(DST/"tree_six_native.png"),"--data",str(DST/"tree_six_native.json"),str(ase)]
t=time.perf_counter()
p=subprocess.run(cmd,capture_output=True,text=True,errors="replace",timeout=55)
(R/"reports"/"T12_LIBRESPRITE_RUN.log").write_text(p.stdout+"\n"+p.stderr,encoding="utf8")
j={"tool":"LibreSprite 1.3","source":str(ase),"source_sha":hashlib.sha256(ase.read_bytes()).hexdigest(),
"command":cmd,"exit":p.returncode,"duration_ms":round(1000*(time.perf_counter()-t)),"stdout":p.stdout[-1200:],"stderr":p.stderr[-1200:],
"expected_frame_durations_ms":durations,"expected_tag":"idle_sway"}
sheet=DST/"tree_six_native.png";metadata=DST/"tree_six_native.json"
if sheet.exists():
 im=Image.open(sheet).convert("RGBA")
 j["sheet_size"]=im.size
 j["sheet_sha"]=hashlib.sha256(sheet.read_bytes()).hexdigest()
 j["frame_pixel_diffs"]=[]
 if im.size==(W*6,H):
  for i in range(6):
   expect=Image.open(SRC/(f"tree_frame_{i:02d}.png")).convert("RGBA")
   frame=im.crop((i*W,0,(i+1)*W,H))
   j["frame_pixel_diffs"].append(sum(a!=b for a,b in zip(frame.getdata(),expect.getdata())))
if metadata.exists():
 try:j["metadata"]=json.loads(metadata.read_text(encoding="utf-8-sig"))
 except Exception as e:j["metadata_error"]=str(e)
 j["metadata_sha"]=hashlib.sha256(metadata.read_bytes()).hexdigest()
dur=[]
for frame in j.get("metadata",{}).get("frames",[]) if isinstance(j.get("metadata",{}),dict) else (j.get("metadata",[]) if isinstance(j.get("metadata"),list) else []):
 if isinstance(frame,dict):dur.append(frame.get("duration"))
j["export_durations"]=dur
def tags(meta):
 if isinstance(meta,dict):return meta.get("meta",{}).get("frameTags",[])
 return []
j["export_tags"]=tags(j.get("metadata",{}))
j["status"]="T12_LIBRESPRITE_NATIVE_ASE_6FRAME_PASS" if p.returncode==0 and j.get("sheet_size")== (W*6,H) and j.get("frame_pixel_diffs")==[0]*6 and dur==durations else "T12_NATIVE_ASE_FAIL_CLOSED"
(R/"reports"/"T12_LIBRESPRITE_NATIVE_ANIMATION.json").write_text(json.dumps(j,ensure_ascii=False,indent=2,default=list),encoding="utf8")
print("T12",j["status"],"size",j.get("sheet_size"),"pixels",j.get("frame_pixel_diffs"),"durations",dur,"tags",j["export_tags"],flush=True)
if j["status"]!="T12_LIBRESPRITE_NATIVE_ASE_6FRAME_PASS":sys.exit(2)
