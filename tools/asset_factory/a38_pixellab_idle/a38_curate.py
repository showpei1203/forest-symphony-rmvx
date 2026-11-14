from PIL import Image,ImageDraw
from pathlib import Path
import shutil,hashlib,json
root=Path(__file__).resolve().parent
private=root.parent
engine=private/'FS_A38_GODOT_BATTLE_RUN_IDLE_20261114'
assets=engine/'assets'
assets.mkdir(parents=True,exist_ok=True)
src=Image.open(root/'assets'/'actor01_idle_a38_8phases.png').convert('RGBA')
r2=Image.open(root/'assets'/'actor01_idle_a38_r2_8phases.png').convert('RGBA')
assert src.size==r2.size==(256,128)
shutil.copy2(root/'assets'/'actor01_idle_a38_8phases.png',assets/'actor01_idle_r1_raw_8phases.png')
shutil.copy2(root/'assets'/'actor01_idle_a38_r2_8phases.png',assets/'actor01_idle_r2_raw_8phases.png')
# Deliberately filter the two wildly moving intermediate frames G1/G2. All source RGBA pixels remain original.
# 8 playback slots, just 3 genuinely different preexisting R1 poses. This is curating, not regeneration.
orig=[src.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64)) for i in range(5)]
indices=[0,0,3,3,4,4,3,0]
sheet=Image.new('RGBA',(256,128),(0,0,0,0))
for i,j in enumerate(indices):sheet.paste(orig[j],((i%4)*64,(i//4)*64))
out=assets/'actor01_idle_r1_calm_curated_8phases.png'
sheet.save(out)
# Keep curated provenance strict
assert sheet.crop((0,0,64,64)).tobytes()==orig[0].tobytes()
assert len({im.tobytes() for im in [orig[j] for j in indices]})==3
for path in assets.glob('actor01_idle_*.png'):print('A38_ENGINE_INPUT',path.name,path.stat().st_size,hashlib.sha256(path.read_bytes()).hexdigest())
report={'curated_indices_from_first_five_R1':[0,0,3,3,4,4,3,0],'8_slots':8,'unique_RGBA_poses':3,'method':'lossless selection of original Pixellab R1 frames only; no new poses synthesized','R2_wide_steps':'REJECTED ART HOLD','R1_G1_G2_upper_body_motion':'REJECTED ART HOLD','source_first_exact':True}
(root/'A38_CURATION_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
