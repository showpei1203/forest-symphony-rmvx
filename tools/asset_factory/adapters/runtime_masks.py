"""Scoped real Master-first runtime PAR validation, NOT whole authoring-PAR acceptance."""
from __future__ import annotations

import hashlib
from io import BytesIO
import re
from typing import Mapping

from PIL import Image, ImageChops


class RuntimeMaskError(ValueError):
    pass


def _img(payload: bytes, label: str) -> Image.Image:
    if not isinstance(payload, bytes) or not payload:
        raise RuntimeMaskError(f'{label}: missing bytes')
    try:
        with Image.open(BytesIO(payload)) as pic:
            if pic.format != 'PNG':
                raise RuntimeMaskError(f'{label}: PNG required')
            return pic.copy()
    except (OSError, ValueError) as e:
        raise RuntimeMaskError(f'{label}: unreadable PNG {e}') from e


def check_runtime_objects(
    master_png: bytes,
    runtime_par_png: bytes,
    object_masks: Mapping[str, bytes],
    object_sha256: Mapping[str, str],
    expected_master_sha256: str,
) -> dict:
    """1:1 same-world-XY RGB proof and all runtime alpha pixel ownership.

    Inputs are real full-canvas authored file bytes; no resizing or composing here.
    This proves source and ownership, NOT whether mask should obscure a walkable actor.
    """
    if not isinstance(expected_master_sha256, str) or not re.fullmatch(r'[0-9a-f]{64}', expected_master_sha256):
        raise RuntimeMaskError('approved master SHA256 required')
    if hashlib.sha256(master_png).hexdigest() != expected_master_sha256:
        raise RuntimeMaskError('master SHA256 mismatch')
    master = _img(master_png, 'master').convert('RGBA')
    par = _img(runtime_par_png, 'runtime PAR').convert('RGBA')
    if master.size != par.size or master.size[0] % 32 or master.size[1] % 32:
        raise RuntimeMaskError('invalid equal 32px-grid canvas')
    if master.getchannel('A').getextrema() != (255, 255):
        raise RuntimeMaskError('master not fully opaque')
    if not object_masks or not isinstance(object_masks, Mapping) or set(object_masks) != set(object_sha256):
        raise RuntimeMaskError('complete object mask/sha inventory required')
    union = Image.new('L', master.size, 0)
    counts = {}
    for oid, payload in object_masks.items():
        if not isinstance(oid, str) or not re.fullmatch(r'[A-Za-z0-9_-]{1,80}', oid):
            raise RuntimeMaskError('invalid object id')
        sha = object_sha256[oid]
        if not isinstance(sha, str) or not re.fullmatch(r'[0-9a-f]{64}', sha):
            raise RuntimeMaskError(f'{oid}: invalid mask SHA256 lock')
        if hashlib.sha256(payload).hexdigest() != sha:
            raise RuntimeMaskError(f'{oid}: mask SHA256 mismatch')
        src = _img(payload, oid)
        if src.mode not in ('L','RGBA') or src.size != master.size:
            raise RuntimeMaskError(f'{oid}: full-canvas L/RGBA mask required')
        mask = src if src.mode == 'L' else src.getchannel('A')
        if any(v not in (0, 255) for v in mask.getextrema()):
            raise RuntimeMaskError(f'{oid}: alpha not binary')
        binary = mask.point(lambda v: 255 if v else 0)
        if ImageChops.difference(mask, binary).getbbox():
            raise RuntimeMaskError(f'{oid}: intermediate alpha forbidden')
        if not mask.getbbox():
            raise RuntimeMaskError(f'{oid}: empty mask')
        if ImageChops.multiply(union, mask).getbbox():
            raise RuntimeMaskError(f'{oid}: overlapping source owners')
        union = ImageChops.lighter(union, mask)
        counts[oid] = mask.histogram()[255]
    if ImageChops.difference(union, par.getchannel('A')).getbbox():
        raise RuntimeMaskError('runtime PAR alpha differs from union of owned masks')
    diff = ImageChops.difference(master.convert('RGB'), par.convert('RGB'))
    if ImageChops.multiply(diff, Image.merge('RGB',(union,union,union))).getbbox():
        raise RuntimeMaskError('runtime PAR RGB not sourced from same master XY')
    return {
        'schema': 'fs-master-runtime-owned/v1',
        'status': 'PASS_STATIC_ONLY', 'canvas': list(master.size),
        'master_sha256': expected_master_sha256,
        'runtime_par_sha256': hashlib.sha256(runtime_par_png).hexdigest(),
        'object_count': len(object_masks), 'object_alpha_pixels': counts,
        'owned_alpha_pixels': sum(counts.values()),
        'overlapping_owner_pixels': 0,
        'runtime_rgb_registration': 'PASS_SAME_XY',
        'runtime_alpha_ownership': 'PASS',
        'authoring_complete_par_ownership': 'NOT_TESTED',
        'walkable_footpoint_occlusion_semantics': 'NOT_TESTED',
        'native_vx': 'NOT_RUN_THIS_ITERATION', 'user_art': 'PENDING', 'formal_seal': 'NO',
    }
