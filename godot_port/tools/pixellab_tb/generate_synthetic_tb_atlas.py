#!/usr/bin/env python3
"""Deterministic synthetic Godot atlas; intentionally contains NO PMD private artwork.
Only exercises GDScript atlas import and timeline event order. NOT art validation.
"""
from pathlib import Path
import argparse, struct,zlib

def chunk(t,data):
 return struct.pack('!I',len(data))+t+data+struct.pack('!I',zlib.crc32(t+data)&0xffffffff)

def make_png(path):
 width,height=384,288
 # RGBA unfiltered scanlines, each 96x96 cell has colored 12x12 marker.
 raw=bytearray()
 for y in range(height):
  raw.append(0)
  for x in range(width):
   cell=(y//96)*4+(x//96)
   dx,dy=x%96,y%96
   if cell<11 and 37<=dx<49 and 37<=dy<49:
    raw.extend(((cell*21+40)%256,(cell*9+75)%256,(cell*7+100)%256,255))
   else:
    raw.extend((0,0,0,0))
 data=b'\x89PNG\r\n\x1a\n'
 data+=chunk(b'IHDR',struct.pack('!2I5B',width,height,8,6,0,0,0))
 data+=chunk(b'IDAT',zlib.compress(bytes(raw),6))
 data+=chunk(b'IEND',b'')
 Path(path).parent.mkdir(parents=True,exist_ok=True)
 Path(path).write_bytes(data)
 print('SYNTHETIC_TEST_ATLAS_ONLY',str(path),len(data))
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True)
 make_png(ap.parse_args().out)
