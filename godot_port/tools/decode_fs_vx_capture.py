#!/usr/bin/env python3
"""Decode completed isolated RGSS2 capture; never self-authorize a boot-final manifest."""
import argparse, hashlib, json, re
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from rvdata_to_json import RubyMarshal48, json_safe, DATA_NAMES

NAMES = DATA_NAMES + ("CommonEvents",)
LIMIT = 128*1024*1024
def sha(data):
    return hashlib.sha256(data).hexdigest()

def read_capture(folder, nonce, expected_autoset_version):
    folder = Path(folder)
    if not re.fullmatch(r"[0-9a-f]{32}",nonce):
        raise ValueError("bad nonce")
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", expected_autoset_version):
        raise ValueError("expected AutoSetup version must be source-pinned")
    expected = {"SCOPE.txt","COMPLETE.tsv"} | {n+".rvdata" for n in NAMES}
    if folder.is_symlink() or not folder.is_dir() or {p.name for p in folder.iterdir()} != expected:
        raise ValueError("capture incomplete or unexpected files")
    for p in folder.iterdir():
        if p.is_symlink() or not p.is_file() or p.stat().st_size > LIMIT:
            raise ValueError("invalid capture member")
    if sum(p.stat().st_size for p in folder.iterdir())>LIMIT:
        raise ValueError("capture total size")
    if (folder/"SCOPE.txt").read_bytes()!=("FS_VX_CAPTURE_V1\n"+nonce+"\n").encode():
        raise ValueError("scope mismatch")
    lines = (folder/"COMPLETE.tsv").read_text(encoding="ascii").splitlines()
    pairs = [line.split("\t") for line in lines]
    if any(len(p)!=2 for p in pairs) or len({p[0] for p in pairs})!=len(pairs):
        raise ValueError("bad completion marker")
    mark=dict(pairs)
    pins={"schema":"fs-vx-capture-v1","stage":"post_Scene_Title.load_database",
          "apply_completed":"1","authority_source":"FS_MASTER_SETUP","autoset_version":expected_autoset_version,"nonce":nonce}
    if any(mark.get(k)!=v for k,v in pins.items()):
        raise ValueError("completion marker mismatch")
    if set(mark)!=set(pins)|{"ruby_version","party"}|{"count_"+n for n in NAMES}:
        raise ValueError("marker fields mismatch")
    tables,raw_hashes,counts={},{},{}
    for name in NAMES:
        raw=(folder/(name+".rvdata")).read_bytes()
        raw_hashes[name]=sha(raw)
        value=json_safe(RubyMarshal48(raw).parse())
        if name=="System":
            if not isinstance(value,dict) or not isinstance(value.get("party_members"),list):
                raise ValueError("invalid system")
            count=1
        else:
            if not isinstance(value,list) or len(value)<2 or value[0] is not None:
                raise ValueError("invalid array "+name)
            if any(row is not None and (not isinstance(row,dict) or type(row.get("id")) is not int or row["id"]!=i) for i,row in enumerate(value)):
                raise ValueError("row index mismatch "+name)
            count=sum(row is not None for row in value)
        if mark["count_"+name]!=str(count):
            raise ValueError("count mismatch "+name)
        counts[name.lower()]=count
        tables[name.lower()]=value
    party=tables["system"]["party_members"]
    if not party or len(set(party))!=len(party) or any(type(i) is not int or i<1 or i>=len(tables["actors"]) or tables["actors"][i] is None for i in party):
        raise ValueError("bad party references")
    if ",".join(map(str,party))!=mark["party"]:
        raise ValueError("party mismatch")
    return tables,{"schema":"fs-vx-capture-structural-receipt-v1",
       "reported_stage":mark["stage"],"reported_ruby_version":mark["ruby_version"],
       "reported_autoset_version":mark["autoset_version"],
       "reported_apply_count":1,"table_counts":counts,"party_actor_ids":party,
       "raw_capture_sha256":raw_hashes,"completion_sha256":sha((folder/"COMPLETE.tsv").read_bytes()),
       "actual_original_vx_authenticated":False,"vx_runtime_trace_verified":False,
       "production_approval":False}

def convert(folder,nonce,output,expected_autoset_version):
    tables,receipt=read_capture(folder,nonce,expected_autoset_version)
    out=Path(output)
    out.mkdir(exist_ok=False)
    digests={}
    for name,value in tables.items():
        raw=(json.dumps(value,ensure_ascii=False,separators=(",",":"))+"\n").encode()
        with (out/(name+".json")).open("xb") as f: f.write(raw)
        digests[name]=sha(raw)
    receipt["database_sha256"]=digests
    with (out/"fs_capture_candidate_receipt.json").open("x",encoding="utf-8") as f:
        json.dump(receipt,f,ensure_ascii=False,indent=2)
    # Deliberately no fs_boot_final_authority.json or runtime witness.
    return receipt

if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("capture");p.add_argument("--nonce",required=True);p.add_argument("--output",required=True)
    p.add_argument("--expected-autoset-version",required=True,help="Exact version verified against original source; never infer from capture alone")
    a=p.parse_args()
    r=convert(a.capture,a.nonce,a.output,a.expected_autoset_version)
    print("FS_VX_CAPTURE_STRUCTURE_PASS; Tables=%d; OriginalVXAuthenticated=False; ProductionApproval=False"%len(r["table_counts"]))
