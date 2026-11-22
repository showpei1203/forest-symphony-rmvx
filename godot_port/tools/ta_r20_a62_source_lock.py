from pathlib import Path
import os
import shutil
import json, hashlib, zipfile, io, xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(os.environ.get('FS_A62_SOURCE_DIR', './private_inputs'))
OUT=Path(os.environ.get('FS_R20_OUTPUT_DIR', './private_outputs/R20_A62_SOURCE_LOCK'))
OUT.mkdir(exist_ok=True)
SRC=ROOT/'A62_SOURCE_F0_48.png'
RAW=ROOT/'A62_PROVIDER_RAW_F0.png'
assert SRC.exists() and RAW.exists()
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
source=Image.open(SRC).convert('RGBA')
raw=Image.open(RAW).convert('RGBA')
assert source.size == (48,48)
assert sha(SRC)=='0ca4ce9f55a718882b801114602c14e3d288ea4371806fe8afcb3d9b64510c37'
assert len(set(source.getchannel('A').getdata())) == 2
# WARNING: these are visible pixel OWNERSHIP masks taken entirely from the
# single complete raster; NOT real upstream LPC armour / fabric component layers.
layer_names=['hair_face_visible','far_sleeve_visible','near_sleeve_visible',
             'torso_and_abdomen_original','belt_and_waist_original',
             'trousers_original','boots_original']
layers={name:Image.new('RGBA',(48,48)) for name in layer_names}
pix_src=source.load(); pix_layers={k:v.load() for k,v in layers.items()}
for y in range(48):
 for x in range(48):
  c=pix_src[x,y]
  if c[3]==0:continue
  if y<=25:label='hair_face_visible'
  elif y>=39:label='boots_original'
  elif y>=36:label='trousers_original'
  elif x<=20:label='far_sleeve_visible'
  elif x>=32:label='near_sleeve_visible'
  elif y>=33 and 21<=x<=31:label='belt_and_waist_original'
  else:label='torso_and_abdomen_original'
  pix_layers[label][x,y]=c
full=Image.new('RGBA',(48,48))
for name in layer_names:full.alpha_composite(layers[name])
assert full.tobytes()==source.tobytes(), 'Pixel owner decomposition altered A62 F0!'
# Export source authority + 7 disjoint ownership masks.
shutil.copyfile(SRC,OUT/'A62_ORIGINAL_FULLBODY_SOURCE_F0_48.png')
shutil.copyfile(RAW,OUT/'A62_PROVIDER_RAW_F0_48_UNAPPROVED.png')
full.save(OUT/'R20_PIXEL_EXACT_RECOMPOSED_F0_48.png')
layer_counts={}
for idx,name in enumerate(layer_names):
 p=OUT/f'L{idx+1:02d}_{name}.png';layers[name].save(p)
 layer_counts[name]={'source_exact_alpha_pixels':sum(q[3]!=0 for q in layers[name].getdata()),'sha256':sha(p)}
assert sum(x['source_exact_alpha_pixels'] for x in layer_counts.values())==sum(q[3]!=0 for q in source.getdata())
# Not real native paper doll: source visible pixels only and hidden parts unpainted.
# Draw 1x and 6x contact. A62 source remains unchanged in the leftmost cell.
thumbs=[('SOURCE ORIGINAL',source)]+[(name.replace('_',' ').upper()[:23],layers[name]) for name in layer_names]+[('COMPOSITE EXACT',full)]
for scale in [1,6]:
 s=48*scale; margin=6
 bg=Image.new('RGBA',(len(thumbs)*s, s+26),(27,30,35,255));d=ImageDraw.Draw(bg)
 for i,(title,im) in enumerate(thumbs):
  tile=im.resize((s,s),Image.Resampling.NEAREST)
  bg.alpha_composite(tile,(s*i,26))
  d.text((s*i+2,6),title if scale==6 else str(i),fill=(242,245,241,255))
 bg.convert('RGB').save(OUT/f'R20_SOURCE_LAYER_OWNERSHIP_{scale}X.png')
# OpenRaster compatible, but EXPLICITLY classed as a visible-pixel dissection,
# not an LPC complete set of hidden semantic pose-ready apparel modules.
ora=OUT/'R20_A62_F0_EXACT_VISIBLE_PIXEL_OWNERSHIP_NOT_TRUE_MODULAR_LPC.ora'
Image.new('RGBA',(48,48)).save(OUT/'_transparent.png')
stack=ET.Element('image',{'version':'0.0.3','w':'48','h':'48','name':'R20 A62 source-exact visible pixel layers','xres':'72','yres':'72'})
st=ET.SubElement(stack,'stack',{'name':'visible_source_only','opacity':'1','visibility':'visible','composite-op':'svg:src-over'})
# OpenRaster specifies topmost first in stack.xml.
for idx,name in reversed(list(enumerate(layer_names))):
 ET.SubElement(st,'layer',{'name':name+' (VISIBLE SOURCE PIXELS ONLY)',
 'src':f'data/layer{idx}.png','x':'0','y':'0','opacity':'1','visibility':'visible','composite-op':'svg:src-over'})
xml=b'<?xml version="1.0" encoding="UTF-8"?>\n'+ET.tostring(stack,encoding='utf-8')
def png_bytes(im):
 b=io.BytesIO();im.save(b,format='PNG');return b.getvalue()
