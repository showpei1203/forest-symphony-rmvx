#!/usr/bin/env python3
"""A34 non-destructive private A33 house-source audit. Requires Pillow."""
import argparse, hashlib, io, json, zipfile
from PIL import Image

def run(path):
    with zipfile.ZipFile(path) as z:
        assert z.testzip() is None, "ZIP CRC failure"
        manifest=json.loads(z.read("data/a33_groundfirst_lantern_manifest.json"))
        scene=z.read("scenes/a33_groundfirst_lantern_scene.tscn").decode()
        ground="private_assets/ground_only.png"
        ground_sha=hashlib.sha256(z.read(ground)).hexdigest()
        assert ground_sha == manifest["ground"]["sha256"], "Ground hash mismatch"
        houses=[]
        for asset_id,meta in manifest["assets"].items():
            if meta.get("semantic")!="house": continue
            name=meta["file"]; data=z.read(name)
            digest=hashlib.sha256(data).hexdigest()
            assert digest==meta["sha256"],f"house hash mismatch: {name}"
            im=Image.open(io.BytesIO(data)).convert("RGBA")
            assert im.size==tuple(meta["size"]),f"house dimensions mismatch: {name}"
            bbox=im.getchannel("A").getbbox()
            assert bbox,f"empty house: {name}"
            assert name in scene,f"house missing from scene: {name}"
            houses.append({"id":asset_id,"path":name,"sha256":digest,"size":list(im.size),"alpha_bbox":list(bbox),"alpha_coverage":round(sum(a>0 for a in im.getchannel("A").get_flattened_data())/(im.width*im.height),4)})
        assert len(houses)==2,f"expected 2 independent houses, got {len(houses)}"
        return {"status":"SOURCE_CONTRACT_PASS","native_godot":"NOT_RUN","art_approval":"HOLD","ground_sha256":ground_sha,"houses":houses,"note":"Source audit only; no native rendering, physical collisions or art approval claimed."}

if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("a33_zip");p.add_argument("--out");args=p.parse_args()
    result=run(args.a33_zip)
    text=json.dumps(result,ensure_ascii=False,indent=2)
    if args.out:
        with open(args.out,"w",encoding="utf-8") as f:f.write(text+"\n")
    print(text)
