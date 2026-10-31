param([string]$GodotExe='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw 'Godot is missing'}
New-Item -ItemType Directory -Force (Join-Path $r 'evidence') | Out-Null
function PY([string]$n){
 & python (Join-Path $r $n) *> (Join-Path $r ('evidence\run_'+$n+'.txt'))
 if($LASTEXITCODE -ne 0){throw ('PY gate failure '+$n)}
 Write-Output ('PASS '+$n)
}
PY 'author_ground15.py'
PY 'compile_stage12_source.py'
$pr=Start-Process -FilePath $GodotExe -ArgumentList @('--headless','--editor','--import','--path',('"' + $r + '"'),'--quit') -Wait -NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $r 'evidence\import_out.txt') -RedirectStandardError (Join-Path $r 'evidence\import_err.txt')
if($pr.ExitCode -ne 0){throw 'Godot import failed'}
foreach($scene in @('A_BLUE_COTTAGE','B_OCHRE_GROVE')){
 $env:FS_STAGE12_SCENE=$scene
 $log=Join-Path $r ('evidence\GPU_'+$scene+'.txt')
 & $GodotExe --path $r --rendering-method gl_compatibility --script res://render_2d_stage12.gd *> $log
 if($LASTEXITCODE -ne 0 -or -not (Get-Content $log -Raw).Contains('STAGE12_GPU_RENDERED '+$scene)){throw ('Godot render missing '+$scene)}
 Write-Output ('REAL_GPU_PASS '+$scene)
}
PY 'audit_stage12.py'
PY 'actor_sweep_stage12.py'
PY 'compare_stage15.py'
Write-Output 'STAGE15_SEAM_QUILT_TECH_PASS; ART_FAIL; VX_NOT_RUN; FORMAL_SEAL_NO'