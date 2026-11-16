"""A09 semantic templates, generated geometry and fail-closed source identity tests."""
import hashlib
import json
import unittest
from tools.asset_factory.scene_blueprint import build_scene, to_tiled_object_layers, TILE


class A09SceneBlueprintTests(unittest.TestCase):
    def test_two_different_fullsize_scene_blueprints(self):
        a=build_scene("ELF_VILLAGE",20261108)
        b=build_scene("FOREST_BRIDGE",20261203)
        self.assertEqual(a["canvas_px"],[1280,928])
        self.assertEqual(b["canvas_px"],[1280,928])
        self.assertNotEqual(a["objects"],b["objects"])
        self.assertNotEqual(a["collision_blocked_tiles"],b["collision_blocked_tiles"])

    def test_deterministic_seed(self):
        a=json.dumps(build_scene("FOREST_BRIDGE",20261203),sort_keys=True)
        b=json.dumps(build_scene("FOREST_BRIDGE",20261203),sort_keys=True)
        self.assertEqual(hashlib.sha256(a.encode()).digest(),hashlib.sha256(b.encode()).digest())

    def test_bridge_deck_and_rail_are_not_same_source_object(self):
        s=build_scene("FOREST_BRIDGE",20261203)
        ob={o["id"]:o for o in s["objects"]}
        self.assertEqual(ob["BRIDGE_DECK"]["runtime_role"],"GROUND_ONLY")
        self.assertEqual(ob["BRIDGE_NEAR_RAIL"]["runtime_role"],"CONDITIONAL_FOREGROUND")
        self.assertNotEqual(ob["BRIDGE_DECK"]["part"],ob["BRIDGE_NEAR_RAIL"]["part"])

    def test_artist_source_required_before_foreground_export(self):
        s=build_scene("FOREST_BRIDGE",20261203)
        for obj in s["objects"]:
            self.assertIsNone(obj["occlusion_mask_sha256"])
            self.assertFalse(obj["art_source_ready"])
        self.assertEqual(s["runtime_occlusion_par"],"NOT_GENERATED")
        self.assertEqual(s["user_art"],"PENDING")

    def test_bridge_crosses_water_and_remains_reachable(self):
        s=build_scene("FOREST_BRIDGE",20261203)
        blocked={tuple(p) for p in s["collision_blocked_tiles"]}
        self.assertTrue(s["bridge_collision_path_verified_static"])
        self.assertNotIn((19,16),blocked)
        self.assertIn((19,6),blocked)

    def test_seeded_ground_decor_never_foreground(self):
        s=build_scene("ELF_VILLAGE",20261108)
        forbidden={tuple(p) for p in s["collision_blocked_tiles"]}
        path={tuple(p) for p in s["walkable_route_tiles"]}
        self.assertGreater(len(s["low_decor_instances"]),10)
        for item in s["low_decor_instances"]:
            self.assertEqual(item["runtime_role"],"GROUND_ONLY")
            self.assertNotIn(tuple(item["tile"]),forbidden)
            self.assertNotIn(tuple(item["tile"]),path)

    def test_native_tiled_schema_not_marked_engine_pass(self):
        s=build_scene("ELF_VILLAGE",20261108)
        tiled=to_tiled_object_layers(s)
        self.assertEqual(tiled["tilewidth"],TILE)
        self.assertEqual(tiled["tileheight"],TILE)
        self.assertEqual(tiled["width"],40)
        self.assertTrue(all(layer["type"]=="objectgroup" for layer in tiled["layers"]))
        self.assertTrue(all("SOURCE_ART_REQUIRED" in str(o["properties"]) for layer in tiled["layers"] for o in layer["objects"]))
        self.assertEqual(s["native_vx"],"NOT_RUN")

    def test_tiled_object_ids_are_unique_across_layers(self):
        tiled=to_tiled_object_layers(build_scene("FOREST_BRIDGE",20261203))
        ids=[o["id"] for layer in tiled["layers"] for o in layer["objects"]]
        self.assertEqual(len(ids),len(set(ids)))
        self.assertEqual(tiled["nextobjectid"],max(ids)+1)
        self.assertEqual(tiled["nextlayerid"],len(tiled["layers"])+1)

    def test_tiled_decor_has_ground_only_source_roles(self):
        s=build_scene("ELF_VILLAGE",20261108)
        tiled=to_tiled_object_layers(s)
        deco=next(l for l in tiled["layers"] if l["name"]=="GROUND_DECOR")
        self.assertEqual(len(deco["objects"]),len(s["low_decor_instances"]))
        for obj in deco["objects"]:
            p={x["name"]:x["value"] for x in obj["properties"]}
            self.assertEqual(p["runtime_role"],"GROUND_ONLY")
            self.assertEqual(p["source_status"],"SOURCE_ART_REQUIRED")

    def test_bad_unknown_scene_or_seed_fails(self):
        with self.assertRaises(ValueError):
            build_scene("UNKNOWN",12)
        with self.assertRaises(ValueError):
            build_scene("ELF_VILLAGE","random")

if __name__=="__main__":
    unittest.main()
