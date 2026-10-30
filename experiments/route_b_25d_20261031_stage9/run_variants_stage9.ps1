$ErrorActionPreference='Stop'
$r=Split-Path -Parent $MyInvocation.MyCommand.Path
$e='E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$env:FS_STAGE7_HOUSE='witch_cottage'
$env:FS_STAGE7_DETAIL='shader'
$env:FS_STAGE7_LIGHTING='unshaded'
$env:FS_STAGE8_TREE='both'
$env:FS_STAGE8_PALETTE='harmonized'
foreach($mode in @('bands','clusters')){
 $env:FS_STAGE9_STYLE=$mode
 Write-Output ("==== RENDER "+$mode+" ====")
 & $e --path $r --rendering-method gl_compatibility --script res://render_stage9_crown.gd 2>&1 | Select-Object -Last 15
 if($LASTEXITCODE -ne 0){throw "RENDER failed"}
 foreach($test in @('qa.py','audit_tree_contact.py','test_actor_occlusion.py')){
  Write-Output "TEST $test"
  & python (Join-Path $r $test) | Select-Object -Last 13
  if($LASTEXITCODE -ne 0){throw "QA failed $test mode $mode"}
 }
 $q=Get-Content (Join-Path $r 'out\QA_REPORT.json') -Raw | ConvertFrom-Json
 $contact=Get-Content (Join-Path $r 'out\CONTACT_32_GRID_AUDIT.json') -Raw | ConvertFrom-Json
 if(($q.ground_mode -ne 'RGB') -or ($q.par_mode -ne 'RGBA') -or ($q.par_border_nonzero -ne 0) -or (-not $contact.one_tile_pass)){throw "Native layer gate FAIL $mode"}
 $dest=Join-Path $r ('candidates\'+$mode)
 New-Item -ItemType Directory -Force $dest | Out-Null
 foreach($f in @('GROUND.png','PAR.png','COMPOSITE_PREVIEW.png','SCENE_FULL.png','TREE_CONTACT_MASK.png','QA_REPORT.json','CONTACT_32_GRID_AUDIT.json','STAGE6_ACTOR_OCCLUSION_QA.json','STAGE6_ACTOR_OCCLUSION_6PANEL.png')){
  Copy-Item -Force (Join-Path $r ('out\'+$f)) (Join-Path $dest $f)
 }
 Write-Output ("STYLE="+$mode+" DIFF="+$q.full_vs_alpha_composite_differing_pixel_count+" PAR_BORDER="+$q.par_border_nonzero+" ACTOR=PASS TREE_CONTACT=PASS")
}