#!/usr/bin/env python3
from PIL import Image,ImageDraw
from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parent;A=R/'artifacts';P=R/'native_capture'
raw=[Image.open(P/f'GODOT_TB_V6_{i:02}.png').convert('RGB') for i in range(11)]
thumb_w,thumb_h=320,340
board=Image.new('RGB',(4*thumb_w,3*thumb_h),(23,27,32));d=ImageDraw.Draw(board)
for i,img in enumerate(raw):
 crop=img.crop((48,24,432,408)).resize((320,320),Image.Resampling.NEAREST)
 x=(i%4)*thumb_w;y=(i//4)*thumb_h
 board.paste(crop,(x,y));d.text((x+10,y+320),f'GODOT 4.7.2 NATIVE F{i:02}',fill=(245,245,245))
board.save(A/'PMD0001_V6_PIXELLAB_GODOT_NATIVE_11F_CONTACT.png')
frames=[im.resize((320,320),Image.Resampling.NEAREST) for im in [r.crop((48,24,432,408)) for r in raw]]
# Small static source metadata as durations in 60Hz ticks, correct for F2/F5/F7 event offsets.
durations=[67,33,67,33,33,33,33,33,33,33,67]
frames[0].save(A/'PMD0001_V6_PIXELLAB_GODOT_NATIVE_REALTIME.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2,optimize=False)
frames[0].save(A/'PMD0001_V6_PIXELLAB_GODOT_NATIVE_SLOW.gif',save_all=True,append_images=frames[1:],duration=[350]*11,loop=0,disposal=2,optimize=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report={'captured_by':'Godot 4.7.2 / Mesa llvmpipe x11 OpenGL Compatibility','native_screenshots':11,'capture_sizes':[im.size for im in raw], 'contact_sha256':h(A/'PMD0001_V6_PIXELLAB_GODOT_NATIVE_11F_CONTACT.png'),'realtime_sha256':h(A/'PMD0001_V6_PIXELLAB_GODOT_NATIVE_REALTIME.gif'),'slow_sha256':h(A/'PMD0001_V6_PIXELLAB_GODOT_NATIVE_SLOW.gif')}
(R/'qa'/'V6_NATIVE_RENDER_MANIFEST.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print(json.dumps(report,indent=2))
