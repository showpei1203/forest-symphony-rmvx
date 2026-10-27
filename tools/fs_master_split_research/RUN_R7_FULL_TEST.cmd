@echo off
setlocal
cd /d "%~dp0"
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r7_sam2_object_proposals.py
if errorlevel 1 exit /b 11
python r7_export_isolated_passability.py
if errorlevel 1 exit /b 12
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r7_occlusion_grid_gate.py
if errorlevel 1 exit /b 13
python build_r7_native_scene.py
if errorlevel 1 exit /b 14
python prepare_r7_capture_analyzer.py
if errorlevel 1 exit /b 15
python capture_r7_native_scene.py
if errorlevel 1 exit /b 16
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/analyze_r7_native_scene.py
if errorlevel 1 exit /b 17
robocopy R7_NATIVE_FULL_MASTER\NATIVE_ABA R7_NATIVE_FULL_MASTER\REPLAY1_NATIVE_ABA /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 18
python capture_r7_native_scene.py
if errorlevel 1 exit /b 19
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/analyze_r7_native_scene.py
if errorlevel 1 exit /b 20
python r7_final_gate.py
if errorlevel 1 exit /b 21
echo R7_ISOLATED_NATIVE_TECH_PASS_PAR_ART_HOLD_FORMAL505_BOOT_FAIL
endlocal