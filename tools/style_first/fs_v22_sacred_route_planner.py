from pathlib import Path
from collections import deque
import json
R=Path(__file__).resolve().parent.parent
blocked={tuple(v) for v in json.loads((R/"build"/"BlockedTiles.json").read_text())["blocked_tiles"]}
print("blocked:",sorted(blocked))
def bfs(start,target):
 q=deque([start]);p={start:None}
 directions=[(0,-1,8),(1,0,6),(0,1,2),(-1,0,4)]
 while q:
  x,y=q.popleft()
  if (x,y)==target:break
  for dx,dy,code in directions:
   n=(x+dx,y+dy)
   if 0<=n[0]<17 and 0<=n[1]<13 and n not in blocked and n not in p:
    p[n]=((x,y),code);q.append(n)
 if target not in p:raise AssertionError(("UNREACHABLE",start,target))
 moves=[];c=target
 while c!=start:
  prev,step=p[c];moves.append(step);c=prev
 return list(reversed(moves))
goals=[("N",(12,4)),("NE",(14,4)),("E",(14,6)),("SE",(14,8)),
       ("S",(12,8)),("SW",(10,8)),("W",(10,6)),("NW",(10,4))]
# Denied entry into trunk from all four sides.
denials=[("BLOCK_FROM_N",(12,4),2,(12,5)),
         ("BLOCK_FROM_E",(14,6),4,(13,6)),
         ("BLOCK_FROM_S",(12,7),8,(12,6)),
         ("BLOCK_FROM_W",(11,6),6,(12,6))]
for tag,p in goals:
 assert p not in blocked,(tag,p)
for tag,start,step,b in denials:
 assert start not in blocked and b in blocked,(tag,start,b)
routes=[];at=(8,11)
for tag,target in goals:
 moves=bfs(at,target);routes.append({"name":tag,"tile":list(target),"moves":moves});at=target
for tag,target,step,forbidden in denials:
 moves=bfs(at,target)
 routes.append({"name":tag,"tile":list(target),"moves":moves,"deny_move":step,"deny_tile":list(forbidden)})
 at=target
result={"origin":[8,11],"sacred_source":"sacred_tree_new_style_v22","targets":dict((n,list(p)) for n,p in goals),
        "blocked_tiles":sorted(map(list,blocked)),"route_steps":sum(len(i["moves"]) for i in routes),
        "routes":routes,"actor_steps":"REAL_RM_VX_MOVE_DIRECTION_ONLY","positions":"BFS_REACHABLE","human":"PENDING"}
(R/"input"/"V22_SACRED_8WAY_ROUTES.json").write_text(json.dumps(result,indent=2),encoding="utf8")
print("V22_SACRED_ROUTE_PLANNED",json.dumps({"steps":result["route_steps"],"route_lengths":[(r["name"],len(r["moves"])) for r in routes]},ensure_ascii=False),flush=True)
