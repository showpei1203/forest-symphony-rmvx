from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib
r=Path(__file__).resolve().parent
ALL={}
for sid in ('A_BLUE_COTTAGE','B_OCHRE_GROVE'):
    b=r/'build'/sid;g=r/'gpu'/sid
    gd=Image.open(b/'GROUND.png').convert('RGBA')
    pd=Image.open(b/'PAR.png').convert('RGBA')
    full=Image.open(b/'COMPOSITE.png').convert('RGB')
    ga=Image.open(g/'GROUND_GPU.png').convert('RGBA')
    pa=Image.open(g/'PAR_GPU.png').convert('RGBA')
    fa=Image.open(g/'FULL_GPU.png').convert('RGBA')
    result={}
    for key,a,c in [('ground',gd,ga),('par',pd,pa),('full',full,fa.convert('RGB'))]:
        a=np.asarray(a).astype('int16');c=np.asarray(c).astype('int16')
        diff=np.abs(a-c)
        result[key]={'different_pixels':int(np.any(diff!=0,axis=2).sum()),'max_channel_delta':int(diff.max()),'mae':round(float(diff.mean()),6)}
    source=np.array(pd.getchannel('A'))
    source_gpu=np.array(pa.getchannel('A'))
    result['gpu_par_border_nonzero']=int(np.sum(np.r_[source_gpu[0],source_gpu[-1],source_gpu[:,0],source_gpu[:,-1]]>0))
    result['par_alpha_exact']=bool(np.array_equal(source,source_gpu))
    result['transparent_gpu_pixels']=int(np.sum(source_gpu==0))
    result['layers_size_ok']=all(x.size==(544,416) for x in [gd,pd,ga,pa,fa])
    result['gpu_file_sha256']={name:hashlib.sha256((g/name).read_bytes()).hexdigest() for name in ['GROUND_GPU.png','PAR_GPU.png','FULL_GPU.png']}
    manifest=json.loads((b/'SCENE_MANIFEST.json').read_text(encoding='utf8'))
    result['trees']=[]
    for obj in manifest['objects']:
        if obj['layer']!='SPLIT_TREE32':continue
        rect=obj['contact_rect']
        base=np.asarray(Image.open(b/'TREE_CONTACT_MASK.png').getchannel('A'))
        # Only own one tree per scene.
        ys,xs=np.where(base>0)
        bbox=[int(xs.min()),int(ys.min()),int(xs.max()),int(ys.max())]
        result['trees'].append({'name':obj['id'],'allocated_rect':rect,'actual_opaque_bbox':bbox,'base_32tile_pass':len(set(xs//32))==1 and len(set(ys//32))==1,'base_pixel_count':int(len(xs))})
    ALL[sid]=result
print(json.dumps(ALL,indent=2))
(r/'evidence'/'STAGE12_GPU_PIXEL_QA.json').write_text(json.dumps(ALL,indent=2),encoding='utf8')