"""A30 explicit, manually reviewed, conservative candidate collision from A11 Master.

NOT a source-approved collision proof. The A10 unrelated masks must never be used.
Outputs source-lock manifest + a tiny PUBLIC debug atlas texture; private art preview
stays only in the owner-only Google Drive ZIP.
"""
from __future__ import annotations
import hashlib, json, pathlib
from PIL import Image, ImageDraw

ROOT=pathlib.Path(__file__).resolve().parent.parent
SOURCE=ROOT/'private_assets/full_ground.png'
SHA='091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530'
WORLD=(1280,928);GRID=(40,29);TILE=32
SAFE_POINTS=((232,556),(232,596),(735,621),(735,670))
# Geometries manually annotated against A11 real Master, NOT from A10.
# Conservative cores are candidates until a human reviews per tile at 1x.
ZONES=[
 dict(id='pond_deepwater_core',semantic='water',points=[[45,699],[150,665],[300,681],[426,700],[515,736],[450,812],[310,825],[145,820],[55,777]]),
 dict(id='pond_north_arm',semantic='water',points=[[315,650],[386,636],[474,627],[550,651],[500,677],[385,674]]),
 dict(id='creek_west_bridge_core',semantic='water',points=[[560,641],[614,625],[670,649],[655,698],[585,709],[545,680]]),
 dict(id='creek_east_lower_core',semantic='water',points=[[873,610],[930,597],[1000,601],[1051,650],[1000,678],[935,670],[887,639]]),
 dict(id='right_waterfall_core',semantic='water',points=[[1228,124],[1260,106],[1279,100],[1279,515],[1248,498],[1218,404],[1240,310]]),
 dict(id='left_cottage_wall_core',semantic='building',points=[[233,183],[378,169],[439,258],[425,329],[249,322],[208,258]]),
 dict(id='right_cottage_wall_core',semantic='building',points=[[861,175],[1010,163],[1086,244],[1086,327],[882,333],[845,261]]),
 dict(id='gazebo_raised_core',semantic='raised_structure',points=[[553,87],[663,86],[725,156],[708,225],[551,217]]),
]

def inside(px,py,verts):
    # Cast ray; only mark tile centers strictly inside candidate polygon.
    v=verts;n=len(v);hit=False
    for j in range(n):
        a=v[j];b=v[(j+1)%n]
        if (a[1]>py)!=(b[1]>py) and px<(b[0]-a[0])*(py-a[1])/(b[1]-a[1])+a[0]: hit=not hit
    return hit

def build():
    assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==SHA, 'wrong/unapproved Master'
    img=Image.open(SOURCE)
    assert img.size==WORLD,'unexpected tile grid'
    tiles={};by_zone={}
    for zone in ZONES:
        by_zone[zone['id']]=[]
        for y in range(GRID[1]):
            for x in range(GRID[0]):
                center=(x*TILE+16,y*TILE+16)
                if inside(*center,zone['points']):
                    if (x,y) not in tiles:tiles[(x,y)]=zone['id']
                    by_zone[zone['id']].append([x,y])
    for x,y in SAFE_POINTS:
        assert (x//TILE,y//TILE) not in tiles,f'legal footpoint incorrectly blocked: {(x,y)}'
    out={
        'schema':'fs-a30-manual-semantic-collision-candidate/v1',
        'status':'CANDIDATE_NOT_USER_COLLISION_APPROVED',
        'ground_sha256':SHA,'grid':list(GRID),'tile_px':TILE,
        'source':'manual visual polygons traced from original A11 Master; not A10',
        'safe_footpoints':[list(x) for x in SAFE_POINTS],
        'zones':ZONES,
        'blocked_tiles':[list(p) for p in sorted(tiles)],
        'zone_tile_counts':{k:len(v) for k,v in by_zone.items()},
        'warning':'Blocked tiles are visually conservative candidate cores; unmarked area not necessarily safe.'
    }
    (ROOT/'data/collision_candidate.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
    # Public synthetic debug atlas only. Never embed original scene pixels in GitHub.
    sw=Image.new('RGBA',(32,32),(225,45,40,75));d=ImageDraw.Draw(sw)
    d.rectangle((0,0,31,31),outline=(255,85,70,255),width=2)
    d.line((4,4,28,28),fill=(255,210,190,140),width=2)
    d.line((4,28,28,4),fill=(255,210,190,140),width=2)
    sw.save(ROOT/'assets/collision_debug_tile.png')
    # Private visual QA: overlay blocked cells on UNMODIFIED original source image.
    display=img.convert('RGBA'); paint=Image.new('RGBA',WORLD,(0,0,0,0)); pd=ImageDraw.Draw(paint)
    for x,y in tiles:
        pd.rectangle((x*TILE,y*TILE,x*TILE+31,y*TILE+31),fill=(255,42,38,85),outline=(255,95,75,190),width=1)
    for x,y in SAFE_POINTS:
        pd.ellipse((x-10,y-10,x+10,y+10),fill=(30,245,80,200),outline=(4,60,10,255),width=2)
    display=Image.alpha_composite(display,paint)
    display.save(ROOT/'qa/A30_COLLISION_CANDIDATE_FULL_1X_NOT_ART_PASS.png')
    print('A30 COLLISION CANDIDATE generated',len(tiles),'blocked of',GRID[0]*GRID[1],'tiles; legal footpoints 4/4')
    return out
if __name__=='__main__':build()
