@echo off
setlocal
cd /d "%~dp0"
echo [T17B] LPC 24-frame dagger weapon compositing (cached/pinned source)
python run_t17b.py > T17B_RUN.log 2>&1
if errorlevel 1 (
  type T17B_RUN.log
  echo [FAIL] T17B source or alignment Gate
  exit /b 2
)
type T17B_RUN.log
python -c "import json; d=json.load(open('T17B_LPC_WEAPON_LAYER_ALIGNMENT.json', encoding='utf-8')); assert d['status']=='T17B_LPC_DAGGER_TWO_DEPTH_24FRAME_STRUCTURAL_PASS' and d['perframe_vs_full_rgba_exact'] and d['frame_count']==24 and d['negative_1px_shift_diff_pixels']>0 and d['negative_swapped_left_down_diff_pixels']>0 and d['negative_reverse_layer_order_diff_pixels']>0;print('[PASS] T17B 24frame four directions + 3 negative tests')"
if errorlevel 1 exit /b 3
exit /b 0
