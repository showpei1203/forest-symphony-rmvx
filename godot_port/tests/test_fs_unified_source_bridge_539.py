import sys
from pathlib import Path
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"tools"))
from fs_unified_source_bridge import index_source,TABLE_SHA,SCHEMA

class CompleteSourceIndex(unittest.TestCase):
 def fake_data(self):return {name:"a"*64 for name in TABLE_SHA}
 def test_global_load_order_and_alias_candidates(self):
  parts=[
   (1,"First",b"class Scene_Battle\n def start\n end\n"),
   (2,"Reopen",b"class Scene_Battle\n alias previous_start start\n def start\n  Cache.parallax('new_back00')\n end\n"),
   (3,"Menu",b"class Window_Menu\n def initialize\n  Cache.menu('Menu01')\n end\n")]
  x=index_source(parts,"b"*64,self.fake_data(),expected=3)
  self.assertEqual(x["schema"],SCHEMA)
  self.assertEqual([s["section"] for s in x["sections"]],[1,2,3])
  self.assertEqual([a["section"] for a in x["method_candidates"]["Scene_Battle#start"]],[1,2])
  self.assertEqual(x["sections"][1]["alias_lines"],[2])
  self.assertEqual({v["name"] for v in x["static_resource_literals"]},{"Menu01","new_back00"})
  self.assertTrue(x["unresolved"]["effective_alias_chain"])
 def test_incomplete_sources_refused(self):
  with self.assertRaises(ValueError):index_source([], "x", self.fake_data(), expected=3)
  with self.assertRaises(ValueError):
   index_source([(1,"x",b"def f\n")],"x",{"Enemies":"a"*64},expected=1)
 def test_comments_do_not_create_fake_methods(self):
  x=index_source([(1,"T",b"# def imaginary\n# Cache.menu('wrong')\nclass Scene_Menu\n def update\n end\n")],
                 "a"*64,self.fake_data(),expected=1)
  self.assertFalse(x["static_resource_literals"])
  self.assertEqual(set(x["method_candidates"]),{"Scene_Menu#update"})

if __name__=="__main__":unittest.main()
