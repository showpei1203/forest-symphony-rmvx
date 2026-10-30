param([string]$GodotExe='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw 'Godot 4.7.2 missing'}
function PY([string]$name){
 & python (Join-Path $r $name) | Select-Object -Last 8
 if($LASTEXITCODE -ne 0){throw ('Python failed: '+$name)}
}
PY 'author_ground_stage5.py'
PY 'author_roof_material.py'
$proc=Start-Process -FilePath $GodotExe -ArgumentList @('--headless','--editor','--import','--path',('"' + $r + '"'),'--quit') -Wait -NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $r 'STAGE11_IMPORT_OUT.txt') -RedirectStandardError (Join-Path $r 'STAGE11_IMPORT_ERR.txt')
if($proc.ExitCode -ne 0){throw ('Godot import failed '+$proc.ExitCode)}
$env:FS_STAGE7_HOUSE='witch_cottage'
$env:FS_STAGE7_DETAIL='shader'
$env:FS_STAGE7_LIGHTING='unshaded'
$env:FS_STAGE8_TREE='both'
$env:FS_STAGE8_PALETTE='harmonized'
$env:FS_STAGE9_STYLE='clusters'
$env:FS_STAGE10_GEOMETRY='woven'
foreach($c in @(@('broad','A_BROAD'),@('fine','B_FINE'),@('pruned','C_PRUNED'))){
 $name=$c[0];$folder=$c[1]
 $env:FS_STAGE11_MODE=$name
 $log=Join-Path $r ('STAGE11_'+$name+'.log')
 & $GodotExe --path $r --rendering-method gl_compatibility --script res://render_stage11_components.gd > $log 2>&1
 if($LASTEXITCODE -ne 0){throw ('Godot failed rendering '+$name)}
 $logText=Get-Content $log -Raw
 if(-not $logText.Contains('ART_ASSET witch_cottage') -or -not $logText.Contains('STAGE11_REAL_GEOMETRY mode='+$name)){throw ('Empty model or missing new geometry: '+$name)}
 PY 'qa.py'
 PY 'audit_tree_contact.py'
 PY 'test_actor_occlusion.py'
 $qa=Get-Content (Join-Path $r 'out\QA_REPORT.json') -Raw|ConvertFrom-Json
 $tr=Get-Content (Join-Path $r 'out\CONTACT_32_GRID_AUDIT.json') -Raw|ConvertFrom-Json
 if($qa.ground_mode -ne 'RGB' -or $qa.par_mode -ne 'RGBA' -or $qa.par_border_nonzero -ne 0 -or $qa.par_alpha_nonzero_pixels -lt 48000 -or -not $tr.one_tile_pass){throw ('Native Ground/PAR gate failed '+$name)}
 $dst=Join-Path $r ('candidates\'+$folder)
 New-Item -ItemType Directory -Force $dst | Out-Null
 foreach($f in @('GROUND.png','PAR.png','COMPOSITE_PREVIEW.png','SCENE_FULL.png','TREE_CONTACT_MASK.png','QA_REPORT.json','CONTACT_32_GRID_AUDIT.json','STAGE6_ACTOR_OCCLUSION_QA.json','STAGE6_ACTOR_OCCLUSION_6PANEL.png')){Copy-Item -Force (Join-Path $r ('out\'+$f)) (Join-Path $dst $f)}
 Write-Output ('CANDIDATE '+$name+' GROUND/PAR PASS FULL_RENDER_MISMATCH='+$qa.full_vs_alpha_composite_differing_pixel_count)
}
PY 'compare_stage11.py'
PY 'audit_walk_stage11.py'
$walk=Get-Content (Join-Path $r 'out\STAGE11_ACTOR_WALK_SWEEP_QA.json') -Raw|ConvertFrom-Json
if($walk.sample_count -ne 70 -or $walk.front_nonzero -ne 0){throw 'Front actor walk sweep regression'}
$cmp=Get-Content (Join-Path $r 'out\STAGE11_GEOMETRY_QA.json') -Raw|ConvertFrom-Json
if(@($cmp.candidates|Where-Object {$_.ground_changed_pixels -ne 0 -or $_.par_lost_opaque -ne 0 -or $_.par_border_violations -ne 0}).Count -ne 0){throw 'Native layer regression'}
Write-Output 'STAGE11_TECH_POC_PASS ART_FAIL FORMAL_SEAL_NO'