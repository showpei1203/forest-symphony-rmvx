@echo off
setlocal
cd /d "%~dp0"
python run_t17a_lpc.py
if errorlevel 1 exit /b 2
python -c "import json;d=json.load(open('T17A_LPC_LAYER_ALIGNMENT.json',encoding='utf-8'));assert d['status']=='T17A_LPC_3_ACTION_4D_88FRAMES_PASS' and d['total_frames']==88;print('[PASS] T17A LPC 3 action 4 directions 88 frames')"
if errorlevel 1 exit /b 3
exit /b 0
