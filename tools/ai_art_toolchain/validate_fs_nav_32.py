from pathlib import Path
import json, collections, hashlib
root=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
b=root/"outputs/FS_V21_ASF_NATIVE32_BRIDGE_A03"
fs=Path(r"E:\GameAssetToolLab_20261023\FS_STYLE_FIRST_V21_WELL_CROP_COLLISION_20261024")
nav=json.loads((b/"nav/nav-grid.json").read_text(encoding="utf-8-sig"))
source=json.loads((fs/"build/BlockedTiles.json").read_text(encoding="utf-8-sig"))
manifest=json.loads((fs/"scene_manifest.json").read_text(encoding="utf-8-sig"))
blocked={tuple(x) for x in source["all_blocked_tiles"]}
assert len(blocked)==23
cols,rows=17,13
errors=[]
for cy in range(rows):
 for cx in range(cols):
  x,y=cx*32+16,cy*32+16
  if not (0<=x<nav["cols"] and 0<=y<nav["rows"]):errors.append(["outside",cx,cy]);continue
  observed=nav["moves"][y][x]=="#"
  expected=(cx,cy) in blocked
  if observed!=expected:errors.append(["collisionMismatch",cx,cy,observed,expected])
start=tuple(int(v//32) for v in manifest["spawn_world"])
seen={start}
q=collections.deque([start])
while q:
 x,y=q.popleft()
 for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
  c=(x+dx,y+dy)
  if 0<=c[0]<cols and 0<=c[1]<rows and c not in blocked and c not in seen:
   seen.add(c);q.append(c)
all_walkable={(x,y) for x in range(cols) for y in range(rows)}-blocked
if seen!=all_walkable: errors.append(["unreachable",sorted(all_walkable-seen)])
for x,y in seen:
 cx,cy=x*32+16,y*32+16
 if nav["reachable"][cy][cx]!="1":errors.append(["navReachMismatch",x,y])
res={"src_blocked":len(blocked),"src_walkable":len(all_walkable),"bfs_reachable":len(seen),"nav_sampled_tiles":cols*rows,"spawn_tile":start,"errors":errors,"pass":not errors}
(root/"reports/A03_FS_NAV_32PX_PARITY.json").write_text(json.dumps(res,indent=2,ensure_ascii=False),encoding="utf-8")
print(json.dumps(res,ensure_ascii=True)[:10000])
if errors:raise SystemExit(1)
