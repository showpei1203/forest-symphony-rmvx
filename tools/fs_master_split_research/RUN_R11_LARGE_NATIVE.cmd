@echo off
setlocal
cd /d "%~dp0"
python r11_ground3_authority_audit.py
if errorlevel 1 exit /b 10
python build_r11_ground3_native.py
if errorlevel 1 exit /b 11
python capture_r11_ground3_native.py
if errorlevel 1 exit /b 12
robocopy R11_GROUND3_40x29_NATIVE\NATIVE R11_GROUND3_40x29_NATIVE\NATIVE_REPLAY1 /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 13
python capture_r11_ground3_native.py
if errorlevel 1 exit /b 14
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r11_ground3_large_source_par_experiment.py
if errorlevel 1 exit /b 15
python build_r11_ground3_5object_native.py
if errorlevel 1 exit /b 16
python prepare_r11_5par_capture.py
if errorlevel 1 exit /b 17
python capture_r11_ground3_5par.py
if errorlevel 1 exit /b 18
robocopy R11_GROUND3_5OBJECT_NATIVE\NATIVE R11_GROUND3_5OBJECT_NATIVE\NATIVE_REPLAY1 /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 19
python capture_r11_ground3_5par.py
if errorlevel 1 exit /b 20
python r11_final_gate.py
if errorlevel 1 exit /b 21
echo R11_LARGE_NATIVE_TECH_PASS_NEW_VILLAGE_ART_GATE_HOLD
endlocal