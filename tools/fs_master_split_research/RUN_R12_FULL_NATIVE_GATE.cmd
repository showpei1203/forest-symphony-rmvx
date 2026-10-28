@echo off
setlocal
cd /d "%~dp0"
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r12_new_village_sam2_source_par.py
if errorlevel 1 exit /b 11
wsl.exe --cd /home/user/sam2 /home/user/sam2/.venv/bin/python /mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/r12_filter_source_par_and_collision.py
if errorlevel 1 exit /b 12
python build_r12_native_village.py
if errorlevel 1 exit /b 13
python capture_r12_native_village.py
if errorlevel 1 exit /b 14
robocopy R12_NEW_ELF_VILLAGE_NATIVE\NATIVE R12_NEW_ELF_VILLAGE_NATIVE\NATIVE_REPLAY1 /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 15
python capture_r12_native_village.py
if errorlevel 1 exit /b 16
python r12_final_gate.py
if errorlevel 1 exit /b 17
python r12_make_visual_review.py
if errorlevel 1 exit /b 18
echo R12_NEW_VILLAGE_NATIVE_TECH_PASS_USER_ART_PENDING
endlocal