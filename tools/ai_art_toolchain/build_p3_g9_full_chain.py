from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,shutil,xml.etree.ElementTree as ET,json,hashlib,math,zipfile
from scipy.ndimage import binary_dilation,label
from collections import Counter
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
OUT=R/"outputs/P3_G9_FULL_0001_0002_0003_EVOLUTION_20261027"
assert not OUT.exists(),"Do not overwrite any prior release."
OUT.mkdir(parents=True)
records={}

# Preserve user-approved original 0001 full action atlas byte-for-byte.
baby_src=R/"outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026/rock_0001"
baby_ori=R/"outputs/P3_G3R1_VOLCANIC_XML_NATIVE_20261026/original_0001"
assert baby_src.is_dir() and baby_ori.is_dir()
baby_dst=OUT/"0001"
shutil.copytree(baby_src,baby_dst,ignore=shutil.ignore_patterns("*.import",".godot"))
assert (baby_src/"AnimData.xml").read_bytes()==(baby_ori/"AnimData.xml").read_bytes()
for x in baby_ori.glob("*"):
 if x.name.endswith(("-Offsets.png","-Shadow.png")):assert x.read_bytes()==(baby_src/x.name).read_bytes(),x.name
assert len(list(baby_dst.glob("*-Anim.png")))==34
records["0001"]={"actions":34,"strategy":"USER_APPROVED_G3R1_FULL_SPRITESHEETS_EXACT_COPY","XML_Offsets_Shadow_byte_identical":True}

PALETTE={
 "0002":{"outline":(32,39,46),"dark":(57,66,73),"mid":(98,105,107),"light":(141,148,146),"bright":(185,184,171),
         "body_bright":(228,159,104),"body_mid":(157,123,104),"body_shadow":(104,92,88)},
 "0003":{"outline":(29,34,40),"dark":(61,67,72),"mid":(101,111,111),"light":(152,151,143),"bright":(192,183,163),
         "body_bright":(238,151,96),"body_mid":(168,112,91),"body_shadow":(106,80,76)}
}
def rock_pixels(canvas,center,radii,palette,idx,face,phase):
 cx,cy=center;rx,ry=radii
 W,H=canvas.size
 arr=np.zeros((H,W,4),dtype=np.uint8);hist=Counter()
 lx,ly={0:(-.68,-.8),2:(.46,-.89),4:(-.4,-.90),6:(-.25,-.86)}[face]
 lx+=.09*(phase%3-1)
 for y in range(max(1,cy-ry),min(H-1,cy+ry+1)):
  for x in range(max(1,cx-rx),min(W-1,cx+rx+1)):
   nx=(x-cx)/max(rx,1);ny=(y-cy)/max(ry,1)
   q=nx*nx+ny*ny
   if q>1.02:continue
   light=nx*lx+ny*ly+(((x*13+y*7+idx*11+face*3)%9)-4)*.038
   shade=("outline" if light<.15 else "dark") if q>.81 else ("dark" if light<-.46 else "mid" if light<.12 else "light" if light<.68 else "bright")
   arr[y,x]=(*palette[shade],255);hist[shade]+=1
 glint_x=max(1,min(W-2,cx+(-1 if face!=2 else 1)))
 glint_y=max(1,min(H-2,cy-1))
 if arr[glint_y,glint_x,3]:arr[glint_y,glint_x,:3]=palette["bright"]
 material={tuple(color[:3]) for color in arr.reshape(-1,4) if color[3]>0}
 # Shape here is actual chunky rounded basalt, separate from the petal mask.
 assert len(material)>=3 and int(np.count_nonzero(arr[:,:,3]>0))>=12,(idx,center,material)
 rock=Image.fromarray(arr,"RGBA")
 return rock,{"bands":len(material),"rock_pixels":int((arr[:,:,3]>0).sum()),"center":[cx,cy]}

