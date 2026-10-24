from pathlib import Path
from PIL import Image,ImageDraw,ImageChops
from xml.etree.ElementTree import Element,SubElement,ElementTree,indent
import json,hashlib,math
r=Path(__file__).resolve().parent.parent
m=json.loads((r/"scene_manifest.json").read_text(encoding="utf8"))
for category in ("base","path"):
    declared=r/m["ground"][category]
    assert declared.is_file(),("MISSING_MATERIAL",category)
    assert hashlib.sha256(declared.read_bytes()).hexdigest()==m["ground"]["material_sha256"][category],("MATERIAL_SHA_MISMATCH",category)

W=m["canvas"]["width"];H=m["canvas"]["height"];tile=32
s=r/"source"/"clean";b=r/"build";w=r/"work"
assert W==864 and H==640 and W%32==0 and H%32==0
def asset(ref):
 p=s/(ref["asset_id"]+".png")
 assert p.is_file()
 assert hashlib.sha256(p.read_bytes()).hexdigest()==ref["sha256"]
 im=Image.open(p).convert("RGBA")
 assert im.size==tuple(ref["dimensions"])
 assert im.getchannel("A").getextrema()[1]==255
 return im
terrain=r/"source"/"terrain"
grass=Image.open(terrain/"grass_tile.png").convert("RGBA")
dirt=Image.open(terrain/"path_tile.png").convert("RGBA")
ground=Image.new("RGBA",(W,H))
dirt_pattern=Image.new("RGBA",(W,H))
for y in range(0,H,tile):
 for x in range(0,W,tile):
  ground.paste(grass,(x,y));dirt_pattern.paste(dirt,(x,y))
mask=Image.new("L",(W,H),0);d=ImageDraw.Draw(mask)
routes=m["ground"]["path_routes"]
# Sacred-Grove ring leaves a genuine planted inner courtyard and changes repeated X-shaped shortcuts into walkable routes.
d.ellipse((302,170,559,430),outline=255,width=40)
d.line([(425,0),(427,102),(415,164),(415,204)],fill=255,width=60,joint="curve")
d.line([(426,640),(420,575),(416,501),(437,416)],fill=255,width=62,joint="curve")
# Core -> west house, east shop, merchant plaza, well and optional southern scenic walk.
for pts,width in [
 ([(325,265),(276,263),(223,290),(178,293)],44),
 ([(525,263),(577,277),(635,284)],45),
 ([(539,353),(640,332),(770,332)],43),
 ([(327,359),(274,385),(240,398)],43),
 ([(420,465),(504,500),(576,516)],32)
]:
 d.line(pts,fill=255,width=width,joint="curve")
 for x,y in (pts[0],pts[-1]):
  rad=width//2;d.ellipse((x-rad,y-rad,x+rad,y+rad),fill=255)
# Keep the inner sacred garden grassy. Final river/stream is deferred until true approved animated water/bank kits exist.
ground.paste(dirt_pattern,(0,0),mask)
for ob in m["ground_decor"]:
 im=asset(ob);ground.alpha_composite(im,(ob["x"],ob["y"]))
 assert ob["category"]=="GROUND_FLORA"
ground.save(b/"FS_ELF_RICH_Ground.png")
par=Image.new("RGBA",(W,H),(0,0,0,0))
parbase=Image.new("RGBA",(W,H),(0,0,0,0))
occlusion=Image.new("RGBA",(W,H),(0,0,0,0))
coll=Image.new("L",(W,H),0);cd=ImageDraw.Draw(coll)
per_instance=[]
for ob in sorted(m["instances"],key=lambda x:(x["draw_order"],x["id"])):
 im=asset(ob);x=ob["x"];y=ob["y"]
 a=im.getchannel("A")
 cut=ob["base_cut_y"]
 # Upper section = occlusion, lower section = base. Pixelwise partition is strict.
 top=Image.new("L",im.size,0);bottom=Image.new("L",im.size,0)
 for yy in range(im.height):
  dest=top if yy<cut else bottom
  dest.paste(a.crop((0,yy,im.width,yy+1)),(0,yy))
 assert ImageChops.add(top,bottom).tobytes()==a.tobytes()
 base=im.copy();base.putalpha(bottom)
 canopy=im.copy();canopy.putalpha(top)
 # Full scene composited in one canonical draw-order chain.
 par.alpha_composite(im,(x,y))
 parbase.alpha_composite(base,(x,y))
 occlusion.alpha_composite(canopy,(x,y))
 nid=ob["id"]
 base.save(b/"semantic_masks"/(nid+"_base_rgba.png"))
 canopy.save(b/"semantic_masks"/(nid+"_occlusion_rgba.png"))
 a.save(b/"semantic_masks"/(nid+"_full_alpha.png"))
 bottom.save(b/"semantic_masks"/(nid+"_base_alpha.png"))
 top.save(b/"semantic_masks"/(nid+"_occlusion_alpha.png"))
 for x0,y0,x1,y1 in ob["collision_local"]:
  assert 0<=x0<x1<=im.width and 0<=y0<y1<=im.height,(nid,ob["collision_local"],im.size)
  cd.rectangle((x+x0,y+y0,x+x1-1,y+y1-1),fill=255)
 per_instance.append({"id":nid,"global_bounds_xyxy":[x,y,x+im.width,y+im.height],"asset":ob["asset_id"],
  "collision":[[x+c[0],y+c[1],x+c[2],y+c[3]] for c in ob["collision_local"]],
  "occlusion_partition":cut,"draw_order":ob["draw_order"],"role":ob["role"]})
