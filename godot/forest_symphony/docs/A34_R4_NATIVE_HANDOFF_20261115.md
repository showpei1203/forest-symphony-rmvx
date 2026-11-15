# Forest Symphony | A34 R4 Native Houses Handoff | 2026-11-15

## Actual construction
The two elf-village houses are independent transparent PAR assets, not a flattened map. The left is the combined residence/workshop; the right is a visually matched independent residence. A34 R4 scene is the ZIP's default scene. Original A32/A33 scenes are preserved byte-for-byte. 146 object owners, stable IDs, original Ground SHA are unchanged.

## Godot 4.7.2 native evidence
Editor import PASS exit 0. Source/texture/physical rectangle collision contract 738/738 PASS exit 0. Real OpenGL 3.3 RX 6700 XT frame capture PASS exit 0. A33→A34 changed 72265 native RGB pixels inside house rectangles, 0 outside. Actor fully behind left house: 0 changed pixels versus no-actor; actor in front: 576 changed pixels, proving footpoint-based Y sort occlusion works in this scene.

## Current art gate
ART HOLD. 1x user inspection pending. Although building visuals are now coherent and new two-house PAR sprites exist, actual art has been rescaled from generated originals and requires source pixel-density review. Future Ground3 work and forest biomes are separate. No game event/story work under this map-art lane.

## Failure Log
- A34 R2: unpaired source_file/source_sha256 caused mismatch.
- A34 R3: private ZIP unexpectedly lacked sealed A33 scene (baseline regression). R4 remerged immutable A33 owner archive and verified scene preservation, preserving R3 candidate only as asset/history.
- A34 R4: Godot headless test PASS, but headless SubViewport frame_post_draw stalls (no native framebuffer). Stopped hung process and reran capture with real Windows OpenGL driver on AMD RX 6700 XT; actual captures and ROI pass.
- Source art remains visually under human review; no claim of final seal.

## Next
A35 natural forest groups and edge continuations, improve Ground-native resolution and surfaces without altering A34 PAR; A36 collision/path and entry hotspots; A37 repeatable automated Ground/PAR scene production; user approval needed before formal village art seal.

## Drive owner-only native artifacts
- Native screenshots, actor occlusion contact, JSON QA and handoff: https://drive.google.com/drive/folders/1wP9AJua0F985j4YgMLcHV86-0LGStUd8
- A34 R4 portable candidate ZIP (169 members): https://drive.google.com/file/d/1iij7dr3dMr5dHh3b3cH-6ofFRz6tOvmS/view
- Complete native ZIP copy in private Drive File Stream folder: verify file ID before using as link.

## Source-only GitHub
`scenes/a34_r4_house_pair_scene.tscn`, `scripts/a34_r4_world.gd`, `tests/test_a34_r4_real.gd`, `tests/capture_a34_r4_native.gd`, `data/a34_r4_house_pair_manifest.json`, `tools/a34_r4_build_pair.py`.
