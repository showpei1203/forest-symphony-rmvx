from pathlib import Path
R=Path(__file__).resolve().parent
s=(R/"capture_r10_actual_map050.py").read_text(encoding="utf8")
s=s.replace('W=R/"R10_ORIGINAL_MAP050_NATIVE"/"FULL505"','W=R/"R10_COLLISION_NATIVE_CANDIDATE"/"FULL505"')
s=s.replace('D=R/"R10_ORIGINAL_MAP050_NATIVE"/"NATIVE_MAP050"','D=R/"R10_COLLISION_NATIVE_CANDIDATE"/"NATIVE_CANDIDATE"')
s=s.replace('log=W/"R10_FORMAL_MAP050_NATIVE.log"','log=W/"R10_COMPILED_MAP050_NATIVE.log"')
s=s.replace('"FS_R10_FORMAL_MAP050"','"FS_R10_COLLISION_CANDIDATE"')
s=s.replace('ids=["F01_', 'ids=["F01_')
line=s.index('\nlog=W/')
s=s[:line].replace('"F10_MAP050_NPC_MOVE"]','"F10_MAP050_NPC_MOVE","F11_MAP050_NPC_FREE"]')+s[line:]
s=s.replace('R10_MAP050_ORIGINAL_LAYER_NATIVE_PASS','R10_COLLISION_CANDIDATE_NATIVE_PASS')
s=s.replace('R10_MAP050_NATIVE_FAIL','R10_COLLISION_CANDIDATE_NATIVE_FAIL')
s=s.replace('"formal_map050_binary_source_identical":True','"formal_map050_source_unmodified_and_compiled_candidate_only":True')
s=s.replace('"map050_events_not_native_preserved":True','"map050_events_not_native_preserved":True')
s=s.replace('R10_MAP050_NATIVE_GATE.json','R10_COLLISION_NATIVE_GATE.json')
(R/"capture_r10_collision_candidate.py").write_text(s,encoding="utf8")
print("R10_COLLISION_CAPTURE_SCRIPTS_PREPARED",len(s),flush=True)