par.save(b/"FS_ELF_RICH_Par_COMPLETE.png")
parbase.save(b/"FS_ELF_RICH_Par_BASE.png")
occlusion.save(b/"FS_ELF_RICH_Occlusion.png")
coll.save(b/"FS_ELF_RICH_Collision.png")
master=ground.copy();master.alpha_composite(par)
master.save(b/"FS_ELF_RICH_Master.png")
ground.save(b/"FS_ELF_RICH_1X_NOBLUR.png")
master.resize((W*2,H*2),Image.Resampling.NEAREST).save(b/"FS_ELF_RICH_Master_2X_NEAREST.png")
# A review-only blueprint guide overlay, not part of runtime.
review=master.copy();rd=ImageDraw.Draw(review)
for ev in m["interactions"]:
 x,y=ev["x"],ev["y"]
 rd.ellipse((x-6,y-6,x+6,y+6),outline=(255,255,180),width=1)
 rd.text((x+8,y-6),ev["id"],fill=(255,255,255))
review.save(b/"FS_ELF_RICH_INTERACT_QA_OVERLAY.png")
(r/"work"/"instances_resolved.json").write_text(json.dumps(per_instance,ensure_ascii=False,indent=2),encoding="utf8")
(r/"work"/"events.json").write_text(json.dumps(m["interactions"],ensure_ascii=False,indent=2),encoding="utf8")
(r/"work"/"collision.json").write_text(json.dumps({"dimensions":[W,H],"instances":per_instance,"spawn":m["spawn"]},ensure_ascii=False,indent=2),encoding="utf8")
# Tiled independent renderer inputs from SAME manifest.
assets=sorted(set(o["asset_id"] for o in m["instances"]))
tmx=Element("map",{"version":"1.10","tiledversion":"1.12.2","orientation":"orthogonal","renderorder":"right-down","width":str(W//32),"height":str(H//32),"tilewidth":"32","tileheight":"32","infinite":"0","nextlayerid":"3","nextobjectid":str(len(m["instances"])+1)})
tiles=SubElement(tmx,"tileset",{"firstgid":"1","name":"FS_ELF_RICH_CANDIDATE_SOURCES","tilewidth":"160","tileheight":"256","tilecount":str(len(assets)),"columns":"0"})
for idx,name in enumerate(assets):
 img=Image.open(s/(name+".png"))
 node=SubElement(tiles,"tile",{"id":str(idx),"type":name})
 SubElement(node,"image",{"source":"../source/clean/"+name+".png","width":str(img.width),"height":str(img.height)})
bg=SubElement(tmx,"imagelayer",{"id":"1","name":"Ground_FROM_SCENE_MANIFEST"})
SubElement(bg,"image",{"source":"../build/FS_ELF_RICH_Ground.png","width":str(W),"height":str(H)})
objgroup=SubElement(tmx,"objectgroup",{"id":"2","name":"CompletePAR_CanonicalZ","draworder":"index"})
for i,ob in enumerate(sorted(m["instances"],key=lambda x:(x["draw_order"],x["id"])),1):
 im=Image.open(s/(ob["asset_id"]+".png"))
 item=SubElement(objgroup,"object",{"id":str(i),"name":ob["id"],"type":ob["asset_id"],"gid":str(assets.index(ob["asset_id"])+1),
   "x":str(ob["x"]),"y":str(ob["y"]+im.height),"width":str(im.width),"height":str(im.height)})
 props=SubElement(item,"properties")
 SubElement(props,"property",{"name":"source_sha256","value":ob["sha256"]})
 SubElement(props,"property",{"name":"role","value":ob["role"]})
indent(tmx)
ElementTree(tmx).write(w/"FS_ELF_RICH_scene.tmx",encoding="utf8",xml_declaration=True)
print("RICH_COMPILED",W,H,"non_ground",len(per_instance),"events",len(m["interactions"]))
