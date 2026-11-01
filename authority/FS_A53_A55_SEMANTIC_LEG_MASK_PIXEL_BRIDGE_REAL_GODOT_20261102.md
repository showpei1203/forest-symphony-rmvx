# FS A53 → A55 | SBS Moving to Close Attack, 2026-11-02

## Authority
User 16-action three-pose reference: left column=left stride, center=neutral, right=other stride. FS stores three 40x40 images, F0 neutral, F1 left, F2 right, playback 0→1→0→2. Tankentai controls world movement. Original FS native actor01 battle PNGs are angle/character authority; this source F0 is A46 PixelLab-rotated 45-degree candidate and NOT exact original native PNG. Never promote to formal release based on 45-degree direction parameter alone.

## A53 semantic parts
From the source 40x40 RGBA F0, extracted L_SHIN 35, L_BOOT 18, R_SHIN 24, R_BOOT 13 source opaque pixels, plus masks and isolated semantic layers. Six independent-joint local render experiments, no PixelLab credits. P4_small_strides is best technically valid candidate with 1 connected component in F0/F1/F2, head/face exact and no clip. P1/P2/P3/P5/P6 exhibit leg disconnections or clipping. Natural running remains ART PENDING.

## A54 local bridge QA
Source-palette shortest-path 1-pixel leg repair. Rejoined most disconnected candidates using no generative model. P5 still bottom clipped and rejected. A54 P3 repaired is only visual comparison candidate, not a certified animation. Technical continuity is not a motion-quality guarantee.

## A55 REAL GPU experiment
Created standalone editable Godot 4.7.2 project with P4 and P3 repaired 3-frame sprites, interactive loop using 0→1→0→2 and keyboard: 1=P4, 2=P3, Space=pause. Verified real OpenGL compatibility renderer on RX 6700 XT: 2 variants * 4 phases = 8 true 544x416 engine screenshots. Every GPU screenshot matches nearest-neighbor expected composition exactly (8 of 8 had 0 different pixels); phase 0 and phase 2 bit-identical. Ran the Godot interactive scene successfully (FS_A55_RUNTIME_LOOP_READY). Initial headless run failed dummy renderer and was rejected, not misrepresented as rendering.

## Final gates
Engineering: source masks, 3 frames, 120x40, alpha continuity P4, loop order, real Godot frame rendering = PASS.
Human FS-native 45-degree art matching: PENDING.
Left/right foot running readability: ART PENDING; stride subtle.
Actual RPG Maker VX Tankentai SBS movement and weapon paper-doll layers: NOT TESTED.
Formal release: FAIL-CLOSED, do not overwrite sealed FS assets.

## Next
Use quarantined original FS VX + Tankentai test build to wire 0-1-0-2 and screenshot actual SBS move-to-target. Compare native battle-facing and motion reference per pose; check feet, hands, weapon overlays, timing and seams. No further paid regeneration until free pose and art masks are approved. All A53/A54/A55 PNG/GIF/JSON/source scripts and Godot project are preserved.