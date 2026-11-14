"""A37 deterministic tree placement proposal generator.
Inputs: private, authorized source tree atlas metadata and biome mask.
Does NOT modify sealed scenes or pretend to generate production PAR.
"""
from dataclasses import dataclass, asdict
import json, math, random

@dataclass(frozen=True)
class Tree:
    id: str
    size: str
    radius: int

TREES = [
    Tree("T1_sapling", "small", 22),
    Tree("T2_squat", "small", 36),
    Tree("T3_tall", "medium", 32),
    Tree("T4_split", "medium", 46),
    Tree("T5_mature", "large", 68),
    Tree("T6_ancient", "landmark", 94),
]
BIOMES = {
    "deep": (0.82, [2, 3, 8, 8, 12, 1]),
    "edge": (0.56, [3, 7, 7, 7, 4, 0]),
    "village": (0.26, [7, 8, 4, 3, 1, 0]),
    "clearing": (0.07, [8, 2, 0, 0, 0, 0]),
}
def generate(width, height, biome_at, walkable_at, seed=3701, attempts=12000):
    rng = random.Random(seed)
    placed = []
    for _ in range(attempts):
        x, y = rng.randrange(width), rng.randrange(height)
        biome = biome_at(x, y)
        density, weights = BIOMES[biome]
        if rng.random() > density:
            continue
        tree = rng.choices(TREES, weights=weights, k=1)[0]
        if not walkable_at(x, y, tree.radius):
            continue
        if any((x-p["x"])**2+(y-p["y"])**2 <
               ((tree.radius+p["radius"])*0.62)**2 for p in placed):
            continue
        if sum(p["id"]==tree.id for p in placed[-2:]) == 2:
            continue
        placed.append({"id":tree.id,"x":x,"y":y,
                       "radius":tree.radius,"biome":biome,
                       "foot_y":y})
    return sorted(placed, key=lambda p:(p["foot_y"],p["id"],p["x"]))
def write_manifest(path, width, height, biome_at, walkable_at, seed=3701):
    data={"schema":"fs.a37.tree-proposal.v1","seed":seed,
          "dimensions":[width,height],
          "status":"PROPOSAL_ONLY_NO_PAR_NO_ENGINE_QA",
          "trees":generate(width,height,biome_at,walkable_at,seed)}
    with open(path,"w",encoding="utf-8") as f:
        json.dump(data,f,ensure_ascii=False,indent=2)
    return data
