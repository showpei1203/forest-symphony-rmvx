# FS A36 Handoff｜修正正式動作格數 3幀（2026-11-01）

## Correction
User: 「按規則每個動作我們只需要3幀」。
Previous A35 generated 28 actual PixelLab interpolation frames and assembled an 18-frame research candidate, but final SBS action must ALWAYS be three frames. Record this as a delivery-spec mistake, not an optional preference.
A36 implemented fail-closed 3 frames/action; each 40x40 => full 120x40 source sheet. A35 raw frames remain source library only.

## Actual outputs
- A36_DODGING_FORMAL_3FRAME_CANDIDATE.png: exact 120x40 3 columns [A34 original native-view F0, true A35 PixelLab B03 low crouch F1, same exact A34 F0 F2]. No new handpainted images.
- A36_DODGING_FORMAL_3FRAME_ONESHOT.gif: exact three frames, single playback (no GIF loop extension), verified PIL.n_frames=3.
- A36_DODGING_FORMAL_3FRAME_LARGE_PREVIEW.png: 3 frames enlarged with action labels.
- A36_DODGING_FOUR_3FRAME_VARIANTS_PREVIEW.png: 4 alternative 3-frame pose choices from same originals; default T3 chosen because 3-frame roll acrobatics overly abrupt. Alternatives are candidates, not final art.
- A36_WALK_3FRAME_APPROVED_A31.png: c0,c1,c2 unique original 3 frames; A31 actual 4-phase c0,c1,c2,c1 now encoded as three source frames and runtime re-use of frame c1. A31 already approved motion and original art not overwritten.
- A36_WAITING_3FRAME_STATIC_REPEATED.png: three copies of the same approved static sprite, no shoulder jitters.
- A36_NOTHING_3FRAME_TRANSPARENT.png: 3 empty alpha cells.
- A36_FORMAL_3FRAME_QA.json, A36_3FRAME_QA.json, source scripts and sample GIFs.

## Objective pass and limitations
3 frames exact -> technical PASS. Every sheet width=120, height=40, clear alpha; per-action single-row. F0=F2 pixel identity PASS. No new PixelLab paid calls; balance last verified at 1741.8/2000 A35.
Every-frame precise battle 45° and actual natural dodge remain to user art review. Tankentai SBS paper-doll + VX/Godot engine NOT RUN, so not formal game integration PASS. User should review T3 motion with concern that low dodge may read more crouch than lateral evasion.
Do not silently reintroduce more frames into official output. Raw A35 provider14+14, original 18-frame preview remain research-only.
FS/PMD original images and SBS files untouched.
