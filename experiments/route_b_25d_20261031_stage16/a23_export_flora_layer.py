from pathlib import Path
import numpy as np,json,hashlib
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
A22=R if (R/'A22_CLEAN_STYLE_NATIVE128_VARIANT_01.png').is_file() else Path(r'E:\FS_ROUTE_B_STAGE16_A22_CLEAN_STYLE_AB_20261101')
cases=[]
for i in range(1,5):
 old=Image.open(A22/f'A22_CLEAN_STYLE_NATIVE128_VARIANT_{i:02d}.png').convert('RGBA')
 bg=Image.open(R/f'A23_QUILTED_GROUND_V{i:02d}_128.png').convert('RGBA')
 result=Image.open(R/f'A23_QUILT_PLUS_SAVED_BOTANICALS_V{i:02d}_128.png').convert('RGBA')
 a=np.asarray(old).copy();b=np.asarray(bg).copy();c=np.asarray(result).copy()
 changed=np.any(b[:,:,:3]!=c[:,:,:3],axis=2)
 o=np.zeros_like(a);o[changed]=a[changed]
 o[:,:,3]=changed.astype('uint8')*255
 overlay=Image.fromarray(o,'RGBA')
 name=f'A23_AI_BOTANICAL_OVERLAY_RGBA_V{i:02d}.png'
 overlay.save(R/name)
 composed=Image.alpha_composite(bg,overlay)
 assert np.array_equal(np.asarray(composed),c)
 # Ensure no false claim of PAR: this is semantic flora overlay, not character occlusion layer.
 sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
 cases.append({'variant':i,'filename':name,'foreground_opaque_pixels':int(changed.sum()),'overlaid_fraction':round(float(changed.mean()),4),'sha256':sha(R/name),
               'exact_alpha_composite_equals_A23_merged':True,'layer_role':'GROUND_DECORATION_CANDIDATE_NOT_PAR'})
(R/'A23_INDEPENDENT_FOREGROUND_LAYER_QA.json').write_text(json.dumps({'stage':'A23','layer_semantics':'diagnostic decoration mask only, not PAR/occlusion or collision','complete_cases':cases,'formal_seal':'NO'},indent=2),encoding='utf8')
print('A23_SEPARATE_BOTANICAL_RGBA_LAYER_PASS',json.dumps(cases),flush=True)
