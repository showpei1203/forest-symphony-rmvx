import copy,json,tempfile,unittest
from pathlib import Path
from PIL import Image
from motion_pack import build,sha
from pose_review import review
class TestReview(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
        source=self.root/"synthetic.txt";source.write_text("SYNTHETIC TEST ONLY")
        frames=[]
        for i in range(8):
            im=Image.new("RGBA",(64,64));im.paste((40+i,80,160,255),(12+i,24,24+i,50));p=self.root/f"{i}.png";im.save(p);frames.append(p)
        self.b=self.root/"bundle";self.o=self.root/"review"
        build("attack",source,frames,[110,90,170,100,80,120,120,210],self.b,sha(source),[sha(p) for p in frames],source_class="SYNTHETIC_TEST_ONLY")
        self.mp=self.b/"motion.json";self.m=json.loads(self.mp.read_text())
    def patch(self,**kwargs):
        self.m.update(kwargs);self.mp.write_text(json.dumps(self.m))
    def reject(self,code,synthetic=True):
        with self.assertRaisesRegex(ValueError,code): review(self.b,self.o,synthetic)
        self.assertFalse(self.o.exists())
    def test_valid(self):
        before={p.name:sha(p) for p in self.b.iterdir()}
        r=review(self.b,self.o,True)
        self.assertEqual((r["structure"],r["art"],r["scope"]),("PASS","HOLD","SYNTHETIC_ONLY"))
        self.assertEqual(len(r["frames"]),8);self.assertEqual(r["frames"][0]["opaque_pixels"],312)
        self.assertIsNone(r["frames"][0]["silhouette_jaccard_change"])
        self.assertEqual(r["frames"][1]["silhouette_centroid"][0]-r["frames"][0]["silhouette_centroid"][0],1)
        self.assertTrue(all(v=="NOT_REVIEWED" for f in r["frames"] for v in f["visual_checks"].values()))
        self.assertEqual(before,{p.name:sha(p) for p in self.b.iterdir()})
        with Image.open(self.o/"contact_4x.png") as im:self.assertEqual(im.size,(1024,512))
        with Image.open(self.o/"preview.gif") as im:self.assertEqual(im.n_frames,8)
    def test_synthetic_rejected_default(self):self.reject("PROVENANCE",False)
    def test_fake_real_pin(self):
        self.patch(source_class="OWNER_SUPPLIED_UNAUTHENTICATED");self.reject("REAL_ATTACK_PIN",False)
    def test_source_tamper(self):
        (self.b/"source.bin").write_text("changed");self.reject("MANIFEST_HASH")
    def test_frame_tamper(self):
        (self.b/"F01.png").write_bytes((self.b/"F02.png").read_bytes());self.reject("FRAME_HASH")
    def test_bad_atlas(self):
        p=self.b/"body.png"
        with Image.open(p) as im:copyim=im.copy()
        copyim.putpixel((0,0),(1,2,3,255));copyim.save(p)
        self.patch(atlas_sha256=sha(p));self.reject("ATLAS_PARITY")
    def test_fake_approval(self):self.patch(art="PASS");self.reject("CONTRACT")
    def test_wrong_order(self):
        r=self.m["frames"];r[0],r[1]=r[1],r[0];self.patch(frames=r);self.reject("FRAME_ORDER")
    def test_existing_output(self):
        self.o.mkdir()
        with self.assertRaisesRegex(ValueError,"OUTPUT_LOCATION"):review(self.b,self.o,True)
    def test_inside_bundle(self):
        with self.assertRaisesRegex(ValueError,"OUTPUT_LOCATION"):review(self.b,self.b/"review",True)
    def test_events(self):self.patch(events=[{"damage":1}]);self.reject("CONTRACT")
    def test_wrong_bbox(self):
        self.m["frames"][0]["bbox"]=[1,2,3,4];self.patch(frames=self.m["frames"]);self.reject("METADATA")
if __name__=="__main__":unittest.main(verbosity=2)
