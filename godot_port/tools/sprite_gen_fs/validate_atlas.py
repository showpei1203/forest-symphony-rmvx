#!/usr/bin/env python3
"""Forest Symphony source-preserving sprite-gen atlas QA and Godot sidecar adapter.

This utility never edits the source manifest or atlas and never approves art.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys

from PIL import Image

PROFILES = {'generic', 'actor64', 'monster_variable', 'prop'}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def positive_integer(value: object, name: str, allow_zero: bool = False) -> int:
    if not isinstance(value, int) or isinstance(value, bool):
        raise ValueError(f'{name}: expected integer')
    if value < (0 if allow_zero else 1):
        raise ValueError(f'{name}: out of range')
    return value


def convert(manifest_path: Path, atlas_path: Path, profile: str = 'generic', expect: dict[str, int] | None = None) -> dict:
    if profile not in PROFILES:
        raise ValueError(f'unsupported profile: {profile}')
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    if not isinstance(manifest, dict):
        raise ValueError('manifest root must be an object')
    layout = manifest.get('frame_layout')
    if not isinstance(layout, dict) or not isinstance(layout.get('rows'), dict):
        raise ValueError('missing frame_layout.rows')
    sw = positive_integer(layout.get('sheetWidth'), 'sheetWidth')
    sh = positive_integer(layout.get('sheetHeight'), 'sheetHeight')
    cw = positive_integer(layout.get('cellWidth'), 'cellWidth')
    ch = positive_integer(layout.get('cellHeight'), 'cellHeight')
    if profile == 'actor64' and (cw, ch) != (64, 64):
        raise ValueError(f'actor64 requires 64x64 cells; got {cw}x{ch}')
    if profile == 'monster_variable' and (cw != ch or cw not in (64, 96, 128, 160, 192)):
        raise ValueError('monster_variable cell must be square, one of 64/96/128/160/192')
    animation = manifest.get('animation', {})
    anim_rows = animation.get('rows', {}) if isinstance(animation, dict) else {}
    if not isinstance(anim_rows, dict):
        raise ValueError('animation.rows must be an object')
    if not layout['rows']:
        raise ValueError('no animation states')
    with Image.open(atlas_path) as source:
        if source.size != (sw, sh):
            raise ValueError(f'atlas size {source.size} disagrees with manifest {(sw, sh)}')
        if source.mode != 'RGBA':
            raise ValueError('source atlas must be RGBA (transparent PNG)')
        img = source.copy()
    out_states: dict[str, dict] = {}
    warnings = []
    for state, rects in layout['rows'].items():
        if not isinstance(state, str) or not state or not isinstance(rects, list) or not rects:
            raise ValueError('invalid state name or empty frame list')
        metadata = anim_rows.get(state, {})
        if not isinstance(metadata, dict):
            raise ValueError(f'{state}: invalid animation metadata')
        fps = metadata.get('fps', 8)
        if not isinstance(fps, (float, int)) or isinstance(fps, bool) or not 0 < fps <= 120:
            raise ValueError(f'{state}: fps must be 0 < fps <= 120')
        loop = metadata.get('loop', False)
        if not isinstance(loop, bool):
            raise ValueError(f'{state}: loop must be boolean')
        if 'frames' in metadata and metadata['frames'] != len(rects):
            raise ValueError(f'{state}: animation.frames does not match atlas region count')
        durations = metadata.get('durations_ms', [round(1000 / fps)] * len(rects))
        if not isinstance(durations, list) or len(durations) != len(rects):
            raise ValueError(f'{state}: durations_ms length mismatch')
        if expect is not None and state in expect and len(rects) != expect[state]:
            raise ValueError(f'{state}: expected {expect[state]} frames, got {len(rects)}')
        frames = []
        hashes = []
        for i, rect in enumerate(rects):
            if not isinstance(rect, dict):
                raise ValueError(f'{state}[{i}]: region must be object')
            x = positive_integer(rect.get('x'), f'{state}[{i}].x', allow_zero=True)
            y = positive_integer(rect.get('y'), f'{state}[{i}].y', allow_zero=True)
            w = positive_integer(rect.get('w'), f'{state}[{i}].w')
            h = positive_integer(rect.get('h'), f'{state}[{i}].h')
            if x + w > sw or y + h > sh:
                raise ValueError(f'{state}[{i}]: region exceeds atlas')
            if w != cw or h != ch:
                raise ValueError(f'{state}[{i}]: region not equal to declared cell size')
            duration = durations[i]
            if not isinstance(duration, (int, float)) or isinstance(duration, bool) or duration <= 0:
                raise ValueError(f'{state}[{i}]: invalid duration')
            crop = img.crop((x, y, x + w, y + h))
            alpha = crop.getchannel('A')
            if alpha.getbbox() is None:
                raise ValueError(f'{state}[{i}]: entirely transparent frame')
            hashes.append(hashlib.sha256(crop.tobytes()).hexdigest())
            frames.append({'region': [x, y, w, h], 'duration_ms': duration})
        duplicates = len(hashes) - len(set(hashes))
        if duplicates:
            warnings.append(f'{state}: {duplicates} repeated source frame(s), visual review required')
        out_states[state] = {'fps': fps, 'loop': loop, 'frames': frames, 'repeated_frames': duplicates}
    if expect:
        missing = set(expect) - set(out_states)
        if missing:
            raise ValueError(f'missing expected states: {sorted(missing)}')
    return {
        'schema': 'fs-sprite-gen-atlas/v1',
        'source_tool': 'aldegad/sprite-gen',
        'source_manifest_sha256': digest(manifest_path),
        'atlas_sha256': digest(atlas_path),
        'atlas_size': [sw, sh],
        'cell_size': [cw, ch],
        'profile': profile,
        'technical_qa': 'PASS',
        'art_gate': 'HOLD',
        'states': out_states,
        'warnings': warnings,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', required=True, type=Path)
    parser.add_argument('--atlas', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path, help='New Godot sidecar JSON, never overwrites existing file')
    parser.add_argument('--profile', choices=sorted(PROFILES), default='generic')
    parser.add_argument('--expect', action='append', default=[], metavar='STATE=FRAMES')
    args = parser.parse_args()
    try:
        expected = {}
        for item in args.expect:
            state, sep, value = item.partition('=')
            if not sep or not state or state in expected:
                raise ValueError('Expected --expect STATE=FRAMES, each state once')
            expected[state] = positive_integer(int(value), f'expected {state}')
        if args.output.exists():
            raise ValueError('Refusing to overwrite existing output file')
        data = convert(args.manifest, args.atlas, args.profile, expected or None)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
        print('FS_SPRITE_GEN_ATLAS_QA_PASS states=' + str(len(data['states'])) + ' art=HOLD')
        return 0
    except (ValueError, OSError, json.JSONDecodeError, KeyError) as exc:
        print(f'FS_SPRITE_GEN_ATLAS_QA_FAIL: {exc}', file=sys.stderr)
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
