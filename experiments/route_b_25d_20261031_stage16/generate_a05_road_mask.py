#!/usr/bin/env python3
'''Generate Stage16 A05 independent geometry-only road/grass masks, no donor pixels.'''
from pathlib import Path
from PIL import Image
import math,numpy as np,argparse
parser=argparse.ArgumentParser();parser.add_argument('--out',required=True)
a=parser.parse_args();root=Path(a.out);root.mkdir(exist_ok=True,parents=True)
W=H=384; road=np.zeros((H,W),dtype=np.uint8)
for y in range(H):
 center=178+34*math.sin(0.82+y*math.pi*2/500)-.09*y
 width=74+5*math.sin(.42+y*math.pi*2/210)
 left=int(math.floor(center-width/2+2.3*math.sin(y*.113)))
 right=int(math.ceil(center+width/2+2.0*math.sin(y*.081+.6)))
 assert 3<left<right<W-3
 road[y,left:right]=255
assert int((road>0).sum())==28818
Image.fromarray(road,'L').save(root/'A05_ROAD_TARGET_MASK_384.png')
Image.fromarray(255-road,'L').save(root/'A05_INPAINT_GRASS_AREA_MASK_384.png')
print('road',int((road>0).sum()),'area fraction',int((road>0).sum())/(W*H))