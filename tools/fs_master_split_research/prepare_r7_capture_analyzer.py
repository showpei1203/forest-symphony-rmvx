#!/usr/bin/env python3
from pathlib import Path
R=Path(__file__).resolve().parent
cases=[("LEFT_CONIFER_FRONT",(3,6),(4,3)),
       ("HOUSE_FRONT_X8",(8,6),(10,4)),
       ("HOUSE_FRONT_X9",(9,6),(10,4)),
       ("RIGHT_MARKER_FRONT",(12,7),(12,5)),
       ("CLEAR",(8,9),(9,9))]
names=[x[0] for x in cases]
src=(R/"capture_r6_same_session_vx.py").read_text()
assert 'W=ROOT/"R6_SAME_SESSION_ISOLATED"/"FULL505"' in src
src=src.replace('W=ROOT/"R6_SAME_SESSION_ISOLATED"/"FULL505"', 'W=ROOT/"R7_NATIVE_FULL_MASTER"/"FULL505"')
src=src.replace('OUT=ROOT/"R6_SAME_SESSION_ISOLATED"/"NATIVE_ABA"', 'OUT=ROOT/"R7_NATIVE_FULL_MASTER"/"NATIVE_ABA"')
src=src.replace('"FS_R6_VX_SAME_SESSION"','"FS_R7_PAR_SAME_SESSION"')
start=src.index('cases=[')
end=src.index('\nmarks=',start)
src=src[:start]+'cases='+repr(names)+src[end:]
(R/"capture_r7_native_scene.py").write_text(src)
an=(R/"analyze_r6_same_session.py").read_text()
assert 'OUT=R/"R6_SAME_SESSION_ISOLATED"/"NATIVE_ABA"' in an
an=an.replace('OUT=R/"R6_SAME_SESSION_ISOLATED"/"NATIVE_ABA"', 'OUT=R/"R7_NATIVE_FULL_MASTER"/"NATIVE_ABA"')
start=an.index('cases=[(')
end=an.index('\nstats=[]',start)
an=an[:start]+"cases="+repr(cases)+an[end:]
(R/"analyze_r7_native_scene.py").write_text(an)
print("R7_CAPTURE_ANALYZER_SCRIPTS_READY",names,flush=True)