"""Recover the real historical A62 3-pose RUN without synthesizing a fourth pose."""
from pathlib import Path
from PIL import Image
import argparse, hashlib, io, json, tempfile, zipfile
from motion_pack import build
ARCHIVE="71062dee924ea38bd595ee3454c8d29f046ae9707014ac5b0e3424c8c9a548ba"
F00="70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,code):
    if not ok: raise ValueError(code)
def recover(archive, approved, out):
    require(sha(archive)==ARCHIVE and sha(approved)==F00,"SOURCE_PIN")
    with zipfile.ZipFile(archive) as z:
        require(z.testzip() is None,"CRC")
        manifest=json.loads(z.read("A62_SHA256_MANIFEST.json"))
        require(len(manifest)==20 and all(hashlib.sha256(z.read(k)).hexdigest()==v["sha256"] and len(z.read(k))==v["bytes"] for k,v in manifest.items()),"ARCHIVE_MANIFEST")
        with tempfile.TemporaryDirectory() as t:
            frames=[]
            for i in range(3):
                im=Image.open(io.BytesIO(z.read(f"A62_PROVIDER_RAW_F{i}.png")))
                require(im.mode=="RGBA" and im.size==(48,48),"RAW")
                # Preserve exact RGBA pixels; transparent padding only. F2 bottom was 51 after +8, align by one pixel.
                y=50-im.getbbox()[3]
                canvas=Image.new("RGBA",(64,64));canvas.paste(im,(8,y))
                require(canvas.crop((8,y,56,y+48)).tobytes()==im.tobytes(),"PIXEL_PARITY")
                if i==0:
                    with Image.open(approved) as base: require(base.tobytes()==canvas.tobytes(),"APPROVED_IDENTITY")
                p=Path(t)/f"F{i+1:02d}.png";canvas.save(p);frames.append(p)
            return build("run",archive,frames,[130]*3,out,ARCHIVE,[sha(p) for p in frames],playback_order=[0,1,0,2])
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("archive",type=Path);p.add_argument("approved",type=Path);p.add_argument("out",type=Path);a=p.parse_args();print(json.dumps(recover(a.archive,a.approved,a.out),indent=2))
