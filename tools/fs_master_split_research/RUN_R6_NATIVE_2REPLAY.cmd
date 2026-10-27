@echo off
setlocal
cd /d "%~dp0"
python stage_full_fs505_r5.py
if errorlevel 1 exit /b 10
python build_full_fs505_overlay_r5.py DYNAMIC_ADAPTER
if errorlevel 1 exit /b 11
python r5_disable_regression_isolated.py
if errorlevel 1 exit /b 12
python build_r6_same_session_vx.py
if errorlevel 1 exit /b 13
python capture_r6_same_session_vx.py
if errorlevel 1 exit /b 14
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/analyze_r6_same_session.py
if errorlevel 1 exit /b 15
robocopy R6_SAME_SESSION_ISOLATED\NATIVE_ABA R6_SAME_SESSION_ISOLATED\R6_FROZEN_PASS_REPLAY_1 /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 16
python capture_r6_same_session_vx.py
if errorlevel 1 exit /b 17
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/analyze_r6_same_session.py
if errorlevel 1 exit /b 18
python r6_final_gate.py
if errorlevel 1 exit /b 19
echo R6_ISOLATED_NATIVE_TECH_PASS_ART_HOLD_FORMAL505_BOOT_FAIL
endlocal