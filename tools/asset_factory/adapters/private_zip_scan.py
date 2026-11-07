"""Source-locked PMD ZIP scan for isolated private execution, not public-art CI.

Consumes in-memory ZIP entries. Returns non-image metadata only. No filesystem extraction.
"""
from __future__ import annotations

import hashlib
import re
from io import BytesIO
from pathlib import Path
from zipfile import BadZipFile, ZipFile

from tools.asset_factory.adapters.pmd import PMDContractError, inspect_pmd_assets


class PrivateZipError(ValueError):
    pass


def scan_pmd_zip(zip_bytes: bytes, source_prefix: str, expected_zip_sha256: str) -> dict:
    if not isinstance(zip_bytes, bytes) or not zip_bytes or len(zip_bytes) > 80_000_000:
        raise PrivateZipError('ZIP missing or over 80MB')
    if not isinstance(source_prefix, str) or not re.fullmatch(r'[A-Za-z0-9_-]{1,80}', source_prefix):
        raise PrivateZipError('unsafe source prefix')
    if not isinstance(expected_zip_sha256, str) or not re.fullmatch(r'[0-9a-f]{64}', expected_zip_sha256):
        raise PrivateZipError('SHA256 lock required')
    digest = hashlib.sha256(zip_bytes).hexdigest()
    if digest != expected_zip_sha256:
        raise PrivateZipError('whole ZIP SHA256 mismatch')
    try:
        with ZipFile(BytesIO(zip_bytes)) as archive:
            members = archive.infolist()
            names = [m.filename for m in members]
            if len(names) != len(set(names)):
                raise PrivateZipError('duplicate ZIP names are forbidden')
            if len(names) > 2000 or sum(m.file_size for m in members) > 160_000_000:
                raise PrivateZipError('ZIP size or entry limit exceeded')
            if any(n.startswith('/') or '\\' in n or '..' in Path(n).parts for n in names):
                raise PrivateZipError('unsafe ZIP path')
            prefix = source_prefix + '/'
            xml_name = prefix + 'AnimData.xml'
            if xml_name not in names:
                raise PrivateZipError('expected native AnimData.xml missing')
            xml_bytes = archive.read(xml_name)
            pngs = {}
            for name in names:
                if name.startswith(prefix) and name.endswith('.png') and name.count('/') == 1:
                    pngs[name[len(prefix):]] = archive.read(name)
            inspection = inspect_pmd_assets(xml_bytes, pngs)
            actions = inspection['actions']
            sheets = inspection['sheets']
            return {
                'schema': 'fs-private-pmd-zip-scan/v1',
                'status': 'PASS_STATIC_ONLY',
                'source_prefix': source_prefix,
                'zip_sha256': digest,
                'xml_sha256': inspection['xml_sha256'],
                'action_count': len(sheets),
                'alias_count': len(actions) - len(sheets),
                'native_png_checked': len(sheets) * 3,
                'direction_rows': {
                    'one_row': sum(x['rows'] == 1 for x in sheets.values()),
                    'eight_rows': sum(x['rows'] == 8 for x in sheets.values()),
                },
                'pilot': {
                    name: {k: v for k, v in actions[name].items() if k in ('frame_width','frame_height','frame_count')}
                    for name in ('Idle','Walk','Attack') if name in actions and 'copy_of' not in actions[name]
                },
                'source_integrity': 'ACTUAL_PRIVATE_BYTES_CHECKED',
                'direction_identity': 'NOT_TESTED',
                'native_vx': 'NOT_RUN',
                'user_art': 'PENDING',
                'formal_seal': 'NO',
            }
    except (BadZipFile, KeyError, OSError, PMDContractError) as exc:
        raise PrivateZipError(f'native PMD ZIP inspection failed: {exc}') from exc
