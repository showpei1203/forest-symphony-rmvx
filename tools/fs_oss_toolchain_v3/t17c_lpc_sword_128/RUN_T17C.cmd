@echo off
setlocal
cd /d "%~dp0"
echo [T17C] 128cell Arming Sword LPC deterministic sprite test
python run_t17c.py > T17C_RUN.log 2>&1
if errorlevel 1 (
  type T17C_RUN.log
  echo [FAIL] T17C
  exit /b 2
)
type T17C_RUN.log
python -c "import json;d=json.load(open('T17C_128_ARMING_WEAPON_VALIDATION.json',encoding='utf-8'));assert d['status']=='T17C_128_CELL_WEAPON_24_FRAME_STRUCTURAL_PASS_HUMAN_PENDING' and d['total_frames']==24 and d['cell_vs_sheet_rgba_identical'] and d['body_extract_rgba_identical'] and d['weapon_edge_alpha_pixels_total']==0 and min(d['negative_tests'].values())>0;print('[PASS] T17C all pixel gates')"
if errorlevel 1 exit /b 3
exit /b 0
