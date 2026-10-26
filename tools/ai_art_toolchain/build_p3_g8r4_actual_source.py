from pathlib import Path
from PIL import Image,ImageDraw
from io import BytesIO
from scipy.ndimage import label, binary_dilation
import numpy as np,zipfile,xml.etree.ElementTree as ET,json,shutil
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
SOURCE=R/"outputs/P3_G8R3_CLEAN_VOLCANO_RIM_20261026"
DEST=R/"outputs/P3_G8R4_AUTHENTIC_FRAME_OUTLINE_MAGMA_20261026"
assert SOURCE.is_dir() and not DEST.exists()
DEST.mkdir()
results={}
def png_bytes(im):
 o=BytesIO();im.save(o,format="PNG");return o.getvalue()
for sp in ("0002","0003"):
 base=SOURCE/sp;out=DEST/sp
 out.mkdir();(out/"frames").mkdir();(out/"pixelorama_layers").mkdir()
 q=json.loads((SOURCE/f"PMD_{sp}_G8_QA.json").read_text(encoding="utf-8"))
 root=R/f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}"
 action_base={a:np.asarray(Image.open(root/(a+"-Anim.png")).convert("RGBA")) for a in ("Idle","Walk")}
 sheets={a:np.asarray(Image.open(base/(a+"-Anim.png")).convert("RGBA")).copy() for a in ("Idle","Walk")}
 qa=[];num_bridged=0;total_added_hot=0
 for row in q["samples"]:
  act,face,frame=row["action"],row["face"],row["frame"]
  direction=row["direction"]
  in_path=base/"pixelorama_layers"/f"{act}_{face}_F{frame}.ora"
  out_path=out/"pixelorama_layers"/in_path.name
  with zipfile.ZipFile(in_path) as z:
   assert z.testzip() is None
   xml_root=ET.fromstring(z.read("stack.xml"))
   layers=[(p,Image.open(BytesIO(z.read(p))).convert("RGBA")) for p in sorted(a for a in z.namelist() if a.startswith("data/") and a.endswith(".png"))]
   orig_merged=Image.open(BytesIO(z.read("mergedimage.png"))).convert("RGBA")
  orig=np.asarray(orig_merged)
  src_img=action_base[act][direction*32:(direction+1)*32,frame*32:(frame+1)*32]
  oldalpha=src_img[:,:,3]>0
  rgb=src_img[:,:,:3].astype(np.int16)
  actor_mask=oldalpha&(rgb[:,:,2]>rgb[:,:,0]*1.07)&(rgb[:,:,1]>=rgb[:,:,0]*.90)&(rgb[:,:,0]>=55)
  mount_x,mount_y=row["mount"]
  lip_y=max(4,min(14,(mount_y-4 if sp=="0002" else mount_y-5)-1))
  overlay=np.zeros((32,32,4),dtype=np.uint8)
  # Light at the crater surface, not isolated bloom detached from the little volcano.
  # Corrective top layer remains editable. Small ellipse of 32px hard pixels.
  def set_pixel(x,y,color,can_new_alpha=False):
   x,y=int(x),int(y)
   if not(1<=x<=30 and 1<=y<=29):return
   if actor_mask[y,x]:return
   if not can_new_alpha and orig[y,x,3]==0:return
   overlay[y,x,:3]=color;overlay[y,x,3]=255
  # glowing crater rim, distinct from original R3 single orange line
  span=2 if sp=="0002" else 3
  for x in range(mount_x-span,mount_x+span+1):
   set_pixel(x,lip_y+1,(255,92,18),True)
   if mount_x-span+1<=x<=mount_x+span-1:set_pixel(x,lip_y,(255,171,42),True)
  for x in (mount_x-1,mount_x,mount_x+1):
   set_pixel(x,lip_y+1,(255,225,92),True)
  # attached magma runnels on basalt surface: no dangling sparks.
  cracks=[(-4,2),(-4,3),(4,3)]
  if sp=="0003":cracks += [(-5,4),(-5,5),(5,4),(5,5),(3,4),(3,5)]
  for dx,dy in cracks:
   color=(250,95,22) if (dx+dy)%2 else (244,151,36)
   set_pixel(mount_x+dx,lip_y+dy,color)
  # Small fire tongue physically joins hot crater lip.
  set_pixel(mount_x,lip_y-1,(255,186,51),True)
  set_pixel(mount_x,lip_y-2-(frame%2),(246,96,20),True)
  if sp=="0003":
   set_pixel(mount_x+1,lip_y-1,(255,178,54),True)
   set_pixel(mount_x+1,lip_y-2-(frame%2),(248,100,22),True)
  # Source-native isolated silhouette fragment: 0003 back D4/F1 contains
  # 6 pixels at (25..26,8..11), 2 of which are ORIGINAL cyan frog body.
  # Never erase the body. Dark outline retone and 1-pixel basalt joining the stone;
  # the resulting fragment is connected to the real back, not a black stray.
  bridge=False
  if sp=="0003" and face=="back" and frame==1:
   for x,y in ((26,8),(25,9),(25,10),(26,11)):
    if src_img[y,x,3]>0 and not actor_mask[y,x]:
     set_pixel(x,y,(92,99,100))
   set_pixel(25,12,(81,88,91),True)
   bridge=True;num_bridged+=1
  edit=Image.fromarray(overlay,"RGBA")
  final=Image.alpha_composite(orig_merged,edit)
  final_rgba=np.asarray(final.convert("RGBA"))
  # preserve body source alpha + foot contact, alpha-boundary gate.
  assert np.all(final_rgba[:,:,3][actor_mask]==255),(sp,act,face,frame,"BODY_ALPHA_LOSS")
  assert np.array_equal(final_rgba[-3:,:,3],src_img[-3:,:,3]),(sp,act,face,frame,"FOOT_ALPHA_CHANGED")
  for now,old in ((final_rgba[0,:,3],src_img[0,:,3]),(final_rgba[-1,:,3],src_img[-1,:,3]),(final_rgba[:,0,3],src_img[:,0,3]),(final_rgba[:,-1,3],src_img[:,-1,3])):
   assert not np.any((now>0)&(old==0)),(sp,act,face,frame,"BORDER_NEW_ALPHA")
  # Tiny detached objects are a hard fail, except if they are already present
  # in the untouched original data. The diagnosed back-F1 region is fixed.
  lbl,n=label(final_rgba[:,:,3]>0,structure=np.ones((3,3)))
  detached=[]
  for i in range(1,n+1):
   yy,xx=np.where(lbl==i)
   if len(xx)<=8 and int(yy.min())<=16:detached.append((len(xx),int(xx.min()),int(yy.min()),int(xx.max()),int(yy.max())))
  assert not detached,(sp,act,face,frame,"LOOSE_OUTLINE",detached)
  flame_hot=(final_rgba[:,:,0]>=240)&(final_rgba[:,:,1]>=90)&(final_rgba[:,:,2]<130)&(final_rgba[:,:,3]>0)
  flame_count=int(np.count_nonzero(flame_hot & (np.indices(flame_hot.shape)[0] <=lip_y+4)))
  assert flame_count>=(7 if sp=="0002" else 12),(sp,act,face,frame,"MOLTEN_CRATER_UNREADABLE",flame_count)
  new_px=int(np.count_nonzero(overlay[:,:,3]>0))
  assert new_px>=7,(sp,act,face,frame,"NO_VISIBLE_DIFFERENCE")
  total_added_hot+=new_px
  # Rebuild genuine editable .ora with all original base layers and new overlay
  # as topmost, no resizing/rearranging action sheet geometry.
  ET.SubElement(xml_root.find("stack"),"layer",{
      "name":"G8R4_Visible_Crater_And_Connected_Outline_Repair","src":"data/G8R4_MAGMA_OUTLINE.png",
      "opacity":"1.0","visibility":"visible","composite-op":"svg:src-over","x":"0","y":"0"})
  # ORA stack first child = highest z-index, so move it to front
  stack=xml_root.find("stack")
  created=stack[-1];stack.remove(created);stack.insert(0,created)
  with zipfile.ZipFile(out_path,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
   z.writestr("mimetype","image/openraster",compress_type=zipfile.ZIP_STORED)
   z.writestr("stack.xml",ET.tostring(xml_root,encoding="utf-8",xml_declaration=True))
   for key,layer in layers:z.writestr(key,png_bytes(layer))
   z.writestr("data/G8R4_MAGMA_OUTLINE.png",png_bytes(edit))
   z.writestr("mergedimage.png",png_bytes(final))
   z.writestr("Thumbnails/thumbnail.png",png_bytes(final.resize((128,128),Image.Resampling.NEAREST)))
  with zipfile.ZipFile(out_path) as z:
   assert z.testzip() is None
   doc=ET.fromstring(z.read("stack.xml"))
   composite=Image.new("RGBA",(32,32))
   # stack XML lists topmost first: alpha composite bottom upward.
   for l in reversed(doc.findall(".//layer")):
    with Image.open(BytesIO(z.read(l.attrib["src"]))) as li:
     composite=Image.alpha_composite(composite,li.convert("RGBA"))
   assert np.array_equal(np.asarray(composite),final_rgba),(sp,act,face,frame,"ORA_COMPOSITE_DRIFT")
  final.save(out/"frames"/f"{act}_{face}_F{frame}.png")
  sheets[act][direction*32:(direction+1)*32,frame*32:(frame+1)*32]=final_rgba
  qa.append({"action":act,"face":face,"direction":direction,"frame":frame,"original_mount":[mount_x,mount_y],"visible_lava_pixels":flame_count,"new_layer_pixel_count":new_px,"bridge_repaired":bridge,"lost_blue_body_alpha":0,"detached_alpha_fragments":0})
 for act in ("Idle","Walk"):
  Image.fromarray(sheets[act],"RGBA").save(out/f"{act}-Anim.png")
  # all unselected cells remain precisely original G8R3 and original PMD in source
  orig_sheet=action_base[act]
  for direction in range(8):
   for f in range(4):
    x=sheets[act][direction*32:(direction+1)*32,f*32:(f+1)*32]
    if direction in (0,2,4) and f<2:
     assert np.any(x!=orig_sheet[direction*32:(direction+1)*32,f*32:(f+1)*32])
    else:assert np.array_equal(x,orig_sheet[direction*32:(direction+1)*32,f*32:(f+1)*32])
 assert len(qa)==12
 q["G8R4_MOLTEN_REPAIR"]={"keyframes":qa,"orphan_0003_back_F1_connected":num_bridged,"original_XML_not_modified":True}
 (DEST/f"PMD_{sp}_G8R4_QA.json").write_text(json.dumps(q,ensure_ascii=False,indent=2),encoding="utf-8")
 results[sp]={"sample_cells":12,"lava_added_pixels_total":total_added_hot,"source_back_orphan_bridged":num_bridged,
             "pixelorama_editable_ORA":12,"body_source_loss":0}
 # matched original-vs-G8R3-vs-G8R4 contact previews at pixel nearest neighbor
 ref=Image.new("RGB",(1260,565),(27,33,39));d=ImageDraw.Draw(ref)
 d.text((16,8),f"PMD {sp} REAL SOURCE / PRIOR G8R3 / ACTUAL G8R4 1x SOURCE, x4 NEAREST PREVIEW",fill=(242,221,194))
 for a_index,act in enumerate(("Idle","Walk")):
  for face_index,(face,dr) in enumerate((("front",0),("side",2),("back",4))):
   for version,root_dir in enumerate((R/f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}",base,out)):
    atl=Image.open(root_dir/f"{act}-Anim.png").convert("RGBA")
    tile=atl.crop((0,dr*32,32,(dr+1)*32)).resize((128,128),Image.Resampling.NEAREST)
    x=12+face_index*416+version*132;y=40+a_index*255
    ref.paste(tile,(x,y),tile)
    d.text((x,y+133),f"{act}-{face} "+("Source" if version==0 else "R3" if version==1 else "R4"),fill=(253,218,162))
 ref.save(DEST/f"PMD_{sp}_G8R4_SOURCE_R3_R4_CONTACT.png")
 # Animation sample PNG/GIF
 for act in ("Idle","Walk"):
  pictures=[]
  for f in (0,1):
   grid=Image.new("RGB",(440,165),(31,37,42));dd=ImageDraw.Draw(grid)
   dd.text((9,7),f"{sp} {act} F{f}: source-native atlas + G8R4 lava",fill=(243,221,193))
   for ii,(face,dir) in enumerate((("front",0),("side",2),("back",4))):
    atlas=Image.open(out/(act+"-Anim.png")).convert("RGBA")
    cell=atlas.crop((f*32,dir*32,(f+1)*32,(dir+1)*32)).resize((112,112),Image.Resampling.NEAREST)
    xx=12+ii*145
    grid.paste(cell,(xx,30),cell);dd.text((xx,145),face,fill=(195,205,212))
   pictures.append(grid)
  pictures[0].save(DEST/f"PMD_{sp}_{act}_G8R4.gif",save_all=True,append_images=pictures[1:],duration=[165,165],loop=0,disposal=2)
(DEST/"G8R4_BUILD_RESULT.json").write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding="utf-8")
print("G8R4_REAL_PMD_PASS",json.dumps(results,ensure_ascii=False),flush=True)
