@echo off
setlocal
cd /d "%~dp0"
python r10_formal_map_match_audit.py
if errorlevel 1 exit /b 10
python r10_formal_map050_tile_audit.py
if errorlevel 1 exit /b 11
python build_r10_actual_formal_map050.py
if errorlevel 1 exit /b 12
python capture_r10_actual_map050.py
if errorlevel 1 exit /b 13
python r10_compile_scene21_collision_candidate.py
if errorlevel 1 exit /b 14
python build_r10_collision_candidate_native.py
if errorlevel 1 exit /b 15
python prepare_r10_candidate_capture.py
if errorlevel 1 exit /b 16
python capture_r10_collision_candidate.py
if errorlevel 1 exit /b 17
robocopy R10_COLLISION_NATIVE_CANDIDATE\NATIVE_CANDIDATE R10_COLLISION_NATIVE_CANDIDATE\NATIVE_REPLAY1 /E /R:0 /W:0 >nul
if errorlevel 8 exit /b 18
python capture_r10_collision_candidate.py
if errorlevel 1 exit /b 19
python r10_final_gate.py
if errorlevel 1 exit /b 20
python r10_make_native_comparison.py
if errorlevel 1 exit /b 21
echo R10_ISOLATED_NATIVE_COLLISION_TECH_PASS_ART_HOLD
endlocal