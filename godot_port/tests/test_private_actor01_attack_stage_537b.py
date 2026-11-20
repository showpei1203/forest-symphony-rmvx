import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
spec=importlib.util.spec_from_file_location("a52",Path(__file__).resolve().parents[1]/"tools"/"stage_private_actor01_attack_537b.py")
a52=importlib.util.module_from_spec(spec)
spec.loader.exec_module(a52)

class Stage(unittest.TestCase):
    def test_sha_dimension_and_refuse_existing(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td)
            raw=bytes.fromhex("89504e470d0a1a0a")+b"\0\0\0\x0dIHDR"+bytes.fromhex("00000100000000c0")+b"x"*20
            source={}
            checksum=hashlib.sha256(raw).hexdigest()
            for name in a52.EXPECTED:
                file=root/name
                file.write_bytes(raw)
                source[name]=file
            dest=root/"assets"/"ta_actor01"
            expected=dict.fromkeys(a52.EXPECTED,checksum)
            self.assertEqual(a52.stage(source,dest,expected,True)["art_status"],"A52_SOURCE_ONLY")
            self.assertFalse(dest.exists())
            a52.stage(source,dest,expected)
            self.assertEqual((dest/"attack_body.png").read_bytes(),raw)
            with self.assertRaises(a52.StageError):
                a52.stage(source,dest,expected)
    def test_mismatched_sha_rejects_without_write(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td)
            s={name:root/name for name in a52.EXPECTED}
            for f in s.values(): f.write_bytes(b"bad")
            dest=root/"assets"/"ta_actor01"
            with self.assertRaisesRegex(a52.StageError,"SHA"):
                a52.stage(s,dest)
            self.assertFalse(dest.exists())
if __name__=="__main__":unittest.main()
