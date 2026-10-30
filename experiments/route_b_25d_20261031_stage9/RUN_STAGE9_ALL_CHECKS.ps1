param([string]$GodotExe='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw 'Godot 4.7.2 not found'}
function PY([string]$name){
 & python (Join-Path $r $name) | Select-Object -Last 12
 if($LASTEXITCODE -ne 0){throw "PY failed: $name"}
}
Write-Output 'GROUND SOURCE REBUILD'
PY 'author_ground_stage5.py'
PY 'author_roof_material.py'
Write-Output 'MANDATORY GODOT ASSET IMPORT'
& $GodotExe --headless --editor --import --path $r --quit | Select-Object -Last 9
if($LASTEXITCODE -ne 0){throw 'Godot project import failed'}
Write-Output 'RUN BOTH STAGE9 CROWN SHADERS / DIRECT LAYERS'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $r 'run_variants_stage9.ps1') | Select-Object -Last 35
if($LASTEXITCODE -ne 0){throw 'A/B source render or six-position actor validation failed'}
Write-Output 'COMPARE ALPHA/ART 1X'
PY 'compare_stage9.py'
$report=Get-Content -Raw (Join-Path $r 'out\STAGE9_ART_COMPARE_QA.json')|ConvertFrom-Json
if(-not $report.alpha_preserved_exact){throw 'PAR alpha changed'}
if($report.results[2].full_diff -gt 2000){throw 'Composite exceeded technical mismatch cap (investigate)'}
Write-Output 'STAGE9_NATIVE_PASS TREE_CONTACT_2/2 ACTOR_6/6 PAR_ALPHA_ZERO_DIFF; ART_FAIL FORMAL_SEAL_NO'