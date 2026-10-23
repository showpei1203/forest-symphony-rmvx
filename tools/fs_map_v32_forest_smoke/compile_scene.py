from PIL import Image,ImageDraw,ImageChops
from pathlib import Path
from xml.etree.ElementTree import Element,SubElement,ElementTree,indent
import json,hashlib,math
ROOT=Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
S=ROOT/"sources"; B=ROOT/"build"; W=ROOT/"work"
B.mkdir(exist_ok=True);W.mkdir(exist_ok=True)
(B/"semantic_masks").mkdir(exist_ok=True)
manifest=json.loads((ROOT/"scene_manifest.json").read_text(encoding="utf8"))
width=manifest["canvas"]["width"];height=manifest["canvas"]["height"];tile=32
assert width==544 and height==416 and tile==32
grass=Image.open(S/"grass_tile.png").convert("RGBA")
dirt=Image.open(S/"path_tile.png").convert("RGBA")
assert grass.size==dirt.size==(32,32) and grass.getchannel("A").getextrema()==(255,255)
ground=Image.new("RGBA",(width,height))
for y in range(0,height,tile):
  for x in range(0,width,tile):
    ground.paste(grass,(x,y))
pathpoints=manifest["ground"]["path_control_points"]
def center_at(y):
  for i in range(len(pathpoints)-1):
    xa,ya=pathpoints[i];xb,yb=pathpoints[i+1]
    if ya<=y<=yb:
      return xa+(xb-xa)*(y-ya)/(yb-ya)
  return pathpoints[-1][0]
pathmask=Image.new("L",(width,height),0)
mp=pathmask.load()
half=manifest["ground"]["path_half_width"]
for y in range(height):
  c=center_at(y)
  for x in range(max(0,int(c-half)-2),min(width,int(c+half)+3)):
    # pixel-level binary mask; no anti-aliasing, one unified path on same canvas
    edge=2*math.sin(y/33)+1*math.sin(y/11+x/19)
    if abs(x-c)<=half+edge: mp[x,y]=255
dirt_tex=Image.new("RGBA",(width,height))
for y in range(0,height,tile):
  for x in range(0,width,tile):dirt_tex.paste(dirt,(x,y))
ground.paste(dirt_tex,(0,0),pathmask)
ground.save(B/"FS_FOREST_V32_Ground.png")
par=Image.new("RGBA",(width,height),(0,0,0,0))
par_base=Image.new("RGBA",(width,height),(0,0,0,0))
occlusion=Image.new("RGBA",(width,height),(0,0,0,0))
collision=Image.new("L",(width,height),0)
witnesses=[];instance_records=[]
assert len({o["instance_id"] for o in manifest["instances"]})==len(manifest["instances"])
for obj in sorted(manifest["instances"],key=lambda z:z["z_order"]):
  name=obj["asset_id"];spec=manifest["asset_specs"][name]
  img=Image.open(S/(name+".png")).convert("RGBA")
  assert list(img.size)==obj["source_dimensions"]
  assert hashlib.sha256((S/(name+".png")).read_bytes()).hexdigest()==obj["source_sha256"]
  x,y=obj["x"],obj["y"]
  assert isinstance(x,int) and isinstance(y,int) and 0<=x<=width-img.width and 0<=y<=height-img.height
  assert obj["anchor"]=="top_left" and obj["transform"]=={"rotation":0,"flip_x":False,"flip_y":False,"scale":1}
  mask=img.getchannel("A")
  cut=spec["canopy_y_lt"]
  ma=Image.new("L",img.size,0);mb=Image.new("L",img.size,0)
  a=mask.load();aa=ma.load();bb=mb.load()
  for ly in range(img.height):
    for lx in range(img.width):
      if ly<cut:aa[lx,ly]=a[lx,ly]
      else:bb[lx,ly]=a[lx,ly]
  assert ImageChops.difference(mask,ImageChops.add(ma,mb)).getbbox() is None
  under=img.copy();under.putalpha(mb)
  over=img.copy();over.putalpha(ma)
  under.save(B/"semantic_masks"/(obj["instance_id"]+"_base_rgba.png"))
  over.save(B/"semantic_masks"/(obj["instance_id"]+"_occlusion_rgba.png"))
  par.alpha_composite(img,(x,y))
  par_base.alpha_composite(under,(x,y))
  occlusion.alpha_composite(over,(x,y))
  ma.save(B/"semantic_masks"/(obj["instance_id"]+"_occlusion.png"))
  mb.save(B/"semantic_masks"/(obj["instance_id"]+"_base.png"))
  mask.save(B/"semantic_masks"/(obj["instance_id"]+"_par_complete.png"))
  # collision is designed for contact geometry: rocks/trunks/sign foot, never whole canopy.
  box=spec["collision_local"]
  d=ImageDraw.Draw(collision)
  d.rectangle((x+box[0],y+box[1],x+box[2]-1,y+box[3]-1),fill=255)
  # actual structure-specific alpha witnesses, not segmentation's full union mask
  for kind,layer in (("PAR",mask),("BASE",mb),("OCCLUSION",ma)):
    alpha=layer.load()
    points=[(lx,ly) for ly in range(img.height) for lx in range(img.width) if alpha[lx,ly]>=128]
    if not points:continue
    mx=sum(q[0] for q in points)//len(points)
    my=sum(q[1] for q in points)//len(points)
    cx,cy=min(points,key=lambda q:(q[0]-mx)**2+(q[1]-my)**2)
    witnesses.append({"instance_id":obj["instance_id"],"kind":kind,"x":x+cx,"y":y+cy,"expect_alpha_min":128})
  instance_records.append({"instance_id":obj["instance_id"],"name":name,"x":x,"y":y,"width":img.width,"height":img.height,"z_order":obj["z_order"],"source_sha256":obj["source_sha256"]})
