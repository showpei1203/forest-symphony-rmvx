import io,unittest,os,sys
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT))
import a18_native_trial as a

class A18OfflineGates(unittest.TestCase):
 def test_ground3_sources_exact(self):
  q=a.verify_reference();self.assertEqual(q['grass']['size'],[64,64]);self.assertEqual(q['sand']['size'],[48,48])
 def test_dryrun_never_paid(self):
  for vendor in ('pixellab_pro','pixellab_pixen','retro_pro'):
   q=a.dryrun(vendor)
   self.assertEqual(q['provider_response'],'NOT_SUBMITTED')
   self.assertNotIn('base64',str(q))
   self.assertEqual(q['formal_seal'],'NO')
 def test_paid_gate_before_key_and_network(self):
  for vendor in ('pixellab_pro','pixellab_pixen','retro_pro'):
   with self.assertRaises(PermissionError):a.run_paid(vendor,False,0.0)
 def test_output_decoder_only_png(self):
  buf=io.BytesIO();Image.new('RGB',(128,128),(102,132,67)).save(buf,format='PNG')
  import base64
  b=base64.b64encode(buf.getvalue()).decode()
  raw,im=a.decode_model_result({'images':[{'base64':'data:image/png;base64,'+b}]},'pixellab_pro')
  self.assertEqual(raw,buf.getvalue());self.assertEqual(im.size,(128,128))
  buf=io.BytesIO();Image.new('RGB',(64,64)).save(buf,format='PNG')
  with self.assertRaises(ValueError):a.decode_model_result({'image':{'base64':base64.b64encode(buf.getvalue()).decode()}},'pixellab_pro')
  with self.assertRaises(ValueError):a.decode_model_result({'no_image':True},'pixellab_pro')
 def test_validation_never_art_pass(self):
  # MOCK is only a diagnostic fixture; never relabel it as a provider output.
  p=ROOT/'A18_MOCK_FIXTURE_NOT_GENERATED.png'
  if not p.exists():
   from PIL import ImageDraw
   im=Image.new('RGB',(128,128),(84,132,58));d=ImageDraw.Draw(im)
   for i in range(9):d.ellipse((i*15,i*9,i*15+7,i*9+7),fill=(105,149,62))
   im.save(p)
  q=a.validate_png(p,'mock',True)
  self.assertTrue(q['is_mock_fixture']);self.assertEqual(q['formal_seal'],'NO')
  self.assertEqual(q['ground3_style'],'REQUIRES_HUMAN')

if __name__=='__main__':unittest.main(verbosity=2)
