"""FS A21: exact-source runtime Ground/PAR; source ownership and depth pilot only.

No art is generated. Provenance masks and footpoint semantics require separate
human/VX review. The full original master stays byte-identical.
"""
from __future__ import annotations
import hashlib
import io
from dataclasses import dataclass
from typing import Iterable, Optional
from PIL import Image, ImageChops

ALLOWED = frozenset({'tree_canopy', 'roof_front_eave', 'bridge_near_rail', 'cliff_top'})
FORBIDDEN = frozenset({'grass','flower','path','bridge_deck','water','low_vegetation','shadow','ground'})

class OcclusionError(ValueError):
    pass

@dataclass(frozen=True)
class Layer:
    object_id: str
    semantic: str
    mask_png: bytes
    mask_sha256: str
    front_limit_y: int
    x_min: int
    x_max: int

def png_bytes(image: Image.Image) -> bytes:
    out = io.BytesIO()
    image.save(out, format='PNG', optimize=False)
    return out.getvalue()

def load_png(data: bytes, label: str) -> Image.Image:
    try:
        with Image.open(io.BytesIO(data)) as im:
            if im.format != 'PNG':
                raise OcclusionError(f'{label}: not PNG')
            return im.copy()
    except (OSError, ValueError) as exc:
        raise OcclusionError(f'{label}: invalid PNG') from exc

def _mask(layer: Layer, canvas: tuple[int,int]) -> Image.Image:
    if layer.semantic not in ALLOWED or layer.semantic in FORBIDDEN:
        raise OcclusionError(f'{layer.object_id}: unsafe foreground semantic {layer.semantic!r}')
    if not isinstance(layer.mask_sha256,str) or len(layer.mask_sha256) != 64:
        raise OcclusionError(f'{layer.object_id}: missing SHA lock')
    if hashlib.sha256(layer.mask_png).hexdigest() != layer.mask_sha256:
        raise OcclusionError(f'{layer.object_id}: SHA mismatch')
    im = load_png(layer.mask_png,layer.object_id)
    if im.mode not in ('L','RGBA') or im.size != canvas:
        raise OcclusionError(f'{layer.object_id}: full-canvas L/RGBA required')
    m = im if im.mode == 'L' else im.getchannel('A')
    hist = m.histogram()
    if sum(hist[1:255]) or not hist[255]:
        raise OcclusionError(f'{layer.object_id}: mask must contain nonempty binary alpha')
    if not 0 <= layer.x_min < layer.x_max <= canvas[0]:
        raise OcclusionError(f'{layer.object_id}: invalid x span')
    if not 0 <= layer.front_limit_y <= canvas[1]:
        raise OcclusionError(f'{layer.object_id}: invalid depth threshold')
    return m

def build(master_png: bytes, master_sha256: str, layers: Iterable[Layer],
          *, actor_foot: Optional[tuple[int,int]]=None,
          negative_mask_png: Optional[bytes]=None) -> tuple[bytes,bytes,dict]:
    """Return byte-identical master, source-same-XY PAR and technical QA.

    actor_foot=None yields an ALL-ON MASK CANDIDATE for static review only.
    A native RPG Maker VX integration must independently implement proper
    real_x/real_y, footpoint, switch203 and z ordering.
    """
    if hashlib.sha256(master_png).hexdigest() != master_sha256:
        raise OcclusionError('master SHA mismatch')
    master=load_png(master_png,'Master').convert('RGBA')
    w,h=master.size
    if w%32 or h%32 or master.getchannel('A').getextrema() != (255,255):
        raise OcclusionError('Master must be opaque 32px-grid canvas')
    layers=list(layers)
    if not layers or len({v.object_id for v in layers})!=len(layers):
        raise OcclusionError('nonempty unique owner manifest required')
    if actor_foot is not None and (len(actor_foot)!=2 or not all(isinstance(v,int) for v in actor_foot)):
        raise OcclusionError('actor footpoint must contain 2 integer world XY')
    union=Image.new('L',master.size,0)
    all_owner_union=Image.new('L',master.size,0)
    selected=[];inventory=[]
    for layer in layers:
        m=_mask(layer,master.size)
        if ImageChops.multiply(all_owner_union,m).getbbox():
            raise OcclusionError(f'{layer.object_id}: mask ownership overlap')
        all_owner_union=ImageChops.lighter(all_owner_union,m)
        active=(actor_foot is None or
                (layer.x_min<=actor_foot[0]<layer.x_max and actor_foot[1]<layer.front_limit_y))
        if active:
            union=ImageChops.lighter(union,m)
            selected.append(layer.object_id)
        inventory.append({'object_id':layer.object_id,'semantic':layer.semantic,
                          'mask_sha256':layer.mask_sha256,'pixels':m.histogram()[255],
                          'front_limit_y':layer.front_limit_y,'x_span':[layer.x_min,layer.x_max]})
    if negative_mask_png is not None:
        n=load_png(negative_mask_png,'negative zone').convert('L')
        if n.size != master.size:
            raise OcclusionError('negative mask canvas mismatch')
        if ImageChops.multiply(union,n).getbbox():
            raise OcclusionError('foreground intersects forbidden ground/deck region')
    par=Image.new('RGBA',master.size,(0,0,0,0))
    par.paste(master,(0,0),union)
    b=png_bytes(par)
    diff=ImageChops.difference(master.convert('RGB'),par.convert('RGB'))
    if ImageChops.multiply(diff,Image.merge('RGB',(union,union,union))).getbbox():
        raise OcclusionError('PAR source RGB differs at master XY')
    qa={'schema':'fs-a21-source-pixel-depth/v1','status':'PASS_STATIC_ONLY',
        'canvas':[w,h],'ground_bytes_unchanged':True,
        'master_sha256':master_sha256,'occlusion_sha256':hashlib.sha256(b).hexdigest(),
        'actor_footpoint':actor_foot,'selected_owner_ids':selected,
        'selected_alpha_pixels':union.histogram()[255],
        'source_same_xy_rgb_mismatch_pixels':0,'ownership':inventory,
        'semantic_art':'CANDIDATE_REQUIRES_REVIEW','vx_game_exe':'NOT_RUN',
        'native_switch_203':'NOT_RUN','art_pass':False}
    return master_png,b,qa

def overlay_actor(master_png: bytes, par_png: bytes, actor_png: bytes,
                  top_left: tuple[int,int]) -> bytes:
    """Static Pillow simulation, NEVER evidence of native VX runtime."""
    master=load_png(master_png,'Master').convert('RGBA')
    actor=load_png(actor_png,'actor').convert('RGBA')
    par=load_png(par_png,'PAR').convert('RGBA')
    if par.size != master.size:
        raise OcclusionError('PAR size mismatch')
    master.alpha_composite(actor,dest=top_left)
    master.alpha_composite(par)
    return png_bytes(master)
