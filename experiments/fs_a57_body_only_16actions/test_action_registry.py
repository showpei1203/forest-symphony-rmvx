#!/usr/bin/env python3
"""A57 pure catalog guards. Historical art statuses are never auto-promoted."""
import json
import sys
from pathlib import Path

doc=json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert doc["schema"]=="FS_A57_BODY_ONLY_16_ACTIONS_V1"
rows=doc["items"]
assert len(rows)==16
assert [x["row"] for x in rows]==list(range(1,17))
ids=[x["id"] for x in rows]
assert len(set(ids))==16
assert all(x["equipment_art"]=="EXTERNAL_RUNTIME_ONLY" for x in rows)
assert all(x["body_pose"]=="NO_WEAPON_SHIELD_FX_BAKED" for x in rows)
lookup={x["id"]:x for x in rows}
assert lookup["moving_to_close_attack"]["play_order"]==[0,1,0,2]
assert lookup["waiting"]["play_order"]==[0,1,2,1]
assert lookup["waiting"]["source"]=="A63_W3B"
assert lookup["nothing"]["mode"]=="EMPTY" and not lookup["nothing"]["play_order"]
assert lookup["close_ranged_attack"]["play_order"]==list(range(12))
assert lookup["close_ranged_attack"]["contact"]["frame"]==7
assert abs(lookup["close_ranged_attack"]["contact"]["second"]-0.63)<1e-7
assert lookup["close_ranged_attack"]["status"]=="TECHNICAL_ART_HOLD"
assert lookup["dodging"]["status"]=="REJECTED_NEEDS_NEW_POSE"
assert lookup["moving_to_close_attack"]["status"]=="HISTORICAL_USER_PASS"
assert all(x["status"]!="FORMAL_USER_ART_PASS" for x in rows if x["id"]!="moving_to_close_attack")
print("A57_CATALOG_16_ACTION_CONTRACT_PASS")
