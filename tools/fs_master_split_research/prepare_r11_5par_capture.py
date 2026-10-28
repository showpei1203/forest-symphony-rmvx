from pathlib import Path
R=Path(__file__).resolve().parent
s=(R/"capture_r11_ground3_native.py").read_text(encoding="utf8")
assert 'W=R/"R11_GROUND3_40x29_NATIVE"/"FULL505"' in s
s=s.replace('W=R/"R11_GROUND3_40x29_NATIVE"/"FULL505"','W=R/"R11_GROUND3_5OBJECT_NATIVE"/"FULL505"')
s=s.replace('D=R/"R11_GROUND3_40x29_NATIVE"/"NATIVE"','D=R/"R11_GROUND3_5OBJECT_NATIVE"/"NATIVE"')
s=s.replace('FS_R11_GROUND3_40x29','FS_R11_GROUND3_PAR5')
s=s.replace('R11_MAP003_LARGE_NATIVE_PASS','R11_GROUND3_PAR5_NATIVE_PASS')
s=s.replace('R11_MAP003_LARGE_NATIVE_HOLD','R11_GROUND3_PAR5_NATIVE_HOLD')
s=s.replace('"real_ground3_1280x928_used":True,','"real_ground3_1280x928_used":True,"candidate_source_aligned_PAR_5_objects":True,')
(R/"capture_r11_ground3_5par.py").write_text(s,encoding="utf8")
print("R11_5PAR_CAPTURE_READY",flush=True)