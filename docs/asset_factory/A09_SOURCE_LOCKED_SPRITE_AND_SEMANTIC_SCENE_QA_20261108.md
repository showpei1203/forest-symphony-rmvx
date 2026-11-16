# A09 real-source sprite and semantic two-scene QA | 2026-11-08

## REAL binary source recovery, not a plan
- Recovered private P3_G9 complete 0001–0003 2026-10-27 PMD evolution ZIP, verified 3,881,101 bytes, SHA256 `74061d61a7fde6650699ee30ad1339ff255924a9cae13c98cb1703478eae260f`, 1128 entries / ZIP CRC PASS.
- PMD0001 production XML SHA256 `c7722f5da724f40f35fccabb1135fbd1b70e770b2a38db3d9fbe7643af626162`; source art G3R1 native accepted baseline (historical, DO NOT extrapolate). Idle 32x40x3 frames, Walk 40x40x6, both true 8 native row atlases. First-frame native row RGBA bytes all eight distinct.
- PMD0002 native production XML SHA `e1c494c9d795980bb77622e8ce782b4fba62bd1e5103165351748dc3924702c0`; PMD0003 native production XML SHA `b5b556e42df4322440f63da430e918bbad794c83cdf58dbff2393138f96c15d3`. Idle/Walk each 32x32x4 frames with eight rows. Only selected earlier G8R4/G8R5 keyframes accepted; 1356 newly generated G9 action frames across 0002/3 need human review, not full art PASS.
- A62 historical accepted Actor running strip remains 144x48 three stored 48x48 poses; playback [0,1,0,2]; no new SBS native integration.
- Source-locked PRIVATE kit: `FS_A09_SOURCE_LOCKED_SPRITE_FACTORY_PILOT_20261108.zip`, 217,991 bytes, SHA256 `9b1465828dd40b4fedf63e49f7598583b2a08ac9e2181c5a0c85ebb86c5b389a`, 37 files, SHA and CRC readback. Stored in owner-only restricted Google Drive Binaries area, no private download link in public GH. Includes actual native Anim/Offsets/Shadow + XML for all six Idle/Walk, source bboxes/pixel-change metrics, 8-row contact previews, A62 actual PNG/GIF, and SHA manifest. **No AI-created monster new art here.**
- A25 distinct PixelLab approved-looking 64px concept archive remains SOURCE_NOT_VERIFIED; source G9 is a DIFFERENT genuine approved baseline and must never be relabeled as A25.

## Authentic Ground3 reference source
- Read-only authorized Windows source at `Graphics/Parallaxes/ground3.png` was found and verified, 2,400,808 bytes, SHA256 `ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13`. Do not substitute same-name `Overlays/ground3.png` shadow layer. No PC files created or modified.

## Actual A09 two-scene cloud blueprint generator
- Public `tools/asset_factory/scene_blueprint.py`: deterministic 32x32, 40x29 grid for distinct `ELF_VILLAGE` seed 20261108 and `FOREST_BRIDGE` seed 20261203. Templates source-register whole-house+workshop, canopy families, bridge deck/far rail/near rail/posts, grass, water, paths, and source-pending mask/depth.
- Semantic source gate: bridge deck stays `GROUND_ONLY`, near/front rail is `CONDITIONAL_FOREGROUND` with empty source/mask and cannot be promoted to runtime PAR. Low vegetation never becomes foreground. Collision graph checked for a river crossing on an actual deck.
- `tools/asset_factory/export_a09_scenes.py` emits two real Tiled-compatible `.tmj` object-layer files, two canonical scene JSONs, and a SHA manifest directly in GitHub Actions runner with no paid call. Tiled object layer ≠ native finished art. **Master/Runtime Ground/PAR images not generated.**
- Initially failed seven tests because an 8-digit YYYYMMDD seed exceeded an obsolete 6-digit validator; fixed once in shared template, CI green. No per-map repainting.
- First green 95/95 after correction: Actions 42424730379. Latest source/config build run 42424904974, 95/95 PASS; artifact [FS_A09_Tiled_Semantic_Blueprints](https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/42424904974/artifacts/13595047682), uploaded SHA256 `50a05e6e99ef555ce8540c48471d0553b78137eaab6bc18c35c853ddc76a7048`. Later documentation commits require fresh latest HEAD CI check.

## Gate matrix
REAL PMD SOURCE RECOVERY PASS; private archive/readback PASS; accepted PMD0001 look/motions historical G3R1 only; 0002/0003 newly generated art HOLD; Actor A62 historical run accepted only; correct Ground3 reference SHA PASS; dual semantic scene BLUEPRINT generation PASS; native art Ground/PAR NOT_GENERATED; Game.exe A09 NOT_RUN; new Orca Agent NOT_LAUNCHED; PixelLab paid calls 0; main untouched; formal seal NO.

## Next template gate, not detail retouch
Grow family-level approved source art and masks together for WHOLE tree/house/bridge; replace blank source art slots in both generated scenes with the same kit and produce actual complete Masters. Then native FS 4-layer exporter and user 1x Art. PMD new movement must come from accepted appearance source and per-action XML, not fake direction or frame duplication.