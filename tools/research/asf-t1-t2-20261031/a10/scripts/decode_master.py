from pathlib import Path
from PIL import Image
import base64,zlib,json,hashlib,numpy as np
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A10_ONE_MASTER_RIG")
info=json.loads((root/"MASTER_TRANSPORT.json").read_text(encoding="utf8"))
for name,(h,w,encoded) in info.items():
 raw=zlib.decompress(base64.b64decode(encoded))
 n=raw[0];palette=np.frombuffer(raw[1:1+3*n],dtype=np.uint8).reshape(n,3)
 start=1+3*n;pix=w*h
 indices=np.frombuffer(raw[start:start+pix],dtype=np.uint8).reshape(h,w)
 alpha=np.frombuffer(raw[start+pix:],dtype=np.uint8).reshape(h,w)
 assert len(raw)==1+3*n+pix*2
 rgba=np.concatenate([palette[indices],alpha[:,:,None]],axis=2).astype(np.uint8)
 p=root/name;p.mkdir(parents=True,exist_ok=True)
 Image.fromarray(rgba,"RGBA").save(p/"master.png")
 print(name,w,h,hashlib.sha256(rgba.tobytes()).hexdigest())