from pathlib import Path
import json, math, hashlib
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
blueprint = json.loads((ROOT/"A12_ECOLOGICAL_BLUEPRINT.json").read_text(encoding="utf8"))
W,H = blueprint["canvas"]
assert (W,H)==(544,416)
rng = np.random.default_rng(blueprint["seed"])
inputname = "A12_INPUT_A10_BENCHMARK_GROUND_544x416.png"
source_file=ROOT/inputname
assert hashlib.sha256(source_file.read_bytes()).hexdigest()=="20bb55e2b9212b45204a885cb34c0a59ba77fa2e5d0c0754d8eb62a956e33e5a"
with Image.open(source_file) as im: original=np.asarray(im.convert("RGB"),dtype=np.uint8).copy()
with Image.open(ROOT/"A12_INPUT_A10_BENCHMARK_ROAD_MASK_544x416.png") as im:road=np.asarray(im.convert("L"))>0
with Image.open(ROOT/"A12_INPUT_A10_BENCHMARK_EDGE_BAND_544x416.png") as im:edge=np.asarray(im.convert("L"))>0
protected=road|edge
editable=~protected
assert int(road.sum())==44321 and int(edge.sum())==3328 and not (road&edge).any()

def noise_field(px, seed):
    local=np.random.default_rng(seed)
    gw=int(math.ceil(W/px))+4;gh=int(math.ceil(H/px))+4
    small=np.clip(local.normal(127,45,(gh,gw)),0,255).astype("uint8")
    im=Image.fromarray(small,"L").resize((gw*px,gh*px),Image.Resampling.BICUBIC)
    sample=np.asarray(im.crop((px,px,px+W,px+H)),dtype="float64")
    return (sample-sample.mean())/(sample.std()+1e-6)

y,x=np.mgrid[:H,:W]
large=noise_field(67,120131)
mid=noise_field(24,120132)
fine=noise_field(9,120133)
distortion=0.18*large+0.08*mid+0.045*fine
types=("dense","dry","flower")
weights={key:np.zeros((H,W),dtype="float64") for key in types}
zoneinfo=[]
for zone in blueprint["zones"]:
    cx,cy=zone["center"];aw,ah=zone["axes"]
    angle=math.radians(zone["rotation"])
    co,si=math.cos(angle),math.sin(angle)
    dx=x-cx;dy=y-cy
    u=(dx*co+dy*si)/aw;v=(-dx*si+dy*co)/ah
    radial=np.sqrt(u*u+v*v)
    shape=np.clip((1.14-radial+distortion)*2.5,0.,1.)*float(zone["strength"])
    weights[zone["type"]]=np.maximum(weights[zone["type"]],shape)
    zoneinfo.append({"id":zone["id"],"kind":zone["type"],"center_px":zone["center"],"effective_nonzero_editable_px":int(np.count_nonzero((shape>.15)&editable))})
dense=weights["dense"]
dry=weights["dry"]
flowers=weights["flower"]
# Explicitly divide competing cover intensity to avoid artificial painted shapes.
dense=np.clip(dense*(1-.40*dry),0,1)
dry=np.clip(dry*(1-.48*dense),0,1)
flora=np.clip(flowers*(.4+.60*dense),0,1)
delta=np.zeros((H,W,3),dtype="float64")
delta+=dense[:,:,None]*np.array([-16.,+8.,-7.])
delta+=dry[:,:,None]*np.array([+28.,-8.,+9.])
delta+=flora[:,:,None]*np.array([-6.,+6.,+3.])
# Apply low frequency ecological tints, no blur of the A10 material samples.
composite=np.clip(original.astype("float64")+delta,0,255).astype("uint8")
out=original.copy();out[editable]=composite[editable]
tint_image=out.copy()

# 1–4px flush-to-ground leaf groups. Positions are conditional on semantic cluster intensity.
leaf_pixels=np.zeros((H,W),dtype=bool)
flower_pixels=np.zeros((H,W),dtype=bool)
soil_pixels=np.zeros((H,W),dtype=bool)
leaf_clusters=[]
flower_clusters=[]
soil_clusters=[]

def safe_paint(xx,yy,rgb,pixel_mask):
    if not (0<=xx<W and 0<=yy<H and editable[yy,xx]):return False
    out[yy,xx]=np.clip(np.array(rgb,dtype="float64"),0,255).astype("uint8")
    pixel_mask[yy,xx]=True
    return True

