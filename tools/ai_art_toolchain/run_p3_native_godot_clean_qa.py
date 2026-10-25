from pathlib import Path
import subprocess,json,hashlib
from PIL import Image
import numpy as np
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
P=R/"outputs/P3_R3_G2_NATIVE_GODOT_XML_PLAYER_20261026"
G=Path(r"E:\GameAssetToolLab_20261023\FS_MapDepthPar_20261024\godot_depth_probe\Godot_v4.7.2-stable_win64.exe")
res=subprocess.run([str(G),"--path",str(P),"--rendering-driver","opengl3","--scene","res://player.tscn"],cwd=str(P),capture_output=True,text=True,errors="replace",timeout=55)
raw=res.stdout+"\nSTDERR\n"+res.stderr
log=R/"reports/P3_G2_NATIVE_GODOT_XML_ENGINE_REPAIRED.log"
log.write_text(raw,encoding="utf-8")
checks={
"engine_no_errors":"ERROR:" not in raw and "SCRIPT ERROR" not in raw,
"xml_structure":"P3_NATIVE_GODOT_XML_STRUCTURE_PASS" in raw,
"gpu_native":"P3_NATIVE_GODOT_XML_GPU_PASS" in raw,
"gpu_screenshots":all((P/f"GODOT_XML_RENDER_FRAME_{i}.png").is_file() for i in range(3))}
if checks["gpu_screenshots"]:
 a=[np.asarray(Image.open(P/f"GODOT_XML_RENDER_FRAME_{i}.png").convert("RGBA")) for i in range(3)]
 checks["gpu_frame_differences"]=all(np.any(a[0]!=v) for v in a[1:])
 print("PIXELS",{str(i):int(np.count_nonzero(np.any(a[0]!=v,axis=2))) for i,v in enumerate(a[1:],1)},flush=True)
summary={"status":"PASS" if all(checks.values()) else "FAIL","exit":res.returncode,
 "checks":checks,"log_tail":raw[-1200:]}
(R/"reports/P3_G2_NATIVE_GODOT_XML_RESULT.json").write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding="utf-8")
print("RESULT",json.dumps({k:v for k,v in summary.items() if k!="log_tail"}),flush=True)
print("TAIL",raw[-1000:].encode("ascii","backslashreplace").decode("ascii"),flush=True)
if not all(checks.values()):raise SystemExit(1)
