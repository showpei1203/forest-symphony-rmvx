param(
 [string]$GodotExe = 'E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
)
$ErrorActionPreference='Stop'
$project=Split-Path -Parent $MyInvocation.MyCommand.Path
if(-not (Test-Path $GodotExe)){throw "Godot 4.7.2 missing: $GodotExe"}
function RunPython([string]$n){
 Write-Output "PYTHON $n"
 & python (Join-Path $project $n)
 if($LASTEXITCODE -ne 0){throw "$n FAIL exit $LASTEXITCODE"}
}
RunPython 'author_ground_stage5.py'
RunPython 'author_roof_material.py'
Write-Output 'GODOT IMPORT SOURCE ASSETS'
& $GodotExe --headless --editor --import --path $project --quit
if($LASTEXITCODE -ne 0){throw "Godot import failure exit $LASTEXITCODE"}
$env:FS_STAGE7_HOUSE='witch_cottage'
$env:FS_STAGE7_DETAIL='shader'
$env:FS_STAGE7_LIGHTING='unshaded'
$env:FS_STAGE8_TREE='both'
$env:FS_STAGE8_PALETTE='harmonized'
Write-Output 'GODOT RENDER NATIVE GROUND+PAR'
& $GodotExe --path $project --rendering-method gl_compatibility --script res://render_stage8_oak.gd
if($LASTEXITCODE -ne 0){throw "Godot render failure exit $LASTEXITCODE"}
RunPython 'qa.py'
RunPython 'audit_tree_contact.py'
RunPython 'test_actor_occlusion.py'
RunPython 'compare_stage8.py'
$contact=Get-Content -Raw (Join-Path $project 'out/CONTACT_32_GRID_AUDIT.json')|ConvertFrom-Json
$scene=Get-Content -Raw (Join-Path $project 'out/QA_REPORT.json')|ConvertFrom-Json
$actor=Get-Content -Raw (Join-Path $project 'out/STAGE6_ACTOR_OCCLUSION_QA.json')|ConvertFrom-Json
if(-not $contact.one_tile_pass){throw '32px tree contact FAIL'}
if($scene.par_border_nonzero -ne 0){throw 'PAR border not transparent'}
if($scene.ground_mode -ne 'RGB' -or $scene.par_mode -ne 'RGBA'){throw 'Ground/PAR mode FAIL'}
if($scene.size[0] -ne 544 -or $scene.size[1] -ne 416){throw 'Resolution FAIL'}
if($actor.scenario_rows.Count -ne 6){throw 'Actor tests missing'}
Write-Output ("GATES: NATIVE_LAYER=PASS TREE_CONTACT=PASS ACTOR=PASS FULL_RENDER_PIXEL_DIFF="+$scene.full_vs_alpha_composite_differing_pixel_count+" FORMAL_SEAL=NO ART=FAIL")