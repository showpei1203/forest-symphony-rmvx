from PIL import Image
from pathlib import Path
import hashlib
root=Path(__file__).resolve().parent
sheet=Image.open(root/'provider'/'A38_PIXELLAB_ORIGINAL_3X2_SHEET.png').convert('RGBA')
f3=sheet.crop((0,64,64,128))
p=root/'assets'/'A38_R2_SUBTLE_INHALE_TARGET_G3.png'
f3.save(p)
print('R2_TARGET_SHA256='+hashlib.sha256(p.read_bytes()).hexdigest())
print('R2_TARGET_PIXELS='+str(f3.size))
