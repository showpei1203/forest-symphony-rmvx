"""A36C: source-only Godot forest repetition audit. Python stdlib only.
Usage: python tools/a36c/audit_tree_distribution.py data/a36b_ecological_tree_manifest.json
Reads manifest; never writes artwork, scene, or private files.
"""
import collections
import json
import math
import pathlib
import sys

def audit(data):
    width, height = data["world_px"]
    assert (width, height) == (2560, 1856)
    assert data["cell_px"] == 32
    trees = [o for o in data["objects"] if o["semantic"] == "tree"]
    assert len(data["objects"]) == 326
    families = collections.Counter(o["family"] for o in trees)
    cells = collections.defaultdict(list)
    # Fixed 320x232 px observation bins: no invented geographic labels.
    for tree in trees:
        x, y = tree["foot"]
        assert 0 <= x < width and 0 <= y < height, (tree["id"], tree["foot"])
        cells[(min(x // 320, 7), min(y // 232, 7))].append(tree)
    hotspots = []
    for (cx, cy), members in sorted(cells.items()):
        counts = collections.Counter(o["family"] for o in members)
        top, n = counts.most_common(1)[0]
        hotspots.append({"cell": [cx, cy], "trees": len(members),
                         "families": len(counts), "dominant_family": top,
                         "dominant_ratio": round(n / len(members), 3)})
    # Pairwise nearest-neighbor analysis, excluding self.
    nearest = []
    for i, a in enumerate(trees):
        x, y = a["foot"]
        nearest.append(min(math.hypot(x - b["foot"][0], y - b["foot"][1])
                           for j, b in enumerate(trees) if i != j))
    total = len(trees)
    return {
        "schema": "fs.a36c.tree_audit.v1",
        "status": "SOURCE_ONLY_AUDIT_NOT_ART_PASS",
        "world_px": [width, height],
        "tree_count": total,
        "family_count": len(families),
        "family_counts": dict(sorted(families.items())),
        "largest_family_share": round(max(families.values()) / total, 4),
        "nearest_foot_distance_px": {
            "min": round(min(nearest), 2),
            "mean": round(sum(nearest) / total, 2),
            "max": round(max(nearest), 2)},
        "hotspots": sorted(hotspots, key=lambda h:
                           (-h["dominant_ratio"], -h["trees"], h["cell"])),
        "qa": {"art": "HOLD", "collision": "HOLD",
               "water_animation": "NOT_IMPLEMENTED",
               "godot_native_a36c": "NOT_RUN"},
    }

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: audit_tree_distribution.py MANIFEST.json")
    source = pathlib.Path(sys.argv[1])
    print(json.dumps(audit(json.loads(source.read_text(encoding="utf-8"))),
                     indent=2, ensure_ascii=False))
