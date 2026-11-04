from pathlib import Path
from PIL import Image,ImageDraw
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
left=Image.open(S/"A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png").convert("RGBA")
patch=left.crop((143,55,278,245))
patch.save(S/"A36G_R5_LEFT_HOUSE_MATERIAL_STYLE_PATCH_RGBA.png",optimize=True)
s=(R/"r5_pixellab_right_house.py").read_text("utf8")
repl=[
 ('left=S/"A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png"',
  'left=S/"A36G_R5_LEFT_HOUSE_MATERIAL_STYLE_PATCH_RGBA.png"'),
 ('Image.open(left).size==(284,259)','Image.open(left).size==(135,190)'),
 ("A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_RGBA.png","A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png"),
 ("A36G_R5_PIXELLAB_RIGHT_HOUSE_UNIFIED_R1_SUBMISSION_LOCK.json","A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_SUBMISSION_LOCK.json"),
 ("A36G_R5_STYLE_UNIFIED_RIGHT_R1","A36G_R5_STYLE_UNIFIED_RIGHT_R2"),
 ('"image_size":{"width":198,"height":236}','"image_size":{"width":256,"height":272}'),
 ('"target_size":[198,236]','"target_size":[256,272]'),
 ('im.size!=(198,236)','im.size!=(256,272)'),
 ('"seed":360721','"seed":360722'),
]
for a,b in repl:
 assert a in s,a
 s=s.replace(a,b)
start=s.index('PROMPT="""')
end=s.index('"""',start+10)+3
NEW='''PROMPT="""Create a completely new ORIGINAL small fantasy ELF VILLAGE COTTAGE as ONE WHOLE NON-CROPPED isolated RPG Maker VX pixel-art environmental building sprite. Exactly match the visual MATERIAL language of the reference STYLE PATCH: soft golden olive moss and leaf-thatch individual hand-pixeled highlights, natural uneven eaves, warm brown half-timber framing, visible cream plaster sections, stone moss foundation, inviting amber wooden door and sunlit shadowed 3/4 top-down southeast-facing perspective. The STYLE PATCH is ONLY for artistic texture, color grading, and shading. It is NOT a complete house, and you MUST NOT try to extend or reproduce its architecture! The SUBJECT reference old right cottage is ONLY for centered front door position and compact standalone single-house proportions; replace all its flat green conical roof and low detail. DISTINCT ARCHITECTURE from the separate large left house: one narrow unified volume with ONE SIMPLE STEEP GABLE ROOF and one ridge line, no attached side wing, no workroom, NO SECOND ROOF, NO roof valley. Attractive rustic stone-and-timber elf dwelling with one roof, front door near lower center, one small square window, subtle timber wood cross bracing, tiny short chimney optional. Highly sophisticated clustered 1-3 pixel shading and texture density equal to supplied native source, no flat shaded polygons, no gradients, no soft blur. Full building entirely contained within source image with 15-22 PIXELS TRANSPARENT EMPTY MARGIN ON ALL FOUR SIDES, including entire roof, any chimney and BOTH SIDE WALLS, so NOTHING is cut off at left, right, top or bottom edges. Compose a single unique full-body house at approximately 214 pixels wide and 232 pixels tall INSIDE a 256x272 transparent canvas. Roof slopes show depth and real overlap with wall, not a flat triangle. No humans, no grass, no scenery, no duplicated buildings, no isolated objects, no lettering. ONE independent single-source transparent RGBA coherent sprite; do not assemble or paste multiple pieces."""'''
s=s[:start]+NEW+s[end:]
s=s.replace('"ABSOLUTE visual art direction: exact golden moss leafy gable, warm timber, stone blocks, 3/4 perspective, expressive high detail and clean pixel clusters of LEFT newly approved house. Generate a smaller unique sister house."',
            '"Only material texture of left house: moss-gold detailed pixels, carved timber frame, cream plaster, moss stone, 3/4 perspective, shading. No architecture copying, it is cropped patch."')
s=s.replace('"ONLY approximate source 198x236 frame, proportions and middle front DOOR location so the new structure remains on the original path. DO NOT copy old shape, palette, flat cone roof or weak art."',
            '"Very rough one-volume right cottage composition and near-center front door reference. Generate distinct new gabled roof perspective, do not copy flat green old roof."')
(R/"r5_pixellab_right_house_r2.py").write_text(s,"utf8")
print("R2 prepared",len(s),"style patch",patch.size)
