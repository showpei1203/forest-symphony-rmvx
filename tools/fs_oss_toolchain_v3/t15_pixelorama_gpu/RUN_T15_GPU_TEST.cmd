@echo off
setlocal
cd /d "%~dp0"
echo [T15] GPU visual Pixelorama export requires an active Windows desktop session.
python run_t15_pixelorama_gpu.py
if errorlevel 1 exit /b 1
python run_t15b_b0_shader.py
if errorlevel 1 exit /b 1
python -c "import json,pathlib,sys; p=pathlib.Path('.'); a=json.loads((p/'T15_PIXELORAMA_GPU_DIAGNOSTIC.json').read_text(encoding='utf-8')); b=json.loads((p/'T15B_PIXELORAMA_B0_SHADER.json').read_text(encoding='utf-8')); print('T15:',a['status'],'T15B:',b['status']);sys.exit(0 if a['status']=='T15_EFFECTS_RENDER_EXPORT_PASS' and b['status']=='T15B_B0_SIX_UNIQUE_FRAMES_EFFECT_GPU_PASS' else 2)"
if errorlevel 1 exit /b 2
echo [PASS] T15 + T15B complete
exit /b 0
