from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np, json, shutil, hashlib
from scipy.ndimage import binary_dilation, label
ROOT=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
BASE=ROOT/"outputs/P3_G7R1_RESET_BACK_MOUNTED_ROCK_CLUSTER_20261026"
assert not BASE.exists(), "Never overwrite a prior candidate"
BASE.mkdir(parents=True)
sample_dirs={0:"front",2:"side",4:"back"}
record={"tag":"P3_G7_RESET_BACK_MOUNTED_ROCK_CLUSTER",
        "map_scope":"PAUSED","PMD0001":"DO_NOT_MODIFY",
        "source_cells_only":True,
        "user_art_gate":"PENDING","source_actor_and_original_xml":"PRESERVED",
        "species":{}}
# source original body color palette -> burnt warm orange/ash, geometry unaffected
body_map={
 (175,207,239):(216,158,117),(111,159,199):(150,122,116),
 (87,119,135):(99,94,98),(135,175,207):(216,156,116),
 (103,135,159):(153,123,115),(63,87,111):(92,88,93),
 (255,135,95):(251,166,110),
}
for species in ("0002","0003"):
 middle=species=="0002"
 SRC=ROOT/f"outputs/P3_G{'4' if middle else '5'}_{species}_OFFICIAL_SOURCE_20261026/SOURCE_{species}"
 TARGET=BASE/f"PMD_{species}_SAMPLE_SHEETS"
 TARGET.mkdir()
 for suffix in ("AnimData.xml",):
  shutil.copy2(SRC/suffix,TARGET/suffix)
 for fn in SRC.glob("*-Offsets.png"):shutil.copy2(fn,TARGET/fn.name)
 for fn in SRC.glob("*-Shadow.png"):shutil.copy2(fn,TARGET/fn.name)
 stats=[];n=0;by_action={}
 original_samples={}
 output_samples={}
 for action in ("Idle","Walk"):
  original=np.asarray(Image.open(SRC/f"{action}-Anim.png").convert("RGBA"))
  assert original.shape[0]==256 and original.shape[1]==128
  new_atlas=original.copy()
  samples_action=[]
  for direction,face in sample_dirs.items():
   for frame in (0,1):
    x0=frame*32;y0=direction*32
    old=original[y0:y0+32,x0:x0+32].copy()
    rgb=old[:,:,:3].astype(np.int32)
    alpha=old[:,:,3]>0
    # Body is identified by cyan-blue, independent of flower position.
    blue=alpha&(rgb[:,:,2]>rgb[:,:,0]*1.07)&(rgb[:,:,1]>=rgb[:,:,0]*.90)&(rgb[:,:,0]>=55)
    ys,xs=np.where(blue)
    assert len(xs)>=70,(species,action,direction,frame,"SOURCE_BODY_NOT_FOUND")
    body_cx=int(np.median(xs));body_cy=int(np.median(ys))
    body_top=int(np.min(ys))
    foot=old[-4:,:,:].copy()
    # Original petal/leaf mask is used ONLY to clear former ornament materials.
    # It is intentionally NOT used for rock positioning or sway.
    green=alpha&(rgb[:,:,1]>rgb[:,:,0]*1.13)&(rgb[:,:,1]>rgb[:,:,2]*1.2)&(rgb[:,:,1]>73)&(rgb[:,:,0]<190)
    red=alpha&(rgb[:,:,0]>110)&(rgb[:,:,0]>rgb[:,:,1]*1.35)&(rgb[:,:,1]<145)&(rgb[:,:,2]<130)
    new=old.copy()
    for color,target_color in body_map.items():
     mask=blue & np.all(rgb==color,axis=2)
     new[mask,:3]=target_color
    # Rock's understructure: completely repaint surviving lower source "leaf" colors.
    near_lower=(np.indices(green.shape)[0]>=body_cy-5)
    new[green&near_lower,:3]=(74,81,82)
    # In the upper region, remove only recognizable flower/leaf pixels and immediate
    # dark petal outline, preserving ALL blue torso pixels plus original contact-foot row.
    upper=np.indices(alpha.shape)[0]<=min(body_cy-5,15)
    colored=(green|red)&upper
    risk=binary_dilation(colored,iterations=1)&upper&(~blue)
    # Preserve any red original eyes near lower face by mask restriction.
    new[risk,:]=0
    # Skin and feet must remain fully opaque where they existed (only recolor tolerated).
    assert np.all(new[:,:,3][blue]==old[:,:,3][blue]),"ORIGINAL_BODY_PIXEL_DELETED"
    assert np.array_equal(new[-4:,:,3],old[-4:,:,3]),"FOOT_MISMATCH"
    # All boulders are BODY mounted, not leaf mounted. A small collective secondary
    # bob is added for Idle even when body centroid happens not to translate.
    body_x=body_cx+(-5 if direction==2 else 0)
    bob=frame if action=="Idle" else 0
    mount_x=int(np.clip(body_x,11,21))
    mount_y=int(np.clip(body_cy-3+bob,12,19))
    # Rock center geometry is stable relative to the ONE mount anchor. All rocks
    # move as a linked group and are part of the same back module.
    if middle:
      spec=[(-5,-3,3,3),(0,-6,4,3),(5,-3,3,3)]
    else:
      spec=[(-7,-3,4,3),(-4,-6,4,3),(0,-8,4,4),(4,-6,4,3),(7,-3,4,3)]
    # Shadowed continuous saddle contacts the actor's back, not a floating hat.
    img=Image.fromarray(new,"RGBA")
    d=ImageDraw.Draw(img)
    saddle_y=mount_y-1
    saddle_w=8 if middle else 10
    d.ellipse((mount_x-saddle_w,saddle_y-4,mount_x+saddle_w,saddle_y+3),
              fill=(49,53,58,255),outline=(26,29,34,255))
    rock_centers=[]
    for idx,(dx,dy,rx,ry) in enumerate(spec):
      cx=int(np.clip(mount_x+dx,rx+2,29-rx))
      cy=int(np.clip(mount_y+dy,ry+2,26-ry))
      rock_centers.append([cx,cy])
      bounds=(cx-rx,cy-ry,cx+rx,cy+ry)
      d.ellipse(bounds,fill=(26,31,36,255))
      base=[(80,87,93),(91,99,101),(110,114,112),(84,91,96),(103,108,109)][idx%5]
      d.ellipse((cx-rx+1,cy-ry+1,cx+rx-1,cy+ry-1),fill=(*base,255))
      d.arc((cx-rx+1,cy-ry+1,cx+rx-1,cy+ry-1),190,295,fill=(172,173,162,255),width=1)
      d.point((cx-1,cy-1),fill=(189,182,168,255))
      d.point((cx+1,cy+1),fill=(54,59,64,255))
    # Black caldera is genuinely behind/within the ring, orange glows on its inner floor.
    crater_x=mount_x
    crater_y=mount_y-5 if middle else mount_y-6
    d.ellipse((crater_x-2,crater_y-1,crater_x+2,crater_y+2),fill=(46,36,37,255))
    d.line((crater_x-1,crater_y+1,crater_x+1,crater_y+1),
           fill=(251,131 if middle else 174,41,255),width=1)
    if not middle:
      d.point((crater_x,crater_y),fill=(255,226,119,255))
      d.line([(crater_x+2,crater_y+2),(crater_x+3,crater_y+4)],
             fill=(245,112,30,255),width=1)
    made=np.asarray(img,dtype=np.uint8).copy()
    # Visual QA correction: detect and remove only tiny disconnected OLD PETAL outline
    # debris in the original upper ornamental zone; never erase any body cyan pixels.
    component_map,component_count=label(made[:,:,3]>0,structure=np.ones((3,3)))
    debris_removed=0
    for component in range(1,component_count+1):
      yy,xx=np.where(component_map==component)
      if not len(xx):continue
      old_debris=(len(xx)<=8 and int(yy.max())<body_cy-3
                  and not bool(np.any(blue[yy,xx]))
                  and int(yy.max())<28)
      if old_debris:
       made[yy,xx,:]=0
       debris_removed+=len(xx)
    # BODY is a protected alpha layer; never allow the orphan cleanup to remove it.
    assert np.all(made[:,:,3][blue]==255),(species,action,face,frame,"BODY_LOST_IN_DEBRIS_CLEANUP")
    # Avoid generating new pixels ON atlas cell borders (some original pixels already there).
    made[0,:,:]=new[0,:,:];made[-1,:,:]=new[-1,:,:]
    made[:,0,:]=new[:,0,:];made[:,-1,:]=new[:,-1,:]
    assert np.all(made[:,:,3][blue]==255),(species,action,face,frame,"BODY_ALPHA_DAMAGED")
    assert np.array_equal(made[-4:,:,3],old[-4:,:,3])
    # No fresh atlas-edge collision.
    assert not any(np.any(x) for x in (
       ((made[0,:,3]>0)&(old[0,:,3]==0)),
       ((made[-1,:,3]>0)&(old[-1,:,3]==0)),
       ((made[:,0,3]>0)&(old[:,0,3]==0)),
       ((made[:,-1,3]>0)&(old[:,-1,3]==0))))
    changes=int(np.count_nonzero(np.any(made!=old,axis=2)))
    assert changes>45
    # Connected under-saddle/new-rock mask includes center and reaches body-protected pixels.
    mask=made[:,:,3]>0
    dil=binary_dilation(blue,iterations=1)
    # Contact at least at some pixel of the new saddle ring around lower rim.
    back_contact=(mask & dil & (np.indices(mask.shape)[0]>=mount_y-5)&(np.indices(mask.shape)[0]<=mount_y+4)).sum()
    assert back_contact>=8,(species,action,direction,frame,"NO_BACK_CONTACT")
    # Keep original actor body exactly alpha-preserved. Prevent transparent source-body holes.
    original_alpha=old[:,:,3]>0;final_alpha=made[:,:,3]>0
    assert np.all(final_alpha[blue])
    # Record enough data for motion regression and review.
    entry={"action":action,"direction":direction,"orientation":face,"frame":frame,
           "source_body_bbox":[int(xs.min()),body_top,int(xs.max()),int(ys.max())],
           "source_body_centroid":[body_cx,body_cy],
           "mount":[mount_x,mount_y],"rock_centers":rock_centers,
           "body_pixels_preserved":int(blue.sum()),
           "body_pixels_erased":int(np.count_nonzero(blue & ~final_alpha)),
           "lower_foot_opaque_pixels_same":True,
           "changed_RGBA_pixels":changes,
           "back_contact_support_pixels":int(back_contact),
           "source_redgreen_upper_pixels_cleared":int(risk.sum()),
           "isolated_petal_debris_pixels_removed":debris_removed}
    n+=1;stats.append(entry);samples_action.append(entry)
    new_atlas[y0:y0+32,x0:x0+32]=made
    original_samples[(action,face,frame)]=Image.fromarray(old,"RGBA")
    output_samples[(action,face,frame)]=Image.fromarray(made,"RGBA")
  out=TARGET/f"{action}-Anim.png"
  Image.fromarray(new_atlas,"RGBA").save(out)
  assert Image.open(out).size==(128,256)
  by_action[action]=samples_action
 # Only Idle/Walk original action sheets copied as PARTIAL sample; the OTHER original 10 action sheets
 # are not touched and are NOT part of this deliverable.
 # No deleted original blue body pixels and original foot geometry confirmed in all 12 sample cells.
 assert n==12
 # Body-driven wobble test on all three directions: one or more mount/rock pixels move
 # between first two frames; we do not rely on original petal pose.
 for name in ("Idle","Walk"):
  for direction in sample_dirs:
   fs=[u for u in stats if u["action"]==name and u["direction"]==direction]
   assert len(fs)==2
   assert fs[0]["mount"]!=fs[1]["mount"],(species,name,direction,"BACK_MODULE_STATIC")
   for k in range(len(fs[0]["rock_centers"])):
    assert fs[0]["rock_centers"][k]!=fs[1]["rock_centers"][k],(species,name,direction,k,"STONE_FROZEN")
 # XML/shadow/offset unchanged. No entire full sheet claim.
 for p in SRC.iterdir():
  if p.name=="AnimData.xml" or p.name.endswith(("-Offsets.png","-Shadow.png")):
   assert (TARGET/p.name).read_bytes()==p.read_bytes()
 record["species"][species]={"sample_cells":n,"action_samples":["Idle","Walk"],
      "directions":sample_dirs,"body_erased_total":sum(q["body_pixels_erased"] for q in stats),
      "all_rock_modules_move_with_body":True,
      "XML_Offsets_Shadow_exact":True,
      "sample_atlas_128x256":True,
      "keyframes":stats,
      "total_original_full_sheet_frames_modified":"NOT_DONE_DO_NOT_MASS_PRODUCE"}
 (BASE/f"PMD_{species}_G7_KEYFRAME_QA.json").write_text(json.dumps(record["species"][species],ensure_ascii=False,indent=2),encoding="utf-8")
 # Human visual triptych original/new 3 facings and 2 sample frames for each Idle/Walk
 preview=Image.new("RGB",(1200,820),(29,34,39));d=ImageDraw.Draw(preview)
 d.text((18,12),f"P3 G7 PMD {species} / REAL SOURCE BODY / BODY-MOUNTED ROCK MODULE / SAMPLE ONLY",fill=(240,230,216))
 for ai,act in enumerate(("Idle","Walk")):
  d.text((18,44+ai*380),act+" — original and repaired sample, original frame sizes/positions",fill=(253,208,149))
  for di,(direction,face) in enumerate(sample_dirs.items()):
   for frame in (0,1):
    xx=24+di*392+frame*194
    yy=75+ai*382
    before=original_samples[(act,face,frame)].resize((128,128),Image.Resampling.NEAREST)
    after=output_samples[(act,face,frame)].resize((128,128),Image.Resampling.NEAREST)
    preview.paste(before,(xx,yy),before)
    preview.paste(after,(xx,yy+162),after)
    d.text((xx,yy+132),f"{face} f{frame}: UPSTREAM",fill=(190,218,184))
    d.text((xx,yy+295),f"{face} f{frame}: G7 ROCKS",fill=(249,202,137))
 preview.save(BASE/f"PMD_{species}_G7_ORIGINAL_VS_SAMPLE.png")
 # Loop actual two edited frames per selected 3 directions, foot and stone wobble shown in motion.
 for act in ("Idle","Walk"):
  frames=[]
  for fr in (0,1):
   gif=Image.new("RGB",(820,185),(30,35,40));dr=ImageDraw.Draw(gif)
   dr.text((10,7),f"PMD {species} {act} f{fr} — original facing front/side/back — ROCKS RIGID-BODY SWAY",fill=(236,229,212))
   for j,(direction,face) in enumerate(sample_dirs.items()):
    img=output_samples[(act,face,fr)].resize((128,128),Image.Resampling.NEAREST)
    x=12+j*260
    gif.paste(img,(x,29),img)
    dr.text((x,159),f"{face}",fill=(252,204,147))
   frames.append(gif)
  frames[0].save(BASE/f"PMD_{species}_{act}_G7_SAMPLE.gif",save_all=True,append_images=frames[1:],
                 duration=[175,175],loop=0,disposal=2,optimize=False)
print("G7_KEYFRAME_BUILD_SUCCESS",json.dumps({sp:{k:v for k,v in val.items() if k!="keyframes"} for sp,val in record["species"].items()},ensure_ascii=False),flush=True)
(BASE/"G7_SAMPLE_BUILD_REPORT.json").write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf-8")
