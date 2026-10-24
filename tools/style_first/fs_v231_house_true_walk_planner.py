from pathlib import Path
from collections import deque
import json
R=Path(__file__).resolve().parent.parent
M=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
B={tuple(x) for x in json.loads((R/"build"/"BlockedTiles.json").read_text(encoding="utf8"))["blocked_tiles"]}
goals=[
 ("BLUE_N",(6,2)),("BLUE_NE",(10,2)),("BLUE_E",(10,4)),("BLUE_SE",(10,6)),
 ("BLUE_S",(6,6)),("BLUE_SW",(3,6)),("BLUE_W",(3,4)),("BLUE_NW",(3,2)),
 ("OCHRE_N",(4,9)),("OCHRE_NE",(7,9)),("OCHRE_E",(7,10)),("OCHRE_SE",(7,12)),
 ("OCHRE_S",(4,12)),("OCHRE_SW",(0,12)),("OCHRE_W",(0,10)),("OCHRE_NW",(0,9))]
deny=[
 ("BLUE_DENY_N",(6,2),2,(6,3)),("BLUE_DENY_E",(10,4),4,(9,4)),
 ("BLUE_DENY_S",(6,6),8,(6,5)),("BLUE_DENY_W",(3,4),6,(4,4)),
 ("OCHRE_DENY_N",(4,9),2,(4,10)),("OCHRE_DENY_E",(7,10),4,(6,10)),
 ("OCHRE_DENY_S",(4,12),8,(4,11)),("OCHRE_DENY_W",(0,10),6,(1,10)),
 ("SACRED_REGRESSION",(12,6),6,(13,6)),("WELL_REGRESSION",(7,8),6,(8,8))]
D=[(0,-1,8),(1,0,6),(0,1,2),(-1,0,4)]
def route(a,b):
 q=deque([a]);parents={a:None}
 while q:
  p=q.popleft()
  if p==b:break
  for dx,dy,n in D:
   t=p[0]+dx,p[1]+dy
   if 0<=t[0]<17 and 0<=t[1]<13 and t not in B and t not in parents:
    parents[t]=(p,n);q.append(t)
 assert b in parents,("STAND_UNREACHABLE",a,b)
 v=[];now=b
 while now!=a:
  parent,dr=parents[now];v.append(dr);now=parent
 return v[::-1]
here=(8,11);rows=[]
for label,pt in goals:
 assert pt not in B,(label,pt)
 moves=route(here,pt);rows.append({"name":label,"tile":list(pt),"moves":moves});here=pt
for label,pt,move,forbidden in deny:
 assert pt not in B and forbidden in B,(label,pt,forbidden)
 moves=route(here,pt)
 rows.append({"name":label,"tile":list(pt),"moves":moves,"deny_move":move,"deny_tile":list(forbidden)})
 here=pt
out={"schema":"FS_STYLE_FIRST_V231_2_HOUSE_REAL_VX_WALK_8DIR_AND_DENIALS",
 "origin":M["spawn"],"legal_house_stands":16,"house_denials":8,
 "sacred_and_well_regression":2,"routes":rows,
 "total_real_move_count":sum(len(x["moves"]) for x in rows),
 "blocked_tiles":len(B)}
(R/"input"/"V231_HOUSE_REAL_WALK_ROUTES.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print("V231_8D_PER_HOUSE_AND_REGRESSION_ROUTES_PASS",json.dumps({
 "stands":16,"denied":10,"steps":out["total_real_move_count"],
 "lengths":[[x["name"],len(x["moves"])] for x in rows]
},ensure_ascii=False),flush=True)
