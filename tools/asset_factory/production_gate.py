"""A08 contract gate for the report's two production pipelines.

This is a MANIFEST / PLANNING gate. It never calls PixelLab, mutates artwork,
starts Game.exe, authorizes a paid operation, or certifies visual art/native.
"""
from __future__ import annotations

import re
from collections.abc import Mapping


class FactoryContractError(ValueError):
    pass


_SHA = re.compile(r"^[0-9a-f]{64}$")
_ID = re.compile(r"^[A-Za-z0-9_-]{1,90}$")
_FOREGROUND_FORBIDDEN = {
    "ground_base", "grass", "flower", "dirt_path", "stone_path",
    "bridge_deck", "water", "back_shadow", "prop_background",
}
_STAGES = ("SOURCE", "STYLE", "TEMPLATE", "GENERATE", "NORMALIZE",
           "TECH_QA", "ART_QA", "FS_EXPORT", "NATIVE_QA", "CLOUD_SEAL")


def _mapping(data: object, label: str) -> Mapping:
    if not isinstance(data, Mapping):
        raise FactoryContractError(f"{label} must be an object")
    return data


def _identifier(data: object, label: str) -> str:
    if not isinstance(data, str) or not _ID.fullmatch(data):
        raise FactoryContractError(f"{label}: safe nonblank ID required")
    return data


def _positive(data: object, label: str) -> int:
    if type(data) is not int or data < 1 or data > 16384:
        raise FactoryContractError(f"{label}: positive integer required")
    return data


def _sha(value: object, label: str, optional: bool = False) -> bool:
    if optional and value is None:
        return False
    if not isinstance(value, str) or not _SHA.fullmatch(value):
        raise FactoryContractError(f"{label}: actual SHA256 or null if optional")
    return True


def _stage(job: Mapping) -> str:
    stage = job.get("requested_stage", "TEMPLATE")
    if stage not in _STAGES:
        raise FactoryContractError("unknown stage")
    return stage


def inspect_production_job(job: Mapping) -> dict:
    """Return fail-closed readiness and exact holds, not synthetic art PASS.

    Required keys are deliberately compact; adapters carry all native file
    format logic. Manifest governs whether those adapters MAY be used.
    """
    j = _mapping(job, "job")
    if j.get("schema") != "fs-asset-factory-job/v1":
        raise FactoryContractError("schema mismatch")
    kind = j.get("kind")
    if kind not in ("sprite", "map"):
        raise FactoryContractError("kind must be sprite or map")
    name = _identifier(j.get("asset_id"), "asset_id")
    stage = _stage(j)
    source = _mapping(j.get("source"), "source")
    style = _mapping(j.get("style"), "style")
    generation = _mapping(j.get("generation"), "generation")
    qa = _mapping(j.get("qa"), "qa")

    holds, errors = [], []
    source_sha = source.get("sha256")
    verified = bool(source.get("verified", False))
    if source_sha is None and verified:
        errors.append("SOURCE_VERIFIED_WITHOUT_SHA")
    elif source_sha is not None:
        _sha(source_sha, "source.sha256")
    else:
        holds.append("SOURCE_SHA_MISSING")
    if not verified:
        holds.append("SOURCE_BYTES_NOT_VERIFIED")
    _identifier(style.get("profile_id"), "style.profile_id")
    if not style.get("art_reference_approved", False):
        holds.append("STYLE_ART_REFERENCE_NOT_APPROVED")

    requested = generation.get("requested_calls", 0)
    ceiling = generation.get("max_authorized_calls", 0)
    if any(type(v) is not int or v < 0 for v in (requested, ceiling)):
        errors.append("INVALID_GENERATION_BUDGET")
    elif requested > 0:
        if not generation.get("explicit_user_authorization", False):
            errors.append("UNAUTHORIZED_PAID_GENERATION")
        if requested > ceiling:
            errors.append("GENERATION_EXCEEDS_APPROVED_LIMIT")

    if kind == "sprite":
        _sprite(j, holds, errors)
    else:
        _map(j, holds, errors)

    if qa.get("native_vx") == "PASS" and not qa.get("native_evidence_sha256"):
        errors.append("FAKE_NATIVE_PASS_NO_EVIDENCE")
    if qa.get("user_art") == "PASS" and not qa.get("user_art_approval_reference"):
        errors.append("FAKE_ART_PASS_NO_APPROVAL")
    if qa.get("formal_seal") == "YES":
        if (qa.get("native_vx") != "PASS" or qa.get("user_art") != "PASS"
                or not qa.get("cloud_readback_verified", False)):
            errors.append("FAKE_FORMAL_SEAL")
    # Even where all planning metadata are sound, this is NOT a source or ART check.
    errors = sorted(set(errors))
    holds = sorted(set(holds))
    return {
        "schema": "fs-asset-factory-contract-audit/v1",
        "kind": kind, "asset_id": name, "requested_stage": stage,
        "status": "FAIL_CONTRACT" if errors else ("HOLD" if holds else "READY_FOR_NEXT_GATE"),
        "errors": errors, "holds": holds,
        "auto_generation_executed": False,
        "technical_format_verified_here": False,
        "new_art_verified_here": False,
        "native_vx_executed_here": False,
        "formal_seal_granted_here": False,
    }


