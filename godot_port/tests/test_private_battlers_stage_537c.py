import hashlib
import importlib.util
import io
import json
import struct
import tempfile
import unittest
import zipfile
from pathlib import Path
root=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location("battlers",root/"tools"/"stage_private_battlers_537c.py")
battlers=importlib.util.module_from_spec(spec)
spec.loader.exec_module(battlers)

class BattlerSourceGate(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.d=Path(self.tmp.name)
        self.z=self.d/"archive.zip"
        self.dest=self.d/"assets"/"battlers"
    def fixture(self,malformed=False,corrupt=False):
        rows=[]
        art={}
        raw=bytes.fromhex("89504e470d0a1a0a")+b"\0\0\0\x0dIHDR"+struct.pack(">II",24,24)+b"test"
        for i in range(battlers.EXPECTED_COUNT):
            name=f"$synthetic_{i:03d}.png"
            path=f"Graphics/Battlers/{name}"
            rows.append({"path":"../bad.png" if malformed and i==0 else path,
                "sha256":"0"*64 if corrupt and i==0 else hashlib.sha256(raw).hexdigest(),
                "bytes":len(raw),"width":24,"height":24})
            art[path]=raw
        art["fs_battlers_source_manifest.json"]=json.dumps({
            "schema":"fs-original-battlers-private-v1",
            "count":battlers.EXPECTED_COUNT,"files":rows}).encode()
        with zipfile.ZipFile(self.z,"w",zipfile.ZIP_DEFLATED) as z:
            for path,data in art.items():z.writestr(path,data)
        return hashlib.sha256(self.z.read_bytes()).hexdigest()
    def test_all_167_and_denied_second_stage(self):
        hash=self.fixture()
        m=battlers.stage(self.z,self.dest,hash,dry_run=True)
        self.assertEqual(m["source_count"],167)
        self.assertFalse(self.dest.exists())
        battlers.stage(self.z,self.dest,hash)
        self.assertEqual(len(list(self.dest.glob("*.png"))),167)
        with self.assertRaisesRegex(battlers.ArtGateError,"overwrite"):
            battlers.stage(self.z,self.dest,hash)
    def test_original_archive_sha_denied(self):
        self.fixture()
        with self.assertRaisesRegex(battlers.ArtGateError,"archive SHA256"):
            battlers.stage(self.z,self.dest)
        self.assertFalse(self.dest.exists())
    def test_tampered_original_png_sha_denied(self):
        sha=self.fixture(corrupt=True)
        with self.assertRaisesRegex(battlers.ArtGateError,"PNG SHA"):
            battlers.stage(self.z,self.dest,sha)
        self.assertFalse(self.dest.exists())
    def test_traversal_denied(self):
        sha=self.fixture(malformed=True)
        with self.assertRaises(battlers.ArtGateError):
            battlers.stage(self.z,self.dest,sha)
if __name__=="__main__":unittest.main()
