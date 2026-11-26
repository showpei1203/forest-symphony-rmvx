#!/usr/bin/env python3
"""Synthetic policy tests; do not confuse with true D25 artistic acceptance."""
import sys, unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).parent))
from fs_tc_d25_art_geometry_gate import art_geometry_failures, TARGET, BRIDGE_W_MIN, BRIDGE_W_MAX, FORGE_W_MAX

class TestArtSizeEarlyGate(unittest.TestCase):
 def test_D24_bad_bridge_and_forge_fail_before_PNG_relayout(self):
  errors=art_geometry_failures({'source_width_px':495,'source_height_px':501},{'source_width_px':388,'source_height_px':215})
  self.assertEqual(set(errors),{'BRIDGE_WIDTH_EXCEEDS_6_TILES','FORGE_MORE_THAN_9_TILES_WIDE','FORGE_HEIGHT_TOO_LARGE'})
 def test_correct_authored_source_geometry_has_no_dimension_rejection(self):
  self.assertEqual(art_geometry_failures({'source_width_px':272,'source_height_px':320},{'source_width_px':176,'source_height_px':176}),[])
 def test_over_shorted_bridge_is_also_rejected(self):
  self.assertEqual(art_geometry_failures({'source_width_px':240,'source_height_px':300},{'source_width_px':95,'source_height_px':170}),['BRIDGE_TOO_SHORT_FOR_TARGET_SPAN'])
 def test_bridge_world_bbox_grid_is_exact(self):
  b=TARGET['bridge']['bbox_xyxy'];self.assertEqual(b[2]-b[0],192)
  self.assertEqual(TARGET['native_canvas'],[1280,928]);self.assertEqual((BRIDGE_W_MIN,BRIDGE_W_MAX,FORGE_W_MAX),(160,192,288))
 def test_footpoints_are_on_opposite_sides_of_lava(self):
  (left,right)=TARGET['bridge']['expected_footpoints_xy'];self.assertLess(left[0],1055);self.assertGreater(right[0],1080)
  self.assertEqual(left[1],right[1])

if __name__=='__main__':unittest.main(verbosity=2)
