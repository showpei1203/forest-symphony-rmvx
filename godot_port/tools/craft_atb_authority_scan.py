"""Audit indexed original source and current candidate call sites, not runtime aliases."""
import hashlib
import json
import pathlib
import re
import subprocess

root=pathlib.Path.cwd()
index=json.loads((root/"authority/SCRIPT_INDEX.json").read_text(encoding="utf-8"))
rows=index["scripts"]
assert len(rows)==index["scripts_count"]==505
assert len({row["order"] for row in rows})==505
pattern=re.compile(r"\batb_minus_damage\b|\batb_damage\b|\balbert_combo_apply_atb_delta\b|\bfs_drain_force_action_queue\b|\bfs_force_action_queue\b|\bprepare_forcing_atb\b")
defs=[]
matches=[]
for row in rows:
    data=subprocess.check_output(["git","cat-file","blob","HEAD:"+row["file"]],timeout=5)
    assert len(data)==row["source_bytes"],row["order"]
    assert hashlib.sha256(data).hexdigest()==row["source_sha256"],row["order"]
    for num,line in enumerate(data.decode("utf-8",errors="replace").splitlines(),1):
        if not pattern.search(line):
            continue
        code=line.strip()
        record={"order":row["order"],"line":num,"text":code[:350]}
        matches.append(record)
        if re.match(r"def\s+(?:self\.)?(atb_minus_damage|atb_damage)\b",code):
            defs.append(record)
for record in defs:
    print("CRAFT_AUTHORITY_DEF; "+json.dumps(record,ensure_ascii=True))
for record in matches:
    if not record["text"].startswith("#"):
        print("CRAFT_AUTHORITY_REF; "+json.dumps(record,ensure_ascii=True))
for path in sorted((root/"godot_port/scripts").rglob("*.gd")):
    for num,line in enumerate(path.read_text(encoding="utf-8").splitlines(),1):
        if re.search(r"\batb_minus_damage\b|\batb_damage\b|\bapply_combo_atb_shift(?:_to_actor)?\s*\(|\bapply_direct_shift\s*\(",line):
            print("CRAFT_GODOT_CALLSITE; "+json.dumps({"path":str(path.relative_to(root)),"line":num,"text":line.strip()[:250]},ensure_ascii=True))
print("CRAFT_AUTHORITY_SCAN_PASS; Indexed=505; VerifiedHashes=505; Definitions="+str(len(defs))+"; LexicalReferences="+str(len(matches))+"; RuntimeAliasWitness=False")
