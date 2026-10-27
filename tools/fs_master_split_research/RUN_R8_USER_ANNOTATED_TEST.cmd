@echo off
setlocal
cd /d "%~dp0"
python r8_red_blue_baseline_audit.py
if errorlevel 1 exit /b 10
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r8_sam2_user_red_blue.py
if errorlevel 1 exit /b 11
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r8_four_direction_real_footprint_scan.py
if errorlevel 1 exit /b 12
python build_r8_native_user_override.py
if errorlevel 1 exit /b 13
python prepare_r8_native_capture.py
if errorlevel 1 exit /b 14
python capture_r8_native_scene.py
if errorlevel 1 exit /b 15
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/analyze_r8_native_scene.py
if errorlevel 1 exit /b 16
robocopy R8_NATIVE_FULL_MASTER\NATIVE_ABA R8_NATIVE_FULL_MASTER\REPLAY1_NATIVE_ABA /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 17
python capture_r8_native_scene.py
if errorlevel 1 exit /b 18
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/analyze_r8_native_scene.py
if errorlevel 1 exit /b 19
python r8_final_gate.py
if errorlevel 1 exit /b 20
echo R8_SOURCE_SAME_PIXEL_NATIVE_TECH_PASS_ART_HOLD
endlocal