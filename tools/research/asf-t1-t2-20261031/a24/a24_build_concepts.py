"""A24 SOURCE-FIRST concept art only: REAL original pixels, no PixelLab calls."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from collections import Counter
import hashlib, json
A23=Path(r"E:\GameAssetToolLab_20261023\A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST")
OUT=Path(r"E:\GameAssetToolLab_20261023\A24_SOURCE_FIRST_ART_APPROVAL")
OUT.mkdir(exist_ok=True)
srcp=A23/"PIXELLAB_INPUTS"/"PMD0001_LAVAFROG_MASTER_SE45_64.png"
srcf=A23/"FS_ACTOR01_NATIVE"/"$actor01.png"
original_p=Image.open(srcp).convert("RGBA")
original_f=Image.open(srcf).convert("RGBA")
assert original_p.size==(64,64) and original_f.size==(96,128)
def rgba(hex):return (*bytes.fromhex(hex),255)
def polygon(draw,points,c):draw.polygon(points,fill=rgba(c))
def line(draw,points,c,w=1):draw.line(points,fill=rgba(c),width=w)
BLACK="111A22"; ASH="263039"; SHADE="354650"; SLATE="53626B"
HOT="F5C05C"; LAVA="F46F30"; GLINT="FFE293"; ORANGE="CC4826"
def pmd_concept(style):
  # True G9 source is always the base, not a newly invented creature.
  back=Image.new("RGBA",(64,64));d=ImageDraw.Draw(back)
  if style=="volcano":
    # Raised jagged volcano shell: new silhouette / species anatomy.
    polygon(d,[(21,30),(20,25),(23,21),(23,18),(26,18),(28,13),(31,14),(32,19),(35,20),(36,27)],BLACK)
    polygon(d,[(24,25),(24,20),(27,19),(28,15),(30,16),(30,21),(33,22),(34,27)],SHADE)
    polygon(d,[(27,15),(29,14),(31,16),(30,18),(27,18)],ORANGE)
    line(d,[(27,16),(29,15),(30,17)],GLINT)
    # Molten smoke/glow (not a particle cloud detached from body)
    polygon(d,[(20,26),(19,22),(21,20),(23,24)],SLATE)
    polygon(d,[(36,29),(39,25),(41,25),(43,30)],BLACK)
  else:
    # Horned salamander/frog design: two branching basalt horns and a crest.
    polygon(d,[(22,32),(18,28),(18,23),(20,24),(21,18),(24,23),(26,20),(27,16),(30,21),(34,25),(35,31)],BLACK)
    polygon(d,[(19,24),(21,20),(22,25),(24,27)],SLATE)
    polygon(d,[(27,20),(28,17),(30,23),(32,26)],SLATE)
    polygon(d,[(24,28),(28,21),(31,24),(36,29)],SHADE)
    # Orange glow at roots of three-point basalt crest
    line(d,[(23,28),(26,24),(28,25)],LAVA)
    line(d,[(28,28),(30,24),(32,27)],HOT)
  back.alpha_composite(original_p)
  d=ImageDraw.Draw(back)
  if style=="volcano":
    # Shell armor visibly extends over original back, with cracks and lava veins
    polygon(d,[(22,28),(25,24),(29,26),(32,24),(35,27),(35,31),(32,34),(27,33),(23,31)],BLACK)
    polygon(d,[(24,28),(27,26),(29,28),(27,31),(24,30)],SHADE)
    polygon(d,[(30,27),(33,26),(34,29),(32,31),(29,30)],SLATE)
    line(d,[(27,26),(29,29),(31,30),(33,33)],ORANGE)
    line(d,[(27,26),(29,28)],GLINT)
    # Horned brow and a clearly armored cheek on the orange head
    polygon(d,[(37,29),(40,25),(42,28),(44,28),(43,34),(40,32)],BLACK)
    polygon(d,[(39,29),(40,27),(42,30)],SLATE)
    polygon(d,[(39,36),(42,35),(44,37),(42,39)],ASH)
    line(d,[(41,37),(43,36)],HOT)
    polygon(d,[(22,37),(19,39),(19,42),(23,41)],BLACK)
    polygon(d,[(33,41),(35,44),(38,44),(36,41)],BLACK)
  else:
    # Completely different outline: forked face horns, broad spiky obsidian collar
    polygon(d,[(22,26),(25,22),(27,25),(31,23),(35,26),(37,32),(33,35),(26,33),(21,31)],BLACK)
    polygon(d,[(24,28),(28,25),(31,28),(29,31)],SLATE)
    line(d,[(24,30),(27,28),(30,30),(33,29)],LAVA)
    polygon(d,[(37,30),(40,24),(42,26),(41,30)],BLACK)
    polygon(d,[(42,31),(45,27),(46,32),(44,35)],BLACK)
    line(d,[(40,27),(41,26)],HOT)
    polygon(d,[(35,38),(39,40),(43,42),(40,43),(35,41)],ASH)
    line(d,[(37,40),(40,41)],ORANGE)
    polygon(d,[(21,37),(18,40),(19,43),(23,41)],BLACK)
  # Fixed luminous pupil and bright under-throat; more than just recolor
  d.point((39,34),fill=rgba(GLINT))
  d.point((40,34),fill=rgba(BLACK))
  line(d,[(35,39),(37,40),(40,39)],HOT)
  # Native XML 32x40 tile must contain all modified pixels.
  assert back.getbbox() and back.getbbox()[0]>=16 and back.getbbox()[1]>=12
  assert back.getbbox()[2]<=48 and back.getbbox()[3]<=52,back.getbbox()
  return back
hair_map={
 (244,244,244):"A6E3F1",(223,223,223):"73B5D3",
 (172,168,168):"355F87",(121,117,113):"203F61"
}
fabric_map={
 (167,139,89):("B1D9EE","FFBD74"),
 (133,109,63):("5579AB","AF3F39"),
 (99,76,42):("263D73","7D253D"),
 (66,49,23):("1B2853","601C34"),
 (54,38,10):("141D3B","45162A"),
 (50,49,49):("253451","4A2235"),
 (21,21,21):("17212E","271820")
}
def recolor_source(frame,style):
  p=frame.load()
  for y in range(32):
    for x in range(32):
      r,g,b,a=p[x,y]
      if a==0:continue
      rgb=(r,g,b)
      if rgb in hair_map:
        if style=="ember":
          rem={ (244,244,244):"FFD1A5",(223,223,223):"E66D50",
                (172,168,168):"8E2A37",(121,117,113):"56233D" }
          p[x,y]=rgba(rem[rgb])
        else:p[x,y]=rgba(hair_map[rgb])
      elif rgb in fabric_map:
        p[x,y]=rgba(fabric_map[rgb][0 if style=="aether" else 1])
  return frame
def fs_frame(source,style,row,col):
  fr=recolor_source(source.copy(),style)
  under=Image.new("RGBA",(32,32));d=ImageDraw.Draw(under)
  if style=="aether": cloak="203758"; trim="51B7C9"; silver="D1E6F0"; metal="3D5773"; gold="F2D085"
  else:cloak="572139";trim="F48A3C";silver="F1B08B";metal="704055";gold="F8D46D"
  # Distinct, newly drawn floor-length cape linked to the shoulders.
  if row==0:  # front
    polygon(d,[(9,20),(13,18),(20,18),(24,21),(26,31),(8,31)],cloak)
    line(d,[(9,21),(8,30),(12,31)],trim)
    line(d,[(23,22),(26,30),(23,31)],trim)
  elif row==1: # left
    polygon(d,[(12,19),(19,19),(20,27),(17,31),(6,31),(10,25)],cloak)
    line(d,[(10,23),(7,30),(14,31)],trim)
  elif row==2: # right
    polygon(d,[(11,19),(19,20),(20,26),(14,31),(5,31),(8,25)],cloak)
    line(d,[(11,22),(7,29),(12,30)],trim)
  else: # back
    polygon(d,[(10,17),(24,17),(27,31),(7,31)],cloak)
    polygon(d,[(13,19),(23,19),(25,30),(9,30)],metal)
    line(d,[(10,22),(8,30),(25,30)],trim)
  under.alpha_composite(fr)
  d=ImageDraw.Draw(under)
  # Distinct plate shoulder/armour geometry on top of original garments.
  if row==0:
    polygon(d,[(7,19),(12,18),(15,21),(13,24),(8,23)],silver)
    polygon(d,[(21,19),(26,18),(28,21),(26,24),(22,23)],silver)
    line(d,[(8,20),(11,19),(13,21)],metal)
    line(d,[(23,20),(26,20)],metal)
    polygon(d,[(14,21),(20,21),(21,26),(14,27)],metal)
    line(d,[(16,22),(18,23),(16,25)],trim)
    d.point((18,23),fill=rgba(gold))
    line(d,[(12,28),(23,28)],trim)
  elif row==1:
    polygon(d,[(9,18),(15,17),(18,20),(16,24),(10,23)],silver)
    polygon(d,[(13,22),(21,21),(23,25),(17,29),(12,28)],metal)
    line(d,[(15,23),(17,25),(19,24)],trim)
    line(d,[(12,29),(22,29)],trim)
    d.point((17,25),fill=rgba(gold))
  elif row==2:
    polygon(d,[(12,18),(19,18),(22,21),(21,24),(13,23)],silver)
    polygon(d,[(16,22),(25,21),(27,25),(21,29),(15,28)],metal)
    line(d,[(18,23),(21,25),(23,24)],trim)
    line(d,[(15,29),(24,29)],trim)
    d.point((21,25),fill=rgba(gold))
  else:
    polygon(d,[(10,18),(15,19),(13,23),(8,22)],silver)
    polygon(d,[(22,19),(26,18),(28,22),(23,23)],silver)
    line(d,[(16,22),(19,23),(17,28)],trim)
    d.point((19,24),fill=rgba(gold))
  # Hem and plated boots to change garment outline in all facing directions
  line(d,[(12,30),(15,30)],metal)
  line(d,[(19,30),(22,30)],metal)
  return under
pmdA=pmd_concept("volcano")
pmdB=pmd_concept("horned")
pmdA.save(OUT/"A24_PMD0001_VOLCANIC_TOAD_A_64.png")
pmdB.save(OUT/"A24_PMD0001_HORNED_LAVAFROG_B_64.png")
for n,im in [("A",pmdA),("B",pmdB)]:
 im.crop((16,12,48,52)).save(OUT/f"A24_PMD0001_{n}_NATIVE_IDLE_32x40.png")
fsouts={}
for style in ["aether","ember"]:
 sheet=Image.new("RGBA",(96,128))
 for row in range(4):
  for col in range(3):
   frm=original_f.crop((32*col,32*row,32*(col+1),32*(row+1)))
   painted=fs_frame(frm,style,row,col)
   sheet.alpha_composite(painted,(col*32,row*32))
 fsouts[style]=sheet
 sheet.save(OUT/f"A24_FS_ACTOR01_{style.upper()}_NATIVE_WALK_96x128.png")
 # A23 battle seed exact row2 middle column; this is its fully transformed outfit
 frame=sheet.crop((32,64,64,96))
 battle=Image.new("RGBA",(64,64))
 battle.alpha_composite(frame,(16,19))
 d=ImageDraw.Draw(battle)
 if style=="aether":
   # New luminous rune blade, separate from the old A23 sword: hilt+guard
   line(d,[(41,40),(46,34)],"C99D4E",2)
   line(d,[(43,35),(48,38)],"182A4E",2)
   polygon(d,[(46,34),(55,19),(57,17),(56,23),(48,36)],"2B6884")
   line(d,[(47,34),(55,20)],"B8F5F4")
   line(d,[(54,22),(55,19)],"FFFFFF")
 else:
   # A different weapon: infernal curved blade with an orange heated cutting edge
   line(d,[(42,41),(46,36)],"543039",2)
   line(d,[(44,36),(49,37)],"F8D46D",2)
   polygon(d,[(47,36),(53,30),(56,19),(57,17),(58,23),(55,32),(49,38)],"6B3442")
   line(d,[(48,35),(54,30),(57,20)],"FCBC59")
 battle.save(OUT/f"A24_FS_ACTOR01_{style.upper()}_BATTLE_SOURCE_64.png")
# Numeric source lineage and pixel-changing metrics
stats={}
def delta(a,b):
 assert a.size==b.size
 pa=list(a.getdata());pb=list(b.getdata())
 n=sum(x!=y for x,y in zip(pa,pb))
 return dict(changed_pixels=n,total_pixels=len(pa),changed_pct=round(100*n/len(pa),2),
             source_opaque=sum(x[3]>0 for x in pa),new_opaque=sum(x[3]>0 for x in pb),
             bbox=b.getbbox())
for lab,im in [("pmd_A",pmdA),("pmd_B",pmdB)]:stats[lab]=delta(original_p,im)
for lab,im in fsouts.items():stats["fs_"+lab]=delta(original_f,im)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
# Contact sheet with large pixel-crisp previews and source images, no interpolated blur.
def stamp(page,img,x,y,w,h,label):
 d=ImageDraw.Draw(page)
 d.rectangle((x,y,x+w,y+h),fill=(235,238,241),outline=(172,182,191))
 for j in range(y+20,y+h-5,24):
  for i in range(x+6,x+w-5,24):
   if ((i-x)//24+(j-y)//24)%2==0:d.rectangle((i,j,i+23,j+23),fill=(249,249,249))
 factor=max(1,min((w-20)//img.width,(h-45)//img.height))
 vis=img.resize((img.width*factor,img.height*factor),Image.Resampling.NEAREST)
 px=x+(w-vis.width)//2
 py=y+25+max(0,(h-45-vis.height)//2)
 page.paste(vis,(px,py),vis)
 d.text((x+9,y+6),label,fill=(20,35,48))
 return factor
page=Image.new("RGB",(1200,790),"#F9FAFB")
# PMD comparison top row: zoom 4x and 6x
stamp(page,original_p,15,15,375,365,"PMD G9 ORIGINAL / source")
stamp(page,pmdA,410,15,375,365,"PMD A / volcano-armored toad")
stamp(page,pmdB,805,15,375,365,"PMD B / twin-horn lava frog")
# FS side view baseline and two altered battle refs
old=Image.open(A23/"PIXELLAB_INPUTS"/"FS_ACTOR01_45_BATTLE_SWORD_EDIT_CANDIDATE_64.png").convert("RGBA")
stamp(page,old,15,405,375,365,"FS ORIGINAL + A23 SWORD")
stamp(page,Image.open(OUT/"A24_FS_ACTOR01_AETHER_BATTLE_SOURCE_64.png"),410,405,375,365,"FS A / aether runeblade")
stamp(page,Image.open(OUT/"A24_FS_ACTOR01_EMBER_BATTLE_SOURCE_64.png"),805,405,375,365,"FS B / ember knight")
page.save(OUT/"A24_TWO_CHARACTERS_ART_APPROVAL_CONTACT.png")
# 3x4 FS original vs two completely redesigned full sheets
walk=Image.new("RGB",(1110,610),"#F7F8FA")
stamp(walk,original_f,10,10,350,580,"FS ORIGINAL 3x4")
stamp(walk,fsouts["aether"],375,10,350,580,"A / AETHER FULL 3x4")
stamp(walk,fsouts["ember"],740,10,350,580,"B / EMBER FULL 3x4")
walk.save(OUT/"A24_FS_FULL_3x4_STYLE_COMPARISON.png")
audit={
 "stage":"A24 SOURCE FIRST - ART CONCEPT, NOT ANIMATED, NOT YET APPROVED",
 "source_paths":{"pmd":str(srcp),"fs":str(srcf)},
 "source_sha256":{"pmd":sha(srcp),"fs":sha(srcf)},
 "native_geometry":{"pmd_idle":[32,40],"fs_actor_walk_sheet":[96,128],"fs_frames":[32,32]},
 "source_compatibility":{"pmd_xml":"not modified","pmd_offsets":"not modified","pmd_shadow":"not modified",
 "fs_originals":"not modified","fs_action_1_2_3":"not modified, must be reworked only after visual approval"},
 "angle_status":"FS battle is original right-facing row2 with painted costume and sword; 45-degree southeastern NOT APPROVED",
 "status":{"concept":"READY FOR USER VISUAL REVIEW","pixelLab":"BLOCKED UNTIL EXPLICIT USER APPROVAL","credits_spent_this_stage":0,"game_integration":"NOT STARTED"},
 "changed_pixels":stats,
 "revised_design_rules":["Original sprite must remain provable source","Silhouette changes required for PMD; no palette-only variants",
 "FS complete equipment/hair/cape/weapon redesign in full 3x4 walk sheet","Never submit unapproved art to PixelLab",
 "Never claim 45 degree correct before review","PMD XML and offset shadow geometry remain unchanged"]
}
(OUT/"A24_ART_APPROVAL_MANIFEST.json").write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"stage":"A24","files":[x.name for x in OUT.iterdir() if x.suffix.lower()==".png"],
  "stats":stats,"source_hashes":audit["source_sha256"],"credit_use":0},ensure_ascii=False,indent=2))
