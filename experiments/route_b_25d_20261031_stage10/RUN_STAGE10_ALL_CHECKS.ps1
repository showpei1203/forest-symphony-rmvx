param([string]$GodotExe='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw 'Godot not found'}
function RunPy([string]$name){
 & python (Join-Path $r $name) | Select-Object -Last 9
 if($LASTEXITCODE -ne 0){throw "Python failed $name"}
}
RunPy 'author_ground_stage5.py'
RunPy 'author_roof_material.py'
$importProc=Start-Process -FilePath $GodotExe -ArgumentList @('--headless','--editor','--import','--path',('"'+$r+'"'),'--quit') -NoNewWindow -Wait -PassThru -RedirectStandardOutput (Join-Path $r 'STAGE10_IMPORT_LOG.txt') -RedirectStandardError (Join-Path $r 'STAGE10_IMPORT_ERR.txt')
if($importProc.ExitCode -ne 0){throw ('Godot source import failed; exit='+$importProc.ExitCode)}
Write-Output 'GODOT_IMPORT_PASS (warnings captured separately)'
$env:FS_STAGE7_HOUSE='witch_cottage'
$env:FS_STAGE7_DETAIL='shader'
$env:FS_STAGE7_LIGHTING='unshaded'
$env:FS_STAGE8_TREE='both'
$env:FS_STAGE8_PALETTE='harmonized'
$env:FS_STAGE9_STYLE='clusters'
foreach($item in @(@('lobes','A_LOBES'),@('sprays','B_SPRAYS_SCATTERED'),@('woven','C_WOVEN_LEAF_ROSETTES'))){
 $name=$item[0];$folder=$item[1]
 $env:FS_STAGE10_GEOMETRY=$name
 Write-Output "=== SOURCE RENDER: $name ==="
 $log=Join-Path $r "STAGE10_$name.log"
 & $GodotExe --path $r --rendering-method gl_compatibility --script res://render_stage10_geometry.gd > $log 2>&1
 if($LASTEXITCODE -ne 0){throw "Godot rendering failed for $name"}
 $txt=Get-Content $log -Raw
 if(-not $txt.Contains('ART_ASSET witch_cottage')){throw "Missing cottage for $name"}
 if($name -ne 'lobes' -and -not $txt.Contains('STAGE10_GEOMETRY_LEAF_TRIANGLES=')){throw "New 3D geometry absent for $name"}
 RunPy 'qa.py'
 RunPy 'audit_tree_contact.py'
 RunPy 'test_actor_occlusion.py'
 $qa=Get-Content (Join-Path $r 'out\QA_REPORT.json') -Raw | ConvertFrom-Json
 $tree=Get-Content (Join-Path $r 'out\CONTACT_32_GRID_AUDIT.json') -Raw | ConvertFrom-Json
 if(($qa.ground_mode -ne 'RGB') -or ($qa.par_mode -ne 'RGBA') -or $qa.par_border_nonzero -ne 0 -or (-not $tree.one_tile_pass)){throw "Native Ground/PAR invalid $name"}
 if($qa.par_alpha_nonzero_pixels -lt 45000 -or $qa.ground_unique_rgb -lt 3000){throw "Suspected empty scene in $name"}
 $target=Join-Path $r ('candidates\'+$folder)
 New-Item -ItemType Directory -Force $target | Out-Null
 foreach($f in @('GROUND.png','PAR.png','COMPOSITE_PREVIEW.png','SCENE_FULL.png','TREE_CONTACT_MASK.png','QA_REPORT.json','CONTACT_32_GRID_AUDIT.json','STAGE6_ACTOR_OCCLUSION_QA.json','STAGE6_ACTOR_OCCLUSION_6PANEL.png')){
  Copy-Item -Force (Join-Path $r ('out\'+$f)) (Join-Path $target $f)
 }
 Write-Output ("PASS "+$name+" DIFF="+$qa.full_vs_alpha_composite_differing_pixel_count)
}
RunPy 'compare_stage10.py'
RunPy 'audit_walk_stage10.py'
$walk=Get-Content (Join-Path $r 'out\STAGE10_ACTOR_WALK_SWEEP_QA.json') -Raw|ConvertFrom-Json
if($walk.sample_count -ne 70 -or $walk.front_nonzero -ne 0){throw 'Dynamic 70-position front actor sweep regressed'}
$report=Get-Content (Join-Path $r 'out\STAGE10_GEOMETRY_QA.json') -Raw|ConvertFrom-Json
if(-not $report.ground_unchanged_for_all_variants){throw 'Ground changed unexpectedly'}
Write-Output 'STAGE10_ENGINE_PASS; THREE_ART_CHOICES_RENDERED; 70_POSITION_ACTOR_PASS; GROUND_NATIVE_PASS; ART_FAIL; SEAL_NO'