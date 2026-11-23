"""Offline fixture tests; never use private game images."""
import json
from pathlib import Path
import tempfile
import unittest

from PIL import Image

from validate_atlas import convert


class TestSpriteGenAdapter(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        atlas = Image.new('RGBA', (128, 64), (0, 0, 0, 0))
        for x in (0, 64):
            for xx in range(x + 12, x + 40):
                for yy in range(15, 52):
                    atlas.putpixel((xx, yy), (205, 80 + x, 40, 255))
        atlas.save(self.root / 'sprite-sheet-alpha.png')
        self.manifest = {
            'frame_layout': {'sheetWidth': 128, 'sheetHeight': 64, 'cellWidth': 64, 'cellHeight': 64,
                             'rows': {'ATTACK': [{'x': 0, 'y': 0, 'w': 64, 'h': 64},
                                                 {'x': 64, 'y': 0, 'w': 64, 'h': 64}]}},
            'animation': {'rows': {'ATTACK': {'fps': 12, 'loop': False, 'frames': 2, 'durations_ms': [83, 83]}}},
        }
        self.path = self.root / 'manifest.json'
        self.save()

    def tearDown(self):
        self.tmp.cleanup()

    def save(self):
        self.path.write_text(json.dumps(self.manifest), encoding='utf-8')

    def run_convert(self):
        return convert(self.path, self.root / 'sprite-sheet-alpha.png', 'actor64', {'ATTACK': 2})

    def test_valid_atlas_and_nonloop(self):
        out = self.run_convert()
        self.assertEqual(out['schema'], 'fs-sprite-gen-atlas/v1')
        self.assertEqual(out['states']['ATTACK']['frames'][1]['region'], [64, 0, 64, 64])
        self.assertEqual(out['states']['ATTACK']['loop'], False)
        self.assertEqual(out['art_gate'], 'HOLD')

    def test_reject_out_of_bounds(self):
        self.manifest['frame_layout']['rows']['ATTACK'][1]['x'] = 65
        self.save()
        with self.assertRaisesRegex(ValueError, 'exceeds atlas'):
            self.run_convert()

    def test_reject_frame_count_mismatch(self):
        self.manifest['animation']['rows']['ATTACK']['frames'] = 3
        self.save()
        with self.assertRaisesRegex(ValueError, 'does not match'):
            self.run_convert()

    def test_reject_blank_alpha(self):
        Image.new('RGBA', (128, 64), (0, 0, 0, 0)).save(self.root / 'sprite-sheet-alpha.png')
        with self.assertRaisesRegex(ValueError, 'transparent'):
            self.run_convert()


if __name__ == '__main__':
    unittest.main()
