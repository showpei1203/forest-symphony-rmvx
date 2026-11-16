"""A02 synthetic positive/negative fixtures. Never publish licensed FS artwork."""
import hashlib
from io import BytesIO
import unittest

from PIL import Image

from tools.asset_factory.adapters.pmd import (
    PMDContractError, inspect_pmd_assets, inspect_pmd_xml,
)
from tools.asset_factory.adapters.actor import (
    ActorContractError, inspect_actor_action,
)
from tools.asset_factory.adapters.map_objects import (
    ObjectMaskError, inspect_object_masks,
)


def png(size=(8, 8), mode="RGBA", color=(1, 40, 99, 255)):
    b = BytesIO()
    Image.new(mode, size, color if mode == "RGBA" else 255).save(b, format="PNG")
    return b.getvalue()


def xml(count=2, copy=False):
    alias = "<Anim><Name>Strike</Name><CopyOf>Attack</CopyOf></Anim>" if copy else ""
    ds = "".join("<Duration>4</Duration>" for _ in range(count))
    return (
        '<?xml version="1.0"?><AnimData><ShadowSize>1</ShadowSize><Anims>'
        '<Anim><Name>Attack</Name><Index>0</Index>'
        '<FrameWidth>4</FrameWidth><FrameHeight>5</FrameHeight>'
        '<Durations>' + ds + '</Durations></Anim>' + alias +
        '</Anims></AnimData>'
    ).encode()


def atlas(rows=8, count=2):
    one = png((4 * count, 5 * rows))
    return {f"Attack-{k}.png": one for k in ("Anim", "Offsets", "Shadow")}


def actor_pngs():
    out = {}
    for index in range(1, 4):
        im = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
        im.putpixel((index, 3), (240, 40, 30, 255))
        b = BytesIO()
        im.save(b, format="PNG")
        out[f"Moving_{index}.png"] = b.getvalue()
    return out


def object_fixture():
    c = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
    c.putpixel((2, 2), (20, 20, 20, 255))
    c.putpixel((2, 3), (20, 20, 20, 255))
    o = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
    o.putpixel((2, 2), (20, 20, 20, 255))
    def pack(im):
        b = BytesIO()
        im.save(b, "PNG")
        return b.getvalue()
    def mask(coords):
        im = Image.new("L", (8, 8))
        for p in coords:
            im.putpixel(p, 255)
        return pack(im)
    source = png()
    objects = [{
        "id": "tree_1", "source": "tree.png",
        "source_sha256": hashlib.sha256(source).hexdigest(),
        "complete_mask": "complete.png", "occlusion_mask": "occ.png",
    }]
    return objects, {"tree.png": source}, {
        "complete.png": mask([(2, 2), (2, 3)]), "occ.png": mask([(2, 2)]),
    }, pack(c), pack(o)


class A02AdapterTests(unittest.TestCase):
    def test_pmd_native_metadata_and_alias(self):
        r = inspect_pmd_assets(xml(copy=True), atlas())
        self.assertEqual(r["status"], "PASS_STATIC_ONLY")
        self.assertEqual(r["actions"]["Strike"]["copy_of"], "Attack")
        self.assertEqual(r["sheets"]["Attack"]["rows"], 8)
        self.assertEqual(r["native_vx"], "NOT_RUN")

    def test_pmd_single_row_legal(self):
        self.assertEqual(inspect_pmd_assets(xml(), atlas(rows=1))["sheets"]["Attack"]["rows"], 1)

    def test_pmd_bad_xml_rejected(self):
        with self.assertRaises(PMDContractError):
            inspect_pmd_xml(b"<AnimData>oops")

    def test_pmd_entity_rejected(self):
        with self.assertRaises(PMDContractError):
            inspect_pmd_xml(b'<!DOCTYPE x [<!ENTITY x SYSTEM "file:///etc/passwd">]><AnimData/>')

    def test_pmd_wrong_count_rejected(self):
        with self.assertRaises(PMDContractError):
            inspect_pmd_assets(xml(count=3), atlas(count=2))

    def test_pmd_missing_shadow_rejected(self):
        images = atlas()
        del images["Attack-Shadow.png"]
        with self.assertRaises(PMDContractError):
            inspect_pmd_assets(xml(), images)

    def test_pmd_alias_cycle_rejected(self):
        payload = xml(copy=True).replace(b"<CopyOf>Attack</CopyOf>", b"<CopyOf>Strike</CopyOf>")
        with self.assertRaises(PMDContractError):
            inspect_pmd_xml(payload)

    def test_pmd_bad_row_count_rejected(self):
        with self.assertRaises(PMDContractError):
            inspect_pmd_assets(xml(), atlas(rows=3))

    def test_actor_real_three_key_contract(self):
        r = inspect_actor_action("actor01", "Moving", actor_pngs(), (8, 8),
                                 "b" * 64, (0, 1, 0, 2))
        self.assertEqual(r["stored_frames"], 3)
        self.assertEqual(r["native_vx"], "NOT_RUN")

    def test_actor_missing_frame_rejected(self):
        frames = actor_pngs()
        del frames["Moving_3.png"]
        with self.assertRaises(ActorContractError):
            inspect_actor_action("actor01", "Moving", frames, (8, 8),
                                 "b" * 64, (0, 1, 0, 2))

    def test_actor_duplicate_frame_rejected(self):
        frames = actor_pngs()
        frames["Moving_3.png"] = frames["Moving_1.png"]
        with self.assertRaises(ActorContractError):
            inspect_actor_action("actor01", "Moving", frames, (8, 8),
                                 "b" * 64, (0, 1, 0, 2))

    def test_map_object_ownership_accepted(self):
        objs, sources, masks, full, occ = object_fixture()
        r = inspect_object_masks((8, 8), full, occ, objs, sources, masks)
        self.assertEqual(r["status"], "PASS_STATIC_ONLY")
        self.assertEqual(r["occlusion_semantics"], "PENDING")

    def test_map_source_sha_rejected(self):
        objs, sources, masks, full, occ = object_fixture()
        objs[0]["source_sha256"] = "0" * 64
        with self.assertRaises(ObjectMaskError):
            inspect_object_masks((8, 8), full, occ, objs, sources, masks)

    def test_map_missing_owned_pixel_rejected(self):
        objs, sources, masks, full, occ = object_fixture()
        masks["complete.png"] = png((8, 8), "L")
        with self.assertRaises(ObjectMaskError):
            inspect_object_masks((8, 8), full, occ, objs, sources, masks)

    def test_map_occlusion_not_subset_rejected(self):
        objs, sources, masks, full, occ = object_fixture()
        im = Image.new("L", (8, 8))
        im.putpixel((0, 0), 255)
        b = BytesIO()
        im.save(b, "PNG")
        masks["occ.png"] = b.getvalue()
        with self.assertRaises(ObjectMaskError):
            inspect_object_masks((8, 8), full, occ, objs, sources, masks)


if __name__ == "__main__":
    unittest.main()