def _sprite(job: Mapping, holds: list[str], errors: list[str]) -> None:
    spec = _mapping(job.get("sprite"), "sprite")
    target = spec.get("native_target")
    if target not in ("PMD_XML", "FS_ACTOR_SBS"):
        errors.append("SPRITE_NATIVE_TARGET_UNKNOWN")
        return
    actions = spec.get("actions", [])
    if not isinstance(actions, list) or not actions:
        errors.append("SPRITE_ACTIONS_EMPTY")
        return
    for a in actions:
        action = _mapping(a, "action")
        _identifier(action.get("name"), "action.name")
        num = _positive(action.get("canonical_frames"), "canonical_frames")
        if target == "PMD_XML":
            actual = _positive(action.get("native_xml_frames"), "native_xml_frames")
            if num != actual:
                errors.append("PMD_NATIVE_FRAME_COUNT_MISMATCH")
            physical_rows = action.get("native_rows")
            if physical_rows not in (1, 8):
                errors.append("PMD_NATIVE_ROWS_NOT_SOURCE_DERIVED")
            if physical_rows == 8 and not action.get("eight_direction_art_verified", False):
                holds.append("EIGHT_DIRECTION_ART_NOT_VERIFIED")
            if not action.get("xml_source_verified", False):
                holds.append("PMD_ACTION_XML_SOURCE_NOT_VERIFIED")
        elif target == "FS_ACTOR_SBS":
            if num != 3:
                errors.append("ACTOR_THREE_KEYFRAME_CONTRACT")
            playback = action.get("playback")
            if (not isinstance(playback, list) or len(playback) < 3 or
                    any(type(i) is not int or i < 0 or i > 2 for i in playback)):
                errors.append("ACTOR_PLAYBACK_INVALID")
            if not action.get("forty_five_degree_visual_approved", False):
                holds.append("ACTOR_45DEG_VISUAL_NOT_APPROVED")
        if not action.get("anchor_verified", False):
            holds.append("ANIMATION_PIVOT_PENDING")
    if not spec.get("approved_concept_sha256"):
        holds.append("SPRITE_CONCEPT_SOURCE_NOT_APPROVED")
    else:
        _sha(spec["approved_concept_sha256"], "sprite.approved_concept_sha256")


def _map(job: Mapping, holds: list[str], errors: list[str]) -> None:
    spec = _mapping(job.get("map"), "map")
    if spec.get("native_contract") != "MASTER_FIRST_4_LAYER" or spec.get("tile_size") != 32:
        errors.append("FS_MASTER_FIRST_32PX_CONTRACT_VIOLATED")
    scene = spec.get("scene_id")
    _identifier(scene, "scene_id")
    obj = spec.get("objects")
    if not isinstance(obj, list) or not obj:
        errors.append("MAP_SEMANTIC_OBJECTS_EMPTY")
        return
    seen = set()
    for it in obj:
        item = _mapping(it, "map.objects item")
        oid = _identifier(item.get("id"), "map.object.id")
        if oid in seen:
            errors.append("MAP_DUPLICATE_OBJECT_ID")
        seen.add(oid)
        kind = item.get("semantic_class")
        if not isinstance(kind, str) or not kind.strip():
            errors.append("MAP_OBJECT_SEMANTIC_CLASS_MISSING")
        foreground = item.get("runtime_foreground", False)
        if type(foreground) is not bool:
            errors.append("MAP_FOREGROUND_NOT_BOOLEAN")
        elif foreground:
            if kind in _FOREGROUND_FORBIDDEN:
                errors.append(f"MAP_FOREGROUND_FORBIDDEN:{oid}:{kind}")
            if not item.get("object_source_separated", False):
                holds.append(f"MAP_OBJECT_NOT_SEMANTICALLY_SEPARATED:{oid}")
            if not item.get("depth_footpoint_rule"):
                holds.append(f"MAP_DEPTH_FOOTPOINT_RULE_MISSING:{oid}")
            if not item.get("occlusion_mask_sha256"):
                holds.append(f"MAP_OCCLUSION_MASK_SOURCE_MISSING:{oid}")
            else:
                _sha(item["occlusion_mask_sha256"], f"map.{oid}.occlusion_mask_sha256")
    if not spec.get("master_1x_art_approved", False):
        holds.append("MAP_MASTER_1X_ART_NOT_APPROVED")
    if not spec.get("collision_semantics_approved", False):
        holds.append("MAP_COLLISION_SEMANTICS_UNAPPROVED")
    if not spec.get("full_authoring_object_inventory", False):
        holds.append("MAP_FULL_SOURCE_OBJECT_OWNERSHIP_PENDING")