# Weighted sampling means real semantic placement rather than uniform scatter.
def weighted_positions(weight,count,seed,margin=5,sep=3):
    local=np.random.default_rng(seed)
    valid=weight.copy()
    valid[~editable]=0
    valid[:margin,:]=0;valid[-margin:,:]=0;valid[:,:margin]=0;valid[:,-margin:]=0
    flat=(valid**1.8).ravel()
    flat_sum=flat.sum()
    assert flat_sum>0
    prob=flat/flat_sum
    choice=local.choice(H*W,size=min(H*W,count*4),replace=True,p=prob)
    selected=[];occupancy=np.zeros((H,W),dtype=bool)
    for idx in choice:
        yy=int(idx//W);xx=int(idx%W)
        y1=max(0,yy-sep);y2=min(H,yy+sep+1)
        x1=max(0,xx-sep);x2=min(W,xx+sep+1)
        if occupancy[y1:y2,x1:x2].any():continue
        occupancy[yy,xx]=True
        selected.append((xx,yy))
        if len(selected)==count:break
    return selected

for i,(px,py) in enumerate(weighted_positions(dense,1150,120134,sep=2)):
    leaf_clusters.append((px,py))
    c=out[py,px].astype("float64")
    shadow=c+np.array([-26.,-3.,-12.])
    light=c+np.array([+12.,+15.,-3.])
    # Small 1–4px grass substrate strokes (not upright shrub or vegetation object).
    strokes=[(px,py,shadow),(px+1,py,light)]
    if i%3==0:strokes.append((px+2,py-1,light))
    if i%5==0:strokes.append((px-1,py,shadow))
    for xx,yy,rgb in strokes:safe_paint(xx,yy,rgb,leaf_pixels)

for i,(px,py) in enumerate(weighted_positions(flora,160,120135,sep=5)):
    flower_clusters.append((px,py))
    variants=([236,223,151],[225,230,185],[211,213,175],[242,198,118])
    petal=variants[i%len(variants)]
    # Each individual group is 2–3px flat ground petals, non-stacked.
    points=[(px,py),(px+1,py)]
    if i%4==0:points.append((px,py+1))
    for xx,yy in points:safe_paint(xx,yy,petal,flower_pixels)

for i,(px,py) in enumerate(weighted_positions(dry,540,120136,sep=3)):
    soil_clusters.append((px,py))
    c=out[py,px].astype("float64")
    dirt=c+np.array([+22.,+4.,+6.])
    dark=c+np.array([-18.,-14.,-8.])
    for xx,yy,rgb in ([(px,py,dirt),(px+1,py,dark)] if i%3 else [(px,py,dirt)]):
        safe_paint(xx,yy,rgb,soil_pixels)

assert np.array_equal(out[protected],original[protected])
assert all(not np.any(mask & protected) for mask in (leaf_pixels,flower_pixels,soil_pixels))
def save_rgb(name,arr):Image.fromarray(arr,"RGB").save(ROOT/name)
def save_mask(name,arr):Image.fromarray((np.clip(arr,0,1)*255).astype("uint8"),"L").save(ROOT/name)
save_rgb("A12_ECOLOGICAL_CLUSTERS_544x416.png",out)
save_rgb("A12_TINT_ONLY_544x416.png",tint_image)
save_mask("A12_DENSE_BLUEPRINT_MASK.png",dense)
save_mask("A12_DRY_BLUEPRINT_MASK.png",dry)
save_mask("A12_FLOWER_BLUEPRINT_MASK.png",flora)
save_mask("A12_LEAF_PIXELS_MASK.png",leaf_pixels)
save_mask("A12_FLOWER_PIXELS_MASK.png",flower_pixels)
save_mask("A12_SOIL_PIXELS_MASK.png",soil_pixels)
save_mask("A12_PROTECTED_MASK.png",protected)
diff=np.any(original!=out,axis=2)
def sha(name):return hashlib.sha256((ROOT/name).read_bytes()).hexdigest()
manifest={"stage":"A12","date":"2026-10-31","input_a10_sha256":sha(inputname),"output_sha256":sha("A12_ECOLOGICAL_CLUSTERS_544x416.png"),"resolution":[W,H],"blueprint_zones":len(blueprint["zones"]),"seed":blueprint["seed"],"road_pixels":int(road.sum()),"edge_pixels":int(edge.sum()),"protected_changed_pixels":int(np.count_nonzero(diff&protected)),"editable_pixels":int(editable.sum()),"editable_changed_pixels":int(np.count_nonzero(diff&editable)),"dense_blueprint_px":int(np.count_nonzero((dense>.55)&editable)),"dry_blueprint_px":int(np.count_nonzero((dry>.55)&editable)),"flower_blueprint_px":int(np.count_nonzero((flora>.55)&editable)),"leaf_groups":len(leaf_clusters),"leaf_pixels":int(leaf_pixels.sum()),"flower_groups":len(flower_clusters),"flower_pixels":int(flower_pixels.sum()),"soil_groups":len(soil_clusters),"soil_pixels":int(soil_pixels.sum()),"zone_coverage":zoneinfo,"technical":"PENDING_COLD","art":"FAIL_INTERNAL_VISUAL_GROUND3","godot":"NOT_RUN","vx":"NOT_RUN","formal_seal":"NO","model_family":"deterministic pixel-space semantic blueprint; NOT neural"}
(ROOT/"A12_EXECUTION_MANIFEST.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
print("A12_GENERATED",json.dumps({k:v for k,v in manifest.items() if k!="zone_coverage"},ensure_ascii=False,indent=2),flush=True)
