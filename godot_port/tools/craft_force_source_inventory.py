"""Read-only lexical inventory of public FS source. No Ruby execution or Troop data claims."""
import collections
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root=pathlib.Path.cwd()
idx=json.loads((root/"authority/SCRIPT_INDEX.json").read_text(encoding="utf-8"))
rows=idx["scripts"]
if len(rows)!=505 or len({x["order"] for x in rows})!=505:
    raise ValueError("script index count")
patterns={
    "force_api_call":re.compile(r"(?<![\w])force_action\s*\("),
    "force_native_command":re.compile(r"\bcommand_339\b|\bRPG::EventCommand\.new\s*\(\s*339\b"),
    "force_queue":re.compile(r"\bfs_force_action_queue\b|\bfs_drain_force_action_queue\b|\bprepare_forcing_atb\b|\bforcing_battler[s]?\b"),
    "troop_table":re.compile(r"\$data_troops\b|\bRPG::Troop\b|\bsetup_battle_event\b"),
    "target_selection":re.compile(r"\bdecide_(?:random|last)_target\b"),
}
findings=[]
counts=collections.Counter()
for row in rows:
    raw=subprocess.check_output(["git","cat-file","blob","HEAD:"+row["file"]],timeout=5)
    if hashlib.sha256(raw).hexdigest()!=row["source_sha256"] or len(raw)!=row["source_bytes"]:
        raise ValueError("source hash mismatch "+str(row["order"]))
    for n,line in enumerate(raw.decode("utf-8",errors="replace").splitlines(),1):
        line=line.strip()
        for key,pattern in patterns.items():
            if not pattern.search(line):
                continue
            # Keep comments/definitions distinguishable, and test scripts separate.
            role="comment" if line.startswith("#") else ("definition" if re.match(r"def\s+",line) else "reference")
            # Numbered authority scanner retains the exact source location. This
            # is lexical only: strings, aliases, dead branches may match too.
            findings.append({"script":row["order"],"line":n,"name":row["script_name"],
                "category":key,"role":role,"text":line[:240]})
            counts[key]+=1
if len(findings)>4000:
    raise ValueError("inventory too large")
report={"schema":1,"scope":"public indexed Ruby text, not raw/post-Apply Troop data",
    "source_sha256_verified":505,"counts":dict(sorted(counts.items())),
    "records":findings,"original_runtime_executed":False,"actual_troop_pages_verified":False}
path=pathlib.Path(sys.argv[1])
path.write_text(json.dumps(report,ensure_ascii=True,sort_keys=True,indent=2)+"\n",encoding="utf-8")
for key in ["force_api_call","force_native_command","troop_table"]:
    for row in findings:
        if row["category"]==key and row["role"]!="comment":
            print("CRAFT_FORCE_INVENTORY; "+json.dumps(row,ensure_ascii=True,sort_keys=True))
print("CRAFT_FORCE_INVENTORY_PASS; VerifiedHashes=505; Records="+str(len(findings))+
      "; Counts="+json.dumps(dict(sorted(counts.items())),separators=(",",":"))+
      "; ActualTroopPagesVerified=False")