with zipfile.ZipFile(ora,'w') as z:
 z.writestr('mimetype','image/openraster',compress_type=zipfile.ZIP_STORED)
 z.writestr('stack.xml',xml)
 for idx,name in enumerate(layer_names):z.writestr(f'data/layer{idx}.png',png_bytes(layers[name]))
 z.writestr('mergedimage.png',png_bytes(full))
 z.writestr('Thumbnails/thumbnail.png',png_bytes(full))
with zipfile.ZipFile(ora) as z:
 assert z.testzip() is None
 o=ET.fromstring(z.read('stack.xml'))
 assert len(o.find('stack').findall('layer'))==7
 assert Image.open(io.BytesIO(z.read('mergedimage.png'))).convert('RGBA').tobytes()==source.tobytes()
report={
 'asset':'FS ACTOR01 A62 source-only full-body F0, not official approved outfit-component library',
 'source':'FS_A62_NATURAL_RUN_3FRAMES_GIF_QA_HANDOFF_20261102.zip / A62_SOURCE_F0_48.png',
 'source_drive_file_id':'OWNER_PRIVATE_A62_SOURCE_ZIP',
 'source_sha256':sha(SRC),
 'original_source_dimensions':[48,48],
 'source_opaque_pixels':sum(p[3]!=0 for p in source.getdata()),
 'provider_F0_sha256':sha(RAW),
 'provider_source_F0_identical':False,
 'source_to_provider_rgba_diff_pixels':sum(a!=b for a,b in zip(source.getdata(),raw.getdata())),
 'reassembled_48RGBA_exact':True,
 'reassembled_sha256':sha(OUT/'R20_PIXEL_EXACT_RECOMPOSED_F0_48.png'),
 'layer_counts':layer_counts,
 'complete_modular_lpc_source_verified':False,
 'layer_type':'single-raster visible-pixel dissection, NO original underpaint / NO source-LPC individual clothing items',
 'art_status':'R20_BASELINE_ONLY_NOT_NEW_ART',
 'official_attack_pose':'BLOCKED: missing source-compatible original 45degree attack clothing and hidden pixels',
 'source_paperdoll_modules':{
 'head':'A62 F0 full raster visible head, historical identity candidate',
 'body':'A62 F0 full raster visible torso, not isolated upstream body source',
 'torso_outfit':'NOT_VERIFIED independent same-pose source',
 'near_arm_outfit':'NOT_VERIFIED independent same-pose source',
 'far_arm_outfit':'NOT_VERIFIED independent same-pose source',
 'pants':'NOT_VERIFIED independent same-pose source',
 'boots':'NOT_VERIFIED independent same-pose source',
 'weapon':'NOT_GENERATED; independent Tankentai SBS',
 'fx':'NOT_GENERATED'},
 'not_done':['new 5 hand-drawn attack keyframes','true LPC source clothing composites','Godot battle integration','human artistic approval']}
(OUT/'R20_SOURCE_PROVENANCE_AUDIT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
readme='''# FS T-A R20 — A62 FULL BODY 原始像素保真基準，非正式 LPC 裝備紙娃娃\n\n從 2026-11-02 A62 私人 Drive ZIP 取回實際 48×48 F0 全身原圖。R19 的多邊形肚子不使用、不修補。\n\n本實驗按可見區域拆成 7 張原像素所有權遮罩，且合成後與 F0 **完整 RGBA 每像素相同**。\n每張圖都只複製原 F0 對應 RGB/Alpha，沒有畫新腰帶、衣服、腹部、鞋或手。\n已輸出 OpenRaster .ora 可在 Krita/Aseprite/LibreSprite 支援環境中編修。\n\n**重要：這不是完整 LPC 紙娃娃換裝素材！** 原 raster 沒有被衣物遮住的底下身體、衣服前後完整紋理、獨立肩袖/鞋的原始遮蔽像素。若直接轉骨架會產生空洞，嚴禁把 ORA 稱為 45° 原生 ATTACK／正式 ART PASS。\n\n還需同姿勢同方向的 base_body/torso_outfit/near_far arms/pants/boots 真正來源部件，或經核准走 A62 F0 Master source-first 局部重新繪圖工法。來源缺件前維持 SOURCE_LAYER_BLOCKED，R16-R19 ART_REJECTED。\n\n源 48px 與先前使用的 64px 參考圖並未確認為單純加框關係，不得不經轉換就拿 64px 覆蓋。\n\n所有檔案僅保存私人 Drive，GitHub 不放人物原始 PNG。\n'''
(OUT/'README_R20_SOURCE_LOCK.md').write_text(readme,encoding='utf-8')
# Package complete source + verifier, no new attack claims.
pack=Path(os.environ.get('FS_R20_ZIP_PATH', str(OUT.parent/'FS_TA_R20_A62_SOURCE_EXACT_7VISIBLE_LAYER_AUDIT_20261122.zip')))
with zipfile.ZipFile(pack,'w',zipfile.ZIP_DEFLATED) as z:
 for p in sorted(OUT.iterdir()):
  if p.is_file() and p.name!='_transparent.png':z.write(p,p.name)
with zipfile.ZipFile(pack) as z:
 assert z.testzip() is None
 print('ZIP',pack,pack.stat().st_size,'members',len(z.namelist()),'SHA',sha(pack))
print('REPORT',json.dumps({k:report[k] for k in ['source_sha256','source_opaque_pixels','source_to_provider_rgba_diff_pixels','reassembled_48RGBA_exact','complete_modular_lpc_source_verified','art_status']},ensure_ascii=False))