def render_frame(original,species,face,frame,action):
 H,W=original.shape[:2];palette=PALETTE[species];rgb=original[:,:,:3].astype(np.int16);opaque=original[:,:,3]>0
 blue=opaque&(rgb[:,:,2]>rgb[:,:,0]*1.07)&(rgb[:,:,1]>=rgb[:,:,0]*.90)&(rgb[:,:,0]>=55)
 ys,xs=np.where(blue)
 assert len(xs)>=60,(species,action,face,frame,"MISSING_BODY",len(xs))
 body_x=int(np.median(xs));body_y=int(np.median(ys));top=int(np.min(ys))
 yy,xx=np.indices((H,W))
 pale=blue&(rgb[:,:,0]>120)
 medium=blue&~pale&(rgb[:,:,0]>78)
 shadow=blue&~pale&~medium
 base=original.copy()
 base[pale,:3]=palette["body_bright"]
 base[medium,:3]=palette["body_mid"]
 base[shadow,:3]=palette["body_shadow"]
 plant=opaque&(rgb[:,:,1]>rgb[:,:,0]*1.13)&(rgb[:,:,1]>rgb[:,:,2]*1.2)&(rgb[:,:,1]>73)&(rgb[:,:,0]<190)
 flower=opaque&(rgb[:,:,0]>110)&(rgb[:,:,0]>rgb[:,:,1]*1.35)&(rgb[:,:,1]<145)&(rgb[:,:,2]<130)
 # Never follow the flower motion: independently mount all rocks on the SOURCE BODY silhouette.
 # Remove old petal material only in upper region and never delete original protected body pixels.
 protected=binary_dilation(blue,iterations=1)
 ycut=min(H-7,top+4)
 deleted=binary_dilation((plant|flower)&(yy<=ycut),iterations=1)&(yy<=ycut)&~protected
 base[deleted]=[0,0,0,0]
 keep_plant=plant&~deleted&~blue
 base[keep_plant,:3]=palette["dark"]
 # Tiny detached old bud ink, only far from original frog's protected silhouette.
 comp,n=label(base[:,:,3]>0,structure=np.ones((3,3)))
 for c in range(1,n+1):
  cy,cx=np.where(comp==c)
  if len(cx)<=8 and len(cx) and not np.any(blue[cy,cx]) and int(cy.min())<top+4:
   base[cy,cx]=[0,0,0,0]
 guard=binary_dilation(blue,iterations=2)
 base[(yy<=ycut)&~guard]=[0,0,0,0]
 assert np.array_equal(base[:,:,3][blue],original[:,:,3][blue])
 # Portrait action canvases (64x64 and 72x72) use the *body* anchor in that
 # 64/72px image, NOT a fake default 32x32 coordinate.
 pose_face=0 if face in (0,1,7) else 2 if face in (2,3) else 4 if face in (4,5) else 6
 mount_x=int(np.clip(body_x+(-3 if pose_face==2 else 0),11,W-11))
 mount_y=int(np.clip(body_y-3,10,H-11))
 # Follow source body posture; secondary 1px bob when held stationary.
 mount_y=max(9,min(H-10,mount_y+frame%2))
 if species=="0002":
  offsets=[(-5,-2,3,3),(0,-5,4,3),(5,-1,3,3)]
 else:
  offsets=[(-7,-1,4,3),(-4,-5,3,3),(0,-7,4,3),(4,-5,4,3),(7,-1,3,3)]
 if pose_face==2:offsets=[(int(dx*.75)+2,dy,rx,ry) for dx,dy,rx,ry in offsets]
 elif pose_face==4:offsets=[(-dx,dy+1,rx,ry) for dx,dy,rx,ry in offsets]
 # Build explicit RGBA layers; then overlay original creature body in front to avoid broken face.
 img=Image.fromarray(base,"RGBA")
 saddle=Image.new("RGBA",(W,H))
 ds=ImageDraw.Draw(saddle)
 rr=7 if species=="0002" else 9
 ds.ellipse((mount_x-rr,mount_y-5,mount_x+rr,mount_y+1),fill=(73,77,80,255),outline=(52,59,63,255))
 img=Image.alpha_composite(img,saddle)
 lava=Image.new("RGBA",(W,H));d=ImageDraw.Draw(lava)
 gap_y=mount_y-(4 if species=="0002" else 5)
 d.ellipse((mount_x-3,gap_y-2,mount_x+3,gap_y+2),fill=(48,32,30,255),outline=(25,25,30,255))
 d.line([(mount_x-2,gap_y),(mount_x+2,gap_y)],fill=(235,102 if species=="0002" else 146,24,255),width=1)
 d.point((mount_x+(frame%2),gap_y),fill=(255,206,76,255))
 img=Image.alpha_composite(img,lava)
 rock_info=[]
 for idx,(dx,dy,rx,ry) in enumerate(offsets):
  x=int(np.clip(mount_x+dx,rx+2,W-rx-3));y=int(np.clip(mount_y+dy,ry+2,H-ry-7))
  r,info=rock_pixels(img,(x,y),(rx,ry),palette,idx,pose_face,frame)
  if (species=="0003" and idx in (0,2,4)) or (species=="0002" and idx==1):
   rd=ImageDraw.Draw(r)
   vx=int(max(2,min(W-3,x+(1 if pose_face==2 else 0))))
   vtop=max(2,y-ry+1)
   rd.line([(vx,vtop),(vx-1,y)],fill=(160,46,20,255),width=1)
   rd.point((vx-1,y-1),fill=(255,125,26,255))
  img=Image.alpha_composite(img,r)
  rock_info.append(info)
 top_body=np.zeros_like(original)
 top_body[blue]=base[blue]
 img=Image.alpha_composite(img,Image.fromarray(top_body,"RGBA"))
 fire=Image.new("RGBA",(W,H));d=ImageDraw.Draw(fire)
 lip_y=max(4,min(H-10,gap_y-1))
 rad=3 if species=="0002" else 4
 d.arc((mount_x-rad,lip_y-1,mount_x+rad,lip_y+3),175,355,fill=(210,49,17,255),width=1)
 d.line((mount_x-rad+1,lip_y,mount_x+rad-1,lip_y),fill=(247,82,15,255),width=1)
 d.line((mount_x-rad+2,lip_y,mount_x+rad-2,lip_y),fill=(255,202,57,255),width=1)
 d.point((mount_x,lip_y),fill=(255,244,121,255))
 tip=lip_y-(2 if species=="0002" else 3)-(frame%2)
 d.line((mount_x,tip+1,mount_x,lip_y-1),fill=(247,91,20,255),width=2)
 d.line((mount_x,tip+1,mount_x,lip_y-1),fill=(255,211,72,255),width=1)
 if species=="0003":
  d.line((mount_x+2,lip_y-3-(frame%2),mount_x+2,lip_y),fill=(236,82,17,255),width=2)
  d.line((mount_x+2,lip_y-2-(frame%2),mount_x+2,lip_y),fill=(255,198,57,255),width=1)
  d.line((mount_x+3,lip_y+1,mount_x+4,lip_y+3),fill=(255,116,23,255),width=1)
 else:d.point((mount_x-2,lip_y-1),fill=(240,95,22,255))
 # Only use scene-local flame pixels. Protect original actor face, original frame edges and feet.
 firearr=np.asarray(fire).copy()
 firearr[blue]=0
 r=np.asarray(Image.alpha_composite(img,Image.fromarray(firearr,"RGBA"))).copy()
 # never add new opaque alpha at atlas cell boundary, and leave original foot silhouette
 r[0,:,:]=base[0,:,:];r[-1,:,:]=base[-1,:,:];r[:,0,:]=base[:,0,:];r[:,-1,:]=base[:,-1,:]
 r[-3:,:,3]=original[-3:,:,3]
 # Body remains visible as in approved keyframes, no original protected-blue alpha removed.
 assert np.all(r[:,:,3][blue]==255),(species,action,face,frame,"BODY_LOST")
 for old,new in ((original[0,:,3],r[0,:,3]),(original[-1,:,3],r[-1,:,3]),(original[:,0,3],r[:,0,3]),(original[:,-1,3],r[:,-1,3])):
  assert not np.any((new>0)&(old==0)),(species,action,face,frame,"NEW_OPAQUE_BORDER")
 assert np.array_equal(r[-3:,:,3],original[-3:,:,3]),(species,action,face,frame,"FOOT_ALPHA")
 changes=int(np.count_nonzero(np.any(r!=original,axis=2)))
 assert changes>=20,(species,action,face,frame,"NO_REAL_ART_CHANGE",changes)
 # Some heavily animated poses have a source flower above torso; small stones are
 # intentionally forced to remain on the BODY even if source petals flail far away.
 return r,{"mount":[mount_x,mount_y],"shades":[info["bands"] for info in rock_info],"changed_pixels":changes,
           "new_rock_units":len(rock_info),"body_protected_pixels":int(blue.sum())}

