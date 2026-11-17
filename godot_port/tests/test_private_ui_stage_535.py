import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
import zipfile
MODULE=Path(__file__).resolve().parents[1]/"tools"/"stage_private_ui_535.py"
spec=importlib.util.spec_from_file_location("stage_ui",MODULE)
stage=importlib.util.module_from_spec(spec)
spec.loader.exec_module(stage)
class PrivateUIStaging(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)
        self.archive=self.root/"ui.zip"
        self.output=self.root/"assets"/"ui"
    def build(self, corrupt=False, malformed=False):
        files=[]
        payload={}
        data=bytes.fromhex("89504e470d0a1a0a")+b"synthetic fixture, not an authentic PNG"
        for i in range(stage.COUNT):
            cat="Menu" if i<40 else "System" if i<181 else "Windows"
            n=f"fixture{i:03d}.png"
            path=f"Graphics/{cat}/{n}"
            sha=hashlib.sha256(data).hexdigest()
            files.append(dict(path=path,sha256="f"*64 if corrupt and i==0 else sha,
                              bytes=len(data),width=1,height=1))
            payload[path]=data
        if malformed:
            files[0]["path"]="../escape.png"
        payload["fs_ui_source_manifest.json"]=json.dumps(
            dict(schema="fs-original-ui-private-v1",count=stage.COUNT,files=files)
        ).encode()
        with zipfile.ZipFile(self.archive,"w",zipfile.ZIP_DEFLATED) as z:
            for name,raw in payload.items():z.writestr(name,raw)
        return hashlib.sha256(self.archive.read_bytes()).hexdigest()
    def test_full_stage_and_dryrun_without_touching_original(self):
        sha=self.build()
        check=stage.stage(self.archive,self.output,sha,True)
        self.assertEqual(check["count"],202)
        self.assertFalse(self.output.exists())
        result=stage.stage(self.archive,self.output,sha)
        self.assertEqual(result["count"],202)
        self.assertTrue((self.output/"menu"/"fixture000.png").is_file())
        self.assertTrue((self.output/"fs_ui_import_manifest.json").is_file())
        with self.assertRaises(stage.UIStageError):
            stage.stage(self.archive,self.output,sha)
    def test_wrong_archive_denied(self):
        self.build()
        with self.assertRaisesRegex(stage.UIStageError,"SHA256"):
            stage.stage(self.archive,self.output,"0"*64)
        self.assertFalse(self.output.exists())
    def test_source_tamper_denied(self):
        sha=self.build(corrupt=True)
        with self.assertRaisesRegex(stage.UIStageError,"hash"):
            stage.stage(self.archive,self.output,sha)
    def test_path_escape_denied(self):
        sha=self.build(malformed=True)
        with self.assertRaises(stage.UIStageError):
            stage.stage(self.archive,self.output,sha)
        self.assertFalse(self.output.exists())
if __name__=="__main__":
    unittest.main()
