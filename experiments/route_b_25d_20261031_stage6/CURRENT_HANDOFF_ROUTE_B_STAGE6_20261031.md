# Forest Symphony | Route B Stage6 Native Actor Occlusion + ground3 Fidelity Audit | 2026-10-31

## Governing Authority
R17_DIRECT_GROUND_PAR_AUTHORITY remains the required 2-layer production mechanism: independently authored RGB GROUND and genuinely transparent RGBA PAR, fixed world coordinates. User will personally build their visual Ground with PAR and set VX passability. FS sealed maps/scripts/K4/collision untouched. Stage5 tree-base-in-one-32px-cell controls remain unchanged.

## Work actually performed
1. Duplicated Stage5 as isolated E:\\FS_ROUTE_B_STAGE6_ACTOR_OCCLUSION_20261031, preserving existing 544x416 Ground and PAR.
2. Authored independent 32x32 RGBA prototype player sprite and a deterministic Python pixel compositor test_actor_occlusion.py. Actor has actual nontransparent head, torso and boot pixels; not a fake bounding-box rectangle.
3. Captured SIX fixed scenarios with actual 2D layers, render order: GROUND -> 32x32 ACTOR -> PAR (not Godot depth-buffer assertion).
4. Referenced actual 3D native TREE_CONTACT_MASK-derived Stage5 audit rects WEST [78,134,92,158], EAST [449,130,478,159]. For each, sprite foot at contact ymax+(-16,0,+16) pixels (behind, at-base, front).
5. Saved native 1x PNGs for all six scenarios, STAGE6_ACTOR_OCCLUSION_6PANEL.png, 32px sprite, 2 alternate draw-order images and STAGE6_ACTOR_OCCLUSION_QA.json. Pass conditions: head behind >80% occluded, front actor 0% occluded, at-base partially occluded.
6. Retrieved user's original `ground3.png` from authoritative private Google Drive benchmark folder (file ID 114CDKKySuzyuuwxRonhx8ebBsgX3ZFww) and visually compared original native 544x416 crop (x70..613, y100..515) with Stage5 candidate. Reference raw/crop stays private, NOT copied into public GitHub.

## Actual six-scenario pixel QA
WEST BEHIND: actor obscured 77.470%, head obscured 100.000%.
WEST AT_BASE: actor obscured 25.889%, head obscured 61.905%.
WEST FRONT: actor obscured 0%, head obscured 0%.
EAST BEHIND: actor obscured 73.913%, head obscured 100%.
EAST AT_BASE: actor obscured 16.008%, head obscured 38.571%.
EAST FRONT: actor obscured 0%, head obscured 0%.
Test thresholds PASS for both trees, this *only* supports these six offsets/one 32x32 prototype sprite/fixed 544x416 camera. This is NOT a full real executable VX collision or dynamic occlusion test.

## Original ground3 fidelity warning (visual and descriptive, NOT a pass metric)
At native 544x416 without scaling, a user-provided ground3 crop shows more detailed roofs/wood planks/windows/stairs, multiple layered vegetation hues, cliff walls, dirt path edges and dense identifiable leaf clusters. Stage5 image shows low-poly tree blobs, simplified single cottage, relatively low-contrast broad ground noise.
A simple comparative color/edge statistic on non-matching-content 544x416 crops: ground3 63,151 distinct RGB values, mean horizontal RGB absolute difference 15.585, 26.704% adjacent x-pairs color difference >20; Stage5 candidate 2,700 distinct RGB values, mean difference 2.808, 5.207% >20. NOTE: these are **descriptive diagnostics only**, confounded by scene composition and cannot be used as artistic quality thresholds. They reinforce the obvious visual disparity.
Priority is a more detailed artist-grade source library, not procedural foliage scatter or post-image sharpening.

## Stage5 inherited technical limitations still active
GROUND native RGB and PAR native RGBA 544x416; PAR border alpha leak zero.
Tree bottom source-native 3D clipped to Ground, both screen footprints within one 32x32 tile, PAR upper tree only.
Ground+PAR versus separate complete Godot 3D scene differs at 2667/226304 pixels (~1.1785%), not pixel-exact. Stage6 did not modify the 3D source and cannot claim this solved.
Room/tree art FAIL vs user's ground3/elf village. No user visual acceptance.

## Next experiment
1. Validate one 32x32 moving sprite at more than six fixed positions and compare against tree footprint/canopy projection; dynamic depth remains a possible limitation of fixed PAR ordering.
2. Preserve original 3D editable cottage/tree source. Get verified high-fidelity *independently editable* wood, canopy and terrain source consistent with benchmark; don't simply copy licensed ground3 into a public kit.
3. Retest full-scale high-density source at 1x with direct Ground + PAR, native tree contacts, then wider walkability areas.
4. Only after visible art quality passes consider expanded village. Original VX software remains untouched until explicitly instructed.

## Gate status
NATIVE_LAYER_PROVENANCE=PASS_STAGE5
ACTOR_TWO_TREES_SIX_POSITIONS=PASS_6_OF_6
TREE_CONTACT_32PX=PASS_2_OF_2
ORIGINAL_ART_REFERENCE_LOCATED=YES
FULL_SCENE_COMPOSITE_PIXEL_EXACT=FAIL_2667
VX_EXECUTABLE_ACTOR_INTEGRATION=NOT_RUN
ART_REFERENCE_FIDELITY=FAIL
FORMAL_SEAL=NO