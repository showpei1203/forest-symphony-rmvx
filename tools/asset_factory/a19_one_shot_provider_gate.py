"""FS A19: cautious, one-POST PixelLab Skeleton v3 transport gate.

This is NOT an authorization to spend credits. Live submission must only be
called after a human approved this exact request SHA and a maximum spending
amount in the current workflow; approval cannot be inferred from `continue`.

- Public code contains NO original sprite, token, or private JSON.
- Dry validation is the normal flow; no network or file writes.
- A live call requires an *isolated cloud runner*, a persistent private ledger,
  a single-use user grant, and a valid token supplied at runtime.
- Record intent before POST. If connection/result is uncertain, NEVER retry POST.
- Ledger is only a same-workspace safety net, NOT a globally coordinated cloud
  lock. Cloud orchestrator must prevent concurrent runs and persist the ledger
  to owner-only Drive before any retry/recovery. Never run on a user's PC.
"""
from __future__ import annotations

import base64
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
import hashlib
from io import BytesIO
import json
import os
from pathlib import Path
import re
import uuid
from typing import Callable
from urllib.request import Request, urlopen

from PIL import Image
from tools.asset_factory.a18_run_anatomy_preflight import audit_actor01_run
from tools.asset_factory.a15_pixellab_skeleton_v3_adapter import (
    F0_SHA, validate_provider_frames,
)

EXPECTED_REQUEST_SHA = "e392291d626ff37bb6038d40e0b63d17a7be0fc54df0835d848e50fba546fbfe"
OFFICIAL_ENDPOINT = "https://api.pixellab.ai/v2/animate-with-skeleton-v3"
OFFICIAL_JOB_ENDPOINT = "https://api.pixellab.ai/v2/background-jobs/"
PUBLISHED_ESTIMATE_USD = Decimal("0.0436")  # Official indicative price, NOT provider-side cap

class A19Hold(ValueError):
    """Do not submit and do not use credits."""

class A19UnknownSubmission(RuntimeError):
    """The POST outcome is uncertain. Reconcile jobs before new permission."""


def canonical_request_preflight(raw_json: bytes) -> tuple[dict, dict]:
    """Validate the ACTUAL A18 private request without printing any F0 data."""
    if not isinstance(raw_json, bytes) or hashlib.sha256(raw_json).hexdigest() != EXPECTED_REQUEST_SHA:
        raise A19Hold("Unknown A18 request checksum; refuses any provider call")
    try:
        payload = json.loads(raw_json)
        frame = payload["first_frame"]
        if not isinstance(frame, dict) or frame.get("type", "base64") != "base64":
            raise A19Hold("Expected reference PNG base64 frame")
        f0 = base64.b64decode(frame["base64"], validate=True)
    except (ValueError, TypeError, KeyError) as exc:
        raise A19Hold("A18 request or F0 base64 invalid") from exc
    if hashlib.sha256(f0).hexdigest() != F0_SHA:
        raise A19Hold("Approved Actor01 F0 checksum differs")
    try:
        image = Image.open(BytesIO(f0))
        image.load()
    except (OSError, ValueError) as exc:
        raise A19Hold("Reference PNG unreadable") from exc
    if image.format != "PNG" or image.size != (48, 48):
        raise A19Hold("Expected real approved 48x48 F0 PNG")
    if set(payload) != {
        "description", "action", "direction", "view", "first_frame",
        "first_frame_keypoints", "keypoints", "template_id", "seed", "no_background",
    }:
        raise A19Hold("Unexpected provider request fields")
    if payload["template_id"] != "mannequin" or payload["view"] != "low top-down":
        raise A19Hold("Unknown template or camera configuration")
    if payload["no_background"] is not True or not isinstance(payload["seed"], int):
        raise A19Hold("Background or seed does not match pilot")
    check = audit_actor01_run(payload, f0)
    if check["status"] != "PASS_POSE_GEOMETRY_ONLY":
        raise A19Hold("A18 real-input bone/pose gate did not pass")
    return payload, {
        "request_sha256": EXPECTED_REQUEST_SHA,
        "source_f0_sha256": F0_SHA,
        "stored_key_poses": len(payload["keypoints"]),
        "geometry_gate": check["status"],
        "provider_calls": 0,
        "art_gate": "NOT_RUN",
        "vx_gate": "NOT_RUN",
        "published_estimate_usd": str(PUBLISHED_ESTIMATE_USD),
    }


def check_explicit_grant(*, request_sha: str, grant: dict) -> None:
    """Require a separately verified, current-conversation human approval receipt."""
    if not isinstance(grant, dict) or grant.get("user_explicitly_approved_one_paid_post") is not True:
        raise A19Hold("No explicit paid authorization for this run")
    if grant.get("request_sha256") != request_sha:
        raise A19Hold("Approval is for another input SHA")
    if grant.get("approved_action") != "pixel_lab_skeleton_v3_one_post":
        raise A19Hold("Approval action mismatch")
    if not isinstance(grant.get("approval_reference"), str) or len(grant["approval_reference"]) < 8:
        raise A19Hold("Missing traceable approval reference")
    try:
        cap = Decimal(str(grant["max_authorized_usd"]))
    except (KeyError, InvalidOperation, ValueError) as exc:
        raise A19Hold("Missing explicit price cap") from exc
    if not cap.is_finite() or cap <= 0 or PUBLISHED_ESTIMATE_USD > cap:
        raise A19Hold("Published price exceeds approved cap; cannot guarantee exact bill")


