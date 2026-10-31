#!/usr/bin/env python3
'''Cold offline source+mask geometry/zone preservation only. Requires private A05 ZIP extraction.'''
from pathlib import Path
from PIL import Image
import numpy as np
root=Path(__file__).resolve().parent
def rgb(name):
 with Image.open(root/name) as im: assert im.size==(384,384);return np.asarray(im.convert('RGB')).copy()
def m(name):
 with Image.open(root/name) as im: return np.asarray(im.convert('L')).copy()==255
road=m('A05_ROAD_TARGET_MASK_384.png');grass=m('A05_INPAINT_GRASS_AREA_MASK_384.png')
assert np.array_equal(road,~grass) and int(road.sum())==28818
assert all(np.count_nonzero(road[y])>0 for y in range(384))
before=rgb('A05_INPUT_A04_B_BASELINE.png')
p1=rgb('A05_ROAD_CONSTRAINED_RESULT.png')
p2=rgb('A05_TWO_PASS_FINAL_384.png')
p3=rgb('A05_R3_NOIP_PATH_FINAL.png')
def diff(a,b):return np.any(a!=b,axis=2)
assert not (diff(before,p1)&road).any()
assert int((diff(before,p1)&grass).sum())==118638
for x in (p2,p3):
 assert not (diff(p1,x)&grass).any()
 assert int((diff(p1,x)&road).sum())==28818
print('A05 pixel zone engineering PASS, Ground3 ART FAIL, Formal Seal NO')