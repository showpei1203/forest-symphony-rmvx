"""A06 regression guards for the V3 false zero-overlap and isolated roof pocket."""
import unittest
from io import BytesIO
from PIL import Image
from tools.asset_factory.adapters.collision_review import (
    audit_footpoint_overlap, connected_walkable, propose_blocked_tiles, CollisionReviewError,
)

def make_mask(mode="L", x=16, y=30, level=255):
    im=Image.new(mode,(64,64),0 if mode=="L" else (0,0,0,0))
    im.putpixel((x,y),level if mode=="L" else (150,60,50,level))
    b=BytesIO();im.save(b,"PNG");return b.getvalue()

class A06ReviewTests(unittest.TestCase):
    def test_any_pixel_is_not_twenty_percent(self):
        grid=[[0,0],[0,0]]
        report=audit_footpoint_overlap(make_mask(),grid)
        self.assertEqual(report["any_overlap_walkable_tile_count"],1)
        self.assertEqual(report["significant_overlap_walkable_tile_count"],0)
        self.assertEqual(report["candidates"][0]["mask_pixels_under_actor_rect"],1)

    def test_l_and_rgba_alpha_are_equivalent(self):
        blocked=[[0,0],[0,0]]
        left=audit_footpoint_overlap(make_mask("L"),blocked)
        right=audit_footpoint_overlap(make_mask("RGBA"),blocked)
        self.assertEqual(left["any_overlap_walkable_tile_count"],right["any_overlap_walkable_tile_count"])
        self.assertEqual(left["candidates"][0]["tile"],right["candidates"][0]["tile"])

    def test_reject_nonbinary_mask(self):
        with self.assertRaises(CollisionReviewError):
            audit_footpoint_overlap(make_mask(level=127),[[0,0],[0,0]])

    def test_reject_blank_or_invalid_grid(self):
        with self.assertRaises(CollisionReviewError):
            connected_walkable([[0,0],[0]],(0,0))
        with self.assertRaises(CollisionReviewError):
            connected_walkable([[1,1],[0,0]],(0,0))

    def test_disconnected_then_explicit_block(self):
        grid=[[0,1,0],[0,1,1],[0,1,1]]
        before=connected_walkable(grid,(0,0))
        self.assertEqual(before["total_walkable"],4)
        self.assertEqual(before["reachable_walkable"],3)
        candidate=propose_blocked_tiles(grid,[{"tile":[2,0],"reason":"isolated known roof pocket"}],(0,0))
        self.assertTrue(candidate["after"]["all_walkable_reachable"])
        self.assertFalse(candidate["before"]["all_walkable_reachable"])
        self.assertEqual(grid[0][2],0) # source unchanged

    def test_refuse_duplicate_or_already_blocked(self):
        grid=[[0,1],[0,0]]
        with self.assertRaises(CollisionReviewError):
            propose_blocked_tiles(grid,[{"tile":[1,0],"reason":"already blocked target"}],(0,0))
        with self.assertRaises(CollisionReviewError):
            propose_blocked_tiles(grid,[{"tile":[0,0],"reason":"manual correction one"},
                                         {"tile":[0,0],"reason":"manual correction again"}],(0,0))

if __name__=="__main__":
    unittest.main()
