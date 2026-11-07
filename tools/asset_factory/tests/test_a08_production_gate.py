"""A08: production-rule negative tests for Sprite and Master-first Map."""
from __future__ import annotations
from copy import deepcopy
import unittest
from tools.asset_factory.production_gate import inspect_production_job, FactoryContractError

def actor():
    return {
        "schema":"fs-asset-factory-job/v1","kind":"sprite","asset_id":"ACTOR01_A62","requested_stage":"TEMPLATE",
        "source":{"sha256":"a"*64,"verified":True},
        "style":{"profile_id":"FS_SPRITE_V1","art_reference_approved":False},
        "generation":{"requested_calls":0,"max_authorized_calls":0,"explicit_user_authorization":False},
        "sprite":{"native_target":"FS_ACTOR_SBS","approved_concept_sha256":"a"*64,
                  "actions":[{"name":"Moving","canonical_frames":3,"playback":[0,1,0,2],
                              "forty_five_degree_visual_approved":True,"anchor_verified":True}]},
        "qa":{"user_art":"PENDING","native_vx":"NOT_RUN","formal_seal":"NO"}}

def pmd():
    j=actor()
    j["asset_id"]="PMD0001_IDLE"
    j["sprite"]={"native_target":"PMD_XML","approved_concept_sha256":None,
                 "actions":[{"name":"Idle","canonical_frames":3,"native_xml_frames":3,
                             "native_rows":8,"xml_source_verified":True,
                             "eight_direction_art_verified":False,"anchor_verified":False}]}
    return j

def map_scene():
    return {
        "schema":"fs-asset-factory-job/v1","kind":"map","asset_id":"V3_BRIDGE","requested_stage":"TEMPLATE",
        "source":{"sha256":"a"*64,"verified":True},
        "style":{"profile_id":"FS_MAP_V1","art_reference_approved":False},
        "generation":{"requested_calls":0,"max_authorized_calls":0,"explicit_user_authorization":False},
        "map":{"native_contract":"MASTER_FIRST_4_LAYER","tile_size":32,"scene_id":"FOREST_BRIDGE",
               "master_1x_art_approved":False,"collision_semantics_approved":False,
               "full_authoring_object_inventory":False,
               "objects":[{"id":"bridge_deck","semantic_class":"bridge_deck","runtime_foreground":False},
                          {"id":"bridge_front","semantic_class":"near_rail","runtime_foreground":True,
                           "object_source_separated":False,"depth_footpoint_rule":"",
                           "occlusion_mask_sha256":None}]},
        "qa":{"user_art":"PENDING","native_vx":"NOT_RUN","formal_seal":"NO"}}

class A08ProductionGateTests(unittest.TestCase):
    def test_actor_metadata_plan_is_not_art(self):
        r=inspect_production_job(actor())
        self.assertEqual(r["status"],"HOLD")
        self.assertFalse(r["new_art_verified_here"])
        self.assertFalse(r["auto_generation_executed"])

    def test_pmd_direction_and_source_are_holds(self):
        r=inspect_production_job(pmd())
        self.assertIn("EIGHT_DIRECTION_ART_NOT_VERIFIED",r["holds"])
        self.assertIn("SPRITE_CONCEPT_SOURCE_NOT_APPROVED",r["holds"])

    def test_pmd_five_frames_cannot_replace_three(self):
        j=pmd();j["sprite"]["actions"][0]["canonical_frames"]=5
        self.assertIn("PMD_NATIVE_FRAME_COUNT_MISMATCH",inspect_production_job(j)["errors"])

    def test_one_row_is_not_eight_row(self):
        j=pmd();j["sprite"]["actions"][0]["native_rows"]=1
        self.assertNotIn("EIGHT_DIRECTION_ART_NOT_VERIFIED",inspect_production_job(j)["holds"])

    def test_invalid_pmd_rows_rejected(self):
        j=pmd();j["sprite"]["actions"][0]["native_rows"]=4
        self.assertIn("PMD_NATIVE_ROWS_NOT_SOURCE_DERIVED",inspect_production_job(j)["errors"])

    def test_actor_frame_count_and_playback(self):
        j=actor();j["sprite"]["actions"][0].update({"canonical_frames":4,"playback":[0,1,2,3]})
        r=inspect_production_job(j)
        self.assertIn("ACTOR_THREE_KEYFRAME_CONTRACT",r["errors"])
        self.assertIn("ACTOR_PLAYBACK_INVALID",r["errors"])

    def test_bridge_deck_must_not_occlude_actor(self):
        j=map_scene();j["map"]["objects"][0]["runtime_foreground"]=True
        self.assertTrue(any(x.startswith("MAP_FOREGROUND_FORBIDDEN:") for x in inspect_production_job(j)["errors"]))

    def test_front_bridge_rail_missing_source_is_hold(self):
        r=inspect_production_job(map_scene())
        self.assertEqual(r["status"],"HOLD")
        self.assertIn("MAP_OBJECT_NOT_SEMANTICALLY_SEPARATED:bridge_front",r["holds"])

    def test_map_duplicate_id_rejected(self):
        j=map_scene();j["map"]["objects"][1]["id"]="bridge_deck"
        self.assertIn("MAP_DUPLICATE_OBJECT_ID",inspect_production_job(j)["errors"])

    def test_wrong_map_grid_rejected(self):
        j=map_scene();j["map"]["tile_size"]=16
        self.assertIn("FS_MASTER_FIRST_32PX_CONTRACT_VIOLATED",inspect_production_job(j)["errors"])

    def test_pixellab_not_authorized_must_fail(self):
        j=pmd();j["generation"]["requested_calls"]=1
        r=inspect_production_job(j)
        self.assertIn("UNAUTHORIZED_PAID_GENERATION",r["errors"])
        self.assertIn("GENERATION_EXCEEDS_APPROVED_LIMIT",r["errors"])

    def test_authorized_plan_does_not_execute(self):
        j=actor();j["generation"].update({"requested_calls":1,"max_authorized_calls":2,"explicit_user_authorization":True})
        r=inspect_production_job(j)
        self.assertFalse(r["auto_generation_executed"])

    def test_fake_native_pass_rejected(self):
        j=actor();j["qa"]["native_vx"]="PASS"
        self.assertIn("FAKE_NATIVE_PASS_NO_EVIDENCE",inspect_production_job(j)["errors"])

    def test_fake_formal_art_pass_rejected(self):
        j=map_scene();j["qa"].update({"user_art":"PASS","native_vx":"PASS","formal_seal":"YES"})
        r=inspect_production_job(j)
        self.assertIn("FAKE_ART_PASS_NO_APPROVAL",r["errors"])
        self.assertIn("FAKE_FORMAL_SEAL",r["errors"])

    def test_source_verification_requires_sha(self):
        j=actor();j["source"]["sha256"]=None
        self.assertIn("SOURCE_VERIFIED_WITHOUT_SHA",inspect_production_job(j)["errors"])

    def test_invalid_schema_refused(self):
        j=map_scene();j["schema"]="wrong"
        with self.assertRaises(FactoryContractError):
            inspect_production_job(j)

if __name__=="__main__":
    unittest.main()
