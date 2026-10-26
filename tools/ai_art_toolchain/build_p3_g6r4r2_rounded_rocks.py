from pathlib import Path
from PIL import Image, ImageDraw
import json, shutil, numpy as np, xml.etree.ElementTree as ET, hashlib
from scipy.ndimage import binary_dilation, label
ROOT=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
OUT=ROOT/"outputs/P3_G6R4R2_0002_0003_ROUNDED_SWAY_STONES_20261026"
assert not OUT.exists(),"Never overwrite an existing art candidate"
OUT.mkdir(parents=True)
summaries={}
for species in ("0002","0003"):
    full=species=="0003"
    SR=ROOT/f"outputs/P3_G{'4' if not full else '5'}_{species}_OFFICIAL_SOURCE_20261026/SOURCE_{species}"
    target=OUT/f"PMD_{species}_ROUND_STONES"
    target.mkdir()
    for p in SR.iterdir():
        if p.name=="AnimData.xml" or p.name.endswith(("-Offsets.png","-Shadow.png")):shutil.copy2(p,target/p.name)
    root=ET.parse(SR/"AnimData.xml").getroot()
    motions=root.findall(".//Anim")
    counts=0;shifts=[];records=[];cropped=0;material=0
    for motion in motions:
        if motion.findtext("CopyOf"):continue
        name=motion.findtext("Name")
        w,h=int(motion.findtext("FrameWidth")),int(motion.findtext("FrameHeight"))
        width=len(motion.find("Durations").findall("Duration"))
        image=np.asarray(Image.open(SR/(name+"-Anim.png")).convert("RGBA"))
        assert image.shape[1]==w*width and image.shape[0]%h==0
        rows=image.shape[0]//h
        modified=image.copy()
        detail=[]
        for row in range(rows):
            for k in range(width):
                old=image[row*h:(row+1)*h,k*w:(k+1)*w].copy()
                rgb=old[:,:,:3].astype(np.int32)
                solid=old[:,:,3]>0
                leaf=solid&(rgb[:,:,1]>rgb[:,:,0]*1.13)&(rgb[:,:,1]>rgb[:,:,2]*1.2)&(rgb[:,:,1]>73)&(rgb[:,:,0]<190)
                flower=solid&(rgb[:,:,0]>110)&(rgb[:,:,0]>rgb[:,:,1]*1.35)&(rgb[:,:,1]<145)&(rgb[:,:,2]<130)
                yy,xx=np.where(leaf)
                fy,fx=np.where(flower)
                assert len(xx)>=9 and len(fx)>=6,(species,name,row,k,"MISSING_LEAF_OR_FLOWER")
                # Source motion anchors derived PER FRAME from flower/leaf positions, not fixed artificial sine waves.
                crown_x=int(np.median(fx));min_red=int(fy.min())
                crown_y=int(min_red+1)
                base_x=int(np.median(xx));leaf_top=int(yy.min());leaf_bottom=int(yy.max())
                upper_flower=flower&(np.indices(flower.shape)[0] <=leaf_bottom+1)
                bud_y,bud_x=np.where(upper_flower)
                if len(bud_x)<4:bud_y,bud_x=fy,fx
                crown_x=int(np.median(bud_x))
                crown_y=max(3,min(h-11,int(np.quantile(bud_y,.25))+1))
                # Recolor source body to orange/ash but without retaining green or red flower-petal surfaces.
                b=old.copy()
                blue=solid&(rgb[:,:,2]>rgb[:,:,0]*1.04)&(rgb[:,:,1]>=rgb[:,:,0]*.93)&(rgb[:,:,0]>=55)
                bright=blue&(rgb[:,:,0]>=125)
                b[bright,:3]=[219,147,109] if not full else [224,145,97]
                b[blue&~bright,:3]=[148,119,111] if not full else [143,110,105]
                # True semantic removal: the original leaf/petal pixels are no longer colored shapes.
                # Erase only raised upper flower and its leaves, not orange face/feet at lower y.
                erase=leaf|upper_flower
                erase=binary_dilation(erase,iterations=1)
                # Never eat belly / feet.
                erase &= np.indices(erase.shape)[0] <= min(h-10,max(leaf_bottom+1,crown_y+6))
                b[erase,:]=0
                img=Image.fromarray(b,"RGBA")
                draw=ImageDraw.Draw(img)
                # Track the actual original leaf-tip motion: every stone shares original petal anchor,
                # but stone centers differ in size and offset so it reads as boulder cluster, NOT flower.
                left=np.where(leaf&(np.indices(leaf.shape)[1]<crown_x))
                right=np.where(leaf&(np.indices(leaf.shape)[1]>=crown_x))
                def group_xy(indices, fallback):
                    ys,xs=indices
                    if len(xs)<3:return fallback
                    return (int(np.median(xs)),int(np.median(ys)))
                L=group_xy(left,(crown_x-5,crown_y+4))
                R=group_xy(right,(crown_x+5,crown_y+4))
                # Backwards/forwards pose naturally moves crown: these are NOT canvas-fixed coords.
                center_x=max(8,min(w-9,crown_x))
                top=max(3,min(h-11,min(leaf_top,min_red)+1))
                limit_y=min(h-8,leaf_bottom+1)
                if limit_y<top+6:limit_y=top+6
                # Stage2 uses 3 rounded boulders + glowing center, stage3 5 uneven rounded boulders.
                # Keep rocks small enough to leave the frog's body recognizable at original 1x.
                if full:
                    stones=[
                      (max(4,L[0]-2),min(limit_y,L[1]),3,3,"dark"),
                      (max(4,center_x-5),min(limit_y,top+6),4,3,"light"),
                      (min(w-5,center_x+5),min(limit_y,top+5),4,3,"mid"),
                      (min(w-5,R[0]+2),min(limit_y,R[1]+1),3,3,"dark"),
                      (center_x+(-1 if k%2==0 else 1),max(4,top+2),3,2,"light")
                    ]
                else:
                    stones=[
                      (max(4,L[0]-1),min(limit_y,L[1]),3,3,"dark"),
                      (min(w-5,R[0]+1),min(limit_y,R[1]),3,3,"mid"),
                      (center_x,max(4,top+2),3,2,"light")
                    ]
                # Shadow behind separated circles. This shades magma caldera while keeping rocks chunky.
                ccy=min(h-10,top+(5 if full else 4))
                crad=4 if full else 3
                draw.ellipse((center_x-crad,ccy-2,center_x+crad,ccy+3),
                             fill=(40,38,39,255),outline=(18,27,31,255))
                draw.ellipse((center_x-crad+1,ccy-1,center_x+crad-1,ccy+1),
                             fill=(153,47,27,255))
                draw.line((center_x-2,ccy,center_x+2,ccy),
                          fill=(255,169 if full else 135,45,255),width=1)
                # Draw each distinct small spherical rock using edge outline, low-right shadows and light top-left facets.
                rock_locations=[]
                for index,(rx,ry,rw,rh,tone) in enumerate(stones):
                    rx=int(max(rw+2,min(w-rw-3,rx)))
                    ry=int(max(rh+2,min(h-rh-7,ry)))
                    # Source petal wiggle enters as moving leaf and flower centers in each original frame.
                    tx=(rx-rw,ry-rh,rx+rw,ry+rh)
                    draw.ellipse(tx,fill=(33,38,43,255))
                    inner=(tx[0]+1,tx[1]+1,tx[2]-1,tx[3]-1)
                    pal={"dark":(75,85,92,255),"mid":(94,103,107,255),"light":(110,118,119,255)}
                    draw.ellipse(inner,fill=pal[tone])
                    draw.arc((tx[0]+1,tx[1]+1,tx[2]-1,tx[3]-1),180,290,fill=(173,174,163,255),width=1)
                    # Uneven offset glints make mineral surface, not monochrome petals.
                    draw.point((rx-1,ry-1),fill=(153,156,148,255))
                    draw.point((rx+1,ry+1),fill=(50,57,61,255))
                    rock_locations.append([rx,ry])
                # Expose crater *between* rocks as an opening, not a literal red flower center.
                draw.ellipse((center_x-2,ccy-1,center_x+2,ccy+2),
                            fill=(42,33,33,255))
                draw.line((center_x-1,ccy+1,center_x+1,ccy+1),
                          fill=(251,138 if full else 103,29,255),width=1)
                if full:
                    # Thin overflow along a rock margin, not a triangular petal.
                    draw.line([(center_x+2,ccy+1),(center_x+3,ccy+3),(center_x+4,ccy+5)],
                              fill=(240,100,31,255),width=1)
                    draw.point((center_x+3,ccy+2),fill=(255,204,80,255))
                new=np.asarray(img,dtype=np.uint8).copy()
                assert new.shape==old.shape
                # Preserve original bounding-cell borders as fixed XML coordinates.
                new[0,:,:]=old[0,:,:];new[-1,:,:]=old[-1,:,:]
                new[:,0,:]=old[:,0,:];new[:,-1,:]=old[:,-1,:]
                # R4 self-review ART FAIL: 0003 retained isolated dark petal-outline pixels
                # above the new stones. Remove only tiny detached flecks in the crown zone.
                labeled,num=label(new[:,:,3]>0)
                for comp in range(1,num+1):
                    cy,cx=np.where(labeled==comp)
                    if len(cx)<=7 and len(cx)>0 and int(cy.max())<=min(7,min_red+2) and abs(int(np.median(cx))-center_x)<=12:
                        new[cy,cx,:]=0
                # Ensure some original torso/feet art remains, not walking stones.
                # Foot contact source remains unchanged at bottom 4 original pixels.
                assert np.array_equal(new[-4:,:,3],old[-4:,:,3]),(species,name,row,k,"FOOT_ALPHA")
                for A,C in ((old,new),):
                    assert not np.any((C[0,:,3]>0)&(A[0,:,3]==0))
                    assert not np.any((C[-1,:,3]>0)&(A[-1,:,3]==0))
                    assert not np.any((C[:,0,3]>0)&(A[:,0,3]==0))
                    assert not np.any((C[:,-1,3]>0)&(A[:,-1,3]==0))
                nc=int(np.count_nonzero(np.any(new!=old,axis=2)))
                assert nc>=18,(species,name,row,k,"NOT_TRANSFORMED",nc)
                hot=(new[:,:,0]>230)&(new[:,:,1]>80)&(new[:,:,1]<215)&(new[:,:,2]<130)&(new[:,:,3]>0)
                assert int(hot.sum())>=2,(species,name,row,k,"NO_VISIBLE_LAVA")
                modified[row*h:(row+1)*h,k*w:(k+1)*w]=new
                counts+=1;material+=nc
                detail.append({"direction":row,"frame":k,"source_original_flower_centroid":[crown_x,crown_y],
                              "source_leaf_group_centers":[list(L),list(R)],
                              "rounded_boulders":rock_locations,
                              "changed_rgba_pixels":nc,"lava_pixels":int(hot.sum())})
        Image.fromarray(modified,"RGBA").save(target/(name+"-Anim.png"))
        assert Image.open(target/(name+"-Anim.png")).size==(w*width,h*rows)
        records.append({"action":name,"frame_dimensions":[w,h],"frame_count":len(detail),"motion_instances":detail})
    expected=698 if full else 682
    assert counts==expected,(species,counts,expected)
    for original in SR.iterdir():
        if original.name=="AnimData.xml" or original.name.endswith(("-Offsets.png","-Shadow.png")):
            assert original.read_bytes()==(target/original.name).read_bytes()
    summary={"pmD_id":species,"source":str(SR),"motions":12,"XML_names":14,"total_frames":counts,
             "changed_RGBA_pixels":material,"XML_Offsets_Shadow_byte_exact":True,
             "round_boulders_per_frame":5 if full else 3,
             "sway_tracks_actual_source_petal_leaf_centroids":True,
             "unchanged_original_duration_and_atlas_layout":True,
             "actor_body_source_pixels_kept":True,
             "human_visual":"PENDING","real_PMD_runtime":"NOT_TESTED",
             "record":records}
    (OUT/f"PMD_{species}_ROUND_STONES_QA.json").write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding="utf-8")
    summaries[species]={k:v for k,v in summary.items() if k!="record"}
    # Actual original vs changed contact sheet 8 directions for Idle and Attack
    sheet=Image.new("RGB",(1080,680),(28,34,40));d=ImageDraw.Draw(sheet)
    for ii,name in enumerate(("Idle","Attack")):
        meta=next(x for x in records if x["action"]==name)
        w,h=meta["frame_dimensions"]
        for typ,folder in enumerate((SR,target)):
            atlas=Image.open(folder/(name+"-Anim.png")).convert("RGBA")
            for row in range(8):
                pic=atlas.crop((0,row*h,w,(row+1)*h)).resize((w*3,h*3),Image.Resampling.NEAREST)
                x=10+row*132;y=23+ii*330+typ*156
                sheet.paste(pic,(x,y),pic)
            d.text((10,4+ii*330+typ*156),f"{species} {name} " + ("UPSTREAM PMD" if typ==0 else "NEW ROUND BASALT SWAY"),fill=(245,226,205))
    sheet.save(OUT/f"PMD_{species}_ORIGINAL_VS_ROUND_ROCKS.png")
(OUT/"G6R4_ACTUAL_ROUND_BASALT_BUILD.json").write_text(json.dumps(summaries,ensure_ascii=False,indent=2),encoding="utf-8")
# User-approved 0001 remains completely untouched.
print("G6R4_SOURCE_BUILD",json.dumps(summaries,ensure_ascii=False),flush=True)
