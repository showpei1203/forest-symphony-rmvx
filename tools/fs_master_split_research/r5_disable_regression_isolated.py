#!/usr/bin/env python3
"""TEST-ONLY DISABLE 1 FS_BattleRegression_AIEdgeI page on isolated clone ONLY.
Can isolate other 504 original code pages (Overlay145 + ParaPassa342 remain byte-identical).
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import hashlib,json,zlib
ROOT=Path(__file__).resolve().parent
ORIG=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
DST=ROOT/"R5_FORMAL_ADAPTER_ISOLATED"/"FULL505"/"Data"/"Scripts.rvdata"
base=load(ORIG.open("rb"));a=load(DST.open("rb"))
assert len(base)==505 and len(a)==506
assert a[480]==base[480] and "FS_BattleRegression_AIEdgeI" in str(a[480][1])
disabled=b"# R5 isolation only: FS_BattleRegression_AIEdgeI has invalid pre-Main alias state.\n"
a[480][2]=zlib.compress(disabled)
assert a[145]==base[145] and a[146]==base[146] and a[342]==base[342]
assert all(a[i if i<482 else i+1]==base[i] for i in range(505) if i!=480)
with DST.open("wb") as f:write(f,a)
report={"status":"R5_ISOLATED_REGRESSION_ONE_PAGE_DISABLED",
"original_pages":505,"modified_original_page_index":480,
"unchanged_source_pages":504,"HK_UOM_145_byte_identical":True,
"MAAP_146_byte_identical":True,"ISS_ParaPassa_342_byte_identical":True,
"test_adapter_page_index":482,"formal_source_sha256":hashlib.sha256(ORIG.read_bytes()).hexdigest(),
"original_source_never_changed":True,
"diagnostic_bridge":False,
"warning":"Any runtime test is NOT an unmodified 505-script pass."}
(ROOT/"R5_FORMAL_ADAPTER_ISOLATED"/"R5_REGRESSION_DISABLED_AUDIT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R5_REGRESSION_ONLY_ISOLATED_DISABLED",flush=True)