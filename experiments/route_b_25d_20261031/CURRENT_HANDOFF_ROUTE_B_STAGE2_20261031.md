# FS ROUTE B / Stage2 + Fantasy Village Kit Trial / 2026-10-31

## Authority and scope
Isolated additive experiment. Never replace prior FS Stage12 ART FAIL authority, nor sealed K4 / Map.rvdata / Scripts.rvdata / Collision / user passability.
Experiment location: E:\\FS_ROUTE_B_STAGE2_KENNEY_20261031
Predecessor: FS_ROUTE_B_GODOT_PROTOTYPE_20261030

## Source asset provenance (license verified)
- Kenney Nature Kit: https://kenney.nl/assets/nature-kit ; CC0, 32 original GLB from https://github.com/Hidencod/tge-assets
- Kenney Fantasy Town Kit 2.0: https://kenney.nl/assets/fantasy-town-kit ; downloaded original ZIP 3,854,691 bytes from author's signed endpoint and directly inspected License.txt (CC0); selected 24 GLB meshes from GLB format directory.
- Fantasy Town shared external GLB texture: Models/GLB format/Textures/colormap.png must be preserved at assets/Textures/colormap.png; imported material 'colormap' was white without it. Explicit albedo_texture binding in render_stage2.gd fixes it.
- Nature Kit leaves and grass are inherently bright cyan in original GLB materials. For this FS proof of concept these material classes are overridden to natural green, with purple, yellow, red flowers and brown bark/dirt mapped separately.

## Work actually executed
1. Started with existing 544x416 native source-first Godot 2.5D example, retained shared orthographic camera / world scene / cull-mask.
2. Imported 32 native Kenney GLB environment models into Godot 4.7.2, rendered native source separately.
3. Created stage2 source-authoring methods using source meshes for trees, floral clumps, mushrooms, stone, cottage accents.
4. Original Stage2 import initially rendered cyan trees; diagnosed actual GLB baseColorFactor and corrected palette in render_stage2.gd.
5. Downloaded original Kenney Fantasy Town Kit 2.0; confirmed CC0 in original License.txt; extracted 24 selected models and required shared colormap.png.
6. Original fantasy glb renders were white; diagnosed imported StandardMaterial3D colormap texture = null in Godot. Explicitly assigned colormap.png to material, confirmed real red/green roof coloring with actual Godot 3D gallery render.
7. Built Stage2 fantasy village source candidate (render_village_kit.gd) with co-authored Ground house-footprint and PAR 3D building meshes. Ran real Godot GL renderer and QA.

## Most recent scene candidate verification
- Rendering engine: Godot 4.7.2 on user's Windows PC, AMD Radeon RX 6700 XT.
- Scene script: render_village_kit.gd, which extends render_stage2.gd -> render_scene.gd; NOT only a picture.
- Exports: out/GROUND.png native RGB 544x416, out/PAR.png native RGBA 544x416; out/SCENE_FULL.png, out/COMPOSITE_PREVIEW.png, out/QA_4PANEL.png, out/QA_REPORT.json.
- PAR alpha0 197,525; alpha>0 28,779; leaked nontransparent edge pixels = 0.
- Composite vs independently rendered full scene: 945 differing pixels (0.4176%), RGB channel mean absolute error 0.0411, max channel error 154. Therefore pixel-exact FAIL, but small average difference.
- Source-first provenance: independent render-layer captures share same 3D mesh scene and camera. No flattened 2D MASTER reverse cut.
- REAL ART REVIEW = FAIL. The resultant buildings have incomplete/awkward roof modules and patchy facade; flat procedural terrain, simplified vegetation, exposed house rectangle and weak painterly lighting. Far below ground3 and high-fidelity elf-village reference. Cannot present as formal FS Ground/PAR candidate.
- No pixel-art style match; not ready for 1280x928 enlargement or production map.

## Critical lessons
1. Source-based 3D Ground/PAR reliably solves much coordinate alignment, not fidelity.
2. CC0 GLB source != self-contained material. External shared textures need exact author-provided paths; never assume GLB import contains them.
3. Original Kenney Nature model colors aren't target FS style; color harmonization must be authored.
4. Kenney Fantasy Town is modular. Simply placing standalone roofs atop procedural boxes results in awkward houses. Need assembled complete building prefabs designed in shared 3D coordinates with coherent scale before using in map.
5. Ground/PAR visual gate must be human-reviewed before any formal seal, regardless of technical dimensions and Alpha.

## Proposed next controlled experiment
- Build ONE correctly assembled 3D cottage prefab, in a small 3D scene using Kenney compatible modular parts at native consistent scale. House close-up frame and source editability test.
- Establish full house roof, door opening, windows and consistent light/shadow. Compare to user's image at 1x native 544x416; if fidelity clearly fails, STOP with ART FAIL.
- If prefab art passes, expand to two houses + natural environment; otherwise test alternative high-fidelity source kit, not add procedural confetti.
- Preserve Ground RGB, native transparent PAR RGBA and no VX collision/passability edits.

## SEAL
ENGINE_3D_RENDER = WORKING
SOURCE_ORIGINALITY = VERIFY_KENNEY_CC0
GROUND_ALPHA_SIZE = PASS
PAR_ALPHA_BORDER = PASS
COMPOSITE_PIXEL_EXACT = FAIL_945_PIXEL
VILLAGE_ART = FAIL
FULL_FS_VISUAL_MATCH = FAIL
FORMAL_SEAL = NO