param([string]$GodotExe='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw 'Godot 4.7.2 executable missing'}
function PY([string]$name){
 & python (Join-Path $r $name) *> (Join-Path $r ('evidence\run_'+$name+'.txt'))
 if($LASTEXITCODE -ne 0){throw "Python gate failed: $name"}
 Write-Output "PY PASS: $name"
}
PY 'compile_stage12_source.py'
$p=Start-Process -FilePath $GodotExe -ArgumentList @('--headless','--editor','--import','--path',('"' + $r + '"'),'--quit') -Wait -NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $r 'evidence\GODOT_IMPORT_OUT.txt') -RedirectStandardError (Join-Path $r 'evidence\GODOT_IMPORT_ERR.txt')
if($p.ExitCode -ne 0){throw 'Godot asset import failed'}
foreach($id in @('A_BLUE_COTTAGE','B_OCHRE_GROVE')){
 $env:FS_STAGE12_SCENE=$id
 $log=Join-Path $r ('evidence\GPU_'+$id+'.txt')
 & $GodotExe --path $r --rendering-method gl_compatibility --script res://render_2d_stage12.gd *> $log
 if($LASTEXITCODE -ne 0){throw "Godot GPU failed $id"}
 $text=Get-Content $log -Raw
 if(-not $text.Contains('STAGE12_GPU_RENDERED '+$id)){throw "Missing actual GPU screen evidence $id"}
 Write-Output "GPU PASS: $id"
}
PY 'audit_stage12.py'
PY 'actor_sweep_stage12.py'
PY 'make_stage12_evidence.py'
$q=Get-Content (Join-Path $r 'evidence\STAGE12_GPU_PIXEL_QA.json') -Raw | ConvertFrom-Json
$actor=Get-Content (Join-Path $r 'evidence\STAGE12_ACTOR_SWEEP.json') -Raw | ConvertFrom-Json
foreach($id in @('A_BLUE_COTTAGE','B_OCHRE_GROVE')){
 $a=$q.$id
 if($a.ground.different_pixels -ne 0 -or $a.par.different_pixels -ne 0 -or $a.full.different_pixels -ne 0 -or -not $a.par_alpha_exact -or $a.gpu_par_border_nonzero -ne 0){throw "GPU pixel exact failure: $id"}
 if(-not $a.trees[0].base_32tile_pass){throw "Tree root core crosses one 32 tile: $id"}
 if($actor.$id.sample_count -ne 35 -or $actor.$id.front_nonzero -ne 0){throw "Actor static walk regression: $id"}
}
Write-Output 'STAGE12_SOURCE_FIRST_2D_GPU_PIXEL_EXACT=PASS_2_SCENES; TREE_CORE=PASS_2_OF_2; ACTOR_70_STATIC_SAMPLES_WITH_20_FRONT_ZERO; ART=VISUAL_CANDIDATE; VX=NOT_RUN; FORMAL_SEAL=NO'