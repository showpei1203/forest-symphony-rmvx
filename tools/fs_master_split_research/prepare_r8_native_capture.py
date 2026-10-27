from pathlib import Path
R=Path(__file__).resolve().parent
names=["RED_HOUSE_CONIFER","RED_FAR_RIGHT_CONIFER","RED_LEFT_INNER_MICRO","RED_BOTTOM_MICRO","BLUE_STEPS","CLEAR"]
cases=[("RED_HOUSE_CONIFER",(13,5),(13,3)),("RED_FAR_RIGHT_CONIFER",(15,7),(15,4)),
 ("RED_LEFT_INNER_MICRO",(3,8),(3,6)),("RED_BOTTOM_MICRO",(12,10),(12,8)),
 ("BLUE_STEPS",(9,6),(9,4)),("CLEAR",(8,9),(9,9))]
src=(R/"capture_r7_native_scene.py").read_text(encoding="utf8")
assert 'W=ROOT/"R7_NATIVE_FULL_MASTER"/"FULL505"' in src
src=src.replace('W=ROOT/"R7_NATIVE_FULL_MASTER"/"FULL505"', 'W=ROOT/"R8_NATIVE_FULL_MASTER"/"FULL505"')
src=src.replace('OUT=ROOT/"R7_NATIVE_FULL_MASTER"/"NATIVE_ABA"', 'OUT=ROOT/"R8_NATIVE_FULL_MASTER"/"NATIVE_ABA"')
src=src.replace('"FS_R7_PAR_SAME_SESSION"','"FS_R8_PAR_RED_BLUE_VX"')
start=src.index("cases=[");end=src.index("\nmarks=",start)
src=src[:start]+"cases="+repr(names)+src[end:]
(R/"capture_r8_native_scene.py").write_text(src,encoding="utf8")
an=(R/"analyze_r7_native_scene.py").read_text(encoding="utf8")
assert 'OUT=R/"R7_NATIVE_FULL_MASTER"/"NATIVE_ABA"' in an
an=an.replace('OUT=R/"R7_NATIVE_FULL_MASTER"/"NATIVE_ABA"','OUT=R/"R8_NATIVE_FULL_MASTER"/"NATIVE_ABA"')
start=an.index('cases=[(');end=an.index('\nstats=[]',start)
an=an[:start]+"cases="+repr(cases)+an[end:]
(R/"analyze_r8_native_scene.py").write_text(an,encoding="utf8")
print("R8_NATIVE_CAPTURE_ANALYZER_READY",names,flush=True)