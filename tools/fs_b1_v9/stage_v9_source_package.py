# -*- coding: utf-8 -*-
"""Stage self-contained private visual prototype and fail-closed art-source verifier."""
from pathlib import Path
import shutil
R=Path(__file__).resolve().parent
S=R.parent/"FS_B1_BRIDGE_DUAL_LEVEL_V8_20261024"
F=R/"fixture"
assert not F.exists()
(F/"source/clean").mkdir(parents=True)
(F/"build").mkdir()
for p in (S/"source/clean").glob("*.png"):shutil.copyfile(p,F/"source/clean"/p.name)
for n in ["Ground","Master"]:
 shutil.copyfile(S/"build"/("FS_ELF_RICH_"+n+".png"),F/"build"/("FS_ELF_RICH_"+n+".png"))
shutil.copyfile(S/"scene_manifest.json",F/"scene_manifest.json")
sfile=R/"generate_sacred_tree_v9.py"
s=sfile.read_text(encoding="utf8")
needle='V8=R.parent/"FS_B1_BRIDGE_DUAL_LEVEL_V8_20261024"'
assert needle in s
s=s.replace(needle,'V8=R/"fixture"')
sfile.write_text(s,encoding="utf8")
cmd='''@echo off
setlocal
cd /d "%~dp0"
where python >nul 2>nul
if errorlevel 1 exit /b 3
python -c "from PIL import Image"
if errorlevel 1 exit /b 4
python generate_sacred_tree_v9.py > BUILD_V9.log 2>&1
if errorlevel 1 (type BUILD_V9.log & exit /b 5)
python validate_v9.py > VERIFY_V9.log 2>&1
if errorlevel 1 (type VERIFY_V9.log & exit /b 6)
echo [PASS] V9 source tree and V8 comparison art preview
echo [PENDING] V9 cannot be used as native VX release or formal artistic seal
exit /b 0
'''
(R/"RUN_V9_ART_SOURCE_TEST.cmd").write_bytes(cmd.replace("\r\n","\n").replace("\n","\r\n").encode("ascii"))
readme='''# FS B1｜V9 神聖樹獨立 Source-First 美術候選
2026-10-24。最新可玩的私人場景仍是 V8 dual-level bridge/river VX 技術候選。
V9僅提供精靈村神聖樹新素材、樹幹/樹冠獨立層、Scene Manifest fragment，以及對照圖。

操作：安裝Python3 + Pillow；雙擊 RUN_V9_ART_SOURCE_TEST.cmd 會重建原圖/預覽、驗證來源 SHA、分層與抗位移負測，將結果保留 LOG/JSON。
output/V8_V9_SACRED_TREE_SIDE_BY_SIDE.png 看前後；output/sacred_trunk_v9.png、output/sacred_canopy_v9.png、output/sacred_tree_v9.png 是真實分離可編輯層。

這不是完整遊戲V9。未寫回V8 source/Game.exe；collision, treehouse Level1, river bridge Level2的交互仍未重跑；禁止標Human Visual Gate F PASS。
原始 canopy 使用現有 B1 broadleaf_oak來源，其第三方權利尚未核准，PRIVATE TEST ONLY，禁止公開GitHub/商用發布。
'''
(R/"README_繁體中文.md").write_text(readme,encoding="utf8")
print("V9_STANDALONE_SOURCE_STAGED",len(list((F/"source/clean").glob("*.png"))),flush=True)
