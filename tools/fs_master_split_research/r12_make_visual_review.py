#!/usr/bin/env python3
"""Author-only diagnostic sheets; never claim this visual QA counts as native game screenshot."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
R=Path(__file__).resolve().parent
D=R/"R12_NEW_ELF_VILLAGE_001"
N=R/"R12_NEW_ELF_VILLAGE_NATIVE"/"NATIVE"
k=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
arr=[("01 NEW SOURCE MASTER","MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"),
 ("02 PAR14 SEMANTIC PINK COVERAGE","R12_PAR_PINK_COVERAGE_QA.png"),
 ("03 PAR14 SOURCE RGB TRANSPARENT","PAR_R12_VX_SELECTED14_SOURCE_ONLY.png"),
 ("04 COLLISION CANDIDATE GRID","R12_COLLISION_GRID_CANDIDATE_QA.png")]
# The selected14 coverage preview must be recomputed from selected PAR, not from R12 all18.
source=Image.open(D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png").convert("RGB")
foreground=Image.open(D/"PAR_R12_VX_SELECTED14_SOURCE_ONLY.png").convert("RGBA")
overlay=source.copy()
orig=source.load();o=overlay.load();a=foreground.getchannel("A")
for y in range(928):
 for x in range(1280):
  if a.getpixel((x,y)):
   r,g,b=orig[x,y]
   o[x,y]=((r*6+255*4)//10,(g*6+20*4)//10,(b*6+175*4)//10)
overlay.save(D/"R12_SELECTED14_PINK_COVERAGE_QA.png")
arr[1]=("02 SELECTED14 PINK COVERAGE","R12_SELECTED14_PINK_COVERAGE_QA.png")
sheet=Image.new("RGB",(1300,990),(21,25,31));draw=ImageDraw.Draw(sheet)
for idx,(label,f) in enumerate(arr):
 x=(idx%2)*650;y=(idx//2)*495
 img=Image.open(D/f).convert("RGBA")
 back=Image.new("RGBA",img.size,(30,33,40,255));back.alpha_composite(img)
 thumb=back.convert("RGB").resize((640,464),Image.Resampling.NEAREST)
 sheet.paste(thumb,(x+5,y+25))
 draw.text((x+14,y+7),label,fill=(240,240,242))
sheet.save(D/"R12_MASTER_PAR_COLLISION_4PANEL_QA.png")
# Ground unmodified, only separate actor-scaling screenshot for perspective check.
actor=Image.open(k/"Graphics"/"Characters"/"$001.png").convert("RGBA")
assert actor.size==(96,128)
# left row: third-facing frame (middle 32x32)
frame=actor.crop((32,0,64,32))
preview=source.convert("RGBA")
for foot in [(570,700),(352,400),(986,765),(776,540)]:
 x,y=foot;preview.alpha_composite(frame,(x-16,y-32))
preview.convert("RGB").save(D/"R12_SCALE_QA_32PX_ACTOR_4SPOTS.png")
# Native gallery: cropped source image from two actual screen positions; note original FS HUD/Lighting persists.
labels=["R12_PLAZA_WEST","R12_CHAPEL_WALL","R12_EAST_BRIDGE","R12_NPC_WALK"]
gallery=Image.new("RGB",(1100,860),(21,24,29));pen=ImageDraw.Draw(gallery)
for i,l in enumerate(labels):
 im=Image.open(N/(l+".png")).convert("RGB")
 x=(i%2)*550;y=(i//2)*430
 gallery.paste(im,(x,y+18))
 pen.text((x+8,y+4),l+" | actual Windows Game.exe / FS HUD is visible",fill="white")
gallery.save(D/"R12_REAL_NATIVE_VX_4SCENE_GALLERY.png")
print("R12_VISUAL_REVIEW_CONTACT_READY","4panel",sheet.size,"actor",preview.size,"native",gallery.size,flush=True)