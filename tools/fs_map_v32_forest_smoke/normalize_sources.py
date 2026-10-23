from PIL import Image, ImageChops
from pathlib import Path
import hashlib, json
ROOT = Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
SRC = ROOT/"sources"
S = {}
def check(name, image, origin, usage):
    image.save(SRC/name)
    im = Image.open(SRC/name).convert("RGBA")
    assert im.size == image.size
    S[name] = {"origin":origin,"usage":usage,"dimensions":list(im.size),"sha256":hashlib.sha256((SRC/name).read_bytes()).hexdigest()}
    print(name,im.size,im.getchannel("A").getextrema())
def crop_clean(source, coords, max_island=0):
    im = Image.open(SRC/source).convert("RGBA").crop(coords)
    im.putalpha(im.getchannel("A").point(lambda a:255 if a>=128 else 0))
    if max_island:
        a=im.getchannel("A"); px=a.load(); w,h=im.size
        visited=set(); islands=[]
        for y in range(h):
            for x in range(w):
                if px[x,y]==0 or (x,y) in visited: continue
                stack=[(x,y)]; visited.add((x,y)); component=[]
                while stack:
                    cx,cy=stack.pop();component.append((cx,cy))
                    for nx,ny in ((cx-1,cy),(cx+1,cy),(cx,cy-1),(cx,cy+1)):
                        if 0<=nx<w and 0<=ny<h and px[nx,ny] and (nx,ny) not in visited:
                            visited.add((nx,ny));stack.append((nx,ny))
                islands.append(component)
        if islands:
            major=max(islands,key=len)
            for island in islands:
                if island is not major and len(island)<=max_island:
                    for x,y in island:px[x,y]=0
        im.putalpha(a)
    return im
grass=Image.open(SRC/"grass_reference_96.png").convert("RGBA").crop((32,32,64,64))
path=Image.open(SRC/"path_reference_96.png").convert("RGBA").crop((32,32,64,64))
for name,im,original in [("grass_tile.png",grass,"grass_reference_96.png"),("path_tile.png",path,"path_reference_96.png")]:
    assert im.size==(32,32) and im.getchannel("A").getextrema()==(255,255)
    check(name,im,original,"GROUND_ONLY")
for source,name in [("broadleaf_01.png","tree_A.png"),("broadleaf_02.png","tree_B.png")]:
    im=Image.open(SRC/source).convert("RGBA")
    assert im.getchannel("A").getextrema()[0]==0
    check(name,im,source,"PAR_COMPLETE; PARTITIONED_ACTOR_OCCLUSION")
for name,source,bbox in [
    ("rock_A.png","legacy_tileD.png",(385,285,419,320)),
    ("rock_B.png","legacy_tileD.png",(418,287,448,320)),
    ("sign_A.png","legacy_tileB.png",(258,317,286,365))]:
    im=crop_clean(source,bbox,max_island=24)
    if name=="rock_A.png":
        from PIL import ImageDraw
        ImageDraw.Draw(im).rectangle((24,0,im.width-1,7),fill=(0,0,0,0))  # legacy TileD stray pixels
    check(name,im,source+" "+str(bbox),"PAR_COMPLETE")
(ROOT/"logs"/"source_provenance.json").write_text(json.dumps(S,ensure_ascii=False,indent=2),encoding="utf8")
print("NORMALIZATION_DONE",len(S))
