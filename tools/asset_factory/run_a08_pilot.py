"""A08 report-driven factory manifest dry run. NO paid generation, NO image work.

Run from repository root:
  python -m tools.asset_factory.run_a08_pilot
The JSON result contains exceptions only and never claims native/art success.
"""
from __future__ import annotations

import json
from pathlib import Path

from tools.asset_factory.production_gate import inspect_production_job


def audit_batch(manifest: dict) -> dict:
    if manifest.get("schema") != "fs-asset-factory-pilot-batch/v1":
        raise ValueError("unsupported pilot batch")
    reports = [inspect_production_job(job) for job in manifest["jobs"]]
    return {
        "schema": "fs-asset-factory-dryrun-report/v1",
        "job_count": len(reports),
        "kind_counts": {k: sum(r["kind"] == k for r in reports) for k in ("sprite", "map")},
        "total_generation_calls": sum(job["generation"]["requested_calls"] for job in manifest["jobs"]),
        "outcomes": reports,
        "blocked_jobs": [r["asset_id"] for r in reports if r["status"] != "READY_FOR_NEXT_GATE"],
        "new_asset_outputs": 0,
        "art_pass": 0,
        "native_vx_pass": 0,
        "production_scale_approved": False,
    }


def load_and_audit(path: str | Path | None = None) -> dict:
    if path is None:
        path = (Path(__file__).resolve().parents[2] /
                "config/asset_factory/FS_A08_PILOT_JOBS_V1.json")
    return audit_batch(json.loads(Path(path).read_text(encoding="utf-8")))


if __name__ == "__main__":
    print(json.dumps(load_and_audit(), indent=2, ensure_ascii=False))