par.save(B/"FS_FOREST_V32_Par_COMPLETE.png")
par_base.save(B/"FS_FOREST_V32_Par_BASE.png")
occlusion.save(B/"FS_FOREST_V32_Occlusion.png")
collision.save(B/"FS_FOREST_V32_CollisionMask.png")
master=ground.copy();master.alpha_composite(par)
master.save(B/"FS_FOREST_V32_Master_FromScene.png")
roundtrip=ground.copy();roundtrip.alpha_composite(par_base);roundtrip.alpha_composite(occlusion)
roundtrip.save(B/"FS_FOREST_V32_RuntimeComposite.png")
assert ImageChops.difference(master,roundtrip).getbbox() is None
# Generate QA-only actor sprite and two depth-review previews (not a new game art asset).
actor=Image.new("RGBA",(20,28));ad=ImageDraw.Draw(actor)
ad.ellipse((3,0,16,13),fill=(235,188,132,255),outline=(75,53,49,255))
ad.rectangle((3,12,16,22),fill=(51,72,140,255),outline=(27,39,71,255))
ad.rectangle((4,22,8,27),fill=(72,48,28,255))
ad.rectangle((12,22,16,27),fill=(72,48,28,255))
actor.save(B/"TEST_ONLY_ACTOR.png")
def preview(name,px,py,front):
  canvas=ground.copy();canvas.alpha_composite(par_base)
  # For QA under-canopy actor is between base and top; front actor is above all props.
  if front:
    canvas.alpha_composite(occlusion)
    canvas.alpha_composite(actor,(px-10,py-28))
  else:
    canvas.alpha_composite(actor,(px-10,py-28))
    canvas.alpha_composite(occlusion)
  canvas.save(B/name)
preview("FS_FOREST_V32_ActorUnderCanopy.png",145,333,False)
preview("FS_FOREST_V32_ActorFront.png",124,350,True)
master.resize((width*2,height*2),Image.Resampling.NEAREST).save(B/"FS_FOREST_V32_Master_2X_NEAREST.png")
(ROOT/"work"/"semantic_witnesses.json").write_text(json.dumps(witnesses,indent=2),encoding="utf8")
(ROOT/"work"/"instances_audit.json").write_text(json.dumps(instance_records,indent=2),encoding="utf8")
(ROOT/"work"/"collision.json").write_text(json.dumps({"canvas":[width,height],"objects":[{"instance_id":o["instance_id"],"box_xyxy":[o["x"]+manifest["asset_specs"][o["asset_id"]]["collision_local"][0],o["y"]+manifest["asset_specs"][o["asset_id"]]["collision_local"][1],o["x"]+manifest["asset_specs"][o["asset_id"]]["collision_local"][2],o["y"]+manifest["asset_specs"][o["asset_id"]]["collision_local"][3]]} for o in manifest["instances"]],"spawn":manifest["spawn"]},indent=2),encoding="utf8")
(ROOT/"work"/"events.json").write_text(json.dumps({"spawn":manifest["spawn"],"events":[]},indent=2),encoding="utf8")
# Tiled visual audit adapter: Ground image + tile-objects sharing exact manifest positions.
m=Element("map",{"version":"1.10","tiledversion":"1.12.2","orientation":"orthogonal","renderorder":"right-down","width":str(width//tile),"height":str(height//tile),"tilewidth":str(tile),"tileheight":str(tile),"infinite":"0","nextlayerid":"3","nextobjectid":str(len(manifest["instances"])+1)})
asset_names=list(manifest["asset_specs"].keys())
ts=SubElement(m,"tileset",{"firstgid":"1","name":"SOURCE_ASSETS_SINGLE_ORIGIN","tilewidth":"64","tileheight":"64","tilecount":str(len(asset_names)),"columns":"0"})
for n,name in enumerate(asset_names):
  obj_im=Image.open(S/(name+".png"))
  item=SubElement(ts,"tile",{"id":str(n),"type":name})
  SubElement(item,"image",{"source":"../sources/"+name+".png","width":str(obj_im.width),"height":str(obj_im.height)})
imlayer=SubElement(m,"imagelayer",{"id":"1","name":"Ground_FROM_MANIFEST"})
SubElement(imlayer,"image",{"source":"../build/FS_FOREST_V32_Ground.png","width":str(width),"height":str(height)})
grp=SubElement(m,"objectgroup",{"id":"2","name":"PAR_COMPLETE_FROM_MANIFEST","draworder":"index"})
for i,obj in enumerate(sorted(manifest["instances"],key=lambda z:z["z_order"]),1):
  name=obj["asset_id"];im=Image.open(S/(name+".png"))
  el=SubElement(grp,"object",{"id":str(i),"name":obj["instance_id"],"type":name,"gid":str(asset_names.index(name)+1),"x":str(obj["x"]),"y":str(obj["y"]+im.height),"width":str(im.width),"height":str(im.height)})
  props=SubElement(el,"properties")
  SubElement(props,"property",{"name":"source_sha256","value":obj["source_sha256"]})
tiled_path=W/"FS_FOREST_V32_scene.tmx"
indent(m)
ElementTree(m).write(tiled_path,encoding="utf-8",xml_declaration=True)
report={"status":"COMPILED_CANDIDATE_PENDING_GATES","canvas":[width,height],"instances":len(manifest["instances"]),"layer_par":"COMPLETE_NON_GROUND","source_origin":"Drive pilot and legacy reference","Tiled_TMX":str(tiled_path),"art_is_scope_limited":True}
(ROOT/"logs"/"compile_report.json").write_text(json.dumps(report,indent=2),encoding="utf8")
print("COMPILED_CANDIDATE_CREATED",report)
