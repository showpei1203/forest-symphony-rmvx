@echo off
setlocal
cd /d "%~dp0"
python build_r9_native_walking.py
if errorlevel 1 exit /b 10
python capture_r9_native_walk.py
if errorlevel 1 exit /b 11
robocopy R9_NATIVE_WALKING_ISOLATED\NATIVE_WALK R9_NATIVE_WALKING_ISOLATED\NATIVE_WALK_REPLAY1 /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 12
python capture_r9_native_walk.py
if errorlevel 1 exit /b 13
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r9_edge_semantic_risk_audit.py
if errorlevel 1 exit /b 14
python r9_final_gate.py
if errorlevel 1 exit /b 15
echo R9_NATIVE_ONE_STEP_WALK_TECH_PASS_ART_GATE_F_HOLD
endlocal