APPROVED={
 "0002":R/"outputs/P3_G8R4_AUTHENTIC_FRAME_OUTLINE_MAGMA_20261026/0002",
 "0003":R/"deliveries/P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX_20261027/G8R5_SAMPLE_0003",
}
for sp in ("0002","0003"):
 ORIGINAL=R/f"outputs/P3_G{'4' if sp=='0002' else '5'}_{sp}_OFFICIAL_SOURCE_20261026/SOURCE_{sp}"
 assert ORIGINAL.is_dir()
 target=OUT/sp;target.mkdir()
 for item in ORIGINAL.glob("*"):
  if item.name=="AnimData.xml" or item.name.endswith(("-Offsets.png","-Shadow.png")):shutil.copy2(item,target/item.name)
 base=ET.parse(ORIGINAL/"AnimData.xml").getroot().findall(".//Anim")
 actionlog=[];total=0;preserved=0;generated=0
 for motion in base:
  if motion.findtext("CopyOf"):continue
  action=motion.findtext("Name")
  W,H=int(motion.findtext("FrameWidth")),int(motion.findtext("FrameHeight"))
  n=len(motion.find("Durations").findall("Duration"))
  source=np.asarray(Image.open(ORIGINAL/(action+"-Anim.png")).convert("RGBA"))
  rows=source.shape[0]//H
  assert source.shape==(rows*H,n*W,4)
  final=source.copy();dets=[]
  for dr in range(rows):
   for fr in range(n):
    a=source[dr*H:(dr+1)*H,fr*W:(fr+1)*W]
    # Preserve approved art pixels EXACTLY at their original grid positions.
    approved=action in ("Idle","Walk") and dr in (0,2,4) and fr in (0,1)
    if approved:
     old=np.asarray(Image.open(APPROVED[sp]/(action+"-Anim.png")).convert("RGBA"))
     assert old.shape==source.shape
     b=old[dr*H:(dr+1)*H,fr*W:(fr+1)*W]
     record={"status":"APPROVED_BASELINE_PRESERVED_EXACT","changed_pixels":int(np.any(a!=b,axis=2).sum())}
     preserved+=1
    else:
     b,record=render_frame(a,sp,dr,fr,action)
     record["status"]="NEW_G9_FULL_SHEET_CANDIDATE"
     generated+=1
    final[dr*H:(dr+1)*H,fr*W:(fr+1)*W]=b
    record.update({"direction":dr,"frame":fr})
    dets.append(record)
    total+=1
  output=target/(action+"-Anim.png")
  Image.fromarray(final,"RGBA").save(output)
  assert Image.open(output).size==(n*W,rows*H)
  actionlog.append({"action":action,"frame_width":W,"frame_height":H,"total_frames":len(dets),"preserved_approved":sum(x["status"].startswith("APPROVED") for x in dets),
                    "generated_new":sum(x["status"].startswith("NEW_") for x in dets)})
 assert total==(682 if sp=="0002" else 698)
 assert preserved==12 and generated==total-12,(sp,preserved,generated,total)
 assert len(actionlog)==12
 # XML/timing/offsets/shadow exact preservation
 assert (target/"AnimData.xml").read_bytes()==(ORIGINAL/"AnimData.xml").read_bytes()
 for p in ORIGINAL.glob("*"):
  if p.name.endswith(("-Offsets.png","-Shadow.png")):assert p.read_bytes()==(target/p.name).read_bytes()
 records[sp]={"xml_motions":len(base),"action_images":len(actionlog),"total_frames":total,
              "approved_G8R4_or_G8R5_frames_preserved":preserved,"new_G9_generated_frames":generated,
              "XML_Offsets_Shadow_byte_identical":True,"action_breakdown":actionlog,
              "status":"FULL_ATLAS_TECH_CANDIDATE_HUMAN_UNREVIEWED"}
 print("G9_ALL_SOURCE_ATLAS_CREATED",sp,json.dumps({k:v for k,v in records[sp].items() if k!="action_breakdown"},ensure_ascii=False),flush=True)
(OUT/"G9_FULL_BUILD.json").write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding="utf-8")
