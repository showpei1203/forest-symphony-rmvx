#!/usr/bin/env python3
"""Read-only inventory of a private, externally SHA-pinned FS raw source ZIP.
Never executes Ruby, extracts files, emits private command parameters, or grants
boot-final authority. Run only in an authorized private workspace.
"""
import argparse
import collections
import hashlib
import io
import json
from pathlib import Path
import re
import zipfile
from rvdata_to_json import RubyMarshal48, DATA_NAMES

MAX_ZIP = 64 * 1024 * 1024
MAX_EXPANDED = 128 * 1024 * 1024
FLAGS = ('turn_ending', 'turn_valid', 'enemy_valid', 'actor_valid', 'switch_valid')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def inventory(path, expected_sha):
    path = Path(path)
    if not re.fullmatch(r'[0-9a-f]{64}', expected_sha) or path.stat().st_size > MAX_ZIP:
        raise ValueError('invalid archive pin or size')
    raw = path.read_bytes()
    if len(raw) > MAX_ZIP or digest(raw) != expected_sha:
        raise ValueError('archive SHA256 mismatch')
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        entries = z.infolist()
        names = [x.filename for x in entries]
        if len(entries) > 2048 or len(names) != len(set(names)) or sum(x.file_size for x in entries) > MAX_EXPANDED:
            raise ValueError('archive entry bounds or duplicate path')
        if any(x.flag_bits & 1 or x.file_size > MAX_EXPANDED for x in entries):
            raise ValueError('encrypted or oversized entry')
        registry = json.loads(z.read('fs_unified_source_registry.json'))
        if registry.get('schema') != 'fs-unified-original-source-index-v1' or registry.get('source_script_sections') != 505:
            raise ValueError('source registry schema')
        sections = registry['sections']
        if len(sections) != 505 or set(registry['original_data_sha256']) != set(DATA_NAMES):
            raise ValueError('source index count')
        for i, section in enumerate(sections, 1):
            name = f'rgss2/{i:03d}.rb'
            if section['section'] != i or section['relative_source_path'] != name or digest(z.read(name)) != section['source_sha256']:
                raise ValueError('indexed script hash mismatch')
        if digest(z.read('Data/Scripts.rvdata')) != registry['source_scripts_rvdata_sha256']:
            raise ValueError('Scripts.rvdata SHA mismatch')
        tables = {}
        for name in DATA_NAMES:
            data = z.read('Data/' + name + '.rvdata')
            if digest(data) != registry['original_data_sha256'][name]:
                raise ValueError('raw table SHA mismatch')
            tables[name] = RubyMarshal48(data).parse()
        rows = tables['Troops']
        if not isinstance(rows, list) or not rows or rows[0] is not None:
            raise ValueError('invalid Troop index')
        counts = collections.Counter()
        opcodes = collections.Counter()
        shapes = collections.Counter()
        for idx, row in enumerate(rows):
            if row is None:
                continue
            if row.get('id') != idx or not isinstance(row.get('pages'), list):
                raise ValueError('invalid Troop record')
            counts['troops'] += 1
            any_nonempty = False
            eligible_pages = []
            for page in row['pages']:
                counts['pages'] += 1
                c = page['condition']
                if any(type(c.get(k)) is not bool for k in FLAGS):
                    raise ValueError('invalid page condition flags')
                commands = page['list']
                if not commands or commands[-1]['code'] != 0:
                    raise ValueError('missing command terminator')
                ops = tuple(cmd['code'] for cmd in commands if cmd['code'] != 0)
                if not ops:
                    continue
                any_nonempty = True
                counts['nonempty_pages'] += 1
                opcodes.update(ops)
                shapes[','.join(map(str, ops))] += 1
                if not any(c[k] for k in FLAGS):
                    counts['inert_nonempty_pages'] += 1
                    continue
                counts['conditioned_nonempty_pages'] += 1
                plain = (ops == (122, 117) and page['span'] == 0 and c['turn_valid'] and
                         not any(c[k] for k in FLAGS if k != 'turn_valid') and
                         c['turn_a'] == 0 and c['turn_b'] == 0)
                eligible_pages.append(plain)
                if plain:
                    counts['turn_zero_plain_common_pages'] += 1
            if any_nonempty:
                counts['troops_with_nonempty_pages'] += 1
            if eligible_pages and all(eligible_pages):
                counts['troops_conditioned_pages_all_plain_common'] += 1
        return {'schema': 1, 'source_stage': 'RAW_RVDATA_NOT_POST_APPLY',
                'archive_sha256': expected_sha, 'archive_entries': len(entries),
                'script_hashes_verified': 505, 'raw_table_hashes_verified': 11,
                'raw_troops_sha256': registry['original_data_sha256']['Troops'],
                'counts': dict(sorted(counts.items())),
                'opcode_counts': dict(sorted(opcodes.items())),
                'nonempty_shapes': dict(sorted(shapes.items())),
                'common_events_raw_present': 'Data/CommonEvents.rvdata' in names,
                'boot_witness_present': 'fs_boot_final_runtime_witness.json' in names,
                'original_runtime_executed': False, 'production_approval': False}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('archive')
    p.add_argument('--sha256', required=True)
    a = p.parse_args()
    print(json.dumps(inventory(a.archive, a.sha256), sort_keys=True, indent=2))
