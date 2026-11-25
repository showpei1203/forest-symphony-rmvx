from pathlib import Path
import tempfile
from PIL import Image
from motion_pack import build,sha
# Explicit test-only provenance; never use existing real motion folders.
with tempfile.TemporaryDirectory() as t:
    t=Path(t);src=t/'test.txt';src.write_text('SYNTHETIC TEST FIXTURE ONLY')
    frames=[]
    for i in range(8):
        im=Image.new('RGBA',(64,64));im.paste((40+i,80,160,255),(12+i,24,24+i,50));p=t/f'{i}.png';im.save(p);frames.append(p)
    out=Path('motions/attack');build('attack',src,frames,[110,90,170,100,80,120,120,210],out,sha(src),[sha(p) for p in frames],source_class='SYNTHETIC_TEST_ONLY')
