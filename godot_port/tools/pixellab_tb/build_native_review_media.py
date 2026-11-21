from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
A=Path(__file__).resolve().parent/'artifacts';indir=A/'native_frames'
frames=[Image.open(indir/f'GODOT_NATIVE_V5_{i:02d}.png').convert('RGB') for i in range(11)]
# Saved screenshots are actual Godot OpenGL-Compatibility output, not Pillow composites.
durations=[4,2,4,2,2,2,2,2,2,2,4]
for fname,speed in [('PMD0001_V5_GODOT_NATIVE_11F_REALTIME.gif',1.0),('PMD0001_V5_GODOT_NATIVE_11F_SLOW_REVIEW.gif',2.7)]:
 ms=[max(40,round(t*1000/60*speed)) for t in durations]
 frames[0].save(A/fname,save_all=True,append_images=frames[1:],duration=ms,loop=0,disposal=2,optimize=False)
# Whole native screenshot cropped to actual viewport region, labels outside cropped frames.
rows=3;cols=4;CW,CH=360,305
out=Image.new('RGB',(cols*CW,rows*CH),(28,30,35))
d=ImageDraw.Draw(out)
stages=['NEUTRAL','CROUCH','RUSH','LEAP','BITE WINDUP','HIT','FOLLOW','RETURN','LAND','RECOVER','NEUTRAL END']
for i,im in enumerate(frames):
 x=(i%4)*CW;y=(i//4)*CH
 crop=im.crop((70,110,410,355))
 # Native output is rendered 4x at source, no scaling up.
 out.paste(crop,(x+10,y+10))
 d.text((x+14,y+265),f'F{i:02d}  {stages[i]}',fill=(235,238,239))
 d.text((x+14,y+283), 'Godot 4.7.2 real PNG / OpenGL llvmpipe',fill=(148,160,166))
out.save(A/'PMD0001_V5_GODOT_NATIVE_11F_CONTACT.png')
print('OK native review GIF/contact')
