"""A08 source-locked zero-cost pilot dry-run assertions."""
import unittest
from tools.asset_factory.run_a08_pilot import load_and_audit


class A08RealPilotManifestTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.report=load_and_audit()
        cls.entries={x["asset_id"]:x for x in cls.report["outcomes"]}

    def test_two_sprites_and_two_map_pilots_exist(self):
        self.assertEqual(self.report["job_count"],4)
        self.assertEqual(self.report["kind_counts"],{"sprite":2,"map":2})

    def test_no_pixellab_generation_was_authorized_or_called(self):
        self.assertEqual(self.report["total_generation_calls"],0)
        self.assertEqual(self.report["new_asset_outputs"],0)

    def test_actual_concepts_are_not_invented(self):
        j=self.entries["PMD0001_LAVA_IDLE_WALK_PILOT"]
        self.assertIn("SPRITE_CONCEPT_SOURCE_NOT_APPROVED",j["holds"])
        self.assertIn("EIGHT_DIRECTION_ART_NOT_VERIFIED",j["holds"])

    def test_actor_run_48px_is_not_complete_native_art(self):
        j=self.entries["ACTOR01_A62_RUN_3POSE"]
        self.assertIn("SPRITE_CONCEPT_SOURCE_NOT_APPROVED",j["holds"])
        self.assertNotEqual(j["status"],"READY_FOR_NEXT_GATE")

    def test_new_second_map_scene_is_not_false_pass(self):
        j=self.entries["FOREST_BRIDGE_NEW_LAYOUT_PILOT"]
        self.assertIn("SOURCE_SHA_MISSING",j["holds"])
        self.assertIn("SOURCE_BYTES_NOT_VERIFIED",j["holds"])
        self.assertIn("MAP_OBJECT_NOT_SEMANTICALLY_SEPARATED:bridge_near_rail",j["holds"])

    def test_v3_map_still_lacks_art_and_legal_footpoints(self):
        j=self.entries["ELF_VILLAGE_1280X928_PILOT"]
        self.assertIn("MAP_COLLISION_SEMANTICS_UNAPPROVED",j["holds"])
        self.assertIn("MAP_MASTER_1X_ART_NOT_APPROVED",j["holds"])

    def test_no_formal_passes_claimed(self):
        self.assertEqual(self.report["art_pass"],0)
        self.assertEqual(self.report["native_vx_pass"],0)
        self.assertFalse(self.report["production_scale_approved"])

    def test_metadata_contracts_have_no_hidden_hard_errors(self):
        for entry in self.report["outcomes"]:
            self.assertEqual(entry["errors"],[],entry["asset_id"])


if __name__=="__main__":
    unittest.main()
