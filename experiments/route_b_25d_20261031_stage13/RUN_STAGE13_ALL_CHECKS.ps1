param([string]$GodotExe='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw 'Missing Godot'}
function Py([string]$name){& python (Join-Path $r $name);if($LASTEXITCODE -ne 0){throw ('Python failed: '+$name)}}
Py 'author_stage13_ground.py'
Py 'compile_stage12_source.py'
$proc=Start-Process -FilePath $GodotExe -ArgumentList @('--headless','--editor','--import','--path',('"' + $r + '"'),'--quit') -Wait -NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $r 'evidence/IMPORT_OUT.txt') -RedirectStandardError (Join-Path $r 'evidence/IMPORT_ERR.txt')
if($proc.ExitCode -ne 0){throw 'Godot import failed'}
foreach($sid in @('A_BLUE_COTTAGE','B_OCHRE_GROVE')){
 $env:FS_STAGE12_SCENE=$sid
 $log=Join-Path $r ('evidence/GODOT_'+$sid+'.txt')
 & $GodotExe --path $r --rendering-method gl_compatibility --script res://render_2d_stage12.gd *> $log
 if($LASTEXITCODE -ne 0){throw ('Render failed: '+$sid)}
 if(-not (Get-Content $log -Raw).Contains('STAGE12_GPU_RENDERED '+$sid)){throw 'Missing actual render proof'}
}
Py 'audit_stage12.py'
Copy-Item -Force (Join-Path $r 'evidence/STAGE12_GPU_PIXEL_QA.json') (Join-Path $r 'evidence/STAGE13_GPU_PIXEL_QA.json')
Py 'actor_sweep_stage12.py'
Py 'compare_stage13.py'
$q=Get-Content -Raw (Join-Path $r 'evidence/STAGE13_GPU_PIXEL_QA.json') | ConvertFrom-Json
$a=Get-Content -Raw (Join-Path $r 'evidence/STAGE12_ACTOR_SWEEP.json') | ConvertFrom-Json
foreach($sid in @('A_BLUE_COTTAGE','B_OCHRE_GROVE')){
 $it=$q.$sid
 if($it.ground.different_pixels -ne 0 -or $it.par.different_pixels -ne 0 -or $it.full.different_pixels -ne 0){throw 'Source vs Godot pixel mismatch'}
 if($it.gpu_par_border_nonzero -ne 0 -or -not $it.par_alpha_exact -or -not $it.trees[0].base_32tile_pass){throw 'Source mask failed'}
 if($a.$sid.sample_count -ne 35 -or $a.$sid.front_nonzero -ne 0){throw 'Actor overlap regression'}
}
Write-Output 'STAGE13_NEW_PROCEDURAL_GROUND_WITH_LEGACY_PARS_GPU_PIXEL_EXACT_PASS_2_SCENES; ART_FAIL; FORMAL_SEAL_NO'