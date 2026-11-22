#!/usr/bin/env python3
"""T-A A62 F0 *visible-pixel* source audit. Not a real LPC equipment gate.

This validator intentionally never outputs ART_PASS or new attack frame success.
Use after packaging owner-private PNG/ORA. It ensures the belly/torso pixels
were not replaced by polygon color swatches or generated fill pixels.
"""
from __future__ import annotations
import argparse
import hashlib
import io
import json
from pathlib import Path
import xml.etree.ElementTree as ET
import zipfile

from PIL import Image

EXPECTED_LAYER_NAMES = (
    'hair_face_visible', 'far_sleeve_visible', 'near_sleeve_visible',
    'torso_and_abdomen_original', 'belt_and_waist_original',
    'trousers_original', 'boots_original')


def inspect(source_path: Path, ora_path: Path, report_path: Path) -> dict:
    original = Image.open(source_path).convert('RGBA')
    assert original.size == (48, 48), f'Original actual A62 source size {original.size} != 48x48'
    raw_bytes = original.tobytes()
    report = json.loads(report_path.read_text(encoding='utf-8'))
    assert report['source_sha256'] == hashlib.sha256(source_path.read_bytes()).hexdigest()
    assert report['complete_modular_lpc_source_verified'] is False
    assert report['art_status'] == 'R20_BASELINE_ONLY_NOT_NEW_ART'
    with zipfile.ZipFile(ora_path) as z:
        assert z.testzip() is None
        assert z.read('mimetype') == b'image/openraster'
        xml = ET.fromstring(z.read('stack.xml'))
        assert xml.attrib['w'] == '48' and xml.attrib['h'] == '48'
        original_layers = xml.find('stack').findall('layer')
        assert len(original_layers) == 7
        assert {name for name in EXPECTED_LAYER_NAMES} == {el.attrib['name'].split(' (')[0] for el in original_layers}
        layers = [Image.open(io.BytesIO(z.read(el.attrib['src']))).convert('RGBA')
                  for el in original_layers]
        merged = Image.open(io.BytesIO(z.read('mergedimage.png'))).convert('RGBA')
        assert merged.tobytes() == raw_bytes, 'Merged ORA differs from approved F0 source'
        rebuilt = Image.new('RGBA', (48, 48))
        for layer in reversed(layers):
            assert layer.size == original.size
            rebuilt.alpha_composite(layer)
        assert rebuilt.tobytes() == raw_bytes, 'ORA visible layer stack does not recompose source'
        verified_layers = 0
        no_duplicate_ownership = 0
        origin = original.load()
        lp = [layer.load() for layer in layers]
        for y in range(48):
            for x in range(48):
                pixel = origin[x, y]
                owned = [layer[x, y] for layer in lp if layer[x, y][3] > 0]
                if pixel[3] == 0:
                    assert not owned, f'new pixel at ({x},{y})'
                else:
                    assert len(owned) == 1, f'pixel owner collision or hole at ({x},{y})'
                    assert owned[0] == pixel, f'new pixel RGB/Alpha at ({x},{y})'
                    verified_layers += 1
                    no_duplicate_ownership += 1
        assert verified_layers == 575, f'A62 raw F0 opaque pixel count changed: {verified_layers}'
        assert no_duplicate_ownership == verified_layers
    return {
        'result': 'SOURCE_VISIBLE_PIXEL_PARITY_PASS_ONLY',
        'art_status': 'R20_BASELINE_ONLY_NOT_NEW_ART',
        'formal_paper_doll_ready': False,
        'godot_native_attack': 'NOT_RUN',
        'approved_attack_12_frames': False,
        'source_sha256': report['source_sha256'],
        'source_rgba_pixels_verified': verified_layers,
        'original_size': [48, 48],
        'ora_layer_count': len(original_layers),
        'source_to_rebuilt_rgba_diff_pixels': 0,
        'missing_source': [
            'same-direction same-pose original outfit and sleeves',
            'source underpaint for occluded body and apparel',
            'matching original pants/boots animation for 45degree ATTACK'
        ]
    }


def main() -> None:
    cli = argparse.ArgumentParser()
    cli.add_argument('--source', type=Path, required=True)
    cli.add_argument('--ora', type=Path, required=True)
    cli.add_argument('--manifest', type=Path, required=True)
    args = cli.parse_args()
    print(json.dumps(inspect(args.source, args.ora, args.manifest), ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main()
