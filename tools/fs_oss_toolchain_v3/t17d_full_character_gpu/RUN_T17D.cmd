@echo off
setlocal
cd /d "%~dp0"
python run_all_t17d.py
if errorlevel 1 (
 echo [FAIL] T17D1+D2 incremental. Inspect T17D_INCREMENTAL_REGRESSION.json
 exit /b 2
)
echo [PASS] T17D1+D2 source composition + real Godot GPU 24frame
exit /b 0