def _write_json_fsync(fd: int, value: dict) -> None:
    data = (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode("utf-8")
    with os.fdopen(fd, "wb", closefd=True) as fout:
        fout.write(data)
        fout.flush()
        os.fsync(fout.fileno())


class PrivateOneShotLedger:
    """Single isolated workspace guard, with immediate pre-POST intent marker."""

    def __init__(self, root: Path):
        self.root = Path(root)
        if not self.root.is_dir():
            raise A19Hold("Ledger directory must already exist in isolated CLOUD worker")

    def _path(self, sha: str) -> Path:
        if not re.fullmatch(r"[a-f0-9]{64}", sha):
            raise A19Hold("Invalid request SHA")
        return self.root / ("pixellab-one-post-" + sha + ".json")

    def claim(self, sha: str, approval_ref: str) -> Path:
        path = self._path(sha)
        try:
            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        except FileExistsError as exc:
            raise A19Hold("Same SHA has a submission intent; do NOT repeat POST") from exc
        _write_json_fsync(fd, {
            "request_sha256": sha,
            "phase": "POST_MAY_HAVE_OCCURRED",
            "approval_reference": approval_ref,
            "job_id": None,
            "retries": 0,
            "private_image_data": "NOT_STORED",
        })
        return path

    def record_job(self, path: Path, job_id: str) -> None:
        obj = json.loads(path.read_text("utf-8"))
        obj["phase"] = "SUBMITTED_ONE_POST"
        obj["job_id"] = job_id
        tmp = path.parent / (path.name + "." + str(uuid.uuid4()) + ".tmp")
        fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        _write_json_fsync(fd, obj)
        os.replace(tmp, path)


def submit_once(
    raw_request: bytes, *, grant: dict, token: str,
    ledger: PrivateOneShotLedger,
    isolated_cloud_runner_confirmed: bool,
    approved_provider_post: Callable[[str, dict, str], dict],
) -> dict:
    """One call only. Neither token nor image data may appear in log/ledger.

    `approved_provider_post` may be the production HTTPS adapter or fake mock;
    never automatically retry even when its result is a timeout or 429.
    """
    payload, info = canonical_request_preflight(raw_request)
    check_explicit_grant(request_sha=info["request_sha256"], grant=grant)
    if isolated_cloud_runner_confirmed is not True:
        raise A19Hold("Not permitted on user PC / unverified local runtime")
    if not isinstance(token, str) or not token.strip():
        raise A19Hold("No authorized token passed by controlled runner")
    if not callable(approved_provider_post):
        raise A19Hold("Provider POST adapter missing")
    path = ledger.claim(info["request_sha256"], grant["approval_reference"])
    try:
        response = approved_provider_post(OFFICIAL_ENDPOINT, payload, token)
        job_id = response["background_job_id"]
        if not isinstance(job_id, str) or not job_id.strip() or len(job_id) > 200:
            raise A19Hold("Provider returned no usable job ID")
        ledger.record_job(path, job_id)
    except Exception as exc:
        raise A19UnknownSubmission(
            "POST may have been accepted; ledger now blocks retries. "
            "Use provider job history and approval review, never repeat automatically."
        ) from exc
    return {"request_sha256": info["request_sha256"],
            "job_id": job_id, "phase": "SUBMITTED_ONE_POST",
            "provider_post_count": 1, "art_gate": "NOT_RUN", "vx_gate": "NOT_RUN"}


def provider_post_once_https(url: str, payload: dict, token: str) -> dict:
    """No hidden retry. Use only after real explicit one-post authorization."""
    if url != OFFICIAL_ENDPOINT:
        raise A19Hold("Endpoint must be official pinned Skeleton v3 POST")
    body = json.dumps(payload, separators=(",", ":")).encode("utf-8")
    req = Request(url, data=body, method="POST", headers={
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json",
    })
    with urlopen(req, timeout=90) as resp:
        return json.load(resp)


def verify_completed_raw_frames(job: dict) -> tuple[list[bytes], dict]:
    """Decode provider RAW 3 PNGs. No art approval, no inference from test fixtures."""
    if not isinstance(job, dict) or job.get("status") != "completed":
        raise A19Hold("Provider job must be completed")
    last = job.get("last_response")
    if not isinstance(last, dict) or not isinstance(last.get("images"), list):
        raise A19Hold("Provider images field missing; preserve RAW for manual reconciliation")
    sources = last["images"]
    if len(sources) != 3:
        raise A19Hold("Must return exactly 3 RAW frames")
    images = []
    png_data = []
    for item in sources:
        if not isinstance(item, dict) or not isinstance(item.get("base64"), str):
            raise A19Hold("Unknown image response structure; do not pretend decoded frames")
        try:
            data = base64.b64decode(item["base64"], validate=True)
            img = Image.open(BytesIO(data))
            img.load()
        except (OSError, ValueError) as exc:
            raise A19Hold("Provider image is not valid base64 PNG") from exc
        if img.format != "PNG":
            raise A19Hold("Provider image not PNG")
        images.append(img)
        png_data.append(data)
    validate_provider_frames(images, reference_image=None)
    return png_data, {
        "raw_frame_sha256": [hashlib.sha256(blob).hexdigest() for blob in png_data],
        "frames": len(png_data),
        "expected_px": [48, 48],
        "art_gate": "USER_REQUIRED",
        "native_vx_gate": "NOT_RUN",
        "formal_seal": False,
    }
