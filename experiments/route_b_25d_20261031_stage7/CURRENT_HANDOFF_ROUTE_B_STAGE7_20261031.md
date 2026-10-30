# Forest Symphony | Route B Stage7 | Native CC0 House Source + glTF Normalization + Detail Shader
Date: 2026-10-31 | Experiment branch only | Formal Seal: NO

## Authority and preserved baseline
- Respect R17 direct Ground/PAR: no independent completed-master segmentation. Ground is RGB native 544x416; PAR is true RGBA 544x416 with camera/world alignment.
- User's original Ground3 and art references are for **private visual comparison only**; no copying to a public source repository.
- Existing sealed FS RPG Maker VX binaries, scripts, maps, collisions, gates and previous Stage3-6 projects not modified.
- Fixed PAR render order Ground -> actor -> PAR. Prior Stage6 six-character-position prototype confirmed for Stage7 candidate, but this does NOT represent full executable VX integration or dynamic depth.

## Actual work this turn
1. Forked Stage6 to E:\\FS_ROUTE_B_STAGE7_SOURCE_ASSETS_20261031, preserving the native tree split and environment baseline.
2. Searched current CC0 3D sources; downloaded actual assets from https://3dassets.dev (license stated CC0 1.0 Universal by publisher):
  - medieval_timber_small, source https://3dassets.dev/assets/medieval-mmo-starter-realm-timber-house-small-25223f49, 132796 bytes
  - medieval_thatch_cottage, source https://3dassets.dev/assets/medieval-mmo-starter-realm-thatched-cottage-3921d162, 116276 bytes
  - witch_cottage, source https://3dassets.dev/assets/witch-cottage-and-apothecary-hedge-witch-25562947-starter-scene, 2744952 bytes.
3. Found all three raw GLBs require KHR_mesh_quantization; original Godot 4.7.2 glTF import returns ERR_PARSE_ERROR. Original raw GLBs are stored in source_raw/ (with .gdignore to prevent Godot from importing them and reporting false errors). Converted using @gltf-transform/cli 4.5.1 **dequantize** into assets/; import successfully produces PackedScene GLBs:
   - medieval_timber_small_std.glb 187256 bytes
   - medieval_thatch_cottage_std.glb 163900 bytes
   - witch_cottage_std.glb 3647124 bytes
   - Third house also includes EXT_texture_webp and KHR_materials_transmission, retained in normalized result; Godot imported the normalized scene.
4. Wrote render_stage7_cottage.gd with true 3D source GLB (not 2D master copy), fixed world-scale/align via actual source bounds, selectable house and material variant via environment variables; preserved Stage5 native Ground/PAR camera and tree contacts. Actual imported witch cottage has 279 instantiated MeshInstance3D nodes / source GLB 179 raw meshes.
5. Authored original detailed 512x512 roof_thatch_stage7.png (deterministic structured rows of reeds) and shader material from 3D world coordinates for the cottage's 'thatch' material. Unlike the Stage7 Triplanar attempt, the world-position shader preserves readable stripes in Godot Compatibility.
6. Detected procedural error: new texture wasn't imported by Godot editor before running render (roof white). Added mandatory editor --import before render. The failed white-roof candidates were preserved in 'candidates'; these must not be claimed as art progress.
7. Rendered three independent cottage sources in common 544x416 scene, compared native size. Tested additional triplanar, lit and 3D world-position roof shading. Selected world-position shader at scale 0.19 as most promising technical/art candidate. Removed synthetic square ground footprint.
8. Rechecked Ground RGB 544x416 and PAR RGBA 544x416, PAR border alpha leak 0, Stage5 two tree contacts still confined to one 32px cell each.
9. Re-ran Stage6 real 2D actor->PAR six placements on Stage7 native layers: 6/6 threshold pass (WEST: rear 77.47%, base 25.889%, front 0%; EAST: rear 73.913%, base 16.008%, front 0%; both rear heads 100% obscured). Scope remains ONLY these two trees, six positions and one 32px actor.
10. Actual Stage7 selected final 3D full render compared with independent Ground + PAR composite differs at 431 of 226304 pixels (~0.19046%), MAE 0.01963, max error 65. This is NOT exact and not a formal technical seal.

## Art decision
- Imported original two MMO thatched/wood cottages were too blocky, roofs broad monochrome; ACTUAL_ART=FAIL.
- Imported witch cottage preserved richer small details but still had excessively plain roof. Texture-based world shader clearly improved roof bands and eliminated the white texture; full reference match still FAIL.
- New cottage adds roof detail with only 189 unique PAR RGBA colors and surrounding trees still primitive canopy blobs. Compare against user's Ground3 with building and foliage material quality: NOT YET A FORMAL ART PASS.
- Never use large mesh count as a substitute for 1x pixel visual acceptance.
- Beware: Unshaded and lit variants do not composite identically. LIT_TEXTURE candidate full-vs-2layer differs at 36092 pixels, rejected for this ground-first method.

## Source build reproducibility
- Godot 4.7.2 Compatibility / AMD RX 6700 XT.
- CLI dependency only for *original raw models*; normalized .glb already included in ZIP:
  npm install --prefix <project>/gltf_tools @gltf-transform/cli
  <project>/gltf_tools/node_modules/.bin/gltf-transform.cmd dequantize <raw>.glb <std>.glb
- Generate roof_thatch_stage7.png with: python author_roof_material.py
- Mandatory import new resources first:
  Godot_v4.7.2-stable_win64_console.exe --headless --editor --import --path <project> --quit
- Then PowerShell:
  $env:FS_STAGE7_HOUSE='witch_cottage'
  $env:FS_STAGE7_DETAIL='shader'
  $env:FS_STAGE7_LIGHTING='unshaded'
  Godot_v4.7.2-stable_win64_console.exe --path <project> --rendering-method gl_compatibility --script res://render_stage7_cottage.gd
  python qa.py
  python audit_tree_contact.py
  python test_actor_occlusion.py
- Final deliverables native out/GROUND.png, PAR.png, SCENE_FULL.png, COMPOSITE_PREVIEW.png, TREE_CONTACT_MASK.png, STAGE6_ACTOR_OCCLUSION_6PANEL.png; out/STAGE7_THREE_HOUSE_COMPARISON.png, out/STAGE7_FIXED_ROOF_COMPARE.png; out/QA_REPORT.json, CONTACT_32_GRID_AUDIT.json, STAGE6_ACTOR_OCCLUSION_QA.json. The three-house gallery is from initial scale 4.32 for witch; final source output uses height 3.75.

## Strict outcome
REAL_GODOT_IMPORT_AFTER_DEQUANTIZE=PASS
ART_ASSET_PROVENANCE_CC0=ATTRIBUTED_TO_PUBLISHER; RAW_SHA_IN_MANIFEST
GROUND_RGB_544x416=PASS
PAR_RGBA_544x416_BORDER_ZERO=PASS
TREE_CONTACT_32PX=PASS_2_OF_2
CHARACTER_OCCLUSION_FIXED_TEST=PASS_6_OF_6
TWO_LAYER_VS_INDEPENDENT_FULL_PIXEL_EXACT=FAIL_431
HIGH_FIDELITY_REFERENCE_ART=FAIL
VX_EXECUTABLE_INTEGRATION=NOT_RUN
FINAL_SEAL=NO

## Next decision
Source fidelity remains the bottleneck. Stop repeatedly adding low-poly geometry or random procedural shrubs. Artist-quality roof, timber, detailed crown texture/mesh need a cohesive style, then re-validate direct Ground/PAR and actual VX character/depth.