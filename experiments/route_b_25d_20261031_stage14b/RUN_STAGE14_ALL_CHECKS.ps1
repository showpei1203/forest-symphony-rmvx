param([string]$GodotExe='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw 'Godot binary missing'}
New-Item -ItemType Directory -Force (Join-Path $r 'evidence')|Out-Null
function PythonStep([string]$name){
 & python (Join-Path $r $name) *> (Join-Path $r ('evidence\run_'+$name+'.txt'))
 if($LASTEXITCODE -ne 0){throw ('Python failed '+$name)}
 Write-Output ('PASS '+$name)
}
PythonStep 'author_ground14.py'
PythonStep 'compile_stage12_source.py'
$p=Start-Process -FilePath $GodotExe -ArgumentList @('--headless','--editor','--import','--path',('"' + $r + '"'),'--quit') -Wait -NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $r 'evidence\import_out.txt') -RedirectStandardError (Join-Path $r 'evidence\import_err.txt')
if($p.ExitCode -ne 0){throw 'Godot asset import failed'}
foreach($scene in @('A_BLUE_COTTAGE','B_OCHRE_GROVE')){
 $env:FS_STAGE12_SCENE=$scene
 $log=Join-Path $r ('evidence\GPU_'+$scene+'.txt')
 & $GodotExe --path $r --rendering-method gl_compatibility --script res://render_2d_stage12.gd *> $log
 if($LASTEXITCODE -ne 0 -or -not (Get-Content $log -Raw).Contains('STAGE12_GPU_RENDERED '+$scene)){throw ('Godot rendered invalid scene '+$scene)}
 Write-Output ('GPU PASS '+$scene)
}
PythonStep 'audit_stage12.py'
PythonStep 'actor_sweep_stage12.py'
PythonStep 'compare_stage14.py'
$qa=Get-Content (Join-Path $r 'evidence\STAGE14_FINAL_QA.json') -Raw|ConvertFrom-Json
if($qa.front_errors -ne 0 -or $qa.static_actor_positions -ne 70){throw 'Actor static QA FAIL'}
foreach($scene in @('A_BLUE_COTTAGE','B_OCHRE_GROVE')){
 $row=$qa.pixel_diffs.$scene
 if($row.ground -ne 0 -or $row.par -ne 0 -or $row.full -ne 0){throw ('Pixel parity fail '+$scene)}
 if(-not $qa.root_contact_single_32px.$scene){throw ('32px root contact fail '+$scene)}
}
Write-Output 'STAGE14B ENGINE TECH=PASS SOURCE DERIVED ART=NOT_APPROVED VX=NOT_RUN FORMAL_SEAL=NO'