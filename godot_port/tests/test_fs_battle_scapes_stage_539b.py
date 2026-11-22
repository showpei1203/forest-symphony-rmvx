import importlib.util
import hashlib
import json
import tempfile
import unittest
import zipfile
from pathlib import Path

root=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location("source_scapes",
    root/"tools"/"stage_private_battle_scapes_539b.py")
mod=importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

class WholeSourceScapeImporter(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)
        self.archive=self.root/"fixture.zip"
        self.dest=self.root/"assets"/"battle_scapes"
        self.actual=mod.SOURCE_SHA.copy()
        self.addCleanup(lambda:mod.SOURCE_SHA.clear())
        self.addCleanup(lambda:mod.SOURCE_SHA.update(self.actual))
    def fixture(self,poison=False):
        records=[]
        parts={}
        for i,name in enumerate(self.actual):
            b=(bytes.fromhex("89504e470d0a1a0a")+bytes([i])) if name.endswith(".png") else (bytes.fromhex("ffd8ff")+bytes([i]))
            hash=hashlib.sha256(b).hexdigest()
            mod.SOURCE_SHA[name]=hash
            records.append({"name":name,"sha256":"0"*64 if poison and i==0 else hash,"bytes":len(b)})
            parts["Graphics/Parallaxes/"+name]=b
        manifest={"schema":"fs-original-battlescape-private-v1",
                  "section":264,"missing_in_original_graphics_parallaxes":["Bridge","BlueSky"],
                  "files":records}
        with zipfile.ZipFile(self.archive,"w") as z:
            for name,data in parts.items():z.writestr(name,data)
            z.writestr("fs_original_battlescape_manifest.json",json.dumps(manifest))
        return hashlib.sha256(self.archive.read_bytes()).hexdigest()
    def test_complete_source_guard_and_no_overwrite(self):
        digest=self.fixture()
        out=mod.stage(self.archive,self.dest,digest)
        self.assertEqual(len(out["files"]),7)
        self.assertEqual(len(list(self.dest.glob("*.png"))),5)
        self.assertEqual(len(list(self.dest.glob("*.jpg"))),2)
        with self.assertRaises(FileExistsError):
            mod.stage(self.archive,self.dest,digest)
    def test_corrupt_pixel_manifest_denied(self):
        digest=self.fixture(poison=True)
        with self.assertRaises(ValueError):
            mod.stage(self.archive,self.dest,digest)
        self.assertFalse(self.dest.exists())
    def test_private_source_archive_sha_denied(self):
        self.fixture()
        with self.assertRaises(ValueError):
            mod.stage(self.archive,self.dest)
        self.assertFalse(self.dest.exists())

if __name__=="__main__":unittest.main()
