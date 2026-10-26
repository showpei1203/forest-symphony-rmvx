from pathlib import Path
from PIL import Image,ImageDraw
from scipy.ndimage import binary_dilation, label
from io import BytesIO
import numpy as np,json,zipfile,xml.etree.ElementTree as ET,math,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
OUT=R/"outputs/P3_G8R1_COMBO_B_LAYERED_ROCK_PALETTE_20261026"
assert not OUT.exists(),"Never overwrite G8 candidates"
OUT.mkdir(parents=True)
directions={0:"front",2:"side",4:"back"}
actions=("Idle","Walk")
colors={
"0002":{
"outline":(32,39,46),"dark":(57,66,73),"mid":(98,105,107),
"light":(141,148,146),"bright":(185,184,171),
"body_bright":(228,159,104),"body_mid":(157,123,104),"body_shadow":(104,92,88)},
"0003":{
"outline":(29,34,40),"dark":(61,67,72),"mid":(101,111,111),
"light":(152,151,143),"bright":(192,183,163),
"body_bright":(238,151,96),"body_mid":(168,112,91),"body_shadow":(106,80,76)}}
palette_names=("outline","dark","mid","light","bright")
def png_bytes(im):
 b=BytesIO();im.save(b,format="PNG");return b.getvalue()
def ora_build(layers,output):
 # layers are bottom-to-top, OpenRaster stack stores topmost first
 b=Image.new("RGBA",(32,32),(0,0,0,0))
 for name,im in layers:b=Image.alpha_composite(b,im)
 xml=ET.Element("image",{"version":"0.0.3","w":"32","h":"32","name":output.stem})
 stack=ET.SubElement(xml,"stack")
 refs=[]
 for i,(name,im) in enumerate(layers):
  refs.append((f"data/layer_{i:02d}.png",im))
 for path,(name,im) in reversed(list(zip([x[0] for x in refs],layers))):
  ET.SubElement(stack,"layer",{"name":name,"src":path,"opacity":"1.0","visibility":"visible","composite-op":"svg:src-over","x":"0","y":"0"})
 with zipfile.ZipFile(output,"w") as z:
  z.writestr("mimetype","image/openraster",compress_type=zipfile.ZIP_STORED)
  z.writestr("stack.xml",ET.tostring(xml,encoding="utf-8",xml_declaration=True))
  z.writestr("mergedimage.png",png_bytes(b))
  z.writestr("Thumbnails/thumbnail.png",png_bytes(b.resize((128,128),Image.Resampling.NEAREST)))
  for path,im in refs:z.writestr(path,png_bytes(im))
 with zipfile.ZipFile(output) as z:assert z.testzip() is None
 return b
def rock_layer(center,radii,species,idx,facing,frame,ref):
 cx,cy=center;rx,ry=radii
 im=np.zeros((32,32,4),np.uint8);hist={}
 # directional light: front from upper-left, side from upper-right, rear muted from upper-left
 lx,ly={0:(-0.68,-0.80),2:(0.46,-0.89),4:(-0.40,-0.90)}[facing]
 # posture controls low-amplitude facet lighting change; rocks remain coherently attached to mount
 lx+=0.13*frame;ly+=0.045*frame
 for y in range(max(1,cy-ry),min(31,cy+ry+1)):
  for x in range(max(1,cx-rx),min(31,cx+rx+1)):
   nx=(x-cx)/max(rx,1);ny=(y-cy)/max(ry,1)
   radius=nx*nx+ny*ny
   if radius>1.02:continue
   light=nx*lx+ny*ly
   facet=((x*13+y*7+idx*11+facing*3)%9)-4
   light+=facet*0.038
   rim=(radius>0.81)
   if rim:
    kind="outline" if light<0.15 else "dark"
   elif light < -0.46:kind="dark"
   elif light<0.12:kind="mid"
   elif light<0.68:kind="light"
   else:kind="bright"
   rgb=ref[kind]
   im[y,x]=[rgb[0],rgb[1],rgb[2],255]
   hist[kind]=hist.get(kind,0)+1
 # Mineral mineral glint varies with orientation and movement
 glint=(max(1,min(30,cx+(-1 if facing!=2 else 1))),max(1,min(30,cy-1)))
 if im[glint[1],glint[0],3]:
  im[glint[1],glint[0],:3]=ref["bright"]
 hist["distinct_palette_colors"]=len({tuple(z[:3]) for z in im.reshape(-1,4) if z[3]>0})
 hist["rock_pixel_count"]=int((im[:,:,3]>0).sum())
 return Image.fromarray(im,"RGBA"),hist
