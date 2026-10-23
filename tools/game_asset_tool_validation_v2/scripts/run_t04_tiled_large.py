from pathlib import Path
from PIL import Image
from xml.etree.ElementTree import Element,SubElement,ElementTree,indent
import json,hashlib,time,subprocess
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
fs=r.parent/"FS_ForestSplit_v3_2"
tiled=r.parent/"tools"/"Tiled"/"tmxrasterizer.exe"
manifest=json.loads((fs/"scene_manifest.json").read_text(encoding="utf8"))
base_w,base_h=544,416
w,h=base_w*2,base_h*2
ground=Image.open(fs/"build"/"FS_FOREST_V32_Ground.png").convert("RGBA")
master=Image.open(fs/"build"/"FS_FOREST_V32_Master_FromScene.png").convert("RGBA")
new_g=Image.new("RGBA",(w,h));expected=Image.new("RGBA",(w,h))
for qy in range(2):
 for qx in range(2):
  new_g.alpha_composite(ground,(qx*base_w,qy*base_h))
  expected.alpha_composite(master,(qx*base_w,qy*base_h))
ground_path=r/"outputs"/"T04_GROUND_1088x832.png";new_g.save(ground_path)
names=list(manifest["asset_specs"])
def write_map(output_path,tamper=False):
 m=Element("map",{"version":"1.10","tiledversion":"1.12.2","orientation":"orthogonal","renderorder":"right-down","width":str(w//32),"height":str(h//32),"tilewidth":"32","tileheight":"32","infinite":"0","nextlayerid":"3","nextobjectid":"25"})
 ts=SubElement(m,"tileset",{"firstgid":"1","name":"CANONICAL_SOURCES","tilewidth":"64","tileheight":"64","tilecount":str(len(names)),"columns":"0"})
 for i,name in enumerate(names):
  im=Image.open(fs/"sources"/(name+".png"))
  tile=SubElement(ts,"tile",{"id":str(i),"type":name})
  SubElement(tile,"image",{"source":"../sources/"+name+".png","width":str(im.width),"height":str(im.height)})
 gl=SubElement(m,"imagelayer",{"id":"1","name":"CANONICAL_GROUND"})
 SubElement(gl,"image",{"source":"../../ToolValidation_v2_20261023/outputs/T04_GROUND_1088x832.png","width":str(w),"height":str(h)})
 group=SubElement(m,"objectgroup",{"id":"2","name":"COMPLETE_PAR_ORDERED","draworder":"index"})
 k=1
 for qy in range(2):
  for qx in range(2):
   for obj in sorted(manifest["instances"],key=lambda x:x["z_order"]):
    im=Image.open(fs/"sources"/(obj["asset_id"]+".png"))
    x=obj["x"]+qx*base_w
    if tamper and qy==1 and qx==1 and obj["instance_id"]=="sign_01":x+=1
    y=obj["y"]+qy*base_h
    SubElement(group,"object",{"id":str(k),"name":f'{obj["instance_id"]}_q{qx}{qy}',"gid":str(names.index(obj["asset_id"])+1),"x":str(x),"y":str(y+im.height),"width":str(im.width),"height":str(im.height)})
    k+=1
 indent(m);ElementTree(m).write(output_path,encoding="utf8",xml_declaration=True)
 return k-1
def render(path,out):
 start=time.perf_counter()
 p=subprocess.run([str(tiled),str(path),str(out)],capture_output=True,text=True,errors="replace",timeout=50)
 return {"rc":p.returncode,"elapsed_ms":round((time.perf_counter()-start)*1000),"stderr":p.stderr[-900:],"stdout":p.stdout[-900:]}
def delta(img):
 if not img.exists():return {"exists":False}
 a=Image.open(img).convert("RGBA")
 # numpy not installed: RGBA exact and difference count across all bytes
 a_bytes=a.tobytes();b_bytes=expected.tobytes()
 return {"dims":a.size,"pixel_rgba_equal":a_bytes==b_bytes,
         "different_pixels":sum(1 for i in range(0,min(len(a_bytes),len(b_bytes)),4) if a_bytes[i:i+4]!=b_bytes[i:i+4]) if a.size==expected.size else -1}
goodmap=fs/"work"/"T04_scaled_1088x832.tmx"
badmap=fs/"work"/"T04_injected_sign_1px.tmx"
object_count=write_map(goodmap)
write_map(badmap,True)
goodoutput=r/"outputs"/"T04_TILED_RENDER_1088x832.png"
badoutput=r/"outputs"/"T04_TILED_RENDER_SHIFTED_SIGN.png"
goodrun=render(goodmap,goodoutput)
badrun=render(badmap,badoutput)
good=delta(goodoutput);bad=delta(badoutput)
ok=good.get("pixel_rgba_equal") and bad.get("different_pixels",0)>0 and goodrun["rc"]==0 and badrun["rc"]==0 and object_count==24
rep={"tool":"Tiled 1.12.2","status":"SMOKE_PASS" if ok else "FAIL","canvas":[w,h],"objects":object_count,"good":{"run":goodrun,"diff":good},"injected":{"run":badrun,"diff":bad},"original_scene_manifest":str(fs/"scene_manifest.json")}
(r/"reports"/"T04_TILED_LARGE_AND_NEGATIVE.json").write_text(json.dumps(rep,ensure_ascii=False,indent=2),encoding="utf8")
print("T04_TILED",rep["status"],"canvas",w,h,"instances",object_count,"good",good,"injected",bad,flush=True)
if not ok:raise SystemExit(2)