output={}
for species in ("0002","0003"):
 src=R/f"outputs/P3_G{'4' if species=='0002' else '5'}_{species}_OFFICIAL_SOURCE_20261026/SOURCE_{species}"
 dest=OUT/species;dest.mkdir()
 frames=dest/"frames";frames.mkdir()
 layers_out=dest/"pixelorama_layers";layers_out.mkdir()
 swatches=colors[species]
 summary=[]
 original_atlases={}
 new_atlases={}
 for act in actions:
  atlas=np.asarray(Image.open(src/(act+"-Anim.png")).convert("RGBA"))
  assert atlas.shape==(256,128,4)
  out_atlas=atlas.copy()
  original_atlases[act]=atlas
  for facing,face_name in directions.items():
   for f in (0,1):
    orig=atlas[facing*32:(facing+1)*32,f*32:(f+1)*32].copy()
    col=orig[:,:,:3].astype(np.int16)
    alpha=orig[:,:,3]>0
    body=alpha&(col[:,:,2]>col[:,:,0]*1.07)&(col[:,:,1]>=col[:,:,0]*.90)&(col[:,:,0]>=55)
    by,bx=np.where(body)
    assert len(bx)>=70,(species,act,facing,f,"body source not located")
    bx_med=int(np.median(bx));by_med=int(np.median(by));body_top=int(by.min())
    protected=binary_dilation(body,iterations=1)
    pale=body&(col[:,:,0]>120)
    medium=body&~pale&(col[:,:,0]>78)
    shadow=body&~pale&~medium
    base=orig.copy()
    base[pale,:3]=swatches["body_bright"]
    base[medium,:3]=swatches["body_mid"]
    base[shadow,:3]=swatches["body_shadow"]
    yy=np.indices(alpha.shape)[0]
    green=alpha & (col[:,:,1]>col[:,:,0]*1.13)&(col[:,:,1]>col[:,:,2]*1.2)&(col[:,:,1]>73)&(col[:,:,0]<190)
    red=alpha &(col[:,:,0]>110)&(col[:,:,0]>col[:,:,1]*1.35)&(col[:,:,1]<145)&(col[:,:,2]<130)
    # Remove original upper ornament only, retaining cyan body and its adjacent
    # black outline (protect_body). Repaint remaining lower leaf mineral gray, not transparent.
    upper=yy<=body_top+1
    ornament=(green|red)&upper
    delete=binary_dilation(ornament,iterations=1)&upper&~protected
    base[delete]=[0,0,0,0]
    keep_green=green&~delete&~body
    base[keep_green,:3]=swatches["dark"]
    # body fully protected from transparency changes
    assert np.array_equal(base[:,:,3][body],orig[:,:,3][body])
    # Self-visual G8 FAIL: original petal outlines leave detached tiny black pixels
    # above/beside the creature. Repair SOURCE UNDERLAYER only, never a boulder.
    # Keep anything connected with the protected blue-body silhouette.
    cc,num=label(base[:,:,3]>0,structure=np.ones((3,3)))
    for ci in range(1,num+1):
      ys,xs=np.where(cc==ci)
      if not len(xs):continue
      if (len(xs)<=8 and not np.any(body[ys,xs]) and
          (int(ys.min())<body_top+3 or int(ys.max())<body_top+5)):
        base[ys,xs]=[0,0,0,0]
    assert np.array_equal(base[:,:,3][body],orig[:,:,3][body])
    base_img=Image.fromarray(base,"RGBA")
    # back mount rooted in actual body shape, not original leaf or flower position
    mount_x=int(np.clip(bx_med+(-3 if facing==2 else 0),11,21))
    mount_y=int(np.clip(by_med-3,12,17))
    phase=f
    mount_y+=phase
    if species=="0002":
      # 3 uneven round basalt cobbles, with eye-readable mass, not radial petals
      positions=[(-5,-2,3,3),(0,-5,4,3),(5,-1,3,3)]
    else:
      positions=[(-7,-1,4,3),(-4,-5,3,3),(0,-7,4,3),(4,-5,4,3),(7,-1,3,3)]
    # direction changes relative arrangement, reflecting the mass seen from side
    if facing==2:positions=[(int(dx*.75)+2,dy,rx,ry) for dx,dy,rx,ry in positions]
    elif facing==4:positions=[(-dx,dy+1,rx,ry) for dx,dy,rx,ry in positions]
    shadowimg=Image.new("RGBA",(32,32));sd=ImageDraw.Draw(shadowimg)
    saddle_w=8 if species=="0002" else 10
    sd.ellipse((mount_x-saddle_w,mount_y-5,mount_x+saddle_w,mount_y+3),
               fill=(36,43,49,255),outline=(24,30,35,255))
    # Draw molten crater over mount, then outer stone units; layers editable independently.
    lava=Image.new("RGBA",(32,32));ld=ImageDraw.Draw(lava)
    gap_y=mount_y-4 if species=="0002" else mount_y-5
    ld.ellipse((mount_x-3,gap_y-2,mount_x+3,gap_y+2),fill=(48,32,30,255),outline=(25,25,30,255))
    ld.line([(mount_x-2,gap_y),(mount_x+2,gap_y)],fill=(234,91 if species=="0002" else 136,24,255),width=1)
    ld.point((mount_x+(f%2),gap_y),fill=(255,206,76,255))
    if species=="0003":
      ld.line([(mount_x+2,gap_y+1),(mount_x+3,gap_y+3)],fill=(250,113,33,255))
    rocks=[];rockstats=[]
    for index,(dx,dy,rx,ry) in enumerate(positions):
      x=int(np.clip(mount_x+dx,rx+2,29-rx));y=int(np.clip(mount_y+dy,ry+2,28-ry))
      one,hist=rock_layer((x,y),(rx,ry),species,index,facing,f,swatches)
      assert hist["distinct_palette_colors"]>=3,(species,act,facing,f,index,"flat stone")
      assert hist["rock_pixel_count"]>=12,(species,act,facing,f,index)
      rockstats.append({"id":index,"center":[x,y],"radii":[rx,ry],**hist})
      rocks.append((f"Round_Basalt_{index+1}",one))
    # restore ORIGINAL BODY onto the FRONT plane, avoiding rock destroying creature face.
    front_body=Image.new("RGBA",(32,32))
    # legacy readonly discarded
    # no readonly write
    # all blue original body always visible front of rocks (preserves at least colorized body)
    body_front=np.zeros_like(base)
    body_front[body,:]=base[body,:]
    body_overlay=Image.fromarray(body_front,"RGBA")
    layers=[("Recolored_Original_Body",base_img),("Mount_Saddle",shadowimg),("Magma_Crater",lava)]+rocks+[("Protected_Original_Frog_Body",body_overlay)]
    group=ora_build(layers,layers_out/f"{act}_{face_name}_F{f}.ora")
    changed=np.asarray(group.convert("RGBA"),dtype=np.uint8).copy()
    old_mask=orig[:,:,3]>0
    assert np.all(changed[:,:,3][body]==255),(species,act,facing,f,"body erased")
    assert np.array_equal(changed[-3:,:,3],orig[-3:,:,3]),(species,act,facing,f,"foot alpha changed")
    # ensure no new border opaque pixels
    for bo in (((changed[0,:,3]>0)&~old_mask[0,:]),((changed[-1,:,3]>0)&~old_mask[-1,:]),
               ((changed[:,0,3]>0)&~old_mask[:,0]),((changed[:,-1,3]>0)&~old_mask[:,-1])):
      assert not np.any(bo),(species,act,facing,f,"atlas boundary")
    assert np.count_nonzero(np.any(changed!=orig,axis=2))>=50
    for id,rock in enumerate(rocks):
      rc=rockstats[id]
      assert rc["distinct_palette_colors"]>=3
    assert sum(int(a["rock_pixel_count"]) for a in rockstats)>45
    assert len(rocks)==(3 if species=="0002" else 5)
    Image.fromarray(changed,"RGBA").save(frames/f"{act}_{face_name}_F{f}.png")
    out_atlas[facing*32:(facing+1)*32,f*32:(f+1)*32]=changed
    summary.append({"species":species,"action":act,"direction":facing,"face":face_name,
      "frame":f,"body_center":[bx_med,by_med],"mount":[mount_x,mount_y],
      "body_original_opaque_pixels":int(body.sum()),"body_erased_pixels":int(np.count_nonzero(body&~(changed[:,:,3]>0))),
      "petal_clear_pixels":int(delete.sum()),"rocks":rockstats})
  Image.fromarray(out_atlas,"RGBA").save(dest/(act+"-Anim.png"))
  new_atlases[act]=out_atlas
  # explicitly exactly 12 sample cells only; everything else untouched
  for d in range(8):
   for f in range(4):
    src_cell=atlas[d*32:(d+1)*32,f*32:(f+1)*32]
    changed_cell=out_atlas[d*32:(d+1)*32,f*32:(f+1)*32]
    selected=d in directions and f<2
    assert np.any(changed_cell!=src_cell) if selected else np.array_equal(changed_cell,src_cell)
 # coherent body-rock motion and variation must be tested per group
 for act in actions:
  for facing in directions:
   pair=[q for q in summary if q["action"]==act and q["direction"]==facing]
   assert len(pair)==2
   assert pair[0]["mount"]!=pair[1]["mount"],(species,act,facing,"static mount")
   for i in range(len(pair[0]["rocks"])):
    assert pair[0]["rocks"][i]["center"]!=pair[1]["rocks"][i]["center"],(species,act,facing,i,"static stone")
 for act in actions:
  p=Image.new("RGB",(1200,352),(28,34,40));dd=ImageDraw.Draw(p)
  dd.text((14,10),f"PMD {species} {act}: ORIGINAL vs G8 FREE TOOL/PALETTE EDITABLE SAMPLES",fill=(236,224,211))
  for i,(face,dir) in enumerate([("front",0),("side",2),("back",4)]):
   for f in (0,1):
    old=Image.fromarray(original_atlases[act][dir*32:(dir+1)*32,f*32:(f+1)*32],"RGBA")
    new=Image.fromarray(new_atlases[act][dir*32:(dir+1)*32,f*32:(f+1)*32],"RGBA")
    x=12+i*396+f*195
    p.paste(old.resize((96,96),Image.Resampling.NEAREST),(x,42),old.resize((96,96),Image.Resampling.NEAREST))
    p.paste(new.resize((96,96),Image.Resampling.NEAREST),(x,190),new.resize((96,96),Image.Resampling.NEAREST))
    dd.text((x,144),face+f" F{f} original",fill=(183,220,190))
    dd.text((x,293),face+f" F{f} G8",fill=(246,196,144))
  p.save(OUT/f"PMD_{species}_{act}_ORIGINAL_VS_G8.png")
  pairframes=[]
  for f in (0,1):
   gif=Image.new("RGB",(700,170),(31,36,42));d=ImageDraw.Draw(gif)
   d.text((8,6),f"PMD {species} {act} f{f} - body-mounted independently shaded rocks",fill=(249,223,197))
   for i,face in enumerate(directions.values()):
    tile=Image.open(frames/f"{act}_{face}_F{f}.png").resize((128,128),Image.Resampling.NEAREST)
    gif.paste(tile,(20+i*215,28),tile)
    d.text((20+i*215,155),face,fill=(193,209,221))
   pairframes.append(gif)
  pairframes[0].save(OUT/f"PMD_{species}_{act}_G8.gif",save_all=True,append_images=pairframes[1:],duration=[180,180],disposal=2,loop=0)
 report={"species":species,"original_action_names":14,"sample_only_cells":12,
     "original_other_actions_unmodified":True,"original_XML_Offsets_Shadow_unmodified":True,
     "rock_palettes_with_3_plus_tones":True,"shadow_direction_variation":True,
     "body_pixel_erased":sum(r["body_erased_pixels"] for r in summary),
     "sway_group":"body_attached plus phase","samples":summary}
 (OUT/f"PMD_{species}_G8_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
 output[species]={"samples":12,"rocks_per_frame":3 if species=="0002" else 5,"body_erased":report["body_pixel_erased"],"ORA_editable_files":len(list(layers_out.glob("*.ora")))}
(OUT/"P3_G8_STATUS.json").write_text(json.dumps(output,ensure_ascii=False,indent=2),encoding="utf-8")
print("G8_COMBO_B_LAYERED_ART_BUILT",json.dumps(output,ensure_ascii=False),flush=True)
